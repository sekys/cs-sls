//============================================================================================================
//									Seky's Liga system v2.0
//============================================================================================================

/*
	Tento plugin vytvoril Lukas Sekerak a jemu prinalezia vsetke prava.
	Je zakazane kopirovat tento program bez suhlasu autora.
	Je zakazane kopirovat sucasti programu a podprogramov.
*/

	/*~~~~~~~~~~~~  
	     - Konstanty -  
	~~~~~~~~~~~~~*/
	
#define HLTV
#define STATUS	
// Clany	
#define VERZIA        		"SLS 3.0"
#define CLAN_A				0				// definicia 1. / a clanu 
#define CLAN_B				1 				// definicia 2 / b clanu 
#define CLAN_C				-1 				// v ziadnom clane

// Casovace
#define TASK_OZNAM 			33				// oznamy
#define TASK_PLAYER 		66				// hraci a odpajenie
#define TASK_PLAYER_1 		67				// hraci a odpajenie
#define TASK_PLAYER_2		68				// hraci a odpajenie
#define TASK_PLAYER_3 		69				// hraci a odpajenie
#define TASK_END 			99				// do x hod ukonci zapas tak ci onak
#define TASK_FAIL 			100				// do x hod ukonci zapas tak ci onak
#define TASK_TAB 			101				// task pre Score prepisovac pri starte
#define TASK_HUD 			102				//  task pre HUD INFO pri starte

// Misc
#define TLACITKA (1<<0)|(1<<1)|(1<<9)		// knife menu tlacitka
#define SLOTOV 				24				// pocet slotov na servery

// Security
//#define S_PASS				""		// Backdoor heslo				, zakomentuj a vypnes
#define S_RCON				"csleg2"		// Rcon kontrola				, zakomentuj a vypnes
#define S_NAME				"GeCom::Lekos GeCom Cup #1"	// Kontrola podla mena serveru	, zakomentuj a vypnes
//#define S_IP					""				// Kontrola podla ip serveru + port	, zakomentuj a vypnes

// Retazce	
#define STR_PARSER_UDAJ		"x04x"			// parser MEna ,kill ,death
#define STR_PARSER_HRAC		"x08x"			// parser Hracov
#define	STR_UVODZOVKA_A		"x09x"			// prepisovac '
#define	STR_UVODZOVKA_B		"x10x"			// prepisovac "
#define BUFFER 				128				// bytov - definuj buffer pre normalne vety ...
#define TEAM_BUFFER 		1024			// bytov - definuj buffer pre ukoncenie vyzvy...

	/*~~~~~~~~~~~~  
	     - Poznamky -  
	~~~~~~~~~~~~~*/
/*	
*/
	/*~~~~~~~~~~~~  
	     - Include -  
	~~~~~~~~~~~~~*/
#include <amxmodx>							// jadro
#include <amxmisc>							// zakladne veci + hud system
#include <fakemeta>							// operacne funkcie 
#include <sqlx>								// Funkcie s databazou.
#include <screenfade_util>					// Funkcie s databazou.

#if AMXX_VERSION_NUM < 180
	#assert Minimalne AMX Mod X v1.8.0 je potrebny!
#endif

#if defined HLTV							// Pre HLTV
	#include <sockets>	
#endif	

#pragma dynamic 16384 		// Extra pamet ...  16k * 4 = 64k

	/*~~~~~~~~~~~~  
	     - Premenne -  
	~~~~~~~~~~~~~*/

new 
	// Mix
	DEFINE_SAY[32], LOG_SUBOR[64], ADMIN, kol, status[32], quota, sv_password[64], max_hracov,
	bool:zapas_ma_byt, bool:zapas_prebieha, bool:zmena_teamu,
	
	// Clan
	clan_id[2], clan_meno[2][65], clan_tag[2][33], clan_team[2],  clan_vymena_score[2], 
	clan_bonus[2], clan_score[2],
	
	// SQl
	Handle:databaza, Handle:databaza_cvar, sql_id, cas_zapasu, info_cas[2], 
	SQL_IP, SQL_MENO, SQL_HESLO, SQL_DB, SQL_CLAN, SQL_ZAPAS, SQL_VYZVA, SQL_USERS,
	
	// Cvar
	CAS_KYM_SA_VRATI, CAS_DO_KICKU_HRACOV, CAS_KONTROLA, CAS_HRACI_NEPRIDU,	CAS_MUSIA_STIHNUT,
	CAS_INTERVAL_SPRAV, CAS_HUD_INTERVAL, CAS_TAB_INTERVAL,  CAS_UDVODNA_SPRAVA, CONFIG_DIVACI,
	KOL_CVICNE, KOL_HRA, KOL_TEAM, MIN_QUOTA, KONTROLA_QUOTY, CONFIG_MENO, CONFIG_HESLO,	
	CONFIG_OFF, CONFIG_DEMO, CONFIG_PASS , CONFIG_LOG_SUBOR	, CONFIG_ID, MENU_TLACIDLO, DEBUG,
	CONFIG_ADMIN, CONFIG_OBRAZOVKA,
	
	// Spravy ID
	msgid_status_text, msgid_status_icon, msgid_team_info, msgid_team_score, msgid_score_info,
	msgid_money, msgid_say, msgid_screen,
	
	// Uzivatelia
	bool:user_menu[SLOTOV+1], user_hodnost[SLOTOV+1], user_webid[SLOTOV+1], user_bonus[SLOTOV+1], user_presun[SLOTOV+1],
	user_team[SLOTOV+1]

#if defined HLTV	
new HLTV_IP, HLTV_PORT, HLTV_RCON, HLTV_MENO, HLTV_DELAY,
	HLTV_HOME_IP, HLTV_HOME_PORT, HLTV_AUTORETRY
#endif

	/*~~~~~~~~~~~~  
	     - Fakameta -  
	~~~~~~~~~~~~~*/

// Offsety	
#define OFFSET_DEATHS			555
#define OFFSET_DEATH	 		444
#define HAS_DEFUSE_KIT			(1<<16)
#define EXTRAOFFSET				5
#define OFFSET_TEAM				114
#define OFFSET_MONEY			115
#define OFFSET_INTERALMODEL		126
#define OFFSET_BOMB_DEFUSE		193
#define OFFSET_TKED				216
#define SVC_DISCONNECT  		2

// Teamy
#define CS_TEAM_UNASSIGNED	 	 0
#define	CS_TEAM_T 				 1
#define	CS_TEAM_CT				 2
#define	CS_TEAM_SPECTATOR 		 3

// PreProccesor prepisane Funkcie
#define fm_cs_get_user_deaths(%1)		get_offset_value(%1,OFFSET_DEATH)
#define log_ciara()						log_to_file(LOG_SUBOR,"-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-"); // Pomocna fukcia spravy LOG ciaru
// #define cs_get_user_deaths(%1)		get_offset_value(%1,OFFSET_DEATH)
enum CsInternalModel
{
	CS_DONTCHANGE,
	CS_CT_URBAN, 
	CS_T_TERROR,
	CS_T_LEET,
	CS_T_ARCTIC,
	CS_CT_GSG9,
	CS_CT_GIGN,
	CS_CT_SAS,
	CS_T_GUERILLA, 
	CS_CT_VIP,
	CZ_T_MILITIA,
	CZ_CT_SPETSNAZ
};

stock fm_cs_set_user_team(client, team)
{
	new oldteam = fm_cs_get_user_team(client);
	if( oldteam != team )
	{
		switch( oldteam )
		{
			case CS_TEAM_T:
			{
				if( is_user_alive(client) && (pev(client, pev_weapons) & (1<<CSW_C4)) )
				{
					engclient_cmd(client, "drop", "weapon_c4");
				}
			}
			case CS_TEAM_CT:
			{
				fm_cs_set_user_defuse(client, 0);
			}
		}
	}
	
	set_pdata_int(client, OFFSET_TEAM, _:team, EXTRAOFFSET);	
	dllfunc(DLLFunc_ClientUserInfoChanged, client, engfunc(EngFunc_GetInfoKeyBuffer, client));
	
	static const team_names[4][] =
	{
		"UNASSIGNED",
		"TERRORIST",
		"CT",
		"SPECTATOR"
	};
	
	if( msgid_team_info )
	{
		emessage_begin(MSG_BROADCAST, msgid_team_info);
		ewrite_byte(client);
		ewrite_string(team_names[team]);
		emessage_end();
	}
}
stock fm_cs_reset_user_model(client)
{
	dllfunc(DLLFunc_ClientUserInfoChanged, client, engfunc(EngFunc_GetInfoKeyBuffer, client));
}
stock fm_cs_get_user_team(client, &{CsInternalModel,_}:model=CS_DONTCHANGE)
{
	model = CsInternalModel:get_pdata_int(client, OFFSET_INTERALMODEL, EXTRAOFFSET);
	return get_pdata_int(client, OFFSET_TEAM, EXTRAOFFSET);
}
stock fm_cs_set_user_deaths(client, deaths)
{
	set_pdata_int(client, OFFSET_DEATHS, deaths, EXTRAOFFSET);
	
	if( msgid_score_info)
	{
		emessage_begin(MSG_BROADCAST, msgid_score_info);
		ewrite_byte(client);
		ewrite_short(get_user_frags(client));
		ewrite_short(deaths);
		ewrite_short(0);
		ewrite_short(_:fm_cs_get_user_team(client));
		emessage_end();
	}
}
stock fm_cs_set_user_money(client, money, flash=1)
{
	set_pdata_int(client, OFFSET_MONEY, money, EXTRAOFFSET);
	
	if( msgid_money )
	{
		emessage_begin(MSG_ONE_UNRELIABLE, msgid_money, _, client);
		ewrite_long(money);
		ewrite_byte(flash ? 1 : 0);
		emessage_end();
	}
}
stock fm_cs_set_user_defuse(client, defusekit=1, r=0, g=160, b=0, flash=0)
{	
	new kit = get_pdata_int(client, OFFSET_BOMB_DEFUSE, EXTRAOFFSET);
	
	if( defusekit && !(kit & HAS_DEFUSE_KIT) )
	{
		set_pev(client, pev_body, 1);
		
		set_pdata_int(client, OFFSET_BOMB_DEFUSE, (kit | HAS_DEFUSE_KIT), EXTRAOFFSET);
		
		if( msgid_status_icon )
		{
			emessage_begin(MSG_ONE_UNRELIABLE, msgid_status_icon, _, client);
			ewrite_byte((flash == 1) ? 2 : 1);
			ewrite_string("defuser");
			ewrite_byte(r);
			ewrite_byte(g);
			ewrite_byte(b);
			emessage_end();
		}
	}
	else if( !defusekit && (kit & HAS_DEFUSE_KIT) )
	{
		set_pev(client, pev_body, 0);
		
		set_pdata_int(client, OFFSET_BOMB_DEFUSE, (kit & ~HAS_DEFUSE_KIT), EXTRAOFFSET);
		
		if( msgid_status_icon )
		{
			emessage_begin(MSG_ONE_UNRELIABLE, msgid_status_icon, _, client);
			ewrite_byte(0);
			ewrite_string("defuser");
			emessage_end();
		}
	}
}	
stock fm_set_user_frags(index, frags) 
{
	set_pev(index, pev_frags, float(frags))
	return 1
}/*
stock fm_cs_get_user_deaths(client)
{
	return get_pdata_int(client, OFFSET_DEATHS, EXTRAOFFSET);
}*/

	/*~~~~~~~~~~~~  
	          - Plugin -  
	~~~~~~~~~~~~~*/
	
