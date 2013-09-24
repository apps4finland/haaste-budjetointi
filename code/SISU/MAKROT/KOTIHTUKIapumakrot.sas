/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyödyntää Tilastokeskuksen yleisten
* käyttöehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto päähakemistossa.
******************************************************************************/

/************************************************************
* Kuvaus: Kotihoidontuen simuloinnin apumakroja             *
* Tekijä: Maria Valaste / KELA                              *
* Luotu: 09.11.2011                                         *
* Viimeksi päivitetty: 20.06.2012                           *
* Päivittäjä: Maria Valaste / KELA                          *
*************************************************************/


/* 1. SISÄLLYS */

/* Tiedosto sisältää seuraavat makrot */

/*
2.1 HaeParam_KotihTukiSIMUL = Makro, joka tekee KOTIHTUKI-mallin parametreista makromuuttujia, simulointilaskelmat
2.2 HaeParam_KotihTukiESIM = Makro, joka tekee KOTIHTUKI-mallin parametreista makromuuttujia, esimerkkilaskelmat
2.3 HaeParam_KotihTukiSIMULx = Tyhjä makro, jolla voidaan korvata lainsäädäntöä kuvaavien makrojen sisällä oleva parametrien haku
2.4 KuuNro_KotihTukiSIMUL = Kuukausinumeron muodostus, simulointi
2.4 KuuNro_KotihTukiSIMULx = Kuukausinumeron muodostus, simulointi
2.5 KuuNro_KotihTukiESIM = Kuukausinumeron muodostus, esimerkkilaskelmat
3.1 IkaKuuk_KotihTuki = Makro, joka laskee ne kuukaudet, jolloin henkilö on tietyllä ikävälillä tarkasteluvuoden aikana
3.2 JarjLuku = Makro, joka laskee lapsille järjestysluvun iän perusteella
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

%MACRO HaeParam_KotihTukiSIMUL(mvuosi, mkuuk, minf)/STORE
DES = 'KOTIHTUKI, SIMUL: Makro, joka tekee KOTIHTUKI-mallin parametreista makromuuttujia, simulointilaskelmat';

%LET valuutta = %SYSFUNC(IFN(&mvuosi < 2002, &euro, 1));
%LET kuuknro = %EVAL((&mvuosi - &paramalkukt) * 12 + &mkuuk);
%LET taulu_kt = %SYSFUNC(OPEN(PARAM.&PKOTIHTUKI, i));
%LET w = %SYSFUNC(REWIND(&taulu_kt));
%LET w = %SYSFUNC(FETCHOBS(&taulu_kt, 1));
%LET y = %SYSFUNC(GETVARN(&taulu_kt, 1));
%LET z = %SYSFUNC(GETVARN(&taulu_kt, 2));
%LET testi = %EVAL((&y - &paramalkukt) * 12 + &z);
%IF &testi <= &kuuknro %THEN;
%ELSE %DO %UNTIL ((&testi <= &kuuknro) OR (&testi = 1));
        %LET w = %SYSFUNC(FETCH(&taulu_kt));
        %LET y = %SYSFUNC(GETVARN(&taulu_kt, 1));
        %LET z = %SYSFUNC(GETVARN(&taulu_kt, 2));
        %LET testi = %EVAL((&y - &paramalkukt) * 12 + &z);
%END;
%IF &w = -1 %THEN %DO;
        %LET riveja = %SYSFUNC(ATTRN(&taulu_kt, NLOBS));
        %LET w = %SYSFUNC(FETCHOBS(&taulu_kt, &riveja));
%END;

%LET Perus = (%SYSFUNC(GETVARN(&taulu_kt, %SYSFUNC(VARNUM(&taulu_kt, Perus)))) / &valuutta) * &minf;
%LET Sisar = (%SYSFUNC(GETVARN(&taulu_kt, %SYSFUNC(VARNUM(&taulu_kt, Sisar)))) / &valuutta) * &minf;
%LET Lisa = (%SYSFUNC(GETVARN(&taulu_kt, %SYSFUNC(VARNUM(&taulu_kt, Lisa)))) / &valuutta) * &minf;
%LET KHRaja1 = (%SYSFUNC(GETVARN(&taulu_kt, %SYSFUNC(VARNUM(&taulu_kt, KHRaja1)))) / &valuutta) * &minf;
%LET KHRaja2 = (%SYSFUNC(GETVARN(&taulu_kt, %SYSFUNC(VARNUM(&taulu_kt, KHRaja2)))) / &valuutta) * &minf;
%LET KHRaja3 = (%SYSFUNC(GETVARN(&taulu_kt, %SYSFUNC(VARNUM(&taulu_kt, KHRaja3)))) / &valuutta) * &minf;
%LET SisarMuu = (%SYSFUNC(GETVARN(&taulu_kt, %SYSFUNC(VARNUM(&taulu_kt, SisarMuu)))) / &valuutta) * &minf;
%LET SisarKerr = %SYSFUNC(GETVARN(&taulu_kt, %SYSFUNC(VARNUM(&taulu_kt, SisarKerr))));
%LET Kerr1 = %SYSFUNC(GETVARN(&taulu_kt, %SYSFUNC(VARNUM(&taulu_kt, Kerr1))));
%LET Kerr2 = %SYSFUNC(GETVARN(&taulu_kt, %SYSFUNC(VARNUM(&taulu_kt, Kerr2))));
%LET Kerr3 = %SYSFUNC(GETVARN(&taulu_kt, %SYSFUNC(VARNUM(&taulu_kt, Kerr3))));
%LET OsKerr = %SYSFUNC(GETVARN(&taulu_kt, %SYSFUNC(VARNUM(&taulu_kt, OsKerr))));
%LET OsRaha = (%SYSFUNC(GETVARN(&taulu_kt, %SYSFUNC(VARNUM(&taulu_kt, OsRaha)))) / &valuutta) * &minf;
%LET PHRaja1 = (%SYSFUNC(GETVARN(&taulu_kt, %SYSFUNC(VARNUM(&taulu_kt, PHRaja1)))) / &valuutta) * &minf;
%LET PHRaja2 = (%SYSFUNC(GETVARN(&taulu_kt, %SYSFUNC(VARNUM(&taulu_kt, PHRaja2)))) / &valuutta) * &minf;
%LET PHRaja3 = (%SYSFUNC(GETVARN(&taulu_kt, %SYSFUNC(VARNUM(&taulu_kt, PHRaja3)))) / &valuutta) * &minf;
%LET PHKerr1 = %SYSFUNC(GETVARN(&taulu_kt, %SYSFUNC(VARNUM(&taulu_kt, PHKerr1))));
%LET PHKerr2 = %SYSFUNC(GETVARN(&taulu_kt, %SYSFUNC(VARNUM(&taulu_kt, PHKerr2))));
%LET PHKerr3 = %SYSFUNC(GETVARN(&taulu_kt, %SYSFUNC(VARNUM(&taulu_kt, PHKerr3))));
%LET PHVahenn = (%SYSFUNC(GETVARN(&taulu_kt, %SYSFUNC(VARNUM(&taulu_kt, PHVahenn)))) / &valuutta) * &minf;
%LET PHAlennus = %SYSFUNC(GETVARN(&taulu_kt, %SYSFUNC(VARNUM(&taulu_kt, PHAlennus))));
%LET PHYlaraja = (%SYSFUNC(GETVARN(&taulu_kt, %SYSFUNC(VARNUM(&taulu_kt, PHYlaraja)))) / &valuutta) * &minf;
%LET PHYlaraja2 = (%SYSFUNC(GETVARN(&taulu_kt, %SYSFUNC(VARNUM(&taulu_kt, PHYlaraja2)))) / &valuutta) * &minf;
%LET PHAlaraja = (%SYSFUNC(GETVARN(&taulu_kt, %SYSFUNC(VARNUM(&taulu_kt, PHAlaraja)))) / &valuutta) * &minf;
%LET PHRaja4 = (%SYSFUNC(GETVARN(&taulu_kt, %SYSFUNC(VARNUM(&taulu_kt, PHRaja4)))) / &valuutta) * &minf;
%LET PHRaja5 = (%SYSFUNC(GETVARN(&taulu_kt, %SYSFUNC(VARNUM(&taulu_kt, PHRaja5)))) / &valuutta) * &minf;
%LET PHKerr4 = %SYSFUNC(GETVARN(&taulu_kt, %SYSFUNC(VARNUM(&taulu_kt, PHKerr4))));
%LET PHKerr5 = %SYSFUNC(GETVARN(&taulu_kt, %SYSFUNC(VARNUM(&taulu_kt, PHKerr5))));
%LET loppu = %SYSFUNC(CLOSE(&taulu_kt));

%MEND HaeParam_KotihTukiSIMUL;


/* 2.2 Tämä makro tekee saman asian kuin edellinen, mutta se toimii vain osana data-askelta.
       Makro luo useita muuttujia data-taulukkoon. Makroa käytetään esimerkkilaskelmissa (tyyppi = ESIM).
           Inflaatio- ja valuuttakurssimuunnokset tehdään tässä vaiheessa */

