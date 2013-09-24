/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyˆdynt‰‰ Tilastokeskuksen yleisten
* k‰yttˆehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto p‰‰hakemistossa.
******************************************************************************/

/******************************************************************** 
* Kuvaus: Kotihoidontuen lains‰‰d‰ntˆ‰ makroina						* 
* Tekij‰: Maria Valaste / KELA 										* 
* Luotu: 09.11.2011 												* 
* Viimeksi p‰ivitetty: 2.3.2012 									* 
* P‰ivitt‰j‰: Olli Kannas / TK		 								* 
*********************************************************************/


/* 1. SISƒLLYS */

/* Tiedosto sis‰lt‰‰ seuraavat makrot */

/*
2. KotihTukiKaava1 = Kotihoidontuki kuukausitasolla, vanhempi lains‰‰d‰ntˆ ennen elokuuta 1997
3. KotihTukiKaava2 = Kotihoidontuki kuukausitasolla, uudempi lains‰‰d‰ntˆ elokuusta 1997 l‰htien
4. KotihTukiKS = Kotihoidontuki kuukausitasolla, vanha ja uusi lains‰‰d‰ntˆ
5. KotihTukiVS = Kotihoidontuki kuukausitasolla vuosikeskiarvona, vanha ja uusi lains‰‰d‰ntˆ
6. KotihTukiTuloS = K‰‰nteisfunktio kotihoidontuen perusteena olevan kuukausitulon laskemiseksi
7. HoitoRahaKS = Makro hoitorahan (perusosa) laskemiseksi kotihoidontuen minimitasoksi kuukausitasolla
8. HoitoRahaVS = Makro hoitorahan (perusosa) laskemiseksi kotihoidontuen minimitasoksi kuukausitasolla vuosikeskiarvona
9. HoitoLisaKS = Makro hoitolis‰n (lis‰osa) laskemiseksi kotihoidontuen ja hoitorahan erotuksena kuukausitasolla
10. HoitoLisaVS = Makro hoitolis‰n (lis‰osa) laskemiseksi kotihoidontuen ja hoitorahan erotuksena kuukausitasolla vuosikeskiarvona
11. HoitoLisaTuloS = K‰‰nteisfunktio hoitolis‰n (lis‰osa) perusteena olevan kuukausitulon laskemiseksi (versio 1)
12. HoitoLisaTuloKS = K‰‰nteisfunktio hoitolis‰n (lis‰osa) perusteena olevan kuukausitulon laskemiseksi (versio 2)
13. OsitHoitRahaS = Osittainen hoitoraha kuukausitasolla    	
14. OsitHoitRahaVS = Osittainen hoitoraha kuukausitasolla vuosikeskiarvona   
15. PHoitoMaksuS = P‰iv‰hoitomaksu kuukausitasolla, vuoden 1997 lains‰‰d‰ntˆ   	
16. PHoitoMaksuVS = P‰iv‰hoitomaksu kuukausitasolla vuosikeskiarvona, vuoden 1997 lains‰‰d‰ntˆ   
17. SumPHoitoMaksuS = P‰iv‰hoitomaksun useammasta lapsesta kuukausitasolla     	
18. SumPHoitoMaksuVS = P‰iv‰hoitomaksun useammasta lapsesta kuukausitasolla vuosikeskiarvona   	


/* 2. Makro laskee kotihoidontuen kuukausitasolla, vanhempi lains‰‰d‰ntˆ ennen elokuuta 1997.
      Kaavaan lis‰tty muiden kotona hoidettavien alle kouluik‰isten laskeminen */

* Makron parametrit:
	tulos: Makron tulosmuuttuja, kotihoidontuki, e/kk
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	sisaria: Kotihoidossa olevien alle 3-vuotiaiden sisarten lukum‰‰r‰
	muuallekouluik: Muiden alle kouluik‰isten hoitolasten lukum‰‰r‰
	bruttotulo: Perheen bruttotulot, e/kk
	nettotulo: Perheen nettotulot, e/kk;

%MACRO KotihTukiKaava1(tulos, mvuosi, mkuuk, minf, sisaria, muuallekouluik, bruttotulo, nettotulo)/STORE
DES = 'KOTIHTUKI: Kotihoidontuki kuukausitasolla, vanhempi lains‰‰d‰ntˆ ennen elokuuta 1997';

%HaeParam_KotihTuki&tyyppi(&mvuosi, &mkuuk, &minf);
%KuuNro_KotihTuki&tyyppi(kuuid, &mvuosi, &mkuuk);

*Peruosa;

temp = sum(&Perus, &sisaria * &SisarKerr * &Perus, &muuallekouluik * &SisarKerr * &Perus);

