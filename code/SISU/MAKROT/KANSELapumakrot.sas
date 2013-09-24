/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyˆdynt‰‰ Tilastokeskuksen yleisten
* k‰yttˆehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto p‰‰hakemistossa.
******************************************************************************/

/*************************************************************
*  Kuvaus: Kansanel‰kkeen simuloinnin apumakroja         	 * 
*  Tekij‰: Jussi Tervola /KELA                          	 *
*  Luotu: 6.10.2011                                          *
*  Viimeksi p‰ivitetty: 25.9.2012							 * 
*  P‰ivitt‰j‰: Jussi Tervola /KELA                         	 *
**************************************************************/


/* 1. SISƒLLYS */

/* Tiedosto sis‰lt‰‰ seuraavat makrot */

/*
2.1 Haeparam_KansElSIMUL = Makro, joka tekee KANSEL-mallin parametreista makromuuttujia, simulointilaskelmat
2.2 Haeparam_KansElESIM = Makro, joka tekee KANSEL-mallin parametreista makromuuttujia, esimerkkilaskelmat
2.3 Haeparam_KansElSIMULx = Tyhj‰ makro, jolla voidaan korvata lains‰‰d‰ntˆ‰ kuvaavien makrojen sis‰ll‰ oleva parametrien haku
2.4 KuuNro_KansElSIMUL = Kuukausinumeron muodostus, simulointi
2.4 KuuNro_KansElSIMULx = Kuukausinumeron muodostus, simulointi
2.5 KuuNro_KansElESIM = Kuukausinumeron muodostus, esimerkkilaskelmat
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

%MACRO Haeparam_KansElSIMUL (mvuosi, mkuuk, minf)/STORE 
DES = 'KANSEL, SIMUL: Makro, joka tekee KANSEL-mallin parametreista makromuuttujia,
simulointilaskelmat';

%LET valuutta = %SYSFUNC(IFN(&mvuosi < 2002, &euro, 1));
%LET kuuknro = %EVAL((&mvuosi - &paramalkuke) * 12 + &mkuuk);
%LET taulu_ke = %SYSFUNC(OPEN(PARAM.&PKANSEL, i));
%LET w = %SYSFUNC(REWIND(&taulu_ke));
%LET w = %SYSFUNC(FETCHOBS(&taulu_ke, 1));
%LET y = %SYSFUNC(GETVARN(&taulu_ke, 1));
%LET z = %SYSFUNC(GETVARN(&taulu_ke, 2));
%LET testi = %EVAL((&y - &paramalkuke) * 12 + &z);
%IF &testi <= &kuuknro %THEN;
%ELSE %DO %UNTIL ((&testi <= &kuuknro) OR (&testi = 1));
	%LET w = %SYSFUNC(FETCH(&taulu_ke));
	%LET y = %SYSFUNC(GETVARN(&taulu_ke, 1));
	%LET z = %SYSFUNC(GETVARN(&taulu_ke, 2));
	%LET testi = %EVAL((&y - &paramalkuke) * 12 + &z);
%END;
%IF &w = -1 %THEN %DO;
	%LET riveja = %SYSFUNC(ATTRN(&taulu_ke, NLOBS));
	%LET w = %SYSFUNC(FETCHOBS(&taulu_ke, &riveja));
%END;

%LET 	ApuLis = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, ApuLis)))) / &valuutta) * &minf;
%LET 	HoitoLis = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, HoitoLis)))) / &valuutta) * &minf;
%LET 	HoitTukiErit = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, HoitTukiErit)))) / &valuutta) * &minf;
%LET 	HoitTukiKor = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, HoitTukiKor)))) / &valuutta) * &minf;
%LET 	HoitTukiNorm = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, HoitTukiNorm)))) / &valuutta) * &minf;
%LET 	Keliak = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, Keliak)))) / &valuutta) * &minf;
%LET 	LaitosRaja1 = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, LaitosRaja1)))));
%LET 	LaitosRaja2 = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, LaitosRaja2)))));
%LET 	LaitosTaysiP1 = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, LaitosTaysiP1)))) / &valuutta) * &minf;
%LET 	LaitosTaysiP2 = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, LaitosTaysiP2)))) / &valuutta) * &minf;
%LET 	LaitosTaysiY1 = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, LaitosTaysiY1)))) / &valuutta) * &minf;
%LET 	LaitosTaysiY2 = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, LaitosTaysiY2)))) / &valuutta) * &minf;
%LET 	KELaps = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, KELaps)))) / &valuutta) * &minf;
%LET 	KEMinimi = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, KEMinimi)))) / &valuutta) * &minf;
%LET 	KEPros = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, KEPros)))));
%LET 	KERaja = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, KERaja)))) / &valuutta) * &minf;
%LET 	LapsHoitTukErit = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, LapsHoitTukErit)))) / &valuutta) * &minf;
%LET 	LapsHoitTukKorot = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, LapsHoitTukKorot)))) / &valuutta) * &minf;
%LET 	LapsHoitTukNorm = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, LapsHoitTukNorm)))) / &valuutta) * &minf;
%LET 	LeskAlku = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, LeskAlku)))) / &valuutta) * &minf;
%LET 	LeskAlkuMinimi1 = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, LeskAlkuMinimi1)))));
%LET 	LeskAlkuMinimi2 = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, LeskAlkuMinimi2)))));
%LET 	LeskTaydP1 = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, LeskTaydP1)))) / &valuutta) * &minf;
%LET 	LeskTaydP2 = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, LeskTaydP2)))) / &valuutta) * &minf;
%LET 	LeskTaydY1 = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, LeskTaydY1)))) / &valuutta) * &minf;
%LET 	LeskTaydY2 = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, LeskTaydY2)))) / &valuutta) * &minf;
%LET 	LeskMinimi = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, LeskMinimi)))) / &valuutta) * &minf;
%LET 	LeskPerus = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, LeskPerus)))) / &valuutta) * &minf;
%LET 	LeskTyoTuloOsuus = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, LeskTyoTuloOsuus)))));
%LET 	LapsElMinimi = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, LapsElMinimi)))) / &valuutta) * &minf;
%LET 	LapsElPerus = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, LapsElPerus)))) / &valuutta) * &minf;
%LET 	LapsElTayd = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, LapsElTayd)))) / &valuutta) * &minf;
%LET 	PerhElOmPros = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, PerhElOmPros)))));
%LET 	PerhElOmRaja = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, PerhElOmRaja)))) / &valuutta) * &minf;
%LET 	PerPohja = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, PerPohja)))) / &valuutta) * &minf;
%LET 	PohjRajaP1 = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, PohjRajaP1)))) / &valuutta) * &minf;
%LET 	PohjRajaP2 = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, PohjRajaP2)))) / &valuutta) * &minf;
%LET 	PohjRajaY1 = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, PohjRajaY1)))) / &valuutta) * &minf;
%LET 	PohjRajaY2 = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, PohjRajaY2)))) / &valuutta) * &minf;
%LET 	PuolAlenn = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, PuolAlenn)))));
%LET 	RiLi = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, RiLi)))) / &valuutta) * &minf;
%LET 	TakuuEl = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, TakuuEl)))) / &valuutta) * &minf;
%LET 	TaysKEP1 = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, TaysKEP1)))) / &valuutta) * &minf;
%LET 	TaysKEP2 = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, TaysKEP2)))) / &valuutta) * &minf;
%LET 	TaysKEY1 = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, TaysKEY1)))) / &valuutta) * &minf;
%LET 	TaysKEY2 = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, TaysKEY2)))) / &valuutta) * &minf;
%LET 	TukiLisPP = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, TukiLisPP)))) / &valuutta) * &minf;
%LET 	TukiLisY = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, TukiLisY)))) / &valuutta) * &minf;
%LET 	TukOsP1 = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, TukOsP1)))) / &valuutta) * &minf;
%LET 	TukOsP2 = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, TukOsP2)))) / &valuutta) * &minf;
%LET 	TukOsY1 = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, TukOsY1)))) / &valuutta) * &minf;
%LET 	TukOsY2 = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, TukOsY2)))) / &valuutta) * &minf;
%LET 	TukOsY3 = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, TukOsY3)))) / &valuutta) * &minf;
%LET 	PuolisoLis = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, PuolisoLis)))) / &valuutta) * &minf;
%LET 	VammErit = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, VammErit)))) / &valuutta) * &minf;
%LET 	VammKorot = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, VammKorot)))) / &valuutta) * &minf;
%LET 	VammNorm = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, VammNorm)))) / &valuutta) * &minf;
%LET 	VeterLisa = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, VeterLisa)))) / &valuutta) * &minf;
%LET 	YliRiliAskel = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, YliRiliAskel)))) / &valuutta) * &minf;
%LET 	YliRiliAskel2 = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, YliRiliAskel2)))) / &valuutta) * &minf;
%LET 	YliRiliMinimi = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, YliRiliMinimi)))) / &valuutta) * &minf;
%LET 	YliRiliPros = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, YliRiliPros)))));
%LET 	YliRiliPros2 = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, YliRiliPros2)))));
%LET 	YliRiliRaja = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, YliRiliRaja)))) / &valuutta) * &minf;
%LET 	SotAvMinimi = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, SotAvMinimi)))) / &valuutta) * &minf;
%LET 	SotAvPros1 = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, SotAvPros1)))));
%LET 	SotAvPros2 = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, SotAvPros2)))));
%LET 	SotAvPros3 = (%SYSFUNC(GETVARN(&taulu_ke, %SYSFUNC(VARNUM(&taulu_ke, SotAvPros3)))));
%LET loppu = %SYSFUNC(CLOSE(&taulu_ke));

%MEND Haeparam_KansElSIMUL;

/* 2.2 T‰m‰ makro tekee saman asian kuin edellinen, mutta se toimii vain osana data-askelta.
       Makro luo useita muuttujia data-taulukkoon. Makroa k‰ytet‰‰n esimerkkilaskelmissa (tyyppi = ESIM).
	   Inflaatio- ja valuuttakurssimuunnokset tehd‰‰n t‰ss‰ vaiheessa */

