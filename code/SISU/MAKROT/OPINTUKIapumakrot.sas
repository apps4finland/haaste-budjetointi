/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyˆdynt‰‰ Tilastokeskuksen yleisten
* k‰yttˆehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto p‰‰hakemistossa.
******************************************************************************/

/*************************************************************
*  Kuvaus: Opintotuen simuloinnin apumakroja         		 * 
*  Tekij‰: Olli Kannas / TK                              	 *
*  Luotu: 27.09.2011                                         *
*  Viimeksi p‰ivitetty: 4.1.2012							 * 
*  P‰ivitt‰j‰: Olli Kannas / TK                         	 *
**************************************************************/


/* 1. SISƒLLYS */

/* Tiedosto sis‰lt‰‰ seuraavat makrot */

/*
2.1 HaeParam_OpinTukiSIMUL = Makro, joka tekee OPINTUKI-mallin parametreista makromuuttujia, simulointilaskelmat
2.2 HaeParam_OpinTukiESIM = Makro, joka tekee OPINTUKI-mallin parametreista makromuuttujia, esimerkkilaskelmat
2.3 HaeParam_OpinTukiSIMULx = Tyhj‰ makro, jolla voidaan korvata lains‰‰d‰ntˆ‰ kuvaavien makrojen sis‰ll‰ oleva parametrien haku
2.4 KuuNro_OpinTukiSIMUL = Kuukausinumeron muodostus, simulointi
2.4 KuuNro_OpinTukiSIMULx = Kuukausinumeron muodostus, simulointi
2.5 KuuNro_OpinTukiESIM = Kuukausinumeron muodostus, esimerkkilaskelmat
3.1 IkaKuuk_OpinTuki = Makro, joka laskee ne kuukaudet, jolloin henkilˆ on tietyll‰ ik‰v‰lill‰ tarkasteluvuoden aikana
3.2 TukiKuuk = Makro p‰‰ttelee opintotukikuukaudet vertaamalla todella maksettua opintotukea lains‰‰d‰nnˆn takaamaan
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

%MACRO HaeParam_OpinTukiSIMUL (mvuosi, mkuuk, minf)/STORE
DES = 'OPINTUKI, SIMUL: Makro, joka tekee OPINTUKI-mallin parametreista makromuuttujia, simulointilaskelmat';

%LET valuutta = %SYSFUNC(IFN(&mvuosi < 2002, &euro, 1));
%LET kuuknro = %EVAL((&mvuosi - &paramalkuot) * 12 + &mkuuk);
%LET alku_ot = 7;
%LET taulu_ot = %SYSFUNC(OPEN(PARAM.&POPINTUKI, i));
%LET w = %SYSFUNC(REWIND(&taulu_ot));
%LET w = %SYSFUNC(FETCHOBS(&taulu_ot, 1));
%LET y = %SYSFUNC(GETVARN(&taulu_ot, 1));
%LET z = %SYSFUNC(GETVARN(&taulu_ot, 2));
%LET testi = %EVAL((&y - &paramalkuot) * 12 + &z);
%IF &testi <= &kuuknro %THEN;
%ELSE %DO %UNTIL ((&testi <= &kuuknro) OR &testi = &alku_ot);
	%LET w = %SYSFUNC(FETCH(&taulu_ot));
	%LET y = %SYSFUNC(GETVARN(&taulu_ot, 1));
	%LET z = %SYSFUNC(GETVARN(&taulu_ot, 2));
	%LET testi = %EVAL((&y - &paramalkuot) * 12 + &z);
%END;
%IF &w = -1 %THEN %DO;
	%LET riveja = %SYSFUNC(ATTRN(&taulu_ot, NLOBS));
	%LET w = %SYSFUNC(FETCHOBS(&taulu_ot, &riveja));
%END;

%LET ORaja1 = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, ORaja1)))));
%LET ORaja2 = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, ORaja2)))));
%LET ORaja3 = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, ORaja3)))));
%LET KorkVanh20 = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, KorkVanh20)))) / &valuutta) * &minf;
%LET KorkVanhAlle20 = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, KorkVanhAlle20)))) / &valuutta) * &minf;
%LET KorkMuu20 = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, KorkMuu20)))) / &valuutta) * &minf;
%LET KorkMuuAlle20 = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, KorkMuuAlle20)))) / &valuutta) * &minf;
%LET MuuVanh20 = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, MuuVanh20)))) / &valuutta) * &minf;
%LET MuuVanhAlle20 = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, MuuVanhAlle20)))) / &valuutta) * &minf;
%LET MuuMuu20 = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, MuuMuu20)))) / &valuutta) * &minf;
%LET MuuMuuAlle20 = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, MuuMuuAlle20)))) / &valuutta) * &minf;
%LET VuokraKatto = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, VuokraKatto)))) / &valuutta) * &minf;
%LET VuokraRaja = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, VuokraRaja)))) / &valuutta) * &minf;
%LET VuokraMinimi = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, VuokraMinimi)))) / &valuutta) * &minf;
%LET AsLisaPros = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, AsLisaPros)))));
%LET AsLisaPerus = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, AsLisaPerus)))) / &valuutta) * &minf;
%LET AsLisaTuloRaja = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, AsLisaTuloRaja)))) / &valuutta) * &minf;
%LET AsLisavahPros = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, AsLisavahPros)))));
%LET AsLisaVanhKynnys = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, AsLisaVanhKynnys)))) / &valuutta) * &minf;
%LET AsLisaPuolTuloRaja = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, AsLisaPuolTuloRaja)))) / &valuutta) * &minf;
%LET AsLisaPuolvahPros = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, AsLisaPuolvahPros)))));
%LET AsLisaPuolTuloKynnys = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, AsLisaPuolTuloKynnys)))) / &valuutta) * &minf;
%LET VanhTuloRaja = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, VanhTuloRaja)))) / &valuutta) * &minf;
%LET VanhKynnys = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, VanhKynnys)))) / &valuutta) * &minf;
%LET VanhPros = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, VanhPros)))));
%LET VanhTuloYlaRaja = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, VanhTuloYlaRaja)))) / &valuutta) * &minf;
%LET SisarAlennus = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, SisarAlennus)))) / &valuutta) * &minf;
%LET AikOpPros = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, AikOpPros)))));
%LET AikOpAlaRaja = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, AikOpAlaRaja)))) / &valuutta) * &minf;
%LET AikOpYlaRaja = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, AikOpYlaRaja)))) / &valuutta) * &minf;
%LET OpTuloRaja = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, OpTuloRaja)))) / &valuutta) * &minf;
%LET OpTulovahPros = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, OpTulovahPros)))));
%LET OpTuloVahKynnys = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, OpTuloVahKynnys )))) / &valuutta) * &minf;
%LET VanhVarRaja = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, VanhVarRaja)))) / &valuutta) * &minf;
%LET VanhVarPros = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, VanhVarPros)))));
%LET VanhTuloRaja2 = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, VanhTuloRaja2)))) / &valuutta) * &minf;
%LET VanhTuloRaja2Kynnys = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, VanhTuloRaja2Kynnys)))) / &valuutta) * &minf;
%LET VanhTuloPros2 = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, VanhTuloPros2)))));
%LET KorkVanh20b = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, KorkVanh20b)))) / &valuutta) * &minf;
%LET KorkVanhAlle20b = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, KorkVanhAlle20b)))) / &valuutta) * &minf;
%LET KorkMuuAlle20b = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, KorkMuuAlle20b)))) / &valuutta) * &minf;
%LET MuuVanh20b = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, MuuVanh20b)))) / &valuutta) * &minf;
%LET MuuVanhAlle20b = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, MuuVanhAlle20b)))) / &valuutta) * &minf;
%LET MuuMuuAlle20b = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, MuuMuuAlle20b)))) / &valuutta) * &minf;
%LET OpTuloRaja2 = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, OpTuloRaja2)))) / &valuutta) * &minf;
%LET AikKoulPerus = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, AikKoulPerus)))) / &valuutta) * &minf;
%LET AikKoulTuloRaja = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, AikKoulTuloRaja)))) / &valuutta) * &minf;
%LET AikKoulPros1 = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, AikKoulPros1)))));
%LET AikKoulPros2 = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, AikKoulPros2)))));
%LET OpLainaKor = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, OpLainaKor)))) / &valuutta) * &minf;
%LET OpLainaKorAlle18 = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, OpLainaKorAlle18)))) / &valuutta) * &minf;
%LET OpLainaMuu = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, OpLainaMuu)))) / &valuutta) * &minf;
%LET OpLainaMuuAlle18 = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, OpLainaMuuAlle18)))) / &valuutta) * &minf;
%LET OpLainaAikKoul = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, OpLainaAikKoul)))) / &valuutta) * &minf;
%LET TakPerRaja = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, TakPerRaja)))) / &valuutta) * &minf;
%LET TakPerPros = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, TakPerPros)))));
%LET TakPerAlaRaja = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, TakPerAlaRaja)))) / &valuutta) * &minf;
%LET TakPerKorotus = (%SYSFUNC(GETVARN(&taulu_ot, %SYSFUNC(VARNUM(&taulu_ot, TakPerKorotus)))));

%LET loppu = %SYSFUNC(CLOSE(&taulu_ot));

%MEND HaeParam_OpinTukiSIMUL;

/* 2.2 T‰m‰ makro tekee saman asian kuin edellinen, mutta se toimii vain osana data-askelta.
       Makro luo useita muuttujia data-taulukkoon. Makroa k‰ytet‰‰n esimerkkilaskelmissa (tyyppi = ESIM).
	   Inflaatio- ja valuuttakurssimuunnokset tehd‰‰n t‰ss‰ vaiheessa */

