/*
	Tento plugin vytvoril Lukas Sekerak a jemu prinalezia vsetke prava.
	Je zakazane kopirovat tento program bez suhlasu autora.
	Je zakazane kopirovat sucasti programu a podprogramov.
	Copyright 2008-2011, Lukas Sekerak
*/

stock clan_get(const clan, const cindex) {
	// Informacie o clanoch
	new s_sql_clan[64], Handle:result;
	get_pcvar_string(SQL_CLAN, s_sql_clan, 63); 							
													
	// Clan 				
	result = SQL_PrepareQuery(databaza,"SELECT meno, tag, bonus FROM %s WHERE id= '%i'", s_sql_clan, clan) 
	if (!SQL_Execute(result)) {	
		mysql_error(result, "clan_get %i", clan);
		return PLUGIN_HANDLED
	}
	
	if (SQL_NumResults(result) == 0) { 
		new sprava[BUFFER]
		formatex(sprava, BUFFER - 1, "%s %L", DEFINE_SAY, LANG_SERVER, "CLAN_NO", clan)
		log_to_file(LOG_SUBOR, sprava)
		set_task(get_pcvar_float(CAS_INTERVAL_SPRAV), "oznam", TASK_OZNAM, sprava, BUFFER - 1, "b")
		end_delete_vyzva(sql_id)
		SQL_FreeHandle(result)
		return PLUGIN_HANDLED
	}
	clan_id[cindex] = clan;					
	SQL_ReadResult(result, 0, clan_meno[cindex],64);
	SQL_ReadResult(result, 1, clan_tag[cindex],	32);
	// Bonus
	clan_bonus[cindex] = SQL_ReadResult(result, 2)					
	SQL_FreeHandle(result)
	return PLUGIN_CONTINUE;
}
stock cw_ReAccesToServer() {
	// Kickovanie uz prihlasenych hracov	
	for(new hrac = 1; hrac <= max_hracov; hrac++) {	
		if(!sls_user_valid(hrac)) continue;	
		// Vsetkyich hracov kontrolujeme	
		sls_cw_access(hrac);
	}
}
stock cw_StartTasks() {
	// Task ulohy
	new Float:cas					
	remove_task(TASK_OZNAM)
	
	// Ukoncime tak ci onak + kontrola hracov.....
	cas = get_pcvar_float(CAS_MUSIA_STIHNUT)
	if( cas > 0.0) {
		new arg[2]; 
		arg[0] = 2;
		arg[1] = CLAN_C;
		set_task( cas, "sls_cw_end", TASK_FAIL, arg, 2, "a", 1)
	}
	
	// Ak hraci nepridu do 30 min				
	cas = get_pcvar_float(CAS_HRACI_NEPRIDU)
	if( cas > 0.0) {
		set_task( cas , "HraciNeprisli", TASK_END, _, _, "a", 1)
	}
	
	// Task hud infa
	cas = get_pcvar_float(CAS_HUD_INTERVAL);
	if(cas > 0.0) {
		set_task(cas, "sls_Hud", TASK_HUD, _, _, "b");
	}	
}
stock cw_StartDemos() {
	if(!get_pcvar_num(CONFIG_DEMO)) return;
	new sprava[BUFFER];	
	formatex(sprava, BUFFER - 1, "record cup_%d", sql_id);
	for(new hrac = 1; hrac <= max_hracov; hrac++) {					
		if(!sls_user_valid(hrac)) continue;			
		client_cmd(hrac, sprava);
	}
}
stock cw_EndDemos() {
	if(!get_pcvar_num(CONFIG_DEMO)) return;	
	for(new hrac = 1; hrac <= max_hracov; hrac++) {					
		if(!sls_user_valid(hrac)) continue;							
		client_cmd(hrac, "+showscores");
		screenshot(hrac, SCREEN_0, "Koniec zapasu");
		client_cmd(hrac, "-showscores");
		client_cmd(hrac, "stoprecord");
	}
}