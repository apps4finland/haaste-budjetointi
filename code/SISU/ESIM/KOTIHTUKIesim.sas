/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyödyntää Tilastokeskuksen yleisten
* käyttöehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto päähakemistossa.
******************************************************************************/

/***********************************************************
* Kuvaus: Kotihoidontuen esimerkkilaskelmien pohja         *
* Tekijä: Maria Valaste / KELA	                		   *
* Luotu: 20.12.2011				       					   *
* Viimeksi päivitetty: 02.01.2012			     		   *
* Päivittäjä: Maria Valaste / KELA		     			   *
***********************************************************/ 

/* 1. Esimerkkilaskentaa ohjaavat makromuuttujat */

%MACRO Aloitus;

%LET TYYPPI = ESIM; * Parametrien hakutapa, aina ESIM ;

/* Jos mallia käytetään käyttöliittymästä (&EG = 1), niin seuraavia vaiheita ei ajeta */

%IF &EG NE 1 %THEN %DO;

%LET TULOSNIMI_KT = kotihtuki_esim_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;
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
%LET LAKIMAK_TIED_KT = KOTIHTUKIlakimakrot;	* Lakimakroissa käytettävän tiedoston nimi ;
%LET APUMAKROT = 1;   	* Apumakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
%LET APUMAK_TIED_KT = KOTIHTUKIapumakrot; * Apumakroissa käytettävän tiedoston nimi ;
%LET EXCEL = 1; 		* Viedäänkö tulostaulukko automaattisesti Exceliin (1 = Kyllä, 0 = Ei) ;

%LET PKOTIHTUKI = pkotihtuki; * Käytettävän parametritiedoston nimi ;

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

/* Jos mallia käytetään käyttöliittymästä (&EG = 1), niin seuraavia vaiheita ei ajeta */

%IF &EG NE 1 %THEN %DO;

/* 3.1 Fiktiivinen data */

* Lainsäädäntövuosi (1985-);
%LET MINIMI_KOTIHTUKI_VUOSI = 2012;
%LET MAKSIMI_KOTIHTUKI_VUOSI = 2012;

* Lainsäädäntökuukausi (1-12);
%LET MINIMI_KOTIHTUKI_KUUK = 12;
%LET MAKSIMI_KOTIHTUKI_KUUK = 12;

* Kotihoidossa olevien alle 3-vuotiaiden sisarten lukumäärä;
%LET MINIMI_KOTIHTUKI_SISARIA = 0;
%LET MAKSIMI_KOTIHTUKI_SISARIA = 0; 

* Muiden alle kouluikäisten hoitolasten lukumäärä;
%LET MINIMI_KOTIHTUKI_MUUALLEKOULUIK = 0 ; 
%LET MAKSIMI_KOTIHTUKI_MUUALLEKOULUIK = 0 ;

* Aikuisten lukumäärä perheessä (1/2);
%LET MINIMI_KOTIHTUKI_AIKLKM = 2; 
%LET MAKSIMI_KOTIHTUKI_AIKLKM = 2; 

* Bruttotulo, e/kk (käytössä 1.1.1991 lähtien);
%LET MINIMI_KOTIHTUKI_BRUTTOTULO = 1500; 
%LET MAKSIMI_KOTIHTUKI_BRUTTOTULO = 5000;  
%LET KYNNYS_KOTIHTUKI_BRUTTOTULO = 500;

* Nettotulo, e/kk (käytössä ennen 1.1.1991);
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

* Muodostetaan muuttuja perheen jäsenten lukumäärälle ;

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

/* 4.3 Määritellään muuttujille selkokieliset selitteet */

LABEL 
KOTIHTUKI_VUOSI = 'Lainsäädäntövuosi'
KOTIHTUKI_KUUK = 'Lainsäädäntökuukausi'
KOTIHTUKI_SISARIA = 'Kotihoidossa olevien alle 3-vuotiaiden sisarten lkm'
KOTIHTUKI_MUUALLEKOULUIK = 'Muiden alle kouluikäisten hoitolasten lkm'
KOTIHTUKI_AIKLKM = 'Aikuisten lkm perheessä'
KOTIHTUKI_KOKO = 'Perheenjäsenten lkm' 
KOTIHTUKI_BRUTTOTULO = 'Bruttotulo, e/kk (1.1.1991 lähtien)'
KOTIHTUKI_NETTOTULO = 'Nettotulo, e/kk (ennen 1.1.1991)'
KOTIHTUKI_TUKIAIKA = 'Tukikuukaudet vuodessa'
INF = 'Inflaatiokorjauksessa käytettävä kerroin'

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

