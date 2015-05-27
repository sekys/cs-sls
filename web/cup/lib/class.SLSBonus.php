<?

class SLSBonus
{
	// Bonusy
	public static $bonus = array(
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

	public static function GetType($id, $typ) {
		$vysledok = '';
		$bonus = self::$bonus[$id];
		$pocet_a = count($bonus);
		
		for($i=0; $i < $pocet_a; $i++) {
			$pocet_b = substr_count($typ, $bonus[$i][1]);
			// Ak obsahuje viackrat to iste
			for( $j=0; $j < $pocet_b; $j++ ) {
				$vysledok .= '<img src="'.SLS::$STYLE.'bonus/'.$bonus[$i][3].'" border="0" title="'.$bonus[$i][0].' +'.$bonus[$i][2].'%" alt="'.$bonus[$i][2].'" align="absmiddle">';
			}
		}
		return $vysledok;	
	}
}