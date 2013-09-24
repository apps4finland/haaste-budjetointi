/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyödyntää Tilastokeskuksen yleisten
* käyttöehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto päähakemistossa.
******************************************************************************/

/***********************************************************
* Kuvaus: Opintotuen esimerkkilaskelmien pohja             *
* Tekijä: Olli Kannas / TK		                		   *
* Luotu: 2.10.2011				       					   *
* Viimeksi päivitetty: 23.1.2012			     		   *
* Päivittäjä: Olli Kannas / TK			     			   *
************************************************************/ 

/* 1. Esimerkkilaskentaa ohjaavat makromuuttujat */

%MACRO Aloitus;

%LET TYYPPI = ESIM; * Parametrien hakutapa, aina ESIM ;

/* Jos mallia käytetään käyttöliittymästä (&EG = 1), niin seuraavia vaiheita ei ajeta */

%IF &EG NE 1 %THEN %DO;

%LET TULOSNIMI_OT = opintuki_esim_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;
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
%LET LAKIMAK_TIED_OT = OPINTUKIlakimakrot;	* Lakimakroissa käytettävän tiedoston nimi ;
%LET APUMAKROT = 1;   	* Apumakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
%LET APUMAK_TIED_OT = OPINTUKIapumakrot; * Apumakroissa käytettävän tiedoston nimi ;
%LET EXCEL = 1; 		 * Viedäänkö tulostaulukko automaattisesti Exceliin (1 = Kyllä, 0 = Ei) ;

%LET POPINTUKI = popintuki; * Käytettävän parametritiedoston nimi ;

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
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_OT..sas";
%END;

/* Ajetaan apumakrot ja tallennetaan ne (optio) */

%IF &APUMAKROT = 1 %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&APUMAK_TIED_OT..sas";
%END;

%MEND TeeMakrot;

%TeeMakrot;


/* 3. Datan generointia ohjaavat makromuuttujat */

%MACRO Generoi_Muuttujat;

/* Jos mallia käytetään käyttöliittymästä (&EG = 1), niin seuraavia vaiheita ei ajeta */

%IF &EG NE 1 %THEN %DO;

/* 3.1 Fiktiivinen data */

* Lainsäädäntövuosi (1992-);
%LET MINIMI_OPINTUKI_VUOSI = 2012;
%LET MAKSIMI_OPINTUKI_VUOSI = 2012;

* Lainsäädäntökuukausi ;
%LET MINIMI_OPINTUKI_KUUK = 12;
%LET MAKSIMI_OPINTUKI_KUUK = 12;

* Aikuiskoulutusopiskelija (1 = tosi, 0 = epätosi) ;
%LET MINIMI_OPINTUKI_AIKKOUL = 0 ; 
%LET MAKSIMI_OPINTUKI_AIKKOUL = 0 ; 

* Asuu vanhempien luona (1 = tosi, 0 = epätosi) ;
%LET MINIMI_OPINTUKI_KOTONA_AS = 0 ; 
%LET MAKSIMI_OPINTUKI_KOTONA_AS = 0 ;

* Opiskeluaste (1 = korkeakouluopiskelija, 0 = keskiasteen opiskelija) ;
%LET MINIMI_OPINTUKI_KORK = 1 ; 
%LET MAKSIMI_OPINTUKI_KORK = 1 ; 

* Opintotukikuukausien määrä vuodessa ;
%LET MINIMI_OPINTUKI_TUKIAIKA = 12 ; 
%LET MAKSIMI_OPINTUKI_TUKIAIKA = 12 ;  

* Henkilön ikä vuosina ;
%LET MINIMI_OPINTUKI_IKA = 25;
%LET MAKSIMI_OPINTUKI_IKA = 25;
%LET KYNNYS_OPINTUKI_IKA = 1;

* Henkilön omat veronalaiset tulot ja apurahat (e/v) ;
%LET MINIMI_OPINTUKI_OMA_TULO = 0;
%LET MAKSIMI_OPINTUKI_OMA_TULO = 20000;
%LET KYNNYS_OPINTUKI_OMA_TULO = 1000;

