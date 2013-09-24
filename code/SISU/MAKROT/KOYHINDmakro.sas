/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hy�dynt�� Tilastokeskuksen yleisten
* k�ytt�ehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto p��hakemistossa.
******************************************************************************/

/****************************************************
* Tulonjakoindikaattorit laskeva makro              *
* Tekij�: Jukka Mattila / TK                   		*
* Luotu: 31.11.2011				       				*
* Viimeksi p�ivitetty: 3.8.2012		     			*
* P�ivitt�j�: Jukka Mattila / TK		            *
*****************************************************/

* Makron parametrit:
	rajat: Laskettavien k�yhyysrajojen m��r�
	rajaN: Parametri jokaiselle k�yhyysrajalle, joka kertoo rajan osuuden mediaanista
	sisaan: Aineisto, josta laskenta tehd��n
	jasenia: Datan muuttuja, joka kertoo kotitalouden j�senm��r�n
	paino: Painokerroin
	tulot: Datan tulomuuttuja, josta tulot lasketaan
	kuluyks: Datan muuttuja, joka kertoo kulutusyksik�iden lukum��r�n
	id: Yksikk�tunniste (kotitalous/asuntokunta, aina knro)
	desit: Desiilimuuttuja (yleens� DESMOD_MALLI)
	destu: Tulostetaanko desiilien tulo-osuudet (1 jos tulostetaan);

%MACRO Indikaattorit(rajat, raja1, raja2, raja3, sisaan, jasenia, paino, tulot, kuluyks, id, desit, destu)/STORE
DES = 'TULOKSET: Makro, joka laskee KOKO-mallista tulonjakoindikaattorit';

/* 1. M��ritet��n tulostaulukon nimi */

%LET OUTP = OUTPUT.&TULOSNIMI_KOKO._IND;

/* 2. Haetaan tiedostosta &sisaan laskentaan tarvittavat tiedot laskentatauluksi */

PROC SQL;
	CREATE VIEW _LASKU AS SELECT
	1 as lkm, a.&id, max(a.&kuluyks)/10 as kuluyks, sum(a.&tulot) as tulot, a.&paino*a.&jasenia as wk, a.&paino, 
	a.&jasenia as jasenia, c.lapset, b.vanhat, d.tyolliset, e.eityol, a.&desit
	FROM &sisaan AS a
	LEFT JOIN (SELECT &id, COUNT(hnro) AS vanhat FROM &sisaan WHERE ikavu >= 65 GROUP BY &id) AS b ON a.&id = b.&id
	LEFT JOIN (SELECT &id, COUNT(hnro) AS lapset FROM &sisaan WHERE ikavu <= 17 GROUP BY &id) AS c on a.&id = c.&id
	LEFT JOIN (SELECT &id, COUNT(hnro) AS tyolliset FROM &sisaan WHERE soss < 60 and ikavu between 18 and 64 GROUP BY &id) AS d ON a.&id = d.&id
	LEFT JOIN (SELECT &id, COUNT(hnro) AS eityol FROM &sisaan WHERE soss > 59 and ikavu between 18 and 64 GROUP BY &id) AS e ON a.&id = e.&id

	GROUP BY a.&id
	ORDER BY a.&id;
	QUIT;

DATA _LASK1/VIEW=_LASK1; 
SET _LASKU;
BY &ID;
IF FIRST.&ID;
%if &kuluyks = jasenia %then %do;
kuluyks = 10*kuluyks; %end;
etulo = tulot/kuluyks;
RUN;

/* 3. Lasketaan mediaanitulo &tulot -muuttujasta tiedostoon med */

PROC UNIVARIATE DATA = _LASK1 NOPRINT;
VAR etulo; WEIGHT wk; 
OUTPUT OUT = _MED PCTLPTS = 50 PCTLPRE = med;
RUN;

/* 4. Tallennetaan valitut k�yhyysrajat makromuuttujiksi */

%DO i = 1 %TO &rajat; 
	PROC SQL NOPRINT; 
	SELECT (&&raja&i/100)*(med50)
	INTO :absoraja&i FROM _MED;
	QUIT;
%END;

/* 5. Merkit��n laskentatauluun k�yhyysrajat */

DATA _LASK2;
SET _LASK1;
%DO i = 1 %TO &rajat;
	IF &&absoraja&i > etulo THEN koy&&raja&i = 1;
%END;
RUN;

/* 6. Lasketaan k�yhyysrajojen alapuolella olevien mediaani- ja keskitulot tauluihin */

