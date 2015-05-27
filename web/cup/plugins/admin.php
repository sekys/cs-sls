<? // 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++

// How simple :)
what_page();	

function what_page()
{
	// Ak je hrac a prihlaseny
	if(SLSUser::isPlayer()) 
	{
		// Ak je admin
		if( !SLS::get_admin() ) // ak je admin a ma dane prava
		{
			echo SLS::MsgL('access_no'));
			return 0;
		}
	} else {
		return 0;
	}
	
	// Nastavime
	SLSUser::$user['cs_meno'] = 'Admin '.SLSUser::$user['user_name'];
		
	echo '<div class="cup_body" align="center">';
	// Stranky
	$p1 = $_GET['p1'];
	$p2 = $_GET['p2'];
	
	echo $p1.$p2;
	if(!is_numeric($p2) or !$p2) {
		choose_page();
	} else {	
		if($p1 == 'clan') {
			// Clan sprava
			//clan_page();
		} elseif($p1 == 'hrac') {
			// Hrac spravuje
			//player_page();	
		} elseif($p1 == 'zapas') {
			// Zapas spravuje
			zapas_page();
		} else {
			// Vyber co spravovat
			choose_page();
		}
	}	
	echo '</div>	
	<div align="center" class="cup_credits" ><br>&copy; Powered by Seky`s Liga System v'.SLS::verzia.'</div>';
}
function choose_page()
{
	
	echo '
	<table class="cup_body" width="520" align="center" cellpadding="0" cellspacing="0">
		<tr>
			<td align="center">
				<a href="clan/">
					<img src="'.SLS::$STYLE.'admin/clan.png" alt="Clan Administr&aacute;cia " title="Clan Administr&aacute;cia " border="0" align="absmiddle">
				</a>
			</td>		
			<td align="center">
				<a href="hrac/">
					<img src="'.SLS::$STYLE.'admin/player.png" alt="Hr&aacute;&#269; Administr&aacute;cia " title="Hr&aacute;&#269; Administr&aacute;cia " border="0" align="absmiddle">
				</a>
			</td>				
			<td align="center">
				<a href="zapas/">
					<img src="'.SLS::$STYLE.'admin/player.png" alt="Z&aacute;pas Administr&aacute;cia " title="Z&aacute;pas Administr&aacute;cia " border="0" align="absmiddle">
				</a>
			</td>	
		</tr>	
	</table>';
}/*
function clan_page()
{
	
	// Kontroluje ci su udaje v poriadku .....
	$p2 = $_GET['p2'];
	if(!is_numeric($p2) or !$p2) {
		search_clan_page();
		return 0;
	}
	
	// Mysql
	@$sql = mysql_query("SELECT * FROM `phpbanlist`.`acp_clans` WHERE id ='".DB::Vstup($p2)."'");
	$clan = mysqli_fetch_assoc($sql);
	
	if(!$clan['id'])
	{
		echo SLS::Msg(SLSsprava('clan_nenajdeny'), 1);
		search_clan_page();
		return 0;
	}
	
	// Sam seba nemoze nastavovat
	if($clan['clan_id'] == SLSUser::$user['clan_id'])
	{
		echo SLS::Msg('Svoj clan nemozes administravovat.', 1);
		return 0;
	}
	
	// Akcia 
	if(isset($_POST['zapasy']))
	{
		_VynulovatZapasy($p2);
	}
	
	// Poracujeme v adminsitracii .....
	echo '
		<form action="" method="post">
			<input class="button" type="submit" name="zapasy" value="VYNULOVAT ZAPASY">
		</form>
	';	
}*/
function zapas_page() {	
	global $p2;
	// Mysql
	@$sql = SLS::Query2("SELECT * FROM `phpbanlist`.`cup_zapas` WHERE id ='".$p2."'");
	$zapas = mysqli_fetch_assoc($sql);
	
	if(!$zapas['id']) {
		echo SLS::Msg('Zapas nenajdeny !', 1);;
		return 0;
	}
		
	// Poracujeme v adminsitracii .....
	echo '
	<form action="" method="post">
			<style type="text/css">
			<!--
			.side-border-right {
				display:none;
				height:0;
				width:0;
			}
			-->
			</style>
			<div style="margin:5px;">	
				<table width="777" class="cup_zapas_bg" border="0" cellpadding="0" cellspacing="0">
					  <tr>
						<td height="30" class="cup_zapas_text_normal" id="cup_zapas_ciara_normal">&nbsp;'.SLSZapas::$server[ $zapas['server'] ][0].' - '.date("Y-m-d \o H", $zapas['datum']).'hod</td>
						<td width="80" align="center" class="cup_zapas_text_normal" id="cup_zapas_ciara_normal">Ob&#357;ia&#382;nos&#357;</td>
						<td width="40" align="center" class="cup_zapas_text_normal" id="cup_zapas_ciara_normal">Bonus</td>
						<td width="40" align="center" class="cup_zapas_text_normal" id="cup_zapas_ciara_normal">Bodov</td>						    
						<td width="180" align="center" class="cup_zapas_text_normal" id="cup_zapas_ciara_normal">'.$zapas['mapa'].'</td>
						<td width="70" align="right" class="cup_zapas_text_normal" id="cup_zapas_ciara_normal" >Score</td>
						<td width="70" align="right" class="cup_zapas_text_normal" id="cup_zapas_ciara_normal">Deaths</td>
						<td width="20" id="cup_zapas_ciara_normal">&nbsp;</td>
					  </tr>';
	
	// T team ,clan A		
			$team  = '';
			$pocet = 0;
			
			@$sql_clan=SLS::Query2("SELECT meno FROM `phpbanlist`.`acp_clans` WHERE id = '".$zapas['prijal']."'");
			$ziada = mysqli_fetch_assoc($sql_clan);		  
			
			if($zapas['t_team']) {
				$team = explode(SLSZapas::PARSER2, $zapas['t_team']);
			}
			
			$pocet = count($team);
			if($pocet) { $pocet--; }
			
			if($ziada['meno']) {
				$temp = '<a href="'.SLSPlugins::Adresa(5).$zapas['prijal'].'/" ><span class="cup_zapas_text_t">'.DB::Vystup($ziada['meno']).'</span></a>';					
			} else {
				$temp = '<span class="cup_zapas_text_t">Clan nen&aacute;jden&yacute;</span>';
			}			  
				echo' <tr>
						<td height="20" class="cup_zapas_text_t" id="cup_zapas_ciara_t" >Terrorists - '.$pocet.' players</td>
						<td align="center" id="cup_zapas_ciara_t">'.$zapas['prijal_narocnost'].'%</td>
						<td align="center" id="cup_zapas_ciara_t">'.$zapas['prijal_bonus'].'%</td>
						<td align="center" class="cup_zapas_text_t" id="cup_zapas_ciara_t" >'.$zapas['prijal_bodov'].'</td>
						<td align="center" id="cup_zapas_ciara_t">'.$temp.'</td>
						<td class="cup_zapas_text_t" align="right" id="cup_zapas_ciara_t" >'.$zapas['prijal_skore'].'</td>
						<td class="cup_zapas_text_t" align="right" id="cup_zapas_ciara_t">&nbsp;</td>
						<td id="cup_zapas_ciara_t">&nbsp;</td>
					  </tr>';
									
				// Hraci
				for($i=0; $i <= $pocet; $i++)
				{			
					if($team[$i])
					{							
						// meno ,kill,deatch
						$temp = explode(SLSZapas::PARSER1, $team[$i]);	
						$temp[0] = trim($temp[0]);
						if(!is_numeric($temp[0]))	
						{								
							echo'<tr>
									<td height="20" class="cup_zapas_text_t" colspan="5">&nbsp;'.DB::Vystup($temp[0]).'</td>
									<td class="cup_zapas_text_t" align="right">'.$temp[1].'</td>
									<td class="cup_zapas_text_t" align="right">'.$temp[2].'</td>
									<td>&nbsp;</td>
								  </tr>';		
						} else {
							@$sql = SLS::Query2("SELECT cs_meno FROM `cstrike`.`fusion_users` WHERE user_id ='".$temp[0]."'");
							$meno = mysqli_fetch_assoc($sql);
							
							echo'<tr>
									<td height="20" colspan="5">&nbsp;<a href="'.ROOT.'profile.php?lookup='.$temp[0].'"><span class="cup_zapas_text_t">'.DB::Vystup( $meno['cs_meno'] ).'</span></a></td>
									<td class="cup_zapas_text_t" align="right">'.$temp[1].'</td>
									<td class="cup_zapas_text_t" align="right">'.$temp[2].'</td>
									<td>&nbsp;</td>
								  </tr>';
						}		
					}	  
				}	
				
	// CT team ,clan B		
			$team  = '';
			$pocet = 0;
			
			@$sql_clan = SLS::Query2("SELECT meno FROM `phpbanlist`.`acp_clans` WHERE id = '".$zapas['ziada']."'");
			$ziada = mysqli_fetch_assoc($sql_clan);		  

			if($zapas['ct_team']) {
				$team = explode(SLSZapas::PARSER2, $zapas['ct_team']);
			}
			
			$pocet = count($team);
			if($pocet) { $pocet--; }
			
			if( $ziada['meno'] ) {
				$temp = '<a href="'.SLSPlugins::Adresa(5).$zapas['ziada'].'/" class="cup_zapas_text_ct" ><span class="cup_zapas_text_ct">'.DB::Vystup($ziada['meno']).'</span></a>';					
			} else {
				$temp = '<span class="cup_zapas_text_ct">Clan nen&aacute;jden&yacute;</span>';
			}			  
				echo' <tr>
						<td height="20" class="cup_zapas_text_ct" id="cup_zapas_ciara_ct" >Counter-Terrorists - '.$pocet.' players</td>
						<td align="center" id="cup_zapas_ciara_ct">'.$zapas['ziada_narocnost'].'%</td>
						<td align="center" id="cup_zapas_ciara_ct">'.$zapas['ziada_bonus'].'%</td>
						<td align="center" class="cup_zapas_text_ct" id="cup_zapas_ciara_ct" >'.$zapas['ziada_bodov'].'</td>
						<td align="center" id="cup_zapas_ciara_ct">'.$temp.'</td>
						<td class="cup_zapas_text_ct" align="right" id="cup_zapas_ciara_ct" >'.$zapas['ziada_skore'].'</td>
						<td class="cup_zapas_text_ct" align="right" id="cup_zapas_ciara_ct">&nbsp;</td>
						<td id="cup_zapas_ciara_ct">&nbsp;</td>
					  </tr>';
									
				// Hraci
				for($i=0; $i <= $pocet; $i++)
				{			
					if($team[$i])
					{							
						// meno ,kill,deatch
						$temp = explode(SLSZapas::PARSER1, $team[$i]);		
						$temp[0] = trim($temp[0]);
						if(!is_numeric($temp[0]))	
						{								
							// echo
							echo'<tr>
									<td height="20" class="cup_zapas_text_ct" colspan="5">&nbsp;'.DB::Vystup($temp[0]).'</td>
									<td class="cup_zapas_text_ct" align="right">'.$temp[1].'</td>
									<td class="cup_zapas_text_ct" align="right">'.$temp[2].'</td>
									<td>&nbsp;</td>
								  </tr>';		
						} else {
							@$sql = SLS::Query2("SELECT cs_meno FROM `cstrike`.`fusion_users` WHERE user_id ='".$temp[0]."'");
							$meno = mysqli_fetch_assoc($sql);
							
							echo'<tr>
									<td height="20" colspan="5">&nbsp;<a href="'.ROOT.'profile.php?lookup='.$temp[0].'"><span class="cup_zapas_text_ct">'.DB::Vystup( $meno['cs_meno'] ).'</span></a></td>
									<td class="cup_zapas_text_ct" align="right">'.$temp[1].'</td>
									<td class="cup_zapas_text_ct" align="right">'.$temp[2].'</td>
									<td>&nbsp;</td>
								  </tr>';
						}		  
					}	  
				}		
	// SPE team 				
			$temp  = '';
			$pocet = 0;
			
			if($zapas['spe_team']) {
				$temp = explode(SLSZapas::PARSER2, $zapas['spe_team']);
			}
			
			$pocet = count($temp);
			if($pocet) { $pocet--; }
					  
				echo' <tr>
						<td height="20" class="cup_zapas_text_spe" id="cup_zapas_ciara_spe" colspan="5">Spectators&nbsp;&nbsp;&nbsp;-&nbsp;&nbsp;&nbsp;'.$pocet.' players</td>
						<td align="center" id="cup_zapas_ciara_spe">&nbsp;</td>
						<td class="cup_zapas_text_spe" align="right" id="cup_zapas_ciara_spe" >&nbsp;</td>
						<td class="cup_zapas_text_spe" align="right" id="cup_zapas_ciara_spe">&nbsp;</td>
						<td id="cup_zapas_ciara_spe">&nbsp;</td>
					  </tr>';
									
				// Hraci
				for($i=0; $i <= $pocet; $i++)
				{			
					$temp[$i] = trim($temp[$i]);

					if(!is_numeric($temp[$i]))
					{														
							// echo
							echo'<tr>
									<td height="20" class="cup_zapas_text_spe" colspan="5">&nbsp;'.DB::Vystup($temp[$i]).'</td>
									<td class="cup_zapas_text_spe" align="center">&nbsp;</td>
									<td class="cup_zapas_text_spe" align="right">&nbsp;</td>
									<td class="cup_zapas_text_spe" align="right">&nbsp;</td>
									<td>&nbsp;</td>
								  </tr>';				  
					} else {
							@$sql = SLS::Query2("SELECT cs_meno FROM `cstrike`.`fusion_users` WHERE user_id ='".$temp[$i]."'");
							$meno = mysqli_fetch_assoc($sql);
							if($meno['cs_meno']) {					  
							echo'<tr>
									<td height="20" class="cup_zapas_text_spe" colspan="5">&nbsp;<a href="profile.php?lookup='.$temp[$i].'"><span class="cup_zapas_text_spe">'.DB::Vystup( $meno['cs_meno'] ).'</span></a></td>
									<td class="cup_zapas_text_spe" align="center">&nbsp;</td>
									<td class="cup_zapas_text_spe" align="right">&nbsp;</td>
									<td class="cup_zapas_text_spe" align="right">&nbsp;</td>
									<td>&nbsp;</td>
								  </tr>';	
							} else {
							echo'<tr>
									<td height="20" class="cup_zapas_text_spe" colspan="5">&nbsp;'.DB::Vystup($temp[$i]).'</td>
									<td class="cup_zapas_text_spe" align="center">&nbsp;</td>
									<td class="cup_zapas_text_spe" align="right">&nbsp;</td>
									<td class="cup_zapas_text_spe" align="right">&nbsp;</td>
									<td>&nbsp;</td>
								  </tr>';
							}		
					}  
				}	
			
				// demo je cup_sql_id.dem a cez ftp stiahnut
					  
				echo' <tr><td colspan="5" height="20">&nbsp;</td></tr>
					  <tr><td colspan="5" height="20" class="cup_zapas_text_normal" >Stiahnu&#357; <a class="cup_zapas_text_normal" href="'.SLSPlugins::Adresa(19).$zapas['id'].'/">DEMO</a></td></tr>
					  <tr><td colspan="5" height="20" class="cup_zapas_text_normal" >Status: '.SLS::get_dovod_zapasu($zapas['status']).'</td></tr>
				</table>
			</div>	
	</form>';	
}
/*
function player_page()
{	
	
	// Kontroluje ci su udaje v poriadku .....
	$p2 = $_GET['p2'];
	if(!is_numeric($p2) or !$p2) {
		search_player_page();
		return 0;
	}
	// Mysql
	@$sql = mysql_query("SELECT * FROM cstrike`.`fusion_users` WHERE user_id ='".$p2."'");
	$clan = mysqli_fetch_assoc($sql);
	
	if(!$clan['user_id'])
	{
		echo SLS::Msg(SLSsprava('hrac_no'), 1);
		search_player_page();
		return 0;
	}
	
	// Sam seba nemoze nastavovat
	if($clan['user_id'] == SLSUser::$user['user_id'])
	{
		echo SLS::Msg('Sam seba nemozes administravovat.', 1);
		return 0;
	}
	
	// Akcia 
	if(isset($_POST['zapasy']))
	{
		_VynulovatZapasy($p2);
	}
	
	// Poracujeme v adminsitracii .....
	echo '
		<form action="" method="post">
			<input class="button" type="submit" name="zapasy" value="VYNULOVAT ZAPASY">
		</form>
	';
}
function search_clan_page()
{
	
	// Hladame CLAN 
	echo '		
	<table class="cup_body" width="500" align="center" cellpadding="0" cellspacing="0">
		<tr>
			<th class="cup_nazov" colspan="6"> H&#318;adanie Clanov...  </th>
		</tr>
		<form action="" method="post">
			<tr> 
				<td class="cup_riadok" align="center"  colspan="6" >
					<strong>ID</strong> <input type="text" name="id" size="10" > alebo <strong> MENO </strong>
					<input type="text" name="meno" size="40" > 
					<input class="button" type="submit" name="Submit" value="H&#318;ada&#357;">
				</td>
			</tr>	
		</form>';

	
	// Odoslal ...	
	if($_POST['id'] and is_numeric($_POST['id'])) {
		$podmienka = " WHERE id = '".DB::Vstup(trim($_POST['id']))."' ";
	} elseif($_POST['meno']) {
		$podmienka = " WHERE `meno` LIKE '%".DB::Vstup(trim($_POST['meno']))."%' ";
	} else {
		echo '</table>';
		return 0;
	}
	// Mysql ...	
	$sql_pocet = DB::Pocet("SELECT COUNT(id) as pocet FROM `phpbanlist`.`acp_clans` ".$podmienka." ORDER BY bodov desc ");
															
	if( $sql_pocet ) {
		@$sql = mysql_query("SELECT id, meno, tag, bodov, COALESCE(pocet_a, 0) + COALESCE(pocet_b, 0) AS zapasov, COALESCE(hracov,0) as hracov
						FROM `phpbanlist`.`acp_clans` c																		
							
							LEFT JOIN ( SELECT prijal, COUNT(prijal) AS pocet_a FROM `phpbanlist`.`cup_zapas` GROUP BY prijal ) a
								ON c.id = a.prijal								
							LEFT JOIN ( SELECT ziada, COUNT(ziada) AS pocet_b FROM `phpbanlist`.`cup_zapas` GROUP BY ziada ) b
								ON c.id = b.ziada																															
							
							LEFT JOIN ( SELECT clan_id, COUNT(user_id) AS hracov FROM `cstrike`.`fusion_users` GROUP BY clan_id ) h
								ON c.id = h.clan_id										
					".$podmienka." ORDER BY bodov desc ");		
		echo '<tr>'; 
			echo "<td  class=\"cup_riadok\" colspan=\"2\" align=\"center\">Meno</td>";
			echo "<td  class=\"cup_riadok\" width=\"80\" align=\"center\">Tag</td>";
			echo "<td  class=\"cup_riadok\" width=\"40\" align=\"center\">Hracov</td>";
			echo "<td  class=\"cup_riadok\" width=\"40\" align=\"center\">Zapasov</td>";									
			echo "<td  class=\"cup_riadok\" width=\"60\" align=\"center\">Bodov</td>";
		echo '</tr>';
		
		while($row = mysqli_fetch_assoc($sql)) 
		{ 
			echo '<tr>'; 
				echo '<td class="cup_riadok" width="10" align="center"><a href="" ><img src="'.SLS::$STYLE.'/admin/tool.gif" alt="Upravi&#357; tento clan" title="Upravi&#357; tento clan" border="0" align="absmiddle"></a></td>';					
				echo "<td  class=\"cup_riadok\" width=\"300\" align=\"center\"><a href=\"".SLSPlugins::Adresa(5).$row['id']."/\" >";			
				echo (SLSUser::$user['clan_id'] == $row['id']) ? '<span style="color:blue;">' : '<span class="cup_clan">';
				echo DB::Vystup($row['meno']) . '<span></a></td>';
				echo "<td  class=\"cup_riadok\" width=\"80\" align=\"center\">" . $row['tag'] . "</td>";
				echo "<td  class=\"cup_riadok\" width=\"40\" align=\"center\">" . $row['hracov'] . "</td>";
				echo "<td  class=\"cup_riadok\" width=\"40\" align=\"center\">" . $row['zapasov'] . "</td>";									
				echo "<td  class=\"cup_riadok\" width=\"60\" align=\"center\">" . $row['bodov'] . "</td>";
			echo '</tr>';
		}
	} else {
		echo '<tr> 
				<td class="cup_riadok" align="center"  colspan="6" >
					<em>V?sledok nen?jden? !</em>
				</td>
			 </tr>';
	}
}/
function search_player_page()
{
	
	
	// Hladame teraz uzivatela
	echo '		
	<table class="cup_body" width="520" align="center" cellpadding="0" cellspacing="0">
		<tr>
			<th class="cup_nazov" colspan="4"> H&#318;adanie hracov...  </th>
		</tr>
		<form action="" method="post">
			<tr> 
				<td class="cup_riadok" align="center" ><strong>ID</strong></td>
				<td class="cup_riadok" align="center" colspan="3"><input type="text" name="id" size="10" > alebo <strong> MENO </strong> <input type="text" name="meno" size="40" /> <input class="button" type="submit" name="Submit" value="H&#318;ada&#357;"></td>
			</tr>	
		</form>';

	
	// Odoslal ...	
	if($_POST['id'] and is_numeric($_POST['id'])) {
		$podmienka = " WHERE user_id = '".trim($_POST['id'])."' ";
	} elseif($_POST['meno']) {
		$podmienka = " WHERE `cs_meno` LIKE '%".DB::Vstup(trim($_POST['meno']))."%' OR user_name LIKE '%".DB::Vstup(trim($_POST['meno']))."%'";
	} else {
		echo '</table>';
		return 0;
	}
	
	// Mysql ...	
	@$sql = mysql_query("SELECT user_id, user_name, cs_meno, meno FROM `cstrike`.`fusion_users` u																									
							LEFT JOIN ( SELECT id, meno FROM `phpbanlist`.`acp_clans`) c
								ON u.clan_id = c.id																	
						".$podmienka." ORDER BY bodov desc ");
	
	while($row = mysqli_fetch_assoc($sql)) 
	{ 
		echo '<tr>'; 
			echo '<td class="cup_riadok" width="10%" align="center"><a href="'.SLSPlugins::Adresa_na_seba().$row['user_id'].'/" ><img src="'.SLS::$STYLE.'/admin/tool.gif" alt="Upravi&#357; tochto hraca" title="Upravi&#357; tochto hraca" border="0" align="absmiddle"></a></td>';					
			echo "<td  class=\"cup_riadok\" width=\"30%\" align=\"center\">
					<a href='/profile.php?lookup=".$row['id']."' >".$row['user_name']."</a>";
			echo "<td  class=\"cup_riadok\" width=\"30%\" align=\"center\">" . DB::Vystup($row['cs_meno']) . "</td>";
			echo "<td  class=\"cup_riadok\" width=\"30%\" align=\"center\">" . $row['meno'] . "</td>";
		echo '</tr>';
	}	
}
function _VynulovatZapasy($id);
{
	$sql = mysql_query("SELECT ziada, ziada_skore, prijal, prijal_bodov, status FROM `cup_zapas` WHERE `ct_team` LIKE '%".$id." %' OR `t_team` LIKE '%".$id." %'");
	while($data = mysqli_fetch_assoc($sql)) {
		array_find_or_add($id, $kolko);
		array_find_or_add($id, $kolko);
	}
}
$clany;
function array_find_or_add($id, $kolko)
{
	global $clany;
	
	for($i=0; $i < count($clany); $i++)
	{
		if($clany[$i][0] == $id) { 
			$clany[$i][1] += $kolko;
			return 0; 
		}
	}
	$clany[] = array($id, $kolko);
}
*/
// 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++ ?>