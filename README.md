##Popis
- Plne automatizova liga pre hru counter strike 1.6.
- Liga je napisana v Pawne ako plugin do amx mod modu.
- Projekt je z roku 2008, vytvoril som ho pre komunitu Gecom::Lekos.
- Boli vytvorene 2 hlavne verzie:
- 2.0 Bola uspesne spustena a otestovana pocas 1 roku komunitou hracov.
- 3.0 Obsahuje viacej vlastnosti, oprav avsak nebola dokoncena.

##Princip
Webova cast:
Hraci a admini vsetko spravuju na webe, dohodnu si cw (zapas). Poziadavka sa posle do databazi.
 
##Serverova cast:
 - Automaticky detekuje ci existuje zapas
 - Automaticky pripravy server, mapu, rezervuje cas
 - Caka na hracov, kontroluje ich identitu a pripadne ich pusti na server
 - Spusti automaticky knife, zapas, automaticky prehadzuje hracov, ukonci zapas a posle vysledok zapasu do databazy
 - Hracom automaticky zapina dema aj robi fotky
 - Obsahuje nejake prvky proti cheaterom
 - Hraci sa o nic nestaraju, nemusia pisat ziadne prikazy
 - Admin menu pre spravovanie servera a Clan leader menu pre spravovanie konkretneho zapasu, nastavenie pauzi
 - HLTV podporu
 

Vsetky casti su plne nastavovatelne cez konfiguracne casti. 
Mnohe vlastnosti tu ani neboli spomenute, viac v zdrojovych suboroch. 
Instalacia je jednoducha, je potrebne subory skopirovat a skompilovat pomocou 
amx mod x compileru.