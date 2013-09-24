/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyˆdynt‰‰ Tilastokeskuksen yleisten
* k‰yttˆehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto p‰‰hakemistossa.
******************************************************************************/

/*************************************************************
*  Kuvaus: Kiinteistˆveron simuloinnin apumakroja      		 * 
*  Tekij‰: Anne Per‰lahti / TK                             	 *
*  Luotu: 6.6.2012                							 *                       
*  Viimeksi p‰ivitetty: 5.9.2012							 * 
*  P‰ivitt‰j‰: Olli Kannas / TK       			     	     *
**************************************************************/


/* 1. SISƒLLYS */

/* Tiedosto sis‰lt‰‰ seuraavat makrot */

/*
2.1 HaeParam_KiVeroSIMUL = Makro, joka tekee KIVERO-mallin parametreista makromuuttujia, simulointilaskelmat
2.2 HaeParam_KiVeroESIM = Makro, joka tekee KIVERO-mallin parametreista makromuuttujia, esimerkkilaskelmat
*/

/* 2. Parametrien muuttaminen makromuuttujiksi */

/* 2.1 Makro, joka hakee halutun vuoden parametrit ja tekee niist‰ makromuuttujat.
	   Jos vuosi, jota tarjotaan ei esiinny parametritaulukossa, valitaan l‰hin mahdollinen ajankohta.
       T‰m‰ makro on itsen‰isesti toimiva makro, jota voi k‰ytt‰‰ myˆs data-askeleen ulkopuolella. 
	   Makroa k‰ytet‰‰n varsinaisissa simulointilaskelmissa (tyyppi = SIMUL). 
	   Inflaatio- ja valuuttakurssimuunnokset tehd‰‰n t‰ss‰ vaiheessa */

* Makron parametrit:
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi ;

%MACRO HaeParam_KiVeroSIMUL (mvuosi, minf)/STORE
DES = 'KIVERO, SIMUL: Makro, joka tekee KIVERO-mallin parametreista makromuuttujia, simulointilaskelmat';

%LET valuutta = %SYSFUNC(IFN(&mvuosi < 2002, &euro, 1));

%LET taulu_kv = %SYSFUNC(OPEN(PARAM.&PKIVERO, i));
%SYSCALL SET(taulu_kv);
%LET w = %SYSFUNC(FETCH(&taulu_kv));
%IF &mvuosi >= %SYSFUNC(GETVARN(&taulu_kv, 1)) %THEN;
%ELSE %DO %UNTIL (%SYSFUNC(GETVARN(&taulu_kv, 1)) = &mvuosi OR &w = -1);
	%LET w = %SYSFUNC(FETCH(&taulu_kv));
%END;
%LET w = %SYSFUNC(CLOSE(&taulu_kv));

%LET PtPerusArvo = (&PtPerusArvo / &valuutta) * &minf;
%LET PtPuuVanh = (&PtPuuVanh / &valuutta) * &minf;
%LET PtPuuUusi = (&PtPuuUusi / &valuutta) * &minf;
%LET KellArvo = (&KellArvo / &valuutta) * &minf;
%LET PtVahPieni = (&PtVahPieni / &valuutta) * &minf;
%LET PtVahSuuri = (&PtVahSuuri / &valuutta) * &minf;
%LET PtEiVesi = (&PtEiVesi / &valuutta) * &minf;
%LET PtEiKesk = (&PtEiKesk / &valuutta) * &minf;
%LET PtEiSahko = (&PtEiSahko / &valuutta) * &minf;
%LET VapPerusArvo = (&VapPerusArvo / &valuutta) * &minf;
%LET VapVahPieni = (&VapVahPieni / &valuutta) * &minf;
%LET VapVahSuuri = (&VapVahSuuri / &valuutta) * &minf;
%LET VapLisTalvi = (&VapLisTalvi / &valuutta) * &minf;
%LET VapLisSahko1 = (&VapLisSahko1 / &valuutta) * &minf;
%LET VapLisSahko2 = (&VapLisSahko2 / &valuutta) * &minf;
%LET VapLisViem = (&VapLisViem / &valuutta) * &minf;
%LET VapLisVesi = (&VapLisVesi / &valuutta) * &minf;
%LET VapLisWC = (&VapLisWC / &valuutta) * &minf;
%LET VapLisSauna = (&VapLisSauna / &valuutta) * &minf;

%MEND HaeParam_KiVeroSIMUL;

/* 2.2 T‰m‰ makro tekee saman asian kuin edellinen, mutta se toimii vain osana data-askelta.
       Makro luo useita muuttujia data-taulukkoon. Makroa k‰ytet‰‰n esimerkkilaskelmissa (tyyppi = ESIM).
	   Inflaatio- ja valuuttakurssimuunnokset tehd‰‰n t‰ss‰ vaiheessa */

* Makron parametrit:
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi ;

%MACRO HaeParam_KiVeroESIM (mvuosi, minf)/STORE
DES = 'KIVERO, ESIM: Makro, joka tekee KIVERO-mallin parametreista makromuuttujia, esimerkkilaskelmat';

