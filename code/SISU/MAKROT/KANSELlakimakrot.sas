/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyödyntää Tilastokeskuksen yleisten
* käyttöehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto päähakemistossa.
******************************************************************************/

/************************************************************************
* Kuvaus: Kelan eläkkeiden ja vammaistukien lainsäädäntöä makroina      *
* Tekijä: Jussi Tervola /KELA		                		   		    *
* Luotu: 8.9.2011				       					   			    * 
* Viimeksi päivitetty: 25.9.2012		  		  	       			    *
* Päivittäjä: Jussi Tervola /KELA 										*
*************************************************************************/ 


/* 1. SISÄLLYS */

/* Tiedosto sisältää seuraavat makrot */

/*
2. Kansanelake_SimpleKS = Kansaneläke kuukausitasolla
3. Kansanelake_SimpleVS = Kansaneläke kuukausitasolla vuosikeskiarvona
4. KanselTuloKS = Kansaneläkkeen ja takuueläkkeen perusteena oleva vuositulo
5. KanselTuloVS = Kansaneläkkeen ja takuueläkkeen perusteena oleva vuositulo vuosikeskiarvona
6. TakuuElakeKS = Takuueläke kuukausitasolla
7. TakuuElakeVS = Takuueläke kuukausitasolla vuosikeskiarvona
8. LapsenElakeaKS = Lapseneläke kuukausitasolla
9. LapsenElakeaVS = Lapseneläke kuukausitasolla vuosikeskiarvona
10. LeskenElakeaKS = Leskeneläke kuukausitasolla
11. LeskenElakeaVS = Leskeneläke kuukausitasolla vuosikeskiarvona
12. PerhElTuloKS = Perhe-eläkkeen perusteena olevan vuositulo
13. PerhElTuloVS = Perhe-eläkkeen perusteena olevan vuositulo vuosikeskiarvona
14. MaMuErTukiKS = Maahanmuuttajan erityistuki kuukausitasolla
15. MaMuErTukiVS = Maahanmuuttajan erityistuki kuukausitasolla vuosikeskiarvona
16. SotilasAvKS = Sotilasavustus kuukausitasolla
17. SotilasAvVS = Sotilasavustus kuukausitasolla vuosikeskiarvona 
18. VammTukiKS = Vammaistuki ja ruokavaliokorvaus kuukausitasolla
19. VammTukiVS = Vammaistuki ja ruokavaliokorvaus kuukausitasolla vuosikeskiarvona 
20. KanselLisatKS = Kansaneläkkeeseen liittyvät lisät kuukausitasolla
21. KanselLisatVS = Kansaneläkkeeseen liittyvät lisät kuukausitasolla vuosikeskiarvona
22. YlimRintLisaKS = Ylimääräinen rintamalisä kuukausitasolla
23. YlimRintLisaVS = Ylimääräinen rintamalisä kuukausitasolla vuosikeskiarvona
*/


/*  2. Makro laskee kansaneläkkeen kuukausitasolla */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, kansaneläke, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
    laitos: Asuuko henkilö laitoksessa (0/1)
	puoliso: Onko henkilöllä puoliso (0/1)
	kryhma: Kuntaryhmä (1/2) (ei merkitystä vuoden 2008 jälkeisessä lainsäädännössä)
	tyoelake: Saadun työeläkkeen määrä, e/vuosi
	asusuht: Asuinaikasuhteutuksen kerroin (0-1), täysi=1;


%MACRO Kansanelake_SimpleKS(tulos, mvuosi, mkuuk, minf, laitos, puoliso, kryhma, tyoelake, asusuht) / STORE 
DES = 'KANSEL: Kansaneläke kuukausitasolla';

%HaeParam_KansEl&tyyppi (&mvuosi, &mkuuk, &minf);
%KuuNro_KansEl&tyyppi(kuuid, &mvuosi, &mkuuk); 

*Pohjaosa (vakio ennen vuotta 1997);
IF &mvuosi < 1997 THEN DO;
	pohja = &PerPohja;

	*Vuonna 1996 myös pohjaosa oli työeläkevähenteinen, tosin erittäin korkeilla tulorajoilla;
	IF &mvuosi = 1996 THEN DO;
		IF &puoliso = 0 THEN raja = (&kryhma < 1.5) * &PohjRajaY1 + (&kryhma > 1.5) * &PohjRajaY2;
		ELSE raja = (&kryhma < 1.5) * &PohjRajaP1 + (&kryhma > 1.5) * &PohjRajaP2;
	
		IF &tyoelake > raja THEN DO;
			pohja = SUM(pohja, -&KEPros * SUM(&tyoelake, -raja) / 12);
			IF pohja < 0 THEN pohja = 0;
		END;
	END;

	 *Lisäosa/tukiosa ennen vuotta 1997. 
	  Huom! Ennen 9/1991 puoliso-valinta tarkoittaa, että puoliso saa myös kansaneläkettä;
	IF &puoliso = 0 THEN taysitukiosa = (&kryhma < 1.5) * &TukOsY1 + (1.5 < &kryhma < 2.5) * &TukOsY2 + (&kryhma > 2.5) * &TukOsY3 + &TukiLisY;
	ELSE DO;
			IF &mvuosi < ((1991 - &paramalkuke) * 12 + 9) THEN taysitukiosa = &PuolAlenn * ((&kryhma < 1.5) * &TukOsY1 + (1.5 < &kryhma < 2.5) * &TukOsY2 + (&kryhma > 2.5) * &TukOsY3) + 0.5 * &TukiLisPP;
			ELSE taysitukiosa = (&kryhma < 1.5) *&TukOsP1 + (&kryhma > 1.5) * &TukOsP2;
	END;

	*Työeläkevähennys;
	IF &tyoelake <= &KERaja THEN lisosa = taysitukiosa;
	ELSE lisosa = SUM(taysitukiosa, -&KEPros * SUM(&tyoelake, -&KERaja) / 12);
	IF lisosa < 0 THEN lisosa = 0;

	*Laitosasumisen tuottama vähennys;
	IF &laitos NE 0 THEN DO;
		IF &kryhma < 1.5 THEN laitosraja = &LaitosRaja1;
		ELSE laitosraja = &LaitosRaja2;
		IF lisosa > laitosraja * taysitukiosa THEN lisosa = laitosraja * taysitukiosa;
	END;
