stock void RebuildMenu(Menu hMenu, ArrayList hSortingArray, ArrayList hMenuArray)
{
	char sName[16];
	bool bLuckMenu = false;
	
	RemoveAllMenuItems(hMenu);
	
	for(int i = 0; i < GetArraySize(hSortingArray); ++i)
	{
		GetArrayString(hSortingArray, i, sName, sizeof(sName));

		if(FindStringInArray(hMenuArray, sName) != -1) 
		{
			hMenu.AddItem(sName, " "); 			
		}
	}
	
	for(int i = 0; i < GetArraySize(hMenuArray); ++i)
	{
		if(hMenu == g_hMainMenu)
		{
			if(!bLuckMenu) 
			{ 
				AddMenuItem(hMenu, "luck_menu", " "); 
				bLuckMenu = true; 
				g_bLuckMenu = true;
			}
		}

		GetArrayString(hMenuArray, i, sName, sizeof(sName));
		
		if(FindStringInArray(hSortingArray, sName) == -1)
			hMenu.AddItem(sName, " ");
	}
}

public int LotteryMenu_Callback(Menu hMenu, MenuAction action, int iClient, int iParam)
{
	switch (action) 
	{  
		case MenuAction_Select: 
		{ 
			char sName[16];
			GetMenuItem(hMenu, iParam, sName, sizeof(sName)); 
			int iMenuID = -1;
			
			if (StrEqual(sName, "luck_menu")) { CreateLotteryMenu(iClient, 2); return; }
			if(view_as<int>(hMenu) == view_as<int>(g_hMainMenu)) iMenuID = 1;
			else if (view_as<int>(hMenu) == view_as<int>(g_hLuckMenu)) iMenuID = 2;
			
			if(iMenuID != -1)
			{
				int iIndex = FindStringInArray(iMenuID == 1 ? g_hMainMenuArray : g_hLuckMenuArray, sName);
				DataPack hPack = GetArrayCell(iMenuID == 1 ? g_hMainMenuFunctions : g_hLuckMenuFunctions, iIndex);
				ResetPack(hPack);
				Handle hPlugin = ReadPackCell(hPack);
				Function hFunc = ReadPackFunction(hPack);
			
				Call_StartFunction(hPlugin, hFunc);
				Call_PushCell(iClient);
				Call_PushString(sName);
				Call_Finish();
			}
		}  
		case MenuAction_DisplayItem:
		{
			char sName[16], sDisplay[256];
			int iMenuID = -1;
			GetMenuItem(hMenu, iParam, sName, sizeof(sName));  

			bool bLuckMenu = StrEqual(sName, "luck_menu");
			if(!bLuckMenu)
			{
				Handle hPlugin;
				Function hFunc;
				
				if(view_as<int>(hMenu) == view_as<int>(g_hMainMenu)) iMenuID = 1;
				else if (view_as<int>(hMenu) == view_as<int>(g_hLuckMenu)) iMenuID = 2;
				
				if(iMenuID != -1)
				{
					int index = FindStringInArray(iMenuID == 1 ? g_hMainMenuArray : g_hLuckMenuArray, sName);
					DataPack hPack = GetArrayCell(iMenuID == 1 ? g_hMainMenuFunctions : g_hLuckMenuFunctions, index);
					ResetPack(hPack);
					hPlugin = ReadPackCell(hPack);
					ReadPackFunction(hPack);
					hFunc = ReadPackFunction(hPack);
				}
				
				if(hFunc != INVALID_FUNCTION)
				{
					Call_StartFunction(hPlugin, hFunc);
					Call_PushCell(iClient);
					Call_PushString(sName);
					Call_PushStringEx(sDisplay, sizeof(sDisplay), SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
					Call_PushCell(sizeof(sDisplay));
					Call_Finish();
				}
				else
				{
					FormatEx(sDisplay, sizeof(sDisplay), "%T", sName, iClient);
					RedrawMenuItem(sDisplay);
				}
			}
			else if(bLuckMenu)
			{
				FormatEx(sDisplay, sizeof(sDisplay), "%T", "LuckTitle", iClient);
				RedrawMenuItem(sDisplay);
			}
		}
		case MenuAction_Cancel:
		{
			if (iParam == MenuCancel_ExitBack)
				CreateLotteryMenu(iClient, 1);
		}
	}
} 

public void CreateLotteryMenu(int iClient, int iMenu)
{
	if (iClient > 0) 
	{ 		
		switch(iMenu)		
		{
			case 1:
			{
				g_hMainMenu.SetTitle("%T\n \n", "MenuTitle", iClient);
				if(!g_bLuckMenu) 
				{
					g_hMainMenu.AddItem("luck_menu", " ");
					g_bLuckMenu = true; 
				}
				g_hMainMenu.Display(iClient, MENU_TIME_FOREVER); 
			}
			case 2:
			{
				g_hLuckMenu.SetTitle("%T\n \n", "LuckTitle", iClient);
				g_hLuckMenu.Display(iClient, MENU_TIME_FOREVER); 	
			}
		}
	}
}