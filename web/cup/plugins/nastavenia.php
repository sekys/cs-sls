<? // 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++

if( SLSUser::isPlayer()) {
	if( SLSUser::MaClan()) {		
		if( SLSUser::isHodnost(SLSHodnost::LEADER) or SLSUser::isHodnost(SLSHodnost::ZASTUPCA) ) {											
				@$sql_clan=SLS::Query2("SELECT * FROM `phpbanlist`.`acp_clans` WHERE id = '".SLSUser::$user['clan_id']."'");
				if( SLSClan::Exist($sql_clan ) ) 
				{													
					$clan = mysqli_fetch_assoc($sql_clan);
					// prepis CSS
					echo '
					<style type="text/css">
					<!--
					.side-border-right {
						padding-left:0px;
					}
					-->
					</style>
					';										
					
					echo '<div style="width:550px" class="cup_body" align="center">';
					
/*~~~~~~~~~~~~~~~~					
	Akcie				
~~~~~~~~~~~~~~~~~~*/
					if($_POST['delete'] == true)
					{
						if( SLSUser::isHodnost(SLSHodnost::LEADER) )
						{	
							//Log
							SLS::Log(-1, 3, SLSUser::$user['clan_id'], false, false, $clan['meno']);
							@SLS::Query2("DELETE FROM `phpbanlist`.`acp_clans` WHERE id ='".SLSUser::$user['clan_id']."'");							
							// Hraci v clanu
							@SLS::Query2("UPDATE `cstrike`.`fusion_users` SET `clan_id` = '0' , `clan_hodnost` = '0' WHERE `clan_id` = '".SLSUser::$user['clan_id']."'");					
							// Vyzvy
							@SLS::Query2("DELETE FROM `phpbanlist`.`acp_vyzva` WHERE ziada ='".SLSUser::$user['clan_id']."' OR prijal ='".SLSUser::$user['clan_id']."'");
							echo SLS::Msg('Clan &uacute;spe&scaron;ne zmazan&yacute;!');
						} else {
							echo SLS::MsgL('hodnost_nema');
						}
					} else {
						
						
						// Uprava
						if($_POST['nazov'] == true)
						{
								if( SLSClan::CheckNametag($_POST['nazov'], $_POST['tag']) ) 
								{
									$steam = ($_POST['steam'] == true)  ? "1" : "0" ;
									$volne = ($_POST['volne'] == true)  ? "1" : "0" ;
									$narod = ( is_numeric($_POST['narod']) )  ? $_POST['narod'] : "0" ;
									SLS::Log(-1, 25, SLSUser::$user['user_id'], SLSUser::$user['clan_id']);
									
									@$sql = SLS::Query2("UPDATE `phpbanlist`.`acp_clans` SET `meno` = '".DB::Vstup(trim($_POST['nazov']))."',
												`tag` = '".DB::Vstup(trim($_POST['tag']))."',
												`popis` = '".DB::Vstup(trim($_POST['popis']))."',
												`steam` = '".$steam."',
												`avatar` = '".DB::Vstup($_POST['avatar'])."',
												`volne` = '".$volne."',
												`narod` = '".$narod."'
												 WHERE `acp_clans`.`id` = '".SLSUser::$user['clan_id']."';
												");
									if( SLS::CheckMysql($sql)) {
										echo SLS::Msg(DB::Vystup($clan['meno'])." upraven&yacute; !");
										//refresh udajov
										$sql_clan=0;
										$clan=0;
										@$sql_clan=SLS::Query2("SELECT * FROM `phpbanlist`.`acp_clans` WHERE id = '".SLSUser::$user['clan_id']."'");
										$clan = mysqli_fetch_assoc($sql_clan);
									}	
								}
						}	
						
						// Team spravy
						if($_POST['predmet'] == true)
						{
							if($_POST['sprava'] == true)
							{
								SLSClan::Posta( SLSUser::$user['clan_id'], DB::Vstup($_POST['sprava']), DB::Vstup($_POST['predmet']), SLSUser::$user['user_id']);
								echo SLS::Msg('Spr&aacute;va odoslan&aacute;.');
								SLS::Log(-1, 26, SLSUser::$user['user_id'], SLSUser::$user['clan_id']);
							} else {
								echo SLS::Msg('Musis zada&#357; text spr&aacute;vy. ', 1);
							}
						}
	/*~~~~~~~~~~~~~~~~					
		Nastavenia					
	~~~~~~~~~~~~~~~~~~*/											
						echo '
							<div class="clan_avatar" align="center">
								<a href="'.SLSPlugins::Adresa(5).DB::Vystup($clan["meno"]).'/">
								<img '.SLSClan::Avatar($clan["avatar"]).' width="150" height="150" alt="'.DB::Vystup($clan['meno']).'" hspace="5" vspace="5" border="0">
								</a>
								<br>
								<br>
								<p style="padding-left:50px;" align="left" class="cup_form_text">Z&aacute;pasov: '.SLS::Zapasov($clan["id"]).'</p>
								<p style="padding-left:50px;" align="left" class="cup_form_text">Bodov: '.$clan['bodov'].'</p>
								<p style="padding-left:50px;" align="left" class="cup_form_text">Rank: ';
									echo  SLSClan::ZoznamRank( SLSClan::Rank($clan['id']) );
								echo '</p>									
																
							</div>
							<div>
							<form action="" method="post">
								<table width="400" border="0" class="cup_body">			
								  <tr>
									<td align="right" class="cup_form_text" >N&aacute;zov :</td>
									<td><input name="nazov" style="width:200px;font-size:10px;" type="text" value="'.DB::Vystup($clan['meno']).'"></td>
								  </tr>
								  <tr>
									<td align="right" class="cup_form_text">Tag clanu :</td>
									<td><input name="tag" style="width:200px;font-size:10px;" type="text" value="'.DB::Vystup($clan['tag']).'"></td>
								  </tr>								
								  <tr>
									<td align="right" class="cup_form_text">Avatar :</td>
									<td><input name="avatar" style="width:200px;font-size:10px;" type="text" value="'.$clan['avatar'].'"></td>
								  </tr>								
								  <tr>
									<td align="right" class="cup_form_text">Steamov&yacute clan:</td>
									<td>';
										$temp = ($clan['steam']) ? "checked" : "";
										echo '<label><input type="radio" name="steam" value="1" '.$temp.'>Ano</label>';
										$temp = ($clan['steam']==false) ? "checked" : "";
										echo'<label><input type="radio" name="steam" value="0" '.$temp.'>Nie</label>
									</td>
								  </tr>									
								  <tr>
									<td align="right" class="cup_form_text">Vo&#318;n&eacute; miesto:</td>
									<td>';
										$temp = ($clan['volne']) ? "checked" : "";
										echo '<label><input type="radio" name="volne" value="1" '.$temp.'>Ano</label>';
										$temp = ($clan['volne']==false) ? "checked" : "";
										echo'<label><input type="radio" name="volne" value="0" '.$temp.'>Nie</label>
									</td>
								  </tr>									
								  <tr>
									<td align="right" class="cup_form_text">N&aacute;rodnos&#357;:</td>
									<td>
										&nbsp;
										<img src="'.SLS::$STYLE.'/vlajka_'.$clan['narod'].'.gif" alt="N&aacute;rodnos&#357; clanu" title="N&aacute;rodnos&#357; clanu"border="0" align="absmiddle">
										&nbsp;						
										<select name="narod" >
											<option '.( $clan['narod']==2 ? 'selected="selected"' : '' ).' value="2">eu</option>
											<option '.( $clan['narod']==1 ? 'selected="selected"' : '' ).' value="1">cz</option>
											<option '.( $clan['narod']==0 ? 'selected="selected"' : '' ).' value="0">sk</option>
										</select>
									</td>
								  </tr>
								  <tr>
									<td colspan="2" align="center" class="cup_form_text">Popis</td>
								  </tr>  			
								  <tr>
									<td colspan="2" align="center" >
										<textarea class="cup_textarea" name="popis" maxlength="500" >'.DB::Vystup($clan['popis']).'</textarea>
									</td>
								  </tr>  		
								  <tr>
									<td colspan="2">&nbsp;</td>
								  </tr>
								  <tr>
									<td align="right">
										<input class="button" id="cup_button" type="submit" name="Submit" value="Upravi&#357;">	
										&nbsp;&nbsp;&nbsp;</form>
									</td>	
									<td align="center">
										<form action="" method="post">
										<input name="delete" type="hidden" value="1" />';
							echo "		<input class=\"button\" id=\"cup_button\" type=\"submit\" name=\"Submit\" value=\"Zmaza&#357;\" onclick=\"javascript:return confirm('Naozaj chce&scaron; zmaza&#357; clan ?')\" >";
							echo ' 	</td>
									</table>
							</form>';
							
							
	/*~~~~~~~~~~~~~~~~					
		Team Spravy					
	~~~~~~~~~~~~~~~~~~*/						


echo '	
	<br>
	<br>
		<form action="" method="post">
			<table width="520" cellspacing="0" cellpadding="0" class="tbl-border">
				<tr>
					<td align="left" colspan="2" class="capmain">Posla&#357; spr&aacute;vu cel&eacute;mu teamu</td>
				</tr>				
				<tr>
					<td align="right" class="tbl2">Predmet:</td>
					<td class="tbl1"><input type="text" class="textbox" maxlength="32" value="" name="predmet" /></td>
				</tr>
				<tr>
					<td valign="top" align="right" class="tbl2">Spr&aacute;va:</td>
					<td class="tbl1"><textarea class="textbox" rows="7" cols="80" name="sprava" ></textarea></td>
				</tr>
				<tr>
					<td valign="top" align="right" class="tbl2">&nbsp;</td>
					<td class="tbl1">';
				echo "	
					<input type=\"button\" onclick=\"addText('message', '[b]', '[/b]');\" Posla&#357; class=\"button\" value=\"b\"/>
					<input type=\"button\" onclick=\"addText('message', '[i]', '[/i]');\" style=\"font-style: italic; width: 25px;\" class=\"button\" value=\"i\"/>
					<input type=\"button\" onclick=\"addText('message', '[u]', '[/u]');\" style=\"text-decoration: underline; width: 25px;\" class=\"button\" value=\"u\"/>
					<input type=\"button\" onclick=\"addText('message', '[url]', '[/url]');\" style=\"width: 30px;\" class=\"button\" value=\"url\"/>
					<input type=\"button\" onclick=\"addText('message', '[mail]', '[/mail]');\" style=\"width: 35px;\" class=\"button\" value=\"mail\"/>
					<input type=\"button\" onclick=\"addText('message', '[img]', '[/img]');\" style=\"width: 30px;\" class=\"button\" value=\"img\"/>
					<input type=\"button\" onclick=\"addText('message', '[center]', '[/center]');\" style=\"width: 45px;\" class=\"button\" value=\"center\"/>
					<input type=\"button\" onclick=\"addText('message', '[small]', '[/small]');\" style=\"width: 40px;\" class=\"button\" value=\"small\"/>
					<input type=\"button\" onclick=\"addText('message', '[code]', '[/code]');\" style=\"width: 40px;\" class=\"button\" value=\"code\"/>
					<input type=\"button\" onclick=\"addText('message', '[quote]', '[/quote]');\" style=\"width: 45px;\" class=\"button\" value=\"quote\"/>
					<br/>
					<img onclick=\"insertText('message', ':)');\" alt=\"smiley\" src=\"/images/smiley/8.gif\"/>
					<img onclick=\"insertText('message', ';)');\" alt=\"smiley\" src=\"/images/smiley/2.gif\"/>
					<img onclick=\"insertText('message', ':|');\" alt=\"smiley\" src=\"/images/smiley/3.gif\"/>
					<img onclick=\"insertText('message', ':(');\" alt=\"smiley\" src=\"/images/smiley/17.gif\"/>
					<img onclick=\"insertText('message', ':o');\" alt=\"smiley\" src=\"/images/smiley/7.gif\"/>
					<img onclick=\"insertText('message', ':p');\" alt=\"smiley\" src=\"/images/smiley/6.gif\"/>
					<img onclick=\"insertText('message', 'B)');\" alt=\"smiley\" src=\"/images/smiley/14.gif\"/>
					<img onclick=\"insertText('message', ':D');\" alt=\"smiley\" src=\"/images/smiley/20.gif\"/>
					<img onclick=\"insertText('message', ':@');\" alt=\"smiley\" src=\"/images/smiley/5.gif\"/>
					<img onclick=\"insertText('message', ':4');\" alt=\"smiley\" src=\"/images/smiley/22.gif\"/>
					<img onclick=\"insertText('message', ':5');\" alt=\"smiley\" src=\"/images/smiley/13.gif\"/>
					";
			echo '	</td>
				</tr>
				<tr>
					<td align="center" colspan="2" class="tbl2"><input type="submit" class="button" value="Posla&#357;" /></td>
				</tr>				
			</table>
		</form>';
			
													
	// footer
			echo    '</div>
						<div align="center" class="cup_credits" ><br>&copy; Powered by Seky`s Liga System v'.SLS::verzia.'</div>	
						';	
					}	
					echo '</div>';		
				
				
				}								
		} else {
			echo SLS::MsgL('hodnost_nema', 1);
		}
	}
}

// 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++ ?>