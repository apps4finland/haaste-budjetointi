/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hy�dynt�� Tilastokeskuksen yleisten
* k�ytt�ehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto p��hakemistossa.
******************************************************************************/

/***********************************************************
* Kuvaus: P�iv�hoidon esimerkkilaskelmien pohja   	       *
* Tekij�: Maria Valaste / KELA	                		   *
* Luotu: 20.12.2011				       					   *
* Viimeksi p�ivitetty: 12.01.2012			     		   *
* P�ivitt�j�: Maria Valaste / KELA		     			   *
***********************************************************/ 

/* 1. Esimerkkilaskentaa ohjaavat makromuuttujat */

%MACRO Aloitus;

%LET TYYPPI = ESIM; * Parametrien hakutapa, aina ESIM ;

/* Jos mallia k�ytet��n k�ytt�liittym�st� (&EG = 1), niin seuraavia vaiheita ei ajeta */

%IF &EG NE 1 %THEN %DO;

%LET TULOSNIMI_PH = phoito_esim_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;
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
%LET LAKIMAK_TIED_PH = KOTIHTUKIlakimakrot;	* Lakimakroissa k�ytett�v�n tiedoston nimi ;
%LET APUMAKROT = 1;   	* Apumakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
%LET APUMAK_TIED_PH = KOTIHTUKIapumakrot; * Apumakroissa k�ytett�v�n tiedoston nimi ;
%LET EXCEL = 1; 		* Vied��nk� tulostaulukko automaattisesti Exceliin (1 = Kyll�, 0 = Ei) ;

%LET PKOTIHTUKI = pkotihtuki; * K�ytett�v�n parametritiedoston nimi 
								(p�iv�hoitomaksut k�ytt�v�t kotihoidontuen kanssa yhteist� parametritaulukkoa) ;
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
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_PH..sas";
%END;

/* Ajetaan apumakrot ja tallennetaan ne (optio) */

%IF &APUMAKROT = 1 %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&APUMAK_TIED_PH..sas";
%END;

%MEND TeeMakrot;

%TeeMakrot;


/* 3. Datan generointia ohjaavat makromuuttujat */

%MACRO Generoi_Muuttujat;

/* Jos mallia k�ytet��n k�ytt�liittym�st� (&EG = 1), niin seuraavia vaiheita ei ajeta */

%IF &EG NE 1 %THEN %DO;

/* 3.1 Fiktiivinen data */

* Lains��d�nt�vuosi (1985-);
%LET MINIMI_PHOITO_VUOSI = 2012;
%LET MAKSIMI_PHOITO_VUOSI = 2012;

* Lains��d�nt�kuukausi (1-12);
%LET MINIMI_PHOITO_KUUK = 12;
%LET MAKSIMI_PHOITO_KUUK = 12;

* Tukikuukaudet vuodessa;
%LET MINIMI_PHOITO_TUKIAIKA = 12 ; 
%LET MAKSIMI_PHOITO_TUKIAIKA = 12 ;

* Onko puolisoa (0 = ei puolisoa, 1 = on puoliso);
%LET MINIMI_PHOITO_PUOLISO = 1;
%LET MAKSIMI_PHOITO_PUOLISO = 1;

* P�iv�hoitoik�isten lasten lkm; 
%LET MINIMI_PHOITO_PHLAPSIA = 1; 
%LET MAKSIMI_PHOITO_PHLAPSIA = 3;  

* Monesko sisar p�iv�hoidossa (nuorin = 1);
%LET MINIMI_PHOITO_SISAR = 1; 
%LET MAKSIMI_PHOITO_SISAR = 1;  

* Muiden lasten lkm; 
%LET MINIMI_PHOITO_MUITALAPSIA = 1; 
%LET MAKSIMI_PHOITO_MUITALAPSIA = 1;  

* P�iv�hoitomaksujen perusteena oleva tulo, e/kk;
%LET MINIMI_PHOITO_TULO = 3500; 
%LET MAKSIMI_PHOITO_TULO = 3500;  
%LET KYNNYS_PHOITO_TULO = 500;

%END;


/* 4. Fiktiivisen aineiston luominen ja simulointi */

/* 4.1 Generoidaan data makromuuttujien arvojen mukaisesti */ 

DATA OUTPUT.&TULOSNIMI_PH;

DO PHOITO_VUOSI = &MINIMI_PHOITO_VUOSI TO &MAKSIMI_PHOITO_VUOSI;
DO PHOITO_KUUK = &MINIMI_PHOITO_KUUK TO &MAKSIMI_PHOITO_KUUK;
DO PHOITO_PUOLISO = &MINIMI_PHOITO_PUOLISO TO &MAKSIMI_PHOITO_PUOLISO;
DO PHOITO_PHLAPSIA = &MINIMI_PHOITO_PHLAPSIA TO &MAKSIMI_PHOITO_PHLAPSIA; 
DO PHOITO_SISAR = &MINIMI_PHOITO_SISAR TO &MAKSIMI_PHOITO_SISAR;
DO PHOITO_MUITALAPSIA = &MINIMI_PHOITO_MUITALAPSIA TO &MAKSIMI_PHOITO_MUITALAPSIA;
DO PHOITO_TULO = &MINIMI_PHOITO_TULO TO &MAKSIMI_PHOITO_TULO BY &KYNNYS_PHOITO_TULO;
DO PHOITO_TUKIAIKA = &MINIMI_PHOITO_TUKIAIKA TO &MAKSIMI_PHOITO_TUKIAIKA;

