
#define SOUNDS_WEAPON_FORBIDEN "*ui/weapon_cant_buy.wav"
#define SOUNDS_WEAPON_REMOVED "*ui/bonus_alert_end.wav"
#define SOUNDS_WEAPON_AWARDED "*ui/bonus_alert_start.wav"
#define SOUNDS_WEAPON_TIMER1 "*buttons/blip2.wav"
#define SOUNDS_WEAPON_TIMER2 "*buttons/blip2.wav"
#define SOUNDS_WEAPON_TIMER3 "*ui/beep07.wav"

#define SOUNDS_SPAWN_MAX_POOL_COUNT 10
#define SOUNDS_SPAWN_MAX_PATH_SIZE 255

static sounds_StringTable = INVALID_STRING_TABLE;
static sounds_DownloadTable = INVALID_STRING_TABLE;

static bool:g_bSounds_SpawnSoundToPlayer_Enabled = false;
static bool:g_bSounds_SpawnSoundToTeam_Enabled = false;
static bool:g_bSounds_SpawnSoundToOthers_Enabled = false;

static g_iSounds_SpawnSoundToPlayer_count = 0;
static g_iSounds_SpawnSoundToTeam_count = 0;
static g_iSounds_SpawnSoundToOthers_count = 0;

static String:g_sSounds_SpawnSoundToPlayer[SOUNDS_SPAWN_MAX_POOL_COUNT][SOUNDS_SPAWN_MAX_PATH_SIZE];
static String:g_sSounds_SpawnSoundToTeam[SOUNDS_SPAWN_MAX_POOL_COUNT][SOUNDS_SPAWN_MAX_PATH_SIZE];
static String:g_sSounds_SpawnSoundToOthers[SOUNDS_SPAWN_MAX_POOL_COUNT][SOUNDS_SPAWN_MAX_PATH_SIZE];

static g_iSounds_SpawnSoundToPlayer_level = 90;
static g_iSounds_SpawnSoundToTeam_level = 90;
static g_iSounds_SpawnSoundToOthers_level = 90;

stock sounds_Init()
{
    sounds_StringTable = FindStringTable("soundprecache");
    sounds_DownloadTable = FindStringTable("downloadtable");
}

stock sounds_OnMapStart()
{
    sounds_StringTable = FindStringTable("soundprecache");
    sounds_DownloadTable = FindStringTable("downloadtable");
    
    sounds_PrecacheSound(SOUNDS_WEAPON_REMOVED);
    sounds_PrecacheSound(SOUNDS_WEAPON_AWARDED);
    sounds_PrecacheSound(SOUNDS_WEAPON_TIMER1);
    sounds_PrecacheSound(SOUNDS_WEAPON_TIMER2);
    sounds_PrecacheSound(SOUNDS_WEAPON_TIMER3);
}

stock sounds_PrecacheSound(const String:sndPath[])
{
    AddToStringTable(sounds_StringTable, sndPath);
}

stock sounds_PlayToClient(clientIndex,
                            const String:sndPath[],
                            entity = SOUND_FROM_PLAYER,
                            channel = SNDCHAN_AUTO,
                            level = SNDLEVEL_NORMAL,
                            flags = SND_NOFLAGS,
                            Float:volume = SNDVOL_NORMAL,
                            pitch = SNDPITCH_NORMAL,
                            speakerentity = -1,
                            const Float:origin[3] = NULL_VECTOR,
                            const Float:dir[3] = NULL_VECTOR,
                            bool:updatePos = true,
                            Float:soundtime = 0.0)
{
   new clients[1];
   
   clients[0] = clientIndex;
   entity = (entity == SOUND_FROM_PLAYER) ? clientIndex : entity;
   
   EmitSound(clients, 1, sndPath, entity, channel, level, flags, volume, pitch, speakerentity, origin, dir, updatePos, soundtime);	
}

