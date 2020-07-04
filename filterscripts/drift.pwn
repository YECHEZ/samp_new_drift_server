#include <a_samp>

#undef MAX_PLAYERS
#define MAX_PLAYERS 101 //максимум игроков на сервере + 1 (если 50 игроков, то пишем 51 !!!)

#if (MAX_PLAYERS > 501)
	#undef MAX_PLAYERS
	#define MAX_PLAYERS 501
#endif

#define DRIFT_MINKAT 10.0
#define DRIFT_MAXKAT 90.0
#define DRIFT_SPEED 30.0

forward LevelUpdate();
forward Drift();
forward DriftCancellation(playerid);

new dddrift[MAX_PLAYERS];//переменная контроля дрифта
new Text3D:Level3D[MAX_PLAYERS];
new LevelStats[MAX_PLAYERS];
new Text:leveldr[11];
new DriftPointsNow[MAX_PLAYERS];
new PlayerDriftCancellation[MAX_PLAYERS];
new Float:ppos[MAX_PLAYERS][3];
new	drifttimer;
new	leveltimer;
new remotelock[MAX_PLAYERS];

enum PlayerData
{
	Level[200]
};
new Playerdr[MAX_PLAYERS][PlayerData];
enum Float:Pos
{
	Float:sX,
	Float:sY,
	Float:sZ,
	Float:dltX,
	Float:dltY,
	Float:dltZ
};
new Float:SavedPos[MAX_PLAYERS][Pos];