* Asumiskustannukset (e/kk) ;
%LET MINIMI_OPINTUKI_ASKUST = 500;
%LET MAKSIMI_OPINTUKI_ASKUST = 500;
%LET KYNNYS_OPINTUKI_ASKUST = 100;

* Puolison veronalaiset tulot (e/v) ;
%LET MINIMI_OPINTUKI_PUOL_TULO = 0;
%LET MAKSIMI_OPINTUKI_PUOL_TULO = 0;
%LET KYNNYS_OPINTUKI_PUOL_TULO = 1000;

* Vanhempien veronalaiset tulot (e/v) ;
%LET MINIMI_OPINTUKI_VANH_TULO = 0;
%LET MAKSIMI_OPINTUKI_VANH_TULO = 0;
%LET KYNNYS_OPINTUKI_VANH_TULO = 1000;

* Vanhempien veronalainen varallisuus (e) ;

%LET MINIMI_OPINTUKI_VANH_VARALL = 0;
%LET MAKSIMI_OPINTUKI_VANH_VARALL = 0;
%LET KYNNYS_OPINTUKI_VANH_VARALL = 1000;

%END;


/* 4. Fiktiivisen aineiston luominen ja simulointi */

/* 4.1 Generoidaan data makromuuttujien arvojen mukaisesti */ 

DATA OUTPUT.&TULOSNIMI_OT;

DO OPINTUKI_VUOSI = &MINIMI_OPINTUKI_VUOSI TO &MAKSIMI_OPINTUKI_VUOSI;
DO OPINTUKI_KUUK = &MINIMI_OPINTUKI_KUUK TO &MAKSIMI_OPINTUKI_KUUK;
DO OPINTUKI_AIKKOUL = &MINIMI_OPINTUKI_AIKKOUL TO &MAKSIMI_OPINTUKI_AIKKOUL;
DO OPINTUKI_KOTONA_AS = &MINIMI_OPINTUKI_KOTONA_AS TO &MAKSIMI_OPINTUKI_KOTONA_AS; 
DO OPINTUKI_KORK = &MINIMI_OPINTUKI_KORK TO &MAKSIMI_OPINTUKI_KORK;
DO OPINTUKI_TUKIAIKA = &MINIMI_OPINTUKI_TUKIAIKA TO &MAKSIMI_OPINTUKI_TUKIAIKA;
DO OPINTUKI_IKA = &MINIMI_OPINTUKI_IKA TO &MAKSIMI_OPINTUKI_IKA BY &KYNNYS_OPINTUKI_IKA; 
DO OPINTUKI_OMA_TULO = &MINIMI_OPINTUKI_OMA_TULO TO &MAKSIMI_OPINTUKI_OMA_TULO BY &KYNNYS_OPINTUKI_OMA_TULO ; 
DO OPINTUKI_ASKUST = &MINIMI_OPINTUKI_ASKUST TO &MAKSIMI_OPINTUKI_ASKUST BY &KYNNYS_OPINTUKI_ASKUST ; 
DO OPINTUKI_PUOL_TULO = &MINIMI_OPINTUKI_PUOL_TULO TO &MAKSIMI_OPINTUKI_PUOL_TULO BY &KYNNYS_OPINTUKI_PUOL_TULO ;
DO OPINTUKI_VANH_TULO = &MINIMI_OPINTUKI_VANH_TULO TO &MAKSIMI_OPINTUKI_VANH_TULO BY &KYNNYS_OPINTUKI_VANH_TULO ;
DO OPINTUKI_VANH_VARALL = &MINIMI_OPINTUKI_VANH_VARALL TO &MAKSIMI_OPINTUKI_VANH_VARALL BY &KYNNYS_OPINTUKI_VANH_VARALL ;

%IF &INF = 999 %THEN %DO;
%IndKerroin_ESIM(&AVUOSI, OPINTUKI_VUOSI);
%END;
%ELSE %DO; 
	INF = &INF;
%END;

OUTPUT;
END;END;END;END;END;END;END;END;END;END;END;END;

RUN;

%MEND Generoi_Muuttujat;

%Generoi_Muuttujat;


