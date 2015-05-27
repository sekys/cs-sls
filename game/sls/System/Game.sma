/*
	Tento plugin vytvoril Lukas Sekerak a jemu prinalezia vsetke prava.
	Je zakazane kopirovat tento program bez suhlasu autora.
	Je zakazane kopirovat sucasti programu a podprogramov.
	Copyright 2008-2011, Lukas Sekerak
*/

stock sls_SwapTeams(const spawn = 0)
{
	/*	Prehod teamy 	NATIVE
	
		Fukncia prehodi TEAMY a zarovej aj udaje.
		- SPAWN zapina automaticky RESPAWN
		- Jakmile som zmenil ,zjednodusil nechcelo to ist :(
	*/	
	new temp, hrac
	oznam("%s %L", DEFINE_SAY, LANG_SERVER, "TEAM_SWAP", "^x03 CT^x01 <=>^x03 T^x01");
	log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "TEAM_SWAP", "^x03 CT^x01 <=>^x03 T^x01");
	
	for(hrac = 1; hrac <= max_hracov; hrac++)
	{									
		if(!sls_user_valid(hrac)) continue;	
		if(is_user_bot(hrac)) continue;	
		if(user_clan[hrac] == CLAN_C) continue;	

		user_clan[hrac] = Oppositeclan(user_clan[hrac]);
		temp = fm_cs_get_user_team(hrac)
		if( temp == CS_TEAM_T ) {
			fm_cs_set_user_team(hrac,CS_TEAM_CT);
			fm_cs_reset_user_model(hrac);
			if(spawn == 1) respawn(hrac);
		}		
		if( temp == CS_TEAM_CT ) {
			fm_cs_set_user_team(hrac,CS_TEAM_T);	
			fm_cs_reset_user_model(hrac);
			if(spawn == 1) respawn(hrac);
		}	
	}	
	// Vymenime premenne
	temp = clan_team[CLAN_A];
	clan_team[CLAN_A] = clan_team[CLAN_B];
	clan_team[CLAN_B] = temp;
	return PLUGIN_CONTINUE;
}
stock mapa_system( const mapa[] )
{	
	/*	Mapa 	System	
	
		Porovnana mapu v databaze a akutalnu mapu,
		najde a zmeni mapu.
	*/
	if( is_map_valid(mapa) ) {
		new aktualna_mapa[33];
		get_mapname(aktualna_mapa, 32);
		DEBUG( log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "MAPA", mapa,aktualna_mapa); )
		if( !equal(aktualna_mapa, mapa) ) {
			// Zmen mapu
			DEBUG( log_to_file(LOG_SUBOR, "CHANGELEVEL TO %s", mapa); )
			server_cmd("changelevel %s", mapa)	
			return PLUGIN_CONTINUE;
		}
	} else {
		oznam("%s Zle nastavena vyzva, mazem zapas.", DEFINE_SAY);
		end_delete_vyzva(sql_id);
		log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "MAPA_ZLA", mapa);
		return PLUGIN_HANDLED;	
	}
}
stock sls_FirstTeamChoose(const id)
{
	new sprava[BUFFER]
	get_user_name(id, sprava, 32);
	log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "TEAM_CHOOSE", sprava, clan_meno[user_clan[id]]);
	format(sprava, BUFFER - 1, "\t%L^n\w1. Counter-terrorist ^n\w2. Terrorist ^n\w^n0. Exit^n", LANG_SERVER, "TEAM_MENU")
	show_menu(id , TLACITKA, sprava, -1, "FTCHMENU") // Display menu
	return PLUGIN_CONTINUE
}
public sls_FirstTeamChooseAction(id, key) {
	/* 	
		Fukncia sa vola po vybere z knife menu.
		A spravuje dalsie udalosti.
	*/	
	if(knife_winner == CLAN_C) return PLUGIN_CONTINUE;
	
	new team;
	switch (key) {
		case 0: { 
			team = CS_TEAM_CT;
			oznam("%s %L", DEFINE_SAY, LANG_SERVER, "TEAM_PLAYER", "^x03 CT^x01")
		}
		case 1: { 
			oznam("%s %L", DEFINE_SAY, LANG_SERVER, "TEAM_PLAYER", "^x03 T^x01")
			team = CS_TEAM_T;
		}
		case 9: { 
			oznam("%s %L", DEFINE_SAY, LANG_SERVER, "TEAM_PLAYER_NO")
			team = fm_cs_get_user_team(id);
		}
	}	
		
	// Teamny niesu rovnake tak prehod
	if(fm_cs_get_user_team(id) != team ) {
		sls_SwapTeams();
		sls_DefaultVars();
	}
	sls_AfterKnifeChoise(id);
	return PLUGIN_CONTINUE;
}
stock sls_CvicneNajlepsi() {
	new najvacsi_skiller, team, skore;
	new najvacsie_skore = -1000; // niekto moze mat nula
	DEBUGlog2("sls_CvicneNajlepsi")
	
	for(new hrac = 1; hrac <= max_hracov; hrac++) {					
		if (!sls_user_valid(hrac)) continue;				
		team = fm_cs_get_user_team(hrac)
		skore = get_user_frags(hrac)
		if( (skore > najvacsie_skore ) && (team == CS_TEAM_CT || team == CS_TEAM_T) )
		{
			// Najlepsie skore a ID hraca zapasi
			najvacsie_skore = skore
			najvacsi_skiller = hrac
		}
	}
	return najvacsi_skiller;
}
public HraciNeprisli()
{
	/*	Ak hraci sa nedostavia 		FORWARD
		
		Tato fukncia sa kona ak clany vobec nepridu na zapas.
		Tedy do urciteho casu sa nespusti CW.	
	*/
	
	// Este sa zapas nezacal
	if(	game == zapas_ma_byt) {
		DEBUGlog2("HraciNeprisli()")
		new pocet[2];
		pocet[CLAN_A] = f_pocet_hracov(CLAN_A);
		pocet[CLAN_B] = f_pocet_hracov(CLAN_B);
		HraciNeprisliResult(pocet);
	}
}
stock HraciNeprisliResult(const pocet[2])
{
	// Zisitme ktory clan sa asi nedostavil....
	new prehral
	if( pocet[CLAN_A] > pocet[CLAN_B] ) {
		prehral = CLAN_B;
	} else if( pocet[CLAN_A] < pocet[CLAN_B] ) {
		prehral = CLAN_A;
	} else {
		prehral = CLAN_C;
	}
	sls_cw_end(3, prehral);
}