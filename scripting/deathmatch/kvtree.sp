
#define KVTREE_ROOT_INDEX 0

#define HANDLE_SIZE 1
#define INT_SIZE 1
#define MAX_STRING_SIZE 1024

#define NULL_NODE -1

enum kvTree_StructureElements {
    kvTree_StructureElement_ArrayParent,
    kvTree_StructureElement_ArrayFirstChild,
    kvTree_StructureElement_ArrayPreviousSibling,
    kvTree_StructureElement_ArrayNextSibling,
    kvTree_StructureElement_ArrayKeys,
    kvTree_StructureElement_ArrayValues,
    kvTree_StructureElement_ArraynodeIterator,
    kvTree_StructureElement_COUNT
}

static kvTree_StructureElementsSize[_:kvTree_StructureElement_COUNT] =
{
    INT_SIZE,          // kvTree_StructureElement_ArrayParent
    INT_SIZE,          // kvTree_StructureElement_ArrayFirstChild
    INT_SIZE,          // kvTree_StructureElement_ArrayPreviousSibling
    INT_SIZE,          // kvTree_StructureElement_ArrayNextSibling
    MAX_STRING_SIZE,   // kvTree_StructureElement_ArrayKeys
    MAX_STRING_SIZE,   // kvTree_StructureElement_ArrayValues
    INT_SIZE           // kvTree_StructureElement_ArraynodeIterator
};

stock Handle:kvTree_Create(maxKeySize, maxValSize, const String:rootKey[], const String:rootValue[])
{
    new Handle:kvTree = CreateArray(HANDLE_SIZE, _:kvTree_StructureElement_COUNT);
    
    kvTree_StructureElementsSize[_:kvTree_StructureElement_ArrayKeys]   = ByteCountToCells(maxKeySize);
    kvTree_StructureElementsSize[_:kvTree_StructureElement_ArrayValues] = ByteCountToCells(maxValSize);
    
    for (new index = 0; index < _:kvTree_StructureElement_COUNT; index++)
    {
        if (index != _:kvTree_StructureElement_ArraynodeIterator)
        {
            SetArrayCell(kvTree, index, CreateArray(kvTree_StructureElementsSize[index]));
        }
    }
        
    kvTree_AddNode(kvTree, NULL_NODE, NULL_NODE, rootKey, rootValue);
    
    SetArrayCell(kvTree, _:kvTree_StructureElement_ArraynodeIterator, KVTREE_ROOT_INDEX);
    
    return kvTree;
}

stock kvTree_Destroy(Handle:kvTree)
{   
    if (kvTree != INVALID_HANDLE)
    {
        for (new index = 0; index < _:kvTree_StructureElement_COUNT; index++)
        {
            if (index != _:kvTree_StructureElement_ArraynodeIterator)
            {
                ClearArray( GetArrayCell(kvTree, index));
                CloseHandle(GetArrayCell(kvTree, index));
            }
        }
        
        ClearArray(kvTree);
        CloseHandle(kvTree);
    }
}

stock kvTree_AddNode(Handle:kvTree, parentNode, previousNode, const String:key[], const String:value[])
{
    decl nodeIndex;
    decl realParent;
    new nextNode = NULL_NODE;
    
    if (previousNode != NULL_NODE)
        realParent = kvTree_GetParent(kvTree, previousNode);
    else
        realParent = parentNode;
    
    if (previousNode != NULL_NODE)
        nextNode = kvTree_GetNextSibling(kvTree, previousNode);
    else if (realParent != NULL_NODE)
        nextNode = kvTree_GetFirstChild(kvTree, realParent);
    
    nodeIndex = PushArrayCell(GetArrayCell(kvTree, _:kvTree_StructureElement_ArrayParent),  realParent);
    PushArrayCell(  GetArrayCell(kvTree, _:kvTree_StructureElement_ArrayFirstChild),        NULL_NODE);
    PushArrayCell(  GetArrayCell(kvTree, _:kvTree_StructureElement_ArrayPreviousSibling),   previousNode);
    PushArrayCell(  GetArrayCell(kvTree, _:kvTree_StructureElement_ArrayNextSibling),       nextNode);
    PushArrayString(GetArrayCell(kvTree, _:kvTree_StructureElement_ArrayKeys),              key);
    PushArrayString(GetArrayCell(kvTree, _:kvTree_StructureElement_ArrayValues),            value);
    
    if (previousNode != NULL_NODE)
        kvTree_SetNextSibling(kvTree, previousNode, nodeIndex);
    else if (realParent != NULL_NODE)
        kvTree_SetFirstChild(kvTree, realParent, nodeIndex);
    
    if (nextNode != NULL_NODE)
        kvTree_SetPreviousSibling(kvTree, nextNode, nodeIndex);
    
    return nodeIndex;
}

