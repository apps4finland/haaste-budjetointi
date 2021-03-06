/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyödyntää Tilastokeskuksen yleisten
* käyttöehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto päähakemistossa.
******************************************************************************/

/*******************************************************************
*  Kuvaus: Sairausvakuutuksen päivärahojen lainsäädäntöä makroina  * 
*  Tekijä: Pertti Honkanen / KELA                                  *
*  Luotu: 12.09.2011                                               *
*  Viimeksi päivitetty: 19.12.2011 							       * 
*  Päivittäjä: Olli Kannas / TK                                    *
********************************************************************/


/* 1. SISÄLLYS */

/* Tiedosto sisältää seuraavat makrot */

/*
2.1 SairVakPrahaK1 = Sairausvakuutuksen päivärahan laskukaava, versio 1 helmikuuhun 1983 asti
2.2 SairVakPrahaK2 = Sairausvakuutuksen päivärahan laskukaava, versio 2 joulukuuhun 1983 asti
2.3 SairVakPrahaK3 = Sairausvakuutuksen päivärahan laskukaava, versio 3 joulukuuhun 1991 asti
2.4 SairVakPrahaK4 = Sairausvakuutuksen päivärahan laskukaava, versio 4 elokuuhun 1992 asti
2.5 SairVakPrahaK5 = Sairausvakuutuksen päivärahan laskukaava, versio 5 joulukuuhun 1995 asti
2.6 SairVakPrahaK6 = Sairausvakuutuksen päivärahan laskukaava, versio 6 tammikuusta 1996 lähtien
2.7 SairVakPrahaKS = Sairausvakuutuksen päiväraha kuukausitasolla
2.8 SairVakPrahaVS = Sairausvakuutuksen päiväraha kuukausitasolla vuosikeskiarvona
3. SairVakTuloKS = Sairausvakuutuksen päivärahan perusteena oleva vuositulo (käänteismakro)
4. SairVakTuloVS = Sairausvakuutuksen päivärahan perusteena oleva vuositulo vuosikeskiarvona (käänteismakro)
5. HarkPRahaS = Tarveharkintainen sairausvakuutuksen päiväraha (1996 - 2002) kuukausitasolla
6. KorVanhRahaKS = Korotettu vanhempainpäiväraha kuukausitasolla
7. KorVanhRahaVS = Korotettu vanhempainpäiväraha kuukausitasolla vuosikeskiarvona
8. VanhPRahaKS = Eri suuruiset vanhempainpäivärahat päivätasolla
9. EtsiVahimm = Pienimpään vanhempainpäivärahaan johtava tulotaso kuukausitasolla 
10. VanhRahaTuloS = Vanhempainpäivärahojen perusteena oleva tulo kuukausitasolla, kun koko päivärahatulo ja erilaisten tasojen päivät tiedetään
*/


/* 2. Kuusi sairausvakuutuksen päivärahan laskumakroa lainsäädännön muutosten perusteella.
      Tässä ei vielä oteta huomioon lapsikorotuksia. 
	  Näissä kaavoissa ei myöskään vielä tarvita kerrointa, joilla 
      laskennan perusteena olevia työtuloja alennetaan vuodesta 1993 lähtien.
      Kaavat laskevat päivärahan kuukausitasolla (25 * päiväarvo)  */

*Päivärahamakrojen parametrit:
tulos: Makron tulosmuuttuja, opintorahaan vanhempien tulojen perusteella laskettava korotus, e/kk 
mvuosi: Vuosi, jonka lainsäädäntöä käytetään
mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
minf: Deflaattori euromääräisten parametrien kertomiseksi 
vanh: Onko vanhempainpäiväraha (=1) tai ei (=0)
lapsia: Alaikäisten lasten lukumäärä (ei vaikutusta vuoden 1993 jälkeen, parametrin arvo parametritaulukossa ratkaisee)
tulo: Henkilön omat (työ)tulot, e/vuosi;

/* 2.1 Laskukaava helmikuuhun 1983 asti */

%MACRO SairVakPrahaK1 (tulos, tulo)/STORE
DES = 'SAIRVAK: Sairausvakuutuksen päivärahan laskukaava, versio 1 helmikuuhun 1983 asti';

temp = &SPros1 * &tulo / &maxpaiv;
temp =  &Minimi + temp;

IF (temp < &SPros2 * &tulo / &maxpaiv) THEN temp = &SPros2 * &tulo / &maxpaiv;

temp = &SPaivat * temp;
&tulos = temp;
DROP temp;
%MEND SairVakPrahaK1;

