
/*****************************************
* Replacement strings
*****************************************/
static String:g_sConfigMessages_SourceTexts[][] = {"{NORMAL}", "{DARK_RED}", "{PINK}", "{DARK_GREEN}", "{YELLOW}", "{LIGHT_GREEN}", "{LIGHT_RED}", "{GRAY}", "{ORANGE}", "{LIGHT_BLUE}", "{DARK_BLUE}", "{PURPLE}", "{CARRIAGE_RETURN}"};
static String:g_sConfigMessages_DestTexts[][] =    {"\x01",     "\x02",      "\x03",   "\x04",         "\x05",     "\x06",          "\x07",        "\x08",   "\x09",     "\x0B",         "\x0C",        "\x0E",     "\n"};

#define CONFIG_MESSAGES_BEGINNING_COLOR_QUIRK " \x01\x0B"

/*****************************************
* Message languages
*****************************************/
enum configMessages_messageLanguagesNodeElements {
    configMessages_messageLanguagesNodeElement_LangId,
    configMessages_messageLanguagesNodeElement_Text,
    configMessages_messageLanguagesNodeElement_COUNT
}

static configMessages_messageLanguagesNodeElementsSize[_:configMessages_messageLanguagesNodeElement_COUNT] =
{
    1,                  // configMessages_messageLanguagesNodeElement_LangId
    USER_MESSAGES_MAX_SIZE,    // configMessages_messageLanguagesNodeElement_Text
};

stock Handle:configMessages_messageLanguagesCreate()
{
    
    new Handle:messageLanguages = CreateArray(HANDLE_SIZE, _:configMessages_messageLanguagesNodeElement_COUNT);
    
    for (new index = 0; index < _:configMessages_messageLanguagesNodeElement_COUNT; index++)
    {
        SetArrayCell(messageLanguages, index, CreateArray(configMessages_messageLanguagesNodeElementsSize[index]));
    }
    
    return messageLanguages;
}

stock configMessages_messageLanguagesDestroy(Handle:messageLanguages)
{
    for (new index = 0; index < _:configMessages_messageLanguagesNodeElement_COUNT; index++)
    {
        ClearArray( GetArrayCell(messageLanguages, index));
        CloseHandle(GetArrayCell(messageLanguages, index));
    }
    
    ClearArray( messageLanguages);
    CloseHandle(messageLanguages);
}

stock configMessages_messageLanguages_ReplaceSpecials(String:text[], size=sizeof text)
{
    for (new index = 0; index < sizeof(g_sConfigMessages_SourceTexts); index++)
        ReplaceString(text, size, g_sConfigMessages_SourceTexts[index], g_sConfigMessages_DestTexts[index], .caseSensitive = true);
    
    // Quirk to display color at the begining of string if first char is a color
    if (text[0] >= '\x01' && text[0] <= '\x0F' && text[0] != '\n')
        StrInsert(CONFIG_MESSAGES_BEGINNING_COLOR_QUIRK, text, size);
}

stock bool:configMessages_messageLanguages_AddTranslation(Handle:messageLanguages, const String:language[], const String:text[])
{
    new langId = GetLanguageByCode(language);
    
    if (langId == -1)
        return false;
    
    new index = FindValueInArray(GetArrayCell(messageLanguages, _:configMessages_messageLanguagesNodeElement_LangId), langId);
    
    decl String:replacedText[USER_MESSAGES_MAX_SIZE];
    strcopy(replacedText, USER_MESSAGES_MAX_SIZE, text);
    configMessages_messageLanguages_ReplaceSpecials(replacedText);
    
    if (index != -1)
        SetArrayString(GetArrayCell(messageLanguages, _:configMessages_messageLanguagesNodeElement_Text), index, replacedText);
    else
    {
        PushArrayCell(  GetArrayCell(messageLanguages, _:configMessages_messageLanguagesNodeElement_LangId), langId);
        PushArrayString(GetArrayCell(messageLanguages, _:configMessages_messageLanguagesNodeElement_Text),   replacedText);
    }
    
    return true;
}

