

// Config Cvar list
enum cvars_PluginCvars {
    eCvars_dm_enabled,
    eCvars_dm_remove_objectives,
    eCvars_dm_remove_chickens,
    eCvars_dm_entity_remove_plugin,
    eCvars_dm_entity_remove_user,
    eCvars_dm_weapons_allow_3rd_party,
    eCvars_dm_weapons_allow_drop,
    eCvars_dm_weapons_allow_drop_nade,
    eCvars_dm_weapons_allow_drop_knife,
    eCvars_dm_weapons_allow_drop_zeus,
    eCvars_dm_weapons_allow_drop_c4,
    eCvars_dm_weapons_allow_not_carried,
    eCvars_dm_weapons_max_not_carried,
    eCvars_dm_weapons_max_same_not_carried,
    eCvars_dm_weapons_remove_furthest,
    eCvars_dm_weapons_remove_not_in_los,
    eCvars_dm_weapons_remove_sametype_first,
    eCvars_dm_randomspawn_internal,
    eCvars_dm_normalspawn_internal,
    eCvars_dm_normalspawn_los,
    eCvars_dm_spawn_median_distance_ratio,
    eCvars_dm_spawn_min_team_distance_ratio,
    eCvars_dm_spawn_protection_enable,
    eCvars_dm_spawn_protection_duration,
    eCvars_dm_spawn_protection_clearonshoot,
    eCvars_dm_spawn_protection_color_t,
    eCvars_dm_spawn_protection_color_ct,
    eCvars_dm_spawn_protection_hudfadecolor_t,
    eCvars_dm_spawn_protection_hudfadecolor_ct,
    eCvars_dm_spawn_custom_sounds_enable,
    eCvars_dm_spawn_custom_sounds,
    eCvars_dm_spawn_custom_sounds_level,
    eCvars_dm_spawn_custom_sounds_to_self_enable,
    eCvars_dm_spawn_custom_sounds_to_self,
    eCvars_dm_spawn_custom_sounds_to_self_level,
    eCvars_dm_spawn_custom_sounds_to_team_enable,
    eCvars_dm_spawn_custom_sounds_to_team,
    eCvars_dm_spawn_custom_sounds_to_team_level,
    eCvars_dm_spawn_fade_enable,
    eCvars_dm_spawn_fade_color,
    eCvars_dm_spawn_fade_hold_duration,
    eCvars_dm_spawn_fade_duration,
    eCvars_dm_hide_radar,
    eCvars_dm_gun_menu_mode,
    eCvars_dm_gun_menu_triggers,
    eCvars_dm_limited_weapons_rotation,
    eCvars_dm_limited_weapons_rotation_time,
    eCvars_dm_limited_weapons_rotation_min_time,
    eCvars_dm_replenish_ammo,
    eCvars_dm_replenish_clip,
    eCvars_dm_replenish_clip_headshot,
    eCvars_dm_replenish_clip_knife,
    eCvars_dm_replenish_clip_nade,
    eCvars_dm_equip_kill,
    eCvars_dm_equip_headshot,
    eCvars_dm_equip_knife,
    eCvars_dm_equip_nade,
    eCvars_dm_fast_equip,
    eCvars_dm_no_damage_knife,
    eCvars_dm_no_damage_taser,
    eCvars_dm_no_damage_nade,
    eCvars_dm_no_damage_world,
    eCvars_dm_no_damage_trigger_hurt,
    eCvars_dm_onlyhs,
    eCvars_dm_onlyhs_oneshot,
    eCvars_dm_onlyhs_allowknife,
    eCvars_dm_onlyhs_allowtaser,
    eCvars_dm_onlyhs_allownade,
    eCvars_dm_onlyhs_allowworld,
    eCvars_dm_onlyhs_allowtriggerhurt,
    eCvars_dm_hp_start,
    eCvars_dm_hp_max,
    eCvars_dm_kevlar_start,
    eCvars_dm_kevlar_max,
    eCvars_dm_hp_kill,
    eCvars_dm_hp_hs,
    eCvars_dm_hp_knife,
    eCvars_dm_hp_nade,
    eCvars_dm_hp_to_kevlar_ratio,
    eCvars_dm_hp_to_kevlar_mode,
    eCvars_dm_hp_to_helmet,
    eCvars_dm_hp_messages,
    eCvars_dm_helmet,
    eCvars_dm_zeus,
    eCvars_dm_knife,
    eCvars_dm_defuser,
    eCvars_dm_nades_incendiary,
    eCvars_dm_nades_decoy,
    eCvars_dm_nades_flashbang,
    eCvars_dm_nades_he,
    eCvars_dm_nades_smoke,
    eCvars_dm_zeus_max,
    eCvars_dm_nades_incendiary_max,
    eCvars_dm_nades_decoy_max,
    eCvars_dm_nades_flashbang_max,
    eCvars_dm_nades_he_max,
    eCvars_dm_nades_smoke_max,
    eCvars_dm_default_primary,
    eCvars_dm_default_secondary,
    eCvars_dm_connect_hide_menu,
    eCvars_dm_enable_random_menu,
    eCvars_dm_warmup_time,
    eCvars_dm_spawns_editor_speed_ratio,
    eCvars_dm_spawns_editor_gravity_ratio,
    eCvars_dm_show_rankme_ladder,
    eCvars_dm_show_rankme_ladder_period,
    eCvars_dm_show_rankme_ladder_duration,
    eCvars_dm_filter_friendly_aimpunch,
    eCvars_dm_filter_all_aimpunch,
    eCvars_dm_filter_kill_log,
    eCvars_dm_filter_kill_beep,
    eCvars_dm_filter_texts_enabled,
    eCvars_dm_filter_texts,
    eCvars_dm_log_texts_enabled,
    eCvars_dm_filter_hints_enabled,
    eCvars_dm_filter_hints,
    eCvars_dm_log_hints_enabled,
    eCvars_dm_filter_sounds_enabled,
    eCvars_dm_filter_sounds,
    eCvars_dm_log_sounds_enabled,
    eCvars_dm_filter_blood_decals,
    eCvars_dm_filter_blood_splatter,
    eCvars_CVARS_COUNT
};

