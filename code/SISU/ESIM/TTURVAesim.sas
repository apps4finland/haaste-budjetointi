/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyödyntää Tilastokeskuksen yleisten
* käyttöehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto päähakemistossa.
******************************************************************************/

/***********************************************************
* Kuvaus: Työttömyysturvan esimerkkilaskelmien pohja       *
* Tekijä: Jussi Tervola / KELA	                		   *
* Luotu: 16.12.2011				       					   *
* Viimeksi päivitetty: 31.5.2011			     		   *
* Päivittäjä: Jussi Tervola / KELA		     			   *
************************************************************; 

/* 1. Esimerkkilaskentaa ohjaavat makromuuttujat */

%MACRO Aloitus;

%LET TYYPPI = ESIM; * Parametrien hakutapa, aina ESIM ;

/* Jos mallia käytetään käyttöliittymästä (&EG = 1), niin seuraavia vaiheita ei ajeta */

%IF &EG NE 1 %THEN %DO;

%LET TULOSNIMI_TT = tturva_esim_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;
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
%LET LAKIMAK_TIED_TT = TTURVAlakimakrot;	* Lakimakroissa käytettävän tiedoston nimi ;
%LET APUMAKROT = 1;   	* Apumakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
%LET APUMAK_TIED_TT = TTURVAapumakrot; * Apumakroissa käytettävän tiedoston nimi ;
%LET EXCEL = 1; 		 * Viedäänkö tulostaulukko automaattisesti Exceliin (1 = Kyllä, 0 = Ei) ;

%LET PTTURVA = ptturva; * Käytettävän parametritiedoston nimi ;

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
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_TT..sas";
%END;

/* Ajetaan apumakrot ja tallennetaan ne (optio) */

%IF &APUMAKROT = 1 %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&APUMAK_TIED_TT..sas";
%END;

%MEND TeeMakrot;

%TeeMakrot;

%MACRO Generoi_Muuttujat;

/* 3. Datan generointia ohjaavat makromuuttujat */

/* Jos mallia käytetään käyttöliittymästä (&EG = 1), niin seuraavia vaiheita ei ajeta */

%IF &EG NE 1 %THEN %DO;

/* 3.1 Fiktiivinen data */

* Lainsäädäntövuosi (1985-);
%LET MINIMI_TTURVA_VUOSI = 2012;
%LET MAKSIMI_TTURVA_VUOSI = 2012;

* Lainsäädäntökuukausi (1-12);
%LET MINIMI_TTURVA_KUUK = 12;
%LET MAKSIMI_TTURVA_KUUK = 12;

*Alle 18-v. lasten lkm;
%LET MINIMI_TTURVA_LAPSIA = 0 ;
%LET MAKSIMI_TTURVA_LAPSIA = 0 ; 

*Toimintastatus (1 = työtön, 2 = vuorotteluvapaalla);
%LET MINIMI_TTURVA_TOIMINTA = 1 ; 
%LET MAKSIMI_TTURVA_TOIMINTA = 1 ;

*Täyttääkö työssäoloehdon (1 = tosi, 0 = epätosi);
%LET MINIMI_TTURVA_TYOSSAOLO = 1 ; 
%LET MAKSIMI_TTURVA_TYOSSAOLO = 1 ;

*Onko työttömyyskassan jäsen (1 = tosi, 0 = epätosi);
%LET MINIMI_TTURVA_TYOTKASS = 0 ; 
%LET MAKSIMI_TTURVA_TYOTKASS = 1 ;

*Onko työvoimapoliittisessa aikuiskoulutuksessa (1 = tosi, 0 = epätosi);
%LET MINIMI_TTURVA_KOULTUKI = 0 ; 
%LET MAKSIMI_TTURVA_KOULTUKI = 0 ;

* Oikeus korotettuihin päivärahoihin  
0 = ei oikeutta
1 = Oikeus ansiopäivärahojen korotettuun ansio-osaan / työmarkkinatuen tai peruspäivärahan korotusosaan / korotettuun vuorottelukorvaukseen
2 = Oikeus ansiopäivärahojen muutosturvaan
3 = Oikeus ansiopäivärahojen korotettuihin lisäpäiviin (voimassa 2003-2009);
%LET MINIMI_TTURVA_OIKEUSKOR = 0 ; 
%LET MAKSIMI_TTURVA_OIKEUSKOR = 0 ;

*Työttömyyttä edeltävä palkka (e/kk);
%LET MINIMI_TTURVA_KUUKPALK = 0 ; 
%LET MAKSIMI_TTURVA_KUUKPALK = 5000 ;
%LET KYNNYS_TTURVA_KUUKPALK =  500; 

