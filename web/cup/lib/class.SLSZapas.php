<?

class SLSZapas
{
	const Parser1 = 'x04x';		// udaje
	const Parser2 = 'x08x';		// hracov
	const MINPLAYERS = 2;	// Minimalny pocet hracov v clane aby mohli hrat ligu
		
	// Servery							Meno 				|| 		IP
	public static $server = array(
		array('GeCom s.r.o. Cup #1', '85.237.232.36:27018')						
		//array('GeCom::Lekos Cup #2', '85.237.232.36:27021')						
		//array('GeCom::Lekos Cup #2', '85.237.232.36:27017')						
	);	
	
	// Vyzvy
	const VYZVY = 5;		// Pocet vyziev na clan, 0 vyzvy su pozastavene	
	CONST MAXZRUSENI = 5;	// Maximalny pocet zruseni...potom sa clan vymaze

	public static function GetTimeList() {
		return array(	// Nastavenia na kazdy server zvlast
			array(0,1,2,3,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23),
			array(0,1,2,3,6,7,8,9,10,11,21,22,23),
		);
	}
	
	public static function GetMapList() {
		return array( // Pridavat len mapy ,kotre urcite funguje a bez .bsp !
			"de_dust2", "cs_italy", "de_nuke", "de_dust", "de_inferno", "de_train", 
			"de_aztec", "cs_militia", "cs_assault", "de_cpl_overrun", "de_dust2_wz", 
			"de_cpl_strike", "de_dust25", "de_dust2_2009", "cs_33_estate", "de_school13", 
			"de_shop", "de_rome", "de_soos", "de_cbble",  "de_prodigy", "de_aztec", 
			"de_rats_1337", "de_rats3", "awp_gowenna", "awp_docks", "scoutzknivez"
		);
	}	
	
