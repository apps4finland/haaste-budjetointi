/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyödyntää Tilastokeskuksen yleisten
* käyttöehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto päähakemistossa.
******************************************************************************/

/*************************************************************
* Kuvaus: Eläkkeensaajien asumistuen lainsäädäntöä makroina  *
* Tekijä: Petri Eskelinen / KELA		                	 *
* Luotu: 11.8.2011			       					         *
* Viimeksi päivitetty: 26.1.2012		     		         *
* Päivittäjä: Olli Kannas / TK		     	     	 		 *
**************************************************************/ 


/* 1. SISÄLLYS */

/* Tiedosto sisältää seuraavat makrot */

/*
2. EHoitoNormiS = Hoitonormi, joka laskee vesi-, lämmitys- ja kunnossapitonormit eri tilanteisiin
3. EnimmAsMenoS = Hyväksyttävä enimmäisasumismeno eläkkeensaajien asumistuessa
4. ElakAsumTukiS = Eläkkeensaajien asumistuki;
*/


/* 2. Makro laskee vesi- ja lämmitysnormit ja omakotitalon hoitonormin eri tyyppisiin tilanteisiin kuukausitasolla */

*Makrot parametrit:
	tulos: Makron tulosmuuttuja, normimeno, e/kk
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	perhe: Perheenjäsenten lukumäärä: 1, 2,...
	lammryhma: Eläkkeensaajien asumistuen lämmitysryhmä: 1, 2 tai 3
	omakoti: Onko omakotitalo (1 = tosi, 0 = epätosi)
	kesklamm: Onko keskuslämmitys (1 = tosi, 0 = epätosi)
	vesijohto: Onko vesijohto (1 = tosi, 0 = epätosi)
	eivesi: Vesi ei sisälly vuokraan tai vastikkeeseen (1 = tosi, 0 = epätosi)
	eilamm: Lämmityskulut eivät sisälly vuokraan tai vastikkeeseen (1 = tosi, 0 = epätosi)
	ala: Asunnon pinta-ala neliömetreinä
	valmvuosi: Asunnon valmistumisvuosi;

%MACRO EHoitonormiS(tulos, mvuosi, minf, perhe, lammryhma, omakoti, kesklamm, 
vesijohto, eivesi, eilamm, ala, valmvuosi)/STORE
DES = 'ELASUMTUKI: Omakotitalon hoitonormi kuukaudessa eläkkeensaajien asumistuessa';

%HaeParam_ElAsumTukiESIM(&mvuosi, &minf);

lammr = IFN(&lammryhma < 1, 1, &lammryhma);
lammr = IFN(&lammryhma > 3, 3, &lammryhma);

* Lämmitysnormi: riippuu siitä, onko keskuslämmitys vai ei, kolme kuntaryhmää ;

IF (&kesklamm NE 0) THEN DO;
	Lamm1 = &Lamm1;
	Lamm2 = &Lamm2;
	Lamm3 = &Lamm3;
END;
ELSE DO;
	Lamm1 = &MuuLamm1;
	Lamm2 = &MuuLamm2;
	Lamm3 = &MuuLamm3;
END;

* Vesinormi ;

IF (&vesijohto NE 0) THEN vesi = &Vesi1;
ELSE vesi = &Vesi2;

nelioraja = IFN(&perhe > 1, &YksRaja + (&perhe-1) * &PerhRaja, &YksRaja);

IF (&ala > nelioraja) THEN alaX = Nelioraja;
ELSE alaX = &ala;

SELECT (lammr);
	WHEN (1) lamm = alaX * Lamm1;
	WHEN (2) lamm = alaX * Lamm2;
	WHEN (3) lamm = alaX * Lamm3;
	OTHERWISE lamm = alaX * Lamm3;
END;

korotus = IFN(&valmvuosi < 1974, &Kor1974, 0);

* Jos omakotitalo, koko normi lasketaan ;

IF (&omakoti NE 0) THEN &tulos = (1 + korotus) * lamm + &perhe * vesi + (1 + korotus) * &KunnPito;

* Muuten lasketaan vain vesi- ja/tai lämmitysnormi sen mukaan, mistä on maksettu erikseen ;

