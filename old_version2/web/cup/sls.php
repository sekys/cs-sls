<? // 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++
// Ligova class	
SLS::StaticInit($zlozka);

// Stary project, zle napisana trieda, funkcie, naorcne na pamet
// Treba prerobiy...
// V mnohych pripadoch XSS utok mozny aj mysql je derave...
/* Vsade:
optavit getuserdata
tabulka musi mat aj user_name inak je to velmi velmi komplikovane
do profilu dat steam cislo a ukladat jeho meno do jednej aj druhej DB
na novom webe je skryta cast a v strede POVOLIT a vtedy skopiruje udaje do druhej DB cim povoli ligu
vlastne to spravit uz pri registracii a kazdemu tak posielat, inak budu problemy a nebude moct posielat pozvanky
*/
// Ochrana
if(!$page) echo SLS::verzia;
require_once(dirname(__FILE__).'/hodnost.php');
		
class SLS
{
	// Config
	const verzia = '3.0';				// © By Seky		
	
	public static $aplikacia, $admin_skupina, $bot,  $debug, $zoznam_vzdialenost, $bonus,
		$odstavka, $mysql,  $plugins,  $vyzvy, $minimalne_hracov, $vyzva_hodina,  $vyzva_mapa,
		$str_parser_1, $str_parser_2,  $hodnost,  $bonus_clan, $bonus_hrac, $server, $max_zruseni;
	
	// Premenne
	public static $adresy, $cuplanguage;
	public static $language = array(  	'no' => "Nemozem najst :", 
										'plugin_no' => "&#381;iadny plugin nen&aacute;jden&yacute;.",
										'plugin_find_no' => "Plugin nen&aacute;jden&yacute;:",
										'mysql_no'	=> 'Ziadne spojenie s databazou.' 
									);	
	public static $zoznam; 					// Premmenna na urcenie pozicii v zozname
	public static $plugin;						// Id spusteneho pluginu
	public static $style;						// Defaulnty vzhlad ....
	public static $db;
	
	// Uzivatelia
	public static $user = array('user_id'	=> 0,
								'user_name' => '', 
								'cs_meno' => '', 
								'cs_heslo' => '', 
								'clan_id' => 0, 
								'clan_hodnost' => 0, 
								'user_cupactive' => false, 
								'user_groups'=>""
							);

