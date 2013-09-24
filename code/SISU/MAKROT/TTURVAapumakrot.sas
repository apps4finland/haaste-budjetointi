/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyödyntää Tilastokeskuksen yleisten
* käyttöehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto päähakemistossa.
******************************************************************************/

/*************************************************************
*  Kuvaus: Työttömyysturvan simuloinnin apumakroja         	 * 
*  Tekijä: Jussi Tervola /KELA                             	 *
*  Luotu: 8.9.2011                                         	 *
*  Viimeksi päivitetty: 31.5.2012							 * 
*  Päivittäjä: Jussi Tervola / KELA                        	 *
**************************************************************/


/* 1. SISÄLLYS */

/* Tiedosto sisältää seuraavat makrot */

/*
2.1 HaeParam_TTurvaSIMUL = Makro, joka tekee TTURVA-mallin parametreista makromuuttujia, simulointilaskelmat
2.2 HaeParam_TTurvaESIM = Makro, joka tekee TTURVA-mallin parametreista makromuuttujia, esimerkkilaskelmat
2.3 HaeParam_TTurvaSIMULx = Tyhjä makro, jolla voidaan korvata lainsäädäntöä kuvaavien makrojen sisällä oleva parametrien haku
2.4 KuuNro_TTurvaSIMUL = Kuukausinumeron muodostus, simulointi
2.4 KuuNro_TTurvaSIMULx = Kuukausinumeron muodostus, simulointi
2.5 KuuNro_TTurvaESIM = Kuukausinumeron muodostus, esimerkkilaskelmat
*/


/* 2. Parametrien muuttaminen makromuuttujiksi */

/* 2.1 Makro, joka hakee halutun vuoden ja kuukauden parametrit ja tekee niistä makromuuttujat.
	   Jos vuosi-kuukausi -yhdistelmä, jota tarjotaan ei esiinny parametritaulukossa, valitaan lähin mahdollinen ajankohta.
       Tämä makro on itsenäisesti toimiva makro, jota voi käyttää myös data-askeleen ulkopuolella. 
	   Makroa käytetään varsinaisissa simulointilaskelmissa (tyyppi = SIMUL). 
	   Inflaatio- ja valuuttakurssimuunnokset tehdään tässä vaiheessa */

* Makron parametrit:
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	minf: Deflaattori euromääräisten parametrien kertomiseksi ;

%MACRO Haeparam_TTurvaSIMUL (mvuosi, mkuuk, minf)/STORE 
DES = 'TTURVA, SIMUL: Makro, joka tekee TTURVA-mallin parametreista makromuuttujia, simulointilaskelmat';

%LET valuutta = %SYSFUNC(IFN(&mvuosi < 2002, &euro, 1));
%LET kuuknro = %EVAL((&mvuosi - &paramalkutt) * 12 + &mkuuk);
%LET taulu_tt = %SYSFUNC(OPEN(PARAM.&PTTURVA, i));
%LET w = %SYSFUNC(REWIND(&taulu_tt));
%LET w = %SYSFUNC(FETCHOBS(&taulu_tt, 1));
%LET y = %SYSFUNC(GETVARN(&taulu_tt, 1));
%LET z = %SYSFUNC(GETVARN(&taulu_tt, 2));
%LET testi = %EVAL((&y - &paramalkutt) * 12 + &z);
%IF &testi <= &kuuknro %THEN;
%ELSE %DO %UNTIL ((&testi <= &kuuknro) OR (&testi = 1));
	%LET w = %SYSFUNC(FETCH(&taulu_tt));
	%LET y = %SYSFUNC(GETVARN(&taulu_tt, 1));
	%LET z = %SYSFUNC(GETVARN(&taulu_tt, 2));
	%LET testi = %EVAL((&y - &paramalkutt) * 12 + &z);
%END;
%IF &w = -1 %THEN %DO;
	%LET riveja = %SYSFUNC(ATTRN(&taulu_tt, NLOBS));
	%LET w = %SYSFUNC(FETCHOBS(&taulu_tt, &riveja));
%END;


