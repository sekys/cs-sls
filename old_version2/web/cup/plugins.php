<?	 // 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++

// Zoznam aktivovanych pluginov	
	self::$plugins = array(
		//  	URL nazov	  			 Subor  			Aplikacia povolena	Zoznam	Popis									
		array( 'info', 			'info.php', 			1,	0	),
		array( 'rank', 			'rank_tabulka.php', 	1,	25	),	// zoznam najlepsich clanov
		array( 'registrovat', 	'create_clan.php', 		1,	0	),	// Clan registr&aacute;cia:
		array( 'admin', 		'admin.php', 			1,	0	),	// admin panel
		array( 'nastavenia', 	'edit_clan.php', 		1,	0	),	// uprava nastaveni
		array( 'clan', 			'info_clan.php', 		1,	10	),	// Informacie o clane,profil clan
		array( 'pozvanku', 		'poslat_pozvanku.php', 	1,	0	),	// Poslat pozvanku hracovy
		array( 'pozvanky', 		'prijat_pozvanku.php', 	1,	0	),	// Prijme pozvanku
		array( 'pozvanka', 		'ziadat_pozvanku.php', 	1,	0	),	// ak v profile clanu klikne vstupit
		array( 'vyzvy', 		'zoznam_vyzva.php', 	1,	20	),	// Zoznam vyzviev podla datumu
		array( 'vyzva', 		'prijat_vyzvu.php', 	1,	0	),	// Clan leader prijme vyzvu vo web poste
		array( 'vyzvu', 		'poslat_vyzvu.php', 	1,	0	),	// V profile klikne na tlactiko a da vyzvu
		array( 'miesto', 		'hraci_tabulka.php', 	1,	20	),	// Clany ktore maju volne miesta
		array( 'hraci', 		'edit_players.php', 	1,	0	),	// Clan leader upravuje a hlada hracov
		array( 'clanvyzvy', 	'edit_vyzvy.php', 		1,	0	),	// Clan leader upravuje svoje vyzvy
		array( 'zapas', 		'info_zapas.php', 		1,	0	),	// Zapas info
		array( 'historia', 		'history.php', 			1,	20	),	// Zoznam zapasov
		array( 'zapasy', 		'zoznam_zapasy.php', 	1,	10	),	// Najblizsie zapasi
		array( 'datum', 		'datum.php', 			0,	0	),	// Datum
		array( 'demo', 			'demo.php', 			0,	0	)	// Stiahnut demo
	);	

	// 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++?>