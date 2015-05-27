/*
	Tento plugin vytvoril Lukas Sekerak a jemu prinalezia vsetke prava.
	Je zakazane kopirovat tento program bez suhlasu autora.
	Je zakazane kopirovat sucasti programu a podprogramov.
	Copyright 2008-2011, Lukas Sekerak
*/

	/*~~~~~~~~~~~~  
	  - Plugin -  
	~~~~~~~~~~~~~*/
	
public plugin_init() 
{
	setstatuslang("Starting...");
	register_plugin("Seky's Liga System", VERZIA, "Seky")	
	register_cvar("cup_version",VERZIA,FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_UNLOGGED|FCVAR_SPONLY)
	hltv_plugin_init();
	security_plugin_init();
	sls_init();
	test_init();
	pause_init();
	blockweapons_init();
	return PLUGIN_CONTINUE;
}
public plugin_modules() {
	require_module("fakemeta");
	require_module("sqlx");
	return PLUGIN_CONTINUE;
}
public spoj_databazu() {
	RETURNH( security_spoj_databazu() )
	RETURNH( sls_spoj_databazu() )
	RETURNH( security_contact() )
	return PLUGIN_CONTINUE;
}
public get_score_info() {
	new tym[2]; read_data(1,tym,1);
	if (tym[0] == 'T') return sls_ScoreGet(CS_TEAM_T, read_data(2));
	if (tym[0] == 'C') return sls_ScoreGet(CS_TEAM_CT, read_data(2));
	return PLUGIN_CONTINUE;
}
#if defined STATUS		
	// Fukncia nastavuje STATUS serveru v zozname serverov
	public status_serveru() {  forward_return( FMV_STRING, status );  return FMRES_SUPERCEDE; } 
#endif

// PomocnE fuknciE , spracuvava a dalej vola vyber teamov
public event_vyber_teamov_1(id) { new arg[2]; read_argv(1,arg,1); return sls_TeamChoose(id, str_to_num(arg)); }
public event_vyber_teamov_2(id,key) {	return sls_TeamChoose(id,key+1); }
public fullupdate(id) { return PLUGIN_HANDLED_MAIN; }
public client_authorized(id) { sls_cw_access(id); return PLUGIN_CONTINUE; }
public client_connect(id)  { return sls_connect(id); }
public client_infochanged(id){ return sls_infochanged(id); }
public client_disconnect(id) {	return sls_disconnect(id); }
