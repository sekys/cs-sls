<?
class SLSLang
{
	protected static $language;
	
	public static function Load($lang) {
		// Jazyk MISC	
		$cesta = SLSSYSTEM."languages/".$lang.".php";
		if(!file_exists($cesta)) exit('Lang file not found !');
		require $cesta;
		self::$language['vyzvy'] = (SLSZapas::VYZVY == 0) ? self::Msg('vyzvy_stop') : sprintf(self::Msg('vyzvy'), SLSZapas::VYZVY);
	}
	public static function Msg($co) {
		return self::$language[$co];
	}
}