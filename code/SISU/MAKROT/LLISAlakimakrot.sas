/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyödyntää Tilastokeskuksen yleisten
* käyttöehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto päähakemistossa.
******************************************************************************/

/************************************************************ 
* Kuvaus: Lapsilisän lainsäädäntöä makroina					* 
* Tekijä: Maria Valaste / KELA 								* 
* Luotu: 05.10.2011 										* 
* Viimeksi päivitetty: 15.12.2011 							* 
* Päivittäjä: Olli Kannas / TK								* 
************************************************************/


/* 1. SISÄLLYS */

/* Tiedosto sisältää seuraavat makrot */

/*
2. LLisaKS = Lapsilisä eri-ikäisten lasten lukumäärän mukaan kuukausitasolla
3. LLisaVS = Lapsilisä eri-ikäisten lasten lukumäärän mukaan kuukausitasolla vuosikeskiarvona
4. AitAvustKS = Äitiysavustus
5. AitAvustVS = Äitiysavustus vuosikeskiarvona
6. ElatTukiKS = Elatustuki kuukausitasolla
7. ElatTukiVS = Elatustuki kuukausitasolla vuosikeskiarvona
8. LLisaK1S = Lapsilisä yhdestä lapsesta järjestysluvun mukaan kuukausitasolla
9. LLisaV1S = Lapsilisä yhdestä lapsesta järjestysluvun mukaan kuukausitasolla vuosikeskiarvona
*/


/* 2. Makro laskee lapsilisän eri-ikäisten lasten lukumäärän mukaan kuukausitasolla */

* Makron parametrit:
    tulos: Makron tulosmuuttuja, lapsilisäkuukaudessa, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	puoliso: Onko henkilöllä puoliso (0/1)
	lapsiaalle_3_v: Alle 3-vuotiaiden lasten lukumäärä 
	lapsia_3_15_v: 3-15-vuotiaiden lasten lukumäärä
	lapsia_16_v: 16-vuotiaiden lasten lukumäärä;


%MACRO LLisaKS(tulos, mvuosi, mkuuk, minf, puoliso, lapsiaAlle_3_v, lapsia_3_15_v, lapsia_16_v)/STORE
DES = 'LAPSILISÄ: Lapsilisä eri-ikäisten lasten lukumäärän mukaan kuukausitasolla';

%HaeParam_LLisa&tyyppi(&mvuosi, &mkuuk, &minf);
%KuuNro_LLisa&tyyppi(kuuid, &mvuosi, &mkuuk);

IF not(&puoliso = 0) THEN yksinhuoltaja = 0; * Ei yksinhuoltaja;
ELSE yksinhuoltaja = 1;

*Lapsilisän ikärajan muutos kuukaudesta 1994/1 lähtien;
IF kuuid >= 12 * (1994 - &paramalkull) + 1 THEN
lapsia = SUM(&lapsiaAlle_3_v, &lapsia_3_15_v, &lapsia_16_v);
ELSE lapsia = SUM(&lapsiaAlle_3_v, &lapsia_3_15_v);

SELECT (lapsia);
	WHEN(0) temp = 0;
	WHEN(1) temp = &Lapsi1;
	WHEN(2) temp = SUM(&Lapsi1, &Lapsi2);
	WHEN(3) temp = SUM(&Lapsi1, &Lapsi2, &Lapsi3);
	WHEN(4) temp = SUM(&Lapsi1, &Lapsi2, &Lapsi3, &Lapsi4);
	WHEN(5) temp = SUM(&Lapsi1, &Lapsi2, &Lapsi3, &Lapsi4, &Lapsi5);
	OTHERWISE temp = SUM(&Lapsi1, &Lapsi2, &Lapsi3, &Lapsi4, &Lapsi5, ((lapsia-5) * &Lapsi5));
END;
temp = SUM(temp, (&lapsiaAlle_3_v * &alle3v), (lapsia * &yksHuolt * yksinhuoltaja));

*Jatkettu lapsilisä kuukausina 1986/10 - 1993/12;
IF kuuid >= 12 * (1986 - &paramalkull) + 10 AND kuuid <= 12 * (1993 - &paramalkull) + 12
THEN temp = SUM(temp, (&lapsia_16_v * &lapsi1));

&tulos = temp; 
DROP temp yksinhuoltaja kuuid;
%MEND LLisaKS;


/* 3. Makro laskee lapsilisän eri-ikäisten lasten lukumäärän mukaan kuukausitasolla vuosikeskiarvona */

