<?

class SLS
{
	const verzia = '3.0';			// ? By Seky	
	const BOT = 451;				// ID bota
	const ODSTAVKA = false;			// Odstavka a dovod , priklad :
	//const ODSTAVKA = 'Liga prechadza prestavbou.';
	
	// TODO: get_zoznam a set_zoznam uz nepodporujeme
	public static $STYLE = 'styles_web2';
	public static $zoznam;
	
	public static function LoadSettings() {	
		self::$STYLE = SLSROOT."styles/".self::$STYLE."/";	
		self::$zoznam = (is_numeric($_GET['p1'])) ? $_GET['p1'] : 0;		
	}	
	public static function Start() {
		// Header
		echo '<!-- Powered by Seky`s Liga System -->';
		echo '<link href="', self::$STYLE, 'cup.css" rel="stylesheet" type="text/css" />';
			
		// Odstavka alebo chyba		
		if(self::ODSTAVKA and !SLSUser::isAdmin())	{
			echo self::Msg(self::ODSTAVKA, 1);
			return false;
		} else {
			self::Header();
		}	
		echo '<!-- Powered by Seky`s Liga System -->';
		return true;	
	}
	protected static function Header() {
		// Dalsi header
		echo '	
			<script type="text/javascript">
				function openCalendar(params, form, field, type) {
					window.open("', SLSPlugins::Adresa(18), '" + params, "calendar", "width=400,height=200,status=yes");
					dateField = eval("document." + form + "." + field);
					dateType = type;
				}
			</script>
			';		
	}
	public static function Msg($co, $error = false) {
		return '
				<table border="0" cellpadding="0" cellspacing="0" align="center" class="cup_sprava">
						<tr>
							<td height="80"><img src="'. self::$STYLE .'cup_'.( $error==true ? 'eror' : 'oznam').'.png" width="80" border="0" height="80"> </td>
							<td class="cup_sprava_'.( $error==true ? 'eror' : 'oznam').'" align="center">'.$co.'</td>
						</tr>
				</table>	
		'; // 4 riadky maximalne
	}
	public static function MsgL($co, $error = false) {
		return self::Msg( SLSLang::Msg($co), $error);
	}
	public static function GetBool($id) {
		return ($id) ? "Ano" : "Nie";
	}
	public static function Farba($farba) {
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
	public static function CheckInput($udaj)	{	// kontroluje ci su udaje v poriadku....
		if(is_numeric($udaj) and $udaj > 0) return true; 
		echo self::MsgL('ziadne_udaje', 1);
		return false;
	}
	public static function Log($kat, $typ, $kto, $komu=false, $int=false, $co=false, $time=true) {
		WebLog::Add($kat, $typ, $kto, $komu, $int, $co, $time);	
	}
	public static function MysqlCheck($sql) {
		if(!$sql) { 
			echo self::MsgL('mysql_error', 1);
			return false;
		}
		return true;
	}
	public static function Count2($sql) {
		//DB::Second();
		$x = DB::Pocet($sql);
		//DB::Main();
		return $x;	
	}
	public static function Query2($sql) {
		//DB::Second();
		$x = DB::Query($sql);
		//DB::Main();
		return $x;
	}	
	public static function FormVypis( $udaj , $meno) {
		echo '<select name="'.$meno.'">';
		$pocet = count($udaj );
		for($i=0; $i < $pocet; $i++) {										
			echo '<option value="'.$udaj[$i].'">'.$udaj[$i].'</option>';
		}	
		echo '</select>';
	}
}