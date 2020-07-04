#include <a_samp>

#include <streamer>
#include <MXini>

//==============================================================================
//                            ��������� �������
//==============================================================================

#define FS11INS 1 //��������� ������ �������:
//                 //FS11INS 0 - ������ 0.3z � ����
//                 //FS11INS 1 - ������ 0.3.7 � ����

#define FS22INS 1 //��� �������:
//                //FS22INS 1 - ����������� ������
//                //FS22INS 2 - Drift + DM ������ �� [Gn_R]
//                //FS22INS 3 - Drift non-DM ������ �� [Gn_R]
//                //FS22INS 4 - ��������� RDS ������� �� [Gn_R]

#undef MAX_PLAYERS
#define MAX_PLAYERS 101 //�������� ������� �� ������� + 1 (���� 50 �������, �� ����� 51 !!!)

#define GARAGE_MAX 300 //�������� ������� �� ������� (�� 1 �� 500)
#define GARAGE_PLAY 3 //�������� �������, ������� ����� ������ ���� ����� (�� 1 �� 5)

//   �������� !!! ����� ��������� �������� ����������� ��������������� !!!

//------------------------------------------------------------------------------

//   �������� !!! ��� ��������� ����� ������ ������ �� ����������� ������� !!!
//   �� �������� �� [Gn_R] ��� ��������� ������ �� ����� !!!
//   ���� � ���� ���� �������� ������ ����������, �� ����� ���������
//   ������ ���������� (� ����) ���������� �������� ������:

//		new carplay = GetPlayerVehicleID(playerid);
//		if(CallRemoteFunction("garagefunction", "d", carplay) != 0)//������ �� ���������� �� ������� �������
//		{
//			SendClientMessage(playerid, 0xFF0000FF, " ������ ! ��� ��������� ������� ������� !");
//			return 1;
//		}

//   ��� �� ��������� ����������� �������� ���������� ������� ������� !!!

//==============================================================================

//==============================================================================

#if (FS11INS < 0)
	#undef FS11INS
	#define FS11INS 0
#endif
#if (FS11INS > 1)
	#undef FS11INS
	#define FS11INS 1
#endif
#if (FS22INS < 1)
	#undef FS22INS
	#define FS22INS 1
#endif
#if (FS22INS > 4)
	#undef FS22INS
	#define FS22INS 4
#endif
#if (GARAGE_MAX < 1)
	#undef GARAGE_MAX
	#define GARAGE_MAX 1
#endif
#if (GARAGE_MAX > 500)
	#undef GARAGE_MAX
	#define GARAGE_MAX 500
#endif
#if (GARAGE_PLAY < 1)
	#undef GARAGE_PLAY
	#define GARAGE_PLAY 1
#endif
#if (GARAGE_PLAY > 5)
	#undef GARAGE_PLAY
	#define GARAGE_PLAY 5
#endif

forward LoadGarageSystem();//�������� ������� �������
forward UnloadGarageSystem();//�������� ������� �������
forward CarTest(carpl);//����������� ������������ ����������
forward CarGarageDel();//������ �� ������������ ���������� �� ������

new Text3D:fantxt;//���������� ��� �������� 3D-������ � ������������� ��
new obj1, obj2, obj3;//�� �������� ������� (�����������)
#if (FS11INS == 0)
	new objd[6];//�� �������� ������� (������������)
#endif
#if (FS11INS == 1)
	new objd[8];//�� �������� ������� (������������)
#endif
new RealName[MAX_PLAYERS][MAX_PLAYER_NAME];//�������� ��� ������
new garagecount[GARAGE_MAX];//0- ����� �� ������, 1- ����� ������
new garageplayname[GARAGE_MAX][MAX_PLAYER_NAME];//��� ��������� ������
new garagecost1[GARAGE_MAX];//��������� ������ (��� ��������)
new garagecost2[GARAGE_MAX];//��������� ������ (�������)
new garagelock[GARAGE_MAX];//0- ����� ������, 1- ����� ������
new garagevwin[GARAGE_MAX];//����������� ��� �������� ������ � �����
new garageintin[GARAGE_MAX];//�������� �������� ������ � �����
new Float:garagecordxin[GARAGE_MAX];//���������� �������� ������ � �����
new Float:garagecordyin[GARAGE_MAX];
new Float:garagecordzin[GARAGE_MAX];
new Float:garageanglein[GARAGE_MAX];//���� ������ �� ������
new Float:garagecordx[GARAGE_MAX];//���������� ������ ���������� � ������
new Float:garagecordy[GARAGE_MAX];
new Float:garagecordz[GARAGE_MAX];
new Float:garageangle[GARAGE_MAX];//���� ������ ���������� � ������
new garageint[GARAGE_MAX];//�������� ������
new garagecarmod[GARAGE_MAX];//������ ������������ ���������� � ������ (���� 0 - �� ��� ������������ ����������)
new garageslot[14][GARAGE_MAX];//����� ������� ������������ ���������� � ������
new PickupID[GARAGE_MAX];//������ �� �������
new MapIconID[GARAGE_MAX];//������ �� ���-������
new Text3D:Ngarage[GARAGE_MAX];//������ �� 3D-�������
new garagecarid[GARAGE_MAX];//������ �� ������������ ����������
new timerdel;//���������� ������� �� ������������ ���������� �� ������
new inttp1[MAX_PLAYERS];//�������� �� ������ ������� (������������ ���������)
new playgID1[MAX_PLAYERS];//����������� ��� �� ������ ������� (������������ ���������)
new Float:cordtpx[3] = {656.88, 660.63, 660.78};//���������� x �� ������ �������
new Float:cordtpy[3] = {31.29, -29.37, -80.24};//���������� y �� ������ �������
new Float:cordtpz[3] = {1050.91, 1048.00, 1047.99};//���������� z �� ������ �������
new DelayPlayer[MAX_PLAYERS];//�������� ������� �� ������������ ���������� �� ������
new inttp2[MAX_PLAYERS];//�������� �� ������ ������� (���������� ����������)
new playgID2[MAX_PLAYERS];//����������� ��� �� ������ ������� (���������� ����������)

public OnFilterScriptInit()
{
	fantxt = Create3DTextLabel(" ",0xFFFFFFAA,0.000,0.000,-4.000,18.0,0,1);//������ 3D-����� � ������������� ��
	//�������� 3
	obj1 = CreateObject(14798, 666.14838, -75.39060, 1048.19495,   0.00000, 0.00000, 0.00000);
	objd[0] = CreateDynamicObject(14797, 667.75000, -75.39060, 1048.31995,   0.00000, 0.00000, 0.00000);
	objd[1] = CreateDynamicObject(980, 658.96381, -75.38860, 1047.92798,   0.00000, 0.00000, -90.00000);//��������� ����� �� ������
	//�������� 2
	obj2 = CreateObject(14783, 666.17188, -26.42970, 1048.96106,   0.00000, 0.00000, 0.00000);
	objd[2] = CreateDynamicObject(14796, 661.27338, -26.52340, 1050.68799,   0.00000, 0.00000, 0.00000);
	objd[3] = CreateDynamicObject(14826, 668.60162, -29.09380, 1047.69495,   0.00000, 0.00000, 0.00000);
	objd[4] = CreateDynamicObject(980, 658.83789, -26.55720, 1047.94604,   0.00000, 0.00000, -90.00000);//��������� ����� �� ������
	//�������� 1
	obj3 = CreateObject(14776, 669.78912, 40.68750, 1056.43005,   0.00000, 0.00000, -90.00000);
	objd[5] = CreateDynamicObject(980, 653.67853, 40.95480, 1051.25903,   0.00000, 0.00000, -90.00000);//��������� ����� �� ������
#if (FS11INS == 1)
	objd[6] = CreateDynamicObject(19817, 663.96960, 38.74000, 1048.99597,   0.00000, 0.00000, -90.00000);//������ ��� ������� 0.3.7 � ���� !!!
	objd[7] = CreateDynamicObject(19817, 674.86853, 29.50200, 1049.10852,   0.00000, 0.00000, 180.00000);//������ ��� ������� 0.3.7 � ���� !!!
#endif
	new pname[MAX_PLAYER_NAME];
	for(new i; i < MAX_PLAYERS; i++)//���� ��� ���� �������
	{
		if(IsPlayerConnected(i))
		{
			GetPlayerName(i, pname, sizeof(pname));
			strdel(RealName[i], 0, MAX_PLAYER_NAME);//�������� �������� ��� ������
			new aa333[64];//��������� ��� ������������� ������� �����
			format(aa333, sizeof(aa333), "%s", pname);//��������� ��� ������������� ������� �����
			strcat(RealName[i], aa333);//��������� �������� ��� ������ (��������� ��� ������������� ������� �����)
//			strcat(RealName[i], pname);//��������� �������� ��� ������
		}
	}
	LoadGarageSystem();//�������� ������� �������
	timerdel = SetTimer("CarGarageDel", 517, 1);//������ �� ������������ ���������� �� ������
	return 1;
}

public OnFilterScriptExit()
{
	Delete3DTextLabel(fantxt);//������� 3D-����� � ������������� ��
	KillTimer(timerdel);//��������� ������� �� ������������ ���������� �� ������
	DestroyObject(obj1);
	DestroyObject(obj2);
	DestroyObject(obj3);
#if (FS11INS == 0)
	for(new i = 0; i < 6; i++)
	{
		DestroyDynamicObject(objd[i]);
	}
#endif
#if (FS11INS == 1)
	for(new i = 0; i < 8; i++)
	{
		DestroyDynamicObject(objd[i]);
	}
#endif
	UnloadGarageSystem();//�������� ������� �������
	return 1;
}

