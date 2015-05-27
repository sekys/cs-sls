<? // 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++
	
	echo '
		<div class="cup_body" align="left">
			<img src="', SLS::$STYLE, 'liga-bg.png" alt="logo" border="0" />
			<script type="text/javascript">
				$(document).ready(function(){
					$("#tabs").tabs();
				});
			</script>

			<div id="tabs" style="color: #999;width:500px;">
				<ul class="tabs_zoznam">
					<li><a href="#liga">O lige</a></li>
					<li><a href="#navod">Za&#269;iatok</a></li>
					<li><a href="#cl">Clan Leader</a></li>
					<li><a href="#hodnosti">Hodnosti</a></li>
					<li><a href="#zapas">Z&aacute;pas</a></li>
					<li><a href="#ceny">Ceny</a></li>
					<li><a href="#bonus">Bonusy</a></li>
				</ul>
				
				
				
<div id="liga">
<pre>	

Tak&#382;e za&#269;al by som t&yacute;m &#382;e t&aacute;to liga iba za&#269;&iacute;na, je to novy m&oacute;d
na ligu ktor&yacute; vyrobil Seky. Liga sa postupne dokon&#269;&iacute;, podopl&#328;uje, 
ak by ste na&scaron;li nejak&uacute; chybu tak sa ospravedl&#328;ujem vopred.
Sekyho m&ocirc;&#382;e kedyko&#318;vek v lige nie&#269;o doplni&#357; doda&#357; upravi&#357; .
.... ak by sa tak stane budete o tom informovan&yacute;.
 
Na&scaron;a liga funguje na podobnom princ&iacute;pe ako hern&eacute; str&aacute;nky v
ktor&yacute;ch clan alebo gang predstavuje skupinku &#318;ud&iacute; 
s rovnak&yacute;m cie&#318;om, &quot;by&#357; najlep&scaron;&iacute;&quot;. 

Gecom cup nem&aacute; presne ur&#269;en&yacute; po&#269;et hr&aacute;&#269;ov ako maj&uacute; 
in&eacute; ligy (2 on 2), u n&aacute;s m&ocirc;&#382;e ma&#357; clan nekone&#269;ne ve&#318;a 
hr&aacute;&#269;ov a hra&#357; sa m&ocirc;&#382;e aj 16 on 16.

Ka&#382;d&yacute; ligov&yacute; z&aacute;pas sa m&ouml;&#382;e odohra&#357; v ur&#269;ity &#269;as, obom stranam
vyhovuj&uacute;ci. Clan (clan leader) poda &#382;iados&#357; (v&yacute;zvu) a ostatne clany 
ju m&ouml;&#382;u prija&#357;, ak im patri&#269;n&yacute; d&aacute;tum / hodina vyhovuje.
			
Server sa automaticky pred zap&aacute;som zapne, n&aacute;jde aktualny z&aacute;pas ,
v&scaron;etko s&aacute;m priprav&yacute; (bez adminov),po&#269;k&aacute; si na 
hr&aacute;&#269;ov a za&#269;ne clan war.
			
Po&#269;as z&aacute;pasu spravuje hr&aacute;&#269;ov a ich t&iacute;my ,upravuje 
quotu (x on x) a povol&iacute; aj n&aacute;v&scaron;tevn&iacute;kom pr&iacute;s&#357; sa pozrie&#357; na z&aacute;pas.
			
Za ka&#382;d&yacute; z&aacute;pas vyhrat&yacute;, alebo aj prehraty, clan dostane body.
Body sa automaticky vypo&#269;itavaju pod&#318;a naro&#269;nosti.

Taktie&#382; si s&aacute;m nahr&aacute;va priebeh hry, teda po z&aacute;pase je mo&#382;n&eacute;,
si na webe pozrie&#357; cel&yacute; z&aacute;pas.
', 
SLS::Msg("Tento projekt vznikol v spolupr&aacute;ci s GeCom s.r.o.<br>&copy; Luk&aacute;&scaron; Seker&aacute;k<br>V&scaron;etke pr&aacute;va vyhraden&eacute;.", 1), 
'Posledn&eacute; zmeny:
...ve&#318;a opr&aacute;v  a zmien :)
<br>
</pre>
</div>


