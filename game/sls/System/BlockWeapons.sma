/*
	Tento plugin vytvoril Lukas Sekerak a jemu prinalezia vsetke prava.
	Je zakazane kopirovat tento program bez suhlasu autora.
	Je zakazane kopirovat sucasti programu a podprogramov.
	Copyright 2008-2011, Lukas Sekerak
*/
#if cellbits == 32
    #define OFFSET_BUYZONE 235
#else
    #define OFFSET_BUYZONE 268
#endif

// FY mapy mozny problem..

stock blockweapons_init() {
	RegisterHam(Ham_Touch, "weaponbox", "fw_TouchWeapon");
	RegisterHam(Ham_Touch, "armoury_entity", "fw_TouchWeapon");
	RegisterHam(Ham_Touch, "weapon_shield", "fw_TouchWeapon");
	
	register_message(get_user_msgid("StatusIcon") , "Message_StatusIcon");
} 
public Message_StatusIcon( const iMsgId, const iMsgDest, const iPlayer )
{
    if(!BlockedWeapons) return PLUGIN_CONTINUE;
	static szMsg[ 8 ];
	get_msg_arg_string( 2, szMsg, 7 );

	if( equal( szMsg, "buyzone" ) ) {
		set_pdata_int( iPlayer, OFFSET_BUYZONE, get_pdata_int( iPlayer, OFFSET_BUYZONE ) & ~( 1<<0 ) );
		return PLUGIN_HANDLED;
	}
    return PLUGIN_CONTINUE;
}  

stock ClearWeaponsAll() {
	new ent = -1, string[32]	
	while((ent = fm_find_ent_by_class(ent, "weaponbox"))) {
		if(pev_valid(ent)) {
			fm_remove_entity(ent);
		}
	}
}
stock DropWeaponsAll() {
	DEBUGlog2("DropWeaponsAll")
	for(new hrac = 1; hrac <= max_hracov; hrac++) {					
		if(!sls_user_valid(hrac)) continue;		
		if(user_clan[hrac] == CLAN_C) continue;	
		if(!is_user_alive(hrac)) continue;	
		drop_weapons(hrac, 1);
		drop_weapons(hrac, 2);
	}
}
stock DefaultsWeapon() {
	for(new hrac = 1; hrac <= max_hracov; hrac++) {					
		if(!sls_user_valid(hrac)) continue;		
		if(user_clan[hrac] == CLAN_C) continue;	
		if(!is_user_alive(hrac)) continue;	
		DefaultWeapon(hrac);
	}
}
public fw_TouchWeapon(weapon, id) {
	// Dont pickup weapons
	if(BlockedWeapons) { 
		// Not a player
		if(1 <= id <= max_hracov && is_user_connected(id)) return HAM_SUPERCEDE;
	}
	return HAM_IGNORED;
}
stock fm_strip_user_weapons(const index) { // ucinnejsie ako drop ale dostrani vsetjkko
	new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "player_weaponstrip"));
	if (!pev_valid(ent)) return 0;
	dllfunc(DLLFunc_Spawn, ent);
	dllfunc(DLLFunc_Use, ent, index);
	engfunc(EngFunc_RemoveEntity, ent);
}
stock DefaultWeapon(const id) {
	fm_strip_user_weapons(id);
	fm_give_item(id, "weapon_knife" );
	
	if(fm_cs_get_user_team(id) == CS_TEAM_CT) {
		fm_give_item(id, "weapon_usp" );
		fm_give_item_x( id, "ammo_9mm", 2);	
	} else if(fm_cs_get_user_team(id) == CS_TEAM_T) {
		fm_give_item(id, "weapon_glock18");
		fm_give_item_x(id, "ammo_45acp", 2);	
	}
}