enum adminMenuTree_StructureElements {
    adminMenuTree_StructureElement_ArrayParent,
    adminMenuTree_StructureElement_ArrayFirstChild,
    adminMenuTree_StructureElement_ArrayPreviousSibling,
    adminMenuTree_StructureElement_ArrayNextSibling,
    adminMenuTree_StructureElement_ArrayNames,
    adminMenuTree_StructureElement_ArrayValues,
    adminMenuTree_StructureElement_COUNT
}

static adminMenuTree_StructureElementsSize[_:adminMenuTree_StructureElement_COUNT] =
{
    INT_SIZE,          // adminMenuTree_StructureElement_ArrayParent
    INT_SIZE,          // adminMenuTree_StructureElement_ArrayFirstChild
    INT_SIZE,          // adminMenuTree_StructureElement_ArrayPreviousSibling
    INT_SIZE,          // adminMenuTree_StructureElement_ArrayNextSibling
    MAX_STRING_SIZE,   // adminMenuTree_StructureElement_ArrayNames
    INT_SIZE,          // adminMenuTree_StructureElement_ArrayValues
};


stock Handle:adminMenuTree_Create(maxKeySize, const String:rootKey[], rootValue)
{
    new Handle:adminMenuTree = CreateArray(HANDLE_SIZE, _:adminMenuTree_StructureElement_COUNT);
    
    adminMenuTree_StructureElementsSize[_:adminMenuTree_StructureElement_ArrayNames]   = ByteCountToCells(maxKeySize);
    
    for (new index = 0; index < _:adminMenuTree_StructureElement_COUNT; index++)
    {
        SetArrayCell(adminMenuTree, index, CreateArray(adminMenuTree_StructureElementsSize[index]));
    }
        
    adminMenuTree_AddNode(adminMenuTree, NULL_NODE, NULL_NODE, rootKey, rootValue);
    
    return adminMenuTree;
}

stock adminMenuTree_Destroy(Handle:adminMenuTree)
{   
    if (adminMenuTree != INVALID_HANDLE)
    {
        for (new index = 0; index < _:adminMenuTree_StructureElement_COUNT; index++)
        {
            ClearArray( GetArrayCell(adminMenuTree, index));
            CloseHandle(GetArrayCell(adminMenuTree, index));
        }
        
        ClearArray(adminMenuTree);
        CloseHandle(adminMenuTree);
    }
}

stock adminMenuTree_Clear(Handle:adminMenuTree)
{   
    if (adminMenuTree != INVALID_HANDLE)
    {
        for (new index = 0; index < _:adminMenuTree_StructureElement_COUNT; index++)
        {
            ClearArray( GetArrayCell(adminMenuTree, index));
        }
    }
}

stock adminMenuTree_AddNode(Handle:adminMenuTree, parentNode, previousNode, const String:name[], value)
{
    decl nodeIndex;
    decl realParent;
    new nextNode = NULL_NODE;
    
    if (previousNode != NULL_NODE)
        realParent = adminMenuTree_GetParent(adminMenuTree, previousNode);
    else
        realParent = parentNode;
    
    if (previousNode != NULL_NODE)
        nextNode = adminMenuTree_GetNextSibling(adminMenuTree, previousNode);
    else if (realParent != NULL_NODE)
        nextNode = adminMenuTree_GetFirstChild(adminMenuTree, realParent);
    
    nodeIndex = PushArrayCell(GetArrayCell(adminMenuTree, _:adminMenuTree_StructureElement_ArrayParent),  realParent);
    PushArrayCell(  GetArrayCell(adminMenuTree, _:adminMenuTree_StructureElement_ArrayFirstChild),        NULL_NODE);
    PushArrayCell(  GetArrayCell(adminMenuTree, _:adminMenuTree_StructureElement_ArrayPreviousSibling),   previousNode);
    PushArrayCell(  GetArrayCell(adminMenuTree, _:adminMenuTree_StructureElement_ArrayNextSibling),       nextNode);
    PushArrayString(GetArrayCell(adminMenuTree, _:adminMenuTree_StructureElement_ArrayNames),             name);
    PushArrayCell  (GetArrayCell(adminMenuTree, _:adminMenuTree_StructureElement_ArrayValues),            value);
    
    if (previousNode != NULL_NODE)
        adminMenuTree_SetNextSibling(adminMenuTree, previousNode, nodeIndex);
    else if (realParent != NULL_NODE)
        adminMenuTree_SetFirstChild(adminMenuTree, realParent, nodeIndex);
    
    if (nextNode != NULL_NODE)
        adminMenuTree_SetPreviousSibling(adminMenuTree, nextNode, nodeIndex);
    
    return nodeIndex;
}

