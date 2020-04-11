#undef REQUIRE_PLUGIN
#include <rankme>
#define REQUIRE_PLUGIN

#define RANK_DISPLAY_SELF_DURATION 4


static bool:g_bRankDisplay_Enabled = true;
static bool:g_bRankDisplay_Available = false;
static bool:g_bRankDisplay_RankmeAvailable = false;
static g_iRankDisplay_Period = 60;
static g_iRankDisplay_Duration = 15;
static Handle:g_hRankDisplay_MessageHandle = INVALID_HANDLE;
static g_iRankDisplay_ClientslocalRanks[MAXPLAYERS + 1] = {-1, ...};
static g_iRankDisplay_ClientsPoints[MAXPLAYERS + 1] = {-1, ...};
static g_iRankDisplay_SortedClients[MAXPLAYERS + 1];

public OnAllPluginsLoaded()
{
    new bool:lastAvailability = g_bRankDisplay_Available;
    
    g_bRankDisplay_RankmeAvailable = LibraryExists("rankme");
    rankDisplay_UpdateAvailability();
    if (g_bRankDisplay_Available && !lastAvailability)
    {
        rankDisplay_GetAllClientPoints();
        rankDisplay_Sort();
        rankDisplay_RegisterMessage();
    }
    
}

stock rankdisplay_OnLibraryAdded(const String:name[])
{
    new bool:lastAvailability = g_bRankDisplay_Available;
    
    if (StrEqual(name, "rankme"))
    {
        g_bRankDisplay_RankmeAvailable = true;
        rankDisplay_UpdateAvailability();
        if (g_bRankDisplay_Available && !lastAvailability)
        {
            rankDisplay_GetAllClientPoints();
            rankDisplay_Sort();
            rankDisplay_RegisterMessage();
        }
    }
}

public rankdisplay_OnLibraryRemoved(const String:name[])
{
    new bool:lastAvailability = g_bRankDisplay_Available;
    
    if (StrEqual(name, "rankme"))
    {
        g_bRankDisplay_RankmeAvailable = false;
        rankDisplay_UpdateAvailability();
        if (!g_bRankDisplay_Available && lastAvailability)
        {
            userMessage_UnRegisterMessage(g_hRankDisplay_MessageHandle);
        }
    }
}

public rankdisplay_CvarUpdate()
{
    new lastPeriod = g_iRankDisplay_Period;
    new lastDuration = g_iRankDisplay_Duration;
    
    g_bRankDisplay_Enabled  = cvars_GetPluginConvarBool(eCvars_dm_show_rankme_ladder);
    g_iRankDisplay_Period   = cvars_GetPluginConvarInt(eCvars_dm_show_rankme_ladder_period);
    g_iRankDisplay_Duration = cvars_GetPluginConvarInt(eCvars_dm_show_rankme_ladder_duration);
    
    if(g_iRankDisplay_Duration > g_iRankDisplay_Period)
        g_iRankDisplay_Period = g_iRankDisplay_Duration;
    
    new bool:lastAvailability = g_bRankDisplay_Available;
    
    rankDisplay_UpdateAvailability();
    
    if (!g_bRankDisplay_Available && lastAvailability)
    {
        userMessage_UnRegisterMessage(g_hRankDisplay_MessageHandle);
    }
    else if (g_bRankDisplay_Available && !lastAvailability)
    {
        rankDisplay_GetAllClientPoints();
        rankDisplay_Sort();
        rankDisplay_RegisterMessage();
    }
    else if(
                g_bRankDisplay_Available && 
                ( lastPeriod != g_iRankDisplay_Period ||
                  lastDuration != g_iRankDisplay_Duration)
            )
    {
        userMessage_UnRegisterMessage(g_hRankDisplay_MessageHandle);
        rankDisplay_RegisterMessage();
    }
    
}

public Action:RankMe_OnPlayerLoaded(client)
{
    if (g_bRankDisplay_Available && IsClientConnected(client))
    {
        g_iRankDisplay_ClientsPoints[client] = rankDisplay_Wrapper_GetPoints(client);
        rankDisplay_SortClient(client);
    }
    
    return Plugin_Continue;
}

