/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyödyntää Tilastokeskuksen yleisten
* käyttöehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto päähakemistossa.
******************************************************************************/

/***********************************************************
* Kuvaus: Kiinteistöverotuksen esimerkkilaskelmien pohja   *
* Tekijä: Anne Perälahti / TK			         		   *
* Luotu: 5.9.2012				       					   *
* Viimeksi päivitetty: 5.9.2012			     		       *
* Päivittäjä: Olli Kannas / TK  			     	  	   *
************************************************************/

/*
ESIMERKKILASKENNASSA LASKETAAN PIENTALOILLE, MAAPOHJALLE JA VAPAA-AJAN ASUNNOILLE KIINTEISTÖVERO. 
*/

/* 1. Esimerkkilaskentaa ohjaavat makromuuttujat */

%MACRO Aloitus;

%LET TYYPPI = ESIM; 			* Parametrien hakutapa, aina ESIM ;

/* Jos mallia käytetään käyttöliittymästä (&EG = 1), niin seuraavia vaiheita ei ajeta */

%IF &EG NE 1 %THEN %DO;

%LET TULOSNIMI_KV = kivero_esim_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;
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
%LET LAKIMAK_TIED_KV = KIVEROlakimakrot;	* Lakimakroissa käytettävän tiedoston nimi ;
%LET APUMAKROT = 1;   	* Apumakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
%LET APUMAK_TIED_KV = KIVEROapumakrot; * Apumakroissa käytettävän tiedoston nimi ;
%LET EXCEL = 1; 		 * Viedäänkö tulostaulukko automaattisesti Exceliin (1 = Kyllä, 0 = Ei) ;

* Käytettävien parametritiedostojen nimet ;

%LET PKIVERO = pkivero;

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
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_KV..sas";
%END;

/* Ajetaan apumakrot ja tallennetaan ne (optio) */

%IF &APUMAKROT = 1 %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&APUMAK_TIED_KV..sas";
%END;

%MEND TeeMakrot;

%TeeMakrot;

/* 3. Datan generointia ohjaavat makromuuttujat */

%MACRO Generoi_Muuttujat;

/* Jos mallia käytetään käyttöliittymästä (&EG = 1), niin seuraavia vaiheita ei ajeta */

%IF &EG NE 1 %THEN %DO;

/* 3.1 Fiktiivinen data */

* Lainsäädäntövuosi (2009-);
%LET MINIMI_KIVERO_VUOSI = 2012;
%LET MAKSIMI_KIVERO_VUOSI = 2012;

/******************************************************/
/* KÄYTETÄÄN SEKÄ PIENTALOJEN ETTÄ VAPAA-AJAN ASUNTOJEN KIINTEISTÖVERON LASKENNASSA */

* Rakennustyyppi (1 = pientalo, 2 = vapaa-ajan asunto);
%LET MINIMI_KIVERO_RAKTYYPPI = 1; 
%LET MAKSIMI_KIVERO_RAKTYYPPI = 1;

* Rakennuksen valmistumisvuosi;
%LET MINIMI_KIVERO_VALMVUOSI = 2010;
%LET MAKSIMI_KIVERO_VALMVUOSI = 2010; 
%LET KYNNYS_KIVERO_VALMVUOSI = 1;

* Kantava rakenne (1 = puu, 2 = kivi);
%LET MINIMI_KIVERO_KANTARAKENNE = 2; 
%LET MAKSIMI_KIVERO_KANTARAKENNE = 2;
	
* Rakennuksen pinta-ala m2;
%LET MINIMI_KIVERO_RAKENNUSPA = 100; 
%LET MAKSIMI_KIVERO_RAKENNUSPA = 100;
%LET KYNNYS_KIVERO_RAKENNUSPA = 10;		

* Rakennukselle määrätty kiinteistöveroprosentti;
%LET MINIMI_KIVERO_VEROPROS = 0.30; 
%LET MAKSIMI_KIVERO_VEROPROS = 0.8;
%LET KYNNYS_KIVERO_VEROPROS = 0.1;

