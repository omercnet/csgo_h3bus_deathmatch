#define CONFIG_GUN_TRIGGER_MAX_COUNT 20
#define CONFIG_GUN_TRIGGER_MAX_SIZE 11
#define CONFIG_ENTITY_REMOVAL_MAX_COUNT 20
#define CONFIG_ENTITY_REMOVAL_MAX_SIZE 50
#define CONFIG_FILTERS_MAX_COUNT 20
#define CONFIG_FILTERS_MAX_SIZE 255

// Options
new bool:g_bConfig_Enabled = false;
new bool:g_bConfig_RemoveObjectives;
new bool:g_bConfig_RemoveChickens;
new String:g_sSystemEntityRemoval[CONFIG_ENTITY_REMOVAL_MAX_COUNT][CONFIG_ENTITY_REMOVAL_MAX_SIZE];
new g_iSystemEntityRemovalCount = 0;
new String:g_sUserEntityRemoval[CONFIG_ENTITY_REMOVAL_MAX_COUNT][CONFIG_ENTITY_REMOVAL_MAX_SIZE];
new g_iUserEntityRemovalCount = 0;
new bool:g_bConfig_HideRadar;
new g_iConfig_GunMenuMode;
new String:g_sGunMenuTriggers[CONFIG_GUN_TRIGGER_MAX_COUNT][CONFIG_GUN_TRIGGER_MAX_SIZE];
new g_bConfig_LimitedWeaponsRotation = true;
new Float:g_fConfig_LimitedWeaponsRotationTime = 60.0;
new Float:g_fConfig_LimitedWeaponsRotationMinTime = 10.0;
new g_iGunMenuTriggersCount = 0;
new bool:g_bConfig_ReplenishAmmo;
new bool:g_bConfig_ReplenishClip;
new bool:g_bConfig_ReplenishClipHS;
new bool:g_bConfig_ReplenishClipKnife;
new bool:g_bConfig_ReplenishClipNade;
new bool:g_bConfig_FastEquip;
new bool:g_bConfig_NoDamage_Knife;
new bool:g_bConfig_NoDamage_Taser;
new bool:g_bConfig_NoDamage_Nade;
new bool:g_bConfig_NoDamage_World;
new bool:g_bConfig_NoDamage_TriggerHurt;
new bool:g_bConfig_OnlyHS;
new bool:g_bConfig_OnlyHS_OneShot;
new bool:g_bConfig_OnlyHS_AllowKnife;
new bool:g_bConfig_OnlyHS_AllowTaser;
new bool:g_bConfig_OnlyHS_AllowNade;
new bool:g_bConfig_OnlyHS_AllowWorld;
new bool:g_bConfig_OnlyHS_AllowTriggerHurt;
new g_iConfig_StartHP;
new g_iConfig_MaxHP;
new g_iConfig_StartKevlar;
new g_iConfig_MaxKevlar;
new g_iConfig_HPPerKill;
new g_iConfig_HPPerHeadshotKill;
new g_iConfig_HPPerKnifeKill;
new g_iConfig_HPPerNadeKill;
new g_iConfig_HPToKevlarRatio;
new g_iConfig_HPToKevlarMode;
new g_iConfig_HPToHelmet;
new bool:g_bConfig_Helmet;
new g_iConfig_Zeus;
new bool:g_bConfig_ZeusRefill;
new bool:g_bConfig_Knife;
new bool:g_bConfig_Defuser;
new g_iConfig_Incendiary;
new g_iConfig_Decoy;
new g_iConfig_flashbang;
new g_iConfig_He;
new g_iConfig_ZeusMax;
new g_iConfig_IncendiaryMax;
new g_iConfig_DecoyMax;
new g_iConfig_flashbangMax;
new g_iConfig_HeMax;
new g_iConfig_SmokeMax;
new bool:g_bConfig_HeRefill;
new g_iConfig_Smoke;
new bool:g_bConfig_DisplayHPMessages;
new g_iConfig_DefaultPrimary = -1; // NO_WEAPON_SELECTED
new g_iConfig_DefaultSecondary = -1; // NO_WEAPON_SELECTED
new bool:g_bConfig_ConnectHideMenu = false;
new bool:g_bConfig_RandomMenuEnabled = true;

