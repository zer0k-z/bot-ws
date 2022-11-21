#include <sourcemod>
#include <smlib>
#include <cstrike>

#undef REQUIRE_EXTENSIONS
#undef REQUIRE_PLUGIN

#include <csgo_weaponstickers>

#pragma semicolon 1
#pragma newdecls required

#define PREFIX "[\x05SM\x01]\x01"

#define CONFIG_FILE "addons/sourcemod/configs/bot_ws/skins.cfg"
#include "bot_ws/pistol.sp"
#include "bot_ws/knife.sp"
#include "bot_ws/sticker.sp"


public Plugin myinfo =
{
	name = "Bot WS",
	author = "<><><>><",
	description = "Give a bot a skin",
	version = "1.0",
	url = "gokz.tv"
};
bool gB_CSGOSticker;

public void OnPluginStart()
{
	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Pre);
	RegConsoleCmd("sm_botpistol", Command_SkinMenu, "Opens the menu");
	// Don't think bot needs a pistol seed ever so we just reuse this.

	RegConsoleCmd("sm_botknife", Command_SkinMenu_Knife, "Opens the menu");
	RegConsoleCmd("sm_botseed", Command_Seed, "Set seed");
	RegConsoleCmd("sm_botsticker", Command_Sticker, "Set sticker");
}

public void OnAllPluginsLoaded()
{
	gB_CSGOSticker = LibraryExists("csgo_weaponsticker");
}

public void OnLibraryAdded(const char[] name)
{
	gB_CSGOSticker = gB_CSGOSticker || StrEqual(name, "csgo_weaponsticker");
}

public void OnLibraryRemoved(const char[] name)
{
	gB_CSGOSticker = gB_CSGOSticker && !StrEqual(name, "csgo_weaponsticker");
}

public void OnMapStart()
{
	LoadPistols();
	LoadKnives();
}

