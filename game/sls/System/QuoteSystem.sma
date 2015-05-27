/*
	Tento plugin vytvoril Lukas Sekerak a jemu prinalezia vsetke prava.
	Je zakazane kopirovat tento program bez suhlasu autora.
	Je zakazane kopirovat sucasti programu a podprogramov.
	Copyright 2008-2011, Lukas Sekerak
*/
	
	/*~~~~~~~~~~~~  
	  -Quota system -  
	~~~~~~~~~~~~~*/
stock q_CheckPlayersInTeams()
{
	/* Kontrola hracov v teame 	NATIVE
	
		Fukncia  pri roznych situaciah kontroluje hracov ci su kde maju byt.
		Zabrani tak vzniku bugu a komplikaciam v hre.
		- Vypnute 
	*/
	for(new hrac = 1; hrac <= max_hracov; hrac++) {					
		q_CheckPlayerInTeams(hrac);
	}	
}	
stock q_CheckPlayerInTeams(const hrac) {
	if(!sls_user_valid(hrac)) return;		
	static temp, team;
	temp = user_clan[hrac];
	team = fm_cs_get_user_team(hrac);
	
	// Nema clan...	SPE
	if( temp == CLAN_C) {	
		if(team != CS_TEAM_SPECTATOR) {
			checkandkill(hrac);
			fm_cs_set_user_team(hrac, CS_TEAM_SPECTATOR)
		}
	} else { // Ak ma clan...
		if( team != clan_team[temp]) {
			checkandkill(hrac);
			fm_cs_set_user_team(hrac,CS_TEAM_SPECTATOR)
		}
	}
}	
public q_CheckQuota()
{
	/* 	Funkcia kontroly a vypoctu quoty	NATIVE
		
		Hlavnou ulohou tejto fukncie je menit X on X
		A to dosiahneme ak v hre budu hraci v spectators 
		a ked bude rovnaky pocet tak priradime ich do teamu ak budu chciet..
		Kontrolu ci quota sedi aj z teamom ak nie tak jedneho vyhodi z teamu
	*/
	if( get_pcvar_num(KONTROLA_QUOTY) != 1) return PLUGIN_HANDLED;
	if(game < cvicne_kolo) return PLUGIN_CONTINUE;
	DEBUG2( log_to_file(LOG_SUBOR,"q_CheckQuota()"); )
	new pocet[2]
	pocet[CLAN_A] = f_pocet_hracov(CLAN_A)
	pocet[CLAN_B] = f_pocet_hracov(CLAN_B)
	
	if( pocet[CLAN_A] >= gcached_MIN_QUOTA && pocet[CLAN_B] >= gcached_MIN_QUOTA ) {
		DEBUG2( log_to_file(LOG_SUBOR,"Odstranujem TASK"); )
		remove_task(TASK_PLAYER)
		remove_task(TASK_PLAYER_1)
		remove_task(TASK_PLAYER_2)
		remove_task(TASK_PLAYER_3)	
	}
	q_CheckClans(pocet);
	return PLUGIN_CONTINUE
}
stock q_CheckClans(const pocet[2]) 
{
// Clan A ma malo hracov ,prerad...
	if( pocet[CLAN_A] > pocet[CLAN_B])		
	{
		if(!q_TeamAdd(CLAN_B))
		{
			if( pocet[CLAN_A] >= gcached_MIN_QUOTA && pocet[CLAN_B] >= gcached_MIN_QUOTA)
			{			
				// mozeme kicknut
				q_TeamDel(CLAN_A)
				//set_task( 3.0, "q_CheckQuota")
			}
		}
// Clan B ma malo hracov ,prerad...		
	} else if( pocet[CLAN_A] < pocet[CLAN_B] ) 		
	{
		if( !q_TeamAdd(CLAN_A))
		{
			if( pocet[CLAN_A] >= gcached_MIN_QUOTA && pocet[CLAN_B] >= gcached_MIN_QUOTA)
			{			
				// mozeme kicknut
				q_TeamDel(CLAN_B)
				//set_task( 5.0, "q_CheckQuota")
			}
		}
// Clany maju dobre hracov a sedi aj quota skus zvysit quotu a najst hracov		
	} else if( pocet[CLAN_A] == quota && pocet[CLAN_B] == quota) 
	{			
		if( q_TeamSearch() )
		{
			quota++;
			//set_task(5.0, "q_CheckQuota")
		}
// Clany maju dobre hracov ale quotu si samy zmenili....len downgradni		
	} else if( pocet[CLAN_A] == pocet[CLAN_B] )
	{
		quota = pocet[CLAN_A]
		//set_task( 5.0, "q_CheckQuota")
	}		
}
stock q_TeamAdd(const id)
{	
	/* 	Quota team / player add	NATIVE
	
		Fukncia skusi najst hraca v SPE team a priradi ho do hry...
		- Vracia TRUE ak uspeje....
	*/	
	for(new hrac = 1; hrac <= max_hracov; hrac++)
	{					
		if(!sls_user_valid(hrac)) continue;			
		if( fm_cs_get_user_team(hrac) == CS_TEAM_SPECTATOR )  { // len spectator	
			if( user_clan[hrac] == id) {
				SpeToGame(hrac,clan_team[id])
				DEBUG2( log_to_file(LOG_SUBOR,"q_TeamAdd(%s,true)",id == CLAN_A ? "A" : "B"); )
				return true;
			}		
		}
	}
	DEBUG2( log_to_file(LOG_SUBOR,"q_TeamAdd(%s,false)",id == CLAN_A ? "A" : "B"); )
	return false;	// nic nenaslo
}
stock q_TeamDel_Find(const id)
{	
	// Daj prec hraca s najmensim skore a skus mrtveho
	new player, playerscore = 2000;
	
	for(new hrac = 1; hrac <= max_hracov; hrac++) {					
		if(!sls_user_valid(hrac)) continue;		
		if( user_clan[hrac] == id) {
			if( fm_cs_get_user_team(hrac) == clan_team[id] ) {
				if( get_user_frags(hrac) < playerscore ) {
					playerscore = get_user_frags(hrac);
					player = hrac;
				}	
			}
		}			
	}	
	return player;
}
stock q_TeamDel(const id)
{	
	/* 	Quota team / player delete	NATIVE
	
		Funkcia preradi hraca do SPE teamu
		- Snazi sa najst najhorsieho hraca
		- Vracia TRUE ak uspeje....	
	*/	
	new hrac = q_TeamDel_Find(id);
										
	// Vystup
	if( hrac ) {
		fm_cs_set_user_team(hrac, CS_TEAM_SPECTATOR);		
		checkandkill(hrac);
		DEBUG2( log_to_file(LOG_SUBOR,"q_TeamDel(%s,true)",id == CLAN_A ? "A" : "B");)
		return true;
	}
	DEBUG2( log_to_file(LOG_SUBOR,"q_TeamDel(%s,false)",id == CLAN_A ? "A" : "B"); )
	return false;	// nic nespravilo
}
stock q_TeamSearch()
{	
	/* 	Quota team / player hladaj	NATIVE
	
		Fukncia najde 2 hracov .
		Jedneho z A clanu.
		Jedneho z B clanu.
		- Vracia TRUE ak uspeje....	
	*/
	new hrac, hrac_2 = 0, hrac_3=0;
	for(hrac = 1; hrac <= max_hracov; hrac++)
	{					
		if(!sls_user_valid(hrac)) continue;			
		if( fm_cs_get_user_team(hrac) == CS_TEAM_SPECTATOR ) // len spectator
		{
			if( user_clan[hrac] == CLAN_A ) hrac_2 = hrac;
			if( user_clan[hrac] == CLAN_B) hrac_3 = hrac;
		}	
	}	
	if( hrac_3 !=0 && hrac_2 !=0) {
		SpeToGame(hrac_2,clan_team[CLAN_A])	;	
		SpeToGame(hrac_3,clan_team[CLAN_B]);
		DEBUG2( log_to_file(LOG_SUBOR,"q_TeamSearch(true)"); )
		return true;
	}
	
	DEBUG2( log_to_file(LOG_SUBOR,"q_TeamSearch(false)"); )
	return false; // nic nenaslo 
}	