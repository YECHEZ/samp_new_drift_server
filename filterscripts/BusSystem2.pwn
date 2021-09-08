// ========================================================================== //

// ~~~~~~~~~~~~~~~ ДИНАМИЧЕСКАЯ СИСТЕМА БИЗНЕСОВ ОТ REMARION ~~~~~~~~~~~~~~~~ //
// ________________________ загружено с http://gnr-samp.ru/ _________________ //
// ========================================================================== //

#include <a_samp>

#include <streamer>
#include <MXini>

//==============================================================================
//                            Настройки скрипта
//==============================================================================

#define FS11INS 0 //система денег на сервере:
//                //FS11INS 0 - стандартная система
//                //FS11INS 1 - защищённая система (на PVar)

#undef MAX_PLAYERS
#define MAX_PLAYERS 101 //максимум игроков на сервере + 1 (если 50 игроков, то пишем 51 !!!)

#define BUS_MAX 100 //максимум бизнесов на сервере (от 1 до 300)
#define BUS_PLAY 2 //максимум бизнесов, сколько может купить один игрок (от 1 до 5)
#define BUS_DAY 3 //число суток, сколько бизнес "закреплён" за игроком без права перекупки (от 1 до 5)

//   ВНИМАНИЕ !!! после изменения настроек ОБЯЗАТЕЛЬНО откомпилировать !!!

//==============================================================================

#if (FS11INS < 0)
	#undef FS11INS
	#define FS11INS 0
#endif
#if (FS11INS > 1)
	#undef FS11INS
	#define FS11INS 1
#endif
#if (BUS_MAX < 1)
	#undef BUS_MAX
	#define BUS_MAX 1
#endif
#if (BUS_MAX > 300)
	#undef BUS_MAX
	#define BUS_MAX 300
#endif
#if (BUS_PLAY < 1)
	#undef BUS_PLAY
	#define BUS_PLAY 1
#endif
#if (BUS_PLAY > 5)
	#undef BUS_PLAY
	#define BUS_PLAY 5
#endif
#if (BUS_DAY < 1)
	#undef BUS_DAY
	#define BUS_DAY 1
#endif
#if (BUS_DAY > 5)
	#undef BUS_DAY
	#define BUS_DAY 5
#endif

forward LoadBusSystem();//загрузка системы бизнесов
forward UnloadBusSystem();//выгрузка системы бизнесов
forward DatCor();//коррекция даты
forward TimCor();//коррекция времени
forward ReadCorTime();//чтение файла cortime.ini
forward dopfunction(per);//функция дальнего вызова для чтения коррекции времени
forward OneMin();//1-минутный таймер
forward OneSec();//1-секундный таймер

new Text3D:fantxt;//переменная для хранения 3D-текста с несущесвующим ИД
new dlgcont[MAX_PLAYERS];//контроль ИД диалога
new timecor[8];//переменная коррекции времени 2
new CorTime[5];//переменная коррекции времени 1
new RealName[MAX_PLAYERS][MAX_PLAYER_NAME];//реальный ник игрока
new playspabs[MAX_PLAYERS];//спавн игрока
new playIDbus[MAX_PLAYERS];//ИД бизнеса для игрока
new DelayPickup[MAX_PLAYERS];//задержка вызовов паблика пикапов
new buscount[BUS_MAX];//0- бизнес не создан, 1- бизнес создан
new busidplay[BUS_MAX];//-600- если владелец бизнеса офф-лайн, ИД игрока- если владелец бизнеса он-лайн
new busmoney[BUS_MAX];//счётчик минут бизнеса (если игрок он-лайн)
new busname[BUS_MAX][64];//название бизнеса
new busplayname[BUS_MAX][MAX_PLAYER_NAME];//имя владельца бизнеса
new buscost[BUS_MAX];//стоимость бизнеса
new busminute[BUS_MAX];//через сколько минут бизнес будет приносить доход
new busincome[BUS_MAX];//доход от бизнеса
new busday[BUS_MAX];//дата окончания срока без права перекупки
new busvw[BUS_MAX];//виртуальный мир бизнеса
new busint[BUS_MAX];//интерьер бизнеса
new Float:buscordx[BUS_MAX];//координаты бизнеса
new Float:buscordy[BUS_MAX];
new Float:buscordz[BUS_MAX];
new PickupID[BUS_MAX];//массив ИД пикапов
new MapIconID[BUS_MAX];//массив ИД мап-иконок
new Text3D:Nbus[BUS_MAX];//массив ИД 3D-текстов
new timeronemin;//переменная 1-минутного таймера
new timeronesec;//переменная 1-секундного таймера
new busdlgcon[MAX_PLAYERS];//переменная контроля диалогов

public OnFilterScriptInit()
{
	fantxt = Create3DTextLabel(" ",0xFFFFFFAA,0.000,0.000,-4.000,18.0,0,1);//создаём 3D-текст с несущесвующим ИД
	for(new i; i < MAX_PLAYERS; i++)//цикл для всех игроков
	{
		dlgcont[i] = -600;//не существующий ИД диалога
	}
	LoadBusSystem();//загрузка системы бизнесов
	timeronemin = SetTimer("OneMin", 59981, 1);//запуск 1-минутного таймера
	timeronesec = SetTimer("OneSec", 993, 1);//запуск 1-секундного таймера
	return 1;
}

public OnFilterScriptExit()
{
	Delete3DTextLabel(fantxt);//удаляем 3D-текст с несущесвующим ИД
	KillTimer(timeronesec);//остановка 1-секундного таймера
	KillTimer(timeronemin);//остановка 1-минутного таймера
	UnloadBusSystem();//выгрузка системы бизнесов
	return 1;
}

public OnPlayerConnect(playerid)
{
	busdlgcon[playerid] = 0;//обнуляем контроль диалогов
	dlgcont[playerid] = -600;//не существующий ИД диалога
	playspabs[playerid] = 0;//игрок не заспавнился
	playIDbus[playerid] = -600;//не существующий ИД бизнеса для игрока
	new pname[MAX_PLAYER_NAME];
	GetPlayerName(playerid, pname, sizeof(pname));
	strdel(RealName[playerid], 0, MAX_PLAYER_NAME);//очистить реальный ник игрока
	new aa333[64];//доработка для использования Русских ников
	format(aa333, sizeof(aa333), "%s", pname);//доработка для использования Русских ников
	strcat(RealName[playerid], aa333);//запомнить реальный ник игрока (доработка для использования Русских ников)
//	strcat(RealName[playerid], pname);//запомнить реальный ник игрока
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	playspabs[playerid] = 0;//игрок не заспавнился
	for(new j; j < BUS_MAX; j++)//цикл для всех бизнесов
	{
		if(buscount[j] == 1 && strcmp(RealName[playerid], busplayname[j], false) == 0)//если бизнес существует,
		{//и это бизнес игрока, то:
			busidplay[j] = -600;//даём бизнесу несуществующий ИД игрока
		}
	}
	playIDbus[playerid] = -600;//не существующий ИД бизнеса для игрока
	dlgcont[playerid] = -600;//не существующий ИД диалога
	busdlgcon[playerid] = 0;//обнуляем контроль диалогов
	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(playspabs[playerid] == 0)//если игрок ещё не заспавнился, то:
	{
		for(new j; j < BUS_MAX; j++)//цикл для всех бизнесов
		{
			if(buscount[j] == 1 && strcmp(RealName[playerid], busplayname[j], false) == 0)//если бизнес существует,
			{//и это бизнес игрока, то:
				busidplay[j] = playerid;//даём бизнесу ИД он-лайн игрока - владельца бизнеса
			}
		}
	}
	playspabs[playerid] = 1;//игрок заспавнился
	return 1;
}