stock bool:configMessages_messageLanguages_GetTranslation(Handle:messageLanguages, clientIndex, String:text[], textSize=sizeof text)
{
    new messageIndex = FindValueInArray(GetArrayCell(messageLanguages, _:configMessages_messageLanguagesNodeElement_LangId), GetClientLanguage(clientIndex));
    
    if (messageIndex != -1)
    {
        GetArrayString(GetArrayCell(messageLanguages, _:configMessages_messageLanguagesNodeElement_Text), messageIndex, text, textSize);
        return true;
    }
    
    messageIndex = FindValueInArray(GetArrayCell(messageLanguages, _:configMessages_messageLanguagesNodeElement_LangId), GetServerLanguage());
    
    if (messageIndex != -1)
    {
        GetArrayString(GetArrayCell(messageLanguages, _:configMessages_messageLanguagesNodeElement_Text), messageIndex, text, textSize);
        return true;
    }
    
    return false;
}

/*****************************************
* Message Text list
*****************************************/
stock Handle:configMessages_messageTextListCreate()
{
    return CreateArray(HANDLE_SIZE);
}

stock configMessages_messageTextListDestroy(Handle:messageTextList)
{
    new arraySize = GetArraySize(messageTextList);
    
    for (new index = 0; index < arraySize; index++)
    {
        configMessages_messageLanguagesDestroy(GetArrayCell(messageTextList, index));
    }
    
    ClearArray(messageTextList);
    CloseHandle(messageTextList);
}

stock configMessages_messageTextList_Add(Handle:messageTextList)
{
    return PushArrayCell(messageTextList, configMessages_messageLanguagesCreate());
}

stock bool:configMessages_messageTextList_AddTranslation(Handle:messageTextList, index, const String:language[], const String:text[])
{
    return configMessages_messageLanguages_AddTranslation(
                    GetArrayCell(messageTextList, index),
                    language,
                    text
                );
}

stock bool:configMessages_messageTextList_GetTranslation(Handle:messageTextList, index, clientIndex, String:text[], textSize=sizeof text)
{
    new bool:ret = configMessages_messageLanguages_GetTranslation(
                    GetArrayCell(messageTextList, index),
                    clientIndex,
                    text,
                    textSize
                );
    return ret;
}

stock bool:configMessages_messageTextList_GetTextFromDrawCount(Handle:messageTextList, drawCount, clientIndex, String:text[], textSize=sizeof text)
{
    new size = GetArraySize(messageTextList);
    
    if(size > 0)
    {
        new drawItem = (drawCount - 1) % size;
        return configMessages_messageTextList_GetTranslation(messageTextList, drawItem, clientIndex, text,  textSize);
    }
    else
    {
        return false;
    }
}

/*****************************************
* Kv loader and track registered messages
*****************************************/
static Handle:g_hconfigMessages_RegisteredMessageKvSection;
static Handle:g_hconfigMessages_RegisteredMessageTargetHandle;
static Handle:g_hconfigMessages_RegisteredKeepedMessage;
static Handle:g_hconfigMessages_RegisteredUserMessage;

stock configMessages_Init()
{
    g_hconfigMessages_RegisteredMessageKvSection = CreateArray(HANDLE_SIZE);
    g_hconfigMessages_RegisteredMessageTargetHandle = CreateArray(HANDLE_SIZE);
    g_hconfigMessages_RegisteredKeepedMessage = CreateArray(HANDLE_SIZE);
    g_hconfigMessages_RegisteredUserMessage = CreateArray(HANDLE_SIZE);
}

