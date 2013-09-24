/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyˆdynt‰‰ Tilastokeskuksen yleisten
* k‰yttˆehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto p‰‰hakemistossa.
******************************************************************************/

/*********************************************************** *
*  Kuvaus: Yleisen asumistuen simuloinnin apumakroja         *
*  Tekij‰: Pertti Honkanen/ Kela                             *
*  Luotu: 12.09.2011                                         *
*  Viimeksi p‰ivitetty: 2.4.2012                             *
*  P‰ivitt‰j‰: Pertti Honkanen/ Kela                         *
**************************************************************/


/* 1. SISƒLLYS */

/* Tiedosto sis‰lt‰‰ seuraavat makrot */

/*
2.1 HaeParam_AsumTukiSIMUL = Makro, joka tekee ASUMTUKI-mallin parametreista makromuuttujia, simulointilaskelmat
2.2 HaeParam_AsumTukiESIM = Makro, joka tekee ASUMTUKI-mallin parametreista makromuuttujia, esimerkkilaskelmat
3.1 HaeParam_VuokraNormit = Makro, joka tarvitaan vuokranormitaulukon lukemiseen
3.2 HaeParam_EnimmVuokra = Makro, joka etsii osa-asuntojen enimm‰isasumismenotaulukosta halutun vuoden rivit
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

%MACRO HaeParam_AsumTukiSIMUL (mvuosi, minf)/STORE
DES = 'ASUMTUKI, SIMUL: Makro, joka tekee ASUMTUKI-mallin parametreista makromuuttujia,
simulointilaskelmat';

%LET valuutta = %SYSFUNC(IFN(&mvuosi < 2002, &euro, 1));
%LET taulu_ya = %SYSFUNC(OPEN(PARAM.&PASUMTUKI, i));
%SYSCALL SET(taulu_ya);
%LET w = %SYSFUNC(FETCH(&taulu_ya));
%IF &mvuosi >= %SYSFUNC(GETVARN(&taulu_ya, 1)) %THEN;
%ELSE %DO %UNTIL (%SYSFUNC(GETVARN(&taulu_ya, 1)) = &mvuosi OR &w = -1);
        %LET w = %SYSFUNC(FETCH(&taulu_ya));
%END;
%LET w = %SYSFUNC(CLOSE(&taulu_ya));

%LET YksHVah = (&YksHVah / &valuutta) * &minf;
%LET OmaVastVah = (&OmaVastVah / &valuutta) * &minf;
%LET APieninTuki = (&APieninTuki / &valuutta) * &minf;
%LET AVarRaja1 = (&AVarRaja1 / &valuutta) * &minf;
%LET AVarRaja2 = (&AVarRaja2 / &valuutta) * &minf;
%LET AVarRaja3 = (&AVarRaja3 / &valuutta) * &minf;
%LET AVarRaja4 = (&AVarRaja4 / &valuutta) * &minf;
%LET AVarRaja5 = (&AVarRaja5 / &valuutta) * &minf;
%LET AVarRaja6 = (&AVarRaja6 / &valuutta) * &minf;
%LET VesiMaksu = (&VesiMaksu / &valuutta) * &minf;
%LET HoitoMenoAs = (&HoitoMenoAs / &valuutta) * &minf;
%LET HoitoMenoHenk = (&HoitoMenoHenk / &valuutta) * &minf;
%LET HoitoMeno1 = (&HoitoMeno1 / &valuutta) * &minf;
%LET HoitoMeno2 = (&HoitoMeno2 / &valuutta)* &minf;
%LET HoitoMeno3 = (&HoitoMeno3 / &valuutta)* &minf;

%MEND HaeParam_AsumTukiSIMUL;

/* 2.2 T‰m‰ makro tekee saman asian kuin edellinen, mutta se toimii vain osana data-askelta.
       Makro luo useita muuttujia data-taulukkoon. Makroa k‰ytet‰‰n esimerkkilaskelmissa (tyyppi = ESIM).
           Inflaatio- ja valuuttakurssimuunnokset tehd‰‰n t‰ss‰ vaiheessa */

* Makron parametrit:
        mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
        minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi ;

%MACRO HaeParam_AsumTukiESIM (mvuosi, minf)/STORE
DES = 'ASUMTUKI, ESIM: Makro, joka tekee ASUMTUKI-mallin parametreista makromuuttujia,
esimerkkilaskelmat';