/* 2.2 Laskukaava joulukuuhun 1983 asti */

%MACRO SairVakPrahaK2 (tulos,  tulo)/STORE
DES = 'SAIRVAK: Sairausvakuutuksen päivärahan laskukaava, versio 2 joulukuuhun 1983 asti';

temp = &SPros1 * &tulo / &maxpaiv;
temp =  &Minimi + temp;

IF (temp < &SPros2 * &tulo / &maxpaiv) THEN temp = &SPros2 * &tulo / &maxpaiv;
IF (temp <  &Minimi) THEN temp =  &Minimi;
IF (&tulo >  &SRaja1) THEN temp = (&SPros2 *  &SRaja1 + &SPros3 * (&tulo -  &SRaja1)) / &maxpaiv;

temp = &SPaivat * temp;
&tulos = temp;
DROP temp;
%MEND SairVakPrahaK2;

/* 2.3 Laskukaava joulukuuhun 1991 asti */

%MACRO SairVakPrahaK3 (tulos,  tulo)/STORE
DES = 'SAIRVAK: Sairausvakuutuksen päivärahan laskukaava, versio 3 joulukuuhun 1991 asti';

temp = &SPros1 * &tulo/&maxpaiv;
temp =  &Minimi + temp;

IF (temp < &SPros2 * &tulo / &maxpaiv) THEN temp = &SPros2 * &tulo / &maxpaiv;
IF (&tulo >  &SRaja1) THEN temp = (&SPros2 *  &SRaja1 + &SPros3 * (&tulo -  &SRaja1)) / &maxpaiv;
IF (&tulo >  &SRaja2) THEN temp = (&SPros2 *  &SRaja1 + &SPros3*  (&SRaja2 - &SRaja1)
	+ &SPros4 * (&tulo -  &SRaja2)) / &maxpaiv;

temp = &SPaivat * temp;
&tulos = temp;
DROP temp;
%MEND SairVakPrahaK3;

/* 2.4 Laskukaava elokuuhun 1992 asti */

%MACRO SairVakPrahaK4 (tulos,  tulo)/STORE
DES = 'SAIRVAK: Sairausvakuutuksen päivärahan laskukaava, versio 4 elokuuhun 1992 asti';

temp = &SPros1 * &tulo/&maxpaiv;
temp =  &Minimi + temp;

IF (temp < &SPros2 * &tulo / &maxpaiv) THEN temp = &SPros2 * &tulo / &maxpaiv;
IF (&tulo >  &SRaja1) THEN temp = (&SPros2 *  &SRaja1+ &SPros3 * (&tulo -  &SRaja1)) / &maxpaiv;
IF (&tulo >  &SRaja2) THEN temp = (&SPros2 *  &SRaja1 + &SPros3 *  (&SRaja2 - &SRaja1)
	+ &SPros4 * (&tulo -  &SRaja2)) / &maxpaiv;
IF (&tulo >  &SRaja3) THEN temp = (&SPros2 *  &SRaja1 + &SPros3 *  (&SRaja2 - &SRaja1)
	+ &SPros4 * (&SRaja3 - &SRaja2) + &SPros5 * (&tulo -  &SRaja3)) / &maxpaiv;

temp = &SPaivat * temp;
&tulos = temp;
DROP temp;
%MEND SairVakPrahaK4;

/* 2.5 Laskukaava joulukuuhun 1995 asti */

%MACRO SairVakPrahaK5 (tulos, mvuosi, vanh,  tulo)/STORE
DES = 'SAIRVAK: Sairausvakuutuksen päivärahan laskukaava, versio 5 joulukuuhun 1995 asti';

temp =  &Minimi + &SPros1 * &tulo / &maxpaiv;

IF &tulo >  &SRaja1 THEN DO;
	temp =  &Minimi + &SPros1 * &SRaja1 / &maxpaiv;
	temp = temp + &SPros2 * (&tulo -  &SRaja1) / &maxpaiv;
END;
IF (&tulo >  &SRaja2) THEN DO;
	temp =  &Minimi + &SPros1 *  &SRaja1 / &maxpaiv + &SPros2 *  (&SRaja2 - &SRaja1) / &maxpaiv;
	temp = temp + &SPros3 * (&tulo -  &SRaja2) / &maxpaiv;
END;
IF (&tulo >  &SRaja3) THEN DO;
	temp =  &Minimi + &SPros1 *  &SRaja1 / &maxpaiv + &SPros2*  (&SRaja2 - &SRaja1) / &maxpaiv 
		+ &SPros3 *  (&SRaja3 - &SRaja2) / &maxpaiv;
	temp = temp + &SPros4 * (&tulo -  &SRaja3) / &maxpaiv;