stock configMessages_Clear(bool:keepedAlso)
{
    new size = GetArraySize(g_hconfigMessages_RegisteredMessageKvSection);
    decl keepedIndex;
    
    for (new index = 0; index < _:size; index++)
    {
        keepedIndex = FindValueInArray(g_hconfigMessages_RegisteredKeepedMessage, GetArrayCell(g_hconfigMessages_RegisteredUserMessage, index));
        if(keepedAlso ||  keepedIndex == -1)
        {
            configMessages_messageTextListDestroy(GetArrayCell(g_hconfigMessages_RegisteredMessageTargetHandle, index));
            userMessage_UnRegisterMessage(GetArrayCell(g_hconfigMessages_RegisteredUserMessage, index));
            
            RemoveFromArray(g_hconfigMessages_RegisteredMessageKvSection, index);
            RemoveFromArray(g_hconfigMessages_RegisteredMessageTargetHandle, index);
            RemoveFromArray(g_hconfigMessages_RegisteredUserMessage, index);
            if(keepedAlso && keepedIndex != -1)
                 RemoveFromArray(g_hconfigMessages_RegisteredKeepedMessage, keepedIndex);
            
            size--;
            index--;
        }
    }
}

stock configMessages_Close()
{
    configMessages_Clear(.keepedAlso = true);
    
    CloseHandle(g_hconfigMessages_RegisteredMessageKvSection);
    CloseHandle(g_hconfigMessages_RegisteredMessageTargetHandle);
    CloseHandle(g_hconfigMessages_RegisteredKeepedMessage);
    CloseHandle(g_hconfigMessages_RegisteredUserMessage);    
}

public bool:configMessages_BuildCallBack(clientIndex, argument, drawCount, drawDuration, String:message[], length)
{
    return configMessages_messageTextList_GetTextFromDrawCount(
                                            Handle:argument,
                                            drawCount,
                                            clientIndex,
                                            message,
                                            length
                                        );
}

stock configMessages_RegisterMessageList(bool:keeped,
                                            Handle:messageTextList,
                                            userMessages_MessageDisplayType:displayType,
                                            _:repeatPeriod=0,
                                            _:repeatCount=0,
                                            _:minDisplayTime=0,
                                            _:displayDelay=0,
                                            _:flags=USER_MESSAGES_FLAG_NONE,
                                            _:priority=50,
                                            _:noRedisplayTime=0)
{
    new Handle:userMessage = userMessage_RegisterNewMessage(
                                            displayType,
                                            configMessages_BuildCallBack,
                                            _:messageTextList,
                                            repeatPeriod,
                                            repeatCount,
                                            minDisplayTime,
                                            displayDelay,
                                            flags,
                                            priority,
                                            noRedisplayTime
                                        );
    
    PushArrayCell(g_hconfigMessages_RegisteredUserMessage, userMessage);
    
    if(keeped)
        PushArrayCell(g_hconfigMessages_RegisteredKeepedMessage, userMessage);
}

stock configMessages_LoadTextSection(Handle:keyValues, Handle:messageTextList, const String:section[], const String:name[])
{
    decl String:key[KV_MAX_STRING_SIZE];
    decl String:value[KV_MAX_STRING_SIZE];
    
    
    kvTree_Rewind(keyValues);
    
    if (
        !kvTree_GotoFirstSubKey(keyValues)      || 
        !kvTree_JumpToKey(keyValues, section)   || 
        !kvTree_GotoFirstSubKey(keyValues)      ||
        !kvTree_JumpToKey(keyValues, name)      ||
        !kvTree_GotoFirstSubKey(keyValues)
    )
    {
        LogError("Can't find subsection \"%s\" in section \"%s\" or it is empty", name, section);
        return;
    }
    
    new translations = configMessages_messageTextList_Add(messageTextList);
    
    do{
        
        kvTree_GetValue(keyValues, value, sizeof(value));
        kvTree_GetSectionName(keyValues, key, sizeof(key));
        
        configMessages_messageTextList_AddTranslation(messageTextList, translations, key, value);
        
    } while(kvTree_GotoNextKey(keyValues, false));
}