stock ini_GetKey( line[] )
{
	new keyRes[256];
	keyRes[0] = 0;
    if ( strfind( line , "=" , true ) == -1 ) return keyRes;
    strmid( keyRes , line , 0 , strfind( line , "=" , true ) , sizeof( keyRes) );
    return keyRes;
}

stock ini_GetValue( line[] )
{
	new valRes[256];
	valRes[0]=0;
	if ( strfind( line , "=" , true ) == -1 ) return valRes;
	strmid( valRes , line , strfind( line , "=" , true )+1 , strlen( line ) , sizeof( valRes ) );
	return valRes;
}

strtok(const string[], &index)
{
	new length = strlen(string);
	while ((index < length) && (string[index] <= ' '))
	{
		index++;
	}

	new offset = index;
	new result[30];
	while ((index < length) && (string[index] > ' ') && ((index - offset) < (sizeof(result) - 1)))
	{
		result[index - offset] = string[index];
		index++;
	}
	result[index - offset] = EOS;
	return result;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if(GetPVarInt(playerid, "CComAc7") < 0)
	{
		new dopcis, sstr[256];
		dopcis = FCislit(GetPVarInt(playerid, "CComAc7"));
		switch(dopcis)
		{
			case 0: format(sstr, sizeof(sstr), " Спам в чате (или в командах) !   Попробуйте через %d секунд !", GetPVarInt(playerid, "CComAc7") * -1);
			case 1: format(sstr, sizeof(sstr), " Спам в чате (или в командах) !   Попробуйте через %d секунду !", GetPVarInt(playerid, "CComAc7") * -1);
			case 2: format(sstr, sizeof(sstr), " Спам в чате (или в командах) !   Попробуйте через %d секунды !", GetPVarInt(playerid, "CComAc7") * -1);
		}
		SendClientMessage(playerid, 0xFF0000FF, sstr);
		return 1;
	}
	SetPVarInt(playerid, "CComAc7", GetPVarInt(playerid, "CComAc7") + 1);
	new idx;
	idx = 0;
	new string[256];
	new sendername[MAX_PLAYER_NAME];
	new cmd[256];
	new tmp[256];
	cmd = strtok(cmdtext, idx);
	if(strcmp(cmd, "/helpbus", true) == 0)
	{
		if(IsPlayerAdmin(playerid))
		{
			SendClientMessage(playerid, 0x00FFFFFF, " -------------------------- Система бизнесов -------------------------- ");
			SendClientMessage(playerid, 0x00FFFFFF, "   /helpbus - помощь по командам BusSystem");
			SendClientMessage(playerid, 0x00FFFFFF, "   /createbus - создать бизнес");
			SendClientMessage(playerid, 0x00FFFFFF, "   /removebus - удалить бизнес по его ID");
			SendClientMessage(playerid, 0x00FFFFFF, "   /removebusall - удалить все бизнесы");
			SendClientMessage(playerid, 0x00FFFFFF, "   /gotobus - телепортироваться к бизнесу по его ID");
			SendClientMessage(playerid, 0x00FFFFFF, "   /reloadbus - перезагрузка системы бизнесов");
			SendClientMessage(playerid, 0x00FFFFFF, " --------------------------------------------------------------------------------- ");
		}
		else
		{
			SendClientMessage(playerid, 0xFF0000FF, " У Вас нет прав на использование этой команды !");
		}
		return 1;
	}
	if(strcmp(cmd, "/createbus", true) == 0)
	{
		if(IsPlayerAdmin(playerid))
		{
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, 0x00FFFFFF, " Используйте: /createbus [стоимость(100-1000000 $)] [число минут, через");
				SendClientMessage(playerid, 0x00FFFFFF, " которое бизнес будет приносить доход(10-120)] [доход от бизнеса");
				SendClientMessage(playerid, 0x00FFFFFF, " за минуты он-лайн игры(100-1000000 $)] [название бизнеса(от 3 до 32 символов)]");
				return 1;
			}
			new para1 = strval(tmp);
			if(para1 < 100 || para1 > 1000000)
			{
				SendClientMessage(playerid, 0xFF0000FF, " Стоимость от 100 $ до 1000000 $ !");
				return 1;
			}
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, 0xFF0000FF, " /createbus [стоимость] [число минут] [доход] [название бизнеса] !");
				return 1;
			}
			new para2 = strval(tmp);
			if(para2 < 10 || para2 > 120)
			{
				SendClientMessage(playerid, 0xFF0000FF, " Число минут от 10 до 120 !");
				return 1;
			}
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, 0xFF0000FF, " /createbus [стоимость] [число минут] [доход] [название бизнеса] !");
				return 1;
			}
			new para3 = strval(tmp);
			if(para3 < 100 || para3 > 1000000)
			{
				SendClientMessage(playerid, 0xFF0000FF, " Доход от 100 $ до 1000000 $ !");
				return 1;
			}
			new length = strlen(cmdtext);
			while ((idx < length) && (cmdtext[idx] <= ' '))
			{
				idx++;
			}
			new offset = idx;
			new result[128];
			while ((idx < length) && ((idx - offset) < (sizeof(result) - 1)))
			{
				result[idx - offset] = cmdtext[idx];
				idx++;
			}
			result[idx - offset] = EOS;
			if(strlen(result) < 3 || strlen(result) > 32)
			{
				SendClientMessage(playerid, 0xFF0000FF, " Название от 3 до 32 символов !");
				return 1;
			}
