

enum menus_Type
{
    Handle:menus_Type_Option,
    Handle:menus_Type_Primary,
    Handle:menus_Type_Secondary
};

static Handle:g_hMenus_WeaponMenus[MAXPLAYERS + 1][menus_Type];

stock menus_Init()
{
    for (new i = 0; i < MAXPLAYERS + 1; i++)
    {
        g_hMenus_WeaponMenus[i][menus_Type_Option] = INVALID_HANDLE;
        g_hMenus_WeaponMenus[i][menus_Type_Primary] = INVALID_HANDLE;
        g_hMenus_WeaponMenus[i][menus_Type_Secondary] = INVALID_HANDLE;
    }
}

stock menus_Close()
{
    for (new i = 0; i < MAXPLAYERS + 1; i++)
    {
        menus_DestroyMenus(i);
    }
}

stock menus_IsValidMenu(client, menus_Type:type)
{
    return (g_hMenus_WeaponMenus[client][type] != INVALID_HANDLE);
}

stock menus_DestroyMenuType(client, menus_Type:type)
{
    if (menus_IsValidMenu(client, type))
    {
        menusFifo_Remove(client, g_hMenus_WeaponMenus[client][type]);
        CancelMenu(g_hMenus_WeaponMenus[client][type]);
        CloseHandle(g_hMenus_WeaponMenus[client][type]);
        g_hMenus_WeaponMenus[client][type] = INVALID_HANDLE;
    }
}

stock menus_DestroyMenus(client)
{
    menus_DestroyMenuType(client, menus_Type_Option);
    menus_DestroyMenuType(client, menus_Type_Primary);
    menus_DestroyMenuType(client, menus_Type_Secondary);
}

stock menus_DisplayOptionsMenu(clientIndex)
{
    menus_DestroyMenuType(clientIndex, menus_Type_Option);
    menus_BuildOptionsMenu(clientIndex);
    menusFifo_DisplayMenu(g_hMenus_WeaponMenus[clientIndex][menus_Type_Option], clientIndex, MENU_TIME_FOREVER);
}

stock Handle:menus_BuildOptionsMenu(clientIndex)
{
    decl String:translatedStr[255];
    
    g_hMenus_WeaponMenus[clientIndex][menus_Type_Option] = CreateMenu(menus_OptionsMenuCallback);
    
    Format(translatedStr, sizeof(translatedStr), "%T:", "Weapons Shop", clientIndex);
    SetMenuTitle( g_hMenus_WeaponMenus[clientIndex][menus_Type_Option], translatedStr);
    
    SetMenuExitButton( g_hMenus_WeaponMenus[clientIndex][menus_Type_Option], false);
    
    Format(translatedStr, sizeof(translatedStr), "%T", "New weapons", clientIndex);
    AddMenuItem( g_hMenus_WeaponMenus[clientIndex][menus_Type_Option], "New", translatedStr);
    
    Format(translatedStr, sizeof(translatedStr), "%T", "Random weapons", clientIndex);
    AddMenuItem( g_hMenus_WeaponMenus[clientIndex][menus_Type_Option], "Random", translatedStr);
}

public menus_OptionsMenuCallback(Handle:menu, MenuAction:action, param1, param2)
{
    if ((action == MenuAction_Select) && players_IsClientValid(param1))
    {
        decl String:info[10];
        GetMenuItem(menu, param2, info, sizeof(info));
        
        if (StrEqual(info, "New"))
        {
            menusFifo_Remove(param1, menu);
            
            if (!weapons_IsListEmpty(.weaponPrimary = false))
                menus_BuildDisplayWeaponMenu(param1, false);
            if (!weapons_IsListEmpty(.weaponPrimary = true))
                menus_BuildDisplayWeaponMenu(param1, true);
            
            menusFifo_ShowFirst(param1);
        }
        else if (StrEqual(info, "Random"))
        {
            players_OnPrimarySelected(param1, RANDOM_WEAPON_SELECTED);
            players_OnSecondarySelected(param1, RANDOM_WEAPON_SELECTED);

            menusFifo_OnMenuClosed(param1);
        }
    }
    else if ((action == MenuAction_Cancel) && players_IsClientValid(param1))
    {
        menusFifo_OnMenuClosed(param1);
    }
}

stock menus_BuildDisplayWeaponMenu(clientIndex, bool:primary)
{
    decl String:translatedStr[255];
    new bool:isCT = (GetClientTeam(clientIndex) == CS_TEAM_CT);
    new menus_Type:type = primary ? menus_Type_Primary : menus_Type_Secondary;
    
    menus_DestroyMenuType(clientIndex, type);
    
    if (primary)
    {
        g_hMenus_WeaponMenus[clientIndex][type] = CreateMenu(menus_PrimaryMenuCallBack);
        Format(translatedStr, sizeof(translatedStr), "%T:", "Primary Weapons", clientIndex);
        SetMenuTitle(g_hMenus_WeaponMenus[clientIndex][type], translatedStr);
    }
    else
    {
        g_hMenus_WeaponMenus[clientIndex][type] = CreateMenu(menus_SecondaryMenuCallBack);
        Format(translatedStr, sizeof(translatedStr), "%T:", "Secondary Weapons", clientIndex);
        SetMenuTitle(g_hMenus_WeaponMenus[clientIndex][type], translatedStr);
    }
        
    weapons_BuildListedMenu(g_hMenus_WeaponMenus[clientIndex][type], primary, isCT, clientIndex);
    
    menusFifo_AddItem(clientIndex, g_hMenus_WeaponMenus[clientIndex][type], .first = true);
}

