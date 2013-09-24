/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyödyntää Tilastokeskuksen yleisten
* käyttöehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto päähakemistossa.
******************************************************************************/

/***********************************************************
* Kuvaus: Työttömyysturvan lainsäädäntöä makroina          *
* Tekijä: Jussi Tervola / KELA		                	   *
* Luotu: 8.9.2011				       					   *
* Viimeksi päivitetty: 31.5.2011		     		       *
* Päivittäjä: Jussi Tervola / KELA	                       *							
************************************************************/ 

/* 1. SISÄLLYS */

/* Tiedosto sisältää seuraavat makrot */

/*
2. AnsioSidKS = Ansiosidonnainen päiväraha kuukausitasolla
3. AnsioSidVS = Ansiosidonnainen päiväraha kuukausitasolla vuosikeskiarvona
4. TyomTukiKS = Työmarkkinatuki kuukausitasolla
5. TyomTukiVS = Työmarkkinatuki kuukausitasolla vuosikeskiarvona
6. PerusPRahaKS =  Peruspäiväraha kuukausitasolla
7. PerusPRahaVS = Peruspäiväraha kuukausitasolla vuosikeskiarvona
8. SoviteltuKS = Soviteltu työttömyyspäiväraha kuukausitasolla
9. SoviteltuVS = Soviteltu työttömyyspäiväraha kuukausitasolla vuosikeskiarvona   
10. AnsioSidPalkkaS = Ansiosidonnaisen päivärahan perusteena oleva palkka kuukausitasolla
11. YPitoKorvS = Ylläpitokorvaukset kuukausitasolla
12. YPitoKorvVS = Ylläpitokorvaukset kuukausitasolla vuosikeskiarvona    
13. VuorVapKorvKS = Vuorotteluvapaakorvaukset kuukausitasolla
14. VuorVapKorvVS = Vuorotteluvapaakorvaukset kuukausitasolla vuosikeskiarvona     
15. SovPalkkaS = Sovitellun päivärahan perusteena oleva palkka kuukausitasolla
16. TarvHarkTuloS = Työmarkkinatuen tarveharkinnan perusteena oleva tulo kuukausitasolla
17. OsittTmTTuloS = Osittaisen työmarkkinatuen perusteena oleva vanhempien tulo kuukausitasolla
*/ 


/*  2. Makro laskee ansiosidonnaisen työttömyyspäivärahan kuukausitasolla */

*Makron parametrit:
	tulos: Makron tulosmuuttuja, ansiosidonnainen työttömyyspäiväraha, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
  	lapsia: Lapsien lkm perheessä 
	oikeuskor: Onko oikeus korotettuun päivärahaan
	muutturva: Onko oikeus muutosturvaan
	lisapaiv: Onko oikeus ansiopäivärahojen korotettuihin lisäpäiviin
	kuukpalkka: Työttömyyttä edeltävä kuukausipalkka
	vahsosetuus: Päivärahasta vähennettävä muu sosiaalietuus, e/kk;
	
%MACRO AnsioSidKS(tulos, mvuosi, mkuuk, minf, lapsia, oikeuskor, muutturva, lisapaiv, kuukpalkka, vahsosetuus)/STORE 
DES = 'TTURVA: Ansiosidonnainen päiväraha kuukausitasolla';

%HaeParam_TTurva&tyyppi (&mvuosi, &mkuuk, &minf);
%KuuNro_TTurva&tyyppi (kuuid, &mvuosi, &mkuuk);

*Lapsikorotukset;
IF &lapsia <= 0 THEN lapsikor = 0;
ELSE IF &lapsia < 2 THEN lapsikor = &TTLaps1;
ELSE IF &lapsia < 3 THEN lapsikor = &TTLaps2;
ELSE lapsikor = &TTLaps3;

*Kuukausipalkkaan tehtävä vähennys;
tyotulo = (1 - &VahPros) * (&kuukpalkka / &TTPAIVIA);

*Korotetun päivärahan ja työllistymisohjelmalisän prosentit. Tässä on varmistettu että korotuksia ei tule kun ne eivät ole olleet voimassa;
IF &oikeuskor NE 0 AND &mvuosi >= 2003 THEN DO;
	pros1 = &ProsKor1;
	pros2 = &ProsKor2;
	raja = tyotulo;
END;
ELSE IF &muutturva NE 0 AND kuuid >= 12 * (2005 - &paramalkutt) + 7 THEN DO;
	pros1 = &MuutTurvaPros1;
	pros2 = &MuutTurvaPros2;
	raja = tyotulo;
END;
ELSE IF &lisapaiv NE 0 AND 2003 <= &mvuosi <= 2009 THEN DO; 
	pros1 = &TTPros1;
	pros2 = &ProsKor2;
	raja = &ProsYlaRaja * tyotulo;
