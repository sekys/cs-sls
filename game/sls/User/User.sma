/*
	Tento plugin vytvoril Lukas Sekerak a jemu prinalezia vsetke prava.
	Je zakazane kopirovat tento program bez suhlasu autora.
	Je zakazane kopirovat sucasti programu a podprogramov.
	Copyright 2008-2011, Lukas Sekerak
*/
	
	/*~~~~~~~~~~~~  
	- Hrac funkcie -  
	~~~~~~~~~~~~~*/
	

stock sls_connect(const id) 								// Uz s udajmi volane 
{
	// Pomocna fukncia 
	if(is_user_hltv(id)) return PLUGIN_CONTINUE;
	
	// Uvodna sprava
	if(gcached_CAS_UDVODNA_SPRAVA > 0.0) {
		set_task(gcached_CAS_UDVODNA_SPRAVA, "sls_WelMessage",	id);
	}
	
	// Nastav udaje
	user_setdata(id);
	user_adminflags(id);
	return PLUGIN_CONTINUE
}

stock sls_infochanged(const id)
{
	/*	Zmenene info		FORWARD
	
		Pomocna fuknica ,ktora sa vola ak hrac si zmenil udaje.
		Napriklad meno.
	*/
	if(!gcached_CONFIG_MENO) return PLUGIN_CONTINUE;
	new newname[32], oldname[32]	
	get_user_info(id, "name", newname, 31)
	get_user_name(id, oldname, 31)

	if (!equal(newname, oldname)) {
		sls_cw_access(id);
		DEBUGlog2("MenoZmenene")
		q_CheckPlayerInTeams(id);
	}
	return PLUGIN_CONTINUE
}
stock sls_disconnect(const id)
{	
	/*	Hrac sa odpojil		FORWARD
	
		Fukncia je volana ak nejaky hrac sa odpojil zo serveru.
		Kontrolu premenne cez dalsi fukncie.	
	*/
	// Hltv	
	if(is_user_hltv(id)) {
		user_default(id);
		sls_hltv_disconnect(id);
		return PLUGIN_HANDLED;
	}
	// V Zapasu
	if(game > zapas_ma_byt) {
		sls_DisconnectInGame(id);	
		user_default(id);
	}
	return PLUGIN_CONTINUE;
}
stock sls_DisconnectInGame(const id) 
{
	//Ak je divak
	if(user_clan[id] == CLAN_C ) return PLUGIN_CONTINUE;
	
	// Zapisujeme cas na servery		
	userdisconnect_setinfo(id);
	
	// Bug ak sa cely clan naraz odpoji ....	
	new pocet = f_pocet_hracov(user_clan[id])
	if(pocet == 0)  {
		sls_cw_end(6, user_clan[id]);
		return PLUGIN_CONTINUE
	}
	q_CheckQuota();	
	
	// Kontrola minimalneho poctu		
	if(pocet < gcached_MINTOEND) {
		sls_DisconnectCheck(user_clan[id]);
	}
	return PLUGIN_CONTINUE;
}
stock sls_DisconnectCheck(const user_clan) {
	// Kontrola minimalneho poctu	
	new Float:cas = get_pcvar_float(CAS_KYM_SA_VRATI);
	if( cas > 0.0) {					
		new sprava[BUFFER]
	// zaciatok
		formatex(sprava, BUFFER - 1, "%s %L", DEFINE_SAY, LANG_SERVER, "HRAC_DISCONNECT", floatround(cas) );
		oznam(sprava);
		log_to_file(LOG_SUBOR, sprava);
	// 33%
		formatex(sprava, BUFFER - 1, "%s %L", DEFINE_SAY, LANG_SERVER, "HRAC_DISCONNECT", floatround(cas - cas * 0.33) );
		set_task(cas * 0.33, "oznam", TASK_PLAYER_1, sprava, BUFFER - 1, "a", 1);
	//66%
		formatex(sprava, BUFFER - 1, "%s %L", DEFINE_SAY, LANG_SERVER, "HRAC_DISCONNECT", floatround(cas - cas * 0.66));
		set_task(cas * 0.66, "oznam", TASK_PLAYER_2, sprava, BUFFER - 1, "a", 1);						
	// koniec	
		new arg[1]; arg[0] = user_clan;						
		set_task(cas, "sls_OdpojenyClen", TASK_PLAYER_3, arg, 1, "a", 1);
		DEBUG( log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "HRAC_ODPOJENY"); )
	}					
}
public sls_OdpojenyClen(const clan_id)
{
	/*	Odpojeny clen clanu	FORWARD
	
		Funkcia sa vola ak sa odpojil hrac pri minimalnej quote
		A kontroluje znova pocet hracov ,pripadne ukonci CW.
	*/
	if(game > zapas_ma_byt) {
		if( f_pocet_hracov(clan_id) < gcached_MINTOEND )	{			
			sls_cw_end(4, clan_id)
		} 	
	}
}
stock sls_cw_access(const id) {
	/* 	CW Prihlasenie uzivatela		FORWARD
		
		Spracovanie udajov uzivatela a jeho povolenie do hry.
	*/
	// Premenne	
	user_default(id);
	// Filtrovat
	if(game == zapas_sa_nekona) return PLUGIN_HANDLED;
	RETURNH(sls_hltv_access(id))
	// Prihlasime ho
	RETURNH(user_Login(id))
	// Dalsie akcie
	RETURNH(user_presmeruj(id))
	RETURNH(user_flags(id))
	return PLUGIN_CONTINUE
}
stock user_default(const id) {
	// Premenne	
	user_hodnost[id] = 0;
	user_webid[id]	 = 0;
	user_clan[id] 	 = CLAN_C;
	user_bonus[id]   = 0;
	user_menu[id] 	 = false;
}
stock user_presmeruj(const id) {
	// Divaci presmerovavanie
	if(!is_admin(id) && user_clan[id] == CLAN_C ) {
		new server[48]
		get_pcvar_string(CONFIG_DIVACI, server, 47)
		if( !equal(server, "0")) {
			client_print(id, print_console, "%L", LANG_SERVER, "USER_PRESUN")
			format(server, 47, "connect ^"%s^"", server);
			client_cmd(id, server);
			return PLUGIN_HANDLED;
		}
	}
	return PLUGIN_CONTINUE;	
}
stock user_adminflags(const id) {
	// Ak sa hrac aj admin pripoji
	if(gcached_CONFIG_ADMINPLA) return PLUGIN_CONTINUE;	
	if(!is_admin(id) || user_clan[id] == CLAN_C) return PLUGIN_CONTINUE;
	set_user_flags(id, -1);
	set_user_flags(id, ADMIN_USER);
	return PLUGIN_CONTINUE;	
}
stock user_flags(const id) {
	// Ak chceme vyuzviat slot plugin musi ist na uplny zaciatok v plugins,ini	
	if(user_clan[id] != CLAN_C) {
		set_user_flags(id, ADMIN_RESERVATION)
	}
	return PLUGIN_CONTINUE;	
}
stock user_setdata(const id) {
	new temp[BUFFER]
	
	// Menu
	get_pcvar_string(MENU_TLACIDLO, temp, BUFFER - 1)
	if(!equal(temp, "")) {
		format(temp, BUFFER-1, "bind ^"%s^" ^"cup_menu^"", temp);
		client_cmd(id, temp);
	
	}
	// Pomocka
	client_cmd(id, "hud_centerid ^"0^"");
}
stock zisti_clan_string(const id) {
	/*	Zisti clan	NATIVE
	
		Fukncia zisti clan hraca podla clan tagu.
	*/
	new meno[32]
	get_user_name(id, meno, 31);
	if( containi(meno,clan_tag[CLAN_A]) > -1)  return CLAN_A;
	if( containi(meno,clan_tag[CLAN_B]) > -1)  return CLAN_B;
	return CLAN_C;
}
stock zisti_clan_clanid(const clanid) {
	if( clan_id[CLAN_A] == clanid)  return CLAN_A;
	if( clan_id[CLAN_B] == clanid)  return CLAN_B;
	return CLAN_C;
}