public OnPlayerConnect(playerid)
{
	new pname[MAX_PLAYER_NAME];
	GetPlayerName(playerid, pname, sizeof(pname));
	strdel(RealName[playerid], 0, MAX_PLAYER_NAME);//�������� �������� ��� ������
	new aa333[64];//��������� ��� ������������� ������� �����
	format(aa333, sizeof(aa333), "%s", pname);//��������� ��� ������������� ������� �����
	strcat(RealName[playerid], aa333);//��������� �������� ��� ������ (��������� ��� ������������� ������� �����)
//	strcat(RealName[playerid], pname);//��������� �������� ��� ������
	return 1;
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
	if(GetPVarInt(playerid, "CComAc8") < 0)
	{
		new dopcis, sstr[256];
		dopcis = FCislit(GetPVarInt(playerid, "CComAc8"));
		switch(dopcis)
		{
			case 0: format(sstr, sizeof(sstr), " ���� � ���� (��� � ��������) !   ���������� ����� %d ������ !", GetPVarInt(playerid, "CComAc8") * -1);
			case 1: format(sstr, sizeof(sstr), " ���� � ���� (��� � ��������) !   ���������� ����� %d ������� !", GetPVarInt(playerid, "CComAc8") * -1);
			case 2: format(sstr, sizeof(sstr), " ���� � ���� (��� � ��������) !   ���������� ����� %d ������� !", GetPVarInt(playerid, "CComAc8") * -1);
		}
		SendClientMessage(playerid, 0xFF0000FF, sstr);
		return 1;
	}
	SetPVarInt(playerid, "CComAc8", GetPVarInt(playerid, "CComAc8") + 1);
	new idx;
	idx = 0;
	new string[512];
	new sendername[MAX_PLAYER_NAME];
	new cmd[256];
	new tmp[256];
	cmd = strtok(cmdtext, idx);
	if(strcmp(cmd, "/grhelp", true) == 0)
	{
		if(IsPlayerAdmin(playerid))
		{
			SendClientMessage(playerid, 0x00FFFFFF, " ---------- ������� ������� (RCON �������) ----------- ");
			SendClientMessage(playerid, 0x00FFFFFF, "   /grhelp - ������ �� RCON �������� Garage");
			SendClientMessage(playerid, 0x00FFFFFF, "   /gcreate - ������� �����");
			SendClientMessage(playerid, 0x00FFFFFF, "   /gremove - ������� ����� �� ��� ID");
			SendClientMessage(playerid, 0x00FFFFFF, "   /gremoveall - ������� ��� ������");
			SendClientMessage(playerid, 0x00FFFFFF, "   /ggoto - ����������������� � ������ �� ��� ID");
			SendClientMessage(playerid, 0x00FFFFFF, "   /gspawn - ���������� ���� ��������� � �������");
			SendClientMessage(playerid, 0x00FFFFFF, "   /greload - ������������ ������� �������");
			SendClientMessage(playerid, 0x00FFFFFF, " -------------------------------------------------------------------------- ");
		}
		else
		{
			SendClientMessage(playerid, 0xFF0000FF, " � ��� ��� ���� �� ������������� ���� ������� !");
		}
		return 1;
	}
	if(strcmp(cmd, "/ghelp", true) == 0)
	{
		SendClientMessage(playerid, 0x00FFFFFF, " ------------------------ ������� ������� -------------------------- ");
		SendClientMessage(playerid, 0x00FFFFFF, "   /ghelp - ������ �� �������� Garage");
		SendClientMessage(playerid, 0x00FFFFFF, "   /gbuy - ������ �����   /gsale - ������� �����");
		SendClientMessage(playerid, 0x00FFFFFF, "   /glock - �������(�������) �����");
		SendClientMessage(playerid, 0x00FFFFFF, "   /genter - ����� � �����   /gexit - ����� �� ������");
		SendClientMessage(playerid, 0x00FFFFFF, "   /gsave - ��������� ��������� � ������");
		SendClientMessage(playerid, 0x00FFFFFF, "   /gdel - ������� (�� ���������) ��������� � ������");
		SendClientMessage(playerid, 0x00FFFFFF, "   /grsp - ���������� ��������� � ������");
		SendClientMessage(playerid, 0x00FFFFFF, " ----------------------------------------------------------------------------- ");
		return 1;
	}
	if(strcmp(cmd, "/gcreate", true) == 0)
	{
		if(IsPlayerAdmin(playerid))
		{
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, 0x00FFFFFF, " �����������: /gcreate [���������(50000-10000000 $)] [��������(1-3)]");
				return 1;
			}
			new para1 = strval(tmp);
			if(para1 < 50000 || para1 > 10000000)
			{
				SendClientMessage(playerid, 0xFF0000FF, " ��������� �� 50000 $ �� 10000000 $ !");
				return 1;
			}
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, 0xFF0000FF, " /gcreate [���������] [��������] !");
				return 1;
			}
			new para2 = strval(tmp);
			if(para2 < 1 || para2 > 3)
			{
				SendClientMessage(playerid, 0xFF0000FF, " �������� �� 1 �� 3 !");
				return 1;
			}
//------------------------------------------------------------------------------
//���� ������ �����������, ��: ������ ����� ����� ��������� ������ � 0-� ���������, � �� �������� ����� !
/*
			if(GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0)
			{
				SendClientMessage(playerid, 0xFF0000FF, " ����� ����� ������� ������ � 0-� ���������, � �� �������� ����� !");
				return 1;
			}
*/
//------------------------------------------------------------------------------
			new para3 = 0;
			new para4 = 0;
			while(para3 < GARAGE_MAX)
			{
				if(garagecount[para3] == 0)
				{
					para4 = 1;
					break;
				}
				para3++;
			}
			if(para4 == 0)
			{
				SendClientMessage(playerid, 0xFF0000FF, " �������� ����� �������� ������� !");
				SendClientMessage(playerid, 0xFF0000FF, " ��� ����������� - ��������� �������� ������� �� ������� !");
				return 1;
			}
			strdel(garageplayname[para3], 0, MAX_PLAYER_NAME);//������� ��� ��������� ������
			strcat(garageplayname[para3], "*** INV_PL_ID");
		    garagecost1[para3] = para1;//����� ��������� ������
		    garagecost2[para3] = para1;
			garagelock[para3] = 1;//��������� �����
			garagevwin[para3] = GetPlayerVirtualWorld(playerid);//����� ����������� ��� ����� � �����
			garageintin[para3] = GetPlayerInterior(playerid);//����� �������� ����� � �����
			GetPlayerPos(playerid, garagecordxin[para3], garagecordyin[para3], garagecordzin[para3]);//����� ���������� ����� � �����
			GetPlayerFacingAngle(playerid, garageanglein[para3]);//����� ���� ������ �� ������
			garageanglein[para3] = garageanglein[para3] + 180.00;
			if(garageanglein[para3] > 360.00) { garageanglein[para3] = garageanglein[para3] - 360.00; }
			if(para2 == 1)//���� ��� ����� �������� 1, ��:
			{
				garagecordx[para3] = 665.28;//����� ���������� ������ ���������� � ������
				garagecordy[para3] = -74.24;
				garagecordz[para3] = 1047.65;
				garageangle[para3] = 90.00;//����� ���� ������ ���������� � ������
				garageint[para3] = 3;//����� �������� ������
			}
			if(para2 == 2)//���� ��� ����� �������� 2, ��:
			{
				garagecordx[para3] = 666.78;//����� ���������� ������ ���������� � ������
				garagecordy[para3] = -24.82;
				garagecordz[para3] = 1047.72;
				garageangle[para3] = 90.00;//����� ���� ������ ���������� � ������
				garageint[para3] = 2;//����� �������� ������
			}
			if(para2 == 3)//���� ��� ����� �������� 3, ��:
			{
				garagecordx[para3] = 667.53;//����� ���������� ������ ���������� � ������
				garagecordy[para3] = 48.01;
				garagecordz[para3] = 1050.62;
				garageangle[para3] = 90.00;//����� ���� ������ ���������� � ������
				garageint[para3] = 1;//����� �������� ������
			}
			garagecarmod[para3] = 0;//����� ������ ������������ ���������� � ������ (������ ���)
			for(new i; i < 14; i++)
			{
				garageslot[i][para3] = 0;//������� ����� ������� ������������ ���������� � ������
			}
			garagecount[para3] = 1;//������ �����

    		new file, f[256];//������ ������ � ����
	    	format(f, 256, "garages/%i.ini", para3);
			file = ini_createFile(f);
			if(file >= 0)
			{
		    	ini_setString(file, "PlayName", garageplayname[para3]);
		    	ini_setInteger(file, "Cost1", garagecost1[para3]);
		    	ini_setInteger(file, "Cost2", garagecost2[para3]);
		    	ini_setInteger(file, "Lock", garagelock[para3]);
		    	ini_setInteger(file, "GarVWin", garagevwin[para3]);
		    	ini_setInteger(file, "GarIntin", garageintin[para3]);
		    	ini_setFloat(file, "CordXin", garagecordxin[para3]);
		    	ini_setFloat(file, "CordYin", garagecordyin[para3]);
		    	ini_setFloat(file, "CordZin", garagecordzin[para3]);
		    	ini_setFloat(file, "Anglein", garageanglein[para3]);
		    	ini_setFloat(file, "CordX", garagecordx[para3]);
		    	ini_setFloat(file, "CordY", garagecordy[para3]);
		    	ini_setFloat(file, "CordZ", garagecordz[para3]);
		    	ini_setFloat(file, "Angle", garageangle[para3]);
		    	ini_setInteger(file, "Interior", garageint[para3]);
		    	ini_setInteger(file, "CarMod", garagecarmod[para3]);
		    	ini_setInteger(file, "Slot00", garageslot[0][para3]);
		    	ini_setInteger(file, "Slot01", garageslot[1][para3]);
		    	ini_setInteger(file, "Slot02", garageslot[2][para3]);
		    	ini_setInteger(file, "Slot03", garageslot[3][para3]);
		    	ini_setInteger(file, "Slot04", garageslot[4][para3]);
		    	ini_setInteger(file, "Slot05", garageslot[5][para3]);
		    	ini_setInteger(file, "Slot06", garageslot[6][para3]);
		    	ini_setInteger(file, "Slot07", garageslot[7][para3]);
		    	ini_setInteger(file, "Slot08", garageslot[8][para3]);
		    	ini_setInteger(file, "Slot09", garageslot[9][para3]);
		    	ini_setInteger(file, "Slot10", garageslot[10][para3]);
		    	ini_setInteger(file, "Slot11", garageslot[11][para3]);
		    	ini_setInteger(file, "Slot12", garageslot[12][para3]);
		    	ini_setInteger(file, "Slot13", garageslot[13][para3]);
				ini_closeFile(file);
			}

			CallRemoteFunction("GPSrfun", "iiisifff", 3, 1, para3, garageplayname[para3],
			garagevwin[para3], garagecordxin[para3], garagecordyin[para3], garagecordzin[para3]);
			PickupID[para3] = CreateDynamicPickup(1318, 1, garagecordxin[para3], garagecordyin[para3], garagecordzin[para3],
			garagevwin[para3], garageintin[para3], -1, 25.0);//������ ����� ������
			MapIconID[para3] = CreateDynamicMapIcon(garagecordxin[para3], garagecordyin[para3], garagecordzin[para3], 55, -1,
			garagevwin[para3], garageintin[para3], -1, 200.0);//������ ���-������ ������
			format(string, sizeof(string), "�����: ��������\n���������: %d\n/gbuy - ������ �����\nID: %d", garagecost2[para3], para3);
			Ngarage[para3] = CreateDynamic3DTextLabel(string, 0xADFF2FFF, garagecordxin[para3], garagecordyin[para3], garagecordzin[para3]+0.70, 25,
			INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, garagevwin[para3], garageintin[para3], -1);//������ 3D-����� ������
			GetPlayerName(playerid, sendername, sizeof(sendername));
			new aa333[64];//��������� ��� ������������� ������� �����
			format(aa333, sizeof(aa333), "%s", sendername);//��������� ��� ������������� ������� �����
			printf("[Garage] ����� %s [%d] ������ ����� ID: %d .", aa333, playerid, para3);//��������� ��� ������������� ������� �����
