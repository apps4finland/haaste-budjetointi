/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyˆdynt‰‰ Tilastokeskuksen yleisten
* k‰yttˆehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto p‰‰hakemistossa.
******************************************************************************/

/************************************************************ 
* Kuvaus: Lapsilis‰n simuloinnin apumakroja					* 
* Tekij‰: Maria Valaste / KELA 								* 
* Luotu: 14.11.2011  										* 
* Viimeksi p‰ivitetty: 7.12.2011 							* 
* P‰ivitt‰j‰: Olli Kannas / TK								* 
************************************************************/


/* 1. SISƒLLYS */

/* Tiedosto sis‰lt‰‰ seuraavat makrot */

/*
2.1 HaeParam_LLisaSIMUL = Makro, joka tekee LLISA-mallin parametreista makromuuttujia, simulointilaskelmat
2.2 HaeParam_LLisaESIM = Makro, joka tekee LLISA-mallin parametreista makromuuttujia, esimerkkilaskelmat
2.3 HaeParam_LLisaSIMULx = Tyhj‰ makro, jolla voidaan korvata lains‰‰d‰ntˆ‰ kuvaavien makrojen sis‰ll‰ oleva parametrien haku
2.4 KuuNro_LLisaSIMUL = Kuukausinumeron muodostus, simulointi
2.4 KuuNro_LLisaSIMULx = Kuukausinumeron muodostus, simulointi
2.5 KuuNro_LLisaESIM = Kuukausinumeron muodostus, esimerkkilaskelmat
3.1 IkaKuuk_LLisa = Makro, joka laskee ne kuukaudet, jolloin henkilˆ on tietyll‰ ik‰v‰lill‰ tarkasteluvuoden aikana
3.2 AitLkm = Makro, jolla m‰‰ritell‰‰n ‰itiysavustukseen oikeuttavien lasten lukum‰‰r‰ vuodesta 2003 l‰htien
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

%MACRO Haeparam_LLisaSIMUL(mvuosi, mkuuk, minf)/STORE
DES = 'LLISA, SIMUL: Makro, joka tekee LLISA-mallin parametreista makromuuttujia,
simulointilaskelmat';

%LET valuutta = %SYSFUNC(IFN(&mvuosi < 2002, &euro, 1));
%LET kuuknro = %EVAL((&mvuosi - &paramalkull) * 12 + &mkuuk);
%LET taulu_ll = %SYSFUNC(OPEN(PARAM.&PLLISA, i));
%LET w = %SYSFUNC(REWIND(&taulu_ll));
%LET w = %SYSFUNC(FETCHOBS(&taulu_ll, 1));
%LET y = %SYSFUNC(GETVARN(&taulu_ll, 1));
%LET z = %SYSFUNC(GETVARN(&taulu_ll, 2));
%LET testi = %EVAL((&y - &paramalkull) * 12 + &z);
%IF &testi <= &kuuknro %THEN;
%ELSE %DO %UNTIL ((&testi <= &kuuknro) OR (&testi = 1));
	%LET w = %SYSFUNC(FETCH(&taulu_ll));
	%LET y = %SYSFUNC(GETVARN(&taulu_ll, 1));
	%LET z = %SYSFUNC(GETVARN(&taulu_ll, 2));
	%LET testi = %EVAL((&y - &paramalkull) * 12 + &z);
%END;
%IF &w = -1 %THEN %DO;
	%LET riveja = %SYSFUNC(ATTRN(&taulu_ll, NLOBS));
	%LET w = %SYSFUNC(FETCHOBS(&taulu_ll, &riveja));
%END;

%LET Lapsi1 = (%SYSFUNC(GETVARN(&taulu_ll, %SYSFUNC(VARNUM(&taulu_ll, Lapsi1)))) / &valuutta) * &minf;
%LET Lapsi2 = (%SYSFUNC(GETVARN(&taulu_ll, %SYSFUNC(VARNUM(&taulu_ll, Lapsi2)))) / &valuutta) * &minf;
%LET Lapsi3 = (%SYSFUNC(GETVARN(&taulu_ll, %SYSFUNC(VARNUM(&taulu_ll, Lapsi3)))) / &valuutta) * &minf;
%LET Lapsi4 = (%SYSFUNC(GETVARN(&taulu_ll, %SYSFUNC(VARNUM(&taulu_ll, Lapsi4)))) / &valuutta) * &minf;
%LET Lapsi5 = (%SYSFUNC(GETVARN(&taulu_ll, %SYSFUNC(VARNUM(&taulu_ll, Lapsi5)))) / &valuutta) * &minf;
%LET Alle3v = (%SYSFUNC(GETVARN(&taulu_ll, %SYSFUNC(VARNUM(&taulu_ll, Alle3v)))) / &valuutta) * &minf;
%LET YksHuolt = (%SYSFUNC(GETVARN(&taulu_ll, %SYSFUNC(VARNUM(&taulu_ll, YksHuolt)))) / &valuutta) * &minf;
%LET AitAv = (%SYSFUNC(GETVARN(&taulu_ll, %SYSFUNC(VARNUM(&taulu_ll, AitAv)))) / &valuutta) * &minf;  
%LET ElatTuki = (%SYSFUNC(GETVARN(&taulu_ll, %SYSFUNC(VARNUM(&taulu_ll, ElatTuki)))) / &valuutta) * &minf;
%LET AlenElatTuki = (%SYSFUNC(GETVARN(&taulu_ll, %SYSFUNC(VARNUM(&taulu_ll, AlenElatTuki)))) / &valuutta) * &minf;
%LET IRaja = %SYSFUNC(GETVARN(&taulu_ll, %SYSFUNC(VARNUM(&taulu_ll, IRaja)))) ;
%LET loppu = %SYSFUNC(CLOSE(&taulu_ll));

%MEND Haeparam_LLisaSIMUL;


/* 2.2 T‰m‰ makro tekee saman asian kuin edellinen, mutta se toimii vain osana data-askelta.
       Makro luo useita muuttujia data-taulukkoon. Makroa k‰ytet‰‰n esimerkkilaskelmissa (tyyppi = ESIM).
	   Inflaatio- ja valuuttakurssimuunnokset tehd‰‰n t‰ss‰ vaiheessa */

