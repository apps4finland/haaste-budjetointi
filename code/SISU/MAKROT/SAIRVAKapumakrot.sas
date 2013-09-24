/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyˆdynt‰‰ Tilastokeskuksen yleisten
* k‰yttˆehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto p‰‰hakemistossa.
******************************************************************************/

/*******************************************************************
*  Kuvaus: Sairausvakuutuksen simuloinnin apumakroja               * 
*  Tekij‰: Pertti Honkanen / Kela                                  *
*  Luotu: 12.09.2011                                               *
*  Viimeksi p‰ivitetty: 7.12.2011 							       * 
*  P‰ivitt‰j‰: Olli Kannas / TK                               	   *
********************************************************************/


/* 1. SISƒLLYS */

/* Tiedosto sis‰lt‰‰ seuraavat makrot */

/*
2.1 HaeParam_SairVakSIMUL = Makro, joka tekee SAIRVAK-mallin parametreista makromuuttujia, simulointilaskelmat
2.2 HaeParam_SairVakESIM = Makro, joka tekee SAIRVAK-mallin parametreista makromuuttujia, esimerkkilaskelmat
2.3 HaeParam_SairVakSIMULx = Tyhj‰ makro, jolla voidaan korvata lains‰‰d‰ntˆ‰ kuvaavien makrojen sis‰ll‰ oleva parametrien haku
2.4 KuuNro_SairVakSIMUL = Kuukausinumeron muodostus, simulointi
2.4 KuuNro_SairVakSIMULx = Kuukausinumeron muodostus, simulointi
2.5 KuuNro_SairVakESIM = Kuukausinumeron muodostus, esimerkkilaskelmat
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

%MACRO Haeparam_SairVakSIMUL (mvuosi, mkuuk, minf)/STORE
DES = 'SAIRVAK, SIMUL: Makro, joka tekee SAIRVAK-mallin parametreista makromuuttujia,
simulointilaskelmat';

%LET valuutta = %SYSFUNC(IFN(&mvuosi < 2002, &euro, 1));
%LET kuuknro = %EVAL((&mvuosi - &paramalkusv) * 12 + &mkuuk);
%LET taulu_sv = %SYSFUNC(OPEN(PARAM.&PSAIRVAK, i));
%LET w = %SYSFUNC(REWIND(&taulu_sv));
%LET w = %SYSFUNC(FETCHOBS(&taulu_sv, 1));
%LET y = %SYSFUNC(GETVARN(&taulu_sv, 1));
%LET z = %SYSFUNC(GETVARN(&taulu_sv, 2));
%LET testi = %EVAL((&y - &paramalkusv) * 12 + &z);
%IF &testi <= &kuuknro %THEN;
%ELSE %DO %UNTIL ((&testi <= &kuuknro) OR (&testi = 1));
	%LET w = %SYSFUNC(FETCH(&taulu_sv));
	%LET y = %SYSFUNC(GETVARN(&taulu_sv, 1));
	%LET z = %SYSFUNC(GETVARN(&taulu_sv, 2));
	%LET testi = %EVAL((&y - &paramalkusv) * 12 + &z);
%END;
%IF &w = -1 %THEN %DO;
	%LET riveja = %SYSFUNC(ATTRN(&taulu_sv, NLOBS));
	%LET w = %SYSFUNC(FETCHOBS(&taulu_sv, &riveja));
%END;

%LET Minimi = (%SYSFUNC(GETVARN(&taulu_sv, %SYSFUNC(VARNUM(&taulu_sv, Minimi)))) / &valuutta) * &minf ;
%LET VanhMin = (%SYSFUNC(GETVARN(&taulu_sv, %SYSFUNC(VARNUM(&taulu_sv, VanhMin)))) / &valuutta) * &minf ;
%LET SRaja1 = (%SYSFUNC(GETVARN(&taulu_sv, %SYSFUNC(VARNUM(&taulu_sv, SRaja1)))) / &valuutta) * &minf;
%LET SRaja2 = (%SYSFUNC(GETVARN(&taulu_sv, %SYSFUNC(VARNUM(&taulu_sv, SRaja2)))) / &valuutta) * &minf ;
%LET SRaja3 = (%SYSFUNC(GETVARN(&taulu_sv, %SYSFUNC(VARNUM(&taulu_sv, SRaja3)))) / &valuutta) * &minf ;
%LET LapsiKor = (%SYSFUNC(GETVARN(&taulu_sv, %SYSFUNC(VARNUM(&taulu_sv, LapsiKor)))) / &valuutta) * &minf ;
%LET SPros1 = %SYSFUNC(GETVARN(&taulu_sv, %SYSFUNC(VARNUM(&taulu_sv, SPros1))));
%LET SPros2 = %SYSFUNC(GETVARN(&taulu_sv, %SYSFUNC(VARNUM(&taulu_sv, SPros2))));
%LET SPros3 = %SYSFUNC(GETVARN(&taulu_sv, %SYSFUNC(VARNUM(&taulu_sv, SPros3))));
%LET SPros4 = %SYSFUNC(GETVARN(&taulu_sv, %SYSFUNC(VARNUM(&taulu_sv, SPros4))));
%LET SPros5 = %SYSFUNC(GETVARN(&taulu_sv, %SYSFUNC(VARNUM(&taulu_sv, SPros5))));
%LET PalkVah = %SYSFUNC(GETVARN(&taulu_sv, %SYSFUNC(VARNUM(&taulu_sv, PalkVah))));
%LET PoikRaja1 = (%SYSFUNC(GETVARN(&taulu_sv, %SYSFUNC(VARNUM(&taulu_sv, PoikRaja1)))) / &valuutta) * &minf ;
%LET PoikRaja2 = (%SYSFUNC(GETVARN(&taulu_sv, %SYSFUNC(VARNUM(&taulu_sv, PoikRaja2)))) / &valuutta) * &minf ;
%LET PoikPros = %SYSFUNC(GETVARN(&taulu_sv, %SYSFUNC(VARNUM(&taulu_sv, PoikPros))));
%LET HarkRaja = %SYSFUNC(GETVARN(&taulu_sv, %SYSFUNC(VARNUM(&taulu_sv, HarkRaja))));
%LET HarkPuol = %SYSFUNC(GETVARN(&taulu_sv, %SYSFUNC(VARNUM(&taulu_sv, HarkPuol))));
%LET VarRaja = (%SYSFUNC(GETVARN(&taulu_sv, %SYSFUNC(VARNUM(&taulu_sv, VarRaja)))) / &valuutta) * &minf ;
%LET KorProsAit = %SYSFUNC(GETVARN(&taulu_sv, %SYSFUNC(VARNUM(&taulu_sv, KorProsAit))));
%LET KorPros1 = %SYSFUNC(GETVARN(&taulu_sv, %SYSFUNC(VARNUM(&taulu_sv, KorPros1))));
%LET KorPros2 = %SYSFUNC(GETVARN(&taulu_sv, %SYSFUNC(VARNUM(&taulu_sv, KorPros2))));
%LET OsaPRaha = %SYSFUNC(GETVARN(&taulu_sv, %SYSFUNC(VARNUM(&taulu_sv, OsaPRaha))));
%LET SPaivat = %SYSFUNC(GETVARN(&taulu_sv, %SYSFUNC(VARNUM(&taulu_sv, SPaivat))));
%LET MaxPaiv = %SYSFUNC(GETVARN(&taulu_sv, %SYSFUNC(VARNUM(&taulu_sv, MaxPaiv))));
%LET SMaksLaps = %SYSFUNC(GETVARN(&taulu_sv, %SYSFUNC(VARNUM(&taulu_sv, SMaksLaps))));
%LET loppu = %SYSFUNC(CLOSE(&taulu_sv));

%MEND Haeparam_SairVakSIMUL;


/* 2.2 T‰m‰ makro tekee saman asian kuin edellinen, mutta se toimii vain osana data-askelta.
       Makro luo useita muuttujia data-taulukkoon. Makroa k‰ytet‰‰n esimerkkilaskelmissa (tyyppi = ESIM).
	   Inflaatio- ja valuuttakurssimuunnokset tehd‰‰n t‰ss‰ vaiheessa */

