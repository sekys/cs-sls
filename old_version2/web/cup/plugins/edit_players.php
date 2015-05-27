<? // 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++
if(!$page) { header("Location: ../index.php"); exit; }

	if(SLS::is_hrac() ) {
		if( SLS::ma_clan() ) { // ak ma uz clan	
			if( SLS::is_access(CLAN_LEADER) or SLS::is_access(CLAN_ZASTUPCA) or SLS::is_access(HRAC_VEDUCI)) 	
			{	
				@$sql_clan=SLS::mysql_dbquery("SELECT volne FROM `phpbanlist`.`acp_clans` WHERE id = '".SLS::$user['clan_id']."'");
				
				if( SLS::is_clan_exist($sql_clan)) {	
					$clan = mysql_fetch_assoc($sql_clan);			
						echo SLS::get_spravu('Spravovanie &#269;lenov clanu,<br>h&#318;adanie hr&aacute;&#269;ov,<br>posielanie pozv&aacute;nok.');
								// Header
								echo '
								<div class="cup_body" align="center">
									<table class="cup_body" width="520" align="center" cellpadding="0" cellspacing="0">
										<tr>
											<th class="cup_nazov" > # </th>
											<th class="cup_nazov" > Hern&eacute; meno </th>
											<th class="cup_nazov" > Web meno </th>
											<th class="cup_nazov" > Hodnos&#357; </th>
											<th class="cup_nazov" > Vyhodi&#357; </th>
										</tr>
									<form action="'.SLS::adresa_na_seba().'" method="post">';
								
								
								// Hraci v clanu
									@$sql_users=SLS::mysql_dbquery("SELECT user_id, user_name, cs_meno, clan_hodnost FROM `cstrike`.`fusion_users` WHERE clan_id ='".SLS::$user['clan_id']."' ORDER BY clan_hodnost");
									while($row = mysql_fetch_assoc($sql_users))
									{
										// Akcia
										if($_POST['delete_'.$row['user_id'].''] == true)
										{
											if( $row['clan_hodnost'] !== CLAN_LEADER)
											{
												if( $row['clan_hodnost'] === CLAN_ZASTUPCA and  SLS::$user['clan_hodnost'] === HRAC_VEDUCI)
												{
													//nic
												} else {
													@SLS::mysql_dbquery("UPDATE `cstrike`.`fusion_users` SET `clan_id` = '' , `clan_hodnost` = '".HRAC."' WHERE `user_id` = '".$row['user_id']."'");
													SLS::cup_log(-1, 2, SLS::$user['clan_id'], $row['user_id'], SLS::$user['user_id']);
														SLS::team_posta( SLS::$user['clan_id'], '													
																	<div  class="cup_body" align="center">	
																		<div align="center" style="background-color: #fff;color:#000000;">
																			<img src="'.SLS::$adresy[3].'player_logo.jpg" alt="Logo" width="375" height="250" />
																			<br><br>
																			<strong>'.SLS::mysql_vystup(SLS::$user['user_name']).' vyhodil '.SLS::mysql_vystup($row['user_name']).' z clanu.</strong>
																			<br><br><br><br>
																		</div>
																	</div>',  'Hr&aacute;&#269; vyhoden&yacute;');
														SLS::web_posta($row['user_id'], '
														
															<div  class="cup_body" align="center">	
																<div align="center" style="background-color: #fff;color:#000000;">
																<img src="'.SLS::$adresy[3].'player_logo.jpg" alt="Logo" width="375" height="250" />
																<br><br>
																	<strong>Bol si vykopnut&yacute; z clanu !<br>
																	Hr&aacute;&#269;om: '.SLS::mysql_vystup(SLS::$user['user_name']).'</strong>
																<br><br><br>
																</div>
															</div>													
															', 'Clan');
												}
											}
										} else {
											// update
											$update = $_POST['update_'.$row['user_id'].''];
											if( $update !== $row['clan_hodnost'] ) // ak zmenene
											{
												if( is_numeric( $update) )	// ak cislo
												{
													if( $row['clan_hodnost'] !== CLAN_LEADER)
													{
														if( $update === CLAN_ZASTUPCA and SLS::is_access(HRAC_VEDUCI))
														{
															// nic aby sa nepovysil
														} else {	
															$row['clan_hodnost'] = SLS::mysql_vstup($update); // prepis 
															@SLS::mysql_dbquery("UPDATE `cstrike`.`fusion_users` SET `clan_hodnost` = '".$row['clan_hodnost']."' WHERE `user_id` = '".$row['user_id']."'");																									
															SLS::cup_log(-1, 33, SLS::$user['clan_id'], $row['user_id'], SLS::$user['user_id']);
															
																SLS::web_posta($row['user_id'], '													
																<div  class="cup_body" align="center">	
																	<div align="center" style="background-color: #fff;color:#000000;">
																	<img src="'.SLS::$adresy[3].'player_logo.jpg" alt="Logo" width="375" height="250" />
																	<br><br>
																		<strong>Dostal si nov&uacute; hodnos&#357;! </strong>
																	<br><br><br><br>
																	</div>
																</div>													
																', 'Clan');
														}
													}
												}									
											}
																		
											// Vypis
											echo '<tr> 
														<td class="cup_riadok" style="padding: 3px;" width="30" align="center">
															<a href="'.SLS::$aplikacia.'messages.php?msg_send='.$row['user_id'].'">
																<img src="'.SLS::$adresy[3].'sms.png" alt="Web Po&scaron;ta" title="Web Po&scaron;ta hr&aacute;&#269;a" border="0" align="absmiddle">
															</a>
														</td>
														<td class="cup_riadok" style="padding: 3px;" width="110" align="center">
															<a href="'.SLS::$aplikacia.'psychostats/index.php?q='.SLS::mysql_vystup($row['cs_meno']).'">
																'.SLS::mysql_vystup($row['cs_meno']).'
															</a>										
														</td>										
														<td class="cup_riadok" style="padding: 3px;" width="80" align="center">
															<a href="'.SLS::$aplikacia.'profile.php?lookup='.$row['user_id'].'">
																'.$row['user_name'].'
															</a>										
														</td>
														<td class="cup_riadok" style="padding: 3px;" width="100" align="center">';
													if( $row['clan_hodnost'] === CLAN_LEADER)
													{
														echo 'Clan Leader</td>							
															<td class="cup_riadok" style="padding: 3px;" width="50" align="center">
																-
															</td>';
													} else {
														echo '<select name="update_'.$row['user_id'].'" id="select">';
																$pocet = count(SLS::$hodnost);
																for($i=2; $i <= $pocet; $i++)
																{
																	echo '<option';
																	if($row['clan_hodnost'] == $i)
																	{																	
																		echo ' "selected" ';
																	}
																	echo ' value="'.$i.'">'.SLS::$hodnost[$i].'</option>';
																}	
														echo '		
															</select>
															</td>';
															
														if( $row['clan_hodnost'] === CLAN_ZASTUPCA and SLS::is_access(HRAC_VEDUCI))	
														{
															echo '							
																<td class="cup_riadok" style="padding: 3px;" width="50" align="center">
																	-
																</td>';
														} else {
															echo '<td class="cup_riadok" style="padding: 3px;" width="50" align="center">
																	<input type="checkbox" name="delete_'.$row['user_id'].'" value="1" />	
																</td>';
														}	
													}
											echo '</tr>';
											}
									}
							// Footer																				
							$temp = ($clan['volne']==true) ? 'Pr&iacute;jmame &#271;al&scaron;&iacute;ch hr&aacute;&#269;ov...' : 'M&aacute;me plno.';
							echo 	'
										<tr> 
											<td class="cup_riadok" style="padding: 3px;" align="left" colspan="5">
												<strong> Stav: </strong> <em>'.$temp.'</em>	
											</td>
										</tr>	
										<tr> 
											<td class="cup_riadok" style="padding: 3px;" align="center" colspan="5">
												<input  class="button" type="submit" name="Submit" value="Odosla&#357;" >	
											</td>
										</tr>											
									</form>	
								</table>
							';
							// Hladanie hracov
							echo '
							<br>
								<table class="cup_body" width="300" align="center" cellpadding="0" cellspacing="0">
									<tr>
										<th class="cup_nazov" colspan="4"> H&#318;adanie hr&aacute;&#269;ov...  </th>
									</tr>
									<form action="'.SLS::adresa_na_seba().'" method="post">
										<tr> 
											<td class="cup_riadok" align="center" ><strong>Meno</strong></td>
											<td class="cup_riadok" align="center" colspan="2"><input type="text" name="meno" size="50" ></td>
											<td class="cup_riadok" align="center" ><input  class="button" type="submit" name="Submit" value="H&#318;ada&#357;"></td>
										</tr>	
									</form>';
							if($_POST['meno'])		
							{
								if(strlen($_POST['meno']) >=3 )
								{
									@$sql_users=SLS::mysql_dbquery("
															SELECT user_id, user_name, cs_meno
															FROM `cstrike`.`fusion_users`
															WHERE (`user_name` LIKE '%".SLS::mysql_vstup(trim($_POST['meno']))."%'
															OR `cs_meno` LIKE '%".SLS::mysql_vstup(trim($_POST['meno']))."%')"
															);
														/*	AND `clan_id` IS NOT NULL"
															AND `cs_meno` IS NOT NULL"
															Moze posielat aj hracom co uz maju clan a aj novym hracom ...neviem ci to bude dobre
														*/
									if(@mysql_num_rows($sql_users) != 0) {	
										while($row = mysql_fetch_assoc($sql_users))
										{
											echo '<tr> 
															<td class="cup_riadok" style="padding: 3px;" width="30" align="center">
																<a href="'.SLS::$aplikacia.'messages.php?msg_send='.$row['user_id'].'">
																	<img src="'.SLS::$adresy[3].'sms.png" alt="Web Po&scaron;ta" title="Web Po&scaron;ta hr&aacute;&#269;a" border="0" align="absmiddle">
																</a>
															</td>
															<td class="cup_riadok" style="padding: 3px;" width="110" align="center">
																<a href="'.SLS::$aplikacia.'psychostats/index.php?q='.SLS::mysql_vystup($row['cs_meno']).'">
																	'.SLS::mysql_vystup($row['cs_meno']).'
																</a>										
															</td>										
															<td class="cup_riadok" style="padding: 3px;" width="80" align="center">
																<a href="'.SLS::$aplikacia.'profile.php?lookup='.$row['user_id'].'">
																	'.$row['user_name'].'
																</a>										
															</td>

															<td class="cup_riadok" style="padding: 3px;" width="50" align="center">
																<a href="'.SLS::cesta(6).$row['user_name'].'/">
																	<img src="'.SLS::$adresy[3].'join.png" alt="Posla&#357; pozv&aacute;nku" title="Posla&#357; pozv&aacute;nku" border="0" align="absmiddle">
																</a>
															</td>';

												echo '</tr>';
										}					
									} else {
										echo '
											<tr> 
												<td class="cup_riadok" align="center" colspan="4"><em>Hr&aacute;&#269; s menom "'.SLS::mysql_vstup($_POST['meno']).'" nen&aacute;jden&yacute;.</em></td>
											</tr>';
									}
								} else {
										echo '
											<tr> 
												<td class="cup_riadok" align="center" colspan="4"><em>Meno mus&iacute; ma&#357; aspo&#328; 3 znaky.</em></td>
											</tr>';
								}
							}
							echo '</table>	
							</div>	
							<div align="center" class="cup_credits" ><br>&copy; Powered by Seky`s Liga System v'.SLS::verzia.'</div>';
				}
			} else {
				echo SLS::get_spravu(SLS::sprava('clan_uz_ma'),1);
			}
			
		}	
	}	

// 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++ ?>