public OnFilterScriptInit()
{
	drifttimer = SetTimer("Drift", 200, true);
	leveltimer = SetTimer("LevelUpdate",1991,1);

	print("Levels Downloading");
	// ==================================================================== //
	leveldr[0] = TextDrawCreate(515.000000,99.000000,"Drift level:~g~1");
	TextDrawAlignment(leveldr[0],0);
	TextDrawBackgroundColor(leveldr[0],0x000000ff);
	TextDrawFont(leveldr[0],3);
	TextDrawLetterSize(leveldr[0],0.299999,1.000000);
	TextDrawColor(leveldr[0],0xffffffff);
	TextDrawSetOutline(leveldr[0],1);
	TextDrawSetProportional(leveldr[0],1);
	TextDrawSetShadow(leveldr[0],1);

	leveldr[1] = TextDrawCreate(515.000000,99.000000,"Drift level:~g~2");
	TextDrawAlignment(leveldr[1],0);
	TextDrawBackgroundColor(leveldr[1],0x000000ff);
	TextDrawFont(leveldr[1],3);
	TextDrawLetterSize(leveldr[1],0.299999,1.000000);
	TextDrawColor(leveldr[1],0xffffffff);
	TextDrawSetOutline(leveldr[1],1);
	TextDrawSetProportional(leveldr[1],1);
	TextDrawSetShadow(leveldr[1],1);

	leveldr[2] = TextDrawCreate(515.000000,99.000000,"Drift level:~g~3");
	TextDrawAlignment(leveldr[2],0);
	TextDrawBackgroundColor(leveldr[2],0x000000ff);
	TextDrawFont(leveldr[2],3);
	TextDrawLetterSize(leveldr[2],0.299999,1.000000);
	TextDrawColor(leveldr[2],0xffffffff);
	TextDrawSetOutline(leveldr[2],1);
	TextDrawSetProportional(leveldr[2],1);
	TextDrawSetShadow(leveldr[2],1);

	leveldr[3] = TextDrawCreate(515.000000,99.000000,"Drift level:~g~4");
	TextDrawAlignment(leveldr[3],0);
	TextDrawBackgroundColor(leveldr[3],0x000000ff);
	TextDrawFont(leveldr[3],3);
	TextDrawLetterSize(leveldr[3],0.299999,1.000000);
	TextDrawColor(leveldr[3],0xffffffff);
	TextDrawSetOutline(leveldr[3],1);
	TextDrawSetProportional(leveldr[3],1);
	TextDrawSetShadow(leveldr[3],1);

	leveldr[4] = TextDrawCreate(515.000000,99.000000,"Drift level:~g~5");
	TextDrawAlignment(leveldr[4],0);
	TextDrawBackgroundColor(leveldr[4],0x000000ff);
	TextDrawFont(leveldr[4],3);
	TextDrawLetterSize(leveldr[4],0.299999,1.000000);
	TextDrawColor(leveldr[4],0xffffffff);
	TextDrawSetOutline(leveldr[4],1);
	TextDrawSetProportional(leveldr[4],1);
	TextDrawSetShadow(leveldr[4],1);

	leveldr[5] = TextDrawCreate(515.000000,99.000000,"Drift level:~g~6");
	TextDrawAlignment(leveldr[5],0);
	TextDrawBackgroundColor(leveldr[5],0x000000ff);
	TextDrawFont(leveldr[5],3);
	TextDrawLetterSize(leveldr[5],0.299999,1.000000);
	TextDrawColor(leveldr[5],0xffffffff);
	TextDrawSetOutline(leveldr[5],1);
	TextDrawSetProportional(leveldr[5],1);
	TextDrawSetShadow(leveldr[5],1);

	leveldr[6] = TextDrawCreate(515.000000,99.000000,"Drift level:~g~7");
	TextDrawAlignment(leveldr[6],0);
	TextDrawBackgroundColor(leveldr[6],0x000000ff);
	TextDrawFont(leveldr[6],3);
	TextDrawLetterSize(leveldr[6],0.299999,1.000000);
	TextDrawColor(leveldr[6],0xffffffff);
	TextDrawSetOutline(leveldr[6],1);
	TextDrawSetProportional(leveldr[6],1);
	TextDrawSetShadow(leveldr[6],1);

	leveldr[7] = TextDrawCreate(515.000000,99.000000,"Drift level:~g~8");
	TextDrawAlignment(leveldr[7],0);
	TextDrawBackgroundColor(leveldr[7],0x000000ff);
	TextDrawFont(leveldr[7],3);
	TextDrawLetterSize(leveldr[7],0.299999,1.000000);
	TextDrawColor(leveldr[7],0xffffffff);
	TextDrawSetOutline(leveldr[7],1);
	TextDrawSetProportional(leveldr[7],1);
	TextDrawSetShadow(leveldr[7],1);

	leveldr[8] = TextDrawCreate(515.000000,99.000000,"Drift level:~g~9");
	TextDrawAlignment(leveldr[8],0);
	TextDrawBackgroundColor(leveldr[8],0x000000ff);
	TextDrawFont(leveldr[8],3);
	TextDrawLetterSize(leveldr[8],0.299999,1.000000);
	TextDrawColor(leveldr[8],0xffffffff);
	TextDrawSetOutline(leveldr[8],1);
	TextDrawSetProportional(leveldr[8],1);
	TextDrawSetShadow(leveldr[8],1);

	leveldr[9] = TextDrawCreate(515.000000,99.000000,"Drift level:~g~10");
	TextDrawAlignment(leveldr[9],0);
	TextDrawBackgroundColor(leveldr[9],0x000000ff);
	TextDrawFont(leveldr[9],3);
	TextDrawLetterSize(leveldr[9],0.299999,1.000000);
	TextDrawColor(leveldr[9],0xffffffff);
	TextDrawSetOutline(leveldr[9],1);
	TextDrawSetProportional(leveldr[9],1);
	TextDrawSetShadow(leveldr[9],1);

	leveldr[10] = TextDrawCreate(515.000000,99.000000,"Drift level:~y~VIP");
	TextDrawAlignment(leveldr[10],0);
	TextDrawBackgroundColor(leveldr[10],0x000000ff);
	TextDrawFont(leveldr[10],3);
	TextDrawLetterSize(leveldr[10],0.299999,1.000000);
	TextDrawColor(leveldr[10],0xffffffff);
	TextDrawSetOutline(leveldr[10],1);
	TextDrawSetProportional(leveldr[10],1);
	TextDrawSetShadow(leveldr[10],1);
	// ===================================================================== //
	new Max = GetMaxPlayers();
	for(new i=0; i<Max; i++)
	{
		remotelock[i] = 0;
		Level3D[i] = Create3DTextLabel(" ",0xFFFFFFAA,0.000,0.000,-4.000,18.0,0,1);
	}
	return 1;
}

public OnPlayerConnect(playerid)
{
	LevelStats[playerid] = 0;
	remotelock[playerid] = 0;
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	remotelock[playerid] = 0;
	return 1;
}

