//==============================================================================
//                              Includes
//==============================================================================
#include <a_samp> // 
#include <streamer> //
#include <dini> //
#include <dudb> //
#include <sscanf2> //
#pragma unused strtok //
#pragma dynamic 5000 //
//==============================================================================
//                              Macros
//==============================================================================
//##############################################################################
#undef MAX_PLAYERS
#define MAX_PLAYERS 101 //максимум игроков на сервере + 1 (если 50 игроков, то пишем 51 !!!)

#if (MAX_PLAYERS > 501)
	#undef MAX_PLAYERS
	#define MAX_PLAYERS 501
#endif

//#define MAX_PLAYERS 30 // Замените ее на количество слотов сервера!!
//#define HOUSEMENU 500 // ид диолога
//##############################################################################
#define dcmd(%1,%2,%3) if (!strcmp((%3)[1], #%1, true, (%2)) && ((((%3)[(%2) + 1] == '\0') && (dcmd_%1(playerid, ""))) || (((%3)[(%2) + 1] == ' ') && (dcmd_%1(playerid, (%3)[(%2) + 2]))))) return 1
new FALSE = false, CMDSString[1000];
#define ShowInfoBox(%0,%1,%2,%3) do{format(CMDSString, 1000, %2, %3); ShowPlayerDialog(%0, 520, DIALOG_STYLE_MSGBOX, %1, CMDSString, "Close", "Cancel");}while(FALSE)
#define SendMSG(%0,%1,%2,%3,%4) do{new _str[%2]; format(_str,%2,%3,%4); SendClientMessage(%0,%1,_str);}while(FALSE)
#define Loop(%0,%1) for(new %0 = 0; %0 < %1; %0++)
#define TYPE_OUT (0)
#define TYPE_INT (1)
//==============================================================================
//                              Colours
//==============================================================================
#define COLOUR_INFO 0x00FFFFFF
#define COLOUR_SYSTEM 0xB60000FF
#define COLOUR_YELLOW 0xFFFF2AFF
#define COLOUR_GREEN 0x00BC00FF
//==============================================================================
//                              Configuration
//==============================================================================
//#define HOUSEMENU 21700 // ид диолога
#define SPAWN_IN_HOUSE // Комментарий Если вы не хотите, чтобы игрок spawn в своем доме в следующий раз он возвращается.
#define GH_USE_MAPICONS // Комментарий, если вы не хотите карте значками.
//#define GH_USE_CPS // Комментарий, если вы хотите использовать пикапы вместо чек-поинтов.
#define GH_HINTERIOR_UPGRADE // Комментарий, если вы не хотите, чтобы игроки были в состоянии модернизировать их домашнего интерьера.
#define HSPAWN_TIMER_RATE 500 // После, как долго будет таймер вызова появляются в доме функции? (в мс)
#define MICON_VD 100.0 // Значок карты видимом диапазоне (drawdistance).
//#define MICON_VD 50.0 // Значок карты видимом диапазоне (drawdistance).
#define DEFAULT_H_INTERIOR 0 // DEFAULT домашнего интерьера при создании дома
#define DEFAULT_H_INTERIOR_PRICE 3000000 // По умолчанию домашнего интерьера цена при создании дома
#define GH_USE_WEAPONSTORAGE // Если определено владельца дома может хранить свое оружие в доме хранения.
#define GH_SAVE_ADMINWEPS // Если определено дом владелец может сохранить оружие, как пулемет, гранаты, РПГ и т.д..
#define GH_DEBUGGING // Если определена это позволит отладки печатает в консоли сервера.
//#define GH_HOUSECARS // Если определенный сценарий будет иметь дом автомобили (примечание: вам нужно добавить позицию дом автомобиля с помощью /addhcar)
// Примечание 2: Необходимо определить SPAWN_IN_HOUSE для того, чтобы создать housecar на первом spawn.
#define HCAR_COLOUR1 -1 // первый цвет housecar
#define HCAR_COLOUR2 -1 // Второй цвет housecar
#define HCAR_RESPAWN 60 // респаун задержки дом автомобиля (в секундах)
#define HCAR_RANGE 10.0 // Диапазон для проверки близлежащих транспортных средств при сохранении дома автомобиля.
#define MAX_HOUSES 500 // Макс дома создан
//#define MAX_HOUSES 250 // Макс дома создан
#define MAX_HOUSES_OWNED 4 // Макс домов, принадлежащих за игрока
//#define MAX_HOUSES_OWNED 1 // Макс домов, принадлежащих за игрока
#define PICKUP_MODEL_OUT (1273)
#define PICKUP_MODEL_INT (1272)
#define PICKUP_TYPE (1)
#define HOUSEFILE_LENGTH 30 // Длина housefile (по умолчанию /GarHouse/Houses/<0-MAX_HOUSES>.ini
#define MAX_VISIT_TIME 60 // Максимальное время игрок может быть посещения в (в секундах).
//#define MAX_VISIT_TIME 1 // Максимальное время игрок может быть посещения в (в минутах).
#define INVALID_HOWNER_NAME "*** INV_PL_ID" // "имя " хозяина дома, когда нет реального владельца дома (если это имело смысл)
//#define INVALID_HOWNER_NAME "INVALID_PLAYER_ID" // "имя " хозяина дома, когда нет реального владельца дома (если это имело смысл)
//#define TIME_BETWEEN_VISITS 2 // время игрок должен подождать, прежде чем просмотр нового интерьера дома (в минутах).
#define H_INT_0_VALUE 3000000 // Интерьер дома цена для домашнего интерьера 0
#define H_INT_1_VALUE 100000 //Интерьер дома цена для домашнего интерьера 1
#define H_INT_2_VALUE 1000000 // Интерьер дома цена для домашнего интерьера 2
#define H_INT_3_VALUE 1500000 // Интерьер дома цена для домашнего интерьера 3
#define H_INT_4_VALUE 1500000 // Интерьер дома цена для домашнего интерьера 4
#define H_INT_5_VALUE 2500000 // Интерьер дома цена для домашнего интерьера 5
#define H_INT_6_VALUE 3000000 // Интерьер дома цена для домашнего интерьера 6
#define H_INT_7_VALUE 5000000 // Интерьер дома цена для домашнего интерьера 7
#define H_INT_8_VALUE 7500000 // Интерьер дома цена для домашнего интерьера 8
#define H_INT_9_VALUE 10000000 // Интерьер дома цена для домашнего интерьера 9
#define H_INT_10_VALUE 25000000 // Интерьер дома цена для домашнего интерьера 10
#define HOUSE_SELLING_PROCENT 75 // количество дом значение игрок получит, когда дом продается.
#define HOUSE_SELLING_PROCENT2 6.5 // Общий процент близлежащих домов будет идти /down путем, когда дом продается /bought неподалеку.
#define RANGE_BETWEEN_HOUSES 200 // диапазон, используемый при увеличении /decreasing Значение близлежащих домов, когда дом купили /sold (значение 0 для отключения)
#define MAX_HOUSE_NAME 35 // Максимальная длина дом имя
#define MIN_HOUSE_NAME 4 // Mв длину дом имя
#define MAX_HOUSE_PASSWORD 35 // Максимальная длина пароля дом
#define MIN_HOUSE_PASSWORD 4 // Мин длина дом пароль
//#define MIN_HOUSE_PASSWORD 8 // Мин длина дом пароль
#define DEFAULT_HOUSE_NAME "Свободен" // имя по умолчанию, когда дом создан /sold
#define MIN_HOUSE_VALUE 500000 // Мин дома стоимость дома (OFC цены будут изменяться, когда дом купили /sold поблизости)
#define MAX_HOUSE_VALUE 25000000 // Макс дома стоимость дома (OFC цены будут изменяться, когда дом купили /sold поблизости)
#define CASE_SENSETIVE false // Используется в виде чеков STRCMP имя. Определить, как истинный /false [0/1]. Читайте вики для получения дополнительной информации
//#define CASE_SENSETIVE true // Используется в виде чеков STRCMP имя. Определить, как истинный /false [0/1]. Читайте вики для получения дополнительной информации
#if defined GH_USE_CPS
	new HouseCPOut[MAX_HOUSES], HouseCPInt[MAX_HOUSES];
#endif
#if !defined GH_USE_CPS
	new HousePickupOut[MAX_HOUSES], HousePickupInt[MAX_HOUSES];
#endif
new Text3D:HouseLabel[MAX_HOUSES];
new Float:X, Float:Y, Float:Z, Float:Angle;
#if defined GH_USE_MAPICONS
	new HouseMIcon[MAX_HOUSES];
#endif
#if defined GH_HOUSECARS
	new HouseCar[MAX_HOUSES];
#endif
//==============================================================================

//------------------------------------------------------------------------------
//                              Important.
//------------------------------------------------------------------------------
#define LABELTEXT1 "Дом: %s\nВладелец дома: Нет хозяина\nДом продаётся за: %d $\nДом ID: %d"
#define LABELTEXT2 "Имя дома: %s\nВладелец дома: %s\nДом куплен за: %d $\nДом ID: %d"
#define FILEPATH "/GarHouse/Houses/%d.ini"
#define INFORMATION_HEADER "Информация"
//------------------------------------------------------------------------------
// 				Информация и сообщения об ошибках
//------------------------------------------------------------------------------
#define E_NO_HOUSES_OWNED "Вы не являетесь владельцем этого дома."
#define I_HMENU "/housemenu - для доступа к меню дома."
#define E_H_ALREADY_OWNED "Этот дом уже принадлежит другому."
#define E_INVALID_HPASS_LENGTH "Неверная длина пароля."
#define E_INVALID_HPASS "Неверный пароль. Вы не можете использовать этот пароль."
#define E_INVALID_HNAME_LENGTH "Неверная длина имени дома."
#define I_HPASS_NO_CHANGE "Пароль для дома остался без изменений."
#define I_HPASS_REMOVED "Пароль дома был удален."
#define E_NOT_ENOUGH_PMONEY "У Вас нет столько денег!"
#define E_INVALID_AMOUNT "Неверная сумма."
#define E_HSTORAGE_L_REACHED "Вы не можете хранить в доме столько денег. (максимум 25000000 $)"
#define E_NOT_ENOUGH_HSMONEY "У Вас нет на хранении столько денег!"
#define E_NO_WEAPONS "У Вас нет оружия."
#define E_NO_HS_WEAPONS "У Вас нет оружия на хранении."
#define E_C_ACCESS_SE_HM "Вы не можете открыть меню дома, это не Ваш дом."
#define E_NOT_IN_HOUSE "Вы должны быть в доме для использования этой команды."
#define E_NOT_HOWNER "Вы должны быть владельцем дома для использования этой команды."
#define E_HCAR_NOT_IN_VEH "Вы должны быть в автомобиле. Добавить автомобиль возле дома."
#define E_INVALID_HID "Неверный дом ID. Этот дом ID не существует."
#define E_NO_HCAR "Этот дом ID не имеет автомобиля возле дома. Не удается удалить."
#define E_H_A_F_SALE "Этот дом уже на продаже. Вы не можете продать дом."
#define HMENU_ENTER_PASS "Имя дома: %s\nВладелец дома: %s\nДом продаётся за: %d $\nДом ID: %d\n\nЧтобы войти в дом, введите пароль:"
#define HMENU_BUY_HOUSE "%s, Вы хотите купить этот дом за %d $ ?"
#define HMENU_BUY_HINTERIOR "Вы хотите купить интерьер %s для дома за %d $ ?"
#define HMENU_SELL_HOUSE "%s, Вы уверены, что хотите продать свой дом %s за %d $ ?"
#define I_SELL_HOUSE1 "Вы успешно продали свой дом за %d $.\nОплата: %d $.\nВаши %d $ , находившиеся на хранении, были переданы Вам."
#define I_SELL_HOUSE2 "Вы успешно продали свой дом \"%s\" за %d $.\nОплата: %d $."
#define I_BUY_HOUSE "Вы успешно купили этот дом за %d $ !"
#define I_HPASSWORD_CHANGED "Вы успешно создали пароль для дома \"%s\"!"
#define I_HNAME_CHANGED "Вы успешно изменили имя дома на \"%s\"!"
#define E_ALREADY_HAVE_HINTERIOR "У Вас уже есть этот интерьер."
#define I_VISITING_HOUSEINT "Вы осматриваете интерьер %s.\nЭтот интерьер стоит %d $.\nВремя осмотра закончится через %d Сек."
//#define I_VISITING_HOUSEINT "Вы осматриваете интерьер %s.\nЭтот интерьер стоит %d $.\nВремя осмотра закончится через %d Сек. %s."
#define E_CANT_AFFORD_HINT "Вы не можете позволить себе купить интерьер %s.\nСтоимость интерьера: %d $.\nУ Вас есть: %d $.\nВам не хватает: %d $."
#define I_HINT_BOUGHT "Вы купили интерьер %s за %d $."
#define I_HINT_DEPOSIT1 "У Вас на хранении уже есть %d $.\n\nВведите сумму, которую вы хотите положить:"
#define I_HINT_WITHDRAW1 "У Вас на хранении есть %d $.\n\nВведите сумму, которую вы хотите снять:"
#define I_HINT_DEPOSIT2 "Вы успешно положили на хранение %d $.\nТекущий баланс: %d $."
#define I_HINT_WITHDRAW2 "Вы успешно сняли с хранения %d $.\nТекущий баланс: %d $."
#define I_HINT_CHECKBALANCE "У Вас на хранении лежит %d $."
#define E_HINT_WAIT_BEFORE_VISITING "Пожалуйста, подождите до осмотра следующего интерьера."
#define I_HS_WEAPONS1 "Успешно сохранено %d единицы оружия в Вашем доме."
//#define I_HS_WEAPONS1 "Успешно сохранен %d Оружие %s В вашем доме хранения."
#define I_HS_WEAPONS2 "Вы успешно сняли с хранения %d единицы оружия в Вашем доме."
//#define I_HS_WEAPONS2 "Успешно поступила %d Оружие %s От вашего дома хранения."
#define I_WRONG_HPASS1 "Вы не вошли в дом %s с использованием пароля \"%s\"."
#define I_WRONG_HPASS2 "Дом информация: %s [%d] попытался войти в дом с использованием пароля \"%s\"."
#define I_CORRECT_HPASS1 "Вы успешно вошли в дом %s используя пароль \"%s\"!"
#define I_CORRECT_HPASS2 "Дом информация: %s [%d] успешно вошёл в Ваш дом, используя пароль \"%s\"!"
#define E_TOO_MANY_HOUSES "Извините, но дом с максимальным ID %d уже создан.\nУдалите один из существующих или увеличите максимум домов."
#define E_INVALID_HVALUE "Неверная стоимость дома. Стоимость должна быть между 500,000 $ и 25,000,000 $."
#define I_H_CREATED "Дом ID %d Создан..."
#define I_HCAR_EXIST_ALREADY "Автомобиль возле дома ID %d уже есть. Замена текущего."
#define I_HCAR_CREATED "Автомобиль возле дома ID %d создан..."
#define I_H_DESTROYED "Дом ID %d удален..."
#define I_HCAR_REMOVED "Автомобиль возле дома ID %d Удалён..."
#define I_ALLH_DESTROYED "Все дома удалены. (%d в итоге)"
#define I_ALLHCAR_REMOVED "Все автомобили возле домов удалены. (%d в итоге)"
#define I_HSPAWN_CHANGED "Вы изменили позицию спавна и угол для дома ID %d."
#define I_TELEPORT_MSG "Вы телепортировались к дому ID %d."
#define I_H_SOLD "Вы продали дом ID %d..."
#define I_ALLH_SOLD "Все дома на сервере были проданы. (%d в итоге)"
#define I_H_PRICE_CHANGED "Стоимость дома ID %d была изменена на %d $."
#define I_ALLH_PRICE_CHANGED "Вы изменили стоимость всех домов на сервере на %d $. (%d в итоге)"
#define I_HINT_VISIT_OVER "Время осмотра закончилось.\nВы хотите купить интерьер %s за %d $ ?"
//#define I_HINT_VISIT_OVER "Ваше посещение время кончилось.\nВы хотите купить дом Интерьер %s Для $%d?"
#define E_INVALID_HCAR_MODEL "Неверный ID модели автомобиля. (ID модели должны быть от 400 и до 611)"
#define I_HCAR_CHANGED "ID модели автомобиля возле дома ID %d был изменён на %d."
//------------------------------------------------------------------------------
#define E_CMD_USAGE_CREATEHOUSE "Использование: /createhouse [стоимость] [дополнительно: интерьер дома]"
#define E_CMD_USAGE_ADDHCAR "Использование: /addhcar [ID дома]"
#define E_CMD_USAGE_REMOVEHOUSE "Использование: /removehouse [ID дома]"
#define E_CMD_USAGE_REMOVEHCAR "Использование: /removehcar [ID дома]"
#define E_CMD_USAGE_CHANGEHCAR "Использование: /changehcar [ID дома] [ID модели: 400-611]"
#define E_CMD_USAGE_CHANGESPAWN "Использование: /changespawn [ID дома]"
#define E_CMD_USAGE_GOTOHOUSE "Использование: /gotohouse [ID дома]"
#define E_CMD_USAGE_SELLHOUSE "Использование: /sellhouse [ID дома]"
#define E_CMD_USAGE_CHANGEPRICE "Использование: /changeprice [ID дома] [стоимость]"
#define E_CMD_USAGE_CHANGEALLPRICE "Использование: /changeallprices [стоимость]"
//------------------------------------------------------------------------------
//                          Отладочные сообщения
//------------------------------------------------------------------------------
#if defined GH_DEBUGGING
#define DEBUG_OP_DISCONNECT "[GarHouse] %s [%d] остался в своём доме (disconnect)"
#define DEBUG_OP_ED_CP1 "[GarHouse] %s [%d] вошёл в дом ID %d."
#define DEBUG_OP_ED_CP2 "[GarHouse] %s [%d] вышел из дома ID %d."
#define DEBUG_OP_PUD_PICKUP1 "[GarHouse] %s [%d] вошёл в дом ID %d."
#define DEBUG_OP_PUD_PICKUP2 "[GarHouse] %s [%d] вышел из дома ID %d."
#define DEBUG_ODR1 "[GarHouse] %s [%d] купил дом ID %d за %d $."
#define DEBUG_ODR2 "[GarHouse] %s [%d] изменил имя дома ID %d на %s ."
#define DEBUG_ODR3 "[GarHouse] %s [%d] купил интерьер %s за %d $ для дома ID %d."
#define DEBUG_ODR4 "[GarHouse] %s [%d] осматривает интерьер %s (дом ID %d)"
#define DEBUG_ODR5 "[GarHouse] для дома ID %d установлен интерьер %d."
#define DEBUG_ODR6 "[GarHouse] %s [%d] проверил сумму денег в доме ID %d (сумма: %d $)"
#define DEBUG_ODR7 "[GarHouse] %s [%d] положил на хранение %d $ в доме ID %d."
#define DEBUG_ODR8 "[GarHouse] %s [%d] снял с хранения %d $ в доме ID %d."
//#define DEBUG_ODR9 "[GarHouse] (OnDialogResponse) - %s [%d] Положить %d оружие%s В доме для хранения дома ID %d."
#define DEBUG_ODR10 "[GarHouse] %s [%d] положил на хранение %d единиц оружия в доме ID %d."
//#define DEBUG_ODR10 "[GarHouse] (OnDialogResponse) - %s [%d] Взять %d оружия%s В доме для хранения дома ID %d."
#define DEBUG_ODR11 "[GarHouse] %s [%d] снял с хранения %d единиц оружия в доме ID %d."
//#define DEBUG_ODR11 "[GarHouse] (OnDialogResponse) - %s [%d] Новое оружия %d оружия%s Из дома для хранения дома ID %d."
#define DEBUG_ODR12 "[GarHouse] %s [%d] успешно вошел в дом ID %d с использованием пароля."
#define DEBUG_ODR13 "[GarHouse] %s [%d] продал свой дом за %d $ (денег в доме: %d $ | дом ID %d)"
#define DEBUG_ODR14 "[GarHouse] %s [%d] изменил пароль для дома ID %d на (%s) FP: (%s) ."
#define DEBUG_OP_CMD1 "[GarHouse] %s [%d] создал дом (дом ID %d | стоимость: %d $ | всего домов: %d)"
#define DEBUG_OP_CMD2 "[GarHouse] %s [%d] создал автомобиль возле дома ID %d."
#define DEBUG_OP_CMD3 "[GarHouse] %s [%d] удалил дом ID %d."
#define DEBUG_OP_CMD4 "[GarHouse] %s [%d] удалил автомобиль возле дома ID %d."
#define DEBUG_OP_CMD5 "[GarHouse] %s [%d] удалил все дома (%d в итоге)"
#define DEBUG_OP_CMD6 "[GarHouse] %s [%d] удалил все автомобили возле домов (%d в итоге)"
#define DEBUG_OP_CMD7 "[GarHouse] %s [%d] изменил позицию спавна и угол для дома ID %d."
#define DEBUG_OP_CMD8 "[GarHouse] %s [%d] продал дом ID %d."
#define DEBUG_OP_CMD9 "[GarHouse] %s [%d] продал все дома (%d в итоге)"
#define DEBUG_OP_CMD10 "[GarHouse] %s [%d] изменил стоимость дома ID %d на %d $."
#define DEBUG_OP_CMD11 "[GarHouse] %s [%d] изменил стоимость всех домов на %d $ (%d в итоге)"
#define DEBUG_OP_CMD12 "[GarHouse] %s [%d] изменил ID модели автомобиля возле дома ID %d на %d."
#define DEBUG_OP_SPAWN "[GarHouse] %s [%d] Заспавнился в своём доме."
#endif

