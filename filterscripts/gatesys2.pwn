//==============================================================================
//                            Основные настройки
//==============================================================================

#define MOD77INS 1 //режим управления воротами:
//                 //MOD77INS 1 - командой-паролем (может управлять любой игрок из любого места карты).
//                 //MOD77INS 2 - командой /gate (может управлять только игрок из соответствующей
//                 //             банды, и находясь вблизи ворот своей банды).

//   ВНИМАНИЕ !!! после изменения настроек ОБЯЗАТЕЛЬНО откомпилировать !!!
//==============================================================================
#if (MOD77INS < 1)
	#undef MOD77INS
	#define MOD77INS 1
#endif
#if (MOD77INS > 2)
	#undef MOD77INS
	#define MOD77INS 2
#endif

#include <a_samp>
#include <streamer>

#undef MAX_PLAYERS
#define MAX_PLAYERS 101 //максимум игроков на сервере + 1 (если 50 игроков, то пишем 51 !!!)

#if (MAX_PLAYERS > 501)
	#undef MAX_PLAYERS
	#define MAX_PLAYERS 501
#endif

#define MAX_GATE 2 //число ворот на сервере (ОБЯЗАТЕЛЬНО - ТОЧНОЕ КОЛИЧЕСТВО !!!) (2)
#define MAX_MOVE 3 //число "перемещаемых" объектов (ОБЯЗАТЕЛЬНО - ТОЧНОЕ КОЛИЧЕСТВО !!!) (3)
#define G_SPEED 1.00 //скорость перемещения ворот
/*
--------------------------------------------------------------------------------
Правила перевода стандартных объектов в динамические:

Стандартные объекты:
CreateObject(971, -250.89, 1510.65, 78.17,   0.00, 0.00, 180.00);
CreateObject(971, -269.57, 1510.95, 78.17,   0.00, 0.00, 0.00);
CreateObject(971, -278.45, 1510.98, 78.17,   0.00, 0.00, 0.00);

Динамические объекты:
CreateDynamicObject(971, -250.89, 1510.65, 78.17,   0.00, 0.00, 180.00, -1, -1, -1, 500);
CreateDynamicObject(971, -269.57, 1510.95, 78.17,   0.00, 0.00, 0.00, -1, -1, -1, 500);
CreateDynamicObject(971, -278.45, 1510.98, 78.17,   0.00, 0.00, 0.00, -1, -1, -1, 500);

Перемещение динамических объектов:
MoveDynamicObject(idobject[0], -250.89, 1510.65, 81.67, G_SPEED, -90.00, 0.00, 180.00);
MoveDynamicObject(idobject[1], -269.57, 1510.95, 70.60, G_SPEED);//пример перемещения объекта БЕЗ поворотов по осям X, Y, и Z
MoveDynamicObject(idobject[2], -278.45, 1510.98, 70.60, G_SPEED);//пример перемещения объекта БЕЗ поворотов по осям X, Y, и Z

	idobject[0] - ID перемещаемого объекта
	-250.89, 1510.65, 78.17 - координаты, В которые нужно переместить объект
	G_SPEED - скорость перемещения объекта
	-90.00, 0.00, 180.00 - углы поворотов по осям X, Y, и Z соответственно,
	НА которые нужно повернуть перемещаемый объект

	Внимание !!! Данный скрипт тестировался со streamer-плагином v2.7.2 !!!
	При использовании streamer-плагина более ранних версий - возможен
	скачкообразный, либо неверный поворот по осям X, Y, и Z в функции
	перемещения динамического объекта (MoveDynamicObject) !!!
	В таком случае используйте MoveDynamicObject БЕЗ задания углов поворотов
	по осям X, Y, и Z... Пример:

Перемещение динамических объектов для более ранних версий streamer-плагина:
MoveDynamicObject(idobject[0], -240.38, 1510.78, 86.17, G_SPEED);
MoveDynamicObject(idobject[1], -269.57, 1510.95, 70.60, G_SPEED);
MoveDynamicObject(idobject[2], -278.45, 1510.98, 70.60, G_SPEED);

--------------------------------------------------------------------------------
*/
forward timobj();