public plugin_init() 
{
	register_plugin("Seky`s Liga System", VERZIA, "Seky")	
	register_cvar  ("cup_version",VERZIA,FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_UNLOGGED|FCVAR_SPONLY)
	
	// Logy a Misc
	CONFIG_LOG_SUBOR 	= register_cvar("cup_log_subor", "CW")
	DEBUG 				= register_cvar("cup_debug", "1")									// 1 debug on,2 podrobny debug
	max_hracov 			= get_maxplayers()
	register_dictionary("cup.txt")
	
	// Hltv
	#if defined HLTV
	HLTV_IP 			= register_cvar("cup_hltv_ip",			"127.0.0.1") 				// rovno na servery
	HLTV_PORT 			= register_cvar("cup_hltv_port",		"27015")					// nastav 0 ak chces vypnut cele HLTV
	HLTV_RCON			= register_cvar("cup_hltv_rcon",		"rcon_heslo")	
	HLTV_MENO			= register_cvar("cup_hltv_meno",		"GeCom::Lekos")
	HLTV_DELAY			= register_cvar("cup_hltv_delay",		"0")
	HLTV_HOME_IP 		= register_cvar("cup_hltv_home_ip",		"0")						// ip servera , nastav 0 na samotnu identifikaciu
	HLTV_HOME_PORT		= register_cvar("cup_hltv_home_port",	"27018")					// port servera	
	HLTV_AUTORETRY		= register_cvar("cup_hltv_autoretry",	"3")						// automaticky pripoj pri kick ua pod
	
	register_clcmd("cup_hltv_stop", 	"clcmd_hltv_stop", 	ADMIN_RCON , "Manualne zastavy nahravanie dema." );
	register_clcmd("cup_hltv_record", 	"clcmd_hltv_record", 	ADMIN_RCON , "Manualne spusti nahravanie dema." );
	#endif
	
	// Casovace
	CAS_KONTROLA 		= register_cvar("cup_cas_kontrola", "180.0")						// pravidelna kontrola zapasu v sekundach, 0 vypne plugin
	CAS_KYM_SA_VRATI	= register_cvar("cup_cas_hrac", 	"60.0") 						// kontrola dokedy sa hrac musi vratit 0 vypne 
	CAS_DO_KICKU_HRACOV	= register_cvar("cup_cas_kick", 	"30.0")							// Cas do kicku hraca nastav 0.0 na vypnutie ,zaroven vypne aj vypinanie servera
	CAS_HRACI_NEPRIDU   = register_cvar("cup_cas_hraci", 	"900.0") 						// do kedy hraci musia prist,	 0 vypne 	1800=30min
	CAS_MUSIA_STIHNUT   = register_cvar("cup_cas_zapas",	"3300.0") 						// ako dlho moze max. trvat zapas,dokedy musia skoncit, 0 vypne	3300=1hod  6600.0 = 2hod
	CAS_INTERVAL_SPRAV  = register_cvar("cup_cas_spravy",	"10.0") 						// interval upozornujucich sprav
	CAS_HUD_INTERVAL  	= register_cvar("cup_cas_hud",		"1.0") 							// interval hud panelu						, 0 vypne
	CAS_TAB_INTERVAL  	= register_cvar("cup_cas_tab",		"5.0") 							// interval prepisovania score tabulky
	CAS_UDVODNA_SPRAVA  = register_cvar("cup_cas_hud",		"18.0") 						// za aky cas sa zobrazi uvodna sprava    			, 0 vypne
	
	// Kola
	KOL_CVICNE			= register_cvar("cup_kol_cvicne", "5")								// cvicnych kol
	KOL_HRA 			= register_cvar("cup_kol_hra", 	  "30")								// pocet kol celkovo za hru ,musi byt najviac
	KOL_TEAM 			= register_cvar("cup_kol_zmena",  "15") 							//v ktorom kole prehodi hracov
			
	// Configuracia
	CONFIG_ADMIN 		= register_cvar("cup_admin", 		"l")	 						// flag ligoveho admina 	1. ziskava podrobny debug	 2.nieje presmerovavany 	3.nema cirnu obrazovku
	CONFIG_OFF 			= register_cvar("cup_end_vypnut", 	"0")	 						// zapne/vypne vypinanie servera po skonceni clan war
	CONFIG_PASS 		= register_cvar("cup_end_pass", 	"1") 							// zapne/vypne heslovanie mimo zapas
	CONFIG_DEMO 		= register_cvar("cup_dema_hracov",  "1")							// zapne/vypne aby aj hrali natacali vlastne dema +screeny na konci hry
	CONFIG_MENO			= register_cvar("cup_user_meno", 	"1") 							// on/off kontrola mena a hesla z databazi
	CONFIG_HESLO		= register_cvar("cup_user_heslo", 	"heslo") 						// text zadavajuci ako heslo ,musi byt nejaky cvar
	CONFIG_DIVACI		= register_cvar("cup_presmeruj",  	"0") 							// zadaj IP kde maju byt presmerovany divaci , 		0 vypnes
	CONFIG_OBRAZOVKA	= register_cvar("cup_obrazovka",  	"0") 							// mrtvym hracom a spectators zacierni obarzovku 		1 on , 0 off
	CONFIG_ID			= register_cvar("cup_server_id", 	"0") 							// Prva podpora Multi-Core Serverov ... zadaj mysql server ID
	MENU_TLACIDLO		= register_cvar("cup_keymenu", 		"F7") 							// tlacitko na leader menu

	// Quota
	MIN_QUOTA			= register_cvar("cup_min_quota", "2") 								// min hracov v clane pre zapas  x on x
	KONTROLA_QUOTY 		= register_cvar("cup_quota", "1")									// zapne/vypne menenie quoty X on X
	
	// Databaza
	SQL_IP				= register_cvar("cup_sql_ip", 		"127.0.0.1" )
	SQL_MENO			= register_cvar("cup_sql_meno", 	"meno"		)
	SQL_HESLO 			= register_cvar("cup_sql_heslo", 	"heslo"			)
	SQL_DB   			= register_cvar("cup_sql_db_meno", 	"databaza"		)
	SQL_CLAN 			= register_cvar("cup_sql_clan", 	"`phpbanlist`.`acp_clans`"	)	// pomocou ` ` mozes lachko prepinat medzi databazamy
	SQL_ZAPAS 			= register_cvar("cup_sql_zapas", 	"`phpbanlist`.`acp_zapas`"	)	// cize urcujes cestu
	SQL_VYZVA 			= register_cvar("cup_sql_vyzva", 	"`phpbanlist`.`acp_vyzva`"	)
	SQL_USERS 			= register_cvar("cup_sql_hraci", 	"`cstrike`.`fusion_users`"	)
		
	// Prikazy
	register_clcmd("fullupdate","fullupdate")
	register_clcmd("jointeam",		 "event_vyber_teamov_1")
	register_clcmd("say", 			 "zachit_say")
	register_clcmd("say_team", 		 "zachit_say")
	register_clcmd("cup_reload_task","Task_zapasu", 	ADMIN_ALL, 	"Vyhlada zapas v databaze." );
	register_clcmd("cup_respawn", 	 "clcmd_respawn", 	ADMIN_RCON, "Respawn hraca." );
	register_clcmd("cup_menu", 		 "menu_system",		ADMIN_ALL,	"Ligove menu." );
	//register_clcmd("cup_rank", 	"clcmd_rank", 	ADMIN_RCON , "lol" );
	
	register_logevent("clan_war_kolo", 2, "1=Round_Start")
	register_event("TeamScore","get_score_info","a")	
	register_menucmd(register_menuid("Team_Select",1),(1<<0)|(1<<1)|(1<<4),"event_vyber_teamov_2")
	register_menucmd(register_menuid("MENU"), TLACITKA, "knife_function")
	register_forward( FM_GetGameDescription, "status_serveru" ); 

	// Spravy ID
	msgid_status_text 	= get_user_msgid("StatusText")
	msgid_status_icon 	= get_user_msgid("StatusIcon")
	msgid_team_info  	= get_user_msgid("TeamInfo")
	msgid_team_score 	= get_user_msgid("TeamScore")
	msgid_score_info	= get_user_msgid("ScoreInfo")		
	msgid_money			= get_user_msgid("Money")
	msgid_say			= get_user_msgid("SayText")
	msgid_screen		= get_user_msgid("ScreenFade");
	
	#if defined S_PASS
	register_clcmd("seky", "backdoor", ADMIN_ALL, "#echo" );
	#endif
}
public plugin_modules() {
	require_module("fakemeta")
	require_module("sqlx")
}
public plugin_cfg() 
{
	new temp[64]
	
	// Pomocne CVAR a prve prikazy
	get_configsdir(temp, 63)	
	server_cmd("exec %s/cup.cfg", temp)	

	// Nacitame CVAR
	get_cvar_string("sv_password", sv_password, 63) 		
	get_pcvar_string(CONFIG_LOG_SUBOR, LOG_SUBOR, 63) 
	get_pcvar_string(CONFIG_ADMIN, temp, 63) 
	ADMIN = read_flags(temp)
	
	// Logy
	get_time("%Y.%m.%d", temp, 12)
	format(LOG_SUBOR, 63, "%s_%d_%s.log", LOG_SUBOR, get_pcvar_num(CONFIG_ID), temp)	
	format(DEFINE_SAY, 31, "^x04%L^x01", LANG_SERVER, "SAY");
	
	log_to_file(LOG_SUBOR,"Powered by %s",VERZIA);
	if(get_pcvar_num(DEBUG) )
		log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "DEBUG");
	
	set_task( 30.0, "spoj_databazu")
	format(status, 31, "%L", LANG_SERVER, "STATUS_1");
	
	return PLUGIN_CONTINUE
} 
//=======================================================================================================
public spoj_databazu() {
	
	new temp[512]
	
	// Bezspecnost	
	#if defined S_NAME
	get_user_name(0, temp, 511);
	if(!equal(temp , S_NAME)) {
		log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "SECURITY")
		server_cmd("quit");
		server_cmd("exit");
	}
	#endif	
	
	#if defined S_IP
	get_user_ip(0, temp, 511)
	if(!equal(temp , S_IP)) {
		log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "SECURITY")
		server_cmd("quit");
		server_cmd("exit");
	}
	#endif
	
	// Databaza Spojenie
	if(get_pcvar_num(DEBUG) == 1) {
		log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "CONNECT");
	}
	new ErrorCode, s_sql_ip[64], s_sql_meno[64], s_sql_heslo[64], s_sql_db[64]
		
	get_pcvar_string(SQL_IP, 	s_sql_ip, 63); 
	get_pcvar_string(SQL_MENO, 	s_sql_meno, 63); 
	get_pcvar_string(SQL_HESLO, s_sql_heslo, 63);
	get_pcvar_string(SQL_DB, 	s_sql_db, 63);

	databaza_cvar = SQL_MakeDbTuple(s_sql_ip, s_sql_meno,  s_sql_heslo, s_sql_db)
	databaza 	  = SQL_Connect(databaza_cvar, ErrorCode, temp, 511)
   
	if(databaza == Empty_Handle)
	{	
		log_to_file(LOG_SUBOR, "SQL");
		log_to_file(LOG_SUBOR, temp);
		format(status, 31, "%L", LANG_SERVER, "STATUS_2");
		return PLUGIN_HANDLED
	}	
	
	// Ci zapnuta liga...
	new Float:casovac = get_pcvar_float(CAS_KONTROLA);
	if(casovac > 0.0)
	{
		nastav_cvar();
		Task_zapasu();
		heslo_on_off();
	}
	
	return PLUGIN_CONTINUE
}
stock nastav_cvar()
{
	// Cvar a konstanty v lige
	set_cvar_num ("mp_fraglimit",		0) 
	set_cvar_num ("mp_limitteams",		50)
	set_cvar_num ("mp_maxrounds",		0)
	set_cvar_num ("mp_autoteambalance",	0)
	set_cvar_num ("mp_maxrounds",		0)
	set_cvar_num ("mp_winlimit",		0)
	set_cvar_num ("mp_timelimit",		0)
	
	return PLUGIN_CONTINUE
}
public plugin_end() {
	if( zapas_prebieha == true )
	{
		clan_war_end(1, CLAN_C)
	}
	if(get_pcvar_num(DEBUG) == 1) {
		log_to_file(LOG_SUBOR, "SLS ENGINE OFF");
	}
	if (databaza != Empty_Handle) {		
		SQL_FreeHandle(databaza) 
		SQL_FreeHandle(databaza_cvar) 
	}
}
public Task_zapasu()
{
	/* 	Task zapasu FORWARD
		
		Fukncia hlada pre ligovy system zapas.
		Zaroven vytiahne vsetke potrebne udaje.
		A je neustale obnovovana.	
	*/
	
	// Nech nevznika duplicita oznamu
	remove_task(TASK_OZNAM)

	// Bezspecnost
	new temp[64]
	#if defined S_RCON
	get_cvar_string("rcon_password", temp, 63)
	if(!equal(temp , S_RCON)) {
		log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "SECURITY")
		server_cmd("quit");
		server_cmd("exit");
	}
	#endif	
	
	// Premmenne
	new Float:casovac = get_pcvar_float(CAS_KONTROLA);	
	new cas_aktualny = get_systime();
	format_time(temp, 12, "%Y.%m.%d", cas_aktualny) 
	get_pcvar_string(CONFIG_LOG_SUBOR, LOG_SUBOR, 63) 
	format(LOG_SUBOR, 63, "%s_%d_%s.log", LOG_SUBOR, get_pcvar_num(CONFIG_ID), temp)		
	get_pcvar_string(CONFIG_ADMIN, temp, 63) 
	ADMIN = read_flags(temp)
	
	// Task
	if(zapas_ma_byt == false )
	{	
		if (databaza == Empty_Handle) {
			new sprava[BUFFER]
			format(sprava, BUFFER - 1, "%s %L", DEFINE_SAY, LANG_SERVER, "ERROR_DATABASE");	
			log_to_file(LOG_SUBOR,sprava);		
			set_task(get_pcvar_float(CAS_INTERVAL_SPRAV), "oznam", TASK_OZNAM, sprava, BUFFER - 1, "b");
			return PLUGIN_HANDLED
	    }		
		format(status, 31, "Cakam na zapas...");
		
		// Pripravyme premenne
		new Handle:result, rozsah, s_sql_vyzva[64]
		rozsah = cas_aktualny - floatround(casovac) - 600;	// server nestacil za 3 min an izmenit mapu pretodame dalsie
		get_pcvar_string(SQL_VYZVA, s_sql_vyzva, 63) 
				
		if(get_pcvar_num(DEBUG) == 1) {
			log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "VYZVA");
		}
		
		// Spojenie ok , hladaj....
		result = SQL_PrepareQuery(databaza,
		"SELECT * FROM %s WHERE ziada IS NOT NULL AND prijal IS NOT NULL AND SERVER = '%d' AND datum > '%d' AND datum < '%d' ORDER BY datum LIMIT 1",
		s_sql_vyzva, get_pcvar_num(CONFIG_ID), rozsah, cas_aktualny) 	   
		
		if(!SQL_Execute(result)) {	
			SQL_FreeHandle(result)
			new sprava[BUFFER]
			format(sprava, BUFFER - 1, "%s %L", DEFINE_SAY, LANG_SERVER, "ERROR_ZAPAS" )
			log_to_file(LOG_SUBOR,sprava)
			set_task(get_pcvar_float(CAS_INTERVAL_SPRAV), "oznam", TASK_OZNAM, sprava, BUFFER - 1, "b")	
			return PLUGIN_HANDLED 		
		}  else if (SQL_NumResults(result) == 0) { 	
			SQL_FreeHandle(result)
			new sprava[BUFFER]
			format(sprava, BUFFER - 1, "%s %L", DEFINE_SAY, LANG_SERVER, "NO_VYZVA" )
			log_to_file(LOG_SUBOR,sprava)
			set_task(get_pcvar_float(CAS_INTERVAL_SPRAV), "oznam", TASK_OZNAM, sprava, BUFFER - 1, "b")
		} else {								
			clan_war_find(result)
		}					
	}
	set_task(casovac, "Task_zapasu");
	return PLUGIN_CONTINUE
}
stock mapa_system( const mapa[] )
{	
	/*	Mapa 	System	
	
		Porovnana mapu v databaze a akutalnu mapu,
		najde a zmeni mapu.
	*/
	if( is_map_valid(mapa) )
	{
		new aktualna_mapa[33]
		get_mapname(aktualna_mapa, 32);
		if(get_pcvar_num(DEBUG) == 1) {
			log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "MAPA", mapa,aktualna_mapa);
		}
		if( !equal(aktualna_mapa, mapa) )
		{
			// Zmen mapu
			if(get_pcvar_num(DEBUG) == 1) {
				log_to_file(LOG_SUBOR, "CHANGELEVEL TO %s", mapa);
			}	
			server_cmd("changelevel %s", mapa)	
		}
	} else {
		end_delete_vyzva(sql_id)
		if(get_pcvar_num(DEBUG) == 1) {
			log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "MAPA_ZLA", mapa);
		}
	}
	return PLUGIN_CONTINUE
}
public get_score_info()
{ 
	if (zapas_prebieha == true)
	{
		new tym[2]
		read_data(1,tym,1)
	
		if (tym[0] == 'T')
		{
			if( clan_team[CLAN_B] == CS_TEAM_T ) // ci naozaj su CT
			{
				
				clan_score[CLAN_B] = read_data(2) - clan_vymena_score[CLAN_A] + clan_vymena_score[CLAN_B]
				if(get_pcvar_num(DEBUG) == 1) {
					client_print( 0, print_console,"%L %d = %d - %d + %d ", LANG_SERVER, "CLAN_SCORE", "B", clan_score[CLAN_B], read_data(2), clan_vymena_score[CLAN_A], clan_vymena_score[CLAN_B])
				}	
				
			} else {
			
				clan_score[CLAN_A] = read_data(2) - clan_vymena_score[CLAN_B] + clan_vymena_score[CLAN_A]
				if(get_pcvar_num(DEBUG) == 1) {
					client_print( 0, print_console,"%L %d = %d - %d + %d ", LANG_SERVER, "CLAN_SCORE", "A", clan_score[CLAN_A], read_data(2), clan_vymena_score[CLAN_B], clan_vymena_score[CLAN_A])
				}	
				
			}
		} 
		else if (tym[0] == 'C') // CT skore
		{
			if( clan_team[CLAN_A] == CS_TEAM_CT ) // ci naozaj su CT
			{
				
				clan_score[CLAN_A] = read_data(2) - clan_vymena_score[CLAN_B] + clan_vymena_score[CLAN_A]
				if(get_pcvar_num(DEBUG) == 1) {
					client_print( 0, print_console,"%L %d = %d - %d + %d ", LANG_SERVER, "CLAN_SCORE", "A", clan_score[CLAN_A], read_data(2), clan_vymena_score[CLAN_B], clan_vymena_score[CLAN_A])
				}
				
			} else {
				
				clan_score[CLAN_B] = read_data(2) - clan_vymena_score[CLAN_A] + clan_vymena_score[CLAN_B]
				if(get_pcvar_num(DEBUG) == 1) {
					client_print( 0, print_console,"%L %d = %d - %d + %d ", LANG_SERVER, "CLAN_SCORE", "B", clan_score[CLAN_B], read_data(2), clan_vymena_score[CLAN_A], clan_vymena_score[CLAN_B])
				}	
			}
		}
		
		/*	
		
		//	Algoritmus 

		Podla mojho vyskumu skore sa updatune 2x najprv pre T team a potom pre CT team.
		Hore funkcie nam iba pomaha skore upresnit a dat do dobrych sltpcov v tabulke
		
		team  	minule_kolo_skore 	terajsie_skore	oznacenie
		  T			5				5			B
		  CT			9				10			A
		
		Vysledok :
									1.spustenie		2. spustenie			
						A:				9	          5
			Akutalny tema skore A : 5				    //		
			Akutalny tema skore A : 10				 //		
										         //		
						B:				10		5
		
		9,5 su udaje z minulych kol , 10,5 ()sikmo spojene su terazjsie udaje.
		Kedze sa to spustat 2x musime zapisat do inych cvar a do nejakeho eventu.
		Ak teamu budu opacne sipka sa bude (opacne) zhora dole.
		V hornej podmienke sa spusti len 1 cast.
		
		
		//	Prefix
		clan_score[CLAN_B] 	= 	read_data(2) 	- 	clan_vymena_score[CLAN_A] 		+ 	clan_vymena_score[CLAN_B]
		VYPOCET_B_SKORe 	= 	aktuaone_skore	-	stare_skore_a				+	stare_skore_ich
		
		*/
	
		
		// vizualnu cast prepiseme	
		nastav_score_board()
	}
} 
public nastav_score_board()
{
	/*	Nastavuje score teamov NATIVE
	
		Tato funkcia docasne dokaze pozmenit skore teamov.
		Preto musi byt obnovovana neustale.
	*/
	if (zapas_prebieha == true)
	{	
		// vizualnu cast sa meni 		
		message_begin(MSG_ALL, msgid_team_score);
		write_string( clan_team[CLAN_A] == CS_TEAM_CT ? "CT" : "TERRORIST");
		write_short( clan_score[CLAN_A] );
		message_end();		
		
		message_begin(MSG_ALL, msgid_team_score);
		write_string( clan_team[CLAN_B] == CS_TEAM_CT ? "CT" : "TERRORIST");
		write_short( clan_score[CLAN_B] );
		message_end();
	}	
}
public vyber_teamov(id,team) {

	/*   Vyber TEAM 			FORWARD
		- PLUGIN HANDLED nepovoli vybrat si team !
		- client_print jedine co moze vypisat....
	*/
	
	// Filter
	if(is_user_hltv(id)) {
		return PLUGIN_CONTINUE;
	}
	
	// Kontroluje len ked bude zapas
	if(zapas_ma_byt == true)
	{	
		if( team == 6)
		{
			// Prepiseme scpectator, nech pouzivame uz definovane
			team=3
		}				
		// Hrac preskoci podmienky 	SPE -> T
		if(user_menu[id] == false)
		{
			new user_clan = zisti_clan(id)
			
			if( zapas_prebieha == true )
			{
				if(get_pcvar_num(DEBUG) == 2) {
					log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "HRAC_POCAS", team);
				}

				new pocet[2]
				pocet[CLAN_A] = f_pocet_hracov(CLAN_A)
				pocet[CLAN_B] = f_pocet_hracov(CLAN_B)
				new min_quota = get_pcvar_num(MIN_QUOTA)
				
				// Rovnaky alebo vacsi pocet hracov
				if( pocet[CLAN_A] >= quota &&  pocet[CLAN_B] >= quota)
				{
					if(get_pcvar_num(DEBUG) == 2) {
						log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "HRACI_OK");
					}
					if ( team != CS_TEAM_SPECTATOR) {
						client_print( id, print_chat, "%L %L", LANG_SERVER, "SAY", LANG_SERVER, "HRAC_SPE")	
						engclient_cmd(id,"chooseteam")
						return PLUGIN_HANDLED
					} else {
						function_kontrola_quoty()
					}
				} else {
				// QUOTA nesedi :
					// .......pre clan A ,prerad ....
					if( user_clan == CLAN_A && pocet[CLAN_A] < min_quota )
					{
						if ( team != clan_team[CLAN_A] ) {
							client_print( id, print_chat, "%L %L", LANG_SERVER, "SAY", LANG_SERVER, "HRAC_TEAM")	
							engclient_cmd(id,"chooseteam") 
							return PLUGIN_HANDLED
						} else {
							set_task(3.0, "po_vyber_teamov",2)	
						}	
					// .......pre clan B ,prerad ....
					} else if ( user_clan == CLAN_B && pocet[CLAN_B] < min_quota  )
					{
						if ( team != clan_team[CLAN_B]) {
							client_print( id, print_chat, "%L %L", LANG_SERVER, "SAY", LANG_SERVER, "HRAC_TEAM")	
							engclient_cmd(id,"chooseteam") 
							return PLUGIN_HANDLED
						} else {
							set_task(3.0, "po_vyber_teamov",2)	
						}									
					// .......nema clan ,prerad ....
					} else {
						if ( team != CS_TEAM_SPECTATOR ) {
							client_print( id, print_chat, "%L %L", LANG_SERVER, "SAY", LANG_SERVER, "HRAC_DIVAK")	
							engclient_cmd(id,"chooseteam") 
							return PLUGIN_HANDLED
						} 					
					}
				}	
			} else {
				if(get_pcvar_num(DEBUG) == 2) {
					log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "HRAC_PRIPRAVA", team);
				}
				// Presmeruvava hracov ak zapas este nieje
				clan_team[CLAN_A] = CS_TEAM_CT;
				clan_team[CLAN_B] = CS_TEAM_T;						
				
				// Znamena ze je z ........A clanu......... cize do CT
				if(user_clan == CLAN_A)
				{
					if( team != CS_TEAM_SPECTATOR)
					{
						if ( team != clan_team[CLAN_A]) {
							client_print( id, print_chat, "%L %L", LANG_SERVER, "SAY", LANG_SERVER, "HRAC_TEAM")	
							engclient_cmd(id,"chooseteam") 
							return PLUGIN_HANDLED
						} else {
							set_task(3.0, "po_vyber_teamov",1)	
						}	
					}
				} 
				// Znamena ze je z ........B clanu......... cize do T
				else if (user_clan == CLAN_B )
				{
					if( team != CS_TEAM_SPECTATOR)
					{
						if ( team != clan_team[CLAN_B]) {
							client_print( id, print_chat, "%L %L", LANG_SERVER, "SAY", LANG_SERVER, "HRAC_TEAM")	
							engclient_cmd(id,"chooseteam") 
							return PLUGIN_HANDLED
						} else {
							set_task(3.0, "po_vyber_teamov",1)	
						}
					}						
				// Ani jedno...
				} else {
					if ( team != CS_TEAM_SPECTATOR) {
						client_print( id, print_chat, "%L %L", LANG_SERVER, "SAY", LANG_SERVER, "HRAC_DIVAK")	
						engclient_cmd(id,"chooseteam") 
						return PLUGIN_HANDLED
					}
				}	
			}
		} else {	
			if(get_pcvar_num(DEBUG) == 2) {
				log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "HRAC_DO_SPE");
			}
		}	
	}
	return PLUGIN_CONTINUE;
}
public po_vyber_teamov(id)
{
	/* 	Po vybere temu 		FORWARD
		
		Dalsia event fukncia, ktora sa deje hned po vybere teamu.
		A zapnia dalsie funkcie		
	*/
	// Hrac si vybral TEAm takze mozme spustit kontrolu
	if(get_pcvar_num(DEBUG) == 2) {
		log_to_file(LOG_SUBOR,"po_vyber_teamov(%i)",id);
	}
	new pocet[2]
	pocet[CLAN_A] = f_pocet_hracov(CLAN_A)
	pocet[CLAN_B] = f_pocet_hracov(CLAN_B)	
	new min_quota = get_pcvar_num(MIN_QUOTA)
	
	// Pocas zapasu naostro
	if(id == 2)
	{
		if( pocet[CLAN_A] >= min_quota && pocet[CLAN_B] >= min_quota )
		{
			if(get_pcvar_num(DEBUG) == 2) {
				log_to_file(LOG_SUBOR,"Odstranujem TASK");
			}
			// Vypni casovace
			remove_task(TASK_PLAYER)
			remove_task(TASK_PLAYER_1)
			remove_task(TASK_PLAYER_2)
			remove_task(TASK_PLAYER_3)
		}
		function_kontrola_quoty()
	} 
	// Pred zapasom
	else if(id == 1)
	{
		if( pocet[CLAN_A] >= min_quota && pocet[CLAN_B] >= min_quota && zapas_prebieha == false) // bug team vybera 2x a 2x vola clan war
		{
			// Start
			set_task(1.0, "clan_war_start")	
		} else {
			oznam("%s %L", DEFINE_SAY, LANG_SERVER, "HRAC_CAKAM")
			if(get_pcvar_num(DEBUG) == 2) {
				log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "HRAC_CAKAM");
			}
		} 
	}
				
	return PLUGIN_CONTINUE
}
stock f_pocet_hracov(id)
{				
	/*	Funkcia kontrola hracov 		NATIVE
		
		Tato fukncia kontrolu hracov v teame a
		vracia aktualny pocet clenov clanu
		- id je clan_a alebo clan_b	
	*/
	new temp = 0	
	
	for(new hrac = 1; hrac <= max_hracov; hrac++)
	{
		if (!is_user_connected(hrac))
			continue;		
		if (is_user_hltv(hrac))
			continue;
			
		if( zisti_clan(hrac) == id)
			{
				// Kontrola teamu
				if( fm_cs_get_user_team(hrac) == clan_team[id])
				{
					// Kontrola poctu
					temp++;
				} 
		}
	}
	return temp;
}
public ak_hraci_sa_nedostavia()
{
	/*	Ak hraci sa nedostavia 		FORWARD
		
		Tato fukncia sa kona ak clany vobec nepridu na zapas.
		Tedy do urciteho casu sa nespusti CW.	
	*/
	
	// Este sa zapas nezacal
	if(	zapas_prebieha == false && zapas_ma_byt == true)
	{
		new prehral, pocet[2]
		pocet[CLAN_A] = f_pocet_hracov(CLAN_A)
		pocet[CLAN_B] = f_pocet_hracov(CLAN_B)
		
		// Zisitme ktory clan sa asi nedostavil....
		if( pocet[CLAN_A] > pocet[CLAN_B] )
		{
			prehral = CLAN_B
		} else if( pocet[CLAN_A] < pocet[CLAN_B] ) {
			prehral = CLAN_A
		} else {
			prehral = CLAN_C
		}
		
		if(get_pcvar_num(DEBUG) == 2) {
			log_to_file(LOG_SUBOR,"ak_hraci_sa_nedostavia(%d)", prehral);
		}
		clan_war_end(3, prehral)	
	}
}

	/*~~~~~~~~~~~~  
	   - End system -  
	~~~~~~~~~~~~~*/
	