//------------------------------------------------------------------------------
//если убрать комментарий, то: безнесы можно будет создавать ТОЛЬКО в 0-м интерьере, и на основной карте !
/*
			if(GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0)
			{
				SendClientMessage(playerid, 0xFF0000FF, " Бизнес можно создать только в 0-м интерьере, и на основной карте !");
				return 1;
			}
*/
//------------------------------------------------------------------------------
			new para4 = 0;
			new para5 = 0;
			while(para4 < BUS_MAX)
			{
				if(buscount[para4] == 0)
				{
					para5 = 1;
					break;
				}
				para4++;
			}
			if(para5 == 0)
			{
				SendClientMessage(playerid, 0xFF0000FF, " Превышен лимит создания бизнесов !");
				SendClientMessage(playerid, 0xFF0000FF, " Для продолжения - увеличьте максимум бизнесов на сервере !");
				return 1;
			}
			buscount[para4] = 1;//создаём бизнес
			busvw[para4] = GetPlayerVirtualWorld(playerid);//задаём виртуальный мир бизнеса
			busint[para4] = GetPlayerInterior(playerid);//задаём интерьер бизнеса
			GetPlayerPos(playerid, buscordx[para4], buscordy[para4], buscordz[para4]);//задаём координаты бизнеса
			strdel(busname[para4], 0, 64);//задаём название бизнеса
			strcat(busname[para4], result);
			strdel(busplayname[para4], 0, MAX_PLAYER_NAME);//удаляем имя владельца бизнеса
			strcat(busplayname[para4], "*** INV_PL_ID");
		    buscost[para4] = para1;//задаём стоимость бизнеса
		    busminute[para4] = para2;//задаём, через сколько минут бизнес будет приносить доход
		    busincome[para4] = para3;//задаём доход от бизнеса
		    busday[para4] = 0;//даём бизнесу право на его перекупку (покупку)
			busmoney[para4] = busminute[para4];//копируем в счётчик минут бизнеса - минуты бизнеса

    		new file, f[256];//запись бизнеса в файл
	    	format(f, 256, "bussystem/%i.ini", para4);
			file = ini_createFile(f);
			if(file >= 0)
			{
		    	ini_setString(file, "BusName", busname[para4]);
		    	ini_setString(file, "PlayName", busplayname[para4]);
		    	ini_setInteger(file, "Cost", buscost[para4]);
		    	ini_setInteger(file, "Minute", busminute[para4]);
		    	ini_setInteger(file, "Income", busincome[para4]);
		    	ini_setInteger(file, "Day", busday[para4]);
		    	ini_setInteger(file, "BusVW", busvw[para4]);
		    	ini_setInteger(file, "BusInt", busint[para4]);
		    	ini_setFloat(file, "CordX", buscordx[para4]);
		    	ini_setFloat(file, "CordY", buscordy[para4]);
		    	ini_setFloat(file, "CordZ", buscordz[para4]);
		    	ini_setInteger(file, "Count", busmoney[para4]);
				ini_closeFile(file);
			}

			CallRemoteFunction("GPSrfun", "iiisifff", 2, 1, para4, busplayname[para4],
			busvw[para4], buscordx[para4], buscordy[para4], buscordz[para4]);
			PickupID[para4] = CreateDynamicPickup(1274, 1, buscordx[para4], buscordy[para4], buscordz[para4],
			busvw[para4], busint[para4], -1, 100.0);//создаём пикап бизнеса
			MapIconID[para4] = CreateDynamicMapIcon(buscordx[para4], buscordy[para4], buscordz[para4], 52, -1,
			busvw[para4], busint[para4], -1, 200.0);//создаём мап-иконку бизнеса
			format(string, sizeof(string), "Бизнес: %s\nID: %d", busname[para4], para4);
			Nbus[para4] = CreateDynamic3DTextLabel(string, 0x00FF00FF, buscordx[para4], buscordy[para4], buscordz[para4]+0.70, 50,
			INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, busvw[para4], busint[para4], -1);//создаём 3D-текст бизнеса
			GetPlayerName(playerid, sendername, sizeof(sendername));
			new aa333[64];//доработка для использования Русских ников
			format(aa333, sizeof(aa333), "%s", sendername);//доработка для использования Русских ников
			printf("[BusSystem] Админ %s [%d] создал бизнес ID: %d .", aa333, playerid, para4);//доработка для использования Русских ников