	public static function Reason($dovod) {
		return ($dovod == false) ? SLSLang::Msg('ok') : DB::Vystup($dovod);
	}				
	public static function Sukromna($sukromne) {
		if($sukromne) {
			if($sukromne == User::$m->clan_id) return false;			
			echo self::MsgL('vyzva_sukromna');			
			return true;
		} else {
			return false;
		}
	}
	public static function is_vlastna($id) {
		if($id ===  User::$m->clan_id) {
			echo self::MsgL('vyzva_vlastna',1);
			return true;
		}
		return false;
	}	
	public static function is_vlastny($id) {
		if($id ===  User::$m->clan_id) {
			echo self::MsgL('vyzva_vlastny',1);
			return true;
		}
		return false;
	}
	public static function is_prijata($co) {
		if($co) {
			echo self::MsgL('vyzva_prijata',1);
			return true;
		}
		return false;
	}
	public static function PostVyzva() {		
		// Server
		$server = $_POST['server'];
		if(!is_numeric($server)) {
			echo SLS::MsgL('zle_udaje', 1);
			return false;
		}	
		// Hodiny  a mapa
		$hodina = $_POST['hodina'];
		$vyzva_hodina = self::GetTimeList();
		$vyzva_mapa = self::GetMapList();
		if( !in_array($hodina, $vyzva_hodina[$server]) or !in_array($_POST['mapa'], $vyzva_mapa)) {
			echo  self::Msg(self::sprava('zle_udaje'), 1);		
			return false;	
		}	
		unset($vyzva_mapa);
		unset($vyzva_hodina);
		
		// Format datumu
		$datum = $_POST['datum'];
		$temp = explode("-",$datum);
		if( 
			(
			is_numeric($temp[0]) and strlen($temp[0])==4 and 
			is_numeric($temp[1]) and strlen($temp[1])==2 and $temp[1] < 13 and $temp[1] > 0 and 
			is_numeric($temp[2]) and strlen($temp[2])==2 and $temp[2] < 32 and $temp[2] > 0	) == false
		) {
			echo  SLS::Msg(SLSLang::Msg('vyzva_format').date("Y-m-d"));		
			return false;
		}
		// Kontrola casu
		$cas = mktime($hodina, 0, 0, $temp[1], $temp[2], $temp[0]);
		$rozdiel = time()+60*60*2;
		if($cas < $rozdiel) {
			echo  SLS::Msg(SLSLang::Msg('vyzva_minulost').'<br>'.date("Y-m-d \o H:m", $rozdiel+60*15));
			return false;
		}																																																	
		// Obsadene
		@$sql_kontrola = SLS::Query2("SELECT id FROM `phpbanlist`.`acp_vyzva` WHERE datum ='".$cas."' LIMIT 1");
		if( $sql_kontrola->num_rows > 0) {
			echo self::MsgL('vyzva_obsadena', 1);	
			return false;
		}			
		return $cas;
	}
	public static function MessageZapas($data) {
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
		$von = '<div class="cup_body" align="center">
				<img src="'.SLS::$STYLE.'logo.png" border="0" title="Logo" >
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
							<img src="'.SLS::$STYLE.'vs.png" border="0" >
						</td>

						<td width="100" align="left"><a href="'.SLSPlugins::Adresa(5).$data[2][0].'/" ><img '.$data[2][2].' style="border: 1px;solid: #000" width="100" height="100"></a>
							<br>
							<a href="'.SLSPlugins::Adresa(5).$data[2][0].'/" class="cup_form_text" >'.$data[2][1].'</a>
							<br>
							Rank '.$data[2][3].'
						</td>
					</tr>
				</table>
				<br>
				<span class="cup_form_text"><b>'.SLSLang::Msg('vyzva_datum').'</b> '.date("Y-m-d \o H", $data[0][1]).'hod('.$data[0][3].')</span>
				<br>
				<br>
				'.$data[0][4].'';
		if($data[0][2]) {
			$von .=	'<div>
						<a href="'.SLSPlugins::Adresa(10).$data[0][2].'/" ><img src="'.SLS::$STYLE.'tlacitko_ano.gif" border="0" title="Prija&#357; z&aacute;pas" > </a>
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<a href="'.SLSPlugins::Adresa(10).$data[0][2].'/odmietnut/" ><img src="'.SLS::$STYLE.'tlacitko_ne.gif" border="0" title="Odmietnu&#357; z&aacute;pas" > </a>
					</div>';
		}
		$von .=	'</div>';
		return $von;	
	}
	public static function is_adresa(&$p1, &$p2, &$p3) {
		$p1 = $_GET['p1'];
		$p2 = $_GET['p2'];
		$p3 = $_GET['p3'];

		if( strlen($p1) != 10 ) {
			echo self::MsgL('zapas_datum', 1);
			return false;
		}	
		if( !is_numeric($p2) ) {	
			echo self::MsgL('zapas_hodina', 1);
			return false;
		}	
		if( !is_numeric($p3)) {	
			echo self::MsgL('zapas_server', 1);
			return false;
		}
		$temp = explode("-", $p1);
		$p2 = mktime($p2, 0, 0, $temp[1], $temp[2], $temp[0]);
		return true;	
	}
	public static function is_pocet_ok() {
		@$sql_kontrola = SLS::Query2("SELECT COUNT(id) as pocet FROM `phpbanlist`.`acp_vyzva` WHERE ziada = '".User::$m->clan_id."' OR prijal = '".User::$m->clan_id."'");
		$kontrola = $sql_kontrola->fetch_assoc();
		if($kontrola['pocet'] >= self::$vyzvy) {											
			echo self::MsgL('vyzvy', 1);
			return false;
		} else {	
			@$sql_kontrola = SLS::Query2("SELECT COUNT(user_id) AS hracov FROM `cstrike`.`fusion_users` WHERE clan_id = '".User::$m->clan_id."'");
			$kontrola = $sql_kontrola->fetch_assoc();
			if($kontrola['hracov'] >= self::MINPLAYERS) {
				return true;
			} else {
				echo self::Msg( sprintf(SLSLang::Msg('min_hracov'), self::MINPLAYERS) );
				return false;	
			}	
		}
	}
	
}