%IF &TYYPPI = ESIM %THEN %DO;

        %LET valuutta = IFN(&mvuosi < 2002, &euro,  1);
        IF _N_ = 1 OR taulu_ya = . THEN taulu_ya = OPEN ("PARAM.&PASUMTUKI" , "i");
        RETAIN taulu_ya;
		X = REWIND(taulu_ya);
        X = FETCHOBS(taulu_ya, 1);
        IF GETVARN(taulu_ya, 1) <= &mvuosi THEN;
        ELSE DO UNTIL (GETVARN(taulu_ya, 1)= &mvuosi OR X = -1);
                X = FETCH(taulu_ya);
        END;
        IF X = -1 THEN DO;
                %LET riveja_ya = ATTRN(taulu_ya, 'NLOBS');
                X = FETCHOBS(taulu_ya, &riveja_ya);
        END;


        %LET ATukiPros = GETVARN(taulu_ya, VARNUM(taulu_ya, 'ATukiPros'));
        %LET KorkoTukiPros = GETVARN(taulu_ya, VARNUM(taulu_ya, 'KorkoTukiPros'));
        %LET AravaPros = GETVARN(taulu_ya, VARNUM(taulu_ya, 'AravaPros'));
        %LET EnimmN1 = GETVARN(taulu_ya, VARNUM(taulu_ya, 'EnimmN1'));
        %LET EnimmN2 = GETVARN(taulu_ya, VARNUM(taulu_ya, 'EnimmN2'));
        %LET EnimmN3 = GETVARN(taulu_ya, VARNUM(taulu_ya, 'EnimmN3'));
        %LET EnimmN4 = GETVARN(taulu_ya, VARNUM(taulu_ya, 'EnimmN4'));
        %LET EnimmN5 = GETVARN(taulu_ya, VARNUM(taulu_ya, 'EnimmN5'));
        %LET EnimmN6 = GETVARN(taulu_ya, VARNUM(taulu_ya, 'EnimmN6'));
        %LET EnimmN7 = GETVARN(taulu_ya, VARNUM(taulu_ya, 'EnimmN7'));
        %LET EnimmN8 = GETVARN(taulu_ya, VARNUM(taulu_ya, 'EnimmN8'));
        %LET EnimmNplus = GETVARN(taulu_ya, VARNUM(taulu_ya, 'EnimmNplus'));
        %LET YksHVah = (GETVARN(taulu_ya, VARNUM(taulu_ya, 'YksHVah')) / &valuutta) * &minf ;
        %LET OmaVastVah = (GETVARN(taulu_ya, VARNUM(taulu_ya, 'OmaVastVah')) / &valuutta) * &minf;
        %LET APieninTuki = (GETVARN(taulu_ya, VARNUM(taulu_ya, 'APieninTuki')) / &valuutta) * &minf;
        %LET AVarRaja1 = (GETVARN(taulu_ya, VARNUM(taulu_ya, 'AVarRaja1')) / &valuutta) * &minf;
        %LET AVarRaja2 = (GETVARN(taulu_ya, VARNUM(taulu_ya, 'AVarRaja2')) / &valuutta) * &minf;
        %LET AVarRaja3 = (GETVARN(taulu_ya, VARNUM(taulu_ya, 'AVarRaja3')) / &valuutta) * &minf;
        %LET AVarRaja4 = (GETVARN(taulu_ya, VARNUM(taulu_ya, 'AVarRaja4')) / &valuutta) * &minf;
        %LET AVarRaja5 = (GETVARN(taulu_ya, VARNUM(taulu_ya, 'AVarRaja5')) / &valuutta) * &minf;
        %LET AVarRaja6 = (GETVARN(taulu_ya, VARNUM(taulu_ya, 'AVarRaja6')) / &valuutta) * &minf;
        %LET VesiMaksu = (GETVARN(taulu_ya, VARNUM(taulu_ya, 'VesiMaksu')) / &valuutta) * &minf;
        %LET HoitoMenoAs = (GETVARN(taulu_ya, VARNUM(taulu_ya, 'HoitoMenoAs')) / &valuutta) * &minf;
        %LET HoitoMenoHenk = (GETVARN(taulu_ya, VARNUM(taulu_ya, 'HoitoMenoHenk')) / &valuutta) * &minf;
        %LET HoitoMeno1 = (GETVARN(taulu_ya, VARNUM(taulu_ya, 'HoitoMeno1')) / &valuutta) * &minf;
        %LET HoitoMeno2 = (GETVARN(taulu_ya, VARNUM(taulu_ya, 'HoitoMeno2')) / &valuutta) * &minf;
        %LET HoitoMeno3 = (GETVARN(taulu_ya, VARNUM(taulu_ya, 'HoitoMeno3')) / &valuutta) * &minf;
        %LET VarallPros = GETVARN(taulu_ya, VARNUM(taulu_ya, 'VarallPros'));