//			printf("[Garage] ����� %s [%d] ������ ����� ID: %d .", sendername, playerid, para3);
			format(string, sizeof(string), " ����� ID: %d ������� ������.", para3);
			SendClientMessage(playerid, 0xFFFF00FF, string);
		}
		else
		{
			SendClientMessage(playerid, 0xFF0000FF, " � ��� ��� ���� �� ������������� ���� ������� !");
		}
		return 1;
	}
	if(strcmp(cmd, "/gremove", true) == 0)
	{
		if(IsPlayerAdmin(playerid))
		{
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, 0x00FFFFFF, " �����������: /gremove [ID ������]");
				return 1;
			}
			new para1 = strval(tmp);
			if(para1 < 0 || para1 >= GARAGE_MAX)
			{
				SendClientMessage(playerid, 0xFF0000FF, " ������ � ����� ID �� ���������� !");
				return 1;
			}
			format(string, sizeof(string), "garages/%i.ini", para1);
			if(fexist(string) || garagecount[para1] == 1)//���� ���� ��� ��� ����� ����������, ��:
			{
				DestroyDynamicPickup(PickupID[para1]);//������� ����� ������
				DestroyDynamicMapIcon(MapIconID[para1]);//������� ���-������ ������
				DestroyDynamic3DTextLabel(Ngarage[para1]);//������� 3D-����� ������
				if(fexist(string))//���� ���� ����������, ��:
				{
                    fremove(string);//������� ����
				}
				if(garagecarmod[para1] != 0)//���� ���� ���������� ���������, ��:
				{
					DestroyVehicle(garagecarid[para1]);//������� ��������� �� ������
				}
				garagecount[para1] = 0;//������� �����
				strdel(garageplayname[para1], 0, MAX_PLAYER_NAME);//������� ��� ��������� ������
				strcat(garageplayname[para1], "*** INV_PL_ID");
				CallRemoteFunction("GPSrfun", "iiisifff", 3, 0, para1, garageplayname[para1],
				0, 0.0, 0.0, 0.0);
				GetPlayerName(playerid, sendername, sizeof(sendername));
				new aa333[64];//��������� ��� ������������� ������� �����
				format(aa333, sizeof(aa333), "%s", sendername);//��������� ��� ������������� ������� �����
				printf("[Garage] ����� %s [%d] ������ ����� ID: %d .", aa333, playerid, para1);//��������� ��� ������������� ������� �����
//				printf("[Garage] ����� %s [%d] ������ ����� ID: %d .", sendername, playerid, para1);
				format(string, sizeof(string), " ����� ID: %d ������� �����.", para1);
				SendClientMessage(playerid, 0xFF0000FF, string);
			}
			else//���� �� ����, � �� ��� ����� �� ����������, ��:
			{
				SendClientMessage(playerid, 0xFF0000FF, " ������ � ����� ID �� ���������� !");
			}
		}
		else
		{
			SendClientMessage(playerid, 0xFF0000FF, " � ��� ��� ���� �� ������������� ���� ������� !");
		}
		return 1;
	}
	if(strcmp(cmd, "/gremoveall", true) == 0)
	{
		if(IsPlayerAdmin(playerid))
		{
			new para1 = 0;
			for(new i; i < GARAGE_MAX; i++)
			{
				format(string, sizeof(string), "garages/%i.ini", i);
				if(fexist(string) || garagecount[i] == 1)//���� ���� ��� ��� ����� ����������, ��:
				{
					para1 = 1;
					DestroyDynamicPickup(PickupID[i]);//������� ����� ������
					DestroyDynamicMapIcon(MapIconID[i]);//������� ���-������ ������
					DestroyDynamic3DTextLabel(Ngarage[i]);//������� 3D-����� ������
					if(fexist(string))//���� ���� ����������, ��:
					{
                    	fremove(string);//������� ����
					}
					if(garagecarmod[i] != 0)//���� ���� ���������� ���������, ��:
					{
						DestroyVehicle(garagecarid[i]);//������� ��������� �� ������
					}
					garagecount[i] = 0;//������� �����
					strdel(garageplayname[i], 0, MAX_PLAYER_NAME);//������� ��� ��������� ������
					strcat(garageplayname[i], "*** INV_PL_ID");
				}
				CallRemoteFunction("GPSrfun", "iiisifff", 3, 0, i, "*** INV_PL_ID",
				0, 0.0, 0.0, 0.0);
			}
			if(para1 == 1)
			{
				GetPlayerName(playerid, sendername, sizeof(sendername));
				new aa333[64];//��������� ��� ������������� ������� �����
				format(aa333, sizeof(aa333), "%s", sendername);//��������� ��� ������������� ������� �����
				printf("[Garage] ����� %s [%d] ������ ��� ������.", aa333, playerid);//��������� ��� ������������� ������� �����
//				printf("[Garage] ����� %s [%d] ������ ��� ������.", sendername, playerid);
				SendClientMessage(playerid, 0xFF0000FF, " ��� ������ ���� ������� �������.");
			}
			else
			{
				SendClientMessage(playerid, 0xFF0000FF, " �� ������� �� ������� �� ������ ������ !");
			}
		}
		else
		{
			SendClientMessage(playerid, 0xFF0000FF, " � ��� ��� ���� �� ������������� ���� ������� !");
		}
		return 1;
	}
	if(strcmp(cmd, "/ggoto", true) == 0)
	{
		if(IsPlayerAdmin(playerid))
		{
#if (FS22INS > 1)
			if(GetPVarInt(playerid, "SecPris") > 0)
			{
				SendClientMessage(playerid, 0xFF0000FF, " � ������ ������� �� �������� !");
				return 1;
			}
#endif
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, 0x00FFFFFF, " �����������: /ggoto [ID ������]");
				return 1;
			}
			new para1 = strval(tmp);
			if(para1 < 0 || para1 >= GARAGE_MAX)
			{
				SendClientMessage(playerid, 0xFF0000FF, " ������ � ����� ID �� ���������� !");
				return 1;
			}
			if(garagecount[para1] == 1)//���� ����� ����������, ��:
			{
				SetPlayerVirtualWorld(playerid, garagevwin[para1]);
 				SetPlayerInterior(playerid, garageintin[para1]);
				SetPlayerPos(playerid, garagecordxin[para1], garagecordyin[para1], garagecordzin[para1]);
				GetPlayerName(playerid, sendername, sizeof(sendername));
				new aa333[64];//��������� ��� ������������� ������� �����
				format(aa333, sizeof(aa333), "%s", sendername);//��������� ��� ������������� ������� �����
				printf("[Garage] ����� %s [%d] ���������������� � ������ ID: %d .", aa333, playerid, para1);//��������� ��� ������������� ������� �����
//				printf("[Garage] ����� %s [%d] ���������������� � ������ ID: %d .", sendername, playerid, para1);
				format(string, sizeof(string), " �� ����������������� � ������ ID: %d .", para1);
				SendClientMessage(playerid, 0x00FF00FF, string);
			}
			else//���� ����� �� ����������, ��:
			{
				SendClientMessage(playerid, 0xFF0000FF, " ������ � ����� ID �� ���������� !");
			}
		}
		else
		{
			SendClientMessage(playerid, 0xFF0000FF, " � ��� ��� ���� �� ������������� ���� ������� !");
		}
		return 1;
	}
	if(strcmp(cmd, "/gspawn", true) == 0)
	{
#if (FS22INS == 1)
		if(IsPlayerAdmin(playerid))
#endif
#if (FS22INS == 2 || FS22INS == 3)
		if(IsPlayerAdmin(playerid) || GetPVarInt(playerid, "AdmLvl") >= 2)
#endif
#if (FS22INS == 4)
		if(IsPlayerAdmin(playerid) || GetPVarInt(playerid, "AdmLvl") >= 5)
#endif
		{
			for(new i; i < GARAGE_MAX; i++)
			{
				if(garagecount[i] == 1 && garagecarmod[i] != 0)//���� ����� ����������, � � ������ ���� ���������� ���������, ��:
				{
					DestroyVehicle(garagecarid[i]);//������� ��������� �� ������
					garagecarid[i] = CreateVehicle(garagecarmod[i], garagecordx[i],garagecordy[i],garagecordz[i], garageangle[i], -1, -1, 90000);//������ ��������� � ������
					LinkVehicleToInterior(garagecarid[i], garageint[i]);//���������� ��������� � ��������� ������
					SetVehicleVirtualWorld(garagecarid[i], i+3000);//������������� ���������� ����������� ��� ������
					for(new j; j < 14; j++)
					{
						AddVehicleComponent(garagecarid[i], garageslot[j][i]);//��������� �� ��������� ������
					}
				}
			}
			GetPlayerName(playerid, sendername, sizeof(sendername));
			new aa333[64];//��������� ��� ������������� ������� �����
			format(aa333, sizeof(aa333), "%s", sendername);//��������� ��� ������������� ������� �����
			printf("[Garage] ����� %s [%d] ������ ���� ��������� ��������� � ������.", aa333, playerid);//��������� ��� ������������� ������� �����
//			printf("[Garage] ����� %s [%d] ������ ���� ��������� ��������� � ������.", sendername, playerid);
			format(string, sizeof(string), " ����� %s [%d] ������ ���� ��������� ��������� � ������.", sendername, playerid);
			SendClientMessageToAll(0xFF0000FF, string);
		}
		else
		{
			SendClientMessage(playerid, 0xFF0000FF, " � ��� ��� ���� �� ������������� ���� ������� !");
		}
		return 1;
	}
	if(strcmp(cmd, "/greload", true) == 0)
	{
		if(IsPlayerAdmin(playerid))
		{
			GetPlayerName(playerid, sendername, sizeof(sendername));
			new aa333[64];//��������� ��� ������������� ������� �����
			format(aa333, sizeof(aa333), "%s", sendername);//��������� ��� ������������� ������� �����
			printf("[Garage] ����� %s [%d] ����� ������������ ������� �������.", aa333, playerid);//��������� ��� ������������� ������� �����
//			printf("[Garage] ����� %s [%d] ����� ������������ ������� �������.", sendername, playerid);
			format(string, sizeof(string), " ����� %s [%d] ����� ������������ ������� �������.", sendername, playerid);
			SendClientMessageToAll(0xFF0000FF, string);
			SetTimerEx("reloadgarage1", 1000, 0, "i", playerid);
		}
		else
		{
			SendClientMessage(playerid, 0xFF0000FF, " � ��� ��� ���� �� ������������� ���� ������� !");
		}
		return 1;
	}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
	if(strcmp(cmd, "/gbuy", true) == 0)
	{
		new para1 = 0;
		for(new i; i < GARAGE_MAX; i++)//������� ����� ��� ��������� �������
		{
			if(garagecount[i] == 1 && strcmp(RealName[playerid], garageplayname[i], false) == 0) { para1++; }
		}
		if(para1 >= GARAGE_PLAY)
		{
			format(string, sizeof(string), " � ��� ��� ���� %d ������ !, ��� �� ������ ���� ����� -", para1);
			SendClientMessage(playerid, 0xFF0000FF, string);
			SendClientMessage(playerid, 0xFF0000FF, " �������� ���� �� ���� �� ����� ������������ ������� !");
			return 1;
		}
		para1 = 0;
		new para2 = 0;
		new playlocvw, playlocint;
		playlocvw = GetPlayerVirtualWorld(playerid);
		playlocint = GetPlayerInterior(playerid);
		while(para2 < GARAGE_MAX)
		{
			if(garagecount[para2] == 1)//���������� ��������� ���� ����� ����������
			{
				if(IsPlayerInRangeOfPoint(playerid, 4.00, garagecordxin[para2], garagecordyin[para2], garagecordzin[para2]) &&
				playlocvw == garagevwin[para2] && playlocint == garageintin[para2])
				{
					if(strcmp(garageplayname[para2], "*** INV_PL_ID", false) == 0)//���� ��� ��������� ����� , ��:
					{
						new para3;
#if (FS22INS == 1)
						para3 = GetPlayerMoney(playerid);
						if(GetPlayerMoney(playerid) < garagecost2[para2])//���� � ������ ������������ �����, ��:
						{
							para1 = -100;
							break;
						}
						SetPVarInt(playerid, "MonControl", 1);
						GivePlayerMoney(playerid, - garagecost2[para2]);//���������� ����� �� ����� ������
#endif
#if (FS22INS > 1)
						para3 = GetPVarInt(playerid, "PlMon");
						if(GetPVarInt(playerid, "PlMon") < garagecost2[para2])//���� � ������ ������������ �����, ��:
						{
							para1 = -100;
							break;
						}
						SetPVarInt(playerid, "PlMon", GetPVarInt(playerid, "PlMon") - garagecost2[para2]);//���������� ����� �� ����� ������
#endif
						para1 = 1;
						garagelock[para2] = 1;//��������� �����
						strdel(garageplayname[para2], 0, MAX_PLAYER_NAME);//����� ��� ��������� ������
						strcat(garageplayname[para2], RealName[playerid]);
						format(string, sizeof(string), "�����: %s\n������\n/glock - �������(�������) �����\n/genter - ����� � �����\nID: %d", garageplayname[para2], para2);
						UpdateDynamic3DTextLabelText(Ngarage[para2], 0xADFF2FFF, string);//��������� 3D-����� ������

						new file, f[256];//���������� ��������� � ����
						format(f, 256, "garages/%i.ini", para2);
						file = ini_openFile(f);
						if(file >= 0)
						{
		    				ini_setString(file, "PlayName", garageplayname[para2]);
							ini_setInteger(file, "Lock", garagelock[para2]);
							ini_closeFile(file);
						}

						CallRemoteFunction("GPSrfun", "iiisifff", 3, 1, para2, garageplayname[para2],
						garagevwin[para2], garagecordxin[para2], garagecordyin[para2], garagecordzin[para2]);
						GetPlayerName(playerid, sendername, sizeof(sendername));
						new aa333[64];//��������� ��� ������������� ������� �����
						format(aa333, sizeof(aa333), "%s", sendername);//��������� ��� ������������� ������� �����
						printf("[Garage] ����� %s [%d] ����� ����� (ID: %d) �� %d $ .", aa333, playerid, para2, garagecost2[para2]);//��������� ��� ������������� ������� �����
//						printf("[Garage] ����� %s [%d] ����� ����� (ID: %d) �� %d $ .", sendername, playerid, para2, garagecost2[para2]);
						SendClientMessage(playerid, 0x00FF00FF, " �� ������ ���� �����.");
						printf("[moneysys] ���������� ����� ������ %s [%d] : %d $", aa333, playerid, para3);//��������� ��� ������������� ������� �����
//						printf("[moneysys] ���������� ����� ������ %s [%d] : %d $", sendername, playerid, para3);
						break;
					}
				}
			}
			para2++;
		}
		if(para1 == -100)
		{
			SendClientMessage(playerid, 0xFF0000FF, " � ��� ������������ ����� ��� ������� ����� ������ !");
		}
		if(para1 == 0)
		{
			SendClientMessage(playerid, 0xFF0000FF, " ���� ����� ��� �����, ��� ����� ������� ������ !");
		}
		return 1;
	}
	if(strcmp(cmd, "/gsale", true) == 0)
	{
		new para1 = 0;
		new para2 = 0;
		new playlocvw, playlocint;
		playlocvw = GetPlayerVirtualWorld(playerid);
		playlocint = GetPlayerInterior(playerid);
		while(para2 < GARAGE_MAX)
		{
			if(garagecount[para2] == 1)//���������� ��������� ���� ����� ����������
			{
				if(IsPlayerInRangeOfPoint(playerid, 4.00, garagecordxin[para2], garagecordyin[para2], garagecordzin[para2]) &&
				playlocvw == garagevwin[para2] && playlocint == garageintin[para2])
				{
					if(strcmp(garageplayname[para2], RealName[playerid], false) == 0)//���� ��� ����� ������, ��:
					{
						para1 = 1;
						new para3, para4, para5, para6, para7;
						para3 = random(10);//0-4- ���������, 5-9- ��������� ������� �����
						para4 = garagecost2[para2] / 5;//����� 20% �� ��������� ������
						para5 = random(para4);//�������� ������� ����� �� 20% �� ��������� ������
						if(para3 >= 0 && para3 <= 4)//��������� ������� �����:
						{
							para6 = garagecost2[para2] - para5;
						}
						else//�����: (����������� ������� �����)
						{
							para6 = garagecost2[para2] + para5;
						}
						new para8;
#if (FS22INS == 1)
						para8 = GetPlayerMoney(playerid);
						SetPVarInt(playerid, "MonControl", 1);
						GivePlayerMoney(playerid, para6);//������� ����� ������
#endif
#if (FS22INS > 1)
						para8 = GetPVarInt(playerid, "PlMon");
						SetPVarInt(playerid, "PlMon", GetPVarInt(playerid, "PlMon") + para6);//������� ����� ������
#endif
						para3 = random(10);//0-4- ���������, 5-9- ��������� ��������� ������
						para4 = garagecost2[para2] / 5;//����� 20% �� ��������� ������
						para5 = random(para4);//�������� ��������� ������ �� 20%
						para7 = (garagecost1[para2] / 100) * 30;//����� 30% �� ��������� ������ (��� ��������)
						if(para3 >= 0 && para3 <= 4)//��������� ��������� ������:
						{
							garagecost2[para2] = garagecost2[para2] - para5;
							if(garagecost2[para2] < (garagecost1[para2] - para7))//����������� ��������� ������
							{//(���� ��� ������ ����������� �������)
								garagecost2[para2] = garagecost2[para2] + random(para4);
							}
						}
						else//�����: (����������� ��������� ������)
						{
							garagecost2[para2] = garagecost2[para2] + para5;
							if(garagecost2[para2] > (garagecost1[para2] + para7))//��������� ��������� ������
							{//(���� ��� ������ ����������� �������)
								garagecost2[para2] = garagecost2[para2] - random(para4);
							}
						}
						if(garagecarmod[para2] != 0)//���� ���� ���������� ���������, ��:
						{
							DestroyVehicle(garagecarid[para2]);//������� ��������� �� ������
						}
						garagelock[para2] = 1;//��������� �����
						strdel(garageplayname[para2], 0, MAX_PLAYER_NAME);//������� ��� ��������� ������
						strcat(garageplayname[para2], "*** INV_PL_ID");
						garagecarmod[para2] = 0;//����� ������ ������������ ���������� � ������ (������ ���)
						for(new i; i < 14; i++)
						{
							garageslot[i][para2] = 0;//������� ����� ������� ������������ ���������� � ������
						}
						format(string, sizeof(string), "�����: ��������\n���������: %d\n/gbuy - ������ �����\nID: %d", garagecost2[para2], para2);
						UpdateDynamic3DTextLabelText(Ngarage[para2], 0xADFF2FFF, string);//��������� 3D-����� ������

						new file, f[256];//���������� ��������� � ����
						format(f, 256, "garages/%i.ini", para2);
						file = ini_openFile(f);
						if(file >= 0)
						{
		    				ini_setString(file, "PlayName", garageplayname[para2]);
		    				ini_setInteger(file, "Cost2", garagecost2[para2]);
							ini_setInteger(file, "Lock", garagelock[para2]);
		    				ini_setInteger(file, "CarMod", garagecarmod[para2]);
	    					ini_setInteger(file, "Slot00", garageslot[0][para2]);
		    				ini_setInteger(file, "Slot01", garageslot[1][para2]);
		    				ini_setInteger(file, "Slot02", garageslot[2][para2]);
		    				ini_setInteger(file, "Slot03", garageslot[3][para2]);
		    				ini_setInteger(file, "Slot04", garageslot[4][para2]);
		    				ini_setInteger(file, "Slot05", garageslot[5][para2]);
		    				ini_setInteger(file, "Slot06", garageslot[6][para2]);
		    				ini_setInteger(file, "Slot07", garageslot[7][para2]);
		    				ini_setInteger(file, "Slot08", garageslot[8][para2]);
		    				ini_setInteger(file, "Slot09", garageslot[9][para2]);
		    				ini_setInteger(file, "Slot10", garageslot[10][para2]);
		    				ini_setInteger(file, "Slot11", garageslot[11][para2]);
		    				ini_setInteger(file, "Slot12", garageslot[12][para2]);
		    				ini_setInteger(file, "Slot13", garageslot[13][para2]);
							ini_closeFile(file);
						}

						CallRemoteFunction("GPSrfun", "iiisifff", 3, 1, para2, garageplayname[para2],
						garagevwin[para2], garagecordxin[para2], garagecordyin[para2], garagecordzin[para2]);
						GetPlayerName(playerid, sendername, sizeof(sendername));
						new aa333[64];//��������� ��� ������������� ������� �����
						format(aa333, sizeof(aa333), "%s", sendername);//��������� ��� ������������� ������� �����
						printf("[Garage] ����� %s [%d] ������ ����� (ID: %d) �� %d $ .", aa333, playerid, para2, para6);//��������� ��� ������������� ������� �����
//						printf("[Garage] ����� %s [%d] ������ ����� (ID: %d) �� %d $ .", sendername, playerid, para2, para6);
						format(string, sizeof(string), " �� ������� ���� ����� �� %d $ .", para6);
						SendClientMessage(playerid, 0xFFFF00FF, string);
						printf("[moneysys] ���������� ����� ������ %s [%d] : %d $", aa333, playerid, para8);//��������� ��� ������������� ������� �����
//						printf("[moneysys] ���������� ����� ������ %s [%d] : %d $", sendername, playerid, para8);
						break;
					}
				}
			}
			para2++;
		}
		if(para1 == 0)
		{
			SendClientMessage(playerid, 0xFF0000FF, " ��� �� ��� �����, ��� ����� ������� ������ !");
		}
		return 1;
	}
	if(strcmp(cmd, "/glock", true) == 0)
	{
		new para1 = 0;
		new para2 = 0;
		new playlocvw, playlocint;
		playlocvw = GetPlayerVirtualWorld(playerid);
		playlocint = GetPlayerInterior(playerid);
		while(para2 < GARAGE_MAX)
		{
			if(garagecount[para2] == 1)//���������� ��������� ���� ����� ����������
			{
				if(IsPlayerInRangeOfPoint(playerid, 4.00, garagecordxin[para2], garagecordyin[para2], garagecordzin[para2]) &&
				playlocvw == garagevwin[para2] && playlocint == garageintin[para2])
				{
					if(strcmp(garageplayname[para2], RealName[playerid], false) == 0)//���� ��� ����� ������, ��:
					{
						para1 = 1;
						GetPlayerName(playerid, sendername, sizeof(sendername));
						if(garagelock[para2] == 1)//���� ����� ������, ��:
						{
							garagelock[para2] = 0;//��������� �����
							format(string, sizeof(string), "�����: %s\n������\n/genter - ����� � �����\nID: %d", garageplayname[para2], para2);
							new aa333[64];//��������� ��� ������������� ������� �����
							format(aa333, sizeof(aa333), "%s", sendername);//��������� ��� ������������� ������� �����
							printf("[Garage] ����� %s [%d] ������ ���� ����� (ID: %d).", aa333, playerid, para2);//��������� ��� ������������� ������� �����
//							printf("[Garage] ����� %s [%d] ������ ���� ����� (ID: %d).", sendername, playerid, para2);
							SendClientMessage(playerid, 0x00FF00FF, " �� ������� ���� �����.");
						}
						else//�����:
						{
							garagelock[para2] = 1;//��������� �����
							format(string, sizeof(string), "�����: %s\n������\n/glock - �������(�������) �����\n/genter - ����� � �����\nID: %d", garageplayname[para2], para2);
							new aa333[64];//��������� ��� ������������� ������� �����
							format(aa333, sizeof(aa333), "%s", sendername);//��������� ��� ������������� ������� �����
							printf("[Garage] ����� %s [%d] ������ ���� ����� (ID: %d).", aa333, playerid, para2);//��������� ��� ������������� ������� �����
//							printf("[Garage] ����� %s [%d] ������ ���� ����� (ID: %d).", sendername, playerid, para2);
							SendClientMessage(playerid, 0xFF0000FF, " �� ������� ���� �����.");
						}

						new file, f[256];//���������� ��������� � ����
						format(f, 256, "garages/%i.ini", para2);
						file = ini_openFile(f);
						if(file >= 0)
						{
		    				ini_setInteger(file, "Lock", garagelock[para2]);
							ini_closeFile(file);
						}

						UpdateDynamic3DTextLabelText(Ngarage[para2], 0xADFF2FFF, string);//��������� 3D-����� ������
						break;
					}
				}
			}
			para2++;
		}
		if((IsPlayerInRangeOfPoint(playerid, 23.00, 666.46, -74.40, 1047.60+2.00) && playlocint == 3) ||
		(IsPlayerInRangeOfPoint(playerid, 23.00, 667.00, -24.70, 1048.84+2.00) && playlocint == 2) ||
		(IsPlayerInRangeOfPoint(playerid, 23.00, 666.80, 38.63, 1050.75+2.00) && playlocint == 1))
		{
			new gID = playlocvw-3000;
			if(gID >= 0 && gID < GARAGE_MAX)
			{
				if(strcmp(garageplayname[gID], RealName[playerid], false) == 0)//���� ��� ����� ������, ��:
				{
					para1 = 1;
					GetPlayerName(playerid, sendername, sizeof(sendername));
					if(garagelock[gID] == 1)//���� ����� ������, ��:
					{
						garagelock[gID] = 0;//��������� �����
						format(string, sizeof(string), "�����: %s\n������\n/genter - ����� � �����\nID: %d", garageplayname[gID], gID);
						new aa333[64];//��������� ��� ������������� ������� �����
						format(aa333, sizeof(aa333), "%s", sendername);//��������� ��� ������������� ������� �����
						printf("[Garage] ����� %s [%d] ������ ���� ����� (ID: %d).", aa333, playerid, gID);//��������� ��� ������������� ������� �����
//						printf("[Garage] ����� %s [%d] ������ ���� ����� (ID: %d).", sendername, playerid, gID);
						SendClientMessage(playerid, 0x00FF00FF, " �� ������� ���� �����.");
					}
					else//�����:
					{
						garagelock[gID] = 1;//��������� �����
						format(string, sizeof(string), "�����: %s\n������\n/glock - �������(�������) �����\n/genter - ����� � �����\nID: %d", garageplayname[gID], gID);
						new aa333[64];//��������� ��� ������������� ������� �����
						format(aa333, sizeof(aa333), "%s", sendername);//��������� ��� ������������� ������� �����
						printf("[Garage] ����� %s [%d] ������ ���� ����� (ID: %d).", aa333, playerid, gID);//��������� ��� ������������� ������� �����
//						printf("[Garage] ����� %s [%d] ������ ���� ����� (ID: %d).", sendername, playerid, gID);
						SendClientMessage(playerid, 0xFF0000FF, " �� ������� ���� �����.");
					}

					new file, f[256];//���������� ��������� � ����
					format(f, 256, "garages/%i.ini", gID);
					file = ini_openFile(f);
					if(file >= 0)
					{
		    			ini_setInteger(file, "Lock", garagelock[gID]);
						ini_closeFile(file);
					}

					UpdateDynamic3DTextLabelText(Ngarage[gID], 0xADFF2FFF, string);//��������� 3D-����� ������
				}
			}
		}
		if(para1 == 0)
		{
			SendClientMessage(playerid, 0xFF0000FF, " ��� �� ��� �����, ��� ����� ������� ������ !");
		}
		return 1;
	}
	if(strcmp(cmd, "/genter", true) == 0)
	{
#if (FS22INS > 1)
		if(GetPVarInt(playerid, "PlFrost") == 1)
		{
			SendClientMessage(playerid, 0xFF0000FF, " ������, �� ���������� !");
			return 1;
		}
#endif
		new para1 = 0;
		new para2 = 0;
		new playlocvw, playlocint;
		playlocvw = GetPlayerVirtualWorld(playerid);
		playlocint = GetPlayerInterior(playerid);
		while(para2 < GARAGE_MAX)
		{
			if(garagecount[para2] == 1)//���������� ��������� ���� ����� ����������
			{
				if(IsPlayerInRangeOfPoint(playerid, 4.00, garagecordxin[para2], garagecordyin[para2], garagecordzin[para2]) &&
				playlocvw == garagevwin[para2] && playlocint == garageintin[para2])
				{
					if(strcmp(garageplayname[para2], RealName[playerid], false) == 0)//���� ��� ����� ������, ��:
					{
						para1 = 1;
						if(GetPlayerState(playerid) == 2)//���� ����� �� ����� ��������, ��:
						{
							new carpl = GetPlayerVehicleID(playerid);//��������� �� ���������� ������
							if(CarTest(carpl) == 0)
							{
								SendClientMessage(playerid, 0xFF0000FF, " � ����� ����������� ������ ����� � ����� !");
								break;
							}
							if(garagecarmod[para2] != 0 &&
							((GetVehicleDistanceFromPoint(garagecarid[para2], 666.46, -74.40, 1047.60+2.00) <= 23.00 && garageint[para2] == 3) ||
							(GetVehicleDistanceFromPoint(garagecarid[para2], 667.00, -24.70, 1047.84+2.00) <= 23.00 && garageint[para2] == 2) ||
							(GetVehicleDistanceFromPoint(garagecarid[para2], 666.80, 38.63, 1050.75+2.00) <= 23.00 && garageint[para2] == 1)))
							{//���� ���� ���������� ���������, � �� ����� � ������, ��:
 								SetPlayerInterior(playerid, garageint[para2]);
								SetPlayerVirtualWorld(playerid, para2+3000);
								SetPlayerPos(playerid, cordtpx[garageint[para2]-1], cordtpy[garageint[para2]-1], cordtpz[garageint[para2]-1]);
							}
							else//�����: (���� ����������� ���������� ��� � ������)
							{
#if (FS22INS == 1)
								SetPlayerInterior(playerid, garageint[para2]);
								SetPlayerVirtualWorld(playerid, para2+3000);
								LinkVehicleToInterior(carpl, garageint[para2]);//���������� ��������� � �� ���������
								SetVehicleVirtualWorld(carpl, para2+3000);//���������� ���������� ����������� ��� ������
								for(new i = 0; i < MAX_PLAYERS; i++)
								{
									if(IsPlayerConnected(i))
									{
										if(GetPlayerVehicleID(i) == carpl && i != playerid)
										{//���������� ���������� �������� � ����������� ��� ������
											SetPlayerInterior(i, garageint[para2]);
											SetPlayerVirtualWorld(i, para2+3000);
										}
									}
								}
								SetVehiclePos(carpl, garagecordx[para2], garagecordy[para2], garagecordz[para2]);
								SetVehicleZAngle(carpl, garageangle[para2]);
								SetPlayerPos(playerid, garagecordx[para2], garagecordy[para2], garagecordz[para2]);
								PutPlayerInVehicle(playerid, carpl, 0);
#endif
#if (FS22INS == 2 || FS22INS == 3)
								CallRemoteFunction("StopDrift", "ddddffff", playerid, 7, garageint[para2], para2+3000, garageangle[para2],
								garagecordx[para2], garagecordy[para2], garagecordz[para2]);
#endif
#if (FS22INS == 4)
								CallRemoteFunction("StopDrift", "ddddffff", playerid, 2, garageint[para2], para2+3000, garageangle[para2],
								garagecordx[para2], garagecordy[para2], garagecordz[para2]);
#endif
							}
						}
						else//�����: (���� ����� �� �� ����� ��������)
						{
							if(garagecarmod[para2] != 0 &&
							((GetVehicleDistanceFromPoint(garagecarid[para2], 666.46, -74.40, 1047.60+2.00) <= 23.00 && garageint[para2] == 3) ||
							(GetVehicleDistanceFromPoint(garagecarid[para2], 667.00, -24.70, 1047.84+2.00) <= 23.00 && garageint[para2] == 2) ||
							(GetVehicleDistanceFromPoint(garagecarid[para2], 666.80, 38.63, 1050.75+2.00) <= 23.00 && garageint[para2] == 1)))
							{//���� ���� ���������� ���������, � �� ����� � ������, ��:
 								SetPlayerInterior(playerid, garageint[para2]);
								SetPlayerVirtualWorld(playerid, para2+3000);
								SetPlayerPos(playerid, cordtpx[garageint[para2]-1], cordtpy[garageint[para2]-1], cordtpz[garageint[para2]-1]);
							}
							else//�����: (���� ����������� ���������� ��� � ������)
							{
 								SetPlayerInterior(playerid, garageint[para2]);
								SetPlayerVirtualWorld(playerid, para2+3000);
								SetPlayerPos(playerid, garagecordx[para2], garagecordy[para2], garagecordz[para2]);
								SetPlayerFacingAngle(playerid, garageangle[para2]);
								SetCameraBehindPlayer(playerid);
							}
						}
						GetPlayerName(playerid, sendername, sizeof(sendername));
						new aa333[64];//��������� ��� ������������� ������� �����
						format(aa333, sizeof(aa333), "%s", sendername);//��������� ��� ������������� ������� �����
						printf("[Garage] ����� %s [%d] ����� � ���� ����� (ID: %d).", aa333, playerid, para2);//��������� ��� ������������� ������� �����
//						printf("[Garage] ����� %s [%d] ����� � ���� ����� (ID: %d).", sendername, playerid, para2);
						SendClientMessage(playerid, 0x00FF00FF, " �� ����� � ���� �����.");
						SendClientMessage(playerid, 0x00FFFFFF, " /ghelp - ��� ������� � �������� ������.");
						break;
					}
					if(strcmp(garageplayname[para2], RealName[playerid], false) != 0 && garagelock[para2] == 0)//���� ���� ����� �� ������,
					{//� ��� �������� �����, ��:
						para1 = 1;
						if(garagecarmod[para2] != 0 &&
							((GetVehicleDistanceFromPoint(garagecarid[para2], 666.46, -74.40, 1047.60+2.00) <= 23.00 && garageint[para2] == 3) ||
							(GetVehicleDistanceFromPoint(garagecarid[para2], 667.00, -24.70, 1047.84+2.00) <= 23.00 && garageint[para2] == 2) ||
							(GetVehicleDistanceFromPoint(garagecarid[para2], 666.80, 38.63, 1050.75+2.00) <= 23.00 && garageint[para2] == 1)))
						{//���� ���� ���������� ���������, � �� ����� � ������, ��:
 							SetPlayerInterior(playerid, garageint[para2]);
							SetPlayerVirtualWorld(playerid, para2+3000);
							SetPlayerPos(playerid, cordtpx[garageint[para2]-1], cordtpy[garageint[para2]-1], cordtpz[garageint[para2]-1]);
						}
						else//�����: (���� ����������� ���������� ��� � ������)
						{
 							SetPlayerInterior(playerid, garageint[para2]);
							SetPlayerVirtualWorld(playerid, para2+3000);
							SetPlayerPos(playerid, garagecordx[para2], garagecordy[para2], garagecordz[para2]);
							SetPlayerFacingAngle(playerid, garageangle[para2]);
							SetCameraBehindPlayer(playerid);
						}
						GetPlayerName(playerid, sendername, sizeof(sendername));
						new aa333[64];//��������� ��� ������������� ������� �����
						format(aa333, sizeof(aa333), "%s", sendername);//��������� ��� ������������� ������� �����
						printf("[Garage] ����� %s [%d] ����� � ����� (ID: %d).", aa333, playerid, para2);//��������� ��� ������������� ������� �����
//						printf("[Garage] ����� %s [%d] ����� � ����� (ID: %d).", sendername, playerid, para2);
						SendClientMessage(playerid, 0x00FF00FF, " �� ����� � �����.");
						SendClientMessage(playerid, 0x00FFFFFF, " /gexit - ����� �� ������.");
						break;
					}
				}
			}
			para2++;
		}
		if(para1 == 0)
		{
			SendClientMessage(playerid, 0xFF0000FF, " ��� �� ��� ����� !, ��� ����� ������ !,");
			SendClientMessage(playerid, 0xFF0000FF, " ��� ����� ������� ������ !");
		}
		return 1;
	}
	if(strcmp(cmd, "/gexit", true) == 0)
	{
#if (FS22INS > 1)
		if(GetPVarInt(playerid, "PlFrost") == 1)
		{
			SendClientMessage(playerid, 0xFF0000FF, " ������, �� ���������� !");
			return 1;
		}
#endif
		new para1 = 0;
		if((IsPlayerInRangeOfPoint(playerid, 23.00, 666.46, -74.40, 1047.60+2.00) && GetPlayerInterior(playerid) == 3) ||
		(IsPlayerInRangeOfPoint(playerid, 23.00, 667.00, -24.70, 1048.84+2.00) && GetPlayerInterior(playerid) == 2) ||
		(IsPlayerInRangeOfPoint(playerid, 23.00, 666.80, 38.63, 1050.75+2.00) && GetPlayerInterior(playerid) == 1))
		{
			new gID = GetPlayerVirtualWorld(playerid)-3000;
			if(gID >= 0 && gID < GARAGE_MAX)
			{
				new Float:Ang, Float:CorX, Float:CorY;
				Ang = garageanglein[gID] + 90.00;
				if(Ang > 360.00) { Ang = Ang - 360.00; }
				Ang = floatdiv(floatmul(Ang, 3.1416), 180.00);
				if(strcmp(garageplayname[gID], RealName[playerid], false) == 0)//���� ��� ����� ������, ��:
				{
					para1 = 1;
					if(GetPlayerState(playerid) == 2)//���� ����� �� ����� ��������, ��:
					{
						CorX = floatmul(floatcos(Ang), 4.00);
						CorY = floatmul(floatsin(Ang), 4.00);
#if (FS22INS == 1)
						new carpl = GetPlayerVehicleID(playerid);//��������� �� ���������� ������
						SetPlayerInterior(playerid, garageintin[gID]);
						SetPlayerVirtualWorld(playerid, garagevwin[gID]);
						LinkVehicleToInterior(carpl, garageintin[gID]);//���������� ��������� � �� ���������
						SetVehicleVirtualWorld(carpl, garagevwin[gID]);//���������� ���������� ����������� ��� ������
						for(new i = 0; i < MAX_PLAYERS; i++)
						{
							if(IsPlayerConnected(i))
							{
								if(GetPlayerVehicleID(i) == carpl && i != playerid)
								{//���������� ���������� �������� � ����������� ��� ������
									SetPlayerInterior(i, garageintin[gID]);
									SetPlayerVirtualWorld(i, garagevwin[gID]);
								}
							}
						}
						SetVehiclePos(carpl, garagecordxin[gID]+CorX, garagecordyin[gID]+CorY, garagecordzin[gID]+2.00);
						SetVehicleZAngle(carpl, garageanglein[gID]);
						SetPlayerPos(playerid, garagecordxin[gID]+CorX, garagecordyin[gID]+CorY, garagecordzin[gID]+2.00);
						PutPlayerInVehicle(playerid, carpl, 0);
#endif
#if (FS22INS == 2 || FS22INS == 3)
						CallRemoteFunction("StopDrift", "ddddffff", playerid, 7, garageintin[gID], garagevwin[gID],
						garageanglein[gID], garagecordxin[gID]+CorX, garagecordyin[gID]+CorY, garagecordzin[gID]+2.00);
#endif
#if (FS22INS == 4)
						CallRemoteFunction("StopDrift", "ddddffff", playerid, 2, garageintin[gID], garagevwin[gID],
						garageanglein[gID], garagecordxin[gID]+CorX, garagecordyin[gID]+CorY, garagecordzin[gID]+2.00);
#endif
					}
					else//�����:
					{
						CorX = floatmul(floatcos(Ang), 2.00);
						CorY = floatmul(floatsin(Ang), 2.00);
 						SetPlayerInterior(playerid, garageintin[gID]);
						SetPlayerVirtualWorld(playerid, garagevwin[gID]);
						SetPlayerPos(playerid, garagecordxin[gID]+CorX, garagecordyin[gID]+CorY, garagecordzin[gID]+2.00);
						SetPlayerFacingAngle(playerid, garageanglein[gID]);
						SetCameraBehindPlayer(playerid);
					}
					GetPlayerName(playerid, sendername, sizeof(sendername));
					new aa333[64];//��������� ��� ������������� ������� �����
					format(aa333, sizeof(aa333), "%s", sendername);//��������� ��� ������������� ������� �����
					printf("[Garage] ����� %s [%d] ����� �� ������ ������ (ID: %d).", aa333, playerid, gID);//��������� ��� ������������� ������� �����
//					printf("[Garage] ����� %s [%d] ����� �� ������ ������ (ID: %d).", sendername, playerid, gID);
					SendClientMessage(playerid, 0xFFFF00FF, " �� ����� �� ������ ������.");
				}
				else//���� ���� ����� �� ������, ��:
				{
					para1 = 1;
					CorX = floatmul(floatcos(Ang), 2.00);
					CorY = floatmul(floatsin(Ang), 2.00);
 					SetPlayerInterior(playerid, garageintin[gID]);
					SetPlayerVirtualWorld(playerid, garagevwin[gID]);
					SetPlayerPos(playerid, garagecordxin[gID]+CorX, garagecordyin[gID]+CorY, garagecordzin[gID]+2.00);
					SetPlayerFacingAngle(playerid, garageanglein[gID]);
					SetCameraBehindPlayer(playerid);
					GetPlayerName(playerid, sendername, sizeof(sendername));
					new aa333[64];//��������� ��� ������������� ������� �����
					format(aa333, sizeof(aa333), "%s", sendername);//��������� ��� ������������� ������� �����
					printf("[Garage] ����� %s [%d] ����� �� ������ (ID: %d).", aa333, playerid, gID);//��������� ��� ������������� ������� �����
//					printf("[Garage] ����� %s [%d] ����� �� ������ (ID: %d).", sendername, playerid, gID);
					SendClientMessage(playerid, 0xFFFF00FF, " �� ����� �� ������.");
				}
			}
		}
		if(para1 == 0)
		{
			SendClientMessage(playerid, 0xFF0000FF, " ��� ������� �������� ������ � ������ !");
		}
		return 1;
	}
	if(strcmp(cmd, "/gsave", true) == 0)
	{
#if (FS22INS > 1)
		if(GetPVarInt(playerid, "PlFrost") == 1)
		{
			SendClientMessage(playerid, 0xFF0000FF, " ������, �� ���������� !");
			return 1;
		}
#endif
		new para1 = 0;
		inttp2[playerid] = GetPlayerInterior(playerid);
		if((IsPlayerInRangeOfPoint(playerid, 23.00, 666.46, -74.40, 1047.60+2.00) && inttp2[playerid] == 3) ||
		(IsPlayerInRangeOfPoint(playerid, 23.00, 667.00, -24.70, 1048.84+2.00) && inttp2[playerid] == 2) ||
		(IsPlayerInRangeOfPoint(playerid, 23.00, 666.80, 38.63, 1050.75+2.00) && inttp2[playerid] == 1))
		{
			playgID2[playerid] = GetPlayerVirtualWorld(playerid)-3000;
			if(playgID2[playerid] >= 0 && playgID2[playerid] < GARAGE_MAX)
			{
				if(strcmp(garageplayname[playgID2[playerid]], RealName[playerid], false) == 0)//���� ��� ����� ������, ��:
				{
					para1 = 1;
					if(GetPlayerState(playerid) == 2)//���� ����� �� ����� ��������, ��:
					{
						new carpl = GetPlayerVehicleID(playerid);//��������� �� ���������� ������
						if(CarTest(carpl) == 0)
						{
							SendClientMessage(playerid, 0xFF0000FF, " ����� ��������� ������ ��������� � ���� ������ !");
							return 1;
						}
						if(garagecarmod[playgID2[playerid]] != 0)//���� ���� ���������� ���������, ��:
						{
							DestroyVehicle(garagecarid[playgID2[playerid]]);//������� ��������� �� ������
						}
						for(new i; i < 14; i++)
						{
							garageslot[i][playgID2[playerid]] = GetVehicleComponentInSlot(carpl, i);//������ � ���������� ������
						}
						garagecarmod[playgID2[playerid]] = GetVehicleModel(carpl);//��������� �� ������ ���������� ������

						new file, f[256];//���������� ��������� � ����
						format(f, 256, "garages/%i.ini", playgID2[playerid]);
						file = ini_openFile(f);
						if(file >= 0)
						{
		    				ini_setInteger(file, "CarMod", garagecarmod[playgID2[playerid]]);
	    					ini_setInteger(file, "Slot00", garageslot[0][playgID2[playerid]]);
		    				ini_setInteger(file, "Slot01", garageslot[1][playgID2[playerid]]);
		    				ini_setInteger(file, "Slot02", garageslot[2][playgID2[playerid]]);
		    				ini_setInteger(file, "Slot03", garageslot[3][playgID2[playerid]]);
		    				ini_setInteger(file, "Slot04", garageslot[4][playgID2[playerid]]);
		    				ini_setInteger(file, "Slot05", garageslot[5][playgID2[playerid]]);
		    				ini_setInteger(file, "Slot06", garageslot[6][playgID2[playerid]]);
		    				ini_setInteger(file, "Slot07", garageslot[7][playgID2[playerid]]);
		    				ini_setInteger(file, "Slot08", garageslot[8][playgID2[playerid]]);
		    				ini_setInteger(file, "Slot09", garageslot[9][playgID2[playerid]]);
		    				ini_setInteger(file, "Slot10", garageslot[10][playgID2[playerid]]);
		    				ini_setInteger(file, "Slot11", garageslot[11][playgID2[playerid]]);
		    				ini_setInteger(file, "Slot12", garageslot[12][playgID2[playerid]]);
		    				ini_setInteger(file, "Slot13", garageslot[13][playgID2[playerid]]);
							ini_closeFile(file);
						}

						new Float:Ang, Float:CorX, Float:CorY;
						Ang = garageanglein[playgID2[playerid]] + 90.00;
						if(Ang > 360.00) { Ang = Ang - 360.00; }
						Ang = floatdiv(floatmul(Ang, 3.1416), 180.00);
						CorX = floatmul(floatcos(Ang), 4.00);
						CorY = floatmul(floatsin(Ang), 4.00);
#if (FS22INS == 1)
						SetPlayerInterior(playerid, garageintin[playgID2[playerid]]);
						SetPlayerVirtualWorld(playerid, garagevwin[playgID2[playerid]]);
						LinkVehicleToInterior(carpl, garageintin[playgID2[playerid]]);//���������� ��������� � �� ���������
						SetVehicleVirtualWorld(carpl, garagevwin[playgID2[playerid]]);//���������� ���������� ����������� ��� ������
						for(new i = 0; i < MAX_PLAYERS; i++)
						{
							if(IsPlayerConnected(i))
							{
								if(GetPlayerVehicleID(i) == carpl && i != playerid)
								{//���������� ���������� �������� � ����������� ��� ������
									SetPlayerInterior(i, garageintin[playgID2[playerid]]);
									SetPlayerVirtualWorld(i, garagevwin[playgID2[playerid]]);
								}
							}
						}
						SetVehiclePos(carpl, garagecordxin[playgID2[playerid]]+CorX, garagecordyin[playgID2[playerid]]+CorY, garagecordzin[playgID2[playerid]]+2.00);
						SetVehicleZAngle(carpl, garageanglein[playgID2[playerid]]);
						SetPlayerPos(playerid, garagecordxin[playgID2[playerid]]+CorX, garagecordyin[playgID2[playerid]]+CorY, garagecordzin[playgID2[playerid]]+2.00);
						PutPlayerInVehicle(playerid, carpl, 0);
#endif
#if (FS22INS == 2 || FS22INS == 3)
						CallRemoteFunction("StopDrift", "ddddffff", playerid, 7, garageintin[playgID2[playerid]], garagevwin[playgID2[playerid]], garageanglein[playgID2[playerid]],
						garagecordxin[playgID2[playerid]]+CorX, garagecordyin[playgID2[playerid]]+CorY, garagecordzin[playgID2[playerid]]+2.00);
#endif
#if (FS22INS == 4)
						CallRemoteFunction("StopDrift", "ddddffff", playerid, 2, garageintin[playgID2[playerid]], garagevwin[playgID2[playerid]], garageanglein[playgID2[playerid]],
						garagecordxin[playgID2[playerid]]+CorX, garagecordyin[playgID2[playerid]]+CorY, garagecordzin[playgID2[playerid]]+2.00);
#endif
						SetTimerEx("playret2", 1000, 0, "i", playerid);
					}
					else
					{
						SendClientMessage(playerid, 0xFF0000FF, " �� ������ ���� �� ����� �������� !");
					}
				}
			}
		}
		if(para1 == 0)
		{
			SendClientMessage(playerid, 0xFF0000FF, " ��� ������� �������� ������ � ������ !");
		}
		return 1;
	}
	if(strcmp(cmd, "/gdel", true) == 0)
	{
		new para1 = 0;
		if((IsPlayerInRangeOfPoint(playerid, 23.00, 666.46, -74.40, 1047.60+2.00) && GetPlayerInterior(playerid) == 3) ||
		(IsPlayerInRangeOfPoint(playerid, 23.00, 667.00, -24.70, 1048.84+2.00) && GetPlayerInterior(playerid) == 2) ||
		(IsPlayerInRangeOfPoint(playerid, 23.00, 666.80, 38.63, 1050.75+2.00) && GetPlayerInterior(playerid) == 1))
		{
			new gID = GetPlayerVirtualWorld(playerid)-3000;
			if(gID >= 0 && gID < GARAGE_MAX)
			{
				if(strcmp(garageplayname[gID], RealName[playerid], false) == 0)//���� ��� ����� ������, ��:
				{
					para1 = 1;
					if(garagecarmod[gID] == 0)
					{
						SendClientMessage(playerid, 0xFF0000FF, " � ��� ��� ����������� ���������� � ���� ������ !");
						return 1;
					}
					DestroyVehicle(garagecarid[gID]);//������� ��������� �� ������
					garagecarmod[gID] = 0;//����� ������ ������������ ���������� � ������ (������ ���)
					for(new i; i < 14; i++)
					{
						garageslot[i][gID] = 0;//������� ����� ������� ������������ ���������� � ������
					}

					new file, f[256];//���������� ��������� � ����
					format(f, 256, "garages/%i.ini", gID);
					file = ini_openFile(f);
					if(file >= 0)
					{
		    			ini_setInteger(file, "CarMod", garagecarmod[gID]);
	    				ini_setInteger(file, "Slot00", garageslot[0][gID]);
		    			ini_setInteger(file, "Slot01", garageslot[1][gID]);
		    			ini_setInteger(file, "Slot02", garageslot[2][gID]);
		    			ini_setInteger(file, "Slot03", garageslot[3][gID]);
		    			ini_setInteger(file, "Slot04", garageslot[4][gID]);
		    			ini_setInteger(file, "Slot05", garageslot[5][gID]);
		    			ini_setInteger(file, "Slot06", garageslot[6][gID]);
		    			ini_setInteger(file, "Slot07", garageslot[7][gID]);
		    			ini_setInteger(file, "Slot08", garageslot[8][gID]);
		    			ini_setInteger(file, "Slot09", garageslot[9][gID]);
		    			ini_setInteger(file, "Slot10", garageslot[10][gID]);
		    			ini_setInteger(file, "Slot11", garageslot[11][gID]);
		    			ini_setInteger(file, "Slot12", garageslot[12][gID]);
		    			ini_setInteger(file, "Slot13", garageslot[13][gID]);
						ini_closeFile(file);
					}

					GetPlayerName(playerid, sendername, sizeof(sendername));
					new aa333[64];//��������� ��� ������������� ������� �����
					format(aa333, sizeof(aa333), "%s", sendername);//��������� ��� ������������� ������� �����
					printf("[Garage] ����� %s [%d] ������ ��������� � ���� ������ (ID: %d).", aa333, playerid, gID);//��������� ��� ������������� ������� �����
//					printf("[Garage] ����� %s [%d] ������ ��������� � ���� ������ (ID: %d).", sendername, playerid, gID);
					SendClientMessage(playerid, 0xFF0000FF, " �� ������� ��������� � ���� ������.");
				}
			}
		}
		if(para1 == 0)
		{
			SendClientMessage(playerid, 0xFF0000FF, " ��� ������� �������� ������ � ������ !");
		}
		return 1;
	}
	if(strcmp(cmd, "/grsp", true) == 0)
	{
		new para1 = 0;
		if((IsPlayerInRangeOfPoint(playerid, 23.00, 666.46, -74.40, 1047.60+2.00) && GetPlayerInterior(playerid) == 3) ||
		(IsPlayerInRangeOfPoint(playerid, 23.00, 667.00, -24.70, 1048.84+2.00) && GetPlayerInterior(playerid) == 2) ||
		(IsPlayerInRangeOfPoint(playerid, 23.00, 666.80, 38.63, 1050.75+2.00) && GetPlayerInterior(playerid) == 1))
		{
			new gID = GetPlayerVirtualWorld(playerid)-3000;
			if(gID >= 0 && gID < GARAGE_MAX)
			{
				if(strcmp(garageplayname[gID], RealName[playerid], false) == 0)//���� ��� ����� ������, ��:
				{
					para1 = 1;
					if(garagecarmod[gID] == 0)
					{
						SendClientMessage(playerid, 0xFF0000FF, " � ��� ��� ����������� ���������� � ���� ������ !");
						return 1;
					}
					DestroyVehicle(garagecarid[gID]);//������� ��������� �� ������
					garagecarid[gID] = CreateVehicle(garagecarmod[gID], garagecordx[gID],garagecordy[gID],garagecordz[gID], garageangle[gID], -1, -1, 90000);//������ ��������� � ������
					LinkVehicleToInterior(garagecarid[gID], garageint[gID]);//���������� ��������� � ��������� ������
					SetVehicleVirtualWorld(garagecarid[gID], gID+3000);//������������� ���������� ����������� ��� ������
					for(new i; i < 14; i++)
					{
						AddVehicleComponent(garagecarid[gID], garageslot[i][gID]);//��������� �� ��������� ������
					}
					GetPlayerName(playerid, sendername, sizeof(sendername));
					new aa333[64];//��������� ��� ������������� ������� �����
					format(aa333, sizeof(aa333), "%s", sendername);//��������� ��� ������������� ������� �����
					printf("[Garage] ����� %s [%d] ��������� ��������� � ���� ������ (ID: %d).", aa333, playerid, gID);//��������� ��� ������������� ������� �����
//					printf("[Garage] ����� %s [%d] ��������� ��������� � ���� ������ (ID: %d).", sendername, playerid, gID);
					SendClientMessage(playerid, 0xFFFF00FF, " �� ���������� ��������� � ���� ������.");
				}
			}
		}
		if(para1 == 0)
		{
			SendClientMessage(playerid, 0xFF0000FF, " ��� ������� �������� ������ � ������ !");
		}
		return 1;
	}
	return 0;
}

