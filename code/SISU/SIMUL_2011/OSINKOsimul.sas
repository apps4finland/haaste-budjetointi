/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyödyntää Tilastokeskuksen yleisten
* käyttöehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto päähakemistossa.
******************************************************************************/

/******************************************************************************
* Kuvaus: Osinkoverotuksen erillislaskelma
* Tekijä: Jukka Mattila / TK		   			           
* Luotu: 22.5.2013		     					   
* Viimeksi päivitetty: 22.5.2013 			 		   	   
* Päivittäjä: Jukka Mattila / TK			     		   
******************************************************************************/

/* Makro osinkojen sarjatason laskentaan.
	jaktyyppi: 	osinkoja jakaneen yhtiön tyyppi (noteerattu J/ei M)
	suorlaji: 	suorituslaji(osuuspääoman korko 02/osinko 01)
	osakelkm:	suorituksen saaneen sarjan osakkeiden lkm
	lkm:		yhtiön ulkona olevat osakkeet yhteensä
	netvar:		osakeomistuksen osuus yhtiön nettovarallisuudesta
	osinkoe:	maksettu osinko/osuuspääoman korko, euroa
	eilist_rajapros:	listaamattoman yhtiön osinkojen nettovarallisuusosuus
						verovapaille osingoille
	list_pros:	listattujen yhtiöiden osinkojen pääomaverotulon alainen osuus	
	eilist_pros:listaamattomien yhtiöiden nettovarallisuusrajan ylittävän
				osuuden ansiotuloveron alainen osuus
*/

%macro OsinkojenJakoErillis(
		jaktyypp, suorlaji, netvar, osinkoe,
		eilist_rajapros, list_pros, eilist_pros);

		/*=====================================================================
		Noteeraamattomat:
		---------------------------------------------------------------------*/
		if &jaktyypp = "M" and &suorlaji = '01' then do;

			RAJA = sum(&eilist_rajapros * &netvar);

		/*=====================================================================
		Alle X% matemaattisesta arvosta:
			- kaikki verovapaata
		---------------------------------------------------------------------*/
			if &osinkoe <= raja then do;
				EILIST_VAPM= &osinkoe;
			end;

		/*=====================================================================
		Yli X% matemaattisesta arvosta:
			- vapa (vapaata), eli alle jäävä osa
			- at eli ansiotulo-osuus Y%:a
			- vapy eli ylittävien vapaa-osuus 1-Y%:a.
		---------------------------------------------------------------------*/
			else if &osinkoe > raja then do;
				EILIST_VAPM = raja;
				EILIST_AT = (&osinkoe - raja) * &eilist_pros;
				EILIST_VAPY = (&osinkoe - raja) * (1-&eilist_pros);
			end;		

		/*=====================================================================
		Kaikki asetetaan eilistattujen bruttoon
		---------------------------------------------------------------------*/
			EILIST_BR = &osinkoe;

		end;

		/*=====================================================================
		Julkisesti noteeratut:
			- X%:a pääomatuloveron alaista, 1-X%a vapaata
		---------------------------------------------------------------------*/
		else if (&jaktyypp = "J" and &suorlaji = '01') 
			OR (&jaktyypp = '' and &suorlaji = '01')
			then do;
				LIST_BR = &osinkoe;
				LIST_POT = &list_pros * &osinkoe;
				LIST_VAPAA = (1-&list_pros) * &osinkoe;		
		end;			

		/*=====================================================================
		Osuuspääomien korot:
		---------------------------------------------------------------------*/
		else if &suorlaji = '02' then do;

			OSPKOR_BR = &osinkoe;

		end;

%mend OsinkojenJakoErillis;