new bool:g_bConfig_RandomSpam_Internal;
new bool:g_bConfig_NormalSpam_Internal;
new bool:g_bConfig_NormalSpam_LOS;
new Float:g_fConfig_MedianSpawnDistance_ratio = 0.04;
new Float:g_fConfig_MinTeamSpawnDistance_ratio = 0.04;

new bool:g_bConfig_SpawnProtection_Enable = false;
new Float:g_fConfig_SpawnProtection_Duration = 1.0;
new bool:g_bConfig_SpawnProtection_ClearOnShoot = true;
new g_iConfig_SpawnProtection_ColorT[4] = {255, 0, 0, 200};
new g_iConfig_SpawnProtection_ColorCT[4] = {0, 0, 255, 200};
new g_iConfig_SpawnProtection_HUDColorT[4] = {255, 0, 0, 100};
new g_iConfig_SpawnProtection_HUDColorCT[4] = {0, 0, 255, 100};

new bool:g_bConfig_SpawnFade_Enable = false;
new g_iConfig_SpawnFade_Color[4] = {0, 0, 0, 240};
new g_iConfig_SpawnFade_HoldDuration = 0;
new g_iConfig_SpawnFade_Duration = 1500;

new bool:g_bConfig_WeaponsAllowThirdParty = false;
new bool:g_bConfig_WeaponsAllowUncarried = false;
new bool:g_bConfig_WeaponsAllowDrop = false;
new bool:g_bConfig_WeaponsAllowNadeDrop = false;
new bool:g_bConfig_WeaponsAllowKnifeDrop = false;
new bool:g_bConfig_WeaponsAllowTazerDrop = false;
new bool:g_bConfig_WeaponsAllowC4Drop = true;
new g_iConfig_WeaponsMaxUncarried = 100;
new g_iConfig_WeaponsMaxUncarriedSameType = 20;
new bool:g_bConfig_WeaponsUncarriedEnforce_FurthestToPlayers = true;
new bool:g_bConfig_WeaponsUncarriedEnforce_NotInPlayerLOS = true;
new bool:g_bConfig_WeaponsUncarriedEnforce_MostWeaponSameTypeFirst = true;

new bool:g_bConfig_Filter_FriendlyAimPunch = false;
new bool:g_bConfig_Filter_AllAimPunch = false;

new bool:g_bConfig_Filter_KillEvents = false;
new bool:g_bConfig_Filter_KillBeep = false;

new bool:g_bConfig_Filter_Texts = false;
new bool:g_bConfig_Log_Texts = false;
new g_iConfig_Filter_Texts_Count = 0;
new String:g_sConfig_Filter_Texts[CONFIG_FILTERS_MAX_COUNT][CONFIG_FILTERS_MAX_SIZE];
new bool:g_bConfig_Filter_Hints = false;
new bool:g_bConfig_Log_Hints = false;
new g_iConfig_Filter_Hints_Count = 0;
new String:g_sConfig_Filter_Hints[CONFIG_FILTERS_MAX_COUNT][CONFIG_FILTERS_MAX_SIZE];
new bool:g_bConfig_Filter_Sounds = false;
new bool:g_bConfig_Log_Sounds = false;
new g_iConfig_Filter_Sounds_Count = 0;
new String:g_sConfig_Filter_Sounds[CONFIG_FILTERS_MAX_COUNT][CONFIG_FILTERS_MAX_SIZE];

new g_bConfigs_FilterBloodDecals = false;
new g_bConfigs_FilterBloodSplatter = false;


new Float:g_fConfig_SpawnEditorSpeed_ratio = 1.5;
new Float:g_fConfig_SpawnEditorGravity_ratio = 0.2;

// CSGO config
new bool:g_bConfig_mp_randomspawn;
new bool:g_bConfig_mp_randomspawn_los;
new bool:g_bConfig_mp_teammates_are_enemies;
new g_iConfig_mp_death_drop_gun;
new g_iConfig_mp_death_drop_grenade;


// Local
static bool:g_bConfigLoadAsLocked = false;
static bool:g_bConfigLoadAsKept = false;

stock config_Init()
{
}

stock config_Close()
{
    kvTree_Destroy(g_hSmcReader_ConfigTree);
}

config_OnMapStart()
{
    smcReader_ProcessConfigFile("configs/deathmatch.ini");
}

