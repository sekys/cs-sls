/*
	Tento plugin vytvoril Lukas Sekerak a jemu prinalezia vsetke prava.
	Je zakazane kopirovat tento program bez suhlasu autora.
	Je zakazane kopirovat sucasti programu a podprogramov.
	Copyright 2008-2011, Lukas Sekerak
*/

public plugin_cfg() 
{	
	// Nacitame CVAR
	LoadConfig();
	new temp[64]
	cache_cvars();
	get_cvar_string("sv_password", sv_password, 63) 		
	get_pcvar_string(CONFIG_LOG_SUBOR, LOG_SUBOR, 63) 
	get_pcvar_string(CONFIG_ADMIN, temp, 63) 
	ADMIN = read_flags(temp)
	
	// Logy
	get_time("%Y.%m.%d", temp, 12)
	format(LOG_SUBOR, 63, "%s_%d_%s.log", LOG_SUBOR, gcached_CONFIG_ID, temp)	
	format(DEFINE_SAY, 31, "^x04%L^x01", LANG_SERVER, "SAY");
	
	log_to_file(LOG_SUBOR, "Powered by %s",VERZIA);
	DEBUG( log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "DEBUG", gcached_DEBUG); )
	
	set_task( 30.0, "spoj_databazu")
	setstatuslang("STATUS_1");
	game = zapas_sa_nekona;
	return PLUGIN_CONTINUE;
} 
stock sls_spoj_databazu() {	
	// Databaza Spojenie
	DEBUG(  log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "CONNECT"); )
	new ErrorCode, s_sql_ip[64], s_sql_meno[64], s_sql_heslo[64], s_sql_db[64], temp[512];
		
	// Data
	#if defined S_SQLIP
	format(s_sql_ip, 63, S_SQLIP);
	#else
	get_pcvar_string(SQL_IP, 	s_sql_ip, 63); 
	#endif
	
	#if defined S_SQLMENO
	format(s_sql_meno, 63, S_SQLMENO);
	#else
	get_pcvar_string(SQL_MENO, 	s_sql_meno, 63); 
	#endif
		
	#if defined S_SQLPASS
	format(s_sql_heslo, 63, S_SQLPASS);
	#else
	get_pcvar_string(SQL_HESLO, s_sql_heslo, 63);
	#endif
	
	#if defined S_SQLDB
	format(s_sql_db, 63, S_SQLDB);
	#else
	get_pcvar_string(SQL_DB, 	s_sql_db, 63);
	#endif
	
	databaza_cvar = SQL_MakeDbTuple(s_sql_ip, s_sql_meno,  s_sql_heslo, s_sql_db)
	databaza 	  = SQL_Connect(databaza_cvar, ErrorCode, temp, 511)
   
	if(databaza == Empty_Handle) {	
		log_to_file(LOG_SUBOR, "SQL");
		log_to_file(LOG_SUBOR, temp);
		format(status, 31, "%L", LANG_SERVER, "STATUS_2");
		return PLUGIN_HANDLED
	}	
	
	// Ci zapnuta liga...
	new Float:casovac = get_pcvar_float(CAS_KONTROLA);
	if(casovac > 0.0) {
		DEBUGlog2("Nastavujem server.")
		nastav_cvar();
		Task_zapasu();
		sls_PassChange();
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
	if( game > zapas_ma_byt ) {
		sls_cw_end(1, CLAN_C)
	}
	log_to_file(LOG_SUBOR, "SLS ENGINE OFF");
	if (databaza != Empty_Handle) {		
		SQL_FreeHandle(databaza) 
		SQL_FreeHandle(databaza_cvar) 
	}
}