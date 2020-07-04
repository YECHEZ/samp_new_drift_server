#include <a_samp>
#define FILTERSCRIPT
//******************************************************************************
							  /////////////////////////////////
							  // RenisiL Vehicle SpeeDometer //
							  //    Version: v4.4            //
							  //    Next version: v4.5       //
							  /////////////////////////////////
//******************************************************************************
//упрощённая версия

#undef MAX_PLAYERS
#define MAX_PLAYERS 101 //максимум игроков на сервере + 1 (если 50 игроков, то пишем 51 !!!)

#if (MAX_PLAYERS > 501)
	#undef MAX_PLAYERS
	#define MAX_PLAYERS 501
#endif

forward Speed();
new speedtimer;

#define VehicleSpeed_1       false
#define VehicleSpeed_2       true

new bool:R_Vehicle[MAX_PLAYERS] = false;
new PlayerText:VehicleSpeed[MAX_PLAYERS];
new Text:KMH;
new conconTD[MAX_PLAYERS];//блокировка создания текст-дравов при подключении игрока
//______________________________________________________________________________
public OnFilterScriptInit()
{
    print(" ");
    print("**************************************");
	print("     Vehicle Speedometer Load...       ");
	print("**************************************\n");
	
	speedtimer = SetTimer("Speed",443,1);
	VehicleSpeedTextDraw_R();
	return 1;
}
//______________________________________________________________________________
public OnPlayerConnect(playerid)
{
	if(conconTD[playerid] == 0)
	{//если создание текст-дравов НЕ заблокировано, то:
		VehicleSpeed[playerid] = CreatePlayerTextDraw(playerid,565.000000,106.000000,"_");
		PlayerTextDrawAlignment(playerid,VehicleSpeed[playerid],0);
		PlayerTextDrawBackgroundColor(playerid,VehicleSpeed[playerid],0x0000ff66);
		PlayerTextDrawFont(playerid,VehicleSpeed[playerid],2);
		PlayerTextDrawLetterSize(playerid,VehicleSpeed[playerid],0.699999,2.699999);
		PlayerTextDrawColor(playerid,VehicleSpeed[playerid],0xffffffff);
		PlayerTextDrawSetOutline(playerid,VehicleSpeed[playerid],1);
		PlayerTextDrawSetProportional(playerid,VehicleSpeed[playerid],1);
		PlayerTextDrawSetShadow(playerid,VehicleSpeed[playerid],1);
	}
	conconTD[playerid] = 1;//блокировка создания текст-дравов при подключении игрока
	return 1;
}
//______________________________________________________________________________
public OnPlayerDisconnect(playerid, reason)
{
	PlayerTextDrawHide(playerid, VehicleSpeed[playerid]);
	TextDrawHideForPlayer(playerid, KMH);
	PlayerTextDrawDestroy(playerid, VehicleSpeed[playerid]);
	R_Vehicle[playerid] = VehicleSpeed_1;
	conconTD[playerid] = 0;//снятие блокировки создания текст-дравов при подключении игрока
	return 1;
}
//______________________________________________________________________________
public OnPlayerSpawn(playerid)
{
	R_Vehicle[playerid] = VehicleSpeed_1;
	return 1;
}
//______________________________________________________________________________
public OnPlayerDeath(playerid, killerid, reason)
{
	R_Vehicle[playerid] = VehicleSpeed_1;
	return 1;
}
//______________________________________________________________________________
public OnFilterScriptExit()
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
	    PlayerTextDrawHide(i, VehicleSpeed[i]);
	    TextDrawHideForPlayer(i, KMH);
		if(IsPlayerConnected(i))
		{
			PlayerTextDrawDestroy(i, VehicleSpeed[i]);
		}
		conconTD[i] = 0;//снятие блокировки создания текст-дравов при подключении игрока
	}
	TextDrawDestroy(KMH);
	KillTimer(speedtimer);
	return 1;
}
//______________________________________________________________________________
public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_DRIVER)
	{
		new String[64];
// Vehicle KM/H
		TextDrawShowForPlayer(playerid, KMH);

		format(String, sizeof(String), "%d", GetPlayerSpeed(playerid));
		PlayerTextDrawSetString(playerid, VehicleSpeed[playerid], String);
		PlayerTextDrawShow(playerid, VehicleSpeed[playerid]);
//******************************************************************************
		R_Vehicle[playerid] = VehicleSpeed_2;
	}
	else if(newstate == PLAYER_STATE_ONFOOT)
	{
		R_Vehicle[playerid] = VehicleSpeed_1;

		PlayerTextDrawHide(playerid, VehicleSpeed[playerid]);
		TextDrawHideForPlayer(playerid, KMH);
	}
	return 1;
}
//______________________________________________________________________________
public OnPlayerExitVehicle(playerid, vehicleid)
{
	R_Vehicle[playerid] = VehicleSpeed_1;

	PlayerTextDrawHide(playerid, VehicleSpeed[playerid]);
	TextDrawHideForPlayer(playerid, KMH);
	return 1;
}
//______________________________________________________________________________
public Speed()
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerInAnyVehicle(i))
		{
			if(bool:R_Vehicle[i] == VehicleSpeed_2)
			{
//******************************************************************************
// Vehicle Speed
				new string[64];
				format(string, sizeof(string), "%d", GetPlayerSpeed(i));
				PlayerTextDrawSetString(i, VehicleSpeed[i], string);
//******************************************************************************
			}
		}
	}
	return 1;
}
//______________________________________________________________________________
VehicleSpeedTextDraw_R()
{
	new String[64];
//Vehicle K/MH
	KMH = TextDrawCreate(500.000000,107.000000,"KM/H:");
	TextDrawAlignment(KMH,0);
	TextDrawBackgroundColor(KMH,0x000000ff);
	TextDrawFont(KMH,1);
	TextDrawLetterSize(KMH,0.599999,2.599999);
	TextDrawColor(KMH,0x7777ffff);
	TextDrawSetOutline(KMH,1);
	TextDrawSetProportional(KMH,1);
	TextDrawSetShadow(KMH,1);
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		conconTD[i] = 0;//снятие блокировки создания текст-дравов при подключении игрока
		if(IsPlayerConnected(i))
		{
//Vehicle K/MH_2
			VehicleSpeed[i] = CreatePlayerTextDraw(i,565.000000,106.000000,"_");
			PlayerTextDrawAlignment(i,VehicleSpeed[i],0);
			PlayerTextDrawBackgroundColor(i,VehicleSpeed[i],0x0000ff66);
			PlayerTextDrawFont(i,VehicleSpeed[i],2);
			PlayerTextDrawLetterSize(i,VehicleSpeed[i],0.699999,2.699999);
			PlayerTextDrawColor(i,VehicleSpeed[i],0xffffffff);
			PlayerTextDrawSetOutline(i,VehicleSpeed[i],1);
			PlayerTextDrawSetProportional(i,VehicleSpeed[i],1);
			PlayerTextDrawSetShadow(i,VehicleSpeed[i],1);

			if(GetPlayerState(i) == PLAYER_STATE_DRIVER)
			{
// Vehicle KM/H
				TextDrawShowForPlayer(i, KMH);

				format(String, sizeof(String), "%d", GetPlayerSpeed(i));
				PlayerTextDrawSetString(i, VehicleSpeed[i], String);
				PlayerTextDrawShow(i, VehicleSpeed[i]);
//******************************************************************************
				R_Vehicle[i] = VehicleSpeed_2;
			}
			conconTD[i] = 1;//блокировка создания текст-дравов при подключении игрока
		}
	}
	return 1;
}
//______________________________________________________________________________
stock GetPlayerSpeed(playerid)
{
    new Float:ST[4];
    if(IsPlayerInAnyVehicle(playerid))
	GetVehicleVelocity(GetPlayerVehicleID(playerid),ST[0],ST[1],ST[2]);
	else GetPlayerVelocity(playerid,ST[0],ST[1],ST[2]);
	ST[3] = floatsqroot(floatmul(ST[0], ST[0]) + floatmul(ST[1], ST[1]) + floatmul(ST[2], ST[2])) * 200;
//	ST[3] = floatsqroot(floatpower(floatabs(ST[0]), 2.0) + floatpower(floatabs(ST[1]), 2.0) + floatpower(floatabs(ST[2]), 2.0)) * 200;
//	ST[3] = floatsqroot(floatpower(floatabs(ST[0]), 2.0) + floatpower(floatabs(ST[1]), 2.0) + floatpower(floatabs(ST[2]), 2.0)) * 253.3;
    return floatround(ST[3]);
}

