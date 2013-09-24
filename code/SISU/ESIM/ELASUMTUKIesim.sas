/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hy�dynt�� Tilastokeskuksen yleisten
* k�ytt�ehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto p��hakemistossa.
******************************************************************************/

/****************************************************************
* Kuvaus: El�kkeensaajan asumistuen esimerkkilaskelmien pohja   *
* Tekij�: Petri Eskelinen / KELA		                   		*
* Luotu: 30.12.2011				       					   		*
* Viimeksi p�ivitetty: 15.2.2012			     		   		*
* P�ivitt�j�: Olli Kannas / TK			     			   		*
*****************************************************************/ 

/* 1. Esimerkkilaskentaa ohjaavat makromuuttujat */

%MACRO Aloitus;

%LET TYYPPI = ESIM; * Parametrien hakutapa, aina ESIM ;

/* Jos mallia k�ytet��n k�ytt�liittym�st� (&EG = 1), niin seuraavia vaiheita ei ajeta */

%IF &EG NE 1 %THEN %DO;

%LET TULOSNIMI_EA = elasumtuki_esim_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;
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
%LET LAKIMAK_TIED_EA = ELASUMTUKIlakimakrot;	* Lakimakroissa k�ytett�v�n tiedoston nimi ;
%LET APUMAKROT = 1;   	* Apumakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
%LET APUMAK_TIED_EA = ELASUMTUKIapumakrot; * Apumakroissa k�ytett�v�n tiedoston nimi ;
%LET EXCEL = 1; 		 * Vied��nk� tulostaulukko automaattisesti Exceliin (1 = Kyll�, 0 = Ei) ;

%LET PELASUMTUKI = pelasumtuki; * K�ytett�v�n parametritiedoston nimi ;

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
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_EA..sas";
%END;

/* Ajetaan apumakrot ja tallennetaan ne (optio) */

%IF &APUMAKROT = 1 %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&APUMAK_TIED_EA..sas";
%END;

%MEND TeeMakrot;

%TeeMakrot;


/* 3. Datan generointia ohjaavat makromuuttujat */

%MACRO Generoi_Muuttujat;

/* Jos mallia k�ytet��n k�ytt�liittym�st� (&EG = 1), niin seuraavia vaiheita ei ajeta */

%IF &EG NE 1 %THEN %DO;

/* 3.1 Fiktiivinen data */

* Lains��d�nt�vuosi (1990�);
%LET MINIMI_ELASUMTUKI_VUOSI = 2012;
%LET MAKSIMI_ELASUMTUKI_VUOSI = 2012;

* Asunnon tyyppi (1 = Vuokra-asunto, 2 = Omakotitalo, 3 = Osakehuoneisto);
%LET MINIMI_ELASUMTUKI_ASTYYPPI = 1;
%LET MAKSIMI_ELASUMTUKI_ASTYYPPI = 1;

* Perheenj�senten lukum��r� (1, 2...);
%LET MINIMI_ELASUMTUKI_PERHE = 0;
%LET MAKSIMI_ELASUMTUKI_PERHE = 1;

* Onko kyse puolisoista (1 = tosi, 0 = ep�tosi);
%LET MINIMI_ELASUMTUKI_PUOLISO = 0;
%LET MAKSIMI_ELASUMTUKI_PUOLISO = 0;

* Onko puolisolla oikeus el.saaj. asumistukeen (1 = tosi, 0 = ep�tosi);
%LET MINIMI_ELASUMTUKI_PUOLOIKAT = 0;
%LET MAKSIMI_ELASUMTUKI_PUOLOIKAT = 0;

* Onko leskenel�kkeen saaja (1 = tosi, 0 = ep�tosi);
%LET MINIMI_ELASUMTUKI_LESKENELAKE = 0;
%LET MAKSIMI_ELASUMTUKI_LESKENELAKE = 0;

* Saako rintamasotilasel�kett� (1 = tosi, 0 = ep�tosi);
%LET MINIMI_ELASUMTUKI_RINTSOTELAKE = 0;
%LET MAKSIMI_ELASUMTUKI_RINTSOTELAKE = 0;

