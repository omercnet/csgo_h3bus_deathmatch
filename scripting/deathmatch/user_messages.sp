#include <functions>

#define USER_MESSAGES_MAX_SIZE 1024
#define USER_MESSAGES_CLIENT_BROADCAST -1

/*****************************************
* Message element definition
*****************************************/
#define USER_MESSAGES_FLAG_NONE                     0
#define USER_MESSAGES_FLAG_REPEAT                   (1 << 0)
#define USER_MESSAGES_FLAG_REPEAT_INFINITE          ((1 << 1) | USER_MESSAGES_FLAG_REPEAT)
#define USER_MESSAGES_FLAG_ONSPAWN                  (1 << 2)
#define USER_MESSAGES_FLAG_CANCEL_ON_MAP_END        (1 << 3)
#define USER_MESSAGES_FLAG_UNREGISTER_ON_MAP_END    (1 << 4)
#define USER_MESSAGES_FLAG_CANCEL_ON_DEATH          (1 << 5)
#define USER_MESSAGES_FLAG_BROADCAST_ON_CONNECT     (1 << 6)


enum userMessages_MessageDisplayType {
    eUserMessages_ToChat,
    eUserMessages_ToHint,
    eUserMessages_ToCenter
}

enum userMessage_MessageStructureElements {
    userMessage_MessageStructureElement_DisplayType,
    userMessage_MessageStructureElement_Flags,
    userMessage_MessageStructureElement_BuildCallBack,
    userMessage_MessageStructureElement_BuildCallBackArgument,
    userMessage_MessageStructureElement_RepeatPeriod,
    userMessage_MessageStructureElement_RepeatCount,
    userMessage_MessageStructureElement_DisplayDuration,
    userMessage_MessageStructureElement_DisplayDelay,
    userMessage_MessageStructureElement_Priority,
    userMessage_MessageStructureElement_NoRedisplayTime,
    userMessage_MessageStructureElement_COUNT
}

functag userMessage_BuildCallBack bool:public(clientIndex, argument, drawCount, drawDuration, String:message[], length);

static Handle:g_hUserMessages_MessagesArray;

stock userMessage_MessageStructureCreate()
{
    g_hUserMessages_MessagesArray = CreateArray(HANDLE_SIZE);
}

stock userMessage_MessageStructureClear()
{
    new size = GetArraySize(g_hUserMessages_MessagesArray);
    
    for (new index = 0; index < size; index++)
    {
        ClearArray( GetArrayCell(g_hUserMessages_MessagesArray), index));
        CloseHandle(GetArrayCell(g_hUserMessages_MessagesArray), index));
    }
    
    ClearArray(g_hUserMessages_MessagesArray);
}

stock userMessage_MessageStructureDestroy()
{
    userMessage_MessageStructureClear();
    
    CloseHandle(g_hUserMessages_MessagesArray);
}

stock Handle:userMessage_MessageStructure_Add(  userMessages_MessageDisplayType:displayType,
                                                userMessage_BuildCallBack:buildcallBack,
                                                _:buildcallBackArgument,
                                                _:repeatPeriod=0,
                                                _:repeatCount=0,
                                                _:minDisplayTime=0,
                                                _:displayDelay=0,
                                                _:flags=USER_MESSAGES_FLAG_NONE,
                                                _:priority=50,
                                                _:noRedisplayTime=0)
{
    new Handle:message = CreateArray(1, _:userMessage_MessageStructureElement_COUNT);
    
    SetArrayCell(message, _:userMessage_MessageStructureElement_DisplayType,           displayType);
    SetArrayCell(message, _:userMessage_MessageStructureElement_Flags,                 flags);
    SetArrayCell(message, _:userMessage_MessageStructureElement_BuildCallBack,         buildcallBack);
    SetArrayCell(message, _:userMessage_MessageStructureElement_BuildCallBackArgument, buildcallBackArgument);
    SetArrayCell(message, _:userMessage_MessageStructureElement_RepeatPeriod,          repeatPeriod);
    SetArrayCell(message, _:userMessage_MessageStructureElement_RepeatCount,           repeatCount);
    SetArrayCell(message, _:userMessage_MessageStructureElement_DisplayDuration,       minDisplayTime);
    SetArrayCell(message, _:userMessage_MessageStructureElement_DisplayDelay,          displayDelay);
    SetArrayCell(message, _:userMessage_MessageStructureElement_Priority,              priority);
    SetArrayCell(message, _:userMessage_MessageStructureElement_NoRedisplayTime,       noRedisplayTime);
    
    PushArrayCell(g_hUserMessages_MessagesArray, message);
    
    return message;
}

