/*
	Tento plugin vytvoril Lukas Sekerak a jemu prinalezia vsetke prava.
	Je zakazane kopirovat tento program bez suhlasu autora.
	Je zakazane kopirovat sucasti programu a podprogramov.
	Copyright 2008-2011, Lukas Sekerak
*/

new Float:prepare_time;

stock pause_init() {
	paused_server = PAUSE_NO;
}
stock PauseSet(id, const bool:set) 
{
	if(!id) id = find_player("h"); 
	if(!id) { 
		log_to_file(LOG_SUBOR, "PauseSet() Exception: No ID.");
		return PLUGIN_HANDLED;
	}
	set_cvar_float("pausable", set ? 1.0 : 0.0);
	client_cmd(id, "pause");
	return PLUGIN_CONTINUE;
}
stock PauseEnd(id = 0) {
	DEBUGlog2("UnpauseEnd")
	TaskDestroy();
	PauseSet(id, false)
	paused_server = PAUSE_NO;
}	
stock is_paused() { return ( paused_server != PAUSE_NO); }	
stock menu_pause(const id) 
{
	if(get_pcvar_float(CAS_PAUZA) <= 0.0) {
		send_sprava(id, "%s %L", DEFINE_SAY, LANG_SERVER, "PAUSE_OFFCVAR");
		return PLUGIN_CONTINUE;
	}
	menu_question(id, is_paused() ? "MENU_UNPAUSE" : "MENU_PAUSE", "menu_pause_cmd");
	return PLUGIN_CONTINUE;
}
public menu_pause_cmd(id, menu, item) {
	new key;
	key = menu_start(id, item, menu);
	if(key == 2) {
		MenuPauseCmd(id);
	}
	return PLUGIN_HANDLED;
}
stock MenuPauseCmd(const id) 
{	
	// Za admina
	RETURNH( MenuPauseCmdAdmin(id) )
	
	// Za hraca
	if( is_paused()) { // Snazi sa odpauznut
		if(paused_server == PAUSE_PREPARE) {
			send_sprava(id, "%s %s", DEFINE_SAY, LANG_SERVER, "PAUSE_PREPARE");
			return PLUGIN_HANDLED;
		}
		if(paused_server == PAUSE_SYSTEM) {
			send_sprava(id, "%s %s", DEFINE_SAY,  "Admin nastavil pauzu, nemozes ju zrusit.");
			return PLUGIN_HANDLED;
		}
		// Druhy clan ma pauzu
		if(paused_server != user_clan[id]) {
			send_sprava(id, "%s %L", DEFINE_SAY, LANG_SERVER, "PAUSE_ERROR");
			return PLUGIN_HANDLED;
		}
		
		UserPauseOff(id);
	} else { // Snazi sa dat pauzu
		// Ma vyprsany cas ?
		if(clan_pause[user_clan[id]] <= 0.0) {
			send_sprava(id, "%s %L", DEFINE_SAY, LANG_SERVER, "PAUSE_CANT", get_pcvar_float(CAS_PAUZA));
			return PLUGIN_HANDLED;
		}
		
		UserPauseOn(id, user_clan[id]);
	}	
	return PLUGIN_CONTINUE;
}
stock UserPauseOff(const id) {
	// Ak je zapnuta priprava
	if(get_pcvar_float(CAS_PAUZAPRE) > 0.0) {
		new sprava[BUFFER]
		get_user_name(id, sprava, 32);
		format(sprava, BUFFER - 1, "%s Hrac ^x03%s ^x01 odpauzol server. Priprav sa..", DEFINE_SAY, sprava)
		oznam(sprava);
		log_to_file(LOG_SUBOR, sprava);
		prepare_time = get_pcvar_float(CAS_PAUZAPRE) + 1.0;
		paused_server = PAUSE_PREPARE;
	} else {
		PauseEnd(id);
	}
}
stock MenuPauseCmdAdmin(const id) {
	// Je to admin a chce odpauznut server, je jedno kto ho puazol
	if(user_clan[id] == CLAN_C) {
		if(is_paused()) {
			UserPauseOff(id);
		} else {
			UserPauseOn(id, PAUSE_SYSTEM);
		}
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}
stock UserPauseOn(const id, const TypPauzy) {
	paused_server = TypPauzy;
	TaskStart();
	
	// + Dalsie logy
	new sprava[BUFFER]
	get_user_name(id, sprava, 32);
	format(sprava, BUFFER - 1, "%s Hrac ^x03%s ^x01 pauzol hru.", DEFINE_SAY, sprava)
	log_to_file(LOG_SUBOR, sprava);
	oznam(sprava);
	
	// Musi byt na konci ebo server zamrzne
	PauseSet(id, true);
}
public sls_PauseTask() {
	// Vola sa kazdu jednu sekundu,...
	switch(paused_server) {
		case PAUSE_NO: {
			// Nastala asi nejaka chyba
			TaskDestroy();
			DEBUGlog2("Exception at sls_PauseTask()")
		}
		case PAUSE_PREPARE: {
			prepare_time -= 1.0;
			if(prepare_time <= 0.0) PauseEnd();
			set_hudmessage(255, 255, 255, 0.42, 0.5, 0, 0.1, 1.0, 0.0, 0.0,4);
			show_hudmessage(0, "%L", LANG_SERVER, "PAUSE_PREPARING", floatround(prepare_time));
		}
		case PAUSE_SYSTEM: {
			set_hudmessage(255, 255, 255, 0.42, 0.5, 0, 0.1, 1.0, 0.0, 0.0,4);
			show_hudmessage(0, "Admin pauzol server");
		}
		default: {
			// Normalne odpocitavanie
			clan_pause[paused_server] -= 1.0;
			if(clan_pause[paused_server] <= 0.0) {
				PauseEnd();
				return;
			}
			// Vsetko ok ,zobraz dalsie info,...
			set_hudmessage(255, 255, 255, 0.42, 0.5, 0, 0.1, 1.0, 0.0, 0.0,4);
			show_hudmessage(0, "%L", LANG_SERVER, "PAUSE_TIMING", 
			floatround(clan_pause[paused_server]), clan_meno[paused_server]);
		}
	}
}