END;
ELSE DO;
	pros1 = &TTPros1;
	pros2 = &TTPros2;
	raja = &ProsYlaRaja * tyotulo;
END;

*Ansiosidonnaisen päivärahan varsinainen laskukaava;
IF (1 - &VahPros) * &kuukpalkka < &TTTaite * &TTPerus THEN temp = SUM(&TTPerus, pros1 * SUM(tyotulo, -&TTPerus), lapsikor);
ELSE temp = SUM(&TTPerus, pros1 * SUM(&TTTaite * &TTPerus / &TTPAIVIA, -&TTPerus), pros2 * SUM(tyotulo, -&TTTaite * &TTPerus / &TTPAIVIA), lapsikor);

*Maksimipäiväraha;
IF temp > raja THEN temp = raja;

*Minimipäiväraha;
IF &mvuosi >= 2012 AND (&muutturva NE 0 OR &oikeuskor NE 0) THEN temp = MAX(temp, SUM(&TTPerus, lapsikor, &KorotusOsa));
ELSE temp = MAX(temp, SUM(&TTPerus, lapsikor));

temp = SUM(temp * &TTPAIVIA, -&vahsosetuus);
IF temp < 0 THEN temp = 0;

&tulos = temp;
DROP temp kuuid tyotulo raja lapsikor pros1 pros2;
%MEND AnsioSidKS;


/*  3. Makro laskee ansiosidonnaisen työttömyyspäivärahan kuukausitasolla vuosikeskiarvona */

*Makron parametrit:
	tulos: Makron tulosmuuttuja, ansiosidonnainen työttömyyspäiväraha, e/kk (vuosikeskiarvo)
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
  	lapsia: Lapsien lkm perheessä 
	oikeuskor: Onko oikeus korotettuun päivärahaan
	lisapaiv: Onko oikeus ansiopäivärahojen korotettuihin lisäpäiviin
	muutturva: Onko oikeus työllistymisohjelmalisään
	kuukpalkka: Työttömyyttä edeltävä kuukausipalkka
	vahsosetuus: Päivärahasta vähennettävä muu sosiaalietuus, e/kk;

%MACRO AnsioSidVS(tulos, mvuosi, minf, lapsia, oikeuskor, muutturva, lisapaiv, kuukpalkka, vahsosetuus)/STORE 
DES = 'TTURVA: Ansiosidonnainen päiväraha kuukausitasolla vuosikeskiarvona';

vuosipraha = 0;

%DO i = 1 %TO 12;
	%AnsioSidKS(temp, &mvuosi, &i, &minf, &lapsia, &oikeuskor, &muutturva, &lisapaiv, &kuukpalkka, &vahsosetuus);
	vuosipraha = SUM(vuosipraha, temp);
%END;

&tulos = vuosipraha / 12;
DROP temp vuosipraha;
%MEND AnsioSidVS;


/*  4. Makro laskee työmarkkinatuen kuukausitasolla */

*Makron parametrit:  
	tulos: Makron tulosmuuttuja, työmarkkinatuki, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	tarvhark: Onko kyseessä tarveharkittu työmarkkinatuki (0/1)
	ositt: Onko kyseessä osittainen työmarkkinatuki (0/1)
	puoliso: Onko saajalla puolisoa (0/1)
	lapsia: Lapsien lkm perheessä 
	huoll: Muiden huollettavien lkm perheessä, jos kyseessä osittainen tmtuki
	omatulo: Oman muun tulon määrä, e/kk
	puoltulo: Puolison tulon määrä, e/kk
	vanhtulot: Vanhempien kuukausitulot, jos kyseessä osittainen tmtuki, e/kk
	oikeuskor: Onko oikeus korotusosaan (0/1)
	vahsosetuus: Päivärahasta vähennettävä muu sosiaalietuus, e/kk;
	

%MACRO TyomTukiKS(tulos, mvuosi, mkuuk, minf, tarvhark, ositt, puoliso, lapsia, huoll, omatulo, puoltulo, vanhtulot, oikeuskor, vahsosetuus)/STORE
DES = 'TTURVA: Työmarkkinatuki kuukausitasolla';

%HaeParam_TTurva&tyyppi (&mvuosi, &mkuuk, &minf);

*Lapsikorotukset;
IF &lapsia <= 0 THEN lapsikor = 0;
ELSE IF &lapsia < 2 THEN lapsikor = &TyomLapsPros * &TTLaps1;
ELSE IF &lapsia < 3 THEN lapsikor = &TyomLapsPros * &TTLaps2;
ELSE lapsikor = &TyomLapsPros * &TTLaps3;

*Täysmääräinen työmarkkinatuki;
temp = &TTPAIVIA * SUM(&TTPerus, lapsikor);
IF &oikeuskor NE 0 AND &mvuosi >= 2010 THEN temp = SUM(temp, &TTPAIVIA * &KorotusOsa);

*Tarveharkittu tuki;

