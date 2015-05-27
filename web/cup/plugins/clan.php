<? // 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++

	$id = $_GET['p1'];
	
	if(!$id) {
		echo SLS::MsgL('ziadne_udaje', 1);	
	} else {
		if(is_numeric($id)) {
			$id = DB::Vstup($id);
			@$sql=SLS::Query2("SELECT * FROM `phpbanlist`.`acp_clans` WHERE id ='".$id."'");
			// Ak za CLAN MENO maju cislo
			if(!@mysqli_num_rows($sql) ) {
				@$sql=SLS::Query2("SELECT * FROM `phpbanlist`.`acp_clans` WHERE meno LIKE '".$id."' ");
			}	
		} else {
			@$sql=SLS::Query2("SELECT * FROM `phpbanlist`.`acp_clans` WHERE meno LIKE '".DB::Vstup($id)."' ");
		}

		if( SLSClan::Exist($sql) ) {
				$riadok = mysqli_fetch_assoc($sql);				
				SLS::Log(-1, 31, SLSUser::$user['user_id'], $riadok["id"], false, false, false);
				echo '			
				<div style="padding-top:30px;" class="cup_body" id="cup_info" align="center">';
	/*~~~~~~~~~~~~~~
		Informacie
	~~~~~~~~~~~~~~~*/				
			$sql_pocet = SLS::Zapasov($riadok["id"]);
			echo '<table  border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td width="180" >
						<a href="'.SLSPlugins::Adresa(5).DB::Vystup($riadok["id"]).'/">
							<img '.SLSClan::Avatar($riadok["avatar"]).' width="150" height="150" alt="'.DB::Vystup($riadok['meno']).'" hspace="5" vspace="5" border="0">
						</a>
					</td>
					<td>
						<table width="300" border="0" class="cup_body">
						  <tr><td colspan="2">&nbsp;</td></tr>
						  <tr>
							<td width="150" align="left" class="cup_form_text">N&aacute;zov</td>
							<td align="left">'.DB::Vystup($riadok['meno']).'</td>
						  </tr>
						  <tr>
							<td align="left" class="cup_form_text">Tag clanu</td>
							<td align="left">'.DB::Vystup($riadok['tag']).'</td>
						  </tr>
						  <tr>
							<td align="left" class="cup_form_text">Rank</td>
							<td align="left">';						
							echo SLSClan::ZoznamRank( SLSClan::Rank($riadok['id']) );
							echo '</a>';
							
					echo	'</td>
						  </tr>			
						  <tr>
							<td align="left" class="cup_form_text">Bodov</td>
							<td align="left">'.$riadok['bodov'].'</td>
						  </tr>						
						  <tr>
							<td align="left" class="cup_form_text">Aktivita</td>
							<td align="left"><span title="Stupe&#328; aktivity: '.$riadok['aktivita'].'">'.SLS::get_aktivita($riadok['aktivita']).'</span></td>
						  </tr>				
						  <tr>
							<td align="left" class="cup_form_text">Steamov&yacute; clan:</td>
							<td align="left">';
							echo SLS::GetBool($riadok['steam']);
					echo '	</td>
						  </tr>
						  <tr>
							<td align="left" class="cup_form_text">Odohran&yacute;ch z&aacute;pasov:</td>
							<td align="left">'.$sql_pocet.'</td>
						  </tr>
						  <tr>
							<td align="left" class="cup_form_text">Vo&#318;n&eacute; miesto:</td>
							<td align="left">';
							echo SLS::GetBool($riadok['volne']);
					echo '	</td>
						  </tr>						
						<tr>
							<td colspan="2" align="center">
								'.SLS::Narod($riadok['narod']).'
							</td>
						</tr>
						<tr><td colspan="2">&nbsp;</td></tr>
					</table>
				</td>
			</tr>
			<tr>
				<td width="180">		
							<a href="'.SLSPlugins::Adresa(11).$riadok["id"].'/">
								<img src="'.SLS::$STYLE.'vyzvat.png" alt="Vyzva&#357; tento clan !" title="Vyzva&#357; tento clan !" hspace="5" vspace="5" border="0">
							</a>					
							<br>
							<a href="'.SLSPlugins::Adresa(8).$riadok["id"].'/">
								<img src="'.SLS::$STYLE.'vstupit.png" alt="Vst&uacute;pi&#357; do clanu." title="Vst&uacute;pi&#357; do clanu." hspace="5" vspace="5" border="0">
							</a>
				</td>
				<td>&nbsp;</td>	
			</tr>	
			<tr>
				<td colspan="2"><div class="popis">
					'.DB::Vystup($riadok['popis']).'
				</div></td>
		</table>';					

	
	
	/*~~~~~~~~~~~~~~~~~~~
		Dalsie informacie
	~~~~~~~~~~~~~~~~~~~~~*/
				
				// Neskor + ajax
				echo '		
				<script type="text/javascript">
					$(document).ready(function(){
						$("#tabs").tabs();
					});
				</script>

				<div id="tabs" style="color: #999;">
				    <ul class="tabs_zoznam">
				        <li class="ui-state-default ui-corner-top"><a href="#vyzvy">V&yacute;zvy</a></li>
				        <li class="ui-state-default ui-corner-top"><a href="#hraci">Hr&aacute;&#269;i</a></li>
				        <li class="ui-state-default ui-corner-top"><a href="#zapasy">Z&aacute;pasy</a></li>
				        <li class="ui-state-default ui-corner-top"><a href="#bonus">Bonusy</a></li>
				    </ul>
				    <div id="vyzvy">
						';						
				// Vyzvy							
					@$sql_vyzva = SLS::Query2("SELECT * FROM `phpbanlist`.`acp_vyzva` WHERE (ziada ='".$riadok['id']."' OR prijal ='".$riadok['id']."') AND sukromna = 0 ORDER BY datum desc");
						if( mysqli_num_rows($sql_vyzva) ) {
							echo '<br><br>';
							echo '<table width="400"  border="0" cellpadding="0" cellspacing="0">
									<tr>				
										<td>&nbsp;</td>	
										<td align="center"><em>S&uacute;per</em></td>
										<td align="center"><em>&#268;as</em></td>
										<td align="center"><em>Mapa</em></td>
									</tr';	
							while($vyzva = mysqli_fetch_assoc($sql_vyzva))
							{											
								if( $vyzva['prijal'] == true)
								{
									// ak nejde o ten isty clan
									$temp = ($vyzva['prijal'] != $riadok['id'] ) ? $vyzva['prijal'] : $vyzva['ziada'];
									@$sql_vyzva_clan = SLS::Query2("SELECT id, meno, bodov FROM `phpbanlist`.`acp_clans` WHERE id ='".$temp."'");
									$vyzva_clan = mysqli_fetch_assoc($sql_vyzva_clan);
									
									if($vyzva_clan["meno"]) {				
										$temp_2 = '<a href="'.SLSPlugins::Adresa(5).$vyzva_clan['id'].'/">'.DB::Vystup($vyzva_clan['meno']).'</a>';
									} else {
										$temp_2 = '<em>Clan nen&aacute;jden&yacute;</em>';
									}
								} else {
									$temp_2 = '<em>-</em>';
								}
								
								echo '	<tr>
											<td align="center" width="10">
												'.( $vyzva['prijal'] == false ? '<a href="'.SLSPlugins::Adresa(10).date("Y-m-d\/H", $vyzva['datum']).'/'.$vyzva['server'].'/"><img title="Prija&#357; v&yacute;zvu ?" src="'.SLS::$STYLE.'cup_ok.png" alt="ok" width="20" height="20" border="0" align="absmiddle"></a>' : '&nbsp;').'
											</td>														
											<td align="left" width="180">
												'.$temp_2.'</a>'.'
											</td>											
											<td align="center" width="110">
												'.date("Y-m-d \o H", $vyzva['datum']).'
											</td>						
											<td align="center" width="90">
												'.$vyzva['mapa'].'
											</td>
										</tr>';	
									
							}
							echo'</table>';	
						} else {
							echo '<br><br><p align="center"><em>- &#381;iadne v&yacute;zvy  -</em></p>';
						}	
				echo '
				    </div>
				    <div id="hraci">';
			// Hraci
					@$sql=SLS::Query2("SELECT user_id, user_name, cs_meno, clan_hodnost FROM `cstrike`.`fusion_users` WHERE clan_id ='".$riadok["id"]."' ORDER BY clan_hodnost ASC"); // viacero clanov
					if( @mysqli_num_rows($sql) ) {
						echo '<br><br>';
						echo '<table width="450" border="0" cellpadding="0" cellspacing="0">								
								<tr>				
									<td align="left" colspan="2"><em>Web meno</em></td>	
									<td align="left"><em>Hern&eacute; meno</em></td>
								</tr>';								
													
						while($data = mysqli_fetch_assoc($sql))
						{
							$temp = SLSHodnost::$hodnost[$data['clan_hodnost']];
							echo '<tr>
									<td align="left" width="10">
										<img src="'.SLS::$STYLE.'hodnost/'.$data['clan_hodnost'].'.png" title="Hodnos&#357;: '.$temp.'" alt="'.$temp.'" border="0" align="absmiddle" width="16" height="16" />
									</td>					
									<td align="left" width="120">
										<a href="'.ROOT.'profile.php?lookup='.$data["user_id"].'" >'.$data["user_name"].'</a>
									</td>	
									<td align="left" >
										<a href="'.ROOT.'psychostats/index.php?q='.DB::Vystup($data["cs_meno"]).'">'.DB::Vystup($data['cs_meno']).'</a>
									</td>									
									<td align="right" >
										<a href="'.ROOT.'messages.php?msg_send='.$data["user_id"].'">
											<img src="'.SLS::$STYLE.'/sms.png" alt="Web Po&scaron;ta" title="Web Po&scaron;ta hr&aacute;&#269;a" border="0" align="absmiddle">
										</a>
									</td>
								</tr>';
						}
						echo'</table>';
					} else {	
						echo '<br><br><p align="center"><em>- Clan nem&aacute; hr&aacute;&#269;ov, pros&iacute;m nahlaste clan adminovy -</em></p>';
					}
				echo '	</div>
				    <div id="zapasy">';	
			// Zapasy
						// Prefix
						//SLS::$zoznam = (is_numeric($_GET['p2'])) ? $_GET['p2'] : 0;	
						
								if( $sql_pocet ) 
								{

									@$sql_zapas=SLS::Query2("SELECT id, ziada, ziada_skore, ziada_bodov, ziada_narocnost, ziada_bonus, 
																	prijal, prijal_skore, prijal_bodov, prijal_narocnost, prijal_bonus,
																	status, datum, server 
																	FROM `phpbanlist`.`cup_zapas` WHERE 
																	ziada = '".$riadok['id']."' OR prijal = '".$riadok['id']."' 
																	ORDER BY datum desc "); // ".SLS::get_zoznam()."

									echo '<br><br>';
									echo '<table width="450" border="0" cellpadding="0" cellspacing="0">
											<tr>				
												<td align="center"><em>S&uacute;per</em></td>	
												<td align="center"><em> Ob&#357;ia&#382;nos&#357; </em></td>
												<td align="center"><em> Bonus </em></td>
												<td align="center"><em> Sk&oacute;re </em></td>
												<td align="center"><em> Bodov</em></td>
												<td align="center">&nbsp;</td>
											</tr>';
									
									while($zapas = mysqli_fetch_assoc($sql_zapas))
									{											
										@$sql_super = SLS::Query2("SELECT id,meno FROM `phpbanlist`.`acp_clans` WHERE id ='".( $zapas['ziada'] == $riadok['id'] ? $zapas['prijal'] : $zapas['ziada'] )."'");
										$super = mysqli_fetch_assoc($sql_super);	
											
											$temp = ( $zapas['ziada'] == $riadok['id'] ) ? $zapas['ziada_bonus'] : $zapas['prijal_bonus'];

											echo '<tr>
													<td align="left" width="200">
														<a href="'.SLSPlugins::Adresa(5).$super["id"].'/">'.SLSClan::ClanMeno($super["meno"]).'</a>
													</td>														
													<td align="center" width="20">
														<strong>
															'.( $zapas['ziada'] == $riadok['id'] ?  $zapas['ziada_narocnost'] :  $zapas['prijal_narocnost'] ).'%
														</strong>
													</td>	
													<td align="center" width="20"><strong>';
															if($temp < 0) {
																echo '<span style="color:red;">'.$temp.'%</span>';
															} elseif($temp > 0 ) {
																echo '<span style="color:green;">'.$temp.'%</span>';
															} else {
																echo $temp.'%';
															}
											echo '		</strong>
													</td>
													<td align="center" width="30">
														<strong>
															'.( $zapas['ziada'] == $riadok['id'] ?  $zapas['ziada_skore'] :  $zapas['prijal_skore'] ).'
														</strong>
													</td>											
													<td align="center" width="40">
														<strong>
															'.( $zapas['ziada'] == $riadok['id'] ?  $zapas['ziada_bodov'] :  $zapas['prijal_bodov'] ).'
														</strong>
													</td>						
													<td align="right" width="40">
														<a href="'.SLSPlugins::Adresa(15).date("Y-m-d\/H", $zapas['datum']).'/'.$zapas['server'].'/">
															<img title="Pozrie&#357; detaily z&aacute;pasu." src="'.SLS::$STYLE.'stats.gif" alt="Pozrie&#357; detaily z&aacute;pasu." border="0" align="absmiddle">
														</a>
													</td>
												</tr>';																																			
									}
									echo '</table>';
									//echo SLS::set_zoznam($sql_pocet, SLSROOT.$_GET['stranka'].'/'.$_GET['p1'].'/');
								} else {
									echo '<br><br><p align="center"><em>- Neodohrali zatia&#318; &#382;iadny z&aacute;pas  -</em></p>';
								}
			// Bonusy				
							echo'				
					</div>
						<div id="bonus">';	
							if($riadok['bonus_type'])
							{
								echo '<br><br>'.SLSClan::BonusType(0, $riadok['bonus_type'], 'Clan z&iacute;skal ocenenie:');
							} else {	
								echo '<br><br><p align="center"><em>- Clan nem&aacute; &#382;iadny bonus / cenu  -</em></p>';
							}
					echo '		
						</div>		
			</div>';
				
	/*~~~~~~~~~~~~~~
		Admin panel
	~~~~~~~~~~~~~~~*/

				/*if($_POST['admin'])
				{
					// header sa uz neda pouzit :(
					if($_POST['admin'] == 3) {
						echo '<meta http-equiv="refresh" content="1;url='.SLS::cesta.'cup.php?cup_edit_vyzvy=true&admin='.$id.'">';				
					} elseif($_POST['admin'] == 2) {
						echo '<meta http-equiv="refresh" content="1;url='.SLS::cesta.'cup.php?cup_edit_players=true&admin='.$id.'">';				
					} else {	
						echo '<meta http-equiv="refresh" content="1;url='.SLS::cesta.'cup.php?cup_edit_clan=true&admin='.$id.'">';										
					}
				}
					<br>	
							<form action="'.SLS::cesta.'cup.php?cup_info_clan='.$id.'" method="post">
								<select type="submit" style="font-size:10px;" onchange="form.submit()" name="admin">
									<option value="0" >&nbsp;</option>
									<option value="1" >Administr&aacute;cia</option>
									<option value="2" >Spr&aacute;va hr&aacute;&#269;ov</option>
									<option value="3" >Spr&aacute;va v&yacute;ziev</option>
								</select>
							</form>	
				
				*/
				
			echo '<div align="center" class="cup_credits" >
					<br><br>&copy; Powered by Seky`s Liga System v'.SLS::verzia.'
				</div>';
		echo '</div>';
		} 
	}
// 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++	?>