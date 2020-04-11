
static Handle:g_hMenuFifo_PlayersFifo[MAXPLAYERS + 1];

stock menusFifo_Init()
{
    for(new i = 0; i < sizeof(g_hMenuFifo_PlayersFifo); i++)
        g_hMenuFifo_PlayersFifo[i] = fifo_Create();
}

stock menusFifo_Close()
{
    for(new i = 0; i < sizeof(g_hMenuFifo_PlayersFifo); i++)
        fifo_Close(g_hMenuFifo_PlayersFifo[i]);
}

stock menusFifo_Clear(clientIndex)
{
    fifo_Clear(g_hMenuFifo_PlayersFifo[clientIndex]);
}

stock menusFifo_ClearAll(clientIndex)
{
    for(i = 0; i < sizeof(g_hMenuFifo_PlayersFifo); i++)
        fifo_Clear(g_hMenuFifo_PlayersFifo[i]);
}

stock menusFifo_AddItem(clientIndex, Handle:menu, bool:first=false)
{
    if(first)
        fifo_PushFirst(g_hMenuFifo_PlayersFifo[clientIndex], menu);
    else
        fifo_PushIfNotPresent(g_hMenuFifo_PlayersFifo[clientIndex], menu);
}

stock menusFifo_DisplayMenu(Handle:menu, clientIndex, time, bool:killFirst=false)
{
    if(killFirst)
        fifo_Pop(g_hMenuFifo_PlayersFifo[clientIndex]);
    
    menusFifo_AddItem(clientIndex, menu, .first = true);
    menusFifo_ShowFirst(clientIndex);
}

stock menusFifo_ShowFirst(clientIndex)
{
    decl Handle:menu;
    
    if(fifo_GetFirstItem(g_hMenuFifo_PlayersFifo[clientIndex], menu))
        DisplayMenu(menu, clientIndex, MENU_TIME_FOREVER);
}

stock menusFifo_Remove(clientIndex, Handle:menu)
{
    fifo_RemoveValue(g_hMenuFifo_PlayersFifo[clientIndex], menu);
}

stock menusFifo_IsPending(clientIndex, Handle:menu)
{
    return fifo_FindItem(g_hMenuFifo_PlayersFifo[clientIndex], menu) != -1;
}

public Action:menusFifo_Timer_OnClientSpawn(Handle:timer, any:clientRef)
{
    new clientIndex = EntRefToEntIndex(clientRef);
    if (players_IsClientValid(clientIndex) && IsClientInGame(clientIndex) && IsPlayerAlive(clientIndex))
    {
        menusFifo_ShowFirst(clientIndex);
    }
}

stock menusFifo_OnClientSpawn(clientIndex)
{
    CreateTimer(0.2, menusFifo_Timer_OnClientSpawn, EntIndexToEntRef(clientIndex));
}

stock menusFifo_OnMenuClosed(clientIndex, Handle:menu=INVALID_HANDLE)
{
    if(menu == INVALID_HANDLE)
        fifo_Pop(g_hMenuFifo_PlayersFifo[clientIndex]);
    else
        menusFifo_Remove(clientIndex, menu);
        
    menusFifo_ShowFirst(clientIndex);
}