IF &tarvhark NE 0 THEN DO;

	*Perheellisen tarveharkinta;
	IF &puoliso NE 0 OR &lapsia > 0 THEN DO;
		raja = SUM(&RajaHuolt, &lapsia * &RajaLaps );

		*Puolison tuloista tehtävä vähennys;
		*Vuonna 2013 työttömyysturvan tarveharkinta puolisojen tulojen perusteella poistui; 
		IF &puoliso NE 0 AND &mvuosi < 2013 THEN DO;
			tulo =  SUM(&puoltulo, -&PuolVah);
			IF tulo < 0 THEN tulo =  0;
		END;

		tulo = SUM(tulo, &omatulo);

		IF tulo > raja THEN temp = SUM(temp, -&TarvPros2 * SUM(tulo, -raja));
	END;

	*Yksinäisen tarveharkinta;
	ELSE IF &omatulo > &RajaYks THEN temp = SUM(temp, -&TarvPros1 * SUM(&omatulo -&RajaYks));

	IF temp < 0 THEN temp = 0;
END;

*Osittainen tuki; 
IF &ositt NE 0 THEN DO;

	IF &mvuosi >= 2003 THEN DO;
		raja = SUM(&OsRaja, &huoll * &OsRajaKor);

		*Tietyn rajan jälkeen vanhemman tulot pienentävät osittaista työmarkkinatukea. Tuki on kuitenkin minimissään tietty prosentti täydestä tuesta.;
		IF &vanhtulot > raja THEN DO;
			testi = temp;
			temp  = SUM(temp, -&OsTarvPros * SUM(&vanhtulot, -raja));
			IF temp < &OsPros * testi THEN temp = &OsPros * testi;
		END; 

	END;

	*Ennen vuotta 2003 osittainen tyomtukeen ei vaikuttanut vanhempien tulot vaan se oli aina tietty osuus täysmääräisestä.;
	ELSE temp = &OsPros * temp;
END;
	
temp = temp - &vahsosetuus;
IF temp < 0 THEN temp = 0;
IF &mvuosi < 1994 THEN temp = .;

&tulos = temp;
DROP raja testi temp tulo lapsikor;
%MEND TyomTukiKS;


/*  5. Makro laskee työmarkkinatuen kuukausitasolla vuosikeskiarvona */

*Makron parametrit:  
	tulos: Makron tulosmuuttuja, työmarkkinatuki, e/kk (vuosikeskiarvo)
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	tarvhark: Onko kyseessä tarveharkittu työmarkkinatuki (0/1)
	ositt: Onko kyseessä osittainen työmarkkinatuki (0/1)
	puoliso: Onko saajalla puolisoa (0/1)
	lapsia: Lapsien lkm perheessä 
	huoll: Muiden huollettavien lkm perheessä, jos kyseessä osittainen tmtuki
	omatulo: Oman muun tulon määrä, e/kk
	puoltulo: Puolison tulon määrä, e/kk
	vanhtulot: Vanhempien kuukausitulot, jos kyseessä osittainen tmtuki, e/kk
	oikeuskor: Onko oikeus korotusosaan (0/1)
	vahsosetuus: Päivärahasta vähennettävä muu sosiaalietuus, e/kk;

%MACRO TyomTukiVS(tulos, mvuosi, minf, tarvhark, ositt, puoliso, lapsia, huoll, omatulo, puoltulo, vanhtulot, oikeuskor, vahsosetuus)/STORE
DES = 'TTURVA: Työmarkkinatuki kuukausitasolla vuosikeskiarvona';

vuosipraha = 0;

%DO i = 1 %TO 12;
	%TyomTukiKS(temp, &mvuosi, &i, &minf, &tarvhark, &ositt, &puoliso, &lapsia, &huoll, &omatulo, &puoltulo, &vanhtulot, &oikeuskor, &vahsosetuus);
	vuosipraha = SUM(vuosipraha, temp);
%END;

&tulos = vuosipraha / 12;
DROP vuosipraha temp;
%MEND TyomTukiVS;


/*  6. Makro laskee peruspäivärahan kuukausitasolla */

*Makron parametrit: 
	tulos: Makron tulosmuuttuja, peruspäiväraha, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
    tarvhark: Onko kyseessä tarveharkittu Peruspäiväraha (0/1)
	muutturva: Onko oikeus muutosturvaan (0/1)
	puoliso: Onko saajalla puolisoa (0/1)
	lapsia: Lapsien lkm perheessä 
	omatulo: Oman muun tulon määrä, e/kk
	puoltulo: Puolison tulon määrä, e/kk
	vahsosetuus: Päivärahasta vähennettävä muu sosiaalietuus, e/kk;

%MACRO PerusPRahaKS(tulos, mvuosi, mkuuk, minf, tarvhark, muutturva, puoliso, lapsia, omatulo, puoltulo, vahsosetuus)/STORE
DES = 'TTURVA: Peruspäiväraha kuukausitasolla';

