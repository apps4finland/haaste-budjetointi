/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyödyntää Tilastokeskuksen yleisten
* käyttöehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto päähakemistossa.
******************************************************************************/

/**************************************************************************************
*  Kuvaus: Rahanarvon muuttamiseen tarkoitettuja makroja    						  *	 
*  Tekijä: Pertti Honkanen / Kela                            						  *
*  Luotu: 12.09.2011                                         						  *
*  Viimeksi päivitetty: 9.3.2012 							 						  * 
*  Päivittäjä: Olli Kannas / TK                        		 						  *
***************************************************************************************/


/* 1. Makrojen parametrit 

tulos: Makron tulosmuuttuja (vertailuvuoden rahanarvoon muunnettu arvo)
vertvuosi: Vertailuvuosi (aineistovuosi)
vuosi: Lainsäädäntövuosi
vertkuuk: Vertailuvuoden kuukausi
kuuk: Lainsäädäntökuukausi
arvo: Rahamäärä, joka halutaan muuntaa vertailuvuoden rahanarvoon */


/* 2. Elinkustannusindeksiin perustuva rahanarvon muunnosmakro */

/* 2.1 Vuositaso */

%MACRO KH51X (tulos, vertvuosi, vuosi, arvo)/STORE
DES = 'INDEKSIT, V: Elinkustannusindeksiin perustuva rahanarvon muunnosmakro, vuositaso';
%LET taulu = %SYSFUNC(OPEN(PARAM.&PINDEKSI_VUOSI, i));
%LET w = %SYSFUNC(FETCH(&taulu));
%LET y = %SYSFUNC(GETVARN(&taulu, 1));
%DO %WHILE (&w = 0);
	%LET y = %SYSFUNC(GETVARN(&taulu, 1));
	%IF &y = &vertvuosi %THEN %LET indvert = %SYSFUNC(GETVARN(&taulu, 2));
	%IF &y = &vuosi %THEN %LET indnyt = %SYSFUNC(GETVARN(&taulu, 2));
	%LET w = %SYSFUNC(FETCH(&taulu));
%END;
&tulos = %SYSEVALF(&arvo * %SYSEVALF(&indvert / &indnyt));
%IF &vertvuosi < 1952 OR &vuosi < 1952 %THEN &tulos = .;
%LET z = %SYSFUNC(CLOSE(&taulu));
%MEND KH51X;

/* 2.2 Kuukausitaso */

%MACRO KH51XKuuk (tulos, vertvuosi, vertkuuk, vuosi, kuuk, arvo)/STORE
DES = 'INDEKSIT, KK: Elinkustannusindeksiin perustuva rahanarvon muunnosmakro, kuukausitaso';
%LET taulu = %SYSFUNC(OPEN(PARAM.&PINDEKSI_KUUK, i));
%LET w = %SYSFUNC(FETCH(&taulu));
%LET y = %SYSFUNC(GETVARN(&taulu, 1));
%DO %WHILE (&W = 0);
	%LET y = %SYSFUNC(GETVARN(&taulu, 1));
	%LET z = %SYSFUNC(GETVARN(&taulu, 2));
	%IF &y = &vertvuosi AND &z = &vertkuuk %THEN %LET indvert = %SYSFUNC(GETVARN(&taulu, 3));
	%IF &y = &vuosi AND &z = &kuuk %THEN %LET indnyt = %SYSFUNC(GETVARN(&taulu, 3));
	%LET W = %SYSFUNC(FETCH(&taulu));
%END;
&tulos =%SYSEVALF(&arvo * %SYSEVALF(&indvert/&indnyt));
%IF &vertvuosi < 1952 OR &vuosi < 1952 %THEN &tulos = .;
%LET v = %SYSFUNC(CLOSE(&taulu));
%MEND KH51XKuuk;


/* 3. Elinkustannusindeksiin perustuva rahanarvon muunnosmakro, esimerkkilaskelmat */

/* 3.1 Vuositaso */

%MACRO KH51 (tulos, vertvuosi, vuosi, arvo)/STORE
DES = 'INDEKSIT, V: Data-askeleen ulkopuolella toimiva elinkustannusindeksiin perustuva rahanarvon muunnosmakro, vuositaso';
taulu = OPEN( "PARAM.&PINDEKSI_VUOSI", "i");
w = FETCH(taulu);
y = GETVARN(taulu, 1);
DO WHILE (w = 0);
	 y = GETVARN(taulu, 1);
	 IF y = &vertvuosi THEN  indvert = GETVARN(taulu, 2);
	 IF y = &vuosi THEN  indnyt = GETVARN(taulu, 2);
	 w = FETCH(taulu);
END;
IF (indnyt NE . ) OR (indnyt NE 0) THEN &tulos = &arvo * indvert / indnyt;
IF (&arvo = .) OR (indnyt = .) OR (indnyt = 0) OR (&vertvuosi < 1952) OR (&vuosi < 1952) THEN &tulos = .;
z = CLOSE(taulu);
%MEND KH51;

/* 3.2 Kuukausitaso */

%MACRO KH51Kuuk (tulos, vertvuosi, vertkuuk, vuosi, kuuk, arvo)/STORE
DES = 'INDEKSIT, KK: Data-askeleen ulkopuolella toimiva elinkustannusindeksiin perustuva rahanarvon muunnosmakro, kuukausitaso';
taulu = OPEN("PARAM.&PINDEKSI_KUUK", "i");
w = FETCH(taulu);
y = GETVARN(taulu, 1);
DO WHILE (w = 0);
	 y = GETVARN(taulu, 1);
	 z = GETVARN(taulu, 2);
	 IF y = &vertvuosi AND z = &vertkuuk THEN  indvert = GETVARN(taulu, 3);
	 IF y = &vuosi AND z = &kuuk THEN  indnyt = GETVARN(taulu, 3);
	 w = FETCH(taulu);
