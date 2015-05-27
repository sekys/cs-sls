/*
	Tento plugin vytvoril Lukas Sekerak a jemu prinalezia vsetke prava.
	Je zakazane kopirovat tento program bez suhlasu autora.
	Je zakazane kopirovat sucasti programu a podprogramov.
	Copyright 2008-2011, Lukas Sekerak
*/

stock cw_CvicneRound() {
	// O uroven vyssie
	if(kol == gcached_KOL_CVICNE + 1) { // pre EndRound()v KnifePreStart
		game++;
		sls_KnifePreStart();
		return PLUGIN_HANDLED;
	}
	// Vsetko zariadi v cvicnom kole,...
	DEBUGlog2("CWR Cvicne")
	new sprava[BUFFER];
	formatex(sprava, BUFFER - 1, "^x03%i.^x01", kol);
	oznam("%s %L", DEFINE_SAY, LANG_SERVER, "KOLO_PREBIEHA", sprava);
	setstatus("%i. %L", kol, LANG_SERVER, "KOLO_CVICNE");
	DEBUG( log_to_file(LOG_SUBOR,"%L %i", LANG_SERVER, "KOLO_CVICNE", kol); )
	return PLUGIN_CONTINUE;
}
stock sls_KnifePreStart() {
	kol = 0;
	knife_winner = CLAN_C;
	EndRound();
}
stock cw_KnifeRound() {
	// Ak uz mame vybraneho vitaza...ale menu sa skrylo
	if(knife_winner != CLAN_C) {
		new id = PlayerWithMaxHodnost(knife_winner);
		// TODO: id == 0 exception !
		sls_FirstTeamChoose(id);
		return PLUGIN_CONTINUE;
	}
	// Spusti nam to len raz
	if(kol == 1) {
		sls_KnifeStartRound();	
	}
	return PLUGIN_CONTINUE;
}
stock sls_KnifeStartRound()
{		
	// Kolo zacina
	DEBUGlog2("CWR KnifeStart")
	BlockedWeapons = true;
	DropWeaponsAll();
	ClearWeaponsAll();
	sls_DefaultVars();
	clan_score[CLAN_A] = clan_score[CLAN_B] = 0;
	SetMoney(0);
	
	DEBUG( log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "KNIFE_START"); )
	oznam("%s Zacina sa knife kolo, team ktory vyhraje si vybera team.", DEFINE_SAY)
	setstatus("Knife kolo");
	return PLUGIN_CONTINUE;
}
stock sls_KnifeEndRound()
{		
	// Kolo konci
	DEBUGlog2("CWR KnifeEnd")
	BlockedWeapons = false;
	
	// Najdi najlepsi clan
	knife_winner = ClanScoreWinner();
	if(knife_winner == CLAN_C) {
		// Neziaduca situacia - exception
		sls_KnifePreStart();
		oznam("%s Knife kolo nevyhral ziadny clan, restartujem kolo.", DEFINE_SAY);
		log_to_file(LOG_SUBOR, "Knife kolo nevyhral ziadny clan, restartujem kolo.");
		return PLUGIN_HANDLED;
	}
		
	// Posli udaje
	new id = PlayerWithMaxHodnost(knife_winner);
	sls_KnifeMenu(id, knife_winner);
	sls_DefaultVars();
	return PLUGIN_CONTINUE;
}
stock sls_KnifeMenu(const id, const clan) {
	// Posli udaje	
	new meno[33], clanmeno[BUFFER];
	get_user_name(id, meno, 32);
	format(clanmeno, BUFFER - 1, "^x03 %s ^x01", clan_meno[clan]);
	DEBUG( log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "KNIFE_END"); )
	oznam("%s %L", DEFINE_SAY, LANG_SERVER, "KNIFE_WIN", clanmeno, meno)		
	sls_FirstTeamChoose(id);
}
stock sls_AfterKnifeChoise(const id) {
	sls_DefaultVars();
	clan_score[CLAN_A] = clan_score[CLAN_B] = 0;
	game++;
	kol=0;
	knife_winner = CLAN_C;
	EndRound();
}