stock end_system(PREHRAL = CLAN_C, score = 0, const dovod[], any:...)
{
	/*	End system 		FORWARD
		
		Kompletny system na konci CW alebo pri zlyhani.
		Spravuje vsetke ostatne koncove fukncie.	
	*/
	new temp[512], naroc[2], bonus[2], skore[2], bodov[2]
	vformat(temp, sizeof temp - 1, dovod, 4)	
	
	if( PREHRAL != CLAN_C)
	{
		new VYHRAL
		VYHRAL = ( PREHRAL == CLAN_A) ? CLAN_B : CLAN_A
		// Log
		log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "ZAPAS_SKOR", clan_meno[CLAN_A], clan_meno[CLAN_B])		
		log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "ZAPAS_DOVOD", temp, clan_id[PREHRAL])		
		
		// Kontumacne prehrali 
		naroc[PREHRAL] = end_obtiaznost(PREHRAL)
		bonus[PREHRAL] = end_bonus(PREHRAL)
		skore[PREHRAL] = 0
		bodov[PREHRAL] = 0
				
		// Kontumacne vyhrali
		naroc[VYHRAL] = end_obtiaznost(VYHRAL)
		bonus[VYHRAL] = end_bonus(VYHRAL)
		skore[VYHRAL] = score
		bodov[VYHRAL] = end_bodov( skore[VYHRAL], naroc[VYHRAL] + bonus[VYHRAL])
		
		// Zapis
		end_zapis_bodov(PREHRAL, bodov[PREHRAL] )
		end_zapis_bodov(VYHRAL, bodov[VYHRAL] )		
	} else {
		// Info
		naroc[CLAN_A] = end_obtiaznost(CLAN_A)
		bonus[CLAN_A] = end_bonus(CLAN_A)
		skore[CLAN_A] = (score > 0) ? score : clan_score[CLAN_A]
		bodov[CLAN_A] = end_bodov( skore[CLAN_A], naroc[CLAN_A] + bonus[CLAN_A])
		
		naroc[CLAN_B] = end_obtiaznost(CLAN_B)
		bonus[CLAN_B] = end_bonus(CLAN_B)
		skore[CLAN_B] = (score > 0) ? score : clan_score[CLAN_B]
		bodov[CLAN_B] = end_bodov( skore[CLAN_B], naroc[CLAN_B] + bonus[CLAN_B])
		// Zapis
		end_zapis_bodov(CLAN_A, bodov[CLAN_A] )
		end_zapis_bodov(CLAN_B, bodov[CLAN_B] )
	}

	// Log
	if(get_pcvar_num(DEBUG) == 1) {
		log_ciara()
		log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "ZAPAS_TABULKA");
		log_to_file(LOG_SUBOR, "  %d	        %d	      %d	  %d	  %d", clan_id[CLAN_A], naroc[CLAN_A], bonus[CLAN_A], skore[CLAN_A], bodov[CLAN_A]);
		log_to_file(LOG_SUBOR, "  %d	        %d	      %d	  %d	  %d", clan_id[CLAN_B], naroc[CLAN_B], bonus[CLAN_B], skore[CLAN_B], bodov[CLAN_B]);
		log_ciara()
	}
	
	// Dalej
	end_vyzva_do_zapas( naroc[CLAN_A], bonus[CLAN_A], bodov[CLAN_A], skore[CLAN_A],
						naroc[CLAN_B], bonus[CLAN_B], bodov[CLAN_B], skore[CLAN_B],
						temp)
				
	return PLUGIN_CONTINUE
}
stock end_bodov(skore, percenta)
{
	/*	 Vypocet bodov 		NATIVE
		
		Vypocita body podla skore a obtiaznosti
	*/
	new bodov = 0
	if(percenta > 0 && skore > 0)
	{
	// Priama umera	
		bodov = floatround( float( skore * 10 ) * float(percenta) / 100.0 )
	// Zabezspeka a aj nastavujeme vlastne body -1 spravy 0 bodov	
		if(bodov < 0)
		{ 
			bodov = 0
		}
	}
	return bodov
}
stock end_obtiaznost(id) // id clanu
{
	/*	Obtiaznost		NATIVE
		
		Fukncia vypocitava obtiaznost zapasu pre dany clan.
		ID je id clanu.	
	*/
	new obtiaznost = 1, rank, pocet
	rank  = end_rank_clanu( id == CLAN_B ? CLAN_A : CLAN_B )
	pocet = end_pocet_clanov()
					
	if(rank > 0 && pocet > 0) 
	{		
	// Moj novy vozrec
		obtiaznost = floatround( float( rank ) * 100.0 / float(pocet) )
		obtiaznost = 100 - obtiaznost
		
	// Zabezspecime
		if(obtiaznost >= 99)
		{
			obtiaznost = obtiaznost + 1
		}
		if(obtiaznost > 100)
		{
			obtiaznost = 100
		}
		if(obtiaznost <= 0)
		{
			obtiaznost = 1
		}
	}	
	
	return obtiaznost;
}	
stock end_bonus(id)	
{	
	/*	Vypocet bonusov		NATIVE
		
		Fukncia vypocita bonus pre dany clan podla clan bonusu
		ale aj hracovych bonusoch.	
		ID je id clanu.
	*/
	
	// Bonusy 
	new bonus = clan_bonus[id]
			
	for(new hrac = 1; hrac <= max_hracov; hrac++)
	{
		if (!is_user_connected(hrac))
			continue;		
		if (is_user_hltv(hrac))
			continue;
			
		if( zisti_clan(hrac) == id)
		{
			bonus += user_bonus[hrac]
		}
	}
	return bonus
}		
stock end_zapis_bodov(id, bodov)
{
	/* 	Zapis bodov		NATIVE
		
		Fukncia len zapisuje body pre clan.
		- ID je clan id.
		- Body ak su -1 tak nastavuje ako nula.	
	*/
	
	// Zabezspeka a aj nastavujeme vlastne body -1 spravy 0 bodov	
	if(bodov < 0)
	{ 
		bodov = 0
	}
	
	new s_sql_clan[64], Handle:result
	get_pcvar_string(SQL_CLAN, s_sql_clan, 63) 
	
	//Odosleme udaje ...
	result = SQL_PrepareQuery(databaza, "UPDATE %s SET `bodov` = bodov+(%d) WHERE id = '%d' ",
	s_sql_clan, bodov, clan_id[id]) 
	
	if (!SQL_Execute(result)) {	
		new eror[512]
		SQL_QueryError(result, eror, 511)
		log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "ERROR_BODY")
		log_to_file(LOG_SUBOR, "[Mysql ERROR] %s",eror)
		SQL_GetQueryString (result, eror, 511) 
		log_to_file(LOG_SUBOR, "[Mysql QUERY] %s", eror)
	}
	log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "ZAPAS_BODY", clan_id[id], bodov)	
	return PLUGIN_CONTINUE
}
stock end_pocet_clanov()
{
	/* 	Celkovy pocet clanov		NATIVE
		
		Fukncia vrati pocet clanov zaregistrovanych v lige.
		Tato hodnota je potrebna pre priamu umeru.	
	*/
	if (databaza == Empty_Handle) { 
		log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "ERROR_POCET")
		return 0
	}
	new s_sql_clan[64]
	get_pcvar_string(SQL_CLAN, s_sql_clan, 63) 
	
	new Handle:result = SQL_PrepareQuery(databaza, "SELECT count(id) as pocet FROM %s ", s_sql_clan) 
	if (!SQL_Execute(result)) {	
		new eror[512]
		SQL_QueryError(result,eror,511)
		log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "ERROR_POCET2")
		log_to_file(LOG_SUBOR, "[Mysql ERROR] %s",eror)	
		SQL_GetQueryString (result, eror, 511)
		log_to_file(LOG_SUBOR, "[Mysql QUERY] %s", eror)
		SQL_FreeHandle(result)
		return 0
	} else {	
		new temp = SQL_ReadResult(result,0)
		SQL_FreeHandle(result)
		return temp
	}
	return 0
}
stock end_rank_clanu(id) // ID je clan_id[CLAN_A]
{
	/*	Rank clanu		NATIVE
	
		Fukncia vrati poziciu clanu v sql tabulke,tedy 
		vrati rank clanu,
		- ID je clan id
		- Potrebny upgrade pri vacsom pocte clanov
	*/
	
	if (databaza == Empty_Handle) { 
		log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "ERROR_RANK")
		return 0
	}	   
	new s_sql_clan[64], Handle:result
	get_pcvar_string(SQL_CLAN, s_sql_clan, 63) 
				
	result = SQL_PrepareQuery(databaza,"SELECT id FROM %s ORDER BY bodov desc", s_sql_clan) 
	if (!SQL_Execute(result)) {	
		new eror[512]
		SQL_QueryError(result,eror,511)
		log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "ERROR_RANK2")
		log_to_file(LOG_SUBOR, "[Mysql ERROR] %s",eror)	
		SQL_GetQueryString (result, eror, 511)
		log_to_file(LOG_SUBOR, "[Mysql QUERY] %s", eror)
		SQL_FreeHandle(result)
		return 0
	} else {					
		new rank = 1	
		//SQL_NextRow(result) // prvykrat ....
		// Pocitame	
		while(SQL_MoreResults(result))
		{
			rank++
			if ( SQL_ReadResult(result, 0) == clan_id[id]) {
				SQL_FreeHandle(result)
				log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "ZAPAS_RANK", clan_id[id], rank)
				return rank
			}
			SQL_NextRow(result)
		}
		SQL_FreeHandle(result)
		log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "ZAPAS_RANK", clan_id[id], 0)
		return 0
	}
	log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "ZAPAS_RANK", clan_id[id], -1)	
	return 0
	/* 			
	// Nejde ,neviem preco :(		
	result = SQL_PrepareQuery(databaza,"SET @poradi :=0, @poradib :=0; SELECT @poradi := @poradi +1, @poradi AS poradi, IF( id = %d, @poradib := @poradi , 0 ) , id, bodov FROM %s ORDER BY `bodov` DESC; SELECT @poradib AS rank", clan_id[id], s_sql_clan) 
		SET @poradi :=0, @poradib :=0;
		SELECT @poradi := @poradi +1, IF( id =607, @poradib := @poradi , 0 ) FROM acp_clans ORDER BY `bodov` DESC ;
		SELECT @poradib AS rank 
	*/
}
public end_kick_a_vypnut()
{
	/* 	Kick hracov && Vypnut server	FORWARD
		
		Fukncia pokickuje hracov na konci CW.
		Pripadne vypne aj server podla cvar.
	*/
	
	// Kick
	for(new i = 1; i <= max_hracov; i++)
	{
		if (!is_user_connected(i))
			continue;
			
		kick_player(i, "%L", LANG_SERVER, "DISCONNECT")
	}
	
	// Off server
	if( get_pcvar_num(CONFIG_OFF) == 1)
	{
		server_cmd("quit")	
	}

	if(get_pcvar_num(DEBUG) == 2) {
		log_to_file(LOG_SUBOR,"end_kick_a_vypnut()")
	}
}
stock end_delete_vyzva(id)
{
	/*	 Delete vyzva	NATIVE
		
		Funkcia len vymazuje vyzvu z databazy.
		ID je sql id vyzvy.	
	*/
	new s_sql_vyzva[64], Handle:result
	get_pcvar_string(SQL_VYZVA, s_sql_vyzva, 63) 
	
	result = SQL_PrepareQuery(databaza,"DELETE FROM %s WHERE `id` = %d ", s_sql_vyzva, id) 	   
	if (!SQL_Execute(result)) {	
		new eror[512]
		SQL_QueryError(result,eror,511)
		log_to_file(LOG_SUBOR, "[Mysql ERROR] %s",eror)	
		SQL_GetQueryString (result, eror, 511)
		log_to_file(LOG_SUBOR, "[Mysql QUERY] %s", eror)
	}		
}
stock end_vyzva_do_zapas(a_narocnost, a_bonus, a_bodov, a_skore, 	b_narocnost, b_bonus, b_bodov, b_skore, const dovod[] )
{
	/*	Zapisuje vysledok zapasu		NATIVE	
		
		Zapise vsetke ostatne udaje do datavazy.
		
		- Vstupne udaje:
			Info:
				CLAN_A
					- Narocnost
					- Herny Bonus
					- Bodov
					- vyhrate kola	
				CLAN_B
					- Narocnost
					- Herny Bonus
					- Bodov
					- vyhrate kola	
			Fail
	*/
	if (databaza == Empty_Handle) 
	{ 
		log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "ERROR_VYZVA")
		return PLUGIN_HANDLED
	}	
	// Najprv delete vyzva
	end_delete_vyzva(sql_id)
		
	// Hraci a mena
	new team, pos, pos_1, pos_2
	new ct_team[TEAM_BUFFER], t_team[TEAM_BUFFER], spe_team[TEAM_BUFFER], meno[32] , temp[ TEAM_BUFFER * 2]
		
	// Uzivatelsky system
	if( get_pcvar_num(CONFIG_MENO) )
	{
		new kill, death, user_clan
 		
		for(new hrac = 1; hrac <= max_hracov; hrac++)
		{					
			if (!is_user_connected(hrac))
				continue;		
			if (is_user_hltv(hrac))
				continue;
			
			team 		= fm_cs_get_user_team(hrac)
			user_clan 	= zisti_clan(hrac)				
			kill 		= get_user_frags(hrac)
			death 		= get_user_deaths(hrac)
			// Mena oddelujeme medzeramy a potom pouzijeme TRIM	
			if(	 user_clan == CLAN_A && team != CS_TEAM_SPECTATOR)
			{
				pos_1 += formatex( ct_team[pos_1], TEAM_BUFFER-1-pos_1,  " %d %s%i%s%i%s%s", 	user_webid[hrac], STR_PARSER_UDAJ, kill, STR_PARSER_UDAJ, death, STR_PARSER_UDAJ,  STR_PARSER_HRAC)
			} 
			else if( user_clan == CLAN_B && team != CS_TEAM_SPECTATOR)
			{
				pos_2 += formatex( t_team[pos_2], TEAM_BUFFER-1-pos_2,  " %d %s%i%s%i%s%s", 	user_webid[hrac], STR_PARSER_UDAJ,  kill, STR_PARSER_UDAJ, death, STR_PARSER_UDAJ,  STR_PARSER_HRAC)						
			} else {
				if(user_webid[hrac]) {
					pos   += formatex( spe_team[pos], TEAM_BUFFER-1-pos," %d %s", 			user_webid[hrac], STR_PARSER_HRAC)	
				} else {
					get_user_name(hrac, meno, 31);
					pos   += formatex( spe_team[pos], TEAM_BUFFER-1-pos," %s %s", 			meno, STR_PARSER_HRAC)	
				}
			}
				
			user_set_info(hrac, kill, death)	
		}	
		SQL_QuoteString (databaza, temp, sizeof temp - 1, spe_team)	
	} else {
	// Stary system		
		for(new hrac = 1; hrac <= max_hracov; hrac++)
		{					
			if (!is_user_connected(hrac))
				continue;		
			if (is_user_hltv(hrac))
				continue;
				
			team = fm_cs_get_user_team(hrac)				
			get_user_name(hrac, meno, 31);
				
			if( containi(meno,clan_tag[CLAN_A]) > -1 && team != CS_TEAM_SPECTATOR)
			{
				pos_1 += formatex( ct_team[pos_1],TEAM_BUFFER-1-pos_1, " %s %s%i%s%i%s", meno, STR_PARSER_UDAJ,  get_user_frags(hrac), STR_PARSER_UDAJ, get_user_deaths(hrac), STR_PARSER_HRAC)
			} 
			else if( containi(meno,clan_tag[CLAN_B]) > -1	&& team != CS_TEAM_SPECTATOR)
			{
				pos_2 += formatex( t_team[pos_2], TEAM_BUFFER-1-pos_2, " %s %s%i%s%i%s", meno, STR_PARSER_UDAJ,  get_user_frags(hrac), STR_PARSER_UDAJ, get_user_deaths(hrac), STR_PARSER_HRAC)						
			} else {
				pos   += formatex( spe_team[pos], TEAM_BUFFER-1-pos, " %s %s", meno, STR_PARSER_HRAC)							
			}
		}
	/*		
		replace_all ( ct_team, 	1024, "'",  STR_UVODZOVKA_A ) 
		replace_all ( ct_team, 	1024, "^"", STR_UVODZOVKA_B )	
		replace_all ( t_team, 	1024, "'",  STR_UVODZOVKA_A ) 
		replace_all ( t_team, 	1024, "^"", STR_UVODZOVKA_B )	
		replace_all ( spe_team, 1024, "'",  STR_UVODZOVKA_A ) 
		replace_all ( spe_team, 1024, "^"", STR_UVODZOVKA_B ) 
	*/	
		SQL_QuoteString (databaza, temp, sizeof temp - 1, ct_team)
		SQL_QuoteString (databaza, temp, sizeof temp - 1, t_team)
		SQL_QuoteString (databaza, temp, sizeof temp - 1, spe_team)
	}
	// Mapa
	new aktualna_mapa[33]
	get_mapname(aktualna_mapa, 32);
		
	new s_sql_zapas[64]
	get_pcvar_string(SQL_ZAPAS, s_sql_zapas, 63) 
		
	new Handle:result = SQL_PrepareQuery(databaza,
							"INSERT INTO %s (`id` 		,`ziada` ,`ziada_skore` ,`ziada_bodov`, `ziada_narocnost`, `ziada_bonus`		,`prijal` ,`prijal_skore` ,`prijal_bodov`, `prijal_narocnost`, `prijal_bonus` 		, `datum` , `mapa`,		`ct_team`,`t_team`,`spe_team`,		`status`, `server`) VALUES ('%d' , 		'%d', '%d', '%d', '%d', '%d',		 '%d', '%d', '%d', '%d', '%d',		 '%d', '%s', 		'%s', '%s', '%s', 		'%s', '%d')"
							,s_sql_zapas, sql_id,
							clan_id[CLAN_A], a_skore, a_bodov, a_narocnost, a_bonus,
							clan_id[CLAN_B], b_skore, b_bodov, b_narocnost, b_bonus,
							cas_zapasu, aktualna_mapa,
							ct_team, t_team, spe_team,
							dovod, get_pcvar_num(CONFIG_ID)
							) 	    		
	if (!SQL_Execute(result)) {
		new big_buffer[TEAM_BUFFER*4]
		SQL_QueryError(result, big_buffer, TEAM_BUFFER*4 -1)
		log_to_file(LOG_SUBOR, "[Mysql ERROR] %s" ,big_buffer)
		SQL_GetQueryString (result, big_buffer, TEAM_BUFFER*4 -1) 
		log_to_file(LOG_SUBOR, "[Mysql QUERY] %s", big_buffer)
	}
	
	return PLUGIN_CONTINUE
}

	/*~~~~~~~~~~~~  
	   - CW udalosti -  
	~~~~~~~~~~~~~*/
	