//			printf("[BusSystem] Админ %s [%d] создал бизнес ID: %d .", sendername, playerid, para4);
			format(string, sizeof(string), " Бизнес ID: %d успешно создан.", para4);
			SendClientMessage(playerid, 0xFFFF00FF, string);
		}
		else
		{
			SendClientMessage(playerid, 0xFF0000FF, " У Вас нет прав на использование этой команды !");
		}
		return 1;
	}
	if(strcmp(cmd, "/removebus", true) == 0)
	{
		if(IsPlayerAdmin(playerid))
		{
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, 0x00FFFFFF, " Используйте: /removebus [ID бизнеса]");
				return 1;
			}
			new para1 = strval(tmp);
			if(para1 < 0 || para1 >= BUS_MAX)
			{
				SendClientMessage(playerid, 0xFF0000FF, " Бизнеса с таким ID не существует !");
				return 1;
			}
			format(string, sizeof(string), "bussystem/%i.ini", para1);
			if(fexist(string) || buscount[para1] == 1)//если файл или сам бизнес существует, то:
			{
				DestroyDynamicPickup(PickupID[para1]);//удаляем пикап бизнеса
				if(busday[para1] == 0)//если есть мап-иконка бизнеса, то:
				{
					DestroyDynamicMapIcon(MapIconID[para1]);//удаляем мап-иконку бизнеса
				}
				DestroyDynamic3DTextLabel(Nbus[para1]);//удаляем 3D-текст бизнеса
				if(fexist(string))//если файл существует, то:
				{
                    fremove(string);//удаляем файл
				}
				buscount[para1] = 0;//удаляем бизнес
				strdel(busplayname[para1], 0, MAX_PLAYER_NAME);//удаляем имя владельца бизнеса
				strcat(busplayname[para1], "*** INV_PL_ID");
				CallRemoteFunction("GPSrfun", "iiisifff", 2, 0, para1, busplayname[para1],
				0, 0.0, 0.0, 0.0);
				PickupID[para1] = -600;//задаём несуществующий ID-номер пикапа для бизнеса
				GetPlayerName(playerid, sendername, sizeof(sendername));
				new aa333[64];//доработка для использования Русских ников
				format(aa333, sizeof(aa333), "%s", sendername);//доработка для использования Русских ников
				printf("[BusSystem] Админ %s [%d] удалил бизнес ID: %d .", aa333, playerid, para1);//доработка для использования Русских ников
//				printf("[BusSystem] Админ %s [%d] удалил бизнес ID: %d .", sendername, playerid, para1);
				format(string, sizeof(string), " Бизнес ID: %d успешно удалён.", para1);
				SendClientMessage(playerid, 0xFF0000FF, string);
			}
			else//если ни файл, и ни сам бизнес не существуют, то:
			{
				SendClientMessage(playerid, 0xFF0000FF, " Бизнеса с таким ID не существует !");
			}
		}
		else
		{
			SendClientMessage(playerid, 0xFF0000FF, " У Вас нет прав на использование этой команды !");
		}
		return 1;
	}
	if(strcmp(cmd, "/removebusall", true) == 0)
	{
		if(IsPlayerAdmin(playerid))
		{
			new para1 = 0;
			for(new i; i < BUS_MAX; i++)
			{
				format(string, sizeof(string), "bussystem/%i.ini", i);
				if(fexist(string) || buscount[i] == 1)//если файл или сам бизнес существует, то:
				{
					para1 = 1;
					DestroyDynamicPickup(PickupID[i]);//удаляем пикап бизнеса
					if(busday[i] == 0)//если есть мап-иконка бизнеса, то:
					{
						DestroyDynamicMapIcon(MapIconID[i]);//удаляем мап-иконку бизнеса
					}
					DestroyDynamic3DTextLabel(Nbus[i]);//удаляем 3D-текст бизнеса
					if(fexist(string))//если файл существует, то:
					{
                    	fremove(string);//удаляем файл
					}
					buscount[i] = 0;//удаляем бизнес
					strdel(busplayname[i], 0, MAX_PLAYER_NAME);//удаляем имя владельца бизнеса
					strcat(busplayname[i], "*** INV_PL_ID");
					PickupID[i] = -600;//задаём несуществующий ID-номер пикапа для бизнеса
				}
				CallRemoteFunction("GPSrfun", "iiisifff", 2, 0, i, "*** INV_PL_ID",
				0, 0.0, 0.0, 0.0);
			}
			if(para1 == 1)
			{
				GetPlayerName(playerid, sendername, sizeof(sendername));
				new aa333[64];//доработка для использования Русских ников
				format(aa333, sizeof(aa333), "%s", sendername);//доработка для использования Русских ников
				printf("[BusSystem] Админ %s [%d] удалил все бизнесы.", aa333, playerid);//доработка для использования Русских ников
//				printf("[BusSystem] Админ %s [%d] удалил все бизнесы.", sendername, playerid);
				SendClientMessage(playerid, 0xFF0000FF, " Все бизнесы были успешно удалены.");
			}
			else
			{
				SendClientMessage(playerid, 0xFF0000FF, " На сервере не создано ни одного бизнеса !");
			}
		}
		else
		{
			SendClientMessage(playerid, 0xFF0000FF, " У Вас нет прав на использование этой команды !");
		}
		return 1;
	}
	if(strcmp(cmd, "/gotobus", true) == 0)
	{
		if(IsPlayerAdmin(playerid))
		{
#if (FS11INS == 1)
			if(GetPVarInt(playerid, "SecPris") > 0)
			{
				SendClientMessage(playerid, 0xFF0000FF, " В тюрьме команда не работает !");
				return 1;
			}
#endif
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, 0x00FFFFFF, " Используйте: /gotobus [ID бизнеса]");
				return 1;
			}
			new para1 = strval(tmp);
			if(para1 < 0 || para1 >= BUS_MAX)
			{
				SendClientMessage(playerid, 0xFF0000FF, " Бизнеса с таким ID не существует !");
				return 1;
			}
			if(buscount[para1] == 1)//если бизнес существует, то:
			{
				SetPlayerVirtualWorld(playerid, busvw[para1]);
 				SetPlayerInterior(playerid, busint[para1]);
				SetPlayerPos(playerid, buscordx[para1], buscordy[para1]+2, buscordz[para1]+1);
				GetPlayerName(playerid, sendername, sizeof(sendername));
				new aa333[64];//доработка для использования Русских ников
				format(aa333, sizeof(aa333), "%s", sendername);//доработка для использования Русских ников
				printf("[BusSystem] Админ %s [%d] телепортировался к бизнесу ID: %d .", aa333, playerid, para1);//доработка для использования Русских ников
//				printf("[BusSystem] Админ %s [%d] телепортировался к бизнесу ID: %d .", sendername, playerid, para1);
				format(string, sizeof(string), " Вы телепортировались к бизнесу ID: %d .", para1);
				SendClientMessage(playerid, 0x00FF00FF, string);
			}
			else//если бизнес не существуют, то:
			{
				SendClientMessage(playerid, 0xFF0000FF, " Бизнеса с таким ID не существует !");
			}
		}
		else
		{
			SendClientMessage(playerid, 0xFF0000FF, " У Вас нет прав на использование этой команды !");
		}
		return 1;
	}
	if(strcmp(cmd, "/reloadbus", true) == 0)
	{
		if(IsPlayerAdmin(playerid))
		{
			GetPlayerName(playerid, sendername, sizeof(sendername));
			new aa333[64];//доработка для использования Русских ников
			format(aa333, sizeof(aa333), "%s", sendername);//доработка для использования Русских ников
			printf("[BusSystem] Админ %s [%d] начал перезагрузку системы бизнесов.", aa333, playerid);//доработка для использования Русских ников
//			printf("[BusSystem] Админ %s [%d] начал перезагрузку системы бизнесов.", sendername, playerid);
			format(string, sizeof(string), " Админ %s [%d] начал перезагрузку системы бизнесов.", sendername, playerid);
			SendClientMessageToAll(0xFF0000FF, string);
			SetTimerEx("reloadbus1", 1000, 0, "i", playerid);
		}
		else
		{
			SendClientMessage(playerid, 0xFF0000FF, " У Вас нет прав на использование этой команды !");
		}
		return 1;
	}
	return 0;
}

forward reloadbus1(playerid);
public reloadbus1(playerid)
{
	UnloadBusSystem();//выгрузка системы бизнесов
	SetTimerEx("reloadbus2", 1000, 0, "i", playerid);
    return 1;
}

forward reloadbus2(playerid);
public reloadbus2(playerid)
{
	LoadBusSystem();//загрузка системы бизнесов
	SetTimerEx("reloadbus3", 1000, 0, "i", playerid);
    return 1;
}

forward reloadbus3(playerid);
public reloadbus3(playerid)
{
	new string[256];
	new sendername[MAX_PLAYER_NAME];
	GetPlayerName(playerid, sendername, sizeof(sendername));
	new aa333[64];//доработка для использования Русских ников
	format(aa333, sizeof(aa333), "%s", sendername);//доработка для использования Русских ников
	printf("[BusSystem] Админ %s [%d] перезагрузил систему бизнесов.", aa333, playerid);//доработка для использования Русских ников
//	printf("[BusSystem] Админ %s [%d] перезагрузил систему бизнесов.", sendername, playerid);
	format(string, sizeof(string), " Админ %s [%d] перезагрузил систему бизнесов.", sendername, playerid);
	SendClientMessageToAll(0xFF0000FF, string);
    return 1;
}