new lockpas[MAX_PLAYERS];//массив блокировок диалога ввода пароля
//разблокировать диалог ввода пароля
new dlgcont[MAX_PLAYERS];//контроль ИД диалога
new timcontrol;//контрольный таймер нахождения игрока в доме
#define MAX_VW_HOUSE (999 + MAX_HOUSES)//максимальный виртуальный мир системы домов
//------------------------------------------------------------------------------
//==============================================================================
//                              Awesomeness
//==============================================================================
public OnFilterScriptInit()
{

	timcontrol = SetTimer("HouseOneSec", 1009, 1);//контрольный таймер нахождения игрока в доме
	for(new i = 0; i < MAX_PLAYERS; i++)//цикл для всех игроков
	{
		dlgcont[i] = -600;//не существующий ИД диалога
		lockpas[i] = 0;//обнуление массива блокировок диалога ввода пароля
	}

    LoadHouses(); // Загрузка фс дома
    Loop(i, MAX_PLAYERS)
    {
        if(IsPlayerConnected(i) && !IsPlayerNPC(i))
        {
            SetPVarInt(i, "HousePrevTime", 0);
        }
    }
    return 1;
}
public OnFilterScriptExit()
{
	new file[HOUSEFILE_LENGTH], tmp;
	Loop(i, MAX_PLAYERS)
	{
	    if(IsPlayerConnected(i) && !IsPlayerNPC(i))
	    {
	        tmp = GetPVarInt(i, "LastHouseCP");
			format(file, sizeof(file), FILEPATH, tmp);
		    if(!strcmp(GetHouseOwner(tmp), pNick(i), CASE_SENSETIVE) && GetPVarInt(i, "IsInHouse") == 1 && dini_Exists(file))
			{
			    dini_IntSet(file, "QuitInHouse", 1);
			    #if defined GH_HOUSECARS
			    	SaveHouseCar(tmp);
		        #endif
			}
		}
	}
    UnloadHouses(); // Выгрузка домов (также разгружает дом автомобили)
	KillTimer(timcontrol);//контрольный таймер нахождения игрока в доме
    return 1;
}
public OnPlayerSpawn(playerid)
{
    if(GetPVarInt(playerid, "FirstSpawn") == 0)
    {
        // Используется для того, чтобы плеер spawn в их доме, если они уходят в их доме (только призвал к первому spawn)
		#if defined SPAWN_IN_HOUSE
    		SetTimerEx("HouseSpawning", HSPAWN_TIMER_RATE, false, "i", playerid);
    	#endif
    	// Увеличение скорости таймера, если ваш режимы игры OnPlayerSpawn вызывается после таймер закончился
    }
	return 1;
}
public OnPlayerConnect(playerid)
{

	dlgcont[playerid] = -600;//не существующий ИД диалога
	lockpas[playerid] = 0;//разблокировать диалог ввода пароля
	SetPVarInt(playerid, "HousePrevTime", 0);//обнуление важных глобальных переменных !!!
	SetPVarInt(playerid, "HousePreview", 0);
	SetPVarInt(playerid, "IsHouseVisiting", 0);
	SetPVarInt(playerid, "LastHouseCP", 0);
	SetPVarInt(playerid, "IsInHouse", 0);
	SetPVarInt(playerid, "HousePrevInt", 0);
	SetPVarInt(playerid, "IsHouseVisiting", 0);
	SetPVarInt(playerid, "ChangeHouseInt", 0);
	SetPVarInt(playerid, "HouseIntUpgradeMod", 0);
	SetPVarInt(playerid, "JustCreatedHouse", 0);
	SetPVarInt(playerid, "FirstSpawn", 0);

	return 1;
}
public OnPlayerDisconnect(playerid, reason)
{

	if(GetPVarInt(playerid, "HousePrevTime") != 0)
	{//если игрок осматривает интерьер, то сбросить таймер осмотра интерьера
	    SetPVarInt(playerid, "HousePreview", 0);
	    KillTimer(GetPVarInt(playerid, "HousePrevTimer"));
	    SetPVarInt(playerid, "IsHouseVisiting", 0);
		SetPVarInt(playerid, "HousePrevTime", 0);
	}
	if(GetPVarInt(playerid, "HouseIntUpgradeMod") == 1)
	{//если игрок был в режиме осмотра интерьера, то вернуть старый интерьер
		new file555[HOUSEFILE_LENGTH], h = GetPVarInt(playerid, "LastHouseCP");
		format(file555, sizeof(file555), FILEPATH, h);

  		DestroyHouseEntrance(h, TYPE_INT);
		CreateCorrectHouseExitCP(h);
		Loop(i, MAX_PLAYERS)
		{
  			if(GetPVarInt(i, "LastHouseCP") == h && GetPVarInt(i, "IsInHouse") == 1)
  			{
				SetPlayerHouseInterior(i, h);
			}
		}
//		#if defined GH_DEBUGGING
//			printf(DEBUG_ODR5, h, GetPVarInt(playerid, "HousePrevInt"));
//		#endif
	}
	SetPVarInt(playerid, "HouseIntUpgradeMod", 0);

	new file[HOUSEFILE_LENGTH];
	format(file, sizeof(file), FILEPATH, GetPVarInt(playerid, "LastHouseCP"));
    if(!strcmp(GetHouseOwner(GetPVarInt(playerid, "LastHouseCP")), pNick(playerid), CASE_SENSETIVE) && GetPVarInt(playerid, "IsInHouse") == 1 && dini_Exists(file))
	{
	    dini_IntSet(file, "QuitInHouse", 1);
	    #if defined GH_HOUSECARS
	    	SaveHouseCar(GetPVarInt(playerid, "LastHouseCP"));
	    	UnloadHouseCar(GetPVarInt(playerid, "LastHouseCP"));
        #endif
	    #if defined GH_DEBUGGING
	    	printf(DEBUG_OP_DISCONNECT, pNick(playerid), playerid);
    	#endif
	}
	dlgcont[playerid] = -600;//не существующий ИД диалога
	return 1;
}
public OnPlayerCommandText(playerid, cmdtext[])
{
	if(GetPVarInt(playerid, "CComAc3") < 0)
	{
		new dopcis, sstr[256];
		dopcis = FCislit(GetPVarInt(playerid, "CComAc3"));
		switch(dopcis)
		{
			case 0: format(sstr, sizeof(sstr), " Спам в чате (или в командах) !   Попробуйте через %d секунд !", GetPVarInt(playerid, "CComAc3") * -1);
			case 1: format(sstr, sizeof(sstr), " Спам в чате (или в командах) !   Попробуйте через %d секунду !", GetPVarInt(playerid, "CComAc3") * -1);
			case 2: format(sstr, sizeof(sstr), " Спам в чате (или в командах) !   Попробуйте через %d секунды !", GetPVarInt(playerid, "CComAc3") * -1);
		}
		SendClientMessage(playerid, 0xFF0000FF, sstr);
		return 1;
	}
	SetPVarInt(playerid, "CComAc3", GetPVarInt(playerid, "CComAc3") + 1);
    dcmd(removeallhouses, 15, cmdtext);
	dcmd(changeallprices, 15, cmdtext);
	dcmd(removeallhcars, 14, cmdtext);
	dcmd(sellallhouses, 13, cmdtext);
    dcmd(createhouse, 11, cmdtext);
    dcmd(passhouse, 9, cmdtext);//просмотр пароля дома
    dcmd(relhouses, 9, cmdtext);//перезагрузка системы домов
    dcmd(lchouse, 7, cmdtext);//блокировка дома по его ИД
	dcmd(removehouse, 11, cmdtext);
	dcmd(changeprice, 11, cmdtext);
	dcmd(changespawn, 11, cmdtext);
	dcmd(removehcar, 10, cmdtext);
	dcmd(changehcar, 10, cmdtext);
	dcmd(sellhouse, 9, cmdtext);
	dcmd(housemenu, 9, cmdtext);
	dcmd(gotohouse, 9, cmdtext);
	dcmd(addhcar, 7, cmdtext);
	dcmd(ghcmds, 6, cmdtext);
	return 0;
}
#if defined GH_USE_CPS
public OnPlayerEnterDynamicCP(playerid, checkpointid)
{
    if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
	{
	    new file[HOUSEFILE_LENGTH], string[256]; // Не жалуются на огромные размеры, просто измените его, если вам нужно.
	    Loop(h, MAX_HOUSES)
		{
		    format(file, sizeof(file), FILEPATH, h);
		    if(checkpointid == HouseCPOut[h])
		    {
		        SetPVarInt(playerid, "LastHouseCP", h);
		        if(!strcmp(GetHouseOwner(h), pNick(playerid), CASE_SENSETIVE)/* || IsPlayerAdmin(playerid)*/) // Если удалить комментарий, RCON администраторы могут войти в любой дом они хотят.
		        {
		            SetPVarInt(playerid, "IsInHouse", 1);
		            SetPlayerHouseInterior(playerid, h);
		            if(!strcmp(GetHouseOwner(h), pNick(playerid), CASE_SENSETIVE))
		            {
			        	SendClientMessage(playerid, COLOUR_INFO, I_HMENU);
			        }
			        #if defined GH_DEBUGGING
				    	printf(DEBUG_OP_ED_CP1, pNick(playerid), playerid, h);
			    	#endif
		        }
		        if(strcmp(GetHouseOwner(h), pNick(playerid), CASE_SENSETIVE) && strcmp(GetHouseOwner(h), INVALID_HOWNER_NAME, CASE_SENSETIVE))
		        {
		            if(!strcmp(dini_Get(file, "HousePassword"), "INVALID_HOUSE_PASSWORD", CASE_SENSETIVE))
					{
		        		ShowInfoBox(playerid, INFORMATION_HEADER, LABELTEXT2, GetHouseName(h), GetHouseOwner(h), GetHouseValue(h), h);
					}
					if(strcmp(dini_Get(file, "HousePassword"), "INVALID_HOUSE_PASSWORD", CASE_SENSETIVE))
					{
		        		format(string,sizeof(string), HMENU_ENTER_PASS, GetHouseName(h), GetHouseOwner(h), GetHouseValue(h), h);
	                	ShowPlayerDialog(playerid, 521, DIALOG_STYLE_INPUT, "Информация о доме", string, "Ok", "Отмена");
						dlgcont[playerid] = 521;
					}
		        }
		        if(!strcmp(GetHouseOwner(h), INVALID_HOWNER_NAME, CASE_SENSETIVE) && dini_Int(file, "HouseValue") > 0 && GetPVarInt(playerid, "JustCreatedHouse") == 0)
				{
					format(string, sizeof(string), HMENU_BUY_HOUSE, pNick(playerid), GetHouseValue(h));
					ShowPlayerDialog(playerid, 504, DIALOG_STYLE_MSGBOX, "Покупка дома", string, "Купить", "Отмена");
					dlgcont[playerid] = 504;
				}
				break;
		    }
		    if(checkpointid == HouseCPInt[h])
		    {
		        #if defined GH_HINTERIOR_UPGRADE
		        if(GetPVarInt(playerid, "HousePreview") == 1)
		        {
		            new tmpstring[50];
					GetPVarString(playerid, "HousePrevName", tmpstring, 50);
					format(string, sizeof(string), HMENU_BUY_HINTERIOR, tmpstring, GetPVarInt(playerid, "HousePrevValue"));
					ShowPlayerDialog(playerid, 517, DIALOG_STYLE_MSGBOX, "Интерьер", string, "Купить", "Отмена");
					dlgcont[playerid] = 517;
		        }
		        #endif
		        if(GetPVarInt(playerid, "HousePreview") == 0)
		        {
		            SetPVarInt(playerid, "IsInHouse", 0);
			        SetPlayerPosEx(playerid, dini_Float(file, "SpawnOutX"), dini_Float(file, "SpawnOutY"), dini_Float(file, "SpawnOutZ"), dini_Float(file, "SpawnOutAngle"), dini_Int(file, "SpawnInterior"), dini_Int(file, "SpawnWorld"));
			        #if defined GH_DEBUGGING
				    	printf(DEBUG_OP_ED_CP2, pNick(playerid), playerid, h);
			    	#endif
				}
				break;
		    }
	    }
	}
	return 1;
}
public OnPlayerLeaveDynamicCP(playerid, checkpointid)
{
    if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT && GetPVarInt(playerid, "JustCreatedHouse") == 1)
	{
	    Loop(h, MAX_HOUSES)
		{
		    if(checkpointid == HouseCPOut[h])
		    {
		        SetPVarInt(playerid, "JustCreatedHouse", 0);
		        break;
		    }
	    }
	}
	return 1;
}
#endif
#if !defined GH_USE_CPS
public OnPlayerPickUpDynamicPickup(playerid, pickupid)
{

	if(GetPVarInt(playerid, "HousePrevTime") != 0) return 1;//запрет активации пикапа

    if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
	{
	    new file[HOUSEFILE_LENGTH], string[256]; // Не жалуются на огромные размеры, просто измените его, если вам нужно.
	    Loop(h, MAX_HOUSES)
		{
		    format(file, sizeof(file), FILEPATH, h);
		    if(pickupid == HousePickupOut[h])
		    {
		        SetPVarInt(playerid, "LastHouseCP", h);
		        if(!strcmp(GetHouseOwner(h), pNick(playerid), CASE_SENSETIVE)/* || IsPlayerAdmin(playerid)*/) // Если удалить комментарий, RCON администраторы могут войти в любой дом они хотят.
		        {
		            SetPVarInt(playerid, "IsInHouse", 1);
		            SetPlayerHouseInterior(playerid, h);
		            if(!strcmp(GetHouseOwner(h), pNick(playerid), CASE_SENSETIVE))
		            {
			        	SendClientMessage(playerid, COLOUR_INFO, I_HMENU);
			        }
			        #if defined GH_DEBUGGING
				    	printf(DEBUG_OP_PUD_PICKUP1, pNick(playerid), playerid, h);
			    	#endif
		        }
		        if(strcmp(GetHouseOwner(h), pNick(playerid), CASE_SENSETIVE) && strcmp(GetHouseOwner(h), INVALID_HOWNER_NAME, CASE_SENSETIVE))
		        {
		            if(!strcmp(dini_Get(file, "HousePassword"), "INVALID_HOUSE_PASSWORD", CASE_SENSETIVE))
					{
		        		ShowInfoBox(playerid, INFORMATION_HEADER, LABELTEXT2, GetHouseName(h), GetHouseOwner(h), GetHouseValue(h), h);
					}
					if(strcmp(dini_Get(file, "HousePassword"), "INVALID_HOUSE_PASSWORD", CASE_SENSETIVE))
					{

            			if(lockpas[playerid] == 1) return 1;//если диалог ввода пароля заблокирован, то завершить public
						lockpas[playerid] = 1;//заблокировать диалог ввода пароля

		        		format(string,sizeof(string), HMENU_ENTER_PASS, GetHouseName(h), GetHouseOwner(h), GetHouseValue(h), h);
	                	ShowPlayerDialog(playerid, 521, DIALOG_STYLE_INPUT, "Информация о доме", string, "OK", "Отмена");
						dlgcont[playerid] = 521;
					}
		        }
		        if(!strcmp(GetHouseOwner(h), INVALID_HOWNER_NAME, CASE_SENSETIVE) && dini_Int(file, "HouseValue") > 0)
				{
					format(string, sizeof(string), HMENU_BUY_HOUSE, pNick(playerid), GetHouseValue(h));
					ShowPlayerDialog(playerid, 504, DIALOG_STYLE_MSGBOX, "Покупка дома", string, "Купить", "Отмена");
					dlgcont[playerid] = 504;
				}
				break;
		    }
		    if(pickupid == HousePickupInt[h])
		    {
		        #if defined GH_HINTERIOR_UPGRADE
		        if(GetPVarInt(playerid, "HousePreview") == 1)
		        {
		            new tmpstring[50];
					GetPVarString(playerid, "HousePrevName", tmpstring, 50);
					format(string, sizeof(string), HMENU_BUY_HINTERIOR, tmpstring, GetPVarInt(playerid, "HousePrevValue"));
					ShowPlayerDialog(playerid, 517, DIALOG_STYLE_MSGBOX, "Интерьер", string, "Купить", "Отмена");
					dlgcont[playerid] = 517;
		        }
		        #endif
		        if(GetPVarInt(playerid, "HousePreview") == 0)
		        {
		            SetPVarInt(playerid, "IsInHouse", 0);
			        SetPlayerPosEx(playerid, dini_Float(file, "SpawnOutX"), dini_Float(file, "SpawnOutY"), dini_Float(file, "SpawnOutZ"), dini_Float(file, "SpawnOutAngle"), dini_Int(file, "SpawnInterior"), dini_Int(file, "SpawnWorld"));
			        #if defined GH_DEBUGGING
				    	printf(DEBUG_OP_PUD_PICKUP2, pNick(playerid), playerid, h);
			    	#endif
				}
				break;
		    }
	    }
	}
	return 1;
}
#endif
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	new string[400], file[HOUSEFILE_LENGTH], file2[HOUSEFILE_LENGTH], h = GetPVarInt(playerid, "LastHouseCP"); // Don't complain about huge size, just change it if you need.
    format(file, sizeof(file), FILEPATH, h);
	if(dialogid == 500)
	{
		if(dialogid != dlgcont[playerid])
		{
			dlgcont[playerid] = -600;//не существующий ИД диалога
			return 1;
		}
		dlgcont[playerid] = -600;//не существующий ИД диалога
		if(response)
		{
		    switch(listitem)
			{
			    case 0:
			    {
					format(string, sizeof(string), HMENU_SELL_HOUSE, pNick(playerid), GetHouseName(h), ReturnProcent(GetHouseValue(h), HOUSE_SELLING_PROCENT));
					ShowPlayerDialog(playerid, 503, DIALOG_STYLE_MSGBOX, "Продажа дома", string, "Продать", "Отмена");
					dlgcont[playerid] = 503;
			    }
			    case 1:
				{
					#if defined GH_USE_WEAPONSTORAGE
						ShowPlayerDialog(playerid, 518, DIALOG_STYLE_LIST, "Хранение в доме", "Хранение денег\nХранение оружия", "OK", "Отмена");
						dlgcont[playerid] = 518;
					#endif
					#if !defined GH_USE_WEAPONSTORAGE
						ShowPlayerDialog(playerid, 510, DIALOG_STYLE_LIST, "Хранение денег", "Положить на хранение\nСнять с хранения\nПроверить сумму", "OK", "Отмена");
						dlgcont[playerid] = 510;
					#endif
				}
				case 2:
				{
					ShowPlayerDialog(playerid, 514, DIALOG_STYLE_INPUT, "Имя дома", "Введите новое имя дома", "OK", "Отмена");
					dlgcont[playerid] = 514;
				}
			    case 3:
				{
					new parloc[128];
					format(parloc, sizeof(parloc), "%s", dini_Get(file, "HousePassword"));
					if(strcmp(parloc, "INVALID_HOUSE_PASSWORD", false) == 0)
					{
						ShowPlayerDialog(playerid, 513, DIALOG_STYLE_INPUT, "Пароль для дома", "{FFC4E4}У Вас нет пароля для дома!\n{A9C4E4}Введите новый пароль для дома ниже.\
						\nОставьте поле пустым, если хотите сохранить Ваш старый пароль.\nУдалить - чтобы удалить пароль.", "OK", "Удалить");
					}
					else
					{
						new parloc44[1024];
				    	format(parloc44, sizeof(parloc44), "{A9FFE4}У Вас уже есть пароль для дома \"%s\"!\n{A9C4E4}Введите новый пароль для дома ниже.\
						\nОставьте поле пустым, если хотите сохранить Ваш старый пароль.\nУдалить - чтобы удалить пароль.", parloc);
						ShowPlayerDialog(playerid, 513, DIALOG_STYLE_INPUT, "Пароль для дома", parloc44, "OK", "Удалить");
					}
					dlgcont[playerid] = 513;
				}
				case 4:
				{
					ShowPlayerDialog(playerid, 516, DIALOG_STYLE_LIST, "Интерьер", "Предварительный осмотр интерьера\nКупить интерьер", "OK", "Отмена");
					dlgcont[playerid] = 516;
				}
			}
		}
		return 1;
	}
