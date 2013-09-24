/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyˆdynt‰‰ Tilastokeskuksen yleisten
* k‰yttˆehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto p‰‰hakemistossa.
******************************************************************************/

/************************************************************
* Kuvaus: Toimeentulotuen lains‰‰d‰ntˆ‰ makroina.			*
* Tekij‰: Elina Ahola / KELA								*
* Luotu: 06.07.2011											*
* Viimeksi p‰ivitetty: 08.11.2012							*
* P‰ivitt‰j‰: Elina Ahola / KELA							*
************************************************************/


/* 1. SISƒLLYS */

/* Tiedosto sis‰lt‰‰ seuraavat makrot */

/*
2. LapsKerrS = Alaik‰isten lasten osuus desimaalilukuna yksin asuvan ja yksinhuoltajan toimeentulotuen peruosasta
3. ToimTukiKS = Toimeentulotuki kuukausitasolla
4. ToimTukiVS = Toimeentulotuki kuukausitasolla vuosikeskiarvona
5. ToimTukiLLKS = Toimeentulotuen perusosa ja lapsilis‰t yhteens‰ kuukausitasolla
6. VahimmTuloS = Toimeentulotuen perusosa, lapsilis‰t ja asumistukinormien mukaan korvatut asumismenot yhteens‰ kuukausitasolla
*/


/* 2. Makro laskee alaik‰isten lasten osuuden desimaalilukuna yksin asuvan ja yksinhuoltajan toimeentulotuen peruosasta */

*Makron parametrit:
	tulos: Makron tulosmuuttuja, alaik‰isten lasten osuus desimaalilukuna toimeentulotuen peruosasta
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	lapsia17: 17-vuotiaiden lasten m‰‰r‰
	lapsia10_16: 10-16 -vuotiaiden lasten m‰‰r‰
	lapsiaalle10: Alle 10-vuotiaiden lasten m‰‰r‰; 
	
%MACRO LapsKerrS(tulos, mvuosi, mkuuk, lapsia17, lapsia10_16, lapsiaalle10)/STORE
DES = 'TOIMTUKI: Alaik‰isten lasten osuus desimaalilukuna yksin asuvan ja yksinhuoltajan toimeentulotuen peruosasta';

%HaeParam_ToimTuki&tyyppi(&mvuosi, &mkuuk, &minf);

*Lasketaan aluksi kerroin, kun lasten lukum‰‰r‰‰n liittyvi‰ v‰hennyksi‰ ei oteta huomioon.;
%KuuNro_ToimTuki&tyyppi(kuuid, &mvuosi, &mkuuk);
%KuuNro_ToimTuki&tyyppi(kuuid1998_3, 1998, 3);

*Vuoden 1998 maaliskuusta l‰htien myˆs 17-vuotiaat on katsottu toimeentulotuessa lapsiksi.;
IF kuuid >= kuuid1998_3 THEN DO;
	lapsiayht = SUM(&lapsia17, &lapsia10_16, &lapsiaalle10);
	kerrennenvah = SUM(&lapsia17 * &Lapsi17, &lapsia10_16 * &Lapsi10_16, &lapsiaalle10 * &LapsiAlle10);
END;
ELSE DO;
	lapsiayht = SUM(&lapsia10_16, &lapsiaalle10);
	kerrennenvah = SUM(&lapsia10_16 * &Lapsi10_16, &lapsiaalle10 * &LapsiAlle10);
END;
kerr = kerrennenvah;

*Lasten lukum‰‰r‰‰n liittyv‰t v‰hennykset huomioon.;
IF lapsiayht >= 2 THEN DO;
	kerr = SUM(kerr, -&LapsiVah2);
	IF lapsiayht >= 3 THEN DO;
		kerr = SUM(kerr, -&LapsiVah3);
		IF lapsiayht >= 4 THEN DO;
			kerr = SUM(kerr, -&LapsiVah4);
			IF lapsiayht >= 5 THEN DO;
				kerr = SUM(kerr, - &LapsiVah5 * (SUM(lapsiayht, -4)));
			END;
		END;
	END;
END;

&tulos = kerr;

DROP kuuid kuuid1998_3 lapsiayht kerrennenvah kerr;

%MEND LapsKerrS;


/* 3. Makro laskee toimeentulotuen kuukausitasolla */