* Makron parametrit:
        mvuosi: Vuosi, jonka lainsäädäntöä käytetään
        mkuuk: Kuukausi, jonka lainsäädäntöä käytetään
        minf: Deflaattori euromääräisten parametrien kertomiseksi ;

%MACRO HaeParam_KotihTukiESIM(mvuosi, mkuuk, minf)/STORE
DES = 'KOTIHTUKI, ESIM: Makro, joka tekee KOTIHTUKI-mallin parametreista makromuuttujia, esimerkkilaskelmat';

%LET valuutta = IFN(&mvuosi < 2002, &euro,  1);
kuuknro = (&mvuosi - &paramalkukt) * 12 + &mkuuk;
IF _N_ = 1 OR taulu_kt =. THEN taulu_kt = OPEN("PARAM.&PKOTIHTUKI", "i");
RETAIN taulu_kt;
w = REWIND(taulu_kt);
w = FETCHOBS(taulu_kt, 1);
y = GETVARN(taulu_kt, 1);
z = GETVARN(taulu_kt, 2);
testi = (y - &paramalkukt) * 12 + z;
IF testi <= kuuknro THEN;
ELSE DO UNTIL (testi <= kuuknro);
        w = FETCH(taulu_kt);
        y = GETVARN(taulu_kt, 1);
        z = GETVARN(taulu_kt, 2);
        testi = (y - &paramalkukt) * 12 + z;
