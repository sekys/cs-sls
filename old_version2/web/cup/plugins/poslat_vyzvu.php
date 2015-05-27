<? // 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++
if(!$page) { header("Location: ../index.php"); exit; }

	if(SLS::is_hrac() ) {
		if( SLS::ma_clan() ) { // ak ma uz clan		
			$id = $_GET['p1']; 
			if(SLS::is_udaj($id)) {
				if( SLS::is_access(CLAN_LEADER) or SLS::is_access(CLAN_ZASTUPCA))
				{
						@$sql_clan = SLS::mysql_dbquery("SELECT id, meno, avatar FROM `phpbanlist`.`acp_clans` WHERE id = '".SLS::$user['clan_id']."'");
						if( SLS::is_clan_exist($sql_clan) ) 	
						{
							$prijma_clan = mysql_fetch_assoc($sql_clan);
							if( $id === SLS::$user['clan_id'] )
							{
								echo SLS::get_spravu(SLS::sprava('vyzva_vlastny'),1);
							} else {
							if( SLS::is_pocet_ok() ) 
							{		
								// Stranka
								@$sql_clan = SLS::mysql_dbquery("SELECT id, meno, avatar FROM `phpbanlist`.`acp_clans` WHERE id = '".$id."'");
								$super_clan = mysql_fetch_assoc($sql_clan);						
								
									// Clan A
										$avatar_A =  SLS::set_avatar_html($prijma_clan["avatar"]);
										$rank_A = SLS::set_rank_html($prijma_clan['id']);
									// Clan B				
										$avatar_B = SLS::set_avatar_html(SLS::get_rank($super_clan["avatar"])); 
										$rank_B = SLS::set_rank_html( SLS::get_rank($super_clan['id']));
			//	============ akcia =========================		
								
								if($_POST['datum']== true)
								{																																																																		
									$cas = SLS::get_kontrola_vyzvy();
									if($cas)
									{							
										SLS::cup_log(-1, 34, $prijma_clan['id'], $super_clan['id']);
										@$sql = SLS::mysql_dbquery("INSERT INTO `phpbanlist`.`acp_vyzva` 
															(ziada, prijal, datum, mapa, sukromna, server) VALUES
															('".$prijma_clan['id']."', NULL,'".$cas."', '".SLS::mysql_vstup($_POST['mapa'])."', '".$super_clan['id']."', '".SLS::mysql_vstup($_POST['server'])."')");
										if( SLS::is_mysql_ok($sql) ) {																								
										
											// Data do spravy
												$data='';
												$data[] = array	(
													'Pri&scaron;la V&aacute;m v&yacute;zva na s&uacute;boj!',
													SLS::mysql_vstup($_POST['datum']),
													mysql_insert_id(),
													SLS::mysql_vstup($_POST['hodina']),
													SLS::mysql_vstup($_POST['mapa'])
																);			
												$data[] = array	(
													$prijma_clan['id'],
													SLS::mysql_vystup($prijma_clan['meno']),
													$avatar_A,
													$rank_A
																);		
												$data[] = array	(
													$super_clan['id'],
													SLS::mysql_vystup($super_clan['meno']),
													$avatar_B,
													$rank_B
																);																	
												
												SLS::web_posta( SLS::get_najdi_leadera($super_clan['id']), SLS::set_zapas($data) , 'V&yacute;zva');															
												echo SLS::get_spravu(SLS::sprava('vyzva_poslana'));
										}
									}
								}
		//	============ normalna stranka bez akcie =========================													
									echo '	<script type="text/javascript">
											$(function() {
													$("#vyzva_datum").datepicker();
												});
											</script>	
											<div class="cup_body" align="center">
												<img src="'.SLS::$adresy[3].'/logo.png" border="0" title="Logo">
												<br>
												<span style="color:white;font-weight: bold;"> </span>
												<br><br>
												<table width="400" class="cup_body" align="center" style="border: 1px; solid: #000;">
													<tr>
														<td width="100" align="right"><a href="'.SLS::cesta(5).$prijma_clan['id'].'/" ><img '.$avatar_A.' style="border: 1px;solid: #000" width="100" height="100"></a>
															<br>
															<a href="'.SLS::cesta(5).$prijma_clan['id'].'/" class="cup_form_text">'.SLS::mysql_vystup($prijma_clan['meno']).'</a>
															<br>
															Rank '.$rank_A.'
														</td>

														<td width="70" height="40" align="center">
															<img src="'.SLS::$adresy[3].'vs.png" border="0" >
														</td>
															<td width="100" align="left"><a href="'.SLS::cesta(5).$super_clan['id'].'/" ><img '.$avatar_B.' style="border: 1px;solid: #000" width="100" height="100"></a>
															<br>
															<a href="'.SLS::cesta(5).$super_clan['id'].'/" class="cup_form_text">'.SLS::mysql_vystup($super_clan['meno']).'</a>
															<br>
															Rank '.$rank_B.'
														</td>
													</tr>
												</table>
												<br>
												<div class="cup_potvrdenie" style="height:auto;" >
												<form action="'.SLS::adresa_na_seba().'" method="post" name="formular">';
											
											echo	'<b>Z&aacute;pas na:</b><br>';
										if(isset($_POST['server'])) {
											echo	"<a href=\"javascript:openCalendar('', 'formular', 'datum', 'date')\" >";
											echo	'<img alt="Datum" title="Kalendar" src="'.SLS::$adresy[3].'cup_datum.png" align="absmiddle" border="0"/></a>
													<input name="datum" id="vyzva_datum" style="width: 70px;" type="text" value="'.date("Y-m-d").'" />
													<select name="hodina">';
													//'.SLS::cyklus_vypis( SLS::$vyzva_hodina , "hodina").'	
													$s = $_POST['server'];
													$pocet = count(SLS::$vyzva_hodina[$s]);
													for($i=0; $i < $pocet; $i++)
													{										
														echo '<option value="'.SLS::$vyzva_hodina[$s][$i].'">'.SLS::$vyzva_hodina[$s][$i].'</option>';
													}													
											echo '	</select>	
													<br>
													<select name="mapa">';
													$pocet = count(SLS::$vyzva_mapa);
													for($i=0; $i < $pocet; $i++)
													{										
														echo '<option value="'.SLS::$vyzva_mapa[$i].'">'.SLS::$vyzva_mapa[$i].'</option>';
													}	
											echo	'</select>
													<input name="server" type="hidden" value="'.$s.'" />
													<br>'.SLS::$server[$_POST['server']][0];;
										} else {	
											echo	'<br>
													<select name="server">';
													$pocet = count(SLS::$server);
													for($i=0; $i < $pocet; $i++)
													{										
														echo '<option value="'.$i.'">'.SLS::$server[$i][0].'</option>';
													}	
													echo '</select>';
										}			
											echo	'<br>	
														<input type="image" src="'.SLS::$adresy[3].'tlacitko_ano.gif" title="Prija&#357; z&aacute;pas" name="potvrdit" value="potvrdit">
														&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
														<a href="/" ><img src="'.SLS::$adresy[3].'tlacitko_ne.gif" border="0" title="Odmietnu&#357; z&aacute;pas" ></a></div>
												</form>	
												<br>
												</div>												
											</div>
											<div align="center" class="cup_credits" ><br>&copy; Powered by Seky`s Liga System v'.SLS::verzia.'</div>';	
							}
							}		
						} 
							
				} else {
					echo SLS::get_spravu(SLS::sprava('hodnost_nema'), 1);
				}
			}
		}
	}

// 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++ ?>