%LET 	TTMaksLaps = (%SYSFUNC(GETVARN(&taulu_tt, %SYSFUNC(VARNUM(&taulu_tt, TTMaksLaps)))));
%LET 	TTPaivia = (%SYSFUNC(GETVARN(&taulu_tt, %SYSFUNC(VARNUM(&taulu_tt, TTPaivia)))));
%LET 	TTPerus = (%SYSFUNC(GETVARN(&taulu_tt, %SYSFUNC(VARNUM(&taulu_tt, TTPerus)))) / &valuutta) * &minf;
%LET 	TTTaite= (%SYSFUNC(GETVARN(&taulu_tt, %SYSFUNC(VARNUM(&taulu_tt, TTTaite)))));
%LET 	TTPros1= (%SYSFUNC(GETVARN(&taulu_tt, %SYSFUNC(VARNUM(&taulu_tt, TTPros1)))));
%LET 	TTPros2 = (%SYSFUNC(GETVARN(&taulu_tt, %SYSFUNC(VARNUM(&taulu_tt, TTPros2)))));
%LET 	ProsKor1= (%SYSFUNC(GETVARN(&taulu_tt, %SYSFUNC(VARNUM(&taulu_tt, Proskor1)))));
%LET 	ProsKor2 = (%SYSFUNC(GETVARN(&taulu_tt, %SYSFUNC(VARNUM(&taulu_tt, Proskor2)))));
%LET 	ProsYlaraja = (%SYSFUNC(GETVARN(&taulu_tt, %SYSFUNC(VARNUM(&taulu_tt, Prosylaraja)))));
%LET 	TTLaps1= (%SYSFUNC(GETVARN(&taulu_tt, %SYSFUNC(VARNUM(&taulu_tt, TTLaps1)))) / &valuutta) * &minf;
%LET 	TTLaps2 = (%SYSFUNC(GETVARN(&taulu_tt, %SYSFUNC(VARNUM(&taulu_tt, TTLaps2)))) / &valuutta) * &minf;
%LET 	TTLaps3= (%SYSFUNC(GETVARN(&taulu_tt, %SYSFUNC(VARNUM(&taulu_tt, TTLaps3)))) / &valuutta) * &minf;
%LET 	TyomLapsPros= (%SYSFUNC(GETVARN(&taulu_tt, %SYSFUNC(VARNUM(&taulu_tt, TyomLapsPros)))) / &valuutta);
%LET 	RajaYks = (%SYSFUNC(GETVARN(&taulu_tt, %SYSFUNC(VARNUM(&taulu_tt, Rajayks)))) / &valuutta) * &minf;
%LET 	RajaHuolt = (%SYSFUNC(GETVARN(&taulu_tt, %SYSFUNC(VARNUM(&taulu_tt, Rajahuolt)))) / &valuutta) * &minf;
%LET 	RajaLaps = (%SYSFUNC(GETVARN(&taulu_tt, %SYSFUNC(VARNUM(&taulu_tt, Rajalaps)))) / &valuutta) * &minf;
%LET 	PuolVah= (%SYSFUNC(GETVARN(&taulu_tt, %SYSFUNC(VARNUM(&taulu_tt, PuolVah)))) / &valuutta) * &minf;
%LET 	TarvPros1= (%SYSFUNC(GETVARN(&taulu_tt, %SYSFUNC(VARNUM(&taulu_tt, TarvPros1)))));
%LET 	TarvPros2 = (%SYSFUNC(GETVARN(&taulu_tt, %SYSFUNC(VARNUM(&taulu_tt, TarvPros2)))));
%LET 	VahPros = (%SYSFUNC(GETVARN(&taulu_tt, %SYSFUNC(VARNUM(&taulu_tt, VahPros)))));
%LET 	OsPros = (%SYSFUNC(GETVARN(&taulu_tt, %SYSFUNC(VARNUM(&taulu_tt, OsPros)))));
%LET 	OsRaja = (%SYSFUNC(GETVARN(&taulu_tt, %SYSFUNC(VARNUM(&taulu_tt, OsRaja)))) / &valuutta) * &minf;
%LET 	OsRajaKor = (%SYSFUNC(GETVARN(&taulu_tt, %SYSFUNC(VARNUM(&taulu_tt, OsRajaKor)))) / &valuutta) * &minf;
%LET 	OsTarvPros = (%SYSFUNC(GETVARN(&taulu_tt, %SYSFUNC(VARNUM(&taulu_tt, OsTarvPros)))));
%LET 	SovSuoja = (%SYSFUNC(GETVARN(&taulu_tt, %SYSFUNC(VARNUM(&taulu_tt, SovSuoja)))) / &valuutta) * &minf;
%LET 	SovPros = (%SYSFUNC(GETVARN(&taulu_tt, %SYSFUNC(VARNUM(&taulu_tt, SovPros)))));
%LET 	SovRaja = (%SYSFUNC(GETVARN(&taulu_tt, %SYSFUNC(VARNUM(&taulu_tt, SovRaja)))));
%LET 	YPiToK= (%SYSFUNC(GETVARN(&taulu_tt, %SYSFUNC(VARNUM(&taulu_tt, YPitoK)))) / &valuutta) * &minf;
%LET 	KorotusOsa = (%SYSFUNC(GETVARN(&taulu_tt, %SYSFUNC(VARNUM(&taulu_tt, KorotusOsa)))) / &valuutta) * &minf;
%LET 	MuutTurvaPros1= (%SYSFUNC(GETVARN(&taulu_tt, %SYSFUNC(VARNUM(&taulu_tt, MuutTurvaPros1)))));
%LET 	MuutTurvaPros2 = (%SYSFUNC(GETVARN(&taulu_tt, %SYSFUNC(VARNUM(&taulu_tt, MuutTurvaPros2)))));
%LET 	VuorKorvPros = (%SYSFUNC(GETVARN(&taulu_tt, %SYSFUNC(VARNUM(&taulu_tt, VuorKorvPros)))));
%LET 	VuorKorvPros2 = (%SYSFUNC(GETVARN(&taulu_tt, %SYSFUNC(VARNUM(&taulu_tt, VuorKorvPros2)))));
%LET 	VuorKorvYlaRaja = (%SYSFUNC(GETVARN(&taulu_tt, %SYSFUNC(VARNUM(&taulu_tt, VuorKorvYlaRaja)))) / &valuutta)  * &minf;
%LET 	SovSuojaKoul= (%SYSFUNC(GETVARN(&taulu_tt, %SYSFUNC(VARNUM(&taulu_tt, SovSuojaKoul)))) / &valuutta) * &minf;
%LET 	SovProsKoul= (%SYSFUNC(GETVARN(&taulu_tt, %SYSFUNC(VARNUM(&taulu_tt, SovProsKoul)))));
%LET loppu = %SYSFUNC(CLOSE(&taulu_tt));

