/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyˆdynt‰‰ Tilastokeskuksen yleisten
* k‰yttˆehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto p‰‰hakemistossa.
******************************************************************************/

/***************************************************************
* Kuvaus: El‰kkeensaajan asumistuen simuloinnin apumakroja 	   *
* Tekij‰: Petri Eskelinen / KELA							   * 
* Luotu: 11.8.2011											   *
* Viimeksi p‰ivitetty: 9.1.2012								   *
* P‰ivitt‰j‰: Olli Kannas / TK							   	   *
****************************************************************/


/* 1. SISƒLLYS */

/* Tiedosto sis‰lt‰‰ seuraavat makrot */

/*
2.1 HaeParam_ElAsumTukiSIMUL = Makro, joka tekee ELASUMTUKI-mallin parametreista makromuuttujia, simulointilaskelmat
2.2 HaeParam_ElAsumTukiESIM = Makro, joka tekee ELASUMTUKI-mallin parametreista makromuuttujia, esimerkkilaskelmat
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

%MACRO HaeParam_ElAsumTukiSIMUL (mvuosi, minf)/STORE
DES = 'ELASUMTUKI, SIMUL: Makro, joka tekee ELASUMTUKI-mallin parametreista makromuuttujia, simulointilaskelmat';

%LET valuutta = %SYSFUNC(IFN(&mvuosi < 2002, &euro, 1));
%LET taulu_ea = %SYSFUNC(OPEN(PARAM.&PELASUMTUKI, i));
%SYSCALL SET(taulu_ea);
%LET w = %SYSFUNC(FETCH(&taulu_ea));
%IF &mvuosi >= %SYSFUNC(GETVARN(&taulu_ea, 1)) %THEN;
%ELSE %DO %UNTIL (%SYSFUNC(GETVARN(&taulu_ea, 1)) = &mvuosi OR &w = -1);
	%LET w = %SYSFUNC(FETCH(&taulu_ea));
%END;
%LET w = %SYSFUNC(CLOSE(&taulu_ea));

%LET EPieninTuki = (&EPieninTuki / &valuutta) * &minf;
%LET PerusOVast = (&PerusOVast / &valuutta) * &minf;
%LET LisOVRaja = (&LisOVRaja / &valuutta) * &minf;
%LET LisOVRaja2 = (&LisOVRaja2 / &valuutta) * &minf;
%LET LisOVRaja3 = (&LisOVRaja3 / &valuutta) * &minf;
%LET LisOVRaja4 = (&LisOVRaja4 / &valuutta) * &minf;
%LET LisOVRaja5 = (&LisOVRaja5 / &valuutta) * &minf;
%LET RintSotVah = (&RintSotVah / &valuutta) * &minf;
%LET OmRaja = (&OmRaja / &valuutta) * &minf;
%LET OmRaja2 = (&OmRaja2 / &valuutta) * &minf;
%LET Lamm1 = (&Lamm1 / &valuutta) * &minf;
%LET Lamm2 = (&Lamm2 / &valuutta) * &minf;
%LET Lamm3 = (&Lamm3 / &valuutta) * &minf;
%LET MuuLamm1 = (&MuuLamm1 / &valuutta) * &minf;
%LET MuuLamm2 = (&MuuLamm2 / &valuutta) * &minf;
%LET MuuLamm3 = (&MuuLamm3 / &valuutta) * &minf;
%LET Vesi1 = (&Vesi1 / &valuutta) * &minf;
%LET Vesi2 = (&Vesi2 / &valuutta) * &minf;
%LET KunnPito = (&KunnPito / &valuutta) * &minf;
%LET Enimm1 = (&Enimm1 / &valuutta) * &minf;
%LET Enimm2 = (&Enimm2 / &valuutta) * &minf;
%LET Enimm3 = (&Enimm3 / &valuutta) * &minf;
%LET Enimm4 = (&Enimm4 / &valuutta) * &minf;

%MEND HaeParam_ElAsumTukiSIMUL;

/* 2.2 T‰m‰ makro tekee saman asian kuin edellinen, mutta se toimii vain osana data-askelta.
       Makro luo useita muuttujia data-taulukkoon. Makroa k‰ytet‰‰n esimerkkilaskelmissa (tyyppi = ESIM).
	   Inflaatio- ja valuuttakurssimuunnokset tehd‰‰n t‰ss‰ vaiheessa */

* Makron parametrit:
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi ;

%MACRO HaeParam_ElAsumTukiESIM (mvuosi, minf)/STORE
DES = 'ELASUMTUKI, ESIM: Makro, joka tekee ELASUMTUKI-mallin parametreista makromuuttujia, esimerkkilaskelmat';