stock kvTree_RemoveNode(Handle:kvTree, node, bool:updateLinks=true)
{
    new retNode = NULL_NODE;
    new child = kvTree_GetFirstChild(kvTree, node);
    new nextChild;
    
    if(updateLinks)
    {
        new previousNode = kvTree_GetPreviousSibling(kvTree, node);
        new nextNode = kvTree_GetNextSibling(kvTree, node);
        new parentNode = kvTree_GetParent(kvTree, node);
        
        if (parentNode != NULL_NODE)
            kvTree_SetNextSibling(kvTree, previousNode, nextNode);
        else if (parentNode != NULL_NODE)
            kvTree_SetFirstChild(kvTree, parentNode, nextNode);
        
        if (nextNode != NULL_NODE)
            kvTree_SetPreviousSibling(kvTree, nextNode, previousNode);
        
        retNode = nextNode != NULL_NODE? nextNode : parentNode;
    }
    
    while(child != NULL_NODE)
    {
        nextChild = kvTree_GetNextSibling(kvTree, child);
        kvTree_RemoveNode(kvTree, child, .updateLinks=false);
        child = nextChild;
    }
    
    for (new index = 0; index < _:kvTree_StructureElement_COUNT; index++)
        if (index != _:kvTree_StructureElement_ArraynodeIterator)
            RemoveFromArray( GetArrayCell(kvTree, index), node);
    
    return retNode;
}

stock kvTree_SetFirstChild(Handle:kvTree, node, firstChild)
{
    SetArrayCell(GetArrayCell(kvTree, _:kvTree_StructureElement_ArrayFirstChild), node, firstChild);
}

stock kvTree_GetFirstChild(Handle:kvTree, node)
{
    if (node == NULL_NODE)
        return NULL_NODE;
    else
        return GetArrayCell(GetArrayCell(kvTree, _:kvTree_StructureElement_ArrayFirstChild), node);
}

stock kvTree_GetPreviousSibling(Handle:kvTree, node)
{
    if (node == NULL_NODE)
        return NULL_NODE;
    else
        return GetArrayCell(GetArrayCell(kvTree, _:kvTree_StructureElement_ArrayPreviousSibling), node);
}

stock kvTree_SetPreviousSibling(Handle:kvTree, node, previousSibling)
{
    SetArrayCell(GetArrayCell(kvTree, _:kvTree_StructureElement_ArrayPreviousSibling), node, previousSibling);
}

stock kvTree_GetNextSibling(Handle:kvTree, node)
{
    if (node == NULL_NODE)
        return NULL_NODE;
    else
        return GetArrayCell(GetArrayCell(kvTree, _:kvTree_StructureElement_ArrayNextSibling), node);
}

stock kvTree_SetNextSibling(Handle:kvTree, node, nextSibling)
{
    SetArrayCell(GetArrayCell(kvTree, _:kvTree_StructureElement_ArrayNextSibling), node, nextSibling);
}

stock kvTree_GetParent(Handle:kvTree, node)
{
    if (node == NULL_NODE)
        return NULL_NODE;
    else
        return GetArrayCell(GetArrayCell(kvTree, _:kvTree_StructureElement_ArrayParent), node);
}

stock kvTree_SetParent(Handle:kvTree, node, parentNode)
{
    SetArrayCell(GetArrayCell(kvTree, _:kvTree_StructureElement_ArrayParent), node, parentNode);
}

stock kvTree_GetNodeKey(Handle:kvTree, node, String:key[], maxlength)
{
    if (node == NULL_NODE)
        return 0;
    else
        return GetArrayString(GetArrayCell(kvTree, _:kvTree_StructureElement_ArrayKeys), node, key, maxlength);
}

stock kvTree_SetNodeKey(Handle:kvTree, node, String:key[])
{
    SetArrayString(GetArrayCell(kvTree, _:kvTree_StructureElement_ArrayKeys), node, key);
}

stock kvTree_GetNodeValue(Handle:kvTree, node, String:value[], maxlength, const String:defvalue[]="")
{
    if (node == NULL_NODE)
    {
        strcopy(value, maxlength,defvalue);
        return strlen(value)+1;
    }
    else
        return GetArrayString(GetArrayCell(kvTree, _:kvTree_StructureElement_ArrayValues), node, value, maxlength);
}

stock kvTree_SetNodeValue(Handle:kvTree, node, String:key[])
{
    SetArrayString(GetArrayCell(kvTree, _:kvTree_StructureElement_ArrayValues), node, key);
}

stock kvTree_FindAfter(Handle:kvTree, node, const String:key[], bool:caseSensitive=true)
{
    decl currentNodeLocal;
    decl String:foundKey[MAX_STRING_SIZE];
    
    currentNodeLocal = node;
    foundKey = NULL_STRING;
    
    while (currentNodeLocal != NULL_NODE && !StrEqual(key, foundKey, caseSensitive))
    {
        currentNodeLocal = kvTree_GetNextSibling(kvTree, currentNodeLocal);
        kvTree_GetNodeKey(kvTree, currentNodeLocal, foundKey, sizeof(foundKey));
    }
    
    return currentNodeLocal;
}