stock Handle:configMessages_LoadMessageSectionTexts(Handle:keyValues)
{
    decl String:key[KV_MAX_STRING_SIZE];
    decl String:value[KV_MAX_STRING_SIZE];
    
    new Handle:messageTextList = INVALID_HANDLE;
    new sectionSymbol;
    
    if (kvTree_GotoFirstSubKey(keyValues, false))
    {
        messageTextList = configMessages_messageTextListCreate();
        
        do{
            kvTree_GetSectionSymbol(keyValues, sectionSymbol);
            
            kvTree_GetSectionName(keyValues, key, sizeof(key));
            kvTree_GetValue(keyValues, value, sizeof(value), "");
            
            configMessages_LoadTextSection(keyValues, messageTextList, key, value);
            
            kvTree_JumpToKeySymbol(keyValues, sectionSymbol);
            
        } while(kvTree_GotoNextKey(keyValues, false));
        
        kvTree_GoBack(keyValues);
    }
    
    return messageTextList;
}

configMessages_LoadMessageSection_DisplayTarget(const String:value[], &userMessages_MessageDisplayType:displayType)
{
    if (StrEqual(value, "Chat"))
        displayType = eUserMessages_ToChat;
    
    else if (StrEqual(value, "Hint"))
        displayType = eUserMessages_ToHint;
    
    else if (StrEqual(value, "Alert"))
        displayType = eUserMessages_ToCenter;
    
    else
        LogError("Incorrect message Display target \"%s\"", value);
}

configMessages_LoadMessageSection_DisplayEvent(const String:value[], &flags)
{
    if (StrEqual(value, "Spawn"))
        flags = flags | USER_MESSAGES_FLAG_ONSPAWN | USER_MESSAGES_FLAG_CANCEL_ON_DEATH;
    
    else if (StrEqual(value, "Timer"))
        flags = (flags & ~USER_MESSAGES_FLAG_ONSPAWN) | USER_MESSAGES_FLAG_BROADCAST_ON_CONNECT;
    
    else
        LogError("Incorrect message Display event \"%s\"", value);
}

configMessages_LoadMessageSection_Repeat(const String:value[], &flags, &repeatCount)
{
    if (StrEqual(value, "Single"))
        flags = (flags & ~USER_MESSAGES_FLAG_REPEAT_INFINITE);
    
    else if (StrEqual(value, "Infinite"))
        flags = flags | USER_MESSAGES_FLAG_REPEAT_INFINITE;
    
    else if ((repeatCount = StringToInt(value)) > 0)
        flags = (flags & ~USER_MESSAGES_FLAG_REPEAT_INFINITE) | USER_MESSAGES_FLAG_REPEAT;
    
    else
        LogError("Incorrect message Repeat \"%s\"", value);
}