stock userMessage_MessageStructure_Remove(Handle:id)
{
    new index = FindValueInArray(g_hUserMessages_MessagesArray, id);
    
    ClearArray(id);
    CloseHandle(id);
    
    if (index != -1)
        RemoveFromArray(g_hUserMessages_MessagesArray, index);
}

stock userMessages_MessageDisplayType:userMessage_MessageStructure_GetDisplayType(Handle:id)
{
    return userMessages_MessageDisplayType:GetArrayCell(id, _:userMessage_MessageStructureElement_DisplayType);
}

stock bool:userMessage_MessageStructure_HasFlags(Handle:id, flag)
{
    return flag == (GetArrayCell(id, _:userMessage_MessageStructureElement_Flags) & flag);
}

stock bool:userMessage_MessageStructure_CallBuildCallBack(Handle:id, clientIndex, drawCount, drawDuration, String:message[], length)
{
    new Function:callback = GetArrayCell(id, _:userMessage_MessageStructureElement_BuildCallBack);
    new argument = GetArrayCell(id, _:userMessage_MessageStructureElement_BuildCallBackArgument);
    decl bool:result;
    
    Call_StartFunction(INVALID_HANDLE, callback);
    Call_PushCell(clientIndex);
    Call_PushCell(argument);
    Call_PushCell(drawCount);
    Call_PushCell(drawDuration);
    Call_PushStringEx(message, length, 0, SM_PARAM_COPYBACK);
    Call_PushCell(length);
    
    Call_Finish(_:result);
    
    return result;
}

stock userMessage_MessageStructure_GetRepeatPeriod(Handle:id)
{
    return GetArrayCell(id, _:userMessage_MessageStructureElement_RepeatPeriod);
}

stock userMessage_MessageStructure_GetRepeatCount(Handle:id)
{
    return GetArrayCell(id, _:userMessage_MessageStructureElement_RepeatCount);
}

stock userMessage_MessageStructure_GetDisplayDuration(Handle:id)
{
    return GetArrayCell(id, _:userMessage_MessageStructureElement_DisplayDuration);
}

stock userMessage_MessageStructure_GetDisplayDelay(Handle:id)
{
    return GetArrayCell(id, _:userMessage_MessageStructureElement_DisplayDelay);
}

stock userMessage_MessageStructure_GetPriority(Handle:id)
{
    return GetArrayCell(id, _:userMessage_MessageStructureElement_Priority);
}

stock userMessage_MessageStructure_GetNoRedisplayTime(Handle:id)
{
    return GetArrayCell(id, _:userMessage_MessageStructureElement_NoRedisplayTime);
}

stock bool:userMessage_MessageStructure_IsDisplayed(Handle:id, displayStart, currentTime)
{
    return  displayStart <= currentTime &&
            currentTime <= displayStart + userMessage_MessageStructure_GetDisplayDuration(id);
}

stock bool:userMessage_MessageStructure_ShallBeDisplayed(Handle:id, displayStart, currentTime, &bool:shallBeSkipped=false)
{
    if(userMessage_MessageStructure_GetDisplayType(id) == eUserMessages_ToChat)
    {
        if(displayStart == currentTime)
        {
            shallBeSkipped = false;
            return true;
        }
        else
        {
            shallBeSkipped = displayStart < currentTime &&  currentTime <= displayStart + userMessage_MessageStructure_GetNoRedisplayTime(id);
            return false;
        }
    }
    else
    {
        if (displayStart <= currentTime && currentTime <= displayStart + userMessage_MessageStructure_GetDisplayDuration(id))
        {
            shallBeSkipped = false;
            return true;
        }
        else
        {
            shallBeSkipped = displayStart + userMessage_MessageStructure_GetDisplayDuration(id) < currentTime &&  currentTime <= displayStart + userMessage_MessageStructure_GetNoRedisplayTime(id);
            return false;
        } 
    }
}

stock bool:userMessage_MessageStructure_ShallBeDropped(Handle:id, displayStart, currentTime, bool:forced=false, &bool:shallBeSkipped=false)
{   
    if(
        forced &&
            (
                displayStart < currentTime &&
                displayStart + userMessage_MessageStructure_GetNoRedisplayTime(id) < currentTime
            )
       )
    {
        return true;
    }
    else if(userMessage_MessageStructure_GetDisplayType(id) == eUserMessages_ToChat)
    {
        if(displayStart == currentTime)
        {
            shallBeSkipped = false;
        }
        else
        {
            shallBeSkipped = displayStart < currentTime &&  currentTime <= displayStart + userMessage_MessageStructure_GetNoRedisplayTime(id);
        }
    }
    else
    {
        if (displayStart <= currentTime && currentTime <= displayStart + userMessage_MessageStructure_GetDisplayDuration(id))
        {
            shallBeSkipped = false;
        }
        else
        {
            shallBeSkipped = displayStart + userMessage_MessageStructure_GetDisplayDuration(id) < currentTime &&  currentTime <= displayStart + userMessage_MessageStructure_GetNoRedisplayTime(id);
        } 
    }
    
    return displayStart + userMessage_MessageStructure_GetDisplayDuration(id) < currentTime && displayStart + userMessage_MessageStructure_GetNoRedisplayTime(id) < currentTime;
}