public CarTest(carpl)//����������� ������������ ����������
{
	new modelcar;
	modelcar = GetVehicleModel(carpl);//��������� �� ������ ���������� ������
	switch(modelcar)
	{
		case 435:return 0;//���������, ������� � ������� ���������
		case 450:return 0;
		case 591:return 0;
		case 584:return 0;
		case 499:return 0;
		case 498:return 0;
		case 609:return 0;
		case 524:return 0;
		case 532:return 0;
		case 578:return 0;
		case 486:return 0;
		case 406:return 0;
		case 573:return 0;
		case 455:return 0;
		case 588:return 0;
		case 403:return 0;
		case 423:return 0;
		case 414:return 0;
		case 443:return 0;
		case 515:return 0;
		case 514:return 0;
		case 531:return 0;
		case 610:return 0;
		case 456:return 0;

		case 459:return 0;//�������� ��������� � �������
		case 422:return 0;
		case 482:return 0;
		case 530:return 0;
		case 418:return 0;
		case 572:return 0;
		case 582:return 0;
		case 413:return 0;
		case 440:return 0;
		case 543:return 0;
		case 583:return 0;
		case 478:return 0;
		case 554:return 0;

		case 568:return 0;//���� ��� �����������
		case 424:return 0;
		case 504:return 0;
		case 457:return 0;
		case 483:return 0;
		case 508:return 0;
//		case 571:return 0;
		case 500:return 0;
		case 444:return 0;
		case 556:return 0;
		case 557:return 0;
		case 471:return 0;
		case 495:return 0;
		case 539:return 0;

		case 606:return 0;//���� ��� ���������������
		case 607:return 0;
		case 485:return 0;
		case 431:return 0;
		case 438:return 0;
		case 437:return 0;
		case 574:return 0;
		case 611:return 0;
//		case 420:return 0;
		case 525:return 0;
		case 408:return 0;
		case 608:return 0;
		case 552:return 0;

		case 416:return 0;//������������ � ��������������� ���������
		case 433:return 0;
		case 427:return 0;
		case 490:return 0;
		case 528:return 0;
		case 407:return 0;
		case 544:return 0;
		case 523:return 0;
		case 470:return 0;
		case 596:return 0;
		case 597:return 0;
		case 598:return 0;
		case 599:return 0;
		case 432:return 0;
		case 428:return 0;
		case 601:return 0;

		case 592:return 0;//��������� ���������
		case 577:return 0;
		case 511:return 0;
		case 548:return 0;
		case 512:return 0;
		case 593:return 0;
		case 425:return 0;
		case 417:return 0;
		case 487:return 0;
		case 553:return 0;
		case 488:return 0;
		case 497:return 0;
		case 563:return 0;
		case 476:return 0;
		case 447:return 0;
		case 519:return 0;
		case 460:return 0;
		case 469:return 0;
		case 513:return 0;
		case 520:return 0;

		case 472:return 0;//�����
		case 473:return 0;
		case 493:return 0;
		case 595:return 0;
		case 484:return 0;
		case 430:return 0;
		case 453:return 0;
		case 452:return 0;
		case 446:return 0;
		case 454:return 0;

		case 441:return 0;//���������������� ��������� � ������� ����
		case 464:return 0;
		case 594:return 0;
		case 465:return 0;
		case 501:return 0;
		case 564:return 0;
//		case 604:return 0;
//		case 605:return 0;
	}
	return 1;
}

