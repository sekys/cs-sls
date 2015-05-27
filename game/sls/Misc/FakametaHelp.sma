/*
	Tento plugin vytvoril Lukas Sekerak a jemu prinalezia vsetke prava.
	Je zakazane kopirovat tento program bez suhlasu autora.
	Je zakazane kopirovat sucasti programu a podprogramov.
	Copyright 2008-2011, Lukas Sekerak
*/

	/*~~~~~~~~~~~~  
	     - Fakameta -  
	~~~~~~~~~~~~~*/

// Offsety	
#define OFFSET_DEATHS			555
#define OFFSET_DEATH	 		444
#define HAS_DEFUSE_KIT			(1<<16)
#define EXTRAOFFSET				5
#define OFFSET_TEAM				114
#define OFFSET_MONEY			115
#define OFFSET_INTERALMODEL		126
#define OFFSET_BOMB_DEFUSE		193
#define OFFSET_TKED				216
#define SVC_DISCONNECT  		2
#define FADE_OUT				(1<<1)

// Teamy
#define CS_TEAM_UNASSIGNED	 	 0
#define	CS_TEAM_T 				 1
#define	CS_TEAM_CT				 2
#define	CS_TEAM_SPECTATOR 		 3

// Weapon bitsums
const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)
const SECONDARY_WEAPONS_BIT_SUM = (1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE)
// HACK: pev_ field used to store additional ammo on weapons
const PEV_ADDITIONAL_AMMO = pev_iuser1

#define fm_cs_get_user_deaths(%1)		get_offset_value(%1,OFFSET_DEATH)
#define fm_cs_set_user_nobuy(%1)    	set_pdata_int(%1, 235, get_pdata_int(%1, 235) & ~(1<<0) ) 
#define fm_find_ent_by_class(%1,%2) 	engfunc(EngFunc_FindEntityByString, %1, "classname", %2)
#define fm_remove_entity(%1) 			engfunc(EngFunc_RemoveEntity, %1)

enum CsInternalModel
{
	CS_DONTCHANGE,
	CS_CT_URBAN, 
	CS_T_TERROR,
	CS_T_LEET,
	CS_T_ARCTIC,
	CS_CT_GSG9,
	CS_CT_GIGN,
	CS_CT_SAS,
	CS_T_GUERILLA, 
	CS_CT_VIP,
	CZ_T_MILITIA,
	CZ_CT_SPETSNAZ
};