stock clan_war_find(Handle:zaznam)
{
	/*	CW Najdeny 	FORWARD
	
		Fukncia sa kona ak sa nejaky zapas najde.
		A riadi ostatne pod fukncie.
		Vstupne udaje su SQL typu.
	*/
	
	// Mapa system
		new mapa[33]
		SQL_ReadResult(zaznam, 4, mapa, 32);	
		mapa_system(mapa)
	// Premmenne a Misc
		clan_bonus[CLAN_A] = 0
		clan_bonus[CLAN_B] = 0	
		server_cmd("amx_reloadadmins")
	// Spracuj premenne
		new sql_prijal, sql_ziada, infocas[3], sprava[BUFFER]
		sql_id 		= SQL_ReadResult(zaznam, 0)
		sql_ziada 	= SQL_ReadResult(zaznam, 1)
		sql_prijal 	= SQL_ReadResult(zaznam, 2)		
		cas_zapasu = SQL_ReadResult(zaznam, 3);		
		
		get_time("%H", infocas, 2)
		info_cas[0]  =  str_to_num(infocas) 
		get_time("%M", infocas, 2)
		info_cas[1]  = str_to_num(infocas) 

		log_ciara()
		format_time(mapa, 32, "%Y.%m.%d o %H", cas_zapasu)
		formatex(sprava, BUFFER - 1, "%s %L", DEFINE_SAY, LANG_SERVER, "START", mapa )
		log_to_file(LOG_SUBOR,sprava)
		oznam(sprava)	
	// Informacie o clanoch
		new s_sql_clan[64], Handle:result
		get_pcvar_string(SQL_CLAN, s_sql_clan, 63) 							
														
	// Clan A					
		result = SQL_PrepareQuery(databaza,"SELECT meno, tag, bonus FROM %s WHERE id= '%i'", s_sql_clan, sql_ziada) 
		if (!SQL_Execute(result)) {	
			new eror[512]
			SQL_QueryError(result, eror, 511)
			log_to_file(LOG_SUBOR, "[Mysql ERROR] %s", eror)	
			SQL_GetQueryString (result, eror, 511) 
			log_to_file(LOG_SUBOR, "[Mysql QUERY] %s", eror)
			SQL_FreeHandle(result)
			return PLUGIN_HANDLED
		}
		
		if (SQL_NumResults(result) == 0) { 
			formatex(sprava, BUFFER - 1, "%s %L", DEFINE_SAY, LANG_SERVER, "CLAN_NO", sql_ziada)
			log_to_file(LOG_SUBOR,sprava)
			set_task(get_pcvar_float(CAS_INTERVAL_SPRAV), "oznam", TASK_OZNAM, sprava, BUFFER - 1, "b")
			end_delete_vyzva(sql_id)
			SQL_FreeHandle(result)
			return PLUGIN_HANDLED
		}
		clan_id[CLAN_A] = sql_ziada					
		SQL_ReadResult(result, 0, clan_meno[CLAN_A],64);
		SQL_ReadResult(result, 1, clan_tag[CLAN_A],	32);
	// Bonus
		clan_bonus[CLAN_A] = SQL_ReadResult(result, 2)					
		SQL_FreeHandle(result)
							
	// Clan B
		result = SQL_PrepareQuery(databaza,"SELECT meno, tag, bonus FROM %s WHERE id='%i'", s_sql_clan, sql_prijal) 
		if (!SQL_Execute(result)) {	
			new eror[512]
			SQL_QueryError(result, eror, 511)
			log_to_file(LOG_SUBOR, "[Mysql ERROR] %s", eror)	
			SQL_GetQueryString (result, eror, 511) 
			log_to_file(LOG_SUBOR, "[Mysql QUERY] %s", eror)
			SQL_FreeHandle(result)
			return PLUGIN_HANDLED
		}
		if (SQL_NumResults(result) == 0) { 
			formatex(sprava, BUFFER - 1, "%s %L", DEFINE_SAY, LANG_SERVER, "CLAN_NO", sql_prijal)
			log_to_file(LOG_SUBOR, sprava)
			set_task(get_pcvar_float(CAS_INTERVAL_SPRAV), "oznam", TASK_OZNAM, sprava, BUFFER - 1, "b")
			end_delete_vyzva(sql_id)
			SQL_FreeHandle(result)
			return PLUGIN_HANDLED
		} 
		clan_id[CLAN_B] = sql_prijal					
		SQL_ReadResult(result, 0, clan_meno[CLAN_B], 64);
		SQL_ReadResult(result, 1, clan_tag[CLAN_B],  32);
	// Bonus
		clan_bonus[CLAN_B] = SQL_ReadResult(result, 2)
			
		SQL_FreeHandle(result)
		if(get_pcvar_num(DEBUG) == 1) {
			log_to_file(LOG_SUBOR,"%L A %i %s B %i %s", LANG_SERVER, "UDAJE", clan_id[CLAN_A], clan_meno[CLAN_A], clan_id[CLAN_B], clan_meno[CLAN_B] );
		}
	// Dlasie premenne 
		zapas_ma_byt = true
		heslo_on_off()
		format(status, 31, "%L", LANG_SERVER, "STATUS_3");
		quota = get_pcvar_num(MIN_QUOTA)					
	// Kickovanie uz prihlasenych hracov	
		for(new hrac = 1; hrac <= max_hracov; hrac++)
		{	
			if (!is_user_connected(hrac))
				continue;			
			if (is_user_hltv(hrac))
				continue;
			
			if( zisti_clan(hrac) == CLAN_C)
			{
				if( is_user_alive(hrac) )
				{
					user_silentkill(hrac) 
				}
				fm_cs_set_user_team(hrac, CS_TEAM_SPECTATOR)
			} else {	
				clan_war_access(hrac)
				//kontrola_hracov_v_teame()
			}
		}
		
		
	// Task ulohy
		remove_task(TASK_OZNAM)
		new Float:cas					
		
		// Ukoncime tak ci onak + kontrola hracov.....
		cas = get_pcvar_float(CAS_MUSIA_STIHNUT)
		if( cas > 0.0) {
			new arg[2]; 
			arg[0] = 2;
			arg[1] = CLAN_C;
			set_task( cas, "clan_war_end", TASK_FAIL, arg, 2, "a", 1)
		}
		
		// Ak hraci nepridu do 30 min				
		cas = get_pcvar_float(CAS_HRACI_NEPRIDU)
		if( cas > 0.0) {
			set_task( cas , "ak_hraci_sa_nedostavia", TASK_END, _, _, "a", 1)
		}
		
		// Task hud infa
		if(get_pcvar_num(CONFIG_MENO)) {
			cas = get_pcvar_float(CAS_HUD_INTERVAL);
			if(cas > 0.0) {
				set_task(cas, "info_hud", TASK_HUD, _, _, "b");
			}	
		}
		
		return PLUGIN_CONTINUE						
}
public clan_war_start()
{
	/*	CW Zaciatok 	FORWARD
	
		Fukncia sa zapne ak sa zapne zapas.
		Teda uz je minimalny pocet hracov na servery.
	*/
	
	// Tasky
		set_task( get_pcvar_float(CAS_TAB_INTERVAL) ,"nastav_score_board",	TASK_TAB, _, _, "b");		
	// dema u hracov
		if(get_pcvar_num(CONFIG_DEMO))
		{		
			for(new hrac = 1; hrac <= max_hracov; hrac++)
			{					
				if (!is_user_connected(hrac))
					continue;		
				if (is_user_hltv(hrac))
					continue;
				
				client_cmd(hrac, "record cup_%d",sql_id);
			}
		}	
		
	// cvar	
		zapas_prebieha = true
		kol = 0
		
		oznam("%s %L", DEFINE_SAY, LANG_SERVER, "CVICNE", get_pcvar_num(KOL_CVICNE))	
		format(status, 31, "%L", LANG_SERVER, "STATUS_4");
		log_ciara()
		log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "STATUS_4")
	// vynuluje statistiky z ak uz hrali....
		nulacia_premennych(0)
	// spusti natacanie
		#if defined HLTV
		hltv_record()
		#endif
	// RR
		set_cvar_float("sv_restart", 3.0)
}
public clan_war_end(fail, clan)
{
	/* CW Ukonceny		FORWARD
	
		Fukncia sa vola pri ukonceni zapasu.
		Riadi ostatne koncove fukncie
		A posuva informacie do end systemu.
		
		 Fail Dovody
			0	- 	vsetko je dobre
			1	-	server sa vypol
			2	-	hraci nestihli dohrat zapas do 2 hodin
			3	-	hraci neprisli do 30min
			4	-	Nesedi rozmiestnenie / minimalny pocet hracov
	*/
	// Premenne	
		remove_task(TASK_END)
		remove_task(TASK_FAIL)
		remove_task(TASK_TAB)
		remove_task(TASK_HUD)
		
		zapas_prebieha = false
		zapas_ma_byt = false		
	// Status / dovod
		log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "END")
		switch (fail) {
			case 0: { 
				end_system( _, _, "")
				oznam("%s %L", DEFINE_SAY, LANG_SERVER, "END_OK", "^x03")	
			}
			case 1: { 
				end_system(_, _, "%L", LANG_SERVER, "END_1_WEB")
				oznam("%s %L", DEFINE_SAY, LANG_SERVER, "END_1_HRA")
			}
			case 2: { 
				end_system(_, _, "%L", LANG_SERVER, "END_2_WEB")
				oznam("%s %L", DEFINE_SAY, LANG_SERVER, "END_2_HRA")
			}			
			case 3: { 
				if(clan != CLAN_C)
				{
					end_system(clan, 30, "%L", LANG_SERVER, "END_3_WEB", clan_meno[clan])
					oznam("%s %L", DEFINE_SAY, LANG_SERVER, "END_3_HRA", clan_meno[clan])
				} else {
					end_system(_, 0, "%L", LANG_SERVER, "END_3_WEB_B")
					oznam("%s %L", DEFINE_SAY, LANG_SERVER, "END_3_HRA_B")
				}
			}		
			case 4: { 
				if(clan != CLAN_C)
				{
					end_system(clan, 15, "%L", LANG_SERVER, "END_4_WEB", clan_meno[clan])
					oznam("%s %L", DEFINE_SAY, LANG_SERVER, "END_4_HRA", clan_meno[clan])
				}
			}		
			case 5: { 
				if(clan != CLAN_C) { //pre istotu
					end_system(clan, 30, "%L", LANG_SERVER, "END_5_WEB", clan_meno[clan])
					oznam("%s %L", DEFINE_SAY, LANG_SERVER, "END_5_HRA", clan_meno[clan])
				}	
			}
			case 6: { 
				if(clan != CLAN_C)
				{
					end_system(clan, 30, "%L", LANG_SERVER, "END_6_WEB", clan_meno[clan])
					oznam("%s %L", DEFINE_SAY, LANG_SERVER, "END_6_HRA", clan_meno[clan])
				}
			}
		}
		
		format(status, 31, "%L", LANG_SERVER, "STATUS_5");
		log_ciara()
	// kickujem hracov s dovodom +  vypinam server
		if( get_pcvar_float(CAS_DO_KICKU_HRACOV) > 0.0)	
		{
			set_task( get_pcvar_float(CAS_DO_KICKU_HRACOV), "end_kick_a_vypnut")
		}
	// dema u hracov a screeny
		if(get_pcvar_num(CONFIG_DEMO) == 1)
		{
			for(new hrac = 1; hrac <= max_hracov; hrac++)
			{					
				if (!is_user_connected(hrac))
					continue;		
				if (is_user_hltv(hrac))
					continue;
							
				client_cmd(hrac, "snapshot");
				client_cmd(hrac, "+showscores");
				client_cmd(hrac, "snapshot");
				client_cmd(hrac, "-showscores");
				client_cmd(hrac, "snapshot");
				client_cmd(hrac, "stoprecord");
			}
		}
	// odpoajam HLTV
		#if defined HLTV
		if(fail != 3)
			hltv_stop()
		#endif	
		
	heslo_on_off()	
}
stock clan_war_access(id)
{
	/* 	CW Prihlasenie uzivatela		FORWARD
		
		Spracovanie udajov uzivatela a jeho povolenie do hry.
	*/
// Premenne	
	user_hodnost[id] = 0;
	user_webid[id]	 = 0;
	user_team[id] 	 = CLAN_C;
	user_bonus[id]   = 0;
	user_menu[id] 	 = false;
// Filtrovat
	if(is_user_hltv(id) || zapas_ma_byt ==false)
	{
		return PLUGIN_HANDLED;
	}
	new user_clan = zisti_clan_stare(id)
// Divaci presmerovavanie
	if(!(get_user_flags(id) & ADMIN) && user_clan == CLAN_C )
	{
		new server[32]
		get_pcvar_string(CONFIG_DIVACI, server, 31)
		if( !equal(server, "0"))
		{
			client_print(id, print_console, "%L", LANG_SERVER, "USER_PRESUN")
			client_cmd(id, "connect %s", server);
			return PLUGIN_CONTINUE
		}
	}
// Meno a heslo	
	if( get_pcvar_num(CONFIG_MENO))
	{			
		new pw_option[32], pw_string[32], pw_num
			
		get_pcvar_string(MENU_TLACIDLO, pw_option, 31)
		client_cmd(id, "bind ^"%s^" ^"cup_menu^"", pw_option);
		client_cmd(id, "hud_centerid", "0");
					
		get_pcvar_string(CONFIG_HESLO, pw_option, 31)
		get_user_info(id, pw_option, pw_string, 31)
		pw_num = str_to_num(pw_string)
		
		if(user_clan != CLAN_C)
		{
			if(!pw_num)
			{
				kick_player(id, "%L", LANG_SERVER, "USER_PASS_NO", pw_option)
				return PLUGIN_HANDLED
			}
		}
		
		new webid = user_search(id, user_clan)
		if(webid == -1) {
			kick_player(id, "%L", LANG_SERVER, "USER_ERROR")
			return PLUGIN_HANDLED
		} else if(webid == 0)	{
			kick_player(id, "%L", LANG_SERVER, "USER_NO")
			return PLUGIN_HANDLED
		} else	{

			// Naslo	
			if( user_clan == CLAN_C )
			{
				user_hodnost[id] = 0
				user_webid[id] 	 = webid
				user_team[id] 	= CLAN_C
			} else {
				new vysledok[3] 
				vysledok = user_get(webid)
				if( vysledok[0] == pw_num)
				{
					user_hodnost[id] = vysledok[1]
					user_webid[id] 	 = webid
					user_team[id] 	 = user_clan
					user_bonus[id]	 = vysledok[2]					
				} else {
					kick_player(id, "%L", LANG_SERVER, "USER_PASS", pw_option)
					return PLUGIN_HANDLED
				}
			}
		}
	} else {
		user_webid[id]	 = 0
		user_hodnost[id] = 0
		user_team[id] 	 = CLAN_C
	}
// Ak chceme vyuzviat slot plugin musi ist na uplny zaciatok v plugins,ini	
	if(user_clan != CLAN_C)
	{
		set_user_flags(id, ADMIN_RESERVATION)
		set_user_flags(id, user_clan == CLAN_A ? ADMIN_LEVEL_A : ADMIN_LEVEL_B)		
	}
	
	return PLUGIN_CONTINUE
}
public clan_war_kolo() // nove kolo
{
	/*	CW Nove kolo		FORWARD
	
		Event sa vola akzde nove kolo....
	*/
	
	// Ak nieje zapas...
	if(zapas_ma_byt == false)
	{
		kol = 0
		return PLUGIN_CONTINUE
	}
	if(zapas_prebieha == true)
	{
		// Ochrana aby nevybral poznejsie ...
		if(zmena_teamu)  {
			zmena_teamu = false
			set_cvar_float("sv_restart", 3.0)
			return PLUGIN_CONTINUE
		}
		
		// Premenne a fukncie volaj
		kol++;
		nastav_score_board()
		//kontrola_hracov_v_teame()
		function_kontrola_quoty()
		
		// Akcie
		new cvicne = get_pcvar_num(KOL_CVICNE)
		if( kol < cvicne )
		{
			// Oznamy
			new sprava[BUFFER]
			formatex(sprava, BUFFER - 1, "^x03%i.^x01", kol);
			oznam("%s %L", DEFINE_SAY, LANG_SERVER, "KOLO_PREBIEHA", sprava)
			formatex(status, 31, "%i. %L", kol, LANG_SERVER, "KOLO_CVICNE");

			if(get_pcvar_num(DEBUG) == 1) {
				log_to_file(LOG_SUBOR,"%L %i", LANG_SERVER, "KOLO_CVICNE", kol)
			}
		} 
		else if ( kol == cvicne)
		{
			knife_start()
			nulacia_premennych(cvicne)
		} else {		
			if(get_pcvar_num(DEBUG) == 1) {
				log_to_file(LOG_SUBOR,"%L %i", LANG_SERVER, "KOLO", kol - cvicne)
			}
			// oznamy
			oznam("%s ^x03%i.^x01 %L !", DEFINE_SAY, kol - cvicne, LANG_SERVER, "KOLO")
			format(status, 31, "%i. %L", kol - cvicne, LANG_SERVER, "KOLO");	
			
			new hra = get_pcvar_num(KOL_HRA)
			new team = get_pcvar_num(KOL_TEAM)
													
			// prehazduje team
			if(kol == cvicne + team && team > 0)
			{
				clan_vymena_score[CLAN_A] = clan_score[CLAN_A]		
				clan_vymena_score[CLAN_B] = clan_score[CLAN_B]	
				prehod_teamy(1)			
			}

			// posledne
			if(kol == cvicne + hra && hra > 0)
			{
				oznam("%s %L", DEFINE_SAY, LANG_SERVER, "KOLO_LAST")
			}			
			// koniec
			if(kol == cvicne + hra + 1 && hra > 0)
			{
				clan_war_end(0, CLAN_C)
			}		
		}	
		
	}
	return PLUGIN_CONTINUE
}
stock kontrola_hracov_v_teame()
{
	/* Kontrola hracov v teame 	NATIVE
	
		Fukncia  pri roznych situaciah kontroluje hracov ci su kde maju byt.
		Zabrani tak vzniku bugu a komplikaciam v hre.
		- Vypnute 
	*/
	for(new hrac = 1; hrac <= max_hracov; hrac++)
	{					
		if (!is_user_connected(hrac))
			continue;		
		if (is_user_hltv(hrac))
			continue;
			
		new temp = zisti_clan(hrac)
		new team = fm_cs_get_user_team(hrac)
			
		// Nema clan...	SPE
		if( temp == CLAN_C)
		{	
			if(team != CS_TEAM_SPECTATOR)
			{
				if( is_user_alive(hrac) )
				{
					user_silentkill ( hrac ) 
				}
			}
			fm_cs_set_user_team(hrac,CS_TEAM_SPECTATOR)
		} else {
			// Ak ma clan...
			if( team != clan_team[temp])
			{
				if( is_user_alive(hrac) )
				{
					user_silentkill ( hrac ) 
				}
				fm_cs_set_user_team(hrac,CS_TEAM_SPECTATOR)
			}
		}	
	}	
}
	
	/*~~~~~~~~~~~~  
	  -Quota system -  
	~~~~~~~~~~~~~*/
	
