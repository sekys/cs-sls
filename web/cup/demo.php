<?
require_once($_SERVER["DOCUMENT_ROOT"].'/globals.php');

User::Start();
if(!User::Logged()) {
	die('Niesi prihlaseny.');	
}

$ftp_host = "10.0.1.3"; 
$ftp_uzivatel = "cstrike";
$ftp_heslo = "cslege";
$ftp_cesta = '/hlds_liga/cstrike/'; // hltv zlzoka
$home_cesta = S_PRIVATE."cup/dema/"; // zlozka kde s asukladaju dema
$kluc = '_hltvdemo'; // zadaj nejaky bezspecnosty kluc aby si to zbytocne nestahhovali 

if(is_numeric($_GET['p1']) and $_GET['p1'] > 0)
{
	$demo = $home_cesta.$_GET['p1'].$kluc.'.dem';
	// Stahovanie
	if( file_exists($demo) ) 
	{
		stiahni($demo , 'hltv_'.$_GET['p1'].'.dem');
	} else {
		// Prensieme si subor z HLTV
		$hltv = ftp_najdi($_GET['p1']); // vracia nazov dema na HLTV servery
		if($hltv) {
			$home = ftp_prenes($ftp_cesta.$hltv, $demo);
			if($home) {
				stiahni($demo , 'hltv_'.$_GET['p1'].'.dem');
			}
		} else {
			echo 'Subor na HLTV servery nebol najdeny.';
		}
	}	
} else {
	// Zoznam suborov v HLTV
	echo '
	<style type="text/css">
	<!--
	.dema_nadpis { color: #FFFFFF; background-color: #666666; }
	.dema tr { background-color:#FFFFFF; }
	.dema tr:hover { background-color:#E3E9F0; }
	-->
	</style
	<br>
		<p style="color;red;" align="center">Nov&eacute; dema sa zobrazia ihne&#271;  po z&aacute;pase. </p>
		<p style="color;red;" align="center">Dema sa ukladaj&uacute; do konca kola ligy. </p>
	<br>
	<table width="100%" class="dema" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<th class="dema_nadpis">D&aacute;tum</th>
			<th class="dema_nadpis">&#268;as</th>
			<th class="dema_nadpis">Mapa</th>
			<th class="dema_nadpis">Ve&#318;kos&#357;</th>
			<th class="dema_nadpis">Download</th>
		</tr>';
	ftp_zoznam();
	echo'
	</table>';
}
function stiahni($subor , $nazov) 
{
	global $userdata;
	@mysql_query("INSERT INTO `cstrike`.`web2_logs` (kat, typ, kto, co, komu, int, kedy) VALUES ('-1', '30', ".$userdata[0].", ".DB::Vstup($_GET['p1']).", NULL, NULL, ".$time.")");
	header("Content-Description: File Transfer");
	header("Content-Type: application/force-download");
	header("Content-Disposition: attachment; filename=\"$nazov\"");
	header("Content-Length: " . filesize($subor));
	readfile($subor); 
}
function ftp_spojenie() 
{		
	static $ftp;
	if(!$ftp) {
		@$ftp = ftp_connect($GLOBALS['ftp_host']);
		@$login = ftp_login($ftp, $GLOBALS['ftp_uzivatel'], $GLOBALS['ftp_heslo']);		
		$ftp = ($ftp) ? $ftp : false;
	}
	return $ftp;
}
function ftp_zoznam() 
{
	$spojenie = ftp_spojenie();
	if(!$spojenie) {	echo '<br>Nepodarilo sa pripojit na HLTV server.';	return false; }
	@$ftp_cesta = ftp_rawlist( $spojenie , $GLOBALS['ftp_cesta']);

	foreach ($ftp_cesta as $file) {
		if(ereg("([-dl][rwxst-]+).* ([0-9]*) ([a-zA-Z0-9]+).* ([a-zA-Z0-9]+).* ([0-9]*) ([a-zA-Z]+[0-9: ]*[0-9])[ ]+(([0-9]{2}:[0-9]{2})|[0-9]{4}) (.+)", $file, $regs)) 
		{
			//  => 0 subor , 1 zlozka
			$type = (int) strpos("-dl", $regs[1]{0});	//  => 0 subor , 1 zlozka
			if($type == 0)
			{
				if(!(strpos($regs[9], ".dem") === false) ) // iba dema
				{
					// Dalsie 
					$pomlcky = explode("-", $regs[9]);
					$bodky = explode(".", $pomlcky[count($pomlcky)- 1]);
					$podtrznik = explode("_", $pomlcky[0]);
					/*
					$temp['server'] = $podtrznik[1];
					$temp['id'] = $podtrznik[2];
					*/
					echo '	
					<!-- '.$regs[9].' -->
					<tr>						
						<td align="center">'.date("Y.m.d",strtotime($regs[6])).'</td>
						<td align="center">'.$regs[7].'</td>
						<td align="center">'.$bodky[0].'</td>
						<td align="center">'.byteConvert($regs[5]).'</td>
						<td align="center">
							<a href="http://www.cs.gecom.sk/cup/demo/'.$podtrznik[2].'/">
								<img vspace="0" hspace="0" border="0" alt="" src="/web2/web2/images/download.png"/>
								S&#357;iahnu&#357;
							</a>
						</td>
					</tr>';				
				}
			}
		}
	}
}
function byteConvert($bytes)
{
	$s = array('B', 'Kb', 'MB', 'GB', 'TB', 'PB');
	$e = floor(log($bytes)/log(1024));
 
	return sprintf('%.2f '.$s[$e], ($bytes/pow(1024, floor($e))));
	// '.round($regs[5] / 1024 / 1024).' mb
}
function ftp_najdi($subor) 
{
	$spojenie = ftp_spojenie();
	if(!$spojenie) {	echo '<br>Nepodarilo sa pripojit na HLTV server.';	return false; }
	@$ftp_cesta = ftp_rawlist( $spojenie , $GLOBALS['ftp_cesta']);
	$subor = '_'.$subor.'-';
	
	foreach ($ftp_cesta as $file) {
		if(ereg("([-dl][rwxst-]+).* ([0-9]*) ([a-zA-Z0-9]+).* ([a-zA-Z0-9]+).* ([0-9]*) ([a-zA-Z]+[0-9: ]*[0-9])[ ]+(([0-9]{2}:[0-9]{2})|[0-9]{4}) (.+)", $file, $regs)) 
		{
			$type = (int) strpos("-dl", $regs[1]{0});	//  => 0 subor , 1 zlozka
			if($type == 0)
			{
				if( !(strpos($regs[9], ".dem") === false) ) // iba dema
				{
					if( !(strpos($regs[9], $subor) === false) )	{
						return $regs[9];
					}		
				}
			}
		}
	}
	return false;
}
function ftp_prenes($ftp_subor, $home_subor)
{
	$spojenie = ftp_spojenie();
	if(!$spojenie) {
		echo '<br>Nepodarilo sa pripojit na HLTV server.';	
		return false; 
	}	
	/*if( !is_writable($GLOBAL['home_cesta'])) {
		echo 'Nastav chmod 777 na HOME zlozku';	
		return false; 
	}*/
	
	$fp = fopen($home_subor, 'w');
	$ret = ftp_nb_fget($spojenie, $fp, $ftp_subor, FTP_BINARY);
	
	while ($ret == FTP_MOREDATA) {
	   $ret = ftp_nb_continue($spojenie);
	}
	echo $i;
	if ($ret != FTP_FINISHED) {
	   echo "<br>Subor sa nepodarilo stiahnut.";
	   return false;
	}
	fclose($fp);
	return true;
}
?>