END;
IF &vanh NE 0 THEN DO;
	IF (temp <  &VanhMin) THEN  temp =   &VanhMin;
END;

*Poikkeukselliset pienten päivärahojen korotukset;
*Huom! Vuonna 1994 kriteerinä päiväraha ja 1995 tulo;
IF (&mvuosi = 1994) AND  (temp <  &PoikRaja1) THEN temp = (1 + &PoikPros) * temp;
IF (&mvuosi = 1995) AND  (&tulo <  &PoikRaja2) THEN temp = (1 + &PoikPros) * temp;

temp = &SPaivat * temp;
&tulos = temp;
DROP temp;
%MEND SairVakPrahaK5;

/* 2.6 Laskukaava tammikuusta 1996 lähtien */

%MACRO SairVakPrahaK6 (tulos,  vanh, tulo)/STORE
DES = 'SAIRVAK: Sairausvakuutuksen päivärahan laskukaava, versio 6 tammikuusta 1996 lähtien';

IF (&tulo <  &SRaja1) THEN &tulos = 0;
IF (&tulo >=  &SRaja1) THEN &tulos = &SPros1 * &tulo / &maxpaiv;
IF (&tulo >  &SRaja2) THEN &tulos = &SPros1 *  &SRaja2 / &maxpaiv + &SPros2 * (&tulo -  &SRaja2) / &maxpaiv;
IF (&tulo >  &SRaja3) THEN &tulos = &SPros1 *  &SRaja2 / &maxpaiv + &SPros2 *  (&SRaja3-&SRaja2) / &maxpaiv + &SPros3 * (&tulo -  &SRaja3) / &maxpaiv;
IF (&vanh NE 0) AND  (&tulos <  &VanhMin) THEN &tulos =  &VanhMin;

&tulos = &SPaivat * &tulos;
%MEND SairVakPrahaK6;


/* 2.7 Makro laskee sairausvakuutuksen päivärahan kuukausitasolla valitsemalla ajankohdan mukaan jonkin edellisistä makroista. 
	   Tässä vaiheessa lisätään (mahdolliset) lapsikorotukset.
	   Kerroin, jolla työtuloa alennetaan, otetaan myös tässä huomioon */

%MACRO SairVakPrahaKS (tulos, mvuosi, mkuuk, minf, vanh, lapsia, tulo)/STORE
DES = 'SAIRVAK: Sairausvakuutuksen päiväraha kuukausitasolla';

%HaeParam_SairVak&tyyppi (&mvuosi, &mkuuk, &minf);

tyotulo = (1 - &PalkVah) * &tulo ;
IF tyotulo < 0 THEN tyotulo = 0;
lapsluku = &lapsia;
IF lapsluku > &SMaksLaps THEN lapsluku = &SMaksLaps;
lapsikorot = &SPaivat * lapsluku *  &LapsiKor;

%KuuNro_SairVak&tyyppi (kuuid, &mvuosi, &mkuuk);

*Ennen maaliskuuta 1983;
IF kuuid < 12 * (1983 - &paramalkusv) + 3 THEN DO;
	%SairVakPrahaK1(temp, tyotulo)
END;

*Ennen tammikuuta 1984;
IF kuuid >= 12 * (1983 - &paramalkusv) + 3 AND  kuuid < 12 * (1984 - &paramalkusv) + 1 THEN DO;
	%SairVakPrahaK2(temp,   tyotulo);
END;

*Ennen tammikuuta 1992;
IF kuuid >= 12 * (1984 - &paramalkusv) + 1 AND  kuuid < 12 * (1992 - &paramalkusv) + 1 THEN DO;
	%SairVakPrahaK3(temp,   tyotulo);
END;

*Ennen syyskuuta 1992;
IF kuuid >= 12 * (1992 - &paramalkusv) + 1 AND  kuuid < 12 * (1992 - &paramalkusv) + 9 THEN DO;
	%SairVakPrahaK4(temp,    tyotulo);
END;

*Ennen tammikuuta 1996;
IF kuuid >= 12 * (1992 - &paramalkusv) + 9 AND  kuuid < 12 * (1996 - &paramalkusv) + 1 THEN DO;
	%SairVakPrahaK5(temp, &mvuosi,   &vanh, tyotulo);
END;

