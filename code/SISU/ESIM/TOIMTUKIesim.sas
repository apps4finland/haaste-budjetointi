/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyödyntää Tilastokeskuksen yleisten
* käyttöehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto päähakemistossa.
******************************************************************************/

/***********************************************************
* Kuvaus: Toimentulotuen esimerkkilaskelmien pohja         *
* Tekijä: Elina Ahola / KELA		                	   *
* Luotu: 20.12.2011				       					   *
* Viimeksi päivitetty: 30.12.2011			     		   *
* Päivittäjä: Elina Ahola / KELA			     		   *
***********************************************************/ 

/* 1. Esimerkkilaskentaa ohjaavat makromuuttujat */

%MACRO Aloitus;

%LET TYYPPI = ESIM;	* Parametrien hakutapa, aina ESIM ;

/* Jos mallia käytetään käyttöliittymästä (&EG = 1), niin seuraavia vaiheita ei ajeta */

%IF &EG NE 1 %THEN %DO;

%LET TULOSNIMI_TO = toimtuki_esim_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;
%LET VUOSIKA = 1; 				* 1 = Vuosikeskiarvo, 2 = datassa annetun kuukauden lainsäädäntö ;
%LET VALITUT =  _ALL_; 			* Tulostaulukossa näytettävät muuttujat ;

* Inflaatiokorjaus. Parametrien deflatoinnissa käytettävän kertoimen voi syöttää itse
  INF-makromuuttujaan (HUOM! desimaalit erotettava pisteellä .). Jos puolestaan haluaa käyttää automaattista 
  elinkustannusindeksiin perustuvaa parametrien muunnoskerrointa, 
  tulee INF-makromuuttujalle antaa arvoksi 999.
  Tällöin on annettava myös perusvuosi, johon aineiston lainsäädäntövuotta verrataan; 	

%LET INF = 1.00; * Syötä arvo tai 999 ;
%LET AVUOSI = 2012; * Perusvuosi inflaatiokorjausta varten ;
%LET PINDEKSI_VUOSI = pindeksi_vuosi; * Käytettävä indeksien parametritaulukko ;

* Laki- ja apumakro-ohjelmien ajon säätäminen ; 

%LET LAKIMAKROT = 1;    * Lakimakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
%LET LAKIMAK_TIED_TO = TOIMTUKIlakimakrot;	* Lakimakroissa käytettävän tiedoston nimi ;
%LET APUMAKROT = 1;   	* Apumakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
%LET APUMAK_TIED_TO = TOIMTUKIapumakrot; * Apumakroissa käytettävän tiedoston nimi ;
%LET EXCEL = 1; 		 * Viedäänkö tulostaulukko automaattisesti Exceliin (1 = Kyllä, 0 = Ei) ;

* Käytettävien parametritiedostojen nimet ;

%LET PTOIMTUKI = ptoimtuki;
%LET POPINTUKI = popintuki;

%END;

%MEND Aloitus;

%Aloitus;


/* 2. Tällä makrolla säädellään laki- ja apumakro-ohjelmien ajoa. 
	  Jos makrot on jo tallennettu tai otettu käyttöön, makro-ohjelmia ei ole pakko ajaa uudestaan. 
	  C-funktioita käytettäessä SASCBTBL-määritys on joka tapauksessa pakko tehdä. */

%MACRO TeeMakrot;

%IF &F = C %THEN %DO;
	FILENAME SASCBTBL "&LEVY&KENO&HAKEM&KENO.JUTTA&KENO.juttamodul.txt";
%END;

/* Ajetaan lakimakrot ja tallennetaan ne (optio) */

%IF (&LAKIMAKROT = 1 AND &F = C) %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.JUTTA&KENO.juttafunkc.sas";
%END;

%ELSE %IF (&LAKIMAKROT = 1 AND &F = S) %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_TO..sas";
%END;

/* Ajetaan apumakrot ja tallennetaan ne (optio) */

%IF &APUMAKROT = 1 %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&APUMAK_TIED_TO..sas";
%END;

%MEND TeeMakrot;

%TeeMakrot;


/* 3. Määritellään datan generointia ohjaavat makromuuttujat */

%MACRO Generoi_Muuttujat;

/* Jos mallia käytetään käyttöliittymästä (&EG = 1), niin seuraavia vaiheita ei ajeta */

%IF &EG NE 1 %THEN %DO;

/* 3.1. Esimerkissä käytettävä data */

* Lainsäädäntövuosi (1989-);
%LET MINIMI_TOIMTUKI_VUOSI = 2012;
%LET MAKSIMI_TOIMTUKI_VUOSI = 2012;

* Lainsäädäntökuukausi (1-12);
%LET MINIMI_TOIMTUKI_KUUK = 12;
%LET MAKSIMI_TOIMTUKI_KUUK = 12;

* Toimeentulotuen kuntaryhmä (1/2);
%LET MINIMI_TOIMTUKI_KRYHMA = 1;
%LET MAKSIMI_TOIMTUKI_KRYHMA = 1;