Float:GetPlayerTheoreticAngle(i)
{
	new Float:sin;
	new Float:dis;
	new Float:angle2;
	new Float:x,Float:y,Float:z;
	new Float:tmp3;
	new Float:tmp4;
	new Float:MindAngle;
	GetPlayerPos(i,x,y,z);
	dis = floatsqroot(floatpower(floatabs(floatsub(x,ppos[i][0])),2)+floatpower(floatabs(floatsub(y,ppos[i][1])),2));
	if(IsPlayerInAnyVehicle(i))GetVehicleZAngle(GetPlayerVehicleID(i), angle2); else GetPlayerFacingAngle(i, angle2);
	if(x>ppos[i][0]){tmp3=x-ppos[i][0];}else{tmp3=ppos[i][0]-x;}
	if(y>ppos[i][1]){tmp4=y-ppos[i][1];}else{tmp4=ppos[i][1]-y;}
	if(ppos[i][1]>y && ppos[i][0]>x){
		sin = asin(tmp3/dis);
		MindAngle = floatsub(floatsub(floatadd(sin, 90), floatmul(sin, 2)), -90.0);
	}
	if(ppos[i][1]<y && ppos[i][0]>x){
		sin = asin(tmp3/dis);
		MindAngle = floatsub(floatadd(sin, 180), 180.0);
	}
	if(ppos[i][1]<y && ppos[i][0]<x){
		sin = acos(tmp4/dis);
		MindAngle = floatsub(floatadd(sin, 360), floatmul(sin, 2));
	}
	if(ppos[i][1]>y && ppos[i][0]<x){
		sin = asin(tmp3/dis);
		MindAngle = floatadd(sin, 180);
	}
	if(MindAngle == 0.0){
		return angle2;
	} else
		return MindAngle;
}

public OnFilterScriptExit()
{
	for(new i=0; i<11; i++)
	{
		TextDrawDestroy(leveldr[i]);
	}
	new Max = GetMaxPlayers();
	for(new i=0; i<Max; i++)
	{
		Delete3DTextLabel(Level3D[i]);
	}
	KillTimer(drifttimer);
	KillTimer(leveltimer);
	return 1;
}