public OnPlayerPickUpDynamicPickup(playerid, pickupid)
{
	if(DelayPickup[playerid] == 0)
	{
		DelayPickup[playerid]++;
		return 1;
	}
	if(DelayPickup[playerid] == 1)
	{
		DelayPickup[playerid]++;
		return 1;
	}
	if(DelayPickup[playerid] == 2)
	{
		DelayPickup[playerid] = 0;
	}
    if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
	{
		new para1 = 0;
		new para2 = 0;
		while(para1 < BUS_MAX)
		{
			if(PickupID[para1] == pickupid)
			{
				para2 = 1;
				break;
			}
			para1++;
		}
		if(para2 == 1)
		{
			new string[2048];
			playIDbus[playerid] = para1;//запоминаем ИД бизнеса для игрока
			if(busday[para1] == 0 && strcmp(RealName[playerid], busplayname[para1], false) != 0)
			{//если у бизнеса есть право на его перекупку, и этот бизнес не игрока, то:
				format(string, sizeof(string), "{ADFF2F}Название бизнеса: %s\nСтоимость бизнеса: %d $\n\nЭтот бизнес будет Вам приносить доход: %d $\
				\nкаждые %d минут Вашего он-лайн отыгранного времени.\n\nВнимание ! Через %d суток, со дня покупки этого бизнеса,\
				\nэтот бизнес сможет перекупить любой другой игрок !", busname[para1], buscost[para1], busincome[para1],
				busminute[para1], BUS_DAY);
				ShowPlayerDialog(playerid, 8001, 0, "Информация.", string, "Купить", "Отмена");
				dlgcont[playerid] = 8001;
			}
			if(busday[para1] != 0 && strcmp(RealName[playerid], busplayname[para1], false) != 0)
			{//если у бизнеса нет права на его перекупку, и этот бизнес не игрока, то:
				format(string, sizeof(string), "{ADFF2F}Название бизнеса: %s\nВладелец бизнеса: %s\nСтоимость бизнеса: %d $", busname[para1],
				busplayname[para1], buscost[para1]);
				ShowPlayerDialog(playerid, 8000, 0, "Информация.", string, "OK", "");
				dlgcont[playerid] = 8000;
			}
			if(strcmp(RealName[playerid], busplayname[para1], false) == 0)
			{//если этот бизнес - бизнес игрока, то:
				format(string, sizeof(string), "{ADFF2F}Название бизнеса: %s\nСтоимость бизнеса: %d $\n\nЭтот бизнес Вам приносит доход: %d $\
				\nкаждые %d минут Вашего он-лайн отыгранного времени.\n\nВы хотите продать этот бизнес ?", busname[para1], buscost[para1],
				busincome[para1], busminute[para1]);
				ShowPlayerDialog(playerid, 8002, 0, "Информация.", string, "Продать", "Отмена");
				dlgcont[playerid] = 8002;
			}
		}
	}
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == 8000)
    {
		if(dialogid != dlgcont[playerid])
		{
			dlgcont[playerid] = -600;//не существующий ИД диалога
			return 1;
		}
		dlgcont[playerid] = -600;//не существующий ИД диалога
		busdlgcon[playerid]++;//контроль диалогов +1
		playIDbus[playerid] = -600;//не существующий ИД бизнеса для игрока
		return 1;
	}
	if(dialogid == 8001)
    {
		if(dialogid != dlgcont[playerid])
		{
			dlgcont[playerid] = -600;//не существующий ИД диалога
			return 1;
		}
		dlgcont[playerid] = -600;//не существующий ИД диалога
		busdlgcon[playerid]++;//контроль диалогов +1
        if(response)
		{
			new string[256];
#if (FS11INS == 0)
			if(GetPlayerMoney(playerid) < buscost[playIDbus[playerid]])//если у игрока недостаточно денег, то:
			{
				busdlgcon[playerid]--;//контроль диалогов -1
				ShowPlayerDialog(playerid, 8000, 0, "Информация.", "{ADFF2F}У Вас недостаточно денег для покупки этого бизнеса !", "OK", "");
				dlgcont[playerid] = 8000;
				return 1;
			}
#endif
#if (FS11INS == 1)
			if(GetPVarInt(playerid, "PlMon") < buscost[playIDbus[playerid]])//если у игрока недостаточно денег, то:
			{
				busdlgcon[playerid]--;//контроль диалогов -1
				ShowPlayerDialog(playerid, 8000, 0, "Информация.", "{ADFF2F}У Вас недостаточно денег для покупки этого бизнеса !", "OK", "");
				dlgcont[playerid] = 8000;
				return 1;
			}
#endif
			new para1 = 0;
			for(new i; i < BUS_MAX; i++)//подсчёт числа уже купленных бизнесов
			{
				if(buscount[i] == 1 && strcmp(RealName[playerid], busplayname[i], false) == 0) { para1++; }
			}
			if(para1 >= BUS_PLAY)
			{
				format(string, sizeof(string), "{ADFF2F}У вас уже есть %d бизнеса !   Что бы купить этот бизнес -\
				\nпродайте хотя бы один из своих существующих бизнесов !", para1);
				busdlgcon[playerid]--;//контроль диалогов -1
				ShowPlayerDialog(playerid, 8000, 0, "Информация.", string, "OK", "");
				dlgcont[playerid] = 8000;
				return 1;
			}
			if(strcmp(busplayname[playIDbus[playerid]], "*** INV_PL_ID", false) != 0 && busday[playIDbus[playerid]] != 0)
			{//если в момент покупки, покупаемый бизнес успел купить другой игрок, то:
				SendClientMessage(playerid, 0xFF0000FF, " Этот бизнес уже принадлежит другому игроку !");
				format(string, sizeof(string), "{ADFF2F}Название бизнеса: %s\nВладелец бизнеса: %s\nСтоимость бизнеса: %d $", busname[playIDbus[playerid]],
				busplayname[playIDbus[playerid]], buscost[playIDbus[playerid]]);
				busdlgcon[playerid]--;//контроль диалогов -1
				ShowPlayerDialog(playerid, 8000, 0, "Информация.", string, "OK", "");
				dlgcont[playerid] = 8000;
				return 1;
			}
			strdel(busplayname[playIDbus[playerid]], 0, MAX_PLAYER_NAME);//изменение имени владельца бизнеса
			strcat(busplayname[playIDbus[playerid]], RealName[playerid]);
			busday[playIDbus[playerid]] = 99;//временная блокировка возможности перекупки бизнеса
			new para2;
#if (FS11INS == 0)
			para2 = GetPlayerMoney(playerid);
			SetPVarInt(playerid, "MonControl", 1);
			GivePlayerMoney(playerid, - buscost[playIDbus[playerid]]);//списывание денег со счёта игрока
#endif
#if (FS11INS == 1)
			para2 = GetPVarInt(playerid, "PlMon");
			SetPVarInt(playerid, "PlMon", GetPVarInt(playerid, "PlMon") - buscost[playIDbus[playerid]]);//списывание денег со счёта игрока
#endif
			gettime(timecor[0], timecor[1]);
			getdate(timecor[2], timecor[3], timecor[4]);
			TimCor();//коррекция времени
			DatCor();//коррекция даты
			new per22;//вычисление даты окончания срока без права перекупки
			per22 = BUS_DAY + timecor[4];
			if(per22 > 28 && timecor[7] == 0 && timecor[3] == 2)
			{
				per22 = per22 - 28;
			}
			if(per22 > 29 && timecor[7] == 1 && timecor[3] == 2)
			{
				per22 = per22 - 29;
			}
			if(per22 > 30 && (timecor[3] == 4 || timecor[3] == 6 || timecor[3] == 9 || timecor[3] == 11))
			{
				per22 = per22 - 30;
			}
			if(per22 > 31 && (timecor[3] == 1 || timecor[3] == 3 || timecor[3] == 5 || timecor[3] == 7 || timecor[3] == 8 || timecor[3] == 10 || timecor[3] == 12))
			{
				per22 = per22 - 31;
			}
			busidplay[playIDbus[playerid]] = playerid;//даём бизнесу ИД он-лайн игрока - владельца бизнеса
			busmoney[playIDbus[playerid]] = busminute[playIDbus[playerid]];//копируем в счётчик минут бизнеса - минуты бизнеса
			busday[playIDbus[playerid]] = per22;//изменение даты окончания срока без права перекупки
			new file, f[256];//записываем изменения в файл
			format(f, 256, "bussystem/%i.ini", playIDbus[playerid]);
			file = ini_openFile(f);
			if(file >= 0)
			{
		    	ini_setString(file, "PlayName", busplayname[playIDbus[playerid]]);
		    	ini_setInteger(file, "Day", busday[playIDbus[playerid]]);
		    	ini_setInteger(file, "Count", busmoney[playIDbus[playerid]]);
				ini_closeFile(file);
			}
			CallRemoteFunction("GPSrfun", "iiisifff", 2, 1, playIDbus[playerid], busplayname[playIDbus[playerid]],
			busvw[playIDbus[playerid]], buscordx[playIDbus[playerid]], buscordy[playIDbus[playerid]], buscordz[playIDbus[playerid]]);
			DestroyDynamicMapIcon(MapIconID[playIDbus[playerid]]);//удаляем мап-иконку бизнеса
			printf("[BusSystem] Игрок %s [%d] купил бизнес %s [ID: %d] .", RealName[playerid], playerid, busname[playIDbus[playerid]], playIDbus[playerid]);
			format(string, sizeof(string), " Игрок %s [%d] купил бизнес %s .", RealName[playerid], playerid, busname[playIDbus[playerid]]);
			SendClientMessageToAll(0x00FFFFFF, string);
			printf("[moneysys] Предыдущая сумма игрока %s [%d] : %d $", RealName[playerid], playerid, para2);
		}
		playIDbus[playerid] = -600;//не существующий ИД бизнеса для игрока
		return 1;
	}
	if(dialogid == 8002)
    {
		if(dialogid != dlgcont[playerid])
		{
			dlgcont[playerid] = -600;//не существующий ИД диалога
			return 1;
		}
		dlgcont[playerid] = -600;//не существующий ИД диалога
		busdlgcon[playerid]++;//контроль диалогов +1
        if(response)
		{
			new string[256];
			new para1;
#if (FS11INS == 0)
			para1 = GetPlayerMoney(playerid);
			SetPVarInt(playerid, "MonControl", 1);
			GivePlayerMoney(playerid, buscost[playIDbus[playerid]]);//возврат денег игроку
#endif
#if (FS11INS == 1)
			para1 = GetPVarInt(playerid, "PlMon");
			SetPVarInt(playerid, "PlMon", GetPVarInt(playerid, "PlMon") + buscost[playIDbus[playerid]]);//возврат денег игроку
#endif
			busidplay[playIDbus[playerid]] = -600;//даём бизнесу несуществующий ИД игрока
			busmoney[playIDbus[playerid]] = busminute[playIDbus[playerid]];//копируем в счётчик минут бизнеса - минуты бизнеса
			strdel(busplayname[playIDbus[playerid]], 0, MAX_PLAYER_NAME);//изменение имени владельца бизнеса
			strcat(busplayname[playIDbus[playerid]], "*** INV_PL_ID");
			if(busday[playIDbus[playerid]] != 0)//если бизнес без права его перекупки, то:
			{
				MapIconID[playIDbus[playerid]] = CreateDynamicMapIcon(buscordx[playIDbus[playerid]], buscordy[playIDbus[playerid]],
				buscordz[playIDbus[playerid]], 52, -1, busvw[playIDbus[playerid]], busint[playIDbus[playerid]], -1, 200.0);//создаём мап-иконку бизнеса
			}
			busday[playIDbus[playerid]] = 0;//изменение даты окончания срока без права перекупки
			new file, f[256];//записываем изменения в файл
			format(f, 256, "bussystem/%i.ini", playIDbus[playerid]);
			file = ini_openFile(f);
			if(file >= 0)
			{
		    	ini_setString(file, "PlayName", busplayname[playIDbus[playerid]]);
		    	ini_setInteger(file, "Day", busday[playIDbus[playerid]]);
		    	ini_setInteger(file, "Count", busmoney[playIDbus[playerid]]);
				ini_closeFile(file);
			}
			CallRemoteFunction("GPSrfun", "iiisifff", 2, 1, playIDbus[playerid], busplayname[playIDbus[playerid]],
			busvw[playIDbus[playerid]], buscordx[playIDbus[playerid]], buscordy[playIDbus[playerid]], buscordz[playIDbus[playerid]]);
			printf("[BusSystem] Игрок %s [%d] продал бизнес %s [ID: %d] .", RealName[playerid], playerid, busname[playIDbus[playerid]], playIDbus[playerid]);
			format(string, sizeof(string), " Игрок %s [%d] продал бизнес %s .", RealName[playerid], playerid, busname[playIDbus[playerid]]);
			SendClientMessageToAll(0x00FFFFFF, string);
			printf("[moneysys] Предыдущая сумма игрока %s [%d] : %d $", RealName[playerid], playerid, para1);
		}
		playIDbus[playerid] = -600;//не существующий ИД бизнеса для игрока
		return 1;
	}
	return 0;
}

