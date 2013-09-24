/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hy�dynt�� Tilastokeskuksen yleisten
* k�ytt�ehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto p��hakemistossa.
******************************************************************************/

/************************************************************ 
* Kuvaus: Lapsilis�n lains��d�nt�� makroina					* 
* Tekij�: Maria Valaste / KELA 								* 
* Luotu: 05.10.2011 										* 
* Viimeksi p�ivitetty: 15.12.2011 							* 
* P�ivitt�j�: Olli Kannas / TK								* 
************************************************************/


/* 1. SIS�LLYS */

/* Tiedosto sis�lt�� seuraavat makrot */

/*
2. LLisaKS = Lapsilis� eri-ik�isten lasten lukum��r�n mukaan kuukausitasolla
3. LLisaVS = Lapsilis� eri-ik�isten lasten lukum��r�n mukaan kuukausitasolla vuosikeskiarvona
4. AitAvustKS = �itiysavustus
5. AitAvustVS = �itiysavustus vuosikeskiarvona
6. ElatTukiKS = Elatustuki kuukausitasolla
7. ElatTukiVS = Elatustuki kuukausitasolla vuosikeskiarvona
8. LLisaK1S = Lapsilis� yhdest� lapsesta j�rjestysluvun mukaan kuukausitasolla
9. LLisaV1S = Lapsilis� yhdest� lapsesta j�rjestysluvun mukaan kuukausitasolla vuosikeskiarvona
*/


/* 2. Makro laskee lapsilis�n eri-ik�isten lasten lukum��r�n mukaan kuukausitasolla */

* Makron parametrit:
    tulos: Makron tulosmuuttuja, lapsilis�kuukaudessa, e/kk 
	mvuosi: Vuosi, jonka lains��d�nt�� k�ytet��n
	mkuuk: Kuukausi, jonka lains��d�nt�� k�ytet��n 
	minf: Deflaattori eurom��r�isten parametrien kertomiseksi 
	puoliso: Onko henkil�ll� puoliso (0/1)
	lapsiaalle_3_v: Alle 3-vuotiaiden lasten lukum��r� 
	lapsia_3_15_v: 3-15-vuotiaiden lasten lukum��r�
	lapsia_16_v: 16-vuotiaiden lasten lukum��r�;


%MACRO LLisaKS(tulos, mvuosi, mkuuk, minf, puoliso, lapsiaAlle_3_v, lapsia_3_15_v, lapsia_16_v)/STORE
DES = 'LAPSILIS�: Lapsilis� eri-ik�isten lasten lukum��r�n mukaan kuukausitasolla';

%HaeParam_LLisa&tyyppi(&mvuosi, &mkuuk, &minf);
%KuuNro_LLisa&tyyppi(kuuid, &mvuosi, &mkuuk);

IF not(&puoliso = 0) THEN yksinhuoltaja = 0; * Ei yksinhuoltaja;
ELSE yksinhuoltaja = 1;

*Lapsilis�n ik�rajan muutos kuukaudesta 1994/1 l�htien;
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

*Jatkettu lapsilis� kuukausina 1986/10 - 1993/12;
IF kuuid >= 12 * (1986 - &paramalkull) + 10 AND kuuid <= 12 * (1993 - &paramalkull) + 12
THEN temp = SUM(temp, (&lapsia_16_v * &lapsi1));

&tulos = temp; 
DROP temp yksinhuoltaja kuuid;
%MEND LLisaKS;


/* 3. Makro laskee lapsilis�n eri-ik�isten lasten lukum��r�n mukaan kuukausitasolla vuosikeskiarvona */

* Makron parametrit:
    tulos: Makron tulosmuuttuja, lapsilis�, e/kk (vuosikeskiarvo) 
	mvuosi: Vuosi, jonka lains��d�nt�� k�ytet��n
	mkuuk: Kuukausi, jonka lains��d�nt�� k�ytet��n 
	minf: Deflaattori eurom��r�isten parametrien kertomiseksi 
	puoliso: Onko henkil�ll� puoliso (0/1)
	lapsiaAlle_3_v: Alle 3-vuotiaiden lasten lukum��r� 
	lapsia_3_15_v: 3-15-vuotiaiden lasten lukum��r�
	lapsia_16_v: 16-vuotiaiden lasten lukum��r�;