*Makron parametrit:
	tulos: Makron tulosmuuttuja, toimeentulotutuki, e/kk.
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kryhma: Toimeentulotuen kuntaryhm‰
	ydinp: Onko kyseess‰ ydiperhe? (0/1)
	aik: Yli 18-vuotiaiden m‰‰r‰ poisluettuna yli 18-vuotiaat lapset
	aiklapsia: Yli 18-vuotiaiden lasten m‰‰r‰
	lapsia17: 17-vuotiaiden lasten m‰‰r‰
	lapsia10_16: 10-16 -vuotiaiden lasten m‰‰r‰
	lapsiaalle10: Alle 10-vuotiaiden lasten m‰‰r‰
	lapsilisat: Lapsilis‰n m‰‰r‰, e/kk
	tyotulo: Tˆist‰ saadut tulot, e/kk
	muuttulot: Muut tulot, e/kk
	asmenot: Asumismenot, e/kk
	harkmenot: Harkinnanvaraiset menot, e/kk; 

%MACRO ToimTukiKS(tulos, mvuosi, mkuuk, minf, kryhma, ydinp, aik, aiklapsia, lapsia17,
lapsia10_16, lapsiaalle10, lapsilisat, tyotulo, muuttulot, asmenot, harkmenot)/STORE
DES = 'TOIMTUKI: Toimeentulotuki kuukausitasolla';

%HaeParam_ToimTuki&tyyppi(&mvuosi, &mkuuk, &minf);

*Kuntaryhman valinta.;
IF &kryhma = 1 THEN DO;
	perusmaara = &YksinKR1;
END;
ELSE DO;
	IF &kryhma = 2 THEN DO;
		perusmaara = &YksinKR2;
	END;
END;

*Lasketaan yksinasuvan perusosan suuruus.;
perus = &YksPros * perusmaara;
*Lasketaan yksinhuoltajan perusosan suuruus.;
perusyh = (1 + &Yksinhuoltaja) * perus;

%KuuNro_ToimTuki&tyyppi(kuuid, &mvuosi, &mkuuk);
%KuuNro_ToimTuki&tyyppi(kuuid1998_3, 1998, 3);

*Lasketaan aluksi toimeentulotuen suuruus, kun vain aikuiset ja aikuiset lapset otetaan huomioon.
Lasketaan erikseen ennen vuoden 1998 maaliskuuta olevassa tilanteessa ja sen j‰lkeen, sill‰ 
- Ennen vuoden 1998 maaliskuuta 17-vuotiaat on katsottu toimeentulotuessa aikuisiksi.
- Maaliskuusta 1998 l‰htien yksin aikuisten lasten kanssa asuva katsotaan toimeentulotuessa yksinasuvaksi.;

IF kuuid < kuuid1998_3 THEN DO;

	*Lasketaan normin suuruus, kun vain aikuiset ja aikuiset lapset otetaan huomioon.;
	IF &aik = 1 AND SUM(&lapsia10_16, &lapsiaalle10) > 0 THEN normi = perusyh + SUM(&aiklapsia, &lapsia17) * &AikLapsi18Plus * perus;
	ELSE IF &aik = 1 AND &ydinp = 1 AND SUM(&aiklapsia, &lapsia17) = 0 THEN normi = perus;
	ELSE normi = &aik * &Aik18Plus * perus + SUM(&aiklapsia, &lapsia17) * &AikLapsi18Plus * perus;

END;
ELSE DO;
	
	*Lasketaan normin suuruus, kun vain aikuiset ja aikuiset lapset otetaan huomioon.;
	IF &aik = 1 AND SUM(&lapsia17, &lapsia10_16, &lapsiaalle10) > 0 THEN normi = perusyh + &aiklapsia * &AikLapsi18Plus * perus;
	ELSE IF &aik = 1 AND &ydinp = 1 THEN normi = perus + &aiklapsia * &AikLapsi18Plus * perus;
	ELSE normi = &aik * &Aik18Plus * perus + &aiklapsia * &AikLapsi18Plus * perus;
	
END;

*Otetaan huomioon alaik‰iset lapset.;
%LapsKerrS(lapskerr, &mvuosi, &mkuuk, &lapsia17, &lapsia10_16, &lapsiaalle10);
normi = SUM(normi, lapskerr * perus);
	
*Toimeentulotuessa huomioon otettava tyˆtulo.;
IF &tyotulo > 0 THEN DO;
	vapaatulo = &VapaaOs * &tyotulo;
	IF vapaatulo > &VapaaOsRaja THEN vapaatulo = &VapaaOsRaja;
	tyotulohuomioon = SUM(&tyotulo, -vapaatulo);