* Makron parametrit:
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi ;

%MACRO Haeparam_SairVakESIM (mvuosi, mkuuk, minf)/STORE
DES = 'SAIRVAK, ESIM: Makro, joka tekee SAIRVAK-mallin parametreista makromuuttujia,
esimerkkilaskelmat';

%LET valuutta = IFN(&mvuosi < 2002, &euro,  1);
kuuknro = (&mvuosi - &paramalkusv) * 12 + &mkuuk;
IF _N_ = 1 OR taulu_sv = . THEN taulu_sv = OPEN("PARAM.&PSAIRVAK", "i");
RETAIN taulu_sv;
w = REWIND(taulu_sv);
w = FETCHOBS(taulu_sv, 1);
y = GETVARN(taulu_sv, 1);
z = GETVARN(taulu_sv, 2);
testi = (y - &paramalkusv) * 12 + z;
IF testi <= kuuknro THEN;
ELSE DO UNTIL (testi <= kuuknro);
	w = FETCH(taulu_sv);
	y = GETVARN(taulu_sv, 1);
	z = GETVARN(taulu_sv, 2);
	testi = (y - &paramalkusv) * 12 + z;
END;
IF w = -1 THEN DO;
	%LET riveja = ATTRN(taulu_sv, "NLOBS");
	w = FETCHOBS(taulu_sv, &riveja);
