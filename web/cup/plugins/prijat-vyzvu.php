<? // 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++


	// Akcia	
	if($_POST['datum'] or $_POST['mapa'])
	{
		$temp = explode("-", $_POST['datum']);
		$cas = mktime(0, 0, 0, $temp[1], $temp[2], $temp[0]);
		$rozdiel = $cas+60*60*24;
		$prikaz = "`datum` > '".DB::Vstup(trim($cas))."' AND `datum` < '".DB::Vstup(trim($rozdiel))."'";
		$mapa = DB::Vstup(trim($_POST['mapa']));
		
		@$sql_vyzva=SLS::Query2("SELECT * FROM `phpbanlist`.`acp_vyzva` c
									LEFT JOIN ( SELECT id, meno FROM `phpbanlist`.`acp_clans`) h
										ON c.ziada = h.id	
									WHERE prijal IS NULL AND sukromna = 0 AND
										(( ".$prikaz." ) 
										OR `mapa` LIKE '%".$mapa."%')
									ORDER BY datum  ".SLS::get_zoznam()."");
		$sql_pocet = SLS::Count2("SELECT COUNT(id) as pocet FROM `phpbanlist`.`acp_vyzva` 
											WHERE prijal IS NULL AND sukromna = 0 AND
												(( ".$prikaz." )
												OR `mapa` LIKE '%".$mapa."%')");						
	} else {
		@$sql_vyzva=SLS::Query2("SELECT * FROM `phpbanlist`.`acp_vyzva` c
									LEFT JOIN ( SELECT id, meno FROM `phpbanlist`.`acp_clans` ) h
										ON c.ziada = h.id
									WHERE prijal IS NULL AND sukromna = 0
									ORDER BY datum ".SLS::get_zoznam()."");
		$sql_pocet = SLS::Count2("SELECT COUNT(id) as pocet FROM `phpbanlist`.`acp_vyzva` WHERE prijal IS NULL AND sukromna = 0");
	}
	echo '<div class="cup_body" align="center">';
		echo '<table class="cup_body" width="520" align="center" cellpadding="0" cellspacing="0" >
				<tr>
					<th class="cup_nazov" > # </th>
					<th class="cup_nazov" > &#381;iada </th>
					<th class="cup_nazov" > &#268;as </th>
					<th class="cup_nazov" > Mapa </th>
				</tr>
		
		';
	// Hladat	
			echo '
			<form action="" method="post">
				<tr>
					<td class="cup_riadok" width="40" align="center" colspan="6" >
						<input name="datum" style="font-size:10px;" type="text" value="'.date("Y-m-d").'">
						<input name="mapa" style="font-size:10px;" type="text" value="'.($_POST['mapa'] ? $mapa : SLS::$vyzva_mapa[0] ).'">
						<input class="button" type="submit" name="Submit" value="H&#318;ada&#357;">
					</td>
				</tr>
			</form>';			
			
		if( $sql_pocet ) 
		{											
			while($vyzva=mysqli_fetch_assoc($sql_vyzva)) 
			{ 
				$datum = date("Y-m-d", $vyzva['datum']);
				$hodina = date("H", $vyzva['datum']);	
				echo '
					<tr>
						<td class="cup_riadok" width="10" align="center" style="padding: 0px;">
							<a href="'.SLSPlugins::Adresa(10).$datum.'/'.$hodina.'/'.$vyzva['server'].'/">
								<img title="Prija&#357; v&yacute;zvu ?" src="'.SLS::$STYLE.'cup_ok.gif" alt="Prija&#357; v&yacute;zvu ?" width="20" height="20" border="0" align="absmiddle">
							</a>
						</td>	
						<td class="cup_riadok" width="100" align="center" >
							<a href="'.SLSPlugins::Adresa(5).$vyzva['ziada'].'/">'.SLSClan::ClanMeno($vyzva['meno']).'</a> 
						</td>	
						<td class="cup_riadok" width="80" style="color:#999999;" align="center" >
							'.$datum.'	o '.$hodina.'hod
						</td>					
						<td class="cup_riadok" style="color:#999999;" width="80" align="center" >
							'.$vyzva['mapa'].'	
						</td>
					</tr>';
			} 
			$pocet = SLS::Count2("SELECT COUNT(id) as pocet FROM `phpbanlist`.`acp_vyzva` WHERE prijal IS NULL AND sukromna > 0");
			echo '<tr>
					<td class="cup_riadok" width="40" align="center" colspan="6" >
						<em>'.$pocet.' s&uacute;kromn&yacute;ch v&yacute;ziev  ... </em>
					</td>
				</tr>';
		}	else {
			echo '<tr>
					<td class="cup_riadok" width="40" align="center" colspan="6" >
						<em>&#381;iadne v&yacute;zvy ... </em>
					</td>
				</tr>';	
		}
		echo '</table>';
		echo SLS::set_zoznam($sql_pocet);
	echo '</div><div align="center" class="cup_credits" ><br>&copy; Powered by Seky`s Liga System v'.SLS::verzia.'</div>';	

// 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++ ?>