stock config_SwitchLoadType(Handle:keyValues)
{
    decl String:value[KV_MAX_STRING_SIZE];
    
    kvTree_GetValue(keyValues, value, sizeof(value));
    
    if(StrEqual(value, "LockedLoads", false))
        g_bConfigLoadAsLocked = true;
    else if(StrEqual(value, "UnlockedLoads", false))
        g_bConfigLoadAsLocked = false;
    else if(StrEqual(value, "KeepedLoads", false) || StrEqual(value, "KeptLoads", false))
        g_bConfigLoadAsKept = true;
    else if(StrEqual(value, "RestoredLoads", false))
        g_bConfigLoadAsKept = false;
    else
        LogError("Unknown \"SwitchLoadType\" option \"%s\"", value);
}

stock config_LoadWeaponDefinition(Handle:keyValues)
{
    new String:tempStr[KV_MAX_STRING_SIZE] = "";
    decl localInt;
    decl Float:localFloat;
    
    decl String:weaponClassName[KV_MAX_STRING_SIZE];
    new String:weaponDisplayName[KV_MAX_STRING_SIZE] = "";
    new weapons_Types:weaponType = weapons_type_None;
    new weaponSkinTeam = CS_TEAM_SPECTATOR;
    new weaponDefinitionIndex = -1;
    new Float:weaponReloadTime = -1.0;
    new weaponPerBulletReload = -1;
    new weaponClipSize = -1;
    new weaponOriginalClipSize = -1;
    new weaponAmmoMax = -1;
    
    if (kvTree_GotoFirstSubKey(keyValues, false))
    {
        kvTree_GetString(keyValues, "ClassName", weaponClassName, KV_MAX_STRING_SIZE);
        
        if(StrEqual(weaponClassName, ""))
        {
            LogError("\"DefineWeapon\" is missing mandatory \"ClassName\" key");
            return;
        }
        
        kvTree_GetString(keyValues, "DisplayName", weaponDisplayName, KV_MAX_STRING_SIZE);
        
        kvTree_GetString(keyValues, "Type", tempStr, KV_MAX_STRING_SIZE);
        if(StrEqual(tempStr, "Primary", false))
            weaponType = weapons_type_Primary;
        else if(StrEqual(tempStr, "Secondary", false))
            weaponType = weapons_type_Secondary;
        else if(StrEqual(tempStr, "Equipment", false))
            weaponType = weapons_type_Equipement;
        else if(!StrEqual(tempStr, "", false))
            LogError("Unknown \"Type\" value \"%s\"", tempStr);
        
        kvTree_GetString(keyValues, "SkinTeam", tempStr, KV_MAX_STRING_SIZE);
        if(StrEqual(tempStr, "Both", false))
            weaponSkinTeam = CS_TEAM_NONE;
        else if(StrEqual(tempStr, "T", false))
            weaponSkinTeam = CS_TEAM_T;
        else if(StrEqual(tempStr, "CT", false))
            weaponSkinTeam = CS_TEAM_CT;
        else if(!StrEqual(tempStr, "", false))
            LogError("Unknown \"SkinTeam\" value \"%s\"", tempStr);
        
        kvTree_GetString(keyValues, "ItemDefinitionIndex", tempStr, KV_MAX_STRING_SIZE);
        if(StringToIntEx(tempStr, localInt) <= 0)
        {
            if(!StrEqual(tempStr, ""))
                LogError("\"ItemDefinitionIndex\" value \"%s\" is not an integer", tempStr);
        }
        else
            weaponDefinitionIndex = localInt;
        
        kvTree_GetString(keyValues, "ReloadTime", tempStr, KV_MAX_STRING_SIZE);
        if(StringToFloatEx(tempStr, localFloat) <= 0)
        {
            if(!StrEqual(tempStr, ""))
                LogError("\"ReloadTime\" value \"%s\" is not an Float", tempStr);
        }
        
        kvTree_GetString(keyValues, "PerBulletReload", tempStr, KV_MAX_STRING_SIZE);
        if(StringToInt(tempStr, localInt) <= 0)
        {
            if(!StrEqual(tempStr, ""))
                LogError("\"PerBulletReload\" value \"%s\" is not an Int", tempStr);
        }
        else if(localInt == 0 || localInt == 1)
            weaponPerBulletReload = localInt;
        else
            LogError("\"PerBulletReload\" value \"%s\" is not equal to 0 or 1", tempStr);
        
        kvTree_GetString(keyValues, "ClipSize", tempStr, KV_MAX_STRING_SIZE);
        if(StringToIntEx(tempStr, localInt) <= 0)
        {
            if(!StrEqual(tempStr, ""))
                LogError("\"ClipSize\" value \"%s\" is not an integer", tempStr);
        }
        else
            weaponClipSize = localInt;
        
        kvTree_GetString(keyValues, "OriginalClipSize", tempStr, KV_MAX_STRING_SIZE);
        if(StringToIntEx(tempStr, localInt) <= 0)
        {
            if(!StrEqual(tempStr, ""))
                LogError("\"OriginalClipSize\" value \"%s\" is not an integer", tempStr);
        }
        else
            weaponOriginalClipSize = localInt;
            
        kvTree_GetString(keyValues, "AmmoMax", tempStr, KV_MAX_STRING_SIZE);
        if(StringToIntEx(tempStr, localInt) <= 0)
        {
            if(!StrEqual(tempStr, ""))
                LogError("\"AmmoMax\" value \"%s\" is not an integer", tempStr);
        }
        else
            weaponAmmoMax = localInt;
        
        weapons_Add(
                        .weaponEntityName = weaponClassName,
                        .weaponName = weaponDisplayName,
                        .weaponType = weaponType,
                        .weaponSkinTeam = weaponSkinTeam,
                        .weaponDefinitionIndex = weaponDefinitionIndex,
                        .weaponLimit = -1,
                        .weaponReloadTime = weaponReloadTime,
                        .weaponPerBulletReload = weaponPerBulletReload,
                        .weaponClipSize = weaponClipSize,
                        .weaponOriginalClipSize = weaponOriginalClipSize,
                        .weaponAmmoMax = weaponAmmoMax
                   );
    }
    else
        LogError("Empty \"DefineWeapon\" section");
}