* 18-v. täyttäneiden lkm (pl. 18-v. täyttäneet lapset);
%LET MINIMI_TOIMTUKI_AIK = 1;
%LET MAKSIMI_TOIMTUKI_AIK = 2;

* 18-v. täyttäneiden lasten lkm;
%LET MINIMI_TOIMTUKI_AIKLAPSIA = 0;
%LET MAKSIMI_TOIMTUKI_AIKLAPSIA = 0;

* 17-v. lasten lkm;
%LET MINIMI_TOIMTUKI_LAPSIA17 = 0;
%LET MAKSIMI_TOIMTUKI_LAPSIA17 = 0;

* 10-16-v. lasten lkm;
%LET MINIMI_TOIMTUKI_LAPSIA10_16 = 0;
%LET MAKSIMI_TOIMTUKI_LAPSIA10_16 = 0;

* Alle 10-v. lasten lkm;
%LET MINIMI_TOIMTUKI_LAPSIAALLE10 = 0;
%LET MAKSIMI_TOIMTUKI_LAPSIAALLE10 = 0;

* Lapsilisän määrä (e/kk) ;
%LET MINIMI_TOIMTUKI_LAPSILISAT = 0;
%LET MAKSIMI_TOIMTUKI_LAPSILISAT = 0;
%LET KYNNYS_TOIMTUKI_LAPSILISAT = 10;

* Palkkatulot (e/kk) ;
%LET MINIMI_TOIMTUKI_TYOTULO = 0;
%LET MAKSIMI_TOIMTUKI_TYOTULO = 0;
%LET KYNNYS_TOIMTUKI_TYOTULO = 500;

* Muut tulot (e/kk) ;
%LET MINIMI_TOIMTUKI_MUUTTULOT = 0;
%LET MAKSIMI_TOIMTUKI_MUUTTULOT = 1000;
%LET KYNNYS_TOIMTUKI_MUUTTULOT = 200;

* Asumismenot (e/kk) ;
%LET MINIMI_TOIMTUKI_ASMENOT = 500;
%LET MAKSIMI_TOIMTUKI_ASMENOT = 500;
%LET KYNNYS_TOIMTUKI_ASMENOT = 100;

* Harkinnanvaraiset menot (e/kk)  ;
%LET MINIMI_TOIMTUKI_HARKMENOT = 0;
%LET MAKSIMI_TOIMTUKI_HARKMENOT = 0;
%LET KYNNYS_TOIMTUKI_HARKMENOT = 100;

* Tukikuukaudet vuodessa ;
%LET MINIMI_TOIMTUKI_TUKIAIKA = 12;
%LET MAKSIMI_TOIMTUKI_TUKIAIKA = 12;

%END;


/* 4. Luodaan esimerkissä käytettävä data ja simuloidaan sen pohjalta. */

/* 4.1. Generoidaan esimerkissä käytettävä data makromuuttujien arvojen mukaisesti. */ 

DATA OUTPUT.&TULOSNIMI_TO;

DO TOIMTUKI_VUOSI = &MINIMI_TOIMTUKI_VUOSI TO &MAKSIMI_TOIMTUKI_VUOSI;
DO TOIMTUKI_KUUK = &MINIMI_TOIMTUKI_KUUK TO &MAKSIMI_TOIMTUKI_KUUK;
DO TOIMTUKI_KRYHMA = &MINIMI_TOIMTUKI_KRYHMA TO &MAKSIMI_TOIMTUKI_KRYHMA;
DO TOIMTUKI_AIK = &MINIMI_TOIMTUKI_AIK TO &MAKSIMI_TOIMTUKI_AIK;
DO TOIMTUKI_AIKLAPSIA = &MINIMI_TOIMTUKI_AIKLAPSIA TO &MAKSIMI_TOIMTUKI_AIKLAPSIA;
DO TOIMTUKI_LAPSIA17 = &MINIMI_TOIMTUKI_LAPSIA17 TO &MAKSIMI_TOIMTUKI_LAPSIA17;
DO TOIMTUKI_LAPSIA10_16 = &MINIMI_TOIMTUKI_LAPSIA10_16 TO &MAKSIMI_TOIMTUKI_LAPSIA10_16;
DO TOIMTUKI_LAPSIAALLE10 = &MINIMI_TOIMTUKI_LAPSIAALLE10 TO &MAKSIMI_TOIMTUKI_LAPSIAALLE10;
DO TOIMTUKI_LAPSILISAT = &MINIMI_TOIMTUKI_LAPSILISAT TO &MAKSIMI_TOIMTUKI_LAPSILISAT BY &KYNNYS_TOIMTUKI_LAPSILISAT;
DO TOIMTUKI_TYOTULO = &MINIMI_TOIMTUKI_TYOTULO TO &MAKSIMI_TOIMTUKI_TYOTULO BY &KYNNYS_TOIMTUKI_TYOTULO;
DO TOIMTUKI_MUUTTULOT = &MINIMI_TOIMTUKI_MUUTTULOT TO &MAKSIMI_TOIMTUKI_MUUTTULOT BY &KYNNYS_TOIMTUKI_MUUTTULOT;
DO TOIMTUKI_ASMENOT = &MINIMI_TOIMTUKI_ASMENOT TO &MAKSIMI_TOIMTUKI_ASMENOT BY &KYNNYS_TOIMTUKI_ASMENOT;
DO TOIMTUKI_HARKMENOT = &MINIMI_TOIMTUKI_HARKMENOT TO &MAKSIMI_TOIMTUKI_HARKMENOT BY &KYNNYS_TOIMTUKI_HARKMENOT;
DO TOIMTUKI_TUKIAIKA = &MINIMI_TOIMTUKI_TUKIAIKA TO &MAKSIMI_TOIMTUKI_TUKIAIKA;

