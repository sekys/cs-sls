/*
	Tento plugin vytvoril Lukas Sekerak a jemu prinalezia vsetke prava.
	Je zakazane kopirovat tento program bez suhlasu autora.
	Je zakazane kopirovat sucasti programu a podprogramov.
	Copyright 2008-2011, Lukas Sekerak
*/

	/*~~~~~~~~~~~~  
	   - Menu system -  
	~~~~~~~~~~~~~*/

public menu_system(id)
{
	/* 	Menu system	FORWARD
	
		Hlavna fukncia ,ktora sa kona pri stisknuti menu tlacidla.
		Riadi ostatne pod menu fukncie.
	*/	
	// Zapnute ?
	new temp[BUFFER]
	get_pcvar_string(MENU_TLACIDLO, temp, BUFFER - 1)
	if(equal(temp, "")) {
		send_sprava(id, "%s %L", DEFINE_SAY, LANG_SERVER, "MENU_OFF")
		return PLUGIN_HANDLED;
	}	
	
	// Je zapas ?
	if(game < cvicne_kolo){
		send_sprava(id, "%s %L", DEFINE_SAY, LANG_SERVER, "MENU_ZAPAS");
		return PLUGIN_CONTINUE;
	}	
	// Rozlisujeme a kontrolujeme komu zapneme menu
	if(!menu_CheckAccess(id)) {
		send_sprava(id, "%s %L", DEFINE_SAY, LANG_SERVER, "MENU_ACCESS")
		return PLUGIN_CONTINUE;
	}
	
	menu_leader(id);
	return PLUGIN_CONTINUE;
}
stock menu_CheckAccess(const id) {
	if(user_clan[id] == CLAN_C) return false;
	if(user_hodnost[id] == 1 ) return true;
	
	// Ak je zastupca
	if(user_hodnost[id] == 2) {
		// Hladame clan leadera z toho isteho clanu
		new id = PlayerWithHodnost(user_clan[id], 1);
		return (id == 0);
	}
	return false;
}
stock menu_leader(const id)
{
	/* 	Leader menu		NATIVE
	
		Hlavne leader menu.
		- Vizualna cast
	*/
	new menu_id, temp[32]	
	formatex(temp, 31, "\r%L", LANG_SERVER, "MENU")	
	menu_id = menu_create(temp, "menu_cmd")
	formatex(temp, 31, "\w%L", LANG_SERVER, "MENU_KICK")
	menu_additem(menu_id, temp,				"1", 0)
	formatex(temp, 31, "\w%s", "Spravit screenshot hraca")
	menu_additem(menu_id, temp,				"2", 0)	
	formatex(temp, 31, "\w%s", "Pauznut hru")
	menu_additem(menu_id, temp,				"3", 0)
	//formatex(temp, 31, "\w%L", LANG_SERVER, "MENU_PRESUN")
	//menu_additem(menu_id, temp,				"4", 0)	
	formatex(temp, 31, "\w%L", LANG_SERVER, "MENU_VZDAT_SA");
	menu_additem(menu_id, temp,				"5", 0);
	menu_addblank(menu_id, 0)
	formatex(temp, 31, "\yPowered by %s", VERZIA);
	menu_additem(menu_id, temp,				"6", 0);    
	
	menu_setprop(menu_id, MPROP_EXIT, MEXIT_ALL);
	menu_display (id, menu_id, 0);
	client_cmd(id,"spk buttons/button9");
}
public menu_cmd(id, menu, item)
{
	/* 	Leader menu		NATIVE
	
		Hlavne leader menu.
		- Procesy
		- Vypni menu tak ci onak
	*/
	new key;
	key = menu_start(id, item, menu); 
	if(key == -1) return PLUGIN_HANDLED;
	
	switch(key) {
		case 1: menu_kick(id);
		case 2: menu_screen(id);
		case 3: menu_pause(id);
		//case 4: menu_presun(id); break;
		case 5: menu_question(id, "MENU_VZDAT", "menu_vzdat_cmd");	
	
		case 6: { 
			new iName[64]
			formatex(iName, sizeof iName - 1, "%L", LANG_SERVER, "URL_INFO");
			show_motd(id, iName, VERZIA);
		}
	}
	return PLUGIN_HANDLED;
}
stock menu_kick(const id) {
	menu_ClanPlayers(id, "MENU_KICK", "menu_kick_cmd");
}
stock menu_ClanPlayers(const id, const lang[], const call[])
{
	new meno[32], temp[10], menu, hrac;
	formatex(meno, sizeof meno - 1, "\r%L", LANG_SERVER, lang)
	menu = menu_create(meno, call);
	// Hladaj hracov
	for(hrac=1; hrac <= max_hracov; hrac++)
	{						
		if(!sls_user_valid(hrac)) continue;
		get_user_name(hrac, meno, 31);				
		if(user_clan[id] == user_clan[hrac]) {
			// Zapisuj
			num_to_str(hrac, temp, 9);
			menu_additem(menu, meno, temp, 0);
		}
	}
	menu_display(id, menu, 0);
}
stock menu_AllPlayers(const id, const lang[], const call[])
{
	new meno[32], temp[10], menu, hrac;
	formatex(meno, sizeof meno - 1, "\r%L", LANG_SERVER, lang)
	menu = menu_create(meno, call);
	// Hladaj hracov
	for(hrac=1; hrac <= max_hracov; hrac++)
	{						
		if(!sls_user_valid(hrac)) continue;
		get_user_name(hrac, meno, 31);				
		// Zapisuj
		num_to_str(hrac, temp, 9);
		menu_additem(menu, meno, temp, 0);
	}
	menu_display(id, menu, 0);
}
public menu_kick_cmd(id, menu, item)
{
	/* 	Leader kick menu		NATIVE
	
		Kickuje hracov z rovnakeho clanu alebo pozorvatelov.
		- Procesy
	*/
	new user2[BUFFER]
	new hrac = menu_start(id, item, menu);
	if(hrac == -1) return PLUGIN_HANDLED;
	
	// Spracuje udaje a kickne hraca......
	if(sls_user_valid(hrac)) {
		// Pridat log
		new temp[BUFFER]
		info_user(id, temp, BUFFER-1);
		info_user(hrac, user2, BUFFER-1);
		log_to_file(LOG_SUBOR, "Hrac %s kickol %s", temp, user2);
		
		get_user_name(hrac, user2, 31);
		kick_player(hrac, "%L", LANG_SERVER, "MENU_KICK_HRAC")
		send_sprava(hrac, "%s^x03%s ^x01%L", DEFINE_SAY, user2, LANG_SERVER, "MENU_KICK_DONE")
	} else {
		get_user_name(hrac, user2, 31);
		send_sprava(hrac, "%s^x03%s ^x01%L", DEFINE_SAY, user2, LANG_SERVER, "MENU_KICK_NO")
	}
	return PLUGIN_HANDLED;
}
stock menu_presun(const id)
{
	/* 	Leader presun menu		NATIVE
	
		Toto menu najde nahradu za hraca v zapase a
		vymeni ho za hraca v SPE
		- Vizualna cast
	*/
	new menu, temp[10], stary_hrac, meno[32];
	formatex(meno, sizeof meno - 1, "\r%L", LANG_SERVER, "MENU_PRESUN")
	stary_hrac = user_presun[id];
	
	// Menu mozme pouzit 2x
	if(!stary_hrac)
	{
		menu = menu_create(meno, "menu_presun_cmd");
		// Hladame nahradu najprv
		for(new hrac = 1; hrac <= max_hracov; hrac++) {					
			if (!sls_user_valid(hrac)) continue;		
			if(user_clan[id] != user_clan[hrac]) continue;
			if(fm_cs_get_user_team(hrac) == CS_TEAM_SPECTATOR) {
				get_user_name(hrac, meno, 31);
				num_to_str(hrac, temp, 9);
				menu_additem(menu, meno, temp, 0);
			}
		}	
	} else	{
	// Ak sme uz raz pouzili menu takze uz mame nahradu...
	// Vyberame noveho hraca....
		formatex(meno, sizeof meno - 1, "\r%L", LANG_SERVER, "MENU_PRESUN_ZA")
		menu = menu_create(meno, "menu_presun_cmd");	
		for(new hrac = 1; hrac <= max_hracov; hrac++)
		{					
			if(!sls_user_valid(hrac)) continue;				
			if(stary_hrac == hrac) continue;		
			if(user_clan[id] != user_clan[hrac]) continue;	
			if(fm_cs_get_user_team(hrac) == clan_team[user_clan[id]]) {
				get_user_name(hrac, meno, 31);				
				num_to_str(hrac, temp, 9);
				menu_additem(menu, meno, temp, 0);
			}						
		}
	}
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0);
}
public menu_presun_cmd(id, menu, item)
{
	/* 	Leader presun menu		NATIVE
	
		Toto menu najde nahradu za hraca v zapase a
		vymeni ho za hraca v SPE
		- Procesy
	*/
	new hrac, user2[BUFFER]
	hrac = menu_start(id, item, menu); 
	if(hrac == -1) return PLUGIN_HANDLED;

	new stary_hrac = user_presun[id];
	if( stary_hrac == 0) {
		stary_hrac = hrac
		menu_presun(id)
		get_user_name(hrac, user2, 32);
		format(user2, BUFFER - 1, "^x03%s ^x01", user2)
		send_sprava(hrac, "%s %L.", DEFINE_SAY, LANG_SERVER, "MENU_PRESUVAM", user2)
	} else {
		get_user_name(id, user2, 32);
		if(sls_user_valid(hrac) && sls_user_valid(stary_hrac)) {
			// Pridat log
			new temp[BUFFER], user3[BUFFER]
			info_user(id, temp, BUFFER-1);
			info_user(stary_hrac, user2, BUFFER-1);
			info_user(hrac, user3, BUFFER-1);
			log_to_file(LOG_SUBOR, "Hrac %s vymenil %s za %s", temp, user2, user3);
		
			// Stary hrac
			get_user_name(stary_hrac, user3, 31)
			fm_cs_set_user_team(stary_hrac, CS_TEAM_SPECTATOR)
			get_user_name(hrac, user2, 32);
				
			// Novy hrac
			if(fm_cs_get_user_team(hrac) == CS_TEAM_SPECTATOR) {
				SpeToGame(hrac, clan_team[user_clan[id]]);
			} else {
				fm_cs_set_user_team(hrac, clan_team[user_clan[id]]);
				respawn(hrac);
				DefaultMoney(hrac);
			}
			
			// ok 
			send_sprava(id, "%s ^x03%s ^x01%L ^x03%s", DEFINE_SAY, user3, LANG_SERVER, "MENU_PRESUN_DONE", user2)
		} else {
			send_sprava(id, "%s %L", DEFINE_SAY, LANG_SERVER, "MENU_PRESUN_NO")
		}
		user_presun[id] = 0;
	}	
	return PLUGIN_CONTINUE;
}
stock menu_question(const id, const question[], const callback[])
{	
	new menu_id, temp[32];	
	formatex(temp, 31, "\r%L", LANG_SERVER, question);
	menu_id = menu_create(temp, callback);
	formatex(temp, 31, "\w%L", LANG_SERVER, "MENU_ANO");
	menu_additem(menu_id, temp, "2", 0);
	formatex(temp, 31, "\w%L", LANG_SERVER, "MENU_NIE");
	menu_additem(menu_id, temp, "1", 0); 
	menu_setprop(menu_id, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu_id, 0);
}
public menu_vzdat_cmd(id, menu, item)
{
	/* 	Leader vzdat menu		NATIVE
	
		Menu ponukne CL moznost vzdat sa.
		- procesy
		- Vypni menu tak ci onak
	*/	
	new key;
	key = menu_start(id, item, menu);
	if(key == 2) {
		// Pridat log
		new temp[BUFFER]; 
		info_user(id, temp, BUFFER-1);
		log_to_file(LOG_SUBOR, "Hrac %s za %s clan sa vzdal.", temp, clan_meno[user_clan[id]]);	
		sls_cw_end(5, user_clan[id]);	
	}
	return PLUGIN_HANDLED;
}
stock menu_start(const id, item, menu) 
{ 	
	client_cmd(id, "spk buttons/button3"); 
	if( item == MENU_EXIT ) { 
        menu_destroy(menu); 
        return -1; 
    } 
	new data[6], iName[64], callback, key; 
	menu_item_getinfo(menu, item, key, data,5, iName, 63, callback); 
	menu_destroy(menu); 
	key = str_to_num(data); 
	return key; 
}