*Lis‰osa;

lisa = &Kerr1 * &Perus;

*Erilainen tulok‰site ennen vuotta 1991;

tulo1 = &bruttotulo;

IF &mvuosi < 1991 THEN tulo1 = &nettotulo;
	
IF (tulo1 <= &KHraja1) THEN temp = temp + lisa;

ELSE IF tulo1 > &KHraja1 THEN DO;
	lisa = MAX(SUM(lisa, -&Kerr2 *(tulo1 - &KHraja1)), 0);
	temp = SUM(temp, lisa);
END;

&tulos = temp; 

DROP kuuid temp lisa tulo1; 

%MEND KotihTukiKaava1;


/* 3. Makro laskee kotihoidontuen kuukausitasolla, uudempi lains‰‰d‰ntˆ elokuusta 1997 l‰htien */

* Makron parametrit:
	tulos: Makron tulosmuuttuja, kotihoidontuki, e/kk
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	sisaria: Kotihoidossa olevien alle 3-vuotiaiden sisarten lukum‰‰r‰
	muuallekouluik: Muiden alle kouluik‰isten hoitolasten lukum‰‰r‰
	koko: Perheen koko (2,3, ...)
	tulo: Perheen bruttotulot, e/kk;

%MACRO KotihTukiKaava2(tulos, mvuosi, mkuuk, minf, sisaria, muuallekouluik, koko, tulo)/STORE
DES = 'KOTIHTUKI: Kotihoidontuki kuukausitasolla, uudempi lains‰‰d‰ntˆ elokuusta 1997 l‰htien';

%HaeParam_KotihTuki&tyyppi(&mvuosi, &mkuuk, &minf);

koko1 = &koko; *Apumuuttuja;

*Hoitoraha;

temp = SUM(&Perus, &sisaria * &Sisar, &muuallekouluik * &SisarMuu);

IF koko1 < SUM(&sisaria, &muuallekouluik, 1) THEN koko1 = SUM(&sisaria, &muuallekouluik, 1);

*koko-muuttuja rajataan tapauksiin 2, 3 ja 4;

IF (koko1 > 4) THEN koko1 = 4;

IF (koko1 < 2) THEN koko1 = 2;

*Tulorajat ja kertoimet;

SELECT (koko1);
	WHEN(2) DO;
		raja = &KHraja1; kerr = &Kerr1;
	END;
	WHEN(3) DO;
		raja = &KHraja2; kerr = &Kerr2;
	END;
   	WHEN(4)  DO;
		raja = &KHraja3; kerr = &Kerr3;
	END;
END;
  		
*Hoitolis‰;
	
IF (&tulo <= raja) THEN hlisa = &Lisa;

*Alenema tulojen suuruuden mukaan;

ELSE IF (&tulo > raja) THEN hlisa = SUM(&Lisa, -kerr * (&tulo - raja));

IF (hlisa < 0) THEN hlisa = 0;

temp = SUM(temp, hlisa);

&tulos = temp; 

DROP temp raja kerr hlisa koko1; 

%MEND KotihTukiKaava2;


/* 	4. Makro laskee kotihoidontuen kuukausitasolla sek‰ vanhalla ett‰ uudella lains‰‰d‰nnˆll‰ */

* Makron parametrit:
	tulos: Makron tulosmuuttuja, kotihoidontuki, e/kk
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	sisaria: Kotihoidossa olevien alle 3-vuotiaiden sisarten lukum‰‰r‰
	muuallekouluik: Muiden alle kouluik‰isten hoitolasten lukum‰‰r‰
	koko: Perheen koko (2,3, ...)
	bruttotulo: Perheen bruttotulot, e/kk
	nettotulo: Perheen nettotulot, e/kk;

%MACRO KotihTukiKS(tulos, mvuosi, mkuuk, minf, sisaria, muuallekouluik, koko, bruttotulo, nettotulo)/STORE
DES ='KOTIHTUKI: Kotihoidontuki kuukausitasolla, vanha ja uusi lains‰‰d‰ntˆ';

%HaeParam_KotihTuki&tyyppi(&mvuosi, &mkuuk, &minf);
%KuuNro_KotihTuki&tyyppi(kuuid, &mvuosi, &mkuuk);

IF kuuid >= 12 * (1997 - &paramalkukt) + 8 THEN DO;
	%KotihTukiKaava2(&tulos, &mvuosi, &mkuuk, &minf, &sisaria, &muuallekouluik, &koko, &bruttotulo);
END;

*Vanha kaava ennen elokuuta 1997;

