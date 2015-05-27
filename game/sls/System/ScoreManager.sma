/*
	Tento plugin vytvoril Lukas Sekerak a jemu prinalezia vsetke prava.
	Je zakazane kopirovat tento program bez suhlasu autora.
	Je zakazane kopirovat sucasti programu a podprogramov.
	Copyright 2008-2011, Lukas Sekerak
*/

stock sls_ScoreGet(const team, const score)
{ 
	if(game == zapas_sa_nekona) return PLUGIN_CONTINUE;
	// Ci naozaj su T
	if (team == CS_TEAM_T) {
		sls_SetScore(score, clan_team[CLAN_B] == CS_TEAM_T ? CLAN_B : CLAN_A);
	}  else { // CT skore -  ci naozaj su CT
		sls_SetScore(score, clan_team[CLAN_A] == CS_TEAM_T ? CLAN_B : CLAN_A);
	}		
		
	// Vizualnu cast prepiseme	
	sls_UpdateScore();
	return PLUGIN_CONTINUE;
} 
stock sls_SetScore(const score, const team) {
	clan_score[team] = score - clan_vymena_score[ Oppositeclan(team) ] + clan_vymena_score[team];
	if(DEBUGon()) {
		client_print( 0, print_console,"%L %d = %d - %d + %d ", LANG_SERVER, "CLAN_SCORE", team == CLAN_A ? "A" : "B", clan_score[team], score, clan_vymena_score[Oppositeclan(team)], clan_vymena_score[team]);
	}
}
public sls_UpdateScore()
{
	/*	Nastavuje score teamov NATIVE
	
		Tato funkcia docasne dokaze pozmenit skore teamov.
		Preto musi byt obnovovana neustale.
	*/
	if(game == zapas_sa_nekona) return PLUGIN_HANDLED;	
	
	//Vizualnu cast sa meni 		
	ClanUpdateScore(CLAN_A);
	ClanUpdateScore(CLAN_B);
	return PLUGIN_CONTINUE;
}
stock ClanUpdateScore(const clan) {
	message_begin(MSG_ALL, msgid_team_score);
	write_string( clan_team[clan] == CS_TEAM_CT ? "CT" : "TERRORIST");
	write_short( clan_score[clan] );
	message_end();
}
/*	

//	Algoritmus 

Podla mojho vyskumu skore sa updatune 2x najprv pre T team a potom pre CT team.
Hore funkcie nam iba pomaha skore upresnit a dat do dobrych sltpcov v tabulke

team  	minule_kolo_skore 	terajsie_skore	oznacenie
  T			5				5			B
  CT			9				10			A

Vysledok :
							1.spustenie		2. spustenie			
				A:				9	          5
	Akutalny tema skore A : 5				    //		
	Akutalny tema skore A : 10				 //		
										 //		
				B:				10		5

9,5 su udaje z minulych kol , 10,5 ()sikmo spojene su terazjsie udaje.
Kedze sa to spustat 2x musime zapisat do inych cvar a do nejakeho eventu.
Ak teamu budu opacne sipka sa bude (opacne) zhora dole.
V hornej podmienke sa spusti len 1 cast.


//	Prefix
clan_score[CLAN_B] 	= 	score 	- 	clan_vymena_score[CLAN_A] 		+ 	clan_vymena_score[CLAN_B]
VYPOCET_B_SKORe 	= 	aktuaone_skore	-	stare_skore_a				+	stare_skore_ich

*/