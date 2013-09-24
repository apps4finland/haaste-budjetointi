/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyödyntää Tilastokeskuksen yleisten
* käyttöehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto päähakemistossa.
******************************************************************************/

/***********************************************************
* Kuvaus: Päivähoidon esimerkkilaskelmien pohja   	       *
* Tekijä: Maria Valaste / KELA	                		   *
* Luotu: 20.12.2011				       					   *
* Viimeksi päivitetty: 12.01.2012			     		   *
* Päivittäjä: Maria Valaste / KELA		     			   *
***********************************************************/ 

/* 1. Esimerkkilaskentaa ohjaavat makromuuttujat */

%MACRO Aloitus;

%LET TYYPPI = ESIM; * Parametrien hakutapa, aina ESIM ;

/* Jos mallia käytetään käyttöliittymästä (&EG = 1), niin seuraavia vaiheita ei ajeta */

%IF &EG NE 1 %THEN %DO;

%LET TULOSNIMI_PH = phoito_esim_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;
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
%LET LAKIMAK_TIED_PH = KOTIHTUKIlakimakrot;	* Lakimakroissa käytettävän tiedoston nimi ;
%LET APUMAKROT = 1;   	* Apumakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
%LET APUMAK_TIED_PH = KOTIHTUKIapumakrot; * Apumakroissa käytettävän tiedoston nimi ;
%LET EXCEL = 1; 		* Viedäänkö tulostaulukko automaattisesti Exceliin (1 = Kyllä, 0 = Ei) ;

%LET PKOTIHTUKI = pkotihtuki; * Käytettävän parametritiedoston nimi 
								(päivähoitomaksut käyttävät kotihoidontuen kanssa yhteistä parametritaulukkoa) ;
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

/* Jos mallia käytetään käyttöliittymästä (&EG = 1), niin seuraavia vaiheita ei ajeta */

%IF &EG NE 1 %THEN %DO;

/* 3.1 Fiktiivinen data */

* Lainsäädäntövuosi (1985-);
%LET MINIMI_PHOITO_VUOSI = 2012;
%LET MAKSIMI_PHOITO_VUOSI = 2012;

* Lainsäädäntökuukausi (1-12);
%LET MINIMI_PHOITO_KUUK = 12;
%LET MAKSIMI_PHOITO_KUUK = 12;

* Tukikuukaudet vuodessa;
%LET MINIMI_PHOITO_TUKIAIKA = 12 ; 
%LET MAKSIMI_PHOITO_TUKIAIKA = 12 ;

* Onko puolisoa (0 = ei puolisoa, 1 = on puoliso);
%LET MINIMI_PHOITO_PUOLISO = 1;
%LET MAKSIMI_PHOITO_PUOLISO = 1;

* Päivähoitoikäisten lasten lkm; 
%LET MINIMI_PHOITO_PHLAPSIA = 1; 
%LET MAKSIMI_PHOITO_PHLAPSIA = 3;  

* Monesko sisar päivähoidossa (nuorin = 1);
%LET MINIMI_PHOITO_SISAR = 1; 
%LET MAKSIMI_PHOITO_SISAR = 1;  

* Muiden lasten lkm; 
%LET MINIMI_PHOITO_MUITALAPSIA = 1; 
%LET MAKSIMI_PHOITO_MUITALAPSIA = 1;  

* Päivähoitomaksujen perusteena oleva tulo, e/kk;
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

/* 4.2.1 Lasketaan päivähoitomaksu (yhdestä lapsesta) */

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

/* 4.2.2 Lasketaan päivähoitomaksu (useasta lapsesta) */

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

/* 4.3 Määritellään muuttujille selkokieliset selitteet */

LABEL 
PHOITO_VUOSI = 'Lainsäädäntövuosi'
PHOITO_KUUK = 'Lainsäädäntökuukausi'
PHOITO_PUOLISO = 'Onko puolisoa (0/1)'
PHOITO_PHLAPSIA = 'Päivähoitoikäisten lasten lkm'
PHOITO_SISAR = 'Monesko sisar päivähoidossa (nuorin = 1)' 
PHOITO_MUITALAPSIA = 'Muiden lasten lkm'
PHOITO_TULO = 'Päivähoitomaksujen perusteena oleva tulo, e/kk'
PHOITO_TUKIAIKA = 'Tukikuukaudet vuodessa'
INF = 'Inflaatiokorjauksessa käytettävä kerroin'

PHOITOMAKSUK = 'Päivähoitomaksu (yhdestä lapsesta), e/kk' 
PHOITOMAKSUV = 'Päivähoitomaksu (yhdestä lapsesta), e/v' 
SUMPHOITOMAKSUK = 'Päivähoitomaksu (useammasta lapsesta), e/kk' 
SUMPHOITOMAKSUV = 'Päivähoitomaksu (useammasta lapsesta), e/v' ;

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