* Alle 16-vuotiaiden lasten lukum��r�;
%LET MINIMI_ELASUMTUKI_LAPSIA = 0;
%LET MAKSIMI_ELASUMTUKI_LAPSIA = 0;

* L�mmitysryhm� (1, 2 tai 3);
%LET MINIMI_ELASUMTUKI_LAMMRYHMA = 1;
%LET MAKSIMI_ELASUMTUKI_LAMMRYHMA = 1;

* Keskusl�mmitys (1 = tosi, 0 = ep�tosi) ;
%LET MINIMI_ELASUMTUKI_KESKLAMM = 1;
%LET MAKSIMI_ELASUMTUKI_KESKLAMM = 1;

* Vesijohto (1 = tosi, 0 = ep�tosi) ;
%LET MINIMI_ELASUMTUKI_VESIJOHTO = 1;
%LET MAKSIMI_ELASUMTUKI_VESIJOHTO= 1;	

* Vesimaksu ei sis�lly vuokraan (1 = tosi, 0 = ep�tosi);
%LET MINIMI_ELASUMTUKI_EIVESI = 0;
%LET MAKSIMI_ELASUMTUKI_EIVESI = 0;

* L�mmitys ei sis�lly vuokraan (1 = tosi, 0 = ep�tosi);
%LET MINIMI_ELASUMTUKI_EILAMM = 0;
%LET MAKSIMI_ELASUMTUKI_EILAMM = 0;

* Asunnon pinta-ala, m2;
%LET MINIMI_ELASUMTUKI_ALA = 40;
%LET MAKSIMI_ELASUMTUKI_ALA = 40;
%LET KYNNYS_ELASUMTUKI_ALA = 10;

* Alueryhmitys (1, 2, 3 tai 4);
%LET MINIMI_ELASUMTUKI_KRYHMA = 1;
%LET MAKSIMI_ELASUMTUKI_KRYHMA = 1;

* Hakijan tulot tai puolisoiden tulot yhteens� (e/kk);
%LET MINIMI_ELASUMTUKI_TULOT = 700;
%LET MAKSIMI_ELASUMTUKI_TULOT = 1700;
%LET KYNNYS_ELASUMTUKI_TULOT = 100;

* Hakijan omaisuus tai puolisoiden omaisuus yhteens� (e);
%LET MINIMI_ELASUMTUKI_OMAISUUS = 0;
%LET MAKSIMI_ELASUMTUKI_OMAISUUS = 0;
%LET KYNNYS_ELASUMTUKI_OMAISUUS = 1000;

* Vuokra (e/kk);
%LET MINIMI_ELASUMTUKI_VUOKRA = 500;
%LET MAKSIMI_ELASUMTUKI_VUOKRA = 500;
%LET KYNNYS_ELASUMTUKI_VUOKRA = 100;

* Asunnon valmistumisvuosi;
%LET MINIMI_ELASUMTUKI_VALMVUOSI = 1994;
%LET MAKSIMI_ELASUMTUKI_VALMVUOSI = 1994;

* Asuntolainan korot (e/v);
%LET MINIMI_ELASUMTUKI_ASKOROT = 0;
%LET MAKSIMI_ELASUMTUKI_ASKOROT = 0;
%LET KYNNYS_ELASUMTUKI_ASKOROT = 100;

%END;


/* 4. Fiktiivisen aineiston luoMINIMIen ja simulointi */

/* 4.1 Generoidaan data makromuuttujien arvojen mukaisesti */ 

DATA OUTPUT.&TULOSNIMI_EA;

