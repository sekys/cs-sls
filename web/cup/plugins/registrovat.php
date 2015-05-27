<? // 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++

if(SLSUser::isPlayer() ) {
	if( SLSUser::$user['clan_id'] == false) { // ak ma uz clan	

			echo '<div class="cup_body" id="cup_player" align="center">';
			if( isset($_POST['meno']) ) {
				if ( SLSClan::CheckNametag($_POST['meno'], $_POST['tag']) ) 
				{	
					@$sql = SLS::Query2("INSERT INTO `phpbanlist`.`acp_clans` 
					(meno, tag, popis, bodov, narod) values 
					('".DB::Vstup(trim($_POST['meno']))."','".DB::Vstup(trim($_POST['tag']))."',
					'".DB::Vstup(trim($_POST['popis']))."',
					'0', '0')");

					if(SLS::CheckMysql($sql)) {
						$id = mysql_insert_id();
						SLS::Log(-1, 4, $id, SLSUser::$user['user_id']);
						@SLS::Query2("UPDATE `cstrike`.`fusion_users` SET `clan_id` = '".$id."' , `clan_hodnost` = '".SLSHodnost::LEADER."' WHERE `user_id` = '".SLSUser::$user['user_id']."'");				
						echo SLS::Msg('Clan &uacute;spe&scaron;ne registrovan&yacute;.');
					}
				}		
			} else {
				echo SLS::MsgL('Po skon&#269;en&iacute; registr&aacute;cia ako<br>clan leader<br>bude&scaron; m&ocirc;c&#357; spravova&#357; clan<br>hr&aacute;&#269;ov,v&yacute;zvy ...');
			}

			echo	'
				<div>
					<form action="" method="post">
						<table width="300" class="cup_body" border="0">
						  <tr>
							<td class="cup_form_text">N&aacute;zov :</td>
							<td><input name="meno" style="width:200px;font-size:10px;" type="text" value="'.DB::Vystup($_POST['meno']).'"></td>
						  </tr>
						  <tr>
							<td class="cup_form_text">Tag clanu :</td>
							<td><input name="tag" style="width:200px;font-size:10px;" type="text" value="'.DB::Vystup($_POST['tag']).'"></td>
						  </tr>
						  <tr>
							<td colspan="2"><div class="cup_form_text" align="center">Popis</div></td>
						  </tr>
						  <tr>
							<td colspan="2">
								<div align="center">
									<textarea class="cup_textarea" name="popis" maxlength="500" >'.DB::Vystup($_POST['popis']).'</textarea>
								</div>
							</td>
						  </tr>  
						  <tr>
							 <td colspan="2">
								<div align="center">
									<input src="'.SLS::$STYLE.'registracia.gif" class="cup_button" type="image" name="Submit" value="Submit">
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
			echo SLS::MsgL('clan_uz_ma', 1);
	} 
}	
// 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++ ?>