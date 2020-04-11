
static Handle:g_hAdminMenu_TopLevelMenu = INVALID_HANDLE;
static Handle:g_hAdminMenu_RespawnMenu = INVALID_HANDLE;
static Handle:g_hAdminMenu_SpawnEditorMenu = INVALID_HANDLE;
static Handle:g_hAdminMenu_SpawnTesterMenu = INVALID_HANDLE;
static Handle:g_hAdminMenu_ConfigLoaderModeMenu = INVALID_HANDLE;
static Handle:g_hAdminMenu_ConfigLoaderPreviousMenu = INVALID_HANDLE;
static Handle:g_hAdminMenu_ConfigLoaderMenuTreeFULL = INVALID_HANDLE;
static Handle:g_hAdminMenu_ConfigLoaderMenuTreeMOD = INVALID_HANDLE;

static g_iAdminMenu_ConfigLoaderSection;
static bool:g_bAdminMenu_ConfigLoaderAsMod = false;

stock adminMenu_init()
{
    g_hAdminMenu_TopLevelMenu = adminMenu_buildTopLevel();
    g_hAdminMenu_RespawnMenu = adminMenu_buildRespawns();
    g_hAdminMenu_SpawnEditorMenu = adminMenu_buildSpawnsEditor();
    g_hAdminMenu_SpawnTesterMenu = adminMenu_buildSpawnsTester();
    g_hAdminMenu_ConfigLoaderMenuTreeFULL = adminMenu_buildConfigLoader(.asMod = false);
    g_hAdminMenu_ConfigLoaderMenuTreeMOD = adminMenu_buildConfigLoader(.asMod = true);
    g_hAdminMenu_ConfigLoaderModeMenu = adminMenu_buildConfigLoaderMode();
}

stock adminMenu_DisplayRoot(clientIndex, Handle:backMenu=INVALID_HANDLE)
{    
    SetMenuExitBackButton(g_hAdminMenu_TopLevelMenu, backMenu != INVALID_HANDLE);
    
    menusFifo_DisplayMenu(g_hAdminMenu_TopLevelMenu, clientIndex, MENU_TIME_FOREVER);
}

stock Handle:adminMenu_buildTopLevel()
{
    decl Handle:menu;
    
    menu = CreateMenu(adminMenu_TopLevelHandler);
        
    SetMenuTitle( menu, "Deathmatch admin");
    
    SetMenuExitButton(menu, true);
    
    AddMenuItem( menu, "Respawn", "Respawn players");
    AddMenuItem( menu, "FULL Config Loader", "Configuration Loader");
    AddMenuItem( menu, "MOD Config Loader", "Modifier Configuration Loader");
    AddMenuItem( menu, "Spawns Editor", "Spawns Editor");
    AddMenuItem( menu, "Spawns Tester", "Spawns Tester");
    
    return menu;
}

public adminMenu_TopLevelHandler(Handle:menu, MenuAction:action, param1, param2)
{
    if ((action == MenuAction_Select) && players_IsClientValid(param1))
    {
        decl String:info[20];
        GetMenuItem(menu, param2, info, sizeof(info));
                
        if (StrEqual(info, "Respawn"))
        {
            menusFifo_DisplayMenu(g_hAdminMenu_RespawnMenu, param1, MENU_TIME_FOREVER, .killFirst=true);
        }
        else if (StrEqual(info, "Spawns Editor"))
        {
            menusFifo_DisplayMenu(g_hAdminMenu_SpawnEditorMenu, param1, MENU_TIME_FOREVER, .killFirst=true);
        }
        else if (StrEqual(info, "Spawns Tester"))
        {
            menusFifo_DisplayMenu(g_hAdminMenu_SpawnTesterMenu, param1, MENU_TIME_FOREVER, .killFirst=true);
        }
        else if (StrEqual(info, "FULL Config Loader"))
        {
            menusFifo_DisplayMenu(Handle:adminMenuTree_GetNodeValue(g_hAdminMenu_ConfigLoaderMenuTreeFULL, 0), param1, MENU_TIME_FOREVER, .killFirst=true);
        }
        else if (StrEqual(info, "MOD Config Loader"))
        {
            menusFifo_DisplayMenu(Handle:adminMenuTree_GetNodeValue(g_hAdminMenu_ConfigLoaderMenuTreeMOD, 0), param1, MENU_TIME_FOREVER, .killFirst=true);
        }
        else
            menusFifo_OnMenuClosed(param1);
    }
    else if(action == MenuAction_Cancel && param2 == MenuCancel_Exit && players_IsClientValid(param1))
        menusFifo_OnMenuClosed(param1);
}