* Makron parametrit:
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi ;

%MACRO HaeParam_OpinTukiESIM (mvuosi, mkuuk, minf)/STORE
DES = 'OPINTUKI, ESIM: Makro, joka tekee OPINTUKI-mallin parametreista makromuuttujia, esimerkkilaskelmat';

%LET valuutta = IFN(&mvuosi < 2002, &euro,  1);
kuuknro = (&mvuosi - &paramalkuot) * 12 + &mkuuk;
IF _N_ = 1 OR taulu_ot =. THEN taulu_ot = OPEN("PARAM.&POPINTUKI", "i");
RETAIN taulu_ot;
w = REWIND(taulu_ot);
w = FETCHOBS(taulu_ot, 1);
y = GETVARN(taulu_ot, 1);
z = GETVARN(taulu_ot, 2);
testi = (y - &paramalkuot) * 12 + z;
IF testi <= kuuknro THEN;
ELSE DO UNTIL (testi <= kuuknro) ;
	w = FETCH(taulu_ot);
	y = GETVARN(taulu_ot, 1);
	z = GETVARN(taulu_ot, 2);
	testi = (y - &paramalkuot) * 12 + z;
END;
IF w = -1 THEN DO;
	%LET riveja = ATTRN(taulu_ot, "NLOBS");
	w = FETCHOBS(taulu_ot, &riveja);