//------------------------------------------------------------------------------
//                               House Sale
//------------------------------------------------------------------------------
	if(dialogid == 503)
	{
		if(dialogid != dlgcont[playerid])
		{
			dlgcont[playerid] = -600;//не существующий ИД диалога
			return 1;
		}
		dlgcont[playerid] = -600;//не существующий ИД диалога
		if(response)
		{
			if(GetOwnedHouses(playerid) == 0) return SendClientMessage(playerid, COLOUR_SYSTEM, E_NO_HOUSES_OWNED);
			else
			{
			    new tmp = dini_Int(file, "HouseStorage");
				new para1;
				para1 = GetPlayerMoney(playerid);
				SetPVarInt(playerid, "MonControl", 1);
				GivePlayerMoney(playerid, ReturnProcent(GetHouseValue(h), HOUSE_SELLING_PROCENT));
				if(tmp >= 1)
				{
	   				ShowInfoBox(playerid, INFORMATION_HEADER, I_SELL_HOUSE1, ReturnProcent(GetHouseValue(h), HOUSE_SELLING_PROCENT), (GetHouseValue(h) - ReturnProcent(GetHouseValue(h), HOUSE_SELLING_PROCENT)), tmp);
					SetPVarInt(playerid, "MonControl", 1);
					GivePlayerMoney(playerid, tmp);
				}
				if(tmp == 0)
				{
				    ShowInfoBox(playerid, INFORMATION_HEADER, I_SELL_HOUSE2, GetHouseName(h), ReturnProcent(GetHouseValue(h), HOUSE_SELLING_PROCENT), (GetHouseValue(h) - ReturnProcent(GetHouseValue(h), HOUSE_SELLING_PROCENT)));
				}
				dini_IntSet(file, "HouseValue", ReturnProcent(GetHouseValue(h), HOUSE_SELLING_PROCENT));
				dini_Set(file, "HouseOwner", INVALID_HOWNER_NAME);
				dini_Set(file, "HousePassword", "INVALID_HOUSE_PASSWORD");
				dini_Set(file, "HouseName", DEFAULT_HOUSE_NAME);
				dini_IntSet(file, "HouseStorage", 0);
				Loop(h2, MAX_HOUSES)
				{
					if(IsHouseInRangeOfHouse(h, h2, RANGE_BETWEEN_HOUSES) && h2 != h)
					{
				   		format(file2, sizeof(file2), FILEPATH, h2);
						dini_IntSet(file2, "HouseValue", (dini_Int(file2, "HouseValue") - ReturnProcent(GetHouseValue(h2), HOUSE_SELLING_PROCENT2)));
	                    UpdateHouseText(h2);
					}
				}
				new dvw, Float:dcX, Float:dcY, Float:dcZ;
				dcX = dini_Float(file, "CPOutX");
				dcY = dini_Float(file, "CPOutY");
				dcZ = dini_Float(file, "CPOutZ");
				dvw = dini_Int(file, "SpawnWorld");
				#if defined GH_USE_MAPICONS
					DestroyDynamicMapIcon(HouseMIcon[h]);
					HouseMIcon[h] = CreateDynamicMapIcon(dcX, dcY, dcZ, 31, -1, dvw, dini_Int(file, "SpawnInterior"), -1, MICON_VD);
				#endif
				UpdateHouseText(h);
				CallRemoteFunction("GPSrfun", "iiisifff", 1, 1, h, "*** INV_PL_ID", dvw, dcX, dcY, dcZ);
	            #if defined GH_DEBUGGING
	  				printf(DEBUG_ODR13, pNick(playerid), playerid, GetHouseValue(h), tmp, h);
		    	#endif
				printf("[moneysys] Предыдущая сумма игрока %s [%d] : %d $", pNick(playerid), playerid, para1);
			}
		}
		return 1;
	}
//------------------------------------------------------------------------------
//                               House Buying
//------------------------------------------------------------------------------
	if(dialogid == 504)
	{
		if(dialogid != dlgcont[playerid])
		{
			dlgcont[playerid] = -600;//не существующий ИД диалога
			return 1;
		}
		dlgcont[playerid] = -600;//не существующий ИД диалога
		if(response)
		{
		    new hname[MAX_PLAYER_NAME+9];
			if(GetOwnedHouses(playerid) >= MAX_HOUSES_OWNED) { ShowInfoBox(playerid, INFORMATION_HEADER, "У Вас уже есть %d дома.\nПродайте один из старых домов и купите этот дом.", MAX_HOUSES_OWNED); return 1; }
			if(strcmp(GetHouseOwner(GetPVarInt(playerid, "LastHouseCP")), pNick(playerid), CASE_SENSETIVE) && strcmp(GetHouseOwner(h), INVALID_HOWNER_NAME, CASE_SENSETIVE)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_H_ALREADY_OWNED);
			if(GetHouseValue(h) > GetPlayerMoney(playerid)) { ShowInfoBox(playerid, INFORMATION_HEADER, "Вы не можете купить этот дом\nСтоимость дома: $%d.\nУ Вас есть: $%d.\nВам не хватает: $%d.", GetHouseValue(h), GetPlayerMoney(playerid), (GetHouseValue(h) - GetPlayerMoney(playerid))); return 1; }

			else
			{
			    format(hname, sizeof(hname), "%s's House", pNick(playerid));
				new para1;
				para1 = GetPlayerMoney(playerid);
				SetPVarInt(playerid, "MonControl", 1);
				GivePlayerMoney(playerid, - GetHouseValue(h));
				dini_Set(file, "HouseOwner", pNick(playerid));
				dini_Set(file, "HousePassword", "INVALID_HOUSE_PASSWORD");
				dini_Set(file, "HouseName", hname);
				dini_IntSet(file, "HouseStorage", 0);
				ShowInfoBox(playerid, INFORMATION_HEADER, I_BUY_HOUSE, GetHouseValue(h));
				Loop(h2, MAX_HOUSES)
				{
					if(IsHouseInRangeOfHouse(h, h2, RANGE_BETWEEN_HOUSES) && h2 != h)
					{
					    format(file2, sizeof(file2), FILEPATH, h2);
						dini_IntSet(file2, "HouseValue", (dini_Int(file2, "HouseValue") + ReturnProcent(GetHouseValue(h2), HOUSE_SELLING_PROCENT2)));
                        UpdateHouseText(h2);
					}
				}
				new dvw, Float:dcX, Float:dcY, Float:dcZ;
				dcX = dini_Float(file, "CPOutX");
				dcY = dini_Float(file, "CPOutY");
				dcZ = dini_Float(file, "CPOutZ");
				dvw = dini_Int(file, "SpawnWorld");
				#if defined GH_USE_MAPICONS
					DestroyDynamicMapIcon(HouseMIcon[h]);
					HouseMIcon[h] = CreateDynamicMapIcon(dcX, dcY, dcZ, 32, -1, dvw, dini_Int(file, "SpawnInterior"), -1, MICON_VD);
				#endif
				UpdateHouseText(h);
				CallRemoteFunction("GPSrfun", "iiisifff", 1, 1, h, pNick(playerid), dvw, dcX, dcY, dcZ);
                #if defined GH_DEBUGGING
  					printf(DEBUG_ODR1, pNick(playerid), playerid, h, GetHouseValue(h));
	    		#endif
				printf("[moneysys] Предыдущая сумма игрока %s [%d] : %d $", pNick(playerid), playerid, para1);
			}
		}
		return 1;
	}
//------------------------------------------------------------------------------
//                               House Password
//------------------------------------------------------------------------------
	if(dialogid == 513)
	{
		if(dialogid != dlgcont[playerid])
		{
			dlgcont[playerid] = -600;//не существующий ИД диалога
			return 1;
		}
		dlgcont[playerid] = -600;//не существующий ИД диалога
		new parloc[128];
		format(parloc, sizeof(parloc), "%s", dini_Get(file, "HousePassword"));
		if(response)
		{
			if(InpTxtControl(inputtext) == 0)
			{
				SendClientMessage(playerid, COLOUR_SYSTEM, "Ваш пароль содержит недопустимые символы:");
				SendClientMessage(playerid, COLOUR_SYSTEM, "запрещённые коды, или знак процентов, или ~ .");
				return 1;
			}
			if(strlen(inputtext) > MAX_HOUSE_PASSWORD || (strlen(inputtext) < MIN_HOUSE_PASSWORD && strlen(inputtext) >= 1)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_INVALID_HPASS_LENGTH);
			if(strcmp(inputtext, "INVALID_HOUSE_PASSWORD", CASE_SENSETIVE) == 0 && strlen(inputtext) >= 1) return SendClientMessage(playerid, COLOUR_SYSTEM, E_INVALID_HPASS);
			else
			{
			    if(strlen(inputtext) >= 1)
			    {
					if(strcmp(parloc, "INVALID_HOUSE_PASSWORD", false) == 0)
					{
						ShowInfoBox(playerid, INFORMATION_HEADER, I_HPASSWORD_CHANGED, inputtext);
	                    #if defined GH_DEBUGGING
	  						printf("[GarHouse] %s [%d] создал пароль для дома ID %d (%s) .", pNick(playerid), playerid, h, inputtext);
		    			#endif
					}
					else
					{
						if(strcmp(inputtext, parloc, false) == 0)
						{
							SendClientMessage(playerid, COLOUR_INFO, I_HPASS_NO_CHANGE);
							return 1;
						}
						else
						{
							ShowInfoBox(playerid, INFORMATION_HEADER, "Вы успешно изменили пароль для дома на \"%s\"!", inputtext);
		                    #if defined GH_DEBUGGING
		  						printf(DEBUG_ODR14, pNick(playerid), playerid, h, inputtext, parloc);
			    			#endif
						}
					}
					dini_Set(file, "HousePassword", inputtext);//пароль без хэш-шифрования
//					dini_IntSet(file, "HousePassword", udb_hash(inputtext));
				}
				else
				{
					SendClientMessage(playerid, COLOUR_INFO, I_HPASS_NO_CHANGE);
					return 1;
				}
			}
		}
		if(!response)
		{
			if(strcmp(parloc, "INVALID_HOUSE_PASSWORD", false) != 0)
			{
			    dini_Set(file, "HousePassword", "INVALID_HOUSE_PASSWORD");
				SendClientMessage(playerid, COLOUR_INFO, I_HPASS_REMOVED);
				#if defined GH_DEBUGGING
					printf("[GarHouse] %s [%d] удалил пароль дома ID %d .", pNick(playerid), playerid, h);
				#endif
			}
		}
		return 1;
	}
//------------------------------------------------------------------------------
//                               House Name
//------------------------------------------------------------------------------
	if(dialogid == 514)
	{
		if(dialogid != dlgcont[playerid])
		{
			dlgcont[playerid] = -600;//не существующий ИД диалога
			return 1;
		}
		dlgcont[playerid] = -600;//не существующий ИД диалога
		if(response)
		{
			new parloc[128];
			format(parloc, sizeof(parloc), "%s", dini_Get(file, "HouseName"));
			if(InpTxtControl(inputtext) == 0)
			{
				SendClientMessage(playerid, COLOUR_SYSTEM, "Ваше имя дома содержит недопустимые символы:");
				SendClientMessage(playerid, COLOUR_SYSTEM, "запрещённые коды, или знак процентов, или ~ .");
				return 1;
			}
			if(strlen(inputtext) < MIN_HOUSE_NAME || strlen(inputtext) > MAX_HOUSE_NAME) return SendClientMessage(playerid, COLOUR_SYSTEM, E_INVALID_HNAME_LENGTH);
			else
			{
				if(strcmp(inputtext, parloc, false) == 0)
				{
					SendClientMessage(playerid, COLOUR_INFO, "Имя дома осталось без изменений.");
					return 1;
				}
				else
				{
					dini_Set(file, "HouseName", inputtext);
					SendMSG(playerid, COLOUR_INFO, 128, I_HNAME_CHANGED, inputtext);
	                UpdateHouseText(h);
	                #if defined GH_DEBUGGING
						printf(DEBUG_ODR2, pNick(playerid), playerid, h, inputtext);
	  				#endif
				}
			}
		}
		return 1;
	}
//------------------------------------------------------------------------------
//                       House Interior Upgrade
//------------------------------------------------------------------------------
	if(dialogid == 515)
	{
		if(dialogid != dlgcont[playerid])
		{
			dlgcont[playerid] = -600;//не существующий ИД диалога
			return 1;
		}
		dlgcont[playerid] = -600;//не существующий ИД диалога
		if(response)
		{
		    SetPVarInt(playerid, "OldHouseInt", dini_Int(file, "HouseInterior"));
			switch(listitem)
			{
			    case 0:
				{
	 		    	SetPVarInt(playerid, "HousePrevInt", 1);
					SetPVarInt(playerid, "HousePrevValue", H_INT_1_VALUE);
					SetPVarString(playerid, "HousePrevName", "Shitty Shack");
				}
				case 1:
				{
				    SetPVarInt(playerid, "HousePrevInt", 2);
					SetPVarInt(playerid, "HousePrevValue", H_INT_2_VALUE);
					SetPVarString(playerid, "HousePrevName", "Motel Room");
				}
				case 2:
				{
	 		    	SetPVarInt(playerid, "HousePrevInt", 3);
					SetPVarInt(playerid, "HousePrevValue", H_INT_3_VALUE);
					SetPVarString(playerid, "HousePrevName", "Hotel Room 1");
				}
				case 3:
				{
				    SetPVarInt(playerid, "HousePrevInt", 4);
					SetPVarInt(playerid, "HousePrevValue", H_INT_4_VALUE);
					SetPVarString(playerid, "HousePrevName", "Hotel Room 2");
				}
				case 4:
				{
				    SetPVarInt(playerid, "HousePrevInt", 5);
					SetPVarInt(playerid, "HousePrevValue", H_INT_5_VALUE);
					SetPVarString(playerid, "HousePrevName", "Gang House");
				}
				case 5:
				{
				    SetPVarInt(playerid, "HousePrevInt", 6);
					SetPVarInt(playerid, "HousePrevValue", H_INT_6_VALUE);
					SetPVarString(playerid, "HousePrevName", "Normal House");
				}
				case 6:
				{
				    SetPVarInt(playerid, "HousePrevInt", 0);
					SetPVarInt(playerid, "HousePrevValue", H_INT_0_VALUE);
					SetPVarString(playerid, "HousePrevName", "Default House");
				}
				case 7:
				{
				    SetPVarInt(playerid, "HousePrevInt", 7);
					SetPVarInt(playerid, "HousePrevValue", H_INT_7_VALUE);
					SetPVarString(playerid, "HousePrevName", "Medium Mansion");
				}
				case 8:
				{
				    SetPVarInt(playerid, "HousePrevInt", 8);
					SetPVarInt(playerid, "HousePrevValue", H_INT_8_VALUE);
					SetPVarString(playerid, "HousePrevName", "Rich Mansion");
				}
				case 9:
				{
				    SetPVarInt(playerid, "HousePrevInt", 9);
					SetPVarInt(playerid, "HousePrevValue", H_INT_9_VALUE);
					SetPVarString(playerid, "HousePrevName", "Huge Mansion");
				}
				case 10:
				{
				    SetPVarInt(playerid, "HousePrevInt", 10);
					SetPVarInt(playerid, "HousePrevValue", H_INT_10_VALUE);
					SetPVarString(playerid, "HousePrevName", "Madd Dogg's Mansion");
				}
			}
			if(dini_Int(file, "HouseInterior") == GetPVarInt(playerid, "HousePrevInt")) return SendClientMessage(playerid, COLOUR_SYSTEM, E_ALREADY_HAVE_HINTERIOR);
			else
			{
			    GetPVarString(playerid, "HousePrevName", string, 50);
//------------------------------------------------------------------------------
			    switch(GetPVarInt(playerid, "HouseIntUpgradeMod"))
			    {
					case 1:
					{
//				    	if(GetSecondsBetweenAction(GetPVarInt(playerid, "HousePrevTime")) < (TIME_BETWEEN_VISITS * 1000) && GetPVarInt(playerid, "HousePrevTime") != 0) return SendClientMessage(playerid, COLOUR_SYSTEM, E_HINT_WAIT_BEFORE_VISITING);
//				    	else
//				    	{

							SetPVarInt(playerid, "HousePrevTime", 1);//включаем блокировку меню дома
					        SetPVarInt(playerid, "IsHouseVisiting", 1);
							SetPVarInt(playerid, "HousePreview", 1);
							SetPVarInt(playerid, "ChangeHouseInt", 1);
//							SetPVarInt(playerid, "HousePrevTime", GetTickCount());
							SetPVarInt(playerid, "HousePrevTimer", SetTimerEx("HouseVisiting", (MAX_VISIT_TIME * 1000), false, "i", playerid));
							ShowInfoBox(playerid, INFORMATION_HEADER, I_VISITING_HOUSEINT, string, GetPVarInt(playerid, "HousePrevValue"), MAX_VISIT_TIME, AddS(MAX_VISIT_TIME));
		                    #if defined GH_DEBUGGING
								printf(DEBUG_ODR4, pNick(playerid), playerid, string, h);
		  					#endif
//  					}
					}
					case 2:
					{
						if(GetPVarInt(playerid, "HousePrevValue") > GetPlayerMoney(playerid))
						{
	                        ShowInfoBox(playerid, INFORMATION_HEADER, E_CANT_AFFORD_HINT, string, GetPVarInt(playerid, "HousePrevValue"), GetPlayerMoney(playerid), (GetPVarInt(playerid, "HousePrevValue") - GetPlayerMoney(playerid)));
						}
						if(GetPVarInt(playerid, "HousePrevValue") <= GetPlayerMoney(playerid))
						{
							new para1;
							para1 = GetPlayerMoney(playerid);
							SetPVarInt(playerid, "MonControl", 1);
						    GivePlayerMoney(playerid, - GetPVarInt(playerid, "HousePrevValue"));
						    SetPVarInt(playerid, "ChangeHouseInt", 1);
						    dini_IntSet(file, "HouseInteriorValue", GetPVarInt(playerid, "HousePrevValue"));
							ShowInfoBox(playerid, INFORMATION_HEADER, I_HINT_BOUGHT, string, GetPVarInt(playerid, "HousePrevValue"));
	                        #if defined GH_DEBUGGING
								printf(DEBUG_ODR3, pNick(playerid), playerid, string, GetPVarInt(playerid, "HousePrevValue"), h);
	  						#endif
							printf("[moneysys] Предыдущая сумма игрока %s [%d] : %d $", pNick(playerid), playerid, para1);
						}
					}
				}
//------------------------------------------------------------------------------
				if(GetPVarInt(playerid, "ChangeHouseInt") == 1)
			    {
					if(GetPVarInt(playerid, "HouseIntUpgradeMod") == 2)
					{
						new locdata[128];
            			GetPVarString(playerid, "HousePrevName", locdata, 128);
						dini_IntSet(file, "HouseInterior", GetPVarInt(playerid, "HousePrevInt"));
				    	dini_IntSet(file, "HouseInteriorValue", GetPVarInt(playerid, "HousePrevValue"));
		            	dini_Set(file, "HouseInteriorName", locdata);
					}
				    SetPVarInt(playerid, "ChangeHouseInt", 0);
				    DestroyHouseEntrance(h, TYPE_INT);
					if(GetPVarInt(playerid, "HouseIntUpgradeMod") == 1)
					{
						CreateCorrectHouseExitCP22(playerid, h);
						Loop(i, MAX_PLAYERS)
				  		{
				  		    if(GetPVarInt(i, "LastHouseCP") == h && GetPVarInt(i, "IsInHouse") == 1)
				  		    {
				  				SetPlayerHouseInterior22(i, h);
				  			}
				  		}
					}
					if(GetPVarInt(playerid, "HouseIntUpgradeMod") == 2)
					{
						CreateCorrectHouseExitCP(h);
						Loop(i, MAX_PLAYERS)
				  		{
				  		    if(GetPVarInt(i, "LastHouseCP") == h && GetPVarInt(i, "IsInHouse") == 1)
				  		    {
				  				SetPlayerHouseInterior(i, h);
				  			}
				  		}
					}
			  		#if defined GH_DEBUGGING
						if(GetPVarInt(playerid, "HouseIntUpgradeMod") == 2)
						{
							printf(DEBUG_ODR5, h, GetPVarInt(playerid, "HousePrevInt"));
						}
					#endif
		  		}
				if(GetPVarInt(playerid, "HouseIntUpgradeMod") == 2)
				{
					SetPVarInt(playerid, "HouseIntUpgradeMod", 0);
				}
//------------------------------------------------------------------------------
			}
		}
		return 1;
	}