*Onko puolisoa (1 = tosi, 0 = epätosi) ;
%LET MINIMI_TTURVA_PUOLISO = 0 ; 
%LET MAKSIMI_TTURVA_PUOLISO = 0 ; 

*Puolison veronalaiset tulot (e/kk);
%LET MINIMI_TTURVA_PUOLTULO = 0 ; 
%LET MAKSIMI_TTURVA_PUOLTULO = 0 ;
%LET KYNNYS_TTURVA_PUOLTULO = 1000; 

*Omat pääomatulot (e/kk) (tarveharkitussa työmarkkinatuessa);
%LET MINIMI_TTURVA_OMATULO = 0 ; 
%LET MAKSIMI_TTURVA_OMATULO = 0 ;
%LET KYNNYS_TTURVA_OMATULO = 1000; 

*Asuuko saaja vanhempien luona (1 = tosi, 0 = epätosi);
%LET MINIMI_TTURVA_OSITT = 0 ; 
%LET MAKSIMI_TTURVA_OSITT = 0 ; 

*Alle 18-vuotiaiden lkm vanhempien perheessä;
%LET MINIMI_TTURVA_HUOLL = 0 ;
%LET MAKSIMI_TTURVA_HUOLL = 0 ; 

* Vanhempien veronalaiset tulot (e/kk) ;
%LET MINIMI_TTURVA_VANHTULO = 0;
%LET MAKSIMI_TTURVA_VANHTULO = 0;
%LET KYNNYS_TTURVA_VANHTULO = 1000;

*Sovittelun perusteena oleva tulo (e/kk) (työttömyysaikana saatu työtulo);
%LET MINIMI_TTURVA_SOVTULO = 0;
%LET MAKSIMI_TTURVA_SOVTULO = 0;
%LET KYNNYS_TTURVA_SOVTULO = 100;

*Vähennettävä muu sosiaalietuus (e/kk);
%LET MINIMI_TTURVA_VAHSOSET = 0 ; 
%LET MAKSIMI_TTURVA_VAHSOSET = 0 ;
%LET KYNNYS_TTURVA_VAHSOSET = 1000; 

%END;


/* 4. Fiktiivisen aineiston luominen ja simulointi */

/* 4.1 Generoidaan data makromuuttujien arvojen mukaisesti */ 

DATA OUTPUT.&TULOSNIMI_TT;

DO TTURVA_VUOSI = &MINIMI_TTURVA_VUOSI TO &MAKSIMI_TTURVA_VUOSI;
DO TTURVA_KUUK = &MINIMI_TTURVA_KUUK TO &MAKSIMI_TTURVA_KUUK;

DO TTURVA_TOIMINTA = &MINIMI_TTURVA_TOIMINTA TO &MAKSIMI_TTURVA_TOIMINTA;
DO TTURVA_LAPSIA = &MINIMI_TTURVA_LAPSIA TO &MAKSIMI_TTURVA_LAPSIA;
DO TTURVA_PUOLISO = &MINIMI_TTURVA_PUOLISO TO &MAKSIMI_TTURVA_PUOLISO;
DO TTURVA_TYOSSAOLO = &MINIMI_TTURVA_TYOSSAOLO TO &MAKSIMI_TTURVA_TYOSSAOLO;
DO TTURVA_TYOTKASS = &MINIMI_TTURVA_TYOTKASS TO &MAKSIMI_TTURVA_TYOTKASS;

DO TTURVA_KUUKPALK = &MINIMI_TTURVA_KUUKPALK TO &MAKSIMI_TTURVA_KUUKPALK BY &KYNNYS_TTURVA_KUUKPALK;
DO TTURVA_SOVTULO = &MINIMI_TTURVA_SOVTULO TO &MAKSIMI_TTURVA_SOVTULO BY &KYNNYS_TTURVA_SOVTULO ; 
DO TTURVA_OIKEUSKOR = &MINIMI_TTURVA_OIKEUSKOR TO &MAKSIMI_TTURVA_OIKEUSKOR;
DO TTURVA_KOULTUKI = &MINIMI_TTURVA_KOULTUKI TO &MAKSIMI_TTURVA_KOULTUKI;
DO TTURVA_VAHSOSET = &MINIMI_TTURVA_VAHSOSET TO &MAKSIMI_TTURVA_VAHSOSET BY &KYNNYS_TTURVA_VAHSOSET ;