// Plugin Cvar handle storage
static Handle:g_hCvars_PluginCvars[eCvars_CVARS_COUNT] = { INVALID_HANDLE, ... };

// Cvar value backup stacks
static Handle:g_hCvars_LockedCvarStack;
static Handle:g_hCvars_KeepedCvarStack;
static Handle:g_hCvars_BackupCvarStack;

stock cvars_Init()
{
    cvars_BuildPluginCvars();
    
    g_hCvars_LockedCvarStack = cvarStack_Create();
    g_hCvars_KeepedCvarStack = cvarStack_Create();
    g_hCvars_BackupCvarStack = cvarStack_Create();
}

stock cvars_Close()
{
    cvars_RestoreCvars(.keepedAlso = true, .clearLocked = true);
    
    cvarStack_Destroy(g_hCvars_LockedCvarStack);
    cvarStack_Destroy(g_hCvars_KeepedCvarStack);
    cvarStack_Destroy(g_hCvars_BackupCvarStack);
}

stock cvars_CreatePluginConVar(
        cvars_PluginCvars:cvarInternalId,
        String:cvarName[], String:cvarDefaultValue[], String:cvarDescription[],
        cvarFlags=FCVAR_PLUGIN | FCVAR_SPONLY,
        bool:cvarHasMin=false, Float:cvarMin=0.0,
        bool:cvarHasMax=false, Float:cvarMax=0.0
    )
{
    g_hCvars_PluginCvars[_:cvarInternalId] = CreateConVar(cvarName, cvarDefaultValue, cvarDescription, cvarFlags, cvarHasMin, cvarMin, cvarHasMax, cvarMax);
}

stock bool:cvars_GetPluginConvarBool(cvars_PluginCvars:cvarInternalId)
{
    return GetConVarBool(g_hCvars_PluginCvars[_:cvarInternalId]);
}

stock cvars_GetPluginConvarInt(cvars_PluginCvars:cvarInternalId)
{
    return GetConVarInt(g_hCvars_PluginCvars[_:cvarInternalId]);
}

stock Float:cvars_GetPluginConvarFloat(cvars_PluginCvars:cvarInternalId)
{
    return GetConVarFloat(g_hCvars_PluginCvars[_:cvarInternalId]);
}

stock cvars_GetPluginConvarString(cvars_PluginCvars:cvarInternalId, String:value[], maxLength)
{
    GetConVarString(g_hCvars_PluginCvars[_:cvarInternalId], value, maxLength);
}

stock cvars_SetPluginConvarBool(cvars_PluginCvars:cvarInternalId, bool:value, bool:replicate=false, bool:notify=false)
{
    SetConVarBool(g_hCvars_PluginCvars[_:cvarInternalId], value, replicate, notify);
}

stock cvars_SetPluginConvarInt(cvars_PluginCvars:cvarInternalId, value, bool:replicate=false, bool:notify=false)
{
    SetConVarInt(g_hCvars_PluginCvars[_:cvarInternalId], value, replicate, notify);
}

stock cvars_SetPluginConvarFloat(cvars_PluginCvars:cvarInternalId, Float:value, bool:replicate=false, bool:notify=false)
{
    SetConVarFloat(g_hCvars_PluginCvars[_:cvarInternalId], value, replicate, notify);
}

stock cvars_SetPluginConvarString(cvars_PluginCvars:cvarInternalId, const String:value[], bool:replicate=false, bool:notify=false)
{
    SetConVarString(g_hCvars_PluginCvars[_:cvarInternalId], value, replicate, notify);
}

