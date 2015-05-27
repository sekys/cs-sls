//============================================================================================================
//									Seky's Liga system v3.0
//============================================================================================================

/*
	Tento plugin vytvoril Lukas Sekerak a jemu prinalezia vsetke prava.
	Je zakazane kopirovat tento program bez suhlasu autora.
	Je zakazane kopirovat sucasti programu a podprogramov.
	Copyright 2008-2011, Lukas Sekerak
*/

	/*~~~~~~~~~~~~  
	 - Poznamky -  
	~~~~~~~~~~~~~*/
/*	
*/


//#define HLTV
#define STATUS	

#define S_NAME		"GeCom s.r.o. Cup #1"	// Kontrola podla mena serveru	, zakomentuj a vypnes
#define S_RCON		"csleg2"				// Rcon kontrola				, zakomentuj a vypnes

#include "sls/Includes.sma"

	/*~~~~~~~~~~~~  
	  - Plugin -  
	~~~~~~~~~~~~~*/
		
stock sls_init() 
{	
	// Logy a Misc
	CONFIG_LOG_SUBOR 	= register_cvar("cup_log_subor", "CW")
	DEBUG 				= register_cvar("cup_debug", "1")									// 1 debug on,2 podrobny debug
	max_hracov 			= get_maxplayers()
	register_dictionary("cup.txt")
		
	// Casovace
	CAS_KONTROLA 		= register_cvar("cup_cas_kontrola", "180.0")						// pravidelna kontrola zapasu v sekundach, 0 vypne plugin
	CAS_KYM_SA_VRATI	= register_cvar("cup_cas_hrac", 	"60.0") 						// kontrola dokedy sa hrac musi vratit 0 vypne 
	CAS_DO_KICKU_HRACOV	= register_cvar("cup_cas_kick", 	"30.0")							// Cas do kicku hraca nastav 0.0 na vypnutie ,zaroven vypne aj vypinanie servera
	CAS_HRACI_NEPRIDU   = register_cvar("cup_cas_hraci", 	"600.0") 						// do kedy hraci musia prist,	 0 vypne 	1800=30min
	CAS_MUSIA_STIHNUT   = register_cvar("cup_cas_zapas",	"3300.0") 						// ako dlho moze max. trvat zapas,dokedy musia skoncit, 0 vypne	3300=1hod  6600.0 = 2hod
	CAS_INTERVAL_SPRAV  = register_cvar("cup_cas_spravy",	"10.0") 						// interval upozornujucich sprav
	CAS_HUD_INTERVAL  	= register_cvar("cup_cas_hud",		"1.0") 							// interval hud panelu						, 0 vypne
	CAS_TAB_INTERVAL  	= register_cvar("cup_cas_tab",		"5.0") 							// interval prepisovania score tabulky
	CAS_UDVODNA_SPRAVA  = register_cvar("cup_cas_wel",		"18.0") 						// za aky cas sa zobrazi uvodna sprava    			, 0 vypne
	CAS_PAUZA  			= register_cvar("cup_cas_pause",	"60.0") 						// cas na pauzu, 0.0 vypnut
	CAS_PAUZAPRE  		= register_cvar("cup_cas_pausepre",	"10.0") 						// cas napripravu po pauze, 0.0 to hned vypne
	
	// Kola
	KOL_CVICNE			= register_cvar("cup_kol_cvicne",	"2")							// cvicnych kol
	KOL_HRA 			= register_cvar("cup_kol_hra",		"30")							// pocet kol celkovo za hru ,musi byt najviac
	KOL_DEBAKEL 		= register_cvar("cup_kol_debakel",	"16")							// kolko kol potrebuje mat vyhratych aby bol debakel
	KOL_TEAM 			= register_cvar("cup_kol_zmena",	"15") 							// V ktorom kole prehodi hracov
	KOL_KNIFE			= register_cvar("cup_knife",		"1")							// on/off Ak je 0 tak najlepsi hrac z cvicneych kol si vyebrie team
			
	// Configuracia
	CONFIG_ADMIN 		= register_cvar("cup_admin", 		"l")	 						// flag ligoveho admina 	1. ziskava podrobny debug	 2.nieje presmerovavany 	3.nema cirnu obrazovku
	CONFIG_ADMINPLA 	= register_cvar("cup_adminplayer", 	"0")	 						// ak je zapnute hrac moze byt admin aj hrac inak pride o prava
	CONFIG_OFF 			= register_cvar("cup_end_vypnut", 	"0")	 						// zapne/vypne vypinanie servera po skonceni clan war
	CONFIG_PASS 		= register_cvar("cup_end_pass", 	"1") 							// zapne/vypne heslovanie mimo zapas
	CONFIG_DEMO 		= register_cvar("cup_dema_hracov",  "1")							// zapne/vypne aby aj hrali natacali vlastne dema +screeny na konci hry
	CONFIG_STEAM		= register_cvar("cup_user_steam", 	"1") 							// on/off kontrola podla steam cisla - ak su obidve zapnute ide mix metoda
	CONFIG_MENO			= register_cvar("cup_user_meno", 	"0") 							// on/off kontrola mena a hesla z databazi - ak su obidve zapnute ide mix metoda
	CONFIG_HESLO		= register_cvar("cup_user_heslo", 	"heslo") 						// text zadavajuci ako heslo ,musi byt nejaky cvar
	CONFIG_DIVACI		= register_cvar("cup_presmeruj",  	"0") 							// zadaj IP kde maju byt presmerovany divaci , 		0 vypnes
	CONFIG_OBRAZOVKA	= register_cvar("cup_obrazovka",  	"0") 							// mrtvym hracom a spectators zacierni obarzovku 		1 on , 0 off
	CONFIG_BLOCKSPE		= register_cvar("cup_blockspe",  	"1") 							// 
	CONFIG_ID			= register_cvar("cup_server_id", 	"0") 							// Prva podpora Multi-Core Serverov ... zadaj mysql server ID
	MENU_TLACIDLO		= register_cvar("cup_keymenu", 		"F7") 							// tlacitko na leader menu, ziadne - menu vypnute

	// Quota
	MIN_QUOTA			= register_cvar("cup_min_quota", "4") 								// min hracov v clane pre zapas  x on x
	MIN_TOEND			= register_cvar("cup_min_toend", "3") 								// min pocet hracov aby dohrali, 0 je plny pocet hracov
	KONTROLA_QUOTY 		= register_cvar("cup_quota", "0")									// zapne/vypne menenie quoty X on X
	
	// Databaza
	SQL_IP				= register_cvar("cup_sql_ip", 		"127.0.0.1" )
	SQL_MENO			= register_cvar("cup_sql_meno", 	"meno"		)
	SQL_HESLO 			= register_cvar("cup_sql_heslo", 	"heslo"			)
	SQL_DB   			= register_cvar("cup_sql_db_meno", 	"databaza"		)
	SQL_CLAN 			= register_cvar("cup_sql_clan", 	"`phpbanlist`.`acp_clans`"	)	// pomocou ` ` mozes lachko prepinat medzi databazamy
	SQL_ZAPAS 			= register_cvar("cup_sql_zapas", 	"`phpbanlist`.`acp_zapas`"	)	// cize urcujes cestu
	SQL_VYZVA 			= register_cvar("cup_sql_vyzva", 	"`phpbanlist`.`acp_vyzva`"	)
	SQL_USERS 			= register_cvar("cup_sql_hraci", 	"`cstrike`.`fusion_users`"	)
	SQL_TESTY 			= register_cvar("cup_sql_testy", 	"`phpbanlist`.`cup_testy`"	)
		
	// Prikazy
	register_clcmd("fullupdate",	 "fullupdate")
	register_clcmd("jointeam",		 "event_vyber_teamov_1")
	register_clcmd("say", 			 "sls_HandleSay")
	register_clcmd("say_team", 		 "sls_HandleSay")
	register_clcmd("cup_reloadtask", "Task_zapasu", 	ADMIN_ALL, 	"Vyhlada zapas v databaze." );
	register_clcmd("cup_respawn", 	 "clcmd_respawn", 	ADMIN_RCON, "Respawn hraca." );
	register_clcmd("cup_who", 	 	"cup_who", 	ADMIN_RCON, "Zisti informacie o hracoch." );
	register_clcmd("cup_menu", 		 "menu_system",		ADMIN_ALL,	"Ligove menu." );
	
	//register_clcmd("cup_rank", 	"clcmd_rank", 	ADMIN_RCON , "lol" );
	
	register_logevent("sls_cw_round", 2, "1=Round_Start")
	register_logevent("sls_cw_endround", 2, "1=Round_End")
	register_event("TeamScore","get_score_info","a")	
	register_menucmd(register_menuid("Team_Select",1),(1<<0)|(1<<1)|(1<<4),"event_vyber_teamov_2")
	register_menucmd(register_menuid("FTCHMENU"), TLACITKA, "sls_FirstTeamChooseAction")
	register_forward( FM_GetGameDescription, "status_serveru" ); 

	// Spravy ID
	msgid_status_text 	= get_user_msgid("StatusText")
	msgid_status_icon 	= get_user_msgid("StatusIcon")
	msgid_team_info  	= get_user_msgid("TeamInfo")
	msgid_team_score 	= get_user_msgid("TeamScore")
	msgid_score_info	= get_user_msgid("ScoreInfo")		
	msgid_money			= get_user_msgid("Money")
	msgid_say			= get_user_msgid("SayText")
	
	// Pre knife
	RegisterHam(Ham_Touch, "weaponbox", "fw_TouchWeapon")
	RegisterHam(Ham_Touch, "armoury_entity", "fw_TouchWeapon")
	RegisterHam(Ham_Touch, "weapon_shield", "fw_TouchWeapon")
}