%HaeParam_TTurva&tyyppi (&mvuosi, &mkuuk, &minf);

*Lapsikorotukset;
IF &lapsia <= 0 THEN lapsikor = 0;
ELSE IF &lapsia < 2 THEN lapsikor = &TTLaps1;
ELSE IF &lapsia < 3 THEN lapsikor = &TTLaps2;
ELSE lapsikor = &TTLaps3;

*Täysmääräinen peruspäiväraha;
temp = &TTPAIVIA * SUM(&TTPerus, lapsikor);
IF &muutturva NE 0 THEN temp = SUM(temp, &TTPAIVIA * &KorotusOsa);

*Tarveharkittu tuki, voimassa ennen vuotta 1994;
IF &tarvhark NE 0 AND &mvuosi < 1994 THEN DO;

	*Perheellisen tarveharkinta;
	IF &puoliso NE 0 OR &lapsia > 0 THEN DO;
		raja = SUM(&RajaHuolt, &lapsia * &RajaLaps );

		IF &puoliso NE 0 THEN DO;
			tulo =  SUM(&puoltulo, -&PuolVah);
			IF tulo < 0 THEN tulo =  0;
		END;

		tulo = SUM(tulo, &omatulo);

		IF tulo > raja THEN temp = SUM(temp, -&TarvPros2 * SUM(tulo, -raja));
	END;

	*Yksinäisen tarveharkinta;
	ELSE IF &omatulo > &RajaYks THEN temp = SUM(temp, -&TarvPros1 * SUM(&omatulo -&RajaYks));

	IF temp < 0 THEN temp = 0;
END;

temp = temp - &vahsosetuus;
IF temp < 0 THEN temp = 0;

&tulos = temp;
DROP raja temp tulo lapsikor;
%MEND PerusPRahaKS;


/*  7. Makro laskee peruspäivärahan kuukausitasolla vuosikeskiarvona */

*Makron parametrit: 
	tulos: Makron tulosmuuttuja, peruspäiväraha, e/kk (vuosikeskiarvo)
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
    tarvhark: Onko kyseessä tarveharkittu Peruspäiväraha (0/1)
	muutturva: Onko oikeus muutosturvaan (0/1)
	puoliso: Onko saajalla puolisoa (0/1)
	lapsia: Lapsien lkm perheessä 
	omatulo: Oman muun tulon määrä, e/kk
	puoltulo: Puolison tulon määrä, e/kk
	vahsosetuus: Päivärahasta vähennettävä muu sosiaalietuus, e/kk;

%MACRO PerusPRahaVS(tulos, mvuosi, minf, tarvhark, muutturva, puoliso, lapsia, omatulo, puoltulo, vahsosetuus)/STORE
DES = 'TTURVA: Peruspäiväraha kuukausitasolla vuosikeskiarvona';

vuosipraha = 0;

%DO i = 1 %TO 12;
	%PerusPRahaKS(temp, &mvuosi, &i, &minf, &tarvhark, &muutturva, &puoliso, &lapsia, &omatulo, &puoltulo, &vahsosetuus);
	vuosipraha = SUM(vuosipraha, temp);
%END;

&tulos = vuosipraha / 12;
DROP temp vuosipraha;
%MEND PerusPRahaVS;


/*  8. Makro laskee sovitellun työttömyysetuuden kuukausitasolla */

*Makron parametrit: 
	tulos: Makron tulosmuuttuja, soviteltu työttömyysetuus, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
    ansiosid: Onko kyseessä ansiosidonnainen työttömyysetuus (0/1)
	oikeuskor: Onko oikeus korotettuun päivärahaan (0/1)
	lapsia: Lapsien lkm perheessä 
	praha: Täyden tuen määrä, jos ei olisi soviteltu, e/kk
	tyotulo: Työtulo, joka on sovittelun perusteena, e/kk
	rahapalkka: Ansiosidonnaisen päivärahan perusteena oleva palkka, e/kk
	koultuki: Onko kyseessä koulutustuki (0/1)
	vahsosetuus: Päivärahasta vähennettävä muu sosiaalietuus, e/kk;

%MACRO SoviteltuKS(tulos, mvuosi, mkuuk, minf, ansiosid, oikeuskor, lapsia, praha, tyotulo, rahapalkka, koultuki)/STORE
DES = 'TTURVA: Soviteltu työttömyyspäiväraha kuukausitasolla';

%HaeParam_TTurva&tyyppi (&mvuosi, &mkuuk, &minf);

IF &koultuki NE 0 THEN DO;
	sovsuoja = &SovSuojaKoul;
	sovpros = &SovProsKoul;
END;
ELSE DO;
	sovsuoja = &SovSuoja;
	sovpros = &SovPros;
END;