stock sounds_PlayToClients( clientIndexes[],
                            clientCount,
                            const String:sndPath[],
                            entity = SOUND_FROM_PLAYER,
                            channel = SNDCHAN_AUTO,
                            level = SNDLEVEL_NORMAL,
                            flags = SND_NOFLAGS,
                            Float:volume = SNDVOL_NORMAL,
                            pitch = SNDPITCH_NORMAL,
                            speakerentity = -1,
                            const Float:origin[3] = NULL_VECTOR,
                            const Float:dir[3] = NULL_VECTOR,
                            bool:updatePos = true,
                            Float:soundtime = 0.0)
{  
   EmitSound(clientIndexes, clientCount, sndPath, entity, channel, level, flags, volume, pitch, speakerentity, origin, dir, updatePos, soundtime);	
}

stock sounds_PlayToAll(  const String:sndPath[],
                            entity = SOUND_FROM_PLAYER,
                            channel = SNDCHAN_AUTO,
                            level = SNDLEVEL_NORMAL,
                            flags = SND_NOFLAGS,
                            Float:volume = SNDVOL_NORMAL,
                            pitch = SNDPITCH_NORMAL,
                            speakerentity = -1,
                            const Float:origin[3] = NULL_VECTOR,
                            const Float:dir[3] = NULL_VECTOR,
                            bool:updatePos = true,
                            Float:soundtime = 0.0)
{
   EmitSoundToAll(sndPath, entity, channel, level, flags, volume, pitch, speakerentity, origin, dir, updatePos, soundtime);	
}

stock sounds_LoadSpawnSounds(String:soundsPaths[], String:targetDeserializedArray[][], targetMaxSize, targetMaxPathSize)
{
    RemoveChar(soundsPaths, ' ');
    new loadedCount = deserializeStrings(soundsPaths, targetDeserializedArray, targetMaxSize, targetMaxPathSize, ',');
    new removedCount = 0;
    
    for(new index = 0; index < loadedCount; index++)
    {
        decl String:soundPath[targetMaxPathSize+6];
        Format(soundPath, targetMaxPathSize+6, "sound/%s", targetDeserializedArray[index-removedCount]);
        
        if(!FileExists(soundPath, .use_valve_fs=true) && !FileExists(soundPath, .use_valve_fs=false))
        {
            LogError("Sound file %s not found, not loaded", soundPath);
            RemoveFromStringArray(targetDeserializedArray, loadedCount-removedCount, targetMaxPathSize, index-removedCount);
            removedCount++;
            continue;
        }
        
        if(FileExists(soundPath, .use_valve_fs=false) && FindStringIndex(sounds_DownloadTable, soundPath) == INVALID_STRING_INDEX)
        {
            LogMessage("Sound file %s should have been added in download table before", soundPath);
            LogMessage("Trying to add it now but already connected client might not play the sound");
            AddFileToDownloadsTable(soundPath);
        }
        
        if(targetDeserializedArray[index-removedCount][0] != '*')
            StrInsert("*", targetDeserializedArray[index-removedCount], targetMaxPathSize);
            
        sounds_PrecacheSound(targetDeserializedArray[index-removedCount]);
    }
    
    return loadedCount-removedCount;
}

stock sounds_LoadSpawnSounds_ToPlayer(bool:enabled, level, String:soundsPaths[])
{
    g_bSounds_SpawnSoundToPlayer_Enabled = enabled;
    g_iSounds_SpawnSoundToPlayer_level = level;
    
    if(enabled)
        g_iSounds_SpawnSoundToPlayer_count = sounds_LoadSpawnSounds(soundsPaths, g_sSounds_SpawnSoundToPlayer, SOUNDS_SPAWN_MAX_POOL_COUNT, SOUNDS_SPAWN_MAX_PATH_SIZE);
}

stock sounds_LoadSpawnSounds_ToTeam(bool:enabled, level, String:soundsPaths[])
{
    g_bSounds_SpawnSoundToTeam_Enabled = enabled;
    g_iSounds_SpawnSoundToTeam_level = level;
    
    if(enabled)
        g_iSounds_SpawnSoundToTeam_count = sounds_LoadSpawnSounds(soundsPaths, g_sSounds_SpawnSoundToTeam, SOUNDS_SPAWN_MAX_POOL_COUNT, SOUNDS_SPAWN_MAX_PATH_SIZE);
}