new Text3D:fantxt;//переменная для хранения 3D-текста с несущесвующим ИД
new statgate[MAX_GATE];
new idobject[MAX_MOVE];
new idgang[MAX_GATE];
new Float:CorX[MAX_GATE];
new Float:CorY[MAX_GATE];
new Float:CorZ[MAX_GATE];
new namegate[MAX_GATE][128];
new Text3D:GateLabel[MAX_GATE];

public OnFilterScriptInit()
{
	fantxt = Create3DTextLabel(" ",0xFFFFFFAA,0.000,0.000,-4.000,18.0,0,1);//создаём 3D-текст с несущесвующим ИД
	print(" ");
	print("-------------------------");
	print("    GateSys загружена");
	print("-------------------------\n");

	for(new i = 0; i < MAX_GATE; i++)//присваиваем всем воротам статус "закрыто"
	{
		statgate[i] = 0;
	}
	SetTimer("timobj", 300, 0);
	new string[256];

	CorX[0] = -250.89;//координаты 3D-текста названия банды для ворот-1
	CorY[0] = 1511.65;
	CorZ[0] = 76.17;

	CorX[1] = -274.45;//координаты 3D-текста названия банды для ворот-2
	CorY[1] = 1511.95;
	CorZ[1] = 76.17;

#if (MOD77INS == 1)//режим управления командой-паролем
	idgang[0] = -1;//фиктивная переменная ID банды
	format(namegate[0], 128, "{FF0000}Drift-1");//название банды для ворот-1
	format(string, sizeof(string), "База банды: %s", namegate[0]);
	GateLabel[0] = CreateDynamic3DTextLabel(string, 0x00FF00FF, CorX[0], CorY[0], CorZ[0], 25, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0, -1);//подписываем ворота-1

	idgang[1] = -1;//фиктивная переменная ID банды
	format(namegate[1], 128, "{FF0000}Drift-2");//название банды для ворот-2
	format(string, sizeof(string), "База банды: %s", namegate[1]);
	GateLabel[1] = CreateDynamic3DTextLabel(string, 0x00FF00FF, CorX[1], CorY[1], CorZ[1], 25, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0, -1);//подписываем ворота-2
#endif
#if (MOD77INS == 2)//режим управления командой /gate
	idgang[0] = 1;//ID банды для ворот-1
	format(namegate[0], 128, "{FF0000}Drift-1");//название банды для ворот-1
	format(string, sizeof(string), "База банды: %s\n{00FF00}управление воротами - /gate", namegate[0]);
	GateLabel[0] = CreateDynamic3DTextLabel(string, 0x00FF00FF, CorX[0], CorY[0], CorZ[0], 25, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0, -1);//подписываем ворота-1

	idgang[1] = 12;//ID банды для ворот-2
	format(namegate[1], 128, "{FF0000}Drift-2");//название банды для ворот-2
	format(string, sizeof(string), "База банды: %s\n{00FF00}управление воротами - /gate", namegate[1]);
	GateLabel[1] = CreateDynamic3DTextLabel(string, 0x00FF00FF, CorX[1], CorY[1], CorZ[1], 25, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0, -1);//подписываем ворота-2
#endif
	return 1;
}

public timobj()
{

	idobject[0] = CreateDynamicObject(971, -250.89, 1510.65, 78.17,   0.00, 0.00, 180.00, -1, -1, -1, 500);//ворота-1 в закрытом состоянии

	idobject[1] = CreateDynamicObject(971, -269.57, 1510.95, 78.17,   0.00, 0.00, 0.00, -1, -1, -1, 500);//ворота-2 в закрытом состоянии
	idobject[2] = CreateDynamicObject(971, -278.45, 1510.98, 78.17,   0.00, 0.00, 0.00, -1, -1, -1, 500);

	return 1;
}