*Sovittelun laskukaava;
IF &tyotulo < sovsuoja THEN temp2 = &praha;
ELSE temp2 = &praha - (sovpros * (&tyotulo - sovsuoja));

IF temp2 < 0 THEN temp2 = 0;

* Jos on ansiosidonnainen päiväraha, asetetaan maksimi ja minimi ;
IF &ansiosid NE 0 THEN DO;
	IF &oikeuskor NE 0 AND &mvuosi > 2002 THEN ylaraja = 1;
	ELSE ylaraja = &SovRaja;

	IF SUM(temp2, &tyotulo) > ylaraja * (1 - &VahPros) * &rahapalkka THEN temp2 = SUM(ylaraja * (1 - &VahPros) * &rahapalkka, -&tyotulo);
	
	IF &mvuosi >= 1994 THEN DO;
		%PerusPRahaKS(perus, &mvuosi, &mkuuk, &minf, 0, &oikeuskor, 0, &lapsia, 0, 0, 0);
		temp2 = MAX(temp2, perus - sovpros * (&tyotulo - sovsuoja) * (&tyotulo > sovsuoja));
	END;
END;

IF temp2 < 0 THEN temp2 = 0;

&tulos = temp2;
DROP ylaraja sovsuoja sovpros temp2 perus;
%MEND SoviteltuKS;


/*  9. Makro laskee sovitellun työttömyysetuuden kuukausitasolla vuosikeskiarvona */

*Makron parametrit: 
	tulos: Makron tulosmuuttuja, soviteltu työttömyysetuus, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
    ansiosid: Onko kyseessä ansiosidonnainen työttömyysetuus (0/1)
	oikeuskor: Onko oikeus korotettuun päivärahaan (0/1)
	lapsia: Lapsien lkm perheessä 
	praha: Täyden tuen määrä, jos ei olisi soviteltu, e/kk
	tyotulo: Työtulo, joka on sovittelun perusteena, e/kk
	rahapalkka: Ansiosidonnaisen päivärahan perusteena oleva palkka, e/kk
	koultuki: Onko kyseessä koulutustuki (0/1);

%MACRO SoviteltuVS(tulos, mvuosi, minf, ansiosid, oikeuskor, lapsia, praha, tyotulo, rahapalkka, koultuki)/STORE
DES = 'TTURVA: Soviteltu työttömyyspäiväraha kuukausitasolla vuosikeskiarvona';

sovtyot = 0;

%DO i = 1 %TO 12;
	%SoviteltuKS(temp, &mvuosi, &i, &minf, &ansiosid, &oikeuskor, &lapsia, &praha, &tyotulo, &rahapalkka, &koultuki);
	sovtyot = SUM(sovtyot, temp);
%END;

&tulos = sovtyot / 12;
DROP temp sovtyot;
%MEND SoviteltuVS;


/*  10. Makro laskee ansiosidonnaisen päivärahan perusteena olevan palkan kuukausitasolla (iteroiva käänteisfunktio) */

*Makron parametrit: 
	tulos: Makron tulosmuuttuja, ansiosidonnaisen päivärahan perusteena oleva palkka, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
 	lapsia: Lapsien lkm perheessä 
	vuosipraha: Saadun ansiosidonnaisen päivärahan määrä, e/vuosi
	tayspv: Täyden tuen päivien määrä vuoden aikana
	korpv: Korotetun tuen päivien määrä vuoden aikana
	mutpv: Muutosturvapäivien määrä vuoden aikana
	vuor: Jos kyseessä on vuorotteluvapaakorvaus (0/1)
	vuorkor: Jos vuorotteluvapaakorvaus on korotettu (0/1);

%MACRO AnsioSidPalkkaS(tulos, mvuosi, mkuuk, lapsia, vuosipraha, tayspv, korpv, mutpv, vuor, vuorkor)/STORE
DES = 'TTURVA: Ansiosidonnaisen päivärahan perusteena oleva palkka kuukausitasolla';

%HaeParam_TTurva&tyyppi (&mvuosi, &mkuuk, 1);

tayspr = 0; 
korpr = 0; 
mutpr = 0;
vuosipraha = &vuosipraha;

IF &vuor NE 0 THEN DO;	
	IF &vuorkor NE 0 THEN korpros = &VuorKorvPros2;
	ELSE korpros = &VuorKorvPros;
	vuosipraha = &vuosipraha / korpros;
END;

