//==============================================================================
//                            Основные настройки
//==============================================================================

#define MOD77INS 1 //настройка использования транспорта:
//                 //MOD77INS 0 - БЕЗ использования транспорта.
//                 //MOD77INS 1 - С использованием транспорта.

#define MOD88INS 1 //настройка использования 3D-текстов:
//                 //MOD77INS 0 - БЕЗ использования 3D-текстов.
//                 //MOD77INS 1 - С использованием 3D-текстов.

//   ВНИМАНИЕ !!! после изменения настроек ОБЯЗАТЕЛЬНО откомпилировать !!!
//==============================================================================
#if (MOD77INS < 0)
	#undef MOD77INS
	#define MOD77INS 0
#endif
#if (MOD77INS > 1)
	#undef MOD77INS
	#define MOD77INS 1
#endif
#if (MOD88INS < 0)
	#undef MOD88INS
	#define MOD88INS 0
#endif
#if (MOD88INS > 1)
	#undef MOD88INS
	#define MOD88INS 1
#endif

#include <a_samp>
#include <streamer>

#if (MOD77INS == 1)
	#define MAXVEH 3 //число единиц транспорта (ОБЯЗАТЕЛЬНО - ТОЧНОЕ КОЛИЧЕСТВО !!!)
	new objveh[MAXVEH];//массив ИД транспорта
#endif
#if (MOD88INS == 1)
	#define MAX3DT 3 //число 3D-текстов (ОБЯЗАТЕЛЬНО - ТОЧНОЕ КОЛИЧЕСТВО !!!)
	new Text3D:obj3dt[MAX3DT];//массив ИД 3D-текстов
#endif

forward myobjtime();

new Text3D:fantxt;//переменная для хранения 3D-текста с несущесвующим ИД

public OnFilterScriptInit()
{
	fantxt = Create3DTextLabel(" ",0xFFFFFFAA,0.000,0.000,-4.000,18.0,0,1);//создаём 3D-текст с несущесвующим ИД
	SetTimer("myobjtime", 1500, 0);
	return 1;
}

public OnFilterScriptExit()
{
	Delete3DTextLabel(fantxt);//удаляем 3D-текст с несущесвующим ИД
#if (MOD77INS == 1)
	for(new i = 0; i < MAXVEH; i++)
	{
		DestroyVehicle(objveh[i]);
	}
#endif
#if (MOD88INS == 1)
	for(new i = 0; i < MAX3DT; i++)
	{
		DestroyDynamic3DTextLabel(obj3dt[i]);
	}
#endif
	return 1;
}

public myobjtime()
{
//	сюда ставим объекты

//	стандартные объекты созданые мап-конструктором (их нужно переделать в динамические объекты !!!)
//	CreateObject(988, 2508.16699, -1677.91479, 13.56860,   0.00000, 0.00000, -120.00000);
//	CreateObject(988, 2510.76660, -1670.00928, 13.45860,   0.00000, 0.00000, -91.00000);
//	CreateObject(988, 2509.57983, -1662.63647, 13.59860,   0.00000, 0.00000, -62.00000);

//	динамические объекты
	CreateDynamicObject(988, 2508.16699, -1677.91479, 13.56860,   0.00000, 0.00000, -120.00000, -1, -1, -1, 500);
	CreateDynamicObject(988, 2510.76660, -1670.00928, 13.45860,   0.00000, 0.00000, -91.00000, -1, -1, -1, 500);
	CreateDynamicObject(988, 2509.57983, -1662.63647, 13.59860,   0.00000, 0.00000, -62.00000, -1, -1, -1, 500);

#if (MOD77INS == 1)
//  транспорт
	objveh[0] = CreateVehicle(562, 2510.58, -1679.28, 13.21, 330.32, 1, 1, 90000);
	objveh[1] = CreateVehicle(562, 2513.33, -1669.96, 13.20, 358.81, 1, 1, 90000);
	objveh[2] = CreateVehicle(562, 2511.63, -1661.40, 13.25, 29.08, 1, 1, 90000);
#endif

#if (MOD88INS == 1)
//	3D-тексты
	obj3dt[0] = CreateDynamic3DTextLabel("текст1", 0xFF0000FF, 2492.34, -1666.33, 13.34, 25, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0, -1);
	obj3dt[1] = CreateDynamic3DTextLabel("текст2", 0x00FF00FF, 2490.34, -1666.33, 13.34, 25, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0, -1);
	obj3dt[2] = CreateDynamic3DTextLabel("текст3", 0x0000FFFF, 2488.34, -1666.33, 13.34, 25, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0, -1);
#endif

	return 1;
}

#if (MOD77INS == 1)
	forward myobjvehfunc(carid);
	public myobjvehfunc(carid)
	{
		new para1 = 0;
		for(new i; i < MAXVEH; i++)
		{
			if(objveh[i] == carid)//если ИД удаляемого транспорта есть в скрипте myobj, то:
			{
				para1 = 1;//возвращаем 1 (иначе, возвращаем 0)
			}
		}
	    return para1;
	}
#endif

