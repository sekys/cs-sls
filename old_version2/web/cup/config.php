<?	 // 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++

// Config
	// © By Seky		
	self::$aplikacia = "http://www.cs.gecom.sk/webb/";	// Adresa aplikacie ,fusionu ....
	self::$admin_skupina = 27;					// id  ADMIN skupiny 
	self::$bot = 451;							// ID bota
	self::$debug = false;						// Aktivovany debug
	self::$style = 'styles_web2';				// Aktivovany styl
	self::$cuplanguage = 'sk';						// jazyk nastaveny pre aplikaciu
	self::$zoznam_vzdialenost	= 3;			// Vziadlenost v zoznamoch
	self::$odstavka = false;					// Odstavka a dovod , priklad :
	//self::$odstavka = 'Liga prechadza prestavbou.';
	
// Mysql udaje na spojenie			IP		MENO		HESLO		DATABAZA
	self::$mysql = array("localhost", "cstrike" , "asda6mdks5dfds", "cstrike");
		
// Servery							Meno 				|| 		IP
	self::$server = array(
						array('GeCom s.r.o. Cup #1', '85.237.232.36:27018')						
						//array('GeCom::Lekos Cup #2', '85.237.232.36:27021')						
						//array('GeCom::Lekos Cup #2', '85.237.232.36:27017')						
						);	
// Vyzvy
	self::$vyzvy = 5;												// Pocet vyziev na clan, 0 vyzvy su pozastavene	
	self::$max_zruseni = 5;												// Maximalny pocet zruseni...potom sa clan vymaze
	self::$minimalne_hracov = 2;									// Minimalny pocet hracov v clane aby mohli hrat ligu
	self::$vyzva_hodina = array(		// Nastavenia na kazdy server zvlast
							array(0,1,2,3,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23),
							array(0,1,2,3,6,7,8,9,10,11,21,22,23),
						);
	self::$vyzva_mapa = array( // Pridavat len mapy ,kotre urcite funguje a bez .bsp !
							"de_dust2", "cs_italy", "de_nuke", "de_dust", "de_inferno", "de_train", 
							"de_aztec", "cs_militia", "cs_assault", "de_cpl_overrun", "de_dust2_wz", 
							"de_cpl_strike", "de_dust25", "de_dust2_2009", "cs_33_estate", "de_school13", 
							"de_shop", "de_rome", "de_soos", "de_cbble",  "de_prodigy", "de_aztec", 
							"de_rats_1337", "de_rats3", "awp_gowenna", "awp_docks", "scoutzknivez"
						);	
						
// Str parsery - uprav aj v re			
	self::$str_parser_1 = 'x04x';		// udaje
	self::$str_parser_2 = 'x08x';		// hracov
				
// Hodnosti	
	self::$hodnost = array (	//Meno
						1 =>			
						'Clan Leader',
						'Z&aacute;stupca CL',
						'Spr&aacute;vca hr&aacute;&#269;ov',
						'Rusher',
						'Camper',
						'Skiller',
						'Sniper',	
						'Lama Clanu',
						'Hr&aacute;&#269'	
						//'Ligov&yacute; admin'	
					);	
						
// Bonusy
	self::$bonus = array(
					// Clany
					array(	// Nazov									oznacenie	bonus			obrazok
						array("1. miesto",							"a",	"15", 	"1miesto.png"),
						array("2. miesto",							"b", 	"10", 	"2miesto.png"),
						array("3. miesto", 							"c", 	"5", 	"3miesto.png"),
						array("Clan s najlep&scaron;ou aktivitou", 	"d", 	"3", "aktivita.png")
					),
					// Hraci
					array(
						array("Najlepsi skill", 					"a", 	"5", 	"5.gif")
					)
				);			

	// 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++?>