public LevelUpdate()
{
    for(new i=0; i<MAX_PLAYERS; i++)
    {
		if(IsPlayerConnected(i))
		{
//если используется money
/*
			new Score = GetPlayerMoney(i);//drift bonus
			if(Score >= 0 && Score < 100000) format(Playerdr[i][Level],200,"{FFFFFF}*{00CCFF}Игрок{FFFFFF}*\n*Уровень: {00CCFF}1{FFFFFF}.*\n*{00CCFF}Нуб в дрифтинге{FFFFFF}*");
			if(Score >= 100000 && Score < 200000) format(Playerdr[i][Level],200,"{FFFFFF}*Игрок{FFFFFF}*\n*Уровень: {00CCFF}2{FFFFFF}.*\n*{00CCFF}Новичок{FFFFFF}*");
			if(Score >= 200000 && Score < 300000) format(Playerdr[i][Level],200,"{FFFFFF}*{00CCFF}Игрок{FFFFFF}*\n*Уровень: {00CCFF}3{FFFFFF}.*\n*{00CCFF}Начинающий дрифтер{FFFFFF}*");
			if(Score >= 300000 && Score < 400000) format(Playerdr[i][Level],200,"{FFFFFF}*{00CCFF}Игрок{FFFFFF}*\n*Уровень: {00CCFF}4{FFFFFF}.*\n*{00CCFF}Проживающий{FFFFFF}*");
			if(Score >= 400000 && Score < 500000) format(Playerdr[i][Level],200,"{FFFFFF}*{00CCFF}Игрок{FFFFFF}*\n*Уровень: {00CCFF}5{FFFFFF}.*\n*{00CCFF}Свой{FFFFFF}*");
			if(Score >= 500000 && Score < 600000) format(Playerdr[i][Level],200,"{FFFFFF}*{00CCFF}Игрок{FFFFFF}*\n*Уровень: {00CCFF}6{FFFFFF}.*\n*{00CCFF}Пахан{FFFFFF}*");
			if(Score >= 600000 && Score < 700000) format(Playerdr[i][Level],200,"{FFFFFF}*{00CCFF}*ViP*{FFFFFF}*\n*Уровень: {00CCFF}7{FFFFFF}.*\n*{00CCFF}Pro Drifter{FFFFFF}*");
			if(Score >= 700000 && Score < 800000) format(Playerdr[i][Level],200,"{FFFFFF}*{00CCFF}*ViP*{FFFFFF}*\n*Уровень: {00CCFF}8{FFFFFF}.*\n*{00CCFF}VIP{FFFFFF}*");
			if(Score >= 800000 && Score < 900000) format(Playerdr[i][Level],200,"{FFFFFF}*{00CCFF}*ViP*{FFFFFF}*\n*Уровень: {00CCFF}9{FFFFFF}.*\n*{00CCFF}Гловарь{FFFFFF}*");
			if(Score >= 900000 ) format(Playerdr[i][Level],200,"{FFFFFF}*{00CCFF}*ViP*{FFFFFF}*\n*Уровень: {00CCFF}*10*{FFFFFF}.*\n*{00CCFF}Король дрифта{FFFFFF}*");
*/
//если используется money
//если используется score
			new Score = GetPlayerScore(i);//drift bonus
			if(Score >= 0 && Score < 200) format(Playerdr[i][Level],200,"{FFFFFF}*{00CCFF}Игрок{FFFFFF}*\n*Уровень: {00CCFF}1{FFFFFF}.*\n*{00CCFF}Нуб в дрифтинге{FFFFFF}*");
			if(Score >= 200 && Score < 400) format(Playerdr[i][Level],200,"{FFFFFF}*Игрок{FFFFFF}*\n*Уровень: {00CCFF}2{FFFFFF}.*\n*{00CCFF}Новичок{FFFFFF}*");
			if(Score >= 400 && Score < 600) format(Playerdr[i][Level],200,"{FFFFFF}*{00CCFF}Игрок{FFFFFF}*\n*Уровень: {00CCFF}3{FFFFFF}.*\n*{00CCFF}Начинающий дрифтер{FFFFFF}*");
			if(Score >= 600 && Score < 800) format(Playerdr[i][Level],200,"{FFFFFF}*{00CCFF}Игрок{FFFFFF}*\n*Уровень: {00CCFF}4{FFFFFF}.*\n*{00CCFF}Проживающий{FFFFFF}*");
			if(Score >= 800 && Score < 1000) format(Playerdr[i][Level],200,"{FFFFFF}*{00CCFF}Игрок{FFFFFF}*\n*Уровень: {00CCFF}5{FFFFFF}.*\n*{00CCFF}Свой{FFFFFF}*");
			if(Score >= 1000 && Score < 1200) format(Playerdr[i][Level],200,"{FFFFFF}*{00CCFF}Игрок{FFFFFF}*\n*Уровень: {00CCFF}6{FFFFFF}.*\n*{00CCFF}Пахан{FFFFFF}*");
			if(Score >= 1200 && Score < 1400) format(Playerdr[i][Level],200,"{FFFFFF}*{00CCFF}*ViP*{FFFFFF}*\n*Уровень: {00CCFF}7{FFFFFF}.*\n*{00CCFF}Pro Drifter{FFFFFF}*");
			if(Score >= 1400 && Score < 1600) format(Playerdr[i][Level],200,"{FFFFFF}*{00CCFF}*ViP*{FFFFFF}*\n*Уровень: {00CCFF}8{FFFFFF}.*\n*{00CCFF}VIP{FFFFFF}*");
			if(Score >= 1600 && Score < 1800) format(Playerdr[i][Level],200,"{FFFFFF}*{00CCFF}*ViP*{FFFFFF}*\n*Уровень: {00CCFF}9{FFFFFF}.*\n*{00CCFF}Гловарь{FFFFFF}*");
			if(Score >= 1800 ) format(Playerdr[i][Level],200,"{FFFFFF}*{00CCFF}*ViP*{FFFFFF}*\n*Уровень: {00CCFF}*10*{FFFFFF}.*\n*{00CCFF}Король дрифта{FFFFFF}*");
//если используется score
			if(remotelock[i] == 0)
			{
				if(LevelStats[i] == 0) Attach3DTextLabelToPlayer(Level3D[i],i,0.0,0.0,1.00);
				Update3DTextLabelText(Level3D[i],0x00FF00FF,Playerdr[i][Level]);
				LevelStats[i] = 1;
			}
		}
 		TextDrawHideForPlayer(i,leveldr[0]);
  		TextDrawHideForPlayer(i,leveldr[1]);
   		TextDrawHideForPlayer(i,leveldr[2]);
   		TextDrawHideForPlayer(i,leveldr[3]);
    	TextDrawHideForPlayer(i,leveldr[4]);
    	TextDrawHideForPlayer(i,leveldr[5]);
    	TextDrawHideForPlayer(i,leveldr[6]);
    	TextDrawHideForPlayer(i,leveldr[7]);
    	TextDrawHideForPlayer(i,leveldr[8]);
    	TextDrawHideForPlayer(i,leveldr[9]);
    	TextDrawHideForPlayer(i,leveldr[10]);
//если используется money
/*
		new kill  = GetPlayerMoney(i);
 		if(kill >= 0 && kill <= 100000) { TextDrawShowForPlayer(i,leveldr[0]); }
  		else if(kill >= 100000 && kill <= 200000) { TextDrawShowForPlayer(i,leveldr[1]); }
   		else if(kill >= 200000 && kill <= 300000) { TextDrawShowForPlayer(i,leveldr[2]); }
    	else if(kill >= 300000 && kill <= 400000) { TextDrawShowForPlayer(i,leveldr[3]); }
    	else if(kill >= 400000 && kill <= 500000) { TextDrawShowForPlayer(i,leveldr[4]); }
    	else if(kill >= 500000 && kill <= 600000) { TextDrawShowForPlayer(i,leveldr[5]); }
    	else if(kill >= 600000 && kill <= 700000) { TextDrawShowForPlayer(i,leveldr[6]); }
    	else if(kill >= 700000 && kill <= 800000) { TextDrawShowForPlayer(i,leveldr[7]); }
    	else if(kill >= 800000 && kill <= 900000) { TextDrawShowForPlayer(i,leveldr[8]); }
    	else if(kill >= 900000 && kill <= 1000000) { TextDrawShowForPlayer(i,leveldr[9]); }
    	else if(kill >= 1000000) { TextDrawShowForPlayer(i,leveldr[10]); }
		else { TextDrawShowForPlayer(i,leveldr[0]); }
*/
//если используется money
//если используется score
		new kill  = GetPlayerScore(i);
 		if(kill >= 0 && kill <= 200) { TextDrawShowForPlayer(i,leveldr[0]); }
  		else if(kill >= 200 && kill <= 400) { TextDrawShowForPlayer(i,leveldr[1]); }
   		else if(kill >= 400 && kill <= 600) { TextDrawShowForPlayer(i,leveldr[2]); }
    	else if(kill >= 600 && kill <= 800) { TextDrawShowForPlayer(i,leveldr[3]); }
    	else if(kill >= 800 && kill <= 1000) { TextDrawShowForPlayer(i,leveldr[4]); }
    	else if(kill >= 1000 && kill <= 1200) { TextDrawShowForPlayer(i,leveldr[5]); }
    	else if(kill >= 1200 && kill <= 1400) { TextDrawShowForPlayer(i,leveldr[6]); }
    	else if(kill >= 1400 && kill <= 1600) { TextDrawShowForPlayer(i,leveldr[7]); }
    	else if(kill >= 1600 && kill <= 1800) { TextDrawShowForPlayer(i,leveldr[8]); }
    	else if(kill >= 1800 && kill <= 2000) { TextDrawShowForPlayer(i,leveldr[9]); }
    	else if(kill >= 2000) { TextDrawShowForPlayer(i,leveldr[10]); }
		else { TextDrawShowForPlayer(i,leveldr[0]); }
//если используется score
    }
    return 1;
}

