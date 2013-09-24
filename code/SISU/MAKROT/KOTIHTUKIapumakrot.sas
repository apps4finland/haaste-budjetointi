/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hy�dynt�� Tilastokeskuksen yleisten
* k�ytt�ehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto p��hakemistossa.
******************************************************************************/

/************************************************************
* Kuvaus: Kotihoidontuen simuloinnin apumakroja             *
* Tekij�: Maria Valaste / KELA                              *
* Luotu: 09.11.2011                                         *
* Viimeksi p�ivitetty: 20.06.2012                           *
* P�ivitt�j�: Maria Valaste / KELA                          *
*************************************************************/


/* 1. SIS�LLYS */

/* Tiedosto sis�lt�� seuraavat makrot */

/*
2.1 HaeParam_KotihTukiSIMUL = Makro, joka tekee KOTIHTUKI-mallin parametreista makromuuttujia, simulointilaskelmat
2.2 HaeParam_KotihTukiESIM = Makro, joka tekee KOTIHTUKI-mallin parametreista makromuuttujia, esimerkkilaskelmat
2.3 HaeParam_KotihTukiSIMULx = Tyhj� makro, jolla voidaan korvata lains��d�nt�� kuvaavien makrojen sis�ll� oleva parametrien haku
2.4 KuuNro_KotihTukiSIMUL = Kuukausinumeron muodostus, simulointi
2.4 KuuNro_KotihTukiSIMULx = Kuukausinumeron muodostus, simulointi
2.5 KuuNro_KotihTukiESIM = Kuukausinumeron muodostus, esimerkkilaskelmat
3.1 IkaKuuk_KotihTuki = Makro, joka laskee ne kuukaudet, jolloin henkil� on tietyll� ik�v�lill� tarkasteluvuoden aikana
3.2 JarjLuku = Makro, joka laskee lapsille j�rjestysluvun i�n perusteella
*/


/* 2. Parametrien muuttaminen makromuuttujiksi */

/* 2.1 Makro, joka hakee halutun vuoden ja kuukauden parametrit ja tekee niist� makromuuttujat.
           Jos vuosi-kuukausi -yhdistelm�, jota tarjotaan ei esiinny parametritaulukossa, valitaan l�hin mahdollinen ajankohta.
       T�m� makro on itsen�isesti toimiva makro, jota voi k�ytt�� my�s data-askeleen ulkopuolella.
           Makroa k�ytet��n varsinaisissa simulointilaskelmissa (tyyppi = SIMUL).
           Inflaatio- ja valuuttakurssimuunnokset tehd��n t�ss� vaiheessa */

* Makron parametrit:
        mvuosi: Vuosi, jonka lains��d�nt�� k�ytet��n
        mkuuk: Kuukausi, jonka lains��d�nt�� k�ytet��n
        minf: Deflaattori eurom��r�isten parametrien kertomiseksi ;

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


/* 2.2 T�m� makro tekee saman asian kuin edellinen, mutta se toimii vain osana data-askelta.
       Makro luo useita muuttujia data-taulukkoon. Makroa k�ytet��n esimerkkilaskelmissa (tyyppi = ESIM).
           Inflaatio- ja valuuttakurssimuunnokset tehd��n t�ss� vaiheessa */

* Makron parametrit:
        mvuosi: Vuosi, jonka lains��d�nt�� k�ytet��n
        mkuuk: Kuukausi, jonka lains��d�nt�� k�ytet��n
        minf: Deflaattori eurom��r�isten parametrien kertomiseksi ;

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


/* 2.3 Tyhj� makro, jolla voidaan korvata lains��d�nt�� kuvaavien
           makrojen sis�ll� oleva parametrien haku, jos parametrit on m��ritelty
           ennen simulointiohjelman ajoa. K�ytet��n, jos halutaan k�ytt�� vuosikeskiarvon laskemisessa tietyn
           kuukauden lains��d�nt�� (tyyppi = SIMULx). */

* Makron parametrit:
        mvuosi: Vuosi, jonka lains��d�nt�� k�ytet��n
        mkuuk: Kuukausi, jonka lains��d�nt�� k�ytet��n
        minf: Deflaattori eurom��r�isten parametrien kertomiseksi ;

%MACRO HaeParam_KotihTukiSIMULx (mvuosi, mkuuk, minf)/STORE
DES = 'KOTIHTUKI, SIMULx: Tyhj� makro, jolla voidaan korvata lains��d�nt�� kuvaavien makrojen sis�ll� oleva parametrien haku';
%MEND HaeParam_KotihTukiSIMULx;


/* 2.4 Makro, jolla vuosiluvusta ja kuukauden numerosta johdetaan j�rjestysluku ajankohtien vertailua varten.
           Jos tarjotaan parametritaulukon l�ht�vuotta aikaisempaa arvoa, valitaan ensimm�inen mahdollinen kuukausi.
           Makroa k�ytet��n varsinaisissa simulointilaskelmissa */

* Makron parametrit:
        nro: Makron tulosmuuttuja, ajankohdan (vuosi ja kuukausi) j�rjestysluku
        mvuosi: Vuosi, jonka lains��d�nt�� k�ytet��n
        mkuuk: Kuukausi, jonka lains��d�nt�� k�ytet��n ;

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


/* 2.5 Edellisest� makrosta versio, joka toimii vain osana data-askelta. Makroa k�ytet��n esimerkkilaskelmissa. */

%MACRO KuuNro_KotihTukiESIM(nro, mvuosi, mkuuk)/STORE
DES = 'KOTIHTUKI, ESIM: Kuukausinumeron muodostus, esimerkkilaskelmat';

&nro = 12 * (&mvuosi - &paramalkukt) + &mkuuk;
IF &mvuosi < &paramalkukt THEN &nro = 1;
%MEND KuuNro_KotihTukiESIM;


/* 3. Simuloinnissa tarvittavat apumakrot */

/* 3.1 Makro, joka laskee ne kuukaudet, jolloin henkil� on tietyll�
       ik�v�lill� tarkasteluvuoden aikana, kun ik�kuukausia vuoden
       lopussa on kaiken kaikkiaan ikakk. */

*Makron parametrit:
    tulos: Kuukaudet, jolloin henki� on esim. 3-17-vuotias tarkasteluvuonna
        mvuosi: Vuosi, jonka lains��d�nt�� k�ytet��n
        mkuuk: Kuukausi, jonka lains��d�nt�� k�ytet��n
        ika_ala: Alaik�raja, v (esim. 3, jos kyse on v�hint��n 3-vuotiasta)
        ika_yla: Yl�ik�raja, v (esim. 17, kun kyse on alle 18-vuotiasta)
        ikakk: Ik�kuukaudet yhteens� tarkasteluvuoden lopussa ;

%MACRO IkaKuuk_Phoito(ika_kuuk, ika_ala, ika_yla, ikakk)/STORE
DES = 'KOTIHTUKI: Makro, joka laskee ne kuukaudet, jolloin henkil� on tietyll�
ik�v�lill� tarkasteluvuoden aikana';

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


/* 3.2 Makro, joka laskee lapsille j�rjestysluvun i�n perusteella */

%MACRO JarjLuku() / STORE
DES = 'KOTIHTUKI: Makro, joka laskee lapsille j�rjestysluvun i�n perusteella';

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