/* Makro henkilötason osinkotulojen jaottelulle
EILIST_VAPM:	listaamattomien yhtiöiden osingot, alle X% 
				matemaattisesta nettovarallisuusarvosta
EILIST_VAPY:	listaamattomien yhtiöiden osingot, yli nettovarallisuusarvon,
				verovapaa osuus.
OSPKOR_BR		osuuspääoman korot, brutto
eilist_raja		listaamattomien yhtiöden nettovarallisuusarvon alittavien
				osinkojen verovapaa osuus.
eilist_ylipros	ym. verovapaan osuuden ylittävistä osingoista pääomatulo-osuus
osp_raja		osuuspääoman korkojen verovapauden raja
*/

%macro HenkiloJaottelu(eilist_vapm, eilist_vapy, ospkor_br, 
			eilist_raja, eilist_ylipros, osp_raja, osp_osuus);

		/*=====================================================================
		Jos noteeraamattomien yhtiöiden osinkojen vapaaprosentin alittavien
		yhteissumma ylittää kattorajan X euroa, tällöin:
			- raja + 1-X%:a rajan ylittävistä ovat vapaita.
			- vapaita myös pääomatulojen vapaa-osuus.
			- X%:a rajan ylittävistä ovat veronalaista pääomatuloa.
		---------------------------------------------------------------------*/
		if &eilist_vapm > &eilist_raja then do;
			EILIST_VAPP = (&eilist_vapm - &eilist_raja) * (1-&eilist_ylipros);
			EILIST_POT = (&eilist_vapm - &eilist_raja) * (&eilist_ylipros);
			EILIST_VAPAA = sum(EILIST_VAPP, &eilist_vapy);
			EILIST_YLIT = &eilist_vapm - &eilist_raja;
		end;

		/*=====================================================================
		Jos noteeraamattomien yhtiöiden vapaaprosentin alittavien yhteissumma
		alittaa kattorajan X euroa, tällöin:
			- kaikki ovat vapaita, pl. aiemmin mainittu AT-osuus.
		---------------------------------------------------------------------*/
		else if &eilist_vapm <= &eilist_raja then do;
			EILIST_VAPAA = sum(&eilist_vapm, &eilist_vapy);
			EILIST_POT = 0;
		end;

		/*=====================================================================
		Kattorajan alittava osa osuuspääoman koroista on verovapaata.
		---------------------------------------------------------------------*/
		if &ospkor_br <= &osp_raja then do;
			OSPKOR_VAPAA = &ospkor_br;
		end;

		/*=====================================================================
		Jos raja ylittyy, tällöin rajan verran vapaata, 
		ja rajan ylittävä osuus pääomatulona verotettavaa.
		---------------------------------------------------------------------*/
		if &ospkor_br > &osp_raja then do;
			OSPKOR_POT = (&ospkor_br-&osp_raja)*&osp_osuus;
			OSPKOR_VAPAA = SUM(&osp_raja, (&ospkor_br-&osp_raja)*(1-&osp_osuus));

		end;

%mend HenkiloJaottelu;


* Simuloinnin asetukset;
%let inf = 1;
%let mvuosi = 2011;
%let aineisto = rek;
%let lvuosi = 2011;
%let avuosi = 2011;
%let eilist_rajapros = .09;
%let eilist_pros = .7;
%let list_pros =.7;
%let eilist_raja = 90000;
%let eilist_ylipros = .7;
%let osp_raja = 1500;
%let osp_osuus = .7;
%let osdata = r11_osingot;
%let tulosnimi_osi = osingoterill;
%let paino = ykor;


data startdat.start_osinko; set pohjadat.&osdata;

%OsinkojenJakoErillis(
		jaktyypp, suorlaji, dmat, osinkoe,
		&eilist_rajapros, &list_pros, &eilist_pros);

	/*=========================================================================
	Osuuspääoman korot ja osingot, brutto
	-------------------------------------------------------------------------*/
	OSINGOT_BR = osinkoe;

