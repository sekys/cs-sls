/*
	Tento plugin vytvoril Lukas Sekerak a jemu prinalezia vsetke prava.
	Je zakazane kopirovat tento program bez suhlasu autora.
	Je zakazane kopirovat sucasti programu a podprogramov.
	Copyright 2008-2011, Lukas Sekerak
*/

#if defined HLTV

stock HLTVRegisterCvar() {
	// Hltv
	HLTV_IP 			= register_cvar("cup_hltv_ip",			"127.0.0.1") 				// rovno na servery
	HLTV_PORT 			= register_cvar("cup_hltv_port",		"27015")					// nastav 0 ak chces vypnut cele HLTV
	HLTV_RCON			= register_cvar("cup_hltv_rcon",		"rcon_heslo")	
	HLTV_MENO			= register_cvar("cup_hltv_meno",		"GeCom HLTV")
	HLTV_DELAY			= register_cvar("cup_hltv_delay",		"0")
	HLTV_HOME_IP 		= register_cvar("cup_hltv_home_ip",		"0")						// ip servera , nastav 0 na samotnu identifikaciu
	HLTV_HOME_PORT		= register_cvar("cup_hltv_home_port",	"27018")					// port servera	
	HLTV_AUTORETRY		= register_cvar("cup_hltv_autoretry",	"1")						// automaticky pripoj pri kick ua pod
	HLTV_KICK_OTHER		= register_cvar("cup_hltv_kickother",	"1")
}
stock hltv_preparecvar()
{
	new tmp[32], pos = 0;
	// Meno
	get_pcvar_string(HLTV_MENO, tmp, 31);
	pos += formatex(hltv_command[pos], 96, "name '%s';", tmp);
	// Cvar
	pos += formatex(hltv_command[pos], 96, "delay %d;" , get_pcvar_num(HLTV_DELAY));
	pos += formatex(hltv_command[pos], 96, "autoretry %d;", get_pcvar_num(HLTV_AUTORETRY));	

	// Connect IP
	get_pcvar_string(HLTV_HOME_IP, tmp, 31);
	if( equal(tmp, "0")) {
		get_user_ip(0, tmp, 31,0);
	} else {
		format(tmp, 31, "%s:%d", tmp, get_pcvar_num(HLTV_HOME_PORT));
	}
	formatex(hltv_command[pos], 96, "connect %s", tmp);
}
public clcmd_hltv_record(id,level,cid) {
	// Admin prikaz na  nahravanie dema
	if(!cmd_access(id,level,cid,1))  return PLUGIN_HANDLED;
	sls_hltv_record();
	return PLUGIN_CONTINUE;
}
public clcmd_hltv_stop(id,level,cid) {
	// Admin prikaz na zastavenie nahravania
	if (!cmd_access(id,level,cid,1))  return PLUGIN_HANDLED;		
	sls_hltv_stop();
	return PLUGIN_CONTINUE;
}
stock HLTVGetRCon(rcon[], const max) {
	#if defined S_HLTVRCON
	copy(rcon, max, S_HLTVRCON);
	#else
	get_pcvar_string(HLTV_RCON, rcon, max);
	#endif
}
stock send_record_fail() {
	if(hltv_status > NOTCONNECTED) return PLUGIN_CONTINUE;	
	
	// Nastala chyba
	recvattempts += 1;
	if (recvattempts > 5) {
		log_to_file(LOG_SUBOR, "[HLTV] No HLTV is connected, sending ^"record^" command failed.");
		abort_query();			
		recvattempts = 0;		
		hltv_disconnect(); //only safety
	} else {
		if(DEBUGon()) {
			log_amx("[HLTV] waiting for hltv connect: %d sec", recvattempts);
		}
		set_task(1.0, "send_record");			
	}
	return PLUGIN_HANDLED;
}
stock hltv_connect()
{
	/*	HLTV pripoj 	NATIVE
	
		Vytvori spojenie s HLTV serverom...
	*/
	if(hltv_status > NOTCONNECTED) return PLUGIN_CONTINUE;	
	hltv_preparecvar();
	sock_open();	
	return PLUGIN_CONTINUE;
} 
public hltv_disconnect() {
	formatex(hltv_command, sizeof hltv_command -1, "stoprecording;autoretry 0;stop");
	if(task_exists(HLTV_TASK)) remove_task(HLTV_TASK);
	
	sock_open();
	hltv_status = NOTCONNECTED;
}
stock MakeDemoName() {	
	if(!sql_id) sql_id = 0;
	formatex(demofile, 31, "record cup_%d_%d", gcached_CONFIG_ID, sql_id);
}
#endif