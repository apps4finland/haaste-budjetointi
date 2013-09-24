/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyödyntää Tilastokeskuksen yleisten
* käyttöehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto päähakemistossa.
******************************************************************************/

/**************************************************************************
* Kuvaus: Sairausvakuutuksen päivärahojen esimerkkilaskelmien pohja       *
* Tekijä: Pertti Honkanen / KELA	                		   			  *
* Luotu: 4.4.2012				       					   				  *
* Viimeksi päivitetty: 5.4.2012			     		   				      *
* Päivittäjä: Olli Kannas / TK		     		   	   				      *
***************************************************************************/  


/* 1. Esimerkkilaskentaa ohjaavat makromuuttujat */

%MACRO Aloitus;

%LET TYYPPI = ESIM; * Parametrien hakutapa, aina ESIM ;

/* Jos mallia käytetään käyttöliittymästä (&EG = 1), niin seuraavia vaiheita ei ajeta */

%IF &EG NE 1 %THEN %DO;

%LET TULOSNIMI_SV = sairvak_esim_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;
%LET VUOSIKA = 1; 				* 1 = Vuosikeskiarvo, 2 = datassa annetun kuukauden lainsäädäntö ;
%LET VALITUT =  _ALL_; 		* Tulostaulukossa näytettävät muuttujat ;

* Inflaatiokorjaus. Parametrien deflatoinnissa käytettävän kertoimen voi syöttää itse
  INF-makromuuttujaan (HUOM! desimaalit erotettava pisteellä .). Jos puolestaan haluaa käyttää automaattista 
  elinkustannusindeksiin perustuvaa parametrien muunnoskerrointa, 
  tulee INF-makromuuttujalle antaa arvoksi 999.
  Tällöin on annettava myös perusvuosi, johon aineiston lainsäädäntövuotta verrataan; 	

%LET INF = 1.00; * Syötä arvo tai 999 ;
%LET AVUOSI = 2012; *Perusvuosi inflaatiokorjausta varten;
%LET PINDEKSI_VUOSI = pindeksi_vuosi; *Käytettävä indeksien parametritaulukko;

* Laki- ja apumakro-ohjelmien ajon säätäminen ; 
* HUOM! Tulonhakkimiskulujen vähentämistä varten tarvitaan myös VERO-mallin makroja ja parametreja; 

%LET LAKIMAKROT = 1;    * Lakimakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
%LET LAKIMAK_TIED_SV = SAIRVAKlakimakrot;	* SAIRVAK-lakimakroissa käytettävän tiedoston nimi ;
%LET LAKIMAK_TIED_VE = VEROlakimakrot;		* VERO-lakimakroissa käytettävän tiedoston nimi ;

%LET APUMAKROT = 1;   	* Apumakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
%LET APUMAK_TIED_SV = SAIRVAKapumakrot; * SAIRVAK-apumakroissa käytettävän tiedoston nimi ;
%LET APUMAK_TIED_VE = VEROapumakrot; * VERO-apumakroissa käytettävän tiedoston nimi ;
%LET EXCEL = 1; 		 * Viedäänkö tulostaulukko automaattisesti Exceliin (1 = Kyllä, 0 = Ei) ;

%LET PSAIRVAK = psairvak; * Käytettävän SAIRVAK-parametritiedoston nimi ;
%LET PVERO = pvero;		  * Käytettävän VERO-parametritiedoston nimi ;

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
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_SV..sas";
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_VE..sas";
%END;

/* Ajetaan apumakrot ja tallennetaan ne (optio) */

%IF &APUMAKROT = 1 %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&APUMAK_TIED_SV..sas";
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&APUMAK_TIED_VE..sas";
%END;

%MEND TeeMakrot;

%TeeMakrot;


/* 3. Datan generointia ohjaavat makromuuttujat */

%MACRO Generoi_Muuttujat;

/* Jos mallia käytetään käyttöliittymästä (&EG = 1), niin seuraavia vaiheita ei ajeta */

%IF &EG NE 1 %THEN %DO;

/* 3.1 Fiktiivinen data */

* Lainsäädäntövuosi (1985-);
%LET MINIMI_SAIRVAK_VUOSI = 2012;
%LET MAKSIMI_SAIRVAK_VUOSI = 2012;

* Lainsäädäntökuukausi (1-12);
%LET MINIMI_SAIRVAK_KUUK = 12;
%LET MAKSIMI_SAIRVAK_KUUK = 12;

* Onko kyse vanhempainrahasta (1 = tosi, 0 = epätosi));
%LET MINIMI_SAIRVAK_VANHRAHA = 1;
%LET MAKSIMI_SAIRVAK_VANHRAHA = 1;

* Onko kyse korotetusta äitiyspäivärahasta (1 = tosi, 0 = epätosi)
  (tarkoittaa 90 ensimmäiseltä äitiyslomapäivältä maksettavaa päivärahaa (2007-));