*Tammikuusta 1996 lähtien;
IF kuuid >= 12 * (1996 - &paramalkusv) + 1 THEN DO;
	%SairVakPrahaK6(temp,  &vanh, tyotulo);
END;

&tulos = temp + lapsikorot;
DROP kuuid temp tyotulo lapsluku lapsikorot ;
%MEND SairVakPrahaKS;


/* 2.8. Makro laskee sairausvakuutuksen päivärahan kuukausitasolla vuosikeskiarvona */

%MACRO SairVakPrahaVS (tulos, mvuosi, minf, vanh, lapsia, tulo)/STORE
DES = 'SAIRVAK: Sairausvakuutuksen päiväraha kuukausitasolla vuosikeskiarvona';

raha = 0;

%DO i = 1 %TO 12;
	%SairVakPrahaKS(temp, &mvuosi, &i, &minf, &vanh, &lapsia,  &tulo);
	raha = raha + temp;
%END;

&tulos = raha / 12;
DROP raha temp;
%MEND SairVakPrahaVS;


/* 3. Käänteismakro, jonka avulla voidaan päätellä päivärahan perusteena oleva vuositulo */

*Makron parametrit:
tulos: Makron tulosmuuttuja, sairausvakuutuksen päivärahan perusteena oleva tulo, e/vuosi 
mvuosi: Vuosi, jonka lainsäädäntöä käytetään
mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
minf: Deflaattori euromääräisten parametrien kertomiseksi 
vanh: Onko vanhempainpäiväraha (=1) tai ei (=0)
lapsia: Alaikäisten lasten lukumäärä (ei vaikutusta vuoden 1993 jälkeen, parametrin arvo parametritaulukossa ratkaisee)
praha: Sairausvakuutuksen päiväraha,;

%MACRO SairVakTuloKS(tulos, mvuosi, mkuuk, minf, vanh, lapsia, praha)/STORE
DES = 'SAIRVAK: Sairausvakuutuksen päivärahan perusteena oleva vuositulo (käänteismakro)';

%SairVakPRahaKS(testi, &mvuosi, &mkuuk, &minf, &vanh, &lapsia,  0);

IF &praha <= testi THEN &tulos = 0;
	ELSE DO;
		DO i = 1 TO 100 UNTIL(testi >= &praha);
			%SairVakPrahaKS(testi, &mvuosi, &mkuuk, &minf, &vanh, &lapsia,  i * 10000);
		END;
		DO j = -9 TO 9 UNTIL(testi >= &praha);
			%SairVakPrahaKS(testi, &mvuosi, &mkuuk, &minf, &vanh, &lapsia,  (i * 10000 + j * 1000) );
		END;
		DO k = -9 TO 9 UNTIL(testi >= &praha);
			%SairVakPrahaKS(testi, &mvuosi, &mkuuk, &minf, &vanh, &lapsia,  (i * 10000 + j * 1000 + k * 100));
		END;
		DO m = -9 TO 9 UNTIL(testi >= &praha);
			%SairVakPrahaKS(testi, &mvuosi, &mkuuk, &minf, &vanh, &lapsia,  (i * 10000 + j * 1000 + k * 100 + m * 10));
		END;
		DO n = -9 TO 9 UNTIL(testi >= &praha);
			%SairVakPrahaKS(testi, &mvuosi, &mkuuk, &minf, &vanh, &lapsia,  (i * 10000 + j * 1000 + k * 100 + m * 10 + n ));
		END;
		DO p = -9 TO 9 UNTIL(testi >= &praha);
			%SairVakPrahaKS(testi, &mvuosi, &mkuuk, &minf, &vanh, &lapsia, (i * 10000 + j * 1000 + k * 100 + m * 10 + n + p / 10));
		END;
	&tulos = (i * 10000 + j * 1000 + k * 100 + m * 10 + n + p / 10);
END;

&tulos =&tulos;
DROP i j k m n p testi;
%MEND SairVakTuloKS;


/* 4. Makro, jonka avulla voidaan päätellä päivärahan perusteena oleva vuositulo vuosikeskiarvona */

*Makron parametrit:
tulos: Makron tulosmuuttuja, päivärahan perusteena oleva tulo, e/vuosi (vuosikeskiarvo)
mvuosi: Vuosi, jonka lainsäädäntöä käytetään
mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
minf: Deflaattori euromääräisten parametrien kertomiseksi 
vanh: Onko vanhempainpäiväraha (=1) tai ei (=0)
lapsia: Alaikäisten lasten lukumäärä (ei vaikutusta vuoden 1993 jälkeen, parametrin arvo parametritaulukossa ratkaisee)
praha: Sairausvakuutuksen päiväraha, e/kk;