%MEND Haeparam_TTurvaSIMUL;

/* 2.2 Tämä makro tekee saman asian kuin edellinen, mutta se toimii vain osana data-askelta.
       Makro luo useita muuttujia data-taulukkoon. Makroa käytetään esimerkkilaskelmissa (tyyppi = ESIM).
	   Inflaatio- ja valuuttakurssimuunnokset tehdään tässä vaiheessa */

* Makron parametrit:
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	minf: Deflaattori euromääräisten parametrien kertomiseksi ;

%MACRO Haeparam_TTurvaESIM(mvuosi, mkuuk, minf)/STORE 
DES = 'OPINTUKI, ESIM: Makro, joka tekee OPINTUKI-mallin parametreista makromuuttujia, esimerkkilaskelmat';

%LET valuutta = IFN(&mvuosi < 2002, &euro,  1);
kuuknro = (&mvuosi - &paramalkutt) * 12 + &mkuuk;
IF _N_ = 1 OR taulu_tt =. THEN taulu_tt = OPEN("PARAM.&PTTURVA", "i");
RETAIN taulu_tt;
w = REWIND(taulu_tt);
w = FETCHOBS(taulu_tt, 1);
y = GETVARN(taulu_tt, 1);
z = GETVARN(taulu_tt, 2);
testi = (y - &paramalkutt) * 12 + z;
IF testi <= kuuknro THEN;
ELSE DO UNTIL (testi <= kuuknro);
	w = FETCH(taulu_tt);
	y = GETVARN(taulu_tt, 1);
	z = GETVARN(taulu_tt, 2);
	testi = (y - &paramalkutt) * 12 + z;
