/****
 *
 * 1.1 - admin menu
 * 1.1.1 - оптимизация
 * 1.2 - оптимизация, мультиязычность и поддержка shop cor
 * 1.2.1 - оптимизация доработана мультиязычность
 * 1.3 - инфа и поддержка вип
 * 1.6 - Ядро и модули
 * 2.0 - Все переписано
 * 
 *****/
	
bool g_bLoaded, g_bLuckMenu;
ConVar g_hCvarCmd;
Handle g_hForward_OnClientWin, g_hForward_OnClientLose, g_hForward_OnLotteryLoaded, g_hForward_OnLotteryStart, g_hForward_OnLotteryEnd;
Menu g_hMainMenu, g_hLuckMenu; 

ArrayList g_hMainMenuArray, g_hMainMenuSortingArray, g_hMainMenuFunctions, 
		  g_hLuckMenuSortingArray, g_hLuckMenuFunctions, g_hLuckMenuArray;

#include "lottery/menu.sp"
#include "lottery/api.sp"

public Plugin myinfo = 
{
	name = "[Lottery] Core",
	author = "DeeperSpy",
	version = "2.0.2"
};

public void OnPluginStart()
{ 
	g_hMainMenuArray = new ArrayList(ByteCountToCells(64));
	g_hMainMenuSortingArray	= new ArrayList(ByteCountToCells(64));
	g_hMainMenuFunctions = new ArrayList(ByteCountToCells(4));

	g_hLuckMenuArray = new ArrayList(ByteCountToCells(64));
	g_hLuckMenuSortingArray = new ArrayList(ByteCountToCells(64));
	g_hLuckMenuFunctions = new ArrayList(ByteCountToCells(4));
	
	LoadTranslations("lottery_core.phrases");
	LoadTranslations("lottery_modules.phrases");
	
	g_hCvarCmd = CreateConVar("lot_cmd", "lot;lottery", "Команда для вызова меню (Разделять через ;)");
	AutoExecConfig(true, "Lottery");
	
	char sPath[256];
	BuildPath(Path_SM, sPath, sizeof(sPath), "configs/lot/lot_main_sorting.ini"); 
	MenuSorting(g_hMainMenuSortingArray, sPath);
	
	BuildPath(Path_SM, sPath, sizeof(sPath), "configs/lot/lot_luck_sorting.ini"); 
	MenuSorting(g_hLuckMenuSortingArray, sPath);
	
	g_hMainMenu	= new Menu(LotteryMenu_Callback, MenuAction_Select|MenuAction_DisplayItem|MenuAction_Cancel);
	g_hLuckMenu = new Menu(LotteryMenu_Callback, MenuAction_Select|MenuAction_DisplayItem|MenuAction_Cancel);  
	SetMenuExitBackButton(g_hLuckMenu, true);
}

public void OnConfigsExecuted()
{
	static bool bIsRegistered;
	if (!bIsRegistered)
	{
		UTILoadCmd(g_hCvarCmd, Command_Lottery);
		bIsRegistered = true;
	}
}

public void OnAllPluginsLoaded()
{
	Call_StartForward(g_hForward_OnLotteryLoaded);
	Call_Finish();
	
	g_bLoaded = true;
}

public void MenuSorting(Handle hArray, const char[] sPatch)
{
	char sBuffer[32];
	Handle hFile = OpenFile(sPatch, "r");
	if (hFile != INVALID_HANDLE)
	{
		while (!IsEndOfFile(hFile) && ReadFileLine(hFile, sBuffer, PLATFORM_MAX_PATH))
		{
			TrimString(sBuffer);
			if(IsCharAlpha(sBuffer[0]))
				PushArrayString(hArray, sBuffer);
		}	
		CloseHandle(hFile);
	}
}

public Action Command_Lottery(int iClient, int iArgs)
{
	if(iClient)
		CreateLotteryMenu(iClient, 1); 
		
	return Plugin_Handled;
}

void UTILoadCmd(ConVar &hCvar, ConCmd CallCMD)
{
	char szPart[64], sBuffer[128];
	int iRelocIdx, iPos;
	hCvar.GetString(sBuffer, sizeof(sBuffer));

	while ((iPos = SplitString(sBuffer[iRelocIdx], ";", szPart, sizeof(szPart))))
	{
		if (iPos == -1)
		{
			strcopy(szPart, sizeof(szPart), sBuffer[iRelocIdx]);
		}
		else
		{
			iRelocIdx += iPos;
		}
		
		TrimString(szPart);
		
		if (szPart[0])
		{
			RegConsoleCmd(szPart, CallCMD);
			
			if (iPos == -1)
				return;
		}
	}
}

void Lottery(int iClient, int iChance)
{
	int iRandom = GetRandomInt(1, 100);
	Call_StartForward(g_hForward_OnLotteryStart);
	Call_PushCell(iClient);
	Call_PushCell(iChance);
	Call_PushCell(iRandom);
	Call_Finish();
	
	if(iRandom <= iChance)
	{
		Call_StartForward(g_hForward_OnClientWin);
		Call_PushCell(iClient);
		Call_Finish();
	}
	else
	{
		Call_StartForward(g_hForward_OnClientLose);
		Call_PushCell(iClient);
		Call_Finish();
	}
	
	Call_StartForward(g_hForward_OnLotteryEnd);
	Call_PushCell(iClient);
	Call_Finish();
}