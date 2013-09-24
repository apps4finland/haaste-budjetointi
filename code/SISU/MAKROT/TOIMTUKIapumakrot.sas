/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyˆdynt‰‰ Tilastokeskuksen yleisten
* k‰yttˆehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto p‰‰hakemistossa.
******************************************************************************/

/************************************************************
* Kuvaus: Toimeentulotuen simuloinnin apumakrot				*
* Tekij‰: Elina Ahola / KELA								*
* Luotu: 12.10.2011											*
* Viimeksi p‰ivitetty: 7.12.2011							*
* P‰ivitt‰j‰: Olli Kannas / TK								*				
************************************************************/


/* 1. SISƒLLYS */

/* Tiedosto sis‰lt‰‰ seuraavat makrot */

/*
2.1 HaeParam_ToimTukiSIMUL = Makro, joka tekee TOIMTUKI-mallin parametreista makromuuttujia, simulointilaskelmat
2.2 HaeParam_ToimTukiESIM = Makro, joka tekee TOIMTUKI-mallin parametreista makromuuttujia, esimerkkilaskelmat
2.3 HaeParam_ToimTukiSIMULx = Tyhj‰ makro, jolla voidaan korvata lains‰‰d‰ntˆ‰ kuvaavien makrojen sis‰ll‰ oleva parametrien haku
2.4 KuuNro_ToimTukiSIMUL = Kuukausinumeron muodostus, simulointi
2.4 KuuNro_ToimTukiSIMULx = Kuukausinumeron muodostus, simulointi
2.5 KuuNro_ToimTukiESIM = Kuukausinumeron muodostus, esimerkkilaskelmat
*/


/* 2. Parametrien muuttaminen makromuuttujiksi */

/* 2.1 Makro, joka hakee halutun vuoden ja kuukauden parametrit ja tekee niist‰ makromuuttujat.
	   Jos vuosi-kuukausi -yhdistelm‰, jota tarjotaan ei esiinny parametritaulukossa, valitaan l‰hin mahdollinen ajankohta.
       T‰m‰ makro on itsen‰isesti toimiva makro, jota voi k‰ytt‰‰ myˆs data-askeleen ulkopuolella. 
	   Makroa k‰ytet‰‰n varsinaisissa simulointilaskelmissa (tyyppi = SIMUL). 
	   Inflaatio- ja valuuttakurssimuunnokset tehd‰‰n t‰ss‰ vaiheessa */

* Makron parametrit:
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi ;

%MACRO Haeparam_ToimTukiSIMUL(mvuosi, mkuuk, minf)/STORE
DES = 'TOIMTUKI, SIMUL: Makro, joka lukee tekee TOIMTUKI-mallin parametreista makromuuttujia,
simulointilaskelmat';

%LET valuutta = %SYSFUNC(IFN(&mvuosi < 2002, &euro, 1));
%LET kuuknro = %EVAL((&mvuosi - &paramalkuto) * 12 + &mkuuk);
%LET taulu_to = %SYSFUNC(OPEN(PARAM.&PTOIMTUKI, i));
%LET w = %SYSFUNC(REWIND(&taulu_to));
%LET w = %SYSFUNC(FETCHOBS(&taulu_to, 1));
%LET y = %SYSFUNC(GETVARN(&taulu_to, 1));
%LET z = %SYSFUNC(GETVARN(&taulu_to, 2));
%LET testi = %EVAL((&y - &paramalkuto) * 12 + &z);
%IF &testi <= &kuuknro %THEN;
%ELSE %DO %UNTIL ((&testi <= &kuuknro) OR (&testi = 1));
	%LET w = %SYSFUNC(FETCH(&taulu_to));
	%LET y = %SYSFUNC(GETVARN(&taulu_to, 1));
	%LET z = %SYSFUNC(GETVARN(&taulu_to, 2));
	%LET testi = %EVAL((&y - &paramalkuto) * 12 + &z);
%END;
%IF &w = -1 %THEN %DO;
	%LET riveja = %SYSFUNC(ATTRN(&taulu_to, NLOBS));
	%LET w = %SYSFUNC(FETCHOBS(&taulu_to, &riveja));
%END;