public DriftCancellation(playerid){
	new locper;//если используется score
	PlayerDriftCancellation[playerid] = 0;
	GameTextForPlayer(playerid, Split("~n~~n~~n~~n~~n~~n~~n~~n~~w~~w~Drifting Bonus:~b~ ", tostr(DriftPointsNow[playerid]), "~w~ !"), 3000, 3);
	SetPVarInt(playerid, "MonControl", 1);
	GivePlayerMoney(playerid, DriftPointsNow[playerid]);
	locper = GetPlayerScore(playerid);//если используется score
	SetPVarInt(playerid, "ScorControl", 1);
	SetPlayerScore(playerid, (locper + (DriftPointsNow[playerid] / 1000)));//если используется score
	DriftPointsNow[playerid] = 0;
	dddrift[playerid] = 0;
    return 1;
}

Float:ReturnPlayerAngle(playerid){
	new Float:Ang;
	if(IsPlayerInAnyVehicle(playerid))GetVehicleZAngle(GetPlayerVehicleID(playerid), Ang); else GetPlayerFacingAngle(playerid, Ang);
	return Ang;
}

public Drift(){
	new Float:Angle1, Float:Angle2, Float:BySpeed, s[256];
	new Float:Z;
	new Float:X;
	new Float:Y;
	new Float:SpeedX;
	for(new g=0;g<MAX_PLAYERS;g++){
		if(IsPlayerConnected(g))
		{
			GetPlayerPos(g, X, Y, Z);
			SavedPos[ g ][ dltX ] = floatsub(X,SavedPos[ g ][ sX ]);
			SavedPos[ g ][ dltY ] = floatsub(Y,SavedPos[ g ][ sY ]);
			SavedPos[ g ][ dltZ ] = floatsub(Z,SavedPos[ g ][ sZ ]);
			SpeedX = floatsqroot(floatadd(floatadd(floatmul(SavedPos[ g ][ dltX ],SavedPos[ g ][ dltX ]),floatmul(SavedPos[ g ][ dltY ],SavedPos[ g ][ dltY ])),floatmul(SavedPos[ g ][ dltZ ],SavedPos[ g ][ dltZ ])));
			Angle1 = ReturnPlayerAngle(g);
			Angle2 = GetPlayerTheoreticAngle(g);
			BySpeed = floatmul(SpeedX, 12);
			if(IsPlayerInAnyVehicle(g) && floatabs(floatsub(Angle1, Angle2)) > DRIFT_MINKAT && floatabs(floatsub(Angle1, Angle2)) < DRIFT_MAXKAT && BySpeed > DRIFT_SPEED){
				if(PlayerDriftCancellation[g] > 0)KillTimer(PlayerDriftCancellation[g]);
				PlayerDriftCancellation[g] = 0;
				dddrift[g] += floatval( floatabs(floatsub(Angle1, Angle2)) * 3 * (BySpeed*0.1) )/10;
				if((dddrift[g] - DriftPointsNow[g]) > 2000)//если дрифт больше xxx, то:
				{
					dddrift[g] = 0;//обнуляем дрифт-очки
				}
				DriftPointsNow[g] = dddrift[g];//запоминаем последний дрифт
				PlayerDriftCancellation[g] = SetTimerEx("DriftCancellation", 3000, 0, "d", g);
			}
			if(DriftPointsNow[g] > 0){
				format(s, sizeof(s), "~n~~n~~n~~n~~n~~n~~n~~n~~w~Drifting Score: ~b~%d~w~ !", DriftPointsNow[g]);
				GameTextForPlayer(g, s, 3000, 3);
			}
			SavedPos[ g ][ sX ] = X;
			SavedPos[ g ][ sY ] = Y;
			SavedPos[ g ][ sZ ] = Z;

			new Float:x333, Float:y333, Float:z333;
			if(IsPlayerInAnyVehicle(g))GetVehiclePos(GetPlayerVehicleID(g), x333, y333, z333); else GetPlayerPos(g, x333, y333, z333);
			ppos[g][0] = x333;
			ppos[g][1] = y333;
			ppos[g][2] = z333;

		}
	}
    return 1;
}

Split(s1[], s2[], s3[]=""){
	new rxx[256];
	format(rxx, 256, "%s%s%s", s1, s2, s3);
	return rxx;
}

tostr(int){
	new st[256];
	format(st, 256, "%d", int);
	return st;
}

floatval(Float:val){
	new str[256];
	format(str, 256, "%.0f", val);
	return todec(str);
}

todec(str[]){ // By Luby
	return strval(str);
}

forward leveldrupr(playerid, reg);
public leveldrupr(playerid, reg)
{
	if(reg == 0)
	{
		remotelock[playerid] = 1;
		Delete3DTextLabel(Level3D[playerid]);
	}
	else
	{
		remotelock[playerid] = 0;
		Level3D[playerid] = Create3DTextLabel(" ",0xFFFFFFAA,0.000,0.000,-4.000,18.0,0,1);
		LevelStats[playerid] = 0;
	}
    return 1;
}