	public static function StaticInit($cesta) {					
		// Prepis
		$cesta .= '/';
		// Config ligy
		if(!file_exists($cesta."config.php")){
			exit(self::sprava('no').'<br>'.$cesta);
			return 0;
		}
		require_once($cesta."config.php");
		require_once($cesta."plugins.php");
		
		// Debug
		if(self::$debug) self::gentime();
		
		// Nastavuje adresy ...
		self::$adresy[0] = self::$aplikacia.$cesta;								// home web
		self::$adresy[1] = $cesta;												// home server
		self::$adresy[3] = self::$adresy[0]."styles/".self::$style."/";		// obrazky

		// Jazyk
		$cesta = self::$adresy[1]."languages/".self::$cuplanguage.".php";
		if(!file_exists($cesta)){
			self::$odstavka = self::sprava('no').'<br>'.$cesta;
			return 0;
		}
		// Ziadne pluginy
		if(!self::$plugins[0][0]) {
			self::$odstavka = self::sprava('plugin_no');
			return 0;
		}		
	}
	public static function aplikacia() {		
		self::$plugin = self::find_array();				
		// Plugin nenajdeny
		if(self::$plugin == -1) return 1;
		// Plugin povoleny
		if( self::$plugins[self::$plugin][2] == 0)  return 0;	
		return 1;
	}
	public static function stranka() {		
		// Stranka neexistuje
		if(self::$plugin == -1) self::$plugin = 0; // defaultne

		// Neexistuje a ziadnu nezadal
		if(!$_GET['stranka']) {	
			// Prihlaseny
			self::$plugin = 9;		
			// Nema clan
			if(!self::$user['clan_id']) self::$plugin = 2;
			// Neprihlaseny
			if(!self::$user['user_id']) self::$plugin = 1;		
		}	
		// Existuje
		$cesta = self::$adresy[1]."plugins/".self::$plugins[self::$plugin][1];	// plugin zlozka
		if(!file_exists($cesta)){
			echo self::get_spravu(self::sprava('plugin_find_no').'<br>'.$cesta, 1);
			return 0;
		}	
		return $cesta;
	}	
	public static function pokracovat() {
		// Odstavka alebo chyba		
		if(self::$odstavka and !self::get_admin())	{		
			echo '<!-- Powered by Seky`s Liga System -->
			<link href="'.self::$adresy[3].self::$style.'.css" rel="stylesheet" type="text/css" />';
			echo self::get_spravu(self::$odstavka, 1);
			self::ukonci();
			return 0;
		}	
		return 1;
	}
	public static function jazyk() {
		// Jazyk MISC	
		require(self::$adresy[1]."languages/".self::$cuplanguage.".php");
		self::$language['vyzvy'] = (self::$vyzvy == 0) ? self::sprava('vyzvy_stop') : sprintf(self::sprava('vyzvy'), self::$vyzvy);
	}	
	public static function aktivuj() {								
		// Header
		echo '<!-- Powered by Seky`s Liga System -->
			<link href="'.self::$adresy[3].self::$style.'.css" rel="stylesheet" type="text/css" />';
			
		// Deje sa pri spusteni ligy nastavi nam premenne ......
		self::$zoznam = (is_numeric($_GET['p1'])) ? $_GET['p1'] : 0;
		
		// Dalsi header
		echo '	
			<script type="text/javascript">
				function openCalendar(params, form, field, type) {
					window.open("'.self::cesta(18).'" + params, "calendar", "width=400,height=200,status=yes");
					dateField = eval("document." + form + "." + field);
					dateType = type;
				}
			</script>		
		
		<link type="text/css" href="'.self::$adresy[0].'styles/js/'.'jquery-ui-1.7.2.custom.css" rel="stylesheet" />	
		<script type="text/javascript" src="'.self::$adresy[0].'jquery-1.3.2.min.js"></script>	
		<script type="text/javascript" src="'.self::$adresy[0].'jquery-ui-1.7.2.custom.min.js"></script>
		';		
	}
	public static function ukonci() {
		// Koniec		
		if(self::$debug) {
			// Vypiseme na konci nejake error spravy	
			echo '<div align="center" style="color: red;"><pre><strong>DEBUG:<br>';
			echo 'Time: '.self::gentime().'<br>';
			echo 'Adress: '.self::adresa_na_seba().'<br>';
			echo 'Error: '.self::mysql_vystup(mysql_error()).'<br>';
			echo '</strong></pre></div>';
		}
		echo '<!-- Powered by Seky`s Liga System -->';
	}	
	public static function mysql_spojenia() {
		/*http://www.php.net/manual/en/function.mysql-connect.php#81028
		expected behavior, to insert the last statement into the master db,
		since it doesn't reference the read-only resource explicitly. instead, 
		it inserts the record into the last connection, even though it shouldn't, 
		since the last connection is not a global/anonymous connection like the first one, it's $objMySQL_Read. 
		*/		
		@self::$db = mysql_connect(self::$mysql[0], self::$mysql[1] , self::$mysql[2], true);
		if(!self::$db)	{ 
			self::$odstavka = self::sprava('mysql_no'); 
			return 0;
		}
		@mysql_select_db(self::$mysql[3], self::$db);
		
		@$spojenie = mysql_connect("localhost", "cstrike" , "asda6mdks5dfds", "cstrike");
		if(!$spojenie)	{ 
			self::$odstavka = self::sprava('mysql_no'); 
			return 0;
		}
		@mysql_select_db("cstrike");
	}
	public static function gentime()  {
		static $a;
		if($a == 0) $a = microtime(true);
		else return (string)(microtime(true)-$a);
	}
	public static function adresa_na_seba() {
		// _SERVER["SCRIPT_URI"]
		if(self::$adresy[1] == 0) {
			self::$adresy[1]  = self::$adresy[0];
			//Na seba
			if(!$_GET['stranka']) { return self::$adresy[0]; }
			self::$adresy[1] .= self::mysql_vstup($_GET['stranka'])."/";			
			// Pocet parametrov ?
			for($i=1; $i <= 3; $i++) {
				if(!isset($_GET['p'.$i])) { return self::$adresy[1]; }
				self::$adresy[1] .= self::mysql_vstup($_GET['p'.$i])."/";	
			}
		}
		return self::$adresy[1];	
	}
	public static function sprava($co) {
		return self::$language[$co];
	}
	public static function cesta($id) {
		return self::$adresy[0].self::$plugins[$id][0]."/";
	}  	
	public static function get_spravu($co, $error = false) {
		return '
				<table border="0" cellpadding="0" cellspacing="0" align="center" class="cup_sprava">
						<tr>
							<td height="80"><img src="'. self::$adresy[3] .'cup_'.( $error==true ? 'eror' : 'oznam').'.png" width="80" border="0" height="80"> </td>
							<td class="cup_sprava_'.( $error==true ? 'eror' : 'oznam').'" align="center">'.$co.'</td>
						</tr>
				</table>	
		'; // 4 riadky maximalne
	}	
	public static function get_admin() {
		return (self::$user['user_id'] === "1" );
		/*	
		$prava = explode('.',self::$user['user_groups']);
		for($i=0; $i < count($prava); $i++)
		{
			if( $prava[$i] == self::$admin_skupina)
			{
				return true;
			}	
		}*/
	}
	public static function find_array() {
		$co = $_GET['stranka'];		
		if(!$co) return -1;
		$pocet = count(self::$plugins);
		for($i=0; $i < $pocet; $i++) {										
			if(self::$plugins[$i][0] == $co) {
				return $i;
			}
		}	
		return -1;
	}
	public static function mysql_count($prikaz) {
		@$sql = mysql_query($prikaz);
		$sql_pocet = mysql_fetch_assoc($sql);	
		return $sql_pocet['pocet'];
	}	
	public static function mysql_count2($prikaz) {
		@$sql = self::mysql_dbquery($prikaz, SLS::$db);
		$sql_pocet = mysql_fetch_assoc($sql);	
		return $sql_pocet['pocet'];
	}
	public static function mysql_dbquery($prikaz) {
		return mysql_query($prikaz, self::$db);
	}
	public static function get_zoznam() {
		return "LIMIT ".self::$zoznam.", ".self::$plugins[self::$plugin][3]."";
	}
	public static function set_zoznam($celkovo, $link = 0) {
		$kolko = self::$plugins[self::$plugin][3];
		$vzdialenost = self::$zoznam_vzdialenost;
		$link = ($link == 0) ? self::$adresy[0].self::mysql_vstup($_GET['stranka']).'/' : $link;	// zoznamy
		$vysledok = "";	
		$stranok = ceil($celkovo / $kolko);
		
		if ($stranok > 1) {			
			$spet = self::$zoznam - $kolko;
			$dalej = self::$zoznam + $kolko;
			$aktualna_stranka=ceil((self::$zoznam + 1) / $kolko);
			
			$vysledok.="<table cellspacing='0' cellpadding='0' border='0' class='tbl-border'><tr>";
			$vysledok.="<td class='tbl2'><span class='small'>Strana ".$aktualna_stranka." z ".$stranok."</span></td>";
			
			if ($spet >= 0) {
				if ($aktualna_stranka > ($vzdialenost + 1)) $vysledok.="<td class='tbl2'><a class='small' href='".$link."'>&lt;&lt;</a></td>";
				$vysledok.="<td class='tbl2'><a class='small' href='".$link."".$spet."/'>&lt;</a></td>\n";
			}			
			$prva_stranka=max($aktualna_stranka - $vzdialenost, 1);
			$posledna_stranka=min($aktualna_stranka + $vzdialenost, $stranok);
			
			if ($vzdialenost==0) {
				$prva_stranka = 1;
				$posledna_stranka=$stranok;
			}
			for($i=$prva_stranka;$i<=$posledna_stranka;$i++) {
				$offset_page=($i - 1) * $kolko;
				if ($i==$aktualna_stranka) {
					$vysledok.="<td class='tbl1'><span class='small'><b>".$i."</b></span></td>";
				} else {
					$vysledok.="<td class='tbl1'><a class='small' href='".$link."".$offset_page."/'>$i</a></td>";
				}
			}
			if ($dalej < $celkovo) {
				$vysledok.="<td class='tbl2'><a class='small' href='".$link."".$dalej."'>&gt;</a></td>\n";
				$kolko = ($stranok-1)*$kolko;
				if ($aktualna_stranka < ($stranok - $vzdialenost)) $vysledok.="<td class='tbl2'><a class='small' href='".$link."".$kolko."'>&gt;&gt;</a></td>";
			}
			$vysledok .="</tr></table>";
		}
		return $vysledok;
	}
	public static function web_posta($id,$sprava,$subject = false) {
		$subject = ($subject) ? 'GeCom Cup || '.$subject : 'GeCom Cup || Automatick&aacute; spr&aacute;va';
		@mysql_query("INSERT INTO `cstrike`.`fusion_messages` 
		(message_to, message_from, message_subject, message_message, message_smileys, message_read, message_datestamp, message_folder) 
		VALUES 
		('".self::mysql_vstup($id)."', ".self::$bot.",'".self::mysql_vstup($subject)."','".self::mysql_vstup($sprava)."','y','0','".time()."','0')");
	}
	public static function team_posta( $id_clanu, $sprava, $subject, $vynimka = 0) {											
		$vynimka = ($vynimka) ? "AND user_id != '".$vynimka."'" : "";
		@$sql=self::mysql_dbquery("SELECT user_id FROM `cstrike`.`fusion_users` WHERE clan_id ='".$id_clanu."' ".$vynimka."", self::$db);
		while($temp = mysql_fetch_assoc($sql)) {
			self::web_posta($temp['user_id'],$sprava, $subject);
		}	
	}
	public static function mysql_vstup($hodnota) {
		if(get_magic_quotes_gpc ()) $hodnota = stripslashes ($hodnota); 
		// strip tags som musel vypnut
		$hodnota = mysql_real_escape_string($hodnota); 		
		$hodnota = str_replace("
				", "\n", $hodnota);
		return $hodnota;
	}	
	public static function get_narod($id) {
		return '<img src="'.self::$adresy[3].'vlajka_'.$id.'.gif" alt="N&aacute;rodnos&#357; clanu" title="N&aacute;rodnos&#357; clanu"border="0" align="absmiddle">';
	}
	public static function get_boolean($id) {
		return ($id) ? "Ano" : "Nie";
	}
	public static function mysql_vystup($hodnota) { // na specialne mena a pod.
		return htmlentities($hodnota, ENT_QUOTES);
	}
	public static function get_najdi_leadera($clan_id) {
		@$sql_hodnost = self::mysql_dbquery("SELECT user_id FROM `cstrike`.`fusion_users` WHERE clan_id = '".$clan_id."' AND clan_hodnost = '".CLAN_LEADER."' ", self::$db);	
		$data = mysql_fetch_row($sql_hodnost);
		return $data[0];
	}	
	public static function get_aktivita($aktivita) {
		$vysledok = "";
		if($aktivita >= 4) {
			$vysledok = '<img src="'.self::$adresy[3].'aktivita/4.gif" border="0" alt="4" align="absmiddle">';
			// Cyklime
			if($aktivita > 4 ) {
				$vysledok .= self::get_aktivita( $aktivita - 4);
			}
		} elseif($aktivita <= 0) {
			$vysledok = '<img src="'.self::$adresy[3].'aktivita/0.gif" border="0"  alt="0" align="absmiddle">';
		} else {
			$vysledok = '<img src="'.self::$adresy[3].'aktivita/'.$aktivita.'.gif" border="0"  alt="'.$aktivita.'" align="absmiddle">';
		}
		return $vysledok;
	}
	public static function get_bonus_type($id, $typ) {
		$vysledok = '';
		$bonus = self::$bonus[$id];
		$pocet_a = count($bonus);
		
		for($i=0; $i < $pocet_a; $i++) {
			$pocet_b = substr_count($typ, $bonus[$i][1]);
			// Ak obsahuje viackrat to iste
			for( $j=0; $j < $pocet_b; $j++ ) {
				$vysledok .= '<img src="'.self::$adresy[3].'bonus/'.$bonus[$i][3].'" border="0" title="'.$bonus[$i][0].' +'.$bonus[$i][2].'%" alt="'.$bonus[$i][2].'" align="absmiddle">';
			}
		}
		return $vysledok;	
	}
	public static function get_rank($id) { // Zisti RANK clanu 
		@$sql = self::mysql_dbquery("SELECT COUNT(`id`) FROM `phpbanlist`.`acp_clans` WHERE `bodov` > 
							(  SELECT bodov FROM `phpbanlist`.`acp_clans` WHERE `id`='".$id."' )", self::$db);
		$data = mysql_fetch_row($sql);
		return $data[0];
	}
	public static function get_dovod_zapasu($dovod) {
		return ($dovod == false) ? self::sprava('ok') : self::mysql_vystup($dovod);
	}
	public static function get_farba($farba) {
		// Farba
		if($farba == 0) {
			$farba="0,0,0";
		} else {				
			if($farba > 255) {
				if($farba > 510)  {
					if($farba >= 765) {
						$farba="0,255,0";
					} else {
						$farba="0,0,0"; // black
					}	
				} else {
					$farba = $farba - 255;
					$farba="0,0,".$farba.""; // blue	
				}
			} else {
				$farba="".$farba.",0,0"; // red
			}
		}
		return $farba;
	}
	public static function get_kontrola_vyzvy() {		
		// Server
		$server = $_POST['server'];
		if(!is_numeric($server)) {
			echo self::get_spravu(self::sprava('zle_udaje'), 1);
			return false;
		}	
		// Hodiny  a mapa
		$hodina = $_POST['hodina'];
		if( !in_array($hodina, self::$vyzva_hodina[$server]) or !in_array($_POST['mapa'], self::$vyzva_mapa)) {
			echo  self::get_spravu(self::sprava('zle_udaje'), 1);		
			return false;	
		}	
		// Format datumu
		$datum = $_POST['datum'];
		$temp = explode("-",$datum);
		if( 
			(
			is_numeric($temp[0]) and strlen($temp[0])==4 and 
			is_numeric($temp[1]) and strlen($temp[1])==2 and $temp[1] < 13 and $temp[1] > 0 and 
			is_numeric($temp[2]) and strlen($temp[2])==2 and $temp[2] < 32 and $temp[2] > 0	) == false
		) {
			echo  self::get_spravu(self::sprava('vyzva_format').date("Y-m-d"));		
			return false;
		}
		// Kontrola casu
		$cas = mktime($hodina, 0, 0, $temp[1], $temp[2], $temp[0]);
		$rozdiel = time()+60*60*2;
		if($cas < $rozdiel) {
			echo  self::get_spravu(self::sprava('vyzva_minulost').'<br>'.date("Y-m-d \o H:m", $rozdiel+60*15));
			return false;
		}																																																	
		// Obsadene
		@$sql_kontrola = self::mysql_dbquery("SELECT id FROM `phpbanlist`.`acp_vyzva` WHERE datum ='".$cas."' LIMIT 1", self::$db);
		if( @mysql_num_rows($sql_kontrola) > 0) {
			echo self::get_spravu(self::sprava('vyzva_obsadena'), 1);	
			return false;
		}			
		return $cas;
	}
	public static function set_zapas($data) {
		/*
		Priklad vstupu:
		$data[] = array	(
							$nadpis,
							$datum,
							$vyzva,
							$mapa
							$info
						);			
		$data[] = array	(
							$prijma_clan['id'],
							$prijma_clan['meno'],
							$avatar_A,
							$rank_A,
						);		
		$data[] = array	(
							$super_clan['id'],
							$super_clan['meno'],
							$avatar_B,
							$rank_B,
						);
		*/				
		$von ='<div class="cup_body" align="center">
				<img src="'.self::$adresy[3].'logo.png" border="0" title="Logo" >
				<br>
				<span class="cup_form_text"><b>'.$data[0][0].'</b></span>
				<br><br>
				<table width="400" align="center" class="cup_body" style="border: 1px; solid: #000;">
					<tr>
						<td width="100" align="right"><a href="'.self::cesta(5).$data[1][0].'/" ><img '.$data[1][2].' style="border: 1px;solid: #000" width="100" height="100"></a>
							<br>
							<a href="'.self::cesta(5).$data[1][0].'/" class="cup_form_text"> '.$data[1][1].'</a>
							<br>
							Rank '.$data[1][3].'
						</td>

						<td width="70" height="40" align="center">
							<img src="'.self::$adresy[3].'vs.png" border="0" >
						</td>

						<td width="100" align="left"><a href="'.self::cesta(5).$data[2][0].'/" ><img '.$data[2][2].' style="border: 1px;solid: #000" width="100" height="100"></a>
							<br>
							<a href="'.self::cesta(5).$data[2][0].'/" class="cup_form_text" >'.$data[2][1].'</a>
							<br>
							Rank '.$data[2][3].'
						</td>
					</tr>
				</table>
				<br>
				<span class="cup_form_text"><b>'.self::sprava('vyzva_datum').'</b> '.date("Y-m-d \o H", $data[0][1]).'hod('.$data[0][3].')</span>
				<br>
				<br>
				'.$data[0][4].'';
		if($data[0][2]) {
			$von .=	'<div>
						<a href="'.self::cesta(10).$data[0][2].'/" ><img src="'.self::$adresy[3].'tlacitko_ano.gif" border="0" title="Prija&#357; z&aacute;pas" > </a>
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<a href="'.self::cesta(10).$data[0][2].'/odmietnut/" ><img src="'.self::$adresy[3].'tlacitko_ne.gif" border="0" title="Odmietnu&#357; z&aacute;pas" > </a>
					</div>';
		}
		$von .=	'</div>';
		return $von;	
	}	
	// Pomocne mini fukncie
	private static function MysqlGetUserData($id) {
		$sql = self::mysql_dbquery("SELECT * FROM `cstrike`.`fusion_users` WHERE `user_id`='".$id."' LIMIT 1");
		if(!mysql_num_rows($sql)) return false;
		self::$user = mysql_fetch_assoc($sql);	
		return true;
	}
	public static function GetUserData() {
		global $userdata;
		// Prihlaseny
		if(!$userdata['user_id']) return false;
		// Liga zapnuta ?
		self::$user['user_cupactive'] = self::MysqlGetUserData($userdata['user_id']);
		self::$user['user_groups'] = $userdata['user_groups'];
		return true;
	}
	public static function is_hrac() {		// zistujeme ci ide o hraca zaregistrovaneho v ligovom systeme.....
		// prihlaseny
		if(!self::$user['user_id'] ) { echo self::get_spravu( self::sprava('prihlaseny') ); return false;}
		// liga zapnuta ?
		if(!self::$user['user_cupactive']) { echo self::get_spravu( self::sprava('userligaon') ); return false;}
		// herne meno	
		if(! self::$user['cs_meno']) { echo self::get_spravu( self::sprava('ziadne_meno') ); return false;}
		// steam cislo
		if(! self::$user['cs_steam']) { echo self::get_spravu( self::sprava('ziadny_steam') ); return false;}
		// herne heslo
		//if(! self::$user['cs_heslo']) { echo self::get_spravu( self::sprava('ziadne_heslo') ); return false;}	
		return true; // akoze v poriadku
	}	
	public static function is_udaj($udaj)	{	// kontroluje ci su udaje v poriadku....
		if( is_numeric($udaj) and $udaj > 0) {
			return true;
		} 
		echo self::get_spravu(self::sprava('ziadne_udaje'), 1);
		return false;
	}	
	public static function is_adresa(&$p1, &$p2, &$p3) {
		$p1 = $_GET['p1'];
		$p2 = $_GET['p2'];
		$p3 = $_GET['p3'];

		if( strlen($p1) != 10 ) {
			echo self::get_spravu( self::sprava('zapas_datum'), 1);
			return false;
		}	
		if( !is_numeric($p2) ) {	
			echo self::get_spravu( self::sprava('zapas_hodina'), 1);
			return false;
		}	
		if( !is_numeric($p3)) {	
			echo self::get_spravu( self::sprava('zapas_server'), 1);
			return false;
		}
		$temp = explode("-", $p1);
		$p2 = mktime($p2, 0, 0, $temp[1], $temp[2], $temp[0]);
		return true;	
	}
	public static function ma_clan() {
		if( self::$user['clan_id'] == false) { 
			echo self::get_spravu( self::sprava('clan_nema') ); 
			return false;
		}
		return true;
	}
	public static function is_access($ake) { // zistujeme ci je to admin....	
		return (self::$user['clan_hodnost'] === $ake);
	}	
	public static function set_avatar_html($adresa) {
		return ($adresa) ? 'src="'.$adresa.'"' : 'src="'.self::$adresy[3].'no_avatar.png"';
	}
	public static function set_rank_html($rank) {
		if($rank > self::$plugins[1][3]) {
			$pocet = floor($rank / self::$plugins[1][3]) * self::$plugins[1][3];
			$pocet .= '/';
		}	
		$vysledok = '<a href="'.self::cesta(1).$pocet.'#miesto'.$rank.'" class="cup_form_text"> ';
		$vysledok .= ($rank < 4) ? '<img src="'.self::$adresy[3].'miesto_'.$rank.'.png" alt="'.$rank.'." title="'.$rank.'. Miesto" border="0" align="absmiddle">' : $rank.'.';
		$vysledok .= '</a>';
		return $vysledok;
	}
	public static function set_clan_meno($meno) {
		return ($meno) ? self::mysql_vystup($meno) : '<em>Clan nen&aacute;jden&yacute;</em>';
	}	
	public static function set_zapasov($id) {
		return self::mysql_count2("SELECT COUNT(id) as pocet FROM `phpbanlist`.`cup_zapas` WHERE ziada = '".$id."' OR prijal = '".$id."'");
	}	
	public static function set_hracov($id) {
		return self::mysql_count2("SELECT COUNT(user_id) as pocet FROM `cstrike`.`fusion_users` WHERE clan_id = '".$id."'");
	}
	public static function is_sukromna($sukromne) {
		if($sukromne) {
			if($sukromne == self::$user['clan_id']) return false;			
			echo self::get_spravu(self::sprava('vyzva_sukromna'));			
			return true;
		} else {
			return false;
		}
	}
	public static function is_vlastna($id) {
		if($id === self::$user['clan_id']) {
			echo self::get_spravu(self::sprava('vyzva_vlastna'),1);
			return true;
		}
		return false;
	}	
	public static function is_vlastny($id) {
		if($id === self::$user['clan_id']) {
			echo self::get_spravu(self::sprava('vyzva_vlastny'),1);
			return true;
		}
		return false;
	}
	public static function is_prijata($co) {
		if($co) {
			echo self::get_spravu(self::sprava('vyzva_prijata'),1);
			return true;
		}
		return false;
	}
	public static function is_pocet_ok() {
		@$sql_kontrola = self::mysql_dbquery("SELECT COUNT(id) as pocet FROM `phpbanlist`.`acp_vyzva` WHERE ziada = '".self::$user['clan_id']."' OR prijal = '".self::$user['clan_id']."'", self::$db);
		$kontrola = mysql_fetch_assoc($sql_kontrola);
		if($kontrola['pocet'] >= self::$vyzvy) {											
			echo self::get_spravu(self::sprava('vyzvy'),1);
			return false;
		} else {	
			@$sql_kontrola = self::mysql_dbquery("SELECT COUNT(user_id) AS hracov FROM `cstrike`.`fusion_users` WHERE clan_id = '".self::$user['clan_id']."'", self::$db);
			$kontrola = mysql_fetch_assoc($sql_kontrola);
			if($kontrola['hracov'] >= self::$minimalne_hracov) {
				return true;
			} else {
				echo self::get_spravu(  sprintf(self::sprava('min_hracov'), self::$minimalne_hracov) );
				return false;	
			}	
		}
	}
	public static function is_clan_exist($udaj) {
		if(!@mysql_num_rows($udaj)) {
			echo self::get_spravu(self::sprava('clan_nenajdeny'),1);
			return false;
		}
		return true;
	}
	public static function is_mysql_ok($sql) {
		if(!$sql) { echo self::get_spravu(self::sprava('mysql_error'),1);
			return false;
		}
		return true;
	}
	public static function cyklus_vypis( $udaj , $meno) {
		echo '<select name="'.$meno.'">';
		$pocet = count($udaj );
		for($i=0; $i < $pocet; $i++) {										
			echo '<option value="'.$udaj[$i].'">'.$udaj[$i].'</option>';
		}	
		echo '</select>';
	}
	public static function is_name_tag_ok($meno , $tag) {
		$zakazane = array('?', '/', '\\', '"', "'", '<', '>', '%', '&');		
		$meno = trim($meno);
		$tag = trim($tag);
		
		if( $meno and $tag)  {
			if(strlen($meno)>=3 and strlen($tag)>=3) {			
				// Konstrolujeme vstup ... :)
				foreach($zakazane as $znak) {
					if(self::contain($meno, $znak)) {
						echo self::get_spravu(self::sprava('clan_znamienka').'?',1);
						return false;
					}
				}				
				// Sql kontrola 
				$pocet = (self::$user['clan_id']) ? " AND id != '".self::$user['clan_id']."' " : '';		
				$pocet = self::mysql_count2("SELECT COUNT(id) as pocet FROM `phpbanlist`.`acp_clans` WHERE `meno` LIKE '".self::mysql_vstup($meno)."' ".$pocet."");
				if($pocet) {
					echo self::get_spravu(self::sprava('clan_obsadene_meno'), 1);
					return false;
				}									
				return true;
			} else {
				echo self::get_spravu(self::sprava('clan_tag'), 1);
				return false;
			}
		} else {
			echo self::get_spravu($cup->sprava('ziadne_udaje'));
			return false;
		}
	}
	public static function contain($kde, $co) {
		return ( strpos($kde, $co) === false );
	}
	public static function admin_action($typ, $koho, $dovod, $ban = 0) {
		// Hociaka akcia vykonana adminom ...
		if($ban) {
			$ban = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + $ban, date("Y")));
			$ban = ", '".$ban."'"; 
		} else {
			$ban = 'NULL';
		}	
		@mysql_query("INSERT INTO `phpbanlist`.`logs` (typ, admin, koho, dovod, cas, dokedy) VALUES 
					('".$typ."', ".self::$user['user_id'].", '".$koho."', '".self::mysql_vstup($dovod)."', '".date("Y-m-d")."' ".$ban."");	
	}	
	public static function admin_unban($d) {
		// Unban
		self::admin_edit($id, '`dokedy` = `cas`');
	}	
	public static function admin_edit($id, $akcia) {
		@mysql_query("UPDATE FROM `phpbanlist`.`logs` SET ".$akcia." WHERE id = '".$id."' ");	
	}
	public static function admin_search($podmienka) {
		// Vypise vsetke informacie
		@$sql = mysql_query("SELECT * FROM `phpbanlist`.`logs` ".$podmienka."");
		return $sql;
	}
	public static function cup_log($kat, $typ, $kto, $komu=false, $int=false, $co=false, $time=true) {
		// Pouzijeme webovy system inak sme mohli vlastny
		if(function_exists("add_log")) {
			add_log($kat, $typ, $kto, $komu, $int, $co, $time);
		} else {
			$co = ($co===false) ? "NULL" : "'".self::mysql_vstup($co)."'";
			$komu = ($komu===false) ? "NULL" : "'".$komu."'";
			$time = ($time===false) ? "NULL" : "'".time()."'";
			$kto = ($kto===false) ? "NULL" : "'".$kto."'";
			$int = ($int===false) ? "NULL" : "'".$int."'";
			@mysql_query("INSERT INTO `cstrike`.`web2_logs` (`kat`, `typ`, `kto`, `co`, `komu`, `int`, `kedy`) VALUES ('".$kat."', '".$typ."', ".$kto.", ".$co.", ".$komu.", ".$int.", ".$time.")");
		}	
	}
}	

// 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++ ?>
