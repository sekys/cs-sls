<? // 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++

	if(SLS::isPlayer() ) {
		if( SLSUser::$user['clan_id'] == false ) {		
			$id = $_GET['p1'];
			if(SLS::CheckInput($id)) {
					@$sql_clan=SLS::Query2("SELECT volne FROM `phpbanlist`.`acp_clans` WHERE id = '".$id."'");
					if( SLSClan::Exist($sql_clan) )
					{
						$clan = mysqli_fetch_assoc($sql_clan);
						if($clan['volne'] == false)
						{
							echo SLS::MsgL('clan_plno'));
						} else {
						// Vsetko je uplne v poriadku zistilo leadera a jeho clan								
								if( isset($_POST['pozvanka']) and $_POST['pozvanka'] == "ano")
								{
									SLS::Log(-1, 27, SLSUser::$user['user_id'], $id);
									SLSUser::Posta( SLSClan::FindLeader($id) ,
									'
											<div  class="cup_body" align="center">	
												<div align="center" style="background-color: #fff;color:#000000;">
												<img src="'.SLS::$STYLE.'player_logo.jpg" alt="Logo" width="375" height="250" />
												<br>
													<strong>'.DB::Vystup(SLSUser::$user['cs_meno']).' &#382;iada o pozv&aacute;nku :</strong>
												<br><br>
												  <a href="'.SLSPlugins::Adresa(6).SLSUser::$user['user_name'].'/">
												  <img src="'.SLS::$STYLE.'cup_submit.gif" alt="Prija&#357;" tile="Prija&#357;" title="Prija&#357;" border="0"></a>
												   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
												  <a href="'.ROOT.'messages.php"><img src="'.SLS::$STYLE.'cup_cancel.gif" alt="Odmietnu&#357;" title="Odmietnu&#357;" border="0"></a>
												<br><br><br>
												</div>
											</div>	
									', '&#381;iados&#357; o pozv&aacute;nku');
									
									echo SLS::Msg('&#381;iadost bola poslan&aacute;!<br>&#268;akaj na odpove&#271;....');
								} else {
									echo '
									<div style="padding:50px;" class="cup_body" align="center">
										<div class="cup_form_text">
											Chces vst&uacute;p&#357; do clanu <a href="'.SLSPlugins::Adresa(5).$id.'/">'.DB::Vystup($clan['meno']).'</a> ?
										</div>
											<br>
											<form action="" method="post">
													<input class="cup_button" type="image" src="'.SLS::$STYLE.'cup_submit.gif" name="pozvanka" value="ano" >
													&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
													<input class="cup_button" type="image" src="'.SLS::$STYLE.'cup_cancel.gif" name="pozvanka" value="nie" >
											</form>
										<div>
										</div>
									</div>';
								}	
						}		
					}			
			} 
		} else {
			echo SLS::MsgL('clan_uz_ma',1);
		}
	}	
	
// 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++ ?>