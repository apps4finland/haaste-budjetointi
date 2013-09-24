/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hy�dynt�� Tilastokeskuksen yleisten
* k�ytt�ehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto p��hakemistossa.
******************************************************************************/

/***********************************************************
* Kuvaus: Kotihoidontuen esimerkkilaskelmien pohja         *
* Tekij�: Maria Valaste / KELA	                		   *
* Luotu: 20.12.2011				       					   *
* Viimeksi p�ivitetty: 02.01.2012			     		   *
* P�ivitt�j�: Maria Valaste / KELA		     			   *
***********************************************************/ 

/* 1. Esimerkkilaskentaa ohjaavat makromuuttujat */

%MACRO Aloitus;

%LET TYYPPI = ESIM; * Parametrien hakutapa, aina ESIM ;

/* Jos mallia k�ytet��n k�ytt�liittym�st� (&EG = 1), niin seuraavia vaiheita ei ajeta */

%IF &EG NE 1 %THEN %DO;

%LET TULOSNIMI_KT = kotihtuki_esim_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;
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
%LET LAKIMAK_TIED_KT = KOTIHTUKIlakimakrot;	* Lakimakroissa k�ytett�v�n tiedoston nimi ;
%LET APUMAKROT = 1;   	* Apumakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
%LET APUMAK_TIED_KT = KOTIHTUKIapumakrot; * Apumakroissa k�ytett�v�n tiedoston nimi ;
%LET EXCEL = 1; 		* Vied��nk� tulostaulukko automaattisesti Exceliin (1 = Kyll�, 0 = Ei) ;

%LET PKOTIHTUKI = pkotihtuki; * K�ytett�v�n parametritiedoston nimi ;

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
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_KT..sas";
%END;

/* Ajetaan apumakrot ja tallennetaan ne (optio) */

%IF &APUMAKROT = 1 %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&APUMAK_TIED_KT..sas";
%END;

%MEND TeeMakrot;

%TeeMakrot;


/* 3. Datan generointia ohjaavat makromuuttujat */

%MACRO Generoi_Muuttujat;

/* Jos mallia k�ytet��n k�ytt�liittym�st� (&EG = 1), niin seuraavia vaiheita ei ajeta */

%IF &EG NE 1 %THEN %DO;

/* 3.1 Fiktiivinen data */

* Lains��d�nt�vuosi (1985-);
%LET MINIMI_KOTIHTUKI_VUOSI = 2012;
%LET MAKSIMI_KOTIHTUKI_VUOSI = 2012;

* Lains��d�nt�kuukausi (1-12);
%LET MINIMI_KOTIHTUKI_KUUK = 12;
%LET MAKSIMI_KOTIHTUKI_KUUK = 12;

* Kotihoidossa olevien alle 3-vuotiaiden sisarten lukum��r�;
%LET MINIMI_KOTIHTUKI_SISARIA = 0;
%LET MAKSIMI_KOTIHTUKI_SISARIA = 0; 

* Muiden alle kouluik�isten hoitolasten lukum��r�;
%LET MINIMI_KOTIHTUKI_MUUALLEKOULUIK = 0 ; 
%LET MAKSIMI_KOTIHTUKI_MUUALLEKOULUIK = 0 ;

* Aikuisten lukum��r� perheess� (1/2);
%LET MINIMI_KOTIHTUKI_AIKLKM = 2; 
%LET MAKSIMI_KOTIHTUKI_AIKLKM = 2; 

* Bruttotulo, e/kk (k�yt�ss� 1.1.1991 l�htien);
%LET MINIMI_KOTIHTUKI_BRUTTOTULO = 1500; 
%LET MAKSIMI_KOTIHTUKI_BRUTTOTULO = 5000;  
%LET KYNNYS_KOTIHTUKI_BRUTTOTULO = 500;

* Nettotulo, e/kk (k�yt�ss� ennen 1.1.1991);
%LET MINIMI_KOTIHTUKI_NETTOTULO = 0;
%LET MAKSIMI_KOTIHTUKI_NETTOTULO = 0;
%LET KYNNYS_KOTIHTUKI_NETTOTULO = 500;

* Tukikuukaudet vuodessa;
%LET MINIMI_KOTIHTUKI_TUKIAIKA = 12 ; 
%LET MAKSIMI_KOTIHTUKI_TUKIAIKA = 12 ;

%END;


/* 4. Fiktiivisen aineiston luominen ja simulointi */

/* 4.1 Generoidaan data makromuuttujien arvojen mukaisesti */ 

DATA OUTPUT.&TULOSNIMI_KT;