stock adminMenuTree_RemoveNode(Handle:adminMenuTree, node, bool:updateLinks=true)
{
    new retNode = NULL_NODE;
    new child = adminMenuTree_GetFirstChild(adminMenuTree, node);
    new nextChild;
    
    if(updateLinks)
    {
        new previousNode = adminMenuTree_GetPreviousSibling(adminMenuTree, node);
        new nextNode = adminMenuTree_GetNextSibling(adminMenuTree, node);
        new parentNode = adminMenuTree_GetParent(adminMenuTree, node);
        
        if (parentNode != NULL_NODE)
            adminMenuTree_SetNextSibling(adminMenuTree, previousNode, nextNode);
        else if (parentNode != NULL_NODE)
            adminMenuTree_SetFirstChild(adminMenuTree, parentNode, nextNode);
        
        if (nextNode != NULL_NODE)
            adminMenuTree_SetPreviousSibling(adminMenuTree, nextNode, previousNode);
        
        retNode = nextNode != NULL_NODE? nextNode : parentNode;
    }
    
    while(child != NULL_NODE)
    {
        nextChild = adminMenuTree_GetNextSibling(adminMenuTree, child);
        adminMenuTree_RemoveNode(adminMenuTree, child, .updateLinks=false);
        child = nextChild;
    }
    
    for (new index = 0; index < _:adminMenuTree_StructureElement_COUNT; index++)
        RemoveFromArray( GetArrayCell(adminMenuTree, index), node);
    
    return retNode;
}

stock adminMenuTree_SetFirstChild(Handle:adminMenuTree, node, firstChild)
{
    SetArrayCell(GetArrayCell(adminMenuTree, _:adminMenuTree_StructureElement_ArrayFirstChild), node, firstChild);
}

stock adminMenuTree_GetFirstChild(Handle:adminMenuTree, node)
{
    if (node == NULL_NODE)
        return NULL_NODE;
    else
        return GetArrayCell(GetArrayCell(adminMenuTree, _:adminMenuTree_StructureElement_ArrayFirstChild), node);
}

stock adminMenuTree_GetPreviousSibling(Handle:adminMenuTree, node)
{
    if (node == NULL_NODE)
        return NULL_NODE;
    else
        return GetArrayCell(GetArrayCell(adminMenuTree, _:adminMenuTree_StructureElement_ArrayPreviousSibling), node);
}

stock adminMenuTree_SetPreviousSibling(Handle:adminMenuTree, node, previousSibling)
{
    SetArrayCell(GetArrayCell(adminMenuTree, _:adminMenuTree_StructureElement_ArrayPreviousSibling), node, previousSibling);
}

stock adminMenuTree_GetNextSibling(Handle:adminMenuTree, node)
{
    if (node == NULL_NODE)
        return NULL_NODE;
    else
        return GetArrayCell(GetArrayCell(adminMenuTree, _:adminMenuTree_StructureElement_ArrayNextSibling), node);
}

stock adminMenuTree_SetNextSibling(Handle:adminMenuTree, node, nextSibling)
{
    SetArrayCell(GetArrayCell(adminMenuTree, _:adminMenuTree_StructureElement_ArrayNextSibling), node, nextSibling);
}

stock adminMenuTree_GetParent(Handle:adminMenuTree, node)
{
    if (node == NULL_NODE)
        return NULL_NODE;
    else
        return GetArrayCell(GetArrayCell(adminMenuTree, _:adminMenuTree_StructureElement_ArrayParent), node);
}

