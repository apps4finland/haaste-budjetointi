/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyödyntää Tilastokeskuksen yleisten
* käyttöehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto päähakemistossa.
******************************************************************************/

/***********************************************************
* Kuvaus: Lapsilisän esimerkkilaskelmien pohja             *
* Tekijä: Maria Valaste / KELA	                		   *
* Luotu: 14.12.2011				       					   *
* Viimeksi päivitetty: 20.12.2011			     		   *
* Päivittäjä: Maria Valaste / KELA		     			   *
************************************************************; 

/* 1. Esimerkkilaskentaa ohjaavat makromuuttujat */

%MACRO Aloitus;

%LET TYYPPI = ESIM; * Parametrien hakutapa, aina ESIM ;

/* Jos mallia käytetään käyttöliittymästä (&EG = 1), niin seuraavia vaiheita ei ajeta */

%IF &EG NE 1 %THEN %DO;

%LET TULOSNIMI_LL = llisa_esim_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;
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
%LET LAKIMAK_TIED_LL = LLISAlakimakrot;	* Lakimakroissa käytettävän tiedoston nimi ;
%LET APUMAKROT = 1;   	* Apumakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
%LET APUMAK_TIED_LL = LLISAapumakrot; * Apumakroissa käytettävän tiedoston nimi ;
%LET EXCEL = 0; 		* Viedäänkö tulostaulukko automaattisesti Exceliin (1 = Kyllä, 0 = Ei) ;

%LET PLLISA = pllisa; * Käytettävän parametritiedoston nimi ;

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
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_LL..sas";
%END;

/* Ajetaan apumakrot ja tallennetaan ne (optio) */

%IF &APUMAKROT = 1 %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&APUMAK_TIED_LL..sas";
%END;

%MEND TeeMakrot;

%TeeMakrot;


/* 3. Datan generointia ohjaavat makromuuttujat */

%MACRO Generoi_Muuttujat;

/* Jos mallia käytetään käyttöliittymästä (&EG = 1), niin seuraavia vaiheita ei ajeta */

%IF &EG NE 1 %THEN %DO;

/* 3.1 Fiktiivinen data */

* Lainsäädäntövuosi (1948-);
%LET MINIMI_LLISA_VUOSI = 2012;
%LET MAKSIMI_LLISA_VUOSI = 2012;

* Lainsäädäntökuukausi (1-12);
%LET MINIMI_LLISA_KUUK = 12;
%LET MAKSIMI_LLISA_KUUK = 12;

* Onko puolisoa (0 = ei puolisoa, 1 = on puoliso) ;
%LET MINIMI_LLISA_PUOLISO = 0; 
%LET MAKSIMI_LLISA_PUOLISO = 1; 

* Alle 3-v. lasten lukumäärä;
%LET MINIMI_LLISA_LAPSIA_ALLE_3_V = 1 ; 
%LET MAKSIMI_LLISA_LAPSIA_ALLE_3_V = 1 ;

* 3-15-v. lasten lukumäärä;
%LET MINIMI_LLISA_LAPSIA_3_15_V = 1; 
%LET MAKSIMI_LLISA_LAPSIA_3_15_V = 3; 

* 16-v. lasten lukumäärä;
%LET MINIMI_LLISA_LAPSIA_16_V = 0; 
%LET MAKSIMI_LLISA_LAPSIA_16_V = 0;  

* Syntyneiden tai adoptoitujen lasten lukumäärä;
%LET MINIMI_LLISA_AITAVLAPSIA = 1;
%LET MAKSIMI_LLISA_AITAVLAPSIA = 1;

* Elatustukeen oikeuttavien lasten lukumäärä;
%LET MINIMI_LLISA_ELATLAPSIA = 1;
%LET MAKSIMI_LLISA_ELATLAPSIA = 1;

* Tukikuukaudet vuodessa;
%LET MINIMI_LLISA_TUKIAIKA = 12 ; 
%LET MAKSIMI_LLISA_TUKIAIKA = 12 ;

%END;


/* 4. Fiktiivisen aineiston luominen ja simulointi */

/* 4.1 Generoidaan data makromuuttujien arvojen mukaisesti */ 

DATA OUTPUT.&TULOSNIMI_LL;

DO LLISA_VUOSI = &MINIMI_LLISA_VUOSI TO &MAKSIMI_LLISA_VUOSI;
DO LLISA_KUUK = &MINIMI_LLISA_KUUK TO &MAKSIMI_LLISA_KUUK;
DO LLISA_PUOLISO = &MINIMI_LLISA_PUOLISO TO &MAKSIMI_LLISA_PUOLISO;
DO LLISA_LAPSIA_ALLE_3_V = &MINIMI_LLISA_LAPSIA_ALLE_3_V TO &MAKSIMI_LLISA_LAPSIA_ALLE_3_V ; 
DO LLISA_LAPSIA_3_15_V = &MINIMI_LLISA_LAPSIA_3_15_V TO &MAKSIMI_LLISA_LAPSIA_3_15_V;
DO LLISA_LAPSIA_16_V = &MINIMI_LLISA_LAPSIA_16_V TO &MAKSIMI_LLISA_LAPSIA_16_V;
DO LLISA_AITAVLAPSIA = &MINIMI_LLISA_AITAVLAPSIA TO &MAKSIMI_LLISA_AITAVLAPSIA;
DO LLISA_ELATLAPSIA = &MINIMI_LLISA_ELATLAPSIA TO &MAKSIMI_LLISA_ELATLAPSIA;
DO LLISA_TUKIAIKA = &MINIMI_LLISA_TUKIAIKA TO &MAKSIMI_LLISA_TUKIAIKA;