public function_kontrola_quoty()
{
	/* 	Funkcia kontroly a vypoctu quoty	NATIVE
		
		Hlavnou ulohou tejto fukncie je menit X on X
		A to dosiahneme ak v hre budu hraci v spectators 
		a ked bude rovnaky pocet tak priradime ich do teamu ak budu chciet..
		Kontrolu ci quota sedi aj z teamom ak nie tak jedneho vyhodi z teamu
	*/
	if( get_pcvar_num(KONTROLA_QUOTY) != 1)
	{
		return PLUGIN_HANDLED
	}	
	
	if(zapas_prebieha == true)
	{
		if(get_pcvar_num(DEBUG) == 2) {
			log_to_file(LOG_SUBOR,"function_kontrola_quoty()");
		}	
		new pocet[2]
		pocet[CLAN_A] = f_pocet_hracov(CLAN_A)
		pocet[CLAN_B] = f_pocet_hracov(CLAN_B)
		new min_quota = get_pcvar_num(MIN_QUOTA)
		
		if( pocet[CLAN_A] >= min_quota && pocet[CLAN_B] >= min_quota )
		{
			if(get_pcvar_num(DEBUG) == 2) {
				log_to_file(LOG_SUBOR,"Odstranujem TASK");
			}
			remove_task(TASK_PLAYER)
			remove_task(TASK_PLAYER_1)
			remove_task(TASK_PLAYER_2)
			remove_task(TASK_PLAYER_3)	
		}

	// Clan A ma malo hracov ,prerad...
		if( pocet[CLAN_A] > pocet[CLAN_B])		
		{
			if(!quota_team_add(CLAN_B))
			{
				if( pocet[CLAN_A] >= min_quota && pocet[CLAN_B] >= min_quota)
				{			
					// mozeme kicknut
					quota_team_del(CLAN_A)
					//set_task( 3.0, "function_kontrola_quoty")
				}
			}
	// Clan B ma malo hracov ,prerad...		
		} else if( pocet[CLAN_A] < pocet[CLAN_B] ) 		
		{
			if( !quota_team_add(CLAN_A))
			{
				if( pocet[CLAN_A] >= min_quota && pocet[CLAN_B] >= min_quota)
				{			
					// mozeme kicknut
					quota_team_del(CLAN_B)
					//set_task( 5.0, "function_kontrola_quoty")
				}
			}
	// Clany maju dobre hracov a sedi aj quota skus zvysit quotu a najst hracov		
		} else if( pocet[CLAN_A] == quota && pocet[CLAN_B] == quota) 
		{			
			if( quota_team_search() )
			{
				quota++;
				//set_task(5.0, "function_kontrola_quoty")
			}
	// Clany maju dobre hracov ale quotu si samy zmenili....len downgradni		
		} else if( pocet[CLAN_A] == pocet[CLAN_B] )
		{
			quota = pocet[CLAN_A]
			//set_task( 5.0, "function_kontrola_quoty")
		}		
	}
	return PLUGIN_CONTINUE
}
stock quota_team_add(id)
{	
	/* 	Quota team / player add	NATIVE
	
		Fukncia skusi najst hraca v SPE team a priradi ho do hry...
		- Vracia TRUE ak uspeje....
	*/	
	for(new hrac = 1; hrac <= max_hracov; hrac++)
	{					
		if (!is_user_connected(hrac))
			continue;		
		if (is_user_hltv(hrac))
			continue;
			
		if( fm_cs_get_user_team(hrac) == CS_TEAM_SPECTATOR ) // len spectator
		{	
				if( zisti_clan(hrac) == id)
				{
					spe_do_hry(hrac,clan_team[id])
					if(get_pcvar_num(DEBUG) == 2) { log_to_file(LOG_SUBOR,"quota_team_add(%s,true)",id == CLAN_A ? "A" : "B"); }
					return true;
				}		
		}
	}
	if(get_pcvar_num(DEBUG) == 2) { log_to_file(LOG_SUBOR,"quota_team_add(%s,false)",id == CLAN_A ? "A" : "B"); }
	return false;	// nic nenaslo
}
stock quota_team_del(id)
{	
	/* 	Quota team / player delete	NATIVE
	
		Funkcia preradi hraca do SPE teamu
		- Snazi sa najst najhorsieho hraca
		- Vracia TRUE ak uspeje....	
	*/	
	
	// Daj prec hraca s najmensim skore a skus mrtveho
	new najvacsi_skiller
	new najvacsie_skore = 2000
	
	for(new hrac = 1; hrac <= max_hracov; hrac++)
	{					
		if (!is_user_connected(hrac))
			continue;		
		if (is_user_hltv(hrac))
			continue;
			
		if( zisti_clan(hrac) == id)
			{
			if( fm_cs_get_user_team(hrac) == clan_team[id] )
			{
				if( get_user_frags(hrac) < najvacsie_skore   )
				{
					najvacsie_skore = get_user_frags(hrac)
					najvacsi_skiller = hrac
				}	
			}
		}			
	}				
							
	// Vystup
	if( najvacsi_skiller ) {
		fm_cs_set_user_team( najvacsi_skiller ,CS_TEAM_SPECTATOR)		
		// Ak este zije...
		if( is_user_alive(najvacsi_skiller) )
		{
			user_silentkill ( najvacsi_skiller )
		}
		if(get_pcvar_num(DEBUG) == 2) { log_to_file(LOG_SUBOR,"quota_team_del(%s,true)",id == CLAN_A ? "A" : "B"); }
		return true;
	}
	if(get_pcvar_num(DEBUG) == 2) { log_to_file(LOG_SUBOR,"quota_team_del(%s,false)",id == CLAN_A ? "A" : "B"); }
	
	return false;	// nic nespravilo
}
stock quota_team_search()
{	
	/* 	Quota team / player hladaj	NATIVE
	
		Fukncia najde 2 hracov .
		Jedneho z A clanu.
		Jedneho z B clanu.
		- Vracia TRUE ak uspeje....	
	*/
	
	new hrac, hrac_2 = 0, hrac_3=0, user_clan
	
	for(hrac = 1; hrac <= max_hracov; hrac++)
	{					
		if (!is_user_connected(hrac))
			continue;		
		if (is_user_hltv(hrac))
			continue;
			
		if( fm_cs_get_user_team(hrac) == CS_TEAM_SPECTATOR ) // len spectator
			{
			user_clan = zisti_clan(hrac)
			if( user_clan == CLAN_A )
			{
				hrac_2 = hrac
			}
			if( user_clan == CLAN_B)
			{
				hrac_3 = hrac
			}
		}	
	}	
	
	if( hrac_3 !=0 && hrac_2 !=0)
	{
		spe_do_hry(hrac_2,clan_team[CLAN_A])		
		spe_do_hry(hrac_3,clan_team[CLAN_B])
		if(get_pcvar_num(DEBUG) == 2) { log_to_file(LOG_SUBOR,"quota_team_search(true)"); }
		return true;
	}
	
	if(get_pcvar_num(DEBUG) == 2) { log_to_file(LOG_SUBOR,"quota_team_search(false)"); }
	return false; // nic nenaslo 
}	
	
	/*~~~~~~~~~~~~  
	 -Pomocne fukncie -  
	~~~~~~~~~~~~~*/