stock userMessage_MessageStructure_Print(Handle:id, clientIndex, String:message[], size=sizeof message)
{    
    switch (userMessage_MessageStructure_GetDisplayType(id))
    {
        case eUserMessages_ToChat:
            if (clientIndex == USER_MESSAGES_CLIENT_BROADCAST)
                PrintToChatAll(message);
            else if (IsClientInGame(clientIndex))
                PrintToChat(clientIndex, message);
        
        case eUserMessages_ToHint:                
            if (clientIndex == USER_MESSAGES_CLIENT_BROADCAST)
                PrintHintTextToAll(message);
            else if (IsClientInGame(clientIndex))
                PrintHintText(clientIndex, message);
        
        case eUserMessages_ToCenter:
            if (clientIndex == USER_MESSAGES_CLIENT_BROADCAST)
                PrintCenterTextAll(message);
            else if (IsClientInGame(clientIndex))
                PrintCenterText(clientIndex, message);
    }
}

stock userMessage_MessageStructure_Execute(Handle:id, clientIndex, Handle:callerQueue, currentTime, drawCount, drawDuration, bool:noRepeat)
{
    decl String:message[USER_MESSAGES_MAX_SIZE];
        
    if (userMessage_MessageStructure_CallBuildCallBack(id, clientIndex, drawCount+1, drawDuration, message, USER_MESSAGES_MAX_SIZE))
    {
        userMessage_MessageStructure_Print(id, clientIndex, message);
    }
    
    if (
            !noRepeat &&
            userMessage_MessageStructure_HasFlags(id, USER_MESSAGES_FLAG_REPEAT) &&
            (
                userMessage_MessageStructure_HasFlags(id, USER_MESSAGES_FLAG_REPEAT_INFINITE) ||
                drawCount+1 < userMessage_MessageStructure_GetRepeatCount(id)
            )
        )
    {
        userMessage_MessageStructure_RegisterRepeatInQueue(id, callerQueue, currentTime, drawCount+1);
    }
}

stock userMessage_MessageStructure_RegisterRepeatInQueue(Handle:id, Handle:targetQueue, currentTime, drawCount)
{
    new period = userMessage_MessageStructure_GetRepeatPeriod(id);
    
    if (period > 0 && targetQueue != INVALID_HANDLE)
    {
        userMessage_MessageQueueDisplay_InsertMessage(targetQueue, currentTime + period, currentTime, drawCount, id);
    }
}

/*****************************************
* Message queue definition
*****************************************/
enum userMessage_MessageQueueNodeElements {
    userMessage_MessageQueueNodeElement_MessageId,
    userMessage_MessageQueueNodeElement_DisplayTime,
    userMessage_MessageQueueNodeElement_DrawCount,
    userMessage_MessageQueueNodeElement_COUNT
}

static userMessage_MessageQueueNodeElementsSize[_:userMessage_MessageQueueNodeElement_COUNT] =
{
    1, // userMessage_MessageQueueNodeElement_MessageId
    1, // userMessage_MessageQueueNodeElement_DisplayTime
    1, // userMessage_MessageQueueNodeElement_DrawCount
};

enum userMessage_MessageQueueDisplays{
    userMessage_MessageQueueDisplays_ToChat,
    userMessage_MessageQueueDisplays_ToHintAndCenter,
    userMessage_MessageQueueDisplays_COUNT
}

stock Handle:userMessage_MessageQueueCreate()
{
    new Handle:messageQueue = CreateArray(HANDLE_SIZE, _:userMessage_MessageQueueDisplays_COUNT);
    decl Handle:messageQueueDisplay;
    
    for (new queueIndex = 0; queueIndex < _: userMessage_MessageQueueDisplays_COUNT; queueIndex++)
    {
        messageQueueDisplay = CreateArray(HANDLE_SIZE, _:userMessage_MessageQueueNodeElement_COUNT);
        SetArrayCell(messageQueue, queueIndex, messageQueueDisplay);
        
        for (new index = 0; index < _:userMessage_MessageQueueNodeElement_COUNT; index++)
        {
            SetArrayCell(messageQueueDisplay, index, CreateArray(userMessage_MessageQueueNodeElementsSize[index]));
        }
    }
    
    return messageQueue;
}