* Makron parametrit:
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi ;

%MACRO Haeparam_KansElESIM (mvuosi, mkuuk, minf)/STORE 
DES = 'KANSEL, ESIM: Makro, joka tekee KANSEL-mallin parametreista makromuuttujia,
esimerkkilaskelmat';

%LET valuutta = IFN(&mvuosi < 2002, &euro,  1);
kuuknro = (&mvuosi - &paramalkuke) * 12 + &mkuuk;
IF _N_ = 1 OR taulu_ke =. THEN taulu_ke = OPEN("PARAM.&PKANSEL", "i");
RETAIN taulu_ke;
w = REWIND(taulu_ke);
w = FETCHOBS(taulu_ke, 1);
y = GETVARN(taulu_ke, 1);
z = GETVARN(taulu_ke, 2);
testi = (y - &paramalkuke) * 12 + z;
IF testi <= kuuknro THEN;
ELSE DO UNTIL (testi <= kuuknro);
	w = FETCH(taulu_ke);
	y = GETVARN(taulu_ke, 1);
	z = GETVARN(taulu_ke, 2);
	testi = (y - &paramalkuke) * 12 + z;
END;
IF w = -1 THEN DO;
	%LET riveja = ATTRN(taulu_ke, "NLOBS");
	w = FETCHOBS(taulu_ke, &riveja);