* Sähkökoodi (0=ei, 1=kyllä);
%LET MINIMI_KIVERO_SAHKOK = 1; 
%LET MAKSIMI_KIVERO_SAHKOK = 1;			

* Vesijohtotieto (0=ei, 1=kyllä);
%LET MINIMI_KIVERO_VESIK = 1; 
%LET MAKSIMI_KIVERO_VESIK = 1;

/******************************************************/
/* KÄYTETÄÄN VAIN PIENTALOJEN KIINTEISTÖVERON LASKENNASSA */

* Pientalon viimeistelemättömän kellarin pinta-ala (m2);
%LET MINIMI_KIVERO_KELLARIPA = 0; 
%LET MAKSIMI_KIVERO_KELLARIPA = 0;
%LET KYNNYS_KIVERO_KELLARIPA = 10;	
	
* Lämmityskoodi (1=keskuslämmitys, 2=ei keskuslämmitystä, 3=sähkölämmitys);
%LET MINIMI_KIVERO_LAMMITYSK = 1; 
%LET MAKSIMI_KIVERO_LAMMITYSK = 1;	

/******************************************************/
/* KÄYTETÄÄN VAIN VAPAA-AJAN ASUNTOJEN KIINTEISTÖVERON LASKENNASSA */

* Vapaa-ajan asunnon talviasuttavuus (0=ei, 1=kyllä);
%LET MINIMI_KIVERO_TALVIASK = 0; 
%LET MAKSIMI_KIVERO_TALVIASK = 0;	

* Viemäritieto (0=ei, 1=kyllä);
%LET MINIMI_KIVERO_VIEMARIK = 0; 
%LET MAKSIMI_KIVERO_VIEMARIK = 0;

* Vapaa-ajan asunnon wc-tieto (0=ei, 1=kyllä);
%LET MINIMI_KIVERO_WCK = 0; 
%LET MAKSIMI_KIVERO_WCK = 0;	

* Vapaa-ajan asunnon saunatieto (0=ei, 1=kyllä);
%LET MINIMI_KIVERO_SAUNAK = 0; 
%LET MAKSIMI_KIVERO_SAUNAK = 0;		

/******************************************************/
/* KÄYTETÄÄN VAIN MAAPOHJAN KIINTEISTÖVERON LASKENNASSA */

* Tontin verotusarvo e;
%LET MINIMI_KIVERO_VEROTUSARVO = 50000; 
%LET MAKSIMI_KIVERO_VEROTUSARVO = 50000;
%LET KYNNYS_KIVERO_VEROTUSARVO = 1000;	

* Yleinen kiinteistöveroprosentti;
%LET MINIMI_KIVERO_KIINTPROS = 0.60; 
%LET MAKSIMI_KIVERO_KIINTPROS = 1.4;
%LET KYNNYS_KIVERO_KIINTPROS = 0.1;	

/******************************************************/

%END;


/* 4. Fiktiivisen aineiston luominen ja simulointi */

/* 4.1 Generoidaan data makromuuttujien arvojen mukaisesti */ 

DATA OUTPUT.&TULOSNIMI_KV;

