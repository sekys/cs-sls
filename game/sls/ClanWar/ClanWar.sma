/*
	Tento plugin vytvoril Lukas Sekerak a jemu prinalezia vsetke prava.
	Je zakazane kopirovat tento program bez suhlasu autora.
	Je zakazane kopirovat sucasti programu a podprogramov.
	Copyright 2008-2011, Lukas Sekerak
*/

	/*~~~~~~~~~~~~  
	   - CW udalosti -  
	~~~~~~~~~~~~~*/
	
stock sls_cw_find(const Handle:zaznam)
{
	/*	CW Najdeny 	FORWARD
	
		Fukncia sa kona ak sa nejaky zapas najde.
		A riadi ostatne pod fukncie.
		Vstupne udaje su SQL typu.
	*/
	
	// Mapa system
	new mapa[33];
	SQL_ReadResult(zaznam, 4, mapa, 32);	
	RETURNH( mapa_system(mapa) )
	
	// Premmenne a Misc
	clan_bonus[CLAN_A] = 0;
	clan_bonus[CLAN_B] = 0;
	clan_team[CLAN_A] = CS_TEAM_CT;
	clan_team[CLAN_B] = CS_TEAM_T;		
	server_cmd("amx_reloadadmins");
	// nesmie tu byt server_exec() lebo pada server
	
	// Spracuj premenne
	new sql_prijal, sql_ziada
	sql_id 		= SQL_ReadResult(zaznam, 0);
	sql_ziada 	= SQL_ReadResult(zaznam, 1);
	sql_prijal 	= SQL_ReadResult(zaznam, 2);		
	cas_zapasu  = SQL_ReadResult(zaznam, 3);
	
	// Informacie
	new sprava[BUFFER];
	start_zapasu = get_systime();
	log_ciara();
	format_time(sprava, 32, "%Y.%m.%d o %H", cas_zapasu);
	format(sprava, BUFFER - 1, "%s %L", DEFINE_SAY, LANG_SERVER, "START", sprava );
	log_to_file(LOG_SUBOR,sprava);
	oznam(sprava);
	
	// Informacie o clanoch					
	RETURNH(clan_get(sql_ziada, CLAN_A))
	RETURNH(clan_get(sql_prijal, CLAN_B))
	if(DEBUGon()) {
		log_to_file(LOG_SUBOR, "%L A %i %s B %i %s", LANG_SERVER, "UDAJE", 
			clan_id[CLAN_A], clan_meno[CLAN_A], 
			clan_id[CLAN_B], clan_meno[CLAN_B] 
		);
	}
	// Pauzovanie
	clan_pause[0] = clan_pause[1] = get_pcvar_float(CAS_PAUZA);
	
	// Dalsie premenne 
	kol = 0;
	game = zapas_ma_byt;
	sls_PassChange();
	setstatuslang("STATUS_3");
	quota = gcached_MIN_QUOTA;	
	
	// Kickovanie uz prihlasenych hracov	
	cw_ReAccesToServer();
	q_CheckPlayersInTeams();
	
	// Task ulohy
	cw_StartTasks();
	sls_CanStartCW();
	return PLUGIN_CONTINUE;						
}
public sls_cw_start()
{
	/*	CW Zaciatok 	FORWARD
	
		Fukncia sa zapne ak sa zapne zapas.
		Teda uz je minimalny pocet hracov na servery.
	*/	
	if(zapas_ma_byt != game) return PLUGIN_HANDLED;
	
	// Cvar	
	game = cvicne_kolo;
	kol = 0;		
	oznam("%s %L", DEFINE_SAY, LANG_SERVER, "CVICNE", get_pcvar_num(KOL_CVICNE));	
	setstatuslang("STATUS_4");
	log_ciara();
	log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "STATUS_4");
	
	// Tasky
	set_task( get_pcvar_float(CAS_TAB_INTERVAL) ,"sls_UpdateScore",	TASK_TAB, _, _, "b");		
	
	// Dema u hracov
	cw_StartDemos();
	
	// Vynuluje statistiky z ak uz hrali....
	sls_DefaultVars();
	
	// spusti natacanie
	#if defined HLTV
	sls_hltv_record()
	#endif
	// RR
	EndRound();
	return PLUGIN_CONTINUE;
}
public sls_cw_end(const fail, const clan)
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
	
	game = zapas_sa_nekona;
	if(paused_server != PAUSE_NO) PauseEnd();
		
	// Status / dovod
	log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "END")
	cw_SwitchDovod(fail, clan);
	setstatuslang("STATUS_5") 
	log_ciara()
		
	// Kickujem hracov s dovodom +  vypinam server
	if(get_pcvar_float(CAS_DO_KICKU_HRACOV) > 0.0) set_task( get_pcvar_float(CAS_DO_KICKU_HRACOV), "end_kick_a_vypnut");
	// Dema u hracov a screeny
	cw_EndDemos();
	sls_PassChange();	
	// Odpoajam HLTV
	#if defined HLTV
	sls_hltv_stop()
	#endif		
}