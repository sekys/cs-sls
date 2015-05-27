<? // 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++
if(!$page) { header("Location: ../index.php"); exit; }
	if(SLS::is_hrac() ) {
		if( SLS::ma_clan() ) { // ak ma uz clan							
			if( SLS::is_access(CLAN_LEADER) or SLS::is_access(CLAN_ZASTUPCA)) {														
					
				// Vsetko je uplne v poriadku ziadn hack ,je prihlaseny a ma prava	
				if( SLS::is_pocet_ok() ) {											
								
					if(is_numeric($_GET['p1'])) {
						@$sql = SLS::mysql_dbquery("SELECT * FROM `phpbanlist`.`acp_vyzva` WHERE id = '".SLS::mysql_vstup($_GET['p1'])."'");
					} elseif(SLS::is_adresa($p1, $p2, $p3)) {				
						@$sql = SLS::mysql_dbquery("SELECT * FROM `phpbanlist`.`acp_vyzva` WHERE 
												datum = '".SLS::mysql_vstup($p2)."' AND 
												server = '".SLS::mysql_vstup($p3)."'");					
					}
					if(@mysql_num_rows($sql))
					{									
						$vyzva = mysql_fetch_assoc($sql);							
						if( !SLS::is_prijata($vyzva['prijal']) ) //neje prijata
						{
							if(! SLS::is_vlastna($vyzva['ziada']) ) //vlastnu vyzvu
							{
								if( !SLS::is_sukromna($vyzva['sukromna']) )		 // sukromna ???
								{
									// Zisti viac o clanoch
									@$sql = SLS::mysql_dbquery("SELECT id, meno, avatar FROM `phpbanlist`.`acp_clans` WHERE id ='".$vyzva['ziada']."'");
									$ziada_clan = mysql_fetch_assoc($sql);
																
									@$sql_clan = SLS::mysql_dbquery("SELECT id, meno, avatar FROM `phpbanlist`.`acp_clans` WHERE id = '".SLS::$user['clan_id']."'");
									$prijma_clan = mysql_fetch_assoc($sql_clan);
																							
											
										// Data do spravy
											$data='';
											$data[] = array	(
															'',
															$vyzva['datum'],
															false,
															$vyzva['mapa']
															);			
											$data[] = array	(
															$prijma_clan['id'],
															SLS::mysql_vystup($prijma_clan['meno']),
															SLS::set_avatar_html($prijma_clan["avatar"]),
															SLS::set_rank_html( $prijma_clan['id'] ),
															);		
											$data[] = array	(
															$ziada_clan['id'],
															SLS::mysql_vystup($ziada_clan['meno']),
															SLS::set_avatar_html($ziada_clan["avatar"]),
															SLS::set_rank_html( $ziada_clan['id'] ),
															);
									$post = $_POST['vyzva' ];
									// Ak je sukromna ma vacsie moznosti
									if($vyzva['sukromna'] and is_numeric($_GET['p1']))
									{
										// Sukromne sa nesmu posielat s datumom ale len ID
										$post = true;

										if($_GET['p2'] == true)	{
											$post = false;
											$vyzva_pokracovat = true;
											SLS::cup_log(-1, 29, SLS::$user['clan_id'], $vyzva['ziada']);
											echo SLS::get_spravu( 'V&yacute;zva odmietnut&aacute;' );
											SLS::web_posta( SLS::get_najdi_leadera($vyzva['ziada']), 
															'<div  class="cup_body" align="center">	
																<div align="center" style="background-color: #fff;color:#000000;">
																<br><br>'.SLS::mysql_vystup($ziada_clan['meno']).' odmietol v&yacute;zvu<br><br>
																</div>
															</div>', 
															'V&yacute;zva odmietnut&aacute;');
											@SLS::mysql_dbquery("DELETE FROM `phpbanlist`.`acp_vyzva` WHERE `id` = '".$vyzva['id']."'");
										}
									}
									
									// Akcia			
									if($post)
									{
										SLS::cup_log(-1, 28, SLS::$user['clan_id'], $vyzva['ziada']);
										// Nastavy vyzvu za obsadenu
										@$sql = SLS::mysql_dbquery("UPDATE `phpbanlist`.`acp_vyzva` SET `prijal` = '".SLS::$user['clan_id']."' WHERE id = '".$vyzva['id']."'");
										if($sql) {
											echo SLS::get_spravu(SLS::sprava('vyzva_ok'));
											vytvor_kurz($vyzva['ziada'], SLS::$user['clan_id'], $vyzva['id']);
																																		
										// Jednotlive odosielanie sprav, SUPERY									
											$data[0][0] = 'V&yacute;zvu prijal '.SLS::mysql_vystup($prijma_clan['meno']).' clan';

											@$sql = SLS::mysql_dbquery("SELECT user_id, cs_heslo FROM `cstrike`.`fusion_users` WHERE clan_id ='".$vyzva['ziada']."'");
											while($temp = mysql_fetch_assoc($sql))
											{
												$data[0][5] = 'Server: '.SLS::$server[ $vyzva['server'] ][1].'<br>'.SLS::$server[ $vyzva['server'] ][0].'<br>'.SLS::sprava('zapas_info');
												$data[0][5] .= '<br><br>Do konzole pred pripojen&iacute;m zadaj:<br><span style="color:red;">'.SLS::sprava('vyzva_heslo').''.$temp['cs_heslo'].'</span><br><br>';
												SLS::web_posta($temp['user_id'],SLS::set_zapas($data), 'Z&aacute;pas');
											}
											
										// SOPULUHRACI CLAN LEADERA																				
											$data[0][0] = "Tvoj clan sa zapojil do bitvy s ".SLS::mysql_vystup($ziada_clan['meno']);;

											@$sql = SLS::mysql_dbquery("SELECT user_id, cs_heslo FROM `cstrike`.`fusion_users` WHERE clan_id ='".SLS::$user['clan_id']."'");
											while($temp = mysql_fetch_assoc($sql))
											{
												$data[0][5] = 'Server: '.SLS::$server[ $vyzva['server'] ][1].'<br>'.SLS::$server[ $vyzva['server'] ][0].'<br>'.SLS::sprava('zapas_info');
												$data[0][5] .= '<br><br>Do konzole pred pripojen&iacute;m zadaj:<br><span style="color:red;">'.SLS::sprava('vyzva_heslo').''.$temp['cs_heslo'].'</span><br><br>';
												SLS::web_posta($temp['user_id'], SLS::set_zapas($data), 'Z&aacute;pas');
											}
										}	
									} elseif($vyzva_pokracovat == false) {
										// Formular ak nieje sukromna a overujeme ....
										echo '
										<div class="cup_body" align="center">
												
												<div>
													'.SLS::set_zapas($data).'
													<br>
													Naozaj chce&scaron; prija&#357; v&yacute;zvu od '.SLS::mysql_vystup($ziada_clan['meno']).'?
													<br><br>
													<form action="'.SLS::adresa_na_seba().'" method="post">
															<input name="vyzva" type="hidden" value="1" />
															<input type="image" src="'.SLS::$adresy[3].'tlacitko_ano.gif" title="Ano" name="submit" value="1" >
															&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
															<a href="/"><img src="'.SLS::$adresy[3].'tlacitko_ne.gif" border="0" title="Odmietnu&#357; z&aacute;pas" ></a>
													</form>
												</div>	
											<div >
											'.SLS::get_spravu("V&yacute;zvu m&ocirc;&#382;e&scaron;  24 hod&iacute;n<br>pred z&aacute;pasom zru&scaron;i&#357; bez<br>potrestania.").'
											<div align="center" class="cup_credits" ><br>&copy; Powered by Seky`s Liga System v'.SLS::verzia.'</div>
											</div>
										</div>';
									}	
							
		

		
								}
							} 							
						} 	
					} else {	
						echo SLS::get_spravu(SLS::sprava('vyzva_no'));
					}		
					}	
				
			} else {
					echo SLS::get_spravu('hodnost_nema', 1);
			}
		}
	}	

// Vytvare kurz + addon
function vytvor_kurz($ziada, $prijal, $id)	
{
	// Na kazdy clan
	
	$clan[] = $ziada; 
	$clan[] = $prijal; 
	
	for($i=0; $i < 2; $i++)
	{
		$clan[$i] = SLS::get_rank($clan[$i]);	
		$clan[$i] = 1.0 + 0.01 * ( $clan[$i] -1 );	// postupnost 	1.0 min
		$clan[$i] = round($clan[$i], 2);
	}
	@mysql_query("INSERT INTO `cstrike`.`kurzy` 
					(`id`, `stavky_ziada`, `stavky_prijal`)
				VALUES ('".$id."', '".$clan[0]."', '".$clan[1]."')");
}
// 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++ ?>