%MACRO LLisaVS(tulos, mvuosi, minf, puoliso, lapsiaAlle_3_v, lapsia_3_15_v, lapsia_16_v)/STORE
DES = 'LAPSILIS�: Lapsilis� eri-ik�isten lasten lukum��r�n mukaan kuukausitasolla vuosikeskiarvona';

raha = 0;

%DO i = 1 %TO 12;
	%LLisaKS(temp, &mvuosi, &i, &minf, &puoliso, &lapsiaAlle_3_v, &lapsia_3_15_v, &lapsia_16_v);
  	raha = SUM(raha, temp);
%END;
&tulos = raha / 12;
DROP raha temp;
%MEND LLisaVS; 


/* 4. Makro laskee �itiysavustuksen */

* Makron parametrit:
    tulos: Makron tulosmuuttuja, �itiysavustus, e
	mvuosi: Vuosi, jonka lains��d�nt�� k�ytet��n
	mkuuk: Kuukausi, jonka lains��d�nt�� k�ytet��n 
	minf: Deflaattori eurom��r�isten parametrien kertomiseksi 
	syntlapsia: Syntyneiden lasten lukum��r�;

%MACRO AitAvustKS(tulos, mvuosi, mkuuk, minf, syntlapsia)/STORE
DES = 'LAPSILIS�: �itiysavustus';

%HaeParam_LLisa&tyyppi(&mvuosi, &mkuuk, &minf);
%KuuNro_LLisa&tyyppi(kuuid, &mvuosi, &mkuuk);

/* �itiysavustuksen suuruus on m��ritelty kutakin syntynytt� tai adoptioon otettua lasta kohden.
Valtioneuvoston asetuksella 30.1.2003/67 t�t� periaatetta muutettiin 1.3.2003 l�htien siten, ett� �itiysavustus
suoritetaan lapsiluvun mukaan korotettuna, jos samanaikaisesti syntyy tai ottolapseksi otetaan useampi
lapsi. Toisesta lapsesta �itiysavustus suoritetaan kaksinkertaisena, kolmannesta kolminkertaisena jne. */

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


/* 5. Makro laskee �itiysavustuksen vuosikeskiarvona */

* Makron parametrit:
    tulos: Makron tulosmuuttuja, �itiysavustus, e 
	mvuosi: Vuosi, jonka lains��d�nt�� k�ytet��n
	mkuuk: Kuukausi, jonka lains��d�nt�� k�ytet��n 
	minf: Deflaattori eurom��r�isten parametrien kertomiseksi 
	syntlapsia: Syntyneiden lasten lukum��r�;

%MACRO AitAvustVS(tulos, mvuosi, minf, syntlapsia)/STORE
DES = 'LAPSILIS�: �itiysavustus vuosikeskiarvona';

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
	mvuosi: Vuosi, jonka lains��d�nt�� k�ytet��n
	mkuuk: Kuukausi, jonka lains��d�nt�� k�ytet��n 
	minf: Deflaattori eurom��r�isten parametrien kertomiseksi 
	puoliso: Onko henkil�ll� puoliso (0/1)
	lapsia: Lasten lukum��r�;

%MACRO ElatTukiKS(tulos, mvuosi, mkuuk, minf, puoliso, lapsia)/STORE
DES = 'LAPSILIS�: Elatustuki kuukausitasolla';

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
	mvuosi: Vuosi, jonka lains��d�nt�� k�ytet��n
	mkuuk: Kuukausi, jonka lains��d�nt�� k�ytet��n 
	minf: Deflaattori eurom��r�isten parametrien kertomiseksi 
	puoliso: Onko henkil�ll� puoliso (0/1)
	lapsia: Lasten lukum��r�;

%MACRO ElatTukiVS(tulos, mvuosi, minf, puoliso, lapsia)/STORE
DES = 'LAPSILIS�: Elatustuki kuukausitasolla vuosikeskiarvona';

raha = 0;

%DO i = 1 %TO 12;
	%ElatTukiKS(temp, &mvuosi, &i, &minf, &puoliso, &lapsia);
  	raha = SUM(raha, temp);
%END;

&tulos = raha / 12;
DROP raha temp;
%MEND ElatTukiVS;


/* 8. Makro laskee lapsilis�n yhdest� lapsesta j�rjestysluvun mukaan kuukausitasolla */

