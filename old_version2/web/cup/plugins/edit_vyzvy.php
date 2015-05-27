<? // 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++
if(!$page) { header("Location: ../index.php"); exit; }
$mapy = SLS::$adresy[0]."styles/maps/";	// mapy


// prepis CSS
echo '<style type="text/css">
<!--
.cup_riadok {
	padding:0px;
}
-->
</style>';

// Ak je vo fusione prihlaseny,tak ma id
	if( SLS::is_hrac()) {
		if( SLS::ma_clan()) {		
			if( SLS::is_access(CLAN_LEADER) or SLS::is_access(CLAN_ZASTUPCA) ) 
			{		
			// Add
				if( isset($_POST['datum']))
				{
					if( SLS::is_pocet_ok() )
					{
						$cas = SLS::get_kontrola_vyzvy();
						if( $cas )
						{	
							@SLS::mysql_dbquery("INSERT INTO `phpbanlist`.`acp_vyzva` 
										(ziada, prijal, datum, mapa, sukromna, server) VALUES
										('".SLS::$user['clan_id']."', NULL, '".$cas."', '".SLS::mysql_vstup($_POST['mapa'])."', '0', '".SLS::mysql_vstup($_POST['server'])."')"
										);
						}
					}
				}
			// Vyzvy
					@$sql_vyzva=SLS::mysql_dbquery("SELECT * FROM `phpbanlist`.`acp_vyzva` WHERE ziada ='".SLS::$user['clan_id']."' or prijal ='".SLS::$user['clan_id']."' ORDER BY datum desc");
					$pocet = @mysql_num_rows($sql_vyzva);																			
					echo '<div class="cup_body" align="center">';	
			// zoznam a vypis			
							while($vyzva = mysql_fetch_assoc($sql_vyzva))
							{											
							// Delete
								if(isset($_POST['vyzva_del_'.$vyzva["id"]]))
								{
									if($vyzva['prijal'])
									{
										// Pocitame
										$super_id = (SLS::$user['clan_id'] == $vyzva['ziada']) ? $vyzva['prijal'] : $vyzva['ziada'];
										$vzdava_id = (SLS::$user['clan_id'] == $vyzva['ziada']) ? $vyzva['ziada'] : $vyzva['prijal'];
										
										//Kontumacia
										$cas = time();
										if( ($vyzva['datum'] < $cas+60*60*2) and $vyzva['datum'] > $cas)			// trestame
										{
											SLS::cup_log(-1, 5, $vzdava_id, $super_id, 1);
											$x = SLS::mysql_count("SELECT COUNT(typ) as pocet FROM `cstrike`.`web2_logs` WHERE kat='-1' AND typ='5' AND kto='".$vzdava_id."' AND int='1'");
											if(SLS::$max_zruseni <= $x)
											{
												@SLS::mysql_dbquery("UPDATE `phpbanlist`.`acp_clans` SET `bodov` = '0' WHERE `id` ='".$vzdava_id."'");		
												@mysql_query("UPDATE `cstrike`.`web2_logs` SET `int` = '0' WHERE kat='-1' AND `typ='5' AND kto='".$vzdava_id."' AND int='1'");		
												echo SLS::get_spravu('V&yacute;zva zmazan&aacute;<br><br><br>Tvoj clan bol potrestan&yacute; a body vynulovan&eacute;.<br>D&ocirc;vod : Zmazovanie z&aacute;pasov.');
												SLS::cup_log(-1, 24, $vzdava_id, 1);
											} else {
												$x = SLS::$max_zruseni - $x;
												echo SLS::get_spravu('V&yacute;zva zmazan&aacute;<br>m&aacute;&scaron; e&scaron;te '.$x.' &scaron;ance.');
											}
										} else {					// bez trestu normal
											SLS::cup_log(-1, 5, $vzdava_id, $super_id, 0);
											echo SLS::get_spravu('V&yacute;zva zmazan&aacute;, bez trestu.');
										}
										
										/*			Bodove trestanie -> bolo zle
										
										if( SLS::$datum_je_stary($vyzva['datum'], $vyzva['hodina']), -1)
										{
											$bodov = 300 / cup_rank($vzdava_id);
											echo SLS::get_spravu('V&yacute;zva zmazan&aacute; !<br>');
											@mysql_query("UPDATE `phpbanlist`.`acp_clans` SET `bodov` = bodov + ".$bodov." WHERE `acp_clans`.`id` =".$super_id."");		
											function vypocet_bodov($super_id)
											{
												$bodov = SLSpocet_kol*10 / SLSget_rank($super_id);
												return $bodov;
											}											
										} else {
											echo SLS::get_spravu('Star&aacute; v&yacute;zva zmazan&aacute; ! ');
										}
										*/
										
										// WEB spravy.....								
										SLS::team_posta($vzdava_id, '													
														<div class="cup_body" align="center">	
															<div align="center" style="background-color: #fff;color:#000000;">
																	<img src="'.SLS::$adresy[3].'rip.png" alt="RIP" />
																	<br><br>
																		<strong>Z&aacute;pas na '.date("n.j. H:m", $vyzva['datum']).'hod bol zru&scaron;en&yacute; ! <br>
																		Hr&aacute;&#269;om: '.SLS::mysql_vystup(SLS::$user['user_name']).'</strong>
																	<br><br><br>
															</div>
														</div>', 
												'Zru&scaron;enie z&aacute;pasu');																																								
										SLS::team_posta($super_id, '													
														<div class="cup_body" align="center">	
															<div align="center" style="background-color: #fff;color:#000000;">
																	<img src="'.SLS::$adresy[3].'rip.png" alt="RIP" />
																	<br><br>
																		<strong>Z&aacute;pas na '.date("n.j. H:m", $vyzva['datum']).'hod bol zru&scaron;en&yacute; ! <br>
																		S&uacute;per sa vzdal ! 
																		<br>
																		</strong>
																	<br><br><br>
															</div>
														</div>', 
												'Zru&scaron;enie z&aacute;pasu');																	
									} else {
										SLS::team_posta($vyzva['ziada'], '													
														<div class="cup_body" align="center">	
															<div align="center" style="background-color: #fff;color:#000000;">
																	<img src="'.SLS::$adresy[3].'rip.png" alt="RIP" />
																	<br><br>
																		<strong>Z&aacute;pas na '.date("n.j. H:m", $vyzva['datum']).'hod bol zru&scaron;en&yacute; ! <br>
																		Hr&aacute;&#269;om: '.SLS::mysql_vystup(SLS::$user['user_name']).'</strong>
																	<br><br><br>
															</div>
														</div>', 
												'Z&aacute;pas zru&scaron;en&yacute;');
										echo SLS::get_spravu('V&yacute;zva zmazan&aacute; a hr&aacute;&#269;i boli obozn&aacute;men&yacute;');		
									}
									@SLS::mysql_dbquery("DELETE FROM `phpbanlist`.`acp_vyzva` WHERE id ='".$vyzva['id']."'");
								} else {
					// Ak nic  zoznam																												
									@$sql_ziada = SLS::mysql_dbquery("SELECT meno, bodov FROM `phpbanlist`.`acp_clans` WHERE id ='".$vyzva['ziada']."'");
									$ziada_clan = mysql_fetch_assoc($sql_ziada);
																		
									if($vyzva['prijal'] == true)
									{
										@$sql_prijal=SLS::mysql_dbquery("SELECT meno, bodov FROM `phpbanlist`.`acp_clans` WHERE id ='".$vyzva['prijal']."'");
										$prijal_clan = mysql_fetch_assoc($sql_prijal);									
									} else {
										$prijal_clan['meno'] = '-';
										$prijal_clan['bodov'] = '-';
									}
									
									echo '
										<table class="cup_body" width="480" border="0" cellpadding="0" cellspacing="0">
											<tr>
												<td width="160" rowspan=5" class="cup_riadok"  align="center">
													<img src="'.$mapy.$vyzva['mapa'].'.jpg" alt="'.$vyzva['mapa'].'" width="160" height="120" border="0"  />
												</td>
												<td height="22" colspan="3" align="center" class="cup_nazov"> '.SLS::$server[ $vyzva['server'] ][0].' - '.$vyzva['mapa'].'</td>
											</tr>
											<tr>
												<td class="cup_riadok" width="70"  align="center">D&aacute;tum:</td>
												<td class="cup_riadok" width="250" cospan="2" height="25">'.date("n.j. H:m", $vyzva['datum']).'</td>
												<td class="cup_riadok" > </td>
											</tr>											
											<tr>
												<td class="cup_riadok" width="70"  align="center">&#381;iada:</td>
												<td class="cup_riadok" width="200" height="25"><a href="'.SLS::cesta(5).$vyzva['ziada'].'/">'.SLS::set_clan_meno($ziada_clan['meno']).'</a></td>
												<td class="cup_riadok" width="50" align="center">'.$ziada_clan['bodov'].'</td>
											</tr>
											<tr>
												<td class="cup_riadok" width="70"  align="center">Prijal:</td>
												<td class="cup_riadok" width="200" height="25"><a href="'.SLS::cesta(5).$vyzva['prijal'].'/">'.SLS::set_clan_meno($prijal_clan['meno']).'</a></td>
												<td class="cup_riadok" width="50" align="center">'.$prijal_clan['bodov'].'</td>
											</tr>
											<tr>
											<form action="'.SLS::adresa_na_seba().'" method="post">
												<td class="cup_riadok" align="center" colspan="3">
													<input name="vyzva_del_'.$vyzva["id"].'" type="hidden" value="1" />
													<input class="button" id="cup_button" type="submit" name="Submit" value="Zmaza&#357;">
												</td>
											</form>
										</tr>
										</table>';
								}	
							}	
														
						// pridat	
							if($pocet < SLS::$vyzvy )
							{					
								// upozornenie
								/*$x = SLS::mysql_count("SELECT COUNT(typ) as pocet FROM `cstrike`.`web2_logs` WHERE kat = '-1' AND typ='5' AND kto='".SLS::$user['clan_id']."' AND komu='1'");
								$x = SLS::$max_zruseni - $x;
								echo '
								<br><p align="center">
									Ak <strong>'.$x.'x</strong>  zru&scaron;i&scaron; v&yacute;zvu alebo nepr&iacute;de&scaron; na z&aacute;pas, vynuluj&uacute; sa ti v&scaron;etk&eacute; body !<br>
									V&yacute;zvu m&ocirc;&#382;e&scaron;  24 hod&iacute;n pred z&aacute;pasom zru&scaron;i&#357; bez potrestania.
								</p>								
								<br>*/
								echo '
									<script type="text/javascript">
										$(function() {
												$("#datum").datepicker();
											});
									</script>
									<form action="'.SLS::adresa_na_seba().'" method="post" name="formular">
										<table class="cup_body" width="480" border="0" cellpadding="0" cellspacing="0">
											<tr>
												<td width="160" rowspan=5" align="center" class="cup_riadok" >
													<img src="'.$mapy.'de_dust2.jpg" alt="Mapa" width="160" height="120" border="0"  />
												</td>
												<td height="22" colspan="3" align="center" class="cup_nazov"> Prida&#357; v&yacute;zvu </td>
											</tr>
											<tr>
												<td class="cup_riadok" width="70" align="center" >Server</td>
												<td class="cup_riadok" width="200" height="25"  colspan="2">';
												if(isset($_POST['server']) and is_numeric($_POST['server']))	 {
													echo SLS::$server[$_POST['server']][0];
												} else {
													echo '<select name="server">';
													$pocet = count(SLS::$server);
													for($i=0; $i < $pocet; $i++)
													{										
														echo '<option value="'.$i.'">'.SLS::$server[$i][0].'</option>';
													}	
													echo '</select>';
												}	
											echo	'	
												</td>
											</tr>		
											<tr>
												<td class="cup_riadok" width="70"  align="center" >D&aacute;tum:</td>
												<td class="cup_riadok" width="200" height="25" >';
												echo isset($_POST['server']) ? '<input name="datum" id="datum" type="text" value="'.date("Y-m-d").'">'.SLS::cyklus_vypis( SLS::$vyzva_hodina[$_POST['server']] , "hodina") : '&nbsp;';
										echo	'</td>
												<td class="cup_riadok"  width="50" align="center">';
											echo	isset($_POST['server']) ? "<a href=\"javascript:openCalendar('', 'formular', 'datum', 'date')\" >
													<img alt=\"Kalendar\" src=\"".SLS::$adresy[3]."cup_datum.png\" align=\"absmiddle\" title=\"Kalendar\" border=\"0\"/>										
												</a>" : "&nbsp;";
										echo	'</td>
											</tr>
											<tr>
												<td class="cup_riadok" width="70"  align="center">Mapa:</td>
												<td class="cup_riadok" width="200" height="25" cospan="2">';
													echo isset($_POST['server']) ? SLS::cyklus_vypis( SLS::$vyzva_mapa , "mapa") : '&nbsp;';
													echo isset($_POST['server']) ? '<input name="server" type="hidden" value="'.SLS::mysql_vstup($_POST['server']).'" />' : '';
										echo 	'</td>
												<td class="cup_riadok" width="10" ><input class="button" id="cup_button" type="submit" name="Submit" value="Prida&#357;"></td>
											</tr>
											</tr>
										</table>
									</form>';								
							} else {
								echo SLS::get_spravu(SLS::sprava('vyzvy') );
							}							
						echo'<div align="center" class="cup_credits" ><br>&copy; Powered by Seky`s Liga System v'.SLS::verzia.'</div>';
					echo '</div>';														
			} else {
				echo SLS::get_spravu(SLS::sprava('hodnost_nema'), 1);
			}
		} 
	}		
// 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++	?>