END;
IF w = -1 THEN DO;
	%LET riveja = ATTRN(taulu_tt, "NLOBS");
	w = FETCHOBS(taulu_tt, &riveja);
END;

%LET 	TTMaksLaps = GETVARN(taulu_tt, VARNUM(taulu_tt, "TTMaksLaps"));
%LET 	TTPaivia = GETVARN(taulu_tt, VARNUM(taulu_tt, "TTPaivia"));
%LET 	TTPerus = (GETVARN(taulu_tt, VARNUM(taulu_tt, "TTPerus")) / &valuutta) * &minf;
%LET 	TTTaite= GETVARN(taulu_tt, VARNUM(taulu_tt, "TTTaite"));
%LET 	TTPros1= GETVARN(taulu_tt, VARNUM(taulu_tt, "TTPros1"));
%LET 	TTPros2 = GETVARN(taulu_tt, VARNUM(taulu_tt, "TTPros2"));
%LET 	ProsKor1= GETVARN(taulu_tt, VARNUM(taulu_tt, "Proskor1"));
%LET 	ProsKor2 = GETVARN(taulu_tt, VARNUM(taulu_tt, "Proskor2"));
%LET 	ProsYlaraja = GETVARN(taulu_tt, VARNUM(taulu_tt, "Prosylaraja"));
%LET 	TTLaps1= (GETVARN(taulu_tt, VARNUM(taulu_tt, "TTLaps1")) / &valuutta) * &minf;
%LET 	TTLaps2 = (GETVARN(taulu_tt, VARNUM(taulu_tt, "TTLaps2")) / &valuutta) * &minf;
%LET 	TTLaps3= (GETVARN(taulu_tt, VARNUM(taulu_tt, "TTLaps3")) / &valuutta) * &minf;
%LET 	TyomLapsPros= (GETVARN(taulu_tt, VARNUM(taulu_tt, "TyomLapsPros")));
%LET 	RajaYks = (GETVARN(taulu_tt, VARNUM(taulu_tt, "Rajayks")) / &valuutta) * &minf;
%LET 	RajaHuolt = (GETVARN(taulu_tt, VARNUM(taulu_tt, "Rajahuolt")) / &valuutta) * &minf;
%LET 	RajaLaps = (GETVARN(taulu_tt, VARNUM(taulu_tt, "Rajalaps")) / &valuutta) * &minf;
%LET 	PuolVah= (GETVARN(taulu_tt, VARNUM(taulu_tt, "PuolVah")) / &valuutta) * &minf;
%LET 	TarvPros1= GETVARN(taulu_tt, VARNUM(taulu_tt, "TarvPros1"));
%LET 	TarvPros2 = GETVARN(taulu_tt, VARNUM(taulu_tt, "TarvPros2"));
%LET 	VahPros = GETVARN(taulu_tt, VARNUM(taulu_tt, "VahPros"));
%LET 	OsPros = GETVARN(taulu_tt, VARNUM(taulu_tt, "OsPros"));
%LET 	OsRaja = (GETVARN(taulu_tt, VARNUM(taulu_tt, "OsRaja")) / &valuutta) * &minf;
%LET 	OsRajaKor = (GETVARN(taulu_tt, VARNUM(taulu_tt, "OsRajaKor")) / &valuutta) * &minf;
%LET 	OsTarvPros = GETVARN(taulu_tt, VARNUM(taulu_tt, "OsTarvPros"));
%LET 	SovSuoja = (GETVARN(taulu_tt, VARNUM(taulu_tt, "SovSuoja")) / &valuutta) * &minf;
%LET 	SovPros = GETVARN(taulu_tt, VARNUM(taulu_tt, "SovPros"));
%LET 	SovRaja = GETVARN(taulu_tt, VARNUM(taulu_tt, "SovRaja"));
%LET 	YPiToK= (GETVARN(taulu_tt, VARNUM(taulu_tt, "YPitoK")) / &valuutta) * &minf;
%LET 	KorotusOsa = (GETVARN(taulu_tt, VARNUM(taulu_tt, "KorotusOsa")) / &valuutta) * &minf;
%LET 	MuutTurvaPros1= GETVARN(taulu_tt, VARNUM(taulu_tt, "MuutTurvaPros1"));
%LET 	MuutTurvaPros2 = GETVARN(taulu_tt, VARNUM(taulu_tt, "MuutTurvaPros2"));
%LET 	VuorKorvPros = GETVARN(taulu_tt, VARNUM(taulu_tt, "VuorKorvPros"));
%LET 	VuorKorvPros2 = GETVARN(taulu_tt, VARNUM(taulu_tt, "VuorKorvPros2"));
%LET 	VuorKorvYlaRaja = (GETVARN(taulu_tt, VARNUM(taulu_tt, "VuorKorvYlaRaja")) / &valuutta) * &minf;
%LET 	SovSuojaKoul= (GETVARN(taulu_tt, VARNUM(taulu_tt, "SovSuojaKoul")) / &valuutta) * &minf;
%LET 	SovProsKoul= GETVARN(taulu_tt, VARNUM(taulu_tt, "SovProsKoul"));