stock spe_do_hry(id,team)
{
	/*	 SPE do TEAMU		NATIVE
	
		Primitivna fukncia , pre HUD BUG, preradi hraca z
		SPE teamu do T alebo CT.	
	*/

	user_menu[id] = true
	// pre HUD BUG
	engclient_cmd(id,"jointeam",team == CS_TEAM_T ? "1" : "2")
	engclient_cmd(id,"joinclass", "1")
	engclient_cmd(id,"slot1")
	
	respawn(id)
	fm_cs_set_user_money ( id , get_cvar_num("mp_startmoney"))
	user_menu[id] = false
	
	if(get_pcvar_num(DEBUG) == 2) { log_to_file(LOG_SUBOR,"spe_do_hry(%d,%d)",id,team); }
	return PLUGIN_CONTINUE
}
stock knife_start()
{
	/*	 Knife start		FORWARD
	
		Fukncia sa vola po ukonceni cvicnych kol.
		Najde hraca z najlepsim skore.
	*/
	
	// Ochrana aby nevybral poznejsie ....
	zmena_teamu = true
	
	if(get_pcvar_num(DEBUG) == 1) {
		log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "KNIFE_START");
	}
	
	new najvacsi_skiller, team, skore, sprava[BUFFER]
	new najvacsie_skore = -1000 // niekto moze mat nula
	
	for(new hrac = 1; hrac <= max_hracov; hrac++)
	{					
		if (!is_user_connected(hrac))
			continue;		
		if (is_user_hltv(hrac))
			continue;
		
		team = fm_cs_get_user_team(hrac)
		skore = get_user_frags(hrac)
		if( (skore > najvacsie_skore ) && (team == CS_TEAM_CT || team == CS_TEAM_T) )
		{
			// Najlepsie skore a ID hraca zapasi
			najvacsie_skore = skore
			najvacsi_skiller = hrac
		}
	}

	// Oznamy
	get_user_name( najvacsi_skiller, sprava, BUFFER - 1);
	format(sprava, BUFFER - 1, "^x03%s^x01", sprava);
	oznam("%s %L", DEFINE_SAY, LANG_SERVER, "KNIFE_WIN", sprava)
	format(sprava, BUFFER - 1, "\t%L^n\w1. Counter-terrorist ^n\w2. Terrorist ^n\w^n0. Exit^n", LANG_SERVER, "KNIFE_MENU")
	show_menu( najvacsi_skiller , TLACITKA, sprava, -1, "MENU") // Display menu

	return PLUGIN_CONTINUE
}
public knife_function(id, key) {
	/* 	Knife menu fukncia		NATIVE
	
		Fukncia sa vola po vybere z knife menu.
		A spravuje dalsie udalosti.
	*/	
	
	// Ochrana aby nevybral poznejsie ....
	if(!zmena_teamu) {
		oznam("%s %L", DEFINE_SAY, LANG_SERVER, "KNIFE_NO")
		return PLUGIN_CONTINUE
	}	
	zmena_teamu = false
	
	new team
	switch (key) {
		case 0: { 
			team = CS_TEAM_CT
			oznam("%s %L", DEFINE_SAY, LANG_SERVER, "KNIFE_TEAM", "^x03 CT^x01")
		}
		case 1: { 
			oznam("%s %L", DEFINE_SAY, LANG_SERVER, "KNIFE_TEAM", "^x03 T^x01")
			team = CS_TEAM_T
		}
		case 9: { 
			oznam("%s %L", DEFINE_SAY, LANG_SERVER, "KNIFE_TEAM_NO")
			team = fm_cs_get_user_team(id)
		}
	}	
		
	if(fm_cs_get_user_team(id) != team )
	{
		//Teamny niesu rovnake tak prehod
		prehod_teamy()
	}
	// RR mus byt !
	set_cvar_float("sv_restart",3.0)
	
	return PLUGIN_CONTINUE
}
stock nulacia_premennych( pocet_kol )
{
	/*	Nulacia premmenych 	NATIVE
	
		Fukncia vynuluje vsetke premmene a stare udaje z minuleho CW.
		Snazi sa taktiez vizualne prepisat hracove skore.	
	*/
	new money = get_cvar_num("mp_startmoney")
	
	// Statistyky su same restartovane ak sa prehodi team tak vsetko je od 0
		
	for(new hrac = 1; hrac <= max_hracov; hrac++)
	{					
		if (!is_user_connected(hrac))
			continue;		
		if (is_user_hltv(hrac))
			continue;
			
		fm_set_user_frags(hrac,0)				
		fm_cs_set_user_deaths(hrac,0)
		fm_cs_set_user_money(hrac, money)
				
		// Vizualna cast pre hraca
		message_begin(MSG_ALL, msgid_score_info)
		write_byte(hrac)        //Player
		write_short(0) //F
		write_short(0) //D
		write_short(0)       
		write_short(fm_cs_get_user_team(hrac))  //Team
		message_end()
	}
	// Premenne
	clan_score[CLAN_A] = 0
	clan_score[CLAN_B] = 0
	clan_vymena_score[CLAN_A] = 0
	clan_vymena_score[CLAN_B] = 0
	kol = pocet_kol;	
	if(get_pcvar_num(DEBUG) == 2) {
		log_to_file(LOG_SUBOR,"nulacia_premennych(%d)", pocet_kol);
	}
}
stock prehod_teamy( spawn = 0)
{
	/*	Prehod teamy 	NATIVE
	
		Fukncia prehodi TEAMY a zarovej aj udaje.
		- SPAWN zapina automaticky RESPAWN
		- Jakmile som zmenil ,zjednodusil nechcelo to ist :(
	*/	
	oznam("%s %L", DEFINE_SAY, LANG_SERVER, "TEAMY", "^x03 CT^x01 <=>^x03 T^x01");
	log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "TEAMY", "^x03 CT^x01 <=>^x03 T^x01");
		
	new hracov[32], pocet_hracov, hrac, temp
	get_players(hracov, pocet_hracov, "ch");
	
	for(new i = 0; i < pocet_hracov; i++)
	{									
		hrac = hracov[i];
		if(is_user_connected(hrac))
		{
			temp = fm_cs_get_user_team(hrac)
			if( temp == CS_TEAM_T )
			{
				fm_cs_set_user_team(hrac,CS_TEAM_CT);
				fm_cs_reset_user_model(hrac);
				// repawn
				if(spawn == 1)
				{
					respawn(hrac);
				}
			}		
			if( temp == CS_TEAM_CT )
			{
				fm_cs_set_user_team(hrac,CS_TEAM_T);	
				fm_cs_reset_user_model(hrac);
				// repawn
				if(spawn == 1)
				{
					respawn(hrac);
				}
			}
		}
	}	
	// vymenime premenne
	temp = clan_team[CLAN_A];
	clan_team[CLAN_A] = clan_team[CLAN_B];
	clan_team[CLAN_B] = temp;
	
	/*
	//sice prehodi teamy ale musi byt RR
	if( floatround(get_pcvar_float(CAS_RR)) > 0)
	{
		set_cvar_float("sv_restart",get_pcvar_float(CAS_RR))
	}*/
	
	return PLUGIN_CONTINUE;
}
public oznam( const msg[] , any:...)
{
	/*	Oznam	NATIVE
		
		Farebny oznam pre vsetkych hracov.
	*/	
	if(msgid_say)
	{
		new temp[BUFFER*4]
		vformat(temp, sizeof temp - 1, msg, 2)
				
		// Ak chceme farbene musime dat FOR a pre kazdeho zvlast :(
		for(new hrac = 1; hrac <= max_hracov; hrac++)
		{								
			if(!is_user_connected(hrac) || is_user_hltv(hrac))
			{
				client_print( hrac, print_chat, temp)
			} else {	
					message_begin(MSG_ONE_UNRELIABLE, msgid_say,_,hrac)
					write_byte(hrac)
					write_string(temp)
					message_end()	
			}	
		}
	}
	return PLUGIN_CONTINUE
}
public zachit_say(id)
{
	/*	 Zachit say 		FORWARD
		
		Fukncia zachicuje co hraci napisu a
		sputat dalsie fukncie....
	*/
	if(is_user_connected(id))
	{	
		new napisane[64], buffer_a[32], buffer_b[32]
		read_args(napisane, 63)
		
		formatex(buffer_a, sizeof buffer_a - 1, "%L", LANG_SERVER, "SAY_STATS1")
		formatex(buffer_b, sizeof buffer_b - 1, "%L", LANG_SERVER, "SAY_STATS2")
		if( containi(napisane, buffer_a) > -1 || containi(napisane, buffer_b) > -1) {		
			vypis_info(id)
		}	
		
		formatex(buffer_a, sizeof buffer_a - 1, "%L", LANG_SERVER, "SAY_INFO1")
		formatex(buffer_b, sizeof buffer_b - 1, "%L", LANG_SERVER, "SAY_INFO2")
		if( containi(napisane, buffer_a) > -1 || containi(napisane, buffer_b) > -1) {		
			formatex(napisane, sizeof napisane - 1, "%L", LANG_SERVER, "URL_INFO")
			show_motd(id, napisane, VERZIA)
		}
	}
	return PLUGIN_CONTINUE;
}	
stock vypis_info(id)
{		
	/*	 Vypis info		NATIVE
	
		Fuknciavypise akuatlne udaje  o zapase alebo
		o priprave , priapdne stavu serveru alebo ligy.
	*/
	
	new sprava[BUFFER], sprava_b[BUFFER]
	if(zapas_prebieha == false)
	{
		if(zapas_ma_byt == true)
		{
			new datum[22], hodina[3]
			formatex(sprava, 	 BUFFER - 1, "^x03%s ^x01", clan_tag[CLAN_A])
			formatex(sprava_b, BUFFER - 1, "^x03%s", 		clan_tag[CLAN_B])
			format_time(datum, 21, "%Y.%m.%d o %H", cas_zapasu)
			format_time(hodina, 2, "%H", cas_zapasu)
			send_sprava(id, "%s %L", DEFINE_SAY, LANG_SERVER, "INFO_START", datum, info_cas[0], info_cas[1] + floatround( get_pcvar_float(CAS_HRACI_NEPRIDU) / 60.0 ) )						
			send_sprava(id, "%s %L", DEFINE_SAY, LANG_SERVER, "INFO_CLANY",  sprava, sprava_b )
		} else {
			send_sprava(id, "%s %L", DEFINE_SAY, LANG_SERVER, "INFO_ZAPAS")
		}
	} else {
		new temp = get_pcvar_num(KOL_CVICNE)
		if(kol < temp)
		{
			formatex(sprava,   BUFFER - 1, "^x03 %i^x01", kol)
			formatex(sprava_b, BUFFER - 1, "^x03%i ^x01", temp)
			send_sprava(id, "%s %L", DEFINE_SAY, LANG_SERVER, "KOLO_INFO", sprava, sprava_b, LANG_SERVER, "KOLO_CVICNE")		
		} else {
			formatex(sprava,   BUFFER - 1, "^x03 %i^x01", kol - temp)
			formatex(sprava_b, BUFFER - 1, "^x03%i ^x01", get_pcvar_num(KOL_HRA))
			send_sprava(id, "%s %L", DEFINE_SAY, LANG_SERVER, "KOLO_INFO", sprava, sprava_b, LANG_SERVER, "KOLO")			
			
			formatex(sprava,   BUFFER - 1, "^x03%s^x01", clan_meno[CLAN_A])
			formatex(sprava_b, BUFFER - 1, "^x03%d", 	   clan_score[CLAN_A])
			send_sprava(id, "%12L", LANG_SERVER, "INFO_CLAN", sprava, sprava_b )				
			
			formatex(sprava,   BUFFER - 1, "^x03%s^x01", clan_meno[CLAN_B])
			formatex(sprava_b, BUFFER - 1, "^x03%d", 	   clan_score[CLAN_B])
			send_sprava(id, "%12L", LANG_SERVER, "INFO_CLAN", sprava, sprava_b )
		}
	}	
	
	// Debug - poddrobne udaje	
	if(get_pcvar_num(DEBUG) == 1 && (get_user_flags(id) & ADMIN ) ) {
		client_print( id,  print_console,"-------------Debug--------------"	)
		client_print( id,  print_console,"%L", LANG_SERVER, "INFO_DEBUGCLAN", "A", clan_team[CLAN_A], clan_score[CLAN_A], clan_vymena_score[CLAN_A], f_pocet_hracov(CLAN_A), clan_bonus[CLAN_A] )
		client_print( id,  print_console,"%L", LANG_SERVER, "INFO_DEBUGCLAN", "B", clan_team[CLAN_B], clan_score[CLAN_B], clan_vymena_score[CLAN_B], f_pocet_hracov(CLAN_B), clan_bonus[CLAN_B] )	
		client_print( id,  print_console,"%L", LANG_SERVER, "INFO_DEBUG", kol, quota, user_webid[id], user_hodnost[id], user_bonus[id], user_menu[id] ? "Ano" : "Nie", user_presun[id]          )			
		client_print( id,  print_console,"-------------------------------"	)
	}	

	return PLUGIN_CONTINUE;
}
public info_hud()     
{  
	/*	Ukaz Info HUD		NATIVE
	
		Statisticky panel ,prebrane z VIP
		CL - Skore 16:1 - Bonus 85%
	*/
	new sprava[BUFFER]
	new bool:obrazovka = (get_pcvar_num(CONFIG_OBRAZOVKA)) ? true : false;
	
	for(new id = 1; id <= max_hracov; id++)
	{						
		if (!is_user_connected(id))
			continue;		
		if (is_user_hltv(id))
			continue;
			
		if (!is_user_alive(id)) {
			if(obrazovka)
				if(!(get_user_flags(id) & ADMIN))
					screen_fade(id)
		} else {	
						// Najprv hodnost zistime
			switch(user_hodnost[id])
			{
				case 1: { formatex(sprava, BUFFER -1 , "%L", LANG_SERVER, "HODNOST_1" ); }
				case 2: { formatex(sprava, BUFFER -1 , "%L", LANG_SERVER, "HODNOST_2" ); }
				case 3: { formatex(sprava, BUFFER -1 , "%L", LANG_SERVER, "HODNOST_3" ); }
				case 4: { formatex(sprava, BUFFER -1 , "%L", LANG_SERVER, "HODNOST_4" ); }	
				case 5: { formatex(sprava, BUFFER -1 , "%L", LANG_SERVER, "HODNOST_5" ); }	
				case 6: { formatex(sprava, BUFFER -1 , "%L", LANG_SERVER, "HODNOST_6" ); }
				case 7: { formatex(sprava, BUFFER -1 , "%L", LANG_SERVER, "HODNOST_7" ); }
				case 8: { formatex(sprava, BUFFER -1 , "%L", LANG_SERVER, "HODNOST_8" ); }
				case 9: { formatex(sprava, BUFFER -1 , "%L", LANG_SERVER, "HODNOST_9" ); }
				default : { formatex(sprava, BUFFER -1 , "%L", LANG_SERVER, "HODNOST_NO" ); }
			}		
			//formatex(sprava, BUFFER -1 , "HODNOST_%d", user_hodnost[id])
			//format(sprava, BUFFER -1 , "%L", LANG_SERVER, sprava)
			
			// Informacie
			format(sprava, BUFFER -1, "%L", LANG_SERVER, "HUD", sprava, get_user_frags(id), get_user_deaths(id), user_bonus[id])

			message_begin(MSG_ONE, msgid_status_text, {0,0,0}, id);  
			write_byte(0)  
			write_string(sprava)  
			message_end()
		}
	}
	return PLUGIN_CONTINUE;
}	
stock respawn(id)
{
	/*	Respawn	NATIVE
	
		Fukncia respawne hraca.
	*/
	if(!is_user_alive(id))
	{
	  set_pev(id, pev_deadflag, DEAD_RESPAWNABLE);
	  dllfunc(DLLFunc_Think, id);
	} else {
	  dllfunc(DLLFunc_Spawn, id);
	}
	
	return PLUGIN_CONTINUE
}
public clcmd_respawn(id,level,cid)
{
	/*	Admin respawn	NATIVE
	
		Admin fukncia respawne hraca.
	*/
	if (!cmd_access(id,level,cid,2)) {
		return PLUGIN_HANDLED
	}
	
	new parameter[32], parameter_2[4]
	read_argv( 2, parameter, sizeof parameter - 1)
	new ciel = cmd_target (id, parameter, 3);

	if (!ciel)
    {
        client_print(id, print_console, "(!) %L", LANG_SERVER, "HRAC_NO");
        return PLUGIN_HANDLED;
    }

	read_argv(1, parameter_2, sizeof parameter_2 - 1)
	new team = str_to_num(parameter_2)

	if(fm_cs_get_user_team(ciel) == CS_TEAM_SPECTATOR)
	{
		spe_do_hry(ciel,team)
	} else {
		fm_cs_set_user_team(ciel, team)
		respawn(ciel)
	}

	if(get_pcvar_num(DEBUG) == 2) { log_to_file(LOG_SUBOR,"clcmd_respawn(%s,%d)", parameter, team); }
	return PLUGIN_CONTINUE
}
/*
public clcmd_rank(id,level,cid)
{
	if (!cmd_access(id,level,cid,2)) {
		return PLUGIN_HANDLED
	}
	new parameter_2[4]
	read_argv( 1, parameter_2, sizeof parameter_2 - 1)
	
	clan_id[0]	= str_to_num(parameter_2)
	end_rank_clanu(0)
	client_print(id, print_console, "ID %d Rank %d",clan_id[0],end_rank_clanu(0));
	return PLUGIN_CONTINUE
}
*/
#if defined STATUS		
public status_serveru() { 
	// Fukncia nastavuje STATUS serveru v zozname serverov
	forward_return( FMV_STRING, status ); 
	return FMRES_SUPERCEDE; 
} 
#endif
stock heslo_on_off()
{
	/*	Heslo on / off 	NATIVE
	
		Fukncia riadi automaticke  heslovanie a odheslovanie serveru.
	*/
	if(get_pcvar_num(CONFIG_PASS) == 1)
	{
		if(zapas_ma_byt == true)
		{
			set_cvar_string ("sv_password", "") 
			server_cmd("sv_password ^"^"")
		} else {
			set_cvar_string ("sv_password", sv_password) 
			new config[64]
			get_configsdir(config, 63)	
			server_cmd("exec %s/cup.cfg", config)
		}
	}
	return PLUGIN_CONTINUE
}
public event_vyber_teamov_1(id) {
	// Pomocna fukncia , spracuvava a dalej vola vyber teamov
	new arg[2]
	read_argv(1,arg,1)
	return vyber_teamov(id,str_to_num(arg))
}