stock userMessage_MessageQueueClear(Handle:messageQueue)
{
    decl Handle:messageQueueDisplay;
    
    for (new queueIndex = 0; queueIndex < _: userMessage_MessageQueueDisplays_COUNT; queueIndex++)
    {
        messageQueueDisplay = GetArrayCell(messageQueue, queueIndex);
        
        for (new index = 0; index < _:userMessage_MessageQueueNodeElement_COUNT; index++)
        {
            ClearArray(GetArrayCell(messageQueueDisplay, index));
        }
    }
}

stock userMessage_MessageQueueDestroy(Handle:messageQueue)
{
    decl Handle:messageQueueDisplay;
    
    for (new queueIndex = 0; queueIndex < _: userMessage_MessageQueueDisplays_COUNT; queueIndex++)
    {
        messageQueueDisplay = GetArrayCell(messageQueue, queueIndex);
        
        for (new index = 0; index < _:userMessage_MessageQueueNodeElement_COUNT; index++)
        {
            ClearArray(GetArrayCell(messageQueueDisplay, index));
            CloseHandle(GetArrayCell(messageQueueDisplay, index));
        }
        
        ClearArray( messageQueueDisplay);
        CloseHandle(messageQueueDisplay);
    }
    
    ClearArray( messageQueue);
    CloseHandle(messageQueue);
}

stock Handle:userMessage_MessageQueueDisplay_GetMessageId(Handle:queueDisplay, index)
{
    return GetArrayCell(GetArrayCell(queueDisplay, _:userMessage_MessageQueueNodeElement_MessageId), index);
}

stock userMessage_MessageQueueDisplay_GetDisplayTime(Handle:queueDisplay, index)
{
    return GetArrayCell(GetArrayCell(queueDisplay, _:userMessage_MessageQueueNodeElement_DisplayTime), index);
}

stock userMessage_MessageQueueDisplay_SetDisplayTime(Handle:queueDisplay, index, time)
{
    SetArrayCell(GetArrayCell(queueDisplay, _:userMessage_MessageQueueNodeElement_DisplayTime), index, time);
}

stock userMessage_MessageQueueDisplay_GetDrawCount(Handle:queueDisplay, index)
{
    return GetArrayCell(GetArrayCell(queueDisplay, _:userMessage_MessageQueueNodeElement_DrawCount), index);
}

stock userMessage_MessageQueueDisplay_SetDrawCount(Handle:queueDisplay, index, count)
{
    SetArrayCell(GetArrayCell(queueDisplay, _:userMessage_MessageQueueNodeElement_DrawCount), index, count);
}

stock userMessage_MessageQueueDisplay_IncDrawCount(Handle:queueDisplay, index)
{
    userMessage_MessageQueue_SetDrawCount(queueDisplay, index, userMessage_MessageQueue_GetDrawCount(queueDisplay, index) + 1);
}

stock userMessage_MessageQueueDisplay_Length(Handle:queueDisplay)
{
    return GetArraySize(GetArrayCell(queueDisplay, _:userMessage_MessageQueueNodeElement_MessageId));
}

stock InsertArrayCell(Handle:array, index, any:value)
{
    ShiftArrayUp(array, index);
    SetArrayCell(array, index, value);
}

stock userMessage_MessageQueueDisplay_ApplyTimeOffset(Handle:queueDisplay, offset)
{
    new queueSize = userMessage_MessageQueueDisplay_Length(queueDisplay);
    
    for (new index = 0; index < queueSize; index++)
        userMessage_MessageQueueDisplay_SetDisplayTime(
                    queueDisplay,
                    index,
                    userMessage_MessageQueueDisplay_GetDisplayTime(queueDisplay, index) + offset
                );
}

stock userMessage_MessageQueueDisplay_UpdateQueueTimes(Handle:queueDisplay, pIindex)
{
    new index = pIindex;
    new bool:timeUpdated = true;
    new queueSize = userMessage_MessageQueueDisplay_Length(queueDisplay);
    decl minimumTime;
    
    while(index < queueSize && timeUpdated)
    {
        timeUpdated = false;
        minimumTime = userMessage_MessageQueueDisplay_GetDisplayTime(queueDisplay, index);
        minimumTime += userMessage_MessageStructure_GetDisplayDuration(userMessage_MessageQueueDisplay_GetMessageId(queueDisplay, index)) + 1;
        
        index++;
        
        if (index < queueSize && minimumTime > userMessage_MessageQueueDisplay_GetDisplayTime(queueDisplay, index))
        {
            timeUpdated = true;
            userMessage_MessageQueueDisplay_SetDisplayTime(queueDisplay, index, minimumTime);
        }
    }
}