%IF &TYYPPI = ESIM %THEN %DO;

	%LET valuutta = IFN(&mvuosi < 2002, &euro,  1);	
	IF _N_ = 1 OR taulu_kv = . THEN taulu_kv = OPEN ("PARAM.&PKIVERO" , "i");
	RETAIN taulu_kv;
	X = REWIND(taulu_kv);
	X = FETCHOBS(taulu_kv, 1);
	IF GETVARN(taulu_kv, 1) <= &mvuosi THEN;
	ELSE DO UNTIL (GETVARN(taulu_kv, 1)= &mvuosi OR X = -1);
		X = FETCH(taulu_kv);
	END;
	IF X = -1 THEN DO;
		%LET riveja_kv = ATTRN(taulu_kv, 'NLOBS');
		X = FETCHOBS(taulu_kv, &riveja_kv);
	END;

	%LET PtPerusArvo = (GETVARN(taulu_kv, VARNUM(taulu_kv, 'PtPerusArvo')) / &valuutta) * &minf ;
	%LET PtPuuVanh = (GETVARN(taulu_kv, VARNUM(taulu_kv, 'PtPuuVanh')) / &valuutta) * &minf ;
	%LET PtPuuUusi = (GETVARN(taulu_kv, VARNUM(taulu_kv, 'PtPuuUusi')) / &valuutta) * &minf ;
	%LET KellArvo = (GETVARN(taulu_kv, VARNUM(taulu_kv, 'KellArvo')) / &valuutta) * &minf ;
	%LET PtVahPieni = (GETVARN(taulu_kv, VARNUM(taulu_kv, 'PtVahPieni')) / &valuutta) * &minf ;
	%LET PtVahSuuri = (GETVARN(taulu_kv, VARNUM(taulu_kv, 'PtVahSuuri')) / &valuutta) * &minf ;
	%LET PtEiVesi = (GETVARN(taulu_kv, VARNUM(taulu_kv, 'PtEiVesi')) / &valuutta) * &minf ;
	%LET PtEiKesk = (GETVARN(taulu_kv, VARNUM(taulu_kv, 'PtEiKesk')) / &valuutta) * &minf ;
	%LET PtEiSahko = (GETVARN(taulu_kv, VARNUM(taulu_kv, 'PtEiSahko')) / &valuutta) * &minf ;
	%LET VapPerusArvo = (GETVARN(taulu_kv, VARNUM(taulu_kv, 'VapPerusArvo')) / &valuutta) * &minf ;
	%LET VapVahPieni = (GETVARN(taulu_kv, VARNUM(taulu_kv, 'VapVahPieni')) / &valuutta) * &minf ;
	%LET VapVahSuuri = (GETVARN(taulu_kv, VARNUM(taulu_kv, 'VapVahSuuri')) / &valuutta) * &minf ;
	%LET VapLisTalvi = (GETVARN(taulu_kv, VARNUM(taulu_kv, 'VapLisTalvi')) / &valuutta) * &minf ;
	%LET VapLisSahko1 = (GETVARN(taulu_kv, VARNUM(taulu_kv, 'VapLisSahko1')) / &valuutta) * &minf ;
	%LET VapLisSahko2 = (GETVARN(taulu_kv, VARNUM(taulu_kv, 'VapLisSahko2')) / &valuutta) * &minf ;
	%LET VapLisViem = (GETVARN(taulu_kv, VARNUM(taulu_kv, 'VapLisViem')) / &valuutta) * &minf ;
	%LET VapLisVesi = (GETVARN(taulu_kv, VARNUM(taulu_kv, 'VapLisVesi')) / &valuutta) * &minf ;
	%LET VapLisWC = (GETVARN(taulu_kv, VARNUM(taulu_kv, 'VapLisWC')) / &valuutta) * &minf ;
	%LET VapLisSauna = (GETVARN(taulu_kv, VARNUM(taulu_kv, 'VapLisSauna')) / &valuutta) * &minf ;

	%LET VuosiRaja1	= GETVARN(taulu_kv, VARNUM(taulu_kv, 'VuosiRaja1'));
	%LET VuosiRaja2	= GETVARN(taulu_kv, VARNUM(taulu_kv, 'VuosiRaja2'));
	%LET PtNelioRaja1 = GETVARN(taulu_kv, VARNUM(taulu_kv, 'PtNelioRaja1'));
	%LET PtNelioRaja2 = GETVARN(taulu_kv, VARNUM(taulu_kv, 'PtNelioRaja2'));
	%LET VapNelioRaja1 = GETVARN(taulu_kv, VARNUM(taulu_kv, 'VapNelioRaja1'));
	%LET VapNelioRaja2 = GETVARN(taulu_kv, VARNUM(taulu_kv, 'VapNelioRaja2'));
	%LET IkaAlePuu = GETVARN(taulu_kv, VARNUM(taulu_kv, 'IkaAlePuu'));
	%LET IkaAleKivi	= GETVARN(taulu_kv, VARNUM(taulu_kv, 'IkaAleKivi'));
	%LET IkaVahRaja = GETVARN(taulu_kv, VARNUM(taulu_kv, 'IkaVahRaja'));

%END;

%MEND HaeParam_KiVeroESIM;