ELSE DO;
	IF (&EiVesi NE 0 AND &EiLamm NE 0) THEN &tulos = lamm + &perhe * vesi;
	ELSE IF (&EiVesi NE 0) THEN &tulos = &perhe * vesi;
	ELSE IF (&EiLamm NE 0) THEN &tulos = lamm;
END;
	
DROP nelioraja lammr lamm lamm1 lamm2 lamm3 vesi korotus alaX;

%MEND EHoitonormiS;


/* 3. Makro laskee eläkkeensaajien asumistuessa hyväksyttävän enimmäisasumismenon vuositasolla*/

*Makrot parametrit:
	tulos: Makron tulosmuuttuja, enimmäisasumismenot, e/vuosi 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	lapsia: Alaikäisten (alle 16-vuotiaiden) lasten lukumäärä: 0, 1, 2,...
	kryhma: Asumistuen kuntaryhmä: 1, 2, 3 tai 4
		    Huom! Eläkkeensaajien asumistukilaki määrittelee kolme kuntaryhmää, mutta
	        mallissa noudatetaan yleisen asumistuen kuntaryhmitystä;

%MACRO EnimmAsMenoS(tulos, mvuosi, minf, lapsia, kryhma)/STORE
DES = 'ELASUMTUKI: Enimmäisasumismeno vuodessa eläkkeensaajien asumistuessa';

%HaeParam_ElAsumTukiESIM(&mvuosi, &minf);

SELECT(&kryhma);
	WHEN(1) enimm = &Enimm1 ;
	WHEN(2)	enimm = &Enimm2 ;
	WHEN(3)	enimm = &Enimm3 ;
	WHEN(4)	enimm = &Enimm4 ;
	OTHERWISE Enimm = &Enimm4 ;
END;
SELECT(&lapsia);
	WHEN(0)	lapsikor = 0;
	WHEN(1)	lapsikor = &LapsiKor1;
	WHEN(2)	lapsikor = &LapsiKor2;
	OTHERWISE lapsikor = &LapsiKor2;
END;

&tulos = (1+ lapsikor) * enimm;

&tulos = SUM(&tulos, 0);

DROP enimm lapsikor;

%MEND EnimmAsMenoS;


/* 4. Makro laskee eläkkeensaajien asumistuen vuositasolla */

*Makrot parametrit:
	tulos: Makron tulosmuuttuja: asumistuki e/vuosi
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	puoliso: Onko puoliso (1 = tosi, 0 = epätosi)
	puoloikat: Onko puolisolla oikeus eläkkeensaajien asumistukeen (1 = tosi, 0 = epätosi)
	leskeneläke: Onko kyse leskeneläkkeestä (1 = tosi, 0 = epätosi)
	rintsotelake: Onko kyse rintamasotilaseläkkeestä (1 = tosi, 0 = epätosi)
	lapsia: Alaikäisten (alle 16-vuotiaiden) lasten lukumäärä: 0, 1, 2,...
	omakoti: Onko oma omakotitalo (1 = tosi, 0 = epätosi)
	lammryhma: Eläkkeensaajien asumistuen lämmitysryhmä: 1, 2 tai 3
	kesklamm: Onko keskuslämmitys (1 = tosi, 0 = epätosi)
	vesijohto: Onko vesijohto (1 = tosi, 0 = epätosi)
	eivesi: Vesi ei sisälly vuokraan tai vastikkeeseen (1 = tosi, 0 = epätosi)
	eilamm: Lämmityskulut eivät sisälly vuokraan tai vastikkeeseen (1 = tosi, 0 = epätosi)
	ala: Asunnon pinta-ala neliömetreinä
	valmvuosi: Asunnon valmistumisvuosi
	kryhma: Asumistuen kuntaryhmä: 1, 2, 3 tai 4
		    Huom! Eläkkeensaajien asumistukilaki määrittelee kolme kuntaryhmää, mutta
		    mallissa noudatetaan yleisen asumistuen kuntaryhmitystä
	tulot: Huomioon otettavat tulot, e/vuosi
	omaisuus: Huomioon otettava omaisuus (e)
	vuokra: Vuokra tai yhtiövastike, e/vuosi 
	askorot: Asuntolainan korot omistusasunnossa: e/vuosi; 