END;

%LET ORaja1 = GETVARN(taulu_ot, VARNUM(taulu_ot, "ORaja1"));
%LET ORaja2 = GETVARN(taulu_ot, VARNUM(taulu_ot, "ORaja2")); 
%LET ORaja3 = GETVARN(taulu_ot, VARNUM(taulu_ot, "ORaja3"));
%LET KorkVanh20 = (GETVARN(taulu_ot, VARNUM(taulu_ot, "KorkVanh20")) / &valuutta) * &minf;
%LET KorkVanhAlle20 = (GETVARN(taulu_ot, VARNUM(taulu_ot, "KorkVanhAlle20")) / &valuutta) * &minf; 
%LET KorkMuu20 = (GETVARN(taulu_ot, VARNUM(taulu_ot, "KorkMuu20")) / &valuutta) * &minf;
%LET KorkMuuAlle20 = (GETVARN(taulu_ot, VARNUM(taulu_ot, "KorkMuuAlle20")) / &valuutta) * &minf;
%LET MuuVanh20 = (GETVARN(taulu_ot, VARNUM(taulu_ot, "MuuVanh20")) / &valuutta) * &minf;
%LET MuuVanhAlle20 = (GETVARN(taulu_ot, VARNUM(taulu_ot, "MuuVanhAlle20")) / &valuutta) * &minf;
%LET MuuMuu20 = (GETVARN(taulu_ot, VARNUM(taulu_ot, "MuuMuu20")) / &valuutta) * &minf;
%LET MuuMuuAlle20 = (GETVARN(taulu_ot, VARNUM(taulu_ot, "MuuMuuAlle20")) / &valuutta) * &minf;
%LET VuokraKatto = (GETVARN(taulu_ot, VARNUM(taulu_ot, "VuokraKatto")) / &valuutta) * &minf;
%LET VuokraRaja = (GETVARN(taulu_ot, VARNUM(taulu_ot, "VuokraRaja")) / &valuutta) * &minf;
%LET VuokraMinimi = (GETVARN(taulu_ot, VARNUM(taulu_ot, "VuokraMinimi")) / &valuutta) * &minf;
%LET AsLisaPros = GETVARN(taulu_ot, VARNUM(taulu_ot, "AsLisaPros"));
%LET AsLisaPerus = (GETVARN(taulu_ot, VARNUM(taulu_ot, "AsLisaPerus")) / &valuutta) * &minf;
%LET AsLisaTuloRaja = (GETVARN(taulu_ot, VARNUM(taulu_ot, "AsLisaTuloRaja")) / &valuutta) * &minf;
%LET AsLisavahPros = GETVARN(taulu_ot, VARNUM(taulu_ot, "AsLisavahPros"));
%LET AsLisaVanhKynnys = (GETVARN(taulu_ot, VARNUM(taulu_ot, "AsLisaVanhKynnys")) / &valuutta) * &minf;
%LET AsLisaPuolTuloRaja = (GETVARN(taulu_ot, VARNUM(taulu_ot, "AsLisaPuolTuloRaja")) / &valuutta) * &minf;
%LET AsLisaPuolvahPros = GETVARN(taulu_ot, VARNUM(taulu_ot, "AsLisaPuolvahPros"));
%LET AsLisaPuolTuloKynnys = (GETVARN(taulu_ot, VARNUM(taulu_ot, "AsLisaPuolTuloKynnys")) / &valuutta) * &minf;
%LET VanhTuloRaja = (GETVARN(taulu_ot, VARNUM(taulu_ot, "VanhTuloRaja")) / &valuutta) * &minf;
%LET VanhKynnys = (GETVARN(taulu_ot, VARNUM(taulu_ot, "VanhKynnys")) / &valuutta) * &minf;
%LET VanhPros = GETVARN(taulu_ot, VARNUM(taulu_ot, "VanhPros"));
%LET VanhTuloYlaRaja = (GETVARN(taulu_ot, VARNUM(taulu_ot, "VanhTuloYlaRaja")) / &valuutta) * &minf;
%LET SisarAlennus = (GETVARN(taulu_ot, VARNUM(taulu_ot, "SisarAlennus")) / &valuutta) * &minf;
%LET AikOpPros = GETVARN(taulu_ot, VARNUM(taulu_ot, "AikOpPros"));
%LET AikOpAlaRaja = (GETVARN(taulu_ot, VARNUM(taulu_ot, "AikOpAlaRaja")) / &valuutta) * &minf;
%LET AikOpYlaRaja = (GETVARN(taulu_ot, VARNUM(taulu_ot, "AikOpYlaRaja")) / &valuutta) * &minf;
%LET OpTuloRaja = (GETVARN(taulu_ot, VARNUM(taulu_ot, "OpTuloRaja")) / &valuutta) * &minf;
%LET OpTulovahPros = GETVARN(taulu_ot, VARNUM(taulu_ot, "OpTulovahPros"));
%LET OpTuloVahKynnys = (GETVARN(taulu_ot, VARNUM(taulu_ot, "OpTuloVahKynnys")) / &valuutta) * &minf;
%LET VanhVarRaja = (GETVARN(taulu_ot, VARNUM(taulu_ot, "VanhVarRaja")) / &valuutta) * &minf;
%LET VanhVarPros = GETVARN(taulu_ot, VARNUM(taulu_ot, "VanhVarPros"));
%LET VanhTuloRaja2 = (GETVARN(taulu_ot, VARNUM(taulu_ot, "VanhTuloRaja2")) / &valuutta) * &minf;
%LET VanhTuloRaja2Kynnys = (GETVARN(taulu_ot, VARNUM(taulu_ot, "VanhTuloRaja2Kynnys")) / &valuutta) * &minf;
%LET VanhTuloPros2 = GETVARN(taulu_ot, VARNUM(taulu_ot, "VanhTuloPros2"));
%LET KorkVanh20b = (GETVARN(taulu_ot, VARNUM(taulu_ot, "korkVanh20b")) / &valuutta) * &minf;
%LET KorkVanhAlle20b = (GETVARN(taulu_ot, VARNUM(taulu_ot, "korkVanhAlle20b")) / &valuutta) * &minf;
%LET KorkMuuAlle20b = (GETVARN(taulu_ot, VARNUM(taulu_ot, "KorkMuuAlle20b")) / &valuutta) * &minf;
%LET MuuVanh20b = (GETVARN(taulu_ot, VARNUM(taulu_ot, "MuuVanh20b")) / &valuutta) * &minf;
%LET MuuVanhAlle20b = (GETVARN(taulu_ot, VARNUM(taulu_ot, "MuuVanhAlle20b")) / &valuutta) * &minf;
%LET MuuMuuAlle20b = (GETVARN(taulu_ot, VARNUM(taulu_ot, "MuuMuuAlle20b")) / &valuutta) * &minf;
%LET OpTuloRaja2 = (GETVARN(taulu_ot, VARNUM(taulu_ot, "OpTuloRaja2")) / &valuutta) * &minf; 
%LET AikKoulPerus = (GETVARN(taulu_ot, VARNUM(taulu_ot, "AikKoulPerus")) / &valuutta) * &minf;
%LET AikKoulTuloRaja = (GETVARN(taulu_ot, VARNUM(taulu_ot, "AikKoulTuloRaja")) / &valuutta) * &minf;
%LET AikKoulPros1 = GETVARN(taulu_ot, VARNUM(taulu_ot, "AikKoulPros1"));
%LET AikKoulPros2 = GETVARN(taulu_ot, VARNUM(taulu_ot, "AikKoulPros2"));
%LET OpLainaKor = (GETVARN(taulu_ot, VARNUM(taulu_ot, "OpLainaKor")) / &valuutta) * &minf;
%LET OpLainaKorAlle18 = (GETVARN(taulu_ot, VARNUM(taulu_ot, "OpLainaKorAlle18")) / &valuutta) * &minf;
%LET OpLainaMuu = (GETVARN(taulu_ot, VARNUM(taulu_ot, "OpLainaMuu")) / &valuutta) * &minf;
%LET OpLainaMuuAlle18 = (GETVARN(taulu_ot, VARNUM(taulu_ot, "OpLainaMuuAlle18")) / &valuutta) * &minf;
%LET OpLainaAikKoul = (GETVARN(taulu_ot, VARNUM(taulu_ot, "OpLainaAikKoul")) / &valuutta) * &minf;
%LET TakPerRaja = (GETVARN(taulu_ot, VARNUM(taulu_ot, "TakPerRaja")) / &valuutta) * &minf;
%LET TakPerPros = GETVARN(taulu_ot, VARNUM(taulu_ot, "TakPerPros"));
%LET TakPerAlaRaja = (GETVARN(taulu_ot, VARNUM(taulu_ot, "TakPerAlaRaja")) / &valuutta) * &minf;
%LET TakPerKorotus = GETVARN(taulu_ot, VARNUM(taulu_ot, "TakPerKorotus"));