stock configMessages_LoadMessageSection(Handle:keyValues, const String:section[], const String:name[], bool:keeped)
{
    decl sectionSymbol;
    
    kvTree_Rewind(keyValues);
    
    if (!kvTree_GotoFirstSubKey(keyValues) || !kvTree_JumpToKey(keyValues, section) || !kvTree_GotoFirstSubKey(keyValues))
    {
        LogError("Can't find subsection \"%s\" in section \"%s\"", name, section);
        return;
    }
    
    if (!kvTree_JumpToKey(keyValues, name))
    {
        LogError("Can't find subsection \"%s\" in section \"%s\"", name, section);
        return;
    }
    
    kvTree_GetSectionSymbol(keyValues, sectionSymbol);
    
    // If symbol is not already loaded
    if(FindValueInArray(g_hconfigMessages_RegisteredMessageKvSection, sectionSymbol) == -1 && kvTree_GotoFirstSubKey(keyValues, false))
    {
        decl String:key[KV_MAX_STRING_SIZE];
        decl String:value[KV_MAX_STRING_SIZE];
        
        new Handle:messageList = INVALID_HANDLE;
        new userMessages_MessageDisplayType:displayType = eUserMessages_ToChat;
        new repeatPeriod=0;
        new repeatCount=0;
        new minDisplayTime=0;
        new displayDelay=0;
        new flags=USER_MESSAGES_FLAG_NONE;
        new priority=50;
        new noRedisplayTime=0;
        
        do{
            
            kvTree_GetSectionName(keyValues, key, sizeof(key));
            kvTree_GetValue(keyValues, value, sizeof(value), "");
            
            if(StrEqual(key, "DisplayTarget"))
                configMessages_LoadMessageSection_DisplayTarget(value, displayType);
                
            else if(StrEqual(key, "DisplayEvent"))
                configMessages_LoadMessageSection_DisplayEvent(value, flags);
            
            else if(StrEqual(key, "Repeat"))
                configMessages_LoadMessageSection_Repeat(value, flags, repeatCount);
            
            else if(StrEqual(key, "Period"))
                repeatPeriod = StringToInt(value);
            
            else if(StrEqual(key, "Priority"))
                priority = StringToInt(value);
            
            else if(StrEqual(key, "Duration"))
                minDisplayTime = StringToInt(value);
            
            else if(StrEqual(key, "Delay"))
                displayDelay = StringToInt(value);
                
            else if(StrEqual(key, "NoReDisplayTime"))
                noRedisplayTime = StringToInt(value);
            
            else if(StrEqual(key, "Text"))
                messageList = configMessages_LoadMessageSectionTexts(keyValues);
                
            else
                LogError("Unknown message option \"%s\"", key);
                        
        } while (kvTree_GotoNextKey(keyValues, false));
    
        if (messageList == INVALID_HANDLE)
        {
            LogError("No text found in \"%s\".\"%s\"", section, name);
            return;
        }
        
        if(
            (flags & USER_MESSAGES_FLAG_REPEAT) == USER_MESSAGES_FLAG_REPEAT &&
            repeatPeriod < minDisplayTime
        )
        {
            LogError("In \"%s\".\"%s\": Duration shall be lower than Period", section, name);
            return;
        }
        
        if(noRedisplayTime > 0)
            flags = flags & ~USER_MESSAGES_FLAG_CANCEL_ON_DEATH;
        
        
        configMessages_RegisterMessageList(
                                    keeped,
                                    messageList,
                                    displayType,
                                    repeatPeriod,
                                    repeatCount,
                                    minDisplayTime,
                                    displayDelay,
                                    flags,
                                    priority,
                                    noRedisplayTime
                                );
                                
        PushArrayCell(g_hconfigMessages_RegisteredMessageKvSection, sectionSymbol);
        PushArrayCell(g_hconfigMessages_RegisteredMessageTargetHandle, messageList);
    }
}

stock configMessages_UnLoadMessageSection(Handle:keyValues, const String:section[], const String:name[])
{
    decl sectionSymbol;
    
    kvTree_Rewind(keyValues);
    
    if (!kvTree_GotoFirstSubKey(keyValues) || !kvTree_JumpToKey(keyValues, section) || !kvTree_GotoFirstSubKey(keyValues))
    {
        LogError("Can't find subsection \"%s\" in section \"%s\"", name, section);
        return;
    }
    
    if (!kvTree_JumpToKey(keyValues, name))
    {
        LogError("Can't find subsection \"%s\" in section \"%s\"", name, section);
        return;
    }
    
    kvTree_GetSectionSymbol(keyValues, sectionSymbol);
    
    new index = FindValueInArray(g_hconfigMessages_RegisteredMessageKvSection, sectionSymbol);
    
    // If symbol exists loaded
    if(index != -1)
    {
        new Handle:message;
        message = GetArrayCell(g_hconfigMessages_RegisteredUserMessage, index);
        
        if(FindValueInArray(g_hconfigMessages_RegisteredKeepedMessage, message) == -1)
        {
            configMessages_messageTextListDestroy(GetArrayCell(g_hconfigMessages_RegisteredMessageTargetHandle, index));
            userMessage_UnRegisterMessage(message);
            
            RemoveFromArray(g_hconfigMessages_RegisteredMessageKvSection, index);
            RemoveFromArray(g_hconfigMessages_RegisteredMessageTargetHandle, index);
            RemoveFromArray(g_hconfigMessages_RegisteredUserMessage, index);
        }
    }
}