DO KOTIHTUKI_VUOSI = &MINIMI_KOTIHTUKI_VUOSI TO &MAKSIMI_KOTIHTUKI_VUOSI;
DO KOTIHTUKI_KUUK = &MINIMI_KOTIHTUKI_KUUK TO &MAKSIMI_KOTIHTUKI_KUUK;
DO KOTIHTUKI_SISARIA = &MINIMI_KOTIHTUKI_SISARIA TO &MAKSIMI_KOTIHTUKI_SISARIA;
DO KOTIHTUKI_MUUALLEKOULUIK = &MINIMI_KOTIHTUKI_MUUALLEKOULUIK TO &MAKSIMI_KOTIHTUKI_MUUALLEKOULUIK; 
DO KOTIHTUKI_AIKLKM = &MINIMI_KOTIHTUKI_AIKLKM TO &MAKSIMI_KOTIHTUKI_AIKLKM;
DO KOTIHTUKI_BRUTTOTULO = &MINIMI_KOTIHTUKI_BRUTTOTULO TO &MAKSIMI_KOTIHTUKI_BRUTTOTULO BY &KYNNYS_KOTIHTUKI_BRUTTOTULO;
DO KOTIHTUKI_NETTOTULO = &MINIMI_KOTIHTUKI_NETTOTULO TO &MAKSIMI_KOTIHTUKI_NETTOTULO BY &KYNNYS_KOTIHTUKI_NETTOTULO;
DO KOTIHTUKI_TUKIAIKA = &MINIMI_KOTIHTUKI_TUKIAIKA TO &MAKSIMI_KOTIHTUKI_TUKIAIKA;

%IF &INF = 999 %THEN %DO;
%IndKerroin_ESIM(&AVUOSI, KOTIHTUKI_VUOSI);
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

%MACRO KotihTuki_Simuloi_Esimerkki;

DATA OUTPUT.&TULOSNIMI_KT;
SET OUTPUT.&TULOSNIMI_KT;

/* 4.2.1 Lasketaan kotihoidontuki */

* Muodostetaan muuttuja perheen j�senten lukum��r�lle ;

KOTIHTUKI_KOKO = SUM(1, KOTIHTUKI_AIKLKM, KOTIHTUKI_SISARIA, KOTIHTUKI_MUUALLEKOULUIK);


IF &VUOSIKA = 2 THEN DO;
	%KotihTukiK&F(KTUKI, KOTIHTUKI_VUOSI, KOTIHTUKI_KUUK, INF, KOTIHTUKI_SISARIA, KOTIHTUKI_MUUALLEKOULUIK, KOTIHTUKI_KOKO, KOTIHTUKI_BRUTTOTULO, KOTIHTUKI_NETTOTULO);
END;
ELSE DO;
	%KotihTukiV&F(KTUKI, KOTIHTUKI_VUOSI, INF, KOTIHTUKI_SISARIA, KOTIHTUKI_MUUALLEKOULUIK, KOTIHTUKI_KOKO, KOTIHTUKI_BRUTTOTULO, KOTIHTUKI_NETTOTULO);
END;
	
/* Kuukausitaso */
KOTIHTUKIK = KTUKI;
/* Vuositaso */ 
KOTIHTUKIV = KTUKI * KOTIHTUKI_TUKIAIKA;

DROP KTUKI;

/* 4.2.2 Lasketaan osittainen hoitoraha */

IF &VUOSIKA = 2 THEN DO;
	%OsitHoitRaha&F(ORAHA, KOTIHTUKI_VUOSI, KOTIHTUKI_KUUK, INF);
END;
ELSE DO;
	%OsitHoitRahaV&F(ORAHA, KOTIHTUKI_VUOSI, INF);
END;

/* Kuukausitaso */
OHRAHAK = ORAHA;
/* Vuositaso */ 
OHRAHAV = ORAHA * KOTIHTUKI_TUKIAIKA;

DROP ORAHA kuuknro taulu_kt w y z testi kuuid;

/* 4.3 M��ritell��n muuttujille selkokieliset selitteet */

LABEL 
KOTIHTUKI_VUOSI = 'Lains��d�nt�vuosi'
KOTIHTUKI_KUUK = 'Lains��d�nt�kuukausi'
KOTIHTUKI_SISARIA = 'Kotihoidossa olevien alle 3-vuotiaiden sisarten lkm'
KOTIHTUKI_MUUALLEKOULUIK = 'Muiden alle kouluik�isten hoitolasten lkm'
KOTIHTUKI_AIKLKM = 'Aikuisten lkm perheess�'
KOTIHTUKI_KOKO = 'Perheenj�senten lkm' 
KOTIHTUKI_BRUTTOTULO = 'Bruttotulo, e/kk (1.1.1991 l�htien)'
KOTIHTUKI_NETTOTULO = 'Nettotulo, e/kk (ennen 1.1.1991)'
KOTIHTUKI_TUKIAIKA = 'Tukikuukaudet vuodessa'
INF = 'Inflaatiokorjauksessa k�ytett�v� kerroin'

KOTIHTUKIK = 'Kotihoidon tuki, e/kk' 
KOTIHTUKIV = 'Kotihoidon tuki, e/v' 
OHRAHAK = 'Osittainen hoitoraha, e/kk' 
OHRAHAV = 'Osittainen hoitoraha, e/v' ;

KEEP &VALITUT;
%IF &VUOSIKA NE 2 %THEN %DO;
	DROP KOTIHTUKI_KUUK;
%END;

RUN;

%IF &EXCEL = 1 %THEN %DO;
	ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_KT..xls" STYLE = MINIMAL;
%END;

PROC PRINT NOOBS LABEL DATA = OUTPUT.&TULOSNIMI_KT;
TITLE "ESIMERKKILASKELMA, KOTIHTUKI";
RUN;

%IF &EXCEL = 1 %THEN %DO;
	ODS HTML3 CLOSE;
%END;

%MEND KotihTuki_Simuloi_Esimerkki;

%KotihTuki_Simuloi_Esimerkki;