<div id="navod">
<pre>	


<span style="color: red;"><b>// Za&#269;iatok</b></span>
Ak sa chcete zapoji&#357; do GeCom Cup ligy ,mus&iacute;te ma&#357; vyplnen&eacute;
<strong>HERN&Eacute; MENO</strong> a to si nastavi&scaron; na str&aacute;nke <a href="http://www.cs.gecom.sk/edit_profile.php">UPRAVI&#356; PROFIL</a>
<img src="images/articles/liga_nav_hrac_men.jpg" >
.......a nezabudnite zopakova&#357; heslo aby sa V&aacute;m meno ulo&#382;ilo.
<img src="images/articles/liga_nav_ov_hesla.jpg" >
Po vyplnen&iacute; t&yacute;chto &uacute;dajov sa automaticky zapoji&scaron; do ligov&eacute;ho syst&eacute;mu.

<span style="color: red;"><b>// Vytvorenie klanu</b></span>
Hore v menu si nastav&iacute;te s kurzorom na <b>GeCom Cup</b> zobraz&iacute; sa V&aacute;m
ligov&aacute; ponuka (panel). Tak na za&#269;iatok m&aacute;te v ponuke <b>VYTVORI&#356; KLAN</b>

<b><span style="color:blue;">N&aacute;zov klanu:</span></b> Ni&#269; zlo&#382;it&eacute;, bez znakov (napr. GecLek) 
<b><span style="color:blue;">Klan tag:</span></b> Je to n&aacute;zov, tag klanu ktor&yacute; ho &scaron;pecifikuje
		a mus&iacute; by&#357; pou&#382;it&yacute; v hre (napr. [G/L]).
<span style="color:blue;"><b>Popis:</b></span> M&ocirc;&#382;ete, ale nie je povinn&yacute;. <span style="color:red;">ZAK&Aacute;ZAN&Aacute; JE AK&Aacute;KO&#317;VEK REKLAMA!</span>

<span style="color:red;"><b>// Odchod z KLANU</b></span>
Ak ste sa rozhodli, &#382;e chcete vyst&uacute;pi&#357; z klanu (opusti&#357; klan)
tak si to nastavte vo svojom profile.
Tak&#382;e <b><a href="http://www.cs.gecom.sk/edit_profile.php" >UPRAVI&#356; PROFIL</a></b> a <span style="color:blue;">Za&scaron;krtnete pol&iacute;&#269;ko:</span>
<img src="images/articles/liga_nav_od_s_klan.jpg" >
A zasa <span style="color:blue;">Overenie hesla</span>:
<img src="images/articles/liga_nav_ov_hesla.jpg">
Potvrdi&#357;, <b>aktualizova&#357; profil</b>.

</pre>
</div>


<div id="cl">
<pre>	

<span style="color: red;"><b>Tento n&aacute;vod je len pre CLAN LEADEROV a 
pre hr&aacute;&#269;ov ,ktor&iacute; maj&uacute; hodnos&#357; s pr&aacute;vamy. </b></span>