END;

*Täysi eläke (vuoden 1996 jälkeen). Ei enää lisä- ja pohjaosaa kuten ennen;
ELSE DO;
	IF &puoliso = 0 THEN DO;	
		IF &kryhma < 1.5 THEN taysike = &TaysKEY1 * &asusuht;
		ELSE taysike = &TaysKEY2 * &asusuht;
	END;
	ELSE DO;
		IF &kryhma < 1.5 THEN taysike = &TaysKEP1 * &asusuht;
		ELSE taysike = &TaysKEP2 * &asusuht;
	END;

	IF &tyoelake > &KERaja THEN DO;
		taysike = SUM(taysike, -&KEPros * SUM(&tyoelake, -&KERaja) / 12);
		IF taysike < 0 THEN taysike = 0;
	END;

	IF &laitos NE 0 THEN DO;
		IF &puoliso = 0 THEN DO;
			IF &kryhma < 1.5 THEN raja = &LaitosTaysiY1;
			ELSE raja = &LaitosTaysiY2;
		END;
		ELSE DO;
			IF &kryhma < 1.5 THEN raja = &LaitosTaysiP1;
			ELSE raja = &LaitosTaysiP2;
		END;
		IF taysike > raja THEN taysike = raja;
	END;
END;

*Ennen 9/1991 makro laskee vain täyden eläkkeen;
IF kuuid < ((1991 - &paramalkuke) * 12 + 9) THEN DO;
	IF &tyoelake > 0 THEN &tulos = .;
	ELSE &tulos = SUM(pohja, taysitukiosa);
END;

ELSE IF &mvuosi < 1997 THEN &tulos = SUM(pohja, lisosa) * &asusuht;
ELSE &tulos = taysike;

IF &tulos < &KEMinimi THEN &tulos = 0;

DROP pohja taysike lisosa taysitukiosa raja laitosraja kuuid;
%MEND Kansanelake_SimpleKS;




/*  3. Makro laskee kansaneläkkeen kuukausitasolla vuosikeskiarvona */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, kansaneläke, e/kk (vuosikeskiarvo)
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
    laitos: Asuuko henkilö laitoksessa (0/1)
	puoliso: Onko henkilöllä puoliso (0/1)
	kryhma: Kuntaryhmä (1/2) (ei merkitystä vuoden 2008 jälkeisessä lainsäädännössä)
	tyoelake: Saadun työeläkkeen määrä, e/vuosi
	asusuht: Asuinaikasuhteutuksen kerroin (0-1), täysi=1;

%MACRO Kansanelake_SimpleVS(tulos, mvuosi, minf, laitos, puoliso, kryhma, tyoelake, asusuht) / STORE 
DES = 'KANSEL: Kansaneläke kuukausitasolla vuosikeskiarvona';

vuosielake = 0;

%DO i = 1 %TO 12;
	%Kansanelake_SimpleKS(temp, &mvuosi, &i, &minf, &laitos, &puoliso, &kryhma, &tyoelake, &asusuht);
	vuosielake = SUM(vuosielake,temp);
%END;

&tulos = vuosielake / 12;

DROP vuosielake temp;
%MEND Kansanelake_SimpleVS;

/*  4. Makro laskee kansaneläkkeen ja takuueläkkeen perusteena olevan vuositulon. 
       Tämä toimii vuodesta 1990 lähtien, muttei kaikilta osin erikoislainsäädäntövuonna 1996 */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, kansaneläkkeen ja takuueläkkeen perusteena oleva tulo, e/v 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	laitos: Asuuko henkilö laitoksessa (0/1)
	puoliso: Onko henkilöllä puoliso (0/1)
	kryhma: Kuntaryhmä (1/2) (ei merkitystä vuoden 2008 jälkeisessä lainsäädännössä)
	elake: Saatu kansaneläkkeen määrä, e/kk
	takuuel: Onko kyseessä takuueläke (0/1)
	asusuht: Asuinaikasuhteutus (0-1), täysi=1
	kertoimet: Lykkäys- ja varhennuskertoimet (0-), täysi=1;

%MACRO KanselTuloKS(tulos, mvuosi, mkuuk, minf, laitos, puoliso, kryhma, elake, takuuela, asusuht, kertoimet) / STORE 
DES = 'KANSEL: Kansaneläkkeen ja takuueläkkeen perusteena oleva vuositulo';

%HaeParam_KansEl&tyyppi (&mvuosi, &mkuuk, &minf);
%KuuNro_KansEl&tyyppi (kuuid, &mvuosi, &mkuuk);

