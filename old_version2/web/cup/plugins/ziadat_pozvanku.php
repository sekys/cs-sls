<? // 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++
if(!$page) { header("Location: ../index.php"); exit; }
	if(SLS::is_hrac() ) {
		if( SLS::$user['clan_id'] == false ) {		
			$id = $_GET['p1'];
			if(SLS::is_udaj($id)) {
					@$sql_clan=SLS::mysql_dbquery("SELECT volne FROM `phpbanlist`.`acp_clans` WHERE id = '".$id."'");
					if( SLS::is_clan_exist($sql_clan) )
					{
						$clan = mysql_fetch_assoc($sql_clan);
						if($clan['volne'] == false)
						{
							echo SLS::get_spravu(SLS::sprava('clan_plno'));
						} else {
						// Vsetko je uplne v poriadku zistilo leadera a jeho clan								
								if( isset($_POST['pozvanka']) and $_POST['pozvanka'] == "ano")
								{
									SLS::cup_log(-1, 27, SLS::$user['user_id'], $id);
									SLS::web_posta( SLS::get_najdi_leadera($id) ,
									'
											<div  class="cup_body" align="center">	
												<div align="center" style="background-color: #fff;color:#000000;">
												<img src="'.SLS::$adresy[3].'player_logo.jpg" alt="Logo" width="375" height="250" />
												<br>
													<strong>'.SLS::mysql_vystup(SLS::$user['cs_meno']).' &#382;iada o pozv&aacute;nku :</strong>
												<br><br>
												  <a href="'.SLS::cesta(6).SLS::$user['user_name'].'/">
												  <img src="'.SLS::$adresy[3].'cup_submit.gif" alt="Prija&#357;" tile="Prija&#357;" title="Prija&#357;" border="0"></a>
												   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
												  <a href="'.SLS::$aplikacia.'messages.php"><img src="'.SLS::$adresy[3].'cup_cancel.gif" alt="Odmietnu&#357;" title="Odmietnu&#357;" border="0"></a>
												<br><br><br>
												</div>
											</div>	
									', '&#381;iados&#357; o pozv&aacute;nku');
									
									echo SLS::get_spravu('&#381;iadost bola poslan&aacute;!<br>&#268;akaj na odpove&#271;....');
								} else {
									echo '
									<div style="padding:50px;" class="cup_body" align="center">
										<div class="cup_form_text">
											Chces vst&uacute;p&#357; do clanu <a href="'.SLS::cesta(5).$id.'/">'.SLS::mysql_vystup($clan['meno']).'</a> ?
										</div>
											<br>
											<form action="'.SLS::adresa_na_seba().'" method="post">
													<input class="cup_button" type="image" src="'.SLS::$adresy[3].'cup_submit.gif" name="pozvanka" value="ano" >
													&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
													<input class="cup_button" type="image" src="'.SLS::$adresy[3].'cup_cancel.gif" name="pozvanka" value="nie" >
											</form>
										<div>
										</div>
									</div>';
								}	
						}		
					}			
			} 
		} else {
			echo SLS::get_spravu(SLS::sprava('clan_uz_ma'),1);
		}
	}	
	
// 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++ ?>