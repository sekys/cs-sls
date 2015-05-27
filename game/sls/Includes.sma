/*
	Tento plugin vytvoril Lukas Sekerak a jemu prinalezia vsetke prava.
	Je zakazane kopirovat tento program bez suhlasu autora.
	Je zakazane kopirovat sucasti programu a podprogramov.
	Copyright 2008-2011, Lukas Sekerak
*/

	/*~~~~~~~~~~~~  
	   - Include -  
	~~~~~~~~~~~~~*/
		
#include <amxmodx>							// jadro
#if AMXX_VERSION_NUM < 180 
	#assert Minimalne AMX Mod X v1.8.0 je potrebny! 
#endif
#include <amxmisc>							// zakladne veci + hud system
#include <fakemeta>							// operacne funkcie 
#include <sqlx>								// Funkcie s databazou.
#include <screenfade_util>					// Misc funkcia na obrazovku
#include <cstrike>
#include <hamsandwich>
#if defined HLTV
	#include <sockets>							// pre hltv
#endif

// Macra
#define DEBUGon() 				gcached_DEBUG >= 1
#define DEBUG2on() 				gcached_DEBUG >= 2
#define DEBUG(%1) 				if(gcached_DEBUG >= 1) { %1 }
#define DEBUGlog(%1) 			if(gcached_DEBUG) >= 1) { log_to_file(LOG_SUBOR, %1); }
#define DEBUG2(%1) 				if(gcached_DEBUG >= 2) { %1 }
#define DEBUGlog2(%1) 			if(gcached_DEBUG >= 2) { log_to_file(LOG_SUBOR, %1); }

#define get_steam(%1,%2)		get_user_authid(%1,%2,35)
#define setstatus(%1) 			format(status, 31, %1)
#define setstatuslang(%1) 		format(status, 31, "%L", LANG_SERVER, %1)
#define RETURNH(%1)				if(%1 == PLUGIN_HANDLED) return PLUGIN_HANDLED;

// Subcasti
#include "sls/Constants.sma"
#include "sls/Global.sma"
#include "sls/Misc/FakametaHelp.sma"
#include "sls/System/Security.sma"
#include "sls/Misc/PluginMisc.sma"
#include "sls/System/TeamChooseSystem.sma"
#include "sls/System/ScoreManager.sma"
#include "sls/Misc/Events.sma"
#include "sls/Misc/Utilities.sma"
#include "sls/Misc/Functions.sma"
#include "sls/Misc/Tasks.sma"
#include "sls/System/Modul.Normal.sma"
#include "sls/System/EndSystem.sma"
#include "sls/User/User.sma"
#include "sls/User/UserLogin.sma"
#include "sls/User/UserMethods.sma"
#include "sls/ClanWar/ClanWarHelp.sma"
#include "sls/ClanWar/ClanWarRoundCvicne.sma"
#include "sls/ClanWar/ClanWarRound.sma"
#include "sls/ClanWar/ClanWar.sma"
#include "sls/System/QuoteSystem.sma"
#include "sls/System/Game.sma"
#include "sls/System/MenuSystem.sma"
#include "sls/System/Tasker.sma"
#include "sls/HLTV/Main.sma"
#include "sls/HLTV/Socket.sma"
#include "sls/HLTV/Help.sma"
#include "sls/System/Testy.sma"
#include "sls/System/Pause.sma"
#include "sls/System/Info.sma"
#include "sls/System/BlockWeapons.sma"
#include "sls/System/SaveLoad.sma"