%MEND HaeParam_OpinTukiESIM ;


/* 2.3 Tyhj‰ makro, jolla voidaan korvata lains‰‰d‰ntˆ‰ kuvaavien
	   makrojen sis‰ll‰ oleva parametrien haku, jos parametrit on m‰‰ritelty
	   ennen simulointiohjelman ajoa. K‰ytet‰‰n, jos halutaan k‰ytt‰‰ vuosikeskiarvon laskemisessa tietyn 
	   kuukauden lains‰‰d‰ntˆ‰ (tyyppi = SIMULx). */

* Makron parametrit:
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi ;

%MACRO HaeParam_OpinTukiSIMULx (mvuosi, mkuuk, minf)/STORE
DES = 'OPINTUKI, SIMULx: Tyhj‰ makro, jolla voidaan korvata lains‰‰d‰ntˆ‰ kuvaavien makrojen sis‰ll‰ oleva parametrien haku';
%MEND HaeParam_OpinTukiSIMULx;

/* 2.4 Makro, jolla vuosiluvusta ja kuukauden numerosta johdetaan j‰rjestysluku ajankohtien vertailua varten.
	   Jos tarjotaan parametritaulukon l‰htˆvuotta aikaisempaa arvoa, valitaan ensimm‰inen mahdollinen kuukausi.
	   Makroa k‰ytet‰‰n varsinaisissa simulointilaskelmissa */