public OnFilterScriptExit()
{
	Delete3DTextLabel(fantxt);//удаляем 3D-текст с несущесвующим ИД
 	for(new i = 0; i < MAX_MOVE; i++)
	{
		DestroyDynamicObject(idobject[i]);//убираем все объекты
	}
 	for(new i = 0; i < MAX_GATE; i++)
	{
		DestroyDynamic3DTextLabel(GateLabel[i]);//убираем все надписи (3D-тексты)
	}
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if(GetPVarInt(playerid, "CComAc6") < 0)
	{
		new dopcis, sstr[256];
		dopcis = FCislit(GetPVarInt(playerid, "CComAc6"));
		switch(dopcis)
		{
			case 0: format(sstr, sizeof(sstr), " Спам в чате (или в командах) !   Попробуйте через %d секунд !", GetPVarInt(playerid, "CComAc6") * -1);
			case 1: format(sstr, sizeof(sstr), " Спам в чате (или в командах) !   Попробуйте через %d секунду !", GetPVarInt(playerid, "CComAc6") * -1);
			case 2: format(sstr, sizeof(sstr), " Спам в чате (или в командах) !   Попробуйте через %d секунды !", GetPVarInt(playerid, "CComAc6") * -1);
		}
		SendClientMessage(playerid, 0xFF0000FF, sstr);
		return 1;
	}
	SetPVarInt(playerid, "CComAc6", GetPVarInt(playerid, "CComAc6") + 1);
	new string[256];
    new pname[MAX_PLAYER_NAME];
	GetPlayerName(playerid,pname,sizeof(pname));
	new aa333[64];//доработка для использования Русских ников
	format(aa333, sizeof(aa333), "%s", pname);//доработка для использования Русских ников
#if (MOD77INS == 1)//режим управления командой-паролем
    if(!strcmp(cmdtext, "/gate1", true))//команда открыть-закрыть ворота-1 "/gate1"
    {
        if(statgate[0] == 0)//открываем, если ворота-1 закрыты
        {
			printf("[gatesys] %s [%d] открыл ворота базы %s", aa333, playerid, namegate[0]);//выводим сообщение в лог сервера (доработка для использования Русских ников)
//			printf("[gatesys] %s [%d] открыл ворота базы %s", pname, playerid, namegate[0]);//выводим сообщение в лог сервера
			format(string, sizeof(string), "Вы открыли ворота базы %s", namegate[0]);
			SendClientMessage(playerid, 0x00FF00FF, string);
			UpdateDynamic3DTextLabelText(GateLabel[0], 0xFFFFFFFF, " ");//убираем надпись с ворот-1
			MoveDynamicObject(idobject[0], -250.89, 1510.65, 81.67, G_SPEED, -90.00, 0.00, 180.00);//перемещение объекта ворота-1
			statgate[0] = 1;//изменяем статус на "открыто"
        }
        else//закрываем, если ворота-1 открыты
        {
			printf("[gatesys] %s [%d] закрыл ворота базы %s", aa333, playerid, namegate[0]);//выводим сообщение в лог сервера (доработка для использования Русских ников)
//			printf("[gatesys] %s [%d] закрыл ворота базы %s", pname, playerid, namegate[0]);//выводим сообщение в лог сервера
			format(string, sizeof(string), "Вы закрыли ворота базы %s", namegate[0]);
			SendClientMessage(playerid, 0xFF0000FF, string);
			format(string, sizeof(string), "База банды: %s", namegate[0]);
			UpdateDynamic3DTextLabelText(GateLabel[0], 0x00FF00FF, string);//подписываем ворота-1
			MoveDynamicObject(idobject[0], -250.89, 1510.65, 78.17, G_SPEED, 0.00, 0.00, 180.00);//перемещение объекта ворота-1 в координаты создания
			statgate[0] = 0;//изменяем статус на "закрыто"
        }
        return 1;
	}
    if(!strcmp(cmdtext, "/gate2", true))//команда открыть-закрыть ворота-2 "/gate2"
    {
        if(statgate[1] == 0)//открываем, если ворота-2 закрыты
        {
			printf("[gatesys] %s [%d] открыл ворота базы %s", aa333, playerid, namegate[1]);//выводим сообщение в лог сервера (доработка для использования Русских ников)
//			printf("[gatesys] %s [%d] открыл ворота базы %s", pname, playerid, namegate[1]);//выводим сообщение в лог сервера
			format(string, sizeof(string), "Вы открыли ворота базы %s", namegate[1]);
			SendClientMessage(playerid, 0x00FF00FF, string);
			UpdateDynamic3DTextLabelText(GateLabel[1], 0xFFFFFFFF, " ");//убираем надпись с ворот-2
			MoveDynamicObject(idobject[1], -269.57, 1510.95, 70.60, G_SPEED);//перемещение объекта ворота-2
			MoveDynamicObject(idobject[2], -278.45, 1510.98, 70.60, G_SPEED);
			statgate[1] = 1;//изменяем статус на "открыто"
        }
        else//закрываем, если ворота-2 открыты
        {
			printf("[gatesys] %s [%d] закрыл ворота базы %s", aa333, playerid, namegate[1]);//выводим сообщение в лог сервера (доработка для использования Русских ников)
//			printf("[gatesys] %s [%d] закрыл ворота базы %s", pname, playerid, namegate[1]);//выводим сообщение в лог сервера
			format(string, sizeof(string), "Вы закрыли ворота базы %s", namegate[1]);
			SendClientMessage(playerid, 0xFF0000FF, string);
			format(string, sizeof(string), "База банды: %s", namegate[1]);
			UpdateDynamic3DTextLabelText(GateLabel[1], 0x00FF00FF, string);//подписываем ворота-2
			MoveDynamicObject(idobject[1], -269.57, 1510.95, 78.17, G_SPEED);//перемещение объекта ворота-2 в координаты создания
			MoveDynamicObject(idobject[2], -278.45, 1510.98, 78.17, G_SPEED);
			statgate[1] = 0;//изменяем статус на "закрыто"
        }
        return 1;
	}
#endif
#if (MOD77INS == 2)//режим управления командой /gate
    if(!strcmp(cmdtext, "/gate", true))//команда /gate
    {
		new per1 = 0;
		new per2 = -600;
		while(per1 < MAX_GATE)
		{
//			if(GetPVarInt(playerid, "PlGng") == idgang[per1] &&
//			IsPlayerInRangeOfPoint(playerid, 15.0, CorX[per1], CorY[per1], CorZ[per1]))//управление воротами ТОЛЬКО игроками из банды
			if((GetPVarInt(playerid, "PlGng") == idgang[per1] || IsPlayerAdmin(playerid)) &&
			IsPlayerInRangeOfPoint(playerid, 15.0, CorX[per1], CorY[per1], CorZ[per1]))//управление воротами игроками из банды И RCON-админом
        	{
				per2 = per1;
				break;
			}
			per1++;
		}
        if(per2 == -600)
        {
			SendClientMessage(playerid, 0xFF0000FF, "Это не Ваши ворота, или ворота слишком далеко !");
			return 1;
        }
		if(statgate[per2] == 0)//если ворота закрыты, то:
		{
			if(GetPVarInt(playerid, "PlGng") != idgang[per2] && IsPlayerAdmin(playerid))
			{
				printf("[gatesys] RCON %s [%d] открыл ворота базы %s", aa333, playerid, namegate[per2]);//выводим сообщение в лог сервера (доработка для использования Русских ников)
//				printf("[gatesys] %s [%d] открыл ворота базы %s", pname, playerid, namegate[per2]);//выводим сообщение в лог сервера
			}
			else
			{
				printf("[gatesys] %s [%d] открыл ворота базы %s", aa333, playerid, namegate[per2]);//выводим сообщение в лог сервера (доработка для использования Русских ников)
//				printf("[gatesys] %s [%d] открыл ворота базы %s", pname, playerid, namegate[per2]);//выводим сообщение в лог сервера
			}
		}
		else//иначе:
		{
			if(GetPVarInt(playerid, "PlGng") != idgang[per2] && IsPlayerAdmin(playerid))
			{
				printf("[gatesys] RCON %s [%d] закрыл ворота базы %s", aa333, playerid, namegate[per2]);//выводим сообщение в лог сервера (доработка для использования Русских ников)
//				printf("[gatesys] %s [%d] закрыл ворота базы %s", pname, playerid, namegate[per2]);//выводим сообщение в лог сервера
			}
			else
			{
				printf("[gatesys] %s [%d] закрыл ворота базы %s", aa333, playerid, namegate[per2]);//выводим сообщение в лог сервера (доработка для использования Русских ников)
//				printf("[gatesys] %s [%d] закрыл ворота базы %s", pname, playerid, namegate[per2]);//выводим сообщение в лог сервера
			}
		}
		if(per2 == 0)//управление воротами-1
        {
        	if(statgate[0] == 0)//открываем, если ворота-1 закрыты
        	{
				format(string, sizeof(string), "Вы открыли ворота базы %s", namegate[0]);
				SendClientMessage(playerid, 0x00FF00FF, string);
				UpdateDynamic3DTextLabelText(GateLabel[0], 0xFFFFFFFF, " ");//убираем надпись с ворот-1
				MoveDynamicObject(idobject[0], -250.89, 1510.65, 81.67, G_SPEED, -90.00, 0.00, 180.00);//перемещение объекта ворота-1
				statgate[0] = 1;//изменяем статус на "открыто"
        	}
        	else//закрываем, если ворота-1 открыты
        	{
				format(string, sizeof(string), "Вы закрыли ворота базы %s", namegate[0]);
				SendClientMessage(playerid, 0xFF0000FF, string);
				format(string, sizeof(string), "База банды: %s\n{00FF00}управление воротами - /gate", namegate[0]);
				UpdateDynamic3DTextLabelText(GateLabel[0], 0x00FF00FF, string);//подписываем ворота-1
				MoveDynamicObject(idobject[0], -250.89, 1510.65, 78.17, G_SPEED, 0.00, 0.00, 180.00);//перемещение объекта ворота-1 в координаты создания
				statgate[0] = 0;//изменяем статус на "закрыто"
        	}
        	return 1;
		}
    	if(per2 == 1)//управление воротами-2
    	{
        	if(statgate[1] == 0)//открываем, если ворота-2 закрыты
        	{
				format(string, sizeof(string), "Вы открыли ворота базы %s", namegate[1]);
				SendClientMessage(playerid, 0x00FF00FF, string);
				UpdateDynamic3DTextLabelText(GateLabel[1], 0xFFFFFFFF, " ");//убираем надпись с ворот-2
				MoveDynamicObject(idobject[1], -269.57, 1510.95, 70.60, G_SPEED);//перемещение объекта ворота-2
				MoveDynamicObject(idobject[2], -278.45, 1510.98, 70.60, G_SPEED);
				statgate[1] = 1;//изменяем статус на "открыто"
        	}
        	else//закрываем, если ворота-2 открыты
        	{
				format(string, sizeof(string), "Вы закрыли ворота базы %s", namegate[1]);
				SendClientMessage(playerid, 0xFF0000FF, string);
				format(string, sizeof(string), "База банды: %s\n{00FF00}управление воротами - /gate", namegate[1]);
				UpdateDynamic3DTextLabelText(GateLabel[1], 0x00FF00FF, string);//подписываем ворота-2
				MoveDynamicObject(idobject[1], -269.57, 1510.95, 78.17, G_SPEED);//перемещение объекта ворота-2 в координаты создания
				MoveDynamicObject(idobject[2], -278.45, 1510.98, 78.17, G_SPEED);
				statgate[1] = 0;//изменяем статус на "закрыто"
        	}
        	return 1;
		}
    }
#endif
	return 0;
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