stock userMessage_MessageQueueDisplay_InsertMessage(Handle:queueDisplay, time, currentTime, drawCount, Handle:messageId)
{
    new queueSize = userMessage_MessageQueueDisplay_Length(queueDisplay);
    
    new index = 0;
    
    // Check if we can insert this message due to no redisplay
    if(userMessage_MessageStructure_GetNoRedisplayTime(messageId) > 0)
    {
        while (
                index < queueSize && 
                userMessage_MessageQueueDisplay_GetMessageId(queueDisplay, index) != messageId
            )
            index++;
        
        if(
            index < queueSize &&
            userMessage_MessageQueueDisplay_GetDisplayTime(queueDisplay, index) + userMessage_MessageStructure_GetNoRedisplayTime(messageId) >= time
           )
           return;
    }
    
    index = 0;
    
    // Go after earlier messages
    while (
            index < queueSize &&
            userMessage_MessageQueueDisplay_GetDisplayTime(queueDisplay, index) <= time
        )
        index++;
    
    // Insert after this message if we overlap its display time and have less priority
    while (
        index < queueSize &&
        userMessage_MessageStructure_IsDisplayed(
            userMessage_MessageQueueDisplay_GetMessageId(queueDisplay, index),
            userMessage_MessageQueueDisplay_GetDisplayTime(queueDisplay, index),
            time) &&
        userMessage_MessageStructure_GetPriority(userMessage_MessageQueueDisplay_GetMessageId(queueDisplay, index)) >= userMessage_MessageStructure_GetPriority(messageId)
        )
            index++;
    
    // Last element?
    if (index == queueSize)
    {
        PushArrayCell(GetArrayCell(queueDisplay, _:userMessage_MessageQueueNodeElement_MessageId), messageId);
        PushArrayCell(GetArrayCell(queueDisplay, _:userMessage_MessageQueueNodeElement_DisplayTime), time);
        PushArrayCell(GetArrayCell(queueDisplay, _:userMessage_MessageQueueNodeElement_DrawCount), drawCount);
    }
    else
    {
        InsertArrayCell(GetArrayCell(queueDisplay, _:userMessage_MessageQueueNodeElement_MessageId),   index, messageId);
        InsertArrayCell(GetArrayCell(queueDisplay, _:userMessage_MessageQueueNodeElement_DisplayTime), index, time);
        InsertArrayCell(GetArrayCell(queueDisplay, _:userMessage_MessageQueueNodeElement_DrawCount), index, drawCount);
    }
    
    // Start updating display times from last message
    if (index > 0) index--;
    
    userMessage_MessageQueueDisplay_UpdateQueueTimes(queueDisplay, index);
}

stock userMessage_MessageQueueDisplay_RemoveMessage(Handle:queueDisplay, Handle:messageId)
{
    new queueSize = userMessage_MessageQueueDisplay_Length(queueDisplay);
    
    new index = 0;
    
    while (index < queueSize)
    {
        if (userMessage_MessageQueueDisplay_GetMessageId(queueDisplay, index) == messageId)
        {
            RemoveFromArray(GetArrayCell(queueDisplay, _:userMessage_MessageQueueNodeElement_MessageId), index);
            RemoveFromArray(GetArrayCell(queueDisplay, _:userMessage_MessageQueueNodeElement_DisplayTime), index);
            RemoveFromArray(GetArrayCell(queueDisplay, _:userMessage_MessageQueueNodeElement_DrawCount), index);
            queueSize--;
        }
        else
            index++;
    }
}

stock userMessage_MessageQueueDisplay_Prune(Handle:queueDisplay, currentTime, bool:forced=false)
{
    new queueSize = userMessage_MessageQueueDisplay_Length(queueDisplay);
    new bool:shallBeSkipped = false;
    new index = 0;
            
    while ( 
            queueSize > index &&
            (
                userMessage_MessageStructure_ShallBeDropped(
                        userMessage_MessageQueueDisplay_GetMessageId(queueDisplay, index),
                        userMessage_MessageQueueDisplay_GetDisplayTime(queueDisplay, index),
                        currentTime,
                        forced,
                        shallBeSkipped
                    )
                ||
                shallBeSkipped
            )
        )
    {
        if(!shallBeSkipped)
        {
            RemoveFromArray(GetArrayCell(queueDisplay, _:userMessage_MessageQueueNodeElement_MessageId), index);
            RemoveFromArray(GetArrayCell(queueDisplay, _:userMessage_MessageQueueNodeElement_DisplayTime), index);
            RemoveFromArray(GetArrayCell(queueDisplay, _:userMessage_MessageQueueNodeElement_DrawCount), index);
            queueSize--;
        }
        else
        {
            index++;
        }
    }
}