IF &takuuela NE 1 THEN DO;
	
	*Ennen vuotta 1997 käytetty lainsäädäntö, jossa sekä pohja- että lisäosa;
	IF &mvuosi < 1997 THEN DO;
		elake2 = &elake / (&asusuht * &kertoimet);
		temp = 0;
		pohja = &PerPohja;
	
		IF &puoliso = 0 THEN DO;	
			IF &kryhma < 1.5 THEN taysitukiosa = &TukOsY1;
			ELSE taysitukiosa = &TukOsY2;
		END;
		ELSE DO;
			IF &kryhma < 1.5 THEN taysitukiosa = &TukOsP1;
			ELSE taysitukiosa = &TukOsP2;
		END;
	
		IF &kryhma < 1.5 THEN laitosraja = &LaitosRaja1;
		ELSE laitosraja = &LaitosRaja2;
	
		IF (&laitos = 0 AND elake2 < SUM(pohja, taysitukiosa)) OR (&laitos NE 0 AND elake2 < SUM(pohja, laitosraja * taysitukiosa)) 
		THEN temp = SUM(SUM(pohja, taysitukiosa, -elake2) / &KEPros, &KERaja / 12);
	END;

	*Vuosina 1997-2010 käytetty lainsäädäntö, jossa vain yksi osa;

	ELSE DO;
		temp = 0;
		elake2 = &elake / &kertoimet;
	
		IF &puoliso = 0 THEN DO;	
			IF &kryhma < 1.5 THEN DO;
				taysike = &TaysKEY1 * &asusuht;
				raja = &LaitosTaysiY1;
			END;
			ELSE DO;
				taysike = &TaysKEY2 * &asusuht;
				raja = &LaitosTaysiY2;
			END;
		END;

		ELSE DO;
			IF &kryhma < 1.5 THEN DO;
				taysike = &TaysKEP1 * &asusuht;
				raja = &LaitosTaysiP1;
			END;
			ELSE DO;
				taysike = &TaysKEP2 * &asusuht;
				raja = &LaitosTaysiP2;
			END;
		END;

		IF (&laitos = 0 AND elake2 < taysike) OR (&laitos NE 0 AND elake2 < raja) THEN temp = 12 * SUM(SUM(taysike, -elake2) / &KEPros, &KERaja / 12);
	END;
END;

*Takuueläkettä koskeva päättely. Tulomaksimi = takuueläke;
ELSE IF kuuid > (2011 - &paramalkuke) * 12 + 2 THEN temp = ((&TakuuEl * &kertoimet) - &elake) * 12;

IF temp < 0 THEN temp = 0;
IF kuuid < (1991 - &paramalkuke) * 12 + 9 THEN &tulos = .;
ELSE IF &elake < &KEMinimi OR (&elake < &PerPohja AND &mvuosi < 1997) THEN &tulos = 99999999; 
ELSE &tulos = temp;

*DROP temp taysike taysitukiosa pohja raja laitosraja kuuid elake2;
%MEND KanselTuloKS;

/*  5. Kansaneläkkeen ja takuueläkkeen perusteena oleva vuositulo vuosikeskiarvona */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, kansaneläkkeen ja takuueläkkeen perusteena oleva tulo, e/vuosi 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	laitos: Asuuko henkilö laitoksessa (0/1)
	puoliso: Onko henkilöllä puoliso (0/1)
	kryhma: Kuntaryhmä (1/2) (ei merkitystä vuoden 2008 jälkeisessä lainsäädännössä)
	elake: Saatu kansaneläkkeen määrä, e/kk
	takuuel: Onko kyseessä takuueläke (0/1)
	asusuht: Asuinaikasuhteutus (0-1), täysi=1
	kertoimet: Lykkäys- ja varhennuskertoimet (0-), täysi=1;

%MACRO KanselTuloVS(tulos, mvuosi, minf, laitos, puoliso, kryhma, elake, takuuela, asusuht, kertoimet) / STORE 
DES = 'KANSEL: Kansaneläkkeen ja takuueläkkeen perusteena oleva vuositulo vuosikeskiarvona';

vuositulo = 0;

%DO i = 1 %TO 12;
	%KanselTuloKS(temp2, &mvuosi, &i, &minf, &laitos, &puoliso, &kryhma, &elake, &takuuela, &asusuht, &kertoimet);
	vuositulo = SUM(vuositulo, temp2);
%END;

&tulos = vuositulo / 12;

DROP vuositulo temp2;
%MEND KanselTuloVS;

/*  6. Makro laskee takuueläkkeen kuukausitasolla (voimassa 3/2011-) */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, takuueläke, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	kokonelake: Muut eläkkeet (työ-, perhe-, kansaneläkkeet ym.) yhteensä, e/kk
	varhkerr: Varhennuskerroin (0-1), täysi=1;

%MACRO TakuuElakeKS(tulos, mvuosi, mkuuk, minf, kokonelake, varhkerr) / STORE 
DES = 'KANSEL: Takuueläke kuukausitasolla';

%HaeParam_KansEl&tyyppi (&mvuosi, &mkuuk, &minf);
%KuuNro_KansEl&tyyppi(kuuid, &mvuosi, &mkuuk);

*Takuueläke on takuueläkerajan ja muiden saatujen eläkkeiden erotus; 
IF &kokonelake < &TakuuEl * &varhkerr THEN temp = &TakuuEl * &varhkerr - &kokonelake;
ELSE temp = 0;

IF temp < &KEMinimi THEN temp = 0;
&tulos = temp;


DROP temp;
%MEND TakuuElakeKS;

/*  7. Makro laskee takuueläkkeen kuukausitasolla vuosikeskiarvona (voimassa 3/2011-) */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, takuueläkke, e/kk (vuosikeskiarvo)
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	kokonelake: Muut eläkkeet (työ-, perhe-, kansaneläkkeet ym.) yhteensä, e/kk
	varhkerr: Varhennuskerroin (0-1), täysi=1;

%MACRO TakuuElakeVS(tulos, mvuosi, minf, kokonelake, varhkerr) / STORE 
DES = 'KANSEL : Takuueläke kuukausitasolla vuosikeskiarvona';

vuositulo = 0;

%DO i = 1 %TO 12;
	%TakuuElakeKS(temp, &mvuosi, &i, &minf, &kokonelake, &varhkerr);
	vuositulo = SUM(vuositulo, temp);
%END;

&tulos = vuositulo / 12;

DROP vuositulo temp;
%MEND TakuuElakeVS;