%IF &INF = 999 %THEN %DO;
%IndKerroin_ESIM(&AVUOSI, TOIMTUKI_VUOSI);
%END;
%ELSE %DO; 
	INF = &INF;
%END;

OUTPUT;
END;END;END;END;END;END;END;END;END;END;END;END;END;END;

RUN;

%MEND Generoi_Muuttujat;

%Generoi_Muuttujat;


/* 4.2. Simuloidaan valitut muuttujat esimerkkidatalla. */

%MACRO ToimTuki_Simuloi_Esimerkki;

DATA OUTPUT.&TULOSNIMI_TO;
SET OUTPUT.&TULOSNIMI_TO;

IF &VUOSIKA = 1 THEN DO;
	%ToimTukiV&F(TOIMTUKIKK, TOIMTUKI_VUOSI, INF, TOIMTUKI_KRYHMA, 1, 
			TOIMTUKI_AIK, TOIMTUKI_AIKLAPSIA, TOIMTUKI_LAPSIA17, TOIMTUKI_LAPSIA10_16, TOIMTUKI_LAPSIAALLE10,
			TOIMTUKI_LAPSILISAT, TOIMTUKI_TYOTULO, TOIMTUKI_MUUTTULOT, TOIMTUKI_ASMENOT, TOIMTUKI_HARKMENOT);
END;
IF &VUOSIKA = 2 THEN DO;
	%ToimTukiK&F(TOIMTUKIKK, TOIMTUKI_VUOSI, TOIMTUKI_KUUK, INF, TOIMTUKI_KRYHMA, 1, 
			TOIMTUKI_AIK, TOIMTUKI_AIKLAPSIA, TOIMTUKI_LAPSIA17, TOIMTUKI_LAPSIA10_16, TOIMTUKI_LAPSIAALLE10,
			TOIMTUKI_LAPSILISAT, TOIMTUKI_TYOTULO, TOIMTUKI_MUUTTULOT, TOIMTUKI_ASMENOT, TOIMTUKI_HARKMENOT);
END;
	
TOIMTUKIV = TOIMTUKI_TUKIAIKA * TOIMTUKIKK;

DROP kuuknro taulu_to w y z testi kuuid;

/* 4.3 Määritellään muuttujille selkokieliset selitteet. */

LABEL 
TOIMTUKI_VUOSI = "Lainsäädäntövuosi"
TOIMTUKI_KUUK = "Lainsäädäntökuukausi"
TOIMTUKI_KRYHMA = "Toimeentulotuen kuntaryhmä (1/2)"
TOIMTUKI_AIK = "18-v. täyttäneiden lkm (pl. 18-v. täyttäneet lapset)"
TOIMTUKI_AIKLAPSIA = "18-v. täyttäneiden lasten lkm"
TOIMTUKI_LAPSIA17 = "17-v. lasten lkm"
TOIMTUKI_LAPSIA10_16 = "10-16-v. lasten lkm"
TOIMTUKI_LAPSIAALLE10 = "Alle 10-v. lasten lkm"
TOIMTUKI_LAPSILISAT = "Lapsilisän määrä, e/kk"
TOIMTUKI_TYOTULO = "Töistä saadut tulot, e/kk"
TOIMTUKI_MUUTTULOT = "Muut tulot, e/kk"
TOIMTUKI_ASMENOT = "Asumismenot, e/kk"
TOIMTUKI_HARKMENOT = "Harkinnanvaraiset menot, e/kk"
TOIMTUKI_TUKIAIKA = "Tukikuukaudet vuodessa"
INF = "Inflaatiokorjauksessa käytettävä kerroin"

TOIMTUKIKK = "Toimeentulotuki, e/kk"
TOIMTUKIV = "Toimeentulotuki, e/v";

KEEP &VALITUT;
%IF &VUOSIKA NE 2 %THEN %DO;
	DROP TOIMTUKI_KUUK;
%END;

RUN;

%IF &EXCEL = 1 %THEN %DO;
	ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_TO..xls"  STYLE = MINIMAL;
%END;

PROC PRINT NOOBS LABEL DATA = OUTPUT.&TULOSNIMI_TO;
TITLE "ESIMERKKILASKELMA, TOIMTUKI";
RUN;

%IF &EXCEL = 1 %THEN %DO;
	ODS HTML3 CLOSE;
%END;

%MEND ToimTuki_Simuloi_Esimerkki;

%ToimTuki_Simuloi_Esimerkki;