END;
ELSE tyotulohuomioon = 0;

*Toimeentulotuessa huomioon otettavat tulot yhteens‰.
Vuodesta 1994 l‰htien myˆs lapsilis‰t on otettu tuloina huomioon.;
IF &mvuosi < 1994 THEN tulothuomioon = SUM(tyotulohuomioon, &muuttulot);
ELSE tulothuomioon = SUM(tyotulohuomioon, &muuttulot, &lapsilisat);

*Toimeentulotuessa huomioon otettavat asumismenot.;
asmenothuomioon = (SUM(1, -&AsOmaVast)) * &asmenot;

*Tulot - menot.;
netto = SUM(tulothuomioon, -asmenothuomioon, -&harkmenot);

*Toimeentulotuki yhteens‰.;
IF (netto >= normi) THEN tuki = 0;
ELSE tuki = SUM(normi, -netto);

&tulos = tuki;

DROP perusmaara perus perusyh kuuid kuuid1998_3
	 normi lapskerr vapaatulo tyotulohuomioon
	 tulothuomioon asmenothuomioon netto tuki;

%MEND ToimTukiKS;


/* 4. Makro laskee toimeentulotuen kuukausitasolla vuosikeskiarvona */

*Makron parametrit:
	tulos: Makron tulosmuuttuja, toimeentulotutuki, e/kk (vuosikeskiarvo)
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kryhma: Toimeentulotuen kuntaryhm‰
	ydinp: Onko kyseess‰ ydiperhe? (0/1)
	aik: Yli 18-vuotiaiden m‰‰r‰ poisluettuna yli 18-vuotiaat lapset
	aiklapsia: Yli 18-vuotiaiden lasten m‰‰r‰
	lapsia17: 17-vuotiaiden lasten m‰‰r‰
	lapsia10_16: 10-16 -vuotiaiden lasten m‰‰r‰
	lapsiaalle10: Alle 10-vuotiaiden lasten m‰‰r‰
	lapsilisat: Lapsilis‰n m‰‰r‰, e/kk
	tyotulo: Tˆist‰ saadut tulot, e/kk
	muuttulot: Muut tulot, e/kk
	asmenot: Asumismenot, e/kk
	harkmenot: Harkinnanvaraiset menot, e/kk; 

%MACRO ToimTukiVS(tulos, mvuosi, minf, kryhma, ydinp, aik, aiklapsia, lapsia17,
lapsia10_16, lapsiaalle10, lapsilisat, tyotulo, muuttulot, asmenot, harkmenot)/STORE
DES = 'TOIMTUKI: Toimeentulotuki kuukausitasolla vuosikeskiarvona';

ttvuosi = 0;

%DO kuuk = 1 %TO 12;
	%ToimTukiKS(ttkk, &mvuosi, &kuuk, &minf, &kryhma, &ydinp, &aik, &aiklapsia, &lapsia17,
	&lapsia10_16, &lapsiaalle10, &lapsilisat, &tyotulo, &muuttulot, &asmenot, &harkmenot);
	ttvuosi = SUM(ttvuosi, ttkk);
%END;

ttvuosi = ttvuosi / 12;

&tulos = ttvuosi;

DROP ttvuosi ttkk;

%MEND ToimTukiVS;


/* 5. Makro laskee toimeentulotuen perusosan ja lapsilis‰t yhteens‰ kuukausitasolla */

*Makron parametrit:
	tulos: Makron tulosmuuttuja, toimeentulotuen perusosa ja lapsilis‰t yhteens‰, e/kk
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kryhma: Toimeentulotuen kuntaryhm‰
	ydinp: Onko kyseess‰ ydiperhe? (0/1)
	aik: Yli 18-vuotiaiden m‰‰r‰ poisluettuna yli 18-vuotiaat lapset
	aiklapsia: Yli 18-vuotiaiden lasten m‰‰r‰
	lapsia17: 17-vuotiaiden lasten m‰‰r‰
	lapsia16: 16-vuotiaiden lasten m‰‰r‰
	lapsia10_15: 10-15 -vuotiaiden lasten m‰‰r‰
	lapsia3_9: 3-9 -vuotiaiden lasten m‰‰r‰
	lapsiaalle3: Alle 3-vuotiaiden lasten m‰‰r‰; 

