/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hy�dynt�� Tilastokeskuksen yleisten
* k�ytt�ehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto p��hakemistossa.
******************************************************************************/

/******************************************************************************
* Kuvaus: Osinkoverotuksen erillislaskelma
* Tekij�: Jukka Mattila / TK		   			           
* Luotu: 22.5.2013		     					   
* Viimeksi p�ivitetty: 22.5.2013 			 		   	   
* P�ivitt�j�: Jukka Mattila / TK			     		   
******************************************************************************/

/* Makro osinkojen sarjatason laskentaan.
	jaktyyppi: 	osinkoja jakaneen yhti�n tyyppi (noteerattu J/ei M)
	suorlaji: 	suorituslaji(osuusp��oman korko 02/osinko 01)
	osakelkm:	suorituksen saaneen sarjan osakkeiden lkm
	lkm:		yhti�n ulkona olevat osakkeet yhteens�
	netvar:		osakeomistuksen osuus yhti�n nettovarallisuudesta
	osinkoe:	maksettu osinko/osuusp��oman korko, euroa
	eilist_rajapros:	listaamattoman yhti�n osinkojen nettovarallisuusosuus
						verovapaille osingoille
	list_pros:	listattujen yhti�iden osinkojen p��omaverotulon alainen osuus	
	eilist_pros:listaamattomien yhti�iden nettovarallisuusrajan ylitt�v�n
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
			- vapa (vapaata), eli alle j��v� osa
			- at eli ansiotulo-osuus Y%:a
			- vapy eli ylitt�vien vapaa-osuus 1-Y%:a.
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
			- X%:a p��omatuloveron alaista, 1-X%a vapaata
		---------------------------------------------------------------------*/
		else if (&jaktyypp = "J" and &suorlaji = '01') 
			OR (&jaktyypp = '' and &suorlaji = '01')
			then do;
				LIST_BR = &osinkoe;
				LIST_POT = &list_pros * &osinkoe;
				LIST_VAPAA = (1-&list_pros) * &osinkoe;		
		end;			

		/*=====================================================================
		Osuusp��omien korot:
		---------------------------------------------------------------------*/
		else if &suorlaji = '02' then do;

			OSPKOR_BR = &osinkoe;

		end;

%mend OsinkojenJakoErillis;

/* Makro henkil�tason osinkotulojen jaottelulle
EILIST_VAPM:	listaamattomien yhti�iden osingot, alle X% 
				matemaattisesta nettovarallisuusarvosta
EILIST_VAPY:	listaamattomien yhti�iden osingot, yli nettovarallisuusarvon,
				verovapaa osuus.
OSPKOR_BR		osuusp��oman korot, brutto
eilist_raja		listaamattomien yhti�den nettovarallisuusarvon alittavien
				osinkojen verovapaa osuus.
eilist_ylipros	ym. verovapaan osuuden ylitt�vist� osingoista p��omatulo-osuus
osp_raja		osuusp��oman korkojen verovapauden raja
*/

%macro HenkiloJaottelu(eilist_vapm, eilist_vapy, ospkor_br, 
			eilist_raja, eilist_ylipros, osp_raja, osp_osuus);

		/*=====================================================================
		Jos noteeraamattomien yhti�iden osinkojen vapaaprosentin alittavien
		yhteissumma ylitt�� kattorajan X euroa, t�ll�in:
			- raja + 1-X%:a rajan ylitt�vist� ovat vapaita.
			- vapaita my�s p��omatulojen vapaa-osuus.
			- X%:a rajan ylitt�vist� ovat veronalaista p��omatuloa.
		---------------------------------------------------------------------*/
		if &eilist_vapm > &eilist_raja then do;
			EILIST_VAPP = (&eilist_vapm - &eilist_raja) * (1-&eilist_ylipros);
			EILIST_POT = (&eilist_vapm - &eilist_raja) * (&eilist_ylipros);
			EILIST_VAPAA = sum(EILIST_VAPP, &eilist_vapy);
			EILIST_YLIT = &eilist_vapm - &eilist_raja;
		end;

		/*=====================================================================
		Jos noteeraamattomien yhti�iden vapaaprosentin alittavien yhteissumma
		alittaa kattorajan X euroa, t�ll�in:
			- kaikki ovat vapaita, pl. aiemmin mainittu AT-osuus.
		---------------------------------------------------------------------*/
		else if &eilist_vapm <= &eilist_raja then do;
			EILIST_VAPAA = sum(&eilist_vapm, &eilist_vapy);
			EILIST_POT = 0;
		end;

		/*=====================================================================
		Kattorajan alittava osa osuusp��oman koroista on verovapaata.
		---------------------------------------------------------------------*/
		if &ospkor_br <= &osp_raja then do;
			OSPKOR_VAPAA = &ospkor_br;
		end;

		/*=====================================================================
		Jos raja ylittyy, t�ll�in rajan verran vapaata, 
		ja rajan ylitt�v� osuus p��omatulona verotettavaa.
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
	Osuusp��oman korot ja osingot, brutto
	-------------------------------------------------------------------------*/
	OSINGOT_BR = osinkoe;

run;

	/*=========================================================================
	2. Summaus henkil�tasolle:
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
3. Henkil�tason laskelma
-----------------------------------------------------------------------------*/

data temp.osingot_simuloitu; set temp.osingot_summa;

	%HenkiloJaottelu(eilist_vapm, eilist_vapy, ospkor_br,
		&eilist_raja, &eilist_ylipros, &osp_raja, &osp_osuus);

		/*=====================================================================
		Verovapaiden osuusp��oman korkojen ja osinkotulojen summat.
		---------------------------------------------------------------------*/
		OSIN_VAPAA = sum(LIST_VAPAA, EILIST_VAPAA);
		OSU_VAPAA= sum(LIST_VAPAA, EILIST_VAPAA, OSPKOR_VAPAA);

	/*=========================================================================
	Nime�miset
	-------------------------------------------------------------------------*/
	label 
	OSINGOT_BR = "Osingot ja osuusp��oman korot yhtens�"
	EILIST_BR = "Osingot noteeraamattomista yhti�ist�"
	EILIST_VAPM = "Noteeraamattomat yhti�t, alle X%:n s��nn�n"
	EILIST_VAPY = "Noteeraamattomat yhti�t, yli X%:n s��nn�n, verovapaa osuus"
	EILIST_AT = "Noteeraamattomat yhti�t, yli X%:n s��nn�n, ansiotuloveron alaine "
	EILIST_VAPP = "Noteeraamattomat yhti�t, verovapaa osuus eurokaton ylitt�neist�"
	EILIST_POT = "Noteeraamattomat yhti�t, p��omatuloveron alainen katon yli"
	EILIST_VAPAA = "Noteeraamattomat yhti�t, verovapaat osingot yhteens�"
	EILIST_YLIT = "Noteeraamattomat yhti�t, eurokaton ylitt�neet osingot yhteens�"
	LIST_BR = "Osingot julkisesti noteeratuista yhti�ist�"
	LIST_POT = "Osingot julkisesti noteeratuista yhti�ist�, p��omatuloveron alainen"
	LIST_VAPAA = "Osingot julkisesti noteeratuista yhti�ist�, verovapaa osuus"
	OSPKOR_BR = "Osuusp��oman korot kaikista yhti�ist�"
	OSPKOR_POT = "Osuusp��oman korot, p��omatuloveron alaiset"
	OSPKOR_VAPAA = "Osuusp��oman korot, verovapaat"
	OSIN_VAPAA = "Osingot, verovapaat"
	OSU_VAPAA = "Osingot ja osuusp��oman korot, verovapaat";

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