END;

%LET Minimi = (GETVARN(taulu_sv, VARNUM(taulu_sv, "Minimi")) / &valuutta) * &minf ;
%LET VanhMin = (GETVARN(taulu_sv, VARNUM(taulu_sv, "VanhMin")) / &valuutta) * &minf ;
%LET SRaja1 = (GETVARN(taulu_sv, VARNUM(taulu_sv, "SRaja1")) / &valuutta) * &minf ;
%LET SRaja2 = (GETVARN(taulu_sv, VARNUM(taulu_sv, "SRaja2")) / &valuutta) * &minf ;
%LET SRaja3 = (GETVARN(taulu_sv, VARNUM(taulu_sv, "SRaja3")) / &valuutta) * &minf ;
%LET LapsiKor = (GETVARN(taulu_sv, VARNUM(taulu_sv, "LapsiKor")) / &valuutta) * &minf ;
%LET SPros1 = GETVARN(taulu_sv, VARNUM(taulu_sv, "SPros1"));
%LET SPros2 = GETVARN(taulu_sv, VARNUM(taulu_sv, "SPros2"));
%LET SPros3 = GETVARN(taulu_sv, VARNUM(taulu_sv, "SPros3"));
%LET SPros4 = GETVARN(taulu_sv, VARNUM(taulu_sv, "SPros4"));
%LET SPros5 = GETVARN(taulu_sv, VARNUM(taulu_sv, "SPros5"));
%LET PalkVah = GETVARN(taulu_sv, VARNUM(taulu_sv, "PalkVah"));
%LET PoikRaja1 = (GETVARN(taulu_sv, VARNUM(taulu_sv, "PoikRaja1")) / &valuutta) * &minf ;
%LET PoikRaja2 = (GETVARN(taulu_sv, VARNUM(taulu_sv, "PoikRaja2")) / &valuutta) * &minf ;
%LET PoikPros = GETVARN(taulu_sv, VARNUM(taulu_sv, "PoikPros"));
%LET HarkRaja = GETVARN(taulu_sv, VARNUM(taulu_sv, "HarkRaja"));
%LET HarkPuol = GETVARN(taulu_sv, VARNUM(taulu_sv, "HarkPuol"));
%LET VarRaja = (GETVARN(taulu_sv, VARNUM(taulu_sv, "VarRaja")) / &valuutta) * &minf ;
%LET KorProsAit = GETVARN(taulu_sv, VARNUM(taulu_sv, "KorProsAit"));
%LET KorPros1 = GETVARN(taulu_sv, VARNUM(taulu_sv, "KorPros1"));
%LET KorPros2 = GETVARN(taulu_sv, VARNUM(taulu_sv, "KorPros2"));
%LET OsaPRaha = GETVARN(taulu_sv, VARNUM(taulu_sv, "OsaPRaha"));
%LET MaxPaiv = GETVARN(taulu_sv, VARNUM(taulu_sv, "MaxPaiv"));
%LET SPaivat = GETVARN(taulu_sv, VARNUM(taulu_sv, "SPaivat"));
%LET SMaksLaps = GETVARN(taulu_sv, VARNUM(taulu_sv, "SMaksLaps"));