stock userMessage_MessageQueueDisplay_Execute(Handle:queueDisplay, clientIndex, currentTime)
{
    userMessage_MessageQueueDisplay_Prune(queueDisplay, currentTime);
    new queueSize = userMessage_MessageQueueDisplay_Length(queueDisplay);
    
    new index = 0;
    new bool:shallBeSkipped = false;
    
    while(  index < queueSize &&
            (
                userMessage_MessageStructure_ShallBeDisplayed(
                                userMessage_MessageQueueDisplay_GetMessageId(queueDisplay, index),
                                userMessage_MessageQueueDisplay_GetDisplayTime(queueDisplay, index),
                                currentTime,
                                shallBeSkipped)
                ||
                shallBeSkipped
            )
        )
    {
        if(!shallBeSkipped)
        {
            userMessage_MessageStructure_Execute(
                    userMessage_MessageQueueDisplay_GetMessageId(queueDisplay, index), 
                    clientIndex, 
                    queueDisplay, 
                    currentTime,
                    userMessage_MessageQueueDisplay_GetDrawCount(queueDisplay, index),
                    currentTime - userMessage_MessageQueueDisplay_GetDisplayTime(queueDisplay, index),
                    userMessage_MessageQueueDisplay_GetDisplayTime(queueDisplay, index) != currentTime);
        }
        
        index++;
    }
}

/*****************************************
* Queue wrappers
*****************************************/
stock Handle:userMessages_MessageQueue_GetDisplayQueueFromMessage(Handle:queue, Handle:messageId)
{
    new userMessages_MessageDisplayType:displayType = userMessage_MessageStructure_GetDisplayType(messageId);
    
    switch(displayType)
    {
        case eUserMessages_ToChat:      return GetArrayCell(queue, _:userMessage_MessageQueueDisplays_ToChat);
        case eUserMessages_ToHint:      return GetArrayCell(queue, _:userMessage_MessageQueueDisplays_ToHintAndCenter);
        case eUserMessages_ToCenter:    return GetArrayCell(queue, _:userMessage_MessageQueueDisplays_ToHintAndCenter);
    }
    return INVALID_HANDLE;
}

userMessage_MessageQueue_InsertMessage(Handle:queue, time, currentTime, drawCount, Handle:messageId)
{
    userMessage_MessageQueueDisplay_InsertMessage(
                userMessages_MessageQueue_GetDisplayQueueFromMessage(queue, messageId),
                time,
                currentTime,
                drawCount,
                messageId
            );
}

userMessage_MessageQueue_RemoveMessage(Handle:queue, Handle:messageId)
{
    userMessage_MessageQueueDisplay_RemoveMessage(
                userMessages_MessageQueue_GetDisplayQueueFromMessage(queue, messageId),
                messageId
             );
}

userMessage_MessageQueue_ApplyTimeOffset(Handle:queue, offset)
{
    for (new queueIndex = 0; queueIndex < _: userMessage_MessageQueueDisplays_COUNT; queueIndex++)
    {
        userMessage_MessageQueueDisplay_ApplyTimeOffset(
                    GetArrayCell(queue, _:queueIndex),
                    offset
                );
    }
}

stock userMessage_MessageQueue_Prune(Handle:queue, currentTime, bool:forced=false)
{
    for (new queueIndex = 0; queueIndex < _: userMessage_MessageQueueDisplays_COUNT; queueIndex++)
    {
        userMessage_MessageQueueDisplay_Prune(
                    GetArrayCell(queue, _:queueIndex),
                    currentTime,
                    forced
                );
    }
}

stock userMessage_MessageQueue_Execute(Handle:queue, clientIndex, currentTime)
{
    for (new queueIndex = 0; queueIndex < _: userMessage_MessageQueueDisplays_COUNT; queueIndex++)
    {
        userMessage_MessageQueueDisplay_Execute(
                    GetArrayCell(queue, _:queueIndex),
                    clientIndex,
                    currentTime
                );
    }
}

/*****************************************
* Main functions
*****************************************/
static Handle:g_hUserMessage_OnSpawnMessages;
static Handle:g_hUserMessage_BroadcastMessages;
static Handle:g_hUserMessage_ToBeRemovedOnDeath;
static Handle:g_hUserMessage_ToBeRemovedOnMapEnd;
static Handle:g_hUserMessage_ClientsQueues[MAXPLAYERS + 1];

static g_iUserMessage_CurrentTime;