/*  8. Makro laskee lapseneläkkeen kuukausitasolla */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, lapseneläke, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	tays: Onko täysorpo (=molemmat vanhemmat kuolleet) (0/1) 
	elake: Saadut muut eläketulot, e/vuosi
	koulel: Onko koululaiseläke (0/1);

%MACRO LapsenElakeaKS(tulos, mvuosi, mkuuk, minf, tays, elake, koulel) / STORE 
DES = 'KANSEL: Lapseneläke kuukausitasolla';

%HaeParam_KansEl&tyyppi (&mvuosi, &mkuuk, &minf);

*Muut eläketulot pienentävät lapseneläkkeen täydennysmäärää tietyn rajan jälkeen;

IF &koulel = 0 THEN DO;
	temp = &LapsElTayd;
	IF &elake > &KERaja THEN temp = SUM(temp, -&KEPros * SUM(&elake, -&KERaja) / 12);
	IF temp < 0 THEN temp = 0;
END;
ELSE temp = 0;

temp = SUM(&LapsElPerus, temp);

*Täysorvoille tuki on kaksinkertainen, koska tuki tulee kummastakin vanhemmasta;
IF &tays NE 0 THEN temp = 2 * temp;

IF &mvuosi < 1990 THEN &tulos = .;
ELSE IF temp < &LapsElMinimi THEN &tulos = 0;
ELSE &tulos = temp;

DROP temp;
%MEND LapsenElakeaKS;

/*  9. Makro laskee lapseneläkkeen kuukausitasolla vuosikeskiarvona */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, lapseneläke, e/kk (vuosikeskiarvo)
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	tays: Onko täysorpo (=molemmat vanhemmat kuolleet) (0/1) 
	elake: Saadut muut eläketulot, e/vuosi
	koulel: Onko koululaiseläke (0/1); 

%MACRO LapsenElakeaVS(tulos, mvuosi, minf, tays, elake, koulel) / STORE 
DES = 'KANSEL: Lapseneläke kuukausitasolla vuosikeskiarvona';

vuosielake = 0;

%DO i = 1 %TO 12;
	%LapsenElakeaKS(temp2, &mvuosi, &i, &minf, &tays, &elake, &koulel);
	vuosielake = SUM(vuosielake, temp2);
%END;

&tulos = vuosielake / 12;

DROP vuosielake temp2;
%MEND LapsenElakeaVS;

/*  10. Makro laskee leskeneläkkeen kuukausitasolla */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, leskeneläke, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	alku: Onko kyseessä lesken alkueläke (0/1)
	puoliso: Onko henkilöllä uusi puoliso (0/1)
	kryhma: Kuntaryhmä (1/2) (ei merkitystä vuonna 2008 ja sen jälkeisessä lainsäädännössä)
	lapsia: Onko henkilöllä lapsia (0/1)
	tyotulo: Työtulot (e/vuosi)
	potulo: Pääomatulot (e/vuosi)
	eltulo: Muut eläketulot (e/vuosi)
	varall: Veronalainen varallisuus, e (ei merkitystä lainsäädännössä vuoden 2007 jälkeen);

%MACRO LeskenElakeaKS(tulos, mvuosi, mkuuk, minf, alku, puoliso, kryhma, lapsia, tyotulo, potulo, eltulo, varall) / STORE 
DES = 'KANSEL: Leskeneläke kuukausitasolla';

%HaeParam_KansEl&tyyppi (&mvuosi, &mkuuk, &minf);
%KuuNro_KansEl&tyyppi(kuuid, &mvuosi, &mkuuk); 

*Varallisuudesta otettiin huomioon vain pieni osa tietyn rajan jälkeen;
IF &varall > &PerhElOmRaja THEN potulo = SUM(&potulo, &PerhElOmPros * SUM(&varall, -&PerhElOmRaja));
ELSE potulo = &potulo;

*Tulojen yhteissumma. Työtulosta otetaan huomioon vain tietty osuus;
tulo = SUM(&tyotulo * &LeskTyoTuloOsuus, potulo, &eltulo);

*Leskeneläkkeen lisäosan parametrin määritys. Ennen vuotta 1991 puolisolla ei ollut vaikutusta;
IF &kryhma < 2 THEN DO;
	IF &puoliso = 0 OR kuuid < ((1991 - &paramalkuke) * 12 + 9) THEN taystayd = &LeskTaydY1;
	ELSE taystayd = &LeskTaydP1;
END;
ELSE DO;
	IF &puoliso = 0 OR kuuid < ((1991 - &paramalkuke) * 12 + 9) THEN taystayd = &LeskTaydY2;
	ELSE taystayd = &LeskTaydP2;
END;

*Tulojen vähentävä vaikutus lisäosaan tietyn vuositulorajan jälkeen;
IF tulo > &KERaja THEN DO;
	vahtayd = SUM(taystayd, -&KEPros * SUM(tulo, -&KERaja) / 12);
	IF vahtayd < 0 THEN vahtayd = 0;
END;
ELSE vahtayd = taystayd;

*Jos on kyseessä ns. alkueläke (jota maksetaan puolen vuoden jälkeen kuolemasta), tulojen vaikutus eläkkeeseen on rajattu. 
Ennen vuotta 2008 alkueläke oli perusmäärä + vähintään tietty osa täydennysmäärästä. Vuodesta 2008 lähtien alkueläke on kiinteämääräinen etuus;
IF &alku NE 0 THEN DO;
	IF &mvuosi < 2008 THEN DO;

		IF &kryhma < 1.5 THEN kerroin = &LeskAlkuMinimi1;
		ELSE kerroin = &LeskAlkuMinimi2;

		IF vahtayd < kerroin * taystayd THEN vahtayd = kerroin * taystayd;
		temp = &LeskPerus + vahtayd;
	END;

	ELSE temp = &LeskAlku;
END;

