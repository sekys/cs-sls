/*
	Tento plugin vytvoril Lukas Sekerak a jemu prinalezia vsetke prava.
	Je zakazane kopirovat tento program bez suhlasu autora.
	Je zakazane kopirovat sucasti programu a podprogramov.
	Copyright 2008-2011, Lukas Sekerak
*/

	/*~~~~~~~~~~~~  
	 -Pomocne fukncie -  
	~~~~~~~~~~~~~*/

stock FindWinner() {
	if(clan_score[CLAN_A] > clan_score[CLAN_B]) return CLAN_A;
	else if(clan_score[CLAN_A] < clan_score[CLAN_B]) return CLAN_B;
	return CLAN_C;
}
stock Oppositeclan(const clan) { return (clan == CLAN_A) ? CLAN_B : CLAN_A; }
stock EndRound(const Float:cas = 1.0) { set_cvar_float("sv_restart", cas); }
stock is_admin(const id) { return (get_user_flags(id) & ADMIN ); }
stock PlayerWithMaxHodnost(const clan) {
	new hrac, max_id = 0, max_hodnost = 10000;
	for(hrac = 1; hrac <= max_hracov; hrac++) {					
		if(!sls_user_valid(hrac)) continue;		
		if(user_clan[hrac] != clan) continue;	
		if( max_hodnost > user_hodnost[hrac]) {
			max_hodnost = user_hodnost[hrac];
			max_id = hrac;
		}
	}
	return max_id;
}
stock PlayerWithHodnost(const clan, const hodnost)
{
	for(new hrac = 1; hrac <= max_hracov; hrac++) {					
		if(!sls_user_valid(hrac)) continue;		
		if(user_hodnost[hrac] != hodnost) continue;		
		if(user_clan[hrac] == clan) return hrac;
	}
	return 0;
}
stock f_pocet_hracov(const id)
{				
	/*	Funkcia kontrola hracov 		NATIVE
		
		Tato fukncia kontrolu hracov v teame a
		vracia aktualny pocet clenov clanu
		- id je clan_a alebo clan_b	
	*/
	new temp = 0;	
		
	for(new hrac = 1; hrac <= max_hracov; hrac++) {
		if(!sls_user_valid(hrac)) continue;		
		if( user_clan[hrac] == id) {
			// Kontrola teamu
			if( fm_cs_get_user_team(hrac) == clan_team[id]) {
				// Kontrola poctu
				temp++;
			} 
		}
	}
	return temp;
}
stock SpeToGame(const id, const team)
{
	/*	 SPE do TEAMU		NATIVE
	
		Primitivna fukncia , pre HUD BUG, preradi hraca z
		SPE teamu do T alebo CT.	
	*/
	user_menu[id] = true;
	// Pre HUD BUG
	engclient_cmd(id,"jointeam", team == CS_TEAM_T ? "1" : "2");
	engclient_cmd(id,"joinclass", "1");
	engclient_cmd(id,"slot1");
	
	respawn(id);
	DefaultMoney(id);
	user_menu[id] = false;
	DEBUG2( log_to_file(LOG_SUBOR,"SpeToGame(%d,%d)", id, team); )
	return PLUGIN_CONTINUE;
}
stock UserDefaultScore(const hrac) {
	fm_set_user_frags(hrac,0)				
	fm_cs_set_user_deaths(hrac,0)
	// Vizualna cast pre hraca
	message_begin(MSG_ALL, msgid_score_info)
	write_byte(hrac)        //Player
	write_short(0) //F
	write_short(0) //D
	write_short(0)       
	write_short(fm_cs_get_user_team(hrac))  //Team
	message_end()
}
stock sls_DefaultVars()
{
	/*	Nulacia premmenych 	NATIVE
	
		Fukncia vynuluje vsetke premmene a stare udaje z minuleho CW.
		Snazi sa taktiez vizualne prepisat hracove skore.	
	*/
	
	// Statistyky su same restartovane ak sa prehodi team tak vsetko je od 0	
	for(new hrac = 1; hrac <= max_hracov; hrac++)
	{					
		if(!sls_user_valid(hrac)) continue;
		UserDefaultScore(hrac);
	}
	DefaultsMoney();
	
	// Premenne
	clan_score[CLAN_A] = 0
	clan_score[CLAN_B] = 0
	clan_vymena_score[CLAN_A] = 0
	clan_vymena_score[CLAN_B] = 0
	DEBUG2( log_to_file(LOG_SUBOR, "sls_DefaultVars()"); )
}
stock ClanScoreWinner() {
	if(clan_score[CLAN_A] > clan_score[CLAN_B]) {
		return CLAN_A;
	} else if(clan_score[CLAN_A] < clan_score[CLAN_B]) {
		return CLAN_B;
	}
	return CLAN_C;
}
public clcmd_respawn(id,level,cid)
{
	/*	Admin respawn	NATIVE
	
		Admin fukncia respawne hraca.
	*/
	if (!cmd_access(id,level,cid,2)) return PLUGIN_HANDLED
	new parameter[32], parameter_2[4]
	read_argv( 2, parameter, sizeof parameter - 1)
	new ciel = cmd_target (id, parameter, 3);

	if (!ciel) {
        client_print(id, print_console, "(!) %L", LANG_SERVER, "HRAC_NO");
        return PLUGIN_HANDLED;
    }

	read_argv(1, parameter_2, sizeof parameter_2 - 1)
	new team = str_to_num(parameter_2)

	if(fm_cs_get_user_team(ciel) == CS_TEAM_SPECTATOR) {
		SpeToGame(ciel, team)
	} else {
		fm_cs_set_user_team(ciel, team)
		respawn(ciel)
	}

	DEBUG2( log_to_file(LOG_SUBOR,"clcmd_respawn(%s,%d)", parameter, team); )
	return PLUGIN_CONTINUE
}
stock sls_PassChange()
{
	/*	Heslo on / off 	NATIVE
	
		Fukncia riadi automaticke  heslovanie a odheslovanie serveru.
	*/
	if(!get_pcvar_num(CONFIG_PASS)) return PLUGIN_CONTINUE
	if(zapas_sa_nekona != game) {
		set_cvar_string ("sv_password", "") 
		server_cmd("sv_password ^"^"")
	} else {
		set_cvar_string ("sv_password", sv_password) 
		LoadConfig();
	}
	return PLUGIN_CONTINUE
}
stock LoadConfig() {
	static config[64];
	get_configsdir(config, 63);
	server_cmd("exec %s/cup.cfg", config);
}