END;

%LET 	ApuLis = (GETVARN(taulu_ke, VARNUM(taulu_ke, "ApuLis")) / &valuutta) * &minf;
%LET 	HoitoLis = (GETVARN(taulu_ke, VARNUM(taulu_ke, "HoitoLis")) / &valuutta) * &minf;
%LET 	HoitTukiErit = (GETVARN(taulu_ke, VARNUM(taulu_ke, "HoitTukiErit")) / &valuutta) * &minf;
%LET 	HoitTukiKor = (GETVARN(taulu_ke, VARNUM(taulu_ke, "HoitTukiKor")) / &valuutta) * &minf;
%LET 	HoitTukiNorm = (GETVARN(taulu_ke, VARNUM(taulu_ke, "HoitTukiNorm")) / &valuutta) * &minf;
%LET 	Keliak = (GETVARN(taulu_ke, VARNUM(taulu_ke, "Keliak")) / &valuutta) * &minf;
%LET 	KEMinimi = (GETVARN(taulu_ke, VARNUM(taulu_ke, "KEMinimi")) / &valuutta) * &minf;
%LET 	Laitosraja1 = GETVARN(taulu_ke, VARNUM(taulu_ke, "Laitosraja1"));
%LET 	Laitosraja2 = GETVARN(taulu_ke, VARNUM(taulu_ke, "Laitosraja2"));
%LET 	LaitosTaysiP1 = (GETVARN(taulu_ke, VARNUM(taulu_ke, "LaitosTaysiP1")) / &valuutta) * &minf;
%LET 	LaitosTaysiP2 = (GETVARN(taulu_ke, VARNUM(taulu_ke, "LaitosTaysiP2")) / &valuutta) * &minf;
%LET 	LaitosTaysiY1 = (GETVARN(taulu_ke, VARNUM(taulu_ke, "LaitosTaysiY1")) / &valuutta) * &minf;
%LET 	LaitosTaysiY2 = (GETVARN(taulu_ke, VARNUM(taulu_ke, "LaitosTaysiY2")) / &valuutta) * &minf;
%LET 	KELaps = (GETVARN(taulu_ke, VARNUM(taulu_ke, "KELaps")) / &valuutta) * &minf;
%LET 	LapsHoitTukErit = (GETVARN(taulu_ke, VARNUM(taulu_ke, "LapsHoitTukErit")) / &valuutta) * &minf;
%LET 	LapsHoitTukKorot = (GETVARN(taulu_ke, VARNUM(taulu_ke, "LapsHoitTukKorot")) / &valuutta) * &minf;
%LET 	LapsHoitTukNorm = (GETVARN(taulu_ke, VARNUM(taulu_ke, "LapsHoitTukNorm")) / &valuutta) * &minf;
%LET 	LeikPohja = (GETVARN(taulu_ke, VARNUM(taulu_ke, "LeikPohja")) / &valuutta) * &minf;
%LET 	LeskAlku = (GETVARN(taulu_ke, VARNUM(taulu_ke, "LeskAlku")) / &valuutta) * &minf;
%LET 	LeskAlkuMinimi1 = GETVARN(taulu_ke, VARNUM(taulu_ke, "LeskAlkuMinimi1"));
%LET 	LeskAlkuMinimi2 = GETVARN(taulu_ke, VARNUM(taulu_ke, "LeskAlkuMinimi2"));
%LET 	LeskTaydP1 = (GETVARN(taulu_ke, VARNUM(taulu_ke, "LeskTaydP1")) / &valuutta) * &minf;
%LET 	LeskTaydP2 = (GETVARN(taulu_ke, VARNUM(taulu_ke, "LeskTaydP2")) / &valuutta) * &minf;
%LET 	LeskTaydY1 = (GETVARN(taulu_ke, VARNUM(taulu_ke, "LeskTaydY1")) / &valuutta) * &minf;
%LET 	LeskTaydY2 = (GETVARN(taulu_ke, VARNUM(taulu_ke, "LeskTaydY2")) / &valuutta) * &minf;
%LET 	LeskMinimi = (GETVARN(taulu_ke, VARNUM(taulu_ke, "LeskMinimi")) / &valuutta) * &minf;
%LET 	LeskPerus = (GETVARN(taulu_ke, VARNUM(taulu_ke, "LeskPerus")) / &valuutta) * &minf;
%LET 	LeskTyoTuloOsuus = GETVARN(taulu_ke, VARNUM(taulu_ke, "LeskTyoTuloOsuus"));
%LET 	KERaja = (GETVARN(taulu_ke, VARNUM(taulu_ke, "KERaja")) / &valuutta) * &minf;
%LET 	LapsElMinimi = (GETVARN(taulu_ke, VARNUM(taulu_ke, "LapsElMinimi")) / &valuutta) * &minf;
%LET 	LapsElPerus = (GETVARN(taulu_ke, VARNUM(taulu_ke, "LapsElPerus")) / &valuutta) * &minf;
%LET 	LapsElTayd = (GETVARN(taulu_ke, VARNUM(taulu_ke, "LapsElTayd")) / &valuutta) * &minf;
%LET 	PerhElOmPros = GETVARN(taulu_ke, VARNUM(taulu_ke, "PerhElOmPros"));
%LET 	PerhElOmRaja = (GETVARN(taulu_ke, VARNUM(taulu_ke, "PerhElOmRaja")) / &valuutta) * &minf;
%LET 	PerPohja = (GETVARN(taulu_ke, VARNUM(taulu_ke, "PerPohja")) / &valuutta) * &minf;
%LET 	PohjRajaP1 = (GETVARN(taulu_ke, VARNUM(taulu_ke, "PohjRajaP1")) / &valuutta) * &minf;
%LET 	PohjRajaP2 = (GETVARN(taulu_ke, VARNUM(taulu_ke, "PohjRajaP2")) / &valuutta) * &minf;
%LET 	PohjRajaY1 = (GETVARN(taulu_ke, VARNUM(taulu_ke, "PohjRajaY1")) / &valuutta) * &minf;
%LET 	PohjRajaY2 = (GETVARN(taulu_ke, VARNUM(taulu_ke, "PohjRajaY2")) / &valuutta) * &minf;
%LET 	PuolAlenn = GETVARN(taulu_ke, VARNUM(taulu_ke, "PuolAlenn"));
%LET 	RiLi = (GETVARN(taulu_ke, VARNUM(taulu_ke, "RiLi")) / &valuutta) * &minf;
%LET 	TakuuEl = (GETVARN(taulu_ke, VARNUM(taulu_ke, "TakuuEl")) / &valuutta) * &minf;
%LET 	TaysKEP1 = (GETVARN(taulu_ke, VARNUM(taulu_ke, "TaysKEP1")) / &valuutta) * &minf;
%LET 	TaysKEP2 = (GETVARN(taulu_ke, VARNUM(taulu_ke, "TaysKEP2")) / &valuutta) * &minf;
%LET 	TaysKEY1 = (GETVARN(taulu_ke, VARNUM(taulu_ke, "TaysKEY1")) / &valuutta) * &minf;
%LET 	TaysKEY2 = (GETVARN(taulu_ke, VARNUM(taulu_ke, "TaysKEY2")) / &valuutta) * &minf;
%LET 	KEPros = GETVARN(taulu_ke, VARNUM(taulu_ke, "KEPros"));
%LET 	TukiLisPP = (GETVARN(taulu_ke, VARNUM(taulu_ke, "TukiLisPP")) / &valuutta) * &minf;
%LET 	TukiLisY = (GETVARN(taulu_ke, VARNUM(taulu_ke, "TukiLisY")) / &valuutta) * &minf;
%LET 	TukOsP1 = (GETVARN(taulu_ke, VARNUM(taulu_ke, "TukOsP1")) / &valuutta) * &minf;
%LET 	TukOsP2 = (GETVARN(taulu_ke, VARNUM(taulu_ke, "TukOsP2")) / &valuutta) * &minf;
%LET 	TukOsY1 = (GETVARN(taulu_ke, VARNUM(taulu_ke, "TukOsY1")) / &valuutta) * &minf;
%LET 	TukOsY2 = (GETVARN(taulu_ke, VARNUM(taulu_ke, "TukOsY2")) / &valuutta) * &minf;
%LET 	TukOsY3 = (GETVARN(taulu_ke, VARNUM(taulu_ke, "TukOsY3")) / &valuutta) * &minf;
%LET 	PuolisoLis = (GETVARN(taulu_ke, VARNUM(taulu_ke, "PuolisoLis")) / &valuutta) * &minf;
%LET 	VammErit = (GETVARN(taulu_ke, VARNUM(taulu_ke, "VammErit")) / &valuutta) * &minf;
%LET 	VammKorot = (GETVARN(taulu_ke, VARNUM(taulu_ke, "VammKorot")) / &valuutta) * &minf;
%LET 	VammNorm = (GETVARN(taulu_ke, VARNUM(taulu_ke, "VammNorm")) / &valuutta) * &minf;
%LET 	VeterLisa = (GETVARN(taulu_ke, VARNUM(taulu_ke, "VeterLisa")) / &valuutta) * &minf;
%LET 	YliRiliAskel = (GETVARN(taulu_ke, VARNUM(taulu_ke, "YliRiliAskel")) / &valuutta) * &minf;
%LET 	YliRiliAskel2 = (GETVARN(taulu_ke, VARNUM(taulu_ke, "YliRiliAskel2")) / &valuutta) * &minf;
%LET 	YliRiliMinimi = (GETVARN(taulu_ke, VARNUM(taulu_ke, "YliRiliMinimi")) / &valuutta) * &minf;
%LET 	YliRiliPros = GETVARN(taulu_ke, VARNUM(taulu_ke, "YliRiliPros"));
%LET 	YliRiliPros2 = GETVARN(taulu_ke, VARNUM(taulu_ke, "YliRiliPros2"));
%LET 	YliRiliRaja = (GETVARN(taulu_ke, VARNUM(taulu_ke, "YliRiliRaja")) / &valuutta) * &minf;
%LET 	SotAvMinimi = (GETVARN(taulu_ke, VARNUM(taulu_ke, "SotAvMinimi")) / &valuutta) * &minf;
%LET 	SotAvPros1 = GETVARN(taulu_ke, VARNUM(taulu_ke, "SotAvPros1"));
%LET 	SotAvPros2 = GETVARN(taulu_ke, VARNUM(taulu_ke, "SotAvPros2"));
%LET 	SotAvPros3 = GETVARN(taulu_ke, VARNUM(taulu_ke, "SotAvPros3"));

