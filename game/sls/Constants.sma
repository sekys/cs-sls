/*
	Tento plugin vytvoril Lukas Sekerak a jemu prinalezia vsetke prava.
	Je zakazane kopirovat tento program bez suhlasu autora.
	Je zakazane kopirovat sucasti programu a podprogramov.
	Copyright 2008-2011, Lukas Sekerak
*/

	/*~~~~~~~~~~~~  
	     - Konstanty -  
	~~~~~~~~~~~~~*/
	
// Clany	
#define VERZIA        		"SLS 3.0"
#define CLAN_A				0				// definicia 1. / a clanu 
#define CLAN_B				1 				// definicia 2 / b clanu 
#define CLAN_C				-1 				// v ziadnom clane

// Casovace
#define TASK_OZNAM 			33				// oznamy
#define TASK_PLAYER 		66				// hraci a odpajenie
#define TASK_PLAYER_1 		67				// hraci a odpajenie
#define TASK_PLAYER_2		68				// hraci a odpajenie
#define TASK_PLAYER_3 		69				// hraci a odpajenie
#define TASK_END 			99				// do x hod ukonci zapas tak ci onak
#define TASK_FAIL 			100				// do x hod ukonci zapas tak ci onak
#define TASK_TAB 			101				// task pre Score prepisovac pri starte
#define TASK_HUD 			102				//  task pre HUD INFO pri starte
#define TASK_PAUSE 			103				//  task pre pause

// Misc
#define TLACITKA (1<<0)|(1<<1)|(1<<9)		// knife menu tlacitka
#define SLOTOV 				15				// pocet slotov na servery

// Retazce	
#define STR_PARSER_UDAJ		"x04x"			// parser MEna ,kill ,death
#define STR_PARSER_HRAC		"x08x"			// parser Hracov
#define	STR_UVODZOVKA_A		"x09x"			// prepisovac '
#define	STR_UVODZOVKA_B		"x10x"			// prepisovac "
#define BUFFER 				128				// bytov - definuj buffer pre normalne vety ...

#define SCREEN_1		"Tento screen si povinny odoslat."
#define SCREEN_0		"Tento screen nemusis odoslat."

#pragma dynamic 16384 		// Extra pamet ...  16k * 4 = 64k

#define PAUSE_NO	 		-1
// 0 - CLAN A
// 1 - CLAN B
#define PAUSE_PREPARE 		2
#define PAUSE_SYSTEM		3