* Makron parametrit:
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi ;

%MACRO Haeparam_LLisaESIM(mvuosi, mkuuk, minf)/STORE
DES = 'LLISA, ESIM: Makro, joka tekee LLISA-mallin parametreista makromuuttujia,
esimerkkilaskelmat';

%LET valuutta = IFN(&mvuosi < 2002, &euro,  1);
kuuknro = (&mvuosi - &paramalkull) * 12 + &mkuuk;
IF _N_ = 1 OR taulu_ll =. THEN taulu_ll = OPEN("PARAM.&PLLISA", "i");
RETAIN taulu_ll;
w = REWIND(taulu_ll);
w = FETCHOBS(taulu_ll, 1);
y = GETVARN(taulu_ll, 1);
z = GETVARN(taulu_ll, 2);
testi = (y - &paramalkull) * 12 + z;
IF testi <= kuuknro THEN;
ELSE DO UNTIL (testi <= kuuknro);
		w = FETCH(taulu_ll);
		y = GETVARN(taulu_ll, 1);
		z = GETVARN(taulu_ll, 2);
		testi = (y - &paramalkull) * 12 + z;
END;
IF w = -1 THEN DO;
	%LET riveja = ATTRN(taulu_ll, "NLOBS");
	w = FETCHOBS(taulu_ll, &riveja);
END;

%LET Lapsi1 = (GETVARN(taulu_ll, VARNUM(taulu_ll, "Lapsi1")) / &valuutta) * &minf;
%LET Lapsi2 = (GETVARN(taulu_ll, VARNUM(taulu_ll, "Lapsi2")) / &valuutta) * &minf;
%LET Lapsi3 = (GETVARN(taulu_ll, VARNUM(taulu_ll, "Lapsi3")) / &valuutta) * &minf;
%LET Lapsi4 = (GETVARN(taulu_ll, VARNUM(taulu_ll, "Lapsi4")) / &valuutta) * &minf;
%LET Lapsi5 = (GETVARN(taulu_ll, VARNUM(taulu_ll, "Lapsi5")) / &valuutta) * &minf;
%LET Alle3v = (GETVARN(taulu_ll, VARNUM(taulu_ll, "Alle3v")) / &valuutta) * &minf;
%LET YksHuolt = (GETVARN(taulu_ll, VARNUM(taulu_ll, "YksHuolt")) / &valuutta) * &minf;
%LET AitAv = (GETVARN(taulu_ll, VARNUM(taulu_ll, "AitAv")) / &valuutta) * &minf;  
%LET ElatTuki = (GETVARN(taulu_ll, VARNUM(taulu_ll, "ElatTuki")) / &valuutta) * &minf;
%LET AlenElatTuki = (GETVARN(taulu_ll, VARNUM(taulu_ll, "AlenElatTuki")) / &valuutta) * &minf;
%LET IRaja = GETVARN(taulu_ll, VARNUM(taulu_ll, "IRaja"));

%MEND Haeparam_LLisaESIM;