*Ei alkueläke. Jos on lapsia, siihen lisätään perusosa. Muuten se on pelkkä tulovähenteinen lisäosa;
ELSE DO;
	IF &lapsia > 0 THEN temp = &LeskPerus + vahtayd;
	ELSE temp = vahtayd;
END;


*Koodi ei sisällä vuotta 1983 aikaisempaa lainsäädäntöä;
IF &mvuosi < 1983 THEN &tulos = .;

ELSE IF temp < &LeskMinimi THEN &tulos = 0;
ELSE &tulos = temp;

DROP temp kuuid vahtayd taystayd kerroin potulo tulo;
%MEND LeskenElakeaKS;

/*  11. Makro laskee leskeneläkkeen kuukausitasolla vuosikeskiarvona */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, leskeneläke, e/kk (vuosikeskiarvo)
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	alku: Onko kyseessä lesken alkueläke (0/1)
	puoliso: Onko henkilöllä uusi puoliso (0/1)
	kryhma: Kuntaryhmä (1/2) (ei merkitystä vuonna 2008 ja sen jälkeisessä lainsäädännössä)
	lapsia: Onko henkilöllä lapsia (0/1)
	tyotulo: Työtulot (e/vuosi)
	potulo: Pääomatulot (e/vuosi)
	eltulo: Muut eläketulot (e/vuosi)
	varall: Veronalainen varallisuus, e (ei merkitystä lainsäädännössä vuoden 2007 jälkeen);

%MACRO LeskenElakeaVS(tulos, mvuosi, minf, alku, puoliso, kryhma, lapsia, tyotulo, potulo, eltulo, varall) / STORE
DES = 'KANSEL: Leskeneläke kuukausitasolla vuosikeskiarvona';

vuosielake = 0;

%DO i = 1 %TO 12;
	%LeskenElakeaKS(temp2, &mvuosi, &i, &minf, &alku, &puoliso, &kryhma, &lapsia, &tyotulo, &potulo, &eltulo, &varall);
	vuosielake = SUM(vuosielake, temp2);
%END;

&tulos = vuosielake / 12;
DROP vuosielake temp2;
%MEND LeskenElakeaVS;

/*  12. Makro laskee perhe-eläkkeen perusteena olevan vuositulon */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Perhe-eläkkeen perusteena oleva tulo, e/vuosi 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	laps: Onko kyseessä lapseneläke (0/1)
	tays: Onko kyseessä täysorpo (0/1)
	alku: Onko kyseessä lesken alkueläke (0/1)
	puoliso: Onko henkilöllä uusi puoliso (0/1)
	kryhma: Kuntaryhmä (1/2) (ei merkitystä vuonna 2008 ja sen jälkeisessä lainsäädännössä)
	lapsia: Onko leskellä lapsia (0/1)
	taydmaara: Saadun eläkkeen (tuloriippuvaisen) täydennysosan suuruus, e/kk;

%MACRO PerhElTuloKS(tulos, mvuosi, mkuuk, minf, laps, tays, alku, puoliso, kryhma, lapsia, taydmaara) / STORE
DES = 'KANSEL: Perhe-eläkkeen perusteena olevan vuositulo';

%HaeParam_KansEl&tyyppi (&mvuosi, &mkuuk, &minf);

taydmaara = &taydmaara;

*Lasketaan lapseneläkkeiden täysi täydennysmäärä;
IF &laps NE 0 THEN DO;
	pieninel = &LapsElMinimi;
	perus2 = &LapsElPerus;
	%LapsenelakeAKS(taysitayd, &mvuosi, &mkuuk, &minf, &tays, 0, 0);

	*Täysorvoilla ollessa kaksinkertainen etuus, jaetaan ne kahdella;
	IF &tays NE 0 THEN	DO;
		taysitayd = SUM(taysitayd / 2, -perus2);
		taydmaara = &taydmaara / 2;
	END;

	ELSE taysitayd = SUM(taysitayd, -perus2);
END;

*Lasketaan leskeneläkkeiden täysi täydennysmäärä;
ELSE DO;
	pieninel = &LeskMinimi;
	IF &alku = 0 THEN DO;
		IF &lapsia > 0 THEN perus2 = &LeskPerus;
		ELSE perus2 = 0;
	END;

	ELSE DO;
		%LeskenElakeAKS(perus2, &mvuosi, &mkuuk, &minf, 1, &puoliso, &kryhma, 0, 0, 0, 999999, 0);
	END;

	%LeskenElakeAKS(taysitayd, &mvuosi, &mkuuk, &minf, (&alku NE 0), &puoliso, &kryhma, 0, 0, 0, 0, 0);
	taysitayd = taysitayd - perus2;
END;

*Lasketaan täydennysmäärää vähentäneen tulon suuruus;
IF taydmaara <= 0 OR SUM(taydmaara, perus2) < pieninel THEN temp2 = 99999999;
ELSE IF taydmaara >= 0 AND taydmaara < taysitayd AND &KEPros > 0 THEN temp2 = SUM( SUM(taysitayd, -taydmaara) / &KEPros, &KERaja / 12);
ELSE temp2 = 0;

&tulos = temp2;
DROP temp2 taysitayd pieninel taydmaara perus2;
%MEND PerhElTuloKS;

/*  13. Makro laskee perhe-eläkkeen perusteena olevan vuositulon vuosikeskiarvona */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, perhe-eläkkeen perusteena oleva tulo, e/vuosi (vuosikeskiarvo)
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	laps: Onko kyseessä lapseneläke (0/1)
	tays: Onko kyseessä täysorpo (0/1)
	alku: Onko kyseessä lesken alkueläke (0/1)
	puoliso: Onko henkilöllä uusi puoliso (0/1)
	kryhma: Kuntaryhmä (1/2) (ei merkitystä vuonna 2008 ja sen jälkeisessä lainsäädännössä)
	lapsia: Onko leskellä lapsia (0/1)
	taydmaara: Saadun eläkkeen (tuloriippuvaisen) täydennysosan suuruus, e/kk;