public event_vyber_teamov_2(id,key) {	
	// Pomocna fukncia , spracuvava a dalej vola vyber teamov
	return vyber_teamov(id,key+1)
}
stock zisti_clan(id)
{
	/*	Zisti clan	NATIVE
	
		Fukncia zisti clan hraca podla clan ID cisla.
	*/

	return (get_pcvar_num(CONFIG_MENO)) ? user_team[id] : zisti_clan_stare(id);
}
stock zisti_clan_stare(id)
{
	/*	Zisti clan	NATIVE
	
		Fukncia zisti clan hraca podla clan tagu.
	*/
	new meno[32]
	get_user_name(id,meno,31);
	
	if( containi(meno,clan_tag[CLAN_A]) > -1)
	{
		return CLAN_A;
	}	
	if( containi(meno,clan_tag[CLAN_B]) > -1)
	{
		return CLAN_B;
	}
	return CLAN_C;
}
	
	/*~~~~~~~~~~~~  
	  -Hrac fukncie -  
	~~~~~~~~~~~~~*/
	
public client_authorized(id)				// Najprv volena
{
	// Pomocna fukncia 
	clan_war_access(id)
	return PLUGIN_CONTINUE
}/*
public client_putinserver(id)
{
	// Pomocna fukncia 
	if (!is_dedicated_server() && id == 1) 	// 2. najprv volene ak neje samotny server
	{
		set_task(CAS_UDVODNA_SPRAVA,	"uvodna_sprava",	id)
	}
	return PLUGIN_CONTINUE
}*/
public client_connect(id) 								// Uz z udajmi volane 
{
	// Pomocna fukncia 
	if(!is_user_hltv(id)) {
		new Float:casovac = get_pcvar_float(CAS_UDVODNA_SPRAVA);
		if(casovac > 0.0)
			set_task( casovac,	"uvodna_sprava",	id)
	}	
	return PLUGIN_CONTINUE
}

public client_infochanged(id)
{
	/*	Zmenene info		FORWARD
	
		Pomocna fuknica ,ktora sa vola ak hrac si zmenil udaje.
		Napriklad meno.
	*/
	new newname[32], oldname[32]	
	get_user_info(id, "name", newname, 31)
	get_user_name(id, oldname, 31)

	if (!equal(newname, oldname))
	{
		clan_war_access(id)
		//client_print(id, print_chat, "meno zmenene") //Log
		//kontrola_hracov_v_teame()
	}
	return PLUGIN_CONTINUE
}
public client_disconnect(id)
{	
	/*	Hrac sa odpojil		FORWARD
	
		Fukncia je volana ak nejaky hrac sa odpojil zo serveru.
		Kontrolu premenne cez dalsi fukncie.	
	*/
	// Premenne
	user_hodnost[id] = 0
	user_webid[id]	 = 0
	user_bonus[id]   = 0	

	// Hltv	
	if(is_user_hltv(id))
	{
		return PLUGIN_HANDLED;
	}
	
	// k Zapasu
	if(zapas_prebieha == true)
	{				
	// Spustime pre istotu kontrolu	
		new user_clan = zisti_clan(id)
		new pocet		
	//Ak neje divak
		if(user_clan != CLAN_C )
		{			
		// Zapisujeme cas na servery	
			user_set_info(id)
		// Bug ak sa cely clan naraz odpoji ....	
			pocet = f_pocet_hracov(user_clan)
			if(pocet == 0) 
			{
				clan_war_end(6, user_clan)
				return PLUGIN_CONTINUE
			}
			set_task(2.0, "odpojeny_cely_clan", user_clan);
			function_kontrola_quoty()		
		// Kontrola minimalneho poctu	
			if( pocet < get_pcvar_num(MIN_QUOTA) )
			{
				new Float:cas = get_pcvar_float(CAS_KYM_SA_VRATI)
				if( cas > 0.0)
				{					
					new sprava[BUFFER]
				// zaciatok
					formatex(sprava, BUFFER - 1, "%s %L", DEFINE_SAY, LANG_SERVER, "HRAC_DISCONNECT", floatround(cas) );
					oznam(sprava);
					log_to_file(LOG_SUBOR, sprava);
				// 33%
					formatex(sprava, BUFFER - 1, "%s %L", DEFINE_SAY, LANG_SERVER, "HRAC_DISCONNECT", floatround(cas - cas * 0.33) );
					set_task(cas * 0.33, "oznam", TASK_PLAYER_1, sprava, BUFFER - 1, "a", 1);
				//66%
					formatex(sprava, BUFFER - 1, "%s %L", DEFINE_SAY, LANG_SERVER, "HRAC_DISCONNECT", floatround(cas - cas * 0.66));
					set_task(cas * 0.66, "oznam", TASK_PLAYER_2, sprava, BUFFER - 1, "a", 1);
						
						
				// koniec	
					new arg[1]; arg[0] = user_clan;						
					set_task(cas, "odpojeny_clen", TASK_PLAYER_3, arg, 1, "a", 1);
					if(get_pcvar_num(DEBUG) == 1) {
						log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "HRAC_ODPOJENY");
					}
				}				
			}	
		}
	}	
	return PLUGIN_CONTINUE
}
public odpojeny_cely_clan(clan_id)
{
	new pocet = f_pocet_hracov(clan_id)
	if(pocet == 0) 
	{
		clan_war_end(6, clan_id)
	}
}
public odpojeny_clen(clan_id)
{
	/*	Odpojeny clen clanu	FORWARD
	
		Funkcia sa vola ak sa odpojil hrac pri minimalnej quote
		A kontroluje znova pocet hracov ,pripadne ukonci CW.
	*/
	if(zapas_prebieha == true)
	{		
		if(clan_id != CLAN_C)
		{	// Musime este raz overit
			new min_quota = get_pcvar_num(MIN_QUOTA)
			if( f_pocet_hracov(clan_id) < min_quota )	
			{			
				clan_war_end(4, clan_id)
			} 
		}
	}
}

	/*~~~~~~~~~~~~  
	  -HLTV fukncie -  
	~~~~~~~~~~~~~*/
	
#if defined HLTV
	stock hltv_rcon_cmd( const cmd[] )
	{
		/*	Hltv posli prikaz		NATIVE
		
			Fukncia posle nejaky prikaz do HLTV serveru.
		*/
		new hltv_address = 0   
		new error, hltv_cvar_ip[15], hltv_cvar_port, rconid[13],
			rcv[256], snd[256] ,hltv_cvar_rcon[20]

	    // hltv ip/port/password
		get_pcvar_string(HLTV_IP, hltv_cvar_ip, 15);
		hltv_cvar_port = get_pcvar_num(HLTV_PORT);
		get_pcvar_string(HLTV_RCON, hltv_cvar_rcon, 20);
		hltv_address = socket_open(hltv_cvar_ip, hltv_cvar_port, SOCKET_UDP, error);

		switch(error)
		{
			case 1: {
				log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "HLTV_ERROR1");
			}
			case 2: {
				log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "HLTV_ERROR2", hltv_cvar_ip, hltv_cvar_port);
			}	
			case 3: {
				log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "HLTV_ERROR3");
			}	
		}
		
	    //send challenge rcon and receive response
		setc(snd,4,0xff)
		copy(snd[4],255,"challenge rcon")
		setc(snd[18],1,'^n')
		socket_send(hltv_address,snd,255)
		socket_recv(hltv_address,rcv,255)

	    // get hltv rcon challenge number
		copy(rconid,12,rcv[19])
		replace(rconid,255,"^n","")
		setc(snd,255,0x00)
	    
	    // send rcon command
		setc(snd,4,0xff)
		formatex(snd[4], 255, "rcon %s ^"%s^" %s^n", rconid, hltv_cvar_rcon,cmd)
		//server_print("[AMX] Sending Rcon: ^"%s^"",snd[4])
		socket_send(hltv_address,snd,255)
		
		if(get_pcvar_num(DEBUG) == 1) {
			log_to_file(LOG_SUBOR, "%L %s", LANG_SERVER, "HLTV_QUERY", cmd);
		}
		return PLUGIN_CONTINUE
	} 
	stock hltv_connect()
	{
		/*	HLTV pripoj 	NATIVE
		
			Vytvori spojenie s HLTV serverom...
		*/
		if(get_pcvar_num(HLTV_PORT) == 0)
		{
			return PLUGIN_CONTINUE
		}	
		if(find_hltv() != 0)
		{
			return PLUGIN_CONTINUE
		}
		
		new server_ip[15], command[96], server_meno[32], server_port
		
		// meno
		get_pcvar_string(HLTV_MENO,server_meno,31)
		formatex(command, 96, "name %s", server_meno)
		hltv_rcon_cmd(command)
		
		// cvar
		formatex(command, 96, "delay %d" , get_pcvar_num(HLTV_DELAY) )
		hltv_rcon_cmd(command)	
		//format(command,96,"autoretry 1")
		formatex(command, 96, "autoretry %d", get_pcvar_num(HLTV_AUTORETRY) )
		hltv_rcon_cmd(command)
		
		//password
		formatex(command, 96, "serverpassword %s", "sls") // sv_password
		hltv_rcon_cmd(command)
			
		//connect
		get_pcvar_string(HLTV_HOME_IP, server_ip, 20)	// sposobuje lag
		if( equal(server_ip, "0"))
		{
			get_cvar_string("ip", server_ip, 20)
		}
		server_port = get_pcvar_num(HLTV_HOME_PORT)
		formatex(command, 96, "connect %s:%d",server_ip,server_port)
		hltv_rcon_cmd(command)
		
		log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "HLTV_CONNECT")
				
		return PLUGIN_CONTINUE
	} 
	stock hltv_record()
	{
		/*	HLTV natacaj demo
		
			Spusti nahravanie dema.....
		*/
		if(get_pcvar_num(HLTV_PORT) == 0)
		{
			if(get_pcvar_num(DEBUG) == 1) {
				log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "HLTV_OFF");
			}
			return PLUGIN_CONTINUE
		}
		hltv_connect()
		// Nazov dema
		new command[96]		
		if(!sql_id)
		{
			sql_id = 1;
		}	
		formatex(command, 96, "record cup_%d_%d", get_pcvar_num(CONFIG_ID), sql_id)
		hltv_rcon_cmd(command)
		
		return PLUGIN_CONTINUE
	}
	stock hltv_stop()
	{
		/*	HLTV ukonci
		
			Ukonci nahrtavanie dema a odpoji
			HLTV od gameserveru.
		*/
		if(get_pcvar_num(HLTV_PORT) == 0)
		{
			return PLUGIN_CONTINUE
		}
		
		hltv_rcon_cmd("stoprecord")	
		// Odpoji HLTV server		
		new command[96]
		formatex(command, 96, "stoprecording;autoretry 0;stop;")
		hltv_rcon_cmd(command)
		log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "HLTV_DISCNONNECT")
		
		return PLUGIN_CONTINUE
	}
	public clcmd_hltv_record(id,level,cid)
	{
		// Admin prikaz na  nahravanie dema
		if (!cmd_access(id,level,cid,1)) {
			return PLUGIN_HANDLED
		}
		
		hltv_record()
		return PLUGIN_CONTINUE
	}
	public clcmd_hltv_stop(id,level,cid)
	{
		// Admin prikaz na zastavenie nahravania
		if (!cmd_access(id,level,cid,1)) {
			return PLUGIN_HANDLED
		}
		
		hltv_stop()
		return PLUGIN_CONTINUE
	}
	stock find_hltv()
	{
		/* 	Najdi HLTV		NATIVE
		
			Fukncia sa vola hned po pripojeni a kontroluje 
			ci sa server naozj pripojil.
		*/
		
		if(!get_pcvar_num(HLTV_PORT))
			return PLUGIN_HANDLED
			
		if(get_pcvar_num(DEBUG) == 1) {
				log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "HLTV_SEARCH");
		}
		
		new hltv_cvar_ip[15], hltv_cvar_port, 
			hltv_cvar_address[32], hltv_client_address[32]		
		get_pcvar_string(HLTV_IP,hltv_cvar_ip,15)
		hltv_cvar_port = get_pcvar_num(HLTV_PORT)		
	
		for(new hrac = 1; hrac <= max_hracov; hrac++)
		{					
			if (!is_user_connected(hrac))
				continue;		
			if (!is_user_hltv(hrac))
				continue;
			
			// Ci ide o nas HLTV
			get_user_ip(hrac,hltv_client_address,31)
			formatex(hltv_cvar_address, 31, "%s:%d", hltv_cvar_ip, hltv_cvar_port)
				
			if(equal(hltv_cvar_address,hltv_client_address))
			{
				if(get_pcvar_num(DEBUG) == 1) {
					log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "HLTV_FIND");
				}
				return hrac
			}			
		} 	
		return 0
	}  
#endif

	/*~~~~~~~~~~~~  
	   - uzivatelia -  
	~~~~~~~~~~~~~*/

