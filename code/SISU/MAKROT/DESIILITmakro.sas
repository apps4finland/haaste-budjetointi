/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyödyntää Tilastokeskuksen yleisten
* käyttöehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto päähakemistossa.
******************************************************************************/

/* *****************************************************************
* Kuvaus: Desiililuokitusten uudelleenlaskenta 					   *
* Tekijä: Jukka Mattila / TK		                		       *
* Luotu: 31.1.2012				       					   		   *
* Viimeksi päivitetty: 18.7.2012								   *
* Päivittäjä: Jukka Mattila / TK								   *
********************************************************************/

* Makron parametrit:
	id: Yksikkötunniste (kotitalous/asuntokunta, aina knro)
	tulo: Datan tulo-/varallisuus- tms. -muuttuja, jonka mukaiset desiilit lasketaan
	jasenia: Datan muuttuja, joka kertoo kotitalouden jäsenmäärän
	kuluyks: Datan muuttuja, joka kertoo kulutusyksiköiden lukumäärän
	paino: Painokerroin
	sisaan: Aineisto, josta laskenta tehdään ;

%MACRO Desiilit(id, tulo, jasenia, kuluyks, paino, sisaan)/STORE
DES = 'TULOKSET: Makro, joka laskee KOKO-mallissa desiililuokituksen uudestaan';

/* Muodostetaan laskentatiedosto kotitaloustasolle */

PROC SQL; 
CREATE VIEW _LASKE AS SELECT &ID, &JASENIA, max(&KULUYKS)/10 AS KULUYKS, &PAINO, 
&JASENIA*&PAINO AS WK, SUM(&TULO) AS TULO
FROM &SISAAN 
GROUP BY &ID 
ORDER BY &ID;
QUIT;

DATA _LASKE1/VIEW=_LASKE1; 
SET _LASKE; 
	BY &ID;
	IF FIRST.&ID;
	ETULO = MAX((TULO/KULUYKS), 0);
RUN;

/* Lasketaan desiilien rajat */

PROC UNIVARIATE DATA = _LASKE1 NOPRINT;
VAR ETULO;
WEIGHT WK;
OUTPUT OUT = _DESIILIT
PCTLPTS = 10 TO 90 BY 10 PCTLPRE = DES;
RUN;

/* Viedään desiilien rajat makromuuttujiksi */
%GLOBAL DES10 DES20 DES30 DES40 DES50 DES60 DES70 DES80 DES90;

PROC SQL NOPRINT;
SELECT DES10, DES20, DES30, DES40, DES50, DES60, DES70, DES80, DES90
INTO :DES10, :DES20, :DES30, :DES40, :DES50, :DES60, :DES70, :DES80, :DES90
FROM _DESIILIT;
QUIT;

/* Määritellään uudet desiilit kotitalouksille */

DATA _LASKE2; 
SET _LASKE1;
IF ETULO <= &DES10 THEN DESMOD_MALLI = 0;
ELSE IF ETULO <= &DES20 THEN DESMOD_MALLI = 1;
ELSE IF ETULO <= &DES30 THEN DESMOD_MALLI = 2;
ELSE IF ETULO <= &DES40 THEN DESMOD_MALLI = 3;
ELSE IF ETULO <= &DES50 THEN DESMOD_MALLI = 4;
ELSE IF ETULO <= &DES60 THEN DESMOD_MALLI = 5;
ELSE IF ETULO <= &DES70 THEN DESMOD_MALLI = 6;
ELSE IF ETULO <= &DES80 THEN DESMOD_MALLI = 7;
ELSE IF ETULO <= &DES90 THEN DESMOD_MALLI = 8;
ELSE DESMOD_MALLI = 9;
DROP KULUYKS &jasenia &paino wk tulo etulo;
RUN;

/* Viedään uusi muuttuja dataan */
DATA &SISAAN; 
MERGE &SISAAN _LASKE2;
BY knro;
LABEL
DESMOD_MALLI = 'Käytettävissä olevien tulojen desiiliryhmä, MALLI';
RUN;

PROC DATASETS LIB = WORK NOLIST;
	DELETE _: /MEMTYPE = VIEW;
	DELETE _: /MEMTYPE = DATA;
RUN;QUIT;

%MEND Desiilit;
