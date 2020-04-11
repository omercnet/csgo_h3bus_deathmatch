#define KV_MAX_STRING_SIZE 1024

new Handle:g_hSmcReader_ConfigTree = INVALID_HANDLE;
static g_iSmcReader_ConfigTimeStamp = 0;
static g_iSmcReader_CurrentNode = NULL_NODE;
static bool:g_bSmcReader_FirstChild = true;

stock smcReader_ProcessConfigFile(const String:file[])
{
    new Handle:hLastConfigTree = g_hSmcReader_ConfigTree;
    new String:sConfigFile[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, sConfigFile, sizeof(sConfigFile), file);
    if (!FileExists(sConfigFile)) 
    {
        if (g_hSmcReader_ConfigTree == INVALID_HANDLE)
            SetFailState("Could not find file %s", sConfigFile);
        else
            LogError("Could not find file %s, resuming with last loaded data", sConfigFile);
    }
    else 
    {
        new iCurrentConfigTimeStamp = GetFileTime(sConfigFile, FileTime_LastChange);
        if (g_iSmcReader_ConfigTimeStamp < iCurrentConfigTimeStamp)
        {
            if (g_hSmcReader_ConfigTree != INVALID_HANDLE)
            {
                g_hSmcReader_ConfigTree = INVALID_HANDLE;
                g_iSmcReader_CurrentNode = NULL_NODE;
                g_bSmcReader_FirstChild = true;
            }
            
            if (!smcReader_ParseConfigFile(sConfigFile))
            {
                if (hLastConfigTree == INVALID_HANDLE)
                    SetFailState("Parse error on file %s", sConfigFile);
                else
                {
                    LogError("Parse error on file %s, resuming with last loaded data", sConfigFile);
                    kvTree_Destroy(g_hSmcReader_ConfigTree);
                    g_hSmcReader_ConfigTree = hLastConfigTree;
                }
            }
            else
            {
                if(hLastConfigTree != INVALID_HANDLE)
                    kvTree_Destroy(hLastConfigTree);
                
                adminMenu_addConfigLoaderItems(g_hSmcReader_ConfigTree);
            }
            
            // Do not reload file until it changes again
            g_iSmcReader_ConfigTimeStamp = iCurrentConfigTimeStamp;
        }
    }
}

stock bool:smcReader_ParseConfigFile(const String:file[]) 
{

    new Handle:hParser = SMC_CreateParser();
    new String:error[128];
    new line = 0;
    new col = 0;
    
    g_iSmcReader_CurrentNode = NULL_NODE;
    g_bSmcReader_FirstChild = true;
    
    /**
    Define the parser functions
    */
    SMC_SetReaders(hParser, smcReader_ConfigNewSection, smcReader_ConfigKeyValue, smcReader_ConfigEndSection);
    SMC_SetParseEnd(hParser, smcReader_ConfigEnd);
    
    /**
    Parse the file and get the result
    */
    new SMCError:result = SMC_ParseFile(hParser, file, line, col);
    CloseHandle(hParser);

    if (result != SMCError_Okay) 
    {
        SMC_GetErrorString(result, error, sizeof(error));
        LogError("%s on line %d, col %d of %s", error, line, col, file);
    }
    
    return (result == SMCError_Okay);
}

public SMCResult:smcReader_ConfigNewSection(Handle:parser, const String:section[], bool:quotes) 
{
    // Root node is not created yet
    if (g_iSmcReader_CurrentNode == NULL_NODE)
    {
        g_hSmcReader_ConfigTree = kvTree_Create(KV_MAX_STRING_SIZE, KV_MAX_STRING_SIZE, section, NULL_STRING);
        kvTree_GetSectionSymbol(g_hSmcReader_ConfigTree, g_iSmcReader_CurrentNode);
    }
    // We are the first child of a node
    else if (g_bSmcReader_FirstChild)
    {
        g_iSmcReader_CurrentNode = kvTree_AddNode(g_hSmcReader_ConfigTree, g_iSmcReader_CurrentNode, NULL_NODE, section, NULL_STRING);
    }
    // We have a previous node
    else
    {
        g_iSmcReader_CurrentNode = kvTree_AddNode(g_hSmcReader_ConfigTree, NULL_NODE, g_iSmcReader_CurrentNode, section, NULL_STRING);
    }
    
    // New section => next key will be first child
    g_bSmcReader_FirstChild = true;
    
    return SMCParse_Continue;
}

public SMCResult:smcReader_ConfigKeyValue(Handle:parser, const String:key[], const String:value[], bool:key_quotes, bool:value_quotes)
{
    // Root node is not created yet: This should not be possible here, but still handled "in case"
    if (g_iSmcReader_CurrentNode == NULL_NODE)
    {
        g_hSmcReader_ConfigTree = kvTree_Create(KV_MAX_STRING_SIZE, KV_MAX_STRING_SIZE, key, value);
        g_iSmcReader_CurrentNode = kvTree_GetSectionSymbol;
    }
    // We are the first child of a node
    else if (g_bSmcReader_FirstChild)
    {
        g_iSmcReader_CurrentNode = kvTree_AddNode(g_hSmcReader_ConfigTree, g_iSmcReader_CurrentNode, NULL_NODE, key, value);
    }
    // We have a previous node
    else
    {
        g_iSmcReader_CurrentNode = kvTree_AddNode(g_hSmcReader_ConfigTree, NULL_NODE, g_iSmcReader_CurrentNode, key, value);
    }
    
    // Next key will be a sibling
    g_bSmcReader_FirstChild = false;
    
    return SMCParse_Continue;
}

public SMCResult:smcReader_ConfigEndSection(Handle:parser) 
{
    // Get parent if at least one child was added
    if (!g_bSmcReader_FirstChild)
        g_iSmcReader_CurrentNode = kvTree_GetParent(g_hSmcReader_ConfigTree, g_iSmcReader_CurrentNode);
    
    // Next key will be a sibling (as a parent exists)
    g_bSmcReader_FirstChild = false;
    
    return SMCParse_Continue;
}

public smcReader_ConfigEnd(Handle:parser, bool:halted, bool:failed) 
{
    if (failed)
    {
        SetFailState("Plugin configuration error");
    }
}  