%DO i = 1 %TO &rajat;
	PROC MEANS DATA = _LASK2 (WHERE = (koy&&raja&i = 1)) MEAN MEDIAN MAXDEC=0 NOPRINT; 
	VAR etulo; 
	WEIGHT wk; 
	OUTPUT OUT = _RMN&i MEAN(etulo) = R&&raja&i;
	RUN;

	PROC MEANS DATA = _LASK2 (WHERE = (koy&&raja&i = 1)) MEAN MEDIAN MAXDEC=0 NOPRINT; 
	VAR etulo; 
	WEIGHT wk; 
	OUTPUT OUT = _RMD&i MEDIAN(etulo) = R&&raja&i;
	RUN;

	PROC SQL NOPRINT;
	SELECT R&&raja&i 
	INTO :KMD&i FROM _RMD&i;
	QUIT; 
%END;

/* 7. Lasketaan rajojen alapuolella oleville erotus tulojen ja rajan v�lill� */

DATA _LASK; 
SET _LASK2;
%DO i = 1 %TO &rajat;
	IF koy&&raja&i = 1 THEN ero&&raja&i = SUM(&&absoraja&i, -etulo);
%END;
RUN;

/* 8. Alle 18-vuotiaiden ja yli 65-vuotiaiden m��r�t k�yhiss� talouksissa ja populaatiossa
   ja ty�llisten sek� ei-ty�llisten m��r�t */

%DO i = 1 %TO &rajat;
	PROC MEANS DATA = _LASK (WHERE = (koy&&raja&i = 1)) SUM MAXDEC=0 NOPRINT; 
	VAR lapset ; 
	WEIGHT &PAINO; 
	OUTPUT OUT = _PLA&i SUM(lapset)= R&&raja&i ;
	RUN;

	PROC MEANS DATA = _LASK (WHERE = (koy&&raja&i = 1)) SUM MAXDEC=0 NOPRINT; 
	VAR vanhat ; 
	WEIGHT &PAINO; 
	OUTPUT OUT = _PVA&i SUM(vanhat)= R&&raja&i ;
	RUN;

	PROC MEANS DATA = _LASK (WHERE = (koy&&raja&i = 1)) SUM MAXDEC=0 NOPRINT; 
	VAR lkm; 
	WEIGHT wk; 
	OUTPUT OUT = _K&i SUM(lkm) = R&&raja&i;
	RUN;

	PROC MEANS DATA = _LASK (WHERE = (koy&&raja&i = 1)) SUM MAXDEC=0 NOPRINT; 
	VAR tyolliset; 
	WEIGHT &PAINO; 
	OUTPUT OUT = _TYO&i SUM(tyolliset)= R&&raja&i;
	RUN;

	PROC MEANS DATA = _LASK (WHERE = (koy&&raja&i = 1)) SUM MAXDEC=0 NOPRINT; 
	VAR eityol; 
	WEIGHT &PAINO; 
	OUTPUT OUT = _ETY&i SUM(eityol)= R&&raja&i;
	RUN;
%END;

/* 9. Totaalilukuja, k�yh�t, koko v�est�, lapset, vanhat, ty�lliset, ei-ty�lliset tallennetaan makromuuttujiksi */

PROC MEANS DATA = _LASK SUM MAXDEC=0 NOPRINT; 
VAR lapset vanhat tyolliset eityol; 
WEIGHT &PAINO; 
OUTPUT OUT = _KVL SUM(vanhat) = vanh SUM(lapset) = laps SUM(tyolliset) = tyol SUM(eityol) = eityol;
RUN;

PROC MEANS DATA = _LASK SUM MAXDEC=0 NOPRINT; 
VAR lkm; WEIGHT wk; 
OUTPUT OUT = _KP SUM(lkm) = lkm;
RUN;

PROC SQL NOPRINT; 
SELECT vanh, laps, tyol, eityol INTO :VANH, :LAPS, :TYOL, :EITYOL FROM _KVL;
SELECT lkm INTO :LKM FROM _KP;
%DO i = 1 %TO &rajat; 
	SELECT R&&raja&i INTO :KLKM&i FROM _K&i;
%END;
QUIT;

/* 10. Lasketaan ginikerroin, keskitulo, ja mediaanitulo ensimm�isille riveille */

PROC UNIVARIATE DATA = _LASK NOPRINT /* ROBUSTSCALE */;
VAR etulo;
FREQ wk;
OUTPUT OUT = _GINI gini = G mean = MeantuPOP median = MedtuPOP;
RUN;

PROC SQL NOPRINT;
SELECT MeantuPOP, MedtuPOP, G 
INTO :meantupop, :medtupop, :GINI FROM _GINI;
QUIT;

/* 11. Lasketaan indikaattorit */

