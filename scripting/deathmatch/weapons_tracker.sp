

enum weaponsTracking_StructureElements {
    weaponsTracking_StructureElement_CTUsers,
    weaponsTracking_StructureElement_TUsers,
    weaponsTracking_StructureElement_CTWaitline,
    weaponsTracking_StructureElement_TWaitline,
    weaponsTracking_StructureElement_COUNT
}

stock Handle:weaponTracking_Create(weaponId)
{
    new Handle:tracker = CreateArray(HANDLE_SIZE, _:weaponsTracking_StructureElement_COUNT);
    
    for (new index = 0; index < _:weaponsTracking_StructureElement_COUNT; index++)
    {
        SetArrayCell(tracker, index, fifo_Create());
    }    
    
    return tracker;
}

stock Handle:weaponTracking_Close(Handle:tracker)
{
    for (new index = 0; index < _:weaponsTracking_StructureElement_COUNT; index++)
    {
        fifo_Close(GetArrayCell(tracker, index));
    }
    
    CloseHandle(tracker);
}

stock Handle:weaponTracking_Clear(Handle:tracker)
{
    for (new index = 0; index < _:weaponsTracking_StructureElement_COUNT; index++)
    {
        fifo_Clear(GetArrayCell(tracker, index));
    }
}

stock weaponTracking_GetUsersCount(Handle:tracker, bool:isCT)
{
    new Handle:fifo = isCT ? GetArrayCell(tracker, (_:weaponsTracking_StructureElement_CTUsers))
                            : GetArrayCell(tracker, (_:weaponsTracking_StructureElement_TUsers));
    
    return fifo_Size(fifo);
}

stock weaponTracking_GetUserByIndex(Handle:tracker, index, bool:isCT)
{
    new Handle:waitFifo = isCT ? GetArrayCell(tracker, (_:weaponsTracking_StructureElement_CTUsers))
                            : GetArrayCell(tracker, (_:weaponsTracking_StructureElement_TUsers));
    
    decl item;
    fifo_GetItem(waitFifo, index, item);
    
    return item;
}

stock weaponTracking_AddUser(Handle:tracker, user, bool:isCT)
{
    new Handle:fifo = isCT ? GetArrayCell(tracker, (_:weaponsTracking_StructureElement_CTUsers))
                            : GetArrayCell(tracker, (_:weaponsTracking_StructureElement_TUsers));
    
    weaponTracking_RemoveWaiter(tracker, user, isCT);
    
    return fifo_PushIfNotPresent(fifo, user);
}

stock bool:weaponTracking_RemoveUser(Handle:tracker, user, bool:isCT)
{
    new Handle:fifo = isCT ? GetArrayCell(tracker, (_:weaponsTracking_StructureElement_CTUsers))
                            : GetArrayCell(tracker, (_:weaponsTracking_StructureElement_TUsers));
    
    return fifo_RemoveValue(fifo, user);
}

stock bool:weaponTracking_IsUsing(Handle:tracker, user, bool:isCT, &index=0)
{
    new Handle:fifo = isCT ? GetArrayCell(tracker, (_:weaponsTracking_StructureElement_CTUsers))
                            : GetArrayCell(tracker, (_:weaponsTracking_StructureElement_TUsers));
    
    index = fifo_FindItem(fifo, user);
    
    return index != -1;
}

stock weaponTracking_GetWaitersCount(Handle:tracker, bool:isCT)
{
    new Handle:waitFifo = isCT ? GetArrayCell(tracker, (_:weaponsTracking_StructureElement_CTWaitline))
                            : GetArrayCell(tracker, (_:weaponsTracking_StructureElement_TWaitline));
    
    return fifo_Size(waitFifo);
}

stock weaponTracking_GetWaiterByIndex(Handle:tracker, index, bool:isCT)
{
    new Handle:waitFifo = isCT ? GetArrayCell(tracker, (_:weaponsTracking_StructureElement_CTWaitline))
                            : GetArrayCell(tracker, (_:weaponsTracking_StructureElement_TWaitline));
    
    decl item;
    fifo_GetItem(waitFifo, index, item);
    
    return item;
}

stock weaponTracking_AddWaiter(Handle:tracker, user, bool:isCT)
{
    new Handle:waitFifo = isCT ? GetArrayCell(tracker, (_:weaponsTracking_StructureElement_CTWaitline))
                            : GetArrayCell(tracker, (_:weaponsTracking_StructureElement_TWaitline));
    new Handle:fifo = isCT ? GetArrayCell(tracker, (_:weaponsTracking_StructureElement_CTUsers))
                            : GetArrayCell(tracker, (_:weaponsTracking_StructureElement_TUsers));
    new index = fifo_PushIfNotPresent(waitFifo, user);
    
    weaponTracking_UpdateTargetTime(fifo, index);
    
    return index;
}