stock config_LoadWeapons(Handle:keyValues, bool:weaponPrimary, bool:clearList=true)
{
    decl String:key[KV_MAX_STRING_SIZE];
    decl String:value[KV_MAX_STRING_SIZE];
    
    decl id;
    
    if(clearList)
        weapons_ClearList(weaponPrimary);
    
    if (kvTree_GotoFirstSubKey(keyValues, false))
    {
        do {
            kvTree_GetSectionName(keyValues, key, sizeof(key));
            kvTree_GetValue(keyValues, value, sizeof(value));
            
            new bool:hidden = RemoveChar(value, 'h');
            new limit = StringToInt(value);
            
            if (weapons_FindId(key, id))
            {
                if(!hidden)
                    weapons_AddToWeaponsListed(id);
                weapons_SetLimit(id, limit);
            }
            else
                LogError("Unknown weapon \"%s\"", key);
            
        } while (kvTree_GotoNextKey(keyValues, false));
    }
}

stock config_RemoveWeapons(Handle:keyValues)
{
    decl String:key[KV_MAX_STRING_SIZE];
    
    decl id;
    
    if (kvTree_GotoFirstSubKey(keyValues, false))
    {
        do {
            kvTree_GetSectionName(keyValues, key, sizeof(key));
            
            if (weapons_FindId(key, id))
            {
                weapons_RemoveFromWeaponsListed(id);
                weapons_SetLimit(id, 0);
            }
            else
                LogError("Unknown weapon \"%s\"", key);
            
        } while (kvTree_GotoNextKey(keyValues, false));
    }
}

stock config_LoadCvars(Handle:keyValues)
{
    decl String:key[KV_MAX_STRING_SIZE];
    decl String:value[KV_MAX_STRING_SIZE];
    
    if (kvTree_GotoFirstSubKey(keyValues, false))
    {
        do {
            kvTree_GetValue(keyValues, value, sizeof(value), "");
            kvTree_GetSectionName(keyValues, key, sizeof(key));
            if(!cvars_SetExternalCvarString(key, value, .backup = true, .keeped = g_bConfigLoadAsKept, .locked = g_bConfigLoadAsLocked))
                LogError("Cant set Cvar \"%s\": Not found", key);
            
        } while (kvTree_GotoNextKey(keyValues, false));
    }
}