%MACRO ElakAsumTukiS(tulos, mvuosi, minf, puoliso, puoloikat, leskenelake, rintsotelake, lapsia, omakoti, 
lammryhma, kesklamm, vesijohto, eivesi, eilamm, ala, valmvuosi, kryhma, tulot, omaisuus, vuokra, askorot)/STORE
DES = 'ELASUMTUKI: Eläkkeensaajan asumistuki vuositasolla';

%HaeParam_ElAsumTukiESIM(&mvuosi, &minf);

perhelkm = IFN(&puoliso NE 0, 2, 1)+ &lapsia;

* Omakotitalossa asumiskustannukset muodostuvat asuntolainan koroista ja hoitonormista ;
IF(&omakoti NE 0) THEN DO;
	%EHoitonormiS(hnormi, &mvuosi, &minf, perhelkm, &lammryhma, 1, &kesklamm, &vesijohto, 1, 1, &ala, &valmvuosi);
	asumkust = &askorot + 12 * hnormi;
END;
ELSE DO;
	asumkust = &vuokra + &askorot;

	* Jos vesi ei sisälly vastikkeseen tai vuokraan, lasketaan vesinormi ;
	IF(&eivesi NE 0) THEN DO;
		%EHoitonormiS(hnormi, &mvuosi, &minf, perhelkm, 1, 0, 1, &vesijohto, 1, 0, 1, &valmvuosi);
		asumkust = asumkust + 12 * hnormi;
	END;

	* Jos lämmitys ei sisälly vastikkeeseen tai vuokraan, lasketaan lämmitysnormin mukaan ;
	IF(&eilamm NE 0) THEN DO;
		%EHoitonormiS(hnormi, &mvuosi, &minf, perhelkm, &lammryhma, 0, &kesklamm, 0, 0, 1, &ala, &valmvuosi);
		asumkust = asumkust + 12 * hnormi;
	END;	
END;

* Haetaan enimmäisasumismeno ;
%EnimmAsMenoS(enimmmeno, &mvuosi, &minf, &lapsia, &kryhma);

IF(asumkust > enimmmeno) THEN asumkust = enimmmeno;

* Leskeneläkkeiden lisäomavastuun tulorajoja ei ole erikseen määritelty vuodesta 2008 alkaen ;
IF ((&leskenelake EQ 0) OR (&mvuosi > 2007)) THEN DO;
	IF (&puoliso EQ 0) THEN lisovastraja = &LisOVRaja;
	ELSE DO;
		IF (&puoloikat EQ 0) THEN lisovastraja =  &LisOVRaja2;
		ELSE DO;
			lisovastraja =  &LisOVRaja3 ;
			IF ( &mvuosi < 1997) THEN lisovastraja = &LisOVRaja2;
		END;
	END;
END;

* Jos leskeneläke ja vuosi < 2008;
ELSE IF((&leskenelake) AND (&mvuosi < 2008)) THEN DO;


	IF (&puoliso EQ 0 ) THEN lisovastraja = &LisOVRaja4;
	ELSE lisovastraja = &LisOVRaja5;
END;

* Jos rintamasotilaseläke, vähennys tuloihin ;
IF (&rintsotelake NE 0) THEN rintsotvah = &RintSotVah;
ELSE rintsotvah = 0;

* Omaisuusrajat ;
IF (&puoliso EQ 0)	THEN omraja = &OmRaja;
ELSE omraja = &OmRaja2;

IF (&omaisuus > omraja) THEN omtulo = &OmPros * (&omaisuus - omraja);
ELSE omtulo = 0;

* Huomioon otettavat tulot yhteensä ;
tulotx = &tulot + omtulo - rintsotvah;

IF (tulotx < 0) THEN tulotx = 0;

* Omavastuu ;
omavast = &PerusOVast;

IF (tulotx > lisovastraja) THEN  omavast = &PerusOVast + &LisOVastPros*(tulotx - lisovastraja);

* Tuki tukiprosentin mukaan laskettuna ;
&tulos = &ETukiPros * (asumkust - omavast);

* Pienin maksettava tuki ;
IF (&tulos < &EPieninTuki) THEN &tulos = 0;

&tulos = SUM(&tulos, 0);

DROP perhelkm asumkust hnormi enimmmeno rintsotvah omraja omtulo omavast lisovastraja tulotx;

%MEND ElakAsumTukiS;