* Makron parametrit:
	nro: Makron tulosmuuttuja, ajankohdan (vuosi ja kuukausi) j‰rjestysluku 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n ;

%MACRO KuuNro_OpinTukiSIMUL (nro, mvuosi, mkuuk)/STORE
DES = 'OPINTUKI, SIMUL: Kuukausinumeron muodostus, simulointi';

&nro = 12 * %EVAL (&mvuosi - &paramalkuot) + &mkuuk;
%IF &mvuosi < &paramalkuot %THEN &nro = 1;
%MEND KuuNro_OpinTukiSIMUL;


%MACRO KuuNro_OpinTukiSIMULx (nro, mvuosi, mkuuk)/STORE
DES = 'OPINTUKI, SIMULx: Kuukausinumeron muodostus, simulointi';

&nro = 12 * %EVAL (&mvuosi - &paramalkuot) + &mkuuk;
%IF &mvuosi < &paramalkuot %THEN &nro = 1;
%MEND KuuNro_OpinTukiSIMULx;

/* 2.5 Edellisest‰ makrosta versio, joka toimii vain osana data-askelta. Makroa k‰ytet‰‰n esimerkkilaskelmissa. */

%MACRO KuuNro_OpinTukiESIM (nro, mvuosi, mkuuk)/STORE
DES = 'OPINTUKI, ESIM: Kuukausinumeron muodostus, esimerkkilaskelmat';

