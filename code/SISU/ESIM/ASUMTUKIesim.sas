/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyödyntää Tilastokeskuksen yleisten
* käyttöehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto päähakemistossa.
******************************************************************************/

/****************************************************************
* Kuvaus: Yleisen asumistuen esimerkkilaskelmien pohja   		*
* Tekijä: Pertti Honkanen / KELA		                   		*
* Luotu: 3.4.2012				       					   		*
* Viimeksi päivitetty: 5.4.2012			     		   			*
* Päivittäjä: Olli Kannas / TK			     			   		*
*****************************************************************/ 


/* 1. Esimerkkilaskentaa ohjaavat makromuuttujat */

%MACRO Aloitus;

%LET TYYPPI = ESIM; 			* Parametrien hakutapa, aina ESIM ;

/* Jos mallia käytetään käyttöliittymästä (&EG = 1), niin seuraavia vaiheita ei ajeta */

%IF &EG NE 1 %THEN %DO;

%LET TULOSNIMI_YA = asumtuki_esim_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;
%LET VALITUT =  _ALL_; 			* Tulostaulukossa näytettävät muuttujat ;

* Inflaatiokorjaus. Parametrien deflatoinnissa käytettävän kertoimen voi syöttää itse
  INF-makromuuttujaan (HUOM! desimaalit erotettava pisteellä .). Jos puolestaan haluaa käyttää automaattista 
  elinkustannusindeksiin perustuvaa parametrien muunnoskerrointa, 
  tulee INF-makromuuttujalle antaa arvoksi 999.
  Tällöin on annettava myös perusvuosi, johon aineiston lainsäädäntövuotta verrataan; 	

%LET INF = 1.00; * Syötä arvo tai 999 ;
%LET AVUOSI = 2012; *Perusvuosi inflaatiokorjausta varten;
%LET PINDEKSI_VUOSI = pindeksi_vuosi; *Käytettävä indeksien parametritaulukko;

* Laki- ja apumakro-ohjelmien ajon säätäminen ; 

%LET LAKIMAKROT = 1;    * Lakimakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
%LET LAKIMAK_TIED_YA = ASUMTUKIlakimakrot;	* Lakimakroissa käytettävän tiedoston nimi ;
%LET APUMAKROT = 1;   	* Apumakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
%LET APUMAK_TIED_YA = ASUMTUKIapumakrot; * Apumakroissa käytettävän tiedoston nimi ;
%LET EXCEL = 1; 		 * Viedäänkö tulostaulukko automaattisesti Exceliin (1 = Kyllä, 0 = Ei) ;

* Käytettävien parametritiedostojen nimet; 

%LET PASUMTUKI = pasumtuki;
%LET PASUMTUKI_VUOKRANORMIT = pasumtuki_vuokranormit;
%LET PASUMTUKI_ENIMMMENOT = pasumtuki_enimmmenot;

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
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_YA..sas";
%END;

/* Ajetaan apumakrot ja tallennetaan ne (optio) */

%IF &APUMAKROT = 1 %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&APUMAK_TIED_YA..sas";
%END;

%MEND TeeMakrot;

%TeeMakrot;


/* 3. Datan generointia ohjaavat makromuuttujat */

%MACRO Generoi_Muuttujat;

/* Jos mallia käytetään käyttöliittymästä (&EG = 1), niin seuraavia vaiheita ei ajeta */

%IF &EG NE 1 %THEN %DO;

/* 3.1 Fiktiivinen data */

* Lainsäädäntövuosi (1990–);
%LET MINIMI_ASUMTUKI_VUOSI = 2012;
%LET MAKSIMI_ASUMTUKI_VUOSI = 2012;