stock kvTree_FindChild(Handle:kvTree, node, const String:key[], bool:caseSensitive=true)
{
    decl currentNodeLocal;
    decl String:foundKey[MAX_STRING_SIZE];
    
    currentNodeLocal = node;
    
    currentNodeLocal = kvTree_GetFirstChild(kvTree, currentNodeLocal);
    kvTree_GetNodeKey(kvTree, currentNodeLocal, foundKey, sizeof(foundKey));
    
    if (currentNodeLocal != NULL_NODE && !StrEqual(key, foundKey, caseSensitive))
        return kvTree_FindAfter(kvTree, currentNodeLocal, key, caseSensitive);
    else
        return currentNodeLocal;
}

stock kvTree_GetNodeChildCount(Handle:kvTree, node)
{
    decl currentNodeLocal;
    decl count;
    
    count = 0;
    
    currentNodeLocal = kvTree_GetFirstChild(kvTree, node);
    
    while(currentNodeLocal != NULL_NODE)
    {
        currentNodeLocal = kvTree_GetNextSibling(kvTree, currentNodeLocal);
        count++;
    }
    
    return count;
}

stock kvTree_GetNodeChildItem(Handle:kvTree, node, id)
{
    decl currentNodeLocal;
    decl count;
    
    count = 0;
    
    currentNodeLocal = kvTree_GetFirstChild(kvTree, node);
    
    while(currentNodeLocal != NULL_NODE && count != id)
    {
        currentNodeLocal = kvTree_GetNextSibling(kvTree, currentNodeLocal);
        count += 1;
    }
    
    return currentNodeLocal;
}


/*********************************************************************
*
*  Iterator functions
*
**********************************************************************/
stock bool:kvTree_GotoFirstSubKey(Handle:kvTree, bool:create=false)
{
    decl iterator;
    
    kvTree_GetSectionSymbol(kvTree, iterator);
    iterator = kvTree_GetFirstChild(kvTree, iterator);
    
    return kvTree_JumpToKeySymbol(kvTree, iterator);
}

stock bool:kvTree_GotoNextKey(Handle:kvTree, bool:create=false)
{
    decl iterator;
    
    kvTree_GetSectionSymbol(kvTree, iterator);
    iterator = kvTree_GetNextSibling(kvTree, iterator);
    
    return kvTree_JumpToKeySymbol(kvTree, iterator);
}

stock bool:kvTree_GoBack(Handle:kvTree)
{
    decl iterator;
    
    kvTree_GetSectionSymbol(kvTree, iterator);
    iterator = kvTree_GetParent(kvTree, iterator);
    
    return kvTree_JumpToKeySymbol(kvTree, iterator);
}

stock kvTree_Rewind(Handle:kvTree)
{
    kvTree_JumpToKeySymbol(kvTree, KVTREE_ROOT_INDEX);
}

stock kvTree_GetSectionName(Handle:kvTree, String:key[], maxlength)
{
    decl iterator;
    
    kvTree_GetSectionSymbol(kvTree, iterator);
    return kvTree_GetNodeKey(kvTree, iterator, key, maxlength);
}

stock bool:kvTree_GotoSectionChildItem(Handle:kvTree, id)
{
    decl iterator;
    
    kvTree_GetSectionSymbol(kvTree, iterator);
    iterator = kvTree_GetNodeChildItem(kvTree, iterator, id);
    
    return kvTree_JumpToKeySymbol(kvTree, iterator);
}

stock kvTree_GetSectionChildCount(Handle:kvTree)
{
    decl iterator;
    
    kvTree_GetSectionSymbol(kvTree, iterator);
    return kvTree_GetNodeChildCount(kvTree, iterator);
}

stock kvTree_GetValue(Handle:kvTree, String:value[], maxlength, const String:defvalue[]="")
{
    decl iterator;
    
    kvTree_GetSectionSymbol(kvTree, iterator);
    return kvTree_GetNodeValue(kvTree, iterator, value, maxlength, defvalue);
}

stock kvTree_GetString(Handle:kvTree, const String:key[], String:value[], maxlength, const String:defvalue[]="")
{
    decl iterator;
    
    kvTree_GetSectionSymbol(kvTree, iterator);
    iterator = kvTree_GetParent(kvTree, iterator);
    iterator = kvTree_FindChild(kvTree, iterator, key);    
    
    return kvTree_GetNodeValue(kvTree, iterator, value, maxlength, defvalue);
}

stock bool:kvTree_JumpToKey(Handle:kvTree, const String:key[])
{
    decl iterator;
    
    kvTree_GetSectionSymbol(kvTree, iterator);
    iterator = kvTree_GetParent(kvTree, iterator);
    iterator = kvTree_FindChild(kvTree, iterator, key);
    
    return kvTree_JumpToKeySymbol(kvTree, iterator);
}

stock bool:kvTree_JumpToKeySymbol(Handle:kvTree, id)
{
    if (id >= 0 && id < GetArraySize(GetArrayCell(kvTree, _:kvTree_StructureElement_ArrayParent)))
    {
        SetArrayCell(kvTree, _:kvTree_StructureElement_ArraynodeIterator, id);
        return true;
    }
    else
        return false;
}

stock bool:kvTree_GetSectionSymbol(Handle:kvTree, &id)
{
    id = GetArrayCell(kvTree, _:kvTree_StructureElement_ArraynodeIterator);
    
    return true;
}
