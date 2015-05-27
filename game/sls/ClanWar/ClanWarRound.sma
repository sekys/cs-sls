/*
	Tento plugin vytvoril Lukas Sekerak a jemu prinalezia vsetke prava.
	Je zakazane kopirovat tento program bez suhlasu autora.
	Je zakazane kopirovat sucasti programu a podprogramov.
	Copyright 2008-2011, Lukas Sekerak
*/

public sls_cw_round() // nove kolo
{
	/*	CW Nove kolo		FORWARD
	
		Event sa vola akzde nove kolo....
	*/
	switch(game) {
		case zapas_ma_byt: {
			
		}
		case zapas_sa_nekona: {
			
		}
		case cvicne_kolo: {
			kol++;
			q_CheckQuota();
			cw_CvicneRound();
		}
		case knife_kolo: {
			kol++;
			q_CheckQuota();
			cw_KnifeRound();
		}
		case normal_kolo: {
			kol++;
			q_CheckQuota();
			cw_NormalRound();
		}
	}
	return PLUGIN_CONTINUE;
}
public sls_cw_endround()
{
	// Na konci knife kola
	if(game == knife_kolo && kol == 1) {
		sls_KnifeEndRound();
	}
}
stock cw_NormalRound() {
	// Oznamy
	DEBUGlog2("CWR Normal")
	DEBUG( log_to_file(LOG_SUBOR,"%L %i", LANG_SERVER, "KOLO", kol); )
	oznam("%s ^x03%i.^x01 %L !", DEFINE_SAY, kol, LANG_SERVER, "KOLO");
	setstatus("%i. %L", kol, LANG_SERVER, "KOLO");	
	
	static hra, team;
	hra = get_pcvar_num(KOL_HRA);
	team = get_pcvar_num(KOL_TEAM);
											
	// Prehadzuje team
	if(kol == team && team > 0) {
		clan_vymena_score[CLAN_A] = clan_score[CLAN_A];		
		clan_vymena_score[CLAN_B] = clan_score[CLAN_B];	
		sls_SwapTeams(1);	
		DropWeaponsAll();
		ClearWeaponsAll();
		DefaultsWeapon();
		DefaultsMoney();
	}
	// Kontrola ci skor nevyhral
	RETURNH(cw_Debakel())

	// Posledne
	if(hra > 0) {
		if(kol == hra) {
			oznam("%s %L", DEFINE_SAY, LANG_SERVER, "KOLO_LAST")
		}			
		// Koniec
		if(kol == hra + 1) {
			new winner = ClanScoreWinner();
			if(winner == CLAN_C) { // Vynimka ?
				kol--;
				oznam("%s Nastala remiza, predlzujem hru o 1 kolo.", DEFINE_SAY);
				log_to_file(LOG_SUBOR, "Nastala remiza, predlzujem hru o 1 kolo.");
				return PLUGIN_HANDLED;
			}
			sls_cw_end(0, winner);
		}
	}
	return PLUGIN_CONTINUE;
}
stock cw_Debakel() {
	static debakel;
	debakel = get_pcvar_num(KOL_DEBAKEL);
	
	if(clan_score[CLAN_A] == debakel) {
		sls_cw_end(7, CLAN_A);
		return PLUGIN_HANDLED;
	}
	if(clan_score[CLAN_B] == debakel) {
		sls_cw_end(7, CLAN_B);
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}