DO ELASUMTUKI_VUOSI = &MINIMI_ELASUMTUKI_VUOSI TO &MAKSIMI_ELASUMTUKI_VUOSI;
DO ELASUMTUKI_ASTYYPPI = &MINIMI_ELASUMTUKI_ASTYYPPI TO &MAKSIMI_ELASUMTUKI_ASTYYPPI;
DO ELASUMTUKI_PERHE = &MINIMI_ELASUMTUKI_PERHE TO &MAKSIMI_ELASUMTUKI_PERHE;
DO ELASUMTUKI_PUOLISO = &MINIMI_ELASUMTUKI_PUOLISO TO &MAKSIMI_ELASUMTUKI_PUOLISO;
DO ELASUMTUKI_PUOLOIKAT = &MINIMI_ELASUMTUKI_PUOLOIKAT TO &MAKSIMI_ELASUMTUKI_PUOLOIKAT;
DO ELASUMTUKI_LESKENELAKE = &MINIMI_ELASUMTUKI_LESKENELAKE TO &MAKSIMI_ELASUMTUKI_LESKENELAKE;
DO ELASUMTUKI_RINTSOTELAKE = &MINIMI_ELASUMTUKI_RINTSOTELAKE TO &MAKSIMI_ELASUMTUKI_RINTSOTELAKE;
DO ELASUMTUKI_LAPSIA = &MINIMI_ELASUMTUKI_LAPSIA TO &MAKSIMI_ELASUMTUKI_LAPSIA;
DO ELASUMTUKI_LAMMRYHMA = &MINIMI_ELASUMTUKI_LAMMRYHMA TO &MAKSIMI_ELASUMTUKI_LAMMRYHMA;
DO ELASUMTUKI_KESKLAMM = &MINIMI_ELASUMTUKI_KESKLAMM TO &MAKSIMI_ELASUMTUKI_KESKLAMM;
DO ELASUMTUKI_VESIJOHTO = &MINIMI_ELASUMTUKI_VESIJOHTO TO &MAKSIMI_ELASUMTUKI_VESIJOHTO;
DO ELASUMTUKI_EIVESI = &MINIMI_ELASUMTUKI_EIVESI TO &MAKSIMI_ELASUMTUKI_EIVESI;
DO ELASUMTUKI_EILAMM = &MINIMI_ELASUMTUKI_EILAMM TO &MAKSIMI_ELASUMTUKI_EILAMM;
DO ELASUMTUKI_ALA = &MINIMI_ELASUMTUKI_ALA TO &MAKSIMI_ELASUMTUKI_ALA BY &KYNNYS_ELASUMTUKI_ALA;
DO ELASUMTUKI_KRYHMA = &MINIMI_ELASUMTUKI_KRYHMA TO &MAKSIMI_ELASUMTUKI_KRYHMA;
DO ELASUMTUKI_TULOT = &MINIMI_ELASUMTUKI_TULOT TO &MAKSIMI_ELASUMTUKI_TULOT BY &KYNNYS_ELASUMTUKI_TULOT;
DO ELASUMTUKI_OMAISUUS = &MINIMI_ELASUMTUKI_OMAISUUS TO &MAKSIMI_ELASUMTUKI_OMAISUUS BY &KYNNYS_ELASUMTUKI_OMAISUUS;
DO ELASUMTUKI_VUOKRA = &MINIMI_ELASUMTUKI_VUOKRA TO &MAKSIMI_ELASUMTUKI_VUOKRA BY &KYNNYS_ELASUMTUKI_VUOKRA;
DO ELASUMTUKI_VALMVUOSI = &MINIMI_ELASUMTUKI_VALMVUOSI TO &MAKSIMI_ELASUMTUKI_VALMVUOSI;
DO ELASUMTUKI_ASKOROT = &MINIMI_ELASUMTUKI_ASKOROT TO &MAKSIMI_ELASUMTUKI_ASKOROT BY &KYNNYS_ELASUMTUKI_ASKOROT;

%IF &INF = 999 %THEN %DO;
%IndKerroin_ESIM(&AVUOSI, ELASUMTUKI_VUOSI);
%END;
%ELSE %DO; 
	INF = &INF;
%END;

OUTPUT;
END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;

RUN;

%MEND Generoi_Muuttujat;

%Generoi_Muuttujat;


/* 4.2 Simuloidaan valitut muuttujat esimerkkiaineistolla */

%MACRO ElAsumTuki_Simuloi_Esimerkki;

DATA OUTPUT.&TULOSNIMI_EA;
SET OUTPUT.&TULOSNIMI_EA;


/* 4.2.1 Lasketaan el�kkeensaajan asumistuki  */