%LET MINIMI_SAIRVAK_KORAIT = 0;
%LET MAKSIMI_SAIRVAK_KORAIT = 0;

* Onko kyse korotetusta vanhempainrahasta (1 = tosi, 0 = epätosi)
  (tarkoittaa 56 päivältä maksettavaa korotettua päivärahaa (2007-));
%LET MINIMI_SAIRVAK_KORVANH = 0;
%LET MAKSIMI_SAIRVAK_KORVANH = 1;

*Alle 18-v. lasten lukumäärä (Huom! Lapsikorotuksia ei ole laissa vuoden 1993 jälkeen);
%LET MINIMI_SAIRVAK_LAPSIA = 0 ;
%LET MAKSIMI_SAIRVAK_LAPSIA = 0 ; 

*Päivärahan perusteena oleva palkka (e/kk);
%LET MINIMI_SAIRVAK_KUUKPALK = 4000 ; 
%LET MAKSIMI_SAIRVAK_KUUKPALK = 4000 ;
%LET KYNNYS_SAIRVAK_KUUKPALK = 500; 

* Tulonhankkimiskulut (e/kk);
%LET MINIMI_SAIRVAK_TULONHANKKULUT = 0;
%LET MAKSIMI_SAIRVAK_TULONHANKKULUT = 0;
%LET KYNNYS_SAIRVAK_TULONHANKKULUT = 100;

* Ay-jäsenmaksut (e/kk);
%LET MINIMI_SAIRVAK_AYMAKSUT = 50;
%LET MAKSIMI_SAIRVAK_AYMAKSUT = 50; 
%LET KYNNYS_SAIRVAK_AYMAKSUT = 10;

* Työmatkakulut (e/kk);
%LET MINIMI_SAIRVAK_TYOMATKAKULUT = 0;
%LET MAKSIMI_SAIRVAK_TYOMATKAKULUT = 0; 
%LET KYNNYS_SAIRVAK_TYOMATKAKULUT = 100;

%END;


/* 4. Fiktiivisen aineiston luominen ja simulointi */

/* 4.1 Generoidaan data makromuuttujien arvojen mukaisesti */ 

DATA OUTPUT.&TULOSNIMI_SV;

DO SAIRVAK_VUOSI = &MINIMI_SAIRVAK_VUOSI TO &MAKSIMI_SAIRVAK_VUOSI;
DO SAIRVAK_KUUK = &MINIMI_SAIRVAK_KUUK TO &MAKSIMI_SAIRVAK_KUUK;
DO SAIRVAK_LAPSIA = &MINIMI_SAIRVAK_LAPSIA TO &MAKSIMI_SAIRVAK_LAPSIA;
DO SAIRVAK_KUUKPALK = &MINIMI_SAIRVAK_KUUKPALK TO &MAKSIMI_SAIRVAK_KUUKPALK BY &KYNNYS_SAIRVAK_KUUKPALK;
DO SAIRVAK_VANHRAHA = &MINIMI_SAIRVAK_VANHRAHA TO &MAKSIMI_SAIRVAK_VANHRAHA;
DO SAIRVAK_KORAIT = &MINIMI_SAIRVAK_KORAIT TO &MAKSIMI_SAIRVAK_KORAIT;
DO SAIRVAK_KORVANH = &MINIMI_SAIRVAK_KORVANH TO &MAKSIMI_SAIRVAK_KORVANH;
DO SAIRVAK_TULONHANKKULUT = &MINIMI_SAIRVAK_TULONHANKKULUT TO &MAKSIMI_SAIRVAK_TULONHANKKULUT BY &KYNNYS_SAIRVAK_TULONHANKKULUT;
DO SAIRVAK_AYMAKSUT = &MINIMI_SAIRVAK_AYMAKSUT TO &MAKSIMI_SAIRVAK_AYMAKSUT BY &KYNNYS_SAIRVAK_AYMAKSUT;
DO SAIRVAK_TYOMATKAKULUT = &MINIMI_SAIRVAK_TYOMATKAKULUT TO &MAKSIMI_SAIRVAK_TYOMATKAKULUT BY &KYNNYS_SAIRVAK_TYOMATKAKULUT;

%IF &INF = 999 %THEN %DO;
%IndKerroin_ESIM(&AVUOSI, SAIRVAK_VUOSI);
%END;
%ELSE %DO; 
	INF = &INF;
%END;

OUTPUT;
END;END;END;END;END;END;END;END;END;END;

RUN;

%MEND Generoi_Muuttujat;

%Generoi_Muuttujat;


/* 4.2 Simuloidaan valitut muuttujat esimerkkiaineistolla */

%MACRO SairVak_Simuloi_Esimerkki;

DATA OUTPUT.&TULOSNIMI_SV;
SET OUTPUT.&TULOSNIMI_SV;

/* Tulonhankkimiskulut vähennetään työtulosta, joka on päivärahan perusteena */