//------------------------------------------------------------------------------
//                       House Interior Mode Selecting
//------------------------------------------------------------------------------
    #if defined GH_HINTERIOR_UPGRADE
	if(dialogid == 516)
	{
		if(dialogid != dlgcont[playerid])
		{
			dlgcont[playerid] = -600;//не существующий ИД диалога
			return 1;
		}
		dlgcont[playerid] = -600;//не существующий ИД диалога
		if(response)
		{
		    switch(listitem)
		    {
		        case 0: SetPVarInt(playerid, "HouseIntUpgradeMod", 1);
		        case 1: SetPVarInt(playerid, "HouseIntUpgradeMod", 2);
		    }
		    format(string, sizeof(string),
			"Shitty Shack Interior\t\t%s\nMotel Room Interior\t\t%s\nHotel Room Interior 1\t\t%s\nHotel Room Interior 2\t\t%s\nGang House Interior\t\t%s\nNormal House Interior\t\t%s\nDefault House Interior\t\t%s\nMedium Mansion Interior\t%s\nRich Mansion Interior\t\t%s\nHuge Mansion Interior\t\t%s\nMadd Dogg's Mansion\t\t%s",
			FM(H_INT_1_VALUE), FM(H_INT_2_VALUE), FM(H_INT_3_VALUE), FM(H_INT_4_VALUE), FM(H_INT_5_VALUE), FM(H_INT_6_VALUE), FM(H_INT_0_VALUE), FM(H_INT_7_VALUE), FM(H_INT_8_VALUE), FM(H_INT_9_VALUE), FM(H_INT_10_VALUE));
			ShowPlayerDialog(playerid, 515, DIALOG_STYLE_LIST, "Интерьер", string, "Купить", "Отмена");
			dlgcont[playerid] = 515;
		}
		return 1;
	}
	#endif
//------------------------------------------------------------------------------
//                       House Interior Upgrade
//------------------------------------------------------------------------------
    #if defined GH_HINTERIOR_UPGRADE
	if(dialogid == 517)
	{
		if(dialogid != dlgcont[playerid])
		{
			dlgcont[playerid] = -600;//не существующий ИД диалога
			return 1;
		}
		dlgcont[playerid] = -600;//не существующий ИД диалога
	    SetPVarInt(playerid, "HousePreview", 0);
	    KillTimer(GetPVarInt(playerid, "HousePrevTimer"));
	    SetPVarInt(playerid, "IsHouseVisiting", 0);
	    if(response)
	    {
            GetPVarString(playerid, "HousePrevName", string, 50);
            if(GetPVarInt(playerid, "PlMon") < GetPVarInt(playerid, "HousePrevValue"))
            {
             	ShowInfoBox(playerid, INFORMATION_HEADER, E_CANT_AFFORD_HINT, string, GetPVarInt(playerid, "HousePrevValue"), GetPVarInt(playerid, "PlMon"), (GetPVarInt(playerid, "HousePrevValue") - GetPVarInt(playerid, "PlMon")));
            }
			else
			{
				new para1;
				para1 = GetPlayerMoney(playerid);
				SetPVarInt(playerid, "MonControl", 1);
            	GivePlayerMoney(playerid, - GetPVarInt(playerid, "HousePrevValue"));
            	dini_Set(file, "HouseInteriorName", string);
		    	dini_IntSet(file, "HouseInterior", GetPVarInt(playerid, "HousePrevInt"));
		    	dini_IntSet(file, "HouseInteriorValue", GetPVarInt(playerid, "HousePrevValue"));
            	ShowInfoBox(playerid, INFORMATION_HEADER, I_HINT_BOUGHT, string, GetPVarInt(playerid, "HousePrevValue"));
                #if defined GH_DEBUGGING
					printf(DEBUG_ODR3, pNick(playerid), playerid, string, GetPVarInt(playerid, "HousePrevValue"), h);

					printf(DEBUG_ODR5, h, GetPVarInt(playerid, "HousePrevInt"));

				#endif
				printf("[moneysys] Предыдущая сумма игрока %s [%d] : %d $", pNick(playerid), playerid, para1);
			}
	    }
//------------------------------------------------------------------------------
  		DestroyHouseEntrance(h, TYPE_INT);
		CreateCorrectHouseExitCP(h);
		Loop(i, MAX_PLAYERS)
		{
  			if(GetPVarInt(i, "LastHouseCP") == h && GetPVarInt(i, "IsInHouse") == 1)
  			{
				SetPlayerHouseInterior(i, h);
			}
		}
//		#if defined GH_DEBUGGING
//			printf(DEBUG_ODR5, h, GetPVarInt(playerid, "HousePrevInt"));
//		#endif
		if(GetPVarInt(playerid, "HouseIntUpgradeMod") == 1)
		{
			SetPVarInt(playerid, "HouseIntUpgradeMod", 0);
		}
//------------------------------------------------------------------------------
		return 1;
	}
	#endif
//------------------------------------------------------------------------------
//                               Money Storage
//------------------------------------------------------------------------------
	if(dialogid == 510)
	{
		if(dialogid != dlgcont[playerid])
		{
			dlgcont[playerid] = -600;//не существующий ИД диалога
			return 1;
		}
		dlgcont[playerid] = -600;//не существующий ИД диалога
		if(response)
		{
		    new tmp = dini_Int(file, "HouseStorage");
	    	if(listitem == 0) // Deposit
		   	{
	     		format(string, sizeof(string), I_HINT_DEPOSIT1, tmp);
	  			ShowPlayerDialog(playerid, 511, DIALOG_STYLE_INPUT, "Хранение денег: положить на хранение", string, "Положить", "Отмена");
				dlgcont[playerid] = 511;
		    }
		    if(listitem == 1) // Withdraw
		    {
	     		format(string, sizeof(string), I_HINT_WITHDRAW1, tmp);
	       		ShowPlayerDialog(playerid, 512, DIALOG_STYLE_INPUT, "Хранение денег: снять с хранения", string, "Снять", "Отмена");
				dlgcont[playerid] = 512;
	    	}
		    if(listitem == 2) // Check Balance
		    {
	     		ShowInfoBox(playerid, INFORMATION_HEADER, I_HINT_CHECKBALANCE, tmp);
	            #if defined GH_DEBUGGING
					printf(DEBUG_ODR6, pNick(playerid), playerid, h, tmp);
				#endif
			}
		}
		return 1;
	}
//------------------------------------------------------------------------------
	if(dialogid == 511)
	{
		if(dialogid != dlgcont[playerid])
		{
			dlgcont[playerid] = -600;//не существующий ИД диалога
			return 1;
		}
		dlgcont[playerid] = -600;//не существующий ИД диалога
		if(response)
		{
			if(InpTxtControl(inputtext) == 0)
			{
				SendClientMessage(playerid, COLOUR_SYSTEM, "Сумма содержит недопустимые символы:");
				SendClientMessage(playerid, COLOUR_SYSTEM, "запрещённые коды, или знак процентов, или ~ .");
				return 1;
			}
		    new amount = floatround(strval(inputtext));
	  		format(file, sizeof(file), FILEPATH, h);
			if(amount > GetPlayerMoney(playerid)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_NOT_ENOUGH_PMONEY);
			if(amount < 1) return SendClientMessage(playerid, COLOUR_SYSTEM, E_INVALID_AMOUNT);
			if((dini_Int(file, "HouseStorage") + amount) > 25000000) return SendClientMessage(playerid, COLOUR_SYSTEM, E_HSTORAGE_L_REACHED);
			else
			{
				dini_IntSet(file, "HouseStorage", (dini_Int(file, "HouseStorage") + amount));
				new para1;
				para1 = GetPlayerMoney(playerid);
				SetPVarInt(playerid, "MonControl", 1);
				GivePlayerMoney(playerid, - amount);
				ShowInfoBox(playerid, INFORMATION_HEADER, I_HINT_DEPOSIT2, amount, dini_Int(file, "HouseStorage"));
	            #if defined GH_DEBUGGING
					printf(DEBUG_ODR7, pNick(playerid), playerid, amount, h);
				#endif
				printf("[moneysys] Предыдущая сумма игрока %s [%d] : %d $", pNick(playerid), playerid, para1);
			}
		}
		return 1;
	}
//------------------------------------------------------------------------------
	if(dialogid == 512)
	{
		if(dialogid != dlgcont[playerid])
		{
			dlgcont[playerid] = -600;//не существующий ИД диалога
			return 1;
		}
		dlgcont[playerid] = -600;//не существующий ИД диалога
		if(response)
		{
			if(InpTxtControl(inputtext) == 0)
			{
				SendClientMessage(playerid, COLOUR_SYSTEM, "Сумма содержит недопустимые символы:");
				SendClientMessage(playerid, COLOUR_SYSTEM, "запрещённые коды, или знак процентов, или ~ .");
				return 1;
			}
		    new amount = floatround(strval(inputtext));
	  		format(file, sizeof(file), FILEPATH, h);
			if(amount > dini_Int(file, "HouseStorage")) return SendClientMessage(playerid, COLOUR_SYSTEM, E_NOT_ENOUGH_HSMONEY);
			if(amount < 1) return SendClientMessage(playerid, COLOUR_SYSTEM, E_INVALID_AMOUNT);
			else
			{
				dini_IntSet(file, "HouseStorage", (dini_Int(file, "HouseStorage") - amount));
				new para1;
				para1 = GetPlayerMoney(playerid);
				SetPVarInt(playerid, "MonControl", 1);
				GivePlayerMoney(playerid, amount);
				ShowInfoBox(playerid, INFORMATION_HEADER, I_HINT_WITHDRAW2, amount, dini_Int(file, "HouseStorage"));
	            #if defined GH_DEBUGGING
					printf(DEBUG_ODR8, pNick(playerid), playerid, amount, h);
				#endif
				printf("[moneysys] Предыдущая сумма игрока %s [%d] : %d $", pNick(playerid), playerid, para1);
			}
		}
		return 1;
	}
//------------------------------------------------------------------------------
//                          House Storage
//------------------------------------------------------------------------------
	if(dialogid == 518)
	{
		if(dialogid != dlgcont[playerid])
		{
			dlgcont[playerid] = -600;//не существующий ИД диалога
			return 1;
		}
		dlgcont[playerid] = -600;//не существующий ИД диалога
		if(response)
		{
			switch(listitem)
			{
			    case 0:
				{
					ShowPlayerDialog(playerid, 510, DIALOG_STYLE_LIST, "Хранение денег", "Положить на хранение\nСнять с хранения\nПроверить сумму", "OK", "Отмена");
					dlgcont[playerid] = 510;
				}
			    case 1:
				{
					ShowPlayerDialog(playerid, 519, DIALOG_STYLE_LIST, "Хренение оружия", "Положить на хранение\nСнять с хранения", "OK", "Отмена");
					dlgcont[playerid] = 519;
				}
			}
		}
		return 1;
	}
//------------------------------------------------------------------------------
//                          Weapon Storage
//------------------------------------------------------------------------------
	if(dialogid == 519)
	{
		if(dialogid != dlgcont[playerid])
		{
			dlgcont[playerid] = -600;//не существующий ИД диалога
			return 1;
		}
		dlgcont[playerid] = -600;//не существующий ИД диалога
		if(response)
		{
		    new WeaponData[13][2], tmp[9], tmp2[13], tmpcount;
			switch(listitem)
			{
			    case 0: // Store weapons
			    {
					Loop(weap, 13)
					{
					    format(tmp, sizeof(tmp), "Weapon%d", weap);
	  					format(tmp2, sizeof(tmp2), "Weapon%dAmmo", weap);
					    if(weap == 0) continue;
					    #if !defined GH_SAVE_ADMINWEPS
					    if(weap == 7 || weap == 8 || weap == 9 || weap == 12) continue;
					    #endif
					    GetPlayerWeaponData(playerid, weap, WeaponData[weap][0], WeaponData[weap][1]);
					    if(WeaponData[weap][1] == 0 || (weap == 11 && WeaponData[weap][0] != 46)) continue;
						dini_IntSet(file, tmp, WeaponData[weap][0]);
						dini_IntSet(file, tmp2, WeaponData[weap][1]);
						GivePlayerWeapon(playerid, WeaponData[weap][0], -WeaponData[weap][1]);
						tmpcount++;
					}
					if(tmpcount >= 1)
					{
						ShowInfoBox(playerid, INFORMATION_HEADER, I_HS_WEAPONS1, tmpcount, AddS(tmpcount));
					}
					if(tmpcount == 0)
					{
						ShowInfoBox(playerid, INFORMATION_HEADER, E_NO_WEAPONS, tmpcount);
					}
		            #if defined GH_DEBUGGING

						printf(DEBUG_ODR10, pNick(playerid), playerid, tmpcount, h);

//						printf(DEBUG_ODR10, pNick(playerid), playerid, tmpcount, AddS(tmpcount), h);
					#endif
				}
				case 1: // Recieve Weapons
				{
					Loop(weap, 13)
					{
					    format(tmp, sizeof(tmp), "Weapon%d", weap);
	  					format(tmp2, sizeof(tmp2), "Weapon%dAmmo", weap);
	  					if(dini_Int(file, tmp2) == 0) continue;
					    if(weap == 0) continue;
					    #if !defined GH_SAVE_ADMINWEPS
					    if(weap == 7 || weap == 8 || weap == 9 || weap == 11 || weap == 12) continue;
					    #endif
						GivePlayerWeapon(playerid, dini_Int(file, tmp), dini_Int(file, tmp2));
						dini_IntSet(file, tmp, 0);
						dini_IntSet(file, tmp2, 0);
						tmpcount++;
					}
					if(tmpcount >= 1)
					{
						ShowInfoBox(playerid, INFORMATION_HEADER, I_HS_WEAPONS2, tmpcount, AddS(tmpcount));
					}
					if(tmpcount == 0)
					{
						ShowInfoBox(playerid, INFORMATION_HEADER, E_NO_HS_WEAPONS, tmpcount); // I had to add tmpcount or it gave an error ^_^
					}
					#if defined GH_DEBUGGING

						printf(DEBUG_ODR11, pNick(playerid), playerid, tmpcount, h);

//						printf(DEBUG_ODR11, pNick(playerid), playerid, tmpcount, AddS(tmpcount), h);
					#endif
				}
			}
		}
		return 1;
	}
//==============================================================================
// пустой диалог
//==============================================================================
	if(dialogid == 520)
	{
		if(dialogid != dlgcont[playerid])
		{
			dlgcont[playerid] = -600;//не существующий ИД диалога
			return 1;
		}
		dlgcont[playerid] = -600;//не существующий ИД диалога
		return 1;
	}