DO KIVERO_VUOSI = &MINIMI_KIVERO_VUOSI TO &MAKSIMI_KIVERO_VUOSI;
DO KIVERO_RAKTYYPPI = &MINIMI_KIVERO_RAKTYYPPI TO &MAKSIMI_KIVERO_RAKTYYPPI;
DO KIVERO_VALMVUOSI = &MINIMI_KIVERO_VALMVUOSI TO &MAKSIMI_KIVERO_VALMVUOSI BY &KYNNYS_KIVERO_VALMVUOSI; 
DO KIVERO_KANTARAKENNE = &MINIMI_KIVERO_KANTARAKENNE TO &MAKSIMI_KIVERO_KANTARAKENNE;
DO KIVERO_RAKENNUSPA = &MINIMI_KIVERO_RAKENNUSPA TO &MAKSIMI_KIVERO_RAKENNUSPA BY &KYNNYS_KIVERO_RAKENNUSPA; 	
DO KIVERO_VEROPROS = &MINIMI_KIVERO_VEROPROS TO &MAKSIMI_KIVERO_VEROPROS BY &KYNNYS_KIVERO_VEROPROS;
DO KIVERO_SAHKOK = &MINIMI_KIVERO_SAHKOK TO &MAKSIMI_KIVERO_SAHKOK;
DO KIVERO_VESIK = &MINIMI_KIVERO_VESIK TO &MAKSIMI_KIVERO_VESIK;
DO KIVERO_KELLARIPA = &MINIMI_KIVERO_KELLARIPA TO &MAKSIMI_KIVERO_KELLARIPA BY &KYNNYS_KIVERO_KELLARIPA;	
DO KIVERO_LAMMITYSK = &MINIMI_KIVERO_LAMMITYSK TO &MAKSIMI_KIVERO_LAMMITYSK;		
DO KIVERO_TALVIASK = &MINIMI_KIVERO_TALVIASK TO &MAKSIMI_KIVERO_TALVIASK;		
DO KIVERO_VIEMARIK = &MINIMI_KIVERO_VIEMARIK TO &MAKSIMI_KIVERO_VIEMARIK;
DO KIVERO_WCK = &MINIMI_KIVERO_WCK TO &MAKSIMI_KIVERO_WCK;			
DO KIVERO_SAUNAK = &MINIMI_KIVERO_SAUNAK TO &MAKSIMI_KIVERO_SAUNAK;
DO KIVERO_VEROTUSARVO = &MINIMI_KIVERO_VEROTUSARVO TO &MAKSIMI_KIVERO_VEROTUSARVO BY &KYNNYS_KIVERO_VEROTUSARVO;	
DO KIVERO_KIINTPROS = &MINIMI_KIVERO_KIINTPROS TO &MAKSIMI_KIVERO_KIINTPROS BY &KYNNYS_KIVERO_KIINTPROS;

%IF &INF = 999 %THEN %DO;
%IndKerroin_ESIM(&AVUOSI, KIVERO_VUOSI);
%END;
%ELSE %DO; 
	INF = &INF;
%END;

OUTPUT;
END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;

RUN;

%MEND Generoi_Muuttujat;

%Generoi_Muuttujat;


/* 4.2 Simuloidaan valitut muuttujat esimerkkiaineistolla */

%MACRO KiVero_Simuloi_Esimerkki;

DATA OUTPUT.&TULOSNIMI_KV;
SET OUTPUT.&TULOSNIMI_KV;

IF KIVERO_RAKTYYPPI = 2 THEN KIVERO_RAKTYYPPI2 = 7;
IF KIVERO_RAKTYYPPI = 1 THEN KIVERO_RAKTYYPPI2 = 1;

/* 4.2.1 Lasketaan pientalon verotusarvo */

%PtVerotusArvoS(KIVERO_PTVARVO, KIVERO_VUOSI, INF, KIVERO_RAKTYYPPI2, KIVERO_VALMVUOSI, 1, KIVERO_KANTARAKENNE, KIVERO_RAKENNUSPA, KIVERO_KELLARIPA, 
KIVERO_VESIK, KIVERO_LAMMITYSK, KIVERO_SAHKOK, 1);

/* 4.2.2 Lasketaan pientalon kiinteistövero */

%KiVeroPtS(KIVERO_PTKIVERO, KIVERO_VUOSI, INF, KIVERO_RAKTYYPPI2, KIVERO_VALMVUOSI, 1, KIVERO_KANTARAKENNE, KIVERO_RAKENNUSPA, KIVERO_KELLARIPA, 
KIVERO_VESIK, KIVERO_LAMMITYSK, KIVERO_SAHKOK, 1, KIVERO_VEROPROS);

/* 4.2.3 Lasketaan vapaa-ajan asunnon verotusarvo */

%VapVerotusArvoS(KIVERO_VAPVARVO, KIVERO_VUOSI, INF, KIVERO_RAKTYYPPI2, KIVERO_VALMVUOSI, 1, KIVERO_KANTARAKENNE, KIVERO_RAKENNUSPA, 
KIVERO_TALVIASK, KIVERO_SAHKOK, KIVERO_VIEMARIK, KIVERO_VESIK, KIVERO_WCK, KIVERO_SAUNAK, 1);