%TulonHankKulut&F(TULHANKSUMS, SAIRVAK_VUOSI, INF, 12*SAIRVAK_KUUKPALK, 12*SAIRVAK_KUUKPALK, 12*SAIRVAK_TULONHANKKULUT,
	12*SAIRVAK_AYMAKSUT, 12*SAIRVAK_TYOMATKAKULUT, 12);

/* Lakimakroissa tulokäsitteenä on vuositulo */

SAIRVAK_VUOSITULO = MAX(SUM(12 * SAIRVAK_KUUKPALK, -TULHANKSUMS), 0);

/* Korotetut vanhempainrahat lasketaan vain, jos SAIRVAK_VANHRAHA = 1 */

IF SAIRVAK_VANHRAHA = 0 THEN DO;
	SAIRVAK_KORVANH = 0;
	SAIRVAK_KORAIT = 0;
END;

/* Koska ei voi olla yhtä aikaa SAIRVAK_KORAIT = 1 ja SAIRVAK_KORVANH = 1,
   suljetaan ristiriitaiset tapaukset pois */

IF SAIRVAK_KORAIT = 1 THEN SAIRVAK_KORVANH = 0;

IF SAIRVAK_KORVANH = 1 THEN SAIRVAK_KORAIT = 0;

/* 4.2.1 Tavalliset päivärahat */

IF SAIRVAK_KORAIT = 0 AND SAIRVAK_KORVANH = 0 THEN DO;

	IF &VUOSIKA = 1 THEN DO;
		%SairVakPrahaV&F (SPRAHAK, SAIRVAK_VUOSI, INF, SAIRVAK_VANHRAHA, SAIRVAK_LAPSIA, SAIRVAK_VUOSITULO);
 	END;
	ELSE DO;
		%SairVakPrahaK&F (SPRAHAK, SAIRVAK_VUOSI, SAIRVAK_KUUK, INF, SAIRVAK_VANHRAHA, SAIRVAK_LAPSIA, SAIRVAK_VUOSITULO);
	END;
	
END;

/* 4.2.2 Korotetut päivärahat */

ELSE DO;

	IF &VUOSIKA = 1 THEN DO;
		%KorVanhRahaV&F (SPRAHAK, SAIRVAK_VUOSI,  INF, SAIRVAK_KORAIT, SAIRVAK_LAPSIA, SAIRVAK_VUOSITULO);
	END;
	ELSE DO;
		%KorVanhRahaK&F (SPRAHAK, SAIRVAK_VUOSI, SAIRVAK_KUUK, INF, SAIRVAK_KORAIT, SAIRVAK_LAPSIA, SAIRVAK_VUOSITULO);
	END;

END;	


SPRAHAP = SPRAHAK / &SPaivat;
		
SPRAHAV = 12 *  SPRAHAK;

DROP kuuknro taulu_sv w y z testi taulua X TULHANKSUMS;

/* 4.3 Määritellään muuttujille selkokieliset selitteet */

LABEL 
SAIRVAK_VUOSI = 'Lainsäädäntövuosi'
SAIRVAK_KUUK = 'Lainsäädäntökuukausi'
SAIRVAK_LAPSIA = 'Alle 18-v. lasten lkm'
SAIRVAK_KUUKPALK = 'Päivärahan perusteena oleva kuukausipalkka'
SAIRVAK_TULONHANKKULUT = 'Tulonhankkimiskulut, (e/kk)'
SAIRVAK_AYMAKSUT = 'Ay-jäsenmaksut, (e/kk)'
SAIRVAK_TYOMATKAKULUT = 'Työmatkakulut, (e/kk)'
SAIRVAK_VUOSITULO = 'Päivärahan perusteena oleva vuositulo'
SAIRVAK_VANHRAHA = 'Onko vanhempainpäiväraha (0/1)'
SAIRVAK_KORAIT = 'Onko korotettu äitiyspäiväraha (0/1)'
SAIRVAK_KORVANH = 'Onko korotettu vanhempainraha (0/1)'
INF = 'Inflaatiokorjauksessa käytettävä kerroin'

SPRAHAK = 'Päiväraha, e/kk'
SPRAHAV = 'Päiväraha, e/v'
SPRAHAP = 'Päiväraha, e/pv';

KEEP &VALITUT;

%IF &VUOSIKA NE 2 %THEN %DO;
	DROP SAIRVAK_KUUK;
%END;

RUN;

%IF &EXCEL = 1 %THEN %DO;
	ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_SV..xls"  STYLE = MINIMAL;
%END;

PROC PRINT NOOBS LABEL DATA = OUTPUT.&TULOSNIMI_SV;
TITLE "ESIMERKKILASKELMA, SAIRVAK";
RUN;

%IF &EXCEL = 1 %THEN %DO;
	ODS HTML3 CLOSE;
%END;


%MEND SairVak_Simuloi_Esimerkki;

%SairVak_Simuloi_Esimerkki;


