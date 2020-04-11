
static Handle:g_hDhook_Function_EntSelectSpawnPoint = INVALID_HANDLE;
static Handle:g_hDhook_Function_NetworkStateChanged_m_iAmmo = INVALID_HANDLE;
static Handle:g_hDhook_Function_DoImpactEffect = INVALID_HANDLE;

stock dhook_Init()
{
    if (!LibraryExists("dhooks"))
    {
        LogMessage("Dynamic Hooks not found! Resuming without Dhooks features");
        return;
    }
    
    new Handle:gameOffsets = LoadGameConfigFile("deathmatch.games");
    if(gameOffsets == INVALID_HANDLE)
    {
        LogMessage("Deathmatch offsets file for Dynamic Hooks not found! Resuming without Dhooks features");
        return;
    }
    
    new offset;
    
    if((offset = GameConfGetOffset(gameOffsets, "EntSelectSpawnPoint")) != -1)
    {
        g_hDhook_Function_EntSelectSpawnPoint = DHookCreate(offset, HookType_Entity, ReturnType_CBaseEntity, ThisPointer_CBaseEntity, dhook_EntSelectSpawnPoint);
    }
    else
    {
        LogMessage("EntSelectSpawnPoint function offset for Dynamic Hooks not found! Resuming without Dhooks features");
        return;
    }
        
    if((offset = GameConfGetOffset(gameOffsets, "NetworkStateChanged_m_iAmmo")) != -1)
    {
        g_hDhook_Function_NetworkStateChanged_m_iAmmo = DHookCreate(offset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, dhook_NetworkStateChanged_m_iAmmo);
        DHookAddParam(g_hDhook_Function_NetworkStateChanged_m_iAmmo, HookParamType_Int);
    }
    else
    {
        LogMessage("NetworkStateChanged_m_iAmmo function offset for Dynamic Hooks not found! Resuming without Dhooks features");
        return;
    }
    
    if((offset = GameConfGetOffset(gameOffsets, "DoImpactEffect")) != -1)
    {
        g_hDhook_Function_DoImpactEffect = DHookCreate(offset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, dhook_DoImpactEffect);
    }
    else
    {
        LogMessage("g_hDhook_Function_DoImpactEffect function offset for Dynamic Hooks not found! Resuming without Dhooks features");
        return;
    }
    
    CloseHandle(gameOffsets);
}

stock dhook_OnLibraryAdded(const String:name[])
{
    if (StrEqual(name, "dhooks"))
    {
        dhook_Init();
    }
}

stock dhook_OnLibraryRemoved(const String:name[])
{
    if (StrEqual(name, "dhooks"))
    {
        g_hDhook_Function_EntSelectSpawnPoint = INVALID_HANDLE;
        g_hDhook_Function_NetworkStateChanged_m_iAmmo = INVALID_HANDLE;
    }
}

stock dhook_OnClientPutInServer(clientIndex)
{
    if(g_hDhook_Function_EntSelectSpawnPoint != INVALID_HANDLE)
        DHookEntity(g_hDhook_Function_EntSelectSpawnPoint, false, clientIndex);
        
    if(g_hDhook_Function_NetworkStateChanged_m_iAmmo != INVALID_HANDLE)
        DHookEntity(g_hDhook_Function_NetworkStateChanged_m_iAmmo, false, clientIndex);
    
    if(g_hDhook_Function_DoImpactEffect != INVALID_HANDLE)
        DHookEntity(g_hDhook_Function_DoImpactEffect, false, clientIndex);
}

public MRESReturn:dhook_EntSelectSpawnPoint(client, Handle:hReturn)
{
    decl spawnEntity;
    
    if((spawnEntity = spawns_SelectSpawnPoint(client)) != -1)
    {
        DHookSetReturn(hReturn, spawnEntity);
        
        return MRES_Supercede;
    }
    else
        return MRES_Ignored;
}

public MRESReturn:dhook_NetworkStateChanged_m_iAmmo(client, Handle:hParams)
{
    if(!IsValidEntity(client))
        return MRES_Ignored;
    
    new offset = DHookGetParam(hParams, 1);
    offset -= _:GetEntityAddress(client);
    
    weapons_NetworkStateChanged_m_iAmmo(client, offset);
    
    return MRES_Ignored;
}

stock dhook_IsSelectSpawnPointAvailable()
{
    return g_hDhook_Function_EntSelectSpawnPoint != INVALID_HANDLE;
}

stock dhook_IsAmmoNetworkStateChangedAvailable()
{
    return g_hDhook_Function_NetworkStateChanged_m_iAmmo != INVALID_HANDLE;
}

public MRESReturn:dhook_DoImpactEffect(client, Handle:hParams)
{
    if(g_bConfig_Filter_AllAimPunch)
        return MRES_Supercede;
    else
        return MRES_Ignored;
}