* Makron parametrit:
    tulos: Makron tulosmuuttuja, lapsilisä, e/kk (vuosikeskiarvo) 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	puoliso: Onko henkilöllä puoliso (0/1)
	lapsiaAlle_3_v: Alle 3-vuotiaiden lasten lukumäärä 
	lapsia_3_15_v: 3-15-vuotiaiden lasten lukumäärä
	lapsia_16_v: 16-vuotiaiden lasten lukumäärä;

%MACRO LLisaVS(tulos, mvuosi, minf, puoliso, lapsiaAlle_3_v, lapsia_3_15_v, lapsia_16_v)/STORE
DES = 'LAPSILISÄ: Lapsilisä eri-ikäisten lasten lukumäärän mukaan kuukausitasolla vuosikeskiarvona';

raha = 0;

%DO i = 1 %TO 12;
	%LLisaKS(temp, &mvuosi, &i, &minf, &puoliso, &lapsiaAlle_3_v, &lapsia_3_15_v, &lapsia_16_v);
  	raha = SUM(raha, temp);
%END;
&tulos = raha / 12;
DROP raha temp;
%MEND LLisaVS; 


/* 4. Makro laskee äitiysavustuksen */

* Makron parametrit:
    tulos: Makron tulosmuuttuja, äitiysavustus, e
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	syntlapsia: Syntyneiden lasten lukumäärä;

%MACRO AitAvustKS(tulos, mvuosi, mkuuk, minf, syntlapsia)/STORE
DES = 'LAPSILISÄ: Äitiysavustus';

%HaeParam_LLisa&tyyppi(&mvuosi, &mkuuk, &minf);
%KuuNro_LLisa&tyyppi(kuuid, &mvuosi, &mkuuk);

/* Äitiysavustuksen suuruus on määritelty kutakin syntynyttä tai adoptioon otettua lasta kohden.
Valtioneuvoston asetuksella 30.1.2003/67 tätä periaatetta muutettiin 1.3.2003 lähtien siten, että äitiysavustus
suoritetaan lapsiluvun mukaan korotettuna, jos samanaikaisesti syntyy tai ottolapseksi otetaan useampi
lapsi. Toisesta lapsesta äitiysavustus suoritetaan kaksinkertaisena, kolmannesta kolminkertaisena jne. */

temp = 0;

%IF kuuid >= 12 * (2003 - &paramalkull) + 3 %THEN %DO;
	DO j = 1 TO &syntlapsia; 
	temp = SUM(temp, (j * &AitAv));
	END;
%END;

IF kuuid < 12 * (2003 - &paramalkull) + 3 THEN temp = &syntlapsia * &AitAv;

&tulos = temp; 
DROP temp kuuid j;
%MEND AitAvustKS;


/* 5. Makro laskee äitiysavustuksen vuosikeskiarvona */

* Makron parametrit:
    tulos: Makron tulosmuuttuja, äitiysavustus, e 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	syntlapsia: Syntyneiden lasten lukumäärä;

%MACRO AitAvustVS(tulos, mvuosi, minf, syntlapsia)/STORE
DES = 'LAPSILISÄ: Äitiysavustus vuosikeskiarvona';

raha = 0;
%DO i = 1 %TO 12;
	%AitAvustKS(temp, &mvuosi, &i, &minf, &syntlapsia);
  	raha = SUM(raha, temp);
%END;

&tulos = raha / 12;
DROP raha temp;
%MEND AitAvustVS;


/* 6. Makro laskee elatustuen kuukausitasolla */

* Makron parametrit:
    tulos: Makron tulosmuuttuja, elatustuki, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	puoliso: Onko henkilöllä puoliso (0/1)
	lapsia: Lasten lukumäärä;

%MACRO ElatTukiKS(tulos, mvuosi, mkuuk, minf, puoliso, lapsia)/STORE
DES = 'LAPSILISÄ: Elatustuki kuukausitasolla';

%HaeParam_LLisa&tyyppi(&mvuosi, &mkuuk, &minf);
%KuuNro_LLisa&tyyppi(kuuid, &mvuosi, &mkuuk);

IF &puoliso = 1 THEN temp = &AlenElatTuki * &lapsia;
ELSE temp = &ElatTuki * &lapsia;

&tulos = temp;
DROP temp kuuid;
%MEND ElatTukiKS;


/* 7. Makro laskee elatustuen kuukausitasolla vuosikeskiarvona */

* Makron parametrit:
    tulos: Makron tulosmuuttuja, elatustuki, e/kk (vuosikeskiarvo) 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	puoliso: Onko henkilöllä puoliso (0/1)
	lapsia: Lasten lukumäärä;

