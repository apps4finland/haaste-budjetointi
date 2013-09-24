/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hy�dynt�� Tilastokeskuksen yleisten
* k�ytt�ehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto p��hakemistossa.
******************************************************************************/

/***********************************************************
* Kuvaus: Ty�tt�myysturvan esimerkkilaskelmien pohja       *
* Tekij�: Jussi Tervola / KELA	                		   *
* Luotu: 16.12.2011				       					   *
* Viimeksi p�ivitetty: 31.5.2011			     		   *
* P�ivitt�j�: Jussi Tervola / KELA		     			   *
************************************************************; 

/* 1. Esimerkkilaskentaa ohjaavat makromuuttujat */

%MACRO Aloitus;

%LET TYYPPI = ESIM; * Parametrien hakutapa, aina ESIM ;

/* Jos mallia k�ytet��n k�ytt�liittym�st� (&EG = 1), niin seuraavia vaiheita ei ajeta */

%IF &EG NE 1 %THEN %DO;

%LET TULOSNIMI_TT = tturva_esim_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;
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
%LET LAKIMAK_TIED_TT = TTURVAlakimakrot;	* Lakimakroissa k�ytett�v�n tiedoston nimi ;
%LET APUMAKROT = 1;   	* Apumakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
%LET APUMAK_TIED_TT = TTURVAapumakrot; * Apumakroissa k�ytett�v�n tiedoston nimi ;
%LET EXCEL = 1; 		 * Vied��nk� tulostaulukko automaattisesti Exceliin (1 = Kyll�, 0 = Ei) ;

%LET PTTURVA = ptturva; * K�ytett�v�n parametritiedoston nimi ;

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

/* Jos mallia k�ytet��n k�ytt�liittym�st� (&EG = 1), niin seuraavia vaiheita ei ajeta */

%IF &EG NE 1 %THEN %DO;

/* 3.1 Fiktiivinen data */

* Lains��d�nt�vuosi (1985-);
%LET MINIMI_TTURVA_VUOSI = 2012;
%LET MAKSIMI_TTURVA_VUOSI = 2012;

* Lains��d�nt�kuukausi (1-12);
%LET MINIMI_TTURVA_KUUK = 12;
%LET MAKSIMI_TTURVA_KUUK = 12;

*Alle 18-v. lasten lkm;
%LET MINIMI_TTURVA_LAPSIA = 0 ;
%LET MAKSIMI_TTURVA_LAPSIA = 0 ; 

*Toimintastatus (1 = ty�t�n, 2 = vuorotteluvapaalla);
%LET MINIMI_TTURVA_TOIMINTA = 1 ; 
%LET MAKSIMI_TTURVA_TOIMINTA = 1 ;

*T�ytt��k� ty�ss�oloehdon (1 = tosi, 0 = ep�tosi);
%LET MINIMI_TTURVA_TYOSSAOLO = 1 ; 
%LET MAKSIMI_TTURVA_TYOSSAOLO = 1 ;

*Onko ty�tt�myyskassan j�sen (1 = tosi, 0 = ep�tosi);
%LET MINIMI_TTURVA_TYOTKASS = 0 ; 
%LET MAKSIMI_TTURVA_TYOTKASS = 1 ;

*Onko ty�voimapoliittisessa aikuiskoulutuksessa (1 = tosi, 0 = ep�tosi);
%LET MINIMI_TTURVA_KOULTUKI = 0 ; 
%LET MAKSIMI_TTURVA_KOULTUKI = 0 ;

* Oikeus korotettuihin p�iv�rahoihin  
0 = ei oikeutta
1 = Oikeus ansiop�iv�rahojen korotettuun ansio-osaan / ty�markkinatuen tai perusp�iv�rahan korotusosaan / korotettuun vuorottelukorvaukseen
2 = Oikeus ansiop�iv�rahojen muutosturvaan
3 = Oikeus ansiop�iv�rahojen korotettuihin lis�p�iviin (voimassa 2003-2009);
%LET MINIMI_TTURVA_OIKEUSKOR = 0 ; 
%LET MAKSIMI_TTURVA_OIKEUSKOR = 0 ;

*Ty�tt�myytt� edelt�v� palkka (e/kk);
%LET MINIMI_TTURVA_KUUKPALK = 0 ; 
%LET MAKSIMI_TTURVA_KUUKPALK = 5000 ;
%LET KYNNYS_TTURVA_KUUKPALK =  500; 

