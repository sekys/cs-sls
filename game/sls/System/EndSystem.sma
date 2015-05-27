/*
	Tento plugin vytvoril Lukas Sekerak a jemu prinalezia vsetke prava.
	Je zakazane kopirovat tento program bez suhlasu autora.
	Je zakazane kopirovat sucasti programu a podprogramov.
	Copyright 2008-2011, Lukas Sekerak
*/

	/*~~~~~~~~~~~~  
	   - End system -  
	~~~~~~~~~~~~~*/
	
stock end_obtiaznost(const id) // id clanu
{
	/*	Obtiaznost		NATIVE
		
		Fukncia vypocitava obtiaznost zapasu pre dany clan.
		ID je id clanu.	
	*/
	new obtiaznost = 1, rank, pocet
	rank  = end_rank_clanu( Oppositeclan(id) )
	pocet = end_pocet_clanov()
					
	if(rank > 0 && pocet > 0)  
	{		
		// Moj novy vozrec
		obtiaznost = floatround( float( rank ) * 100.0 / float(pocet) )
		obtiaznost = 100 - obtiaznost
		
		// Zabezspecime
		if(obtiaznost >= 99) obtiaznost = obtiaznost + 1;
		if(obtiaznost > 100) obtiaznost = 100;
		if(obtiaznost <= 0) obtiaznost = 1;
	}	
	return obtiaznost;
}		
stock end_pocet_clanov()
{
	/* 	Celkovy pocet clanov		NATIVE
		
		Fukncia vrati pocet clanov zaregistrovanych v lige.
		Tato hodnota je potrebna pre priamu umeru.	
	*/
	if (databaza == Empty_Handle) { 
		log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "ERROR_POCET")
		return 0;
	}
	new s_sql_clan[64]
	get_pcvar_string(SQL_CLAN, s_sql_clan, 63) 
	
	new Handle:result = SQL_PrepareQuery(databaza, "SELECT count(id) as pocet FROM %s ", s_sql_clan) 
	if (!SQL_Execute(result)) {	
		log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "ERROR_POCET2")
		mysql_error(result, "end_pocet_clanov");
	} else {	
		new temp = SQL_ReadResult(result,0)
		SQL_FreeHandle(result)
		return temp;
	}
	return 0;
}
stock end_rank_clanu(const id) // ID je clan_id[CLAN_A]
{
	/*	Rank clanu		NATIVE
	
		Fukncia vrati poziciu clanu v sql tabulke,tedy 
		vrati rank clanu,
		- ID je clan id
		- Potrebny upgrade pri vacsom pocte clanov
	*/
	
	if (databaza == Empty_Handle) { 
		log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "ERROR_RANK")
		return 0;
	}	   
	new s_sql_clan[64], Handle:result
	get_pcvar_string(SQL_CLAN, s_sql_clan, 63) 
				
	result = SQL_PrepareQuery(databaza, "SELECT id FROM %s ORDER BY bodov desc", s_sql_clan) 
	if (!SQL_Execute(result)) {	
		log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "ERROR_RANK2")
		mysql_error(result, "end_rank_clanu id=%i", id);
		return 0;
	} else {					
		new rank = 1;	
		//SQL_NextRow(result) // prvykrat ....
		// Pocitame	
		while(SQL_MoreResults(result))
		{
			rank++
			if ( SQL_ReadResult(result, 0) == clan_id[id]) {
				SQL_FreeHandle(result)
				log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "ZAPAS_RANK", clan_id[id], rank)
				return rank;
			}
			SQL_NextRow(result);
		}
		SQL_FreeHandle(result);
		log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "ZAPAS_RANK", clan_id[id], 0);
		return 0;
	}
	log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "ZAPAS_RANK", clan_id[id], -1);
	return 0;
}
public end_kick_a_vypnut()
{
	/* 	Kick hracov && Vypnut server	FORWARD
		
		Fukncia pokickuje hracov na konci CW.
		Pripadne vypne aj server podla cvar.
	*/
	DEBUG2( log_to_file(LOG_SUBOR,"end_kick_a_vypnut()"); )

	// Kick
	for(new i = 1; i <= max_hracov; i++) {
		if (!is_user_connected(i)) continue;		
		kick_player(i, "%L", LANG_SERVER, "DISCONNECT")
	}	
	// Off server
	if( get_pcvar_num(CONFIG_OFF) == 1) server_cmd("quit");	
}
stock end_delete_vyzva(const id)
{
	/*	 Delete vyzva	NATIVE
		
		Funkcia len vymazuje vyzvu z databazy.
		ID je sql id vyzvy.	
	*/
	new s_sql_vyzva[64], Handle:result
	get_pcvar_string(SQL_VYZVA, s_sql_vyzva, 63) 
	
	result = SQL_PrepareQuery(databaza, "DELETE FROM %s WHERE `id` = %d ", s_sql_vyzva, id) 	   
	if (!SQL_Execute(result)) mysql_error(result, "end_delete_vyzva id=%i", id);		
}	
stock end_system(	const bodov[2], const skore[2], 
					const bonus[2], const naroc[2], 
					const typ, const clan, const temp[]
				)
{
	end_zapis_bodov(CLAN_A, bodov[CLAN_A] );
	end_zapis_bodov(CLAN_B, bodov[CLAN_B] );
	log_to_file(LOG_SUBOR, temp);	
	
	// Log
	if(DEBUGon()) {
		log_ciara();
		log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "ZAPAS_TABULKA");
		log_to_file(LOG_SUBOR, "  %d	        %d	      %d	  %d	  %d", clan_id[CLAN_A], naroc[CLAN_A], bonus[CLAN_A], skore[CLAN_A], bodov[CLAN_A]);
		log_to_file(LOG_SUBOR, "  %d	        %d	      %d	  %d	  %d", clan_id[CLAN_B], naroc[CLAN_B], bonus[CLAN_B], skore[CLAN_B], bodov[CLAN_B]);
		log_ciara();
	}
	
	// Dalej
	end_vyzva_do_zapas( naroc, bonus, bodov, skore, typ, clan, temp);		
	return PLUGIN_CONTINUE
}
stock end_vyzva_do_zapas(	const narocnost[2], const bonus[2], const bodov[2], const skore[2],
							const typ, const clan, const dovod[]
						)
{
	/*	Zapisuje vysledok zapasu		NATIVE	
		
		Zapise vsetke ostatne udaje do datavazy.
		
		- Vstupne udaje:
			Info:
				CLAN_A
					- Narocnost
					- Herny Bonus
					- Bodov
					- vyhrate kola	
				CLAN_B
					- Narocnost
					- Herny Bonus
					- Bodov
					- vyhrate kola	
			Fail
	*/
	if (databaza == Empty_Handle)  { 
		log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "ERROR_VYZVA")
		return PLUGIN_HANDLED
	}	
	// Najprv delete vyzva
	end_delete_vyzva(sql_id);
		
	// Hraci a mena
	#define TEAM_BUFFER 		SLOTOV*28			// bytov - definuj buffer pre ukoncenie vyzvy...
	new team, pos, pos_1, pos_2, meno[32], temp[64]
	new ct_team[TEAM_BUFFER], t_team[TEAM_BUFFER], spe_team[TEAM_BUFFER]
		
	// Uzivatelsky system
	new kill, death, clanid, hrac		
	for(hrac = 1; hrac <= max_hracov; hrac++) {					
		if (!sls_user_valid(hrac)) continue;			
		team 	= fm_cs_get_user_team(hrac);
		clanid 	= user_clan[hrac];			
		kill 	= get_user_frags(hrac);
		death 	= get_user_deaths(hrac);
		
		// Mena oddelujeme medzeramy a potom pouzijeme TRIM	
		if(	 clanid == CLAN_A && team != CS_TEAM_SPECTATOR) {
			pos_1 += formatex( ct_team[pos_1], TEAM_BUFFER-1-pos_1,  " %d %s%i%s%i%s%s", user_webid[hrac], STR_PARSER_UDAJ, kill, STR_PARSER_UDAJ, death, STR_PARSER_UDAJ,  STR_PARSER_HRAC)
		} else if( clanid == CLAN_B && team != CS_TEAM_SPECTATOR) {
			pos_2 += formatex( t_team[pos_2], TEAM_BUFFER-1-pos_2,  " %d %s%i%s%i%s%s", user_webid[hrac], STR_PARSER_UDAJ,  kill, STR_PARSER_UDAJ, death, STR_PARSER_UDAJ,  STR_PARSER_HRAC)						
		} else {
			if(user_webid[hrac]) {
				pos += formatex( spe_team[pos], TEAM_BUFFER-1-pos," %d %s", user_webid[hrac], STR_PARSER_HRAC)	
			} else {
				get_user_name(hrac, meno, 31);
				SQL_QuoteString(databaza, temp, sizeof temp - 1, meno)	
				pos += formatex( spe_team[pos], TEAM_BUFFER-1-pos," %s %s", meno, STR_PARSER_HRAC)	
			}
		}		
		usergame_setinfo(hrac, kill, death)	
	}
	
	// Mapa
	new aktualna_mapa[33], s_sql_zapas[64]
	get_mapname(aktualna_mapa, 32);
	get_pcvar_string(SQL_ZAPAS, s_sql_zapas, 63) 
		
	new Handle:result = SQL_PrepareQuery(databaza,
			"INSERT INTO %s (`id` \
			,`ziada` ,`ziada_skore` ,`ziada_bodov`, `ziada_narocnost`, `ziada_bonus` \
			,`prijal` ,`prijal_skore` ,`prijal_bodov`, `prijal_narocnost`, `prijal_bonus` \
			, `datum` , `mapa`, \
			`ct_team`,`t_team`,`spe_team`, \
			`status`, `server`, `fail`, `clan`) VALUES ('%d' ,\
			'%d', '%d', '%d', '%d', '%d', \
			'%d', '%d', '%d', '%d', '%d', \
			'%d', '%s', \
			'%s', '%s', '%s', \
			'%s', '%d', '%d', '%d')",
			
			s_sql_zapas, sql_id,
			clan_id[CLAN_A], skore[CLAN_A], bodov[CLAN_A], narocnost[CLAN_A], bonus[CLAN_A],
			clan_id[CLAN_A], skore[CLAN_B], bodov[CLAN_B], narocnost[CLAN_B], bonus[CLAN_B],
			cas_zapasu, aktualna_mapa,
			ct_team, t_team, spe_team,
			dovod, gcached_CONFIG_ID, typ, clan
		);	    		
	if (!SQL_Execute(result)) {
		new big_buffer[TEAM_BUFFER*4]
		SQL_QueryError(result, big_buffer, TEAM_BUFFER*4 -1)
		log_to_file(LOG_SUBOR, "[Mysql ERROR] %s" ,big_buffer)
		SQL_GetQueryString (result, big_buffer, TEAM_BUFFER*4 -1) 
		log_to_file(LOG_SUBOR, "[Mysql QUERY] %s", big_buffer)
	}
	
	return PLUGIN_CONTINUE
}
stock end_zapis_bodov(const id, const bodov)
{
	/* 	Zapis bodov		NATIVE
		
		Fukncia len zapisuje body pre clan.
		- ID je clan id.
		- Body ak su -1 tak nastavuje ako nula.	
	*/
	// LOg
	log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "ZAPAS_BODY", clan_id[id], bodov)	
	if(bodov == 0) return PLUGIN_CONTINUE
	//Odosleme udaje ...
	new s_sql_clan[64], Handle:result
	get_pcvar_string(SQL_CLAN, s_sql_clan, 63) 
	result = SQL_PrepareQuery(databaza, 
				"UPDATE %s SET `bodov` = bodov+(%d) WHERE id = '%d' ",
				s_sql_clan, bodov, clan_id[id]
			);
	
	if (!SQL_Execute(result)) {	
		log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "ERROR_BODY")
		mysql_error(result, "end_zapis_bodov(id=%i, bodov=%i)", id, bodov);
	}
	return PLUGIN_CONTINUE
}
stock end_bonus(const id)	
{	
	/*	Vypocet bonusov		NATIVE
		
		Fukncia vypocita bonus pre dany clan podla clan bonusu
		ale aj hracovych bonusoch.	
		ID je id clanu.
	*/
	// Bonusy 
	new bonus = clan_bonus[id];	
	for(new hrac = 1; hrac <= max_hracov; hrac++) {
		if (!sls_user_valid(hrac)) continue;		
		if( zisti_clan(hrac) == id) bonus += user_bonus[hrac];
	}
	return bonus;
}		