%MACRO PerhElTuloVS(tulos, mvuosi, minf, laps, taysi, alku, puoliso, kryhma, lapsia, taydmaara) / STORE 
DES = 'KANSEL: Perhe-eläkkeen perusteena oleva vuositulo vuosikeskiarvona';

tulo2 = 0;

%DO i = 1 %TO 12;
	%PerhElTuloKS(temp3, &mvuosi, &i, &minf, &laps, &taysi, &alku, &puoliso, &kryhma, &lapsia, &taydmaara);
	tulo2 = SUM(tulo2, temp3);
%END;

&tulos = tulo2 / 12;
DROP tulo2 temp3;
%MEND PerhElTuloVS;

/*  14. Makro laskee maahanmuuttajan erityistuen kuukausitasolla (voimassa 10/2003 - 3/2011) */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, maahanmuuttajan erityistuki, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	laitos: Asuuko henkilö laitoksessa (0/1)
	puoliso: Onko henkilöllä puoliso (0/1)
	kryhma: Kuntaryhmä (1/2) (ei merkitystä vuonna 2008 ja sen jälkeisessä lainsäädännössä)
	lapsia: Onko henkilöllä lapsia (0/1)
	omatulo: Henkilön muut tulot, e/kk
	puoltulo: Henkilön puolison muut tulot, e/kk;

%MACRO MaMuErTukiKS(tulos, mvuosi, mkuuk, minf, laitos, puoliso, kryhma, omatulo, puoltulo) / STORE 
DES = 'KANSEL: Maahanmuuttajan erityistuki kuukausitasolla';

%HaeParam_KansEl&tyyppi (&mvuosi, &mkuuk, &minf);
%KuuNro_KansEl&tyyppi(kuuid2, &mvuosi, &mkuuk); 

*Maahanmuuttajan erityistuki oli yhtä suuri kuin kansaneläke, mutta tulot vähentävät sitä täysimääräisesti;
%Kansanelake_SimpleKS(temp2, &mvuosi, &mkuuk, &minf, &laitos, &puoliso, &kryhma, 0, 1);

IF &omatulo > 0 OR &puoltulo > 0 THEN temp2 = temp2 - &omatulo - (&puoltulo > temp2) * (&puoltulo - temp2);

IF kuuid2 < ((2003 - &paramalkuke) * 12 + 10) OR kuuid2 >= ((2011 - &paramalkuke) * 12 + 3) THEN &tulos = .;
ELSE IF temp2 < &KEMinimi THEN &tulos = 0;
ELSE &tulos = temp2;
DROP temp2 kuuid2;
%MEND MaMuErTukiKS;

/*  15. Makro laskee maahanmuuttajan erityistuen kuukausitasolla vuosikeskiarvona (voimassa 10/2003 - 3/2011) */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, maahanmuuttajan erityistuki, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	laitos: Asuuko henkilö laitoksessa (0/1)
	puoliso: Onko henkilöllä puoliso (0/1)
	kryhma: Kuntaryhmä (1/2) (ei merkitystä vuonna 2008 ja sen jälkeisessä lainsäädännössä)
	lapsia: Onko henkilöllä lapsia (0/1)
	omatulo: Henkilön muut tulot, e/kk
	puoltulo: Henkilön puolison muut tulot, e/kk;

%MACRO MaMuErTukiVS(tulos, mvuosi, minf, laitos, puoliso, kryhma, omatulo, puoltulo) / STORE 
DES = 'KANSEL: Maahanmuuttajan erityistuki kuukausitasolla vuosikeskiarvona';

vuositulo = 0;

%DO i = 1 %TO 12;
	%MaMuErTukiKS(temp3, &mvuosi, &i, &minf, &laitos, &puoliso, &kryhma, &omatulo, &puoltulo);
	vuositulo = SUM(vuositulo, temp3);
%END;

&tulos = vuositulo / 12;
DROP vuositulo temp3;

%MEND MaMuErTukiVS;

/*  16. Makro laskee sotilasavustuksen kuukausitasolla */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, sotilasavustus, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	kryhma: Kuntaryhmä (1/2) (ei merkitystä vuonna 2008 ja sen jälkeisessä lainsäädännössä)
	jasenia: Avustettavien perheenjäsenien lkm
	asummenot: Asumismenot, e/kk
	tulot: Henkilön muut tulot, e/kk;

%MACRO SotilasAvKS(tulos, mvuosi, mkuuk, minf, kryhma, jasenia, asummenot, tulot) / STORE 
DES = 'KANSEL: Sotilasavustus kuukausitasolla';

%HaeParam_KansEl&tyyppi (&mvuosi, &mkuuk, &minf);

%Kansanelake_SimpleKS(taysi, &mvuosi, &mkuuk, &minf, 0, 0, &kryhma, 0, 1);

IF &jasenia < 1 THEN temp = 0;
ELSE IF &jasenia < 2 THEN temp = &SotAvPros1 * taysi;
ELSE temp = ((&jasenia - 2) * &SotAvPros3 + &SotAvPros1 + &SotAvPros2) * taysi;

temp = SUM(temp, &asummenot, -&tulot);

IF &mvuosi < 1994 THEN temp = .;
ELSE IF temp < &SotAvMinimi THEN temp = 0;

&tulos = temp;
DROP temp taysi;
%MEND SotilasAvKS;

/*  17. Makro laskee sotilasavustuksen kuukausitasolla vuosikeskiarvona */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, sotilasavustus, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	kryhma: Kuntaryhmä (1/2) (ei merkitystä vuonna 2008 ja sen jälkeisessä lainsäädännössä)
	jasenia: Avustettavien perheenjäsenien lkm
	asummenot: Asumismenot, e/kk
	tulot: Henkilön muut tulot, e/kk;

