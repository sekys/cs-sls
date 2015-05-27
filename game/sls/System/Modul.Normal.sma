/*
	Tento plugin vytvoril Lukas Sekerak a jemu prinalezia vsetke prava.
	Je zakazane kopirovat tento program bez suhlasu autora.
	Je zakazane kopirovat sucasti programu a podprogramov.
	Copyright 2008-2011, Lukas Sekerak
*/

stock cw_SwitchDovod(const fail, const clan) {
	// Nastav defaultne veci
	new bonus[2], naroc[2], bodov[2], skore[2], temp[BUFFER]
	bonus[CLAN_A] = 0;
	bonus[CLAN_B] = 0;
	bodov[CLAN_A] = 0;
	bodov[CLAN_B] = 0;
	skore[CLAN_A] = clan_score[CLAN_A];
	skore[CLAN_B] = clan_score[CLAN_B];
	naroc[CLAN_A] = end_obtiaznost(CLAN_A);
	naroc[CLAN_B] = end_obtiaznost(CLAN_B);	
	
	// Hladaj 
	switch (fail) {
		case 0: { // Normalne - clan kto vyhral alebo remiza
			oznam("%s %L", DEFINE_SAY, LANG_SERVER, "END_OK", "^x03")
			if(clan == CLAN_C) {
				bodov[CLAN_A] = 1;
				bodov[CLAN_B] = 1;
				format(temp, BUFFER-1, "Nastala remiza");
			} else {
				bodov[clan] = 2; 
				bodov[Oppositeclan(clan)] = -1;
				format(temp, BUFFER-1, "Zapas vyhral %s.", clan_meno[clan]);
			}
		}
		case 1: { // Clan war ukonceny pre technicku chybu.
			format(temp, BUFFER-1, "%L", LANG_SERVER, "END_1_WEB");
			oznam("%s %L", DEFINE_SAY, LANG_SERVER, "END_1_HRA")
		}
		case 2: { // Hraci nestihli dohrat zapas.
			format(temp, BUFFER-1, "%L", LANG_SERVER, "END_2_WEB");
			oznam("%s %L", DEFINE_SAY, LANG_SERVER, "END_2_HRA")
		}			
		case 3: { // Clan war ukonceny, %s neprisli na zapas
			if(clan != CLAN_C) {
				bodov[clan] = -5; 
				bodov[Oppositeclan(clan)] = 1;
				format(temp, BUFFER-1, "%L", LANG_SERVER, "END_3_WEB", clan_meno[clan]);
				oznam("%s %L", DEFINE_SAY, LANG_SERVER, "END_3_HRA", clan_meno[clan])
			} else {
				bodov[CLAN_A] = -5; 
				bodov[CLAN_B] = -5;
				format(temp, BUFFER-1, "%L", LANG_SERVER, "END_3_WEB_B");
				oznam("%s %L", DEFINE_SAY, LANG_SERVER, "END_3_HRA_B")
			}
		}		
		case 4: { // Ukoncujem zapas. Dovod: Nesedi rozmiestnenie / minimalny pocet hracov pre clan: %s
			bodov[clan] = -1; 
			bodov[Oppositeclan(clan)] = 2;
			format(temp, BUFFER-1, "%L", LANG_SERVER, "END_4_WEB", clan_meno[clan]);
			oznam("%s %L", DEFINE_SAY, LANG_SERVER, "END_4_HRA", clan_meno[clan])
		}		
		case 5: { // %s clan sa vzdal !
			bodov[clan] = -1; 
			bodov[Oppositeclan(clan)] = 2;
			format(temp, BUFFER-1, "%L", LANG_SERVER, "END_5_WEB", clan_meno[clan]);
			oznam("%s %L", DEFINE_SAY, LANG_SERVER, "END_5_HRA", clan_meno[clan])	
		}
		case 6: { // Ukoncujem zapas. Cely %s clan utiekol .
			bodov[clan] = -1; 
			bodov[Oppositeclan(clan)] = 2;
			format(temp, BUFFER-1, "%L", LANG_SERVER, "END_6_WEB", clan_meno[clan]);
			oznam("%s %L", DEFINE_SAY, LANG_SERVER, "END_6_HRA", clan_meno[clan])
		}	
		case 7: { // Nastal debakel clan vyhercu, remiza nieje
			bodov[clan] = 2; 
			bodov[Oppositeclan(clan)] = -1;
			format(temp, BUFFER-1, "%L", LANG_SERVER, "END_7_HRA", clan_meno[clan], get_pcvar_num(KOL_DEBAKEL));
			oznam("%s %s", DEFINE_SAY, temp)
		}
	}
	// Posli dalej
	end_system(bodov, skore, bonus, naroc, fail, clan, temp);
}