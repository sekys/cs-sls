<? // 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++

if(SLSUser::isPlayer() ) {
	if( SLSUser::MaClan() ) { // ak ma uz clan							
		if( SLSUser::isHodnost(SLSHodnost::LEADER) or SLSUser::isHodnost(SLSHodnost::ZASTUPCA)) {														
				
			// Vsetko je uplne v poriadku ziadn hack ,je prihlaseny a ma prava	
			if( SLSZapas::is_pocet_ok() ) {											
							
				if(is_numeric($_GET['p1'])) {
					@$sql = SLS::Query2("SELECT * FROM `phpbanlist`.`acp_vyzva` WHERE id = '".DB::Vstup($_GET['p1'])."'");
				} elseif(SLS::is_adresa($p1, $p2, $p3)) {				
					@$sql = SLS::Query2("SELECT * FROM `phpbanlist`.`acp_vyzva` WHERE 
											datum = '".DB::Vstup($p2)."' AND 
											server = '".DB::Vstup($p3)."'");					
				}
				if(@mysqli_num_rows($sql))
				{									
					$vyzva = mysqli_fetch_assoc($sql);							
					if( !SLS::is_prijata($vyzva['prijal']) ) //neje prijata
					{
						if(! SLS::is_vlastna($vyzva['ziada']) ) //vlastnu vyzvu
						{
							if( !SLS::Sukromna($vyzva['sukromna']) )		 // sukromna ???
							{
								// Zisti viac o clanoch
								@$sql = SLS::Query2("SELECT id, meno, avatar FROM `phpbanlist`.`acp_clans` WHERE id ='".$vyzva['ziada']."'");
								$ziada_clan = mysqli_fetch_assoc($sql);
															
								@$sql_clan = SLS::Query2("SELECT id, meno, avatar FROM `phpbanlist`.`acp_clans` WHERE id = '".SLSUser::$user['clan_id']."'");
								$prijma_clan = mysqli_fetch_assoc($sql_clan);
																						
										
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
														DB::Vystup($prijma_clan['meno']),
														SLSClan::Avatar($prijma_clan["avatar"]),
														SLSClan::ZoznamRank( $prijma_clan['id'] ),
														);		
										$data[] = array	(
														$ziada_clan['id'],
														DB::Vystup($ziada_clan['meno']),
														SLSClan::Avatar($ziada_clan["avatar"]),
														SLSClan::ZoznamRank( $ziada_clan['id'] ),
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
										SLS::Log(-1, 29, SLSUser::$user['clan_id'], $vyzva['ziada']);
										echo SLS::Msg( 'V&yacute;zva odmietnut&aacute;' );
										SLSUser::Posta( SLSClan::FindLeader($vyzva['ziada']), 
														'<div  class="cup_body" align="center">	
															<div align="center" style="background-color: #fff;color:#000000;">
															<br><br>'.DB::Vystup($ziada_clan['meno']).' odmietol v&yacute;zvu<br><br>
															</div>
														</div>', 
														'V&yacute;zva odmietnut&aacute;');
										@SLS::Query2("DELETE FROM `phpbanlist`.`acp_vyzva` WHERE `id` = '".$vyzva['id']."'");
									}
								}
								
								// Akcia			
								if($post)
								{
									SLS::Log(-1, 28, SLSUser::$user['clan_id'], $vyzva['ziada']);
									// Nastavy vyzvu za obsadenu
									@$sql = SLS::Query2("UPDATE `phpbanlist`.`acp_vyzva` SET `prijal` = '".SLSUser::$user['clan_id']."' WHERE id = '".$vyzva['id']."'");
									if($sql) {
										echo SLS::MsgL('vyzva_ok');
										vytvor_kurz($vyzva['ziada'], SLSUser::$user['clan_id'], $vyzva['id']);
																																	
									// Jednotlive odosielanie sprav, SUPERY									
										$data[0][0] = 'V&yacute;zvu prijal '.DB::Vystup($prijma_clan['meno']).' clan';

										@$sql = SLS::Query2("SELECT user_id, cs_heslo FROM `cstrike`.`fusion_users` WHERE clan_id ='".$vyzva['ziada']."'");
										while($temp = mysqli_fetch_assoc($sql))
										{
											$data[0][5] = 'Server: '.SLSZapas::$server[ $vyzva['server'] ][1].'<br>'.SLSZapas::$server[ $vyzva['server'] ][0].'<br>'.SLSLang::Msg('zapas_info');
											$data[0][5] .= '<br><br>Do konzole pred pripojen&iacute;m zadaj:<br><span style="color:red;">'.SLSLang::Msg('vyzva_heslo').''.$temp['cs_heslo'].'</span><br><br>';
											SLSUser::Posta($temp['user_id'],SLS::set_zapas($data), 'Z&aacute;pas');
										}
										
									// SOPULUHRACI CLAN LEADERA																				
										$data[0][0] = "Tvoj clan sa zapojil do bitvy s ".DB::Vystup($ziada_clan['meno']);;

										@$sql = SLS::Query2("SELECT user_id, cs_heslo FROM `cstrike`.`fusion_users` WHERE clan_id ='".SLSUser::$user['clan_id']."'");
										while($temp = mysqli_fetch_assoc($sql))
										{
											$data[0][5] = 'Server: '.SLSZapas::$server[ $vyzva['server'] ][1].'<br>'.SLSZapas::$server[ $vyzva['server'] ][0].'<br>'.SLSLang::Msg('zapas_info');
											$data[0][5] .= '<br><br>Do konzole pred pripojen&iacute;m zadaj:<br><span style="color:red;">'.SLSLang::Msg('vyzva_heslo').''.$temp['cs_heslo'].'</span><br><br>';
											SLSUser::Posta($temp['user_id'], SLS::set_zapas($data), 'Z&aacute;pas');
										}
									}	
								} elseif($vyzva_pokracovat == false) {
									// Formular ak nieje sukromna a overujeme ....
									echo '
									<div class="cup_body" align="center">
											
											<div>
												'.SLS::set_zapas($data).'
												<br>
												Naozaj chce&scaron; prija&#357; v&yacute;zvu od '.DB::Vystup($ziada_clan['meno']).'?
												<br><br>
												<form action="" method="post">
														<input name="vyzva" type="hidden" value="1" />
														<input type="image" src="'.SLS::$STYLE.'tlacitko_ano.gif" title="Ano" name="submit" value="1" >
														&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
														<a href="/"><img src="'.SLS::$STYLE.'tlacitko_ne.gif" border="0" title="Odmietnu&#357; z&aacute;pas" ></a>
												</form>
											</div>	
										<div >
										'.SLS::Msg("V&yacute;zvu m&ocirc;&#382;e&scaron;  24 hod&iacute;n<br>pred z&aacute;pasom zru&scaron;i&#357; bez<br>potrestania.").'
										<div align="center" class="cup_credits" ><br>&copy; Powered by Seky`s Liga System v'.SLS::verzia.'</div>
										</div>
									</div>';
								}	
						
	

	
							}
						} 							
					} 	
				} else {	
					echo SLS::MsgL('vyzva_no');
				}		
				}	
			
		} else {
				echo SLS::Msg('hodnost_nema', 1);
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
	$clan[$i] = SLSClan::Rank($clan[$i]);	
	$clan[$i] = 1.0 + 0.01 * ( $clan[$i] -1 );	// postupnost 	1.0 min
	$clan[$i] = round($clan[$i], 2);
}
@DB::Query("INSERT INTO `cstrike`.`kurzy` 
				(`id`, `stavky_ziada`, `stavky_prijal`)
			VALUES ('".$id."', '".$clan[0]."', '".$clan[1]."')");
}
// 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++ ?>