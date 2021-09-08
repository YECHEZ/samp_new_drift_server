// ========================================================================== //

// ~~~~~~~~~~~~~~~ ������������ ������� �������� �� REMARION ~~~~~~~~~~~~~~~~ //
// ________________________ ��������� � http://gnr-samp.ru/ _________________ //
// ========================================================================== //

#include <a_samp>

#include <streamer>
#include <MXini>

//==============================================================================
//                            ��������� �������
//==============================================================================

#define FS11INS 0 //������� ����� �� �������:
//                //FS11INS 0 - ����������� �������
//                //FS11INS 1 - ���������� ������� (�� PVar)

#undef MAX_PLAYERS
#define MAX_PLAYERS 101 //�������� ������� �� ������� + 1 (���� 50 �������, �� ����� 51 !!!)

#define BUS_MAX 100 //�������� �������� �� ������� (�� 1 �� 300)
#define BUS_PLAY 2 //�������� ��������, ������� ����� ������ ���� ����� (�� 1 �� 5)
#define BUS_DAY 3 //����� �����, ������� ������ "��������" �� ������� ��� ����� ��������� (�� 1 �� 5)

//   �������� !!! ����� ��������� �������� ����������� ��������������� !!!

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

forward LoadBusSystem();//�������� ������� ��������
forward UnloadBusSystem();//�������� ������� ��������
forward DatCor();//��������� ����
forward TimCor();//��������� �������
forward ReadCorTime();//������ ����� cortime.ini
forward dopfunction(per);//������� �������� ������ ��� ������ ��������� �������
forward OneMin();//1-�������� ������
forward OneSec();//1-��������� ������

new Text3D:fantxt;//���������� ��� �������� 3D-������ � ������������� ��
new dlgcont[MAX_PLAYERS];//�������� �� �������
new timecor[8];//���������� ��������� ������� 2
new CorTime[5];//���������� ��������� ������� 1
new RealName[MAX_PLAYERS][MAX_PLAYER_NAME];//�������� ��� ������
new playspabs[MAX_PLAYERS];//����� ������
new playIDbus[MAX_PLAYERS];//�� ������� ��� ������
new DelayPickup[MAX_PLAYERS];//�������� ������� ������� �������
new buscount[BUS_MAX];//0- ������ �� ������, 1- ������ ������
new busidplay[BUS_MAX];//-600- ���� �������� ������� ���-����, �� ������- ���� �������� ������� ��-����
new busmoney[BUS_MAX];//������� ����� ������� (���� ����� ��-����)
new busname[BUS_MAX][64];//�������� �������
new busplayname[BUS_MAX][MAX_PLAYER_NAME];//��� ��������� �������
new buscost[BUS_MAX];//��������� �������
new busminute[BUS_MAX];//����� ������� ����� ������ ����� ��������� �����
new busincome[BUS_MAX];//����� �� �������
new busday[BUS_MAX];//���� ��������� ����� ��� ����� ���������
new busvw[BUS_MAX];//����������� ��� �������
new busint[BUS_MAX];//�������� �������
new Float:buscordx[BUS_MAX];//���������� �������
new Float:buscordy[BUS_MAX];
new Float:buscordz[BUS_MAX];
new PickupID[BUS_MAX];//������ �� �������
new MapIconID[BUS_MAX];//������ �� ���-������
new Text3D:Nbus[BUS_MAX];//������ �� 3D-�������
new timeronemin;//���������� 1-��������� �������
new timeronesec;//���������� 1-���������� �������
new busdlgcon[MAX_PLAYERS];//���������� �������� ��������

public OnFilterScriptInit()
{
	fantxt = Create3DTextLabel(" ",0xFFFFFFAA,0.000,0.000,-4.000,18.0,0,1);//������ 3D-����� � ������������� ��
	for(new i; i < MAX_PLAYERS; i++)//���� ��� ���� �������
	{
		dlgcont[i] = -600;//�� ������������ �� �������
	}
	LoadBusSystem();//�������� ������� ��������
	timeronemin = SetTimer("OneMin", 59981, 1);//������ 1-��������� �������
	timeronesec = SetTimer("OneSec", 993, 1);//������ 1-���������� �������
	return 1;
}

public OnFilterScriptExit()
{
	Delete3DTextLabel(fantxt);//������� 3D-����� � ������������� ��
	KillTimer(timeronesec);//��������� 1-���������� �������
	KillTimer(timeronemin);//��������� 1-��������� �������
	UnloadBusSystem();//�������� ������� ��������
	return 1;
}