%AnsioSidKS(testi, &mvuosi, &mkuuk, 1, &lapsia, 0, 0, 0, 0, 0);
IF SUM(&tayspv, &korpv, &mutpv) <= 0 OR (vuosipraha / SUM(&tayspv, &korpv, &mutpv) * &TTPAIVIA <= testi) THEN &tulos = 0;
ELSE DO;
	DO i = 0 to 100 UNTIL (apr >= vuosipraha);
		IF &tayspv > 0 THEN DO;
			%AnsioSidKS(tayspr, &mvuosi, &mkuuk, 1, &lapsia, 0, 0, 0, i * 1000, 0); 
			tayspr = &tayspv * tayspr / &TTPAIVIA;
		END;
		IF &korpv > 0 THEN DO;
			%AnsioSidKS(korpr, &mvuosi, &mkuuk, 1, &lapsia, 1, 0, 0, i * 1000, 0); 
			korpr = &korpv * korpr / &TTPAIVIA;
		END;
		IF &mutpv > 0 THEN DO;
			%AnsioSidKS(mutpr, &mvuosi, &mkuuk, 1, &lapsia, 0, 1, 0, i * 1000, 0);
			mutpr = &mutpv * mutpr / &TTPAIVIA;
		END;
		apr = SUM(tayspr, korpr, mutpr);
	END;

	DO j = -9 to 9 UNTIL (apr >= vuosipraha);
		IF &tayspv > 0 THEN DO;
			%AnsioSidKS(tayspr, &mvuosi, &mkuuk, 1, &lapsia, 0, 0, 0, (i * 1000 + j * 100), 0); 
			tayspr = &tayspv * tayspr / &TTPAIVIA;
		END;
		IF &korpv > 0 THEN DO;
			%AnsioSidKS(korpr, &mvuosi, &mkuuk, 1, &lapsia, 1, 0, 0, (i * 1000 + j * 100), 0); 
			korpr = &korpv * korpr / &TTPAIVIA;
		END;
		IF &mutpv > 0 THEN DO;
			%AnsioSidKS(mutpr, &mvuosi, &mkuuk, 1, &lapsia, 0, 1, 0, (i * 1000 + j * 100), 0);
			mutpr = &mutpv * mutpr / &TTPAIVIA;
		END;
		apr = SUM(tayspr, korpr, mutpr);
	END;

	DO k = -9 to 9 UNTIL (apr >= vuosipraha);
		IF &tayspv > 0 THEN DO;
			%AnsioSidKS(tayspr, &mvuosi, &mkuuk, 1, &lapsia, 0, 0, 0, (i * 1000 + j * 100 + k * 10), 0); 
			tayspr = &tayspv * tayspr / &TTPAIVIA;
		END;
		IF &korpv > 0 THEN DO;
			%AnsioSidKS(korpr, &mvuosi, &mkuuk, 1, &lapsia, 1, 0, 0, (i * 1000 + j * 100 + k * 10), 0); 
			korpr = &korpv * korpr / &TTPAIVIA;
		END;
		IF &mutpv > 0 THEN DO;
			%AnsioSidKS(mutpr, &mvuosi, &mkuuk, 1, &lapsia, 0, 1, 0, (i * 1000 + j * 100 + k * 10), 0);
			mutpr = &mutpv * mutpr / &TTPAIVIA;
		END;
		apr = SUM(tayspr, korpr, mutpr);
	END;

	DO m = -9 to 9 UNTIL (apr >= vuosipraha);
		IF &tayspv > 0 THEN DO;
			%AnsioSidKS(tayspr, &mvuosi, &mkuuk, 1, &lapsia, 0, 0, 0, (i * 1000 + j * 100 + k * 10 + m), 0); 
			tayspr = &tayspv * tayspr / &TTPAIVIA;
		END;
		IF &korpv > 0 THEN DO;
			%AnsioSidKS(korpr, &mvuosi, &mkuuk, 1, &lapsia, 1, 0, 0, (i * 1000 + j * 100 + k * 10 + m), 0); 
			korpr = &korpv * korpr / &TTPAIVIA;
		END;
		IF &mutpv > 0 THEN DO;
			%AnsioSidKS(mutpr, &mvuosi, &mkuuk, 1, &lapsia, 0, 1, 0, (i * 1000 + j * 100 + k * 10 + m), 0);
			mutpr = &mutpv * mutpr / &TTPAIVIA;
		END;
		apr = SUM(tayspr, korpr, mutpr);
	END;

	&tulos = (i * 1000 + j * 100 + k * 10 + m);
END;

DROP tayspr korpr mutpr apr i j k m vuosipraha korpros testi lapsikor;
%MEND AnsioSidPalkkaS;


/*  11. Makro laskee ylläpitokorvaukset kuukausitasolla */

*Makron parametrit: 
	tulos: Makron tulosmuuttuja, ylläpitokorvaukset, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	oikeuskor: Onko oikeus korotettuun ylläpitokorvaukseen (0/1);

%MACRO YPitoKorvS(tulos, mvuosi, mkuuk, minf, oikeuskor)/STORE
DES = 'TTURVA: Ylläpitokorvaukset kuukausitasolla';

%HaeParam_TTurva&tyyppi(&mvuosi, &mkuuk, &minf);

&tulos = &TTPAIVIA * &YPiToK * ((&oikeuskor NE 0) + 1);

