/*
	Tento plugin vytvoril Lukas Sekerak a jemu prinalezia vsetke prava.
	Je zakazane kopirovat tento program bez suhlasu autora.
	Je zakazane kopirovat sucasti programu a podprogramov.
	Copyright 2008-2011, Lukas Sekerak
*/

public sls_WelMessage(id)
{
	// K HLTV chceme ukazat spravu - nech v demach je verzia serveru
	if(!is_user_connected(id)) return PLUGIN_HANDLED;
	new meno[32];
	get_user_name(id, meno, 31);

	// Uvodna sprava - reklama
	set_hudmessage(0, 0, 255, 0.2, 0.2, 0, 0.1, 5.0, 0.0, 0.0, 4);
	show_hudmessage(id, "Powered by %s:^n%L %s", VERZIA, LANG_SERVER, "WELCOME", meno); 
	
	// HLTV
	send_sprava(id, "%s %L", DEFINE_SAY, LANG_SERVER, "UVODNA");
	send_sprava(id, "%s %L", DEFINE_SAY, LANG_SERVER, "UVODNA2");
	return PLUGIN_CONTINUE;
}
public sls_HandleSay(id)
{
	/*	 Zachit say 		FORWARD
		
		Fukncia zachicuje co hraci napisu a
		sputat dalsie fukncie....
	*/
	if(!sls_user_valid(id)) return PLUGIN_CONTINUE;
	new napisane[64], buffer_a[32], buffer_b[32];
	read_args(napisane, 63);
	
	formatex(buffer_a, sizeof buffer_a - 1, "%L", LANG_SERVER, "SAY_STATS1");
	formatex(buffer_b, sizeof buffer_b - 1, "%L", LANG_SERVER, "SAY_STATS2");
	if( containi(napisane, buffer_a) > -1 || containi(napisane, buffer_b) > -1) {		
		sls_Info(id);
	}	
	
	formatex(buffer_a, sizeof buffer_a - 1, "%L", LANG_SERVER, "SAY_INFO1");
	formatex(buffer_b, sizeof buffer_b - 1, "%L", LANG_SERVER, "SAY_INFO2");
	if( containi(napisane, buffer_a) > -1 || containi(napisane, buffer_b) > -1) {		
		formatex(napisane, sizeof napisane - 1, "%L", LANG_SERVER, "URL_INFO");
		show_motd(id, napisane, VERZIA);
	}
	return PLUGIN_CONTINUE;
}	
stock sls_Info(const id)
{		
	/*	 Vypis info		NATIVE
	
		Fukncia vypise aktulne udaje o zapase alebo
		o priprave, pripadne stavu serveru alebo ligy.
	*/
	sls_ZapasInfo(id, game);
	
	// DEBUG - poddrobne udaje	
	if(DEBUGon() && is_admin(id)) sls_DebugInfo(id);
	return PLUGIN_CONTINUE;
}
stock sls_ZapasInfo(const id, const hra)
{
	switch(hra) {
		case zapas_sa_nekona: {
			send_sprava(id, "%s %L", DEFINE_SAY, LANG_SERVER, "INFO_ZAPAS")
		}
		case zapas_ma_byt: {
			new sprava[BUFFER], sprava_b[BUFFER];
			format_time(sprava, 21, "%Y.%m.%d o %H", cas_zapasu)
			format_time(sprava_b, 21, "%H:%M", start_zapasu + floatround(get_pcvar_float(CAS_HRACI_NEPRIDU)) )
			send_sprava(id, "%s %L", DEFINE_SAY, LANG_SERVER, "INFO_START", sprava, sprava_b);						
			formatex(sprava,	BUFFER - 1, "^x03%s ^x01", clan_tag[CLAN_A])
			formatex(sprava_b,	BUFFER - 1, "^x03%s", clan_tag[CLAN_B])
			send_sprava(id, "%s %L", DEFINE_SAY, LANG_SERVER, "INFO_CLANY",  sprava, sprava_b )
		}
		case cvicne_kolo: {
			if(!kol) return sls_ZapasInfo(id, hra-1); // pofix
			new sprava[BUFFER], sprava_b[BUFFER];
			formatex(sprava,   BUFFER - 1, "^x03 %i^x01", kol);
			formatex(sprava_b, BUFFER - 1, "^x03%i ^x01", gcached_KOL_CVICNE);
			send_sprava(id, "%s %L", DEFINE_SAY, LANG_SERVER, "KOLO_INFO", sprava, sprava_b, LANG_SERVER, "KOLO_CVICNE");
		}
		case knife_kolo: {
			if(!kol) return sls_ZapasInfo(id, hra-1); // pofix
			send_sprava(id, "%s %s", DEFINE_SAY, "Prebieha knife kolo.");
		}
		case normal_kolo: {
			if(!kol) return sls_ZapasInfo(id, hra-1); // pofix
			new sprava[BUFFER], sprava_b[BUFFER];
			formatex(sprava,   BUFFER - 1, "^x03 %i^x01", kol)
			formatex(sprava_b, BUFFER - 1, "^x03%i ^x01", get_pcvar_num(KOL_HRA))
			send_sprava(id, "%s %L", DEFINE_SAY, LANG_SERVER, "KOLO_INFO", sprava, sprava_b, LANG_SERVER, "KOLO")			
			
			formatex(sprava,   BUFFER - 1, "^x03%s^x01", clan_meno[CLAN_A])
			formatex(sprava_b, BUFFER - 1, "^x03%d", clan_score[CLAN_A])
			send_sprava(id, "%12L", LANG_SERVER, "INFO_CLAN", sprava, sprava_b )				
			
			formatex(sprava,   BUFFER - 1, "^x03%s^x01", clan_meno[CLAN_B])
			formatex(sprava_b, BUFFER - 1, "^x03%d", clan_score[CLAN_B])
			send_sprava(id, "%12L", LANG_SERVER, "INFO_CLAN", sprava, sprava_b )
		}
	}
	return PLUGIN_CONTINUE;
}
stock sls_DebugInfo(const id)
{
	client_print( id,  print_console,"-------------DEBUG--------------"	)
	client_print( id,  print_console,"%L", LANG_SERVER, "INFO_DEBUGCLAN", "A", clan_team[CLAN_A], clan_score[CLAN_A], clan_vymena_score[CLAN_A], f_pocet_hracov(CLAN_A), clan_bonus[CLAN_A] )
	client_print( id,  print_console,"%L", LANG_SERVER, "INFO_DEBUGCLAN", "B", clan_team[CLAN_B], clan_score[CLAN_B], clan_vymena_score[CLAN_B], f_pocet_hracov(CLAN_B), clan_bonus[CLAN_B] )	
	client_print( id,  print_console,"%L", LANG_SERVER, "INFO_DEBUG", game, kol, quota)			
	client_print( id,  print_console,"-------------------------------"	)
}
public sls_Hud()     
{  
	/*	Ukaz Info HUD		NATIVE
	
		Statisticky panel ,prebrane z VIP
		CL - Skore 16:1 - Bonus 85%
	*/
	new sprava[BUFFER], hodnost[5], id;
	
	for(new id = 1; id <= max_hracov; id++)
	{						
		if(!sls_user_valid(id)) continue;					
		if(!is_user_alive(id)) continue;	

		// Najprv hodnost zistime	
		switch_hodnost(id, sprava, BUFFER-1);
		/* - nejde to,...proste nejde
		formatex(hodnost, 4, "HODNOST_%d", user_hodnost[id])
		format(sprava, BUFFER -1 , "%L", LANG_SERVER, hodnost)
		*/
		
		// Informacie
		format(sprava, BUFFER -1, "%L", LANG_SERVER, "HUD", sprava, get_user_frags(id), get_user_deaths(id), user_bonus[id])

		message_begin(MSG_ONE, msgid_status_text, {0,0,0}, id);  
		write_byte(0);  
		write_string(sprava); 
		message_end();	
	}
	return PLUGIN_CONTINUE;
}	
stock info_user(const id, info[], const charmax) {
	static authid[36], ip[16], meno[32];
	get_user_authid(id, authid, 35);
	get_user_ip(id, ip, 31, 1);
	get_user_name(id, meno, 31);
	format(info, charmax, "%s [WEBID(%d)-STEAM(%s)-IP(%s)]", meno, user_webid[id], authid, ip)
}
stock switch_hodnost(const id, sprava[], const charmax)
{
	switch(user_hodnost[id])
	{
		case 1: { formatex(sprava, charmax, "%L", LANG_SERVER, "HODNOST_1" ); }
		case 2: { formatex(sprava, charmax, "%L", LANG_SERVER, "HODNOST_2" ); }
		case 3: { formatex(sprava, charmax, "%L", LANG_SERVER, "HODNOST_3" ); }
		case 4: { formatex(sprava, charmax, "%L", LANG_SERVER, "HODNOST_4" ); }	
		case 5: { formatex(sprava, charmax, "%L", LANG_SERVER, "HODNOST_5" ); }	
		case 6: { formatex(sprava, charmax, "%L", LANG_SERVER, "HODNOST_6" ); }
		case 7: { formatex(sprava, charmax, "%L", LANG_SERVER, "HODNOST_7" ); }
		case 8: { formatex(sprava, charmax, "%L", LANG_SERVER, "HODNOST_8" ); }
		case 9: { formatex(sprava, charmax, "%L", LANG_SERVER, "HODNOST_9" ); }
		default : { formatex(sprava, charmax, "%L", LANG_SERVER, "HODNOST_0" ); }
	}
}
public cup_who(id, level, cid) {
	if(!cmd_access(id, level, cid, 1)) return PLUGIN_HANDLED;
	new name[32], team[2]
	client_print( id,  print_console, "^n%s:^n #  %.15s %-5.5s %-5.5s %-5.5s %-5.5s %-5.5s %-1.5s", 
		"Hraci", 
		"Meno", 
		"WebID", 
		"Clan",
		"Hodnost", 
		"Bonus", 
		"Menu", 
		"Presun"
	);
	for(new hrac = 1; hrac <= max_hracov; hrac++)
	{						
		if(!sls_user_valid(hrac)) continue;
		get_user_name(hrac, name, 31);
		switch(user_clan[hrac]) {
			case CLAN_A : team = "A";
			case CLAN_B : team = "B";
			case CLAN_C : team = "C";
		}
		client_print(id, print_console, "%15.15s %-5.5i %-5.5s %-5.5i %-5.5i %-5.5s %-5.5i",  
			name, 
			user_webid[hrac],
			team,			
			user_hodnost[hrac], 
			user_bonus[hrac], 
			user_menu[hrac] ? "Ano" : "Nie", 
			user_presun[hrac]
		);
	}
	return PLUGIN_HANDLED;
}