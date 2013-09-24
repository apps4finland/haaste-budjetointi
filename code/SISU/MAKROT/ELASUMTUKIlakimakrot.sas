/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hy�dynt�� Tilastokeskuksen yleisten
* k�ytt�ehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto p��hakemistossa.
******************************************************************************/

/*************************************************************
* Kuvaus: El�kkeensaajien asumistuen lains��d�nt�� makroina  *
* Tekij�: Petri Eskelinen / KELA		                	 *
* Luotu: 11.8.2011			       					         *
* Viimeksi p�ivitetty: 26.1.2012		     		         *
* P�ivitt�j�: Olli Kannas / TK		     	     	 		 *
**************************************************************/ 


/* 1. SIS�LLYS */

/* Tiedosto sis�lt�� seuraavat makrot */

/*
2. EHoitoNormiS = Hoitonormi, joka laskee vesi-, l�mmitys- ja kunnossapitonormit eri tilanteisiin
3. EnimmAsMenoS = Hyv�ksytt�v� enimm�isasumismeno el�kkeensaajien asumistuessa
4. ElakAsumTukiS = El�kkeensaajien asumistuki;
*/


/* 2. Makro laskee vesi- ja l�mmitysnormit ja omakotitalon hoitonormin eri tyyppisiin tilanteisiin kuukausitasolla */

*Makrot parametrit:
	tulos: Makron tulosmuuttuja, normimeno, e/kk
	mvuosi: Vuosi, jonka lains��d�nt�� k�ytet��n
	minf: Deflaattori eurom��r�isten parametrien kertomiseksi
	perhe: Perheenj�senten lukum��r�: 1, 2,...
	lammryhma: El�kkeensaajien asumistuen l�mmitysryhm�: 1, 2 tai 3
	omakoti: Onko omakotitalo (1 = tosi, 0 = ep�tosi)
	kesklamm: Onko keskusl�mmitys (1 = tosi, 0 = ep�tosi)
	vesijohto: Onko vesijohto (1 = tosi, 0 = ep�tosi)
	eivesi: Vesi ei sis�lly vuokraan tai vastikkeeseen (1 = tosi, 0 = ep�tosi)
	eilamm: L�mmityskulut eiv�t sis�lly vuokraan tai vastikkeeseen (1 = tosi, 0 = ep�tosi)
	ala: Asunnon pinta-ala neli�metrein�
	valmvuosi: Asunnon valmistumisvuosi;

%MACRO EHoitonormiS(tulos, mvuosi, minf, perhe, lammryhma, omakoti, kesklamm, 
vesijohto, eivesi, eilamm, ala, valmvuosi)/STORE
DES = 'ELASUMTUKI: Omakotitalon hoitonormi kuukaudessa el�kkeensaajien asumistuessa';

%HaeParam_ElAsumTukiESIM(&mvuosi, &minf);

lammr = IFN(&lammryhma < 1, 1, &lammryhma);
lammr = IFN(&lammryhma > 3, 3, &lammryhma);

* L�mmitysnormi: riippuu siit�, onko keskusl�mmitys vai ei, kolme kuntaryhm�� ;

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

* Muuten lasketaan vain vesi- ja/tai l�mmitysnormi sen mukaan, mist� on maksettu erikseen ;

ELSE DO;
	IF (&EiVesi NE 0 AND &EiLamm NE 0) THEN &tulos = lamm + &perhe * vesi;
	ELSE IF (&EiVesi NE 0) THEN &tulos = &perhe * vesi;
	ELSE IF (&EiLamm NE 0) THEN &tulos = lamm;
END;
	
DROP nelioraja lammr lamm lamm1 lamm2 lamm3 vesi korotus alaX;

%MEND EHoitonormiS;


/* 3. Makro laskee el�kkeensaajien asumistuessa hyv�ksytt�v�n enimm�isasumismenon vuositasolla*/

*Makrot parametrit:
	tulos: Makron tulosmuuttuja, enimm�isasumismenot, e/vuosi 
	mvuosi: Vuosi, jonka lains��d�nt�� k�ytet��n
	minf: Deflaattori eurom��r�isten parametrien kertomiseksi 
	lapsia: Alaik�isten (alle 16-vuotiaiden) lasten lukum��r�: 0, 1, 2,...
	kryhma: Asumistuen kuntaryhm�: 1, 2, 3 tai 4
		    Huom! El�kkeensaajien asumistukilaki m��rittelee kolme kuntaryhm��, mutta
	        mallissa noudatetaan yleisen asumistuen kuntaryhmityst�;

%MACRO EnimmAsMenoS(tulos, mvuosi, minf, lapsia, kryhma)/STORE
DES = 'ELASUMTUKI: Enimm�isasumismeno vuodessa el�kkeensaajien asumistuessa';

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


/* 4. Makro laskee el�kkeensaajien asumistuen vuositasolla */

