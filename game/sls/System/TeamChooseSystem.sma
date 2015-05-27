/*
	Tento plugin vytvoril Lukas Sekerak a jemu prinalezia vsetke prava.
	Je zakazane kopirovat tento program bez suhlasu autora.
	Je zakazane kopirovat sucasti programu a podprogramov.
	Copyright 2008-2011, Lukas Sekerak
*/

stock sls_TeamChoose(const id, team) 
{
	/*   Vyber TEAM 			FORWARD
		- PLUGIN HANDLED nepovoli vybrat si team !
		- client_print jedine co moze vypisat....
	*/	
	// Filter
	if(is_user_hltv(id))  return PLUGIN_CONTINUE;
	// Kontroluje len ked bude zapas
	if(game == zapas_sa_nekona) return PLUGIN_CONTINUE;
	// Prepiseme scpectator, nech pouzivame uz definovane
	if( team == 6) team = 3;
	// SPectate je bloknuty ?
	if(sls_BlockSpectate(id, team)) return PLUGIN_HANDLED;
	// Hrac preskoci podmienky 	SPE -> T
	if(user_menu[id]) {
		DEBUG2( log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "HRAC_DO_SPE"); )
		return PLUGIN_CONTINUE;
	}
	
	if(game > zapas_ma_byt) return TeamChooseIngame(id, team);
	if(game == zapas_ma_byt) return TeamChooseInPrepare(id, team);
	return PLUGIN_CONTINUE;
}
stock TeamChooseInPrepare(const id, const team) 
{
	DEBUG2( log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "HRAC_PRIPRAVA", team); )
					
	// Znamena ze je z ........A clanu......... cize do CT
	if(user_clan[id] == CLAN_A) {
		if( team != CS_TEAM_SPECTATOR) {
			RETURNH(TeamChooseItem(id, team, CLAN_A, 1))	
		}
	} 
	// Znamena ze je z ........B clanu......... cize do T
	else if (user_clan[id] == CLAN_B ) {
		if( team != CS_TEAM_SPECTATOR) {
			RETURNH(TeamChooseItem(id, team, CLAN_B, 1))
		}		
	// Ani jedno...
	} else {
		if ( team != CS_TEAM_SPECTATOR) {
			client_print( id, print_chat, "%L %L", LANG_SERVER, "SAY", LANG_SERVER, "HRAC_DIVAK")	
			engclient_cmd(id,"chooseteam");
			return PLUGIN_HANDLED;
		}
	}	
	return PLUGIN_CONTINUE;
}
stock TeamChooseItem(const id, const team, const clan, const send) 
{
	if ( team != clan_team[clan]) {
		client_print( id, print_chat, "%L %L", LANG_SERVER, "SAY", LANG_SERVER, "HRAC_TEAM")	
		engclient_cmd(id,"chooseteam");
		return PLUGIN_HANDLED;
	}
	set_task(3.0, "sls_AfterTeamChoose", send);
	return PLUGIN_CONTINUE;
}
stock TeamChooseIngame(const id, const team) 
{
	DEBUG2( log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "HRAC_POCAS", team); )
	new pocet[2];
	pocet[CLAN_A] = f_pocet_hracov(CLAN_A);
	pocet[CLAN_B] = f_pocet_hracov(CLAN_B);
	
	// Rovnaky alebo vacsi pocet hracov
	if( pocet[CLAN_A] >= quota &&  pocet[CLAN_B] >= quota)
	{
		DEBUG2( log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "HRACI_OK"); )
		if ( team != CS_TEAM_SPECTATOR) {
			client_print( id, print_chat, "%L %L", LANG_SERVER, "SAY", LANG_SERVER, "HRAC_SPE")	
			engclient_cmd(id,"chooseteam");
			return PLUGIN_HANDLED;
		} else {
			q_CheckQuota();
		}
	} else {
	// QUOTA nesedi :
		// .......pre clan A ,prerad ....
		if( user_clan[id] == CLAN_A && pocet[CLAN_A] < gcached_MIN_QUOTA ) {
			RETURNH(TeamChooseItem(id, team, CLAN_A, 2))	
		// .......pre clan B ,prerad ....
		} else if ( user_clan[id] == CLAN_B && pocet[CLAN_B] < gcached_MIN_QUOTA  ) {
			RETURNH(TeamChooseItem(id, team, CLAN_B, 2))									
		// .......nema clan ,prerad ....
		} else {
			if ( team != CS_TEAM_SPECTATOR ) {
				client_print( id, print_chat, "%L %L", LANG_SERVER, "SAY", LANG_SERVER, "HRAC_DIVAK")	
				engclient_cmd(id, "chooseteam"); 
				return PLUGIN_HANDLED
			} 					
		}
	}	
	return PLUGIN_CONTINUE;
}
public sls_AfterTeamChoose(const id)
{
	/* 	Po vybere temu 		FORWARD
		
		Dalsia event fukncia, ktora sa deje hned po vybere teamu.
		A zapnia dalsie funkcie		
	*/
	// Hrac si vybral TEAm takze mozme spustit kontrolu
	DEBUG2( log_to_file(LOG_SUBOR, "sls_AfterTeamChoose(%i)", id); )
	new pocet[2];
	pocet[CLAN_A] = f_pocet_hracov(CLAN_A);
	pocet[CLAN_B] = f_pocet_hracov(CLAN_B);
	
	// Pocas zapasu naostro
	if(id == 2) {
		if( pocet[CLAN_A] >= gcached_MIN_QUOTA && pocet[CLAN_B] >= gcached_MIN_QUOTA ) {
			DEBUG2( log_to_file(LOG_SUBOR,"Odstranujem TASK"); )
			// Vypni casovace
			remove_task(TASK_PLAYER)
			remove_task(TASK_PLAYER_1)
			remove_task(TASK_PLAYER_2)
			remove_task(TASK_PLAYER_3)
		}
		q_CheckQuota()
	} 
	// Pred zapasom
	else if(id == 1) {
		if(!sls_CanStartCW()) {
			oznam("%s %L", DEFINE_SAY, LANG_SERVER, "HRAC_CAKAM")
			DEBUG2( log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "HRAC_CAKAM"); )
		} 
	}				
	return PLUGIN_CONTINUE
}
stock sls_CanStartCW() {
	if( f_pocet_hracov(CLAN_A) >= gcached_MIN_QUOTA 
		&& f_pocet_hracov(CLAN_B) >= gcached_MIN_QUOTA 
		&& game == zapas_ma_byt) // bug team vybera 2x a 2x vola clan war
	{
		// Start
		set_task(1.0, "sls_cw_start");
		return true;
	}
	return false;
}
stock sls_BlockSpectate(const id, const team) {
	if(team != 3) return false;
	if(!gcached_CONFIG_BLOCKSPE) return false;
	if(is_admin(id)) {
		client_print(id, print_chat, "%L %s", LANG_SERVER, "SAY", "Spectator team povoleny pre admina.")	
		return false;
	}
	client_print(id, print_chat, "%L %s", LANG_SERVER, "SAY", "Spectator team je zablokovany.")
	engclient_cmd(id,"chooseteam");
	return true;
}