%LET YksinKR1 = (%SYSFUNC(GETVARN(&taulu_to, %SYSFUNC(VARNUM(&taulu_to, YksinKR1)))) / &valuutta) * &minf;
%LET YksinKR2 = (%SYSFUNC(GETVARN(&taulu_to, %SYSFUNC(VARNUM(&taulu_to, YksinKR2)))) / &valuutta) * &minf;
%LET YksPros = (%SYSFUNC(GETVARN(&taulu_to, %SYSFUNC(VARNUM(&taulu_to, YksPros)))));
%LET Yksinhuoltaja = (%SYSFUNC(GETVARN(&taulu_to, %SYSFUNC(VARNUM(&taulu_to, Yksinhuoltaja)))));
%LET Aik18Plus = (%SYSFUNC(GETVARN(&taulu_to, %SYSFUNC(VARNUM(&taulu_to, Aik18plus)))));
%LET AikLapsi18Plus = (%SYSFUNC(GETVARN(&taulu_to, %SYSFUNC(VARNUM(&taulu_to, AikLapsi18plus)))));
%LET Lapsi17 = (%SYSFUNC(GETVARN(&taulu_to, %SYSFUNC(VARNUM(&taulu_to, Lapsi17)))));
%LET Lapsi10_16 = (%SYSFUNC(GETVARN(&taulu_to, %SYSFUNC(VARNUM(&taulu_to, Lapsi10_16)))));
%LET LapsiAlle10 = (%SYSFUNC(GETVARN(&taulu_to, %SYSFUNC(VARNUM(&taulu_to, Lapsi_alle10)))));
%LET LapsiVah2 = (%SYSFUNC(GETVARN(&taulu_to, %SYSFUNC(VARNUM(&taulu_to, LapsiVah2)))));
%LET LapsiVah3 = (%SYSFUNC(GETVARN(&taulu_to, %SYSFUNC(VARNUM(&taulu_to, LapsiVah3)))));
%LET LapsiVah4 = (%SYSFUNC(GETVARN(&taulu_to, %SYSFUNC(VARNUM(&taulu_to, LapsiVah4)))));
%LET LapsiVah5 = (%SYSFUNC(GETVARN(&taulu_to, %SYSFUNC(VARNUM(&taulu_to, LapsiVah5)))));
%LET AsOmaVast = (%SYSFUNC(GETVARN(&taulu_to, %SYSFUNC(VARNUM(&taulu_to, AsOmaVast)))));
%LET VapaaOs = (%SYSFUNC(GETVARN(&taulu_to, %SYSFUNC(VARNUM(&taulu_to, VapaaOs)))));
%LET VapaaOsRaja = (%SYSFUNC(GETVARN(&taulu_to, %SYSFUNC(VARNUM(&taulu_to, VapaaOsRaja)))) / &valuutta) * &minf;
%LET loppu = %SYSFUNC(CLOSE(&taulu_to));

%MEND Haeparam_ToimTukiSIMUL;


/* 2.2 T‰m‰ makro tekee saman asian kuin edellinen, mutta se toimii vain osana data-askelta.
       Makro luo useita muuttujia data-taulukkoon. Makroa k‰ytet‰‰n esimerkkilaskelmissa (tyyppi = ESIM).
	   Inflaatio- ja valuuttakurssimuunnokset tehd‰‰n t‰ss‰ vaiheessa */

* Makron parametrit:
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi ;

%MACRO Haeparam_ToimTukiESIM(mvuosi, mkuuk, minf)/STORE
DES = 'TOIMTUKI, ESIM: Makro, joka tekee TOIMTUKI-mallin parametreista makromuuttujia, esimerkkilaskelmat';

%LET valuutta = IFN(&mvuosi < 2002, &euro,  1);
kuuknro = (&mvuosi - &paramalkuto) * 12 + &mkuuk;
IF _N_ = 1 OR taulu_to =. THEN taulu_to = OPEN("PARAM.&PTOIMTUKI", "i");
RETAIN taulu_to;
w = REWIND(taulu_to);
w = FETCHOBS(taulu_to, 1);
y = GETVARN(taulu_to, 1);
z = GETVARN(taulu_to, 2);
testi = (y - &paramalkuto) * 12 + z;
IF testi <= kuuknro THEN;
ELSE DO UNTIL (testi <= kuuknro);
	w = FETCH(taulu_to);
	y = GETVARN(taulu_to, 1);
	z = GETVARN(taulu_to, 2);
	testi = (y - &paramalkuto) * 12 + z;
END;
IF w = -1 THEN DO;
	%LET riveja = ATTRN(taulu_to, "NLOBS");
	w = FETCHOBS(taulu_to, &riveja);
END;