* Asunnon tyyppi (1 = Vuokra-asunto, 2 = Omistusasunto, 3 = Osa-asunto (alivuokralaisasunto);
%LET MINIMI_ASUMTUKI_ASTYYPPI = 1;
%LET MAKSIMI_ASUMTUKI_ASTYYPPI = 1;

* Omakotitalo (1 = tosi, 0 = epätosi);
%LET MINIMI_ASUMTUKI_OMAKOTI = 0;
%LET MAKSIMI_ASUMTUKI_OMAKOTI = 0;

* Asuntokunnan jäsenten lukumäärä;
%LET MINIMI_ASUMTUKI_PERHE = 4;
%LET MAKSIMI_ASUMTUKI_PERHE = 4;

* Onko kyse puolisoista (1 = tosi, 0 = epätosi);
%LET MINIMI_ASUMTUKI_PUOLISO = 1;
%LET MAKSIMI_ASUMTUKI_PUOLISO = 1;

* Alle 18-vuotiaiden lasten lukumäärä;
%LET MINIMI_ASUMTUKI_LAPSIA = 2;
%LET MAKSIMI_ASUMTUKI_LAPSIA = 2;

* Asuntokuntaan kuuluu lisätilaa tarvitse vammainen (1 = tosi, 0 = epätosi);
%LET MINIMI_ASUMTUKI_VAMM = 0;
%LET MAKSIMI_ASUMTUKI_VAMM = 0;

* Alueryhmitys (1, 2, 3 tai 4);
%LET MINIMI_ASUMTUKI_KRYHMA = 1;
%LET MAKSIMI_ASUMTUKI_KRYHMA = 1;

* Asunnon valmistumisvuosi;
%LET MINIMI_ASUMTUKI_VALMVUOSI = 2000;
%LET MAKSIMI_ASUMTUKI_VALMVUOSI = 2000;
%LET KYNNYS_ASUMTUKI_VALMVUOSI = 10;

* Lämmitysryhmä (1, 2 tai 3);
%LET MINIMI_ASUMTUKI_LAMMRYHMA = 1;
%LET MAKSIMI_ASUMTUKI_LAMMRYHMA = 1;

* Keskuslämmitys (1 = tosi, 0 = epätosi) ;
%LET MINIMI_ASUMTUKI_KESKLAMM = 1;
%LET MAKSIMI_ASUMTUKI_KESKLAMM = 1;

* Vesijohto (1 = tosi, 0 = epätosi) ;
%LET MINIMI_ASUMTUKI_VESIJOHTO = 1;
%LET MAKSIMI_ASUMTUKI_VESIJOHTO= 1;	

* Asunnon pinta-ala, m2;
%LET MINIMI_ASUMTUKI_ALA = 80;
%LET MAKSIMI_ASUMTUKI_ALA = 80;
%LET KYNNYS_ASUMTUKI_ALA = 10;

* Asuntokunnan tulot yhteensä (e/kk);
%LET MINIMI_ASUMTUKI_TULOT = 1000;
%LET MAKSIMI_ASUMTUKI_TULOT = 2000;
%LET KYNNYS_ASUMTUKI_TULOT = 100;

* Hakijan omaisuus tai puolisoiden omaisuus yhteensä (e);
%LET MINIMI_ASUMTUKI_OMAISUUS = 0;
%LET MAKSIMI_ASUMTUKI_OMAISUUS = 0;
%LET KYNNYS_ASUMTUKI_OMAISUUS = 1000;

* Vuokra tai yhtiövastike (e/kk);
%LET MINIMI_ASUMTUKI_VUOKRA = 800;
%LET MAKSIMI_ASUMTUKI_VUOKRA = 800;
%LET KYNNYS_ASUMTUKI_VUOKRA = 100;

* Vesimaksu (e/kk);
%LET MINIMI_ASUMTUKI_VESI = 10;
%LET MAKSIMI_ASUMTUKI_VESI = 10;
%LET KYNNYS_ASUMTUKI_VESI = 10;

* Erilliset lämmityskustannukset (e/kk);
%LET MINIMI_ASUMTUKI_LAMM = 0;
%LET MAKSIMI_ASUMTUKI_LAMM = 0;
%LET KYNNYS_ASUMTUKI_LAMM = 10;

* Asuntolainan korot (e/kk);
%LET MINIMI_ASUMTUKI_ASKOROT = 0;
%LET MAKSIMI_ASUMTUKI_ASKOROT = 0;
%LET KYNNYS_ASUMTUKI_ASKOROT = 100;

%END;

 
/* 4. Fiktiivisen aineiston luoMINIMIen ja simulointi */

/* 4.1 Generoidaan data makromuuttujien arvojen mukaisesti */ 

DATA OUTPUT.&TULOSNIMI_YA;

DO ASUMTUKI_VUOSI = &MINIMI_ASUMTUKI_VUOSI TO &MAKSIMI_ASUMTUKI_VUOSI;
DO ASUMTUKI_ASTYYPPI = &MINIMI_ASUMTUKI_ASTYYPPI TO &MAKSIMI_ASUMTUKI_ASTYYPPI;
DO ASUMTUKI_OMAKOTI = &MINIMI_ASUMTUKI_OMAKOTI TO &MAKSIMI_ASUMTUKI_OMAKOTI;
DO ASUMTUKI_PERHE = &MINIMI_ASUMTUKI_PERHE TO &MAKSIMI_ASUMTUKI_PERHE;
DO ASUMTUKI_PUOLISO = &MINIMI_ASUMTUKI_PUOLISO TO &MAKSIMI_ASUMTUKI_PUOLISO;
DO ASUMTUKI_VAMM = &MINIMI_ASUMTUKI_VAMM TO &MAKSIMI_ASUMTUKI_VAMM;
DO ASUMTUKI_LAPSIA = &MINIMI_ASUMTUKI_LAPSIA TO &MAKSIMI_ASUMTUKI_LAPSIA;
DO ASUMTUKI_LAMMRYHMA = &MINIMI_ASUMTUKI_LAMMRYHMA TO &MAKSIMI_ASUMTUKI_LAMMRYHMA;
DO ASUMTUKI_KESKLAMM = &MINIMI_ASUMTUKI_KESKLAMM TO &MAKSIMI_ASUMTUKI_KESKLAMM;
DO ASUMTUKI_VESIJOHTO = &MINIMI_ASUMTUKI_VESIJOHTO TO &MAKSIMI_ASUMTUKI_VESIJOHTO;
DO ASUMTUKI_ALA = &MINIMI_ASUMTUKI_ALA TO &MAKSIMI_ASUMTUKI_ALA BY &KYNNYS_ASUMTUKI_ALA;
DO ASUMTUKI_KRYHMA = &MINIMI_ASUMTUKI_KRYHMA TO &MAKSIMI_ASUMTUKI_KRYHMA;
DO ASUMTUKI_TULOT = &MINIMI_ASUMTUKI_TULOT TO &MAKSIMI_ASUMTUKI_TULOT BY &KYNNYS_ASUMTUKI_TULOT;
DO ASUMTUKI_OMAISUUS = &MINIMI_ASUMTUKI_OMAISUUS TO &MAKSIMI_ASUMTUKI_OMAISUUS BY &KYNNYS_ASUMTUKI_OMAISUUS;
DO ASUMTUKI_VUOKRA = &MINIMI_ASUMTUKI_VUOKRA TO &MAKSIMI_ASUMTUKI_VUOKRA BY &KYNNYS_ASUMTUKI_VUOKRA;
DO ASUMTUKI_VALMVUOSI = &MINIMI_ASUMTUKI_VALMVUOSI TO &MAKSIMI_ASUMTUKI_VALMVUOSI BY &KYNNYS_ASUMTUKI_VALMVUOSI;
DO ASUMTUKI_ASKOROT = &MINIMI_ASUMTUKI_ASKOROT TO &MAKSIMI_ASUMTUKI_ASKOROT BY &KYNNYS_ASUMTUKI_ASKOROT;
DO ASUMTUKI_VESI = &MINIMI_ASUMTUKI_VESI TO &MAKSIMI_ASUMTUKI_VESI BY &KYNNYS_ASUMTUKI_VESI;
DO ASUMTUKI_LAMM = &MINIMI_ASUMTUKI_LAMM TO &MAKSIMI_ASUMTUKI_LAMM BY &KYNNYS_ASUMTUKI_LAMM;

%IF &INF = 999 %THEN %DO;
%IndKerroin_ESIM(&AVUOSI, ASUMTUKI_VUOSI);
%END;
%ELSE %DO; 
	INF = &INF;
%END;

OUTPUT;
END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;

RUN;

%MEND Generoi_Muuttujat;

%Generoi_Muuttujat;


/* 4.2 Simuloidaan valitut muuttujat esimerkkiaineistolla */

%MACRO AsumTuki_Simuloi_Esimerkki;

%HaeParam_VuokraNormit(2011)

DATA OUTPUT.&TULOSNIMI_YA;
SET OUTPUT.&TULOSNIMI_YA;

IF ASUMTUKI_ASTYYPPI = 1 OR ASUMTUKI_ASTYYPPI = 3 THEN ASUMTUKI_OMAKOTI = 0;

IF ASUMTUKI_PUOLISO = 0 AND ASUMTUKI_LAPSIA > 0 THEN ASUMTUKI_YKSHUOLT = 1;
ELSE ASUMTUKI_YKSHUOLT = 0;

/* 4.2.1 Normipinta-ala */

%NormiNeliot&F(ASUMTUKI_NELIOT, ASUMTUKI_VUOSI, ASUMTUKI_PERHE, ASUMTUKI_VAMM);

/* 4.2.2 Enimmäisasumismeno neliömetriä kohden */

%NormiVuokraESIM(ASUMTUKI_NVUOKRA, ASUMTUKI_VUOSI,  INF, ASUMTUKI_KRYHMA, ASUMTUKI_KESKLAMM, ASUMTUKI_VESIJOHTO, ASUMTUKI_VALMVUOSI, ASUMTUKI_ALA);

/* 4.2.3 Normimeno (normipinta-ala * normivuokra) */

%NormiVuokraESIM(NMVUOKRA, ASUMTUKI_VUOSI,  INF, ASUMTUKI_KRYHMA, ASUMTUKI_KESKLAMM, ASUMTUKI_VESIJOHTO, ASUMTUKI_VALMVUOSI, ASUMTUKI_NELIOT);

ASUMTUKI_NORMIMENO = ASUMTUKI_NELIOT * NMVUOKRA;

DROP NMVUOKRA;

/* 4.2.4 Enimmäisasumismeno osa-asunnossa */

%EnimmVuokraESIM(ASUMTUKI_ENIMMMENO, ASUMTUKI_VUOSI, INF, ASUMTUKI_KRYHMA, ASUMTUKI_PERHE);

/* 4.2.5 Hoitonormi */

%HoitoNormi&F(ASUMTUKI_HNORMI, ASUMTUKI_VUOSI, INF, ASUMTUKI_OMAKOTI, ASUMTUKI_LAMMRYHMA, ASUMTUKI_PERHE, ASUMTUKI_ALA);

/* 4.2.6 Perusomavastuu */

%TuloMuokkaus&F(ASUMTUKI_POVTULO, ASUMTUKI_VUOSI, INF, ASUMTUKI_YKSHUOLT, ASUMTUKI_PERHE, ASUMTUKI_OMAISUUS, ASUMTUKI_TULOT);
%PerusOmaVast&F(ASUMTUKI_PERUSOMV, ASUMTUKI_VUOSI, INF, ASUMTUKI_KRYHMA, ASUMTUKI_PERHE, ASUMTUKI_POVTULO);

/* 4.2.7 Yleisen asumistuen määrä */

SELECT(ASUMTUKI_ASTYYPPI);
	WHEN (1) DO;
		%AsumTukiVuok&F(ASUMTUKI_MAARAK, ASUMTUKI_VUOSI, INF, ASUMTUKI_KRYHMA, 1,
			ASUMTUKI_KESKLAMM, ASUMTUKI_VESIJOHTO, ASUMTUKI_PERHE, ASUMTUKI_VAMM, 
			ASUMTUKI_VALMVUOSI, ASUMTUKI_ALA, ASUMTUKI_PERUSOMV, ASUMTUKI_VUOKRA, ASUMTUKI_VESI, ASUMTUKI_LAMM);
	END;
	WHEN (2) DO;
		%AsumTukiOm&F(ASUMTUKI_MAARAK, ASUMTUKI_VUOSI, INF, ASUMTUKI_KRYHMA, ASUMTUKI_LAMMRYHMA, ASUMTUKI_OMAKOTI, ASUMTUKI_KESKLAMM, ASUMTUKI_VESIJOHTO,
			ASUMTUKI_PERHE, ASUMTUKI_VAMM, ASUMTUKI_VALMVUOSI, ASUMTUKI_ALA, ASUMTUKI_PERUSOMV, ASUMTUKI_VUOKRA, ASUMTUKI_VESI, ASUMTUKI_LAMM, ASUMTUKI_ASKOROT, 0);
	END;
	WHEN (3) DO;
		%AsumTukiOsa&F(ASUMTUKI_MAARAK, ASUMTUKI_VUOSI, INF, ASUMTUKI_KRYHMA, ASUMTUKI_PERHE, ASUMTUKI_VAMM, ASUMTUKI_PERUSOMV, ASUMTUKI_VUOKRA, ASUMTUKI_VESI)
	END;
	OTHERWISE ASUMTUKI_MAARAK = 0;

END;
ASUMTUKI_MAARAV = 12 * ASUMTUKI_MAARAK;
	
DROP taulu_ya X nvuosi taulu_ns w taulu_vn sarake taulu_ev 
	 povnimi1 povnimi2 povnimi3 povnimi4 
	 taulu_pov1 taulu_pov2 taulu_pov3 taulu_pov4
	 tunnus1 tunnus2 tunnus3 tunnus4;	

/* 4.3 Määritellään muuttujille selkokieliset selitteet */

LABEL
ASUMTUKI_VUOSI = "Lainsäädäntövuosi"
ASUMTUKI_ASTYYPPI = "Asunnon tyyppi (1=Vuokra-asunto, 2=Omakotitalo, 3=Osakehuoneisto)"
ASUMTUKI_OMAKOTI = "Omakotitalo (0/1)"
ASUMTUKI_PERHE = "Perheenjäsenten lkm"
ASUMTUKI_PUOLISO = "Onko kyse puolisoista (0/1)"
ASUMTUKI_LAPSIA = "Alle 18-v. lasten lkm"
ASUMTUKI_VAMM = "Asuntokuntaan kuuluu lisätilaa tarvitse vammainen (0/1)"
ASUMTUKI_LAMMRYHMA = "Lämmitysryhmä (1, 2 tai 3)"
ASUMTUKI_KESKLAMM = "Keskuslämmitys (0/1)"
ASUMTUKI_VESIJOHTO = "Vesijohto (0/1)"
ASUMTUKI_ALA = "Asunnon pinta-ala, m2"
ASUMTUKI_KRYHMA = "Alueryhmitys (1, 2, 3 tai 4)"
ASUMTUKI_TULOT = "Hakijan tulot tai puolisoiden tulot yhteensä, e/kk"
ASUMTUKI_OMAISUUS = "Hakijan omaisuus tai puolisoiden omaisuus yhteensä, e"
ASUMTUKI_VUOKRA = "Vuokra, e/kk"
ASUMTUKI_VESI = "Erillinen vesimaksu, e/kk"
ASUMTUKI_LAMM = "Asunnon erilliset lämmityskustannukset, e/kk"
ASUMTUKI_VALMVUOSI = "Asunnon valmistumisvuosi"
ASUMTUKI_ASKOROT = "Asuntolainan korot, e/kk"
ASUMTUKI_YKSHUOLT = "Yksinhuoltaja, (0/1)"
INF = "Inflaatiokorjauksessa käytettävä kerroin"

ASUMTUKI_NELIOT = "Normipinta-ala, m2"
ASUMTUKI_NVUOKRA = "Normivuokra, e/m2/kk"
ASUMTUKI_NORMIMENO = "Normineliöitä vastaava normivuokra, e/kk"
ASUMTUKI_ENIMMMENO = "Enimmäisasumismeno osa-asunnossa, e/kk"
ASUMTUKI_HNORMI = "Omakotitalon hoitonormi tai lämmitysnormi, e/kk"
ASUMTUKI_POVTULO = "Perusomavastuun laskemista varten muokattu tulo, e/kk"
ASUMTUKI_PERUSOMV = "Perusomavastuu, e/kk"
ASUMTUKI_MAARAK = "Asumistuki, e/kk"
ASUMTUKI_MAARAV = "Asumistuki, e/v";

KEEP &VALITUT;

RUN;

%IF &EXCEL = 1 %THEN %DO;
	ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_YA..xls"  STYLE = MINIMAL;
%END;

PROC PRINT NOOBS LABEL DATA = OUTPUT.&TULOSNIMI_YA;
TITLE "ESIMERKKILASKELMA, ASUMTUKI";
RUN;

%IF &EXCEL = 1 %THEN %DO;
	ODS HTML3 CLOSE;
%END;


%MEND AsumTuki_Simuloi_Esimerkki;

%AsumTuki_Simuloi_Esimerkki;