//------------------------------------------------------------------------------
//                          Enter House Using Password
//------------------------------------------------------------------------------
	if(dialogid == 521)
	{
		if(dialogid != dlgcont[playerid])
		{
			dlgcont[playerid] = -600;//не существующий ИД диалога
			return 1;
		}
		dlgcont[playerid] = -600;//не существующий ИД диалога

		lockpas[playerid] = 0;//разблокировать диалог ввода пароля

		if(response)
		{
		    format(file, sizeof(file), FILEPATH, h);
			if(InpTxtControl(inputtext) == 0)
			{
				SendClientMessage(playerid, COLOUR_SYSTEM, "Пароль содержит недопустимые символы:");
				SendClientMessage(playerid, COLOUR_SYSTEM, "запрещённые коды, или знак процентов, или ~ .");
				return 1;
			}
		    if(strlen(inputtext) < MIN_HOUSE_PASSWORD || strlen(inputtext) > MAX_HOUSE_PASSWORD) return SendClientMessage(playerid, COLOUR_SYSTEM, E_INVALID_HPASS_LENGTH);
			if(strcmp(dini_Get(file, "HousePassword"), inputtext, false) != 0)//пароль без хэш-шифрования
//			if(udb_hash(inputtext) != dini_Int(file, "HousePassword"))
			{
				ShowInfoBox(playerid, INFORMATION_HEADER, I_WRONG_HPASS1, GetHouseOwner(GetPVarInt(playerid, "LastHouseCP")), inputtext);
				if(IsPlayerConnected(GetHouseOwnerEx(GetPVarInt(playerid, "LastHouseCP"))))
				{
					SendMSG(GetHouseOwnerEx(h), COLOUR_INFO, 128, I_WRONG_HPASS2, pNick(playerid), playerid, inputtext);
    			}
			}
			else
			{
				ShowInfoBox(playerid, INFORMATION_HEADER, I_CORRECT_HPASS1, GetHouseOwner(GetPVarInt(playerid, "LastHouseCP")), inputtext);
				SetPVarInt(playerid, "IsInHouse", 1);
				SetPlayerHouseInterior(playerid, GetPVarInt(playerid, "LastHouseCP"));
				if(IsPlayerConnected(GetHouseOwnerEx(GetPVarInt(playerid, "LastHouseCP"))))
				{
					SendMSG(GetHouseOwnerEx(h), COLOUR_INFO, 128, I_CORRECT_HPASS2, pNick(playerid), playerid, inputtext);
				}
				#if defined GH_DEBUGGING
					printf(DEBUG_ODR12, pNick(playerid), playerid, h);
				#endif
			}
		}
		return 1;
	}
	return 0; // It is important to have return 0; here at the end of ALL your scripts wich uses dialogs.
}
//==============================================================================
// GetPosInFrontOfPlayer(playerid, &Float:x, &Float:y, Float:distance);
// Used to get the position infront of a player.
// Credits to whoever made this!
//==============================================================================
stock Float:GetPosInFrontOfPlayer(playerid, &Float:x, &Float:y, Float:distance)
{
	new Float:a;
	GetPlayerPos(playerid, x, y, a);
	if (IsPlayerInAnyVehicle(playerid)) GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
	else GetPlayerFacingAngle(playerid, a);
	x += (distance * floatsin(-a, degrees));
	y += (distance * floatcos(-a, degrees));
	return a;
}
//##############################################################################
// 								Commands
//##############################################################################
// 							  By [03]Garsino!
//==============================================================================
// This command is used to display the house owner menu
// when a player is in a house and is the house owner.
//==============================================================================
dcmd_housemenu(playerid, params[])
{
	#pragma unused params

	if(GetPVarInt(playerid, "HousePrevTime") != 0) return SendClientMessage(playerid, COLOUR_SYSTEM, "Сейчас Вы не можете использовать меню дома.");//сообщение о запрете меню

 	if(strcmp(GetHouseOwner(GetPVarInt(playerid, "LastHouseCP")), pNick(playerid), CASE_SENSETIVE) && GetPVarInt(playerid, "IsInHouse") == 1) return SendClientMessage(playerid, COLOUR_SYSTEM, E_C_ACCESS_SE_HM);
	if(GetPVarInt(playerid, "IsInHouse") == 0) return SendClientMessage(playerid, COLOUR_SYSTEM, E_NOT_IN_HOUSE);
	if(GetOwnedHouses(playerid) == 0) return SendClientMessage(playerid, COLOUR_SYSTEM, E_NOT_HOWNER);
	if(GetPVarInt(playerid, "IsInHouse") == 1 && !strcmp(GetHouseOwner(GetPVarInt(playerid, "LastHouseCP")), pNick(playerid), CASE_SENSETIVE) && GetOwnedHouses(playerid) >= 1)
	{
	    #if defined GH_HINTERIOR_UPGRADE
			ShowPlayerDialog(playerid, 500, DIALOG_STYLE_LIST, "Меню дома", "Продажа дома\nХранение в доме\nИмя дома\nПароль для дома\nИнтерьер", "OK", "Отмена");
			dlgcont[playerid] = 500;
		#endif
		#if !defined GH_HINTERIOR_UPGRADE
			ShowPlayerDialog(playerid, 500, DIALOG_STYLE_LIST, "Меню дома", "Продажа дома\nХранение в доме\nИмя дома\nПароль для дома", "OK", "Отмена");
			dlgcont[playerid] = 500;
		#endif
	}
	return 1;
}
//==============================================================================
// This command is used to create a house.
// The only thing you have to enter is the house value,
// the rest is done by the script.
//==============================================================================
dcmd_createhouse(playerid, params[])
{
	new cost, file[HOUSEFILE_LENGTH], h = GetFreeHouseID(), labeltext[150], hinterior;
	if(!IsPlayerAdmin(playerid)) return 0;
	if(sscanf(params, "dD(" #DEFAULT_H_INTERIOR ")", cost, hinterior)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_CMD_USAGE_CREATEHOUSE);
	if(hinterior > 10)
	{
		hinterior = 0;
	}
	if(h < 0)
	{
		ShowInfoBox(playerid, INFORMATION_HEADER, E_TOO_MANY_HOUSES, MAX_HOUSES - 1);
    	return 1;
	}
	if(cost < MIN_HOUSE_VALUE || cost > MAX_HOUSE_VALUE) return SendClientMessage(playerid, COLOUR_SYSTEM, E_INVALID_HVALUE);
	else
	{
		new dvw;
		dvw = GetPlayerVirtualWorld(playerid);
	    format(file, sizeof(file), FILEPATH, h);
	    dini_Create(file);
		GetPlayerPos(playerid, X, Y, Z);
		GetPlayerFacingAngle(playerid, Angle);
		dini_FloatSet(file, "CPOutX", X);
		dini_FloatSet(file, "CPOutY", Y);
		dini_FloatSet(file, "CPOutZ", Z);
		dini_Set(file, "HouseName", DEFAULT_HOUSE_NAME);
		dini_Set(file, "HouseOwner", INVALID_HOWNER_NAME);
		dini_Set(file, "HousePassword", "INVALID_HOUSE_PASSWORD");
		dini_Set(file, "HouseCreator", pNick(playerid));
		dini_IntSet(file, "HouseValue", cost);
		dini_IntSet(file, "HouseStorage", 0);
		CallRemoteFunction("GPSrfun", "iiisifff", 1, 1, h, "*** INV_PL_ID", dvw, X, Y, Z);
		format(labeltext, sizeof(labeltext), LABELTEXT1, DEFAULT_HOUSE_NAME, cost, h);
		#if defined GH_USE_CPS
			HouseCPOut[h] = CreateDynamicCP(X, Y, Z, 1.5, dvw, GetPlayerInterior(playerid), -1, 25.0);
			HouseCPInt[h] = CreateDynamicCP(2196.84, -1204.36, 1049.02, 1.5, (h + 1000), 6, -1, 100.0);
		#endif
		#if !defined GH_USE_CPS
			HousePickupOut[h] = CreateDynamicPickup(PICKUP_MODEL_OUT, PICKUP_TYPE, X, Y, Z, dvw, GetPlayerInterior(playerid), -1, 15.0);
//			HousePickupInt[h] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 2196.84, -1204.36, 1049.02, (h + 1000), 6, -1, 15.0);
		#endif
		#if defined GH_USE_MAPICONS
 			HouseMIcon[h] = CreateDynamicMapIcon(X, Y, Z, 31, -1, dvw, GetPlayerInterior(playerid), -1, MICON_VD);
	 	#endif
		HouseLabel[h] = CreateDynamic3DTextLabel(labeltext, COLOUR_GREEN, X, Y, Z+0.7, 25, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, dvw, GetPlayerInterior(playerid), -1);
		SendMSG(playerid, COLOUR_YELLOW, 128, I_H_CREATED, h);
		GetPosInFrontOfPlayer(playerid, X, Y, -2.5);
		dini_FloatSet(file, "SpawnOutX", X);
		dini_FloatSet(file, "SpawnOutY", Y);
		dini_FloatSet(file, "SpawnOutZ", Z);
		dini_FloatSet(file, "SpawnOutAngle", floatround((180 + Angle)));
		dini_IntSet(file, "SpawnWorld", dvw);
		dini_IntSet(file, "SpawnInterior", GetPlayerInterior(playerid));
		dini_IntSet(file, "HouseInterior", hinterior);
	#if defined GH_USE_CPS
		switch(hinterior)
		{
		    case 1:
			{
				dini_IntSet(file, "HouseInteriorValue", H_INT_1_VALUE);
				dini_Set(file, "HouseInteriorName", "Shitty Shack");
				HouseCPInt[h] = CreateDynamicCP(2259.38, -1135.89, 1050.64, 1.50, (h + 1000), 10, -1, 10.0);
			}
			case 2:
			{
				dini_IntSet(file, "HouseInteriorValue", H_INT_2_VALUE);
				dini_Set(file, "HouseInteriorName", "Motel Room");
				HouseCPInt[h] = CreateDynamicCP(2282.99, -1140.28, 1050.89, 1.50, (h + 1000), 11, -1, 10.0);
			}
			case 3:
			{
				dini_IntSet(file, "HouseInteriorValue", H_INT_3_VALUE);
				dini_Set(file, "HouseInteriorName", "Hotel Room 1");
				HouseCPInt[h] = CreateDynamicCP(2233.69, -1115.26, 1050.88, 1.50, (h + 1000), 5, -1, 10.0);
			}
			case 4:
			{
				dini_IntSet(file, "HouseInteriorValue", H_INT_4_VALUE);
				dini_Set(file, "HouseInteriorName", "Hotel Room 2");
				HouseCPInt[h] = CreateDynamicCP(2218.39, -1076.21, 1050.48, 1.50, (h + 1000), 1, -1, 10.0);
			}
			case 5:
			{
				dini_IntSet(file, "HouseInteriorValue", H_INT_5_VALUE);
				dini_Set(file, "HouseInteriorName", "Gang House");
				HouseCPInt[h] = CreateDynamicCP(2496.00, -1692.08, 1014.74, 1.50, (h + 1000), 3, -1, 10.0);
			}
			case 6:
			{
				dini_IntSet(file, "HouseInteriorValue", H_INT_6_VALUE);
				dini_Set(file, "HouseInteriorName", "Normal House");
				HouseCPInt[h] = CreateDynamicCP(2365.25, -1135.58, 1050.88, 1.50, (h + 1000), 8, -1, 10.0);
			}
			case 0:
			{
				dini_IntSet(file, "HouseInteriorValue", H_INT_0_VALUE);
				dini_Set(file, "HouseInteriorName", "Default House");
				HouseCPInt[h] = CreateDynamicCP(2196.84, -1204.36, 1049.02, 1.5, (h + 1000), 6, -1, 10.0);
			}
			case 7:
			{
				dini_IntSet(file, "HouseInteriorValue", H_INT_7_VALUE);
				dini_Set(file, "HouseInteriorName", "Medium Mansion");
				HouseCPInt[h] = CreateDynamicCP(2317.77, -1026.76, 1050.21, 1.50, (h + 1000), 9, -1, 10.0);
			}
			case 8:
			{
				dini_IntSet(file, "HouseInteriorValue", H_INT_8_VALUE);
				dini_Set(file, "HouseInteriorName", "Rich Mansion");
				HouseCPInt[h] = CreateDynamicCP(2324.41, -1149.54, 1050.71, 1.50, (h + 1000), 12, -1, 10.0);
			}
			case 9:
			{
				dini_IntSet(file, "HouseInteriorValue", H_INT_9_VALUE);
				dini_Set(file, "HouseInteriorName", "Huge Mansion");
				HouseCPInt[h] = CreateDynamicCP(140.28, 1365.92, 1083.85, 1.50, (h + 1000), 5, -1, 10.0);
			}
			case 10:
			{
			    dini_IntSet(file, "HouseInteriorValue", H_INT_10_VALUE);
				dini_Set(file, "HouseInteriorName", "Mad Dogg's Mansion");
				HouseCPInt[h] = CreateDynamicCP(1260.6603, -785.4005, 1091.9063, 1.50, (h + 1000), 5, -1, 10.0);
			}
		}
	#endif
	#if !defined GH_USE_CPS
		switch(hinterior)
		{
		    case 1:
			{
				dini_IntSet(file, "HouseInteriorValue", H_INT_1_VALUE);
				dini_Set(file, "HouseInteriorName", "Shitty Shack");
				HousePickupInt[h] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 2260.38, -1135.89, 1050.64, (h + 1000), 10, -1, 15.0);
			}
			case 2:
			{
				dini_IntSet(file, "HouseInteriorValue", H_INT_2_VALUE);
				dini_Set(file, "HouseInteriorName", "Motel Room");
				HousePickupInt[h] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 2284.24, -1139.42, 1050.89, (h + 1000), 11, -1, 15.0);
			}
			case 3:
			{
				dini_IntSet(file, "HouseInteriorValue", H_INT_3_VALUE);
				dini_Set(file, "HouseInteriorName", "Hotel Room 1");
				HousePickupInt[h] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 2233.69, -1114.26, 1050.88, (h + 1000), 5, -1, 15.0);
			}
			case 4:
			{
				dini_IntSet(file, "HouseInteriorValue", H_INT_4_VALUE);
				dini_Set(file, "HouseInteriorName", "Hotel Room 2");
				HousePickupInt[h] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 2216.39, -1077.10, 1050.48, (h + 1000), 1, -1, 15.0);
			}
			case 5:
			{
				dini_IntSet(file, "HouseInteriorValue", H_INT_5_VALUE);
				dini_Set(file, "HouseInteriorName", "Gang House");
				HousePickupInt[h] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 2496.00, -1693.70, 1014.74, (h + 1000), 3, -1, 15.0);
			}
			case 6:
			{
				dini_IntSet(file, "HouseInteriorValue", H_INT_6_VALUE);
				dini_Set(file, "HouseInteriorName", "Normal House");
				HousePickupInt[h] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 2365.25, -1134.00, 1050.88, (h + 1000), 8, -1, 15.0);
			}
			case 0:
			{
				dini_IntSet(file, "HouseInteriorValue", H_INT_0_VALUE);
				dini_Set(file, "HouseInteriorName", "Default House");
				HousePickupInt[h] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 2195.84, -1204.36, 1049.02, (h + 1000), 6, -1, 15.0);
			}
			case 7:
			{
				dini_IntSet(file, "HouseInteriorValue", H_INT_7_VALUE);
				dini_Set(file, "HouseInteriorName", "Medium Mansion");
				HousePickupInt[h] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 2319.43, -1026.33, 1050.21, (h + 1000), 9, -1, 15.0);
			}
			case 8:
			{
				dini_IntSet(file, "HouseInteriorValue", H_INT_8_VALUE);
				dini_Set(file, "HouseInteriorName", "Rich Mansion");
				HousePickupInt[h] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 2324.41, -1148.54, 1050.71, (h + 1000), 12, -1, 15.0);
			}
			case 9:
			{
				dini_IntSet(file, "HouseInteriorValue", H_INT_9_VALUE);
				dini_Set(file, "HouseInteriorName", "Huge Mansion");
				HousePickupInt[h] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 143.40, 1366.66, 1083.85, (h + 1000), 5, -1, 15.0);
			}
			case 10:
			{
			    dini_IntSet(file, "HouseInteriorValue", H_INT_10_VALUE);
				dini_Set(file, "HouseInteriorName", "Mad Dogg's Mansion");
				HousePickupInt[h] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 1263.11, -785.26, 1091.9063, (h + 1000), 5, -1, 15.0);
			}
		}
	#endif
		dini_IntSet("/GarHouse/House.ini", "CurrentID", dini_Int("/GarHouse/House.ini", "CurrentID") + 1);
		dini_IntSet("/GarHouse/House.ini", "CurrentWorld", dini_Int("/GarHouse/House.ini", "CurrentID") + 1000);
		SetPVarInt(playerid, "JustCreatedHouse", 1);
		#if defined GH_DEBUGGING
			printf(DEBUG_OP_CMD1, pNick(playerid), playerid, h, cost, GetTotalHouses());
		#endif
	}
    return 1;
}
//==============================================================================
// просмотр пароля дома.
//==============================================================================
dcmd_passhouse(playerid, params[])
{
	if(IsPlayerAdmin(playerid))
	{
		new file[HOUSEFILE_LENGTH], h;
		if(sscanf(params, "d", h))
		{
			SendClientMessage(playerid, 0xBFC0C2FF, " Используйте: /passhouse [ид дома]");
			return 1;
		}
    	format(file, sizeof(file), FILEPATH, h);
		if(!dini_Exists(file)) return SendClientMessage(playerid, 0xFF0000FF, " Дома с таким ID не существует !");
		new para1 = 0, para2 = 0, strloc[128];
		if(!strcmp(dini_Get(file, "HouseOwner"), INVALID_HOWNER_NAME, CASE_SENSETIVE)) { para1 = 1; }
		if(!strcmp(dini_Get(file, "HouseOwner"), "* Дом заблокирован", CASE_SENSETIVE)) { para1 = 2; }
		format(strloc, sizeof(strloc), "%s", dini_Get(file, "HousePassword"));
		if(strcmp(strloc, "INVALID_HOUSE_PASSWORD", false) == 0) { para2 = 1; }
		new string[256];
		if(para2 == 1)
		{
			format(string, sizeof(string), "Дом ID %d  {FFFFFF}пароль НЕ создан.", h);
		}
		else
		{
			format(string, sizeof(string), "Дом ID %d  {FFFFFF}пароль: %s .", h, strloc);
		}
		SendClientMessage(playerid, 0xFFFF00FF, string);
		if(para1 == 1)
		{
			format(string, sizeof(string), "Дом ID %d  {FFFFFF}свободен.", h);
			SendClientMessage(playerid, 0xFFFF00FF, string);
		}
		if(para1 == 2)
		{
			format(string, sizeof(string), "Дом ID %d  {FFFFFF}заблокирован !", h);
			SendClientMessage(playerid, 0xFFFF00FF, string);
		}
		new sendername[MAX_PLAYER_NAME];
		GetPlayerName(playerid, sendername, sizeof(sendername));
		format(string, sizeof(string), " *** Админ %s [%d] просмотрел пароль дома ID %d .", sendername, playerid, h);
		print(string);
	}
	else
	{
		SendClientMessage(playerid, 0xFF0000FF, " У Вас нет прав на использование этой команды !");
	}
    return 1;
}
//==============================================================================
// перезагрузка системы домов.
//==============================================================================
dcmd_relhouses(playerid, params[])
{
	#pragma unused params
	if(IsPlayerAdmin(playerid))
	{
		new string[256];
		new sendername[MAX_PLAYER_NAME];
		GetPlayerName(playerid, sendername, sizeof(sendername));
		format(string, sizeof(string), " *** Админ %s [%d] начал перезагрузку системы домов.", sendername, playerid);
		print(string);
		SendClientMessageToAll(0xFF0000FF, string);
		SetTimerEx("relhoyses1", 1000, 0, "i", playerid);
	}
	else
	{
		SendClientMessage(playerid, 0xFF0000FF, " У Вас нет прав на использование этой команды !");
	}
    return 1;
}
forward relhoyses1(playerid);
public relhoyses1(playerid)
{
	new file[HOUSEFILE_LENGTH], tmp;
	Loop(i, MAX_PLAYERS)
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
 		{
  			tmp = GetPVarInt(i, "LastHouseCP");
			format(file, sizeof(file), FILEPATH, tmp);
  			if(!strcmp(GetHouseOwner(tmp), pNick(i), CASE_SENSETIVE) && GetPVarInt(i, "IsInHouse") == 1 && dini_Exists(file))
			{
  				dini_IntSet(file, "QuitInHouse", 1);
	    		#if defined GH_HOUSECARS
	    			SaveHouseCar(tmp);
       			#endif
			}
		}
	}
	UnloadHouses(); // Выгрузка домов (также разгружает дом автомобили)
	SetTimerEx("relhoyses2", 1000, 0, "i", playerid);
    return 1;
}
forward relhoyses2(playerid);
public relhoyses2(playerid)
{
	for(new i = 0; i < MAX_PLAYERS; i++)//цикл для всех игроков
	{
		dlgcont[i] = -600;//не существующий ИД диалога
		lockpas[i] = 0;//обнуление массива блокировок диалога ввода пароля
	}

    LoadHouses(); // Загрузка фс дома
    Loop(i, MAX_PLAYERS)
    {
        if(IsPlayerConnected(i) && !IsPlayerNPC(i))
        {
            SetPVarInt(i, "HousePrevTime", 0);
        }
    }
	SetTimerEx("relhoyses3", 1000, 0, "i", playerid);
    return 1;
}
forward relhoyses3(playerid);
public relhoyses3(playerid)
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			TogglePlayerControllable(i, 1);//разморозить всех игроков
		}
	}
	new string[256];
	new sendername[MAX_PLAYER_NAME];
	GetPlayerName(playerid, sendername, sizeof(sendername));
	format(string, sizeof(string), " *** Админ %s [%d] перезагрузил систему домов.", sendername, playerid);
	print(string);
	SendClientMessageToAll(0xFF0000FF, string);
    return 1;
}
//==============================================================================
// блокировка дома по его ИД.
//==============================================================================
dcmd_lchouse(playerid, params[])
{
	if(IsPlayerAdmin(playerid))
	{
		new file[HOUSEFILE_LENGTH], h;
		if(sscanf(params, "d", h))
		{
			SendClientMessage(playerid, 0xBFC0C2FF, " Используйте: /lchouse [ид дома]");
			SendClientMessage(playerid, 0xFF0000FF, " Внимание !!! Команда блокирует дом по его ID !!!");
			SendClientMessage(playerid, 0xFF0000FF, " Используйте только в КРАЙНЕМ случае !!!");
			return 1;
		}
    	format(file, sizeof(file), FILEPATH, h);
		if(!dini_Exists(file)) return SendClientMessage(playerid, 0xFF0000FF, " Дома с таким ID не существует !");
		if(!strcmp(dini_Get(file, "HouseOwner"), INVALID_HOWNER_NAME, CASE_SENSETIVE)) return SendClientMessage(playerid, 0xFF0000FF, " Нельзя ! Дом свободен !");
		if(!strcmp(dini_Get(file, "HouseOwner"), "* Дом заблокирован", CASE_SENSETIVE)) return SendClientMessage(playerid, 0xFF0000FF, " Дом уже заблокирован !");
		dini_Set(file, "HouseOwner", "* Дом заблокирован");
		dini_Set(file, "HouseName", "* Дом заблокирован");
		UpdateHouseText(h);
		new string[256];
		new sendername[MAX_PLAYER_NAME];
		GetPlayerName(playerid, sendername, sizeof(sendername));
		format(string, sizeof(string), " *** Админ %s [%d] заблокировал дом ID %d .", sendername, playerid, h);
		print(string);
		SendClientMessageToAll(0xFF0000FF, string);
	}
	else
	{
		SendClientMessage(playerid, 0xFF0000FF, " У Вас нет прав на использование этой команды !");
	}
    return 1;
}
//==============================================================================
// This command is used to add a house car for a house.
// The only thing you have to enter is the house value,
// the rest is done by the script.
//==============================================================================
dcmd_addhcar(playerid, params[])
{
	new file[HOUSEFILE_LENGTH], h;
	if(!IsPlayerAdmin(playerid)) return 0;
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_HCAR_NOT_IN_VEH);
	if(sscanf(params, "d", h)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_CMD_USAGE_ADDHCAR);
	format(file, sizeof(file), FILEPATH, h);
	if(!dini_Exists(file)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_INVALID_HID);
	else
	{
	    if(dini_Int(file, "HCar") == 1) { SendMSG(playerid, COLOUR_YELLOW, 128, I_HCAR_EXIST_ALREADY, h); }
	    if(dini_Int(file, "HCar") == 0) { SendMSG(playerid, COLOUR_YELLOW, 128, I_HCAR_CREATED, h); }
		GetVehiclePos(GetPlayerVehicleID(playerid), X, Y, Z);
		GetVehicleZAngle(GetPlayerVehicleID(playerid), Angle);
		dini_FloatSet(file, "HCarPosX", X);
		dini_FloatSet(file, "HCarPosY", Y);
		dini_FloatSet(file, "HCarPosZ", Z);
		dini_FloatSet(file, "HCarAngle", Angle);
		dini_IntSet(file, "HCar", 1);
		dini_IntSet(file, "HCarWorld", GetPlayerVirtualWorld(playerid));
		dini_IntSet(file, "HCarInt", GetPlayerInterior(playerid));
		dini_IntSet(file, "HCarModel", GetVehicleModel(GetPlayerVehicleID(playerid)));
		#if defined GH_DEBUGGING
			printf(DEBUG_OP_CMD2, pNick(playerid), playerid, h);
		#endif
	}
    return 1;
}
//==============================================================================
// This command is used to delete a house.
// Note: It does not give any money to the house owner when the house is deleted
//==============================================================================
dcmd_removehouse(playerid, params[])
{
	new h, file[HOUSEFILE_LENGTH];
	if(!IsPlayerAdmin(playerid)) return 0;
	if(sscanf(params, "d", h)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_CMD_USAGE_REMOVEHOUSE);
    format(file, sizeof(file), FILEPATH, h);
	if(!dini_Exists(file)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_INVALID_HID);
	else
	{
     	DestroyHouseEntrance(h, TYPE_OUT);
	    DestroyHouseEntrance(h, TYPE_INT);
	    #if defined GH_USE_MAPICONS
			DestroyDynamicMapIcon(HouseMIcon[h]);
		#endif
	    DestroyDynamic3DTextLabel(HouseLabel[h]);
		SendMSG(playerid, COLOUR_YELLOW, 128, I_H_DESTROYED, h);
		dini_Remove(file);
		#if defined GH_DEBUGGING
			printf(DEBUG_OP_CMD3, pNick(playerid), playerid, h);
		#endif
		CallRemoteFunction("GPSrfun", "iiisifff", 1, 0, h, "*** INV_PL_ID", 0, 0.0, 0.0, 0.0);
	}
    return 1;
}
//==============================================================================
// This command is used to remove the house car for a house.
//==============================================================================
dcmd_removehcar(playerid, params[])
{
	new file[HOUSEFILE_LENGTH], h;
	if(!IsPlayerAdmin(playerid)) return 0;
	if(sscanf(params, "d", h)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_CMD_USAGE_REMOVEHCAR);
	format(file, sizeof(file), FILEPATH, h);
	if(!dini_Exists(file)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_INVALID_HID);
	if(dini_Int(file, "HCar") == 0) return SendClientMessage(playerid, COLOUR_SYSTEM, E_NO_HCAR);
	else
	{
	    UnloadHouseCar(h);
		dini_IntSet(file, "HCar", 0);
		SendMSG(playerid, COLOUR_YELLOW, 128, I_HCAR_REMOVED, h);
		#if defined GH_DEBUGGING
			printf(DEBUG_OP_CMD4, pNick(playerid), playerid, h);
		#endif
	}
    return 1;
}
//==============================================================================
// This command is used to change the modelid of a housecar.
//==============================================================================
dcmd_changehcar(playerid, params[])
{
	new file[HOUSEFILE_LENGTH], h, modelid;
	if(!IsPlayerAdmin(playerid)) return 0;
	if(sscanf(params, "dd", h, modelid)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_CMD_USAGE_CHANGEHCAR);
	format(file, sizeof(file), FILEPATH, h);
	if(!dini_Exists(file)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_INVALID_HID);
	if(modelid < 400 || modelid > 611) return SendClientMessage(playerid, COLOUR_SYSTEM, E_INVALID_HCAR_MODEL);
	else
	{
		dini_IntSet(file, "HCarModel", modelid);
		SendMSG(playerid, COLOUR_YELLOW, 128, I_HCAR_CHANGED, h, modelid);
    	#if defined GH_HOUSECARS
		if(GetVehicleModel(HouseCar[h]) != -1)
		{
		    if(IsVehicleOccupied(HouseCar[h]))
		    {
		        new Float:Velocity[3], Float:Pos[4], Seat[MAX_PLAYERS] = -1, interior, vw = GetVehicleVirtualWorld(HouseCar[h]);
		        Loop(i, MAX_PLAYERS)
		        {
		            if(!IsPlayerConnected(i) || IsPlayerNPC(i)) continue;
		            if(IsPlayerInVehicle(i, HouseCar[h]))
		            {
		                Seat[i] = GetPlayerVehicleSeat(i);
		                if(Seat[i] == 0)
		                {
		                    interior = GetPlayerInterior(i); // Have to do it this way because there is no GetVehicleInterior..
						}
		            }
		        }
		        GetVehiclePos(HouseCar[h], Pos[0], Pos[1], Pos[2]);
		        GetVehicleZAngle(HouseCar[h], Pos[3]);
		        GetVehicleVelocity(HouseCar[h], Velocity[0], Velocity[1], Velocity[2]);
		        DestroyVehicle(HouseCar[h]);
		        HouseCar[h] = CreateVehicle(modelid, Pos[0], Pos[1], Pos[2], Pos[3], HCAR_COLOUR1, HCAR_COLOUR2, HCAR_RESPAWN);
				LinkVehicleToInterior(HouseCar[h], interior);
				SetVehicleVirtualWorld(HouseCar[h], vw);
				Loop(i, MAX_PLAYERS)
		        {
		            if(!IsPlayerConnected(i) || IsPlayerNPC(i) || Seat[i] == -1) continue;
		            if(IsPlayerInVehicle(i, HouseCar[h]))
		            {
		                PutPlayerInVehicle(i, HouseCar[h], Seat[i]);
		            }
		        }
				SetVehicleVelocity(HouseCar[h], Velocity[0], Velocity[1], Velocity[2]);

		    }
            if(!IsVehicleOccupied(HouseCar[h]))
		    {
		        UnloadHouseCar(h);
		        LoadHouseCar(h);
		    }
		}
		#endif
		#if defined GH_DEBUGGING
			printf(DEBUG_OP_CMD12, pNick(playerid), playerid, h, modelid);
		#endif
	}
    return 1;
}
//==============================================================================
// This command is used to delete all houses.
// It does not give any money to the house owners when the houses is deleted.
//==============================================================================
dcmd_removeallhouses(playerid, params[])
{
	#pragma unused params
	new hcount, file[HOUSEFILE_LENGTH];
	if(!IsPlayerAdmin(playerid)) return 0;
	else
	{
	    Loop(h, MAX_HOUSES)
	    {
	        format(file, sizeof(file), FILEPATH, h);
	        if(dini_Exists(file))
	        {
	            UnloadHouseCar(h);
		     	DestroyHouseEntrance(h, TYPE_OUT);
			    DestroyHouseEntrance(h, TYPE_INT);
			    #if defined GH_USE_MAPICONS
					DestroyDynamicMapIcon(HouseMIcon[h]);
				#endif
			    DestroyDynamic3DTextLabel(HouseLabel[h]);
				dini_Remove(file);
				hcount++;
			}
			CallRemoteFunction("GPSrfun", "iiisifff", 1, 0, h, "*** INV_PL_ID", 0, 0.0, 0.0, 0.0);
		}
		SendMSG(playerid, COLOUR_YELLOW, 128, I_ALLH_DESTROYED, hcount);
		#if defined GH_DEBUGGING
			printf(DEBUG_OP_CMD5, pNick(playerid), playerid, hcount);
		#endif
	}
    return 1;
}
//==============================================================================
// This command is used remove all house cars.
// It does not delete the house cars itself due to SA:MP mixing up vehicle ID's.
//==============================================================================
dcmd_removeallhcars(playerid, params[])
{
	#pragma unused params
	new hcount, file[HOUSEFILE_LENGTH];
	if(!IsPlayerAdmin(playerid)) return 0;
	else
	{
	    Loop(h, MAX_HOUSES)
	    {
	        UnloadHouseCar(h);
	        format(file, sizeof(file), FILEPATH, h);
	        if(dini_Exists(file))
	        {
				dini_IntSet(file, "HCar", 0);
			}
		}
		SendMSG(playerid, COLOUR_YELLOW, 128, I_ALLHCAR_REMOVED, hcount);
		#if defined GH_DEBUGGING
			printf(DEBUG_OP_CMD6, pNick(playerid), playerid, hcount);
		#endif
	}
    return 1;
}
//==============================================================================
// This command is used to change the spawnposition details of a house
//==============================================================================
dcmd_changespawn(playerid, params[])
{
	new h, file[HOUSEFILE_LENGTH];
	if(!IsPlayerAdmin(playerid)) return 0;
	if(sscanf(params, "d", h)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_CMD_USAGE_CHANGESPAWN);
    format(file, sizeof(file), FILEPATH, h);
	if(!dini_Exists(file)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_INVALID_HID);
	else
	{
	    GetPlayerPos(playerid, X, Y, Z);
		GetPlayerFacingAngle(playerid, Angle);
	    dini_FloatSet(file, "SpawnOutX", X);
		dini_FloatSet(file, "SpawnOutY", Y);
		dini_FloatSet(file, "SpawnOutZ", Z);
		dini_FloatSet(file, "SpawnOutAngle", Angle);
		dini_IntSet(file, "SpawnWorld", GetPlayerVirtualWorld(playerid));
		dini_IntSet(file, "SpawnInterior", GetPlayerInterior(playerid));
		SendMSG(playerid, COLOUR_YELLOW, 128, I_HSPAWN_CHANGED, h);
		#if defined GH_DEBUGGING
			printf(DEBUG_OP_CMD7, pNick(playerid), playerid, h);
		#endif
	}
    return 1;
}
//==============================================================================
// This command is used to teleport to a house.
//==============================================================================
dcmd_gotohouse(playerid, params[])
{
	new h, file[HOUSEFILE_LENGTH];
	if(!IsPlayerAdmin(playerid)) return 0;
	if(sscanf(params, "d", h)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_CMD_USAGE_GOTOHOUSE);
    format(file, sizeof(file), FILEPATH, h);
	if(!dini_Exists(file)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_INVALID_HID);
	else
	{
	    SetPlayerPosEx(playerid, dini_Float(file, "SpawnOutX"), dini_Float(file, "SpawnOutY"), dini_Float(file, "SpawnOutZ"), -600.0, dini_Int(file, "SpawnInterior"), dini_Int(file, "SpawnWorld"));
		SendMSG(playerid, COLOUR_YELLOW, 128, I_TELEPORT_MSG, h);
	}
    return 1;
}
//==============================================================================
// This command is used to sell a house.
// If the house owner is connected while selling the house,
// the amount in the house storage and 75% of the house value will be given to the house owner.
//==============================================================================
dcmd_sellhouse(playerid, params[])
{
	new file[HOUSEFILE_LENGTH], h, file2[HOUSEFILE_LENGTH];
	if(!IsPlayerAdmin(playerid)) return 0;
	if(sscanf(params, "d", h)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_CMD_USAGE_SELLHOUSE);
    format(file, sizeof(file), FILEPATH, h);
	if(!dini_Exists(file)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_INVALID_HID);
	if(!strcmp(GetHouseOwner(h), INVALID_HOWNER_NAME, CASE_SENSETIVE)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_H_A_F_SALE);
	else
	{
		SendMSG(playerid, COLOUR_YELLOW, 128, I_H_SOLD, h);
		new para1, para2, para3, strd[256];
		new dvw, Float:dcX, Float:dcY, Float:dcZ;
		para1 = GetHouseOwnerEx(h);
		if(IsPlayerConnected(para1))
		{
			para2 = dini_Int(file, "HouseStorage") + ReturnProcent(GetHouseValue(h), HOUSE_SELLING_PROCENT);
			para3 = GetPlayerMoney(para1);
			SetPVarInt(para1, "MonControl", 1);
			GivePlayerMoney(para1, para2);
			printf("[GarHouse] Сумма %d $ была возвращена игроку %s [%d] (админ продал дом игрока)", para2, pNick(para1), para1);
			format(strd, sizeof(strd), "Сумма %d $ была Вам возвращена (админ продал Ваш дом)", para2);
			SendClientMessage(para1, COLOUR_GREEN, strd);
			printf("[moneysys] Предыдущая сумма игрока %s [%d] : %d $", pNick(para1), para1, para3);
		}
		dini_IntSet(file, "HouseValue", ReturnProcent(GetHouseValue(h), HOUSE_SELLING_PROCENT));
		dini_Set(file, "HouseOwner", INVALID_HOWNER_NAME);
		dini_Set(file, "HousePassword", "INVALID_HOUSE_PASSWORD");
		dini_Set(file, "HouseName", DEFAULT_HOUSE_NAME);
		dini_IntSet(file, "HouseStorage", 0);
		Loop(h2, MAX_HOUSES)
		{
			if(IsHouseInRangeOfHouse(h, h2, RANGE_BETWEEN_HOUSES) && h2 != h)
			{
		    	format(file2, sizeof(file2), FILEPATH, h2);
				dini_IntSet(file2, "HouseValue", (dini_Int(file2, "HouseValue") - ReturnProcent(GetHouseValue(h2), HOUSE_SELLING_PROCENT2)));
			}
		}
		Loop(i, MAX_PLAYERS)
		{
		    if(GetPVarInt(i, "LastHouseCP") == h && GetPVarInt(i, "IsInHouse") == 1)
		    {
		    	SetPVarInt(i, "IsInHouse", 0);
       			SetPlayerPosEx(i, dini_Float(file, "SpawnOutX"), dini_Float(file, "SpawnOutY"), dini_Float(file, "SpawnOutZ"), dini_Float(file, "SpawnOutAngle"), dini_Int(file, "SpawnInterior"), dini_Int(file, "SpawnWorld"));
			}
		}
		dcX = dini_Float(file, "CPOutX");
		dcY = dini_Float(file, "CPOutY");
		dcZ = dini_Float(file, "CPOutZ");
		dvw = dini_Int(file, "SpawnWorld");
		#if defined GH_USE_MAPICONS
			DestroyDynamicMapIcon(HouseMIcon[h]);
			HouseMIcon[h] = CreateDynamicMapIcon(dcX, dcY, dcZ, 31, -1, dvw, dini_Int(file, "SpawnInterior"), -1, MICON_VD);
		#endif
		UpdateHouseText(h);
		CallRemoteFunction("GPSrfun", "iiisifff", 1, 1, h, "*** INV_PL_ID", dvw, dcX, dcY, dcZ);
        #if defined GH_DEBUGGING
			printf(DEBUG_OP_CMD8, pNick(playerid), playerid, h);
		#endif
	}
    return 1;
}
//==============================================================================
// This command is used to sell a house.
// If the house owner is connected while selling the house,
// the amount in the house storage and 75% of the house value will be given to the house owner.
//==============================================================================
dcmd_sellallhouses(playerid, params[])
{
	#pragma unused params
	new file[HOUSEFILE_LENGTH], hcount;
	if(!IsPlayerAdmin(playerid)) return 0;
	else
	{
		new para1, para2, para3, strd[256];
		new dvw, Float:dcX, Float:dcY, Float:dcZ;
	    Loop(h, MAX_HOUSES)
	    {
	        format(file, sizeof(file), FILEPATH, h);
	        if(dini_Exists(file) && strcmp(GetHouseOwner(h), INVALID_HOWNER_NAME, CASE_SENSETIVE))
	        {
				para1 = GetHouseOwnerEx(h);
				if(IsPlayerConnected(para1))
				{
					para2 = dini_Int(file, "HouseStorage") + ReturnProcent(GetHouseValue(h), HOUSE_SELLING_PROCENT);
					para3 = GetPlayerMoney(para1);
					SetPVarInt(para1, "MonControl", 1);
					GivePlayerMoney(para1, para2);
					printf("[GarHouse] Сумма %d $ была возвращена игроку %s [%d] (продажа всех домов)", para2, pNick(para1), para1);
					format(strd, sizeof(strd), "Сумма %d $ была Вам возвращена (продажа всех домов)", para2);
					SendClientMessage(para1, COLOUR_GREEN, strd);
					printf("[moneysys] Предыдущая сумма игрока %s [%d] : %d $", pNick(para1), para1, para3);
				}
				dini_IntSet(file, "HouseValue", ReturnProcent(GetHouseValue(h), HOUSE_SELLING_PROCENT));
				dini_Set(file, "HouseOwner", INVALID_HOWNER_NAME);
				dini_Set(file, "HousePassword", "INVALID_HOUSE_PASSWORD");
				dini_Set(file, "HouseName", DEFAULT_HOUSE_NAME);
				dini_IntSet(file, "HouseStorage", 0);
				dcX = dini_Float(file, "CPOutX");
				dcY = dini_Float(file, "CPOutY");
				dcZ = dini_Float(file, "CPOutZ");
				dvw = dini_Int(file, "SpawnWorld");
				#if defined GH_USE_MAPICONS
					DestroyDynamicMapIcon(HouseMIcon[h]);
					HouseMIcon[h] = CreateDynamicMapIcon(dcX, dcY, dcZ, 31, -1, dvw, dini_Int(file, "SpawnInterior"), -1, MICON_VD);
				#endif
				UpdateHouseText(h);
				hcount++;
				CallRemoteFunction("GPSrfun", "iiisifff", 1, 1, h, "*** INV_PL_ID", dvw, dcX, dcY, dcZ);
			}
		}
		SendMSG(playerid, COLOUR_YELLOW, 128, I_ALLH_SOLD, hcount);
        #if defined GH_DEBUGGING
			printf(DEBUG_OP_CMD9, pNick(playerid), playerid, hcount);
		#endif
	}
    return 1;
}
//==============================================================================
// 			This command is used to change the value of a house.
//==============================================================================
dcmd_changeprice(playerid, params[])
{
	new h, file[HOUSEFILE_LENGTH], price;
	if(!IsPlayerAdmin(playerid)) return 0;
	if(sscanf(params, "dd", h, price)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_CMD_USAGE_CHANGEPRICE);
    format(file, sizeof(file), FILEPATH, h);
	if(!dini_Exists(file)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_INVALID_HID);
	if(price < 1500000 || price > 25000000) return SendClientMessage(playerid, COLOUR_SYSTEM, E_INVALID_HVALUE);
	else
	{
	    dini_IntSet(file, "HouseValue", price);
		SendMSG(playerid, COLOUR_YELLOW, 128, I_H_PRICE_CHANGED, h, price);
		UpdateHouseText(h);
		#if defined GH_DEBUGGING
			printf(DEBUG_OP_CMD10, pNick(playerid), playerid, h, price);
		#endif
	}
    return 1;
}
//==============================================================================
// 		This command is used to change the value of all houses on the server.
//==============================================================================
dcmd_changeallprices(playerid, params[])
{
	new hcount, file[HOUSEFILE_LENGTH], price;
	if(!IsPlayerAdmin(playerid)) return 0;
	if(sscanf(params, "d", price)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_CMD_USAGE_CHANGEALLPRICE);
	if(price < 1500000 || price > 25000000) return SendClientMessage(playerid, COLOUR_SYSTEM, E_INVALID_HVALUE);
	else
	{
	    Loop(h, MAX_HOUSES)
	    {
	        format(file, sizeof(file), FILEPATH, h);
	        if(dini_Exists(file))
	        {
		    	dini_IntSet(file, "HouseValue", price);
		    	UpdateHouseText(h);
		    	hcount++;
	    	}
	    }
		SendMSG(playerid, COLOUR_YELLOW, 128, I_ALLH_PRICE_CHANGED, price, hcount);
        #if defined GH_DEBUGGING
			printf(DEBUG_OP_CMD11, pNick(playerid), playerid, price, hcount);
		#endif
	}
    return 1;
}
dcmd_ghcmds(playerid, params[])
{
	#pragma unused params
	if(!IsPlayerAdmin(playerid)) return 0;
	else
	{
		ShowPlayerDialog(playerid, 520, DIALOG_STYLE_MSGBOX, "Команды", "/removeallhouses\n/changeallprices\
		\n/sellallhouses\n/createhouse\n/removehouse\n/changeprice\n/sellhouse\n/gotohouse\n/relhouses\n/lchouse\
		\n/housemenu\n/ghcmds", "Закрыть", "Закрыть");
		dlgcont[playerid] = 520;
	    return 1;
    }
}
//##############################################################################
// 								      Publics
//##############################################################################
forward HouseVisiting(playerid);
public HouseVisiting(playerid)
{

	SetPVarInt(playerid, "HousePrevTime", 0);//сбрасываем блокировку меню дома

	new string[200], tmpstring[50];
	GetPVarString(playerid, "HousePrevName", tmpstring, 50);
	format(string, sizeof(string), I_HINT_VISIT_OVER, tmpstring, GetPVarInt(playerid, "HousePrevValue"));
	ShowPlayerDialog(playerid, 517, DIALOG_STYLE_MSGBOX, "Интерьер", string, "Купить", "Отмена");
	dlgcont[playerid] = 517;
	return 1;
}
forward HouseSpawning(playerid);
public HouseSpawning(playerid)
{
	new file[HOUSEFILE_LENGTH];
	Loop(h, MAX_HOUSES)
	{
		if(!strcmp(GetHouseOwner(h), pNick(playerid), CASE_SENSETIVE))
		{
  			format(file, sizeof(file), FILEPATH, h);
  			if(dini_Int(file, "QuitInHouse") == 1)
	    	{
		    	SetPVarInt(playerid, "IsInHouse", 1);
			    SetPVarInt(playerid, "LastHouseCP", h);
       			SetPlayerHouseInterior(playerid, h);
       			#if defined GH_HOUSECARS
       				LoadHouseCar(h);
       			#endif
			    SendClientMessage(playerid, COLOUR_INFO, I_HMENU);
			    dini_IntSet(file, "QuitInHouse", 0);
		    	#if defined GH_DEBUGGING
  	    			printf(DEBUG_OP_SPAWN, pNick(playerid), playerid);
		    	#endif
			}
		}
	}
	SetPVarInt(playerid, "FirstSpawn", 1);
	return 1;
}
forward InpTxtControl(string[]);
public InpTxtControl(string[])//контроль вводимого текста на посторонние символы
{
	new dln, dopper;
	dln = strlen(string);
	dopper = 1;
	for(new i = 0; i < dln; i++)
	{
		if(string[i] < 32 || string[i] == 37 || string[i] == 126 ||
		string[i] == 127 || string[i] == 152 || string[i] == 160) { dopper = 0; }
	}
	return dopper;
}
//##############################################################################
// 								Functions
//##############################################################################
// 							  By [03]Garsino!
//==============================================================================
// LoadHouses();
// This function is used to load the houses.
// It creates all the checkpoints, map icons and
// 3D texts for all the houses and sets the correct 3D text information.
//==============================================================================
stock LoadHouses()
{

	for(new i = 0; i < MAX_PLAYERS; i++)//цикл для всех игроков
	{
		if(IsPlayerConnected(i))//дальнейшее выполняем если игрок в коннекте
		{
			SetPVarInt(i, "HousePrevTime", 0);//обнуление важных глобальных переменных !!!
			SetPVarInt(i, "HousePreview", 0);
			SetPVarInt(i, "IsHouseVisiting", 0);
			SetPVarInt(i, "LastHouseCP", 0);
			SetPVarInt(i, "IsInHouse", 0);
			SetPVarInt(i, "HousePrevInt", 0);
			SetPVarInt(i, "IsHouseVisiting", 0);
			SetPVarInt(i, "ChangeHouseInt", 0);
			SetPVarInt(i, "HouseIntUpgradeMod", 0);
			SetPVarInt(i, "JustCreatedHouse", 0);
			SetPVarInt(i, "FirstSpawn", 0);
		}
	}

	new hcount = 0;
	new dname[64], dvw, Float:dcX, Float:dcY, Float:dcZ;
	Loop(h, MAX_HOUSES)
	{
		#if defined GH_USE_CPS
			HouseCPOut[h] = -600;//задаём несуществующие ID-номера чекпоинтов для дома
			HouseCPInt[h] = -600;
		#endif
		#if !defined GH_USE_CPS
			HousePickupOut[h] = -600;//задаём несуществующие ID-номера пикапов для дома
			HousePickupInt[h] = -600;
		#endif
	    new file[HOUSEFILE_LENGTH], labeltext[150];
	    format(file, sizeof(file), FILEPATH, h);
	    if(dini_Exists(file))
	    {
			dcX = dini_Float(file, "CPOutX");
			dcY = dini_Float(file, "CPOutY");
			dcZ = dini_Float(file, "CPOutZ");
			strdel(dname, 0, 64);
			strcat(dname, dini_Get(file, "HouseOwner"));
			dvw = dini_Int(file, "SpawnWorld");
		    #if defined GH_USE_CPS
		    	HouseCPOut[h] = CreateDynamicCP(dcX, dcY, dcZ, 1.5, dvw, dini_Int(file, "SpawnInterior"), -1, 15.0);
			#endif
			#if !defined GH_USE_CPS
				HousePickupOut[h] = CreateDynamicPickup(PICKUP_MODEL_OUT, PICKUP_TYPE, dcX, dcY, dcZ, dvw, dini_Int(file, "SpawnInterior"), -1, 15.0);
			#endif
			CreateCorrectHouseExitCP(h);
		    if(!strcmp(GetHouseOwner(h), INVALID_HOWNER_NAME, CASE_SENSETIVE))
		    {
		        format(labeltext, sizeof(labeltext), LABELTEXT1, GetHouseName(h), GetHouseValue(h), h);
				HouseLabel[h] = CreateDynamic3DTextLabel(labeltext, COLOUR_GREEN, dcX, dcY, dcZ+0.7, 25, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, dvw, dini_Int(file, "SpawnInterior"), -1);
                #if defined GH_USE_MAPICONS
					HouseMIcon[h] = CreateDynamicMapIcon(dcX, dcY, dcZ, 31, -1, dvw, dini_Int(file, "SpawnInterior"), -1, MICON_VD);
				#endif
			}
		    if(strcmp(GetHouseOwner(h), INVALID_HOWNER_NAME, CASE_SENSETIVE))
		    {
		        format(labeltext, sizeof(labeltext), LABELTEXT2, GetHouseName(h), GetHouseOwner(h), GetHouseValue(h), h);
				HouseLabel[h] = CreateDynamic3DTextLabel(labeltext, COLOUR_GREEN, dcX, dcY, dcZ+0.7, 25, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, dvw, dini_Int(file, "SpawnInterior"), -1);
                #if defined GH_USE_MAPICONS
					HouseMIcon[h] = CreateDynamicMapIcon(dcX, dcY, dcZ, 32, -1, dvw, dini_Int(file, "SpawnInterior"), -1, MICON_VD);
				#endif
			}
			CallRemoteFunction("GPSrfun", "iiisifff", 1, 1, h, dname, dvw, dcX, dcY, dcZ);
		    hcount++;
		}
		else
		{
			CallRemoteFunction("GPSrfun", "iiisifff", 1, 0, h, "*** INV_PL_ID", 0, 0.0, 0.0, 0.0);
		}
	}
	print(" ");
	printf("Total Houses Loaded: %d\n", hcount);
	return 1;
}
//==============================================================================
// LoadHouseCar(houseid);
// This function is used to load the house car for a house.
//==============================================================================
stock LoadHouseCar(houseid)
{
	#if defined GH_HOUSECARS
		new file[HOUSEFILE_LENGTH];
		format(file, sizeof(file), FILEPATH, houseid);
		if(dini_Exists(file) && dini_Int(file, "HCar") == 1)
		{
			HouseCar[houseid] = CreateVehicle(dini_Int(file, "HCarModel"), dini_Float(file, "HCarPosX"), dini_Float(file, "HCarPosY"), dini_Float(file, "HCarPosZ"), dini_Float(file, "HCarAngle"), HCAR_COLOUR1, HCAR_COLOUR2, HCAR_RESPAWN);
			SetVehicleVirtualWorld(HouseCar[houseid], dini_Int(file, "HCarWorld"));
			LinkVehicleToInterior(HouseCar[houseid], dini_Int(file, "HCarInt"));
		}
	#endif
	return 1;
}
//==============================================================================
// UnloadHouseCar(houseid);
// This function is used to the unload house car for a house.
//==============================================================================
stock UnloadHouseCar(houseid)
{
	#if !defined GH_HOUSECARS
	    #pragma unused houseid
	#endif
	#if defined GH_HOUSECARS
		new file[HOUSEFILE_LENGTH];
		format(file, sizeof(file), FILEPATH, houseid);
		if(dini_Exists(file) && dini_Int(file, "HCar") == 1)
		{
		    if(GetVehicleModel(HouseCar[houseid]) >= 400 && GetVehicleModel(HouseCar[houseid]) <= 611 && HouseCar[houseid] >= 1)
			{
			    DestroyVehicle(HouseCar[houseid]);
			    HouseCar[houseid] = -1;
			}
		}
	#endif
	return 1;
}
//==============================================================================
// SaveHouseCar(houseid);
// This function is used to check if there is any vehicles
// near the housecar spawn.
//==============================================================================
stock SaveHouseCar(houseid)
{
	#if defined GH_HOUSECARS
		new file[HOUSEFILE_LENGTH], Float:tmpx, Float:tmpy, Float:tmpz;
		format(file, sizeof(file), FILEPATH, houseid);
		if(dini_Exists(file) && dini_Int(file, "HCar") == 1)
		{
		    tmpx = dini_Float(file, "HCarPosX"), tmpy = dini_Float(file, "HCarPosY"), tmpz = dini_Float(file, "HCarPosZ");
		    Loop(v, MAX_VEHICLES)
			{
			    if(GetVehicleModel(v) < 400 || GetVehicleModel(v) > 611 || IsVehicleOccupied(v)) continue;
			    GetVehiclePos(v, X, Y, Z);
			    if(PointInRangeOfPoint(HCAR_RANGE, X, Y, Z, tmpx, tmpy, tmpz))
			    {
			        dini_IntSet(file, "HCarModel", GetVehicleModel(v));
			        DestroyVehicle(v);
			        break;
			    }
			}
		}
	#endif
	return 1;
}
//==============================================================================
// GetOwnedHouses(playerid);
// This function is used to find out how many houses a player owns
//==============================================================================
stock GetOwnedHouses(playerid)
{
	new file[HOUSEFILE_LENGTH], tmpcount;
	Loop(h, MAX_HOUSES)
	{
	    format(file, sizeof(file), FILEPATH, h);
	    if(dini_Exists(file))
	    {
		    if(!strcmp(dini_Get(file, "HouseOwner"), pNick(playerid), CASE_SENSETIVE))
		    {
		        tmpcount++;
		    }
		}
	}
	return tmpcount;
}
//==============================================================================
// GetHouseOwnerEx(houseid);
// This function is used to get the house owner of a house
// and return the playerid, it will return INVALID_PLAYER_ID
// if the house owner is not connected
//==============================================================================
stock GetHouseOwnerEx(houseid)
{
	new file[HOUSEFILE_LENGTH];
	format(file, sizeof(file), FILEPATH, houseid);
 	if(dini_Exists(file))
  	{
   		Loop(i, MAX_PLAYERS)
   		{
	    	if(!strcmp(pNick(i), GetHouseOwner(houseid), CASE_SENSETIVE))
   			{
      			return i;
   			}
		}
	}
	return INVALID_PLAYER_ID;
}
//==============================================================================
// ReturnPlayerHouseID(playerid, houseslot);
// This function is used to return the house id from a players house 'slot'
// Example: ReturnPlayerHouseID(playerid, 0);
// Would return for example house ID 500.
//==============================================================================
stock ReturnPlayerHouseID(playerid, houseslot)
{
	new file[HOUSEFILE_LENGTH], tmpcount = 0;
	if(houseslot < 1 && houseslot > MAX_HOUSES_OWNED) return -1;
	Loop(h, MAX_HOUSES)
	{
	    format(file, sizeof(file), FILEPATH, h);
	    if(dini_Exists(file))
	    {
		    if(!strcmp(pNick(playerid), dini_Get(file, "HouseOwner"), CASE_SENSETIVE))
		    {
		        tmpcount++;
		        if(tmpcount == houseslot)
		        {
		        	return h;
		        }
		    }
		}
	}
	return -1;
}
//==============================================================================
// UnloadHouses();
// This function is used to unload the houses.
// It deletes all the checkpoints, map icons and 3D texts for all the houses.
//==============================================================================
stock UnloadHouses()
{
	Loop(h, MAX_HOUSES)
	{
		DestroyHouseEntrance(h, TYPE_OUT);
		DestroyHouseEntrance(h, TYPE_INT);
		#if defined GH_USE_MAPICONS
			DestroyDynamicMapIcon(HouseMIcon[h]);
		#endif
		DestroyDynamic3DTextLabel(HouseLabel[h]);
		#if defined GH_HOUSECARS
			UnloadHouseCar(h);
		#endif
		CallRemoteFunction("GPSrfun", "iiisifff", 1, 0, h, "*** INV_PL_ID", 0, 0.0, 0.0, 0.0);
	}
	return 1;
}
//==============================================================================
// GetHouseValue(houseid);
// This function is used to get the value of a house
//==============================================================================
stock GetHouseValue(houseid)
{
	new file[HOUSEFILE_LENGTH];
	format(file, sizeof(file), FILEPATH, houseid);
	if(dini_Exists(file))
	{
		return dini_Int(file, "HouseValue");
	}
	else return printf("Couldn't Get House Value For House ID %d. File Doesn't Exist...", houseid);
}
//==============================================================================
// GetHouseName(houseid);
// This function is used to get the name of a house
//==============================================================================
stock GetHouseName(houseid)
{
	new file[HOUSEFILE_LENGTH], hname[MAX_HOUSE_NAME];
	format(hname, MAX_HOUSE_NAME, "%s", DEFAULT_HOUSE_NAME);
	format(file, sizeof(file), FILEPATH, houseid);
	if(dini_Exists(file))
	{
	    format(hname, MAX_HOUSE_NAME, "%s", dini_Get(file, "HouseName"));
		return hname;
	}
	return hname;
}
//==============================================================================
// GetHouseOwner(houseid);
// This function is used to get the owner of a house
//==============================================================================
stock GetHouseOwner(houseid)
{
	new file[HOUSEFILE_LENGTH], howner[MAX_PLAYER_NAME];
	format(howner, MAX_PLAYER_NAME, INVALID_HOWNER_NAME);
	format(file, sizeof(file), FILEPATH, houseid);
	if(dini_Exists(file))
	{
	    format(howner, MAX_PLAYER_NAME, "%s", dini_Get(file, "HouseOwner"));
		return howner;
	}
	return howner;
}
//==============================================================================
// IsHouseInRangeOfHouse(house, house2, Float:range);
// This function is used to check if a house is in range of another house
// Default range is 250.0
//==============================================================================
stock IsHouseInRangeOfHouse(house, house2, Float:range = 250.0)
{
	new file[HOUSEFILE_LENGTH], file2[25];
	format(file, sizeof(file), FILEPATH, house);
	format(file2, sizeof(file2), FILEPATH, house2);
	if(dini_Exists(file) && dini_Exists(file2))
	{
		if(PointInRangeOfPoint(range, dini_Float(file, "CPOutX"), dini_Float(file, "CPOutY"), dini_Float(file, "CPOutZ"), dini_Float(file2, "CPOutX"), dini_Float(file2, "CPOutY"), dini_Float(file2, "CPOutZ")))
		{
		    return 1;
		}
	}
	return 0;
}
//==============================================================================
// CreateCorrectHouseExitCP(houseid);
// This function is used to create the correct house exit checkpoint for the houseid
// based on the house interior ID
//==============================================================================
stock CreateCorrectHouseExitCP(houseid)
{
    new file[HOUSEFILE_LENGTH];
	format(file, sizeof(file), FILEPATH, houseid);
	#if defined GH_USE_CPS
	switch(dini_Int(file, "HouseInterior"))
	{
	 	case 0: HouseCPInt[houseid] = CreateDynamicCP(2196.84, -1204.36, 1049.02, 1.5, (houseid + 1000), 6, -1, 10.0); // Default House
		case 1: HouseCPInt[houseid] = CreateDynamicCP(2259.38, -1135.89, 1050.64, 1.50, (houseid + 1000), 10, -1, 10.0); // Shitty Shack House Interior
		case 2: HouseCPInt[houseid] = CreateDynamicCP(2282.99, -1140.28, 1050.89, 1.50, (houseid + 1000), 11, -1, 10.0); // Motel House Interior
		case 3: HouseCPInt[houseid] = CreateDynamicCP(2233.69, -1115.26, 1050.88, 1.50, (houseid + 1000), 5, -1, 10.0); // Hotel House Interior
		case 4: HouseCPInt[houseid] = CreateDynamicCP(2218.39, -1076.21, 1050.48, 1.50, (houseid + 1000), 1, -1, 10.0); // Hotel 2 House Interior
		case 5: HouseCPInt[houseid] = CreateDynamicCP(2496.00, -1692.08, 1014.74, 1.50, (houseid + 1000), 3, -1, 10.0); // CJ's House Interior
		case 6: HouseCPInt[houseid] = CreateDynamicCP(2365.25, -1135.58, 1050.88, 1.50, (houseid + 1000), 8, -1, 10.0); // Verdant Bluff's Safehouse House Interior
		case 7: HouseCPInt[houseid] = CreateDynamicCP(2317.77, -1026.76, 1050.21, 1.50, (houseid + 1000), 9, -1, 10.0); // Medium Mansion House Interior
		case 8: HouseCPInt[houseid] = CreateDynamicCP(2324.41, -1149.54, 1050.71, 1.50, (houseid + 1000), 12, -1, 10.0); // Rich Mansion House Interior
		case 9: HouseCPInt[houseid] = CreateDynamicCP(140.28, 1365.92, 1083.85, 1.50, (houseid + 1000), 5, -1, 10.0); // Huge Mansion House Interior
        case 10: HouseCPInt[houseid] = CreateDynamicCP(1260.6603, -785.4005, 1091.9063, 1.50, (houseid + 1000), 5, -1, 10.0); // Madd Dogg's Mansion House Interior
	}
	#endif
	#if !defined GH_USE_CPS
	switch(dini_Int(file, "HouseInterior"))
	{
	 	case 0: HousePickupInt[houseid] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 2195.84, -1204.36, 1049.02, (houseid + 1000), 6, -1, 15.0); // Default House
		case 1: HousePickupInt[houseid] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 2260.38, -1135.89, 1050.64, (houseid + 1000), 10, -1, 15.0); // Shitty Shack House Interior
		case 2: HousePickupInt[houseid] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 2284.24, -1139.42, 1050.89, (houseid + 1000), 11, -1, 15.0); // Motel House Interior
		case 3: HousePickupInt[houseid] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 2233.69, -1114.26, 1050.88, (houseid + 1000), 5, -1, 15.0); // Hotel House Interior
		case 4: HousePickupInt[houseid] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 2216.39, -1077.10, 1050.48, (houseid + 1000), 1, -1, 15.0); // Hotel 2 House Interior
		case 5: HousePickupInt[houseid] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 2496.00, -1693.70, 1014.74, (houseid + 1000), 3, -1, 15.0); // CJ's House Interior
		case 6: HousePickupInt[houseid] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 2365.25, -1134.00, 1050.88, (houseid + 1000), 8, -1, 15.0); // Verdant Bluff's Safehouse House Interior
		case 7: HousePickupInt[houseid] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 2319.43, -1026.33, 1050.21, (houseid + 1000), 9, -1, 15.0); // Medium Mansion House Interior
		case 8: HousePickupInt[houseid] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 2324.41, -1148.54, 1050.71, (houseid + 1000), 12, -1, 15.0); // Rich Mansion House Interior
		case 9: HousePickupInt[houseid] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 143.40, 1366.66, 1083.85, (houseid + 1000), 5, -1, 15.0); // Huge Mansion House Interior
		case 10: HousePickupInt[houseid] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 1263.11, -785.26, 1091.9063, (houseid + 1000), 5, -1, 15.0); // Madd Dogg's Mansion House Interior
	}
	#endif
	return 1;
}
stock CreateCorrectHouseExitCP22(playerid, houseid)
{
	#if defined GH_USE_CPS
	switch(GetPVarInt(playerid, "HousePrevInt"))
	{
	 	case 0: HouseCPInt[houseid] = CreateDynamicCP(2196.84, -1204.36, 1049.02, 1.5, (houseid + 1000), 6, -1, 10.0); // Default House
		case 1: HouseCPInt[houseid] = CreateDynamicCP(2259.38, -1135.89, 1050.64, 1.50, (houseid + 1000), 10, -1, 10.0); // Shitty Shack House Interior
		case 2: HouseCPInt[houseid] = CreateDynamicCP(2282.99, -1140.28, 1050.89, 1.50, (houseid + 1000), 11, -1, 10.0); // Motel House Interior
		case 3: HouseCPInt[houseid] = CreateDynamicCP(2233.69, -1115.26, 1050.88, 1.50, (houseid + 1000), 5, -1, 10.0); // Hotel House Interior
		case 4: HouseCPInt[houseid] = CreateDynamicCP(2218.39, -1076.21, 1050.48, 1.50, (houseid + 1000), 1, -1, 10.0); // Hotel 2 House Interior
		case 5: HouseCPInt[houseid] = CreateDynamicCP(2496.00, -1692.08, 1014.74, 1.50, (houseid + 1000), 3, -1, 10.0); // CJ's House Interior
		case 6: HouseCPInt[houseid] = CreateDynamicCP(2365.25, -1135.58, 1050.88, 1.50, (houseid + 1000), 8, -1, 10.0); // Verdant Bluff's Safehouse House Interior
		case 7: HouseCPInt[houseid] = CreateDynamicCP(2317.77, -1026.76, 1050.21, 1.50, (houseid + 1000), 9, -1, 10.0); // Medium Mansion House Interior
		case 8: HouseCPInt[houseid] = CreateDynamicCP(2324.41, -1149.54, 1050.71, 1.50, (houseid + 1000), 12, -1, 10.0); // Rich Mansion House Interior
		case 9: HouseCPInt[houseid] = CreateDynamicCP(140.28, 1365.92, 1083.85, 1.50, (houseid + 1000), 5, -1, 10.0); // Huge Mansion House Interior
        case 10: HouseCPInt[houseid] = CreateDynamicCP(1260.6603, -785.4005, 1091.9063, 1.50, (houseid + 1000), 5, -1, 10.0); // Madd Dogg's Mansion House Interior
	}
	#endif
	#if !defined GH_USE_CPS
	switch(GetPVarInt(playerid, "HousePrevInt"))
	{
	 	case 0: HousePickupInt[houseid] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 2195.84, -1204.36, 1049.02, (houseid + 1000), 6, -1, 15.0); // Default House
		case 1: HousePickupInt[houseid] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 2260.38, -1135.89, 1050.64, (houseid + 1000), 10, -1, 15.0); // Shitty Shack House Interior
		case 2: HousePickupInt[houseid] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 2284.24, -1139.42, 1050.89, (houseid + 1000), 11, -1, 15.0); // Motel House Interior
		case 3: HousePickupInt[houseid] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 2233.69, -1114.26, 1050.88, (houseid + 1000), 5, -1, 15.0); // Hotel House Interior
		case 4: HousePickupInt[houseid] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 2216.39, -1077.10, 1050.48, (houseid + 1000), 1, -1, 15.0); // Hotel 2 House Interior
		case 5: HousePickupInt[houseid] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 2496.00, -1693.70, 1014.74, (houseid + 1000), 3, -1, 15.0); // CJ's House Interior
		case 6: HousePickupInt[houseid] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 2365.25, -1134.00, 1050.88, (houseid + 1000), 8, -1, 15.0); // Verdant Bluff's Safehouse House Interior
		case 7: HousePickupInt[houseid] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 2319.43, -1026.33, 1050.21, (houseid + 1000), 9, -1, 15.0); // Medium Mansion House Interior
		case 8: HousePickupInt[houseid] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 2324.41, -1148.54, 1050.71, (houseid + 1000), 12, -1, 15.0); // Rich Mansion House Interior
		case 9: HousePickupInt[houseid] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 143.40, 1366.66, 1083.85, (houseid + 1000), 5, -1, 15.0); // Huge Mansion House Interior
		case 10: HousePickupInt[houseid] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 1263.11, -785.26, 1091.9063, (houseid + 1000), 5, -1, 15.0); // Madd Dogg's Mansion House Interior
	}
	#endif
	return 1;
}
//==============================================================================
// SetPlayerHouseInterior(playerid, house);
// This function is used to set the correct house interior for a player when he enters a house or buy a new house interior.
//==============================================================================
stock SetPlayerHouseInterior(playerid, house)
{
    new file[HOUSEFILE_LENGTH];
    format(file, sizeof(file), FILEPATH, house);
	switch(dini_Int(file, "HouseInterior"))
	{
	 	case 0: SetPlayerPosEx(playerid, 2193.9001, -1202.4185, 1049.0234, 91.9386, 6, (house + 1000)); // Default House Interior - Spawnpoint
		case 1: SetPlayerPosEx(playerid, 2262.5627, -1136.1664, 1050.6328, 267.5372, 10, (house + 1000)); // Shitty Shack House Interior - Spawnpoint
		case 2: SetPlayerPosEx(playerid, 2283.0632, -1136.9760, 1050.8984, 358.7963, 11, (house + 1000)); // Motel Room House Interior - Spawnpoint
		case 3: SetPlayerPosEx(playerid, 2233.6057, -1111.7039, 1050.8828, 2.9124, 5, (house + 1000)); // Hotel House Interior - Spawnpoint
		case 4: SetPlayerPosEx(playerid, 2214.8909, -1076.0967, 1050.4844, 88.8910, 1, (house + 1000)); // Hotel 2 House Interior - Spawnpoint
		case 5: SetPlayerPosEx(playerid, 2495.8035, -1695.0997, 1014.7422, 181.9661, 3, (house + 1000)); // CJ's House Interior - Spawnpoint
		case 6: SetPlayerPosEx(playerid, 2365.2883, -1132.5228, 1050.8750, 358.0393, 8, (house + 1000)); // Verdant Bluff's Safehouse House Interior - Spawnpoint
		case 7: SetPlayerPosEx(playerid, 2320.0730, -1023.9533, 1050.2109, 358.4915, 9, (house + 1000)); // Medium Mansion House Interior - Spawnpoint
		case 8: SetPlayerPosEx(playerid, 2324.4490, -1145.2841, 1050.7101, 357.5873, 12, (house + 1000)); // Richouse Mansion House Interior - Spawnpoint
		case 9: SetPlayerPosEx(playerid, 140.1788, 1369.1936, 1083.8641, 359.2263, 5, (house + 1000)); // Huge Mansion House Interior - Spawnpoint
		case 10: SetPlayerPosEx(playerid, 1264.7765, -781.2485, 1091.9063, 270.6992, 5, (house + 1000)); // Madd Dogg's Mansion House Interior - Spawnpoint
	}
	return 1;
}
stock SetPlayerHouseInterior22(playerid, house)
{
	switch(GetPVarInt(playerid, "HousePrevInt"))
	{
	 	case 0: SetPlayerPosEx(playerid, 2193.9001, -1202.4185, 1049.0234, 91.9386, 6, (house + 1000)); // Default House Interior - Spawnpoint
		case 1: SetPlayerPosEx(playerid, 2262.5627, -1136.1664, 1050.6328, 267.5372, 10, (house + 1000)); // Shitty Shack House Interior - Spawnpoint
		case 2: SetPlayerPosEx(playerid, 2283.0632, -1136.9760, 1050.8984, 358.7963, 11, (house + 1000)); // Motel Room House Interior - Spawnpoint
		case 3: SetPlayerPosEx(playerid, 2233.6057, -1111.7039, 1050.8828, 2.9124, 5, (house + 1000)); // Hotel House Interior - Spawnpoint
		case 4: SetPlayerPosEx(playerid, 2214.8909, -1076.0967, 1050.4844, 88.8910, 1, (house + 1000)); // Hotel 2 House Interior - Spawnpoint
		case 5: SetPlayerPosEx(playerid, 2495.8035, -1695.0997, 1014.7422, 181.9661, 3, (house + 1000)); // CJ's House Interior - Spawnpoint
		case 6: SetPlayerPosEx(playerid, 2365.2883, -1132.5228, 1050.8750, 358.0393, 8, (house + 1000)); // Verdant Bluff's Safehouse House Interior - Spawnpoint
		case 7: SetPlayerPosEx(playerid, 2320.0730, -1023.9533, 1050.2109, 358.4915, 9, (house + 1000)); // Medium Mansion House Interior - Spawnpoint
		case 8: SetPlayerPosEx(playerid, 2324.4490, -1145.2841, 1050.7101, 357.5873, 12, (house + 1000)); // Richouse Mansion House Interior - Spawnpoint
		case 9: SetPlayerPosEx(playerid, 140.1788, 1369.1936, 1083.8641, 359.2263, 5, (house + 1000)); // Huge Mansion House Interior - Spawnpoint
		case 10: SetPlayerPosEx(playerid, 1264.7765, -781.2485, 1091.9063, 270.6992, 5, (house + 1000)); // Madd Dogg's Mansion House Interior - Spawnpoint
	}
	return 1;
}
//==============================================================================
// pNick(playerid);
// Used to get the name of a player.
//==============================================================================
stock pNick(playerid)
{
	new GHNick[MAX_PLAYER_NAME];
	new aaa[64];//доработка для использования Русских ников
	GetPlayerName(playerid, aaa, 64);//доработка для использования Русских ников
	format(GHNick, sizeof(GHNick), "%s", aaa);//доработка для использования Русских ников
//	GetPlayerName(playerid, GHNick, MAX_PLAYER_NAME);
 	return GHNick;
}
//==============================================================================
// PointInRangeOfPoint(Float:range, Float:x2, Float:y2, Float:z2, Float:X2, Float:Y2, Float:Z2);
// Used to check if a point is in range of another point.
// Credits to whoever made this!
//==============================================================================
stock PointInRangeOfPoint(Float:range, Float:x2, Float:y2, Float:z2, Float:X2, Float:Y2, Float:Z2)
{
    X2 -= x2;
    Y2 -= y2;
    Z2 -= z2;
    return ((X2 * X2) + (Y2 * Y2) + (Z2 * Z2)) < (range * range);
}
//==============================================================================
// ReturnProcent(Float:amount, Float:procent);
// Used to return the procent of an value.
//==============================================================================
stock ReturnProcent(Float:amount, Float:procent)
{
	return floatround((amount / 100 * procent));
}
//==============================================================================
// SetPlayerPosEx(playerid, Float:posX, Float:posY, Float:posZ, Interior = 0, World = 0);
// Used to set the position of a player with optional interiorid and worldid parameters
//==============================================================================
stock SetPlayerPosEx(playerid, Float:posX, Float:posY, Float:posZ, Float:angp, Interior, World)
{
	SetPlayerVirtualWorld(playerid, World);
	SetPlayerInterior(playerid, Interior);
	if(Interior == 0 && World == 0 && (posX > 3050.0 || posX < -3050.0 || posY > 3050.0 || posY < -3050.0))
	{
		SetPlayerPos(playerid, posX, posY, posZ+2.0);
	}
	else
	{
		SetPlayerPos(playerid, posX, posY, posZ);
	}
	if(angp != -600.0) { SetPlayerFacingAngle(playerid, angp); }
	SetCameraBehindPlayer(playerid);
	return 1;
}
//==============================================================================
// GetFreeHouseID();
// Used to get the next free house ID. Will return -1 if there is none free.
//==============================================================================
stock GetFreeHouseID()
{
	new file[HOUSEFILE_LENGTH];
    Loop(h, MAX_HOUSES)
    {
        format(file, sizeof(file), FILEPATH, h);
        if(!dini_Exists(file))
        {
            return h;
		}
	}
    return -1;
}
//==============================================================================
// GetTotalHouses();
// Used to get the amount of existing houses.
//==============================================================================
stock GetTotalHouses()
{
	new tmpcount, file[HOUSEFILE_LENGTH];
    Loop(h, MAX_HOUSES)
    {
        format(file, sizeof(file), FILEPATH, h);
        if(dini_Exists(file))
        {
            tmpcount++;
		}
	}
    return tmpcount;
}
stock UpdateHouseText(houseid)
{
	new labeltext[150], file[HOUSEFILE_LENGTH];
	format(file, sizeof(file), FILEPATH, houseid);
	if(dini_Exists(file))
	{
	    if(!strcmp(dini_Get(file, "HouseOwner"), INVALID_HOWNER_NAME, CASE_SENSETIVE))
	    {
			format(labeltext, sizeof(labeltext), LABELTEXT1, GetHouseName(houseid), GetHouseValue(houseid), houseid);
		}
		else
		{
			format(labeltext, sizeof(labeltext), LABELTEXT2, GetHouseName(houseid), GetHouseOwner(houseid), GetHouseValue(houseid), houseid);
		}
		UpdateDynamic3DTextLabelText(HouseLabel[houseid], COLOUR_GREEN, labeltext);
    }
	return 1;
}
//==============================================================================
// FM(amount, Optional(Delimiter));
// Used to format the money (from 100000 to 100,000).
// Credits to mick88
//==============================================================================
stock FM(amount, delimiter[2]=",")
{
	new txt[20];
	format(txt, 20, "$%d", amount);
	new l = strlen(txt);
	if (amount < 0) // -
	{
	  	if (l >= 5) strins(txt, delimiter, l-3);
		if (l >= 8) strins(txt, delimiter, l-6);
		if (l >= 11) strins(txt, delimiter, l-9);
	}
	else
	{
		if (l >= 4) strins(txt, delimiter, l-3);
		if (l >= 7) strins(txt, delimiter, l-6);
		if (l >= 10) strins(txt, delimiter, l-9);
	}
	return txt;
}
//==============================================================================
// AddS(amount);
// By [03]Garsino.
//==============================================================================
stock AddS(amount)
{
	new returnstring[2];
	format(returnstring, 2, "");
	if(amount != 1 && amount != -1)
	{
	    format(returnstring, 2, "s");
	}
	return returnstring;
}
//==============================================================================
// GetSecondsBetweenAction(action);
// By [03]Garsino.
//==============================================================================
/*
stock GetSecondsBetweenAction(action)
{
	return floatround(floatdiv((GetTickCount() - action), 1000), floatround_tozero);
}
*/
//==============================================================================
// DestroyHouseEntrance(houseid, type);
// Destroys the house entrance of a house (pickup or checkpoint).
// Type can be: TYPE_OUT (0) and TYPE_INT (1)
// By [03]Garsino.
//==============================================================================
stock DestroyHouseEntrance(houseid, type)
{
	#if defined GH_USE_CPS
		if(type == TYPE_OUT)
		{
			DestroyDynamicCP(HouseCPOut[houseid]);
			HouseCPOut[houseid] = -600;//задаём несуществующий ID-номер чекпоинта для дома
		}
		if(type == TYPE_INT)
		{
			DestroyDynamicCP(HouseCPInt[houseid]);
			HouseCPInt[houseid] = -600;//задаём несуществующий ID-номер чекпоинта для дома
		}
	#endif
	#if !defined GH_USE_CPS
		if(type == TYPE_OUT)
		{
			DestroyDynamicPickup(HousePickupOut[houseid]);
			HousePickupOut[houseid] = -600;//задаём несуществующий ID-номер пикапа для дома
		}
		if(type == TYPE_INT)
		{
			DestroyDynamicPickup(HousePickupInt[houseid]);
			HousePickupInt[houseid] = -600;//задаём несуществующий ID-номер пикапа для дома
		}
	#endif
	return 1;
}
//==============================================================================
// IsVehicleOccupied(vehicleid);
// Checks if a vehicle is occupied or not.
// By [03]Garsino.
//==============================================================================
stock IsVehicleOccupied(vehicleid)
{
  	Loop(i, MAX_PLAYERS)
	{
		if(IsPlayerInVehicle(i, vehicleid))
		{
			return 1;
		}
	}
	return 0;
}
// © [03]Garsino - Keep The Credits!
forward HouseOneSec();
public HouseOneSec()
{
	new locper;
	for(new i = 0; i < MAX_PLAYERS; i++)//цикл для всех игроков
	{
		if(IsPlayerConnected(i))//дальнейшее выполняем если игрок в коннекте
		{
			locper = GetPlayerVirtualWorld(i);
			if(GetPVarInt(i, "IsInHouse") == 1 && (locper < 1000 || locper > MAX_VW_HOUSE))
			{
				SetPVarInt(i, "IsInHouse", 0);
			}
		
		}
	}
	return 1;
}
forward FCislit(cislo);
public FCislit(cislo)
{
	new para, para22, string[256], string22[4], string33[4];
	strdel(string22, 0, 4);
	strdel(string33, 0, 4);
	format(string, sizeof(string), "%d", cislo);
	para22 = strlen(string);
	if(para22 == 1)
	{
		strmid(string22, string, para22-1, para22, sizeof(string22));
	}
	else
	{
	    strmid(string22, string, para22-1, para22, sizeof(string22));
	    strmid(string33, string, para22-2, para22-1, sizeof(string33));
	}
	para22 = strval(string33);
	if(para22 > 1) { para22 = 0; }
	para22 = para22 * 10 + strval(string22);
	switch(para22)
	{
		case 0,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19: para = 0;
		case 1: para = 1;
		case 2,3,4: para = 2;
	}
	return para;
}