public CarGarageDel()//������ �� ������������ ���������� �� ������
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			inttp1[i] = GetPlayerInterior(i);
			if((IsPlayerInRangeOfPoint(i, 23.00, 666.46, -74.40, 1047.60+2.00) && inttp1[i] == 3) ||
			(IsPlayerInRangeOfPoint(i, 23.00, 667.00, -24.70, 1048.84+2.00) && inttp1[i] == 2) ||
			(IsPlayerInRangeOfPoint(i, 23.00, 666.80, 38.63, 1050.75+2.00) && inttp1[i] == 1))
			{
				playgID1[i] = GetPlayerVirtualWorld(i)-3000;
				if(playgID1[i] >= 0 && playgID1[i] < GARAGE_MAX)
				{
					new carpl = GetPlayerVehicleID(i);//��������� �� ���������� ������
					if(CarTest(carpl) == 0)
					{
#if (FS22INS != 3)
						if(DelayPlayer[i] == 1)
#endif
#if (FS22INS == 3)
						if(DelayPlayer[i] == 2)
#endif
						{
							new Float:Ang, Float:CorX, Float:CorY;
							Ang = garageanglein[playgID1[i]] + 90.00;
							if(Ang > 360.00) { Ang = Ang - 360.00; }
							Ang = floatdiv(floatmul(Ang, 3.1416), 180.00);
							CorX = floatmul(floatcos(Ang), 4.00);
							CorY = floatmul(floatsin(Ang), 4.00);
							SetPlayerInterior(i, garageintin[playgID1[i]]);
							SetPlayerVirtualWorld(i, garagevwin[playgID1[i]]);
							LinkVehicleToInterior(carpl, garageintin[playgID1[i]]);//���������� ��������� � 0-�� ���������
							SetVehicleVirtualWorld(carpl, garagevwin[playgID1[i]]);//���������� ���������� 0-� ����������� ���
							SetVehiclePos(carpl, garagecordxin[playgID1[i]]+CorX, garagecordyin[playgID1[i]]+CorY, garagecordzin[playgID1[i]]+2.00);
							SetVehicleZAngle(carpl, garageanglein[playgID1[i]]);
							SetPlayerPos(i, garagecordxin[playgID1[i]]+CorX, garagecordyin[playgID1[i]]+CorY, garagecordzin[playgID1[i]]+2.00);
							PutPlayerInVehicle(i, carpl, 0);
							SetTimerEx("playret1", 300, 0, "i", i);
						}
#if (FS22INS == 3)
						if(DelayPlayer[i] == 1) { DelayPlayer[i] = 2; }
#endif
						if(DelayPlayer[i] == 0) { DelayPlayer[i] = 1; }
					}
					else
					{
						DelayPlayer[i] = 0;
					}
				}
			}
		}
	}
	return 1;
}