%MACRO SairVakTuloVS(tulos, mvuosi, minf, vanh, lapsia, praha)/STORE
DES = 'SAIRVAK: Sairausvakuutuksen päivärahan perusteena oleva vuositulo (käänteismakro) vuosikeskiarvona';

%SairVakPrahaVS(testi, &mvuosi, &minf, &vanh, &lapsia,  0);

IF &praha <= testi THEN &tulos = 0;
	ELSE DO;
		DO i = 1 TO 100 UNTIL(testi >= &praha);
			%SairVakPrahaVS(testi, &mvuosi, &minf, &vanh, &lapsia,  i * 10000);
		END;
		DO j = -9 TO 9 UNTIL(testi >= &praha);
			%SairVakPrahaVS(testi, &mvuosi, &minf, &vanh, &lapsia,  (i * 10000 + j * 1000) );
		END;
		DO k = -9 TO 9 UNTIL(testi >= &praha);
			%SairVakPrahaVS(testi, &mvuosi, &minf, &vanh, &lapsia,  (i * 10000 + j * 1000 + k * 100));
		END;
		DO m = -9 TO 9 UNTIL(testi >= &praha);
			%SairVakPrahaVS(testi, &mvuosi, &minf, &vanh, &lapsia,  (i * 10000 + j * 1000 + k * 100 + m * 10));
		END;
		DO n = -9 TO 9 UNTIL(testi >= &praha);
			%SairVakPrahaVS(testi, &mvuosi, &minf, &vanh, &lapsia,  (i * 10000 + j * 1000 + k * 100 + m * 10 + n ));
		END;
		DO p = -9 TO 9 UNTIL(testi >= &praha);
			%SairVakPrahaVS(testi, &mvuosi, &minf, &vanh, &lapsia, (i * 10000 + j * 1000 + k * 100 + m * 10 + n + p / 10));
		END;
	&tulos = (i * 10000 + j * 1000 + k * 100 + m * 10 + n + p / 10);
END;

&tulos = &tulos;
DROP i j k m n p testi;
%MEND SairVakTuloVS;


/* 5. Makro laskee vuosina 1996 - 2002 sovelletun tarveharkintaisen sairausvakuutuksen päivärahan kuukausitasolla. 
	  Jos harkinnan parametrit eivät ole voimassa, makro tuottaa minipäivärahan */

*Makron parametrit:
tulos: Makron tulosmuuttuja, tarveharkintainen päiväraha, e/kk
mvuosi: Vuosi, jonka lainsäädäntöä käytetään
mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
minf: Deflaattori euromääräisten parametrien kertomiseksi 
tulo: Henkilön omat tulot, e/kk
puoltulo: Puolison tulot, e/kk 
varall: Veronalainen varallisuus, e;

%MACRO HarkPRahaS(tulos, mvuosi, mkuuk, minf, tulo, puoltulo, varall)/STORE
DES = 'SAIRVAK: Tarveharkintainen sairausvakuutuksen päiväraha (1996 - 2002) kuukausitasolla';

%HaeParam_SairVak&tyyppi(&mvuosi, &mkuuk, &minf);

temp = &Minimi;
temp = &Minimi - &HarkRaja * &tulo - &HarkPuol  * &puoltulo;
IF temp < 0 THEN temp = 0;

%KuuNro_SairVak&tyyppi (kuuid, &mvuosi, &mkuuk);

IF kuuid < (12 * (2002  - &paramalkusv) + 4) AND  kuuid >= (12 * (1996 - &paramalkusv) + 1) THEN DO;
	IF &varall >  &VarRaja THEN temp = 0;
END;

&tulos = &SPaivat * temp;
DROP temp;
%MEND HarkPRahaS;


/* 6. Makro laskee vuonna 2007 käyttöön otetut korotetun vanhempainpäivärahan kuukausitasolla */

*Makron parametrit:
tulos: Makron tulosmuuttuja, korotettu vanhempainpäiväraha, e/kk
mvuosi: Vuosi, jonka lainsäädäntöä käytetään
mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
minf: Deflaattori euromääräisten parametrien kertomiseksi 
ait: (1 tai 0), äideille ensimmäisten 56 äitiyslomapäivän aikana
     myönnettävä korotettu päiväraha, jossa käytetään 90 prosentin
     kerrointa. Muuten kyse on 75 prosentin kertoimesta alkuperäisen
     lainsäädännön mukaan.