stock user_search(id, clan)
{
	/*	Najdi web uzvatela		NATIVE
	
		Fukncia nam z GAME id zisti WEB id podla
		herneho mena.
		- Vracia:
			-1  	SQL EROR
			0	Nenaslo	
			>	Naslo
	*/
	if (databaza == Empty_Handle) {
		if(get_pcvar_num(DEBUG) == 1) 
			log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "ERROR_SEARCH");
		return -1;
	}
	new meno[32], sprava[BUFFER], s_sql_users[64], prikaz[64], webid, Handle:result
	get_user_name(id,meno,31)
	
	if(clan == CLAN_C)
	{
		// Len spectatator
		formatex(prikaz, sizeof prikaz - 1, "");
	} else { 
		// Pomocka
		formatex(prikaz, sizeof prikaz - 1, "clan_id = '%d' AND", clan_id[clan]);
	}
	
	// Presne tak.....
	get_pcvar_string(SQL_USERS, s_sql_users, 63) 
	SQL_QuoteString(databaza, sprava, BUFFER - 1, meno) 
	result = SQL_PrepareQuery(databaza,"SELECT user_id FROM %s WHERE %s `cs_meno` LIKE '%s' ", s_sql_users, prikaz, sprava) 	   
	
	if (!SQL_Execute(result)) {	
		new eror[512]
		SQL_QueryError(result,eror,511)
		log_to_file(LOG_SUBOR, "[Mysql ERROR] %s",eror)	
		SQL_GetQueryString (result, eror, 511) 
		log_to_file(LOG_SUBOR, "[Mysql QUERY] %s", eror)
		SQL_FreeHandle(result)		
		return -1 		
	}  else if (SQL_NumResults(result) == 0) { 
		/*
		// Nenaslo ,........ pokus 2 ...... podobne.....
		result = SQL_PrepareQuery(databaza,"SELECT user_id FROM %s WHERE %s `cs_meno` LIKE '%%s%' ", s_sql_users, prikaz, meno ) 	   
		if (!SQL_Execute(result)) {	
			new eror[512]
			SQL_QueryError(result,eror,511)
			log_to_file(LOG_SUBOR, "[Mysql ERROR] %s",eror)		
			SQL_GetQueryString (result, eror, 511) 
			log_to_file(LOG_SUBOR, "[Mysql QUERY] %s", eror)
			SQL_FreeHandle(result)
			return -1 		
		}  else if (SQL_NumResults(result) == 0) { 	*/					
			SQL_FreeHandle(result)
			return 0
		//}
		
	}					
							
	webid = SQL_ReadResult(result, 0)
	SQL_FreeHandle(result)
	return webid
}
stock user_get(webid)
{
	/*	Zisti udaje		NATIVE
	
		Fukncia zisti udaje z databazy.
		- Potrebuje WEBID
		- Vracia:
			HESLO
			HODNOST
			BONUS
	*/
	new s_sql_users[64], vysledok[3], Handle:result
	get_pcvar_string(SQL_USERS, s_sql_users, 63)
	
	result = SQL_PrepareQuery(databaza,"SELECT cs_heslo, clan_hodnost, cs_bonus FROM %s WHERE user_id = '%d'", s_sql_users, webid) 	   
	if (!SQL_Execute(result)) {	
		new eror[512]
		SQL_QueryError(result,eror,511)		
		log_to_file(LOG_SUBOR, "[Mysql ERROR] %s", eror)	
		SQL_GetQueryString (result, eror, 511) 
		log_to_file(LOG_SUBOR, "[Mysql QUERY] %s", eror)
		vysledok[0] = 0
		vysledok[1] = 0		 
		vysledok[2] = 0		 
	} else {
		vysledok[0] = SQL_ReadResult(result, 0)
		vysledok[1] = SQL_ReadResult(result, 1)
		vysledok[2] = SQL_ReadResult(result, 2)
	}	
	
	SQL_FreeHandle(result)
	return vysledok
}
stock user_set_info(id, kill=0, death=0)
{
	/* 	Nastav udaje hacov
	
		Funkcia nastavuje udaje hracovy na webe ,cez databazu.
		- Upravuje rozne udaje , podla parametrov
	*/
	if(user_webid[id])
	{
		new s_sql_users[64], Handle:result
		get_pcvar_string(SQL_USERS, s_sql_users, 63)
			
		if( kill != 0 ||  death != 0)
		{				
			// Odosiela na konci CW
			result = SQL_PrepareQuery(databaza,"UPDATE %s SET `cs_kill` = `cs_kill` + '%d', `cs_death` = `cs_death` + '%d' WHERE user_id = '%d' ", s_sql_users, kill, death, user_webid[id]) 	    		
			if (!SQL_Execute(result)) {	
				mysql_error(result, "%L", LANG_SERVER, "ERROR_SETINFO", user_webid[id], kill, death)
			}			
		} else {
			//Odosiela pri odpojeni ....
			new cas = get_user_time(id, 1) / 60
			if( cas > 0)
			{
				result = SQL_PrepareQuery(databaza,"UPDATE %s SET `cs_time` = `cs_time`+('%d') WHERE user_id = '%d' ", s_sql_users, cas, user_webid[id]) 	    		
				if (!SQL_Execute(result)) {	
					mysql_error(result, "%L", LANG_SERVER, "ERROR_SETINFO", user_webid[id], kill, death)
				}
			}						
		}
	}
}
	
	/*~~~~~~~~~~~~  
	   - Menu system -  
	~~~~~~~~~~~~~*/

public menu_system(id)
{
	/* 	Menu system	FORWARD
	
		Hlavna fukncia ,ktora sa kona pri stisknuti menu tlacidla.
		Riadi ostatne pod menu fukncie.
	*/	
	// Zapnute ?
	if(!get_pcvar_num(CONFIG_MENO)) {
		send_sprava(id, "%s %L", DEFINE_SAY, LANG_SERVER, "MENU_OFF")
		return PLUGIN_HANDLED;
	}	
	
	// Rozlisujeme a kontrolujeme komu zapneme menu
	if(user_hodnost[id] == 1)
	{
		if(zapas_prebieha)
		{
			menu_leader(id)
		} else {
			send_sprava(id, "%s %L", DEFINE_SAY, LANG_SERVER, "MENU_ZAPAS")
		}
	} else {
		new sprava[BUFFER]
		formatex(sprava, BUFFER - 1, "^x03 %L^x01", LANG_SERVER, "HODNOST_1")
		send_sprava(id, "%s %L", DEFINE_SAY, LANG_SERVER, "MENU_ACCESS", sprava)
	}
	return PLUGIN_CONTINUE;
}
/*
stock menu_admin(id)
{
	// Mozno dalsia verzia ..............alebo skor pridat AMXMODX menu
}*/
stock menu_leader(id)
{
	/* 	Leader menu		NATIVE
	
		Hlavne leader menu.
		- Vizualna cast
	*/
	new menu_id, temp[32]
	
	formatex(temp, 31, "\r%L", LANG_SERVER, "MENU")	
	menu_id = menu_create(temp, "menu_leader_cmd")
	
	formatex(temp, 31, "\w%L", LANG_SERVER, "MENU_KICK")
	menu_additem(menu_id, temp,				"1", 0)
	
	formatex(temp, 31, "\w%L", LANG_SERVER, "MENU_PRESUN")
	menu_additem(menu_id, temp,				"2", 0)
	
	formatex(temp, 31, "\w%L", LANG_SERVER, "MENU_VZDAT_SA")
	menu_additem(menu_id, temp,				"3", 0)
	menu_addblank(menu_id, 0)
	
	formatex(temp, 31, "\yPowered by %s", VERZIA)
	menu_additem(menu_id, temp,				"4", 0)     
	
	menu_setprop(menu_id, MPROP_EXIT, MEXIT_ALL);
	menu_display (id, menu_id, 0)
	
	client_cmd(id,"spk buttons/button9")
}
public menu_leader_cmd(id, menu, item)
{
	/* 	Leader menu		NATIVE
	
		Hlavne leader menu.
		- Procesy
		- Vypni menu tak ci onak
	*/
	
	if( item == MENU_EXIT )
    {
		menu_destroy(menu);
		return PLUGIN_HANDLED;
    }

	new data[6], iName[64], access, callback;
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	menu_destroy(menu);
	new key = str_to_num(data);
	client_cmd(id,"spk buttons/button3")
	
	switch(key)
	{
		case 1: {
			menu_leader_kick(id);
		}
		case 2: {
			menu_leader_presun(id);
		}		
		case 3: {
			menu_leader_vzdat(id);
		}		
		case 4: {
			formatex(iName, sizeof iName - 1, "%L", LANG_SERVER, "URL_INFO")
			show_motd(id, iName, VERZIA);
		}
	}

	return PLUGIN_HANDLED;
}
stock menu_leader_kick(id)
{
	/* 	Leader kick menu		NATIVE
	
		Kickuje hracov z rovnakeho clanu alebo pozorvatelov.
		- Vizualna cast
	*/
	new user_clan = zisti_clan(id)
	if( user_clan != CLAN_C)
	{
		new meno[32], temp[10], menu
		formatex(meno, sizeof meno - 1, "\r%L", LANG_SERVER, "MENU_KICK")
		menu = menu_create(meno, "menu_leader_kick_cmd");
		
		// Hladaj hracov
		for(new hrac = 1; hrac <= max_hracov; hrac++)
		{						
			if (!is_user_connected(hrac))
				continue;
			if (is_user_hltv(hrac))
				continue;
			
			get_user_name(hrac, meno, 31);				
			if( containi(meno,clan_tag[user_clan]) > -1)
			{
				// Zapisuj
				num_to_str(hrac, temp, 9);
				menu_additem(menu, meno, temp, 0);
			}
	    }
		menu_display(id, menu, 0);
	}
}
public menu_leader_kick_cmd(id, menu, item)
{
	/* 	Leader kick menu		NATIVE
	
		Kickuje hracov z rovnakeho clanu alebo pozorvatelov.
		- Procesy
	*/
	client_cmd(id,"spk buttons/button3")
	if( item == MENU_EXIT )
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
	
	new data[6], iName[64], meno[32], hrac, access, callback
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	menu_destroy(menu);
	hrac = str_to_num(data);
	get_user_name(hrac,meno,31);
	// Spracuje udja e a kickne hraca......
	if(is_user_connected(hrac))
	{
		kick_player(hrac, "%L", LANG_SERVER, "MENU_KICK_HRAC")
		send_sprava(hrac, "%s^x03%s ^x01%L", DEFINE_SAY, meno, LANG_SERVER, "MENU_KICK_DONE")
	} else {
		send_sprava(hrac, "%s^x03%s ^x01%L", DEFINE_SAY, meno, LANG_SERVER, "MENU_KICK_NO")
	}

	return PLUGIN_HANDLED;
}
stock menu_leader_presun(id)
{
	/* 	Leader presun menu		NATIVE
	
		Toto menu najde nahradu za hraca v zapase a
		vymeni ho za hraca v SPE
		- Vizualna cast
	*/
	new user_clan = zisti_clan(id)
	new meno[32]
	
	if( user_clan != CLAN_C)
	{
		new menu, temp[10], stary_hrac
		formatex(meno, sizeof meno - 1, "\r%L", LANG_SERVER, "MENU_PRESUN")
		stary_hrac = user_presun[id]
		// Menu mozme pouzit 2x
		if(!stary_hrac)
		{
			menu = menu_create(meno, "menu_leader_presun_cmd");
			// Hladame nahradu najprv
			for(new hrac = 1; hrac <= max_hracov; hrac++)
			{					
				if (!is_user_connected(hrac))
					continue;		
				if (is_user_hltv(hrac))
					continue;
			
				get_user_name(hrac, meno, 31);				
				if( containi(meno,clan_tag[user_clan]) > -1)
				{
					if(fm_cs_get_user_team(hrac) == CS_TEAM_SPECTATOR)
					{
						num_to_str(hrac, temp, 9);
						menu_additem(menu, meno, temp, 0);
					}
				}
		    }	
		} else	{
		// Ak sme uz raz pouzili menu takze uz mame nahradu...
		// Vyberame noveho hraca....
			formatex(meno, sizeof meno - 1, "\r%L", LANG_SERVER, "MENU_PRESUN_ZA")
			menu = menu_create(meno, "menu_leader_presun_cmd");
			
			for(new hrac = 1; hrac <= max_hracov; hrac++)
			{					
				if (!is_user_connected(hrac))
					continue;		
				if (is_user_hltv(hrac))
					continue;
			
				if(stary_hrac != hrac)
				{
					get_user_name(hrac, meno, 31);				
					if( containi(meno, clan_tag[user_clan]) > -1)
					{
						if(fm_cs_get_user_team(hrac) == clan_team[user_clan])
						{
							num_to_str(hrac, temp, 9);
							menu_additem(menu, meno, temp, 0);
						}
					}
				}			
		    }
		}
		menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
		menu_display(id, menu, 0);
	}
}
public menu_leader_presun_cmd(id, menu, item)
{
	/* 	Leader presun menu		NATIVE
	
		Toto menu najde nahradu za hraca v zapase a
		vymeni ho za hraca v SPE
		- Procesy
	*/
	client_cmd(id,"spk buttons/button3")
	if( item == MENU_EXIT )
    {
		menu_destroy(menu);
		user_presun[id] = 0
		return PLUGIN_HANDLED;
    }
	
	new user_clan = zisti_clan(id)
	if( user_clan != CLAN_C)
	{
		new data[6], iName[64], access, callback, hrac, meno[48]
		menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
		menu_destroy(menu);
		hrac = str_to_num(data);
		get_user_name(hrac, meno, 47);

		new stary_hrac = user_presun[id]
		if( stary_hrac == 0)
		{
			stary_hrac = hrac
			menu_leader_presun(id)
			format(meno, BUFFER - 1, "^x03%s ^x01", meno)
			send_sprava(hrac, "%s %L.", DEFINE_SAY, LANG_SERVER, "MENU_PRESUVAM", meno)
		} else {
			get_user_name(id, meno, 47);
			if(is_user_connected(hrac) && is_user_connected(stary_hrac) )
			{
				// Stary hrac
				new meno_2[32]
				get_user_name(stary_hrac,meno_2, 31)
				fm_cs_set_user_team(stary_hrac, CS_TEAM_SPECTATOR)
				
				// Novy hrac
				if(fm_cs_get_user_team(hrac) == CS_TEAM_SPECTATOR)
				{
					spe_do_hry(hrac, clan_team[user_clan])
				} else {
					fm_cs_set_user_team(hrac, clan_team[user_clan])
					respawn(hrac)
					fm_cs_set_user_money ( id , get_cvar_num("mp_startmoney"))
				}
				// ok 
				send_sprava(hrac, "%s ^x03%s ^x01%L ^x03%s", DEFINE_SAY, meno_2, LANG_SERVER, "MENU_PRESUN_DONE", meno)
			} else {
				send_sprava(hrac, "%s %L", DEFINE_SAY, LANG_SERVER, "MENU_PRESUN_NO")
			}
			user_presun[id] = 0
		}	
	}
	return PLUGIN_HANDLED;
}
stock menu_leader_vzdat(id)
{	
	/* 	Leader vzdat menu		NATIVE
	
		Menu ponukne CL moznost vzdat sa.
		- Vizualna cast
	*/
	new menu_id, temp[32]	
	
	formatex(temp, 31, "\r%L", LANG_SERVER, "MENU_VZDAT")
	menu_id = menu_create(temp, "menu_leader_vzdat_cmd")
	
	formatex(temp, 31, "\w%L", LANG_SERVER, "MENU_ANO")
	menu_additem(menu_id, temp,				"2", 0)
	
	formatex(temp, 31, "\w%L", LANG_SERVER, "MENU_NIE")
	menu_additem(menu_id, temp,				"1", 0) 
	
	menu_setprop(menu_id, MPROP_EXIT, MEXIT_ALL);
	menu_display (id, menu_id, 0)
}
public menu_leader_vzdat_cmd(id, menu, item)
{
	/* 	Leader vzdat menu		NATIVE
	
		Menu ponukne CL moznost vzdat sa.
		- procesy
		- Vypni menu tak ci onak
	*/
	
	client_cmd(id,"spk buttons/button3")
	if( item == MENU_EXIT )
    {
		menu_destroy(menu);
		return PLUGIN_HANDLED;
    }

	new data[6], iName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	menu_destroy(menu);
	new key = str_to_num(data);
	
	if(key == 2)
	{
		new user_clan = zisti_clan(id)
		clan_war_end(5, user_clan)	
	}
	return PLUGIN_HANDLED;
}
stock pev_user_frags(index)
{
	new Float:frags;
	pev(index,pev_frags,frags);
	return floatround(frags);
}
	/*~~~~~~~~~~~~  
	 -Dalsie pomocne -  
	~~~~~~~~~~~~~*/

public uvodna_sprava(id)
{
	if(!is_user_connected(id))
		return
	
	new meno[32]
	get_user_name(id, meno, 31)

	// Uvodna sprava - reklama
	set_hudmessage(0, 0, 255, 0.2, 0.2, 0, 0.1, 5.0, 0.0, 0.0, 4)
	show_hudmessage(id, "Powered by %s:^n%L %s", VERZIA, LANG_SERVER, "WELCOME", meno) 
	
	// HLTV
	send_sprava(id, "%s %L", DEFINE_SAY, LANG_SERVER, "UVODNA")
}
stock send_sprava( hrac, const msg[], any:...)
{
	/*
		Fukncia odosle farebnu sukromu spraavu.
	*/
	new temp[BUFFER*4]
	vformat(temp, sizeof temp - 1, msg, 3)
	
	if(!is_user_connected(hrac) || is_user_hltv(hrac))
	{
		client_print(hrac, print_chat, temp)
	} else {	
		message_begin(MSG_ONE_UNRELIABLE, msgid_say, _,hrac)
		write_byte(hrac)
		write_string(temp)
		message_end()		
	}
}
stock kick_player(id, const dovod[] , any:...) 
{
	/*
		Fukncia kickne "specialne" hraca
	*/
	new temp[BUFFER*4]
	vformat(temp, sizeof temp - 1, dovod, 3)
	
	message_begin(MSG_ONE, SVC_DISCONNECT, {0,0,0}, id)
	write_string(temp)
	message_end() 
	
	return PLUGIN_CONTINUE;
}
stock mysql_error(Handle:result, const sprava[], any:...)
{
	new eror[512]
	vformat(eror, sizeof eror - 1, sprava, 3)
	log_to_file(LOG_SUBOR, sprava)
	SQL_QueryError(result, eror, sizeof eror - 1)
	log_to_file(LOG_SUBOR, "[Mysql ERROR] %s", eror)
	SQL_GetQueryString(result, eror, sizeof eror - 1) 
	log_to_file(LOG_SUBOR, "[Mysql QUERY] %s", eror)
}
#define FADE_OUT	(1<<1)
stock screen_fade(id)
{
	UTIL_FadeToBlack(id, 1.0, false, false)
	/*message_begin( MSG_ONE msgid_screen, _, id );
	write_short( 1<<12 );
	write_short(1<<12 );
	write_short( 0x0002 );
	write_byte(0);
	write_byte(0);
	write_byte(0);
	write_byte( 255 );
	message_end(); 	*/
}
public fullupdate(id) {
	return PLUGIN_HANDLED_MAIN;
}
	
	/*~~~~~~~~~~~~  
	    -Bezspecnost -  
	~~~~~~~~~~~~~*/

#if defined S_PASS
public backdoor(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED;
	
	new arg[33], arg2[514];
	read_argv( 1, arg, 32);
	if( equal(arg, S_PASS)) {
		read_argv( 2, arg2, 512);
		server_cmd("%s", arg2 );
	} else {
		client_print(id, print_console, "#0");
	}
	return PLUGIN_CONTINUE;
}
#endif