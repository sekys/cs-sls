/*
	Tento plugin vytvoril Lukas Sekerak a jemu prinalezia vsetke prava.
	Je zakazane kopirovat tento program bez suhlasu autora.
	Je zakazane kopirovat sucasti programu a podprogramov.
	Copyright 2008-2011, Lukas Sekerak
*/
	
	/*~~~~~~~~~~~~  
	 - uzivatelia -  
	~~~~~~~~~~~~~*/

stock user_search_SteamMethod(const id)
{
	new data[5];
	if (databaza == Empty_Handle) {
		DEBUG( log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "ERROR_SEARCH"); )
		data[0] = -1;
		return data;
	}
	new steam[36], Handle:result;	
	get_steam(id, steam)
	result = SQL_PrepareQuery(	databaza, "SELECT user_id, clan_id, clan_hodnost, cs_bonus FROM %s WHERE `cs_steam` LIKE '%s'", 
								gcached_SQL_USERS, steam ); 								
	if (!SQL_Execute(result)) {	
		mysql_error(result, "user_search ID - %i", id);	
		data[0] = -1;
		return data;		
	}
	if (SQL_NumResults(result) == 0) { 				
		data[0] = 0;		
	} else {	
		data[0] = SQL_ReadResult(result, 0);
		data[1] = SQL_ReadResult(result, 1);
		data[2] = SQL_ReadResult(result, 2);
		data[3] = SQL_ReadResult(result, 3);	
	}
	SQL_FreeHandle(result);
	return data;
}
stock user_search(const id, const clan)
{
	/*	Najdi web uzvatela		NATIVE
	
		Fukncia nam z GAME id zisti WEB id podla
		herneho mena.
		- Vracia:
			-1  	SQL error
			0	Nenaslo	
			>	Naslo
	*/
	if (databaza == Empty_Handle) {
		DEBUG( log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "ERROR_SEARCH"); )
		return -1;
	}
	new meno[32], sprava[BUFFER], prikaz[64], webid, Handle:result
	get_user_name(id, meno, 31);
	// Len spectatator													- // Pomocka
	if(clan == CLAN_C) formatex(prikaz, sizeof prikaz - 1, "");
	else formatex(prikaz, sizeof prikaz - 1, "clan_id = '%d' AND", clan_id[clan]);
	
	// Presne tak.....
	SQL_QuoteString(databaza, sprava, BUFFER - 1, meno) 
	result = SQL_PrepareQuery(databaza,	"SELECT user_id FROM %s WHERE %s `cs_meno` LIKE '%s' ", 
								gcached_SQL_USERS, prikaz, sprava ); 	   
								
	if (!SQL_Execute(result)) {	
		mysql_error(result, "user_search ID - %i CLAN - %i", id, clan);	
		return -1 		
	}
	if (SQL_NumResults(result) == 0) { 
		/*
		// Nenaslo ,........ pokus 2 ...... podobne.....
		result = SQL_PrepareQuery(databaza,"SELECT user_id FROM %s WHERE %s `cs_meno` LIKE '%%s%' ", s_sql_users, prikaz, meno ) 	   
		if (!SQL_Execute(result)) {	
			new error[512]
			SQL_QueryError(result,error,511)
			log_to_file(LOG_SUBOR, "[Mysql ERROR] %s",error)		
			SQL_GetQueryString (result, error, 511) 
			log_to_file(LOG_SUBOR, "[Mysql QUERY] %s", error)
			SQL_FreeHandle(result)
			return -1 		
		}  else if (SQL_NumResults(result) == 0) { 	*/					
			SQL_FreeHandle(result)
			return 0
		//}
		
	}											
	webid = SQL_ReadResult(result, 0);
	SQL_FreeHandle(result);
	return webid;
}
stock user_get(const webid)
{
	/*	Zisti udaje		NATIVE
	
		Fukncia zisti udaje z databazy.
		- Potrebuje WEBID
		- Vracia:
			HESLO
			HODNOST
			BONUS
	*/
	new vysledok[3], Handle:result;
	vysledok[0] =  vysledok[1] =  vysledok[2] = 0;
	result = SQL_PrepareQuery(	databaza, 
								"SELECT cs_heslo, clan_hodnost, cs_bonus FROM %s WHERE user_id = '%d'", 
								gcached_SQL_USERS, webid);
								
	if (!SQL_Execute(result)) {	
		mysql_error(result, "Nemozem dostat informacie od %i", webid);
	} else {
		vysledok[0] = SQL_ReadResult(result, 0)
		vysledok[1] = SQL_ReadResult(result, 1)
		vysledok[2] = SQL_ReadResult(result, 2)
	}	
	
	SQL_FreeHandle(result);
	return vysledok;
}
stock usergame_setinfo(const id, const kill, const death)
{
	if(!user_webid[id]) return;
	new Handle:result
	// Odosiela na konci CW
	result = SQL_PrepareQuery(
				databaza, 
				"UPDATE %s SET `cs_kill` = `cs_kill` + '%d', `cs_death` = `cs_death` + '%d' WHERE user_id = '%d' ", 
				gcached_SQL_USERS, kill, death, user_webid[id]
			);		
	if (!SQL_Execute(result)) mysql_error(result, "%L", LANG_SERVER, "ERROR_SETINFO", user_webid[id], kill, death);		
}
stock userdisconnect_setinfo(const id)
{
	if(!user_webid[id]) return;
	new Handle:result;
	//Odosiela pri odpojeni ....
	new cas = get_user_time(id, 1) / 60;
	if( cas > 0) {
		result = SQL_PrepareQuery(
					databaza, 
					"UPDATE %s SET `cs_time` = `cs_time`+('%d') WHERE user_id = '%d' ", 
					gcached_SQL_USERS, cas, user_webid[id]
				); 	    		
		if (!SQL_Execute(result)) {
			mysql_error(result, "userdisconnect_setinfo()");
		}
	}
}