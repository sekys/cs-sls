/*
	Tento plugin vytvoril Lukas Sekerak a jemu prinalezia vsetke prava.
	Je zakazane kopirovat tento program bez suhlasu autora.
	Je zakazane kopirovat sucasti programu a podprogramov.
	Copyright 2008-2011, Lukas Sekerak
*/

#if defined HLTV

stock sock_open()
{
	if(query_in_progress) return PLUGIN_HANDLED;
	if(hltv_handle) socket_close(hltv_handle);
	query_in_progress=1;
	
	// hltv ip/port/password
	new error, hltv_cvar_ip[15], hltv_cvar_port;
	get_pcvar_string(HLTV_IP, hltv_cvar_ip, 15);
	hltv_cvar_port = get_pcvar_num(HLTV_PORT);	
	hltv_handle = socket_open(hltv_cvar_ip, hltv_cvar_port, SOCKET_UDP, error);
	
	// Nastala chyba ?
	if(error) {
		switch(error) {
			case 1: log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "HLTV_ERROR1");
			case 2: log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "HLTV_ERROR2", hltv_cvar_ip, hltv_cvar_port);
			case 3: log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "HLTV_ERROR3");
		}
		hltv_handle = 0;
		hltv_status = NOTCONNECTED;
		hltv_id = 0;
		query_in_progress=0;
		return PLUGIN_HANDLED;
	}
	DEBUG( log_to_file(LOG_SUBOR, "HLTV sock_open()"); )
	set_task(0.1, "send_challenge_hltv");
	recvattempts = 0;
	return PLUGIN_CONTINUE;
}
public send_challenge_hltv()
{
	new packetstr[32];
	
	// Call challenge number from hltv-server
	formatex(packetstr, sizeof packetstr -1, "%c%c%c%cchallenge rcon^n", -1, -1, -1, -1);
	socket_send2(hltv_handle, packetstr, sizeof packetstr -1);
	
	DEBUG( log_to_file(LOG_SUBOR, "HLTV Challenge number request sent."); )
	set_task(0.1, "get_rconquery");
}
public get_rconquery()
{
	if(!hltv_handle) {
		log_to_file(LOG_SUBOR, "[HLTV] get_rconquery called with null socket");
		query_in_progress = 0;
		hltv_status = NOTCONNECTED;
		return PLUGIN_CONTINUE;
	}
	
	if(!socket_change(hltv_handle, 1)) { 
		recvattempts += 1;
		if (recvattempts > 5) {
			log_to_file(LOG_SUBOR, "[HLTV] No response from the server.");
			abort_query();
			recvattempts = 0;
			return PLUGIN_HANDLED;
		} else {
			DEBUG( log_to_file(LOG_SUBOR, "[HLTV] get challenge number try: %d", recvattempts); )
			set_task(0.2, "get_rconquery");	//5 * 0.2: 1sek timeout
			return PLUGIN_CONTINUE;
		}
	}
	new packet[64];
	recvattempts = 0;
	socket_recv(hltv_handle, packet, sizeof packet -1);
	
	if(!equal(packet, {-1,-1,-1,-1,'c'}, 5)) { 
		log_to_file(LOG_SUBOR, "[HLTV] wrong challenge-nr response from HLTV server.");
		log_to_file(LOG_SUBOR, "[HLTV] returning packet: %s", packet);
		abort_query();
		return PLUGIN_HANDLED;
	}
	
	// Build challenge number
	DEBUG( log_to_file(LOG_SUBOR, "[HLTV] returning challengenr packet: %s", packet); )
	new i = 0, offset = 19;
	while(47 < packet[i+offset] < 58) {
		copy(hltvrcon[i],1,packet[i+offset]) ;
		i++;
	}
	i=0;
	set_task(0.5, "send_command");
	return PLUGIN_CONTINUE;
}
stock abort_query()
{
	socket_close(hltv_handle);
	query_in_progress = 0;
	hltv_handle = 0;
	DEBUG( log_to_file(LOG_SUBOR, "[HLTV] Socket closed."); )
}
public send_command()
{
	new tmp[32]; // Automatika - alebo sv_password premenna
	get_cvar_string("sv_password", tmp, 31); //game-server has a password? then get it
	if(!equal(tmp,"")) {
		format(hltv_command, sizeof hltv_command -1, "serverpassword %s;%s", tmp, hltv_command);
	}
	
	new packetstr[256];
	HLTVGetRCon(tmp, 20);
	formatex(packetstr, sizeof packetstr -1, 
		"%c%c%c%crcon %s ^"%s^" %s^n", 
		-1,-1,-1,-1, 
		hltvrcon, tmp, hltv_command
	);
	socket_send2(hltv_handle, packetstr, sizeof packetstr -1);	
	DEBUG( log_to_file(LOG_SUBOR, "[HLTV] Sending command: %s", hltv_command); )
	
	if(hltv_status != NOTCONNECTED) {
		set_task(1.0, "send_record");
	} else {
		abort_query();
	}
	return PLUGIN_CONTINUE;
}

public send_record()
{
	RETURNH(send_record_fail())
	recvattempts = 0;
	new packetstr[128], tmp[21];
	HLTVGetRCon(tmp, 20);
	
	// Loop cmd - nwm naco..
	formatex(packetstr, sizeof packetstr -1, 
		"%c%c%c%crcon %s ^"%s^" loopcmd 1 120 servercmd status ^n", 
		-1,-1,-1,-1,
		hltvrcon, tmp);
	
	socket_send2(hltv_handle, packetstr, sizeof packetstr -1);
	DEBUG( log_to_file(LOG_SUBOR, "[HLTV] Sending record command (file: %s)", demofile); )
	
	// Teraz demo
	formatex(packetstr, sizeof packetstr -1, 
		"%c%c%c%crcon %s ^"%s^" record %s ^n", 
		-1,-1,-1,-1, 
		hltvrcon, tmp, demofile);	
	socket_send2(hltv_handle, packetstr, sizeof packetstr -1);
	abort_query();
	hltv_status = RECORDING;
	return PLUGIN_CONTINUE;
}

#endif