stock cvars_HookPluginConvarChange(cvars_PluginCvars:cvarInternalId, ConVarChanged:callback)
{
    HookConVarChange(g_hCvars_PluginCvars[_:cvarInternalId], callback);
}

stock cvars_UnHookPluginConvarChange(cvars_PluginCvars:cvarInternalId, ConVarChanged:callback)
{
    UnhookConVarChange(g_hCvars_PluginCvars[_:cvarInternalId], callback);
}

stock cvars_BuildPluginCvars()
{
    // Create console variables
    CreateConVar("dm_h3bus_version", VERSION, "Deathmatch version.", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD);
    cvars_CreatePluginConVar(eCvars_dm_enabled,                     "dm_enabled",                       "1",        "Enable deathmatch.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_gun_menu_mode,               "dm_gun_menu_mode",                 "1",        "Gun menu mode. 1) Enabled. 2) Disabled. 3) Random weapons every round.",  .cvarHasMin = true, .cvarMin = 1.0, .cvarHasMax = true, .cvarMax = 3.0);
    cvars_CreatePluginConVar(eCvars_dm_gun_menu_triggers,           "dm_gun_menu_triggers",             "guns gns buy",      "Gun menu say triggers. Space separated. Not case sensitive. Don't add '!' or '/'. Max size per trigger 10 char, max triggers 20");
    cvars_CreatePluginConVar(eCvars_dm_remove_objectives,           "dm_remove_objectives",             "1",        "Remove objectives (disables bomb sites, and removes c4 and hostages).", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_remove_chickens,             "dm_remove_chickens",               "1",        "Remove spawning chickens.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
   
    cvars_CreatePluginConVar(eCvars_dm_entity_remove_plugin,        "dm_entity_remove_plugin",          "env_entity_maker game_player_equip game_weapon_manager player_weaponstrip",  "Entities to be removed at round start (prefer dm_entity_remove_user)");  
    cvars_CreatePluginConVar(eCvars_dm_entity_remove_user,          "dm_entity_remove_user",            "point_servercommand",        "Entities to be removed at map start. Space separated. Max size per entity 49 char, max entities 20");  
    
    cvars_CreatePluginConVar(eCvars_dm_weapons_allow_3rd_party,     "dm_weapons_allow_3rd_party",       "0",        "Allow 3rd party weapons from map or other plugins.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    
    cvars_CreatePluginConVar(eCvars_dm_weapons_allow_drop,          "dm_weapons_allow_drop",            "0",        "Allow weapon drop.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_weapons_allow_drop_nade,     "dm_weapons_allow_drop_nade",       "0",        "Allow nade drop.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_weapons_allow_drop_knife,    "dm_weapons_allow_drop_knife",      "0",        "Allow knife drop.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_weapons_allow_drop_zeus,     "dm_weapons_allow_drop_zeus",       "0",        "Allow tazer drop.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_weapons_allow_drop_c4,       "dm_weapons_allow_drop_c4",         "1",        "Allow c4 drop.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    
    cvars_CreatePluginConVar(eCvars_dm_weapons_allow_not_carried,   "dm_weapons_allow_not_carried",     "0",        "Allow not carried weapons (on map).", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_weapons_max_not_carried,     "dm_weapons_max_not_carried",       "100",      "Maximum number of not carried weapons on map.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = false);
    cvars_CreatePluginConVar(eCvars_dm_weapons_max_same_not_carried,"dm_weapons_max_same_not_carried",  "20",       "Maximum number of not carried same weapons on map.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = false);
    
    cvars_CreatePluginConVar(eCvars_dm_weapons_remove_furthest,     "dm_weapons_remove_furthest",       "1",        "Enforce uncarried weapon limit enforcement by removing weapons further to a player.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_weapons_remove_not_in_los,   "dm_weapons_remove_not_in_los",     "1",        "Enforce uncarried weapon limit enforcement by removing weapons not in player Line Of Sight.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_weapons_remove_sametype_first,"dm_weapons_remove_sametype_first","1",        "Enforce uncarried weapon limit enforcement by removing first the weapons ttype that is most represented on map.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    
    cvars_CreatePluginConVar(eCvars_dm_randomspawn_internal,        "dm_randomspawn_internal",          "1",        "Use internal randomspawn method, requires DHook extension and custom DM spawns.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_normalspawn_internal,        "dm_normalspawn_internal",          "1",        "Use internal spawn method, requires DHook extension.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_normalspawn_los,             "dm_normalspawn_los",               "0",        "Use LOS for normal (non random) spawn", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_spawn_median_distance_ratio, "dm_spawn_median_distance_ratio",   "0.2",      "Target spawn distance to other player = ratio * maximum distance between spawn points", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_spawn_min_team_distance_ratio,"dm_spawn_min_team_distance_ratio","0.2",      "Target minimum spawn distance to teammates = ratio * maximum distance between team spawn points", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    
    cvars_CreatePluginConVar(eCvars_dm_spawn_protection_enable,     "dm_spawn_protection_enable",        "0",       "Enable internal spawn protection (this has no effect on stock CS:FO spawn protection system)", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_spawn_protection_duration,   "dm_spawn_protection_duration",      "1.0",     "Spawn protection duration, in seconds", .cvarHasMin = true, .cvarMin = 0.1, .cvarHasMax = false);
    cvars_CreatePluginConVar(eCvars_dm_spawn_protection_clearonshoot,"dm_spawn_protection_clearonshoot", "1",       "Immediatly clears spawn protection when player shoots", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_spawn_protection_color_t,    "dm_spawn_protection_color_t",       "255,0,0,255", "Terrorist Client color when spawn protected");
    cvars_CreatePluginConVar(eCvars_dm_spawn_protection_color_ct,   "dm_spawn_protection_color_ct",      "0,0,255,255", "CT Client color when spawn protected");
    cvars_CreatePluginConVar(eCvars_dm_spawn_protection_hudfadecolor_t, "dm_spawn_protection_hudfadecolor_t",  "255,0,0,100", "Terrorist HUD color when spawn protected");
    cvars_CreatePluginConVar(eCvars_dm_spawn_protection_hudfadecolor_ct,"dm_spawn_protection_hudfadecolor_ct", "0,0,255,100", "CT HUD color when spawn protected");
    
    cvars_CreatePluginConVar(eCvars_dm_spawn_custom_sounds_enable,          "dm_spawn_custom_sounds_enable",         "0",   "Enable custom spawn sounds", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_spawn_custom_sounds,                 "dm_spawn_custom_sounds",                "",    "Pool of custom spawn sounds. Comma separated. Sounds in randomly chosen form the pool. Max 10 sounds, path related to the sound/ directory. eg 'custom/sound1.wav,custom/sound2.wav");
    cvars_CreatePluginConVar(eCvars_dm_spawn_custom_sounds_level,           "dm_spawn_custom_sounds_level",          "90", "Custom spawn sound play level. 75 is normal level, 140 is gunshot", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 200.0);
    cvars_CreatePluginConVar(eCvars_dm_spawn_custom_sounds_to_self_enable,  "dm_spawn_custom_sounds_to_self_enable", "0",   "Enable custom spawn sounds to spawned player", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_spawn_custom_sounds_to_self,         "dm_spawn_custom_sounds_to_self",        "",    "Pool of custom spawn sounds to spawned player. Comma separated. Sounds in randomly chosen form the pool. Max 10 sounds, path related to the sound/ directory. eg 'custom/sound1.wav,custom/sound2.wav");
    cvars_CreatePluginConVar(eCvars_dm_spawn_custom_sounds_to_self_level,   "dm_spawn_custom_sounds_to_self_level",  "90", "Custom spawn sound to spawned player play level. 75 is normal level, 120 is gunshot", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 200.0);
    cvars_CreatePluginConVar(eCvars_dm_spawn_custom_sounds_to_team_enable,  "dm_spawn_custom_sounds_to_team_enable", "0",   "Enable custom spawn sounds to teammates", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_spawn_custom_sounds_to_team,         "dm_spawn_custom_sounds_to_team",        "",    "Pool of custom spawn sounds to teammates. Comma separated. Sounds in randomly chosen form the pool. Max 10 sounds, path related to the sound/ directory. eg 'custom/sound1.wav,custom/sound2.wav");
    cvars_CreatePluginConVar(eCvars_dm_spawn_custom_sounds_to_team_level,   "dm_spawn_custom_sounds_to_team_level",  "90", "Custom spawn sound to teammates play level. 75 is normal level, 140 is gunshot", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 200.0);
    
    cvars_CreatePluginConVar(eCvars_dm_spawn_fade_enable,           "dm_spawn_fade_enable",             "0",        "Enable fade at spawn.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_spawn_fade_color,            "dm_spawn_fade_color",              "0,0,0,240","Fade color, Format Red,Green,Blue,Alpha");
    cvars_CreatePluginConVar(eCvars_dm_spawn_fade_hold_duration,    "dm_spawn_fade_hold_duration",      "0",        "Fade hold duration in seconds. Time during which fade color is applied to screen without fading.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = false);
    cvars_CreatePluginConVar(eCvars_dm_spawn_fade_duration,         "dm_spawn_fade_duration",           "1.5",      "Fade duration in seconds. Time after Hold duration during which screen is faded", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = false);
    
    cvars_CreatePluginConVar(eCvars_dm_limited_weapons_rotation,    "dm_limited_weapons_rotation",      "1",        "Enable limited weapons rotation.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_limited_weapons_rotation_time,"dm_limited_weapons_rotation_time","60.0",     "Time in second before rotating limited weapons between client. If 0, plugin will wait for player to change weapon.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = false);
    cvars_CreatePluginConVar(eCvars_dm_limited_weapons_rotation_min_time,"dm_limited_weapons_rotation_min_time","10.0","Minimum time in second before rotating limited weapons between client.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = false);
    
    cvars_CreatePluginConVar(eCvars_dm_hide_radar,                  "dm_hide_radar",                    "1",        "Hide HUD radar.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_replenish_ammo,              "dm_replenish_ammo",                "1",        "Unlimited player ammo.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_replenish_clip,              "dm_replenish_clip",                "1",        "Refill clip on kill.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_replenish_clip_headshot,     "dm_replenish_clip_headshot",       "0",        "Refill clip on headshot kill.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_replenish_clip_knife,        "dm_replenish_clip_knife",          "0",        "Refill clip on knife kill.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_replenish_clip_nade,         "dm_replenish_clip_nade",           "0",        "Refill clip on nade kill.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_equip_kill,                  "dm_equip_kill",                    "",         "Equipment to give after kill. Comma separated. Format <number>*<equimpment>. Equimpent can be he, flash, smoke, incendiary, decoy, zeus. eg '1*he,2*zeus'");
    cvars_CreatePluginConVar(eCvars_dm_equip_headshot,              "dm_equip_headshot",                "",         "Equipment to give after HS kill. Comma separated. Format <number>*<equimpment>. Equimpent can be he, flash, smoke, incendiary, decoy, zeus. eg '1*he,2*zeus'");
    cvars_CreatePluginConVar(eCvars_dm_equip_knife,                 "dm_equip_knife",                   "",         "Equipment to give after Knife kill. Comma separated. Format <number>*<equimpment>. Equimpent can be he, flash, smoke, incendiary, decoy, zeus. eg '1*he,2*zeus'");
    cvars_CreatePluginConVar(eCvars_dm_equip_nade,                  "dm_equip_nade",                    "",         "Equipment to give after Nade kill. Comma separated. Format <number>*<equimpment>. Equimpent can be he, flash, smoke, incendiary, decoy, zeus. eg '1*he,2*zeus'");
    cvars_CreatePluginConVar(eCvars_dm_fast_equip,                  "dm_fast_equip",                    "1",        "Allows to shoot right after weapon equip", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    
    cvars_CreatePluginConVar(eCvars_dm_no_damage_knife,             "dm_no_damage_knife",               "0",        "Filter damage from knives when only HS is not active", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_no_damage_taser,             "dm_no_damage_taser",               "0",        "Filter damage from taser when only HS is not active", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_no_damage_nade,              "dm_no_damage_nade",                "0",        "Filter damage from nades when only HS is not active", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_no_damage_world,             "dm_no_damage_world",               "0",        "Filter damage from world when only HS is not active", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_no_damage_trigger_hurt,      "dm_no_damage_trigger_hurt",        "0",        "Filter damage from trigger_hurt when only HS is not active", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    
    cvars_CreatePluginConVar(eCvars_dm_onlyhs,                      "dm_onlyhs",                        "0",        "Enable only headshot mode.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_onlyhs_oneshot,              "dm_onlyhs_oneshot",                "0",        "Enable one shot kill for only HS.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_onlyhs_allowknife,           "dm_onlyhs_allowknife",             "1",        "Allows knife in only HS mode.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_onlyhs_allowtaser,           "dm_onlyhs_allowtaser",             "1",        "Allows taser in only HS mode.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_onlyhs_allownade,            "dm_onlyhs_allownade",              "1",        "Allows HE nades in only HS mode.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_onlyhs_allowworld,           "dm_onlyhs_allowworld",             "1",        "Allows suicide in only HS mode.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_onlyhs_allowtriggerhurt,     "dm_onlyhs_allowtriggerhurt",       "1",        "Allows trigger_hurt damage in only HS mode.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    
    cvars_CreatePluginConVar(eCvars_dm_hp_start,                    "dm_hp_start",                      "100",      "Spawn HP.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = false);
    cvars_CreatePluginConVar(eCvars_dm_hp_max,                      "dm_hp_max",                        "100",      "Maximum HP.", .cvarHasMin = true, .cvarMin = 1.0, .cvarHasMax = false);
    cvars_CreatePluginConVar(eCvars_dm_kevlar_start,                "dm_kevlar_start",                  "100",      "Spawn Kelvar.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 100.0);
    cvars_CreatePluginConVar(eCvars_dm_kevlar_max,                  "dm_kevlar_max",                    "100",      "Maximum Kelvar.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 100.0);
    cvars_CreatePluginConVar(eCvars_dm_hp_kill,                     "dm_hp_kill",                       "5",        "HP per kill.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = false);
    cvars_CreatePluginConVar(eCvars_dm_hp_hs,                       "dm_hp_hs",                         "10",       "HP per headshot kill.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = false);
    cvars_CreatePluginConVar(eCvars_dm_hp_knife,                    "dm_hp_knife",                      "25",       "HP per knife kill.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = false);
    cvars_CreatePluginConVar(eCvars_dm_hp_nade,                     "dm_hp_nade",                       "25",       "HP per nade kill.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = false);
    cvars_CreatePluginConVar(eCvars_dm_hp_to_kevlar_ratio,          "dm_hp_to_kevlar_ratio",            "0.5",      "Ratio of HP to refill on kevlar on kill.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_hp_to_kevlar_mode,           "dm_hp_to_kevlar_mode",             "2",        "Refill kevlar mode: 0 = Off, 1 = always, 2 = when HP is full.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 2.0);
    cvars_CreatePluginConVar(eCvars_dm_hp_to_helmet,                "dm_hp_to_helmet",                  "3",        "Refill helmet mode: 0 = Off, 1 = always, 2 = when HP is full, 3 when HP and kevlar are full.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 3.0);
    cvars_CreatePluginConVar(eCvars_dm_hp_messages,                 "dm_hp_messages",                   "1",       "Display HP messages.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_helmet,                      "dm_helmet",                        "1",        "Give players Helmet.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_zeus,                        "dm_zeus",                          "0",        "Number of taser to give give each player (-1 = infinite).", .cvarHasMin = true, .cvarMin = -1.0, .cvarHasMax = false);
    cvars_CreatePluginConVar(eCvars_dm_knife,                       "dm_knife",                         "1",        "Give players a knife.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 10.0);
    cvars_CreatePluginConVar(eCvars_dm_defuser,                     "dm_defuser",                       "0",        "Give players a defuse kit.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 10.0);
    cvars_CreatePluginConVar(eCvars_dm_nades_incendiary,            "dm_nades_incendiary",              "0",        "Number of incendiary grenades to give each player.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = false);
    cvars_CreatePluginConVar(eCvars_dm_nades_decoy,                 "dm_nades_decoy",                   "0",        "Number of decoy grenades to give each player.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = false);
    cvars_CreatePluginConVar(eCvars_dm_nades_flashbang,             "dm_nades_flashbang",               "0",        "Number of flashbang grenades to give each player.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = false);
    cvars_CreatePluginConVar(eCvars_dm_nades_he,                    "dm_nades_he",                      "0",        "Number of HE grenades to give each player  (-1 = infinite).", .cvarHasMin = true, .cvarMin = -1.0, .cvarHasMax = false);
    cvars_CreatePluginConVar(eCvars_dm_nades_smoke,                 "dm_nades_smoke",                   "0",        "Number of Smoke grenades to give each player.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = false);
    cvars_CreatePluginConVar(eCvars_dm_zeus_max,                    "dm_zeus_max",                      "0",        "Maximum number of taser grenades to give each player.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = false);
    cvars_CreatePluginConVar(eCvars_dm_nades_incendiary_max,        "dm_nades_incendiary_max",          "0",        "Maximum number of incendiary grenades to give each player.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = false);
    cvars_CreatePluginConVar(eCvars_dm_nades_decoy_max,             "dm_nades_decoy_max",               "0",        "Maximum number of decoy grenades to give each player.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = false);
    cvars_CreatePluginConVar(eCvars_dm_nades_flashbang_max,         "dm_nades_flashbang_max",           "0",        "Maximum number of flashbang grenades to give each player.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = false);
    cvars_CreatePluginConVar(eCvars_dm_nades_he_max,                "dm_nades_he_max",                  "0",        "Maximum number of HE grenades to give each player.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = false);
    cvars_CreatePluginConVar(eCvars_dm_nades_smoke_max,             "dm_nades_smoke_max",               "0",        "Maximum number of Smoke grenades to give each player.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = false);
    
    cvars_CreatePluginConVar(eCvars_dm_default_primary,             "dm_default_primary",               "none",     "Default primary weapon to give a player");
    cvars_CreatePluginConVar(eCvars_dm_default_secondary,           "dm_default_secondary",             "none",     "Default secondary weapon to give a player");
    cvars_CreatePluginConVar(eCvars_dm_connect_hide_menu,           "dm_connect_hide_menu",             "0",        "Hide DM menu at first spawn", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_enable_random_menu,          "dm_enable_random_menu",            "1",        "Enable random item in menu", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_warmup_time,                 "dm_warmup_time",                   "45",       "Warmup duration", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = false);
    
    cvars_CreatePluginConVar(eCvars_dm_spawns_editor_speed_ratio,   "dm_spawns_editor_speed_ratio",     "1.5",      "Speed ratio applied to admin in spawn edit mode.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = false);
    cvars_CreatePluginConVar(eCvars_dm_spawns_editor_gravity_ratio, "dm_spawns_editor_gravity_ratio",   "0.2",      "Gravity ratio applied to admin in spawn edit mode.", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = false);
    
    cvars_CreatePluginConVar(eCvars_dm_show_rankme_ladder,          "dm_show_rankme_ladder",            "1",        "Periodically show a rankme ladder in hint (rankme plugin dependant)", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_show_rankme_ladder_period,   "dm_show_rankme_ladder_period",     "60",       "Rankme ladder display period in seconds", .cvarHasMin = true, .cvarMin = 10.0, .cvarHasMax = false);
    cvars_CreatePluginConVar(eCvars_dm_show_rankme_ladder_duration, "dm_show_rankme_ladder_duration",   "15",       "Rankme ladder display duration in seconds", .cvarHasMin = true, .cvarMin = 1.0, .cvarHasMax = false);
    
    cvars_CreatePluginConVar(eCvars_dm_filter_friendly_aimpunch,    "dm_filter_friendly_aimpunch",      "0",        "Filter aimpunch from a friendly fire", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_filter_all_aimpunch,         "dm_filter_all_aimpunch",           "0",        "Filter all aimpunch (might also remove blood effects)", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    
    cvars_CreatePluginConVar(eCvars_dm_filter_kill_log,             "dm_filter_kill_log",               "0",        "Filter kill log on upper right corner", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_filter_kill_beep,            "dm_filter_kill_beep",              "0",        "Filter beep sound on kill (in deathmatch game mode)", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    
    cvars_CreatePluginConVar(eCvars_dm_filter_texts_enabled,        "dm_filter_texts_enabled",          "0",        "Enable Text messages filtering", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_filter_texts,                "dm_filter_texts",                  "#Player_Point_Award_Killed_Enemy_Plural", "List of Text messages to filter. Comma separated. Maximum 20");
    cvars_CreatePluginConVar(eCvars_dm_log_texts_enabled,           "dm_log_texts_enabled",             "0",        "Enable Text messages logging, Filter shall be enabled to for this to work", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_filter_hints_enabled,        "dm_filter_hints_enabled",          "0",        "Enable Text messages filtering", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_filter_hints,                "dm_filter_hints",                  "",         "List of Hint messages to filter. Comma separated. Maximum 20");
    cvars_CreatePluginConVar(eCvars_dm_log_hints_enabled,           "dm_log_hints_enabled",             "0",        "Enable Text messages logging, Filter shall be enabled to for this to work", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_filter_sounds_enabled,       "dm_filter_sounds_enabled",         "0",        "Enable Sounds filtering", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_filter_sounds,               "dm_filter_sounds",                 "player/pl_respawn.wav", "List of Sounds to filter. Comma separated. Maximum 20");
    cvars_CreatePluginConVar(eCvars_dm_log_sounds_enabled,          "dm_log_sounds_enabled",            "0",        "Enable Sounds logging, Filter shall be enabled to for this to work", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_filter_blood_decals,         "dm_filter_blood_decals",           "0",        "Filter blood decals on walls", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);
    cvars_CreatePluginConVar(eCvars_dm_filter_blood_splatter,       "dm_filter_blood_splatter",         "0",        "Filter blood splatters", .cvarHasMin = true, .cvarMin = 0.0, .cvarHasMax = true, .cvarMax = 1.0);

    cvars_HookAllCvars();    
}

stock cvars_HookAllCvars()
{
    for (new index = _:eCvars_dm_enabled; index < _:eCvars_CVARS_COUNT; index++)
        cvars_HookPluginConvarChange(cvars_PluginCvars:index, cvars_Event_CvarChange);
    
    decl Handle:CvarHandle;
    
    if((CvarHandle = FindConVar("mp_randomspawn")) != INVALID_HANDLE)
        HookConVarChange(CvarHandle, cvars_Event_CvarChange);
    if((CvarHandle = FindConVar("mp_randomspawn_los")) != INVALID_HANDLE)
        HookConVarChange(CvarHandle, cvars_Event_CvarChange);
    if((CvarHandle = FindConVar("mp_teammates_are_enemies")) != INVALID_HANDLE)
        HookConVarChange(CvarHandle, cvars_Event_CvarChange);
    if((CvarHandle = FindConVar("mp_death_drop_gun")) != INVALID_HANDLE)
        HookConVarChange(CvarHandle, cvars_Event_CvarChange);
    if((CvarHandle = FindConVar("mp_death_drop_grenade")) != INVALID_HANDLE)
        HookConVarChange(CvarHandle, cvars_Event_CvarChange);
}

stock cvars_UnHookAllCvars()
{
    for (new index = _:eCvars_dm_enabled; index < _:eCvars_CVARS_COUNT; index++)
        cvars_UnHookPluginConvarChange(cvars_PluginCvars:index, cvars_Event_CvarChange);

    decl Handle:CvarHandle;
    
    if((CvarHandle = FindConVar("mp_randomspawn")) != INVALID_HANDLE)
        UnhookConVarChange(CvarHandle, cvars_Event_CvarChange);
    if((CvarHandle = FindConVar("mp_randomspawn_los")) != INVALID_HANDLE)
        UnhookConVarChange(CvarHandle, cvars_Event_CvarChange);
    if((CvarHandle = FindConVar("mp_teammates_are_enemies")) != INVALID_HANDLE)
        UnhookConVarChange(CvarHandle, cvars_Event_CvarChange);
    if((CvarHandle = FindConVar("mp_death_drop_gun")) != INVALID_HANDLE)
        UnhookConVarChange(CvarHandle, cvars_Event_CvarChange);
    if((CvarHandle = FindConVar("mp_death_drop_grenade")) != INVALID_HANDLE)
        UnhookConVarChange(CvarHandle, cvars_Event_CvarChange);
}

public cvars_Event_CvarChange(Handle:cvar, const String:oldValue[], const String:newValue[])
{
    UpdateState();
}

stock cvars_SetConVarStringUnNotified(Handle:cvarHandle, const String:cvarValue[], bool:replicate=true, bool:notify=false)
{
    decl flags, oldFlags;
    
    oldFlags = GetConVarFlags(cvarHandle);
    flags = oldFlags;
    if(!notify)
        flags = flags & ~FCVAR_NOTIFY;
    if(!replicate)
        flags = flags & ~FCVAR_REPLICATED;
    
    SetConVarFlags(cvarHandle, flags);
    
    SetConVarString(cvarHandle, cvarValue, replicate, notify);
    
    SetConVarFlags(cvarHandle, oldFlags);
}

stock bool:cvars_SetExternalCvarString(const String:cvarName[], const String:cvarValue[], bool:backup, bool:keeped, bool:locked, bool:replicate=true, bool:notify=false)
{
    new Handle:cvarHandle = FindConVar(cvarName);
    
    if (cvarHandle == INVALID_HANDLE)
        return false;
    
    else
    {
        decl String:oldValue[MAX_CONVARVALUE_SIZE];
        
        GetConVarString(cvarHandle, oldValue, MAX_CONVARVALUE_SIZE);
        
        if (backup)
            cvarStack_PushIfNotPresent(g_hCvars_BackupCvarStack, cvarName, oldValue);
        
        if (!cvarStack_Exist(g_hCvars_LockedCvarStack, cvarName))
            cvars_SetConVarStringUnNotified(cvarHandle, cvarValue, replicate, notify);
        
        if (locked)
            cvarStack_PushIfNotPresent(g_hCvars_LockedCvarStack, cvarName, oldValue);
        
        if (keeped)
            cvarStack_PushIfNotPresent(g_hCvars_KeepedCvarStack, cvarName, oldValue);
        
        CloseHandle(cvarHandle);
        return true;
    }
}

stock bool:cvars_SetExternalCvarInt(const String:cvarName[], cvarValue, bool:backup, bool:keeped, bool:locked, bool:replicate=true, bool:notify=false)
{
    decl String:cvarValueStr[MAX_CONVARVALUE_SIZE];
    IntToString(cvarValue, cvarValueStr, sizeof(cvarValueStr));
    
    return cvars_SetExternalCvarString(cvarName, cvarValueStr, backup, keeped, locked, replicate, notify);
}

stock bool:cvars_RestoreCvars(bool:keepedAlso, bool:clearLocked)
{
    decl Handle:cvarHandle;
    decl String:cvarName[MAX_CONVARNAME_SIZE];
    decl String:cvarValue[MAX_CONVARVALUE_SIZE];
    
    while(cvarStack_Pop(g_hCvars_BackupCvarStack, cvarName, sizeof(cvarName), cvarValue, sizeof(cvarValue)))
    {
        if(keepedAlso || !cvarStack_Exist(g_hCvars_KeepedCvarStack, cvarName))
        {
            cvarHandle = FindConVar(cvarName);
            cvars_SetConVarStringUnNotified(cvarHandle, cvarValue, .replicate = true, .notify=false);
            CloseHandle(cvarHandle);
            cvarStack_RemoveIfPresent(g_hCvars_LockedCvarStack, cvarName);
        }
    }
    
    if(!keepedAlso)
        cvarStack_Copy(g_hCvars_KeepedCvarStack, g_hCvars_BackupCvarStack);
    else
        cvarStack_Clear(g_hCvars_KeepedCvarStack);
    
    if(clearLocked)
        cvarStack_Clear(g_hCvars_LockedCvarStack);
}