%MACRO ElatTukiVS(tulos, mvuosi, minf, puoliso, lapsia)/STORE
DES = 'LAPSILISÄ: Elatustuki kuukausitasolla vuosikeskiarvona';

raha = 0;

%DO i = 1 %TO 12;
	%ElatTukiKS(temp, &mvuosi, &i, &minf, &puoliso, &lapsia);
  	raha = SUM(raha, temp);
%END;

&tulos = raha / 12;
DROP raha temp;
%MEND ElatTukiVS;


/* 8. Makro laskee lapsilisän yhdestä lapsesta järjestysluvun mukaan kuukausitasolla */

* Makron parametrit:
	tulos: Makron tulosmuuttuja, lapsilisä, e/kk
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	puoliso: Onko henkilöllä puoliso (0/1)
	alle_3_v: 1 = On alle 3-vuotias, 0 = Ei ole alle 3-v
	b16v: 1 = On 16-vuotias, 0 = Ei 16-vuotias
	jarj: Lapsen järjestysluku;

%MACRO LLisaK1S(tulos, mvuosi, mkuuk, minf, puoliso, alle_3_v, b16v, jarj)/STORE
DES = 'LAPSILISÄ: Lapsilisä yhdestä lapsesta järjestysluvun mukaan kuukausitasolla';

%HaeParam_LLisa&tyyppi(&mvuosi, &mkuuk, &minf);
%KuuNro_LLisa&tyyppi(kuuid, &mvuosi, &mkuuk);

*Jos järjestysluku ei ole positiivinen, tulos = 0;
IF &jarj < 1 THEN temp = 0;

*Lapsi ei voi olla yhtä aikaa 16-vuotias ja alle 3-vuotias, laitetaan 16-vuotiaaksi. ;
IF &alle_3_v = 1 AND &b16v = 1 THEN DO; 
	alle_3_v = 0; 
END;
ELSE alle_3_v = &alle_3_v ;

SELECT (&jarj);
 	WHEN(0) lapsi = 0; * Tämä lisätty laskentateknisistä syistä;
 	WHEN(1) lapsi = &Lapsi1;
	WHEN(2) lapsi = &Lapsi2;
	WHEN(3) lapsi = &Lapsi3;
	WHEN(4) lapsi = &Lapsi4;
	WHEN(5) lapsi = &Lapsi5;
	OTHERWISE lapsi = &Lapsi5; 
END;

*Jatkettu lapsilisä kuukausina 1986/10 - 1993/12;
*Ei mitään lapsilisää, jos alle 17-vuotias ennen 1986/10;
IF &b16v = 1 AND kuuid < 12 * (1986 - &paramalkull) + 10
THEN lapsi = 0 AND alle_3_v = 0; 
IF &b16v = 1 AND kuuid >= 12 * (1986 - &paramalkull) + 10 AND kuuid <= 12 * (1993 -&paramalkull) + 12
THEN lapsi = &lapsi1;

IF &puoliso = 1 THEN YHuoltaja = 0;
IF &puoliso = 0 THEN YHuoltaja = 1;

*Otetaan huomioon yksinhuoltajalisä;
IF lapsi = 0 THEN temp = 0;
ELSE temp = SUM(lapsi, (&yksHuolt * YHuoltaja));

*Alle 3-vuotiaan lisä;
IF alle_3_v = 1 THEN temp = SUM(temp, &Alle3v);

&tulos = temp; 
DROP temp lapsi YHuoltaja kuuid  alle_3_v;
%MEND LLisaK1S;


/* 9. Makro laskee lapsilisän yhdestä lapsesta järjestysluvun mukaan kuukausitasolla vuosikeskiarvona */

* Makron parametrit:
	tulos: Makron tulosmuuttuja, lapsilisä, e/kk (vuosikeskiarvo) 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	puoliso: Onko henkilöllä puoliso (0/1)
	alle_3_v: 1 = On alle 3-vuotias, 0 = Ei ole alle 3-v
	b16v: 1 = On 16-vuotias, 0 = Ei 16-vuotias
	jarj: Lapsen järjestysluku;

%MACRO LLisaV1S(tulos, mvuosi, minf, puoliso, alle_3_v, b16v, jarj)/STORE
DES = 'LAPSILISÄ: Lapsilisä yhdestä lapsesta järjestysluvun mukaan kuukausitasolla vuosikeskiarvona';

raha = 0;

%DO i = 1 %TO 12;
	%LLisaK1S(temp, &mvuosi, &i, &minf, &puoliso, &alle_3_v, &b16v, &jarj);
  	raha = SUM(raha, temp);
%END;

&tulos = raha / 12;
DROP raha temp;
%MEND LLisaV1S;













