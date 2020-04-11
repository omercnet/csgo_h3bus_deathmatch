
enum AdminCmd_ExecType
{
    AdminCmd_ExecType_None,
    AdminCmd_ExecType_Immediate,
    AdminCmd_ExecType_ImmediateAndEquip,
    AdminCmd_ExecType_ImmediateAndRespawn,
    AdminCmd_ExecType_ImmediateAndRestartGame,
    AdminCmd_ExecType_NextRound
}

static AdminCmd_ExecType:g_eAdminCmd_PendingExectype = AdminCmd_ExecType_None;
static bool:g_bAdminCmd_PendingLoasAsAMod = false;
static g_iAdminCmd_PendingLoadSection;

stock adminCmd_Init()
{
    // Admin commands
    RegAdminCmd("dm_debug", adminCmd_Debug, ADMFLAG_CHANGEMAP, "DEBUG."); 
    
    RegAdminCmd("sm_dm", adminCmd_showMenu, ADMFLAG_CHANGEMAP, "Display admin menu.");
    
    RegAdminCmd("dm_respawn_all", adminCmd_RespawnAll, ADMFLAG_CHANGEMAP, "Respawns all players.");    
    RegAdminCmd("dm_respawn_dead", adminCmd_RespawnDead, ADMFLAG_CHANGEMAP, "Respawns dead players.");
    RegAdminCmd("dm_load", adminCmd_Load, ADMFLAG_CHANGEMAP, "Load a config section: dm_load \"section\" \"subsection\" [equip|respawn|restart|nextround]");
    RegAdminCmd("dm_load_mod", adminCmd_Load, ADMFLAG_CHANGEMAP, "Load a config section as a modification of what is curretly loaded: dm_load_mod \"section\" \"subsection\" [equip|respawn|restart|nextround]");
   
    RegAdminCmd("dm_weapon_add", adminCmd_WeaponAdd, ADMFLAG_CHANGEMAP, "Add an available weapon: dm_weapon_add <weapon> [<limit>]");
    RegAdminCmd("dm_weapon_remove", adminCmd_WeaponRemove, ADMFLAG_CHANGEMAP, "Remove an available weapon: dm_weapon_remove <weapon>");
    RegAdminCmd("dm_weapon_limit", adminCmd_WeaponLimit, ADMFLAG_CHANGEMAP, "Limit a weapon count. Set limit to -1 for unlimited: dm_weapon_limit <weapon> <limit>");
    
    RegAdminCmd("dm_spawns_show", adminCmd_ToggleEdit, ADMFLAG_CHANGEMAP, "Toggle spawn display mode.");
    RegAdminCmd("dm_spawns_add", adminCmd_SpawnAdd, ADMFLAG_CHANGEMAP, "Add spawn point: dm_spawns_add [T|CT]");
    RegAdminCmd("dm_spawns_delete", adminCmd_SpawnDelete, ADMFLAG_CHANGEMAP, "Remove spawn point at your position");
    RegAdminCmd("dm_spawns_import", adminCmd_ImportMapSpawns, ADMFLAG_CHANGEMAP, "Import current map spawns");
    RegAdminCmd("dm_spawns_save", adminCmd_SpawnSave, ADMFLAG_CHANGEMAP, "Save spawns");
    RegAdminCmd("dm_spawns_test", adminCmd_SpawnTest, ADMFLAG_CHANGEMAP, "Test point dm_spawns_test <first|next|prev>");
    RegAdminCmd("dm_spawns_stats", adminCmd_SpawnStats, ADMFLAG_CHANGEMAP, "Display spawn statistics");
}

public Action:adminCmd_Debug(clientIndex, args)
{
    weapons_debug(clientIndex);
    
    return Plugin_Handled;
}


public Action:adminCmd_showMenu(clientIndex, args)
{
    adminMenu_DisplayRoot(clientIndex);
    
    return Plugin_Handled;
}

stock adminCmd_Execute()
{
    
    if(config_LoadSection(g_hSmcReader_ConfigTree, g_iAdminCmd_PendingLoadSection, warmup_IsRunning(), g_bAdminCmd_PendingLoasAsAMod))
    {
        menus_Close();
        
        if(adminMenu_ShouldResetClientSetting(g_hSmcReader_ConfigTree, g_iAdminCmd_PendingLoadSection))
            players_ResetAllClientsSettings();
        
        switch(g_eAdminCmd_PendingExectype)
        {
            case AdminCmd_ExecType_ImmediateAndEquip:
                players_EquipAll();
                
            case AdminCmd_ExecType_ImmediateAndRespawn:
                players_RespawnAll();
                
            case AdminCmd_ExecType_ImmediateAndRestartGame:
                ServerCommand("mp_restartgame 1");
        }
        
        weapons_EnforceLimits();
        
        g_eAdminCmd_PendingExectype = AdminCmd_ExecType_None;
    }
    else
        LogError("Failure occured while execution admin command");
}