%MEND Haeparam_TTurvaESIM;

/* 2.3 Tyhjä makro, jolla voidaan korvata lainsäädäntöä kuvaavien
	   makrojen sisällä oleva parametrien haku, jos parametrit on määritelty
	   ennen simulointiohjelman ajoa. Käytetään, jos halutaan käyttää vuosikeskiarvon laskemisessa tietyn 
	   kuukauden lainsäädäntöä (tyyppi = SIMULx). */

* Makron parametrit:
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	minf: Deflaattori euromääräisten parametrien kertomiseksi ;

%MACRO Haeparam_TTurvaSIMULx (mvuosi, mkuuk, minf)/STORE 
DES = 'TTURVA, SIMULx: Tyhjä makro, jolla voidaan korvata lainsäädäntöä kuvaavien makrojen sisällä oleva parametrien haku';
%MEND Haeparam_TTurvaSIMULx;

/* 2.4 Makro, jolla vuosiluvusta ja kuukauden numerosta johdetaan järjestysluku ajankohtien vertailua varten.
       Jos tarjotaan parametritaulukon lähtövuotta aikaisempaa arvoa, valitaan ensimmäinen mahdollinen kuukausi.
	   Makroa käytetään varsinaisissa simulointilaskelmissa */

* Makron parametrit:
	nro: Makron tulosmuuttuja, ajankohdan (vuosi ja kuukausi) järjestysluku 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään ;

%MACRO KuuNro_TTurvaSIMUL (nro, mvuosi, mkuuk)/STORE 
DES = 'TTURVA, SIMUL: Kuukausinumeron muodostus, simulointi';

&nro = 12 * %EVAL (&mvuosi - &paramalkutt) + &mkuuk;
%IF &mvuosi < &paramalkutt %THEN &nro = 1;
%MEND KuuNro_TTurvaSIMUL;


%MACRO KuuNro_TTurvaSIMULx (nro, mvuosi, mkuuk)/STORE 
DES = 'TTURVA, SIMUL: Kuukausinumeron muodostus, simulointi';

&nro = 12 * %EVAL (&mvuosi - &paramalkutt) + &mkuuk;
%IF &mvuosi < &paramalkutt %THEN &nro = 1;
%MEND KuuNro_TTurvaSIMULx;

/* 2.5 Edellisestä makrosta versio, joka toimii vain osana data-askelta. Makroa käytetään esimerkkilaskelmissa. */

%MACRO KuuNro_TTurvaESIM (nro, mvuosi, mkuuk)/STORE 
DES = 'TTURVA, ESIM: Kuukausinumeron muodostus, esimerkkilaskelmat';

&nro = 12 * (&mvuosi - &paramalkutt) + &mkuuk;
IF &mvuosi < &paramalkutt THEN &nro = 1;
%MEND KuuNro_TTurvaESIM;




