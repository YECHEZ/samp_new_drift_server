#include <a_samp>

forward Reklama1();
forward Reklama2();

new reklamatimer1;
new reklamatimer2;

public OnFilterScriptInit()
{
	reklamatimer1 = SetTimer("Reklama1", 300000, 1);
	reklamatimer2 = SetTimer("Reklama2", 360000, 1);
	return 1;
}

public OnFilterScriptExit()
{
	KillTimer(reklamatimer1);
	KillTimer(reklamatimer2);
	return 1;
}

public Reklama1()
{
	SendClientMessageToAll(0xFFFFFFFF, "На этом месте может быть Ваша реклама.");
	SendClientMessageToAll(0xFFFFFFFF, "На этом месте может быть Ваша реклама.");
	return 1;
}

public Reklama2()
{
	SendClientMessageToAll(0xFFFFFFFF, "Помощь по командам сервера: {FFF82F}/help  {FFFFFF}Игровое меню: {FFF82F}левый Alt, ''2'' {FFFFFF}, или {FFF82F}/menu");
	return 1;
}

