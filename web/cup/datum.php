<? 
die('Kalendar na rozvrh zapasov sa pripravuje.');
?>
<html>	
	<head>
	    <title>GeCom Cup Kalendar</title>
	    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<meta name='robots' content='noindex, nofollow' />
	<? SLS::$aktivuj(); ?>
	<script type="text/javascript">
		function returnDate(d) {
			txt = d;
			if (window.opener.dateType != 'date') {
				h = parseInt(document.getElementById('hour').value,10);
				m = parseInt(document.getElementById('minute').value,10);
				s = parseInt(document.getElementById('second').value,10);
				if (window.opener.dateType == 'datetime') {
					txt += ' ' + formatNum2(h, 'hour') + ':' + formatNum2(m, 'minute') + ':' + formatNum2(s, 'second');
				} else {
					txt += formatNum2(h, 'hour') + formatNum2(m, 'minute') + formatNum2(s, 'second');
				}
			}
			
			window.opener.dateField.value = txt;
			window.close();
		}
		$(function(){
			// Datepicker
			$('#datepicker').datepicker({
				inline: true
			});
		});
	</script>
</head>	
<body>
	<div id="datepicker"> </div>
	<div align="center" class="cup_cal">
<?
/*
// Kalendar
$nazvy_dni = Array( 1=> "P", "U", "S", "&Scaron;", "P", "S", "N");
$nazvy_mes = Array( 1=> "Janu&aacute;r", "Febru&aacute;r", "Marec", "Apr&iacute;l", "M&aacute;j", "J&uacute;n",
"J&uacute;l", "August", "September", "Oktober", "November", "December");
SLS::$mysql_spojenie();
	
function kalendar_mysql_mesiac($rok, $mesiac)
{
	// Vlastne formatovanie mesiaca a dna
	$dni_v_mesiaci = cal_days_in_month(CAL_GREGORIAN, $mesiac, $rok);
	$mesiac = ($mesiac < 10) ? '0'.$mesiac : $mesiac;
	$rok_mes = $rok."-".$mesiac."-";
	
	
	// pripravyme script....
	$script = "SELECT count( id ) AS '1' ";
	for($i=2; $i <= $dni_v_mesiaci; $i++)
	{
		$script .= 	", ( SELECT count(id) FROM `acp_vyzva` WHERE `datum` = '";
		$script .= 	($i < 10) ? $rok_mes.'0'.$i."' ) as '".$i."'" : $rok_mes.$i."' ) as '".$i."'";
		
		// , ( SELECT count( id ) FROM `acp_vyzva` WHERE `datum` = '2009-06-26' ) as '2009-06-26'
	}
	$script .= " FROM `acp_vyzva` WHERE `datum` = '".$rok."-".$mesiac ."-01'";
	return mysql_fetch_row( mysql_query($script) );
}

// Upravujeme
	$mesiac = $_GET['p2'];
	$rok = $_GET['p1'];
	if ($mesiac<1 || $mesiac>12)
		$mesiac=date('n');
	if (!$rok)
		$rok=date('Y');
	
// Overime ci sa oplati....
	$dnes = getdate();
	if( ($dnes['year'] <= $rok and $dnes['mon'] <= $mesiac) or $rok > $dnes['year'])
	{
	// Pocitame
		$pocet_hodin = count(SLS::$vyzva_hodina);
		$mysql_dni = kalendar_mysql_mesiac($rok, $mesiac);
		$nieje_stare=1;
			
		if($dnes['year'] == $rok and $dnes['mon'] == $mesiac)
		{
			$nieje_stare=2;	// 3.moznost.....
		}
	}
// Dalsie
	$rok_mes = ($mesiac < 10) ? '0'.$mesiac : $mesiac;
	$rok_mes = $rok."-".$rok_mes."-";
	$prvy_den = gmmktime(0,0,0,$mesiac,1,$rok);

	list($mesiac_2, $rok_2, $mesiac_name, $tyzden) = explode(',',gmstrftime('%m,%Y,%B,%w',$prvy_den));
	$tyzden = ($tyzden + 6) % 7;
// Header
	echo '
		<div class="cup_cal_head">
			<a href="'.SLS::Adresa(18);				
			echo ($mesiac == 1 ? $rok-1 : $rok ).'/';
			echo ($mesiac == 1) ? '12' : $mesiac-1;			
			echo '/"><span class="ui-icon ui-icon-circle-triangle-w">Prev</span></a>
			'.$nazvy_mes[$mesiac].'&nbsp;'.$rok.'&nbsp;
			<a href="'.SLS::Adresa(18);
			echo ($mesiac == 12 ? $rok+1 : $rok ).'/';	
			echo ($mesiac == 12) ? '1' : $mesiac+1;	
			echo '/">D</a>
		</div>
		<table class="cup_cal_tabulka">
			<thead>
				<tr>';
// Nazvy dni
	foreach($nazvy_dni as $nazvy) {
				echo '<th>'.$nazvy.'</th>';
	}	
	echo "		</tr>
			</thead>
			<tbody>
				<tr>";		
	if($tyzden > 0) {
		echo '<td colspan="'.$tyzden.'"  class="cup_cal_prazdne">&nbsp;</td>';
	}
	
	for($day=1, $mysql_dni_v_mesiaci=gmdate('t',$prvy_den); $day<=$mysql_dni_v_mesiaci; $day++, $tyzden++)
	{
		if($tyzden == 7){
			$tyzden   = 0; // novy tyzden
		  echo "</tr>
				<tr>";
		}
		$datum = ($day < 10) ? '0'.$day : $day;
		$datum = $rok_mes.$datum;		
		// Mysql udaje do vypoctu
		if($nieje_stare)
		{
			$mysql_den = $mysql_dni[$day-1];
			
			if($nieje_stare==2)
			{
				if( $day >= $dnes['mday']) {	
					if( $mysql_den > 0) {
						if($mysql_den == $pocet_hodin) { 
						echo "<td><a href=\"#\"  class='ui-state-default cup_cal_policko' id=\"cup_cal_full\"  title=\"Tento de&#328; je zaplnen&yacute;\">".$day."</a></td>"; 
						} else {
						echo "<td><a href=\"javascript:returnDate('".$datum."');\"  class='ui-state-default cup_cal_policko' id=\"cup_cal_normal\"  title=\"V tento de&#328; je ".$mysql_den." v&yacute;ziev\">".$day."</a></td>";
						}
					} else {
						echo "<td><a href=\"javascript:returnDate('".$datum."');\"  class='ui-state-default cup_cal_policko' id=\"cup_cal_null\"  title=\"Tento de&#328; je &uacute;plne vo&#318;ln&yacute;\">".$day."</a></td>";
					}
				} else {
					echo "<td><a href=\"#\"  class='ui-state-default cup_cal_policko' id=\"cup_cal_old\"  title=\"Minulost si nem&ocirc;&#382;e&scaron; rezervova&#357;\">".$day."</a></td>";
				}
			} else {	
				if( $mysql_den > 0) { 	
					if($mysql_den == $pocet_hodin) { 
					echo "<td><a href=\"#\"  class='ui-state-default' id=\"cup_cal_full\"  title=\"Tento de&#328; je zaplnen&yacute;\">".$day."</a></td>"; 
					} else {
					echo "<td><a href=\"javascript:returnDate('".$datum."');\"  class='ui-state-default' id=\"cup_cal_normal\"  title=\"V tento de&#328; je ".$mysql_den." v&yacute;ziev\">".$day."</a></td>";
					}
				} else { 
					echo "<td><a href=\"javascript:returnDate('".$datum."');\" class='ui-state-default' id=\"cup_cal_null\" title=\"Tento de&#328; je &uacute;plne vo&#318;ln&yacute;\">".$day."</a></td>";
				}
			}	
		} else {	
					echo "<td><a href=\"#\" class='ui-state-default' id=\"cup_cal_old\" title=\"Minulost si nem&ocirc;&#382;e&scaron; rezervova&#357;\" >".$day."</a></td>";
		}	
	}
	
	if($tyzden != 7) echo '<td colspan="'.(7-$tyzden).'">&nbsp;</td>';
	echo "		</tr>
			</tbody>
		</table>
	</div>";
			
		echo '<div align="center" class="cup_credits" >&copy; Powered by Seky`s Liga System v'.SLS::verzia.'</div>';*/
	SLS::$ukonci();
	
	
	
	
	
	
	/*
	rezervacia
	
	http://www.kotelna-web.cz/?strana=rezervace
	
	<table cellspacing="2" cellpadding="0" bordercolor="#cbcbcb" border="2" class="rezervace"><tbody><tr><th width="60">Datum</th><th width="17">0</th><th width="17">1</th><th width="17">2</th><th width="17">3</th><th width="17">4</th><th width="17">5</th><th width="17">6</th><th width="17">7</th><th width="17">8</th><th width="17">9</th><th width="17">10</th><th width="17">11</th><th width="17">12</th><th width="17">13</th><th width="17">14</th><th width="17">15</th><th width="17">16</th><th width="17">17</th><th width="17">18</th><th width="17">19</th><th width="17">20</th><th width="17">21</th><th width="17">22</th><th width="17">23</th>
          </tr>
        <tr> <th>06.09</th><td class="false">x</td><td class="false">x</td><td class="false">x</td><td class="false">x</td><td class="false">x</td><td class="false">x</td><td class="false">x</td><td class="false">x</td><td class="false">x</td><td class="false">x</td><td class="false">x</td><td class="false">x</td><td class="false">x</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td></tr><tr> <th>07.09</th><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td></tr><tr> <th>08.09</th><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td></tr><tr> <th>09.09</th><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td></tr><tr> <th>10.09</th><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td></tr><tr> <th>11.09</th><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td></tr><tr> <th>12.09</th><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td></tr><tr> <th>13.09</th><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td><td>?</td></tr>    </tbody></table>
	
		rezervace{
color:black;
font-size:13px;
left:7px;
position:relative;
text-align:center;
}
.rezervace th {
background-color:#CBCBCB;
border:1px solid #9F9F9F;
font-weight:bold;
}
.rezervace td {
background-color:#9DBA1A;
border:1px solid #768C15;
padding:0;
}
.rezervace td.false {
background-color:#E1E1E1;
border:1px solid #D7D7D7;
}
.rezervace td.used {
background-color:black;
border:0 solid #768C15;
}
.rezervace a:link, .rezervace a:visited {
background-color:#9DBA1A;
border:0 solid #768C15;
cursor:pointer;
padding:0 6px 0 7px;
text-decoration:none;
}
.rezervace a:hover {
background-color:blue;
border:0 solid #768C15;
cursor:pointer;
padding:0 6px 0 7px;
text-decoration:none;
}
.rezervace a.moje:link, .rezervace a.moje:visited {
background-color:#FFAE00;
border:0 solid #768C15;
cursor:pointer;
padding:0 6px 0 7px;
text-decoration:none;
}
.rezervace a.moje:hover {
background-color:red;
border:0 solid #768C15;
cursor:pointer;
padding:0 6px 0 7px;
text-decoration:none;
}

	*/	
?>
		</div>
	</body>
</html>
<? 		// 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++	?>