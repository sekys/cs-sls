/*
	Tento plugin vytvoril Lukas Sekerak a jemu prinalezia vsetke prava.
	Je zakazane kopirovat tento program bez suhlasu autora.
	Je zakazane kopirovat sucasti programu a podprogramov.
	Copyright 2008-2011, Lukas Sekerak
*/

public Task_zapasu() {
	remove_task(TASK_OZNAM) 	// Nech nevznika duplicita oznamu
	RETURNH(security_task_zapasu())
	
	// Premmenne
	cache_cvars();
	static Float:casovac;
	casovac = get_pcvar_float(CAS_KONTROLA);		
	
	// Task
	if(game == zapas_sa_nekona) {
		RETURNH( sls_task(casovac, get_systime()) )
	}
	set_task(casovac, "Task_zapasu");
	return PLUGIN_CONTINUE;
}
stock cache_cvars() {
	gcached_DEBUG = get_pcvar_num(DEBUG);
	gcached_CONFIG_ID = get_pcvar_num(CONFIG_ID);
	gcached_CONFIG_STEAM = get_pcvar_num(CONFIG_STEAM);
	gcached_CONFIG_MENO =  get_pcvar_num(CONFIG_MENO);
	gcached_CAS_UDVODNA_SPRAVA = get_pcvar_float(CAS_UDVODNA_SPRAVA);
	gcached_MIN_QUOTA = get_pcvar_num(MIN_QUOTA);
	gcached_MINTOEND = get_pcvar_num(MIN_TOEND);
	gcached_TAWP_TEST = get_pcvar_num(TAWP_TEST);
	gcached_TAWP_RAND = get_pcvar_num(TAWP_RAND);
	gcached_CONFIG_ADMINPLA = get_pcvar_num(CONFIG_ADMINPLA);
	gcached_KOL_CVICNE = get_pcvar_num(KOL_CVICNE);
	gcached_CONFIG_BLOCKSPE = get_pcvar_num(CONFIG_BLOCKSPE);
	 
	// Strings
	get_pcvar_string(SQL_USERS, gcached_SQL_USERS, 63);
	get_pcvar_string(SQL_TESTY, gcached_SQL_TESTY, 63);
	get_pcvar_string(CONFIG_LOG_SUBOR, LOG_SUBOR, 63) 
	
	// Misc
	static temp[64];	
	format_time(temp, 12, "%Y.%m.%d", get_systime()); 		
	format(LOG_SUBOR, 63, "%s_%d_%s.log", LOG_SUBOR, gcached_CONFIG_ID, temp);		
	get_pcvar_string(CONFIG_ADMIN, temp, 63); 
	ADMIN = read_flags(temp);
}
stock sls_task(const Float:casovac, const cas_aktualny)
{
	/* 	Task zapasu FORWARD
		
		Fukncia hlada pre ligovy system zapas.
		Zaroven vytiahne vsetke potrebne udaje.
		A je neustale obnovovana.	
	*/
	
	if (databaza == Empty_Handle) {
		new sprava[BUFFER]
		format(sprava, BUFFER - 1, "%s %L", DEFINE_SAY, LANG_SERVER, "ERROR_DATABASE");	
		log_to_file(LOG_SUBOR,sprava);		
		set_task(get_pcvar_float(CAS_INTERVAL_SPRAV), "oznam", TASK_OZNAM, sprava, BUFFER - 1, "b");
		return PLUGIN_HANDLED;
	}		
	setstatus("Cakam na zapas...");
	
	// Pripravyme premenne
	static Handle:sqlresult;
	static rozsah;
	static s_sql_vyzva[64];
	static vysledok;
	rozsah = cas_aktualny - floatround(casovac) - 600;	// server nestacil za 3 min an izmenit mapu pretodame dalsie
	get_pcvar_string(SQL_VYZVA, s_sql_vyzva, 63)			
	DEBUG( log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "VYZVA"); )
	
	// Spojenie ok , hladaj....
	sqlresult = SQL_PrepareQuery(databaza,
		"SELECT * FROM %s WHERE ziada IS NOT NULL AND prijal IS NOT NULL AND server = '%d' AND datum > '%d' AND datum < '%d' ORDER BY datum LIMIT 1",
		s_sql_vyzva, gcached_CONFIG_ID, rozsah, cas_aktualny) 	   
	vysledok = sls_task_result(sqlresult);
	SQL_FreeHandle(sqlresult);
	return vysledok;
}
sls_task_result(Handle:result) {
	if(!SQL_Execute(result)) {	
		new sprava[BUFFER];
		format(sprava, BUFFER - 1, "%s %L", DEFINE_SAY, LANG_SERVER, "ERROR_ZAPAS");
		log_to_file(LOG_SUBOR, sprava);
		set_task(get_pcvar_float(CAS_INTERVAL_SPRAV), "oznam", TASK_OZNAM, sprava, BUFFER - 1, "b");	
		return PLUGIN_HANDLED;		
	}
	if (SQL_NumResults(result) == 0) { 	
		new sprava[BUFFER];
		format(sprava, BUFFER - 1, "%s %L", DEFINE_SAY, LANG_SERVER, "NO_VYZVA");
		log_to_file(LOG_SUBOR, sprava);
		set_task(get_pcvar_float(CAS_INTERVAL_SPRAV), "oznam", TASK_OZNAM, sprava, BUFFER - 1, "b");
	} else {								
		sls_cw_find(result);
	}
	return PLUGIN_CONTINUE;
}