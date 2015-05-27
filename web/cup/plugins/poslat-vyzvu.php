<? // 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++


if(SLSUser::isPlayer() ) {
	if( SLSUser::MaClan() ) { // ak ma uz clan		
		$id = $_GET['p1']; 
		if(SLS::CheckInput($id)) {
			if( SLSUser::isHodnost(SLSHodnost::LEADER) or SLSUser::isHodnost(SLSHodnost::ZASTUPCA))
			{
					@$sql_clan = SLS::Query2("SELECT id, meno, avatar FROM `phpbanlist`.`acp_clans` WHERE id = '".SLSUser::$user['clan_id']."'");
					if( SLSClan::Exist($sql_clan) ) 	
					{
						$prijma_clan = mysqli_fetch_assoc($sql_clan);
						if( $id === SLSUser::$user['clan_id'] )
						{
							echo SLS::MsgL('vyzva_vlastny',1);
						} else {
						if( SLSZapas::is_pocet_ok() ) 
						{		
							// Stranka
							@$sql_clan = SLS::Query2("SELECT id, meno, avatar FROM `phpbanlist`.`acp_clans` WHERE id = '".$id."'");
							$super_clan = mysqli_fetch_assoc($sql_clan);						
							
								// Clan A
									$avatar_A =  SLSClan::Avatar($prijma_clan["avatar"]);
									$rank_A = SLSClan::ZoznamRank($prijma_clan['id']);
								// Clan B				
									$avatar_B = SLSClan::Avatar(SLSClan::Rank($super_clan["avatar"])); 
									$rank_B = SLSClan::ZoznamRank( SLSClan::Rank($super_clan['id']));
		//	============ akcia =========================		
							
							if($_POST['datum']== true)
							{																																																																		
								$cas = SLSZapas::PostVyzva();
								if($cas)
								{							
									SLS::Log(-1, 34, $prijma_clan['id'], $super_clan['id']);
									@$sql = SLS::Query2("INSERT INTO `phpbanlist`.`acp_vyzva` 
														(ziada, prijal, datum, mapa, sukromna, server) VALUES
														('".$prijma_clan['id']."', NULL,'".$cas."', '".DB::Vstup($_POST['mapa'])."', '".$super_clan['id']."', '".DB::Vstup($_POST['server'])."')");
									if( SLS::CheckMysql($sql) ) {																								
									
										// Data do spravy
											$data='';
											$data[] = array	(
												'Pri&scaron;la V&aacute;m v&yacute;zva na s&uacute;boj!',
												DB::Vstup($_POST['datum']),
												mysql_insert_id(),
												DB::Vstup($_POST['hodina']),
												DB::Vstup($_POST['mapa'])
															);			
											$data[] = array	(
												$prijma_clan['id'],
												DB::Vystup($prijma_clan['meno']),
												$avatar_A,
												$rank_A
															);		
											$data[] = array	(
												$super_clan['id'],
												DB::Vystup($super_clan['meno']),
												$avatar_B,
												$rank_B
															);																	
											
											SLSUser::Posta( SLSClan::FindLeader($super_clan['id']), SLS::set_zapas($data) , 'V&yacute;zva');															
											echo SLS::MsgL('vyzva_poslana');
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
											<img src="'.SLS::$STYLE.'/logo.png" border="0" title="Logo">
											<br>
											<span style="color:white;font-weight: bold;"> </span>
											<br><br>
											<table width="400" class="cup_body" align="center" style="border: 1px; solid: #000;">
												<tr>
													<td width="100" align="right"><a href="'.SLSPlugins::Adresa(5).$prijma_clan['id'].'/" ><img '.$avatar_A.' style="border: 1px;solid: #000" width="100" height="100"></a>
														<br>
														<a href="'.SLSPlugins::Adresa(5).$prijma_clan['id'].'/" class="cup_form_text">'.DB::Vystup($prijma_clan['meno']).'</a>
														<br>
														Rank '.$rank_A.'
													</td>

													<td width="70" height="40" align="center">
														<img src="'.SLS::$STYLE.'vs.png" border="0" >
													</td>
														<td width="100" align="left"><a href="'.SLSPlugins::Adresa(5).$super_clan['id'].'/" ><img '.$avatar_B.' style="border: 1px;solid: #000" width="100" height="100"></a>
														<br>
														<a href="'.SLSPlugins::Adresa(5).$super_clan['id'].'/" class="cup_form_text">'.DB::Vystup($super_clan['meno']).'</a>
														<br>
														Rank '.$rank_B.'
													</td>
												</tr>
											</table>
											<br>
											<div class="cup_potvrdenie" style="height:auto;" >
											<form action="" method="post" name="formular">';
										
										echo	'<b>Z&aacute;pas na:</b><br>';
									if(isset($_POST['server'])) {
										echo	"<a href=\"javascript:openCalendar('', 'formular', 'datum', 'date')\" >";
										echo	'<img alt="Datum" title="Kalendar" src="'.SLS::$STYLE.'cup_datum.png" align="absmiddle" border="0"/></a>
												<input name="datum" id="vyzva_datum" style="width: 70px;" type="text" value="'.date("Y-m-d").'" />
												<select name="hodina">';
												$vyzva_hodina = SLSZapas::GetTimeList();
												$s = $_POST['server'];
												$pocet = count($vyzva_hodina[$s]);
												for($i=0; $i < $pocet; $i++)
												{										
													echo '<option value="'.$vyzva_hodina[$s][$i].'">'.$vyzva_hodina[$s][$i].'</option>';
												}
												unset($vyzva_hodina);
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
												<br>'.SLSZapas::$server[$_POST['server']][0];;
									} else {	
										echo	'<br>
												<select name="server">';
												$pocet = count(SLSZapas::$server);
												for($i=0; $i < $pocet; $i++)
												{										
													echo '<option value="'.$i.'">'.SLSZapas::$server[$i][0].'</option>';
												}	
												echo '</select>';
									}			
										echo	'<br>	
													<input type="image" src="'.SLS::$STYLE.'tlacitko_ano.gif" title="Prija&#357; z&aacute;pas" name="potvrdit" value="potvrdit">
													&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
													<a href="/" ><img src="'.SLS::$STYLE.'tlacitko_ne.gif" border="0" title="Odmietnu&#357; z&aacute;pas" ></a></div>
											</form>	
											<br>
											</div>												
										</div>
										<div align="center" class="cup_credits" ><br>&copy; Powered by Seky`s Liga System v'.SLS::verzia.'</div>';	
						}
						}		
					} 
						
			} else {
				echo SLS::MsgL('hodnost_nema'), 1);
			}
		}
	}
}

// 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++ ?>