%IF &TYYPPI = ESIM %THEN %DO;

	%LET valuutta = IFN(&mvuosi < 2002, &euro,  1);	
	IF _N_ = 1 OR taulu_ea =. THEN taulu_ea = OPEN ("PARAM.&PELASUMTUKI", "i");
	RETAIN taulu_ea;
	X = REWIND(taulu_ea);
	X = FETCHOBS(taulu_ea, 1);
	IF GETVARN(taulu_ea, 1) <= &mvuosi THEN;
	ELSE DO UNTIL (GETVARN(taulu_ea, 1) = &mvuosi OR X = -1);
		X = FETCH(taulu_ea);
	END;
	IF X = -1 THEN DO;
		%LET riveja = ATTRN(taulu_ea, "NLOBS");
		X = FETCHOBS(taulu_ea, &riveja);
	END;

	%LET ETukiPros = GETVARN(taulu_ea, VARNUM(taulu_ea, 'ETukiPros'));
	%LET LisOVastPros = GETVARN(taulu_ea, VARNUM(taulu_ea, 'LisOVastPros'));
	%LET OmPros = GETVARN(taulu_ea, VARNUM(taulu_ea, 'OmPros'));
	%LET Kor1974 = GETVARN(taulu_ea, VARNUM(taulu_ea, 'Kor1974'));
	%LET YksRaja = GETVARN(taulu_ea, VARNUM(taulu_ea, 'YksRaja'));
	%LET PerhRaja = GETVARN(taulu_ea, VARNUM(taulu_ea, 'PerhRaja'));
	%LET LapsiKor1 = GETVARN(taulu_ea, VARNUM(taulu_ea, 'LapsiKor1')) ;
	%LET LapsiKor2 = GETVARN(taulu_ea, VARNUM(taulu_ea, 'LapsiKor2')) ;
	%LET EPieninTuki = (GETVARN(taulu_ea, VARNUM(taulu_ea, 'EPieninTuki')) / &valuutta) * &minf;
	%LET PerusOVast = (GETVARN(taulu_ea, VARNUM(taulu_ea, 'PerusOVast')) / &valuutta) * &minf ;
	%LET LisOVRaja = (GETVARN(taulu_ea, VARNUM(taulu_ea, 'LisOVRaja')) / &valuutta) * &minf ;
	%LET LisOVRaja2 = (GETVARN(taulu_ea, VARNUM(taulu_ea, 'LisOVRaja2')) / &valuutta) * &minf ;
	%LET LisOVRaja3 = (GETVARN(taulu_ea, VARNUM(taulu_ea, 'LisOVRaja3')) / &valuutta) * &minf ;
	%LET LisOVRaja4 = (GETVARN(taulu_ea, VARNUM(taulu_ea, 'LisOVRaja4')) / &valuutta) * &minf ;
	%LET LisOVRaja5 = (GETVARN(taulu_ea, VARNUM(taulu_ea, 'LisOVRaja5')) / &valuutta) * &minf ;
	%LET RintSotVah = (GETVARN(taulu_ea, VARNUM(taulu_ea, 'RintSotVah')) / &valuutta) * &minf ;
	%LET OmRaja = (GETVARN(taulu_ea, VARNUM(taulu_ea, 'OmRaja')) / &valuutta) * &minf ;
	%LET OmRaja2 = (GETVARN(taulu_ea, VARNUM(taulu_ea, 'OmRaja2')) / &valuutta) * &minf ;
	%LET Lamm1 = (GETVARN(taulu_ea, VARNUM(taulu_ea, 'Lamm1')) / &valuutta) * &minf ;
	%LET Lamm2 = (GETVARN(taulu_ea, VARNUM(taulu_ea, 'Lamm2')) / &valuutta) * &minf ;
	%LET Lamm3 = (GETVARN(taulu_ea, VARNUM(taulu_ea, 'Lamm3')) / &valuutta) * &minf ;
	%LET MuuLamm1 = (GETVARN(taulu_ea, VARNUM(taulu_ea, 'MuuLamm1')) / &valuutta) * &minf;
	%LET MuuLamm2 = (GETVARN(taulu_ea, VARNUM(taulu_ea, 'MuuLamm2')) / &valuutta) * &minf ;
	%LET MuuLamm3 = (GETVARN(taulu_ea, VARNUM(taulu_ea, 'MuuLamm3')) / &valuutta) * &minf ;
	%LET Vesi1 = (GETVARN(taulu_ea, VARNUM(taulu_ea, 'Vesi1')) / &valuutta) * &minf ;
	%LET Vesi2 = (GETVARN(taulu_ea, VARNUM(taulu_ea, 'Vesi2')) / &valuutta) * &minf ;
	%LET KunnPito = (GETVARN(taulu_ea, VARNUM(taulu_ea, 'KunnPito')) / &valuutta) * &minf ;
	%LET Enimm1 = (GETVARN(taulu_ea, VARNUM(taulu_ea, 'Enimm1')) / &valuutta) * &minf ;
	%LET Enimm2 = (GETVARN(taulu_ea, VARNUM(taulu_ea, 'Enimm2')) / &valuutta) * &minf ;
	%LET Enimm3 = (GETVARN(taulu_ea, VARNUM(taulu_ea, 'Enimm3')) / &valuutta) * &minf ;
	%LET Enimm4 = (GETVARN(taulu_ea, VARNUM(taulu_ea, 'Enimm4')) / &valuutta) * &minf ;

%END;

%MEND HaeParam_ElAsumTukiESIM;