/* 4.2 Simuloidaan valitut muuttujat esimerkkiaineistolla */

%MACRO OpinTuki_Simuloi_Esimerkki;

DATA OUTPUT.&TULOSNIMI_OT;
SET OUTPUT.&TULOSNIMI_OT;

/* 4.2.1 Lasketaan opintoraha ja takaisinperintä */

IF &VUOSIKA = 2 THEN DO;
	%OpRahaK&F(OPIR, OPINTUKI_VUOSI, OPINTUKI_KUUK, INF, OPINTUKI_KORK, OPINTUKI_KOTONA_AS, OPINTUKI_IKA, 0, OPINTUKI_OMA_TULO, OPINTUKI_VANH_TULO, OPINTUKI_VANH_VARALL);
END;
ELSE DO;
	%OpRahaV&F(OPIR, OPINTUKI_VUOSI, INF, OPINTUKI_KORK, OPINTUKI_KOTONA_AS, OPINTUKI_IKA, 0, OPINTUKI_OMA_TULO, OPINTUKI_VANH_TULO, OPINTUKI_VANH_VARALL);
END;

%OpTukiTakaisin&F(TAKPER1, OPINTUKI_VUOSI, 1, INF, OPINTUKI_TUKIAIKA, OPINTUKI_OMA_TULO - (OPIR * OPINTUKI_TUKIAIKA), (OPIR * OPINTUKI_TUKIAIKA));


/* Kuukausitaso */
OPRAHAK = OPIR - (TAKPER1 / OPINTUKI_TUKIAIKA);
/* Vuositaso */ 
OPRAHAV = (OPIR * OPINTUKI_TUKIAIKA) - TAKPER1;

DROP OPIR TAKPER1;


/* 4.2.2 Lasketaan opintotuen asumislisä ja takaisinperintä */

IF &VUOSIKA = 2 THEN DO;
	%AsumLisaK&F(ASLIS, OPINTUKI_VUOSI, OPINTUKI_KUUK, INF, OPINTUKI_KORK, OPINTUKI_IKA, 0, OPINTUKI_ASKUST, OPINTUKI_OMA_TULO, OPINTUKI_VANH_TULO, OPINTUKI_PUOL_TULO);
END;
ELSE DO;
	%AsumLisaV&F(ASLIS, OPINTUKI_VUOSI, INF, OPINTUKI_KORK, OPINTUKI_IKA, 0, OPINTUKI_ASKUST, OPINTUKI_OMA_TULO, OPINTUKI_VANH_TULO, OPINTUKI_PUOL_TULO);
END;

%OpTukiTakaisin&F(TAKPER2, OPINTUKI_VUOSI, 1, INF, OPINTUKI_TUKIAIKA, OPINTUKI_OMA_TULO - (OPIR * OPINTUKI_TUKIAIKA), (ASLIS * OPINTUKI_TUKIAIKA));


/* Kuukausitaso */
ASUMLISAK = ASLIS - (TAKPER2 / OPINTUKI_TUKIAIKA);
/* Vuositaso */ 
ASUMLISAV = (ASLIS * OPINTUKI_TUKIAIKA)- TAKPER2;

DROP ASLIS TAKPER2;

/* 4.2.3 Lasketaan (potentiaalinen) opintolainan valtiontakaus */

IF &VUOSIKA = 2 THEN DO;
	%OpLainaK&F(OPLAI, OPINTUKI_VUOSI, OPINTUKI_KUUK, INF, OPINTUKI_KORK, OPINTUKI_AIKKOUL, OPINTUKI_IKA);
END;
ELSE DO;
	%OpLainaV&F(OPLAI, OPINTUKI_VUOSI, INF, OPINTUKI_KORK, OPINTUKI_AIKKOUL, OPINTUKI_IKA);
END;

/* Kuukausitaso */
OPLAINAK = OPLAI;
/* Vuositaso */ 
OPLAINAV = OPLAI * OPINTUKI_TUKIAIKA;

DROP OPLAI;

/* 4.2.4 Lasketaan aikuisopintoraha */