%MACRO SotilasAvVS(tulos, mvuosi, minf, kryhma, jasenia, asummenot, tulot) / STORE 
DES = 'KANSEL: Sotilasavustus kuukausitasolla vuosikeskiarvona';

sotav = 0;

%DO i = 1 %TO 12;
	%SotilasAvKS(temp, &mvuosi, &i, &minf, &kryhma, &jasenia, &asummenot, &tulot);
	sotav = SUM(sotav, temp);
%END;

&tulos = sotav / 12;
DROP temp sotav;
%MEND SotilasAvVS;

/*  18. Makro laskee vammaistuen ja ruokavaliokorvauksen kuukausitasolla */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, vammaistuki, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	vammtuki: Onko kyseessä normaali vammaistuki (0/1)
	lapshoituki: Onko kyseessä alle 16-vuotiaan vammasituki (0/1)
	keliakia: Onko kyseessä ruokavaliokorvaus (0/1)
	aste: Korvauksen aste (1/2/3);

%MACRO VammTukiKS(tulos, mvuosi, mkuuk, minf, vammtuki, lapshoituki, keliakia, aste) / STORE 
DES = 'KANSEL: Vammaistuki ja ruokavaliokorvaus kuukausitasolla';

%HaeParam_KansEl&tyyppi (&mvuosi, &mkuuk, &minf);

temp = 0;

*Normaali vammaistuki;
IF &vammtuki NE 0 THEN DO;
	IF &aste = 1 THEN temp = &VammNorm;
	ELSE IF &aste in (2,4) THEN temp = &VammKorot;
	ELSE IF &aste = 3 THEN temp = &VammErit;
END;

*Alle 16-vuotiaan vammasituki;
IF &lapshoituki NE 0 THEN DO;
	IF &aste = 1 THEN temp = temp + &LapsHoitTukNorm;
	ELSE IF &aste = 2 THEN temp = temp + &LapsHoitTukKorot;
	ELSE IF &aste = 3 THEN temp = temp + &LapsHoitTukErit;
END;

*Ruokavaliokorvaus;
IF &keliakia NE 0 THEN temp = temp + &Keliak;

&tulos = temp;
DROP temp;
%MEND VammTukiKS;

/*  19. Makro laskee vammaistuen ja ruokavaliokorvauksen kuukausitasolla vuosikeskiarvona */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, vammaistuki, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	vammtuki: Onko kyseessä normaali vammaistuki (0/1)
	lapshoituki: Onko kyseessä alle 16-vuotiaan vammasituki (0/1)
	keliakia: Onko kyseessä ruokavaliokorvaus (0/1)
	aste: Korvauksen aste (1/2/3);

%MACRO VammTukiVS(tulos, mvuosi, minf, vammtuki, lapshoituki, keliakia, aste) / STORE 
DES = 'KANSEL: Vammaistuki ja ruokavaliokorvaus kuukausitasolla vuosikeskiarvona';

vamtuki = 0;

%DO i = 1 %TO 12;
	%VammTukiKS(temp, &mvuosi, &i, &minf, &vammtuki, &lapshoituki, &keliakia, &aste);
	vamtuki = SUM(vamtuki, temp);
%END;

&tulos = vamtuki / 12;
DROP temp vamtuki;
%MEND VammTukiVS;

/*  20. Makro laskee kansaneläkkeeseen tulevat lisät kuukausitasolla */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, kansaneläkkeeseen tulevat lisät, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	alkava: Onko kyseessä alkava eläke (0/1)
	apulisa: Onko suojattua apulisää (0/1) (ei makseta enää alkaviin eläkkeisiin vuoden 1988 jälkeen) tai veteraanilisä, jos myös hoitotuki2 tai hoitotuki3 valittu
	hoitolisa: Onko suojattua hoitolisää (0/1) (ei makseta enää alkaviin eläkkeisiin vuoden 1988 jälkeen)
	hoitotuki1: Onko normaalia hoitotukea (0/1)
	hoitotuki2: Onko korotettua hoitotukea (0/1)
	hoitotuki3: Onko erityishoitotukea (0/1)
	ril: Onko rintamalisää (0/1)
	puollis: Onko puolisolisää (0/1) (ei makseta enää alkaviin eläkkeisiin vuoden 1996 jälkeen)
	kryhma: Kuntaryhmä (1/2) (ei merkitystä vuoden 2008 jälkeisessä lainsäädännössä)
	lapsia: Lapsien lkm;

%MACRO KanselLisatKS(tulos, mvuosi, mkuuk, minf, alkava, apulisa, hoitolisa, hoitotuki1, hoitotuki2, hoitotuki3, ril, puollis, kryhma, lapsia) / STORE
DES = 'KANSEL: Kansaneläkkeeseen liittyvät lisät kuukausitasolla';

%HaeParam_KansEl&tyyppi (&mvuosi, &mkuuk, &minf);

temp = 0;

IF &hoitolisa NE 0 THEN temp = &HoitoLis;
ELSE IF &hoitotuki1 NE 0 THEN temp = &HoitTukiNorm;
ELSE IF &hoitotuki2 NE 0 THEN temp = &HoitTukiKor;
ELSE IF &hoitotuki3 NE 0 THEN temp = &HoitTukiErit;

IF &apulisa NE 0 THEN DO;
	IF &hoitotuki2 NE 0 OR &hoitotuki3 NE 0 THEN temp = SUM(temp, &VeterLisa);
	ELSE temp = &ApuLis;
END;

IF &ril NE 0 THEN temp = SUM(temp, &RiLi);
IF &puollis NE 0 AND (&alkava = 0 OR &mvuosi < 1996) THEN temp = SUM(temp, &PuolisoLis);
IF (&mvuosi < 1996 OR &mvuosi > 2001) OR &alkava = 0 THEN temp = SUM(temp, &lapsia * &KELaps);