<span style="color:red;"><b>// Nastavenia</b></span>
Ako aj pri registr&aacute;ci&iacute; klanu, tak aj pri jeho &uacute;prave,
v <b>nastaveniach</b> zad&aacute;vate <b>N&aacute;zov klanu, Clan tag</b>.
&#270;al&scaron;ou nepovinnou funkciou v nastaveniach klanu je mo&#382;nos&#357;
pridania <b><span style="color:blue;">avataru</span></b> clanu. Sta&#269;&iacute; ak zad&aacute;te cestu (adresu) k obr&aacute;zku 
(napr. <span style="color:blue;">http://www.cs.gecom.sk/images/liga/no_avatar.jpg</span>).

M&ocirc;&#382;ete si zvoli&#357; &#269;i budete, alebo nebudete <b>Steam klan</b>.
sta&#269;&iacute; jednoducho za&scaron;krtn&uacute;&#357;. Takisto za&scaron;krtnut&iacute;m si m&ocirc;&#382;ete
zvoli&#357; &#269;i m&aacute;te <b>vo&#318;ne miesto </b> v klane alebo nie.
(aby hr&aacute;&#269;i posielali svoje &#382;iadosti o p&ocirc;sobenie vo Va&scaron;om klane).
Taktie&#382; si znova m&ocirc;&#382;te zmeni&#357; <strong>popis clan</strong>, ak to v&scaron;etko m&aacute;te
tak kliknete na <span style="color:blue;">Submit</span>.

<span style="color:red;"><b>// Spr&aacute;va hr&aacute;&#269;ov</b></span><strong><span class="style1">
</span></strong>Ke&#271; si kliknete na <b>spr&aacute;vu hr&aacute;&#269;ov</b>, tak tam m&aacute;te tabu&#318;ku,
v ktorej sa nach&aacute;dzaj&uacute; &#269;lenovia tvojho klanu, je to jednoduch&aacute;
&uacute;prava klanu <b>prida&#357;/vymaza&#357;</b> hr&aacute;&#269;a. Pod tabu&#318;kou sa nach&aacute;dza 
vyh&#318;ad&aacute;vanie hr&aacute;&#269;ov, v ktorom si m&ocirc;&#382;ete n&aacute;js&#357; hr&aacute;&#269;a, 
ktor&yacute; je registrovan&yacute; na webe a posla&#357; mu pozv&aacute;nku do klanu,
ktor&aacute; mu pr&iacute;de web-po&scaron;tou.Funkcia sp&aacute;va hr&aacute;&#269;ov obsahuje
e&scaron;te panel kde m&ocirc;&#382;ete prida&#357; <b>HODNOS&#356;</b> hr&aacute;&#269;ovy.

<a href="http://www.cs.gecom.sk/cup.php#hodnosti"><img src="http://www.cs.gecom.sk/images/sprava_hrac.jpg" border="0" width="450" height="170"/> 
Legenda hodnosti... </a>

<span style="color:red;"><b>// Moje v&yacute;zvy</b></span>
Ak ste sa rozhodli, &#382;e si chcete zahra&#357; z&aacute;pas a neviete si
vybra&#357; s&uacute;pera tak mus&iacute;te poda&#357; v&yacute;zvu.

P&ocirc;jdete do menu <strong>GeCom Cup</strong> a tam si vyberiete <b>MOJE V&Yacute;ZVY</b>
zobraz&iacute; sa V&aacute;m menu, ktor&eacute; pod&#318;a seba vypln&iacute;te.

D&aacute;tum, &#269;as, mapa. Ak to budete ma&#357; vyplnen&eacute;, tak kliknete na <b>prida&#357;.</b>
Va&scaron;a ponuka bude spracovan&aacute; a umiestnen&aacute; v hornej &#269;asti str&aacute;nky
ako <b>V&yacute;zvy</b>. Ak ju niekto prijme, tak V&aacute;m a v&scaron;etk&yacute;m &#269;lenom klanu
pr&iacute;de spr&aacute;va na z&aacute;pas.

<span style="color:red;"><b>// Moje v&yacute;zvy</b></span>
Ak ste sa rozhodli, &#382;e si chcete zahra&#357; z&aacute;pas a neviete si
vybra&#357; s&uacute;pera tak mus&iacute;te poda&#357; v&yacute;zvu.

P&ocirc;jdete do menu <strong>GeCom Cup</strong> a tam si vyberiete <b>MOJE V&Yacute;ZVY</b>
zobraz&iacute; sa V&aacute;m menu, ktor&eacute; pod&#318;a seba vypln&iacute;te.

D&aacute;tum, &#269;as, mapa. Ak to budete ma&#357; vyplnen&eacute;, tak kliknete na <b>prida&#357;.</b>
Va&scaron;a ponuka bude spracovan&aacute; a umiestnen&aacute; v hornej &#269;asti str&aacute;nky
ako <b>V&yacute;zvy</b>. Ak ju niekto prijme, tak V&aacute;m a v&scaron;etk&yacute;m &#269;lenom klanu
pr&iacute;de spr&aacute;va na z&aacute;pas.

<span style="color:red;"><b>// Pr&aacute;va v hre</b></span> Ak m&aacute;te dostato&#269;n&eacute; pr&aacute;va tak m&ocirc;&#382;te v hre vyu&#382;i&#357; pr&aacute;va.
Tieto pr&aacute;va niesu ako admisnk&eacute;!
Pohodlne po&#269;as hry stla&#269;&iacute;te <span style="color:red;"><b>F7</b></span> a uk&aacute;&#382;e sa V&aacute;m
Clan Leader Panel,kde m&ocirc;&#382;te spravova&#357;  hr&aacute;&#269;ov ....
</pre>
</div>



<div id="hodnosti">	
<pre>	

Ka&#382;dy clan ma "clan leadera", ktor&yacute; spravuje clan,
pr&iacute;jma v&yacute;zvy, pr&iacute;jma a odstra&#328;uje hra&#269;ov...
&#268;len clanu od clan leadera m&ocirc;&#382;e dosta&#357; &scaron;pecialnu hodnos&#357;
Viac legenda....

Hodnosti s&uacute; dobr&eacute; ale aj zl&eacute;.
Dobr&eacute; hodnosti ako z&aacute;stupca clan leader maj&uacute; r&ocirc;zne
privil&eacute;gia ,m&ocirc;&#382;u spravovat hr&aacute;&#269;ov a pod.
Zl&eacute; hodnosti m&ocirc;&#382;e clan leader pou&#382;i&#357; na potrestanie hr&aacute;&#269;a.
</pre>
<br>
<table class="cup_body" width="400" align="center" cellpadding="0" cellspacing="0">
	<tr>
		<th class="cup_nazov" colspan="2"> Legenda hodnosti   </th>
	</tr>
		<tr> 
			<td class="cup_riadok" align="center" ><strong>Hodnos&#357;</strong></td>
			<td class="cup_riadok" align="center" ><strong>Pr&aacute;va</strong></td>
		</tr>	
		<tr>
			<td class="cup_riadok"  align="center">Clan Leader</td>
			<td class="cup_riadok"  align="center">Zakladate&#318; clanu,m&aacute; v&scaron;etk&eacute; pr&aacute;va. </td>
		</tr>			
		<tr>
			<td class="cup_riadok"  align="center">Z&aacute;stupca CL</td>
			<td class="cup_riadok"  align="center">M&aacute; v&scaron;etk&eacute; pr&aacute;va.</td>
		</tr>				
		<tr>
			<td class="cup_riadok"  align="center">Spr&aacute;vca hr&aacute;&#269;ov</td>
			<td class="cup_riadok"  align="center">Spravuje len hr&aacute;&#269;ov.</td>
		</tr>			
		<tr>
			<td class="cup_riadok"  align="center">Hr&aacute;&#269;</td>
			<td class="cup_riadok"  align="center">-</td>
		</tr>				
		<tr>
			<td class="cup_riadok"  align="center">Rusher</td>
			<td class="cup_riadok"  align="center">Ozna&#269;enie v hre ,bez pr&aacute;v ... </td>
		</tr>			
		<tr>
			<td class="cup_riadok"  align="center">Camper</td>
			<td class="cup_riadok"  align="center">Ozna&#269;enie v hre ,bez pr&aacute;v ... </td>
		</tr>				
		<tr>
			<td class="cup_riadok"  align="center">Skiller</td>
			<td class="cup_riadok"  align="center">Ozna&#269;enie v hre ,bez pr&aacute;v ... </td>
		</tr>			
		<tr>
			<td class="cup_riadok"  align="center">Sniper</td>
			<td class="cup_riadok"  align="center">Ozna&#269;enie v hre ,bez pr&aacute;v ... </td>
		</tr>					
		<tr>
			<td class="cup_riadok"  align="center">Lama Clanu</td>
			<td class="cup_riadok"  align="center">Sl&uacute;&#382;i na potrestanie hr&aacute;&#269;a.</td>
		</tr>			
	</table>		
</div>


<div id="zapas">
<pre>	

<span style="color:red;"><b>// Servery</b></span>
IP adresa #1: cs.gecom.sk:27018     alebo      85.237.232.36:27018
IP adresa #2: cs.gecom.sk:27021     alebo      85.237.232.36:27021
HLTV :        cs.gecom.sk:27019     alebo      85.237.232.36:27019

<span style="color:red;"><b>// Pripojenie </b></span>
Ak V&aacute;m u&#382; niekto prijal v&yacute;zvu, jednoducho pr&iacute;&#271;te na server v
dohodnutom d&aacute;tume a hodine.Najprv si v&scaron;ak skontrolujte <strong>HERN&Eacute; MENO</strong>,
ktore mus&iacute; by&#357; toto&#382;n&eacute; s t&yacute;m ,ktor&eacute; pou&#382;&iacute;vate v hre.

<span style="color:red;"><b>// Heslo</b></span>
-Len ak ste &#269;lenom clanu mus&iacute;te zada&#357; heslo !
-Heslo n&aacute;jdete v spr&aacute;ve o z&aacute;pase.
-Toto heslo je nastaven&eacute; len na va&scaron;e <strong>HERN&Eacute; MENO</strong>.
-Ka&#382;d&yacute; &#269;len clanu ma in&eacute; heslo !
-HERN&Eacute; HESLO si nastavujete v profile
-Je zakazan&eacute; poskytova&#357; va&scaron;e heslo 3. osobe,
  za poru&scaron;enie zma&#382;eme &uacute;&#269;et.

Heslo v&#382;dy zadavate pred pripojen&iacute;m na server !
Heslo v&#382;dy zadavate do konzole v tvare:
<span style="color:red;"><b>setinfo heslo VA&Scaron;EHESLO</b></span>

Pr&iacute;klad:
V spr&aacute;ve V&aacute;m pri&scaron;lo ,&#382;e va&scaron;e heslo je <strong>123</strong>
Zapnite hru ,potom konzolu a nap&iacute;&scaron;ete :
<span style="color:red;"><b>setinfo heslo 123</b></span>
Potvrd&iacute;te enterom a pripoj&iacute;te sa...

Ak heslo nezadate spr&aacute;vne system V&aacute;s nepust&iacute; &#271;alej.

<span style="color:red;"><b>// &Scaron;tart</b></span>
Na servery po&#269;k&aacute;te na s&uacute;perov ,a ak bude dostato&#269;n&yacute; po&#269;et hr&aacute;&#269;ov,
server zapne CW. Na za&#269;iatku CW sa odohraje <strong>5</strong> cvi&#269;n&yacute;ch k&ocirc;l,
pri ktor&yacute;ch m&ocirc;&#382;ete pou&#382;&iacute;va&#357; v&scaron;etk&eacute; zbrane !

Po cvi&#269;n&yacute;ch kol&aacute;ch si hr&aacute;&#269; s najlep&scaron;&iacute;m sk&oacute;re vyberie team,
za ktor&yacute; bude hra&#357; jeho clan. Po v&yacute;bere teamu sa za&#269;ne CW na ostro,
kde sa po&#269;&iacute;ta obtia&#382;nos&#357; z&aacute;pasu, bonus clanov a sk&oacute;re teamov.

V polovi&#269;ke hry sa teamy prehodia, a znova pokra&#269;uj&uacute; v hre.
Na konci CW sa zap&iacute;&scaron;e sk&oacute;re do tabu&#318;ky clanov a
v&yacute;sledok so &scaron;tatistikamy prid&aacute; na web.

Re&scaron;tart kola v na&scaron;ej lige nepotrebujeme...

<span style="color:red;"><b>// Priebeh hry
</b></span>Po&#269;as hry sa neust&aacute;le upravuje quota hr&aacute;&#269;ov.
Teda ak v polovi&#269;ke hry pr&iacute;de &#269;len clanu A a &#269;len clanu B,
hr&aacute;&#269;i sa pripoja do hry a pokra&#269;uje sa norm&aacute;lne &#271;alej....

Taktie&#382; po&#269;as z&aacute;pasu sa na server m&ocirc;&#382;u pripoji&#357; aj div&aacute;ci.
M&ocirc;&#382;u to spravi&#357; cez HLTV, alebo klasicky ako spectator.
Server po&#269;as z&aacute;pasu nie je zaheslovan&yacute;...

<span style="color:red;"><b>// Pozn&aacute;mka</b></span>
Po&#269;as z&aacute;pasu mo&#382;te vyu&#382;i&#357; pomocku /stav,
kde V&aacute;m vyp&iacute;&scaron;e aktualny stav serveru,
z&aacute;pasu aaktualne sk&oacute;re.  <span style="color:red;">/stav</span> p&iacute;&scaron;ete do chatu

</pre>
</div>



<div id="ceny">
<pre>

Moment&aacute;lne prebieha: <strong>1. kolo</strong>
Koniec kola : <strong>1. Semptembra</strong>

&#268;lenovia v&iacute;&#357;azn&eacute;ho clanu z&iacute;skaju VIP na 6 mesiacov,
clan leader z&iacute;ska  cenu v hodnote<strong> 20 eur</strong>, 
ktor&uacute; si s&aacute;m m&ocirc;&#382;e vybra&#357; z <a href="http://eshop.gecom.sk/">GeCom eShopu</a>
a clan samotn&yacute; 15% bonus do nov&eacute;ho kola.

<strong>2.</strong> Najlep&scaron;&iacute; clan z&iacute;ska 10% bonus
do nov&eacute;ho kola.

<strong>3.</strong> Clan z&iacute;ska 5% bonus .

<span style="color:red;"><b>// Pozn&aacute;mka</b></span>
&#268;len clanu m&ocirc;&#382;e vyhra&#357; cenu len
ak odohral v&auml;&#269;&scaron;inu z&aacute;pasov.

H&#318;adame &scaron;tedr&eacute;ho sponzora, ktor&yacute; by
venoval do s&uacute;&#357;a&#382;e cenu !
</pre>
</div



<div id="bonus">
<pre>

Bonusy pridavaj&uacute; clanu mo&#382;nos&#357; z&iacute;skat viacej bodov za ka&#382;d&yacute; z&aacute;pas.
Existuju r&ocirc;zne typy bonusov, kladn&eacute; aj z&aacute;porne, bonusy
pre clany ale aj bonusy pre hr&aacute;&#269;ov.

Ak hr&aacute;&#269; m&aacute; bonus a je v nejakom clane, tento bonus sa
pripo&#269;it&aacute; pre hr&aacute;&#269;ov clan. Preto je dobre ma&#357; skillerov
v clane ale aj hr&aacute;&#269;ov odmenen&yacute;my bonusmy.

Bonus slu&#382;i ako odmena za nie&#269;o alebo vystihuje
dan&yacute; clan.Viac typy bonusov....

</pre>
</div>
</div>
<div align="center" class="cup_credits" ><br>&copy; Powered by Seky`s Liga System v'.SLS::verzia.'</div></div>';
// 	++++++++++++++++++++++++++++++++++++++++++++ Seky`s Liga System ++++++++++++++++++++++++++++++++++++++++++++++++++	?>