%IF &INF = 999 %THEN %DO;
%IndKerroin_ESIM(&AVUOSI, PHOITO_VUOSI);
%END;
%ELSE %DO; 
	INF = &INF;
%END;

OUTPUT;
END;END;END;END;END;END;END;END;

RUN;

%MEND Generoi_Muuttujat;

%Generoi_Muuttujat;


/* 4.2 Simuloidaan valitut muuttujat esimerkkiaineistolla */

%MACRO PHoito_Simuloi_Esimerkki;

DATA OUTPUT.&TULOSNIMI_PH;
SET OUTPUT.&TULOSNIMI_PH;

/* 4.2.1 Lasketaan p�iv�hoitomaksu (yhdest� lapsesta) */

IF &VUOSIKA = 2 THEN DO;
	%PHoitomaksu&F(PMAKSU, PHOITO_VUOSI, PHOITO_KUUK, INF, PHOITO_PUOLISO, PHOITO_PHLAPSIA, PHOITO_SISAR, PHOITO_MUITALAPSIA, PHOITO_TULO);
END;
ELSE DO; 
	%PHoitomaksuV&F(PMAKSU, PHOITO_VUOSI, INF, PHOITO_PUOLISO, PHOITO_PHLAPSIA, PHOITO_SISAR, PHOITO_MUITALAPSIA, PHOITO_TULO);
END;

/* Kuukausitaso */
PHOITOMAKSUK = PMAKSU;
/* Vuositaso */ 
PHOITOMAKSUV = PMAKSU * PHOITO_TUKIAIKA;

DROP PMAKSU;

/* 4.2.2 Lasketaan p�iv�hoitomaksu (useasta lapsesta) */

IF &VUOSIKA = 2 THEN DO;
	%SumPHoitoMaksu&F(SUMPMAKSU, PHOITO_VUOSI, PHOITO_KUUK, INF, PHOITO_PUOLISO, PHOITO_PHLAPSIA, PHOITO_MUITALAPSIA, PHOITO_TULO);
END;
ELSE DO;
	%SumPHoitoMaksuV&F(SUMPMAKSU, PHOITO_VUOSI, INF, PHOITO_PUOLISO, PHOITO_PHLAPSIA, PHOITO_MUITALAPSIA, PHOITO_TULO);
END;

/* Kuukausitaso */
SUMPHOITOMAKSUK = SUMPMAKSU;
/* Vuositaso */ 
SUMPHOITOMAKSUV = SUMPMAKSU * PHOITO_TUKIAIKA;

DROP SUMPMAKSU;

DROP kuuknro taulu_kt w y z testi kuuid koko;

/* 4.3 M��ritell��n muuttujille selkokieliset selitteet */

LABEL 
PHOITO_VUOSI = 'Lains��d�nt�vuosi'
PHOITO_KUUK = 'Lains��d�nt�kuukausi'
PHOITO_PUOLISO = 'Onko puolisoa (0/1)'
PHOITO_PHLAPSIA = 'P�iv�hoitoik�isten lasten lkm'
PHOITO_SISAR = 'Monesko sisar p�iv�hoidossa (nuorin = 1)' 
PHOITO_MUITALAPSIA = 'Muiden lasten lkm'
PHOITO_TULO = 'P�iv�hoitomaksujen perusteena oleva tulo, e/kk'
PHOITO_TUKIAIKA = 'Tukikuukaudet vuodessa'
INF = 'Inflaatiokorjauksessa k�ytett�v� kerroin'

PHOITOMAKSUK = 'P�iv�hoitomaksu (yhdest� lapsesta), e/kk' 
PHOITOMAKSUV = 'P�iv�hoitomaksu (yhdest� lapsesta), e/v' 
SUMPHOITOMAKSUK = 'P�iv�hoitomaksu (useammasta lapsesta), e/kk' 
SUMPHOITOMAKSUV = 'P�iv�hoitomaksu (useammasta lapsesta), e/v' ;

KEEP &VALITUT;

%IF &VUOSIKA NE 2 %THEN %DO;
	DROP PHOITO_KUUK;
%END;

RUN;

%IF &EXCEL = 1 %THEN %DO;
	ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_PH..xls"  STYLE = MINIMAL;
%END;

PROC PRINT NOOBS LABEL DATA = OUTPUT.&TULOSNIMI_PH;
TITLE "ESIMERKKILASKELMA, PHOITO";
RUN;

%IF &EXCEL = 1 %THEN %DO;
	ODS HTML3 CLOSE;
%END;

%MEND PHoito_Simuloi_Esimerkki;

%PHoito_Simuloi_Esimerkki;