%MEND YPitoKorvS;


/*  12. Makro laskee ylläpitokorvaukset kuukausitasolla vuosikeskiarvona */

*Makron parametrit: 
	tulos: Makron tulosmuuttuja, ylläpitokorvaukset, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	oikeuskor: Onko oikeus korotettuun ylläpitokorvaukseen (0/1);

%MACRO YPitoKorvVS(tulos, mvuosi, minf, oikeuskor)/STORE
DES = 'TTURVA: Ylläpitokorvaukset kuukausitasolla vuosikeskiarvona';

ypito = 0;

%DO i = 1 %TO 12;
	%YPitoKorvS(temp, &mvuosi, &i, &minf, &oikeuskor);
	ypito = SUM(ypito, temp);
%END;

&tulos = ypito / 12;
DROP temp ypito;
%MEND YPitoKorvVS;


/*  13. Makro laskee vuorotteluvapaakorvaukset kuukausitasolla */

*Makron parametrit: 
	tulos: Makron tulosmuuttuja, vuorotteluvapaakorvaukset, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	perust: Onko perusturvan vuorotteluvapaakorvaus (0/1)
	korotus: Onko kyseessä korotettu korvaus (0/1)
	palkka: Korvauksen perusteena oleva palkka, e/kk;

%MACRO VuorVapKorvKS(tulos, mvuosi, mkuuk, minf, perust, korotus, palkka)/STORE
DES = 'TTURVA: Vuorotteluvapaakorvaukset kuukausitasolla';

%HaeParam_TTurva&tyyppi(&mvuosi, &mkuuk, &minf);

IF &perust NE 0 THEN DO;
	%PerusPRahaKS(temp, &mvuosi, &mkuuk, &minf, 0, 0, 0, 0, 0, 0, 0);
END;

ELSE DO;
	%AnsioSidKS(temp, &mvuosi, &mkuuk, &minf, 0, 0, 0, 0, &palkka, 0);
END;

*Vuorottelukorvaus on tietty osuus työttömyysetuudesta, johon olisi oikeutettu työttömänä;
temp = temp * ((&korotus NE 0) * &VuorKorvPros2 + (&korotus = 0) * &VuorKorvPros);

IF &mvuosi IN (1996,1997) AND temp > &VuorKorvYlaRaja THEN temp = &VuorKorvYlaRaja;

&tulos = temp;
DROP temp;
%MEND VuorVapKorvKS;


/*  14. Makro laskee vuorotteluvapaakorvaukset kuukausitasolla vuosikeskiarvona */

*Makron parametrit: 
	tulos: Makron tulosmuuttuja, vuorotteluvapaakorvaukset, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	perust: Onko perusturvan vuorotteluvapaakorvaus (0/1)
	korotus: Onko kyseessä korotettu korvaus (0/1)
	palkka: Korvauksen perusteena oleva palkka, e/kk;

%MACRO VuorVapKorvVS(tulos, mvuosi, minf, perust, korotus, palkka)/STORE
DES = 'TTURVA: Vuorotteluvapaakorvaukset kuukausitasolla vuosikeskiarvona';

vuorvapkorv = 0;

%DO i = 1 %TO 12;
	%VuorVapKorvKS(temp, &mvuosi, &i, &minf, &perust, &korotus, &palkka);
	vuorvapkorv = SUM(vuorvapkorv, temp);
%END;

&tulos = vuorvapkorv / 12;
DROP temp vuorvapkorv;
%MEND VuorVapKorvVS;


/*  15. Makro laskee sovittelun päivärahan perusteena olevan tulon kuukausitasolla (käänteisfunktio) */

*Makron parametrit: 
	tulos: Makron tulosmuuttuja, sovittelun päivärahan perusteena oleva tulo, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	koul: Onko kyseessä koulutustuki (0/1)
	sovpraha: Sovitellun päivärahan määrä (e/kk)
	praha: Täyden tuen määrä, jos ei olisi soviteltu, e/kk
	lapsia: Lapsien lkm perheessä
	rahapalkka: Työttömyyttä edeltävä kuukausipalkka ansioturvassa, e/kk
	oikeuskor: Onko oikeus korotettuun päivärahaan (sis. muutosturvalisä);

%MACRO SovPalkkaS(tulos, mvuosi, mkuuk, koul, sovpraha, praha, lapsia, rahapalkka, oikeuskor)/STORE
DES = 'TTURVA: Sovitellun päivärahan perusteena oleva palkka kuukausitasolla';

%HaeParam_TTurva&tyyppi(&mvuosi, &mkuuk, 1);

IF &koul NE 0 THEN DO;
	sovsuoja = &SovSuojaKoul;
	sovpros = &SovProsKoul;
END;

ELSE DO;
	sovsuoja = &SovSuoja;
	sovpros = &SovPros;