END;
IF w = -1 THEN DO;
        %LET riveja = ATTRN(taulu_kt, "NLOBS");
        w = FETCHOBS(taulu_kt, &riveja);
END;

%LET Perus = ((GETVARN(taulu_kt, VARNUM(taulu_kt, "Perus"))) / &valuutta) * &minf;
%LET Sisar = ((GETVARN(taulu_kt, VARNUM(taulu_kt, "Sisar"))) / &valuutta) * &minf;
%LET Lisa = ((GETVARN(taulu_kt, VARNUM(taulu_kt, "Lisa"))) / &valuutta) * &minf;
%LET KHRaja1 = ((GETVARN(taulu_kt, VARNUM(taulu_kt, "KHRaja1"))) / &valuutta) * &minf;
%LET KHRaja2 = ((GETVARN(taulu_kt, VARNUM(taulu_kt, "KHRaja2"))) / &valuutta) * &minf;
%LET KHRaja3 = ((GETVARN(taulu_kt, VARNUM(taulu_kt, "KHRaja3"))) / &valuutta) * &minf;
%LET SisarMuu = ((GETVARN(taulu_kt, VARNUM(taulu_kt, "SisarMuu"))) / &valuutta) * &minf;
%LET SisarKerr = GETVARN(taulu_kt, VARNUM(taulu_kt, "SisarKerr"));
%LET Kerr1 = GETVARN(taulu_kt, VARNUM(taulu_kt, "Kerr1"));
%LET Kerr2 = GETVARN(taulu_kt, VARNUM(taulu_kt, "Kerr2"));
%LET Kerr3 = GETVARN(taulu_kt, VARNUM(taulu_kt, "Kerr3"));
%LET OsKerr = GETVARN(taulu_kt, VARNUM(taulu_kt, "OsKerr"));
%LET OsRaha = ((GETVARN(taulu_kt, VARNUM(taulu_kt, "OsRaha"))) / &valuutta) * &minf;
%LET PHRaja1 = ((GETVARN(taulu_kt, VARNUM(taulu_kt, "PHRaja1"))) / &valuutta) * &minf;
%LET PHRaja2 = ((GETVARN(taulu_kt, VARNUM(taulu_kt, "PHRaja2"))) / &valuutta) * &minf;
%LET PHRaja3 = ((GETVARN(taulu_kt, VARNUM(taulu_kt, "PHRaja3"))) / &valuutta) * &minf;
%LET PHKerr1 = GETVARN(taulu_kt, VARNUM(taulu_kt, "PHKerr1"));
%LET PHKerr2 = GETVARN(taulu_kt, VARNUM(taulu_kt, "PHKerr2"));
%LET PHKerr3 = GETVARN(taulu_kt, VARNUM(taulu_kt, "PHKerr3"));
%LET PHVahenn = ((GETVARN(taulu_kt, VARNUM(taulu_kt, "PHVahenn"))) / &valuutta) * &minf;
%LET PHAlennus = GETVARN(taulu_kt, VARNUM(taulu_kt, "PHAlennus"));
%LET PHYlaraja = ((GETVARN(taulu_kt, VARNUM(taulu_kt, "PHYlaraja"))) / &valuutta) * &minf;
%LET PHYlaraja2 = ((GETVARN(taulu_kt, VARNUM(taulu_kt, "PHYlaraja2"))) / &valuutta) * &minf;
%LET PHAlaraja = ((GETVARN(taulu_kt, VARNUM(taulu_kt, "PHAlaraja"))) / &valuutta) * &minf;
%LET PHRaja4 = ((GETVARN(taulu_kt, VARNUM(taulu_kt, "PHRaja4"))) / &valuutta) * &minf;
%LET PHRaja5 = ((GETVARN(taulu_kt, VARNUM(taulu_kt, "PHRaja5"))) / &valuutta) * &minf;
%LET PHKerr4 = GETVARN(taulu_kt, VARNUM(taulu_kt, "PHKerr4"));
%LET PHKerr5 = GETVARN(taulu_kt, VARNUM(taulu_kt, "PHKerr5"));