stock Handle:adminMenu_buildRespawns()
{
    decl Handle:menu;
    
    menu = CreateMenu(adminMenu_CommandHandlerLevel1);
        
    SetMenuTitle( menu, "Respawn");
    
    SetMenuExitButton(menu, true);
    SetMenuExitBackButton(menu,true);
    
    AddMenuItem( menu, "dm_respawn_all", "Respawn all players");
    AddMenuItem( menu, "dm_respawn_dead", "Respawn dead players");
    
    return menu;
}

stock Handle:adminMenu_buildSpawnsEditor()
{
    decl Handle:menu;
    
    menu = CreateMenu(adminMenu_PersistentCommandHandlerLevel1);
        
    SetMenuTitle( menu, "Spawns Editor");
    
    SetMenuExitButton(menu, true);
    SetMenuExitBackButton(menu,true);
    
    AddMenuItem( menu, "dm_spawns_show", "Toggle spawn point display");
    AddMenuItem( menu, "dm_spawns_add", "Add: Deathmatch point");
    AddMenuItem( menu, "dm_spawns_add T", "Add: Terrorist point");
    AddMenuItem( menu, "dm_spawns_add CT", "Add: Counter-Terrorist point");
    AddMenuItem( menu, "dm_spawns_delete", "Delete nearest point");
    AddMenuItem( menu, "dm_spawns_save", "Save spawns");
    AddMenuItem( menu, "dm_spawns_import", "Import original map points");
    
    return menu;
}

stock Handle:adminMenu_buildSpawnsTester()
{
    decl Handle:menu;
    
    menu = CreateMenu(adminMenu_PersistentCommandHandlerLevel1);
        
    SetMenuTitle( menu, "Spawns Tester");
    
    SetMenuExitButton(menu, true);
    SetMenuExitBackButton(menu,true);
    
    AddMenuItem( menu, "dm_spawns_show", "Toggle spawn point display");
    AddMenuItem( menu, "dm_spawns_test first", "Spawn to first point");
    AddMenuItem( menu, "dm_spawns_test next", "Spawn to next point");
    AddMenuItem( menu, "dm_spawns_test prev", "Spawn to previous point");
    AddMenuItem( menu, "dm_spawns_delete", "Delete nearest point");
    
    return menu;
}

stock adminMenu_Clear(Handle:menuTree, node = 0)
{
    new currentNode = node;
    new Handle:topMenu;
    decl String:sectionName[MAX_STRING_SIZE];
    
    adminMenuTree_GetNodeKey(menuTree, currentNode, sectionName, sizeof(sectionName));
    
    if(currentNode == 0)
    {
        topMenu = Handle:adminMenuTree_GetNodeValue(menuTree, currentNode);
        RemoveAllMenuItems(topMenu);
    }
    else if(FindCharInString(sectionName, '/') != -1)
        CloseHandle(Handle:adminMenuTree_GetNodeValue(menuTree, currentNode));
    
    if((currentNode = adminMenuTree_GetFirstChild(menuTree, currentNode)) == NULL_NODE)
            return;
    
    do{
        adminMenu_Clear(menuTree, currentNode);
    } while((currentNode = adminMenuTree_GetNextSibling(menuTree, currentNode)) !=  NULL_NODE);
    
    if(node == 0)
    {
        adminMenuTree_Clear(menuTree);
        adminMenuTree_AddNode(menuTree, NULL_NODE, NULL_NODE, "/", _:topMenu);
    }
}

stock Handle:adminMenu_buildConfigLoaderMenu(bool:asMod = false)
{
    decl Handle:menu;
    
    if(!asMod)
    {
        menu = CreateMenu(adminMenu_CommandConfigLoaderLevel1);
        SetMenuTitle( menu, "Configuration load");
    }
    else
    {
        menu = CreateMenu(adminMenu_CommandConfigLoaderModLevel1);
        SetMenuTitle( menu, "Modifier Configuration load");
    }
    
    SetMenuExitButton(menu, true);
    SetMenuExitBackButton(menu,true);
    
    return menu;
}

stock Handle:adminMenu_buildConfigLoader(bool:asMod = false)
{    
    return adminMenuTree_Create(MAX_STRING_SIZE, "/", _:adminMenu_buildConfigLoaderMenu(asMod));
}