public DatCor()
{
	new Float:flyear;
	timecor[3] = timecor[3] + CorTime[3];//обработка месяца
	timecor[5] = 0;//перенос на год
	if(timecor[3] < 1)
	{
		timecor[3] = 12 + timecor[3];
		timecor[5] = -1;//перенос на год
	}
	if(timecor[3] > 12)
	{
		timecor[3] = timecor[3] - 12;
		timecor[5] = 1;//перенос на год
	}
	timecor[2] = timecor[2] + CorTime[4] + timecor[5];//обработка года
	flyear = float(timecor[2]);
	flyear = floatdiv(flyear, 4);
	flyear = floatfract(flyear);
	if(flyear != 0){timecor[7] = 0;}//НЕ високосный год
	if(flyear == 0){timecor[7] = 1;}//високосный год
	timecor[4] = timecor[4] + CorTime[2] + timecor[6];//обработка числа
	timecor[5] = 0;//перенос на месяц
	if(timecor[4] < 1 && timecor[3] == 3 && timecor[7] == 0)
	{
		timecor[4] = 28 + timecor[4];
		timecor[5] = -1;//перенос на месяц
	}
	if(timecor[4] < 1 && timecor[3] == 3 && timecor[7] == 1)
	{
		timecor[4] = 29 + timecor[4];
		timecor[5] = -1;//перенос на месяц
	}
	if(timecor[4] < 1 && (timecor[3] == 5 || timecor[3] == 7 || timecor[3] == 10 || timecor[3] == 12))
	{
		timecor[4] = 30 + timecor[4];
		timecor[5] = -1;//перенос на месяц
	}
	if(timecor[4] < 1 && (timecor[3] == 2 || timecor[3] == 4 || timecor[3] == 6 || timecor[3] == 8 || timecor[3] == 9 || timecor[3] == 11 || timecor[3] == 1))
	{
		timecor[4] = 31 + timecor[4];
		timecor[5] = -1;//перенос на месяц
	}
	if(timecor[4] > 28 && timecor[3] == 2 && timecor[7] == 0)
	{
		timecor[4] = timecor[4] - 28;
		timecor[5] = 1;//перенос на месяц
	}
	if(timecor[4] > 29 && timecor[3] == 2 && timecor[7] == 1)
	{
		timecor[4] = timecor[4] - 29;
		timecor[5] = 1;//перенос на месяц
	}
	if(timecor[4] > 30 && (timecor[3] == 4 || timecor[3] == 6 || timecor[3] == 9 || timecor[3] == 11))
	{
		timecor[4] = timecor[4] - 30;
		timecor[5] = 1;//перенос на месяц
	}
	if(timecor[4] > 31 && (timecor[3] == 1 || timecor[3] == 3 || timecor[3] == 5 || timecor[3] == 7 || timecor[3] == 8 || timecor[3] == 10 || timecor[3] == 12))
	{
		timecor[4] = timecor[4] - 31;
		timecor[5] = 1;//перенос на месяц
	}
	timecor[3] = timecor[3] + timecor[5];//коррекция месяца
	timecor[5] = 0;//перенос на год
	if(timecor[3] < 1)
	{
		timecor[3] = 12 + timecor[3];
		timecor[5] = -1;//перенос на год
	}
	if(timecor[3] > 12)
	{
		timecor[3] = timecor[3] - 12;
		timecor[5] = 1;//перенос на год
	}
	timecor[2] = timecor[2] + timecor[5];//коррекция года
	return 1;
}

