
#define HANDLE_SIZE 1
#define MAX_CONVARNAME_SIZE 40
#define MAX_CONVARVALUE_SIZE 255

enum cvarStack_StructureElements {
    cvarStack_StructureElement_ArrayNames,
    cvarStack_StructureElement_ArrayValues,
    cvarStack_StructureElement_COUNT
}

static cvarStack_StructureElementsSize[_:cvarStack_StructureElement_COUNT] =
{
    MAX_CONVARNAME_SIZE,    // cvarStack_StructureElement_ArrayNames
    MAX_CONVARVALUE_SIZE,   // cvarStack_StructureElement_ArrayValues
};

stock Handle:cvarStack_Create()
{
    new Handle:stack = CreateArray(1, _:cvarStack_StructureElement_COUNT);
    
    for (new index = 0; index < _:cvarStack_StructureElement_COUNT; index++)
    {
        SetArrayCell(stack, index, CreateArray(cvarStack_StructureElementsSize[index]));
    }
    
    return stack;
}

stock cvarStack_Destroy(Handle:stack)
{
    for (new index = 0; index < _:cvarStack_StructureElement_COUNT; index++)
    {
        ClearArray( GetArrayCell(stack, index));
        CloseHandle(GetArrayCell(stack, index));
    }
    
    ClearArray(stack);
    CloseHandle(stack);
}

stock cvarStack_Clear(Handle:stack)
{
    for (new index = 0; index < _:cvarStack_StructureElement_COUNT; index++)
    {
        ClearArray( GetArrayCell(stack, index));
    }
}

stock cvarStack_Copy(Handle:fromStack, &Handle:toStack)
{
    cvarStack_Destroy(toStack);
    toStack = CloneArray(fromStack);
    
    for (new index = 0; index < _:cvarStack_StructureElement_COUNT; index++)
    {
        SetArrayCell(toStack, index, CloneArray(GetArrayCell(fromStack, _:index)));
    }
}

stock cvarStack_IsEmpty(Handle:stack)
{
    return (GetArraySize(GetArrayCell(stack, _:cvarStack_StructureElement_ArrayNames)) == 0);
}

stock bool:cvarStack_Exist(Handle:stack, const String:cvarName[])
{
    return FindStringInArray(GetArrayCell(stack, _:cvarStack_StructureElement_ArrayNames), cvarName) != -1;
}

stock cvarStack_RemoveIfPresent(Handle:stack, const String:cvarName[])
{
    decl index;

    if ( (index = FindStringInArray(GetArrayCell(stack, _:cvarStack_StructureElement_ArrayNames), cvarName)) != -1)
    {
        RemoveFromArray(GetArrayCell(stack, _:cvarStack_StructureElement_ArrayNames), index);
        RemoveFromArray(GetArrayCell(stack, _:cvarStack_StructureElement_ArrayValues), index);
    }
}

stock cvarStack_PushIfNotPresent(Handle:stack, const String:cvarName[], const String:cvarValue[])
{
    if (FindStringInArray(GetArrayCell(stack, _:cvarStack_StructureElement_ArrayNames), cvarName) == -1)
    {
        PushArrayString(GetArrayCell(stack, _:cvarStack_StructureElement_ArrayNames), cvarName);
        PushArrayString(GetArrayCell(stack, _:cvarStack_StructureElement_ArrayValues), cvarValue);
    }
}

stock cvarStack_PushOrUpdate(Handle:stack, const String:cvarName[], const String:cvarValue[])
{
    decl index;

    if ( (index = FindStringInArray(GetArrayCell(stack, _:cvarStack_StructureElement_ArrayNames), cvarName)) == -1)
    {
        PushArrayString(GetArrayCell(stack, _:cvarStack_StructureElement_ArrayNames), cvarName);
        PushArrayString(GetArrayCell(stack, _:cvarStack_StructureElement_ArrayValues), cvarValue);
    }
    else{
        SetArrayString(GetArrayCell(stack, _:cvarStack_StructureElement_ArrayNames), index, cvarName);
        SetArrayString(GetArrayCell(stack, _:cvarStack_StructureElement_ArrayValues), index, cvarValue);
    }
}

stock bool:cvarStack_Pop(Handle:stack, String:cvarName[], nameLength, String:cvarValue[], valueLength)
{
    new lastElement = GetArraySize(GetArrayCell(stack, _:cvarStack_StructureElement_ArrayNames)) - 1;
    
    if (lastElement != -1)
    {
        GetArrayString(GetArrayCell(stack, _:cvarStack_StructureElement_ArrayNames), lastElement, cvarName, nameLength);
        GetArrayString(GetArrayCell(stack, _:cvarStack_StructureElement_ArrayValues), lastElement, cvarValue, valueLength);
        RemoveFromArray(GetArrayCell(stack, _:cvarStack_StructureElement_ArrayNames), lastElement);
        RemoveFromArray(GetArrayCell(stack, _:cvarStack_StructureElement_ArrayValues), lastElement);
        
        return true;
    }
    else
        return false;
}