public Action Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));

	if(IsFakeClient(client) == true)
	{
		CreateTimer(0.15, GiveWeapons, GetEventInt(event, "userid"));
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

//https://forums.alliedmods.net/showthread.php?t=261263
public void GetBotThings(int client, int entity)
{
	// Pistol
	if(entity == -1)
	{
		entity = GivePlayerItem(client, pistolList[botPistolIndex]);
		SetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity", client); 
		EquipPlayerWeapon(client, entity);
	}
	
	int m_iItemIDHigh = GetEntProp(entity, Prop_Send, "m_iItemIDHigh");
	int m_iItemIDLow = GetEntProp(entity, Prop_Send, "m_iItemIDLow");
		
	SetEntProp(entity, Prop_Send, "m_iItemIDLow", 2048);
	SetEntProp(entity, Prop_Send, "m_iItemIDHigh", 0);

	SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", pistolSkin);
	SetEntProp(entity, Prop_Send, "m_nFallbackSeed", pistolFallbackSeed);
	SetEntProp(entity, Prop_Send, "m_iAccountID", -1);
	SetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity", client);
	SetEntPropEnt(entity, Prop_Send, "m_hPrevOwner", -1);

	Handle pack;
	CreateDataTimer(0.01, RestoreItemID, pack);
	WritePackCell(pack, entity);
	WritePackCell(pack, m_iItemIDHigh);
	WritePackCell(pack, m_iItemIDLow);
	int pistol = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
	if (pistol != -1)
	{
		for (int i = 0; i < sizeof(gI_Sticker); i++)
		{
			if (!gI_Sticker[i])
			{
				continue;
			}
			if (gB_CSGOSticker)
			{
				CS_SetWeaponSticker(client, pistol, i, gI_Sticker[i], gF_StickerWear[i]);
			}
		}
	}
}

//https://forums.alliedmods.net/showthread.php?t=261263
public Action RestoreItemID(Handle timer, Handle pack)
{
	int entity;
	int m_iItemIDHigh;
	int m_iItemIDLow;
	
	ResetPack(pack);
	entity = ReadPackCell(pack);
	m_iItemIDHigh = ReadPackCell(pack);
	m_iItemIDLow = ReadPackCell(pack);
	
	if(IsValidEdict(entity))
	{
		SetEntProp(entity, Prop_Send, "m_iItemIDHigh", m_iItemIDHigh);
		SetEntProp(entity, Prop_Send, "m_iItemIDLow", m_iItemIDLow);
	}
	return Plugin_Continue;
}

public Action GiveKnife(int client, int entity)
{
	if (entity == -1)
	{
		entity = GivePlayerItem(client, knifeList[botKnifeIndex]);
		SetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity", client); 
		EquipPlayerWeapon(client, entity);
	}
	
	int m_iItemIDHigh = GetEntProp(entity, Prop_Send, "m_iItemIDHigh");
	int m_iItemIDLow = GetEntProp(entity, Prop_Send, "m_iItemIDLow");
		
	SetEntProp(entity, Prop_Send, "m_iItemIDLow", 2048);
	SetEntProp(entity, Prop_Send, "m_iItemIDHigh", 0);

	SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", knifeSkin);
	SetEntProp(entity, Prop_Send, "m_nFallbackSeed", knifeFallbackSeed);
	SetEntProp(entity, Prop_Send, "m_iAccountID", -1);
	SetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity", client);
	SetEntPropEnt(entity, Prop_Send, "m_hPrevOwner", -1);

	Handle pack;
	CreateDataTimer(0.01, RestoreItemID, pack);
	WritePackCell(pack, entity);
	WritePackCell(pack, m_iItemIDHigh);
	WritePackCell(pack, m_iItemIDLow);

	FakeClientCommandEx(client, "use %s", "weapon_knife");
	return Plugin_Continue;
}

public Action Command_Sticker(int client, int args)
{
	if(args < 3)
	{
		ReplyToCommand(client, "%s Usage: sm_botsticker <slot> <stickerid> <wear>", PREFIX);
		return Plugin_Handled;
	}
	
	char buffer[1024];
	GetCmdArg(1, buffer, sizeof(buffer));
	int slot = StringToInt(buffer);
	GetCmdArg(2, buffer, sizeof(buffer));
	gI_Sticker[slot] = StringToInt(buffer);
	GetCmdArg(3, buffer, sizeof(buffer));
	gF_StickerWear[slot] = StringToFloat(buffer);
	return Plugin_Handled;
}

public Action Command_Seed(int client, int args)
{
	if(client == 0)
	{
		return Plugin_Handled;
	}
	
	if(args != 1)
	{
		ReplyToCommand(client, "%s Usage: sm_botknifeseed <seed>", PREFIX);
		return Plugin_Handled;
	}
	
	else
	{
		char seed[64];
		GetCmdArg(1, seed, 64);
		pistolFallbackSeed = StringToInt(seed);
		knifeFallbackSeed = StringToInt(seed);
		ReplyToCommand(client, "%s Done!", PREFIX);
		return Plugin_Handled;
	}
}

public Action Command_SkinMenu(int client, int args)
{
	if(client == 0)
	{
		return Plugin_Handled;
	}
	
	if(args != 0)
	{
		ReplyToCommand(client, "%s Usage: sm_rskin", PREFIX);
		return Plugin_Handled;
	}
	
	else
	{
		ShowMenu(client);
		return Plugin_Handled;
	}
}

//Menu display methods
//Default Menu
void ShowMenu(int client)
{
	Menu menu = new Menu(Menu_Callback);
		
	menu.SetTitle("Weapon Skin Selection");
	
	for(int i = 0; i < TOTAL_PISTOLS; i++)
	{
		char optionString[16];
		FormatEx(optionString, sizeof(optionString), "option%d", i + 1);
		menu.AddItem(optionString, pistolNameList[i]);
	}
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Menu_Callback(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char item[32];
			menu.GetItem(param2, item, sizeof(item));
			
			char option[3];
			
			//https://forums.alliedmods.net/showthread.php?t=268099
			FormatEx(option, sizeof(option), "%s", item[6]);
			ReplaceString(item, sizeof(item), option, "");
			
			int optionInt = StringToInt(option);
			optionInt -= 1;

			botPistolIndex = optionInt;
			
			PrintToChat(param1, "%s You chose %s", PREFIX, pistolNameList[optionInt]);
			
			ShowSkinMenu(param1);
		}
		
		case MenuAction_Cancel:
		{
			PrintToServer("Client %d's menu was cancelled for reason %d", param1, param2);
		}
		
		case MenuAction_End:
		{
			delete menu;
		}
	}
	return 0;
}

