<? // 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++
if(!$page) { header("Location: ../index.php"); exit; }

	if(SLS::is_hrac() ) {
		if( SLS::ma_clan() ) { // ak ma uz clan						
				if( SLS::is_access(CLAN_LEADER) or SLS::is_access(CLAN_ZASTUPCA) or SLS::is_access(HRAC_VEDUCI)) {				
					
					$p1 = $_GET['p1'];
					if($p1) {	
						@$sql = SLS::mysql_dbquery("SELECT user_id FROM `cstrike`.`fusion_users` WHERE `user_name` LIKE '".SLS::mysql_vstup($p1)."'");
						$hrac =  mysql_fetch_assoc($sql);
						if($hrac['user_id']) {
							@$sql_clan=SLS::mysql_dbquery("SELECT meno FROM `phpbanlist`.`acp_clans` WHERE id = '".SLS::$user['clan_id']."'");					
							if(  SLS::is_clan_exist($sql_clan) ) 
							{																		
								$clan = mysql_fetch_assoc($sql_clan);
								@SLS::mysql_dbquery("INSERT INTO `phpbanlist`.`pozvanky` (hrac_id, clan_id) VALUES ('".$hrac['user_id']."', '".SLS::$user['clan_id']."')");
								$id = mysql_insert_id();
								SLS::cup_log(-1, 32, SLS::$user['clan_id'], $hrac['user_id'], SLS::$user['user_id']);
								SLS::web_posta($hrac['user_id'],'	
										<div  class="cup_body" align="center">	
											<div align="center" style="background-color: #fff;color:#000000;">
											<img src="'.SLS::$adresy[3].'player_logo.jpg" alt="Logo" width="375" height="250" />
											<br>
												<strong>Pozv&aacute;nka do '.SLS::mysql_vystup($clan['meno']).' : </strong>
											<br><br>
											  <a href="'.SLS::cesta(7).$id.'/">
											  <img src="'.SLS::$adresy[3].'cup_submit.gif" alt="Prija&#357;" tile="Prija&#357;" title="Prija&#357;" border="0"></a>
											   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
											  <a href="'.SLS::cesta(7).$id.'/zmazat/"><img src="'.SLS::$adresy[3].'cup_cancel.gif" alt="Odmietnu&#357;" title="Odmietnu&#357;" border="0"></a>
											<br><br><br>
											</div>
										</div>', 'Pozv&aacute;nka');													
								echo '
									<br>
									<p align="center"><b>Pozv&aacute;nka &uacute;spe&scaron;ne poslan&aacute;.<b></p>	
									<br>
									';
								// ok 	
							}	
						} else {
							echo SLS::get_spravu(SLS::sprava('hrac_no'), 1);
						}		
					} else {
						echo SLS::get_spravu(SLS::sprava('hrac_no'), 1);
					}							
				} else {
					echo SLS::get_spravu(SLS::sprava('hodnost_nema'), 1);
				}
		}
	}		

// 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++ ?>