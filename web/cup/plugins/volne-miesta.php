<? // 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++


$sql_pocet = SLS::Count2("SELECT COUNT(id) as pocet FROM `phpbanlist`.`acp_clans` WHERE volne ='1'");
		
echo '<div class="cup_body" align="center">';

$reklama = 'Zoznam<br>clanov<br>s vo&#318;nym miestom... ';
if(SLSUser::$user['user_id'] == false) {
	$reklama .= '<br>Mus&iacute;&scaron; sa prihl&aacute;si&#357;';
} else {
	if(SLSUser::$user['cs_meno'] == false) {
		$reklama .= '<br>V profile zadaj &quot;Her&eacute; meno&quot; !';
	}
}
echo SLS::Msg($reklama);

echo '
<table class="cup_body" width="520" align="center" cellpadding="0" cellspacing="0">
	<tr>
		<th class="cup_nazov" > # </th>
		<th class="cup_nazov" > N&aacute;zov clanu </th>
		<th class="cup_nazov" > Hr&aacute;&#269;ov </th>
		<th class="cup_nazov" > Bodov </th>
		<th class="cup_nazov" > Pripoji&#357; </th>
	</tr>
';
if( $sql_pocet ) {

	@$sql = SLS::Query2("SELECT id, meno, bodov, COALESCE(hracov,0) as hracov, volne FROM `phpbanlist`.`acp_clans` c
							LEFT JOIN ( SELECT clan_id, COUNT(user_id) AS hracov FROM `cstrike`.`fusion_users` GROUP BY clan_id ) h
								ON c.id = h.clan_id									
						WHERE volne ='1' ORDER BY hracov desc ".SLS::get_zoznam().""
						);
					
	while($row=mysqli_fetch_assoc($sql)) 
	{ 
			echo '<tr> 
					<td class="cup_riadok" width="30" align="center">
						<a href="'.ROOT.'messages.php?msg_send='.SLSClan::FindLeader($row['id']).'">
							<img src="'.SLS::$STYLE.'sms.png" alt="Web Po&scaron;ta" title="Web Po&scaron;ta clanu" border="0" align="absmiddle">
						</a>
					</td>
					<td class="cup_riadok" width="300" align="center"><a class="cup_clan" href="'.SLSPlugins::Adresa(0).$row['id'].'/">';
				
				if(SLSUser::$user['clan_id'] == $row['id'])
				{
					echo '<span style="color:blue;">'.DB::Vystup($row['meno']) . '<span></a></td>';
				} else {
					echo '<span class="cup_clan">'.DB::Vystup($row['meno']) . "</span></a></td>";
				}
				echo '<td  class="cup_riadok" width="50" align="center">' . $row['hracov'] . '</td>';
				echo "<td  class=\"cup_riadok\" width=\"60\" align=\"center\" style=\"color: rgb(".SLS::get_farba($row['bodov']).");\">" . $row['bodov'] . "</td>";
				echo '<td class="cup_riadok" width="40" align="center">
						<a href="'.SLSPlugins::Adresa(8).$row['id'].'/">
							<img src="'.SLS::$STYLE.'right.png" alt="Vs&uacute;pi&#357;" title="Vs&uacute;pi&#357; do clanu." border="0" align="absmiddle">
						</a>
					</td>
				</tr>';
	} 
} else {
	echo '		<tr>
					<td class="cup_riadok" width="40" align="center" colspan="5">
							<em>&#381;iadne vo&#318;n&eacute; miesta..... </em>
					</td>
				</tr>';
}	
echo '</table>';
echo SLS::set_zoznam($sql_pocet);
echo '<div align="center" class="cup_credits" ><br>&copy; Powered by Seky`s Liga System v'.SLS::verzia.'</div>';

// 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++	?>