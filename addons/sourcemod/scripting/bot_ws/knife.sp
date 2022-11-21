#define TOTAL_KNIVES 19
enum KnifeIndices
{
	BAYONET,
	M9,
	KARA,
	FLIP,
	GUT,
	HUNTSMAN,
	BUTTER,
	FALCHION,
	SHADOW,
	BOWIE,
	TALON,
	STILETTO,
	NAVAJA,
	URSUS,
	CORD
}
char knifeList[TOTAL_KNIVES][64] = {"weapon_bayonet", "weapon_knife_m9_bayonet",
									   "weapon_knife_css", "weapon_knife_karambit", "weapon_knife_flip", "weapon_knife_gut", "weapon_knife_tactical",
									   "weapon_knife_butterfly", "weapon_knife_falchion", "weapon_knife_push", "weapon_knife_survival_bowie",
									   "weapon_knife_widowmaker", "weapon_knife_stiletto", "weapon_knife_gypsy_jackknife", "weapon_knife_ursus",
									   "weapon_knife_cord", "weapon_knife_canis", "weapon_knife_outdoor", "weapon_knife_skeleton"
									  };
									 
char knifeNameList[TOTAL_KNIVES][64] = { "Bayonet", "M9 Bayonet", "Classic Knife", "Karambit", "Flip Knife", "Gut Knife", "Huntsman Knife", "Butterfly Knife",
												"Falchion Knife", "Shadow Daggers", "Bowie Knife", "Talon Knife", "Stiletto Knife", "Navaja Knife", "Ursus Knife", "Paracord Knife",
												"Survival Knife", "Nomad Knife", "Skeleton Knife" };
int botKnifeIndex = 0;
int knifeSkin = -1;
int knifeFallbackSeed;
int knifeSkinCount[TOTAL_KNIVES];
char knifeSkinNames[TOTAL_KNIVES][100][256];
int knifeSkinIndices[TOTAL_KNIVES][100];


void LoadKnives()
{
	if(FileExists(CONFIG_FILE) == false)
	{
		SetFailState("%s does not exist.", CONFIG_FILE);
	}
	
	KeyValues kv = new KeyValues("WeaponSkins");
	kv.ImportFromFile(CONFIG_FILE);
	
	if(kv == null)
	{
		SetFailState("Failed reading %s as Key-Value pairs. Make sure its in the right format!", CONFIG_FILE);
	}
	
	for (int i = 0; i < TOTAL_KNIVES; i++)
	{
		knifeSkinCount[i] = 0;
	}
	
	//Temp weapon name from 
	char tempWeaponName[64];
	
	while(kv.GotoFirstSubKey() || kv.GotoNextKey())
	{
		char sectionName[256];
		char skinIndexString[16];
		char classesString[1024];
		
		kv.GetSectionName(sectionName, sizeof(sectionName));
		kv.GetString("index", skinIndexString, sizeof(skinIndexString));
		kv.GetString("classes", classesString, sizeof(classesString));
		
		for (int i = 0; i < TOTAL_KNIVES; i++)
		{
			Format(tempWeaponName, sizeof(tempWeaponName), "%s;", knifeList[i]);
			
			if(StrContains(classesString, tempWeaponName) > -1)
			{
				knifeSkinNames[i][knifeSkinCount[i]] = sectionName;
				knifeSkinIndices[i][knifeSkinCount[i]] = StringToInt(skinIndexString);
				knifeSkinCount[i] += 1;
			}
		}
	}
	delete kv;
}