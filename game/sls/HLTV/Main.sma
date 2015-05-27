/*
	Tento plugin vytvoril Lukas Sekerak a jemu prinalezia vsetke prava.
	Je zakazane kopirovat tento program bez suhlasu autora.
	Je zakazane kopirovat sucasti programu a podprogramov.
	Copyright 2008-2011, Lukas Sekerak
*/

	/*~~~~~~~~~~~~  
		-HLTV fukncie -  
	~~~~~~~~~~~~~*/

#if defined HLTV

#define HLTV_TASK	333


enum eHLTV_STATUS
{
	NOTCONNECTED,
	CONNECTED,
	RECORDING
};


// HLTV
new HLTV_IP, HLTV_PORT, HLTV_RCON, HLTV_MENO, HLTV_DELAY,
	HLTV_HOME_IP, HLTV_HOME_PORT, HLTV_AUTORETRY, HLTV_KICK_OTHER,
	
	eHLTV_STATUS:hltv_status, hltv_id, hltv_handle,
	hltv_command[256], recvattempts, query_in_progress,
	hltvrcon[32], demofile[32];

	
stock hltv_plugin_init() {	
	HLTVRegisterCvar();
	register_clcmd("cup_hltv_stop", 	"clcmd_hltv_stop", 	ADMIN_RCON , "Manualne zastavy nahravanie dema." );
	register_clcmd("cup_hltv_record", 	"clcmd_hltv_record", 	ADMIN_RCON , "Manualne spusti nahravanie dema." );
	
	// Defaultne
	hltv_status = NOTCONNECTED;
	hltv_id = 0;
	query_in_progress = 0;
}	
stock sls_hltv_access(const id) {
	if(!is_user_hltv(id)) return PLUGIN_CONTINUE;
	if(get_pcvar_num(HLTV_PORT) == 0) return PLUGIN_HANDLED;
	
	// Informacie
	new conIP[16], cvarIP[16];
	get_user_ip(id, conIP, sizeof conIP -1, 1);
	DEBUG( log_to_file(LOG_SUBOR, "HLTV pripaja sa (%s)", conIP); )
	get_pcvar_string(HLTV_IP, cvarIP, sizeof cvarIP -1)
	if(equal(conIP, cvarIP) || equal(conIP, "127.0.0.1")) {
		hltv_status = CONNECTED;
		hltv_id = id;
	} else {
		// Kickujeme cudzie hltvcka
		if(get_pcvar_num(HLTV_KICK_OTHER)) {
			kick_player(id, "Cudzie HLTV nieje povolene.");
			log_to_file(LOG_SUBOR, "[HLTV] Nepovolene HLTV (IP: %s)", conIP);
		}
	}
	return PLUGIN_HANDLED;
}
stock sls_hltv_disconnect(const id)
{
	if(id != hltv_id) return;
	// Nastav
	hltv_disconnect();
	hltv_status = NOTCONNECTED;
	hltv_id = 0;
}
stock sls_hltv_record()
{
	/*	HLTV natacaj demo
	
		Spusti nahravanie dema.....
	*/
	if(get_pcvar_num(HLTV_PORT) == 0) {
		DEBUG(log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "HLTV_OFF"); )
		return PLUGIN_HANDLED;
	}
	MakeDemoName();
	hltv_connect();
	return PLUGIN_CONTINUE;
}
stock sls_hltv_stop() 
{
	/*	HLTV ukonci
	
		Ukonci nahrtavanie dema a odpoji
		HLTV od gameserveru.
	*/
	if(get_pcvar_num(HLTV_PORT) == 0) return PLUGIN_CONTINUE;
	if(hltv_status == NOTCONNECTED) return PLUGIN_CONTINUE; // zbytocne zase by sa napajal
	query_in_progress=0;
	hltv_disconnect();		
	return PLUGIN_CONTINUE
}

#else
	stock hltv_plugin_init() { return PLUGIN_CONTINUE; }
	stock sls_hltv_access(const id) { return PLUGIN_CONTINUE; }
	stock sls_hltv_disconnect(const id) { }
	stock sls_hltv_record() { }
	stock sls_hltv_stop() { }
#endif