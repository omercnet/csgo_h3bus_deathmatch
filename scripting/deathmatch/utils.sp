static g_iUtils_EffectDispatchTable;
static g_iUtils_DecalPrecacheTable;

stock utils_OnMapStart()
{
    g_iUtils_EffectDispatchTable       = FindStringTable("EffectDispatch");
    g_iUtils_DecalPrecacheTable        = FindStringTable("decalprecache");
}

stock Utils_GetEffectName(index, String:sEffectName[], maxlen)
{
    ReadStringTable(g_iUtils_EffectDispatchTable, index, sEffectName, maxlen);
}

stock Utils_GetDecalName(index, String:sDecalName[], maxlen)
{
    ReadStringTable(g_iUtils_DecalPrecacheTable, index, sDecalName, maxlen);
}

stock TrimChatTriggers(String:text[])
{
    if (
            text[0] == '!' ||
            text[0] == '/'
        )
    {
        new size = strlen(text);
        
        for (new index = 0; index < size; index++)
            text[index] = text[index+1];
    }
}

stock bool:RemoveChar(String:text[], removeChar)
{
    new srcIndex = 0;
    new dstIndex = 0;
    new bool:charFound = false;
    
    while(text[srcIndex] != '\0')
    {
        if(text[srcIndex] != removeChar)
        {
            text[dstIndex] = text[srcIndex];
            dstIndex++;
        }
        else
            charFound = true;
        
        srcIndex++;
    }
    
    text[dstIndex] = '\0';
    
    return charFound;
}

stock RemoveFromStringArray(String:array[][], arraySize, stringSize, item)
{
    if(item == arraySize-1)
        return;
    
    for(new i = item; i < arraySize-1; i++)
    {
        strcopy(String:array[i], stringSize, array[i+1]);
    }
}

stock deserializeStrings(String:serialString[], String:outputArray[][], maxStrings, maxStringSize, separator=' ')
{
    new index = 0;
    new strStart = 0;
    new strEnd = 0;
    
    while(
        index < maxStrings &&
        (strEnd = FindCharInString(serialString[strStart], separator)) != -1
        )
    {
        if(strEnd < maxStringSize && strEnd > 0)
        {
            strcopy(outputArray[index], strEnd + 1, serialString[strStart]);
            index++;
        }
        
        strStart = strStart + strEnd + 1;
    }
    
    if(index < maxStrings && serialString[strStart] != separator && serialString[strStart] != '\0' && strlen(serialString[strStart]) + 1 < maxStringSize)
    {
        strcopy(outputArray[index], strlen(serialString[strStart]) + 1, serialString[strStart]);
        index++;
    }
    
    return index;
}

stock bool:IsStringInList(const String:str[], const String:stringArray[][], stringCounts)
{
    for(new i=0; i < stringCounts; i++)
        if(StrEqual(str, stringArray[i], false))
            return true;
        
    return false;
}

stock bool:StrStartWith(const String:str1[], const String:str2[])
{
    new i = 0;
    
    while(str1[i] == str2[i] && str1[i] != '\0' && str2[i] != '\0')
        i++;
        
    if(str1[i] == '\0' || str2[i] == '\0')
        return true;
    else
        return false;
}

// Insert str1 before str2, into str2
stock StrInsert(const String:str1[], String:str2[], maxSize)
{
    new size1 = strlen(str1);
    new size2 = strlen(str2);
    
    // Copy offsets
    new offset = size1;
    
    // First string end index in destination
    // Not inclunding trailing \0
    new str1End = size1 - 1;
    
    // Secont string end index in destination
    // Inclunding trailing \0
    new str2End = size1 + size2;
    
    // If str2 cannot be fit into destination string, trim it
    new str2SrcEnd = (str2End < maxSize - 1)? size2 : (maxSize - 1) - offset;
    
    // Trim over size
    str1End = (str1End > maxSize - 1)? (maxSize - 1) : str1End;
    str2End = (str2End > maxSize - 1)? (maxSize - 1) : str2End;
    
    // Shift destination (backward to keep data, and including trailing \0)
    for (new index = str2SrcEnd; index >= 0; index --)
        str2[index + offset] = str2[index];
    
    // Copy str1 at the begining (without trailing \0)
    for (new index = 0; index <= str1End; index ++)
        str2[index] = str1[index];
    
    // Close the string everytime, but only usefull truncation occured
    str2[maxSize-1] = '\0';
}

static html_chars[] = { '<', '>', '"', '&' };
static String:html_escape[][] = { "&lt;", "&gt;", "&quot;", "&amp;" };

stock StrEscapeHTML(String:dst[], destSize, String:src[])
{
    new srcIndex = 0;
    new dstIndex = 0;
    new bool:escaped;
    
    while(src[srcIndex] != '\0' && dstIndex < destSize-1)
    {
        escaped = false;
        for (new charIndex = 0; charIndex < sizeof(html_chars) && !escaped; charIndex++)
        {
            if(src[srcIndex] == html_chars[charIndex])
            {
                escaped = true;
                
                dstIndex += strcopy(dst[dstIndex], destSize-dstIndex, html_escape[charIndex]);
            }
        }
        
        if(!escaped)
        {
            dst[dstIndex] = src[srcIndex];
            dstIndex++;
        }
        
        srcIndex++;
    }
    
    dst[dstIndex] = '\0';
}

stock FormatGameTime(String:dst[], destSize, Float:time)
{
    new Float:iTime = time;
    new hours = RoundToFloor(iTime/3600.0);
    iTime -= hours * 3600.0;
    new minutes = RoundToFloor(iTime/60.0);
    iTime -= minutes * 60.0;
    new seconds = RoundFloat(iTime);
    
    if(hours != 0)
        Format(dst, destSize, "%dh%dm%ds", hours, minutes, seconds);
    else if(minutes != 0)
        Format(dst, destSize, "%dm%ds", minutes, seconds);
    else
        Format(dst, destSize, "%ds", seconds);
}