%MACRO ToimTukiLLKS(tulos, mvuosi, mkuuk, minf, kryhma, ydinp, aik, aiklapsia,
lapsia17, lapsia16, lapsia10_15, lapsia3_9, lapsiaalle3)/STORE
DES = 'TOIMTUKI: Toimeentulotuen perusosa ja lapsilis‰t yhteens‰ kuukausitasolla';

*Ennen vuotta 1994 lapsilisi‰ ei otettu toimeentulotuessa tulona huomioon.;
IF &mvuosi < 1994 THEN DO;
	IF &aik = 1 THEN puoliso = 0;
	ELSE puoliso = 1;
	lapsia3_15 = SUM(&lapsia10_15, &lapsia3_9);
	%LLisaKS(llisak, &mvuosi, &mkuuk, &minf, puoliso, &lapsiaalle3, lapsia3_15, &lapsia16);
END;
ELSE llisak = 0;
	
lapsia10_16 = SUM(&lapsia10_15, &lapsia16);
lapsiaalle10 = SUM(&lapsia3_9, &lapsiaalle3);

%ToimTukiKS(ToimTukiK, &mvuosi, &mkuuk, &minf, &kryhma, &ydinp, &aik, &aiklapsia, &lapsia17,
lapsia10_16, lapsiaalle10, 0, 0, 0, 0, 0);

maara = SUM(llisak, ToimTukiK);

&tulos = maara;

DROP puoliso lapsia3_15 llisak lapsia10_16 lapsiaalle10 ToimTukiK maara;

%MEND ToimTukiLLKS;


/* 6. Makro laskee toimeentulotuen perusosan, lapsilis‰t ja asumistukinormien mukaan korvatut asumismenot yhteens‰ kuukausitasolla */

*Makron parametrit:
	tulos: Makron tulosmuuttuja, toimeentulotuen perusosa, lapsilis‰t ja korvatut asumismenot yhteens‰, e/kk
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kryhma1: Toimeentulotuen kuntaryhm‰
	kryhma2: Asumistuen kuntaryhm‰
	ydinp: Onko kyseess‰ ydiperhe? (0/1)
	aik: Yli 18-vuotiaiden m‰‰r‰ poisluettuna yli 18-vuotiaat lapset
	aiklapsia: Yli 18-vuotiaiden lasten m‰‰r‰
	lapsia17: 17-vuotiaiden lasten m‰‰r‰
	lapsia16: 16-vuotiaiden lasten m‰‰r‰
	lapsia10_15: 10-15 -vuotiaiden lasten m‰‰r‰
	lapsia3_9: 3-9 -vuotiaiden lasten m‰‰r‰
	lapsiaalle3: Alle 3-vuotiaiden lasten m‰‰r‰
	valmvuosi: Asunnon valmistumis-, peruskorjaus- tai perusparantamisvuosi; 

%MACRO VahimmTuloS(tulos, mvuosi, mkuuk, minf, kryhma1, kryhma2, ydinp, aik, aiklapsia,
lapsia17, lapsia16, lapsia10_15, lapsia3_9, lapsiaalle3, valmvuosi)/STORE
DES = 'TOIMTUKI: Toimeentulotuen perusosa, lapsilis‰t ja asumistukinormien mukaan korvatut asumismenot yhteens‰ kuukausitasolla';

henkiloitayhteensa = SUM(&aik, &aiklapsia, &lapsia17, &lapsia16, &lapsia10_15, &lapsia3_9, &lapsiaalle3);

*Kohtuulliset neliˆt ruokakunnan koon mukaan.;
%NormineliotS(normineliot, &mvuosi, &minf, henkiloitayhteensa, 0);

*Hyv‰ksytt‰v‰ asumiskustannus neliˆt‰ kohden.;
%NormivuokraS(normivuokra, &mvuosi, &minf, &kryhma2, 1, 1, &valmvuosi, normineliot);

vuokra = normineliot * normivuokra;

*Perusosa ja lapsilis‰t yhteens‰.;
%ToimTukiLLKS(toimtukillk, &mvuosi, &mkuuk, &minf, &kryhma1, &ydinp, &aik, &aiklapsia,
&lapsia17, &lapsia16, &lapsia10_15, &lapsia3_9, &lapsiaalle3);

tulo = SUM(toimtukillk, (SUM(1, -&AsOmaVast)) * vuokra); 

&tulos = tulo;

DROP henkiloitayhteensa normineliot normivuokra vuokra toimtukillk tulo;

%MEND VahimmTuloS;



