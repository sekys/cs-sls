<? // ++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++

require_once "maincore.php";
require_once "subheader.php";
require_once "side_left.php";
Debug::Oblast('SLS');

$__cesta = S_PUBLIC.'cup/lib/';
require_once($__cesta."const.php");	
require_once($__cesta."class.SLSPlugins.php");	
require_once($__cesta."class.SLSHodnost.php");
require_once($__cesta."class.SLSUser.php");	
require_once($__cesta."class.SLSZapas.php");	
require_once($__cesta."class.SLSLang.php");	
//require ($__cesta."class.SLSBonus.php");	
require_once($__cesta."class.SLSClan.php");	
require_once($__cesta."class.SLS.php");
unset($__cesta);

SLSUser::Start();
SLS::LoadSettings();
SLSLang::Load('sk');

if( SLS::Start() ) {
	// Pluginy
	$adresa = SLSPlugins::Load('stranka');
	if(!($adresa === FALSE)) {
		Debug::Oblast('SLSPLUGIN');
		require_once($adresa);	
		Debug::Oblast('SLSPLUGIN');
	}
	unset($adresa);
}

Debug::Oblast('SLS');
require_once "side_right.php";
require_once "footer.php";