public Action:CS_OnTerminateRound(&Float:delay, &CSRoundEndReason:reason)
{
    if(g_eAdminCmd_PendingExectype == AdminCmd_ExecType_NextRound)
        adminCmd_Execute();
}

public Action:adminCmd_RespawnAll(clientIndex, args)
{
    players_RespawnAll();
    return Plugin_Handled;
}

public Action:adminCmd_RespawnDead(clientIndex, args)
{
    players_RespawnDead();
    return Plugin_Handled;
}

stock adminCmd_Load_ShowActivity()
{
    decl String:sectionName[50];
    decl String:sectionNameFormated[52];
    
    kvTree_JumpToKeySymbol(g_hSmcReader_ConfigTree, g_iAdminCmd_PendingLoadSection);
    adminMenu_GetSectionName(g_hSmcReader_ConfigTree, g_bAdminCmd_PendingLoasAsAMod, sectionName, sizeof(sectionName), .displayName=true);
    
    if(StrEqual(sectionName, ""))
        return;
    
    Format(sectionNameFormated, sizeof(sectionNameFormated), "\x0C%s\x01", sectionName);
    
    for(new client = 1; client <= MaxClients; client++)
    {
        if(IsClientConnected(client) && IsClientInGame(client))
        {
            if(g_eAdminCmd_PendingExectype == AdminCmd_ExecType_NextRound)
                PrintToChat(client, "[ \x02DM\x01 ] %t", "Loaded game mode for next round", sectionNameFormated);
            else
                PrintToChat(client, "[ \x02DM\x01 ] %t", "Loaded game mode", sectionNameFormated);
        }
    }
}

stock adminCmd_Load_Section(section, String:option[], bool:AsMod)
{
    g_iAdminCmd_PendingLoadSection = section;
    g_eAdminCmd_PendingExectype = AdminCmd_ExecType_Immediate;
    g_bAdminCmd_PendingLoasAsAMod = AsMod;
    
    if(StrEqual(option, "equip", false))
        g_eAdminCmd_PendingExectype =AdminCmd_ExecType_ImmediateAndEquip;
        
    else if(StrEqual(option, "respawn", false))
        g_eAdminCmd_PendingExectype = AdminCmd_ExecType_ImmediateAndRespawn;
    
    else if(StrEqual(option, "restart", false))
        g_eAdminCmd_PendingExectype = AdminCmd_ExecType_ImmediateAndRestartGame;
        
    else if(StrEqual(option, "nextround", false))
        g_eAdminCmd_PendingExectype = AdminCmd_ExecType_NextRound;
    
    if(g_eAdminCmd_PendingExectype != AdminCmd_ExecType_NextRound)
        adminCmd_Execute();
    else if(warmup_IsRunning())
    {
        warmup_AdminRegisterLoad();
        if(!g_bAdminCmd_PendingLoasAsAMod)
            warmup_AdminOverrideEndLoad();
    }
    
    adminCmd_Load_ShowActivity();
}

public Action:adminCmd_Load(clientIndex, args)
{
    
    if(GetCmdArgs() != 2 && GetCmdArgs() != 3)
    {
        PrintToConsole(clientIndex, "USAGE: dm_load[_mod] \"section\" \"subsection\" [equip|respawn|restart|nextround]");
        return Plugin_Handled;
    }
    
    
    decl String:cmd[MAX_STRING_SIZE];
    decl String:section[MAX_STRING_SIZE];
    decl String:subSection[MAX_STRING_SIZE];
    
    GetCmdArg(0, cmd, sizeof(cmd));
    GetCmdArg(1, section, sizeof(section));
    GetCmdArg(2, subSection, sizeof(subSection));
    
    StripQuotes(section);
    StripQuotes(subSection);
    
    if(!config_FindSectionId(g_hSmcReader_ConfigTree, section, subSection, g_iAdminCmd_PendingLoadSection))
    {
        PrintToConsole(clientIndex, "Sections \"%s\" \"%s\" not found in Configuration file", section, subSection);
        return Plugin_Handled;
    }
    
    g_eAdminCmd_PendingExectype = AdminCmd_ExecType_Immediate;
    
    if(GetCmdArgs() == 3)
    {
        decl String:option[MAX_STRING_SIZE];
        
        GetCmdArg(3, option, sizeof(option));
        StripQuotes(option);
        
        if(StrEqual(option, "equip", false))
            g_eAdminCmd_PendingExectype =AdminCmd_ExecType_ImmediateAndEquip;
        
        else if(StrEqual(option, "respawn", false))
            g_eAdminCmd_PendingExectype = AdminCmd_ExecType_ImmediateAndRespawn;
        
        else if(StrEqual(option, "restart", false))
            g_eAdminCmd_PendingExectype = AdminCmd_ExecType_ImmediateAndRestartGame;
            
        else if(StrEqual(option, "nextround", false))
            g_eAdminCmd_PendingExectype = AdminCmd_ExecType_NextRound;
        
        else
        {
            g_eAdminCmd_PendingExectype = AdminCmd_ExecType_None;
            PrintToConsole(clientIndex, "Option no recognized \"%s\"", option);
            PrintToConsole(clientIndex, "USAGE: dm_load \"section\" \"subsection\" [respawn|restart|nextround]");
            return Plugin_Handled;
        }
    }
    
    if(StrEqual(cmd, "dm_load_mod", false))
        g_bAdminCmd_PendingLoasAsAMod = true;
    else
        g_bAdminCmd_PendingLoasAsAMod = false;
    
    if(g_eAdminCmd_PendingExectype != AdminCmd_ExecType_NextRound)
        adminCmd_Execute();
    else if(warmup_IsRunning())
    {
        warmup_AdminRegisterLoad();
        if(!g_bAdminCmd_PendingLoasAsAMod)
            warmup_AdminOverrideEndLoad();
    }
    
    adminCmd_Load_ShowActivity();
    
    return Plugin_Handled;
}

