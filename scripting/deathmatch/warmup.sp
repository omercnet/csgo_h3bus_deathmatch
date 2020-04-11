
static g_iWarmup_WarmupCount;
static g_iWarmup_WarmUpTime;
static bool:g_bWarmup_WarmupEndNoLoad = false;
static bool:g_bWarmup_WarmupEndExecuteAdminCmd = false;

stock warmup_Start()
{
    config_Load(.warmup = true);
    
    g_iWarmup_WarmUpTime = cvars_GetPluginConvarInt(eCvars_dm_warmup_time);
    
    weapons_ResetUsers();
    menus_Close();
    players_ResetAllClientsSettings();
    players_RespawnAll();
    
    g_iWarmup_WarmupCount = 0;
    g_bWarmup_WarmupEndNoLoad = false;
    g_bWarmup_WarmupEndExecuteAdminCmd = false;
    
    if(g_iWarmup_WarmUpTime > 0)
    {
        cvars_SetExternalCvarInt("mp_do_warmup_period", 1, .backup = false, .keeped = false, .locked = false);
        cvars_SetExternalCvarInt("mp_warmuptime", g_iWarmup_WarmUpTime, .backup = false, .keeped = false, .locked = false);
        cvars_SetExternalCvarInt("mp_warmup_pausetimer", 0, .backup = false, .keeped = false, .locked = false);
        GameRules_SetProp("m_bWarmupPeriod", true, _, _, true);
        GameRules_SetPropFloat("m_fWarmupPeriodEnd", (GetGameTime()+float(g_iWarmup_WarmUpTime)), _, true);
        
        CreateTimer(1.0, Timer_warmupCount, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
    }
    else
    {
        cvars_SetExternalCvarInt("mp_do_warmup_period", 0, .backup = false, .keeped = false, .locked = false);
        cvars_SetExternalCvarInt("mp_warmuptime", g_iWarmup_WarmUpTime, .backup = false, .keeped = false, .locked = false);
        warmup_End();
    }
}

public Action:Timer_warmupCount(Handle:timer)
{
    if(!warmup_IsRunning())
    {
        warmup_End();
        
        return Plugin_Stop;
    }
    else
    {
        GameRules_SetProp("m_bWarmupPeriod", true, _, _, true);
        GameRules_SetPropFloat("m_fWarmupPeriodEnd", GetGameTime()+(float(g_iWarmup_WarmUpTime)-float(g_iWarmup_WarmupCount)), _, true);
        
        new Handle:event = CreateEvent("round_announce_warmup", true);
        if (event != INVALID_HANDLE)
            FireEvent(event);
                
        g_iWarmup_WarmupCount++;
        return Plugin_Continue;
    }
}

stock warmup_End()
{
    if(!g_bWarmup_WarmupEndNoLoad)
        config_Load(.warmup = false);
    
    if(g_bWarmup_WarmupEndExecuteAdminCmd)
        adminCmd_Execute();
    
    GameRules_SetProp("m_bWarmupPeriod", false, _, _, true);
    cvars_SetExternalCvarInt("mp_restartgame", 1, .backup = false, .keeped = false, .locked = false);
    
    if(!g_bWarmup_WarmupEndNoLoad)
    {
        weapons_ResetUsers();
        players_ResetAllClientsSettings();
    }
}

stock bool:warmup_IsRunning()
{
    return g_iWarmup_WarmUpTime > g_iWarmup_WarmupCount;
}

stock warmup_AdminOverrideEndLoad()
{
    g_bWarmup_WarmupEndNoLoad = true;
}

stock warmup_AdminRegisterLoad()
{
    g_bWarmup_WarmupEndExecuteAdminCmd = true;
}