stock userMessage_Init()
{
    userMessage_MessageStructureCreate();
    
    g_hUserMessage_OnSpawnMessages = CreateArray(HANDLE_SIZE);
    g_hUserMessage_BroadcastMessages = CreateArray(HANDLE_SIZE);
    g_hUserMessage_ToBeRemovedOnDeath = CreateArray(HANDLE_SIZE);
    g_hUserMessage_ToBeRemovedOnMapEnd = CreateArray(HANDLE_SIZE);
    
    for(new index = 0; index < MAXPLAYERS + 1; index++)
        g_hUserMessage_ClientsQueues[index] = userMessage_MessageQueueCreate();
    
    g_iUserMessage_CurrentTime = 0;
    
    CreateTimer(1.0, userMessage_Worker, _, TIMER_REPEAT);
}

stock userMessage_EnqueueMessageList(Handle:messageList, clientIndex, timeOffset=0)
{
    new messagesCount = GetArraySize(messageList);
    decl Handle:messageId;
        
    for(new index = 0; index <  messagesCount; index++)
    {
        messageId = GetArrayCell(messageList, index);
    
        userMessage_MessageQueue_InsertMessage(
            g_hUserMessage_ClientsQueues[clientIndex],
            g_iUserMessage_CurrentTime + timeOffset,
            g_iUserMessage_CurrentTime,
            0,
            messageId);
    }
    
    return messagesCount;
}

stock userMessage_AddMessageInList(Handle:messageList, Handle:id)
{
    if (FindValueInArray(messageList, id) == -1)
    {
        PushArrayCell(messageList, id);
    }
}

stock Handle:userMessage_RegisterNewMessage(userMessages_MessageDisplayType:displayType,
                                            userMessage_BuildCallBack:buildcallBack,
                                            _:buildcallBackArgument,
                                            _:repeatPeriod=0,
                                            _:repeatCount=0,
                                            _:minDisplayTime=0,
                                            _:displayDelay=0,
                                            _:flags=USER_MESSAGES_FLAG_NONE,
                                            _:priority=50,
                                            _:noRedisplayTime=0)
{
    new Handle:id = userMessage_MessageStructure_Add(displayType, buildcallBack, buildcallBackArgument, repeatPeriod, repeatCount, minDisplayTime, displayDelay, flags, priority, noRedisplayTime);
    
    if (userMessage_MessageStructure_HasFlags(id, USER_MESSAGES_FLAG_ONSPAWN))
        userMessage_AddMessageInList(g_hUserMessage_OnSpawnMessages, id);
    
    if (userMessage_MessageStructure_HasFlags(id, USER_MESSAGES_FLAG_CANCEL_ON_MAP_END))
        userMessage_AddMessageInList(g_hUserMessage_ToBeRemovedOnMapEnd, id);
    
    if (userMessage_MessageStructure_HasFlags(id, USER_MESSAGES_FLAG_CANCEL_ON_DEATH))
        userMessage_AddMessageInList(g_hUserMessage_ToBeRemovedOnDeath, id);
    
    if (userMessage_MessageStructure_HasFlags(id, USER_MESSAGES_FLAG_BROADCAST_ON_CONNECT))
        userMessage_RequestDisplay(id, USER_MESSAGES_CLIENT_BROADCAST);
    
    return id;
}

stock Handle:userMessage_UnRegisterMessage(Handle:messageId)
{
    userMessage_CancelDisplay(messageId, USER_MESSAGES_CLIENT_BROADCAST);
    
    userMessage_MessageStructure_Remove(messageId);
}

stock userMessage_RequestDisplay(Handle:messageId, clientIndex, timeOffset=0)
{
    if (clientIndex == USER_MESSAGES_CLIENT_BROADCAST)
    {
        userMessage_AddMessageInList(g_hUserMessage_BroadcastMessages, messageId);
        
        for (new index = 0; index < MaxClients + 1; index++)
        {
            if (players_IsClientValid(index))
            {
                userMessage_MessageQueue_InsertMessage(
                    g_hUserMessage_ClientsQueues[index],
                    g_iUserMessage_CurrentTime + timeOffset + userMessage_MessageStructure_GetDisplayDelay(messageId),
                    g_iUserMessage_CurrentTime,
                    0,
                    messageId);
            }
        }
    }
    else if (players_IsClientValid(clientIndex))
    {
        userMessage_MessageQueue_InsertMessage(
            g_hUserMessage_ClientsQueues[clientIndex],
            g_iUserMessage_CurrentTime + timeOffset + userMessage_MessageStructure_GetDisplayDelay(messageId),
            g_iUserMessage_CurrentTime,
            0,
            messageId);
    }
}