stock fm_cs_set_user_team(const client, const team)
{
	new oldteam = fm_cs_get_user_team(client);
	if( oldteam != team ) {
		switch( oldteam ) {
			case CS_TEAM_T: {
				if( is_user_alive(client) && (pev(client, pev_weapons) & (1<<CSW_C4)) )
				{
					engclient_cmd(client, "drop", "weapon_c4");
				}
			}
			case CS_TEAM_CT:
			{
				fm_cs_set_user_defuse(client, 0);
			}
		}
	}
	
	set_pdata_int(client, OFFSET_TEAM, _:team, EXTRAOFFSET);	
	dllfunc(DLLFunc_ClientUserInfoChanged, client, engfunc(EngFunc_GetInfoKeyBuffer, client));
	
	static const team_names[4][] =
	{
		"UNASSIGNED",
		"TERRORIST",
		"CT",
		"SPECTATOR"
	};
	
	if( msgid_team_info )
	{
		emessage_begin(MSG_BROADCAST, msgid_team_info);
		ewrite_byte(client);
		ewrite_string(team_names[team]);
		emessage_end();
	}
}
stock fm_cs_reset_user_model(const client) { dllfunc(DLLFunc_ClientUserInfoChanged, client, engfunc(EngFunc_GetInfoKeyBuffer, client)); }
stock fm_cs_get_user_team(const client, &{CsInternalModel,_}:model=CS_DONTCHANGE) {
	model = CsInternalModel:get_pdata_int(client, OFFSET_INTERALMODEL, EXTRAOFFSET);
	return get_pdata_int(client, OFFSET_TEAM, EXTRAOFFSET);
}
stock fm_cs_set_user_deaths(const client, const deaths) {
	set_pdata_int(client, OFFSET_DEATHS, deaths, EXTRAOFFSET);
	if( msgid_score_info) {
		emessage_begin(MSG_BROADCAST, msgid_score_info);
		ewrite_byte(client);
		ewrite_short(get_user_frags(client));
		ewrite_short(deaths);
		ewrite_short(0);
		ewrite_short(_:fm_cs_get_user_team(client));
		emessage_end();
	}
}
stock fm_cs_set_user_money(const client, const money, const flash=1) {
	set_pdata_int(client, OFFSET_MONEY, money, EXTRAOFFSET);
	if( msgid_money ) {
		emessage_begin(MSG_ONE_UNRELIABLE, msgid_money, _, client);
		ewrite_long(money);
		ewrite_byte(flash ? 1 : 0);
		emessage_end();
	}
}
stock fm_cs_set_user_defuse(const client, defusekit=1, r=0, g=160, b=0, flash=0)
{	
	new kit = get_pdata_int(client, OFFSET_BOMB_DEFUSE, EXTRAOFFSET);
	if( defusekit && !(kit & HAS_DEFUSE_KIT) )
	{
		set_pev(client, pev_body, 1);	
		set_pdata_int(client, OFFSET_BOMB_DEFUSE, (kit | HAS_DEFUSE_KIT), EXTRAOFFSET);	
		if( msgid_status_icon ) {
			emessage_begin(MSG_ONE_UNRELIABLE, msgid_status_icon, _, client);
			ewrite_byte((flash == 1) ? 2 : 1);
			ewrite_string("defuser");
			ewrite_byte(r);
			ewrite_byte(g);
			ewrite_byte(b);
			emessage_end();
		}
	} else if( !defusekit && (kit & HAS_DEFUSE_KIT) ) {
		set_pev(client, pev_body, 0);
		set_pdata_int(client, OFFSET_BOMB_DEFUSE, (kit & ~HAS_DEFUSE_KIT), EXTRAOFFSET);		
		if( msgid_status_icon ) {
			emessage_begin(MSG_ONE_UNRELIABLE, msgid_status_icon, _, client);
			ewrite_byte(0);
			ewrite_string("defuser");
			emessage_end();
		}
	}
}	
stock drop_weapons(id, dropwhat)
{
	// Get user weapons
	static weapons[32], num, i, weaponid
	num = 0 // reset passed weapons count (bugfix)
	get_user_weapons(id, weapons, num)
	
	// Loop through them and drop primaries or secondaries
	for (i = 0; i < num; i++)
	{
		// Prevent re-indexing the array
		weaponid = weapons[i]
		
		if ((dropwhat == 1 && ((1<<weaponid) & PRIMARY_WEAPONS_BIT_SUM)) || (dropwhat == 2 && ((1<<weaponid) & SECONDARY_WEAPONS_BIT_SUM)))
		{
			// Get weapon entity
			static wname[32], weapon_ent
			get_weaponname(weaponid, wname, charsmax(wname))
			weapon_ent = fm_find_ent_by_owner(-1, wname, id)
			
			// Hack: store weapon bpammo on PEV_ADDITIONAL_AMMO
			set_pev(weapon_ent, PEV_ADDITIONAL_AMMO, cs_get_user_bpammo(id, weaponid))
			
			// Player drops the weapon and looses his bpammo
			engclient_cmd(id, "drop", wname)
			cs_set_user_bpammo(id, weaponid, 0)
		}
	}
}
stock fm_find_ent_by_owner(entity, const classname[], owner)
{
	while ((entity = engfunc(EngFunc_FindEntityByString, entity, "classname", classname)) && pev(entity, pev_owner) != owner) { /* keep looping */ }
	return entity;
}
stock fm_set_user_frags(const index, const frags)  { set_pev(index, pev_frags, float(frags)); }
stock fm_give_item(const index, const item[]) {
	if (!equal(item, "weapon_", 7) && !equal(item, "ammo_", 5) && !equal(item, "item_", 5))
		return 0;
	
	static ent, save;
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, item));
	if (!pev_valid(ent))
		return 0;
	
	static Float:origin[3];
	pev(index, pev_origin, origin);
	set_pev(ent, pev_origin, origin);
	set_pev(ent, pev_spawnflags, pev(ent, pev_spawnflags) | SF_NORESPAWN);
	dllfunc(DLLFunc_Spawn, ent);
	
	save = pev(ent, pev_solid);
	dllfunc(DLLFunc_Touch, ent, index);
	if (pev(ent, pev_solid) != save) return ent;
	
	engfunc(EngFunc_RemoveEntity, ent);
	return -1;
}
stock fm_give_item_x(index, const item[], x) {
	for(new i; i <= x; i++) fm_give_item(index, item);
}