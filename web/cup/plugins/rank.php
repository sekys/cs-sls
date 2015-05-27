<? // 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++

$sql_pocet = SLS::Count2("SELECT COUNT(id) as pocet FROM `phpbanlist`.`acp_clans`");
	
echo '<div class="cup_body" align="center">';
if(SLSUser::$user['clan_id'] == false) {
	echo SLS::Msg( sprintf(SLSLang::Msg('reklama'), SLSROOT) );
}
echo '
<table class="cup_body" width="520" align="center" cellpadding="0" cellspacing="0">
	<tr>
		<th class="cup_nazov" > '.SLSLang::Msg('misc_rank').' </th>
		<th class="cup_nazov" > '.SLSLang::Msg('misc_meno').' </th>
		<th class="cup_nazov" > '.SLSLang::Msg('misc_hracov').' </th>
		<th class="cup_nazov" > '.SLSLang::Msg('misc_zapasov').' </th>
		<th class="cup_nazov" > '.SLSLang::Msg('misc_bodov').' </th>
	</tr>
';
if( $sql_pocet ) 
{
	/* Neda sa pouzit lebo inak vypocitava rank
	@$sql = DB::Query("SELECT id, meno, bodov, COALESCE(pocet_a, 0) + COALESCE(pocet_b, 0) AS zapasov, COALESCE(hracov,0) as hracov
							FROM `phpbanlist`.`acp_clans` c																		
								
								LEFT JOIN ( SELECT prijal, COUNT(prijal) AS pocet_a FROM `phpbanlist`.`cup_zapas` GROUP BY prijal ) a
									ON c.id = a.prijal								
								LEFT JOIN ( SELECT ziada, COUNT(ziada) AS pocet_b FROM `phpbanlist`.`cup_zapas` GROUP BY ziada ) b
									ON c.id = b.ziada																															
								
								LEFT JOIN ( SELECT clan_id, COUNT(user_id) AS hracov FROM `cstrike`.`fusion_users` GROUP BY clan_id ) h
									ON c.id = h.clan_id										
						ORDER BY bodov desc ".SLS::get_zoznam()."");							
	*/		
	@$sql = SLS::Query2("SELECT id, meno, bodov FROM `phpbanlist`.`acp_clans` ORDER BY bodov desc ".SLS::get_zoznam()."");		
	$rank = SLS::$zoznam;
	while($row=mysqli_fetch_assoc($sql)) 
	{ 
			$rank++; 
			echo '<tr name="miesto'.$rank.'" id="miesto'.$rank.'">'; 
				echo "<td class=\"cup_riadok\" width=\"30\" align=\"center\">";
				echo  SLSClan::ZoznamRank($rank);		
				echo "</td>";					
				echo "<td  class=\"cup_riadok\" width=\"300\" align=\"center\"><a title=\"".$rank.". ".SLSLang::Msg('misc_miesto')."\" href=\"".SLSPlugins::Adresa(5).$row['id']."/\" >";					
				echo (SLSUser::$user['clan_id'] == $row['id']) ? '<span style="color:blue;">' : '<span class="cup_clan">';
				echo DB::Vystup($row['meno']) . '<span></a></td>';
				echo "<td  class=\"cup_riadok\" width=\"60\" align=\"center\">" . SLS::Hracov($row['id']) . "</td>";
				echo "<td  class=\"cup_riadok\" width=\"60\" align=\"center\">" . SLS::Zapasov($row['id']) . "</td>";									
				echo "<td  class=\"cup_riadok\" width=\"90\" align=\"center\" style=\"color: rgb(".SLS::get_farba($row['bodov']).");\">" . $row['bodov'] . "</td>";
			echo '</tr>';
	} 
} else {
		echo '<tr>
				<td class="cup_riadok" width="40" align="center" colspan="5" >
					<em>'.SLSLang::Msg('clan_ziadne').' </em>
				</td>
			</tr>
			';	
}
echo '</table>
	'.SLS::set_zoznam( $sql_pocet).'
		<div align="center" class="cup_credits" ><br>&copy; Powered by Seky`s Liga System v'.SLS::verzia.'</div>
</div>	
';

// 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++ ?>