DO TTURVA_OMATULO = &MINIMI_TTURVA_OMATULO TO &MAKSIMI_TTURVA_OMATULO BY &KYNNYS_TTURVA_OMATULO ;
DO TTURVA_OSITT = &MINIMI_TTURVA_OSITT TO &MAKSIMI_TTURVA_OSITT; 
DO TTURVA_HUOLL = &MINIMI_TTURVA_HUOLL TO &MAKSIMI_TTURVA_HUOLL;
DO TTURVA_VANHTULO = &MINIMI_TTURVA_VANHTULO TO &MAKSIMI_TTURVA_VANHTULO BY &KYNNYS_TTURVA_VANHTULO ;

%IF &MAKSIMI_TTURVA_PUOLISO = 1 %THEN %DO;
	DO TTURVA_PUOLTULO = &MINIMI_TTURVA_PUOLTULO TO &MAKSIMI_TTURVA_PUOLTULO BY &KYNNYS_TTURVA_PUOLTULO;
%END;

%IF &INF = 999 %THEN %DO;
%IndKerroin_ESIM(&AVUOSI, TTURVA_VUOSI);
%END;
%ELSE %DO; 
	INF = &INF;
%END;

OUTPUT;
END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;

%IF &MAKSIMI_TTURVA_PUOLISO = 1 %THEN %DO;
	END;
%END;

%IF &MINIMI_TTURVA_PUOLISO = 0 %THEN %DO;

	DATA OUTPUT.&TULOSNIMI_TT; 
	SET OUTPUT.&TULOSNIMI_TT;

	IF TTURVA_PUOLISO = 0 THEN TTURVA_PUOLTULO = .;
	RUN;

%END;

RUN;

%MEND Generoi_Muuttujat;

%Generoi_Muuttujat;



/* 4.2 Simuloidaan valitut muuttujat esimerkkiaineistolla */

%MACRO TTurva_Simuloi_Esimerkki;

DATA OUTPUT.&TULOSNIMI_TT;
SET OUTPUT.&TULOSNIMI_TT;

/* 4.2.1 Työmarkkinatuki */

IF TTURVA_TOIMINTA = 1 THEN DO;

	IF TTURVA_TYOSSAOLO = 0 THEN DO;

		IF &VUOSIKA = 2 THEN DO;
			%TyomTukiK&F(TMTUKIK, TTURVA_VUOSI, TTURVA_KUUK, INF, (TTURVA_OMATULO > 0 OR TTURVA_PUOLTULO > 0), TTURVA_OSITT, TTURVA_PUOLISO, TTURVA_LAPSIA, TTURVA_HUOLL, TTURVA_OMATULO, TTURVA_PUOLTULO, TTURVA_VANHTULO, (TTURVA_OIKEUSKOR = 1), TTURVA_VAHSOSET);
		END;
		ELSE DO;
			%TyomTukiV&F(TMTUKIK, TTURVA_VUOSI, INF, (TTURVA_OMATULO > 0 OR TTURVA_PUOLTULO > 0), TTURVA_OSITT, TTURVA_PUOLISO, TTURVA_LAPSIA, TTURVA_HUOLL, TTURVA_OMATULO, TTURVA_PUOLTULO, TTURVA_VANHTULO, (TTURVA_OIKEUSKOR = 1), TTURVA_VAHSOSET);
		END;
		IF TTURVA_SOVTULO > 0 THEN DO;
			TMTUKIK = TMTUKIK + TTURVA_VAHSOSET;
			IF &VUOSIKA = 2 THEN DO;
				%SoviteltuK&F(TMTUKIK, TTURVA_VUOSI, TTURVA_KUUK, INF, 0, 0, TTURVA_LAPSIA, TMTUKIK, TTURVA_SOVTULO, 0, TTURVA_KOULTUKI);
			END;
			ELSE DO;
				%SoviteltuV&F(TMTUKIK, TTURVA_VUOSI, INF, 0, 0, TTURVA_LAPSIA, TMTUKIK, TTURVA_SOVTULO, 0, TTURVA_KOULTUKI);
			END;
		END;

		TMTUKIP = TMTUKIK / &TTPaivia;
		TMTUKIV = TMTUKIK * 12;
	
	END;

