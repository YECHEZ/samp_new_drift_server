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
	SendClientMessageToAll(0xFFFFFFFF, "�� ���� ����� ����� ���� ���� �������.");
	SendClientMessageToAll(0xFFFFFFFF, "�� ���� ����� ����� ���� ���� �������.");
	return 1;
}

public Reklama2()
{
	SendClientMessageToAll(0xFFFFFFFF, "������ �� �������� �������: {FFF82F}/help  {FFFFFF}������� ����: {FFF82F}����� Alt, ''2'' {FFFFFF}, ��� {FFF82F}/menu");
	return 1;
}

