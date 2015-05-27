<? // 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++
if(!$page) { header("Location: ../index.php"); exit; }
	if(SLS::is_hrac() ) {		
		$id = $_GET['p1'];
		if(SLS::is_udaj($id)) {			
			if( SLS::$user['clan_id'] == false) 
			{
					@$sql = SLS::mysql_dbquery("SELECT * FROM `phpbanlist`.`pozvanky` WHERE id = '".$id."'");
					if( @mysql_num_rows($sql) ) 
					{						
						$pozvanka = mysql_fetch_assoc($sql);					
						if($pozvanka['hrac_id'] == SLS::$user['user_id'])
						{
							if($_GET['p2'] == 'zmazat')
							{
								echo SLS::get_spravu( SLS::sprava('pozvanka_delete') );
							} else {
								@SLS::mysql_dbquery("UPDATE `cstrike`.`fusion_users` SET `clan_id` = '".$pozvanka['clan_id']."' , `clan_hodnost` = '".HRAC."' WHERE `user_id` = '".SLS::$user['user_id']."'");
								SLS::cup_log(-1, 1, $pozvanka['clan_id'], $pozvanka['hrac_id']);
								SLS::team_posta($pozvanka['clan_id'], '													
														<div  class="cup_body" align="center">	
															<div align="center" style="background-color: #fff;color:#000000;">
																<img src="'.SLS::$adresy[3].'player_logo.jpg" alt="Logo" width="375" height="250" />
																<br><br>
																<strong>'.SLS::sprava('hrac_vstupil').' '.SLS::mysql_vystup(SLS::$user['cs_meno']).'</strong>
																<br><br><br><br>
															</div>
														</div>',  SLS::sprava('hrac_new') );
								echo SLS::get_spravu( SLS::sprava('pozvanka_vitaj') );						
							}
							@SLS::mysql_dbquery("DELETE FROM `phpbanlist`.`pozvanky` WHERE `id` = '".$id."'");
						} else {
							echo SLS::get_spravu( SLS::sprava('pozvanka_zla') );
						}					
					
					} else {
						echo SLS::get_spravu(SLS::sprava('pozvanka_ziadna'),1);
					}
			} else {
				echo SLS::get_spravu(SLS::sprava('clan_uz_ma'),1);
			}
		}
	}	

// 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++ ?>