/* 4.2.2 Peruspäiväraha */

	ELSE IF (TTURVA_TYOSSAOLO = 1 OR TTURVA_VUOSI < 1994) AND TTURVA_TYOTKASS = 0 THEN DO;

		IF &VUOSIKA = 2 THEN DO;
			%PerusPRahaK&F(PERUSPRAHAK, TTURVA_VUOSI, TTURVA_KUUK, INF, (TTURVA_OMATULO > 0 OR TTURVA_PUOLTULO > 0), (TTURVA_OIKEUSKOR = 1), TTURVA_PUOLISO, TTURVA_LAPSIA, TTURVA_OMATULO, TTURVA_PUOLTULO, TTURVA_VAHSOSET);
		END;
		ELSE DO;
			%PerusPRahaV&F(PERUSPRAHAK, TTURVA_VUOSI, INF,(TTURVA_OMATULO > 0 OR TTURVA_PUOLTULO > 0), (TTURVA_OIKEUSKOR = 1), TTURVA_PUOLISO, TTURVA_LAPSIA, TTURVA_OMATULO, TTURVA_PUOLTULO, TTURVA_VAHSOSET);
		END;
		IF TTURVA_SOVTULO > 0 THEN DO;
			PERUSPRAHAK = PERUSPRAHAK + TTURVA_VAHSOSET;
			IF &VUOSIKA = 2 THEN DO;
				%SoviteltuK&F(PERUSPRAHAK, TTURVA_VUOSI, TTURVA_KUUK, INF, 0, 0, TTURVA_LAPSIA, PERUSPRAHAK, TTURVA_SOVTULO, 0, TTURVA_KOULTUKI);
			END;
			ELSE DO;
				%SoviteltuV&F(PERUSPRAHAK, TTURVA_VUOSI, INF, 0, 0, TTURVA_LAPSIA, PERUSPRAHAK, TTURVA_SOVTULO, 0, TTURVA_KOULTUKI);
			END;
		END;

		PERUSPRAHAP = PERUSPRAHAK / &TTPaivia;
		PERUSPRAHAV = PERUSPRAHAK * 12;

	END;

/* 4.2.3 Ansiosidonnainen päiväraha */

	ELSE IF TTURVA_TYOSSAOLO = 1 AND TTURVA_TYOTKASS = 1 THEN DO; 

		IF &VUOSIKA = 2 THEN DO;
			%AnsioSidK&F(ANSIOSIDK, TTURVA_VUOSI, TTURVA_KUUK, INF, TTURVA_LAPSIA, (TTURVA_OIKEUSKOR = 1), (TTURVA_OIKEUSKOR = 2), (TTURVA_OIKEUSKOR = 3), TTURVA_KUUKPALK, TTURVA_VAHSOSET);
		END;
		ELSE DO;
			%AnsioSidV&F(ANSIOSIDK, TTURVA_VUOSI, INF, TTURVA_LAPSIA, (TTURVA_OIKEUSKOR = 1), (TTURVA_OIKEUSKOR = 2), (TTURVA_OIKEUSKOR = 3), TTURVA_KUUKPALK, TTURVA_VAHSOSET);
		END;
		IF TTURVA_SOVTULO > 0 THEN DO;
			ANSIOSIDK = ANSIOSIDK + TTURVA_VAHSOSET;
			IF &VUOSIKA = 2 THEN DO;
				%SoviteltuK&F(ANSIOSIDK, TTURVA_VUOSI, TTURVA_KUUK, INF, 1, (TTURVA_OIKEUSKOR IN (1,2)), TTURVA_LAPSIA, ANSIOSIDK, TTURVA_SOVTULO, TTURVA_KUUKPALK, TTURVA_KOULTUKI);
			END;
			ELSE DO;
				%SoviteltuV&F(ANSIOSIDK, TTURVA_VUOSI, INF, 1, (TTURVA_OIKEUSKOR IN (1,2)), TTURVA_LAPSIA, ANSIOSIDK, TTURVA_SOVTULO, TTURVA_KUUKPALK, TTURVA_KOULTUKI);
			END;
		END;

		ANSIOSIDP = ANSIOSIDK / &TTPaivia;
		ANSIOSIDV = ANSIOSIDK * 12;

	END;
END;



/* 4.2.4 Vuorottelukorvaus */

