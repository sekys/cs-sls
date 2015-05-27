<? // 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++

	
if(is_numeric($_GET['p1'])) {
	@$sql_zapas = SLS::Query2("SELECT * FROM `phpbanlist`.`cup_zapas` WHERE id = '".DB::Vstup($_GET['p1'])."'");
	@$zapas = mysqli_fetch_assoc($sql_zapas);
} elseif(SLS::is_adresa($p1, $p2, $p3)) {
	@$sql_zapas = SLS::Query2("SELECT * FROM `phpbanlist`.`cup_zapas` WHERE 
								datum = '".DB::Vstup($p2)."' AND 
								server = '".DB::Vstup($p3)."'");
	@$zapas = mysqli_fetch_assoc($sql_zapas);							
											
}																										
		if( $zapas['id']) {																					
	// Info						
			echo '
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
			
			if($ziada['meno'])
			{
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

			if($zapas['ct_team'])
			{
				$team = explode(SLSZapas::PARSER2, $zapas['ct_team']);
			}
			
			$pocet = count($team);
			if($pocet) { $pocet--; }
			
			if( $ziada['meno'] )
			{
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
	// SPE team 
	
			$temp  = '';
			$pocet = 0;
			
			if($zapas['spe_team'])
			{
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
					  
				echo'<tr><td colspan="5" height="20">&nbsp;</td></tr>
					<tr>
						<td colspan="5" height="20" class="cup_zapas_text_normal" >Stiahnu&#357; <a class="cup_zapas_text_normal" href="'.SLSPlugins::Adresa(19).$zapas['id'].'/">DEMO</a> - <a href="/cup/admin/zapas/'.$zapas['id'].'/">Admin</a></td>
					</tr>
					<tr><td colspan="5" height="20" class="cup_zapas_text_normal" >Status: '.SLS::get_dovod_zapasu($zapas['status']).'</td></tr>
				</table>
			</div>
		<div align="center" class="cup_credits" ><br>&copy; Powered by Seky`s Liga System v'.SLS::verzia.'</div>			
		<br>
		<br>
		<br>';
				
			// Komentare
			if (true) {
				include INCLUDES."comments_include.php";
				mysql_select_db('cstrike');
				showcomments("Z", 0, 0, $zapas['id'], SLSPlugins::Adresa_na_seba());
			}
			
		} else {
			echo SLS::Msg('Z&aacute;pas nen&aacute;jden&yacute;.',1);
		}			
// 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++	?>