forward playret1(playerid);
public playret1(playerid)
{
	SetPlayerInterior(playerid, inttp1[playerid]);
	SetPlayerVirtualWorld(playerid, playgID1[playerid]+3000);
	SetPlayerPos(playerid, cordtpx[inttp1[playerid]-1], cordtpy[inttp1[playerid]-1], cordtpz[inttp1[playerid]-1]);
	SendClientMessage(playerid, 0xFF0000FF, " ����� ��������� ������ �������� � ������ !");
	return 1;
}

forward playret2(playerid);
public playret2(playerid)
{
	SetPlayerInterior(playerid, inttp2[playerid]);
	SetPlayerVirtualWorld(playerid, playgID2[playerid]+3000);
	SetPlayerPos(playerid, cordtpx[inttp2[playerid]-1], cordtpy[inttp2[playerid]-1], cordtpz[inttp2[playerid]-1]);
	garagecarid[playgID2[playerid]] = CreateVehicle(garagecarmod[playgID2[playerid]], garagecordx[playgID2[playerid]],garagecordy[playgID2[playerid]],
	garagecordz[playgID2[playerid]], garageangle[playgID2[playerid]], -1, -1, 90000);//������ ��������� � ������
	LinkVehicleToInterior(garagecarid[playgID2[playerid]], garageint[playgID2[playerid]]);//���������� ��������� � ��������� ������
	SetVehicleVirtualWorld(garagecarid[playgID2[playerid]], playgID2[playerid]+3000);//������������� ���������� ����������� ��� ������
	for(new i; i < 14; i++)
	{
		AddVehicleComponent(garagecarid[playgID2[playerid]], garageslot[i][playgID2[playerid]]);//��������� �� ��������� ������
	}
	new sendername[MAX_PLAYER_NAME];
	GetPlayerName(playerid, sendername, sizeof(sendername));
	new aa333[64];//��������� ��� ������������� ������� �����
	format(aa333, sizeof(aa333), "%s", sendername);//��������� ��� ������������� ������� �����
	printf("[Garage] ����� %s [%d] �������� ��������� � ���� ������ (ID: %d).", aa333, playerid, playgID2[playerid]);//��������� ��� ������������� ������� �����
//	printf("[Garage] ����� %s [%d] �������� ��������� � ���� ������ (ID: %d).", sendername, playerid, playgID2[playerid]);
	SendClientMessage(playerid, 0x00FF00FF, " �� ��������� ��������� � ���� ������.");
	return 1;
}