lapsia: Alaikäisten lasten lukumäärä (ei vaikutusta vuoden 1993 jälkeen, parametrin arvo parametritaulukossa ratkaisee)
tulo: Henkilön omat (työ)tulot, e/vuosi;

%MACRO KorVanhRahaKS (tulos, mvuosi, mkuuk, minf, ait, lapsia, tulo)/STORE
DES = 'SAIRVAK: Korotettu vanhempainpäiväraha kuukausitasolla';

*ennen vuotta 2007 lasketaan normaali päiväraha;
IF &mvuosi < 2007 THEN DO;
	%SairVakPrahaKS(&tulos, &mvuosi, &mkuuk, &minf, 1, &lapsia, &tulo);
END;

IF &mvuosi > 2006 THEN DO;

	%HaeParam_SairVak&tyyppi(&mvuosi, &mkuuk, &minf);

	tyotulo = (1 - &PalkVah)* &tulo;
	IF (tyotulo < 0) THEN tyotulo = 0;
	IF tyotulo <  &SRaja3 THEN DO;
		IF &ait NE 0 THEN temp = &KorProsAit * tyotulo / &maxpaiv;
		IF &ait = 0 THEN temp = &KorPros1 * tyotulo / &maxpaiv;
	END;
	ELSE DO;
		IF &ait NE 0 THEN temp = (&KorProsAit *  &SRaja3 + &KorPros2 * (tyotulo -  &SRaja3)) / &maxpaiv;
		IF &ait = 0 THEN temp = (&KorPros1 *  &SRaja3 + &KorPros2 * (tyotulo -  &SRaja3)) / &maxpaiv;
	END;
	IF temp <  &VanhMin THEN temp =  &VanhMin;
	temp = &SPaivat * temp;
	&tulos = temp;
END;

DROP tyotulo temp;
%MEND KorVanhRahaKS;


/* 7. Vuonna 2007 käyttöön otetut korotetut vanhempainrahat kuukausitasolla vuosikeskiarvona */

*Makron parametrit:
tulos: Makron tulosmuuttuja, korotettu vanhempainpäiväraha, e/kk (vuosikeskiarvo)
mvuosi: Vuosi, jonka lainsäädäntöä käytetään
mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
minf: Deflaattori euromääräisten parametrien kertomiseksi 
ait: (1 tai 0), äideille ensimmäisten 56 äitiyslomapäivän aikana
     myönnettävä korotettu päiväraha, jossa käytetään 90 prosentin
     kerrointa. Muuten kyse on 75 prosentin kertoimesta alkuperäisen
     lainsäädännön mukaan.
lapsia: Alaikäisten lasten lukumäärä (ei vaikutusta vuoden 1993 jälkeen, parametrin arvo parametritaulukossa ratkaisee)
tulo: Henkilön omat (työ)tulot, e/vuosi;

%MACRO KorVanhRahaVS (tulos, mvuosi,  minf, ait, lapsia, tulo)/STORE
DES = 'SAIRVAK: Korotettu vanhempainpäiväraha kuukausitasolla vuosikeskiarvona';

raha = 0;

%DO i = 1 %to 12;
	%KorVanhRahaKS(temp, &mvuosi, &i, &minf, &ait, &lapsia,  &tulo);
	raha = raha + temp;
%END;

&tulos = raha / 12;
DROP raha temp;
%MEND KorVanhRahaVS;


/* 8. Makro laskee valinnan mukaan eri tasoiset vanhempainpäivärahat päivätasolla */

*Makron parametrit:
tulos: Makron tulosmuuttuja, vanhempainpäiväraha, e/päivä 
mvuosi: Vuosi, jonka lainsäädäntöä käytetään
mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
minf: Deflaattori euromääräisten parametrien kertomiseksi 
ait: 1 tai 0, korotettu äitiyspäiväraha 56 ensimmäiseltä päivältä
kor: 1 tai 0, korotettu vanhempainraha
norm: 1 tai 0, normaali päiväraha
lapsia: alaikäisten lasten lukumäärä (ei vaikutusta vuoden 1993 jälkeen, parametrin arvo parametritaulukossa ratkaisee)
vanhtulo: Henkilön omat (työ)tulot, e/vuosi; 

%MACRO VanhPRahaKS (tulos, mvuosi, mkuuk, minf, ait, kor, norm, lapsia, vanhtulo)/STORE
DES = 'SAIRVAK: Eri suuruiset vanhempainpäivärahat päivätasolla';

