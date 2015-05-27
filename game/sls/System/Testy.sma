/*
	Tento plugin vytvoril Lukas Sekerak a jemu prinalezia vsetke prava.
	Je zakazane kopirovat tento program bez suhlasu autora.
	Je zakazane kopirovat sucasti programu a podprogramov.
	Copyright 2008-2011, Lukas Sekerak
*/

stock test_init() {
	register_event("CurWeapon", "sls_weapon", "be", "1=1", "2=18")
	TAWP_TEST 	= register_cvar("cup_awptest_pocet", "3");		// max pocet testov pre hraca ?, 0 vypnute test
	TAWP_RAND 	= register_cvar("cup_awptest_nahoda", "20");	// nahoda za ako dlho spravi test ?
	BlockedWeapons = false;
}
public sls_weapon(id) {	
	// Filtruj
	if(game == zapas_sa_nekona) return; 	// Nehraje sa zapas
	if(!is_user_alive(id)) return;
	if(user_clan[id] == CLAN_C) return; 	// Ak to nieje hrac	 
	static clip, ammo, wpnid;
	wpnid = get_user_weapon(id, clip, ammo);
	switch(wpnid) {
		case CSW_AWP: WeaponAwp(id);

		default: return;
	}
}
stock WeaponAwp(const id) {	
	// Max. pocet testov dosiahnuty
	if(gAwptest[id] == gcached_TAWP_TEST) return PLUGIN_CONTINUE;
	// Ziadny test este nebol + Dalsie nahodne testy
	if(!gAwptest[id]) return user_awptest(id);
	// + Dalsie nahodne testy
	if(!gcached_TAWP_RAND) return PLUGIN_CONTINUE;
	if(random_num(0, gcached_TAWP_RAND) == 1) return user_awptest(id);
	return PLUGIN_CONTINUE;
}
stock screenshot(const id, const end[], const start[], any:...) {	
	new temp[BUFFER], steam[36], meno[32];
	vformat(temp, BUFFER - 1, start, 4);
	send_sprava(id, "%s -^x04 AutoScreenshot^x01 -^x04 %s", DEFINE_SAY, start);
	format_time(temp, BUFFER - 1, "%m/%d/%Y^x01 -^x04 %H:%M:%S", get_systime()); 
	get_steam(id, steam);
	get_user_name(id, meno, 31);
	send_sprava(id, "-^x04 %s^x01 -^x04 %s^x01 -^x04 %s^x01 - ", temp, steam, meno);
	sls_ZapasInfo(id, game);
	send_sprava(id, "%s -^x04 AutoScreenshot^x01 - %s", DEFINE_SAY, end);
	client_cmd(id, "snapshot"); 
	DEBUGlog2("Spraveny screenshot.")
}
stock user_awptest(const id) {
	gAwptest[id]++;
	screenshot(id, SCREEN_1, "Prebehol %d AWP Test", gAwptest[id]);
	test_register(id, 1);
	return PLUGIN_CONTINUE;
}
stock test_register(const id, const typ) {
	// + Posli udaje do databazy
	if (databaza == Empty_Handle) return PLUGIN_CONTINUE;
	new Handle:result = SQL_PrepareQuery( databaza, 
				"INSERT INTO %s (`id`, `zapas`, `typ`, `time`) VALUES ('%d', '%d', '%d', '%d')", 
				gcached_SQL_TESTY, user_webid[id], sql_id, typ, get_systime()
			);		
	if (!SQL_Execute(result)) mysql_error(result, "Test register sa nepodarilo odoslat.");	
	return PLUGIN_CONTINUE;
}
stock menu_screen(const id) {
	menu_AllPlayers(id, "MENU_SCREEN", "menu_screen_cmd");
}
public menu_screen_cmd(id, menu, item)
{
	new hrac, user2[BUFFER]
	hrac = menu_start(id, item, menu);  
	if(hrac == -1) return PLUGIN_HANDLED;
	
	if(sls_user_valid(hrac)) {
		// Pridat log
		new temp[BUFFER]
		info_user(id, temp, BUFFER-1);
		info_user(hrac, user2, BUFFER-1);
		log_to_file(LOG_SUBOR, "Hrac %s prikazal spravit screenshot %s", temp, user2);
		
		get_user_name(id, temp, 31);
		get_user_name(hrac, user2, 31);
		send_sprava(id, "%s^x03 Hrac %s spravil screenshot a je povinny ho uploadnut.", DEFINE_SAY, user2)
		format(temp, BUFFER-1, "%s prikazal spravit screenshot.", temp);
		screenshot(hrac, SCREEN_1, temp)
		test_register(hrac, 0);
	} else {
		send_sprava(hrac, "%s^x03 Akcia nebola vykonana.", DEFINE_SAY)
	}
	return PLUGIN_HANDLED;
}