&nro = 12 * (&mvuosi - &paramalkuot) + &mkuuk;
IF &mvuosi < &paramalkuot THEN &nro = 1;
%MEND KuuNro_OpinTukiESIM;


/* 3 Simuloinnissa tarvittavat apumakrot */

/* 3.1 Makro, joka laskee ne kuukaudet, jolloin henkilˆ on tietyll‰ 
       ik‰v‰lill‰ tarkasteluvuoden aikana, kun ik‰kuukausia vuoden 
       lopussa on kaiken kaikkiaan ikakk. */

* Makron parametrit:
    tulos: Kuukaudet, jolloin henkiˆ on esim. 3-17-vuotias tarkasteluvuonna 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	ika_ala: Alaik‰raja, v (esim. 3, jos kyse on v‰hint‰‰n 3-vuotiasta) 
	ika_yla: Yl‰ik‰raja, v (esim. 17, kun kyse on alle 18-vuotiasta)
	ikakk: Ik‰kuukaudet yhteens‰ tarkasteluvuoden lopussa ;

%MACRO IkaKuuk_OpinTuki(ika_kuuk, ika_ala, ika_yla, ikakk)/STORE
DES = 'OPINTUKI: Makro, joka laskee ne kuukaudet, jolloin henkilˆ on tietyll‰ 
ik‰v‰lill‰ tarkasteluvuoden aikana';