public Action:adminCmd_WeaponAdd(clientIndex, args)
{

    if(GetCmdArgs() != 1 && GetCmdArgs() != 2)
    {
        PrintToConsole(clientIndex, "USAGE: dm_weapon_add <weapon> [<limit>]");
        return Plugin_Handled;
    }
    
    decl String:weapon[WEAPON_ENTITIES_NAME_SIZE];
    decl String:limitStr[5];
    decl limit;
    decl weaponId;
    
    GetCmdArg(1, weapon, sizeof(weapon));
    if(GetCmdArgs() == 2)
    {
        GetCmdArg(2, limitStr, sizeof(limitStr));
        limit = StringToInt(limitStr);
    }
    else
        limit = -1;
    
    if(!weapons_FindId(weapon, weaponId))
    {
        PrintToConsole(clientIndex, "Unknown weapon %s", weapon);
        return Plugin_Handled;
    }
    
    if(weapons_AddToWeaponsListed(weaponId))
        PrintToConsole(clientIndex, "Weapon %s is now available", weapon);
    else
        PrintToConsole(clientIndex, "Weapon %s was already available", weapon);
    
    if(weapons_GetLimit(weaponId) != limit)
    {
        weapons_SetLimit(weaponId, limit);
        weapons_EnforceLimits();
        PrintToConsole(clientIndex, "Weapon %s limit set to %d per team", weapon, limit);
    }
    
    return Plugin_Handled;    
}

public Action:adminCmd_WeaponRemove(clientIndex, args)
{

    if(GetCmdArgs() != 1)
    {
        PrintToConsole(clientIndex, "USAGE: dm_weapon_add <weapon>");
        return Plugin_Handled;
    }
    
    decl String:weapon[WEAPON_ENTITIES_NAME_SIZE];
    decl weaponId;
    
    GetCmdArg(1, weapon, sizeof(weapon));
    
    if(!weapons_FindId(weapon, weaponId))
    {
        PrintToConsole(clientIndex, "Unknown weapon %s", weapon);
        return Plugin_Handled;
    }
    
    if(weapons_RemoveFromWeaponsListed(weaponId))
        PrintToConsole(clientIndex, "Weapon %s has been removed", weapon);
    else
        PrintToConsole(clientIndex, "Weapon %s was already not available", weapon);
    
    weapons_SetLimit(weaponId, 0);
    weapons_EnforceLimits();
    
    return Plugin_Handled;    
}

public Action:adminCmd_WeaponLimit(clientIndex, args)
{

    if(GetCmdArgs() != 2)
    {
        PrintToConsole(clientIndex, "USAGE: dm_weapon_limit <weapon> <limit>");
        return Plugin_Handled;
    }
    
    decl String:weapon[WEAPON_ENTITIES_NAME_SIZE];
    decl String:limitStr[5];
    decl limit;
    decl weaponId;
    
    GetCmdArg(1, weapon, sizeof(weapon));
    GetCmdArg(2, limitStr, sizeof(limitStr));
    
    limit = StringToInt(limitStr);
    
    if(!weapons_FindId(weapon, weaponId))
    {
        PrintToConsole(clientIndex, "Unknown weapon %s", weapon);
        return Plugin_Handled;
    }
    
    weapons_SetLimit(weaponId, limit);
    weapons_EnforceLimits();
    
    PrintToConsole(clientIndex, "Weapon %s limit set to %d per team", weapon, limit);
    return Plugin_Handled;    
}