run;

	/*=========================================================================
	2. Summaus henkilötasolle:
	-------------------------------------------------------------------------*/
	proc sql;
	create view temp.osingot_summa as select hnro,
		sum(OSINGOT_BR) as OSINGOT_BR,
		sum(EILIST_BR) as EILIST_BR,
		sum(EILIST_AT) as EILIST_AT,
		sum(EILIST_VAPY) as EILIST_VAPY,
		sum(EILIST_VAPM) as EILIST_VAPM,
		sum(LIST_BR) as LIST_BR,
		sum(LIST_POT) as LIST_POT,
		sum(LIST_VAPAA) as LIST_VAPAA,
		sum(OSPKOR_BR) as OSPKOR_BR
		
		from startdat.start_osinko
		group by hnro
		order by hnro;
	quit;

/*=============================================================================
Varsinainen simulointiohjelma:
3. Henkilötason laskelma
-----------------------------------------------------------------------------*/

data temp.osingot_simuloitu; set temp.osingot_summa;

	%HenkiloJaottelu(eilist_vapm, eilist_vapy, ospkor_br,
		&eilist_raja, &eilist_ylipros, &osp_raja, &osp_osuus);

		/*=====================================================================
		Verovapaiden osuuspääoman korkojen ja osinkotulojen summat.
		---------------------------------------------------------------------*/
		OSIN_VAPAA = sum(LIST_VAPAA, EILIST_VAPAA);
		OSU_VAPAA= sum(LIST_VAPAA, EILIST_VAPAA, OSPKOR_VAPAA);

	/*=========================================================================
	Nimeämiset
	-------------------------------------------------------------------------*/
	label 
	OSINGOT_BR = "Osingot ja osuuspääoman korot yhtensä"
	EILIST_BR = "Osingot noteeraamattomista yhtiöistä"
	EILIST_VAPM = "Noteeraamattomat yhtiöt, alle X%:n säännön"
	EILIST_VAPY = "Noteeraamattomat yhtiöt, yli X%:n säännön, verovapaa osuus"
	EILIST_AT = "Noteeraamattomat yhtiöt, yli X%:n säännön, ansiotuloveron alaine "
	EILIST_VAPP = "Noteeraamattomat yhtiöt, verovapaa osuus eurokaton ylittäneistä"
	EILIST_POT = "Noteeraamattomat yhtiöt, pääomatuloveron alainen katon yli"
	EILIST_VAPAA = "Noteeraamattomat yhtiöt, verovapaat osingot yhteensä"
	EILIST_YLIT = "Noteeraamattomat yhtiöt, eurokaton ylittäneet osingot yhteensä"
	LIST_BR = "Osingot julkisesti noteeratuista yhtiöistä"
	LIST_POT = "Osingot julkisesti noteeratuista yhtiöistä, pääomatuloveron alainen"
	LIST_VAPAA = "Osingot julkisesti noteeratuista yhtiöistä, verovapaa osuus"
	OSPKOR_BR = "Osuuspääoman korot kaikista yhtiöistä"
	OSPKOR_POT = "Osuuspääoman korot, pääomatuloveron alaiset"
	OSPKOR_VAPAA = "Osuuspääoman korot, verovapaat"
	OSIN_VAPAA = "Osingot, verovapaat"
	OSU_VAPAA = "Osingot ja osuuspääoman korot, verovapaat";

run;

/*=============================================================================
Output -taulu
-----------------------------------------------------------------------------*/
data output.&tulosnimi_osi;
	 merge pohjadat.&aineisto&avuosi
	 	(keep = hnro ykor teinoob teinova teinovab teinover teinovv teinovvb
			tnoosb tnoosvab tnoosver tnoosvvb tosjmb)
			temp.osingot_simuloitu;
	by hnro;
run;

proc means data = output.osingoterill sum; var OSINGOT_BR--OSU_VAPAA; weight ykor;run;
proc means data = output.osingoterill111 sum; var OSINGOT_BR--OSU_VAPAA; weight ykor;run;