%DO i = 1 %TO &rajat;

	/* Ty�llisten k�yhyysasteet */
	DATA _TYO&i; 
	SET _TYO&i; 
	LENGTH Otsikko $50;
	Otsikko ="Ty�lliset k�yhiss� talouksissa, &&Raja&i %";
	RLKM = ROUND(R&&raja&i, 10);
	AOSU = ROUND((100 * (R&&raja&i / &tyol)), .01);
	RUN;

	/* Ei-Ty�llisten k�yhyysasteet */
	DATA _ETY&i;
	SET _ETY&i; 
	LENGTH Otsikko $50;
	Otsikko ="Ei-ty�lliset k�yhiss� talouksissa, &&Raja&i %";
	RLKM = ROUND(R&&raja&i, 10);
	AOSU = ROUND((100 * (R&&raja&i / &eityol)), .01);
	RUN;

	/* Kirjoitetaan valitut k�yhyysrajat tauluun outputtia varten */
	DATA _AR&i; 
	LENGTH Otsikko $50;
	Otsikko = "K�yhyysraja, &&Raja&i % mediaanitulosta";
	RLKM = ROUND((&&absoraja&i), 10);
	OUTPUT;
	RUN;

	/* Lasketaan k�yhyysvaje k�yhien mediaanitulon osuutena populaation mediaanitulosta */
	DATA _VAJ&i; 
	LENGTH Otsikko $50;
	Otsikko = "K�yhyysvaje ja osuus med. tulosta, &&Raja&i %";
	RLKM = ROUND(SUM(&&absoraja&i, -&&KMD&i), 10);
	AOSU = ROUND((100 * (RLKM / &&absoraja&i)), .01);
	OUTPUT;
	RUN;

	/* Lasketaan k�yhiss� talouksissa olevat alle 18-vuotiaat, sek� osuus kaikista alle 18-vuotiaista */
	DATA _PLA&i; 
	SET _PLA&i; 
	LENGTH Otsikko $50;
	Otsikko = "Alle 18 K�yhiss� talouksissa, &&Raja&i %";
	RLKM = ROUND(R&&raja&i, 10);
	AOSU = ROUND((100 * (R&&raja&i / &laps)), .01);
	RUN;

	/* Lasketaan k�yhiss� talouksissa olevat 65-t�ytt�neet, sek� osuus kaikista 65-t�ytt�neist� */
	DATA _PVA&i; SET 
	_PVA&i; 
	LENGTH Otsikko $50;
	Otsikko = "65+ K�yhiss� talouksissa, &&Raja&i %";
	RLKM = ROUND(R&&raja&i, 10);
	AOSU = ROUND((100 * (R&&raja&i / &vanh)), .01);
	RUN;

	/* Lasketaan k�yhien nuppiluku sek� k�yhien osuus */
	DATA _POP&i; 
	LENGTH Otsikko $50;
	Otsikko = "K�yh�t ja k�yhien osuus, &&Raja&i %";
	RLKM = ROUND(&&KLKM&i, 10);
	AOSU = ROUND((100 * (&&KLKM&i / &lkm)), .01);
	OUTPUT;
	RUN;

	/* Keskitulo k�yhyysrajan alla */
	DATA _RMN&I; 
	SET _RMN&I; 
	LENGTH Otsikko $50;
	Otsikko = "Keskitulo k�yhyysrajan alla, &&Raja&i %";
	RLKM = ROUND(R&&raja&i, 10);
	RUN;

	/* Mediaanitulo k�yhyysrajan alla */
	DATA _RMD&I; 
	SET _RMD&I; 
	LENGTH Otsikko $50;
	Otsikko = "Mediaanitulo k�yhyysrajan alla, &&Raja&i %";
	RLKM = ROUND(R&&raja&i, 10);
	RUN;
		
%END;

DATA _POPMN; 
LENGTH Otsikko $50;
Otsikko = "Keskitulo / kulutusyksikk�";
RLKM = ROUND(&MeantuPOP, 10);
OUTPUT;
RUN;

DATA _POPMD; LENGTH Otsikko $50;
Otsikko = "Mediaanitulo / kulutusyksikk�";
RLKM = ROUND(&MedtuPOP, 10);
OUTPUT;
RUN;

DATA _GINI; 
LENGTH Otsikko $50;
Otsikko = "Populaatio ja ginikerroin";
RLKM = ROUND(&lkm, 10);
AOSU = ROUND((100 * (&GINI / (&MeantuPOP * 2))), .01);
OUTPUT;
RUN;

/* 12. Vied��n tiedot &OUTP-dataan */