%MEND Haeparam_KansElESIM;

/* 2.3 Tyhj‰ makro, jolla voidaan korvata lains‰‰d‰ntˆ‰ kuvaavien
	   makrojen sis‰ll‰ oleva parametrien haku, jos parametrit on m‰‰ritelty
	   ennen simulointiohjelman ajoa. K‰ytet‰‰n, jos halutaan k‰ytt‰‰ vuosikeskiarvon laskemisessa tietyn 
	   kuukauden lains‰‰d‰ntˆ‰ (tyyppi = SIMULx). */

* Makron parametrit:
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi ;

%MACRO Haeparam_KansElSIMULx (mvuosi, mkuuk, minf)/STORE 
DES = 'KANSEL, SIMULx: Tyhj‰ makro, jolla voidaan korvata lains‰‰d‰ntˆ‰ kuvaavien makrojen sis‰ll‰ oleva parametrien haku';
%MEND Haeparam_KansElSIMULx;


/* 2.4 Makro, jolla vuosiluvusta ja kuukauden numerosta johdetaan j‰rjestysluku ajankohtien vertailua varten.
       Jos tarjotaan parametritaulukon l‰htˆvuotta aikaisempaa arvoa, valitaan ensimm‰inen mahdollinen kuukausi.
	   Makroa k‰ytet‰‰n varsinaisissa simulointilaskelmissa */