ELSE IF TTURVA_TOIMINTA = 2 AND TTURVA_TYOSSAOLO = 1 THEN DO;

	IF &VUOSIKA = 2 THEN DO;
		%VuorVapKorvK&F(VUORKORVK, TTURVA_VUOSI, TTURVA_KUUK, INF, (TTURVA_TYOTKASS = 0), (TTURVA_OIKEUSKOR = 1), TTURVA_KUUKPALK);
	END;
	ELSE DO;
		%VuorVapKorvV&F(VUORKORVK, TTURVA_VUOSI, INF, (TTURVA_TYOTKASS = 0), (TTURVA_OIKEUSKOR = 1), TTURVA_KUUKPALK);
	END;
	IF TTURVA_SOVTULO > 0 THEN DO;
		VUORKORVK = VUORKORVK + TTURVA_VAHSOSET;
		IF &VUOSIKA = 2 THEN DO;
			%SoviteltuK&F(VUORKORVK, TTURVA_VUOSI, TTURVA_KUUK, INF, (TTURVA_TYOTKASS = 1), (TTURVA_OIKEUSKOR = 1), TTURVA_LAPSIA, VUORKORVK, TTURVA_SOVTULO, TTURVA_KUUKPALK, 0);
		END;
		ELSE DO;
			%SoviteltuV&F(VUORKORVK, TTURVA_VUOSI, INF, (TTURVA_TYOTKASS = 1), (TTURVA_OIKEUSKOR = 1), TTURVA_LAPSIA, VUORKORVK, TTURVA_SOVTULO, TTURVA_KUUKPALK, 0);
		END;
	END;

VUORKORVP = VUORKORVK / &TTPaivia;
VUORKORVV = VUORKORVK * 12;

END;

DROP kuuknro taulu_tt w y z testi kuuid;

/* 4.3 Määritellään muuttujille selkokieliset selitteet */

LABEL 
TTURVA_VUOSI = 'Lainsäädäntövuosi'
TTURVA_KUUK = 'Lainsäädäntökuukausi'
TTURVA_LAPSIA = 'Alle 18-v. lasten lkm'
TTURVA_OIKEUSKOR = 'Oikeus korotettuun päivärahaan (0-3)'
TTURVA_TYOTKASS = 'Työttömyyskassan jäsen (0/1)'
TTURVA_TOIMINTA = 'Toimintastatus (1/2)'
TTURVA_TYOSSAOLO = 'Työssäoloehdon täyttyminen (0/1)'
TTURVA_KOULTUKI = 'Työvoimapoliittinen koulutus (0/1)' 
TTURVA_KUUKPALK = 'Työttömyyttä edeltävä palkka, e/kk'
TTURVA_SOVTULO = 'Työttömyyden aikana saadut työtulot, e/kk'
TTURVA_VANHTULO = 'Vanhempien veronalaiset tulot, e/kk'
TTURVA_OMATULO = 'Omat (pääoma)tulot, e/kk'
TTURVA_PUOLTULO = 'Puolison veronalaiset tulot, e/kk'
TTURVA_PUOLISO = 'Onko puolisoa (0/1)'
TTURVA_OSITT = 'Asuu vanhempien luona (0/1)'
TTURVA_VAHSOSET = 'Vähennettävä muu sosiaalietuus, e/kk'
TTURVA_HUOLL = 'Alle 18-v. lasten lkm vanhempien perheessä'
INF = 'Inflaatiokorjauksessa käytettävä kerroin'

TMTUKIK = 'Työmarkkinatuki, e/kk'
TMTUKIV = 'Työmarkkinatuki, e/v'
TMTUKIP = 'Työmarkkinatuki, e/pv'
PERUSPRAHAP = 'Peruspäiväraha, e/pv'
PERUSPRAHAK = 'Peruspäiväraha, e/kk'
PERUSPRAHAV = 'Peruspäiväraha, e/v'
ANSIOSIDK = 'Ansiosidonnainen päiväraha, e/kk'
ANSIOSIDP = 'Ansiosidonnainen päiväraha, e/pv'
ANSIOSIDV = 'Ansiosidonnainen päiväraha, e/v'
VUORKORVV = 'Vuorottelukorvaus, e/v'
VUORKORVK = 'Vuorottelukorvaus, e/kk'
VUORKORVP = 'Vuorottelukorvaus, e/pv';

KEEP &VALITUT;
%IF &VUOSIKA NE 2 %THEN %DO;
	DROP TTURVA_KUUK;
%END;

IF TTURVA_TYOSSAOLO = 0 AND TTURVA_TOIMINTA = 2 THEN DELETE;
RUN;

%IF &EXCEL = 1 %THEN %DO;
	ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_TT..xls" STYLE = MINIMAL;
%END;

PROC PRINT NOOBS LABEL DATA = OUTPUT.&TULOSNIMI_TT;
TITLE "ESIMERKKILASKELMA, TTURVA";
RUN;

%IF &EXCEL = 1 %THEN %DO;
	ODS HTML3 CLOSE;
%END;

%MEND TTurva_Simuloi_Esimerkki;

%TTurva_Simuloi_Esimerkki;