ELSE IF kuuid < 12 * (1997 - &paramalkukt) + 8 THEN DO;	
	%KotihTukiKaava1(&tulos, &mvuosi, &mkuuk, &minf, &sisaria, &muuallekouluik, &bruttotulo, &nettotulo);	
END;

DROP kuuid;

%MEND KotihTukiKS;


/* 5. T‰m‰ makro laskee kotihoidon tuen kuukausitasolla vuosikeskiarvona, sek‰ vanhalla ett‰ uudella lains‰‰d‰nnˆll‰ */

* Makron parametrit:
	tulos: Makron tulosmuuttuja, kotihoidontuki, e/kk (vuosikeskiarvo)
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	sisaria: Kotihoidossa olevien alle 3-vuotiaiden sisarten lukum‰‰r‰
	muuallekouluik: Muiden alle kouluik‰isten hoitolasten lukum‰‰r‰
	koko: Perheen koko (2,3, ...)
	bruttotulo: Perheen bruttotulot, e/kk
	nettotulo: Perheen nettotulot, e/kk;

%MACRO KotihTukiVS(tulos, mvuosi, minf, sisaria, muuallekouluik, koko, bruttotulo, nettotulo)/STORE
DES = 'KOTIHTUKI: Kotihoidontuki kuukausitasolla vuosikeskiarvona, vanha ja uusi lains‰‰d‰ntˆ';

raha = 0;

%DO i = 1 %TO 12;
	%KotihTukiKS(temp, &mvuosi, &i, &minf, &sisaria, &muuallekouluik, &koko, &bruttotulo, &nettotulo);
  	raha = SUM(raha, temp);
%END;

&tulos = raha / 12;

DROP raha temp ;
%MEND KotihTukiVS;


/* 6. Makro laskee k‰‰nteisfunktiona kotihoidon tuen perusteena olevan kuukausitulon */

* Makron parametrit:
	tulos: Makron tulosmuuttuja, kotihoidontuen perusteena oleva tulo, e/kk
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	sisaria: Kotihoidossa olevien alle 3-vuotiaiden sisarten lukum‰‰r‰
	muuallekouluik: Muiden alle kouluik‰isten hoitolasten lukum‰‰r‰
	koko: Perheen koko (2,3, ...)
	tuki: Kotihoidontuki, e/kk;

%MACRO KotihTukiTuloS(tulos, mvuosi, mkuuk, sisaria, muuallekouluik, koko, tuki)/STORE
DES = 'KOTIHTUKI: K‰‰nteisfunktio kotihoidontuen perusteena olevan kuukausitulon laskemiseksi';

testix = 0;
tuki1 = &tuki;

*T‰ysi tuki: jos tuki1-muuttuja on yht‰ suuri tai suurempi kuin t‰ysi tuki, annetaan tuloksi 0;

%KotihTukiKS(vert1, &mvuosi, &mkuuk, 1, &sisaria, &muuallekouluik, &koko, 0, 0);

IF SUM(tuki1, -vert1) >= 0 THEN testix = 0;

ELSE DO;
		
	*Minimituki;
				
	%KotihTukiKS(vert2, &mvuosi, &mkuuk, 1, &sisaria, &muuallekouluik, &koko, 99999, 99999);

	vert = vert2;
								
	DO j = 10 TO 0 BY -1 UNTIL (vert > tuki1);
		testix = j * 1000;
		%KotihTukiKS(vert, &mvuosi, &mkuuk, 1, &sisaria, &muuallekouluik, &koko, testix, testix);
	END;

	DO k = 9 TO -10 BY -1 UNTIL (vert > tuki1);
		testix = SUM(j * 1000,  k * 100);
		%KotihTukiKS(vert, &mvuosi, &mkuuk, 1, &sisaria, &muuallekouluik, &koko, testix, testix);
	END;
			
	DO m = 9 TO -10 BY -1 UNTIL (vert > tuki1);
		testix = SUM(j * 1000, k * 100, m * 10);
		%KotihTukiKS(vert, &mvuosi, &mkuuk, 1, &sisaria, &muuallekouluik, &koko, testix, testix);
	END;

	DO n = 9 TO -10 BY -1 UNTIL (vert > tuki1);
		testix = SUM(j * 1000, k * 100,  m * 10, n);
		%KotihTukiKS(vert, &mvuosi, &mkuuk, 1, &sisaria, &muuallekouluik, &koko, testix, testix);
	END;

	DO p = 9 TO -10 BY -1 UNTIL (vert > tuki1);
		testix = SUM(j * 1000, k * 100, m * 10, n, p/10);
		%KotihTukiKS(vert, &mvuosi, &mkuuk, 1, &sisaria, &muuallekouluik, &koko, testix, testix);
	END;
				