public TimCor()
{
	timecor[1] = timecor[1] + CorTime[1];//обработка минут
	timecor[5] = 0;//перенос на час
	if(timecor[1] < 0)
	{
		timecor[1] = 60 + timecor[1];
		timecor[5] = -1;//перенос на час
	}
	if(timecor[1] > 59)
	{
		timecor[1] = timecor[1] - 60;
		timecor[5] = 1;//перенос на час
	}
	timecor[0] = timecor[0] + CorTime[0] + timecor[5];//обработка часов
	timecor[6] = 0;//перенос на день
	if(timecor[0] < 0)
	{
		timecor[0] = 24 + timecor[0];
		timecor[6] = -1;//перенос на день
	}
	if(timecor[0] > 23)
	{
		timecor[0] = timecor[0] - 24;
		timecor[6] = 1;//перенос на день
	}
	return 1;
}

public ReadCorTime()
{
	new string[256];
	format(string,sizeof(string),"data/cortime.ini");
	if(fexist(string))//если файл существует, то:
	{
		new File: UserFile = fopen(string, io_read);//чтение файла
		new key[ 256 ] , val[ 256 ];
		new Data[ 256 ];
		while ( fread( UserFile , Data , sizeof( Data ) ) )
		{
			key = ini_GetKey( Data );
			if( strcmp( key , "hour" , true ) == 0 ) { val = ini_GetValue( Data ); CorTime[0] = strval( val ); }
			if( strcmp( key , "minute" , true ) == 0 ) { val = ini_GetValue( Data ); CorTime[1] = strval( val ); }
			if( strcmp( key , "day" , true ) == 0 ) { val = ini_GetValue( Data ); CorTime[2] = strval( val ); }
			if( strcmp( key , "month" , true ) == 0 ) { val = ini_GetValue( Data ); CorTime[3] = strval( val ); }
			if( strcmp( key , "year" , true ) == 0 ) { val = ini_GetValue( Data ); CorTime[4] = strval( val ); }
		}
		fclose(UserFile);
	}
	return 1;
}

public dopfunction(per)
{
	SetTimer("ReadCorTime",500,0);//задержка чтения (на время записи файла cortime.ini)
	return 1;
}

public OneMin()//1-минутный таймер
{
	new para1, file, f[256];
	for(new i; i < BUS_MAX; i++)//цикл для всех бизнесов
	{
		if(buscount[i] == 1 && busidplay[i] != -600)//если бизнес существует,
		{//и его владелец он-лайн, то:
			if(IsPlayerConnected(busidplay[i]) && playspabs[busidplay[i]] == 1 &&
			strcmp(RealName[busidplay[i]], busplayname[i], false) == 0)//дополнительная проверка на коннект игрока,
			{//спавн игрока, и его ник (в случае некорректного отключения от скрипта, или если игрок не заспавнился)
				busmoney[i]--;//счётчик минут бизнеса -1
				if(busmoney[i] > 0)//если счётчик минут бизнеса больше нуля, то:
				{
					format(f, 256, "bussystem/%i.ini", i);//записываем изменения в файл
					file = ini_openFile(f);
					if(file >= 0)
					{
				    	ini_setInteger(file, "Count", busmoney[i]);
						ini_closeFile(file);
					}
				}
				if(busmoney[i] <= 0)//если счётчик минут бизнеса меньше или равен нулю, то:
				{
					busmoney[i] = busminute[i];//копируем в счётчик минут бизнеса - минуты бизнеса
					format(f, 256, "bussystem/%i.ini", i);//записываем изменения в файл
					file = ini_openFile(f);
					if(file >= 0)
					{
				    	ini_setInteger(file, "Count", busmoney[i]);
						ini_closeFile(file);
					}
#if (FS11INS == 0)
					para1 = GetPlayerMoney(busidplay[i]);
					SetPVarInt(busidplay[i], "MonControl", 1);
					GivePlayerMoney(busidplay[i], busincome[i]);//прибавление дохода к счёту игрока
#endif
#if (FS11INS == 1)
					para1 = GetPVarInt(busidplay[i], "PlMon");
					SetPVarInt(busidplay[i], "PlMon", GetPVarInt(busidplay[i], "PlMon") + busincome[i]);//прибавление дохода к счёту игрока
#endif
					new string[256];
					printf("[BusSystem] Игрок %s [%d] получил доход %d $ от своего бизнеса %s [ID: %d] .", RealName[busidplay[i]], busidplay[i], busincome[i], busname[i], i);
					format(string, sizeof(string), " Игрок %s [%d] получил доход %d $ от своего бизнеса %s .", RealName[busidplay[i]], busidplay[i], busincome[i], busname[i]);
					SendClientMessageToAll(0x00FFFFFF, string);
					printf("[moneysys] Предыдущая сумма игрока %s [%d] : %d $", RealName[busidplay[i]], busidplay[i], para1);
				}
			}
		}
	}
	return 1;
}

public OneSec()//1-секундный таймер
{
	new string[256];
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			if(busdlgcon[i] > 1)//если контроль диалогов больше 1, то:
			{
				format(string, sizeof(string), "[BusSystem] Игрок %s [%d] был кикнут за чит, мешающий работе сервера !", RealName[i], i);
				print(string);
				SendClientMessageToAll(0xFF0000FF, string);
				SetTimerEx("PlayKick", 300, 0, "i", i);
			}
			busdlgcon[i] = 0;//обнуляем контроль диалогов
		}
	}
	return 1;
}