END;
IF (indnyt NE . ) OR (indnyt NE 0) THEN &tulos = &arvo * indvert / indnyt;
IF (&arvo = .) OR (indnyt = .) OR (indnyt = 0) OR (&vertvuosi < 1952) OR (&vuosi < 1952) THEN &tulos = .;
z = CLOSE(taulu);
%MEND KH51Kuuk;


/* 4. Elinkustannusindeksiin perustuva parametrien muunnoskerroin */

/* 4.1 Vuositaso */

%MACRO IndKerroin (vertvuosi, vuosi)/STORE
DES = 'INDEKSIT, V: Makro, jolla voidaan tuottaa elinkustannusindeksiin perustuva parametrien muunnoskerroin, vuositaso';
%LET taulu = %SYSFUNC(OPEN(PARAM.&PINDEKSI_VUOSI, i));
%LET w = %SYSFUNC(FETCH(&taulu));
%LET y = %SYSFUNC(GETVARN(&taulu, 1));
%DO %WHILE (&w = 0);
	%LET y = %SYSFUNC(GETVARN(&taulu, 1));
	%IF &y = &vertvuosi %THEN %LET indvert = %SYSFUNC(GETVARN(&taulu, 2));
	%IF &y = &vuosi %THEN %LET indnyt = %SYSFUNC(GETVARN(&taulu, 2));
	%LET w = %SYSFUNC(FETCH(&taulu));
%END;
%IF (&indnyt NE 0) OR (&indnyt NE .) %THEN %LET INF =%SYSEVALF(&indvert / &indnyt);
%ELSE %LET INF = 1;
%LET z = %SYSFUNC(CLOSE(&taulu));
%MEND IndKerroin;

/* 4.2 Kuukausitaso */

%MACRO IndKerroinKuuk (vertvuosi, vertkuuk, vuosi, kuuk)/STORE
DES = 'INDEKSIT, KK: Makro, jolla voidaan tuottaa elinkustannusindeksiin perustuva parametrien muunnoskerroin, kuukausitaso';
%LET taulu = %SYSFUNC(OPEN(PARAM.&PINDEKSI_KUUK, i));
%LET w = %SYSFUNC(FETCH(&taulu));
%LET y = %SYSFUNC(GETVARN(&taulu, 1));
%LET z = %SYSFUNC(GETVARN(&taulu, 2));
%DO %WHILE (&w = 0);
	%LET y = %SYSFUNC(GETVARN(&taulu, 1));
	%LET z = %SYSFUNC(GETVARN(&taulu, 2));
	%IF &y = &vertvuosi AND &z = &vertkuuk %THEN %LET indvert = %SYSFUNC(GETVARN(&taulu, 3));
	%IF &y = &vuosi AND &z = &kuuk %THEN %LET indnyt = %SYSFUNC(GETVARN(&taulu, 3));
	%LET w = %SYSFUNC(FETCH(&taulu));
%END;
%IF (&indnyt NE 0) OR (&indnyt NE .) %THEN %LET INF =%SYSEVALF(&indvert / &indnyt);
%ELSE %LET INF = 1;
%LET v = %SYSFUNC(CLOSE(&taulu));
%MEND IndKerroinKuuk;


/* 5. Elinkustannusindeksiin perustuva parametrien muunnoskerroin, esimerkkilaskelmat */

/* 5.1 Vuositaso */

%MACRO IndKerroin_ESIM (vertvuosi, vuosi)/STORE
DES = 'INDEKSIT, V: Makro, jolla voidaan tuottaa elinkustannusindeksiin perustuva parametrien muunnoskerroin esimerkkilaskelmiin, vuositaso';
taulu = OPEN("PARAM.&PINDEKSI_VUOSI", "i");
w = FETCH(taulu);
y = GETVARN(taulu, 1);
DO WHILE (w = 0);
	y = GETVARN(taulu, 1);
	IF y = &vertvuosi THEN indvert = GETVARN(taulu, 2);
	IF y = &vuosi THEN indnyt = GETVARN(taulu, 2);
	w = FETCH(taulu);
END;
IF (indnyt NE 0) OR (indnyt NE .) THEN INF = (indvert / indnyt);
ELSE INF = 1;
z = CLOSE(taulu);
DROP taulu w y indvert indnyt z;
%MEND IndKerroin_ESIM;

/* 5.2 Kuukausitaso */

%MACRO IndKerroinKuuk_ESIM (vertvuosi, vertkuuk, vuosi, kuuk)/STORE
DES = 'INDEKSIT, KK: Makro, jolla voidaan tuottaa elinkustannusindeksiin perustuva parametrien muunnoskerroin esimerkkilaskelmiin, kuukausitaso';
taulu = OPEN("PARAM.&PINDEKSI_KUUK", "i");
w = FETCH(taulu);
y = GETVARN(taulu, 1);
z = GETVARN(taulu, 2);
DO WHILE (w = 0);
	y = GETVARN(taulu, 1);
	z = GETVARN(taulu, 2);
	IF y = &vertvuosi AND z = &vertkuuk THEN indvert = GETVARN(taulu, 3);
	IF y = &vuosi AND z = &kuuk THEN indnyt = GETVARN(taulu, 3);
	w = FETCH(taulu);
END;
IF (indnyt NE 0) OR (indnyt NE .) THEN INF = (indvert / indnyt);
ELSE INF = 1;
v = CLOSE(taulu);
DROP taulu w y indvert indnyt z;
%MEND IndKerroinKuuk_ESIM;