public Action:RankMe_OnPlayerSaved(client)
{
    if (g_bRankDisplay_Available && IsClientConnected(client))
    {
        g_iRankDisplay_ClientsPoints[client] = rankDisplay_Wrapper_GetPoints(client);
        rankDisplay_SortClient(client);
    }
    
    return Plugin_Continue;
}

stock rankDisplay_OnClientDisconnect(client)
{
    if (g_bRankDisplay_Available)
    {
        g_iRankDisplay_ClientsPoints[client] = -1;
        rankDisplay_SortClient(client);
    }
}

stock rankDisplay_Wrapper_GetPoints(clientIndex)
{
    if (g_bRankDisplay_RankmeAvailable)
        return RankMe_GetPoints(clientIndex);
    
    return -1;
}

rankDisplay_UpdateAvailability()
{
    g_bRankDisplay_Available = g_bRankDisplay_Enabled && (g_bRankDisplay_RankmeAvailable);
}

stock rankDisplay_OnMapStart()
{
    if (g_bRankDisplay_Available)
    {
        rankDisplay_GetAllClientPoints();
        rankDisplay_Sort();
    }
}

stock rankDisplay_GetAllClientPoints()
{
    for (new index = 1; index < MaxClients + 1; index++)
    {
        if (IsClientConnected(index))
            g_iRankDisplay_ClientsPoints[index] = rankDisplay_Wrapper_GetPoints(index);
        else
            g_iRankDisplay_ClientsPoints[index] = -1;
    }
}

stock SwapArrayitems(any:array[], item1, item2)
{
    new any:temp = array[item1];
    array[item1] = array[item2];
    array[item2] = temp;
}

stock MoveArrayItem(any:array[], source, destination)
{
    new any:temp = array[source];
    new increment = (source < destination) ? 1 : -1;
    
    for(new i = source; i != destination; i += increment)
        array[i] = array[i + increment];
    
    array[destination] = temp;
}

stock rankDisplay_SortClient(client)
{
    new currentRank = g_iRankDisplay_ClientslocalRanks[client];
    new currentPoints = g_iRankDisplay_ClientsPoints[client];
    new index = 1;
    
    while (index < MaxClients + 1 && g_iRankDisplay_ClientsPoints[g_iRankDisplay_SortedClients[index]] > currentPoints)
        index++;
    
    if(index != currentRank)
        MoveArrayItem(g_iRankDisplay_SortedClients, currentRank, index);
    
    for(index = 1; index < MaxClients + 1; index++)
        g_iRankDisplay_ClientslocalRanks[g_iRankDisplay_SortedClients[index]] = index;
}

stock rankDisplay_Sort()
{
    decl maxIndex;
    decl maxValue;
    decl sortedPoints[MAXPLAYERS + 1];
    
    for (new index = 1; index < MaxClients + 1; index++)
    {
        g_iRankDisplay_SortedClients[index] = index;
        g_iRankDisplay_ClientslocalRanks[index] = index;
        sortedPoints[index] = g_iRankDisplay_ClientsPoints[index];
    }
    
    for (new index = 1; index < MaxClients + 1; index++)
    {
        maxIndex = -1;
        maxValue = sortedPoints[index];
        
        for (new searchMax = index + 1; searchMax < MaxClients + 1; searchMax++)
        {
            if(sortedPoints[searchMax] > maxValue)
            {
                maxIndex = searchMax;
                maxValue = sortedPoints[searchMax];
            }
        }
        
        if (maxIndex != -1)
        {
            SwapArrayitems(g_iRankDisplay_SortedClients, index, maxIndex);
            SwapArrayitems(sortedPoints, index, maxIndex);
            g_iRankDisplay_ClientslocalRanks[g_iRankDisplay_SortedClients[index]] = index;
            g_iRankDisplay_ClientslocalRanks[g_iRankDisplay_SortedClients[maxIndex]] = maxIndex;
        }
    }
}