&tulos = temp;
DROP temp;
%MEND KanselLisatKS;

/*  21. Makro laskee kansaneläkkeeseen tulevat lisät kuukausitasolla vuosikeskiarvona */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, kansaneläkkeeseen tulevat lisät, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	alkava: Onko kyseessä alkava eläke (0/1)
	apulisa: Onko suojattua apulisää (0/1) (ei makseta enää alkaviin eläkkeisiin vuoden 1988 jälkeen)
	hoitolisa: Onko suojattua hoitolisää (0/1) (ei makseta enää alkaviin eläkkeisiin vuoden 1988 jälkeen)
	hoitotuki1: Onko normaalia hoitotukea (0/1)
	hoitotuki2: Onko korotettua hoitotukea (0/1)
	hoitotuki3: Onko erityishoitotukea (0/1)
	ril: Onko rintamalisää (0/1)
	puollis: Onko puolisolisää (0/1) (Ei makseta enää alkaviin eläkkeisiin vuoden 1996 jälkeen)
	kryhma: Kuntaryhmä (1/2) (ei merkitystä vuoden 2008 jälkeisessä lainsäädännössä)
	lapsia: Lapsien lkm;

%MACRO KanselLisatVS(tulos, mvuosi, minf, alkava, apulisa, hoitolisa, hoitotuki1, hoitotuki2, hoitotuki3, ril, puollis, kryhma, lapsia) / STORE
DES = 'KANSEL: Kansaneläkkeeseen liittyvät lisät kuukausitasolla vuosikeskiarvona';

lisat2 = 0;

%DO i = 1 %TO 12;
	%KanselLisatKS(temp2, &mvuosi, &i, &minf, &alkava, &apulisa, &hoitolisa, &hoitotuki1, &hoitotuki2, &hoitotuki3, &ril, &puollis, &kryhma, &lapsia);
	lisat2 = SUM(lisat2, temp2);
%END;

&tulos = lisat2 / 12;
DROP lisat2 temp2;
%MEND KanselLisatVS;

/*  22. Makro laskee ylimääräisen rintamalisän kuukausitasolla */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, ylimääräinen rintamalisä, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	lisaosa: Saadun lisäosan suuruus, e/kk (merkitystä vain vuotta 1997 aikaisemmassa lainsäädännössä)
	kanselake: Saadun kansaneläkkeen määrä, e/kk
	tyoelake: Saadun työeläkkeen määrä, e/kk (merkitystä vain 4/2000 jälkeen);

%MACRO YlimRintLisaKS(tulos, mvuosi, mkuuk, minf, lisaosa, kanselake, tyoelake) / STORE 
DES = 'KANSEL: Ylimääräinen rintamalisä kuukausitasolla';

%HaeParam_KansEl&tyyppi (&mvuosi, &mkuuk, &minf);
%KuuNro_KansEl&tyyppi(kuuid, &mvuosi, &mkuuk);

*Ennen vuotta 1997 ylim. rintamalisä oli tietty osuus kansaneläkkeen lisäosasta;
IF &mvuosi < 1997 THEN DO;
	temp = &YliRiliPros * &lisaosa;
	IF temp < &YliRiliMinimi THEN temp = 0;
END;

*Vuoden 1997 jälkeen ylim. rintamalisä oli tietty prosentti kansaneläkkeen tietyn rajan ylittävästä osasta, 
 mutta kuitenkin minimin verran;
ELSE DO;

	*Vuoden 2000 jälkeen työeläkkeet vaikuttavat rintamalisäprosenttiin alentaen askel askeleelta;
	IF kuuid >= ((2000 - &paramalkuke) * 12 + 4) AND &tyoelake > 0 THEN DO;

			IF &tyoelake * 12 <= &KERaja THEN prosvah = FLOOR(&tyoelake * 12 / SUM(&YliRiliAskel));
			ELSE prosvah = SUM(FLOOR(&KERaja / SUM(&YliRiliAskel)), FLOOR(SUM(&tyoelake * 12, -&KERaja) / SUM(&YliRiliAskel2)));

			ylirilipros = &YliRiliPros - prosvah / 100;
			IF ylirilipros < &YliRiliPros2 THEN ylirilipros = &YliRiliPros2;
	END;
	ELSE ylirilipros = &YliRiliPros; 
	
	temp = 0;
	IF 12 * &kanselake > &YliRiliRaja THEN temp = ylirilipros * SUM(&kanselake, -&YliRiliRaja / 12);
	IF temp < &YliRiliMinimi AND &kanselake > 0 THEN temp = &YliRiliMinimi;
END;

&tulos = temp;
DROP temp ylirilipros kuuid prosvah;
%MEND YlimRintLisaKS;

/*  23. Makro laskee ylimääräisen rintamalisän kuukausitasolla vuosikeskiarvona */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, ylimääräinen rintamalisä, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	lisaosa: Saadun lisäosan suuruus, e/kk (merkitystä vain vuotta 1997 aikaisemmassa lainsäädännössä)
	kanselake: Saadun kansaneläkkeen määrä, e/kk
	tyoelake: Saadun työeläkkeen määrä, e/kk (merkitystä vain 4/2000 jälkeen);

%MACRO YlimRintLisaVS(tulos, mvuosi, minf, lisaosa, kanselake, tyoelake) / STORE 
DES = 'KANSEL: Ylimääräinen rintamalisä kuukausitasolla vuosikeskiarvona';

rintlis = 0;

%DO i = 1 %TO 12;
	%YlimRintLisaKS(temp, &mvuosi, &i, &minf, &lisaosa, &kanselake, &tyoelake); 
	rintlis = SUM(rintlis, temp);
%END;

temp = rintlis / 12;
&tulos = temp;
DROP temp rintlis;
%MEND YlimRintLisaVs;
