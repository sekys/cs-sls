<? // ++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++

// Aktviujeme triedu a kontrolu stranok vypneme
$page = true;
$zlozka = 'cup';
// Engine
require $zlozka."/sls.php";

//  Lachko nastavitelna bez fusionu alebo na inu aplikaciu ....
$aplikacia = SLS::aplikacia();

if($aplikacia)	{			
	// Fusion header
	require_once "maincore.php";
	require_once "subheader.php";
	require_once "side_left.php";
	
	// Dosadime premenne
	SLS::mysql_spojenia();
	SLS::GetUserData();
	
	// Aktivujeme stranky
	if(SLS::pokracovat()) {
		SLS::aktivuj();
		SLS::jazyk();
		$stranka = SLS::stranka();
		if($stranka) { require($stranka); }
		SLS::ukonci();
	}
	
	// Fusion footer
	mysql_select_db("cstrike");
	require_once "side_right.php";
	require_once "footer.php";
} else {
	// Aplikacie bez Fusionu si defunuju samostatne
	$stranka = SLS::stranka();
	if($stranka) { require($stranka); }
}

//	 ++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++ 	?>