* Makron parametrit:
	tulos: Makron tulosmuuttuja, lapsilis�, e/kk
	mvuosi: Vuosi, jonka lains��d�nt�� k�ytet��n
	mkuuk: Kuukausi, jonka lains��d�nt�� k�ytet��n
	minf: Deflaattori eurom��r�isten parametrien kertomiseksi
	puoliso: Onko henkil�ll� puoliso (0/1)
	alle_3_v: 1 = On alle 3-vuotias, 0 = Ei ole alle 3-v
	b16v: 1 = On 16-vuotias, 0 = Ei 16-vuotias
	jarj: Lapsen j�rjestysluku;

%MACRO LLisaK1S(tulos, mvuosi, mkuuk, minf, puoliso, alle_3_v, b16v, jarj)/STORE
DES = 'LAPSILIS�: Lapsilis� yhdest� lapsesta j�rjestysluvun mukaan kuukausitasolla';

%HaeParam_LLisa&tyyppi(&mvuosi, &mkuuk, &minf);
%KuuNro_LLisa&tyyppi(kuuid, &mvuosi, &mkuuk);

*Jos j�rjestysluku ei ole positiivinen, tulos = 0;
IF &jarj < 1 THEN temp = 0;

*Lapsi ei voi olla yht� aikaa 16-vuotias ja alle 3-vuotias, laitetaan 16-vuotiaaksi. ;
IF &alle_3_v = 1 AND &b16v = 1 THEN DO; 
	alle_3_v = 0; 
END;
ELSE alle_3_v = &alle_3_v ;

SELECT (&jarj);
 	WHEN(0) lapsi = 0; * T�m� lis�tty laskentateknisist� syist�;
 	WHEN(1) lapsi = &Lapsi1;
	WHEN(2) lapsi = &Lapsi2;
	WHEN(3) lapsi = &Lapsi3;
	WHEN(4) lapsi = &Lapsi4;
	WHEN(5) lapsi = &Lapsi5;
	OTHERWISE lapsi = &Lapsi5; 
END;

*Jatkettu lapsilis� kuukausina 1986/10 - 1993/12;
*Ei mit��n lapsilis��, jos alle 17-vuotias ennen 1986/10;
IF &b16v = 1 AND kuuid < 12 * (1986 - &paramalkull) + 10
THEN lapsi = 0 AND alle_3_v = 0; 
IF &b16v = 1 AND kuuid >= 12 * (1986 - &paramalkull) + 10 AND kuuid <= 12 * (1993 -&paramalkull) + 12
THEN lapsi = &lapsi1;

IF &puoliso = 1 THEN YHuoltaja = 0;
IF &puoliso = 0 THEN YHuoltaja = 1;

*Otetaan huomioon yksinhuoltajalis�;
IF lapsi = 0 THEN temp = 0;
ELSE temp = SUM(lapsi, (&yksHuolt * YHuoltaja));

*Alle 3-vuotiaan lis�;
IF alle_3_v = 1 THEN temp = SUM(temp, &Alle3v);

&tulos = temp; 
DROP temp lapsi YHuoltaja kuuid  alle_3_v;
%MEND LLisaK1S;


/* 9. Makro laskee lapsilis�n yhdest� lapsesta j�rjestysluvun mukaan kuukausitasolla vuosikeskiarvona */

* Makron parametrit:
	tulos: Makron tulosmuuttuja, lapsilis�, e/kk (vuosikeskiarvo) 
	mvuosi: Vuosi, jonka lains��d�nt�� k�ytet��n
	mkuuk: Kuukausi, jonka lains��d�nt�� k�ytet��n
	minf: Deflaattori eurom��r�isten parametrien kertomiseksi
	puoliso: Onko henkil�ll� puoliso (0/1)
	alle_3_v: 1 = On alle 3-vuotias, 0 = Ei ole alle 3-v
	b16v: 1 = On 16-vuotias, 0 = Ei 16-vuotias
	jarj: Lapsen j�rjestysluku;

%MACRO LLisaV1S(tulos, mvuosi, minf, puoliso, alle_3_v, b16v, jarj)/STORE
DES = 'LAPSILIS�: Lapsilis� yhdest� lapsesta j�rjestysluvun mukaan kuukausitasolla vuosikeskiarvona';

raha = 0;

%DO i = 1 %TO 12;
	%LLisaK1S(temp, &mvuosi, &i, &minf, &puoliso, &alle_3_v, &b16v, &jarj);
  	raha = SUM(raha, temp);
%END;

&tulos = raha / 12;
DROP raha temp;
%MEND LLisaV1S;