stock bool:adminMenu_ShouldResetClientSetting(Handle:configTree, sectionId)
{
    decl String:modOption[KV_MAX_STRING_SIZE];
    
    kvTree_JumpToKeySymbol(configTree, sectionId);
    
    if(
        kvTree_GotoFirstSubKey(configTree) && kvTree_JumpToKey(configTree, "SectionOptions") &&
        kvTree_GotoFirstSubKey(configTree) && kvTree_JumpToKey(configTree, "LoadAsAMod")
       )
    {
        kvTree_GetValue(configTree, modOption, sizeof(modOption));
        
        if(StrEqual(modOption, "KeepClientSettings", false))
            return false;
    }
    
    return true;
}

stock bool:adminMenu_GetSectionName(Handle:configTree, &bool:loadedAsMod, String:name[], size=sizeof name, bool:displayName=false)
{
    new bool:found = false;
    loadedAsMod = false;
    
    if (kvTree_GotoFirstSubKey(configTree))
    {
        if(kvTree_JumpToKey(configTree, "SectionOptions"))
        {
            if (kvTree_GotoFirstSubKey(configTree))
            {
                if(displayName && kvTree_JumpToKey(configTree, "PlayerDisplay"))
                {
                    found = true;
                    kvTree_GetValue(configTree, name, size);
                }
                else if(kvTree_JumpToKey(configTree, "AdminMenuName"))
                {
                    found = true;
                    kvTree_GetValue(configTree, name, size);
                }
                
                if(kvTree_JumpToKey(configTree, "LoadAsAMod"))
                    loadedAsMod = true;
                
                kvTree_GoBack(configTree);
            }
        }
        
        kvTree_GoBack(configTree);
    }
    
    if(!found)
        kvTree_GetSectionName(configTree, name, size);
    
    return found;
}

stock Handle:adminMenu_addConfigLoaderItem(Handle:menuTree, String:sectionId[], String:sectionName[], bool:asMod)
{
    new strStart = 0;
    new strEnd = 0;
    new parentSectionNode = KVTREE_ROOT_INDEX;
    decl String:sectionNodeName[MAX_STRING_SIZE];
    
    new Handle:childMenu;
    new Handle:parentMenu;
    
    if(sectionName[strStart] == '/')
        strStart++;
        
    while((strEnd = FindCharInString(sectionName[strStart], '/')) != -1)
    {
        strcopy(sectionNodeName, strEnd + 2, sectionName[strStart]);
        strStart = strStart + strEnd + 1;
        
        
        new foundNode = adminMenuTree_FindChild(menuTree, parentSectionNode, sectionNodeName);
        if(foundNode != -1)
            parentSectionNode = foundNode;
        else
        {
            new childcount = adminMenuTree_GetNodeChildCount(menuTree, parentSectionNode);
            new previousNode = NULL_NODE;
            
            if(childcount > 0)
                previousNode = adminMenuTree_GetNodeChildItem(menuTree, parentSectionNode, childcount - 1);
                
            childMenu = adminMenu_buildConfigLoaderMenu(asMod);
            
            parentMenu = Handle:adminMenuTree_GetNodeValue(menuTree, parentSectionNode);
            
            AddMenuItem(parentMenu, sectionNodeName, sectionNodeName);
            parentSectionNode = adminMenuTree_AddNode(menuTree, parentSectionNode, previousNode, sectionNodeName, _:childMenu);
        }
    }
    
    parentMenu = Handle:adminMenuTree_GetNodeValue(menuTree, parentSectionNode);
    AddMenuItem(parentMenu, sectionId, sectionName[strStart]);
}