stock bool:weaponTracking_RemoveWaiter(Handle:tracker, user, bool:isCT)
{
    new Handle:waitFifo = isCT ? GetArrayCell(tracker, (_:weaponsTracking_StructureElement_CTWaitline))
                            : GetArrayCell(tracker, (_:weaponsTracking_StructureElement_TWaitline));
    
    return fifo_RemoveValue(waitFifo, user);
}

stock bool:weaponTracking_IsWaiting(Handle:tracker, user, bool:isCT, &index=0)
{
    new Handle:waitFifo = isCT ? GetArrayCell(tracker, (_:weaponsTracking_StructureElement_CTWaitline))
                            : GetArrayCell(tracker, (_:weaponsTracking_StructureElement_TWaitline));
    
    index = fifo_FindItem(waitFifo, user);
    
    return index != -1;
}

stock bool:weaponTracking_FromWaiterToUser(Handle:tracker, &user, bool:isCT)
{
    new Handle:waitFifo = isCT ? GetArrayCell(tracker, (_:weaponsTracking_StructureElement_CTWaitline))
                            : GetArrayCell(tracker, (_:weaponsTracking_StructureElement_TWaitline));
    new Handle:fifo = isCT ? GetArrayCell(tracker, (_:weaponsTracking_StructureElement_CTUsers))
                            : GetArrayCell(tracker, (_:weaponsTracking_StructureElement_TUsers));
    
    new bool:switched = fifo_Pop(waitFifo, user);
    if(switched)
    {        
        fifo_PushIfNotPresent(fifo, user);
    }
    
    return switched;
}

stock weaponTracking_UpdateTargetTime(Handle:usersFifo, index)
{
    if(index < 0)
        return;
    
    new lastUserIndex = fifo_Size(usersFifo) - 1;
    
    if(index > lastUserIndex)
        return;
    
    new Float:assignTime = 0.0;
    fifo_GetItem(usersFifo, index, .time = assignTime);
    
    if(assignTime + g_fConfig_LimitedWeaponsRotationTime < GetGameTime() + g_fConfig_LimitedWeaponsRotationMinTime)
       fifo_SetItemTime(usersFifo, index, GetGameTime() - g_fConfig_LimitedWeaponsRotationTime + g_fConfig_LimitedWeaponsRotationMinTime);
}

stock Float:weaponTracking_GetWaitTime(Handle:tracker, user, bool:isCT, limit, &targetUser=-1, bool:exact=false)
{
    new Handle:fifo = isCT ? GetArrayCell(tracker, (_:weaponsTracking_StructureElement_CTUsers))
                            : GetArrayCell(tracker, (_:weaponsTracking_StructureElement_TUsers));
    new Handle:waitFifo = isCT ? GetArrayCell(tracker, (_:weaponsTracking_StructureElement_CTWaitline))
                            : GetArrayCell(tracker, (_:weaponsTracking_StructureElement_TWaitline));
    
    new Float:assignTime = 0.0;
    new lastWaiterIndex = fifo_Size(waitFifo) - 1;
    new lastUserIndex = fifo_Size(fifo) - 1;
    new waitIndex = -1;
    new Float:gameTime = GetGameTime();
    
    targetUser = -1;
    
    if(!weaponTracking_IsWaiting(tracker, user, isCT, waitIndex))
        waitIndex = lastWaiterIndex+1;
        
    if(waitIndex <= lastUserIndex)
    {
        fifo_GetItem(fifo, waitIndex, .item = targetUser, .time = assignTime);
        assignTime += g_fConfig_LimitedWeaponsRotationTime;
    }
    else if (waitIndex < limit)
    {
        assignTime = gameTime;
    }
    else
    {
        if(lastUserIndex >= (waitIndex % limit))
            fifo_GetItem(fifo, (waitIndex % limit), .item = targetUser, .time = assignTime);
        else
            assignTime = gameTime;
        
        targetUser = -1;
    
        assignTime += ((waitIndex / limit) + 1) * g_fConfig_LimitedWeaponsRotationTime;
    }
    
    if(
        !exact &&
        assignTime < gameTime + g_fConfig_LimitedWeaponsRotationMinTime
       )
       assignTime = gameTime + g_fConfig_LimitedWeaponsRotationMinTime;
    
    return assignTime - gameTime;
}

stock bool:weaponTracking_IsTransfertToUserPending(Handle:tracker, user, bool:isCT)
{
    new Handle:fifo = isCT ? GetArrayCell(tracker, (_:weaponsTracking_StructureElement_CTUsers))
                            : GetArrayCell(tracker, (_:weaponsTracking_StructureElement_TUsers));
    new Handle:waitFifo = isCT ? GetArrayCell(tracker, (_:weaponsTracking_StructureElement_CTWaitline))
                            : GetArrayCell(tracker, (_:weaponsTracking_StructureElement_TWaitline));
    
    if(0 <= fifo_FindItem(fifo, user) < fifo_Size(waitFifo))
        return true;
    else
        return false;
}