* Makron parametrit:
	nro: Makron tulosmuuttuja, ajankohdan (vuosi ja kuukausi) j‰rjestysluku 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n ;

%MACRO KuuNro_KansElSIMUL (nro, mvuosi, mkuuk)/STORE 
DES = 'KANSEL, SIMUL: Kuukausinumeron muodostus, simulointi';

&nro = 12 * %EVAL (&mvuosi - &paramalkuke) + &mkuuk;
%IF &mvuosi < &paramalkuke %THEN &nro = 1;
%MEND KuuNro_KansElSIMUL;


%MACRO KuuNro_KansElSIMULx (nro, mvuosi, mkuuk)/STORE 
DES = 'KANSEL, SIMULx: Kuukausinumeron muodostus, simulointi';

&nro = 12 * %EVAL (&mvuosi - &paramalkuke) + &mkuuk;
%IF &mvuosi < &paramalkuke %THEN &nro = 1;
%MEND KuuNro_KansElSIMULx;

/* 2.5 Edellisest‰ makrosta versio, joka toimii vain osana data-askelta. Makroa k‰ytet‰‰n esimerkkilaskelmissa. */

%MACRO KuuNro_KansElESIM (nro, mvuosi, mkuuk)/STORE 
DES = 'KANSEL, ESIM: Kuukausinumeron muodostus, esimerkkilaskelmat';

&nro = 12 * (&mvuosi - &paramalkuke) + &mkuuk;
IF &mvuosi < &paramalkuke THEN &nro = 1;
%MEND KuuNro_KansElESIM;
