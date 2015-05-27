/*
	Tento plugin vytvoril Lukas Sekerak a jemu prinalezia vsetke prava.
	Je zakazane kopirovat tento program bez suhlasu autora.
	Je zakazane kopirovat sucasti programu a podprogramov.
	Copyright 2008-2011, Lukas Sekerak
*/

	/*~~~~~~~~~~~~  
	     - Premenne -  
	~~~~~~~~~~~~~*/

enum GAME_STATUS
{
	zapas_sa_nekona = -1,
	zapas_ma_byt,
	cvicne_kolo,
	knife_kolo,
	normal_kolo
};

new 
	// Mix
	DEFINE_SAY[32], LOG_SUBOR[64], ADMIN, kol, status[32], quota, sv_password[64], max_hracov,
	GAME_STATUS:game, knife_winner,
	
	// Clan
	clan_id[2], clan_meno[2][65], clan_tag[2][33], clan_team[2],  clan_vymena_score[2], 
	clan_bonus[2], clan_score[2],
	
	// SQl
	Handle:databaza, Handle:databaza_cvar, sql_id, cas_zapasu, start_zapasu, 
	SQL_IP, SQL_MENO, SQL_HESLO, SQL_DB, SQL_CLAN, SQL_ZAPAS, SQL_VYZVA, SQL_USERS,
	SQL_TESTY,
	
	// Cvar
	CAS_KYM_SA_VRATI, CAS_DO_KICKU_HRACOV, CAS_KONTROLA, CAS_HRACI_NEPRIDU,	CAS_MUSIA_STIHNUT,
	CAS_INTERVAL_SPRAV, CAS_HUD_INTERVAL, CAS_TAB_INTERVAL,  CAS_UDVODNA_SPRAVA, CONFIG_DIVACI,
	KOL_CVICNE, KOL_HRA, KOL_TEAM, MIN_QUOTA, KONTROLA_QUOTY, CONFIG_MENO, CONFIG_HESLO,	
	CONFIG_OFF, CONFIG_DEMO, CONFIG_PASS , CONFIG_LOG_SUBOR	, CONFIG_ID, MENU_TLACIDLO, DEBUG,
	CONFIG_ADMIN, CONFIG_OBRAZOVKA, CONFIG_STEAM, MIN_TOEND, CONFIG_ADMINPLA, KOL_KNIFE,
	KOL_DEBAKEL, CONFIG_BLOCKSPE, gcached_CONFIG_BLOCKSPE, gcached_MINTOEND,
	
	// Cache cast
	gcached_DEBUG, gcached_CONFIG_ID, gcached_CONFIG_MENO, Float:gcached_CAS_UDVODNA_SPRAVA,
	gcached_SQL_USERS[64], gcached_SQL_TESTY[64], gcached_MIN_QUOTA, gcached_CONFIG_STEAM,
	gcached_CONFIG_ADMINPLA, gcached_KOL_CVICNE,
	
	// Spravy ID
	msgid_status_text, msgid_status_icon, msgid_team_info, msgid_team_score, msgid_score_info,
	msgid_money, msgid_say,
	
	// Uzivatelia
	bool:user_menu[SLOTOV+1], user_hodnost[SLOTOV+1], user_webid[SLOTOV+1], user_bonus[SLOTOV+1], 
	user_presun[SLOTOV+1], user_clan[SLOTOV+1],
			
	// Misc
	paused_server, Float:clan_pause[2], CAS_PAUZA, CAS_PAUZAPRE,
	TAWP_TEST, TAWP_RAND, gAwptest[SLOTOV+1], gcached_TAWP_TEST, gcached_TAWP_RAND,
	bool:BlockedWeapons;