public Action:adminCmd_SpawnAdd(clientIndex, args)
{
    if(GetCmdArgs() > 1)
    {
        PrintToConsole(clientIndex, "USAGE: dm_spawns_add [T|CT]");
        return Plugin_Handled;
    }
    
    decl String:team[3];
    decl bool:result;
    
    GetCmdArg(1, team, sizeof(team));
    
    if(StrEqual(team, "T"))
        result = spawns_CreateNewPoint(clientIndex, Spawns_TeamT);
    else if(StrEqual(team, "CT"))
        result = spawns_CreateNewPoint(clientIndex, Spawns_TeamCT);
    else
        result = spawns_CreateNewPoint(clientIndex, Spawns_TeamBoth);
    
    if(!result)
    {
        PrintToConsole(clientIndex, "No suitable spawn position or too many points");
        PrintToChat(clientIndex, " \x01\x0B\x02Can't create spawn point: No suitable spawn position or too many points");
    }
    else
    {
        PrintToConsole(clientIndex, "Spawn point created");
        PrintToChat(clientIndex, " \x01\x0B\x04Spawn point added");
    }
    
    return Plugin_Handled;
}

public Action:adminCmd_SpawnDelete(clientIndex, args)
{
    if(!spawns_DeleteNearestPoint(clientIndex))
    {
        PrintToConsole(clientIndex, "No spawn point found near you");
        PrintToChat(clientIndex, " \x01\x0B\x02Can't delete spawn point: No spawn point found near you");
    }
    else
    {
        PrintToConsole(clientIndex, "Nearest spawn point deleted");
        PrintToChat(clientIndex, " \x01\x0B\x0CNearest spawn point deleted");
    }
    
    return Plugin_Handled;
}

public Action:adminCmd_ImportMapSpawns(clientIndex, args)
{
    spawns_ImportMapSpawns(clientIndex);
    
    return Plugin_Handled;
}

public Action:adminCmd_SpawnSave(clientIndex, args)
{
    if(spawns_Save())
    {
        PrintToConsole(clientIndex, "Spawn points have been saved");
        PrintToChat(clientIndex, " \x01\x0B\x04Spawn points have been saved");
        spawns_WarnSpawnsCount(clientIndex);
    }
    else
    {
        PrintToConsole(clientIndex, "An error occured while saving spawn points");
        PrintToChat(clientIndex, " \x01\x0B\x02An error occured while saving spawn points");
    }
    
    return Plugin_Handled;
}

public Action:adminCmd_ToggleEdit(clientIndex, args)
{
    spawns_ToggleEdit(clientIndex);
    
    return Plugin_Handled;
}

public Action:adminCmd_SpawnTest(clientIndex, args)
{
    if(GetCmdArgs() != 1)
    {
        PrintToConsole(clientIndex, "USAGE: dm_spawns_test <first|next|prev>");
        return Plugin_Handled;
    }
    
    decl String:whatdowedo[6];
    new bool:res = false;
    
    GetCmdArg(1, whatdowedo, sizeof(whatdowedo));
    
    if(StrEqual(whatdowedo, "first", false))
    {
        res = spawns_SpawnAdminToFirstPoint(clientIndex);
    }
    else if(StrEqual(whatdowedo, "next", false))
    {
        res = spawns_SpawnAdminToNextPoint(clientIndex);
    }
    else if(StrEqual(whatdowedo, "prev", false))
    {
        res = spawns_SpawnAdminToLastPoint(clientIndex);
    }
    else
    {
        PrintToConsole(clientIndex, "USAGE: dm_spawns_test <first|next|prev>");
        return Plugin_Handled;
    }
    
    if(!dhook_IsSelectSpawnPointAvailable())
    {
        PrintToConsole(clientIndex, "DHooks extension is required for this");
        PrintToChat(clientIndex, " \x01\x0B\x02DHooks extension is required for this");
    }
    
    if(!res)
    {
        PrintToConsole(clientIndex, "Can't spawn you, did you create any point?");
        PrintToChat(clientIndex, " \x01\x0B\x02Can't spawn you, did you create any point?");
    }
    
    return Plugin_Handled;
}

stock adminCmd_SpawnTest_VerboseOnSpawned(clientIndex, SpawnIndex)
{
    PrintToChat(clientIndex, " \x01\x0B\x04Spawned to index \x0C%d", SpawnIndex+1);
}

public Action:adminCmd_SpawnStats(clientIndex, args)
{
    spawns_DisplayStats(clientIndex);
    
    return Plugin_Handled;
}