/* Vuokra-asunto */
IF ELASUMTUKI_ASTYYPPI = 1 THEN DO;

	%ElakAsumTuki&F(ELASUMTUKI_MAARAV, ELASUMTUKI_VUOSI, INF, ELASUMTUKI_PUOLISO, ELASUMTUKI_PUOLOIKAT, ELASUMTUKI_LESKENELAKE,
		ELASUMTUKI_RINTSOTELAKE, ELASUMTUKI_LAPSIA, 0, ELASUMTUKI_LAMMRYHMA, ELASUMTUKI_KESKLAMM, ELASUMTUKI_VESIJOHTO, ELASUMTUKI_EIVESI,
		ELASUMTUKI_EILAMM, ELASUMTUKI_ALA, ELASUMTUKI_VALMVUOSI, ELASUMTUKI_KRYHMA, 12 * ELASUMTUKI_TULOT, ELASUMTUKI_OMAISUUS,
		12 * ELASUMTUKI_VUOKRA, 0);

	ELASUMTUKI_MAARAK = ELASUMTUKI_MAARAV / 12;

END;

/* Omakotitalo */
ELSE IF ELASUMTUKI_ASTYYPPI = 2 THEN DO;

	%ElakAsumTuki&F(ELASUMTUKI_MAARAV, ELASUMTUKI_VUOSI, INF, ELASUMTUKI_PUOLISO, ELASUMTUKI_PUOLOIKAT, ELASUMTUKI_LESKENELAKE,
		ELASUMTUKI_RINTSOTELAKE, ELASUMTUKI_LAPSIA, 1, ELASUMTUKI_LAMMRYHMA,ELASUMTUKI_KESKLAMM, ELASUMTUKI_VESIJOHTO, ELASUMTUKI_EIVESI,
		ELASUMTUKI_EILAMM, ELASUMTUKI_ALA, ELASUMTUKI_VALMVUOSI, ELASUMTUKI_KRYHMA, 12 * ELASUMTUKI_TULOT, ELASUMTUKI_OMAISUUS,
		0, ELASUMTUKI_ASKOROT);

	ELASUMTUKI_MAARAK = ELASUMTUKI_MAARAV / 12;

END;

/* Osakehuoneisto */
ELSE IF ELASUMTUKI_ASTYYPPI = 3 THEN DO;

	%ElakAsumTuki&F(ELASUMTUKI_MAARAV, ELASUMTUKI_VUOSI, INF, ELASUMTUKI_PUOLISO, ELASUMTUKI_PUOLOIKAT, ELASUMTUKI_LESKENELAKE,
		ELASUMTUKI_RINTSOTELAKE, ELASUMTUKI_LAPSIA, 0, ELASUMTUKI_LAMMRYHMA, ELASUMTUKI_KESKLAMM, ELASUMTUKI_VESIJOHTO, ELASUMTUKI_EIVESI,
		ELASUMTUKI_EILAMM, ELASUMTUKI_ALA, ELASUMTUKI_VALMVUOSI, ELASUMTUKI_KRYHMA, 12 * ELASUMTUKI_TULOT, ELASUMTUKI_OMAISUUS,
		12 * ELASUMTUKI_VUOKRA, ELASUMTUKI_ASKOROT);	

	ELASUMTUKI_MAARAK = ELASUMTUKI_MAARAV / 12;

END;

/* 4.2.2 Vesi- ja l�mmitysnormit ja omakotitalon hoitonormi el�kkeensaajien asumistuessa */

/* Omakotitalo (koko normi lasketaan) */
IF ELASUMTUKI_ASTYYPPI = 1 THEN DO;

	%EHoitonormi&F(ELASUMTUKI_HOITONORMIK, ELASUMTUKI_VUOSI, INF, ELASUMTUKI_PERHE, ELASUMTUKI_LAMMRYHMA,
		1, ELASUMTUKI_KESKLAMM, ELASUMTUKI_VESIJOHTO, ELASUMTUKI_EIVESI, ELASUMTUKI_EILAMM, ELASUMTUKI_ALA,
		ELASUMTUKI_VALMVUOSI);

END;