stock sounds_LoadSpawnSounds_ToOthers(bool:enabled, level, String:soundsPaths[])
{
    g_bSounds_SpawnSoundToOthers_Enabled = enabled;
    g_iSounds_SpawnSoundToOthers_level = level;
    
    if(enabled)
        g_iSounds_SpawnSoundToOthers_count = sounds_LoadSpawnSounds(soundsPaths, g_sSounds_SpawnSoundToOthers, SOUNDS_SPAWN_MAX_POOL_COUNT, SOUNDS_SPAWN_MAX_PATH_SIZE);
}

stock sounds_PlaySpawnSounds(SpawnedClientIndex)
{
    if(
        g_bSounds_SpawnSoundToOthers_Enabled &&
        !g_bSounds_SpawnSoundToPlayer_Enabled &&
        !g_bSounds_SpawnSoundToTeam_Enabled
      )
    {
        if(g_iSounds_SpawnSoundToOthers_count > 0)
        {
            new chosenSound = GetRandomInt(0, g_iSounds_SpawnSoundToOthers_count-1);
            
            sounds_PlayToAll(g_sSounds_SpawnSoundToOthers[chosenSound], .entity = SpawnedClientIndex, .level = g_iSounds_SpawnSoundToOthers_level);
        }
    }
    else if(g_bSounds_SpawnSoundToOthers_Enabled || g_bSounds_SpawnSoundToPlayer_Enabled || g_bSounds_SpawnSoundToTeam_Enabled)
    {
        decl teammates[MAXPLAYERS];
        new teammatesCount = 0;
        decl others[MAXPLAYERS];
        new othersCount = 0;
        new SpawnedClientTeam = GetClientTeam(SpawnedClientIndex);
        
        for(new i = 0; i <= MaxClients; i++)
        {
            if(players_IsClientValid(i) && IsClientInGame(i) && IsPlayerAlive(i))
            {
                if(!g_bConfig_mp_teammates_are_enemies && GetClientTeam(i) == SpawnedClientTeam && g_bSounds_SpawnSoundToTeam_Enabled && (i != SpawnedClientIndex || !g_bSounds_SpawnSoundToPlayer_Enabled))
                {
                    teammates[teammatesCount] = i;
                    teammatesCount++;
                }
                else if(i != SpawnedClientIndex || !g_bSounds_SpawnSoundToPlayer_Enabled)
                {
                    others[othersCount] = i;
                    othersCount++;
                }
            }
        }
        
        if(g_bSounds_SpawnSoundToTeam_Enabled && teammatesCount > 0 && g_iSounds_SpawnSoundToTeam_count > 0)
        {
            new chosenSound = GetRandomInt(0, g_iSounds_SpawnSoundToTeam_count-1);
            
            sounds_PlayToClients(teammates, teammatesCount, g_sSounds_SpawnSoundToTeam[chosenSound], .entity = SpawnedClientIndex, .level = g_iSounds_SpawnSoundToTeam_level);
        }
        
        if(g_bSounds_SpawnSoundToOthers_Enabled && othersCount > 0 && g_iSounds_SpawnSoundToOthers_count > 0)
        {
            new chosenSound = GetRandomInt(0, g_iSounds_SpawnSoundToOthers_count-1);
            
            sounds_PlayToClients(others, othersCount, g_sSounds_SpawnSoundToOthers[chosenSound], .entity = SpawnedClientIndex, .level = g_iSounds_SpawnSoundToOthers_level);
        }
        
        if(g_bSounds_SpawnSoundToPlayer_Enabled && g_iSounds_SpawnSoundToPlayer_count > 0)
        {
            new chosenSound = GetRandomInt(0, g_iSounds_SpawnSoundToPlayer_count-1);
            
            sounds_PlayToClient(SpawnedClientIndex, g_sSounds_SpawnSoundToPlayer[chosenSound], .level = g_iSounds_SpawnSoundToPlayer_level, .volume = g_iSounds_SpawnSoundToPlayer_level/100.0);
        }
        
    }
    
}