//Generic skin menu
void ShowSkinMenu(int client, int item = 0)
{
	Menu menu = new Menu(Menu_CallbackSkin);
	
	char menuTitle[64];
	FormatEx(menuTitle, sizeof(menuTitle), "%s Skins", pistolNameList[botPistolIndex]);
	menu.SetTitle(menuTitle);
	
	menu.AddItem("-1", "Default");
	
	for(int i = 0; i < pistolSkinCount[botPistolIndex]; i++)
	{
		char index[8];

		IntToString(i, index, sizeof(index));
		menu.AddItem(index, pistolSkinNames[botPistolIndex][i]);
	}
	
	menu.ExitButton = true;
	menu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int Menu_CallbackSkin(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char item[32];
			menu.GetItem(param2, item, sizeof(item));
			
			int selection = StringToInt(item);
			if(selection == -1)
			{
				pistolSkin = 1;
			}
			
			else
			{
				pistolSkin = pistolSkinIndices[botPistolIndex][selection];
				PrintToChat(param1, "%s You chose %s", PREFIX, pistolSkinNames[botPistolIndex][selection]);
			}
		}
		
		case MenuAction_Cancel:
		{
			PrintToServer("Client %d's menu was cancelled for reason %d", param1, param2);
		}
		
		case MenuAction_End:
		{
			delete menu;
		}
	}
	return 0;
}

public Action GiveWeapons(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	Client_RemoveAllWeapons(client);
	int entity = -1;
	GiveKnife(client,entity);
	entity = GivePlayerItem(client, pistolList[botPistolIndex]);
	
	GetBotThings(client, entity);
	return Plugin_Continue;
}


public Action Command_SkinMenu_Knife(int client, int args)
{
	if(client == 0)
	{
		return Plugin_Handled;
	}
	
	if(args != 0)
	{
		ReplyToCommand(client, "%s Usage: sm_rskin", PREFIX);
		return Plugin_Handled;
	}
	
	else
	{
		ShowMenu_Knife(client);
		return Plugin_Handled;
	}
}

//Menu display methods
//Default Menu
void ShowMenu_Knife(int client)
{
	Menu menu = new Menu(Menu_Callback_Knife);
		
	menu.SetTitle("Weapon Skin Selection");
	
	for(int i = 0; i < TOTAL_KNIVES; i++)
	{
		char optionString[16];
		FormatEx(optionString, sizeof(optionString), "option%d", i + 1);
		menu.AddItem(optionString, knifeNameList[i]);
	}
	
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Menu_Callback_Knife(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char item[32];
			menu.GetItem(param2, item, sizeof(item));
			
			char option[3];
			
			//https://forums.alliedmods.net/showthread.php?t=268099
			FormatEx(option, sizeof(option), "%s", item[6]);
			ReplaceString(item, sizeof(item), option, "");
			
			int optionInt = StringToInt(option);
			optionInt -= 1;

			botKnifeIndex = optionInt;
			
			PrintToChat(param1, "%s You chose %s", PREFIX, knifeNameList[optionInt]);
			
			ShowSkinMenu_Knife(param1);
		}
		
		case MenuAction_Cancel:
		{
			PrintToServer("Client %d's menu was cancelled for reason %d", param1, param2);
		}
		
		case MenuAction_End:
		{
			delete menu;
		}
	}
	return 0;
}

//Generic skin menu
void ShowSkinMenu_Knife(int client, int item = 0)
{
	Menu menu = new Menu(Menu_CallbackSkin_Knife);
	
	char menuTitle[64];
	FormatEx(menuTitle, sizeof(menuTitle), "%s Skins", knifeNameList[botKnifeIndex]);
	menu.SetTitle(menuTitle);
	
	menu.AddItem("-1", "Default");
	
	for(int i = 0; i < knifeSkinCount[botKnifeIndex]; i++)
	{
		char index[8];

		IntToString(i, index, sizeof(index));
		menu.AddItem(index, knifeSkinNames[botKnifeIndex][i]);
	}
	
	menu.ExitButton = true;
	menu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int Menu_CallbackSkin_Knife(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char item[32];
			menu.GetItem(param2, item, sizeof(item));
			
			int selection = StringToInt(item);
			if(selection == -1)
			{
				knifeSkin = 1;
			}
			
			else
			{
				knifeSkin = knifeSkinIndices[botKnifeIndex][selection];
				PrintToChat(param1, "%s You chose %s", PREFIX, knifeSkinNames[botKnifeIndex][selection]);
			}
		}
		
		case MenuAction_Cancel:
		{
			PrintToServer("Client %d's menu was cancelled for reason %d", param1, param2);
		}
		
		case MenuAction_End:
		{
			delete menu;
		}
	}
	return 0;
}
