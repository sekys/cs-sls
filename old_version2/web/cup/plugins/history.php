<? // 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++
if(!$page) { header("Location: ../index.php"); exit; }

	// Akcia	
	if(isset($_POST['datum']))
	{
		$temp = explode("-", $_POST['datum']);
		$cas = mktime(0, 0, 0, $temp[1], $temp[2], $temp[0]);
		$rozdiel = $cas+60*60*24;
		$prikaz = "`datum` > '".SLS::mysql_vstup(trim($cas))."' AND `datum` < '".SLS::mysql_vstup(trim($rozdiel))."'";
		@$sql_vyzva = SLS::mysql_dbquery("SELECT z.id, ziada, prijal, ziada_bodov + prijal_bodov as bodov, datum, server, ziada_meno, prijal_meno FROM `phpbanlist`.`cup_zapas` z
										LEFT JOIN ( SELECT id, meno as ziada_meno FROM `phpbanlist`.`acp_clans` ) a
											on z.ziada = a.id										
										LEFT JOIN ( SELECT id, meno as prijal_meno FROM `phpbanlist`.`acp_clans` ) b
											on z.prijal = b.id
									WHERE ".$prikaz." ORDER BY datum desc ".SLS::get_zoznam().""
									);
		@$sql_pocet = SLS::mysql_count2("SELECT COUNT(id) as pocet FROM `phpbanlist`.`cup_zapas` WHERE ".$prikaz);						
	} else {
		@$sql_vyzva = SLS::mysql_dbquery("SELECT z.id, ziada, prijal, ziada_bodov + prijal_bodov as bodov, datum, server, ziada_meno, prijal_meno FROM `phpbanlist`.`cup_zapas` z 
										LEFT JOIN ( SELECT id, meno as ziada_meno FROM `phpbanlist`.`acp_clans` ) a
											on z.ziada = a.id										
										LEFT JOIN ( SELECT id, meno as prijal_meno FROM `phpbanlist`.`acp_clans` ) b
											on z.prijal = b.id
									ORDER BY datum desc ".SLS::get_zoznam().""
									);
		@$sql_pocet = SLS::mysql_count2("SELECT COUNT(id) as pocet FROM `phpbanlist`.`cup_zapas`");
	}
	echo '<div class="cup_body" align="center">';
		echo '<table class="cup_body" width="520" align="center" cellpadding="0" cellspacing="0" >
				<tr>
					<th class="cup_nazov" > Bodov </th>
					<th class="cup_nazov" > &#381;iadal </th>
					<th class="cup_nazov" > Prijal </th>
					<th class="cup_nazov" > &#268;as </th>
					<th class="cup_nazov" > Info </th>
				</tr>
		
		';
	// Hladat	
			echo '
			<form action="'.SLS::$adresy[1].'" method="post">
				<tr>
					<td class="cup_riadok" align="center" colspan="6" >
						<input name="datum" style="font-size:10px;" type="text" value="'.date("Y-m-d").'">
						<input class="button" type="submit" name="Submit" value="H&#318;ada&#357;">
					</td>
				</tr>
			</form>';			
		
		if($sql_pocet ) 
		{											
			while($vyzva=mysql_fetch_assoc($sql_vyzva)) 
			{ 
					$vyzva['server'] = ($vyzva['server']) ? $vyzva['server'] : '0';
					$datum = date("Y-m-d", $vyzva['datum']);
					$hodina = date("H", $vyzva['datum']);
					echo '
						<tr>
							<td class="cup_riadok" width="10" align="center">
								'.$vyzva['bodov'].'	
							</td>							
							<td class="cup_riadok" width="100" align="center" >
								<a href="'.SLS::cesta(5).$vyzva['ziada'].'/">'.SLS::set_clan_meno($vyzva['ziada_meno']).'</a> 					
							</td>		
							<td class="cup_riadok" width="100" align="center" >
								<a href="'.SLS::cesta(5).$vyzva['prijal'].'/">'.SLS::set_clan_meno($vyzva['prijal_meno']).'</a> 					
							</td>
							<td class="cup_riadok" width="80" style="color:#999999;" align="center" >
								'.$datum.' o '.$hodina.'hod
							</td>	
							<td class="cup_riadok" width="10" align="center" style="padding: 0px;">
								<a href="'.SLS::cesta(15).$datum.'/'.$hodina.'/'.$vyzva['server'].'/">
									<img title="Pozrie&#357; detaily z&aacute;pasu." src="'.SLS::$adresy[3].'stats.gif" alt="Pozrie&#357; detaily z&aacute;pasu." border="0" align="absmiddle">
								</a>
							</td>
						</tr>
					';
			} 
		}	else {
			echo '<tr>
					<td class="cup_riadok" width="40" align="center" colspan="6" >
						<em>'.SLS::sprava('zapasy_history').'</em>
					</td>
				</tr>
				';	
		}
		echo '</table>';
		echo SLS::set_zoznam($sql_pocet);
	echo '</div><div align="center" class="cup_credits" ><br>&copy; Powered by Seky`s Liga System v'.SLS::verzia.'</div>';	
	
// 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++ ?>