/* Vuokra-asunnot ja osakehuoneistot (lasketaan vain vesi- ja/tai l�mmitysnormi) */
ELSE DO;

	%EHoitonormi&F(ELASUMTUKI_HOITONORMIK, ELASUMTUKI_VUOSI, INF, ELASUMTUKI_PERHE, ELASUMTUKI_LAMMRYHMA,
		0, ELASUMTUKI_KESKLAMM, ELASUMTUKI_VESIJOHTO, ELASUMTUKI_EIVESI, ELASUMTUKI_EILAMM, ELASUMTUKI_ALA,
		ELASUMTUKI_VALMVUOSI);

END;

/* 4.2.3 Enimm�isasumismeno el�kkeensaajien asumistuessa */

%EnimmAsMeno&F(ELASUMTUKI_ENIMMAISMENOV,ELASUMTUKI_VUOSI, INF, ELASUMTUKI_LAPSIA, ELASUMTUKI_KRYHMA);

ELASUMTUKI_ENIMMAISMENOK = ELASUMTUKI_ENIMMAISMENOV / 12;

DROP taulu_ea X;

/* 4.3 M��ritell��n muuttujille selkokieliset selitteet */

LABEL
ELASUMTUKI_VUOSI = 'Lains��d�nt�vuosi'
ELASUMTUKI_ASTYYPPI = 'Asunnon tyyppi (1=Vuokra-asunto, 2=Omakotitalo, 3=Osakehuoneisto)'
ELASUMTUKI_PERHE = 'Perheenj�senten lkm'
ELASUMTUKI_PUOLISO = 'Onko kyse puolisoista (0/1)'
ELASUMTUKI_PUOLOIKAT = 'Onko puolisolla oikeus el�kkeensaajan asumistukeen (0/1)'
ELASUMTUKI_LESKENELAKE = 'Onko leskenel�kkeen saaja (0/1)'
ELASUMTUKI_RINTSOTELAKE = 'Saako rintamasotilasel�kett� (0/1)'
ELASUMTUKI_LAPSIA = 'Alle 16-v. lasten lkm'
ELASUMTUKI_LAMMRYHMA = 'Hoitonormien kuntaryhm� (1, 2 tai 3)'
ELASUMTUKI_KESKLAMM = 'Keskusl�mmitys (0/1)'
ELASUMTUKI_VESIJOHTO = 'Vesijohto (0/1)'
ELASUMTUKI_EIVESI = 'Vesimaksu ei sis�lly vuokraan (0/1)'
ELASUMTUKI_EILAMM = 'L�mmitys ei sis�lly vuokraan (0/1)'
ELASUMTUKI_ALA = 'Asunnon pinta-ala, m2'
ELASUMTUKI_KRYHMA = 'Alueryhmitys (1, 2, 3 tai 4)'
ELASUMTUKI_TULOT = 'Hakijan tulot tai puolisoiden tulot yhteens�, e/kk'
ELASUMTUKI_OMAISUUS = 'Hakijan omaisuus tai puolisoiden omaisuus yhteens�, e'
ELASUMTUKI_VUOKRA = 'Vuokra, e/kk'
ELASUMTUKI_VALMVUOSI = 'Asunnon valmistumisvuosi'
ELASUMTUKI_ASKOROT = 'Asuntolainan korot, e/v'
INF = 'Inflaatiokorjauksessa k�ytett�v� kerroin'

ELASUMTUKI_MAARAV = 'El�kkeensaajan asumistuki, e/v'
ELASUMTUKI_MAARAK = 'El�kkeensaajan asumistuki, e/kk'
ELASUMTUKI_HOITONORMIK = 'Hoitonormi, e/kk'
ELASUMTUKI_ENIMMAISMENOV = 'Enimm�isasumismenot, e/v'
ELASUMTUKI_ENIMMAISMENOK = 'Enimm�isasumismenot, e/kk';

KEEP &VALITUT;

RUN;

%IF &EXCEL = 1 %THEN %DO;
	ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_EA..xls"  STYLE = MINIMAL;
%END;

PROC PRINT NOOBS LABEL DATA = OUTPUT.&TULOSNIMI_EA;
TITLE "ESIMERKKILASKELMA, ELASUMTUKI";
RUN;

%IF &EXCEL = 1 %THEN %DO;
	ODS HTML3 CLOSE;
%END;

%MEND ElAsumTuki_Simuloi_Esimerkki;

%ElAsumTuki_Simuloi_Esimerkki;