stock Handle:adminMenu_addConfigLoaderItems(Handle:configTree)
{
    decl sectionSymbol;
    decl bool:sectionLoadAsMod;
    decl String:sectionId[10];
    decl String:sectionName[KV_MAX_STRING_SIZE];
    
    adminMenu_Clear(g_hAdminMenu_ConfigLoaderMenuTreeFULL);
    adminMenu_Clear(g_hAdminMenu_ConfigLoaderMenuTreeMOD);
    
    kvTree_Rewind(configTree);
    
    if (!kvTree_GotoFirstSubKey(configTree))
        return;
    
    do{
        if (!kvTree_GotoFirstSubKey(configTree))
            continue;
        
        do{
            if(adminMenu_GetSectionName(configTree, sectionLoadAsMod, sectionName, sizeof(sectionName)))
            {
                kvTree_GetSectionSymbol(configTree, sectionSymbol);
                IntToString(sectionSymbol, sectionId, sizeof(sectionId));
                
                if(sectionLoadAsMod)
                    adminMenu_addConfigLoaderItem(g_hAdminMenu_ConfigLoaderMenuTreeMOD, sectionId, sectionName, .asMod=true);
                else
                    adminMenu_addConfigLoaderItem(g_hAdminMenu_ConfigLoaderMenuTreeFULL, sectionId, sectionName, .asMod=false);
            }
            
        } while (kvTree_GotoNextKey(configTree, false));
        
        kvTree_GoBack(configTree);
        
    } while (kvTree_GotoNextKey(configTree, false));
}

stock Handle:adminMenu_buildConfigLoaderMode()
{
    decl Handle:menu;
    
    menu = CreateMenu(adminMenu_CommandConfigLoaderLevel2);
        
    SetMenuTitle( menu, "Load mode");
    
    AddMenuItem( menu, "", "Load");
    AddMenuItem( menu, "equip", "Load and EQUIP all players");
    AddMenuItem( menu, "respawn", "Load and RESPAWN all players");
    AddMenuItem( menu, "restart", "Load and RESTART game");
    AddMenuItem( menu, "nextround", "Load at NEXT ROUND");
    SetMenuExitButton(menu, true);
    SetMenuExitBackButton(menu,true);
        
    return menu;
}

public adminMenu_CommandHandlerLevel1(Handle:menu, MenuAction:action, param1, param2)
{
    if ((action == MenuAction_Select) && players_IsClientValid(param1))
    {
        decl String:info[30];
        GetMenuItem(menu, param2, info, sizeof(info));
        
        FakeClientCommand(param1, info);
        
        menusFifo_OnMenuClosed(param1, menu);
    }
    else if(action == MenuAction_Cancel && players_IsClientValid(param1))
        if(param2 ==  MenuCancel_ExitBack)
            menusFifo_DisplayMenu(g_hAdminMenu_TopLevelMenu, param1, MENU_TIME_FOREVER, .killFirst=true);
        else if(param2 == MenuCancel_Exit)
            menusFifo_OnMenuClosed(param1, menu);
}

public adminMenu_PersistentCommandHandlerLevel1(Handle:menu, MenuAction:action, param1, param2)
{
    adminMenu_CommandHandlerLevel1(menu, action, param1, param2);
    
    if ((action == MenuAction_Select) && players_IsClientValid(param1))
        menusFifo_DisplayMenu(menu, param1, MENU_TIME_FOREVER, .killFirst=true);
    else if(action == MenuAction_Cancel && param2 == MenuCancel_Exit && players_IsClientValid(param1))
        menusFifo_OnMenuClosed(param1, menu);
}

public adminMenu_CommandConfigLoaderLevel1(Handle:menu, MenuAction:action, param1, param2)
{
    new menuNode;
    
    if ((action == MenuAction_Select) && players_IsClientValid(param1))
    {
        decl String:info[KV_MAX_STRING_SIZE];
        GetMenuItem(menu, param2, info, sizeof(info));
        
        if(FindCharInString(info, '/') != -1)
        {
            menuNode = adminMenuTree_FindValue(g_hAdminMenu_ConfigLoaderMenuTreeFULL, _:menu);
            menuNode = adminMenuTree_FindChild(g_hAdminMenu_ConfigLoaderMenuTreeFULL, menuNode, info);
            menusFifo_DisplayMenu(Handle:adminMenuTree_GetNodeValue(g_hAdminMenu_ConfigLoaderMenuTreeFULL, menuNode), param1, MENU_TIME_FOREVER, .killFirst=true);
        }
        else
        {
            g_iAdminMenu_ConfigLoaderSection = StringToInt(info);
            g_bAdminMenu_ConfigLoaderAsMod = false;
            g_hAdminMenu_ConfigLoaderPreviousMenu = menu;
            menusFifo_DisplayMenu(g_hAdminMenu_ConfigLoaderModeMenu, param1, MENU_TIME_FOREVER, .killFirst=true);
        }
    }
    else if(action == MenuAction_Cancel && param2 == MenuCancel_ExitBack && players_IsClientValid(param1))
    {
        menuNode = adminMenuTree_FindValue(g_hAdminMenu_ConfigLoaderMenuTreeFULL, _:menu);
        menuNode = adminMenuTree_GetParent(g_hAdminMenu_ConfigLoaderMenuTreeFULL, menuNode);
        
        if(menuNode == NULL_NODE)
            menusFifo_DisplayMenu(g_hAdminMenu_TopLevelMenu, param1, MENU_TIME_FOREVER, .killFirst=true);
        else
            menusFifo_DisplayMenu(Handle:adminMenuTree_GetNodeValue(g_hAdminMenu_ConfigLoaderMenuTreeFULL, menuNode), param1, MENU_TIME_FOREVER, .killFirst=true);
    }
    else if(action == MenuAction_Cancel && param2 == MenuCancel_Exit && players_IsClientValid(param1))
        menusFifo_OnMenuClosed(param1, menu);
}