*Makrot parametrit:
	tulos: Makron tulosmuuttuja: asumistuki e/vuosi
	mvuosi: Vuosi, jonka lains��d�nt�� k�ytet��n
	minf: Deflaattori eurom��r�isten parametrien kertomiseksi 
	puoliso: Onko puoliso (1 = tosi, 0 = ep�tosi)
	puoloikat: Onko puolisolla oikeus el�kkeensaajien asumistukeen (1 = tosi, 0 = ep�tosi)
	leskenel�ke: Onko kyse leskenel�kkeest� (1 = tosi, 0 = ep�tosi)
	rintsotelake: Onko kyse rintamasotilasel�kkeest� (1 = tosi, 0 = ep�tosi)
	lapsia: Alaik�isten (alle 16-vuotiaiden) lasten lukum��r�: 0, 1, 2,...
	omakoti: Onko oma omakotitalo (1 = tosi, 0 = ep�tosi)
	lammryhma: El�kkeensaajien asumistuen l�mmitysryhm�: 1, 2 tai 3
	kesklamm: Onko keskusl�mmitys (1 = tosi, 0 = ep�tosi)
	vesijohto: Onko vesijohto (1 = tosi, 0 = ep�tosi)
	eivesi: Vesi ei sis�lly vuokraan tai vastikkeeseen (1 = tosi, 0 = ep�tosi)
	eilamm: L�mmityskulut eiv�t sis�lly vuokraan tai vastikkeeseen (1 = tosi, 0 = ep�tosi)
	ala: Asunnon pinta-ala neli�metrein�
	valmvuosi: Asunnon valmistumisvuosi
	kryhma: Asumistuen kuntaryhm�: 1, 2, 3 tai 4
		    Huom! El�kkeensaajien asumistukilaki m��rittelee kolme kuntaryhm��, mutta
		    mallissa noudatetaan yleisen asumistuen kuntaryhmityst�
	tulot: Huomioon otettavat tulot, e/vuosi
	omaisuus: Huomioon otettava omaisuus (e)
	vuokra: Vuokra tai yhti�vastike, e/vuosi 
	askorot: Asuntolainan korot omistusasunnossa: e/vuosi; 


%MACRO ElakAsumTukiS(tulos, mvuosi, minf, puoliso, puoloikat, leskenelake, rintsotelake, lapsia, omakoti, 
lammryhma, kesklamm, vesijohto, eivesi, eilamm, ala, valmvuosi, kryhma, tulot, omaisuus, vuokra, askorot)/STORE
DES = 'ELASUMTUKI: El�kkeensaajan asumistuki vuositasolla';

%HaeParam_ElAsumTukiESIM(&mvuosi, &minf);

perhelkm = IFN(&puoliso NE 0, 2, 1)+ &lapsia;

* Omakotitalossa asumiskustannukset muodostuvat asuntolainan koroista ja hoitonormista ;
IF(&omakoti NE 0) THEN DO;
	%EHoitonormiS(hnormi, &mvuosi, &minf, perhelkm, &lammryhma, 1, &kesklamm, &vesijohto, 1, 1, &ala, &valmvuosi);
	asumkust = &askorot + 12 * hnormi;
END;
ELSE DO;
	asumkust = &vuokra + &askorot;

	* Jos vesi ei sis�lly vastikkeseen tai vuokraan, lasketaan vesinormi ;
	IF(&eivesi NE 0) THEN DO;
		%EHoitonormiS(hnormi, &mvuosi, &minf, perhelkm, 1, 0, 1, &vesijohto, 1, 0, 1, &valmvuosi);
		asumkust = asumkust + 12 * hnormi;
	END;

	* Jos l�mmitys ei sis�lly vastikkeeseen tai vuokraan, lasketaan l�mmitysnormin mukaan ;
	IF(&eilamm NE 0) THEN DO;
		%EHoitonormiS(hnormi, &mvuosi, &minf, perhelkm, &lammryhma, 0, &kesklamm, 0, 0, 1, &ala, &valmvuosi);
		asumkust = asumkust + 12 * hnormi;
	END;	
END;

* Haetaan enimm�isasumismeno ;
%EnimmAsMenoS(enimmmeno, &mvuosi, &minf, &lapsia, &kryhma);

IF(asumkust > enimmmeno) THEN asumkust = enimmmeno;

* Leskenel�kkeiden lis�omavastuun tulorajoja ei ole erikseen m��ritelty vuodesta 2008 alkaen ;
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

* Jos leskenel�ke ja vuosi < 2008;
ELSE IF((&leskenelake) AND (&mvuosi < 2008)) THEN DO;


	IF (&puoliso EQ 0 ) THEN lisovastraja = &LisOVRaja4;
	ELSE lisovastraja = &LisOVRaja5;
END;

* Jos rintamasotilasel�ke, v�hennys tuloihin ;
IF (&rintsotelake NE 0) THEN rintsotvah = &RintSotVah;
ELSE rintsotvah = 0;

* Omaisuusrajat ;
IF (&puoliso EQ 0)	THEN omraja = &OmRaja;
ELSE omraja = &OmRaja2;

IF (&omaisuus > omraja) THEN omtulo = &OmPros * (&omaisuus - omraja);
ELSE omtulo = 0;

* Huomioon otettavat tulot yhteens� ;
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

