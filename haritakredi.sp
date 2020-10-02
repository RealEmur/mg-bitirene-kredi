#include <sourcemod>
#include <store>
#include <devzones>

ConVar harita_verilecek_kredi = null, harita_herround_verilsinmi = null, harita_ilkbitiren = null;
bool kazandi[MAXPLAYERS + 1] = false;
bool roundbasi = false;

public void OnPluginStart()
{
	harita_verilecek_kredi = CreateConVar("harita_kredi", "1000", "Bitiren kişiye kaç kredi verilsin", 0, true, 0.0);
	harita_herround_verilsinmi = CreateConVar("harita_odul", "1", "Haritayı bitiren kişi her round sadece 1 kere mi kredi alabilsin? 1 = Evet 0 = Hayır", 0, true, 0.0, true, 1.0);
	harita_ilkbitiren = CreateConVar("harita_ilkbitiren", "1", "İlk bitiren kişiye mi yoksa bitiren herkese mi kredi verilsin? 1 = Herkese 0 = İlk bitirene", 0, true, 0.0, true, 1.0)
	AutoExecConfig(true, "mgkredi", "sourcemod/Plugin_Merkezi");
	
	HookEvent("round_end", event_end);
	HookEvent("player_death", event_death);
}

public void Zone_OnClientEntry(int client, const char [] zone)
{
	if(StrContains(zone, "MapSonu") != -1 && !kazandi[client])
	{
		if(harita_ilkbitiren.IntValue == 0)
		{
			if(!roundbasi)
			{
				Store_SetClientCredits(client, Store_GetClientCredits(client) + harita_verilecek_kredi.IntValue);
				PrintToChat(client, " \x06[MG] \x01Haritayı bitirdiğin için \x04%d kredi \x01kazandın.", harita_verilecek_kredi.IntValue);
				kazandi[client] = true;
				roundbasi = true;
			}
			else
				PrintToChat(client, " \x06[MG] \x01Haritayı daha önce bitiren başka biri olduğu için hiçbir şey kazanamadın.");
		}
		else
		{
			Store_SetClientCredits(client, Store_GetClientCredits(client) + harita_verilecek_kredi.IntValue);
			PrintToChat(client, " \x06[MG] \x01Haritayı bitirdiğin için \x04%d kredi \x01kazandın.", harita_verilecek_kredi.IntValue);
			kazandi[client] = true;
		}
	}
}

public Action event_death(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(harita_herround_verilsinmi.IntValue == 0)
		kazandi[client] = false;
	return Plugin_Continue;
}

public Action event_end(Event event, const char[] name, bool dontBroadcast)
{
	roundbasi = false;
	for(int i = 1; i < MAXPLAYERS; i++)
	{
		kazandi[i] = false;
	}
	return Plugin_Continue;
}