*Onko puolisoa (1 = tosi, 0 = ep�tosi) ;
%LET MINIMI_TTURVA_PUOLISO = 0 ; 
%LET MAKSIMI_TTURVA_PUOLISO = 0 ; 

*Puolison veronalaiset tulot (e/kk);
%LET MINIMI_TTURVA_PUOLTULO = 0 ; 
%LET MAKSIMI_TTURVA_PUOLTULO = 0 ;
%LET KYNNYS_TTURVA_PUOLTULO = 1000; 

*Omat p��omatulot (e/kk) (tarveharkitussa ty�markkinatuessa);
%LET MINIMI_TTURVA_OMATULO = 0 ; 
%LET MAKSIMI_TTURVA_OMATULO = 0 ;
%LET KYNNYS_TTURVA_OMATULO = 1000; 

*Asuuko saaja vanhempien luona (1 = tosi, 0 = ep�tosi);
%LET MINIMI_TTURVA_OSITT = 0 ; 
%LET MAKSIMI_TTURVA_OSITT = 0 ; 

*Alle 18-vuotiaiden lkm vanhempien perheess�;
%LET MINIMI_TTURVA_HUOLL = 0 ;
%LET MAKSIMI_TTURVA_HUOLL = 0 ; 

* Vanhempien veronalaiset tulot (e/kk) ;
%LET MINIMI_TTURVA_VANHTULO = 0;
%LET MAKSIMI_TTURVA_VANHTULO = 0;
%LET KYNNYS_TTURVA_VANHTULO = 1000;

*Sovittelun perusteena oleva tulo (e/kk) (ty�tt�myysaikana saatu ty�tulo);
%LET MINIMI_TTURVA_SOVTULO = 0;
%LET MAKSIMI_TTURVA_SOVTULO = 0;
%LET KYNNYS_TTURVA_SOVTULO = 100;

*V�hennett�v� muu sosiaalietuus (e/kk);
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

/* 4.2.1 Ty�markkinatuki */

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

/* 4.2.2 Perusp�iv�raha */

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

/* 4.2.3 Ansiosidonnainen p�iv�raha */

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

/* 4.3 M��ritell��n muuttujille selkokieliset selitteet */

LABEL 
TTURVA_VUOSI = 'Lains��d�nt�vuosi'
TTURVA_KUUK = 'Lains��d�nt�kuukausi'
TTURVA_LAPSIA = 'Alle 18-v. lasten lkm'
TTURVA_OIKEUSKOR = 'Oikeus korotettuun p�iv�rahaan (0-3)'
TTURVA_TYOTKASS = 'Ty�tt�myyskassan j�sen (0/1)'
TTURVA_TOIMINTA = 'Toimintastatus (1/2)'
TTURVA_TYOSSAOLO = 'Ty�ss�oloehdon t�yttyminen (0/1)'
TTURVA_KOULTUKI = 'Ty�voimapoliittinen koulutus (0/1)' 
TTURVA_KUUKPALK = 'Ty�tt�myytt� edelt�v� palkka, e/kk'
TTURVA_SOVTULO = 'Ty�tt�myyden aikana saadut ty�tulot, e/kk'
TTURVA_VANHTULO = 'Vanhempien veronalaiset tulot, e/kk'
TTURVA_OMATULO = 'Omat (p��oma)tulot, e/kk'
TTURVA_PUOLTULO = 'Puolison veronalaiset tulot, e/kk'
TTURVA_PUOLISO = 'Onko puolisoa (0/1)'
TTURVA_OSITT = 'Asuu vanhempien luona (0/1)'
TTURVA_VAHSOSET = 'V�hennett�v� muu sosiaalietuus, e/kk'
TTURVA_HUOLL = 'Alle 18-v. lasten lkm vanhempien perheess�'
INF = 'Inflaatiokorjauksessa k�ytett�v� kerroin'

TMTUKIK = 'Ty�markkinatuki, e/kk'
TMTUKIV = 'Ty�markkinatuki, e/v'
TMTUKIP = 'Ty�markkinatuki, e/pv'
PERUSPRAHAP = 'Perusp�iv�raha, e/pv'
PERUSPRAHAK = 'Perusp�iv�raha, e/kk'
PERUSPRAHAV = 'Perusp�iv�raha, e/v'
ANSIOSIDK = 'Ansiosidonnainen p�iv�raha, e/kk'
ANSIOSIDP = 'Ansiosidonnainen p�iv�raha, e/pv'
ANSIOSIDV = 'Ansiosidonnainen p�iv�raha, e/v'
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