public menus_PrimaryMenuCallBack(Handle:menu, MenuAction:action, param1, param2)
{
    if ((action == MenuAction_Select) && players_IsClientValid(param1))
    {
        decl String:infoStr[9];
        GetMenuItem(menu, param2, infoStr, sizeof(infoStr));
        
        new weaponId = StringToInt(infoStr);
        
        new weapons_MenuActions:weaponAction = weapons_MenuDecodeAction(weaponId);
        
        if(weaponAction == weapons_MenuActions_Equip)
        {
            players_OnPrimarySelected(param1, weaponId);
            
            menusFifo_OnMenuClosed(param1);
        }
        else if(weaponAction == weapons_MenuActions_GetInWaitLine)
        {
            weapons_EnterWaitLine(param1, weaponId);
            
            menusFifo_OnMenuClosed(param1);
            
            if(g_fConfig_LimitedWeaponsRotationTime > 0)
            {
                decl String:weaponName[WEAPON_NAME_SIZE];
                decl String:formatedWeaponName[WEAPON_NAME_SIZE+2];
                decl String:timeStr[10];
                decl String:timeStrFormated[12];
                new Float:time = weaponTracking_GetWaitTime(weapons_GetTracker(weaponId), param1, GetClientTeam(param1) == CS_TEAM_CT, weapons_GetLimit(weaponId));
                
                FormatGameTime(timeStr, sizeof(timeStr), time);
                Format(timeStrFormated, sizeof(timeStrFormated), "\x09%s\x01", timeStr);
                weapons_GetName(weaponId, weaponName, WEAPON_NAME_SIZE);
                Format(formatedWeaponName, sizeof(formatedWeaponName), "\x0C%s\x01", weaponName);
                
                PrintToChat(param1, "[ \x02DM\x01 ] %t", "Weapon delayed", formatedWeaponName, timeStrFormated);
            }
            
            if(weapons_GetPrimaryWeaponId(param1) == NO_WEAPON_SELECTED)
            {
                players_OnWeaponStripped(param1, weaponId);
            }
        }
        else if(weaponAction == weapons_MenuActions_GetOutWaitLine)
        {
            weapons_ExitWaitLine(param1, weaponId);
            
            menusFifo_OnMenuClosed(param1);
            
            decl String:weaponName[WEAPON_NAME_SIZE];
            decl String:formatedWeaponName[WEAPON_NAME_SIZE+2];
            
            weapons_GetName(weaponId, weaponName, WEAPON_NAME_SIZE);
            Format(formatedWeaponName, sizeof(formatedWeaponName), "\x0C%s\x01", weaponName);
            
            PrintToChat(param1, "[ \x02DM\x01 ] %t", "Exited wait line", formatedWeaponName);
            
            if(weapons_GetPrimaryWeaponId(param1) == NO_WEAPON_SELECTED)
            {
                players_OnWeaponStripped(param1, weaponId);
            }
        }
    }
    else if (action == MenuAction_Cancel && param2 == MenuCancel_Exit && (players_IsClientValid(param1)))
    {
        players_OnPrimarySelected(param1, NO_WEAPON_SELECTED);
        
        menusFifo_OnMenuClosed(param1);
    }
}