%END;

%MEND HaeParam_AsumTukiESIM ;


/* 3 Simuloinnissa tarvittavat apumakrot */

/* 3.1 Makro joka tarvitaan vuokranormitaulukon lukemiseen.
           Vuokranormitaulukosta erotellaan halutun vuoden normit sek‰
           tehd‰‰n pinta-alaluokitusta kuvaava taulukko */

* Makron parametrit:
        mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n;

%MACRO HaeParam_VuokraNormit(mvuosi)/STORE
DES = 'ASUMTUKI: Makro, joka tarvitaan vuokranormitaulukon lukemiseen' ;

%IF &mvuosi < &paramalkuyat %THEN %LET mvuosi = &paramalkuyat;
%ELSE %IF &mvuosi > &paramloppuyat %THEN %LET mvuosi = &paramloppuyat;


DATA PARAM.normit&mvuosi;
SET PARAM.&PASUMTUKI_VUOKRANORMIT;
WHERE vuosi = &mvuosi;
RUN;

* Vuokranormitaulukosta erotellaan pinta-alaluokituksen sis‰lt‰v‰ sarake ;

DATA PARAM.alat;
SET PARAM.normit&mvuosi (KEEP = ala);
RUN;

* J‰rjestet‰‰n halutun vuoden vuokranormitaulukko k‰‰nteiseen j‰rjestykseen pinta-alan mukaan ;

PROC SORT  DATA = PARAM.normit&mvuosi;
BY DESCENDING ala;
RUN;

* Seuraavat toimet tulisi erottaa t‰st‰ makrosta ;

* Normitaulukon m‰‰rittelyist‰ tehd‰‰n taulukko ;

PROC CONTENTS DATA = PARAM.normit&mvuosi
OUT = PARAM.normisarak NOPRINT;
RUN;

* Edell‰ luodusta taulukosta erotellaan rakennuksen valmistumisvuotta
tarkoittavien sarakkeiden nimet, joista edelleen erotetaan vuosiluvut
omaksi sarakkeeksi. T‰t‰ k‰ytet‰‰n NormvuokraS-makroissa haettaessa vuokranormitaulukosta
oikea sarake ;

DATA PARAM.normisarakb (KEEP = taite taiten);
SET PARAM.normisarak;
WHERE SUBSTRN(name, 1, 4) = 'Valm';
taite = SUBSTRN(name, 5, 4);
taiten = INPUT(taite, 4.);
RUN;

* J‰rjestet‰‰n em. taulukko k‰‰nteiseen j‰rjestykseen ;

PROC SORT DATA = PARAM.normisarakb;
BY DESCENDING taiten ;
RUN;

%MEND HaeParam_VuokraNormit;

/* 3.2 Makro, joka etsii osa-asuntojen enimm‰isasumismenotaulukosta
           halutun vuoden rivit */

* Makron parametrit:
        mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n;

%MACRO HaeParam_EnimmVuokra (mvuosi)/STORE
DES = 'Makro, joka etsii osa-asuntojen enimm‰isasumismenotaulukosta halutun vuoden rivit' ;

%IF &mvuosi < &paramalkuyat %THEN %LET mvuosi = &paramalkuyat;
%ELSE %IF &mvuosi > &paramloppuyat %THEN %LET mvuosi = &paramloppuyat;

DATA PARAM.penimmtaulu&mvuosi;
SET PARAM.&PASUMTUKI_ENIMMMENOT;
WHERE vuosi = &mvuosi;
RUN;

%MEND HaeParam_EnimmVuokra;