END;

IF testix < 0 THEN testix = 0;

&tulos = testix; 

DROP vert1 vert2 vert j k m n p testix tuki1;

%MEND KotihTukiTuloS;


/* 7. Makro laskee kuukausitasolla hoitorahan (perusosa) kotihoidon tuen minimitasoksi */

* Makron parametrit:
    tulos: Makron tulosmuuttuja, hoitorahan perusosa, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	sisaria: Kotihoidossa olevien alle 3-vuotiaiden sisarten lukum‰‰r‰
	muuallekouluik: Muiden alle kouluik‰isten hoitolasten lukum‰‰r‰
	koko: Perheen koko
	brutto: Perheen bruttotulot, e/kk
	netto: Perheen nettotulot, e/kk;

%MACRO HoitoRahaKS(tulos, mvuosi, mkuuk, minf, sisaria, muuallekouluik)/STORE
DES = 'KOTIHTUKI: Makro hoitorahan (perusosa) laskemiseksi kotihoidontuen minimitasoksi kuukausitasolla';

%KotihTukiKS(&tulos, &mvuosi, &mkuuk, &minf, &sisaria, &muuallekouluik, 0, 99999, 99999);

%MEND HoitoRahaKS;


/* 8. Makro laskee kuukausitasolla hoitorahan (perusosa) kotihoidon tuen minimitasoksi */

* Makron parametrit:
    tulos: Makron tulosmuuttuja, hoitorahan perusosa, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	sisaria: Kotihoidossa olevien alle 3-vuotiaiden sisarten lukum‰‰r‰
	muuallekouluik: Muiden alle kouluik‰isten hoitolasten lukum‰‰r‰
	koko: Perheen koko
	brutto: Perheen bruttotulot, e/kk
	netto: Perheen nettotulot, e/kk;

%MACRO HoitoRahaVS(tulos, mvuosi, minf, sisaria, muuallekouluik)/STORE
DES = 'KOTIHTUKI: Makro hoitorahan (perusosa) laskemiseksi kotihoidontuen minimitasoksi kuukausitasolla vuosikeskiarvona';

%KotihTukiVS(&tulos, &mvuosi, &minf, &sisaria, &muuallekouluik, 0, 99999, 99999);

%MEND HoitoRahaVS;


/* 9. Makro laskee hoitolis‰n (lis‰osa) kotihoidontuen ja hoitorahan erotuksena kuukausitasolla */

* Makron parametrit:
    tulos: Makron tulosmuuttuja, hoitolis‰, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	sisaria: Kotihoidossa olevien alle 3-vuotiaiden sisarten lukum‰‰r‰
	muuallekouluik: Muiden alle kouluik‰isten hoitolasten lukum‰‰r‰
	koko: Perheen koko
	bruttotulo: Perheen bruttotulot, e/kk
	nettotulo: Perheen nettotulot, e/kk;

%MACRO HoitoLisaKS(tulos, mvuosi, mkuuk, minf, sisaria, muuallekouluik, koko, bruttotulo, nettotulo)/STORE
DES = 'KOTIHTUKI: Makro hoitolis‰n (lis‰osa) laskemiseksi kotihoidontuen ja hoitorahan erotuksena kuukausitasolla';

temp = 0;

%KotihTukiKS(temp1, &mvuosi, &mkuuk, &minf, &sisaria, &muuallekouluik, &koko, &bruttotulo, &nettotulo);
%HoitoRahaKS(temp2, &mvuosi, &mkuuk, &minf, &sisaria, &muuallekouluik);

temp = SUM(temp1, -temp2);

IF temp < 0 THEN temp = 0;

&tulos = Temp;

DROP temp;
%MEND HoitoLisaKS;


/* 10. Makro laskee hoitolis‰n (lis‰osa) kotihoidontuen ja hoitorahan erotuksena kuukausitasolla */

* Makron parametrit:
    tulos: Makron tulosmuuttuja, hoitolis‰, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	sisaria: Kotihoidossa olevien alle 3-vuotiaiden sisarten lukum‰‰r‰
	muuallekouluik: Muiden alle kouluik‰isten hoitolasten lukum‰‰r‰
	koko: Perheen koko
	bruttotulo: Perheen bruttotulot, e/kk
	nettotulo: Perheen nettotulot, e/kk;

%MACRO HoitoLisaVS(tulos, mvuosi, minf, sisaria, muuallekouluik, koko, bruttotulo, nettotulo)/STORE
DES = 'KOTIHTUKI: Makro hoitolis‰n (lis‰osa) laskemiseksi kotihoidontuen ja hoitorahan erotuksena kuukausitasolla';

