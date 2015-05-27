<?

class SLSUser
{
	const ADMINSKUPINA = 27;
	public static $user;
	
	public static function MaClan() {
		if( self::$user['clan_id'] == false) { 
			echo SLS::MsgL('clan_nema'); 
			return false;
		}
		return true;
	}
	public static function Start() {
		// Skopiruj cele - v lige sa to upravuje !
		self::$user = User::$m->GetAll();	
	}
	public static function isHodnost($ake) {
		return (self::$user['clan_hodnost'] === $ake);
	}	
	public static function AdminAction($typ, $koho, $dovod, $ban = 0) {
		// Hociaka akcia vykonana adminom ...
		if($ban) {
			$ban = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + $ban, date("Y")));
			$ban = ", '".$ban."'"; 
		} else {
			$ban = 'NULL';
		}	
		DB::Query("INSERT INTO `phpbanlist`.`logs` (typ, admin, koho, dovod, cas, dokedy) VALUES 
					('".$typ."', ".self::$user['user_id'].", '".$koho."', '".SLSDB::Vstup($dovod)."', '".date("Y-m-d")."' ".$ban."");	
	}	
	public static function AdminUnban($d) {
		// Unban
		self::AdminEdit($id, '`dokedy` = `cas`');
	}	
	public static function AdminEdit($id, $akcia) {
		DB::Query("UPDATE FROM `phpbanlist`.`logs` SET ".$akcia." WHERE id = '".$id."' ");	
	}
	public static function AdminSearch($podmienka) {
		// Vypise vsetke informacie
		return DB::Query("SELECT * FROM `phpbanlist`.`logs` ".$podmienka."");
	}
	public static function isPlayer() {	// zistujeme ci ide o hraca zaregistrovaneho v ligovom systeme.....
		// Prihlaseny
		if(!self::$user['user_id']) { 
			echo SLS::MsgL('prihlaseny'); 
			return false;
		}
		// Steam cislo
		if(! self::$user['cs_steam']) { 
			echo SLS::MsgL('ziadny_steam'); 
			return false;
		}	
		return true;
	}
	public static function isAdmin() {
		//return (self::$user['user_id === "1");
		$prava = explode('.', self::$user['user_groups']);
		for($i=1; $i < count($prava); $i++){
			if( $prava[$i] == self::ADMINSKUPINA) return true;	
		}
		return false;
	}
	public static function Posta($id, $sprava, $subject = false) {
		$subject = ($subject) ? 'GeCom Cup || '.$subject : 'GeCom Cup || Automatick&aacute; spr&aacute;va';
		DB::Query("INSERT INTO `cstrike`.`fusion_messages` 
		(message_to, message_from, message_subject, message_message, message_smileys, message_read, message_datestamp, message_folder) 
		VALUES 
		('".DB::Vstup($id)."', ".self::BOT.",'".DB::Vstup($subject)."','".DB::Vstup($sprava)."','y','0','".time()."','0')");
	}
}
