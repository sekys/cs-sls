<? // 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++
if(!$page) { header("Location: ../index.php"); exit; }
	$g_stavky = false;
	$sql_pocet = SLS::mysql_count2("SELECT COUNT(id) as pocet FROM `phpbanlist`.`acp_vyzva` WHERE (ziada !='".SLS::$user['clan_id']."' OR prijal !='".SLS::$user['clan_id']."') AND prijal IS NOT NULL");
	echo '<div class="cup_body" align="center">';
		echo '<table class="cup_body" width="540" align="center" cellpadding="0" cellspacing="0" >
				<tr>
					<th class="cup_nazov" > &#381;iadal </th>
					<th class="cup_nazov" > Prijal </th>
					<th class="cup_nazov" > &#268;as </th>
					';
			if($g_stavky_switch)	{
				echo '
					<th class="cup_nazov" > 1 </th>
					<th class="cup_nazov" > 2 </th>';
			}
			echo '
					<th class="cup_nazov" > Mapa </th>
				</tr>	
		';			
		SLS::$user['clan_id'] = 0;
		$sql_pocet = 1;
		if($sql_pocet) 
		{														
			@$sql_vyzva=SLS::mysql_dbquery("SELECT * FROM `phpbanlist`.`acp_vyzva` c
						LEFT JOIN ( SELECT id as ziada_id, meno as ziada_meno FROM `phpbanlist`.`acp_clans` GROUP BY id ) h
							ON c.ziada = h.ziada_id								
						LEFT JOIN ( SELECT id as prijal_id, meno as prijal_meno FROM `phpbanlist`.`acp_clans` GROUP BY id ) f
							ON c.prijal = f.prijal_id	
						WHERE 
							(ziada !='".SLS::$user['clan_id']."' OR prijal !='".SLS::$user['clan_id']."') 
							AND prijal IS NOT NULL AND datum > '".time()."'
						ORDER BY datum ".SLS::get_zoznam()."");
			$chover = " onmouseover=\"this.className='cup_riadok2_hover';\"	onmouseout=\"this.className='cup_riadok2'\" ";	
			
			function kurz_hover($id, $clan) {
				return " onmouseover=\"this.className='cup_kurz_hover';\" onmouseout=\"this.className='cup_kurz'\" onclick=\"stavky_pridaj(".$id.", ".$clan.");\" ";	
			}
			
			if($g_stavky)	{	
				while($vyzva=mysql_fetch_assoc($sql_vyzva)) 
				{ 
						echo '
							<tr class="cup_riadok2" '.$chover.' id="zapas-'.$vyzva['id'].'">	
								<td width="100" align="center" >
									<a href="'.SLS::cesta(5).$vyzva['ziada'].'/" id="zapas-'.$vyzva['id'].'-1-meno">'.SLS::set_clan_meno($vyzva['ziada_meno']).'</a> 
								</td>					
								<td width="100" align="center" >
									<a href="'.SLS::cesta(5).$vyzva['prijal'].'/" id="zapas-'.$vyzva['id'].'-2-meno">'.SLS::set_clan_meno($vyzva['prijal_meno']).'</a> 
								</td>	
								<td width="50"align="center" >
									'.date("n.j. H:m", $vyzva['datum']).'
								</td>	
								<td class="cup_kurz" align="center" '.kurz_hover($vyzva['id'], 1).' id="zapas-'.$vyzva['id'].'-1-kurz">
									'.$vyzva['stavky_ziada'].'
								</td>		
								<td class="cup_kurz" align="center" '.kurz_hover($vyzva['id'], 2).' id="zapas-'.$vyzva['id'].'-2-kurz">
									'.$vyzva['stavky_prijal'].'
								</td>					
								<td width="80" align="center" >
									'.$vyzva['mapa'].'	
								</td>
							</tr>
						';
				}
			} else {
				while($vyzva=mysql_fetch_assoc($sql_vyzva)) 
				{ 
						echo '
							<tr>	
								<td class="cup_riadok" width="100" align="center" >
									<a href="'.SLS::cesta(5).$vyzva['ziada'].'/">'.SLS::set_clan_meno($vyzva['ziada_meno']).'</a> 
								</td>					
								<td class="cup_riadok" width="100" align="center" >
									<a href="'.SLS::cesta(5).$vyzva['prijal'].'/">'.SLS::set_clan_meno($vyzva['prijal_meno']).'</a> 
								</td>	
								<td class="cup_riadok" width="100" style="color:#999999;" align="center" >
									'.date("n.j. H:m", $vyzva['datum']).'
								</td>					
								<td class="cup_riadok" style="color:#999999;" width="80" align="center" >
									'.$vyzva['mapa'].'	
								</td>
							</tr>
						';
				}
			}	
		}	else {
			echo '<tr>
					<td class="cup_riadok" width="40" align="center" colspan="6" >
						<em>'.SLS::sprava('zapasy_najblizsie').'</em>
					</td>
				</tr>
				';	
		}
		echo '</table>';
		echo SLS::set_zoznam( $sql_pocet);
					
	if( SLS::$user['clan_id'] == true)
	{	
		echo '	
			<br>
			<br>
			<br>
			<table class="cup_body" width="540" align="center" cellpadding="0" cellspacing="0" >	
				<tr>
					<th class="cup_nazov" colspan="4"> Najbli&#382;&scaron;ie z&aacute;pasy tvojho clanu: </th>
				</tr>';
		
		@$sql_vyzva = SLS::mysql_dbquery("SELECT * FROM `phpbanlist`.`acp_vyzva` c
									LEFT JOIN ( SELECT id as ziada_id, meno as ziada_meno FROM `phpbanlist`.`acp_clans` GROUP BY id ) h
										ON c.ziada = h.ziada_id								
									LEFT JOIN ( SELECT id as prijal_id, meno as prijal_meno FROM `phpbanlist`.`acp_clans` GROUP BY id ) f
										ON c.prijal = f.prijal_id									
									WHERE 
										(ziada ='".SLS::$user['clan_id']."' OR prijal ='".SLS::$user['clan_id']."') 
										AND prijal IS NOT NULL AND datum > '".time()."' ORDER BY datum");		
		
		if( @mysql_num_rows($sql_vyzva) ) 
		{											
			while($vyzva=mysql_fetch_assoc($sql_vyzva)) 
			{ 
					/*@$sql_clan=mysql_query("SELECT meno FROM `phpbanlist`.`acp_clans` WHERE id ='".$vyzva['ziada']."'");
					$clan_a=mysql_fetch_assoc($sql_clan);				
					@$sql_clan=mysql_query("SELECT meno FROM `phpbanlist`.`acp_clans` WHERE id ='".$vyzva['prijal']."'");
					$clan_b=mysql_fetch_assoc($sql_clan);*/
					echo '
						<tr>	
							<td class="cup_riadok" width="100" align="center" >
								<a href="'.SLS::cesta(5).$vyzva['ziada'].'/">'.SLS::set_clan_meno($vyzva['ziada_meno']).'</a> 
							</td>					
							<td class="cup_riadok" width="100" align="center" >
								<a href="'.SLS::cesta(5).$vyzva['prijal'].'/">'.SLS::set_clan_meno($vyzva['prijal_meno']).'</a> 
							</td>	
							<td class="cup_riadok" width="80" style="color:#999999;" align="center" >
								'.$vyzva['datum'].'	o '.$vyzva['hodina'].'hod
							</td>					
							<td class="cup_riadok" style="color:#999999;" width="80" align="center" >
								'.$vyzva['mapa'].'	
							</td>
						</tr>
					';
			} 
		}	else {
			echo '<tr>
					<td class="cup_riadok" width="40" align="center" colspan="4" >
						<em>'.SLS::sprava('zapasy_najblizsie').'</em>
					</td>
				</tr>
				';	
		}	
		echo'</table>';
	}	
	echo '</div><div align="center" class="cup_credits" ><br>&copy; Powered by Seky`s Liga System v'.SLS::verzia.'</div>';	
	
// 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++?>