stock config_LoadSubCall(Handle:keyValues, bool:warmup, option=-1)
{
    decl String:key[KV_MAX_STRING_SIZE];
    decl String:value[KV_MAX_STRING_SIZE];
    decl id;

    if (option > -1 && kvTree_GotoSectionChildItem(keyValues, option))
    {
        kvTree_GetSectionSymbol(keyValues, id);
            
        kvTree_GetValue(keyValues, value, sizeof(value));
        kvTree_GetSectionName(keyValues, key, sizeof(key));
        
        config_LoadRecursive(keyValues, key, value, false, warmup);
    
        kvTree_JumpToKeySymbol(keyValues, id);
    }
    else if (kvTree_GotoFirstSubKey(keyValues, false))
    {
        do {
        
            kvTree_GetSectionSymbol(keyValues, id);
                
            kvTree_GetValue(keyValues, value, sizeof(value));
            kvTree_GetSectionName(keyValues, key, sizeof(key));
            
            config_LoadRecursive(keyValues, key, value, false, warmup);
        
            kvTree_JumpToKeySymbol(keyValues, id);
            
        } while (kvTree_GotoNextKey(keyValues, false));
    }
}

stock config_LoadMessageSubCall(Handle:keyValues)
{
    decl String:key[KV_MAX_STRING_SIZE];
    decl String:value[KV_MAX_STRING_SIZE];
    decl id;

    if (kvTree_GotoFirstSubKey(keyValues, false))
    {
        do {
        
            kvTree_GetSectionSymbol(keyValues, id);
            
            kvTree_GetValue(keyValues, value, sizeof(value));
            kvTree_GetSectionName(keyValues, key, sizeof(key));
            
            configMessages_LoadMessageSection(keyValues, key, value, .keeped = g_bConfigLoadAsKept);
        
            kvTree_JumpToKeySymbol(keyValues, id);
            
        } while (kvTree_GotoNextKey(keyValues, false));
    }
}

stock config_UnLoadMessageSubCall(Handle:keyValues)
{
    decl String:key[KV_MAX_STRING_SIZE];
    decl String:value[KV_MAX_STRING_SIZE];
    decl id;

    if (kvTree_GotoFirstSubKey(keyValues, false))
    {
        do {
        
            kvTree_GetSectionSymbol(keyValues, id);
            
            kvTree_GetValue(keyValues, value, sizeof(value));
            kvTree_GetSectionName(keyValues, key, sizeof(key));
            
            configMessages_UnLoadMessageSection(keyValues, key, value);
        
            kvTree_JumpToKeySymbol(keyValues, id);
            
        } while (kvTree_GotoNextKey(keyValues, false));
    }
}

stock config_LoadChooseOption(Handle:keyValues)
{
    decl choiceCounts;
    
    choiceCounts = kvTree_GetSectionChildCount(keyValues);
    
    if(choiceCounts < 2)
        return choiceCounts;
    else
        return GetRandomInt(0, choiceCounts - 1);
}

stock config_LoadLastLevel(Handle:keyValues, bool:warmup)
{
    decl String:key[KV_MAX_STRING_SIZE];
    decl id;
    
    kvTree_GetSectionSymbol(keyValues, id);
    
    kvTree_GetSectionName(keyValues, key, sizeof(key));
    
    if (StrEqual(key, "Primary"))
        config_LoadWeapons(keyValues, true);

    else if (StrEqual(key, "Secondary"))
        config_LoadWeapons(keyValues, false);
    
    else if (StrEqual(key, "WeaponAdd"))
        config_LoadWeapons(keyValues, false, false);

    else if (StrEqual(key, "WeaponRemove"))
        config_RemoveWeapons(keyValues);
    
    else if (StrEqual(key, "DefineWeapon"))
        config_LoadWeaponDefinition(keyValues);
    
    else if (StrEqual(key, "Cvars"))
        config_LoadCvars(keyValues);
    
    else if (StrEqual(key, "Load"))
        config_LoadSubCall(keyValues, warmup);
        
    else if (StrEqual(key, "LoadWarmup"))
    {
        if (warmup)
            config_LoadSubCall(keyValues, warmup);
    }
    else if (StrEqual(key, "LoadRound"))
    {
        if (!warmup)
            config_LoadSubCall(keyValues, warmup);
    }
    else if (StrEqual(key, "WarmupOption"))
    {
        if (warmup)
            config_LoadSubCall(keyValues, warmup, config_LoadChooseOption(keyValues));
    }
    else if (StrEqual(key, "RoundOption"))
    {
         if (!warmup)
            config_LoadSubCall(keyValues, warmup, config_LoadChooseOption(keyValues));
    }
    else if (StrEqual(key, "LoadMessage"))
    {
        config_LoadMessageSubCall(keyValues);
    }
    else if (StrEqual(key, "LoadMessageWarmup"))
    {
         if (warmup)
            config_LoadMessageSubCall(keyValues);
    }
    else if (StrEqual(key, "UnloadMessage"))
    {
        config_UnLoadMessageSubCall(keyValues);
    }
    else if (StrEqual(key, "#LoadType"))
    {
        config_SwitchLoadType(keyValues);
    }
    else if(!StrEqual(key, "SectionOptions"))
        LogError("Unknown section type \"%s\"", key);
    
    kvTree_JumpToKeySymbol(keyValues, id);
}