temp = 0;

%KotihTukiVS(temp1, &mvuosi, &minf, &sisaria, &muuallekouluik, &koko, &bruttotulo, &nettotulo);
%HoitoRahaVS(temp2, &mvuosi, &minf, &sisaria, &muuallekouluik);

temp = sum(temp1, -temp2);

IF temp < 0 THEN temp = 0;

&tulos = temp;

DROP temp;
%MEND HoitoLisaVS;


/* 11. Makro laskee k‰‰nteisfunktiona hoitolis‰n (lis‰osan) perusteena olevan kuukausitulon (versio 1) */

* Makron parametrit:
    tulos: Makron tulosmuuttuja, hoitolis‰n perusteena olevan tulo, e/kk
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	sisaria: Kotihoidossa olevien alle 3-vuotiaiden sisarten lukum‰‰r‰
	muuallekouluik: Muita alle kouluik‰isi‰ lapsia
	koko: Perheen koko
	hoitolisa: Hoitolis‰, e/kk;   

%MACRO HoitoLisaTuloS(tulos, mvuosi, minf, sisaria, muuallekouluik, koko, hoitolisa)/STORE
DES = 'KOTIHTUKI: K‰‰nteisfunktio hoitolis‰n (lis‰osa) perusteena olevan kuukausitulon laskemiseksi (versio 1)';

testix = 0; 
hoitolisa1 = &HoitoLisa; *Apumuuttuja hoitolisa1;

*T‰ysi tuki, jos hoitolisa1-muuttuja on yht‰ suuri tai suurempi, annetaan tuloksi 0;

%HoitoLisaVS(vert1, &mvuosi, &minf, &sisaria, &muuallekouluik, &koko, 0, 0);
erotus = hoitolisa1 - vert1;
IF erotus >= 0 THEN DO;
	testix = 0;
END;
ELSE DO;

	*Minimituki, jos hoitolisa1-muuttuja on minimitukea pienempi, korjataan se minimituen suuruiseksi;

	%HoitoLisaVS(Vert2, &mvuosi, &minf, &sisaria, &muuallekouluik, &koko, 99999, 99999);
	erotus = hoitolisa1 - vert2;
	IF erotus < 0 THEN hoitolisa1 = vert2; 
						
	*Testataan tulov‰li 10000 - 0 suurimmasta pienimp‰‰n tuhatlukuun;
	DO j = 10 TO 1 BY -1 UNTIL (vert > hoitolisa1);
		testix = j * 1000;
		%HoitoLisaVS(vert, &mvuosi, &minf, &sisaria, &muuallekouluik, &koko, testix, testix);
	END;

	*Sitten 100 euron v‰lein;
	DO k = 9 TO -10 BY -1 UNTIL (vert > hoitolisa1);
		testix = j * 1000 + k * 100;
		%HoitoLisaVS(vert, &mvuosi, &minf, &sisaria, &muuallekouluik, &koko, testix, testix);
	END;

	*10 euron v‰lein;
	DO m = 9 TO -10 BY -1 UNTIL (vert > hoitolisa1);
		testix = j * 1000 + k * 100 + m * 10;
		%HoitoLisaVS(vert, &mvuosi, &minf, &sisaria, &muuallekouluik, &koko, testix, testix);
	END;

	*1 euron v‰lein;
	DO n = 9 TO -10 BY -1 UNTIL (vert > hoitolisa1);
		testix = j * 1000 + k * 100 + n;
		%HoitoLisaVS(vert, &mvuosi, &minf, &sisaria, &muuallekouluik, &koko, testix, testix);
	END;

	*0.1 euron v‰lein;
	DO p = 9 TO -10 BY -1 UNTIL (vert > hoitolisa1);
		testix = j * 1000 + k * 100 + n + p/10;
		%HoitoLisaVS(vert, &mvuosi, &minf, &sisaria, &muuallekouluik, &koko, testix, testix);
	END;

	IF testix < 0 THEN &tulos = 0;

END; 

&tulos = testix;

DROP testix erotus hoitolisa1 vert1 vert2 ;
%MEND HoitoLisaTuloS;


/* 12. Makro laskee k‰‰nteisfunktiona hoitolis‰n (lis‰osan) perusteena olevan kuukausitulon (versio 2) 
	   Huom. T‰ss‰ makrossa tulos muodostetaan satunnaislukujen avulla,
	   jos tulo p‰‰tell‰‰n pienemm‰ksi  kuin suurimpaan kotihoidon tukeen oikeuttava tulo
	   tai jos tulo p‰‰tell‰‰n suuremmaksi kuin kotihoiton tukeen ylip‰‰ns‰ oikeuttava tulo */

