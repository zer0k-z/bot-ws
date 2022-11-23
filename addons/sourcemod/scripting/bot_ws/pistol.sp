//10 Pistols, 19 Knives
#define TOTAL_PISTOLS 10
char pistolList[TOTAL_PISTOLS][64] = { "weapon_usp_silencer", "weapon_hkp2000", "weapon_glock", "weapon_p250", "weapon_deagle", "weapon_fiveseven",
									   "weapon_cz75a", "weapon_elite", "weapon_revolver", "weapon_tec9" };

char pistolNameList[TOTAL_PISTOLS][64] = { "USP-S", "P2000", "Glock-18", "P250", "Desert Eagle", "Five Seven", "CZ75-Auto", "Dual Berettas", "R8 Revolver", "Tec-9" };

int botPistolIndex = 0;
int pistolSkin = -1;
int pistolFallbackSeed;
int pistolSkinCount[TOTAL_PISTOLS];
float pistolFloat = 0.000001;
enum PistolIndices
{
	USP = 0,
	P2K,
	G18,
	P250,
	DEAGLE,
	FIVE7,
	CZ75,
	ELITE, 
	R8,
	TEC9
}
int pistolSkinIndices[TOTAL_PISTOLS][100];
char pistolSkinNames[TOTAL_PISTOLS][100][256];

void LoadPistols()
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
	
	for (int i = 0; i < TOTAL_PISTOLS; i++)
	{
		pistolSkinCount[i] = 0;
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
		
		for (int i = 0; i < TOTAL_PISTOLS; i++)
		{
			Format(tempWeaponName, sizeof(tempWeaponName), "%s;", pistolList[i]);
			
			if(StrContains(classesString, tempWeaponName) > -1)
			{
				pistolSkinNames[i][pistolSkinCount[i]] = sectionName;
				pistolSkinIndices[i][pistolSkinCount[i]] = StringToInt(skinIndexString);
				pistolSkinCount[i] += 1;
			}
		}
	}
	delete kv;
}