%IF &INF = 999 %THEN %DO;
%IndKerroin_ESIM(&AVUOSI, LLISA_VUOSI);
%END;
%ELSE %DO; 
	INF = &INF;
%END;

OUTPUT;
END;END;END;END;END;END;END;END;END;

RUN;

%MEND Generoi_Muuttujat;

%Generoi_Muuttujat;


/* 6.2 Simuloidaan valitut muuttujat esimerkkiaineistolla */

%MACRO LLisa_Simuloi_Esimerkki;

DATA OUTPUT.&TULOSNIMI_LL;
SET OUTPUT.&TULOSNIMI_LL;

/* 4.2.1 Lasketaan lapsilisä */

IF &VUOSIKA = 2 THEN DO;
	%LLisaK&F(LAPSILIS, LLISA_VUOSI, LLISA_KUUK, INF, LLISA_PUOLISO, LLISA_LAPSIA_ALLE_3_V, LLISA_LAPSIA_3_15_V, LLISA_LAPSIA_16_V);
END;
ELSE DO;
	%LLisaV&F(LAPSILIS, LLISA_VUOSI, INF, LLISA_PUOLISO, LLISA_LAPSIA_ALLE_3_V, LLISA_LAPSIA_3_15_V, LLISA_LAPSIA_16_V);
END;
	
/* Kuukausitaso */
LLISAK = LAPSILIS;
/* Vuositaso */ 
LLISAV = LAPSILIS * LLISA_TUKIAIKA;

DROP LAPSILIS;

/* 4.2.2 Lasketaan äitiysavustus */

IF &VUOSIKA = 2 THEN DO;
	%AitAvustK&F(AITIYSAV, LLISA_VUOSI, LLISA_KUUK, INF, LLISA_AITAVLAPSIA);
END;
ELSE DO;
	%AitAvustV&F(AITIYSAV, LLISA_VUOSI, INF, LLISA_AITAVLAPSIA);
END;

/* Kuukausitaso */
AITAVK = AITIYSAV;
/* Vuositaso */ 
AITAVV = AITIYSAV * LLISA_TUKIAIKA;

DROP AITIYSAV;

/* 4.2.3 Lasketaan elatustuki */

IF &VUOSIKA = 2 THEN DO;
	%ElatTukiK&F(ELATTUKI, LLISA_VUOSI, LLISA_KUUK, INF, LLISA_PUOLISO, LLISA_ELATLAPSIA);
END;
ELSE DO;
	%ElatTukiV&F(ELATTUKI, LLISA_VUOSI, INF, LLISA_PUOLISO, LLISA_ELATLAPSIA);
END;

/* Kuukausitaso */
ELATUSTUKIK = ELATTUKI;
/* Vuositaso */ 
ELATUSTUKIV = ELATTUKI * LLISA_TUKIAIKA;

DROP ELATTUKI;

DROP kuuknro taulu_ll w y z testi kuuid lapsia;

/* 4.3 Määritellään muuttujille selkokieliset selitteet */

LABEL 
LLISA_VUOSI = 'Lainsäädäntövuosi'
LLISA_KUUK = 'Lainsäädäntökuukausi'
LLISA_PUOLISO = 'Onko puolisoa (0/1)'
LLISA_LAPSIA_ALLE_3_V = 'Alle 3-v. lasten lkm'
LLISA_LAPSIA_3_15_V = '3-15-v. lasten lkm'
LLISA_LAPSIA_16_V = '16-v. lasten lkm' 
LLISA_AITAVLAPSIA = 'Syntyneiden tai adoptoitujen lasten lkm'
LLISA_ELATLAPSIA = 'Elatustukeen oikeuttavien lasten lkm'
LLISA_TUKIAIKA = 'Tukikuukaudet vuodessa'
INF = 'Inflaatiokorjauksessa käytettävä kerroin'

LLISAK = 'Lapsilisä, e/kk' 
AITAVK = 'Äitiysavustus, e/kk' 
ELATUSTUKIK = 'Elatustuki, e/kk' 
LLISAV = 'Lapsilisä, e/v' 
AITAVV = 'Äitiysavustus, e/v' 
ELATUSTUKIV = 'Elatustuki, e/v' ;

KEEP &VALITUT;
%IF &VUOSIKA NE 2 %THEN %DO;
	DROP LLISA_KUUK;
%END;

RUN;

%IF &EXCEL = 1 %THEN %DO;
	ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_LL..xls" STYLE = MINIMAL;
%END;

PROC PRINT NOOBS LABEL DATA = OUTPUT.&TULOSNIMI_LL;
TITLE "ESIMERKKILASKELMA, LLISA";
RUN;

%IF &EXCEL = 1 %THEN %DO;
	ODS HTML3 CLOSE;
%END;


%MEND LLisa_Simuloi_Esimerkki;

%LLisa_Simuloi_Esimerkki;