public OnPlayerConnect(playerid)
{
	busdlgcon[playerid] = 0;//�������� �������� ��������
	dlgcont[playerid] = -600;//�� ������������ �� �������
	playspabs[playerid] = 0;//����� �� �����������
	playIDbus[playerid] = -600;//�� ������������ �� ������� ��� ������
	new pname[MAX_PLAYER_NAME];
	GetPlayerName(playerid, pname, sizeof(pname));
	strdel(RealName[playerid], 0, MAX_PLAYER_NAME);//�������� �������� ��� ������
	new aa333[64];//��������� ��� ������������� ������� �����
	format(aa333, sizeof(aa333), "%s", pname);//��������� ��� ������������� ������� �����
	strcat(RealName[playerid], aa333);//��������� �������� ��� ������ (��������� ��� ������������� ������� �����)
//	strcat(RealName[playerid], pname);//��������� �������� ��� ������
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	playspabs[playerid] = 0;//����� �� �����������
	for(new j; j < BUS_MAX; j++)//���� ��� ���� ��������
	{
		if(buscount[j] == 1 && strcmp(RealName[playerid], busplayname[j], false) == 0)//���� ������ ����������,
		{//� ��� ������ ������, ��:
			busidplay[j] = -600;//��� ������� �������������� �� ������
		}
	}
	playIDbus[playerid] = -600;//�� ������������ �� ������� ��� ������
	dlgcont[playerid] = -600;//�� ������������ �� �������
	busdlgcon[playerid] = 0;//�������� �������� ��������
	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(playspabs[playerid] == 0)//���� ����� ��� �� �����������, ��:
	{
		for(new j; j < BUS_MAX; j++)//���� ��� ���� ��������
		{
			if(buscount[j] == 1 && strcmp(RealName[playerid], busplayname[j], false) == 0)//���� ������ ����������,
			{//� ��� ������ ������, ��:
				busidplay[j] = playerid;//��� ������� �� ��-���� ������ - ��������� �������
			}
		}
	}
	playspabs[playerid] = 1;//����� �����������
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
			case 0: format(sstr, sizeof(sstr), " ���� � ���� (��� � ��������) !   ���������� ����� %d ������ !", GetPVarInt(playerid, "CComAc7") * -1);
			case 1: format(sstr, sizeof(sstr), " ���� � ���� (��� � ��������) !   ���������� ����� %d ������� !", GetPVarInt(playerid, "CComAc7") * -1);
			case 2: format(sstr, sizeof(sstr), " ���� � ���� (��� � ��������) !   ���������� ����� %d ������� !", GetPVarInt(playerid, "CComAc7") * -1);
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
			SendClientMessage(playerid, 0x00FFFFFF, " -------------------------- ������� �������� -------------------------- ");
			SendClientMessage(playerid, 0x00FFFFFF, "   /helpbus - ������ �� �������� BusSystem");
			SendClientMessage(playerid, 0x00FFFFFF, "   /createbus - ������� ������");
			SendClientMessage(playerid, 0x00FFFFFF, "   /removebus - ������� ������ �� ��� ID");
			SendClientMessage(playerid, 0x00FFFFFF, "   /removebusall - ������� ��� �������");
			SendClientMessage(playerid, 0x00FFFFFF, "   /gotobus - ����������������� � ������� �� ��� ID");
			SendClientMessage(playerid, 0x00FFFFFF, "   /reloadbus - ������������ ������� ��������");
			SendClientMessage(playerid, 0x00FFFFFF, " --------------------------------------------------------------------------------- ");
		}
		else
		{
			SendClientMessage(playerid, 0xFF0000FF, " � ��� ��� ���� �� ������������� ���� ������� !");
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
				SendClientMessage(playerid, 0x00FFFFFF, " �����������: /createbus [���������(100-1000000 $)] [����� �����, �����");
				SendClientMessage(playerid, 0x00FFFFFF, " ������� ������ ����� ��������� �����(10-120)] [����� �� �������");
				SendClientMessage(playerid, 0x00FFFFFF, " �� ������ ��-���� ����(100-1000000 $)] [�������� �������(�� 3 �� 32 ��������)]");
				return 1;
			}
			new para1 = strval(tmp);
			if(para1 < 100 || para1 > 1000000)
			{
				SendClientMessage(playerid, 0xFF0000FF, " ��������� �� 100 $ �� 1000000 $ !");
				return 1;
			}
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, 0xFF0000FF, " /createbus [���������] [����� �����] [�����] [�������� �������] !");
				return 1;
			}
			new para2 = strval(tmp);
			if(para2 < 10 || para2 > 120)
			{
				SendClientMessage(playerid, 0xFF0000FF, " ����� ����� �� 10 �� 120 !");
				return 1;
			}
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, 0xFF0000FF, " /createbus [���������] [����� �����] [�����] [�������� �������] !");
				return 1;
			}
			new para3 = strval(tmp);
			if(para3 < 100 || para3 > 1000000)
			{
				SendClientMessage(playerid, 0xFF0000FF, " ����� �� 100 $ �� 1000000 $ !");
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
				SendClientMessage(playerid, 0xFF0000FF, " �������� �� 3 �� 32 �������� !");
				return 1;
			}