public adminMenu_CommandConfigLoaderModLevel1(Handle:menu, MenuAction:action, param1, param2)
{
    new menuNode;
    
    if ((action == MenuAction_Select) && players_IsClientValid(param1))
    {
        decl String:info[KV_MAX_STRING_SIZE];
        GetMenuItem(menu, param2, info, sizeof(info));
        
        if(FindCharInString(info, '/') != -1)
        {
            menuNode = adminMenuTree_FindValue(g_hAdminMenu_ConfigLoaderMenuTreeMOD, _:menu);
            menuNode = adminMenuTree_FindChild(g_hAdminMenu_ConfigLoaderMenuTreeMOD, menuNode, info);
            menusFifo_DisplayMenu(Handle:adminMenuTree_GetNodeValue(g_hAdminMenu_ConfigLoaderMenuTreeMOD, menuNode), param1, MENU_TIME_FOREVER, .killFirst=true);
        }
        else
        {
            g_iAdminMenu_ConfigLoaderSection = StringToInt(info);
            g_bAdminMenu_ConfigLoaderAsMod = true;
            g_hAdminMenu_ConfigLoaderPreviousMenu = menu;
            menusFifo_DisplayMenu(g_hAdminMenu_ConfigLoaderModeMenu, param1, MENU_TIME_FOREVER, .killFirst=true);
        }
    }
    else if(action == MenuAction_Cancel && param2 ==  MenuCancel_ExitBack && players_IsClientValid(param1))
    {
        menuNode = adminMenuTree_FindValue(g_hAdminMenu_ConfigLoaderMenuTreeMOD, _:menu);
        menuNode = adminMenuTree_GetParent(g_hAdminMenu_ConfigLoaderMenuTreeMOD, menuNode);
        
        if(menuNode == NULL_NODE)
            menusFifo_DisplayMenu(g_hAdminMenu_TopLevelMenu, param1, MENU_TIME_FOREVER, .killFirst=true);
        else
            menusFifo_DisplayMenu(Handle:adminMenuTree_GetNodeValue(g_hAdminMenu_ConfigLoaderMenuTreeMOD, menuNode), param1, MENU_TIME_FOREVER, .killFirst=true);
    }
    else if(action == MenuAction_Cancel && param2 == MenuCancel_Exit && players_IsClientValid(param1))
        menusFifo_OnMenuClosed(param1, menu);
}

public adminMenu_CommandConfigLoaderLevel2(Handle:menu, MenuAction:action, param1, param2)
{
    if ((action == MenuAction_Select) && players_IsClientValid(param1))
    {
        decl String:info[10];
        GetMenuItem(menu, param2, info, sizeof(info));
        
        if(g_bAdminMenu_ConfigLoaderAsMod)
            menusFifo_DisplayMenu(g_hAdminMenu_ConfigLoaderPreviousMenu, param1, MENU_TIME_FOREVER, .killFirst=true);
        else
            menusFifo_OnMenuClosed(param1, menu);
        
        adminCmd_Load_Section(g_iAdminMenu_ConfigLoaderSection, info, g_bAdminMenu_ConfigLoaderAsMod);
    }
    else if(action == MenuAction_Cancel && param2 ==  MenuCancel_ExitBack && players_IsClientValid(param1))
        menusFifo_DisplayMenu(g_hAdminMenu_ConfigLoaderPreviousMenu, param1, MENU_TIME_FOREVER, .killFirst=true);
    else if(action == MenuAction_Cancel && param2 == MenuCancel_Exit && players_IsClientValid(param1))
        menusFifo_OnMenuClosed(param1, menu);
}