%LET YksinKR1 = (GETVARN(taulu_to, VARNUM(taulu_to, "YksinKR1")) / &valuutta) * &minf;
%LET YksinKR2 = (GETVARN(taulu_to, VARNUM(taulu_to, "YksinKR2")) / &valuutta) * &minf;
%LET YksPros = GETVARN(taulu_to, VARNUM(taulu_to, "YksPros"));
%LET Yksinhuoltaja = GETVARN(taulu_to, VARNUM(taulu_to, "Yksinhuoltaja"));
%LET Aik18Plus = GETVARN(taulu_to, VARNUM(taulu_to, "Aik18plus"));
%LET AikLapsi18Plus = GETVARN(taulu_to, VARNUM(taulu_to, "AikLapsi18plus"));
%LET Lapsi17 = GETVARN(taulu_to, VARNUM(taulu_to, "Lapsi17"));
%LET Lapsi10_16 = GETVARN(taulu_to, VARNUM(taulu_to, "Lapsi10_16"));
%LET LapsiAlle10 = GETVARN(taulu_to, VARNUM(taulu_to, "Lapsi_alle10"));
%LET LapsiVah2 = GETVARN(taulu_to, VARNUM(taulu_to, "LapsiVah2"));
%LET LapsiVah3 = GETVARN(taulu_to, VARNUM(taulu_to, "LapsiVah3"));
%LET LapsiVah4 = GETVARN(taulu_to, VARNUM(taulu_to, "LapsiVah4"));
%LET LapsiVah5 = GETVARN(taulu_to, VARNUM(taulu_to, "LapsiVah5"));
%LET AsOmaVast = GETVARN(taulu_to, VARNUM(taulu_to, "AsOmaVast"));
%LET VapaaOs = GETVARN(taulu_to, VARNUM(taulu_to, "VapaaOs"));
%LET VapaaOsRaja = (GETVARN(taulu_to, VARNUM(taulu_to, "VapaaOsraja")) / &valuutta) * &minf;

%MEND Haeparam_ToimTukiESIM;

/* 2.3 Tyhj‰ makro, jolla voidaan korvata lains‰‰d‰ntˆ‰ kuvaavien
	   makrojen sis‰ll‰ oleva parametrien haku, jos parametrit on m‰‰ritelty
	   ennen simulointiohjelman ajoa. K‰ytet‰‰n, jos halutaan k‰ytt‰‰ vuosikeskiarvon laskemisessa tietyn 
	   kuukauden lains‰‰d‰ntˆ‰ (tyyppi = SIMULx). */

* Makron parametrit:
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi ;

%MACRO Haeparam_ToimTukiSIMULx(mvuosi, mkuuk, minf)/STORE
DES = 'TOIMTUKI, SIMULx: Tyhj‰ makro, jolla voidaan korvata lains‰‰d‰ntˆ‰ kuvaavien makrojen sis‰ll‰ oleva parametrien haku';
%MEND Haeparam_ToimTukiSIMULx;

/* 2.4 Makro, jolla vuosiluvusta ja kuukauden numerosta johdetaan j‰rjestysluku ajankohtien vertailua varten.
       Jos tarjotaan parametritaulukon l‰htˆvuotta aikaisempaa arvoa, valitaan ensimm‰inen mahdollinen kuukausi.
	   Makroa k‰ytet‰‰n varsinaisissa simulointilaskelmissa */

* Makron parametrit:
	nro: Makron tulosmuuttuja, ajankohdan (vuosi ja kuukausi) j‰rjestysluku 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n ;

%MACRO KuuNro_ToimTukiSIMUL(nro, mvuosi, mkuuk)/STORE
DES = 'TOIMTUKI, SIMUL: Kuukausinumeron muodostus, simulointi';

&nro = 12 * (&mvuosi - &paramalkuto) + &mkuuk;
%IF &mvuosi < &paramalkuto %THEN &nro = 1;
%MEND KuuNro_ToimTukiSIMUL;

%MACRO KuuNro_ToimTukiSIMULx(nro, mvuosi, mkuuk)/STORE
DES = 'TOIMTUKI, SIMULx: Kuukausinumeron muodostus, simulointi';

&nro = 12 * (&mvuosi - &paramalkuto) + &mkuuk;
%IF &mvuosi < &paramalkuto %THEN &nro = 1;
%MEND KuuNro_ToimTukiSIMULx;

/* 2.5 Edellisest‰ makrosta versio, joka toimii vain osana data-askelta. Makroa k‰ytet‰‰n esimerkkilaskelmissa. */

%MACRO KuuNro_ToimTukiESIM(nro, mvuosi, mkuuk)/STORE
DES = 'TOIMTUKI, ESIM: Kuukausinumeron muodostus, esimerkkilaskelmat';

&nro = 12 * (&mvuosi - &paramalkuto) + &mkuuk;
IF &mvuosi < &paramalkuto THEN &nro = 1;
%MEND KuuNro_ToimTukiESIM;