forward garagefunction(carplay);
public garagefunction(carplay)
{
	new para1 = 0;
	for(new i; i < GARAGE_MAX; i++)
	{
		if(garagecount[i] == 1 && garagecarmod[i] != 0)//���� ����� ����������, � � ������ ���� ���������� ���������, ��:
		{
			if(garagecarid[i] == carplay)//���� �� ���������� ���������� ���� � �������, ��:
			{
				para1 = 1;//���������� 1 (�����, ���������� 0)
			}
		}
	}
    return para1;
}

forward reloadgarage1(playerid);
public reloadgarage1(playerid)
{
	UnloadGarageSystem();//�������� ������� �������
	SetTimerEx("reloadgarage2", 1000, 0, "i", playerid);
    return 1;
}

forward reloadgarage2(playerid);
public reloadgarage2(playerid)
{
	LoadGarageSystem();//�������� ������� �������
	SetTimerEx("reloadgarage3", 1000, 0, "i", playerid);
    return 1;
}

forward reloadgarage3(playerid);
public reloadgarage3(playerid)
{
	new string[256];
	new sendername[MAX_PLAYER_NAME];
	GetPlayerName(playerid, sendername, sizeof(sendername));
	new aa333[64];//��������� ��� ������������� ������� �����
	format(aa333, sizeof(aa333), "%s", sendername);//��������� ��� ������������� ������� �����
	printf("[Garage] ����� %s [%d] ������������ ������� �������.", aa333, playerid);//��������� ��� ������������� ������� �����
//	printf("[Garage] ����� %s [%d] ������������ ������� �������.", sendername, playerid);
	format(string, sizeof(string), " ����� %s [%d] ������������ ������� �������.", sendername, playerid);
	SendClientMessageToAll(0xFF0000FF, string);
    return 1;
}