stock config_LoadRecursive(Handle:keyValues, const String:section[], const String:name[], bool:approxMatch, bool:warmup)
{
    decl String:key[KV_MAX_STRING_SIZE];
    
    kvTree_Rewind(keyValues);
        
    if (!kvTree_GotoFirstSubKey(keyValues) || !kvTree_JumpToKey(keyValues, section) || !kvTree_GotoFirstSubKey(keyValues))
    {
        LogError("Can't find section \"%s\"", section);
        return;
    }
    
    if (!kvTree_JumpToKey(keyValues, name))
        if (!approxMatch)
        {
            LogError("Can't find subsection \"%s\" in section \"%s\"", name, section);
            return;
        }
        else
        {
            do 
            {
                kvTree_GetSectionName(keyValues, key, sizeof(key));
            } while (!StrStartWith(name, key) && kvTree_GotoNextKey(keyValues, false));
            
            if (!StrStartWith(name, key))
                LogError("Can't find approximate subsection \"%s\" in section \"%s\"", name, section);
    
        }
    
    if (kvTree_GotoFirstSubKey(keyValues, false))
    {
        do {
            config_LoadLastLevel(keyValues, warmup);
        } while (kvTree_GotoNextKey(keyValues, false));
    }
}

stock bool:config_FindSectionId(Handle:keyValues, const String:section[], const String:subsection[], &id)
{
    kvTree_Rewind(keyValues);
        
    if (!kvTree_GotoFirstSubKey(keyValues) || !kvTree_JumpToKey(keyValues, section) || !kvTree_GotoFirstSubKey(keyValues))
    {
        return false;
    }
    
    if (!kvTree_JumpToKey(keyValues, subsection))
    {
        return false;
    }
    
    kvTree_GetSectionSymbol(keyValues, id);
    return true;
}

stock bool:config_LoadSection(Handle:keyValues, sectionId, bool:warmup, bool:append=false)
{
    new bool:ret = false;

    g_bConfigLoadAsLocked = false;
    g_bConfigLoadAsKept = false;
    
    // Avoid calling UpdateState at each change
    cvars_UnHookAllCvars();
    if(!append)
    {
        configMessages_Clear(.keepedAlso = false);
        cvars_RestoreCvars(.keepedAlso = false, .clearLocked = false);
    }
    
    if (kvTree_JumpToKeySymbol(keyValues, sectionId) && kvTree_GotoFirstSubKey(keyValues, false))
    {
        do {
            config_LoadLastLevel(keyValues, warmup);
        } while (kvTree_GotoNextKey(keyValues, false));
        
        ret = true;
    }    
    
    cvars_HookAllCvars();
    UpdateState();
    
    return ret;
}

stock config_Load(bool:warmup)
{
    decl String:map[KV_MAX_STRING_SIZE];
    decl mapStart;
    
    g_bConfigLoadAsLocked = false;
    g_bConfigLoadAsKept = false;
    
    GetCurrentMap(map, sizeof(map));
    
    if((mapStart = FindCharInString(map, '/', .reverse = true)) == -1)
        mapStart = 0;
    else
        mapStart = mapStart + 1;
    
    // Avoid calling UpdateState at each change
    cvars_UnHookAllCvars();
    configMessages_Clear(.keepedAlso = true);
    cvars_RestoreCvars(.keepedAlso = true, .clearLocked = true);
    
    config_LoadRecursive(g_hSmcReader_ConfigTree, "Maps", map[mapStart], true, warmup);
    
    cvars_HookAllCvars();
    UpdateState();
}
