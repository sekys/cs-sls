<? // 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++

if(SLSUser::isPlayer() ) {		
	$id = $_GET['p1'];
	if(SLS::CheckInput($id)) {			
		if( SLSUser::$user['clan_id'] == false) 
		{
				@$sql = SLS::Query2("SELECT * FROM `phpbanlist`.`pozvanky` WHERE id = '".$id."'");
				if( @mysqli_num_rows($sql) ) 
				{						
					$pozvanka = mysqli_fetch_assoc($sql);					
					if($pozvanka['hrac_id'] == SLSUser::$user['user_id'])
					{
						if($_GET['p2'] == 'zmazat')
						{
							echo SLS::MsgL('pozvanka_delete') );
						} else {
							@SLS::Query2("UPDATE `cstrike`.`fusion_users` SET `clan_id` = '".$pozvanka['clan_id']."' , `clan_hodnost` = '".HRAC."' WHERE `user_id` = '".SLSUser::$user['user_id']."'");
							SLS::Log(-1, 1, $pozvanka['clan_id'], $pozvanka['hrac_id']);
							SLSClan::Posta($pozvanka['clan_id'], '													
													<div  class="cup_body" align="center">	
														<div align="center" style="background-color: #fff;color:#000000;">
															<img src="'.SLS::$STYLE.'player_logo.jpg" alt="Logo" width="375" height="250" />
															<br><br>
															<strong>'.SLSLang::Msg('hrac_vstupil').' '.DB::Vystup(SLSUser::$user['cs_meno']).'</strong>
															<br><br><br><br>
														</div>
													</div>',  SLSLang::Msg('hrac_new') );
							echo SLS::MsgL('pozvanka_vitaj');						
						}
						@SLS::Query2("DELETE FROM `phpbanlist`.`pozvanky` WHERE `id` = '".$id."'");
					} else {
						echo SLS::MsgL('pozvanka_zla');
					}					
				
				} else {
					echo SLS::MsgL('pozvanka_ziadna',1);
				}
		} else {
			echo SLS::MsgL('clan_uz_ma',1);
		}
	}
}	

// 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++ ?>