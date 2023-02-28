public APLRes AskPluginLoad2(Handle hMyself, bool bLate, char[] sError, int iErr_max)
{
	g_hForward_OnLotteryLoaded = CreateGlobalForward("Lot_OnCoreLoaded", ET_Ignore);
	g_hForward_OnClientWin = CreateGlobalForward("Lot_OnClientWin", ET_Ignore, Param_Cell);
	g_hForward_OnClientLose = CreateGlobalForward("Lot_OnClientLose", ET_Ignore, Param_Cell);
	g_hForward_OnLotteryStart = CreateGlobalForward("Lot_OnLotteryStart", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	g_hForward_OnLotteryEnd =  CreateGlobalForward("Lot_OnLotteryEnd", ET_Ignore, Param_Cell);
	
	CreateNative("Lot_IsCoreLoaded", Native_CoreLoaded);	
	CreateNative("Lot_RegMenuItem", Native_RegMenuItem); 
	CreateNative("Lot_UnRegMenuItem", Native_UnRegItem); 
	CreateNative("Lot_LotteryStart", Native_LotteryStart); 
	CreateNative("Lot_OpenMenu", Native_OpenMenu);
	
	RegPluginLibrary("lottery");
	return APLRes_Success;
}

public int Native_CoreLoaded(Handle hPlugin, int iNumParams)
{
	return g_bLoaded;
}

public int Native_LotteryStart(Handle hPlugin, int iNumParams)
{
	int iClient = GetNativeCell(1),
		iChance = GetNativeCell(2);
		
	if (iClient < 1 || iClient > MaxClients)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", iClient);
	}
	if (!IsClientConnected(iClient))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %d is not connected", iClient);
	}
	
	Lottery(iClient, iChance);
	return 1;
}

public int Native_RegMenuItem(Handle hPlugin, int iNumParams)
{ 
	char sName[16]; 
	if (GetNativeString(1, sName, sizeof(sName)) == SP_ERROR_NONE) 
	{
		int iMenuID = GetNativeCell(2);
		if (1 > iMenuID > 2) iMenuID = 1;
		if(FindStringInArray(iMenuID == 1 ? g_hMainMenuArray : g_hLuckMenuArray, sName) == -1)
		{			
			DataPack hPack = new DataPack();
			WritePackCell(hPack, hPlugin);
			WritePackFunction(hPack, GetNativeFunction(3));
			WritePackFunction(hPack, GetNativeFunction(4));
			
			PushArrayCell(iMenuID == 1 ? g_hMainMenuFunctions : g_hLuckMenuFunctions, hPack);
			PushArrayString(iMenuID == 1 ? g_hMainMenuArray : g_hLuckMenuArray, sName); 
			
			if(iMenuID > 1)
			{
				if(iMenuID == 2)
				{
					//g_bLuckMenu = false;
					CreateTimer(0.2, RebuildMenu_Timer, 1);
				}
			}
			
			CreateTimer(0.2, RebuildMenu_Timer, iMenuID);
			
			return 1; 
		}
	} 

	return -1; 
} 

public int Native_UnRegItem(Handle hPlugin, int iNumParams)
{ 
	char sItem[32];
	int iIndex, iMIndex = -1;
	GetNativeString(1, sItem, sizeof(sItem));
	
	if ((iIndex = FindStringInArray(g_hMainMenuArray, sItem)) != -1) iMIndex = 1;
	else if ((iIndex = FindStringInArray(g_hLuckMenuArray, sItem)) != -1) iMIndex = 2;
	
	if(iMIndex != -1) 
	{
		DataPack hPack = GetArrayCell(iMIndex == 1 ? g_hMainMenuFunctions : g_hLuckMenuFunctions, iIndex);
		delete hPack;
		
		RemoveFromArray(iMIndex == 1 ? g_hMainMenuFunctions : g_hLuckMenuFunctions, iIndex);
		RemoveFromArray(iMIndex == 1 ? g_hMainMenuArray : g_hLuckMenuArray, iIndex);

		if(iMIndex > 1)
		{
			if(iMIndex == 2 && GetMenuItemCount(g_hLuckMenu) == 1)
			{
				//g_bLuckMenu = false;
				CreateTimer(0.2, RebuildMenu_Timer, 1);
			}
		}
		
		CreateTimer(0.2, RebuildMenu_Timer, iMIndex);
	}
} 

public Action RebuildMenu_Timer(Handle hTimer, int iMenu)
{
	switch(iMenu)
	{
		case 1: RebuildMenu(g_hMainMenu, g_hMainMenuSortingArray, g_hMainMenuArray);
		case 2: RebuildMenu(g_hLuckMenu, g_hLuckMenuSortingArray, g_hLuckMenuArray);
	}
}

public int Native_OpenMenu(Handle hPlugin, int iNumParams)
{	
	CreateLotteryMenu(GetNativeCell(1), GetNativeCell(2));
}