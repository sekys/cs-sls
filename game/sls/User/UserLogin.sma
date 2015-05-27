/*
	Tento plugin vytvoril Lukas Sekerak a jemu prinalezia vsetke prava.
	Je zakazane kopirovat tento program bez suhlasu autora.
	Je zakazane kopirovat sucasti programu a podprogramov.
	Copyright 2008-2011, Lukas Sekerak
*/

stock user_Login(const id) {
	// Mix metoda
	if( gcached_CONFIG_STEAM && gcached_CONFIG_MENO) {
		DEBUGlog2("user_Login MIX")
		if(is_steam(id)) return user_SteamLogin(id);
		else return user_MenoLogin(id);
	}	
	if(gcached_CONFIG_STEAM) return user_SteamLogin(id);
	if(gcached_CONFIG_MENO) return user_MenoLogin(id);
	return PLUGIN_CONTINUE;
}
stock user_SteamLogin(const id)
{
	if(!is_steam(id)) {
		kick_player(id, "Nemas steam alebo patch v42 !^n www.cs.gecom.sk/patch");
		return PLUGIN_HANDLED;	
	}
	new data[5], clan;
	data = user_search_SteamMethod(id);
	if(data[0] == -1) {
		kick_player(id, "%L", LANG_SERVER, "USER_ERROR")
		return PLUGIN_HANDLED;
	} else if(data[0] == 0)	{
		kick_player(id, "%L", LANG_SERVER, "USER_NOSTEAM")
		return PLUGIN_HANDLED;
	} else	{
		DEBUGlog2("user_SteamLogin(%d)", data[0])
		clan = zisti_clan_clanid(data[1]);
		user_webid[id] = data[0];
		if( clan != CLAN_C ) {
			user_hodnost[id] = data[2];
			user_clan[id] 	 = clan;
			user_bonus[id]	 = data[3];	
		}		
	}
	return PLUGIN_CONTINUE;
}
stock user_MenoLogin(const id)
{
	// Meno a heslo			
	new pw_option[32], pw_string[32], pw_num, clan				
	get_pcvar_string(CONFIG_HESLO, pw_option, 31)
	get_user_info(id, pw_option, pw_string, 31)
	pw_num = str_to_num(pw_string)
	clan = zisti_clan_string(id);
	
	// Nezadal
	if(clan != CLAN_C) {
		if(!pw_num) {
			kick_player(id, "%L", LANG_SERVER, "USER_PASS_NO", pw_option)
			return PLUGIN_HANDLED
		}
	}
	
	// Hladaj
	new webid = user_search(id, clan)
	if(webid == -1) {
		kick_player(id, "%L", LANG_SERVER, "USER_ERROR")
		return PLUGIN_HANDLED;
	} else if(webid == 0)	{
		kick_player(id, "%L", LANG_SERVER, "USER_NO")
		return PLUGIN_HANDLED;
	} else	{
		// Aspon Naslo	
		if( clan == CLAN_C ) {
			user_webid[id] 	 = webid;
		} else {
			new vysledok[3] 
			vysledok = user_get(webid)
			if( vysledok[0] == pw_num)
			{
				user_hodnost[id] = vysledok[1];
				user_webid[id] 	 = webid;
				user_clan[id] 	 = clan;
				user_bonus[id]	 = vysledok[2];					
			} else {
				kick_player(id, "%L", LANG_SERVER, "USER_PASS", pw_option)
				return PLUGIN_HANDLED
			}
		}
	}
	return PLUGIN_CONTINUE;
}