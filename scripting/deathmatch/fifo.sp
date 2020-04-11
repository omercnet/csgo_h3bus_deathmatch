

stock Handle:fifo_Create()
{
    return CreateArray(2);
}

stock fifo_Close(Handle:fifo)
{
    CloseHandle(fifo);
}

stock fifo_Clear(Handle:fifo)
{
    ClearArray(fifo);
}

stock fifo_Size(Handle:fifo)
{
    return GetArraySize(fifo);
}

stock fifo_FindItem(Handle:fifo, any:item)
{
    return FindValueInArray(fifo, item);
}

stock fifo_PushIfNotPresent(Handle:fifo, any:item, Float:time=-1.0)
{
    if(fifo_FindItem(fifo, item) != -1)
    {
        return -1;
    }
    
    new pushedCell = PushArrayCell(fifo, item);
    if(time < 0.0)
        time = GetGameTime();
    
    SetArrayCell(fifo, pushedCell, time, .block = 1);
    
    return pushedCell;
}

stock fifo_PushFirst(Handle:fifo, any:item, Float:time=-1.0, bool:replaceIfPresent=true)
{
    if(!replaceIfPresent)
        fifo_RemoveValue(fifo, item);
    
    if(time < 0.0)
        time = GetGameTime();
        
    if(fifo_Size(fifo) <= 0)
    {
        PushArrayCell(fifo, item);
        SetArrayCell(fifo, 0, time, .block = 1);
    }
    else
    {
        ShiftArrayUp(fifo, 0);
        SetArrayCell(fifo, 0, item);
        SetArrayCell(fifo, 0, time, .block = 1);
    }
}

stock bool:fifo_Pop(Handle:fifo, &any:item=0, &Float:time=0.0)
{
    if(fifo_Size(fifo) <= 0)
        return false;
    
    item = GetArrayCell(fifo, 0);
    time = GetArrayCell(fifo, 0, .block = 1);
    RemoveFromArray(fifo, 0);
    
    return true;
}

stock bool:fifo_GetFirstItem(Handle:fifo, &any:item=0, &Float:time=0.0)
{
    if(fifo_Size(fifo) <= 0)
        return false;
    
    item = GetArrayCell(fifo, 0);
    time = GetArrayCell(fifo, 0, .block = 1);
    
    return true;
}

stock bool:fifo_GetLastItem(Handle:fifo, &any:item=0, &Float:time=0.0)
{
    new length = fifo_Size(fifo)
    if(length <= 0)
        return false;
    
    item = GetArrayCell(fifo, length-1);
    time = GetArrayCell(fifo, length-1, .block = 1);
    
    return true;
}

stock bool:fifo_GetItem(Handle:fifo, index, &any:item=0, &Float:time=0.0)
{
    new length = fifo_Size(fifo);
    if(index >= length)
        return false;
    
    item = GetArrayCell(fifo, index);
    time = GetArrayCell(fifo, index, .block = 1);
    
    return true;
}

stock bool:fifo_SetItemTime(Handle:fifo, index, Float:time=0.0)
{
    new length = fifo_Size(fifo);
    if(index >= length)
        return false;
    
    SetArrayCell(fifo, index, time, .block = 1);
    
    return true;
}

stock bool:fifo_RemoveValue(Handle:fifo, any:item, bool:onlyFirst=false)
{
    decl index;
    new bool:found = false;
    
    while((!onlyFirst || !found) && (index = fifo_FindItem(fifo, item)) != -1)
    {
        found = true;
        RemoveFromArray(fifo, index);
    }
    return found;
}

stock fifo_PrintItems_Debug(Handle:fifo, String:str[])
{
    str[0] = '\0';
    new size = fifo_Size(fifo);
    
    for(new index = 0; index < size; index++)
    {
        new String:buffer[200];
        
        Format(buffer, 200, "%s, %d", str, GetArrayCell(fifo, index));
        strcopy(str, 200, buffer);
    }
}