IF (&ika_ala < 0 OR &ika_yla < 0 OR &ika_yla < &ika_ala) 
THEN temp = 0;

ELSE DO;

	ala_kuuk = 12 * &ika_ala;
	yla_kuuk = 12 * &ika_yla;

	SELECT;
    	WHEN (&ikakk < ala_kuuk) temp = 0;
    	WHEN (&ikakk > yla_kuuk) DO;
			temp = yla_kuuk + 24 - &ikakk;
			IF temp > 12 THEN temp = 12;
			IF temp < 0 THEN temp = 0;
		END;
		WHEN (ala_kuuk <= &ikakk <= yla_kuuk) DO;
			temp= &ikakk - ala_kuuk;
    		IF temp > 12 THEN temp = 12;
		END;
	END;
END;
&ika_kuuk = temp;
DROP ala_kuuk yla_kuuk temp;
%MEND IkaKuuk_OpinTuki;

/* 3.2 Makron avulla voidaan p‰‰tell‰ opintotukikuukaudet
       vertaamalla todella maksettua opintotukea lains‰‰d‰nnˆn takaamaan  */

* Makron parametrit:
    tukikuuk: Makron tulosmuuttuja, opintotukikuukausien lukum‰‰r‰ tarkasteluvuonna 
    tuki: Aineiston mukainen opintoraha 
	aste: 1 = korkeakouluopiskelija, 0 = keskiasteen opiskelija
	vanh: Vanhempien luona asuminen (1 = tosi, 0 = ep‰tosi).
	ika: Ik‰ vuosina
	oletus: Aineiston perusteella laskettujen oletusarvona olevien opintotukikuukausien lukum‰‰r‰ ;

%MACRO TukiKuuk(tukikuuk, tuki, aste, vanh, ika, oletus)/STORE
DES = 'OPINTUKI: Makro p‰‰ttelee opintotukikuukaudet
vertaamalla todella maksettua opintotukea lains‰‰d‰nnˆn takaamaan';

* Lasketaan t‰ysim‰‰r‰inen opintotuki aineistovuoden perusteella (&AVUOSI), joka riippuu oppilaitosasteesta,
  vanhempien luona asumisesta ja i‰st‰ ;

%OpRahaV&F(taystuki, &AVUOSI, 1, &aste, &vanh, &ika, 0, 0, 0, 0);
kuuktuki = taystuki;

* Tarkistetaan, vastaako tuki jotakin t‰yden tuen monikertaa ;

DO i = 1 TO 12 UNTIL (round(&tuki) = round(i * kuuktuki)); 

&tukikuuk = i;

END;

* Jos ei, annetaan tulokseksi valmiina oleva tieto ;

IF &tukikuuk NE i THEN &tukikuuk = &oletus;

DROP i kuuktuki taystuki;
%MEND TukiKuuk;