* Makron parametrit:
    tulos: Makron tulosmuuttuja, hoitolis‰n perusteena olevan tulo, e/kk
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	sisaria: Kotihoidossa olevien alle 3-vuotiaiden sisarten lukum‰‰r‰
	muuallekouluik: Muita alle kouluik‰isi‰ lapsia
	koko: Perheen koko
	hoitolisa: Hoitolis‰, e/kk;  

%MACRO HoitoLisaTuloKS(tulos, mvuosi, mkuuk, minf, sisaria, muuallekouluik, koko, hoitolisa)/STORE
DES = 'KOTIHTUKI: K‰‰nteisfunktio hoitolis‰n (lis‰osa) perusteena olevan kuukausitulon laskemiseksi (versio 2)';

%HaeParam_KotihTuki&tyyppi(&mvuosi, &mkuuk, &minf);
%KuuNro_KotihTuki&tyyppi(kuuid, &mvuosi, &mkuuk);

IF kuuid >= 12 * (1997 - &paramalkukt) + 8 THEN hoitolisa1 = &Lisa;
ELSE hoitolisa1 = &Kerr1 * &Perus; 

koko1 = &koko;

IF SUM(&sisaria, &muuallekouluik, 1) > koko1 THEN koko1 = SUM(&sisaria, &muuallekouluik, 1);

IF koko1 > 4 THEN koko1 = 4;
IF koko1 < 2 THEN koko1 = 2;

SELECT (koko1);
	WHEN(2) DO;
		raja = &KHraja1; kerr = &Kerr1;
	END;
	WHEN(3) DO;
		raja = &KHraja2; kerr = &Kerr2;
	END;
   	WHEN(4)  DO;
		raja = &KHraja3; kerr = &Kerr3;
	END;
END;
	
IF kuuid < 12 * (1997 - &paramalkukt) + 8 THEN DO;
	raja = &KHraja1;
	kerr = &Kerr2;
END;

nollaraja = raja + hoitolisa1 / kerr;

IF &hoitolisa >= hoitolisa1 THEN &tulos = raja * RAND('UNIFORM');
ELSE IF &hoitolisa = 0 THEN &tulos = nollaraja + nollaraja * RAND('UNIFORM');
ELSE &tulos = SUM(hoitolisa1, -&hoitolisa, kerr * raja) / kerr; 

DROP hoitolisa1 koko1 raja kerr nollaraja;
%MEND HoitoLisaTuloKS;


/* 13. Makro laskee osittaisen hoitorahan kuukausitasolla */

* Makron parametrit:
	tulos: Makron tulosmuuttuja, osittainen hoitoraha, e/kk
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi;

%MACRO OsitHoitRahaS(tulos, mvuosi, mkuuk, minf)/STORE
DES = 'KOTIHTUKI: Osittainen hoitoraha kuukausitasolla';

%HaeParam_KotihTuki&tyyppi(&mvuosi, &mkuuk, &minf);
%KuuNro_KotihTuki&tyyppi(kuuid, &mvuosi, &mkuuk);

*Elokuusta 1997 alkaen;

IF kuuid >= 12 * (1997 - &paramalkukt) + 8 THEN DO;
	&tulos = &OsRaha;
END;

*Ennen elokuuta 1997;

ELSE IF kuuid < 12 * (1997 - &paramalkukt) + 8 THEN DO;
	&tulos = &OsKerr * &Perus;
END;
	
%MEND OsitHoitRahaS;

/* 14. Makro laskee osittaisen hoitorahan kuukausitasolla vuosikeskiarvona */

* Makron parametrit:
	tulos: Makron tulosmuuttuja, osittainen hoitoraha, e/kk
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi;

%MACRO OsitHoitRahaVS(tulos, mvuosi, minf)/STORE
DES = 'KOTIHTUKI: Osittainen hoitoraha kuukausitasolla vuosikeskiarvona';

oshoiraha = 0;

%DO i = 1 %TO 12;
	%OsitHoitRahaS(temp, &mvuosi, &i, &minf);
	oshoiraha = SUM(oshoiraha, temp);
%END;

&tulos = oshoiraha / 12;

drop temp oshoiraha;
%MEND OsitHoitRahaVS;

/* 15. T‰m‰ makro laskee yhden lapsen p‰iv‰hoitomaksun kuukausitasolla, vuoden 1997 lains‰‰d‰ntˆ */

