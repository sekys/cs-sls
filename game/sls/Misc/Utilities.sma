/*
	Tento plugin vytvoril Lukas Sekerak a jemu prinalezia vsetke prava.
	Je zakazane kopirovat tento program bez suhlasu autora.
	Je zakazane kopirovat sucasti programu a podprogramov.
	Copyright 2008-2011, Lukas Sekerak
*/

	/*~~~~~~~~~~~~  
	 -Dalsie pomocne -  
	~~~~~~~~~~~~~*/
stock log_ciara() { log_to_file(LOG_SUBOR,"-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-"); }
stock checkandkill(const id) { if(is_user_alive(id)) user_silentkill(id); }
stock sls_user_valid(const id) { return (is_user_connected(id) && !is_user_hltv(id)); }
stock DefaultMoney(const id) { 	fm_cs_set_user_money ( id , get_cvar_num("mp_startmoney")); }
stock is_steam(const id) 
{
	new steamcislo[36];
	get_steam(id, steamcislo);
	return ( 
			!equal(steamcislo, "STEAM_ID_LAN") 
			&& 	!equal(steamcislo, "STEAM_ID_PENDING") 
			&& 	!equal(steamcislo, "VALVE_ID_LAN") 
			&& 	!equal(steamcislo, "VALVE_ID_PENDING") 
			&& 	!equal(steamcislo, "STEAM_666:88:666") 
	);
}
public oznam( const msg[] , any:...)
{
	/*	Oznam	NATIVE
		
		Farebny oznam pre vsetkych hracov.
	*/	
	if(msgid_say) {
		new temp[BUFFER*4]
		vformat(temp, sizeof temp - 1, msg, 2)
				
		// Ak chceme farbene musime dat FOR a pre kazdeho zvlast :(
		for(new hrac = 1; hrac <= max_hracov; hrac++)
		{								
			if(!is_user_connected(hrac) || is_user_hltv(hrac)) {
				client_print( hrac, print_chat, temp)
			} else {	
				message_begin(MSG_ONE_UNRELIABLE, msgid_say,_,hrac)
				write_byte(hrac)
				write_string(temp)
				message_end()	
			}	
		}
	}
	return PLUGIN_CONTINUE
}
stock respawn(const id)
{
	/*	Respawn	NATIVE
	
		Fukncia respawne hraca.
	*/
	if(!is_user_alive(id)) {
	  set_pev(id, pev_deadflag, DEAD_RESPAWNABLE);
	  dllfunc(DLLFunc_Think, id);
	} else {
	  dllfunc(DLLFunc_Spawn, id);
	}
	return PLUGIN_CONTINUE
}
stock send_sprava(const hrac, const msg[], any:...)
{
	/*
		Fukncia odosle farebnu sukromu spraavu.
	*/
	new temp[BUFFER*4]
	vformat(temp, sizeof temp - 1, msg, 3)
	
	if(!is_user_connected(hrac) || is_user_hltv(hrac)) {
		client_print(hrac, print_chat, temp)
	} else {	
		message_begin(MSG_ONE_UNRELIABLE, msgid_say, _,hrac)
		write_byte(hrac)
		write_string(temp)
		message_end()		
	}
}
stock kick_player(const id, const dovod[] , any:...) 
{
	/*
		Fukncia kickne "specialne" hraca
	*/
	new temp[BUFFER*4]
	vformat(temp, sizeof temp - 1, dovod, 3)
	
	message_begin(MSG_ONE, SVC_DISCONNECT, {0,0,0}, id)
	write_string(temp)
	message_end() 	
	return PLUGIN_CONTINUE;
}
stock mysql_error(const Handle:result, const sprava[], any:...)
{
	new error[512]
	vformat(error, sizeof error - 1, sprava, 3)
	log_to_file(LOG_SUBOR, sprava)
	SQL_QueryError(result, error, sizeof error - 1)
	log_to_file(LOG_SUBOR, "[Mysql ERROR] %s", error)
	SQL_GetQueryString(result, error, sizeof error - 1) 
	log_to_file(LOG_SUBOR, "[Mysql QUERY] %s", error)
}
stock DefaultsMoney() { 
	SetMoney( get_cvar_num("mp_startmoney") );
}
stock SetMoney(money) { 
	for(new hrac = 1; hrac <= max_hracov; hrac++) {									
		if(!sls_user_valid(hrac)) continue;	
		fm_cs_set_user_money(hrac , money); 
	}
}