//------------------------------------------------------------------------------
//���� ������ �����������, ��: ������� ����� ����� ��������� ������ � 0-� ���������, � �� �������� ����� !
/*
			if(GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0)
			{
				SendClientMessage(playerid, 0xFF0000FF, " ������ ����� ������� ������ � 0-� ���������, � �� �������� ����� !");
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
				SendClientMessage(playerid, 0xFF0000FF, " �������� ����� �������� �������� !");
				SendClientMessage(playerid, 0xFF0000FF, " ��� ����������� - ��������� �������� �������� �� ������� !");
				return 1;
			}
			buscount[para4] = 1;//������ ������
			busvw[para4] = GetPlayerVirtualWorld(playerid);//����� ����������� ��� �������
			busint[para4] = GetPlayerInterior(playerid);//����� �������� �������
			GetPlayerPos(playerid, buscordx[para4], buscordy[para4], buscordz[para4]);//����� ���������� �������
			strdel(busname[para4], 0, 64);//����� �������� �������
			strcat(busname[para4], result);
			strdel(busplayname[para4], 0, MAX_PLAYER_NAME);//������� ��� ��������� �������
			strcat(busplayname[para4], "*** INV_PL_ID");
		    buscost[para4] = para1;//����� ��������� �������
		    busminute[para4] = para2;//�����, ����� ������� ����� ������ ����� ��������� �����
		    busincome[para4] = para3;//����� ����� �� �������
		    busday[para4] = 0;//��� ������� ����� �� ��� ��������� (�������)
			busmoney[para4] = busminute[para4];//�������� � ������� ����� ������� - ������ �������

    		new file, f[256];//������ ������� � ����
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
			busvw[para4], busint[para4], -1, 100.0);//������ ����� �������
			MapIconID[para4] = CreateDynamicMapIcon(buscordx[para4], buscordy[para4], buscordz[para4], 52, -1,
			busvw[para4], busint[para4], -1, 200.0);//������ ���-������ �������
			format(string, sizeof(string), "������: %s\nID: %d", busname[para4], para4);
			Nbus[para4] = CreateDynamic3DTextLabel(string, 0x00FF00FF, buscordx[para4], buscordy[para4], buscordz[para4]+0.70, 50,
			INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, busvw[para4], busint[para4], -1);//������ 3D-����� �������
			GetPlayerName(playerid, sendername, sizeof(sendername));
			new aa333[64];//��������� ��� ������������� ������� �����
			format(aa333, sizeof(aa333), "%s", sendername);//��������� ��� ������������� ������� �����
			printf("[BusSystem] ����� %s [%d] ������ ������ ID: %d .", aa333, playerid, para4);//��������� ��� ������������� ������� �����
//			printf("[BusSystem] ����� %s [%d] ������ ������ ID: %d .", sendername, playerid, para4);
			format(string, sizeof(string), " ������ ID: %d ������� ������.", para4);
			SendClientMessage(playerid, 0xFFFF00FF, string);
		}
		else
		{
			SendClientMessage(playerid, 0xFF0000FF, " � ��� ��� ���� �� ������������� ���� ������� !");
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
				SendClientMessage(playerid, 0x00FFFFFF, " �����������: /removebus [ID �������]");
				return 1;
			}
			new para1 = strval(tmp);
			if(para1 < 0 || para1 >= BUS_MAX)
			{
				SendClientMessage(playerid, 0xFF0000FF, " ������� � ����� ID �� ���������� !");
				return 1;
			}
			format(string, sizeof(string), "bussystem/%i.ini", para1);
			if(fexist(string) || buscount[para1] == 1)//���� ���� ��� ��� ������ ����������, ��:
			{
				DestroyDynamicPickup(PickupID[para1]);//������� ����� �������
				if(busday[para1] == 0)//���� ���� ���-������ �������, ��:
				{
					DestroyDynamicMapIcon(MapIconID[para1]);//������� ���-������ �������
				}
				DestroyDynamic3DTextLabel(Nbus[para1]);//������� 3D-����� �������
				if(fexist(string))//���� ���� ����������, ��:
				{
                    fremove(string);//������� ����
				}
				buscount[para1] = 0;//������� ������
				strdel(busplayname[para1], 0, MAX_PLAYER_NAME);//������� ��� ��������� �������
				strcat(busplayname[para1], "*** INV_PL_ID");
				CallRemoteFunction("GPSrfun", "iiisifff", 2, 0, para1, busplayname[para1],
				0, 0.0, 0.0, 0.0);
				PickupID[para1] = -600;//����� �������������� ID-����� ������ ��� �������
				GetPlayerName(playerid, sendername, sizeof(sendername));
				new aa333[64];//��������� ��� ������������� ������� �����
				format(aa333, sizeof(aa333), "%s", sendername);//��������� ��� ������������� ������� �����
				printf("[BusSystem] ����� %s [%d] ������ ������ ID: %d .", aa333, playerid, para1);//��������� ��� ������������� ������� �����
//				printf("[BusSystem] ����� %s [%d] ������ ������ ID: %d .", sendername, playerid, para1);
				format(string, sizeof(string), " ������ ID: %d ������� �����.", para1);
				SendClientMessage(playerid, 0xFF0000FF, string);
			}
			else//���� �� ����, � �� ��� ������ �� ����������, ��:
			{
				SendClientMessage(playerid, 0xFF0000FF, " ������� � ����� ID �� ���������� !");
			}
		}
		else
		{
			SendClientMessage(playerid, 0xFF0000FF, " � ��� ��� ���� �� ������������� ���� ������� !");
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
				if(fexist(string) || buscount[i] == 1)//���� ���� ��� ��� ������ ����������, ��:
				{
					para1 = 1;
					DestroyDynamicPickup(PickupID[i]);//������� ����� �������
					if(busday[i] == 0)//���� ���� ���-������ �������, ��:
					{
						DestroyDynamicMapIcon(MapIconID[i]);//������� ���-������ �������
					}
					DestroyDynamic3DTextLabel(Nbus[i]);//������� 3D-����� �������
					if(fexist(string))//���� ���� ����������, ��:
					{
                    	fremove(string);//������� ����
					}
					buscount[i] = 0;//������� ������
					strdel(busplayname[i], 0, MAX_PLAYER_NAME);//������� ��� ��������� �������
					strcat(busplayname[i], "*** INV_PL_ID");
					PickupID[i] = -600;//����� �������������� ID-����� ������ ��� �������
				}
				CallRemoteFunction("GPSrfun", "iiisifff", 2, 0, i, "*** INV_PL_ID",
				0, 0.0, 0.0, 0.0);
			}
			if(para1 == 1)
			{
				GetPlayerName(playerid, sendername, sizeof(sendername));
				new aa333[64];//��������� ��� ������������� ������� �����
				format(aa333, sizeof(aa333), "%s", sendername);//��������� ��� ������������� ������� �����
				printf("[BusSystem] ����� %s [%d] ������ ��� �������.", aa333, playerid);//��������� ��� ������������� ������� �����
//				printf("[BusSystem] ����� %s [%d] ������ ��� �������.", sendername, playerid);
				SendClientMessage(playerid, 0xFF0000FF, " ��� ������� ���� ������� �������.");
			}
			else
			{
				SendClientMessage(playerid, 0xFF0000FF, " �� ������� �� ������� �� ������ ������� !");
			}
		}
		else
		{
			SendClientMessage(playerid, 0xFF0000FF, " � ��� ��� ���� �� ������������� ���� ������� !");
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
				SendClientMessage(playerid, 0xFF0000FF, " � ������ ������� �� �������� !");
				return 1;
			}
#endif
			tmp = strtok(cmdtext, idx);
			if(!strlen(tmp))
			{
				SendClientMessage(playerid, 0x00FFFFFF, " �����������: /gotobus [ID �������]");
				return 1;
			}
			new para1 = strval(tmp);
			if(para1 < 0 || para1 >= BUS_MAX)
			{
				SendClientMessage(playerid, 0xFF0000FF, " ������� � ����� ID �� ���������� !");
				return 1;
			}
			if(buscount[para1] == 1)//���� ������ ����������, ��:
			{
				SetPlayerVirtualWorld(playerid, busvw[para1]);
 				SetPlayerInterior(playerid, busint[para1]);
				SetPlayerPos(playerid, buscordx[para1], buscordy[para1]+2, buscordz[para1]+1);
				GetPlayerName(playerid, sendername, sizeof(sendername));
				new aa333[64];//��������� ��� ������������� ������� �����
				format(aa333, sizeof(aa333), "%s", sendername);//��������� ��� ������������� ������� �����
				printf("[BusSystem] ����� %s [%d] ���������������� � ������� ID: %d .", aa333, playerid, para1);//��������� ��� ������������� ������� �����
//				printf("[BusSystem] ����� %s [%d] ���������������� � ������� ID: %d .", sendername, playerid, para1);
				format(string, sizeof(string), " �� ����������������� � ������� ID: %d .", para1);
				SendClientMessage(playerid, 0x00FF00FF, string);
			}
			else//���� ������ �� ����������, ��:
			{
				SendClientMessage(playerid, 0xFF0000FF, " ������� � ����� ID �� ���������� !");
			}
		}
		else
		{
			SendClientMessage(playerid, 0xFF0000FF, " � ��� ��� ���� �� ������������� ���� ������� !");
		}
		return 1;
	}
	if(strcmp(cmd, "/reloadbus", true) == 0)
	{
		if(IsPlayerAdmin(playerid))
		{
			GetPlayerName(playerid, sendername, sizeof(sendername));
			new aa333[64];//��������� ��� ������������� ������� �����
			format(aa333, sizeof(aa333), "%s", sendername);//��������� ��� ������������� ������� �����
			printf("[BusSystem] ����� %s [%d] ����� ������������ ������� ��������.", aa333, playerid);//��������� ��� ������������� ������� �����
//			printf("[BusSystem] ����� %s [%d] ����� ������������ ������� ��������.", sendername, playerid);
			format(string, sizeof(string), " ����� %s [%d] ����� ������������ ������� ��������.", sendername, playerid);
			SendClientMessageToAll(0xFF0000FF, string);
			SetTimerEx("reloadbus1", 1000, 0, "i", playerid);
		}
		else
		{
			SendClientMessage(playerid, 0xFF0000FF, " � ��� ��� ���� �� ������������� ���� ������� !");
		}
		return 1;
	}
	return 0;
}

forward reloadbus1(playerid);
public reloadbus1(playerid)
{
	UnloadBusSystem();//�������� ������� ��������
	SetTimerEx("reloadbus2", 1000, 0, "i", playerid);
    return 1;
}

forward reloadbus2(playerid);
public reloadbus2(playerid)
{
	LoadBusSystem();//�������� ������� ��������
	SetTimerEx("reloadbus3", 1000, 0, "i", playerid);
    return 1;
}

forward reloadbus3(playerid);
public reloadbus3(playerid)
{
	new string[256];
	new sendername[MAX_PLAYER_NAME];
	GetPlayerName(playerid, sendername, sizeof(sendername));
	new aa333[64];//��������� ��� ������������� ������� �����
	format(aa333, sizeof(aa333), "%s", sendername);//��������� ��� ������������� ������� �����
	printf("[BusSystem] ����� %s [%d] ������������ ������� ��������.", aa333, playerid);//��������� ��� ������������� ������� �����
//	printf("[BusSystem] ����� %s [%d] ������������ ������� ��������.", sendername, playerid);
	format(string, sizeof(string), " ����� %s [%d] ������������ ������� ��������.", sendername, playerid);
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
			playIDbus[playerid] = para1;//���������� �� ������� ��� ������
			if(busday[para1] == 0 && strcmp(RealName[playerid], busplayname[para1], false) != 0)
			{//���� � ������� ���� ����� �� ��� ���������, � ���� ������ �� ������, ��:
				format(string, sizeof(string), "{ADFF2F}�������� �������: %s\n��������� �������: %d $\n\n���� ������ ����� ��� ��������� �����: %d $\
				\n������ %d ����� ������ ��-���� ����������� �������.\n\n�������� ! ����� %d �����, �� ��� ������� ����� �������,\
				\n���� ������ ������ ���������� ����� ������ ����� !", busname[para1], buscost[para1], busincome[para1],
				busminute[para1], BUS_DAY);
				ShowPlayerDialog(playerid, 8001, 0, "����������.", string, "������", "������");
				dlgcont[playerid] = 8001;
			}
			if(busday[para1] != 0 && strcmp(RealName[playerid], busplayname[para1], false) != 0)
			{//���� � ������� ��� ����� �� ��� ���������, � ���� ������ �� ������, ��:
				format(string, sizeof(string), "{ADFF2F}�������� �������: %s\n�������� �������: %s\n��������� �������: %d $", busname[para1],
				busplayname[para1], buscost[para1]);
				ShowPlayerDialog(playerid, 8000, 0, "����������.", string, "OK", "");
				dlgcont[playerid] = 8000;
			}
			if(strcmp(RealName[playerid], busplayname[para1], false) == 0)
			{//���� ���� ������ - ������ ������, ��:
				format(string, sizeof(string), "{ADFF2F}�������� �������: %s\n��������� �������: %d $\n\n���� ������ ��� �������� �����: %d $\
				\n������ %d ����� ������ ��-���� ����������� �������.\n\n�� ������ ������� ���� ������ ?", busname[para1], buscost[para1],
				busincome[para1], busminute[para1]);
				ShowPlayerDialog(playerid, 8002, 0, "����������.", string, "�������", "������");
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
			dlgcont[playerid] = -600;//�� ������������ �� �������
			return 1;
		}
		dlgcont[playerid] = -600;//�� ������������ �� �������
		busdlgcon[playerid]++;//�������� �������� +1
		playIDbus[playerid] = -600;//�� ������������ �� ������� ��� ������
		return 1;
	}
	if(dialogid == 8001)
    {
		if(dialogid != dlgcont[playerid])
		{
			dlgcont[playerid] = -600;//�� ������������ �� �������
			return 1;
		}
		dlgcont[playerid] = -600;//�� ������������ �� �������
		busdlgcon[playerid]++;//�������� �������� +1
        if(response)
		{
			new string[256];
#if (FS11INS == 0)
			if(GetPlayerMoney(playerid) < buscost[playIDbus[playerid]])//���� � ������ ������������ �����, ��:
			{
				busdlgcon[playerid]--;//�������� �������� -1
				ShowPlayerDialog(playerid, 8000, 0, "����������.", "{ADFF2F}� ��� ������������ ����� ��� ������� ����� ������� !", "OK", "");
				dlgcont[playerid] = 8000;
				return 1;
			}
#endif
#if (FS11INS == 1)
			if(GetPVarInt(playerid, "PlMon") < buscost[playIDbus[playerid]])//���� � ������ ������������ �����, ��:
			{
				busdlgcon[playerid]--;//�������� �������� -1
				ShowPlayerDialog(playerid, 8000, 0, "����������.", "{ADFF2F}� ��� ������������ ����� ��� ������� ����� ������� !", "OK", "");
				dlgcont[playerid] = 8000;
				return 1;
			}
#endif
			new para1 = 0;
			for(new i; i < BUS_MAX; i++)//������� ����� ��� ��������� ��������
			{
				if(buscount[i] == 1 && strcmp(RealName[playerid], busplayname[i], false) == 0) { para1++; }
			}
			if(para1 >= BUS_PLAY)
			{
				format(string, sizeof(string), "{ADFF2F}� ��� ��� ���� %d ������� !   ��� �� ������ ���� ������ -\
				\n�������� ���� �� ���� �� ����� ������������ �������� !", para1);
				busdlgcon[playerid]--;//�������� �������� -1
				ShowPlayerDialog(playerid, 8000, 0, "����������.", string, "OK", "");
				dlgcont[playerid] = 8000;
				return 1;
			}
			if(strcmp(busplayname[playIDbus[playerid]], "*** INV_PL_ID", false) != 0 && busday[playIDbus[playerid]] != 0)
			{//���� � ������ �������, ���������� ������ ����� ������ ������ �����, ��:
				SendClientMessage(playerid, 0xFF0000FF, " ���� ������ ��� ����������� ������� ������ !");
				format(string, sizeof(string), "{ADFF2F}�������� �������: %s\n�������� �������: %s\n��������� �������: %d $", busname[playIDbus[playerid]],
				busplayname[playIDbus[playerid]], buscost[playIDbus[playerid]]);
				busdlgcon[playerid]--;//�������� �������� -1
				ShowPlayerDialog(playerid, 8000, 0, "����������.", string, "OK", "");
				dlgcont[playerid] = 8000;
				return 1;
			}
			strdel(busplayname[playIDbus[playerid]], 0, MAX_PLAYER_NAME);//��������� ����� ��������� �������
			strcat(busplayname[playIDbus[playerid]], RealName[playerid]);
			busday[playIDbus[playerid]] = 99;//��������� ���������� ����������� ��������� �������
			new para2;
#if (FS11INS == 0)
			para2 = GetPlayerMoney(playerid);
			SetPVarInt(playerid, "MonControl", 1);
			GivePlayerMoney(playerid, - buscost[playIDbus[playerid]]);//���������� ����� �� ����� ������
#endif
#if (FS11INS == 1)
			para2 = GetPVarInt(playerid, "PlMon");
			SetPVarInt(playerid, "PlMon", GetPVarInt(playerid, "PlMon") - buscost[playIDbus[playerid]]);//���������� ����� �� ����� ������
#endif
			gettime(timecor[0], timecor[1]);
			getdate(timecor[2], timecor[3], timecor[4]);
			TimCor();//��������� �������
			DatCor();//��������� ����
			new per22;//���������� ���� ��������� ����� ��� ����� ���������
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
			busidplay[playIDbus[playerid]] = playerid;//��� ������� �� ��-���� ������ - ��������� �������
			busmoney[playIDbus[playerid]] = busminute[playIDbus[playerid]];//�������� � ������� ����� ������� - ������ �������
			busday[playIDbus[playerid]] = per22;//��������� ���� ��������� ����� ��� ����� ���������
			new file, f[256];//���������� ��������� � ����
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
			DestroyDynamicMapIcon(MapIconID[playIDbus[playerid]]);//������� ���-������ �������
			printf("[BusSystem] ����� %s [%d] ����� ������ %s [ID: %d] .", RealName[playerid], playerid, busname[playIDbus[playerid]], playIDbus[playerid]);
			format(string, sizeof(string), " ����� %s [%d] ����� ������ %s .", RealName[playerid], playerid, busname[playIDbus[playerid]]);
			SendClientMessageToAll(0x00FFFFFF, string);
			printf("[moneysys] ���������� ����� ������ %s [%d] : %d $", RealName[playerid], playerid, para2);
		}
		playIDbus[playerid] = -600;//�� ������������ �� ������� ��� ������
		return 1;
	}
	if(dialogid == 8002)
    {
		if(dialogid != dlgcont[playerid])
		{
			dlgcont[playerid] = -600;//�� ������������ �� �������
			return 1;
		}
		dlgcont[playerid] = -600;//�� ������������ �� �������
		busdlgcon[playerid]++;//�������� �������� +1
        if(response)
		{
			new string[256];
			new para1;
#if (FS11INS == 0)
			para1 = GetPlayerMoney(playerid);
			SetPVarInt(playerid, "MonControl", 1);
			GivePlayerMoney(playerid, buscost[playIDbus[playerid]]);//������� ����� ������
#endif
#if (FS11INS == 1)
			para1 = GetPVarInt(playerid, "PlMon");
			SetPVarInt(playerid, "PlMon", GetPVarInt(playerid, "PlMon") + buscost[playIDbus[playerid]]);//������� ����� ������
#endif
			busidplay[playIDbus[playerid]] = -600;//��� ������� �������������� �� ������
			busmoney[playIDbus[playerid]] = busminute[playIDbus[playerid]];//�������� � ������� ����� ������� - ������ �������
			strdel(busplayname[playIDbus[playerid]], 0, MAX_PLAYER_NAME);//��������� ����� ��������� �������
			strcat(busplayname[playIDbus[playerid]], "*** INV_PL_ID");
			if(busday[playIDbus[playerid]] != 0)//���� ������ ��� ����� ��� ���������, ��:
			{
				MapIconID[playIDbus[playerid]] = CreateDynamicMapIcon(buscordx[playIDbus[playerid]], buscordy[playIDbus[playerid]],
				buscordz[playIDbus[playerid]], 52, -1, busvw[playIDbus[playerid]], busint[playIDbus[playerid]], -1, 200.0);//������ ���-������ �������
			}
			busday[playIDbus[playerid]] = 0;//��������� ���� ��������� ����� ��� ����� ���������
			new file, f[256];//���������� ��������� � ����
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
			printf("[BusSystem] ����� %s [%d] ������ ������ %s [ID: %d] .", RealName[playerid], playerid, busname[playIDbus[playerid]], playIDbus[playerid]);
			format(string, sizeof(string), " ����� %s [%d] ������ ������ %s .", RealName[playerid], playerid, busname[playIDbus[playerid]]);
			SendClientMessageToAll(0x00FFFFFF, string);
			printf("[moneysys] ���������� ����� ������ %s [%d] : %d $", RealName[playerid], playerid, para1);
		}
		playIDbus[playerid] = -600;//�� ������������ �� ������� ��� ������
		return 1;
	}
	return 0;
}

public DatCor()
{
	new Float:flyear;
	timecor[3] = timecor[3] + CorTime[3];//��������� ������
	timecor[5] = 0;//������� �� ���
	if(timecor[3] < 1)
	{
		timecor[3] = 12 + timecor[3];
		timecor[5] = -1;//������� �� ���
	}
	if(timecor[3] > 12)
	{
		timecor[3] = timecor[3] - 12;
		timecor[5] = 1;//������� �� ���
	}
	timecor[2] = timecor[2] + CorTime[4] + timecor[5];//��������� ����
	flyear = float(timecor[2]);
	flyear = floatdiv(flyear, 4);
	flyear = floatfract(flyear);
	if(flyear != 0){timecor[7] = 0;}//�� ���������� ���
	if(flyear == 0){timecor[7] = 1;}//���������� ���
	timecor[4] = timecor[4] + CorTime[2] + timecor[6];//��������� �����
	timecor[5] = 0;//������� �� �����
	if(timecor[4] < 1 && timecor[3] == 3 && timecor[7] == 0)
	{
		timecor[4] = 28 + timecor[4];
		timecor[5] = -1;//������� �� �����
	}
	if(timecor[4] < 1 && timecor[3] == 3 && timecor[7] == 1)
	{
		timecor[4] = 29 + timecor[4];
		timecor[5] = -1;//������� �� �����
	}
	if(timecor[4] < 1 && (timecor[3] == 5 || timecor[3] == 7 || timecor[3] == 10 || timecor[3] == 12))
	{
		timecor[4] = 30 + timecor[4];
		timecor[5] = -1;//������� �� �����
	}
	if(timecor[4] < 1 && (timecor[3] == 2 || timecor[3] == 4 || timecor[3] == 6 || timecor[3] == 8 || timecor[3] == 9 || timecor[3] == 11 || timecor[3] == 1))
	{
		timecor[4] = 31 + timecor[4];
		timecor[5] = -1;//������� �� �����
	}
	if(timecor[4] > 28 && timecor[3] == 2 && timecor[7] == 0)
	{
		timecor[4] = timecor[4] - 28;
		timecor[5] = 1;//������� �� �����
	}
	if(timecor[4] > 29 && timecor[3] == 2 && timecor[7] == 1)
	{
		timecor[4] = timecor[4] - 29;
		timecor[5] = 1;//������� �� �����
	}
	if(timecor[4] > 30 && (timecor[3] == 4 || timecor[3] == 6 || timecor[3] == 9 || timecor[3] == 11))
	{
		timecor[4] = timecor[4] - 30;
		timecor[5] = 1;//������� �� �����
	}
	if(timecor[4] > 31 && (timecor[3] == 1 || timecor[3] == 3 || timecor[3] == 5 || timecor[3] == 7 || timecor[3] == 8 || timecor[3] == 10 || timecor[3] == 12))
	{
		timecor[4] = timecor[4] - 31;
		timecor[5] = 1;//������� �� �����
	}
	timecor[3] = timecor[3] + timecor[5];//��������� ������
	timecor[5] = 0;//������� �� ���
	if(timecor[3] < 1)
	{
		timecor[3] = 12 + timecor[3];
		timecor[5] = -1;//������� �� ���
	}
	if(timecor[3] > 12)
	{
		timecor[3] = timecor[3] - 12;
		timecor[5] = 1;//������� �� ���
	}
	timecor[2] = timecor[2] + timecor[5];//��������� ����
	return 1;
}

public TimCor()
{
	timecor[1] = timecor[1] + CorTime[1];//��������� �����
	timecor[5] = 0;//������� �� ���
	if(timecor[1] < 0)
	{
		timecor[1] = 60 + timecor[1];
		timecor[5] = -1;//������� �� ���
	}
	if(timecor[1] > 59)
	{
		timecor[1] = timecor[1] - 60;
		timecor[5] = 1;//������� �� ���
	}
	timecor[0] = timecor[0] + CorTime[0] + timecor[5];//��������� �����
	timecor[6] = 0;//������� �� ����
	if(timecor[0] < 0)
	{
		timecor[0] = 24 + timecor[0];
		timecor[6] = -1;//������� �� ����
	}
	if(timecor[0] > 23)
	{
		timecor[0] = timecor[0] - 24;
		timecor[6] = 1;//������� �� ����
	}
	return 1;
}

public ReadCorTime()
{
	new string[256];
	format(string,sizeof(string),"data/cortime.ini");
	if(fexist(string))//���� ���� ����������, ��:
	{
		new File: UserFile = fopen(string, io_read);//������ �����
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
	SetTimer("ReadCorTime",500,0);//�������� ������ (�� ����� ������ ����� cortime.ini)
	return 1;
}

public OneMin()//1-�������� ������
{
	new para1, file, f[256];
	for(new i; i < BUS_MAX; i++)//���� ��� ���� ��������
	{
		if(buscount[i] == 1 && busidplay[i] != -600)//���� ������ ����������,
		{//� ��� �������� ��-����, ��:
			if(IsPlayerConnected(busidplay[i]) && playspabs[busidplay[i]] == 1 &&
			strcmp(RealName[busidplay[i]], busplayname[i], false) == 0)//�������������� �������� �� ������� ������,
			{//����� ������, � ��� ��� (� ������ ������������� ���������� �� �������, ��� ���� ����� �� �����������)
				busmoney[i]--;//������� ����� ������� -1
				if(busmoney[i] > 0)//���� ������� ����� ������� ������ ����, ��:
				{
					format(f, 256, "bussystem/%i.ini", i);//���������� ��������� � ����
					file = ini_openFile(f);
					if(file >= 0)
					{
				    	ini_setInteger(file, "Count", busmoney[i]);
						ini_closeFile(file);
					}
				}
				if(busmoney[i] <= 0)//���� ������� ����� ������� ������ ��� ����� ����, ��:
				{
					busmoney[i] = busminute[i];//�������� � ������� ����� ������� - ������ �������
					format(f, 256, "bussystem/%i.ini", i);//���������� ��������� � ����
					file = ini_openFile(f);
					if(file >= 0)
					{
				    	ini_setInteger(file, "Count", busmoney[i]);
						ini_closeFile(file);
					}
#if (FS11INS == 0)
					para1 = GetPlayerMoney(busidplay[i]);
					SetPVarInt(busidplay[i], "MonControl", 1);
					GivePlayerMoney(busidplay[i], busincome[i]);//����������� ������ � ����� ������
#endif
#if (FS11INS == 1)
					para1 = GetPVarInt(busidplay[i], "PlMon");
					SetPVarInt(busidplay[i], "PlMon", GetPVarInt(busidplay[i], "PlMon") + busincome[i]);//����������� ������ � ����� ������
#endif
					new string[256];
					printf("[BusSystem] ����� %s [%d] ������� ����� %d $ �� ������ ������� %s [ID: %d] .", RealName[busidplay[i]], busidplay[i], busincome[i], busname[i], i);
					format(string, sizeof(string), " ����� %s [%d] ������� ����� %d $ �� ������ ������� %s .", RealName[busidplay[i]], busidplay[i], busincome[i], busname[i]);
					SendClientMessageToAll(0x00FFFFFF, string);
					printf("[moneysys] ���������� ����� ������ %s [%d] : %d $", RealName[busidplay[i]], busidplay[i], para1);
				}
			}
		}
	}
	return 1;
}

public OneSec()//1-��������� ������
{
	new string[256];
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			if(busdlgcon[i] > 1)//���� �������� �������� ������ 1, ��:
			{
				format(string, sizeof(string), "[BusSystem] ����� %s [%d] ��� ������ �� ���, �������� ������ ������� !", RealName[i], i);
				print(string);
				SendClientMessageToAll(0xFF0000FF, string);
				SetTimerEx("PlayKick", 300, 0, "i", i);
			}
			busdlgcon[i] = 0;//�������� �������� ��������
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

public LoadBusSystem()//�������� ������� ��������
{
	CorTime[0] = 0;//��������� ��������� �������
	CorTime[1] = 0;
	CorTime[2] = 0;
	CorTime[3] = 0;
	CorTime[4] = 0;

	new count = 0;
    new file, f[256];//������ ���� ��������
	for(new i; i < BUS_MAX; i++)
	{
		PickupID[i] = -600;//����� �������������� ID-����� ������ ��� �������
	    format(f, 256, "bussystem/%i.ini", i);
		file = ini_openFile(f);
		if(file >= 0)
		{
			count++;
			buscount[i] = 1;//������ ������ (���������)
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
			buscount[i] = 0;//������ �� ������ (�� ���������)
			strdel(busplayname[i], 0, MAX_PLAYER_NAME);//������� ��� ��������� �������
			strcat(busplayname[i], "*** INV_PL_ID");
			busday[i] = 0;//��� ������� ����� �� ��� ��������� (�������)
			CallRemoteFunction("GPSrfun", "iiisifff", 2, 0, i, busplayname[i],
			0, 0.0, 0.0, 0.0);
		}
	}
	print(" ");
	printf(" %d �������� ���������.", count);

	ReadCorTime();//������ ��������� �������
	gettime(timecor[0], timecor[1]);
	getdate(timecor[2], timecor[3], timecor[4]);
	TimCor();//��������� �������
	DatCor();//��������� ����
	new string[256];
	for(new i; i < BUS_MAX; i++)
	{
		busidplay[i] = -600;//�������� ������� ���-����
		if(busday[i] == timecor[4])//���� �������� ���� ����� ���� ��������� ����� ��� ����� ���������, ��:
		{
			busday[i] = 0;//��� ������� ����� �� ��� ���������,
			format(f, 256, "bussystem/%i.ini", i);//� ���������� ��������� � ����
			file = ini_openFile(f);
			if(file >= 0)
			{
				ini_setInteger(file, "Day", busday[i]);
				ini_closeFile(file);
			}
		}
		if(buscount[i] == 1)//���� ������ ������, ��:
		{
			PickupID[i] = CreateDynamicPickup(1274, 1, buscordx[i], buscordy[i], buscordz[i], busvw[i], busint[i], -1, 100.0);//������ ����� �������
			if(busday[i] == 0)//���� � ������� ���� ����� �� ��� ���������, ��:
			{
				MapIconID[i] = CreateDynamicMapIcon(buscordx[i], buscordy[i], buscordz[i], 52, -1, busvw[i], busint[i], -1, 200.0);//������ ���-������ �������
			}
			format(string, sizeof(string), "������: %s\nID: %d", busname[i], i);
			Nbus[i] = CreateDynamic3DTextLabel(string, 0x00FF00FF, buscordx[i], buscordy[i], buscordz[i]+0.70, 50,
			INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, busvw[i], busint[i], -1);//������ 3D-����� �������
		}
	}

	new pname[MAX_PLAYER_NAME];//��������� �������� ���� ���� �������
	new aa333[64];//��������� ��� ������������� ������� �����
	for(new i; i < MAX_PLAYERS; i++)
	{
		playspabs[i] = 0;//����� �� �����������
		playIDbus[i] = -600;//�� ������������ �� ������� ��� ������
		if(IsPlayerConnected(i))//���� ����� � ��������, ��:
		{
			GetPlayerName(i, pname, sizeof(pname));
			strdel(RealName[i], 0, MAX_PLAYER_NAME);//�������� �������� ��� ������
			format(aa333, sizeof(aa333), "%s", pname);//��������� ��� ������������� ������� �����
			strcat(RealName[i], aa333);//��������� �������� ��� ������ (��������� ��� ������������� ������� �����)
//			strcat(RealName[i], pname);//��������� �������� ��� ������
			if(GetPlayerState(i) != 0)//���� ����� ��� �����������, ��:
			{
				playspabs[i] = 1;//����� �����������
				for(new j; j < BUS_MAX; j++)//���� ��� ���� ��������
				{
					if(buscount[j] == 1 && strcmp(RealName[i], busplayname[j], false) == 0)//���� ������ ����������,
					{//� ��� ������ ������, ��:
						busidplay[j] = i;//��� ������� �� ��-���� ������ - ��������� �������
					}
				}
			}
		}
	}
	print(" ");
	print("--------------------------------------");
	print("     BusSystem ������� ���������! ");
	print("--------------------------------------\n");
	return 1;
}

public UnloadBusSystem()//�������� ������� ��������
{
	for(new i; i < BUS_MAX; i++)
	{
		if(buscount[i] == 1)//���� ������ ����������, ��:
		{
			DestroyDynamicPickup(PickupID[i]);//������� ����� �������
			if(busday[i] == 0)//���� ���� ���-������ �������, ��:
			{
				DestroyDynamicMapIcon(MapIconID[i]);//������� ���-������ �������
			}
			DestroyDynamic3DTextLabel(Nbus[i]);//������� 3D-����� �������
		}
		buscount[i] = 0;//������ �� ������ (�� ���������)
		strdel(busplayname[i], 0, MAX_PLAYER_NAME);//������� ��� ��������� �������
		strcat(busplayname[i], "*** INV_PL_ID");
		busidplay[i] = -600;//�������� ������� ���-����
		PickupID[i] = -600;//����� �������������� ID-����� ������ ��� �������
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