forward PlayKick(playerid);
public PlayKick(playerid)
{
	Kick(playerid);
	return 1;
}

public LoadBusSystem()//загрузка системы бизнесов
{
	CorTime[0] = 0;//обнуление коррекции времени
	CorTime[1] = 0;
	CorTime[2] = 0;
	CorTime[3] = 0;
	CorTime[4] = 0;

	new count = 0;
    new file, f[256];//чтение всех бизнесов
	for(new i; i < BUS_MAX; i++)
	{
		PickupID[i] = -600;//задаём несуществующий ID-номер пикапа для бизнеса
	    format(f, 256, "bussystem/%i.ini", i);
		file = ini_openFile(f);
		if(file >= 0)
		{
			count++;
			buscount[i] = 1;//бизнес создан (сущесвует)
		    ini_getString(file, "BusName", busname[i]);
		    ini_getString(file, "PlayName", busplayname[i]);
		    ini_getInteger(file, "Cost", buscost[i]);
		    ini_getInteger(file, "Minute", busminute[i]);
		    ini_getInteger(file, "Income", busincome[i]);
		    ini_getInteger(file, "Day", busday[i]);
		    ini_getInteger(file, "BusVW", busvw[i]);
		    ini_getInteger(file, "BusInt", busint[i]);
		    ini_getFloat(file, "CordX", buscordx[i]);
		    ini_getFloat(file, "CordY", buscordy[i]);
		    ini_getFloat(file, "CordZ", buscordz[i]);
		    ini_getInteger(file, "Count", busmoney[i]);
			ini_closeFile(file);
			CallRemoteFunction("GPSrfun", "iiisifff", 2, 1, i, busplayname[i],
			busvw[i], buscordx[i], buscordy[i], buscordz[i]);
		}
		else
		{
			buscount[i] = 0;//бизнес не создан (не сущесвует)
			strdel(busplayname[i], 0, MAX_PLAYER_NAME);//удаляем имя владельца бизнеса
			strcat(busplayname[i], "*** INV_PL_ID");
			busday[i] = 0;//даём бизнесу право на его перекупку (покупку)
			CallRemoteFunction("GPSrfun", "iiisifff", 2, 0, i, busplayname[i],
			0, 0.0, 0.0, 0.0);
		}
	}
	print(" ");
	printf(" %d бизнесов загружено.", count);

	ReadCorTime();//чтение коррекции времени
	gettime(timecor[0], timecor[1]);
	getdate(timecor[2], timecor[3], timecor[4]);
	TimCor();//коррекция времени
	DatCor();//коррекция даты
	new string[256];
	for(new i; i < BUS_MAX; i++)
	{
		busidplay[i] = -600;//владелец бизнеса офф-лайн
		if(busday[i] == timecor[4])//если реальная дата равна дате окончания срока без права перекупки, то:
		{
			busday[i] = 0;//даём бизнесу право на его перекупку,
			format(f, 256, "bussystem/%i.ini", i);//и записываем изменения в файл
			file = ini_openFile(f);
			if(file >= 0)
			{
				ini_setInteger(file, "Day", busday[i]);
				ini_closeFile(file);
			}
		}
		if(buscount[i] == 1)//если бизнес создан, то:
		{
			PickupID[i] = CreateDynamicPickup(1274, 1, buscordx[i], buscordy[i], buscordz[i], busvw[i], busint[i], -1, 100.0);//создаём пикап бизнеса
			if(busday[i] == 0)//если у бизнеса есть право на его перекупку, то:
			{
				MapIconID[i] = CreateDynamicMapIcon(buscordx[i], buscordy[i], buscordz[i], 52, -1, busvw[i], busint[i], -1, 200.0);//создаём мап-иконку бизнеса
			}
			format(string, sizeof(string), "Бизнес: %s\nID: %d", busname[i], i);
			Nbus[i] = CreateDynamic3DTextLabel(string, 0x00FF00FF, buscordx[i], buscordy[i], buscordz[i]+0.70, 50,
			INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, busvw[i], busint[i], -1);//создаём 3D-текст бизнеса
		}
	}

	new pname[MAX_PLAYER_NAME];//прочитать реальные ники всех игроков
	new aa333[64];//доработка для использования Русских ников
	for(new i; i < MAX_PLAYERS; i++)
	{
		playspabs[i] = 0;//игрок не заспавнился
		playIDbus[i] = -600;//не существующий ИД бизнеса для игрока
		if(IsPlayerConnected(i))//если игрок в коннекте, то:
		{
			GetPlayerName(i, pname, sizeof(pname));
			strdel(RealName[i], 0, MAX_PLAYER_NAME);//очистить реальный ник игрока
			format(aa333, sizeof(aa333), "%s", pname);//доработка для использования Русских ников
			strcat(RealName[i], aa333);//запомнить реальный ник игрока (доработка для использования Русских ников)
//			strcat(RealName[i], pname);//запомнить реальный ник игрока
			if(GetPlayerState(i) != 0)//если игрок уже заспавнился, то:
			{
				playspabs[i] = 1;//игрок заспавнился
				for(new j; j < BUS_MAX; j++)//цикл для всех бизнесов
				{
					if(buscount[j] == 1 && strcmp(RealName[i], busplayname[j], false) == 0)//если бизнес существует,
					{//и это бизнес игрока, то:
						busidplay[j] = i;//даём бизнесу ИД он-лайн игрока - владельца бизнеса
					}
				}
			}
		}
	}
	print(" ");
	print("--------------------------------------");
	print("     BusSystem успешно загружена! ");
	print("--------------------------------------\n");
	return 1;
}

public UnloadBusSystem()//выгрузка системы бизнесов
{
	for(new i; i < BUS_MAX; i++)
	{
		if(buscount[i] == 1)//если бизнес существует, то:
		{
			DestroyDynamicPickup(PickupID[i]);//удаляем пикап бизнеса
			if(busday[i] == 0)//если есть мап-иконка бизнеса, то:
			{
				DestroyDynamicMapIcon(MapIconID[i]);//удаляем мап-иконку бизнеса
			}
			DestroyDynamic3DTextLabel(Nbus[i]);//удаляем 3D-текст бизнеса
		}
		buscount[i] = 0;//бизнес не создан (не сущесвует)
		strdel(busplayname[i], 0, MAX_PLAYER_NAME);//удаляем имя владельца бизнеса
		strcat(busplayname[i], "*** INV_PL_ID");
		busidplay[i] = -600;//владелец бизнеса офф-лайн
		PickupID[i] = -600;//задаём несуществующий ID-номер пикапа для бизнеса
		CallRemoteFunction("GPSrfun", "iiisifff", 2, 0, i, busplayname[i],
		0, 0.0, 0.0, 0.0);
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