/* 4.2.4 Lasketaan vapaa-ajan asunnon kiinteistövero */

%KiVeroVapS(KIVERO_VAPKIVERO, KIVERO_VUOSI, INF, KIVERO_RAKTYYPPI2, KIVERO_VALMVUOSI, 1, KIVERO_KANTARAKENNE, KIVERO_RAKENNUSPA, 
KIVERO_TALVIASK, KIVERO_SAHKOK, KIVERO_VIEMARIK, KIVERO_VESIK, KIVERO_WCK, KIVERO_SAUNAK, 1, KIVERO_VEROPROS);

/* 4.2.5 Lasketaan maapohjan kiinteistövero e/v */

KIVERO_MPKIVE = KIVERO_VEROTUSARVO * (KIVERO_KIINTPROS / 100);

/* 4.2.6 Lasketaan kiinteistöverot yhteensä e/v */

KIVERO_KIVEROYHT = SUM(KIVERO_PTKIVERO, KIVERO_VAPKIVERO, KIVERO_MPKIVE);

DROP taulu_kv X KIVERO_RAKTYYPPI2;

/* 4.3 Määritellään muuttujille selkokieliset selitteet */

LABEL 
KIVERO_VUOSI = 'Lainsäädäntövuosi'
KIVERO_RAKTYYPPI = 'Rakennustyyppi (1=pientalo, 2=vapaa-ajan asunto)'
KIVERO_VALMVUOSI = 'Rakennuksen valmistumisvuosi'
KIVERO_KANTARAKENNE = 'Kantava rakenne (1=puu, 2=kivi)'
KIVERO_RAKENNUSPA = 'Rakennuksen pinta-ala, m2'
KIVERO_VEROPROS = 'Rakennukselle määrätty kiinteistöveroprosentti'
KIVERO_SAHKOK = 'Sähkökoodi (0/1)'
KIVERO_VESIK = 'Vesijohtotieto (0/1)'
KIVERO_KELLARIPA = 'Pientalon viimeistelemättömän kellarin pinta-ala, m2'
KIVERO_LAMMITYSK = 'Lämmityskoodi (1=keskuslämmitys, 2=ei keskuslämmitystä, 3=sähkölämmitys)'
KIVERO_TALVIASK = 'Vapaa-ajan asunnon talviasuttavuus (0/1)'
KIVERO_VIEMARIK = 'Viemäritieto (0/1)'
KIVERO_WCK = 'Vapaa-ajan asunnon wc-tieto (0/1)'
KIVERO_SAUNAK = 'Vapaa-ajan asunnon saunatieto (0/1)'
KIVERO_VEROTUSARVO = 'Tontin verotusarvo, e'	
KIVERO_KIINTPROS = 'Yleinen kiinteistöveroprosentti'

INF = 'Inflaatiokorjauksessa käytettävä kerroin'

KIVERO_PTVARVO = 'Pientalon verotusarvo, e'
KIVERO_PTKIVERO = 'Pientalon kiinteistövero, e/v'
KIVERO_VAPVARVO = 'Vapaa-ajan asunnon verotusarvo, e'
KIVERO_VAPKIVERO = 'Vapaa-ajan asunnon kiinteistövero, e/v'
KIVERO_MPKIVE = 'Maapohjan kiinteistövero e/v'
KIVERO_KIVEROYHT = 'Kiinteistöverot yhteensä e/v';

KEEP &VALITUT;

RUN;

%IF &EXCEL = 1 %THEN %DO;
	ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_KV..xls" STYLE = MINIMAL;
%END;

PROC PRINT NOOBS LABEL DATA = OUTPUT.&TULOSNIMI_KV;
TITLE "ESIMERKKILASKELMA, KIVERO";
RUN;

%IF &EXCEL = 1 %THEN %DO;
	ODS HTML3 CLOSE;
%END;

%MEND Kivero_Simuloi_Esimerkki;

%Kivero_Simuloi_Esimerkki;