DATA &OUTP;
SET _GINI _POPMN _POPMD
%DO i = 1 %TO &rajat; _AR&i %END;
%DO i = 1 %TO &rajat; _RMN&i %END;
%DO i = 1 %TO &rajat; _RMD&i %END;
%DO i = 1 %TO &rajat; _POP&i %END;
%DO i = 1 %TO &rajat; _VAJ&i %END;
%DO i = 1 %TO &rajat; _PLA&i %END;
%DO i = 1 %TO &rajat; _PVA&i %END;
%DO i = 1 %TO &rajat; _TYO&i %END;
%DO i = 1 %TO &rajat; _ETY&i %END;
;
LABEL RLKM = "Euroa / lukum��r�" AOSU = "Suhdeluku / %-osuus";
FORMAT RLKM tuhat.;
KEEP Otsikko RLKM AOSU;
RUN;

/* 13. Desiilien tulo-osuudet */

%IF &destu = 1 %THEN %DO;

	/* Lasketaan desiilien rajat ja vied��n ne makromuuttujiksi */	

	PROC UNIVARIATE DATA = _LASK NOPRINT;
	VAR ETULO;
	WEIGHT &PAINO;
	OUTPUT OUT = _DESIILIT
	PCTLPTS = 10 TO 90 BY 10 PCTLPRE = DES;
	RUN;

	PROC SQL NOPRINT;
	SELECT DES10, DES20, DES30, DES40, DES50, DES60, DES70, DES80, DES90
	INTO :DES10, :DES20, :DES30, :DES40, :DES50, :DES60, :DES70, :DES80, :DES90
	FROM _DESIILIT;
	QUIT;

	/* Lasketaan desiilien tulo-osuudet */

	PROC MEANS DATA = _LASK NOPRINT; 
	VAR TULOT; CLASS &desit; 
	WEIGHT &PAINO; 
	OUTPUT OUT = _DESTEMP SUM=;
	RUN;

	PROC SQL NOPRINT; 
	SELECT TULOT INTO :TOT FROM _DESTEMP WHERE &desit = .;
	QUIT;

	/* Vied�n desiilien tiedot tauluksi */

	DATA _DESTEMP; 
	SET _DESTEMP (DROP = _TYPE_ _FREQ_);
	LENGTH Otsikko $50;	
	IF &desit = . THEN DELETE;
	AOSU = ROUND((100 * TULOT / &TOT), 0.01);
	RLKM = ROUND(TULOT, 10);
	IF &desit = 0 THEN Otsikko = "1. Desiilin tulot ja tulo-osuus"; 
	ELSE IF &desit = 1 THEN DO; Otsikko = "2. Desiilin tulot ja tulo-osuus"; DES = &DES10;END;
	ELSE IF &desit = 2 THEN DO; Otsikko = "3. Desiilin tulot ja tulo-osuus"; DES = &DES20;END;
	ELSE IF &desit = 3 THEN DO; Otsikko = "4. Desiilin tulot ja tulo-osuus"; DES = &DES30;END;
	ELSE IF &desit = 4 THEN DO; Otsikko = "5. Desiilin tulot ja tulo-osuus"; DES = &DES40;END;
	ELSE IF &desit = 5 THEN DO; Otsikko = "6. Desiilin tulot ja tulo-osuus"; DES = &DES50;END;
	ELSE IF &desit = 6 THEN DO; Otsikko = "7. Desiilin tulot ja tulo-osuus"; DES = &DES60;END;
	ELSE IF &desit = 7 THEN DO; Otsikko = "8. Desiilin tulot ja tulo-osuus"; DES = &DES70;END;
	ELSE IF &desit = 8 THEN DO; Otsikko = "9. Desiilin tulot ja tulo-osuus"; DES = &DES80;END;
	ELSE DO; Otsikko = "10. Desiilin tulot ja tulo-osuus"; DES = &DES90;
	END;
	LABEL DES = 'Desiilien tulorajat';
	DROP TULOT &desit;
	RUN;

	DATA &OUTP; 
	SET &OUTP _DESTEMP;
	FORMAT RLKM tuhat. DES tuhat.;
	RUN;

%END;

/* 14. Poistetaan TEMP-taulut WORK-hakemistosta*/

PROC DATASETS LIBRARY = WORK NOLIST; 
	DELETE _: /MEMTYPE = DATA;
	DELETE _: /MEMTYPE = VIEW;
QUIT;

/* 15. Tulostetaan indikaattorit SAS:n outputtiin */

PROC PRINT DATA = OUTPUT.&TULOSNIMI_KOKO._IND LABEL;
TITLE "TULONJAKOINDIKAATTOREITA, KOKOMALLI";
FORMAT AOSU commax15.2 RLKM tuhat.;
RUN;

%MEND Indikaattorit;