%MEND HaeParam_KotihTukiESIM;


/* 2.3 Tyhjä makro, jolla voidaan korvata lainsäädäntöä kuvaavien
           makrojen sisällä oleva parametrien haku, jos parametrit on määritelty
           ennen simulointiohjelman ajoa. Käytetään, jos halutaan käyttää vuosikeskiarvon laskemisessa tietyn
           kuukauden lainsäädäntöä (tyyppi = SIMULx). */

* Makron parametrit:
        mvuosi: Vuosi, jonka lainsäädäntöä käytetään
        mkuuk: Kuukausi, jonka lainsäädäntöä käytetään
        minf: Deflaattori euromääräisten parametrien kertomiseksi ;

%MACRO HaeParam_KotihTukiSIMULx (mvuosi, mkuuk, minf)/STORE
DES = 'KOTIHTUKI, SIMULx: Tyhjä makro, jolla voidaan korvata lainsäädäntöä kuvaavien makrojen sisällä oleva parametrien haku';
%MEND HaeParam_KotihTukiSIMULx;


/* 2.4 Makro, jolla vuosiluvusta ja kuukauden numerosta johdetaan järjestysluku ajankohtien vertailua varten.
           Jos tarjotaan parametritaulukon lähtövuotta aikaisempaa arvoa, valitaan ensimmäinen mahdollinen kuukausi.
           Makroa käytetään varsinaisissa simulointilaskelmissa */