*Ennen vuotta 2007 lasketaan normaali päiväraha;
IF &mvuosi < 2007 THEN DO;
	%SairVakPrahaKS(temp, &mvuosi, &mkuuk, &minf, 1, &lapsia, &vanhtulo);
	&tulos = temp / &SPaivat;
END;

*Muussa tapauksessa noudatetaan uutta lainsäädäntöä;
*Ehtolauseiden järjestys merkitsee sitä, että vain ensimmäinen ehdoista (ait, kor, norm) hyväksytään;

IF &mvuosi >= 2007 THEN DO;

	%HaeParam_SairVak&tyyppi(&mvuosi, &mkuuk, &minf);

	tyotulo = (1 - &palkvah) * (&vanhtulo);
	IF &norm = 1 THEN DO;
		IF (tyotulo >=  &SRaja1) THEN temp = &SPros1 * tyotulo / &maxpaiv;
		IF (tyotulo >  &SRaja2) THEN temp = &SPros1 *  &SRaja2 / &maxpaiv + &SPros2 * (tyotulo -  &SRaja2) / &maxpaiv;
		IF (tyotulo >  &SRaja3) THEN temp = &SPros1 *  &SRaja2 / &maxpaiv + &SPros2 *  (&SRaja3-&SRaja2) / &maxpaiv + &SPros3 * (tyotulo -  &SRaja3) / &maxpaiv;
	END;
	IF &kor = 1 THEN DO;
		IF (tyotulo <  &SRaja3) THEN temp = &KorPros1 * tyotulo / &maxpaiv;
		ELSE temp = (&KorPros1 *  &SRaja3 + &KorPros2 * (tyotulo -  &SRaja3)) / &maxpaiv;
	END;
	IF &ait = 1 THEN DO;
		IF (tyotulo <  &SRaja3) THEN temp = &KorProsAit * tyotulo / &maxpaiv;
		ELSE temp = (&KorProsAit *  &SRaja3 + &KorPros2 * (tyotulo -  &SRaja3)) / &maxpaiv;
	END;
	IF (temp <  &VanhMin) THEN temp =  &VanhMin;
	&tulos  = temp;
END;

DROP temp;
%MEND VanhPRahaKS;


/* 9. Makro, joka laskee kuukausitasolla pienimpään päivärahaan johtavan tulotason ottamalla huomioon eri
      vanhempainpäivärahatasot */

*Makron parametrit:
tulos: Makron tulosmuuttuja, pienimpään päivärahaan johtavan tulo, e/kk 
mvuosi: Vuosi, jonka lainsäädäntöä käytetään
normpaiv: Normaalit päivärahapäivät
korpaiv90: Korotetut päivät 90 %:n korvausasteella
korpaiv75: Korotetut päivät 75 %:n korvausasteella;

%MACRO EtsiVahimm (tulos, mvuosi, normpaiv, korpaiv90, korpaiv75)/STORE
DES = 'SAIRVAK: Pienimpään vanhempainpäivärahaan johtava tulotaso kuukausitasolla';

%HaeParam_SairVak&tyyppi(&mvuosi, 1, 1);

&tulos = 0;

IF &korpaiv90 > 0 THEN
 	&tulos = &maxpaiv * &VanhMin / (&KorProsAit * (1 - &palkvah));
IF &korpaiv75 > 0 AND  &korpaiv90 = 0 THEN
 	&tulos = &maxpaiv * &VanhMin / (&KorPros1 *( 1 - &palkvah));
IF &korpaiv75 = 0 AND  &korpaiv90 = 0 THEN
 	&tulos = &maxpaiv * &VanhMin / (&SPros1 * (1 - &palkvah));

%MEND EtsiVahimm;


/* 10. Makro, joka laskee vanhempainpäivärahan perusteena olevan
      tulon kuukausitasolla, kun tiedätään koko päivärahatulo ja erilaisten tasojen päivärahapäivät */

*Makron parametrit:
tulos: Makron tulosmuuttuja, vanhempainpäivärahan perusteena olevan tulo, e/kk 
mvuosi: Vuosi, jonka lainsäädäntöä käytetään
normpaiv: Normaalit päivärahapäivät
korpaiv90: Korotetut päivät 90 %:n korvausasteella
korpaiv75: Korotetut päivät 75 %:n korvausasteella
praha: Vanhempainpäiväraha, e/kk;

%MACRO VanhRahaTuloS(tulos, mvuosi, normpaiv, korpaiv90, korpaiv75, praha)/STORE
DES = 'SAIRVAK: Vanhempainpäivärahojen perusteena oleva tulo kuukausitasolla, kun koko päivärahatulo
ja erilaisten tasojen päivät tiedetään';

