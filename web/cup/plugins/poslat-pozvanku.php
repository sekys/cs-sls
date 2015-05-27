<? // 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++


if(SLSUser::isPlayer() ) {
	if( SLSUser::MaClan() ) { // ak ma uz clan						
			if( SLSUser::isHodnost(SLSHodnost::LEADER) or SLSUser::isHodnost(SLSHodnost::ZASTUPCA) or SLSUser::isHodnost(SLSUser::HRACVEDUCI)) {				
				
				$p1 = $_GET['p1'];
				if($p1) {	
					@$sql = SLS::Query2("SELECT user_id FROM `cstrike`.`fusion_users` WHERE `user_name` LIKE '".DB::Vstup($p1)."'");
					$hrac =  mysqli_fetch_assoc($sql);
					if($hrac['user_id']) {
						@$sql_clan=SLS::Query2("SELECT meno FROM `phpbanlist`.`acp_clans` WHERE id = '".SLSUser::$user['clan_id']."'");					
						if(  SLSClan::Exist($sql_clan) ) 
						{																		
							$clan = mysqli_fetch_assoc($sql_clan);
							@SLS::Query2("INSERT INTO `phpbanlist`.`pozvanky` (hrac_id, clan_id) VALUES ('".$hrac['user_id']."', '".SLSUser::$user['clan_id']."')");
							$id = mysql_insert_id();
							SLS::Log(-1, 32, SLSUser::$user['clan_id'], $hrac['user_id'], SLSUser::$user['user_id']);
							SLSUser::Posta($hrac['user_id'],'	
									<div  class="cup_body" align="center">	
										<div align="center" style="background-color: #fff;color:#000000;">
										<img src="'.SLS::$STYLE.'player_logo.jpg" alt="Logo" width="375" height="250" />
										<br>
											<strong>Pozv&aacute;nka do '.DB::Vystup($clan['meno']).' : </strong>
										<br><br>
										  <a href="'.SLS::Adresa(7).$id.'/">
										  <img src="'.SLS::$STYLE.'cup_submit.gif" alt="Prija&#357;" tile="Prija&#357;" title="Prija&#357;" border="0"></a>
										   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
										  <a href="'.SLS::Adresa(7).$id.'/zmazat/"><img src="'.SLS::$STYLE.'cup_cancel.gif" alt="Odmietnu&#357;" title="Odmietnu&#357;" border="0"></a>
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
						echo SLS::MsgL('hrac_no', 1);
					}		
				} else {
					echo SLS::MsgL('hrac_no', 1);
				}							
			} else {
				echo SLS::MsgL('hodnost_nema', 1);
			}
	}
}		

// 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++ ?>