%MEND Haeparam_SairVakESIM;

/* 2.3 Tyhj‰ makro, jolla voidaan korvata lains‰‰d‰ntˆ‰ kuvaavien
	   makrojen sis‰ll‰ oleva parametrien haku, jos parametrit on m‰‰ritelty
	   ennen simulointiohjelman ajoa. K‰ytet‰‰n, jos halutaan k‰ytt‰‰ vuosikeskiarvon laskemisessa tietyn 
	   kuukauden lains‰‰d‰ntˆ‰ (tyyppi = SIMULx). */

* Makron parametrit:
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi ;

%MACRO Haeparam_SairVakSIMULx(mvuosi, mkuuk, minf)/STORE
DES = 'SAIRVAK, SIMULx: Tyhj‰ makro, jolla voidaan korvata lains‰‰d‰ntˆ‰ kuvaavien makrojen sis‰ll‰ oleva parametrien haku';
%MEND Haeparam_SairVakSIMULx;

/* 2.4 Makro, jolla vuosiluvusta ja kuukauden numerosta johdetaan j‰rjestysluku ajankohtien vertailua varten.
       Jos tarjotaan parametritaulukon l‰htˆvuotta aikaisempaa arvoa, valitaan ensimm‰inen mahdollinen kuukausi.
	   Makroa k‰ytet‰‰n varsinaisissa simulointilaskelmissa */

* Makron parametrit:
	nro: Makron tulosmuuttuja, ajankohdan (vuosi ja kuukausi) j‰rjestysluku 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n ;

%MACRO KuuNro_SairVakSIMUL (nro, mvuosi, mkuuk)/STORE
DES = 'SAIRVAK, SIMUL: Kuukausinumeron muodostus, simulointi';

&nro = 12 * %EVAL (&mvuosi - &paramalkusv) + &mkuuk;
%IF &mvuosi < &paramalkusv %THEN &nro = 1;
%MEND KuuNro_SairVakSIMUL;

%MACRO KuuNro_SairVakSIMULx (nro, mvuosi, mkuuk)/STORE
DES = 'SAIRVAK, SIMULx: Kuukausinumeron muodostus, simulointi';

&nro = 12 * %EVAL (&mvuosi - &paramalkusv) + &mkuuk;
%IF &mvuosi < &paramalkusv %THEN &nro = 1;
%MEND KuuNro_SairVakSIMULx;

/* 2.5 Edellisest‰ makrosta versio, joka toimii vain osana data-askelta. Makroa k‰ytet‰‰n esimerkkilaskelmissa. */

%MACRO KuuNro_SairVakESIM (nro, mvuosi, mkuuk)/STORE
DES = 'SAIRVAK, ESIM: Kuukausinumeron muodostus, esimerkkilaskelmat';

&nro = 12 * (&mvuosi - &paramalkusv) + &mkuuk;
IF &mvuosi < &paramalkusv THEN &nro = 1;
%MEND KuuNro_SairVakESIM;