*Yli 100 000 euron päivärahatulot sivuutetaan;
IF &praha > 100000 THEN &tulos = 999999;

*Testataan vähimmäispäiväraha;
vahimm = &normpaiv *  &VanhMin + &korpaiv90 * &VanhMin + &korpaiv75 * &VanhMin;

IF &praha <= vahimm THEN DO;

	%EtsiVahimm(vahimmtulo, &mvuosi, &normpaiv, &korpaiv90, &korpaiv75);
	&tulos = RAND('UNIFORM')* vahimmtulo;
END;

IF &praha > vahimm THEN DO;
	testi = 0;
	DO i = 1 TO 10 UNTIL(testi >= &praha);
		testitulo = i * 100000;
		%VanhPRahaKS(testi1, &mvuosi, 1, 1, 0, 0, 1, 0, testitulo);
		%VanhPRahaKS(testi2, &mvuosi, 1, 1, 0, 1, 0, 0, testitulo);
		%VanhPRahaKS(testi3, &mvuosi, 1, 1, 1, 0, 0, 0, testitulo);
		testi = &normpaiv * testi1 + &korpaiv75 * testi2 + &korpaiv90 * testi3;
	END;
	DO j = -9 TO 10 UNTIL(testi >= &praha);
		testitulo = (i * 100000 + j*10000);
		%VanhPRahaKS(testi1, &mvuosi, 1, 1, 0, 0, 1, 0, testitulo);
		%VanhPRahaKS(testi2, &mvuosi, 1, 1, 0, 1, 0, 0, testitulo);
		%VanhPRahaKS(testi3, &mvuosi, 1, 1, 1, 0, 0, 0, testitulo);
		testi = &normpaiv * testi1 + &korpaiv75 * testi2 + &korpaiv90 * testi3;
	END;
	DO k = -9 TO 10 UNTIL(testi >= &praha);
		testitulo = ( i * 100000 + j*10000 + k * 1000);
		%VanhPRahaKS(testi1, &mvuosi, 1, 1, 0, 0, 1, 0, testitulo);
		%VanhPRahaKS(testi2, &mvuosi, 1, 1, 0, 1, 0, 0, testitulo);
		%VanhPRahaKS(testi3, &mvuosi, 1, 1, 1, 0, 0, 0, testitulo);
		testi = &normpaiv * testi1 + &korpaiv75 * testi2 + &korpaiv90 * testi3;
	END;
	DO m = -9 TO 10 UNTIL(testi >= &praha);
		testitulo = (i * 100000 + j*10000 + k * 1000 + m * 100);
		%VanhPRahaKS(testi1, &mvuosi, 1, 1, 0, 0, 1, 0, testitulo);
		%VanhPRahaKS(testi2, &mvuosi, 1, 1, 0, 1, 0, 0, testitulo);
		%VanhPRahaKS(testi3, &mvuosi, 1, 1, 1, 0, 0, 0, testitulo);
		testi = &normpaiv * testi1 + &korpaiv75 * testi2 + &korpaiv90 * testi3;
	END;
	DO n = -9 TO 10 UNTIL(testi >= &praha);
		testitulo = (i * 100000 + j*10000 + k * 1000 + m * 100 + n * 10);
		%VanhPRahaKS(testi1, &mvuosi, 1, 1, 0, 0, 1, 0, testitulo);
		%VanhPRahaKS(testi2, &mvuosi, 1, 1, 0, 1, 0, 0, testitulo);
		%VanhPRahaKS(testi3, &mvuosi, 1, 1, 1, 0, 0, 0, testitulo);
		testi = &normpaiv * testi1 + &korpaiv75 * testi2 + &korpaiv90 * testi3;
	END;
	DO p = -9 TO 10 UNTIL(testi >= &praha);
		testitulo = (i * 100000 + j*10000 + k * 1000 + m * 100 + n * 10 + p);
		%VanhPRahaKS(testi1, &mvuosi, 1, 1, 0, 0, 1, 0, testitulo);
		%VanhPRahaKS(testi2, &mvuosi, 1, 1, 0, 1, 0, 0, testitulo);
		%VanhPRahaKS(testi3, &mvuosi, 1, 1, 1, 0, 0, 0, testitulo);
		testi = &normpaiv * testi1 + &korpaiv75 * testi2 + &korpaiv90 * testi3;
	END;

	&tulos = testitulo;

END;

DROP vahimm vahimmtulo testi testi1 testi2 testi3 testitulo;
%MEND VanhRahaTuloS;
	



