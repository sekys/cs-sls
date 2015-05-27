<? // 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++
if(!$page) { header("Location: ../index.php"); exit; }
SLS::$language['create_done'] = 'Clan &uacute;spe&scaron;ne registrovan&yacute;.';
SLS::$language['create_register'] = 'Po skon&#269;en&iacute; registr&aacute;cia ako<br>clan leader<br>bude&scaron; m&ocirc;c&#357; spravova&#357; clan<br>hr&aacute;&#269;ov,v&yacute;zvy ...';
	
	if(SLS::is_hrac() ) {
		if( SLS::$user['clan_id'] == false) { // ak ma uz clan	

				echo '<div class="cup_body" id="cup_player" align="center">';
				if( isset($_POST['meno']) ) {
					if ( SLS::is_name_tag_ok($_POST['meno'], $_POST['tag']) ) 
					{	
						@$sql = SLS::mysql_dbquery("INSERT INTO `phpbanlist`.`acp_clans` 
						(meno, tag, popis, bodov, narod) values 
						('".SLS::mysql_vstup(trim($_POST['meno']))."','".SLS::mysql_vstup(trim($_POST['tag']))."',
						'".SLS::mysql_vstup(trim($_POST['popis']))."',
						'0', '0')");

						if(SLS::is_mysql_ok($sql)) {
							$id = mysql_insert_id();
							SLS::cup_log(-1, 4, $id, SLS::$user['user_id']);
							@SLS::mysql_dbquery("UPDATE `cstrike`.`fusion_users` SET `clan_id` = '".$id."' , `clan_hodnost` = '".CLAN_LEADER."' WHERE `user_id` = '".SLS::$user['user_id']."'");				
							echo SLS::get_spravu(SLS::sprava('create_done'));
						}
					}		
				} else {
					echo SLS::get_spravu(SLS::sprava('create_register'));
				}

				echo	'
					<div>
						<form action="'.SLS::adresa_na_seba().'" method="post">
							<table width="300" class="cup_body" border="0">
							  <tr>
							    <td class="cup_form_text">N&aacute;zov :</td>
							    <td><input name="meno" style="width:200px;font-size:10px;" type="text" value="'.SLS::mysql_vystup($_POST['meno']).'"></td>
							  </tr>
							  <tr>
							    <td class="cup_form_text">Tag clanu :</td>
							    <td><input name="tag" style="width:200px;font-size:10px;" type="text" value="'.SLS::mysql_vystup($_POST['tag']).'"></td>
							  </tr>
							  <tr>
							    <td colspan="2"><div class="cup_form_text" align="center">Popis</div></td>
							  </tr>
							  <tr>
							    <td colspan="2">
									<div align="center">
										<textarea class="cup_textarea" name="popis" maxlength="500" >'.SLS::mysql_vystup($_POST['popis']).'</textarea>
									</div>
								</td>
							  </tr>  
							  <tr>
							     <td colspan="2">
									<div align="center">
										<input src="'.SLS::$adresy[3].'registracia.gif" class="cup_button" type="image" name="Submit" value="Submit">
									</div>
								</td>
							  </tr>	
							</table>
						</form>	
					</div>
					<div align="center" class="cup_credits" ><br>&copy; Powered by Seky`s Liga System v'.SLS::verzia.'</div>
				</div>	
				';				
		} else {
				echo SLS::get_spravu(SLS::sprava('clan_uz_ma'),1);
		} 
	}	
// 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++ ?>