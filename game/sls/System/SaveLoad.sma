/*
	Tento plugin vytvoril Lukas Sekerak a jemu prinalezia vsetke prava.
	Je zakazane kopirovat tento program bez suhlasu autora.
	Je zakazane kopirovat sucasti programu a podprogramov.
	Copyright 2008-2011, Lukas Sekerak
*/
/*
		Ukladam: hraci - >pozicie hracov, ci zije, hp, armor, zbrane, pannazi, naboje k zbraniam, skore hracov
			Status sls ligy - > kol, status kol,
				pozicia v kode zhruba,...hltv ci je pripojene
				+ dodatocne informacie ako cas vytvorenia savu			
			status hry - > skore teamu, ci je plant, kolko casu do konca,..
			Ak ale robim save / load len na zaciatku kola tak polovicku z toho netreba. 
			
			
	txt je normalne citatelyn, binary je len akesi kodovanie ziadne vyhody to nema
	dobr ebude ak dam normalne oznacenia, na akzdy riadok nejaku hodnotu...
	ako v dolnom priklade, vela babracky ale treba
	
	
	amxmodx/save zlozka
	potom zlozka s nazvom id zapasu
	
	kazda cast bude mat vlastny subor
	player.txt pre hracov, riadok jeden hrac
	hra.txt
	sls.txt 

	
	Alebo zlozka amxmodx/zapas
	ID zapasu a potom zlozka save
	+ tam mozu byt aj logy
*/