stock adminMenuTree_SetParent(Handle:adminMenuTree, node, parentNode)
{
    SetArrayCell(GetArrayCell(adminMenuTree, _:adminMenuTree_StructureElement_ArrayParent), node, parentNode);
}

stock adminMenuTree_GetNodeKey(Handle:adminMenuTree, node, String:name[], maxlength)
{
    if (node == NULL_NODE)
        return 0;
    else
        return GetArrayString(GetArrayCell(adminMenuTree, _:adminMenuTree_StructureElement_ArrayNames), node, name, maxlength);
}

stock adminMenuTree_SetNodeKey(Handle:adminMenuTree, node, String:name[])
{
    SetArrayString(GetArrayCell(adminMenuTree, _:adminMenuTree_StructureElement_ArrayNames), node, name);
}

stock adminMenuTree_GetNodeValue(Handle:adminMenuTree, node)
{
    if (node == NULL_NODE)
        return -1;
    else
        return GetArrayCell(GetArrayCell(adminMenuTree, _:adminMenuTree_StructureElement_ArrayValues), node);
}

stock adminMenuTree_SetNodeValue(Handle:adminMenuTree, node, value)
{
    SetArrayCell(GetArrayCell(adminMenuTree, _:adminMenuTree_StructureElement_ArrayValues), node, value);
}

stock adminMenuTree_FindAfter(Handle:adminMenuTree, node, const String:name[], bool:caseSensitive=true)
{
    decl currentNodeLocal;
    decl String:foundName[MAX_STRING_SIZE];
    
    currentNodeLocal = node;
    foundName = NULL_STRING;
    
    while (currentNodeLocal != NULL_NODE && !StrEqual(name, foundName, caseSensitive))
    {
        currentNodeLocal = adminMenuTree_GetNextSibling(adminMenuTree, currentNodeLocal);
        adminMenuTree_GetNodeKey(adminMenuTree, currentNodeLocal, foundName, sizeof(foundName));
    }
    
    return currentNodeLocal;
}

stock adminMenuTree_FindChild(Handle:adminMenuTree, node, const String:name[], bool:caseSensitive=true)
{
    decl currentNodeLocal;
    decl String:foundName[MAX_STRING_SIZE];
    
    currentNodeLocal = node;
    
    currentNodeLocal = adminMenuTree_GetFirstChild(adminMenuTree, currentNodeLocal);
    adminMenuTree_GetNodeKey(adminMenuTree, currentNodeLocal, foundName, sizeof(foundName));
    
    if (currentNodeLocal != NULL_NODE && !StrEqual(name, foundName, caseSensitive))
        return adminMenuTree_FindAfter(adminMenuTree, currentNodeLocal, name, caseSensitive);
    else
        return currentNodeLocal;
}

stock adminMenuTree_FindValue(Handle:adminMenuTree, value)
{
    return FindValueInArray(GetArrayCell(adminMenuTree, _:adminMenuTree_StructureElement_ArrayValues), value);
}

stock adminMenuTree_GetNodeChildCount(Handle:adminMenuTree, node)
{
    decl currentNodeLocal;
    decl count;
    
    count = 0;
    
    currentNodeLocal = adminMenuTree_GetFirstChild(adminMenuTree, node);
    
    while(currentNodeLocal != NULL_NODE)
    {
        currentNodeLocal = adminMenuTree_GetNextSibling(adminMenuTree, currentNodeLocal);
        count++;
    }
    
    return count;
}

stock adminMenuTree_GetNodeChildItem(Handle:adminMenuTree, node, id)
{
    decl currentNodeLocal;
    decl count;
    
    count = 0;
    
    currentNodeLocal = adminMenuTree_GetFirstChild(adminMenuTree, node);
    
    while(currentNodeLocal != NULL_NODE && count != id)
    {
        currentNodeLocal = adminMenuTree_GetNextSibling(adminMenuTree, currentNodeLocal);
        count += 1;
    }
    
    return currentNodeLocal;
}