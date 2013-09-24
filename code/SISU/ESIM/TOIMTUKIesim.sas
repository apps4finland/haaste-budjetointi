/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hy�dynt�� Tilastokeskuksen yleisten
* k�ytt�ehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto p��hakemistossa.
******************************************************************************/

/***********************************************************
* Kuvaus: Toimentulotuen esimerkkilaskelmien pohja         *
* Tekij�: Elina Ahola / KELA		                	   *
* Luotu: 20.12.2011				       					   *
* Viimeksi p�ivitetty: 30.12.2011			     		   *
* P�ivitt�j�: Elina Ahola / KELA			     		   *
***********************************************************/ 

/* 1. Esimerkkilaskentaa ohjaavat makromuuttujat */

%MACRO Aloitus;

%LET TYYPPI = ESIM;	* Parametrien hakutapa, aina ESIM ;

/* Jos mallia k�ytet��n k�ytt�liittym�st� (&EG = 1), niin seuraavia vaiheita ei ajeta */

%IF &EG NE 1 %THEN %DO;

%LET TULOSNIMI_TO = toimtuki_esim_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;
%LET VUOSIKA = 1; 				* 1 = Vuosikeskiarvo, 2 = datassa annetun kuukauden lains��d�nt� ;
%LET VALITUT =  _ALL_; 			* Tulostaulukossa n�ytett�v�t muuttujat ;

* Inflaatiokorjaus. Parametrien deflatoinnissa k�ytett�v�n kertoimen voi sy�tt�� itse
  INF-makromuuttujaan (HUOM! desimaalit erotettava pisteell� .). Jos puolestaan haluaa k�ytt�� automaattista 
  elinkustannusindeksiin perustuvaa parametrien muunnoskerrointa, 
  tulee INF-makromuuttujalle antaa arvoksi 999.
  T�ll�in on annettava my�s perusvuosi, johon aineiston lains��d�nt�vuotta verrataan; 	

%LET INF = 1.00; * Sy�t� arvo tai 999 ;
%LET AVUOSI = 2012; * Perusvuosi inflaatiokorjausta varten ;
%LET PINDEKSI_VUOSI = pindeksi_vuosi; * K�ytett�v� indeksien parametritaulukko ;

* Laki- ja apumakro-ohjelmien ajon s��t�minen ; 

%LET LAKIMAKROT = 1;    * Lakimakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
%LET LAKIMAK_TIED_TO = TOIMTUKIlakimakrot;	* Lakimakroissa k�ytett�v�n tiedoston nimi ;
%LET APUMAKROT = 1;   	* Apumakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
%LET APUMAK_TIED_TO = TOIMTUKIapumakrot; * Apumakroissa k�ytett�v�n tiedoston nimi ;
%LET EXCEL = 1; 		 * Vied��nk� tulostaulukko automaattisesti Exceliin (1 = Kyll�, 0 = Ei) ;

* K�ytett�vien parametritiedostojen nimet ;

%LET PTOIMTUKI = ptoimtuki;
%LET POPINTUKI = popintuki;

%END;

%MEND Aloitus;

%Aloitus;


/* 2. T�ll� makrolla s��dell��n laki- ja apumakro-ohjelmien ajoa. 
	  Jos makrot on jo tallennettu tai otettu k�ytt��n, makro-ohjelmia ei ole pakko ajaa uudestaan. 
	  C-funktioita k�ytett�ess� SASCBTBL-m��ritys on joka tapauksessa pakko tehd�. */

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


/* 3. M��ritell��n datan generointia ohjaavat makromuuttujat */

%MACRO Generoi_Muuttujat;

/* Jos mallia k�ytet��n k�ytt�liittym�st� (&EG = 1), niin seuraavia vaiheita ei ajeta */

%IF &EG NE 1 %THEN %DO;

/* 3.1. Esimerkiss� k�ytett�v� data */

* Lains��d�nt�vuosi (1989-);
%LET MINIMI_TOIMTUKI_VUOSI = 2012;
%LET MAKSIMI_TOIMTUKI_VUOSI = 2012;

* Lains��d�nt�kuukausi (1-12);
%LET MINIMI_TOIMTUKI_KUUK = 12;
%LET MAKSIMI_TOIMTUKI_KUUK = 12;

* Toimeentulotuen kuntaryhm� (1/2);
%LET MINIMI_TOIMTUKI_KRYHMA = 1;
%LET MAKSIMI_TOIMTUKI_KRYHMA = 1;

* 18-v. t�ytt�neiden lkm (pl. 18-v. t�ytt�neet lapset);
%LET MINIMI_TOIMTUKI_AIK = 1;
%LET MAKSIMI_TOIMTUKI_AIK = 2;

* 18-v. t�ytt�neiden lasten lkm;
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

* Lapsilis�n m��r� (e/kk) ;
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


/* 4. Luodaan esimerkiss� k�ytett�v� data ja simuloidaan sen pohjalta. */

/* 4.1. Generoidaan esimerkiss� k�ytett�v� data makromuuttujien arvojen mukaisesti. */ 

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

/* 4.3 M��ritell��n muuttujille selkokieliset selitteet. */

LABEL 
TOIMTUKI_VUOSI = "Lains��d�nt�vuosi"
TOIMTUKI_KUUK = "Lains��d�nt�kuukausi"
TOIMTUKI_KRYHMA = "Toimeentulotuen kuntaryhm� (1/2)"
TOIMTUKI_AIK = "18-v. t�ytt�neiden lkm (pl. 18-v. t�ytt�neet lapset)"
TOIMTUKI_AIKLAPSIA = "18-v. t�ytt�neiden lasten lkm"
TOIMTUKI_LAPSIA17 = "17-v. lasten lkm"
TOIMTUKI_LAPSIA10_16 = "10-16-v. lasten lkm"
TOIMTUKI_LAPSIAALLE10 = "Alle 10-v. lasten lkm"
TOIMTUKI_LAPSILISAT = "Lapsilis�n m��r�, e/kk"
TOIMTUKI_TYOTULO = "T�ist� saadut tulot, e/kk"
TOIMTUKI_MUUTTULOT = "Muut tulot, e/kk"
TOIMTUKI_ASMENOT = "Asumismenot, e/kk"
TOIMTUKI_HARKMENOT = "Harkinnanvaraiset menot, e/kk"
TOIMTUKI_TUKIAIKA = "Tukikuukaudet vuodessa"
INF = "Inflaatiokorjauksessa k�ytett�v� kerroin"

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