stock userMessage_CancelDisplay(Handle:messageId, clientIndex)
{
    if (clientIndex == USER_MESSAGES_CLIENT_BROADCAST)
    {
        decl messageIndex;
        
        if((messageIndex = FindValueInArray(g_hUserMessage_OnSpawnMessages, messageId)) != -1)
            RemoveFromArray(g_hUserMessage_OnSpawnMessages, messageIndex);
        
        if((messageIndex = FindValueInArray(g_hUserMessage_BroadcastMessages, messageId)) != -1)
            RemoveFromArray(g_hUserMessage_BroadcastMessages, messageIndex);
        
        if((messageIndex = FindValueInArray(g_hUserMessage_ToBeRemovedOnDeath, messageId)) != -1)
            RemoveFromArray(g_hUserMessage_ToBeRemovedOnDeath, messageIndex);
        
        if((messageIndex = FindValueInArray(g_hUserMessage_ToBeRemovedOnMapEnd, messageId)) != -1)
            RemoveFromArray(g_hUserMessage_ToBeRemovedOnMapEnd, messageIndex);
            
        for (new index = 0; index < MaxClients + 1; index++)
            userMessage_CancelDisplay(messageId, index);
    }
    else if (players_IsClientValid(clientIndex))
    {
        userMessage_MessageQueue_RemoveMessage(g_hUserMessage_ClientsQueues[clientIndex], messageId);
    }
}

stock userMessage_OnClientConnected(clientIndex)
{
    userMessage_ClearClientMessages(clientIndex);
    userMessage_EnqueueMessageList(g_hUserMessage_BroadcastMessages, clientIndex);
}

stock userMessage_OnClientDisconnect(clientIndex)
{
    userMessage_ClearClientMessages(clientIndex);
}

stock userMessage_OnClientSpawn(clientIndex)
{
    userMessage_EnqueueMessageList(g_hUserMessage_OnSpawnMessages, clientIndex);
}

stock userMessage_OnClientDeath(clientIndex)
{
    new removeOnDeathSize = GetArraySize(g_hUserMessage_ToBeRemovedOnDeath);
    
    // userMessage_MessageQueue_Prune(g_hUserMessage_ClientsQueues[clientIndex], g_iUserMessage_CurrentTime, .forced = true);
    
    for(new index = 0; index < removeOnDeathSize; index++)
    {
        userMessage_MessageQueue_RemoveMessage(g_hUserMessage_ClientsQueues[clientIndex], GetArrayCell(g_hUserMessage_ToBeRemovedOnDeath, index));
    }
}

stock userMessage_ClearAllClientMessages()
{
    for (new index = 0; index < MAXPLAYERS + 1; index++)
    {
        userMessage_ClearClientMessages(index);
    }
}

stock userMessage_ClearClientMessages(clientIndex)
{
    userMessage_MessageQueueClear(g_hUserMessage_ClientsQueues[clientIndex]);
}

stock userMessage_UnregisterAll()
{
    userMessage_ClearAllClientMessages();
    ClearArray(g_hUserMessage_OnSpawnMessages);
    ClearArray(g_hUserMessage_BroadcastMessages);
    ClearArray(g_hUserMessage_ToBeRemovedOnDeath);
    ClearArray(g_hUserMessage_ToBeRemovedOnMapEnd);
    userMessage_MessageStructureClear();
}

userMessage_clearTimer()
{
    new offset = -g_iUserMessage_CurrentTime;
    
    for (new index = 0; index < MaxClients + 1; index++)
    {
        userMessage_MessageQueue_ApplyTimeOffset(g_hUserMessage_ClientsQueues[index], offset);
    }
    
    g_iUserMessage_CurrentTime = 0;
}

stock userMessage_OnMapEnd()
{
    new removeOnMapEndSize = GetArraySize(g_hUserMessage_ToBeRemovedOnMapEnd);
    
    for(new index = 0; index < removeOnMapEndSize; index++)
    {
        if(userMessage_MessageStructure_HasFlags(GetArrayCell(g_hUserMessage_ToBeRemovedOnMapEnd, index), USER_MESSAGES_FLAG_UNREGISTER_ON_MAP_END))
            userMessage_UnRegisterMessage(GetArrayCell(g_hUserMessage_ToBeRemovedOnMapEnd, index));
        else
            userMessage_CancelDisplay(GetArrayCell(g_hUserMessage_ToBeRemovedOnMapEnd, index), USER_MESSAGES_CLIENT_BROADCAST);
    }
    
    userMessage_clearTimer();
}

public Action:userMessage_Worker(Handle:timer)
{
    for (new index = 0; index < MaxClients + 1; index++)
    {
        if (players_IsClientValid(index))
        {
            if (IsClientInGame(index))
                userMessage_MessageQueue_Execute(g_hUserMessage_ClientsQueues[index], index, g_iUserMessage_CurrentTime);
            else
                userMessage_MessageQueue_ApplyTimeOffset(g_hUserMessage_ClientsQueues[index], 1);
        }
    }
    
    g_iUserMessage_CurrentTime++;
    
    return Plugin_Continue;
}