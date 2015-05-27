<? // 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++

/*
require_once "sls.php";
$cup->debug = true;
$cup->aktivuj();
	// uzivatelia
	mysql_query("ALTER TABLE `fusion_users` 
					ADD `cs_meno` varchar(64) collate utf8_slovak_ci NOT NULL,
					ADD `clan_id` int(12) NOT NULL,
					ADD `clan_hodnost` int(6) NOT NULL default '9',
					ADD `cs_kill` int(6) NOT NULL default '0',
					ADD `cs_death` int(6) NOT NULL default '0',
					ADD `cs_time` int(6) NOT NULL default '0',
					ADD `cs_heslo` int(32) NOT NULL default '0',
					ADD `cs_bonus` int(6) NOT NULL default '0',
					ADD `cs_bonus_type` varchar(64) collate utf8_slovak_ci NOT NULL;")

	// Struktura tabulky `acp_clans`
	mysql_query("CREATE TABLE IF NOT EXISTS `acp_clans` (
				  `id` int(12) NOT NULL auto_increment,
				  `meno` varchar(64) collate utf8_slovak_ci NOT NULL,
				  `tag` varchar(32) collate utf8_slovak_ci NOT NULL,
				  `popis` varchar(256) collate utf8_slovak_ci NOT NULL,
				  `bodov` int(12) NOT NULL,
				  `steam` int(2) NOT NULL,
				  `avatar` varchar(128) collate utf8_slovak_ci NOT NULL,
				  `volne` int(4) NOT NULL,
				  `narod` int(4) NOT NULL default '0',
				  `zapasov_stare` int(6) NOT NULL default '0',
				  `aktivita` int(6) NOT NULL default '0',
				  `bonus` int(6) NOT NULL default '0',
				  `bonus_type` varchar(64) collate utf8_slovak_ci NOT NULL,
				  PRIMARY KEY  (`id`)
				) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_slovak_ci AUTO_INCREMENT=702;")

	// Struktura tabulky `acp_vyzva`
	mysql_query("CREATE TABLE IF NOT EXISTS `acp_vyzva` (
				  `id` int(6) NOT NULL auto_increment,
				  `ziada` int(6) NOT NULL,
				  `prijal` int(6) default NULL,
				  `datum` date NOT NULL,
				  `hodina` int(6) NOT NULL,
				  `mapa` varchar(32) collate utf8_slovak_ci NOT NULL,
				  `sukromna` int(12) NOT NULL,
				  `server` int(4) NOT NULL,
				  PRIMARY KEY  (`id`)
				) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_slovak_ci AUTO_INCREMENT=2642 ;")

	// Struktura tabulky `cup_zapas`
	mysql_query("CREATE TABLE IF NOT EXISTS `cup_zapas` (
				  `id` int(6) NOT NULL auto_increment,
				  `ziada` int(6) NOT NULL,
				  `ziada_skore` int(6) NOT NULL,
				  `ziada_bodov` int(6) NOT NULL,
				  `ziada_narocnost` int(6) NOT NULL default '0',
				  `ziada_bonus` int(6) NOT NULL default '0',
				  `prijal` int(6) NOT NULL,
				  `prijal_skore` int(6) NOT NULL,
				  `prijal_bodov` int(6) NOT NULL,
				  `prijal_narocnost` int(6) NOT NULL default '0',
				  `prijal_bonus` int(6) NOT NULL default '0',
				  `datum` varchar(14) collate utf8_slovak_ci NOT NULL,
				  `hod` int(4) NOT NULL,
				  `mapa` varchar(32) collate utf8_slovak_ci NOT NULL,
				  `ct_team` varchar(512) collate utf8_slovak_ci NOT NULL,
				  `t_team` varchar(512) collate utf8_slovak_ci NOT NULL,
				  `spe_team` varchar(512) collate utf8_slovak_ci NOT NULL,
				  `status` varchar(256) collate utf8_slovak_ci NOT NULL,
				  PRIMARY KEY  (`id`)
				) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_slovak_ci AUTO_INCREMENT=2596 ;")

	// Struktura tabulky `pozvanky`
	mysql_query("CREATE TABLE IF NOT EXISTS `pozvanky` (
				  `id` int(12) NOT NULL auto_increment,
				  `hrac_id` int(12) NOT NULL,
				  `clan_id` int(12) NOT NULL,
				  PRIMARY KEY  (`id`)
				) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_slovak_ci AUTO_INCREMENT=892 ;")	
				
	/* Logs
	
	CREATE TABLE `phpbanlist`.`logs` (
`id` INT( 12 ) NOT NULL AUTO_INCREMENT PRIMARY KEY ,
`typ` INT( 4 ) NOT NULL ,
`admin` INT( 12 ) NOT NULL ,
`koho` INT( 15 ) NOT NULL ,
`dovod` VARCHAR( 128 ) NOT NULL ,
`cas` DATE NOT NULL ,
`dokedy` DATE NULL
) 
	// Bot
	mysql_query("INSERT INTO `cstrike`.`fusion_users` (
			`user_id` , `user_name` , `user_password` , `user_email` , `user_hide_email` , `user_location` , `user_birth` , `user_aim` , `user_icq` , `user_msn` , `user_yahoo` , `user_web` , `user_theme` , `user_offset` , `user_avatar` , `user_sig` , `user_posts` , `user_joined` , `user_lastvisit` , `user_ip` , `user_rights` ,`user_groups` , `user_level` , `user_status` , `cs_meno` , `clan_id`)
			VALUES (
			NULL , 'GeCom s.r.o. Cup', 'c5f5170a5b317c5be15eabde4c7f2b90', 'SekyS@centrum.sk', '1', 'GeCom s.r.o. Cup', '0000-00-00', 'GeCom s.r.o. Cup', 'GeCom s.r.o. Cup', 'GeCom s.r.o. Cup', 'GeCom s.r.o. Cup', 'http://www.cs.gecom.sk', 'Default', '0', 'profile_avt[1].jpg', 'Ligovy bot ,stara sa nam o ligu :) GeCom s.r.o. Cup Powered by Seky`s Liga System. &copy; 2009 Seky', '1', '1', '0', '0.0.0.0', '', '.3', '101', '0', 'GeCom s.r.o. Cup', NULL
			);")
	// Spravyme formular nech vyplnia udaje ake chceu a zapiseme ....
	a last insert id je bot 	
$cup->ukonci();	

*/
	// 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++?>