END;

IF sovpros NE 0 THEN temp3 = (&praha - &sovpraha + (sovpros * sovsuoja)) / sovpros;

IF &rahapalkka NE 0 THEN DO;
	IF &oikeuskor NE 0 AND &mvuosi > 2002 THEN ylaraja = 1;
	ELSE ylaraja = &SovRaja;

	%SoviteltuKS(test, &mvuosi, &mkuuk, 1, 1, &oikeuskor, &lapsia, &praha, temp3, &rahapalkka, &koul);
	IF test < &sovpraha THEN DO;
		temp3 = SUM(ylaraja * (1 - &VahPros) * &rahapalkka, - &sovpraha, sovpros * sovsuoja);

		%SoviteltuKS(test2, &mvuosi, &mkuuk, 1, 1, &oikeuskor, &lapsia, &praha, temp3, &rahapalkka, &koul);
		IF test > &sovpraha THEN DO;
			%PerusPRahaKS(perus, &mvuosi, &mkuuk, 1, 0, &oikeuskor, 0, &lapsia, 0, 0, 0);
			 IF sovpros NE 0 THEN temp3 = SUM(perus, -&sovpraha, sovpros * sovsuoja) / sovpros;
		END;
	END;
END;


IF temp < 0 THEN temp3 = 0;
IF &sovpraha >= &praha THEN temp3 = 0;
IF &mvuosi < 1997 then temp3=.;

&tulos = temp3;
DROP sovsuoja sovpros temp3 ylaraja test ;
%MEND SovPalkkaS;


/*  16. Makro laskee tarveharkinnan perusteena olevan tulon kuukausitasolla (käänteisfunktio) */

*Makron parametrit: 
	tulos: Makron tulosmuuttuja, tarveharkinnan perusteena oleva tulo, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	puoliso: Onko saajalla puolisoa (0/1)
	lapsia: Lapsien lkm perheessä 
	oikeuskor: Onko oikeus korotusosaan (0/1)
	tmtuki: Tarveharkitun työmarkkinatuen määrä, e/kk;

%MACRO TarvHarkTuloS(tulos, mvuosi, mkuuk, puoliso, lapsia, oikeuskor, tmtuki)/STORE
DES = 'TTURVA: Työmarkkinatuen tarveharkinnan perusteena oleva tulo kuukausitasolla';

%HaeParam_TTurva&tyyppi(&mvuosi, &mkuuk, 1);

%TyomTukiKS(taysi, &mvuosi, &mkuuk, 1, 0, 0, 0, &lapsia, 0, 0, 0, 0, &oikeuskor, 0);

IF &puoliso NE 0 OR &lapsia > 0 THEN DO;
	vah= &RajaHuolt + &lapsia * &RajaLaps;
	tarvpros = &TarvPros2;
END;

ELSE DO; 
	vah = &RajaYks;
	tarvpros = &TarvPros1;
END;

IF &puoliso NE 0 THEN vah = vah + &PuolVah;
IF tarvpros > 0 THEN temp = (taysi - &tmtuki + (tarvpros * vah)) / tarvpros;

IF &tmtuki >= taysi OR temp < 0 THEN temp = 0;

&tulos = temp;
DROP taysi tarvpros vah temp;
%MEND TarvHarkTuloS;


/*  17. Makro laskee osittaisen työmarkkinatuen perusteena olevan vanhempien tulon kuukausitasolla (käänteisfunktio) */

*Makron parametrit: 
	tulos: Makron tulosmuuttuja, työmarkkinatuen perusteena oleva vanhempien tulo, e/kk 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	mkuuk: Kuukausi, jonka lainsäädäntöä käytetään 
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
    huoll: Muiden huollettavien lkm perheessä
	oikeuskor: Onko oikeus korotusosaan (0/1)
	tmtuki: Osittaisen työmarkkinatuen määrä, e/kk;

%MACRO OsittTmTTuloS(tulos, mvuosi, mkuuk, huoll, oikeuskor, tmtuki)/STORE
DES = 'TTURVA: Osittaisen työmarkkinatuen perusteena oleva vanhempien tulo kuukausitasolla';

%HaeParam_TTurva&tyyppi(&mvuosi, &mkuuk, 1);

%TyomTukiKS(taysi, &mvuosi, &mkuuk, 1, 0, 0, 0, 0, 0, 0, 0, 0, &oikeuskor, 0);

raja = (&OsRaja + (&huoll * &OsRajaKor));
temp = SUM((&OsTarvPros * raja), taysi, -&tmtuki) / &OsTarvPros;

IF &tmtuki >= &OsPros * taysi AND &tmtuki < taysi THEN &tulos = temp;
ELSE IF &tmtuki < &OsPros * taysi THEN &tulos = 99999999;
ELSE &tulos = 0;

DROP raja taysi temp;
%MEND OsittTmTTuloS;