IF &VUOSIKA = 2 THEN DO;
	%AikOpinRahaK&F (AIKOPRAHA, OPINTUKI_VUOSI, OPINTUKI_KUUK, INF, OPINTUKI_KORK, OPINTUKI_OMA_TULO);
END;
ELSE DO; 
	%AikOpinRahaV&F (AIKOPRAHA, OPINTUKI_VUOSI, INF, OPINTUKI_KORK, OPINTUKI_OMA_TULO);
END;

/* Kuukausitaso */
AIKOPRAHAK = AIKOPRAHA;
/* Vuositaso */ 
AIKOPRAHAV = AIKOPRAHA * OPINTUKI_TUKIAIKA;

DROP AIKOPRAHA;

/* 4.2.5 Lasketaan aikuiskoulutustuki */

IF &VUOSIKA = 2 THEN DO;
	%AikKoulTukiK&F (AIKKOULTUKI, OPINTUKI_VUOSI, OPINTUKI_KUUK, INF, OPINTUKI_OMA_TULO);
END;
ELSE DO;
	%AikKoulTukiV&F (AIKKOULTUKI, OPINTUKI_VUOSI, INF, OPINTUKI_OMA_TULO);
END;

/* Kuukausitaso */
AIKKOULTUKIK = AIKKOULTUKI;
/* Vuositaso */ 
AIKKOULTUKIV = AIKKOULTUKI * OPINTUKI_TUKIAIKA;

DROP AIKKOULTUKI;

DROP kuuknro taulu_ot w y z testi kuuid;

/* 4.3 Määritellään muuttujille selkokieliset selitteet */

LABEL 
OPINTUKI_VUOSI = 'Lainsäädäntövuosi'
OPINTUKI_KUUK = 'Lainsäädäntökuukausi'
OPINTUKI_AIKKOUL = 'Aikuiskoulutusopiskelija (0/1)'
OPINTUKI_KOTONA_AS = 'Asuu vanhempien luona (0/1)'
OPINTUKI_KORK = 'Opiskeluaste (1=korkeakoulu, 0=keskiaste)'
OPINTUKI_TUKIAIKA = 'Tukikuukaudet vuodessa' 
OPINTUKI_IKA = 'Ikä vuosina'
OPINTUKI_OMA_TULO = 'Omat veronalaiset tulot ja apurahat, e/v'
OPINTUKI_ASKUST = 'Asumiskustannukset, e/kk'
OPINTUKI_PUOL_TULO = 'Puolison veronalaiset tulot, e/v'
OPINTUKI_VANH_TULO = 'Vanhempien veronalaiset tulot, e/v'
OPINTUKI_VANH_VARALL = 'Vanhempien varallisuus, e'
INF = 'Inflaatiokorjauksessa käytettävä kerroin'

OPRAHAK = 'Opintoraha, e/kk' 
ASUMLISAK = 'Opintotuen asumislisä, e/kk' 
OPLAINAK = 'Opintolainan valtiontakaus, e/kk' 
OPRAHAV = 'Opintoraha, e/v' 
ASUMLISAV = 'Opintotuen asumislisä, e/v' 
OPLAINAV = 'Opintolainan valtiontakaus, e/v' 
AIKOPRAHAK = 'Aikuisopintoraha, e/kk' 
AIKOPRAHAV = 'Aikuisopintoraha, e/v' 
AIKKOULTUKIK = 'Aikuiskoulutustuki, e/kk' 
AIKKOULTUKIV = 'Aikuiskoulutustuki, e/v';

KEEP &VALITUT;
%IF &VUOSIKA NE 2 %THEN %DO;
	DROP OPINTUKI_KUUK;
%END;

RUN;

%IF &EXCEL = 1 %THEN %DO;
	ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_OT..xls"  STYLE = MINIMAL;
%END;

PROC PRINT NOOBS LABEL DATA = OUTPUT.&TULOSNIMI_OT;
TITLE "ESIMERKKILASKELMA, OPINTUKI";
RUN;

%IF &EXCEL = 1 %THEN %DO;
	ODS HTML3 CLOSE;
%END;

%MEND OpinTuki_Simuloi_Esimerkki;

%OpinTuki_Simuloi_Esimerkki;