* Makron parametrit:
    tulos: Makron tulosmuuttuja, p‰iv‰hoitomaksu, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	puoliso: Onko puolisoa (0/1)
	phlapsia: P‰iv‰hoitoik‰isi‰ lapsia
	sisarn: Monesko sisar p‰iv‰hoidossa (nuorin = 1) (HUOM. parametreissa sisar)
	muitalapsia: Perheen muiden alaik‰isten lasten lukum‰‰r‰
	tulo: P‰iv‰hoitomaksun perusteena oleva tulo, e/kk ;

%MACRO PHoitoMaksuS(tulos, mvuosi, mkuuk, minf, puoliso, phlapsia, sisarn, muitalapsia, tulo)/STORE
DES = 'KOTIHTUKI: P‰iv‰hoitomaksu kuukausitasolla, vuoden 1997 lains‰‰d‰ntˆ';

%HaeParam_KotihTuki&tyyppi(&mvuosi, &mkuuk, &minf);
%KuuNro_KotihTuki&tyyppi(kuuid, &mvuosi, &mkuuk);

tulo1 = &tulo;

*Perheen koko aina v‰hint‰‰n 2;
koko = 2; 

IF (&puoliso = 1) THEN koko = koko + 1; 

*Ennen 1.8.2008 perheen koossa otetaan huomioon korkeintaan kaksi p‰iv‰hoitolasta;
IF (&phlapsia > 1) AND kuuid < 12 * (2008 - &paramalkukt) + 8 THEN koko = SUM(koko, 1);

*1.8.2008 l‰htien perheen koossa otetaan huomioon kaikki alaik‰iset lapset;
IF kuuid >= 12 * (2008 - &paramalkukt) + 8 THEN koko = sum(koko, &phlapsia, &muitalapsia, -1);

IF koko < 3 THEN DO;
	raja = &PHRaja1;
	kerr = &PHKerr1;
END;

ELSE IF koko = 3 THEN DO;
	raja = &PHRaja2;
	kerr = &PHKerr2;
END;

* Elokuusta 2008 l‰htien lis‰‰ portaita;

ELSE IF koko > 3 AND kuuid < 12 * (2008 - &paramalkukt) + 8 THEN DO;
	Raja = &PHRaja3;
    Kerr = &PHKerr3;
END;
		
ELSE IF koko = 4 AND kuuid >=  12 * (2008 - &paramalkukt) + 8 THEN DO;
	Raja = &PHRaja3;
    Kerr = &PHKerr3;
END;
		
ELSE IF koko = 5 AND kuuid >= 12 * (2008 - &paramalkukt) + 8 THEN DO;
	raja = &PHRaja4;
    kerr = &PHKerr4;
END;
	
ELSE IF Koko > 5 AND kuuid >= 12 * (2008 - &paramalkukt) + 8 THEN DO;
	raja = &PHRaja5;
    kerr = &PHKerr5;
END;
			
* PHVahenn-parametrin k‰yttˆ on erilainen ennen 1.8.2008 ja sen j‰lkeen;
* Ennen 8/2008 v‰hennys tuloista;
 
IF kuuid < 12 * (2008 - &paramalkukt) + 8 THEN DO;
	lukum = &muitalapsia;
	*Jos p‰iv‰hoitolapsia on > 2 ylimenev‰t lapset lis‰t‰‰n "muihin lapsiin";

	IF &PHLapsia > 2 THEN lukum = sum(&muitalapsia, &phlapsia, -2);

	tulo1 = sum(&tulo, -lukum * &PHVahenn);

END;
	   
IF tulo1 < 0 THEN tulo1 = 0;

*PHVahenn-parametrilla suurennetaan tulorajaa 8/2008 l‰htien, jos koko-muuttuja > 6;

IF kuuid >= 12 * (2008 - &paramalkukt) + 8 AND koko > 6 THEN raja = SUM(raja, (koko - 6) * &PHVahenn);

*Jos pienet tulot, nollamaksu;

IF tulo1 <= raja THEN DO;
	temp = 0; 		
END;

*Tulosidonnaisuus;

ELSE DO;

	IF tulo1 > raja THEN temp = kerr * (tulo1 - raja);

	*Yl‰raja;

	IF temp > &PHYlaraja THEN temp = &PHYlaraja;

	*Alarajan alitus johtaa nollamaksuun;

	IF temp <  &PHAlaraja THEN DO;
 		temp = 0; 
	END;

	*Sisarn-muuttujan mukaan yl‰raja muuttuu, ja lis‰ksi
	 otetaan huomioon mahdollinen alennus;

	ELSE DO;

		IF &sisarn = 1 THEN DO;
			
		END; 

		ELSE DO;

			temp2 = temp;

			IF temp2 > &PHYlaraja2 THEN temp2 = &PHYlaraja2;

			IF temp2 < &PHAlaraja THEN temp2 = 0;

			IF &sisarn = 2 THEN DO;
					temp = temp2;
			END;
			ELSE DO;

				alennettu = &PHAlennus * temp;

				IF alennettu < &PHAlaraja THEN alennettu = 0;

				IF &sisarn > 2 THEN temp = alennettu; 

			END;
		END;
	END;