public LoadGarageSystem()//�������� ������� �������
{
	new string[512];
	new count = 0;
    new file, f[256];//������ ���� �������
	for(new i; i < GARAGE_MAX; i++)
	{
//��� ������ ��������� ��� ������������� � ������ ������� ������� !!!
//--------------------------------- ������ -------------------------------------
		garagevwin[i] = 0;
		garageintin[i] = 0;
//---------------------------------- ����� -------------------------------------
	    format(f, 256, "garages/%i.ini", i);
		file = ini_openFile(f);
		if(file >= 0)
		{
			count++;
			garagecount[i] = 1;//����� ������ (���������)
		    ini_getString(file, "PlayName", garageplayname[i]);
		    ini_getInteger(file, "Cost1", garagecost1[i]);
		    ini_getInteger(file, "Cost2", garagecost2[i]);
		    ini_getInteger(file, "Lock", garagelock[i]);
		    ini_getInteger(file, "GarVWin", garagevwin[i]);
		    ini_getInteger(file, "GarIntin", garageintin[i]);
		    ini_getFloat(file, "CordXin", garagecordxin[i]);
		    ini_getFloat(file, "CordYin", garagecordyin[i]);
		    ini_getFloat(file, "CordZin", garagecordzin[i]);
		    ini_getFloat(file, "Anglein", garageanglein[i]);
		    ini_getFloat(file, "CordX", garagecordx[i]);
		    ini_getFloat(file, "CordY", garagecordy[i]);
		    ini_getFloat(file, "CordZ", garagecordz[i]);
		    ini_getFloat(file, "Angle", garageangle[i]);
		    ini_getInteger(file, "Interior", garageint[i]);
		    ini_getInteger(file, "CarMod", garagecarmod[i]);
		    ini_getInteger(file, "Slot00", garageslot[0][i]);
		    ini_getInteger(file, "Slot01", garageslot[1][i]);
		    ini_getInteger(file, "Slot02", garageslot[2][i]);
		    ini_getInteger(file, "Slot03", garageslot[3][i]);
		    ini_getInteger(file, "Slot04", garageslot[4][i]);
		    ini_getInteger(file, "Slot05", garageslot[5][i]);
		    ini_getInteger(file, "Slot06", garageslot[6][i]);
		    ini_getInteger(file, "Slot07", garageslot[7][i]);
		    ini_getInteger(file, "Slot08", garageslot[8][i]);
		    ini_getInteger(file, "Slot09", garageslot[9][i]);
		    ini_getInteger(file, "Slot10", garageslot[10][i]);
		    ini_getInteger(file, "Slot11", garageslot[11][i]);
		    ini_getInteger(file, "Slot12", garageslot[12][i]);
		    ini_getInteger(file, "Slot13", garageslot[13][i]);
			ini_closeFile(file);

			CallRemoteFunction("GPSrfun", "iiisifff", 3, 1, i, garageplayname[i],
			garagevwin[i], garagecordxin[i], garagecordyin[i], garagecordzin[i]);
			PickupID[i] = CreateDynamicPickup(1318, 1, garagecordxin[i], garagecordyin[i], garagecordzin[i],
			garagevwin[i], garageintin[i], -1, 25.0);//������ ����� ������
			MapIconID[i] = CreateDynamicMapIcon(garagecordxin[i], garagecordyin[i], garagecordzin[i], 55, -1,
			garagevwin[i], garageintin[i], -1, 200.0);//������ ���-������ ������
			if(strcmp(garageplayname[i], "*** INV_PL_ID", false) != 0)//���� ���� ����� - ����� ������, ��:
			{
				if(garagelock[i] == 1)//���� ����� ������, ��:
				{
					format(string, sizeof(string), "�����: %s\n������\n/glock - �������(�������) �����\n/genter - ����� � �����\nID: %d", garageplayname[i], i);
				}
				else//�����:
				{
					format(string, sizeof(string), "�����: %s\n������\n/genter - ����� � �����\nID: %d", garageplayname[i], i);
				}
			}
			else//���� ����� �������� (� ������ ��� �������), ��:
			{
				format(string, sizeof(string), "�����: ��������\n���������: %d\n/gbuy - ������ �����\nID: %d", garagecost2[i], i);
			}
			Ngarage[i] = CreateDynamic3DTextLabel(string, 0xADFF2FFF, garagecordxin[i], garagecordyin[i], garagecordzin[i]+0.70, 25,
			INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, garagevwin[i], garageintin[i], -1);//������ 3D-����� ������
			if(garagecarmod[i] != 0)//���� ���� ���������� ���������, ��:
			{
				garagecarid[i] = CreateVehicle(garagecarmod[i], garagecordx[i],garagecordy[i],garagecordz[i], garageangle[i], -1, -1, 90000);//������ ��������� � ������
				LinkVehicleToInterior(garagecarid[i], garageint[i]);//���������� ��������� � ��������� ������
				SetVehicleVirtualWorld(garagecarid[i], i+3000);//������������� ���������� ����������� ��� ������
				for(new j; j < 14; j++)
				{
					AddVehicleComponent(garagecarid[i], garageslot[j][i]);//��������� �� ��������� ������
				}
			}
		}
		else
		{
			garagecount[i] = 0;//����� �� ������ (�� ���������)
			strdel(garageplayname[i], 0, MAX_PLAYER_NAME);//������� ��� ��������� ������
			strcat(garageplayname[i], "*** INV_PL_ID");
			CallRemoteFunction("GPSrfun", "iiisifff", 3, 0, i, garageplayname[i],
			0, 0.0, 0.0, 0.0);
		}
	}
	print(" ");
	printf(" %d ������� ���������.", count);

	print(" ");
	print("--------------------------------------");
	print("      Garage ������� ���������! ");
	print("--------------------------------------\n");
	return 1;
}

public UnloadGarageSystem()//�������� ������� �������
{
	for(new i; i < GARAGE_MAX; i++)
	{
		if(garagecount[i] == 1)//���� ����� ����������, ��:
		{
			DestroyDynamicPickup(PickupID[i]);//������� ����� ������
			DestroyDynamicMapIcon(MapIconID[i]);//������� ���-������ ������
			DestroyDynamic3DTextLabel(Ngarage[i]);//������� 3D-����� ������
			if(garagecarmod[i] != 0)//���� ���� ���������� ���������, ��:
			{
				DestroyVehicle(garagecarid[i]);//������� ��������� �� ������
			}
		}
		CallRemoteFunction("GPSrfun", "iiisifff", 3, 0, i, "*** INV_PL_ID",
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