stock rankDisplay_RegisterMessage()
{
    g_hRankDisplay_MessageHandle = userMessage_RegisterNewMessage(
                                            eUserMessages_ToHint,
                                            rankDisplay_BuildCallBack,
                                            .buildcallBackArgument = 0,
                                            .repeatPeriod = g_iRankDisplay_Period,
                                            .repeatCount = 0,
                                            .minDisplayTime = g_iRankDisplay_Duration,
                                            .flags = USER_MESSAGES_FLAG_REPEAT_INFINITE | USER_MESSAGES_FLAG_BROADCAST_ON_CONNECT,
                                            .priority= 20
                                        );
}

stock TerminateNameUTF8(String:name[])
{
    new len = strlen(name);
    
    for (new i = 0; i < len; i++)
    {
        new bytes = IsCharMB(name[i]);
        
        if (bytes > 1)
        {
            if (len - i < bytes)
            {
                name[i] = '\0';
                return;
            }
            
            i += bytes - 1;
        }
    }
}  

stock bool:rankDisplay_BuildRankStr(clientIndex, String:message[], length, clientEmphasis)
{
    decl String:clientName[15];
    decl String:clientNameEscaped[30];
    decl String:line[255];
    decl start,end;
    
    message[0] = '\0';
    
    if(g_iRankDisplay_ClientslocalRanks[clientIndex] > 1)
    {
        start = g_iRankDisplay_ClientslocalRanks[clientIndex] - 1;
    }
    else
    {
        start = g_iRankDisplay_ClientslocalRanks[clientIndex];
    }
    
    end = start + 2;
    if (end > MaxClients) end = MaxClients;
        
    
    for(new i = start; i <= end; i++)
    {
        new client = g_iRankDisplay_SortedClients[i];
        
        if (players_IsClientValid(client) && g_iRankDisplay_ClientsPoints[client] > 0 && GetClientName(client, clientName, sizeof(clientName)))
        {
            TerminateNameUTF8(clientName);
            StrEscapeHTML(clientNameEscaped, sizeof(clientNameEscaped), clientName);
            decl String:color[7];
            
            if(i == 1) strcopy(color, sizeof(color), "FF9900");
            else if (i == 2) strcopy(color, sizeof(color), "C99936");
            else if (i == 3) strcopy(color, sizeof(color), "A3995C");
            else strcopy(color, sizeof(color), "669999");
            
            if (client == clientEmphasis)
            {
                Format(line, sizeof(line), "<font size='22' color='#%s'>%d.%s</font> [%d pts]\n", 
                            color,
                            g_iRankDisplay_ClientslocalRanks[client],
                            clientNameEscaped,
                            g_iRankDisplay_ClientsPoints[client]);
            }
            else
            {
                
                Format(line, sizeof(line), "<font size='18' color='#%s'>%d.%s</font> [%d pts]\n", 
                            color,
                            g_iRankDisplay_ClientslocalRanks[client],
                            clientNameEscaped,
                            g_iRankDisplay_ClientsPoints[client]);
            }
            
            StrCat(message, length, line);
        }
    }
    
    if (message[0] != '\0')
        return true;
    
    return false;
}

public bool:rankDisplay_BuildCallBack(clientIndex, argument, drawCount, drawDuration, String:message[], length)
{
    if (g_bRankDisplay_Available && g_iRankDisplay_ClientsPoints[clientIndex] > 0)
    {
        decl bool:displayed;
        
        if (drawDuration <= RANK_DISPLAY_SELF_DURATION)
            displayed = rankDisplay_BuildRankStr(clientIndex, message, length, clientIndex);
        else
        {
            new idx = g_iRankDisplay_ClientslocalRanks[clientIndex] - (drawDuration - RANK_DISPLAY_SELF_DURATION);
            if (idx < 1) idx = 2-idx;
            if (drawDuration == g_iRankDisplay_Duration)
                idx = 2;
            
            displayed = rankDisplay_BuildRankStr(g_iRankDisplay_SortedClients[idx], message, length, clientIndex);
            
        }
        
        if (!displayed)
            displayed = rankDisplay_BuildRankStr(g_iRankDisplay_SortedClients[2], message, length, clientIndex);
        
        return displayed;
    }
    
    return false;
}