END;

&tulos = temp;

DROP kuuid raja kerr temp temp2 alennettu lukum tulo1; 
%MEND PHoitoMaksuS;

/* 16. T‰m‰ makro laskee yhden lapsen p‰iv‰hoitomaksun kuukausitasolla vuosikeskiarvona, vuoden 1997 lains‰‰d‰ntˆ */

* Makron parametrit:
    tulos: Makron tulosmuuttuja, p‰iv‰hoitomaksu, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi
	puoliso: Onko puolisoa (0/1)
	phlapsia: P‰iv‰hoitoik‰isi‰ lapsia
	sisarn: Monesko sisar p‰iv‰hoidossa (nuorin = 1) (HUOM. parametreissa sisar)
	muitalapsia: Perheen muiden alaik‰isten lasten lukum‰‰r‰
	tulo: P‰iv‰hoitomaksun perusteena oleva tulo, e/kk ;

%MACRO PHoitoMaksuVS(tulos, mvuosi, minf, puoliso, phlapsia, sisarn, muitalapsia, tulo)/STORE
DES = 'KOTIHTUKI: P‰iv‰hoitomaksu kuukausitasolla vuosikeskiarvona, vuoden 1997 lains‰‰d‰ntˆ';

phmaksu = 0;

%DO i = 1 %TO 12;
	%PHoitoMaksuS(temp, &mvuosi, &i, &minf, &puoliso, &phlapsia, &sisarn, &muitalapsia, &tulo);
	phmaksu = SUM(phmaksu, temp);
%END;

&tulos = phmaksu / 12;
DROP temp phmaksu;
%MEND PHoitoMaksuVS;

/* 17. Makro laskee p‰iv‰hoitomaksun useammasta lapsesta kuukausitasolla */

* Makron parametrit:
    tulos: Makron tulosmuuttuja, p‰iv‰hoitomaksu, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	puoliso: Onko puolisoa (0/1)
	phlapsia: P‰iv‰hoitoik‰isi‰ lapsia, joista maksu perit‰‰n
	sisar: Monesko sisar p‰iv‰hoidossa (nuorin = 1)
	muitalapsia: Onko muita lapsia (0/1)
	tulo: P‰iv‰hoitomaksun perusteena oleva perheen bruttotulo, e/kk;

%MACRO SumPHoitoMaksuS(tulos, mvuosi, mkuuk, minf, puoliso, phlapsia, muitalapsia, tulo)/STORE
DES =  'KOTIHTUKI: P‰iv‰hoitomaksun useammasta lapsesta kuukausitasolla';

tempx = 0;

DO i = 1 TO &PHLapsia;
	%PHoitoMaksuS(maksu, &mvuosi, &mkuuk, &minf, &puoliso, &phlapsia, i, &muitalapsia, &tulo);
	tempx = SUM(tempx, maksu);
END;

&tulos = tempx;

DROP maksu tempx i;
%MEND SumPHoitoMaksuS;

/* 18. Makro laskee p‰iv‰hoitomaksun useammasta lapsesta kuukausitasolla vuosikeskiarvona */

* Makron parametrit:
    tulos: Makron tulosmuuttuja, p‰iv‰hoitomaksu, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	puoliso: Onko puolisoa (0/1)
	phlapsia: P‰iv‰hoitoik‰isi‰ lapsia, joista maksu perit‰‰n
	sisar: Monesko sisar p‰iv‰hoidossa (nuorin = 1)
	muitalapsia: Onko muita lapsia (0/1)
	tulo: P‰iv‰hoitomaksun perusteena oleva perheen bruttotulo, e/kk;

%MACRO SumPHoitoMaksuVS(tulos, mvuosi, minf, puoliso, phlapsia, muitalapsia, tulo)/STORE
DES =  'KOTIHTUKI: P‰iv‰hoitomaksun useammasta lapsesta kuukausitasolla vuosikeskiarvona';

phmaksusum = 0;

%DO i = 1 %TO 12;
	%SumPHoitoMaksuS(temp, &mvuosi, &i, &minf, &puoliso, &phlapsia, &muitalapsia, &tulo);
	phmaksusum = SUM(phmaksusum, temp);
%END;

&tulos = phmaksusum / 12;

DROP temp phmaksusum;
%MEND SumPHoitoMaksuVS;