/* 2.3 Tyhj‰ makro, jolla voidaan korvata lains‰‰d‰ntˆ‰ kuvaavien
	   makrojen sis‰ll‰ oleva parametrien haku, jos parametrit on m‰‰ritelty
	   ennen simulointiohjelman ajoa. K‰ytet‰‰n, jos halutaan k‰ytt‰‰ vuosikeskiarvon laskemisessa tietyn 
	   kuukauden lains‰‰d‰ntˆ‰ (tyyppi = SIMULx). */

* Makron parametrit:
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi ;

%MACRO Haeparam_LLisaSIMULx(mvuosi, mkuuk, minf)/STORE;
DES = 'LLISA, SIMULx: Tyhj‰ makro, jolla voidaan korvata lains‰‰d‰ntˆ‰ kuvaavien makrojen sis‰ll‰ oleva parametrien haku';
%MEND Haeparam_LLisaSIMULx;

/* 2.4 Makro, jolla vuosiluvusta ja kuukauden numerosta johdetaan j‰rjestysluku ajankohtien vertailua varten.
       Jos tarjotaan parametritaulukon l‰htˆvuotta aikaisempaa arvoa, valitaan ensimm‰inen mahdollinen kuukausi.
	   Makroa k‰ytet‰‰n varsinaisissa simulointilaskelmissa */

* Makron parametrit:
	nro: Makron tulosmuuttuja, ajankohdan (vuosi ja kuukausi) j‰rjestysluku 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n ;

%MACRO KuuNro_LLisaSIMUL(nro, mvuosi, mkuuk)/STORE
DES = 'LLISA, SIMUL: Kuukausinumeron muodostus, simulointi';

&nro = 12 * %EVAL (&mvuosi - &paramalkull) + &mkuuk;
%IF &mvuosi < &paramalkull %THEN &nro = 1;
%MEND KuuNro_LLisaSIMUL;


%MACRO KuuNro_LLisaSIMULx(nro, mvuosi, mkuuk)/STORE
DES = 'LLISA, SIMUL: Kuukausinumeron muodostus, simulointi';

&nro = 12 * %EVAL (&mvuosi - &paramalkull) + &mkuuk;
%IF &mvuosi < &paramalkull %THEN &nro = 1;
%MEND KuuNro_LLisaSIMULx;

/* 2.5 Edellisest‰ makrosta versio, joka toimii vain osana data-askelta. Makroa k‰ytet‰‰n esimerkkilaskelmissa. */

%MACRO KuuNro_LLisaESIM(nro, mvuosi, mkuuk)/STORE
DES = 'LLISA, ESIM: Kuukausinumeron muodostus, esimerkkilaskelmat';

&nro = 12 * (&mvuosi - &paramalkull) + &mkuuk;
IF &mvuosi < &paramalkull THEN &nro = 1;
%MEND KuuNro_LLisaESIM;


/* 3 Simuloinnissa tarvittavat apumakrot */

/* 3.1 Makro, joka laskee ne kuukaudet, jolloin henkilˆ on tietyll‰ 
       ik‰v‰lill‰ tarkasteluvuoden aikana, kun ik‰kuukausia vuoden 
       lopussa on kaiken kaikkiaan ikakk. */

* Makron parametrit:
    tulos: kuukaudet, jolloin henkiˆ on esim. 3-17-vuotias tarkasteluvuonna 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	ika_ala: alaik‰raja, v (esim. 3, jos kyse on v‰hint‰‰n 3-vuotiasta) 
	ika_yla: yl‰ik‰raja, v (esim. 17, kun kyse on alle 18-vuotiasta)
	ikakk: ik‰kuukaudet yhteens‰ tarkasteluvuoden lopussa ;

%MACRO IkaKuuk_LLisa(ika_kuuk, ika_ala, ika_yla, ikakk)/STORE
DES = 'LLISA: Makro, joka laskee ne kuukaudet, jolloin henkilˆ on tietyll‰ 
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

%MEND IkaKuuk_LLisa;


/* 3.2 Makro, jolla m‰‰ritell‰‰n ‰itiysavustukseen oikeuttavien lasten lukum‰‰r‰ 
	   vuodesta 2003 l‰htien. Korkeintaan neloset otetaan huomioon. */

* Makron parametrit:
	aitlkm: ƒitiysavustukseen oikeuttavien lasten lukum‰‰r‰ 
	luku: Syˆtteen‰ annettava kokonaisluku ;

%MACRO AitLkm(aitlkm, luku)/STORE
DES = 'LLISA: Makro, jolla m‰‰ritell‰‰n ‰itiysavustukseen oikeuttavien lasten lukum‰‰r‰ 
		vuodesta 2003 l‰htien';

SELECT (&luku);
	WHEN(1) temp = 1;
	WHEN(3) temp = 2;
	WHEN(6) temp = 3;
	WHEN(10) temp = 4;
	OTHERWISE temp = 1;
END;

&aitlkm = temp;
DROP temp;
%MEND AitLkm;