public menus_SecondaryMenuCallBack(Handle:menu, MenuAction:action, param1, param2)
{
    if ((action == MenuAction_Select) && players_IsClientValid(param1))
    {
        decl String:infoStr[9];
        GetMenuItem(menu, param2, infoStr, sizeof(infoStr));
        
        new weaponId = StringToInt(infoStr);
        
        new weapons_MenuActions:weaponAction = weapons_MenuDecodeAction(weaponId);
        
        if(weaponAction == weapons_MenuActions_Equip)
        {
            players_OnSecondarySelected(param1, weaponId);
            
            menusFifo_OnMenuClosed(param1);
        }
        else if(weaponAction == weapons_MenuActions_GetInWaitLine)
        {
            weapons_EnterWaitLine(param1, weaponId);
            
            menusFifo_OnMenuClosed(param1);
            
            decl String:weaponName[WEAPON_NAME_SIZE];
            decl String:formatedWeaponName[WEAPON_NAME_SIZE+2];
            decl String:timeStr[10];
            decl String:timeStrFormated[12];
            new Float:time = weaponTracking_GetWaitTime(weapons_GetTracker(weaponId), param1, GetClientTeam(param1) == CS_TEAM_CT, weapons_GetLimit(weaponId));
            
            FormatGameTime(timeStr, sizeof(timeStr), time);
            Format(timeStrFormated, sizeof(timeStrFormated), "\x09%s\x01", timeStr);
            weapons_GetName(weaponId, weaponName, WEAPON_NAME_SIZE);
            Format(formatedWeaponName, sizeof(formatedWeaponName), "\x0C%s\x01", weaponName);
            
            PrintToChat(param1, "[ \x02DM\x01 ] %t", "Weapon delayed", formatedWeaponName, timeStrFormated);
            
            if(weapons_GetSecondaryWeaponId(param1) == NO_WEAPON_SELECTED)
            {
                players_OnWeaponStripped(param1, weaponId);
            }
        }
        else if(weaponAction == weapons_MenuActions_GetOutWaitLine)
        {
            weapons_ExitWaitLine(param1, weaponId);
            
            menusFifo_OnMenuClosed(param1);
            
            decl String:weaponName[WEAPON_NAME_SIZE];
            decl String:formatedWeaponName[WEAPON_NAME_SIZE+2];
            
            weapons_GetName(weaponId, weaponName, WEAPON_NAME_SIZE);
            Format(formatedWeaponName, sizeof(formatedWeaponName), "\x0C%s\x01", weaponName);
            
            PrintToChat(param1, "[ \x02DM\x01 ] %t", "Exited wait line", formatedWeaponName);
            
            if(weapons_GetSecondaryWeaponId(param1) == NO_WEAPON_SELECTED)
            {
                players_OnWeaponStripped(param1, weaponId);
            }
        }
    }
    else if (action == MenuAction_Cancel && param2 == MenuCancel_Exit && players_IsClientValid(param1) )
    {
        players_OnSecondarySelected(param1, NO_WEAPON_SELECTED);
        menusFifo_OnMenuClosed(param1);
    }
}

stock menus_OnClientRequestGuns(clientIndex)
{
    decl String:translatedStr[255];
    
    if (g_iConfig_GunMenuMode == 1)
    {
        if (g_bConfig_RandomMenuEnabled)
            menus_DisplayOptionsMenu(clientIndex);
        else
        {
            if(weapons_IsListEmpty(.weaponPrimary = true) && weapons_IsListEmpty(.weaponPrimary = false))
                Format(translatedStr, sizeof(translatedStr), " \x01\x0B\x07%T.", "No weapons available", clientIndex);
            else
            {
                if (!weapons_IsListEmpty(.weaponPrimary = false))
                    menus_BuildDisplayWeaponMenu(clientIndex, false);
                if (!weapons_IsListEmpty(.weaponPrimary = true))
                    menus_BuildDisplayWeaponMenu(clientIndex, true);
                
                menusFifo_ShowFirst(clientIndex);
            }
        }
    }
    else
    {
        Format(translatedStr, sizeof(translatedStr), " \x01\x0B\x07%T.", "The armory is disabled", clientIndex);
        PrintToChat(clientIndex, translatedStr);
    }
}

stock menus_OnClientSpawn(clientIndex)
{
    if (g_iConfig_GunMenuMode == 1) 
    {
        if (g_bConfig_RandomMenuEnabled)
            menus_DisplayOptionsMenu(clientIndex);
        else
        {
            if (!weapons_IsListEmpty(.weaponPrimary = false))
                menus_BuildDisplayWeaponMenu(clientIndex, false);
            if (!weapons_IsListEmpty(.weaponPrimary = true))
                menus_BuildDisplayWeaponMenu(clientIndex, true);
        }
    }
}

stock menus_OnClientSwitchTeam(clientIndex)
{
    new bool:display = false;
    
    if(menusFifo_IsPending(clientIndex, g_hMenus_WeaponMenus[clientIndex][menus_Type_Option]))
    {
        menus_DisplayOptionsMenu(clientIndex);
        display = true;
    }
    
    if(menusFifo_IsPending(clientIndex, g_hMenus_WeaponMenus[clientIndex][menus_Type_Secondary]) && !weapons_IsListEmpty(.weaponPrimary = false))
    {
        menus_BuildDisplayWeaponMenu(clientIndex, false);
        display = true;
    }
    
    if(menusFifo_IsPending(clientIndex, g_hMenus_WeaponMenus[clientIndex][menus_Type_Primary]) && !weapons_IsListEmpty(.weaponPrimary = true))
    {
        menus_BuildDisplayWeaponMenu(clientIndex, true);
        display = true;
    }
    
    if(display)
        menusFifo_ShowFirst(clientIndex);
}

stock menus_OnWeaponStripped(clientIndex, bool:isPrimary)
{
    if (g_iConfig_GunMenuMode == 1) 
    {
        if (!weapons_IsListEmpty(.weaponPrimary = isPrimary))
        {
            menus_BuildDisplayWeaponMenu(clientIndex, isPrimary);
            menusFifo_ShowFirst(clientIndex);
        }
        
    }
}

stock menus_OnMapStart()
{
    for (new i = 1; i < MAXPLAYERS; i++)
        menus_DestroyMenus(i);
}

stock menus_OnClientDisconnect(clientIndex)
{
    menus_DestroyMenus(clientIndex);
}