* Makron parametrit:
        nro: Makron tulosmuuttuja, ajankohdan (vuosi ja kuukausi) järjestysluku
        mvuosi: Vuosi, jonka lainsäädäntöä käytetään
        mkuuk: Kuukausi, jonka lainsäädäntöä käytetään ;

%MACRO KuuNro_KotihTukiSIMUL(nro, mvuosi, mkuuk)/STORE
DES = 'KOTIHTUKI, SIMUL: Kuukausinumeron muodostus, simulointi';

&nro = 12 * %EVAL (&mvuosi - &paramalkukt) + &mkuuk;
%IF &mvuosi < &paramalkukt %THEN &nro = 1;
%MEND KuuNro_KotihTukiSIMUL;

%MACRO KuuNro_KotihTukiSIMULx(nro, mvuosi, mkuuk)/STORE
DES = 'KOTIHTUKI, SIMULx: Kuukausinumeron muodostus, simulointi';

&nro = 12 * %EVAL (&mvuosi - &paramalkukt) + &mkuuk;
%IF &mvuosi < &paramalkukt %THEN &nro = 1;
%MEND KuuNro_KotihTukiSIMULx;


/* 2.5 Edellisestä makrosta versio, joka toimii vain osana data-askelta. Makroa käytetään esimerkkilaskelmissa. */

%MACRO KuuNro_KotihTukiESIM(nro, mvuosi, mkuuk)/STORE
DES = 'KOTIHTUKI, ESIM: Kuukausinumeron muodostus, esimerkkilaskelmat';

&nro = 12 * (&mvuosi - &paramalkukt) + &mkuuk;
IF &mvuosi < &paramalkukt THEN &nro = 1;
%MEND KuuNro_KotihTukiESIM;


/* 3. Simuloinnissa tarvittavat apumakrot */

/* 3.1 Makro, joka laskee ne kuukaudet, jolloin henkilö on tietyllä
       ikävälillä tarkasteluvuoden aikana, kun ikäkuukausia vuoden
       lopussa on kaiken kaikkiaan ikakk. */

*Makron parametrit:
    tulos: Kuukaudet, jolloin henkiö on esim. 3-17-vuotias tarkasteluvuonna
        mvuosi: Vuosi, jonka lainsäädäntöä käytetään
        mkuuk: Kuukausi, jonka lainsäädäntöä käytetään
        ika_ala: Alaikäraja, v (esim. 3, jos kyse on vähintään 3-vuotiasta)
        ika_yla: Yläikäraja, v (esim. 17, kun kyse on alle 18-vuotiasta)
        ikakk: Ikäkuukaudet yhteensä tarkasteluvuoden lopussa ;

%MACRO IkaKuuk_Phoito(ika_kuuk, ika_ala, ika_yla, ikakk)/STORE
DES = 'KOTIHTUKI: Makro, joka laskee ne kuukaudet, jolloin henkilö on tietyllä
ikävälillä tarkasteluvuoden aikana';

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
%MEND IkaKuuk_Phoito;


/* 3.2 Makro, joka laskee lapsille järjestysluvun iän perusteella */

%MACRO JarjLuku() / STORE
DES = 'KOTIHTUKI: Makro, joka laskee lapsille järjestysluvun iän perusteella';

PROC SORT DATA = TEMP.PHOITO_LAPSET;
BY knro hnro syvu syntkk;
RUN;

DATA TEMP.PHOITO_LAPSET;
RETAIN SISAR 0;
SET TEMP.PHOITO_LAPSET;
BY knro;

IF hoiaikak > 0 OR hoiaikao > 0 THEN DO;
        SISAR = SUM(SISAR, 1);
END;

ELSE DO;
        SISAR = 0;
END;

RUN;

%MEND JarjLuku;
