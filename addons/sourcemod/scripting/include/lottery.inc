#if defined _lottery_included
    #endinput
#endif
#define _lottery_included

#define LOT_MAIN_MENU 1
#define LOT_LUCK_MENU 2

/**
 *
 * Начало лотереи
 *	-
 * @param iClient 			Индекс игрока
 * @param iChance 			Шанс выиграша
 * @param iRandom 			Рандомное число (для шанса)
 *
 */
forward void Lot_OnLotteryStart(int iClient, int iChance, int iRandom)

/**
 *
 * Конец лотереи
 *	-
 * @param iClient 			Индекс игрока
 *
 */
forward void Lot_OnLotteryEnd(int iClient)

/**
 *
 * Игрок выиграл в лотерее
 *	-
 * @param iClient 			Индекс игрока
 *
 */
forward void Lot_OnClientWin(int iClient)

/**
 *
 * Игрок проиграл в лотерее
 *	-
 * @param iClient 			Индекс игрока
 *
 */
forward void Lot_OnClientLose(int iClient)

/**
 *
 * Вызывается, когда ядро загрузилось
 *	-
 *
 */
forward void Lot_OnCoreLoaded();

/**
 *
 * Проверка на готовность ядра к работе.
 *	-
 *
 */
native int Lot_IsCoreLoaded();

/**
 *
 * Открывает главное меню
 *	-
 * @param iClient 			Индекс игрока
 *
 */
native int Lot_OpenMenu(int iClient, int iMenu = LOT_MAIN_MENU);

/**
 *
 * Запустить лотерею
 *	-
 * @param iClient 			Индекс игрока
 * @param iChance 			Шанс
 *
 */
native int Lot_LotteryStart(int iClient, int iChance);

/**
 * 
 * Вызывается когда игрок нажимает на пункт в меню.
 * -
 * @param iClient 			Индекс игрока
 * @param sItem				Уникальное название пункта
 *
 */
typedef OnItemPressed = function void(int iClient, const char[] sItem);

/**
 * 
 * Вызывается когда игроку отображается пункт в меню.
 * -
 * @param iClient 			Индекс игрока
 * @param sItem				Уникальное название пункта
 * @param sBuff				Буфер
 * @param maxsize			Размер буфера
 *
 */
typedef OnItemDisplay = function void(int iClient, const char[] sItem, char[] sBuffer, int iMaxSize);

/**
 *
 * Регистрирует новый пункт в главном меню.
 * -
 * @param sName 					Уникальное название пункта
 * @param MenuCallback 				Обратный вызов при нажатии на пункт
 *
 */
native int Lot_RegMenuItem(const char[] sName, int iMenu = LOT_MAIN_MENU, OnItemPressed OnItemPressedCallback, OnItemDisplay OnItemDisplayCallback = INVALID_FUNCTION); 

/**
 *
 * Удаляет пункт из меню.
 * -
 * @param sName 			Уникальное название пункта
 *
 */
native int Lot_UnRegMenuItem(const char[] sName);