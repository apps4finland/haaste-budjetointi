/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyˆdynt‰‰ Tilastokeskuksen yleisten
* k‰yttˆehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto p‰‰hakemistossa.
******************************************************************************/

/*********************************************************** *
*  Kuvaus: Yleisen asumistuen lains‰‰d‰ntˆ‰ makroina         * 
*  Tekij‰: Pertti Honkanen/ KELA                             *
*  Luotu: 12.09.2011                                         *
*  Viimeksi p‰ivitetty: 3.4.2012							 * 
*  P‰ivitt‰j‰: Olli Kannas / TK								 *
*  Korjattu 2.11.2012/Pertti Honkanen				         *
**************************************************************/

/* 1. SISƒLLYS */

/* HUOM! ASUMTUKI-mallissa parametrien haku tapahtuu vuokranormien osalta eri tavalla kuin muissa malleissa.
	  	 T‰st‰ johtuen Normivuokra- ja EnimmVuora-lakimakroista on kaksi eri versiota aineistosimulointiin ja esimerkkilaskelmiin.
		 Tyyppi: SIMUL = Aineistosimulointi
	     Tyyppi: ESIM = Esimerkkilaskelmat			
*/

/* Tiedosto sis‰lt‰‰ seuraavat makrot */

/* 
2. NormiNeliotS = Asunnon pinta-alan kohtuullinen neliˆmetrim‰‰r‰ (normineliˆt)
3. NormiVuokraSIMUL = Hyv‰ksytt‰v‰ enimm‰isasumismeno neliˆmetri‰ kohden kuukaudessa (normivuokra), SIMUL
4. NormiVuokraESIM = Hyv‰ksytt‰v‰ enimm‰isasumismeno neliˆmetri‰ kohden kuukaudessa (normivuokra), ESIM
5. EnimmVuokraSIMUL = Hyv‰ksytt‰v‰ enimm‰isasumismeno kuukaudessa osa-asunnossa (normivuokra), SIMUL
6. EnimmVuokraESIM = Hyv‰ksytt‰v‰ enimm‰isasumismeno kuukaudessa osa-asunnossa (normivuokra), ESIM
7. HoitoNormiS = Omakotitalon hoitonormi kuukaudessa
8. TuloMuokkausS = Perusomavastuun m‰‰rittelyss‰ tarvittavan tulon laskenta
9. PerusOmaVastS = Perusomavastuu kuukaudessa
10. AsumTukiVuokS = Asumisuki kuukaudessa vuokra-asunnossa
11. AsumTukiOmS = Asumituki kuukaudessa omistusasunnossa
12. AsumTukiOsaS = Asumisuki kuukaudessa osa-asunnossa
*/


/* 2. Makro, joka m‰‰rittelee normineliˆt (asunnon pinta-alan kohtuullisen neliˆmetrim‰‰r‰n);
	  Toimii, kun lains‰‰d‰ntˆvuosi annettu makromuuttujana ja kyseisen vuoden parametrit jo m‰‰ritelty */

*Makron parametrit:
	tulos: Makron tulosmuuttuja, normineliˆt, m2 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	henk: Ruokakuntaan kuuluvien henkilˆiden lukum‰‰r‰
	vamm: Ruokakuntaan kuuluu vammainen (on/ei, 1/0);

%MACRO NormiNeliotS(tulos, mvuosi, henk, vamm)/STORE
DES = 'ASUMTUKI: Asunnon pinta-alan kohtuullinen neliˆmetrim‰‰r‰ (normineliˆt)';

%HaeParam_AsumTuki&tyyppi(&mvuosi, 1);

luku = &henk;

*Vuodesta 1998 l‰htien vammaisille normi suuremman henkilˆluvun mukaan;

IF (&mvuosi > 1997) AND (&vamm NE 0) THEN luku = &henk + 1;

SELECT (luku);
   WHEN(1) &tulos = &EnimmN1;
   WHEN(2) &tulos = &EnimmN2;
   WHEN(3) &tulos = &EnimmN3;
   WHEN(4) &tulos = &EnimmN4;
   WHEN(5) &tulos = &EnimmN5;
   WHEN(6) &tulos = &EnimmN6;
   WHEN(7) &tulos = &EnimmN7;
   WHEN(8) &tulos = &EnimmN8;
   OTHERWISE &tulos = &EnimmN8 + (luku - 8) * &EnimmNPlus;
END;

DROP luku;

%MEND NormiNeliotS;


/* 3. Makro, joka m‰‰rittelee normivuokran (hyv‰ksytt‰v‰n kuukausittaisen enimm‰isasumismenon neliˆmetri‰ kohden).
	  T‰m‰ makro on itsen‰isesti toimiva makro, jota voi k‰ytt‰‰ myˆs data-askeleen ulkopuolella. 
	  Makroa k‰ytet‰‰n varsinaisissa simulointilaskelmissa (tyyppi = SIMUL). 
	  T‰m‰ edellytt‰‰, ett‰ halutun vuoden vuokranormit on jo erotettu omaksi taulukoksi normit&mvuosi. */
 
*Makron parametrit:
	tulos: Makron tulosmuuttuja, normivuokra, e/m2/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kryhma: Asumistuen kuntaryhma (1-4)
	kesklamm: Keskusl‰mmmitys (on/ei, 1/0)
	vesijohto: Vesijohto (on/ei, 1/0)
	valmvuosi: Asunnon valmistumis- tai perusparannusvuosi
	ala: Asunnon pinta-ala;

%MACRO NormiVuokraSIMUL (tulos, mvuosi,  minf, kryhma, kesklamm, vesijohto, valmvuosi, ala)/STORE
DES = 'ASUMTUKI, SIMUL: Hyv‰ksytt‰v‰ enimm‰isasumismeno neliˆmetri‰ kohden kuukaudessa (normivuokra)';

*Ensin etsit‰‰n oikea sarake, hakemalla vuosiluvun perusteella taulukosta normisarakb oikea
sarakkeen nimi;

IF &mvuosi < &paramalkuyat THEN nvuosi = &paramalkuyat;
ELSE IF &mvuosi > &paramloppuyat THEN nvuosi = &paramloppuyat;
ELSE nvuosi = &mvuosi;


IF _N_ = 1 OR taulu_ns = . THEN taulu_ns = OPEN("PARAM.normisarakb", "i");

RETAIN taulu_ns;

w = REWIND(taulu_ns);

w = FETCHOBS(taulu_ns, 1);

IF (GETVARN(taulu_ns, 2) <= &valmvuosi) OR (GETVARN(taulu_ns, 2) = 1900) THEN DO;
	sarake = COMPRESS(TRIM('valm')||GETVARC(taulu_ns, 1));
END;

ELSE DO UNTIL ((GETVARN(taulu_ns, 2) <= &valmvuosi) OR (GETVARN(taulu_ns, 2) = 1900));
	w = FETCH(taulu_ns);
	sarake = COMPRESS(TRIM('valm')||GETVARC(taulu_ns, 1));
END;

*T‰m‰n j‰lkeen haetaan vuokranormi pinta-alan, kuntaryhm‰n ym. muuttujien avulla;

nimi = COMPRESS("PARAM.normit"||nvuosi);


IF _N_ = 1 OR taulu_vn = . THEN taulu_vn = OPEN(nimi, "i");

RETAIN taulu_vn;

w = REWIND(taulu_vn);

w = FETCHOBS(taulu_vn, 1);
IF GETVARN(taulu_vn, 1) <= &ala AND &kryhma = GETVARN(taulu_vn, 2) THEN DO;
	IF &kesklamm NE 0 THEN &tulos = &minf * GETVARN(taulu_vn, VARNUM(taulu_vn, sarake));
	IF &kesklamm = 0 AND &vesijohto NE 0 THEN &tulos = &minf * GETVARN(taulu_vn, VARNUM(taulu_vn, "Vesijohto"));
	IF &kesklamm = 0 AND &vesijohto = 0 THEN &tulos = &minf * GETVARN(taulu_vn, VARNUM(taulu_vn, "Eivesijohto"));
	&tulos = &tulos / IFN(&mvuosi < 2002, &euro, 1);
END;
ELSE DO UNTIL (GETVARN(taulu_vn, 1) <= &ala AND &kryhma = GETVARN(taulu_vn, 2));
	w = FETCH(taulu_vn);
	IF &kesklamm NE 0 THEN &tulos = &minf * GETVARN(taulu_vn, VARNUM(taulu_vn, sarake));
	IF &kesklamm = 0 AND &vesijohto NE 0 THEN &tulos = &minf * GETVARN(taulu_vn, VARNUM(taulu_vn, "Vesijohto"));
	IF &kesklamm = 0 AND &vesijohto = 0 THEN &tulos = &minf * GETVARN(taulu_vn, VARNUM(taulu_vn, "Eivesijohto"));
	&tulos = &tulos / IFN(&mvuosi < 2002, &euro, 1);	
END;

*w = CLOSE(taulu_vn);

%MEND NormiVuokraSIMUL;


/* 4. Makro, joka m‰‰rittelee normivuokran kuukausitasolla.
	  T‰m‰ makro tekee saman asian kuin edellinen, mutta se toimii vain taulukossa, jossa lains‰‰d‰ntˆvuosi on SAS-muuttuja.
      Makro luo useita muuttujia data-taulukkoon. Makroa k‰ytet‰‰n esimerkkilaskelmissa (tyyppi = ESIM). */

*Makron parametrit:
	tulos: Makron tulosmuuttuja, normivuokra, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kryhma: Asumistuen kuntaryhma (1-4)
	kesklamm: Keskusl‰mmmitys (on/ei, 1/0)
	vesijohto: Vesijohto (on/ei, 1/0)
	valmvuosi: Asunnon valmistumis- tai perusparannusvuosi
	ala: Asunnon pinta-ala;

%MACRO NormiVuokraESIM (tulos, mvuosi, minf, kryhma, kesklamm, vesijohto, valmvuosi, ala)/STORE
DES = 'ASUMTUKI, ESIM: Hyv‰ksytt‰v‰ enimm‰isasumismeno neliˆmetri‰ kohden kuukaudessa (normivuokra)';

IF &mvuosi < &paramalkuyat THEN nvuosi = &paramalkuyat;
ELSE IF &mvuosi > &paramloppuyat THEN nvuosi = &paramloppuyat;
ELSE nvuosi = &mvuosi;

IF _N_ = 1 OR taulu_ns = . THEN taulu_ns = OPEN("PARAM.normisarakb", "i");

RETAIN taulu_ns;

w = REWIND(taulu_ns);
w = FETCHOBS(taulu_ns, 1);

IF (GETVARN(taulu_ns, 2) <= &valmvuosi) THEN sarake = COMPRESS(TRIM('valm')||GETVARC(taulu_ns, 1));
ELSE DO UNTIL ((GETVARN(taulu_ns, 2) <= &valmvuosi) OR (GETVARN(taulu_ns, 2) = 1900));
	w = FETCH(taulu_ns);
	sarake = COMPRESS(TRIM('valm')||GETVARC(taulu_ns, 1));
END;

IF _N_ = 1 OR taulu_vn = . THEN taulu_vn = OPEN("PARAM.&PASUMTUKI_VUOKRANORMIT", "i");

RETAIN taulu_vn;

w = REWIND(taulu_vn);

w = FETCHOBS(taulu_vn, 1);

IF  (GETVARN(taulu_vn, 1) <= &ala AND &kryhma = GETVARN(taulu_vn, 2) AND nvuosi = GETVARN(taulu_vn, 3)) THEN DO;
	IF &kesklamm NE 0 THEN &tulos = &minf * GETVARN(taulu_vn, VARNUM(taulu_vn, sarake));
	IF &kesklamm = 0 AND &vesijohto NE 0 THEN &tulos = &minf * GETVARN(taulu_vn, VARNUM(taulu_vn, "Vesijohto"));
	IF &kesklamm = 0 AND &vesijohto = 0 THEN &tulos = &minf * GETVARN(taulu_vn, VARNUM(taulu_vn, "Eivesijohto"));
	&tulos = &tulos / IFN(&mvuosi<2002, &euro, 1);	
END;
ELSE DO UNTIL (GETVARN(taulu_vn, 1) <= &ala AND &kryhma = GETVARN(taulu_vn, 2) AND nvuosi = GETVARN(taulu_vn, 3));
	w = FETCH(taulu_vn);
	IF &kesklamm NE 0 THEN &tulos = &minf * GETVARN(taulu_vn, VARNUM(taulu_vn, sarake));
	IF &kesklamm = 0 AND &vesijohto NE 0 THEN &tulos = &minf * GETVARN(taulu_vn, VARNUM(taulu_vn, "Vesijohto"));
	IF &kesklamm = 0 AND &vesijohto = 0 THEN &tulos = &minf * GETVARN(taulu_vn, VARNUM(taulu_vn, "Eivesijohto"));
	&tulos = &tulos / IFN(&mvuosi<2002, &euro, 1);	
END;

DROP sarake;

%MEND NormiVuokraESIM;


/* 5. Makro, joka m‰‰rittelee normivuokran osa-asunnossa kuukausitasolla.
	  T‰m‰ makro on itsen‰isesti toimiva makro, jota voi k‰ytt‰‰ myˆs data-askeleen ulkopuolella. 
	  Makroa k‰ytet‰‰n varsinaisissa simulointilaskelmissa (tyyppi = SIMUL). 
	  Toimii osana data-asekelta, kun lains‰‰d‰ntˆvuosi on m‰‰ritelty ennen makron ajamista ja halutun
	  vuoden normit eroteltu taulukoksi penimmtaulu&mvuosi. */

*Makron parametrit:
	tulos: Makron tulosmuuttuja, normivuokra osa-asunnossa, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kryhma: Asumistuen kuntaryhma (1-4)
	henk: Ruokakuntaan kuuluvien henkilˆiden lukum‰‰r‰;

%MACRO EnimmVuokraSIMUL(tulos, mvuosi, minf, kryhma, henk)/STORE
DES = 'ASUMTUKI, SIMUL: Hyv‰ksytt‰v‰ enimm‰isasumismeno kuukaudessa osa-asunnossa (normivuokra)';

%LET valuutta = IFN(&mvuosi < 2002, &euro, 1);

IF &mvuosi < &paramalkuyat THEN nvuosi = &paramalkuyat;
ELSE IF &mvuosi > &paramloppuyat THEN nvuosi = &paramloppuyat;
ELSE nvuosi = &mvuosi;

enimnimi = COMPRESS("PARAM.penimmtaulu"||nvuosi);

IF _N_ = 1 OR taulu_ev = . THEN taulu_ev = OPEN(enimnimi, "i");

RETAIN taulu_ev;

w = REWIND(taulu_ev);

w = FETCHOBS(taulu_ev, 1);

IF GETVARN(taulu_ev, 1 ) = &kryhma THEN &tulos = &minf * GETVARN(taulu_ev, MIN(&henk + 2, 10)) / &valuutta;
ELSE DO UNTIL ((GETVARN(taulu_ev, 1) = &kryhma) OR (w = -1));
	w = FETCH(taulu_ev);
	IF GETVARN(taulu_ev, 1 ) = &kryhma THEN &tulos = &minf * GETVARN(taulu_ev, MIN(&henk + 2, 10)) / &valuutta;
END;

*W = CLOSE(taulu_ev);

%MEND EnimmVuokraSIMUL;


/* 6. Makro, joka m‰‰rittelee normivuokran osa-asunnossa kuukausitasolla.
	  T‰m‰ makro tekee saman asian kuin edellinen, mutta se toimii vain taulukossa, jossa lains‰‰d‰ntˆvuosi on SAS-muuttuja.
      Makro luo useita muuttujia data-taulukkoon. Makroa k‰ytet‰‰n esimerkkilaskelmissa (tyyppi = ESIM).*/

*Makron parametrit:
	tulos: Makron tulosmuuttuja, normivuokra, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kryhma: Asumistuen kuntaryhma (1-4)
	henk: Ruokakuntaan kuuluvien henkilˆiden lukum‰‰r‰;

%MACRO EnimmVuokraESIM(tulos, mvuosi, minf, kryhma, henk)/STORE
DES = 'ASUMTUKI, ESIM: Hyv‰ksytt‰v‰ enimm‰isasumismeno kuukaudessa osa-asunnossa (normivuokra)';

%LET valuutta = IFN(&mvuosi < 2002, &euro, 1);

IF &mvuosi < &paramalkuyat THEN nvuosi = &paramalkuyat;
ELSE IF &mvuosi > &paramloppuyat THEN nvuosi = &paramloppuyat;
ELSE nvuosi = &mvuosi;

IF _N_ = 1 OR taulu_ev = . THEN taulu_ev = OPEN("param.&PASUMTUKI_ENIMMMENOT", "i");

RETAIN taulu_ev;

w = REWIND(taulu_ev);

w = FETCHOBS(taulu_ev, 1);

IF GETVARN(taulu_ev, 2 ) = nvuosi AND GETVARN(taulu_ev, 1 ) = &kryhma THEN &tulos = &minf * GETVARN(taulu_ev, MIN(&henk + 2, 10)) / &valuutta;
ELSE DO UNTIL ((GETVARN(taulu_ev, 2 ) = nvuosi) AND (GETVARN(taulu_ev, 1) = &kryhma) OR (w = -1));
	w = FETCH(taulu_ev);
	IF GETVARN(taulu_ev, 1 ) = &kryhma AND GETVARN(taulu_ev, 2 ) = nvuosi THEN &tulos = &minf * GETVARN(taulu_ev, MIN(&henk + 2, 10)) / &valuutta;
END;

%MEND EnimmVuokraESIM;


/* 7. Makro, joka laskee omakotitalon hoitonormin, tai erillisen l‰mmitysnormin */

*Makron parametrit:
	tulos: Makron tulosmuuttuja, omakotitalon hoitonormi, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	omakoti: Onko omakotitalo (on/ei, 1/0)
	lryhma: L‰mmitysryhma (1-3)
	henk: Ruokakuntaan kuuluvien henkilˆiden lukum‰‰r‰
	ala: Asunnon pinta-ala;

%MACRO HoitoNormiS(tulos, mvuosi, minf, omakoti, lryhma, henk, ala)/STORE
DES = 'ASUMTUKI: Omakotitalon hoitonormi kuukaudessa';

%HaeParam_AsumTuki&tyyppi (&mvuosi, &minf);

SELECT(&lryhma);
	WHEN(1) neliokohd = &Hoitomeno1;
	WHEN(2) neliokohd = &Hoitomeno2;
	WHEN(3) neliokohd = &Hoitomeno3;
	OTHERWISE neliokohd = &Hoitomeno1;
END;

IF &omakoti = 0 THEN &tulos = &ala * neliokohd;

ELSE &tulos = SUM(&HoitoMenoAs, &henk * &HoitoMenoHenk, &ala * neliokohd);

DROP neliokohd;
%MEND HoitoNormiS;


/* 8. Makro, joka laskee perusomavastuun m‰‰rittelyss‰ tarvittavan tulon
	  ottamalla huomioon varallisuuden, yksinhuoltajuuden ja henkilˆluvun */

*Makron parametrit:
	tulos: Makron tulosmuuttuja, perusomavastuun m‰‰rittelyss‰ tarvittava tulo, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	ykshuolt: Yksinhuoltaja (on/ei, 1/0)
	henk: Ruokakuntaan kuuluvien henkilˆiden lukum‰‰r‰
	varall: Ruokakunnan varallisuus, e
	tulot: Ruokakunnan huomioon otettavat tulot, e/kk;

%MACRO TuloMuokkausS(tulos, mvuosi, minf, ykshuolt, henk, varall, tulot)/STORE
DES = 'ASUMTUKI: Perusomavastuun m‰‰rittelyss‰ tarvittavan tulon laskenta';

%HaeParam_AsumTuki&tyyppi (&mvuosi, &minf);

*Ensin valitaan varallisuusrajanormi;

SELECT(&henk);
	WHEN(1) varraja = &AVarRaja1;
	WHEN(2) varraja = &AVarRaja2;
	WHEN(3) varraja = &AVarRaja3;
	WHEN(4) varraja = &AVarRaja4;
	WHEN(5) varraja = &AVarRaja5;
	OTHERWISE;
END;
SELECT;
	WHEN(&henk >= 6) varraja = &AVarRaja6;
	OTHERWISE varraja = varraja;
END;
&tulos = &tulot;

*Ennen vuotta 1998 varallisuusrajan ylitys johti siihen, ett‰ asumistukea ei saanut,
eli tulot katsottiin niin suuriksi, ettei asumistukeen ole oikeutta;

IF (&mvuosi < 1998) AND (&varall >  varraja) THEN &tulos = 999999;

*Vuodesta 1998 l‰htien tietty prosenttisuus (VarallPros) rajan ylityksest‰ katsotaan tuloksi;

IF (&mvuosi >= 1998 AND &varall >  varraja) THEN &tulos = &tulot + &VarallPros * (&varall - varraja);

*Jos henkilˆit‰ on enemm‰n kuin 8 tuloista v‰hennet‰‰n henkilˆluvun ylityksell‰ kerrottu vakio;

IF (&henk > 8) THEN &tulos = &tulot - (&henk - 8) * &OmaVastVah;

*Yhden lapsen yksinhuoltajille lis‰v‰hennys huomioon otettaviin tuloihin;

IF (&ykshuolt NE 0 AND &henk = 2) THEN &tulos = &tulot -  &YksHVah;

IF &tulos < 0 THEN &tulos = 0;

DROP varraja;

%MEND TuloMuokkausS;


* 9. Makro, joka m‰‰rittelee perusomavastuun kuukaudessa */

*Makron parametrit:
	tulos: Makron tulosmuuttuja, perusomavastuu, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kryhma: Asumistuen kuntaryhma (1-4)
	henk: Ruokakuntaan kuuluvien henkilˆiden lukum‰‰r‰
	tulo: Ruokakunnan tulot, johon on tehty edellisen makron sis‰lt‰m‰t
		  muokkaukkset henkilˆluvun, varallisuuden ja yksinhuoltajuuden perusteella, e/kk;

%MACRO PerusOmaVastS (tulos, mvuosi, minf, kryhma, henk, tulo)/STORE
DES = 'ASUMTUKI: Perusomavastuu kuukaudessa';

IF &mvuosi < &paramalkuyat THEN nvuosi = &paramalkuyat;
ELSE IF &mvuosi > &paramloppuyat THEN nvuosi = &paramloppuyat;
ELSE nvuosi = &mvuosi;

%LET valuutta = IFN(nvuosi < 2002, &euro, 1);

&tulos = 0;
testi = &tulo / &minf;

*Oikean taulukon nime‰mist‰ varten m‰‰ritell‰‰n kuntaryhm‰st‰ ja vuodesta riippuva tunnus, joka on
taulukon nimen lopussa; 
*Ennen vuotta 1995 kuntaryhmi‰ oli kolme ja nykyisell‰ 3. ja 4. kuntaryhm‰ll‰ oli yhteinen taulukko (c).
*Vuosina 1995ñ2001 kuntaryhmi‰ oli 3 ja nykyisill‰ 1. ja 2. kuntaryhm‰ll‰ oli yhteinen taulukko (a).
*Vuodesta 2002 l‰htien kuntaryhmi‰ on 4 ja kuntaryhmill‰ 1. ja 2. on yhteinen taulukko (ab).;

IF nvuosi < 1995 THEN DO;
		tunnus1 = ' a';
		tunnus2 = ' b';
		tunnus3 = ' c';
		tunnus4 = ' c';
END;

ELSE IF nvuosi> 1994 AND nvuosi < 2002 THEN DO;
		tunnus1 = ' a';
		tunnus2 = ' a';
		tunnus3 = ' b';
		tunnus4 = ' c';
END;

ELSE IF nvuosi GE 2002 THEN DO;
		tunnus1 = 'ab';
		tunnus2 = 'ab';
		tunnus3 = ' c';
		tunnus4 = ' d';
END;

*Avattavan taulukon nimi;

povnimi1 = COMPRESS("PARAM.pomavast"||nvuosi||tunnus1);
povnimi2 = COMPRESS("PARAM.pomavast"||nvuosi||tunnus2);
povnimi3 = COMPRESS("PARAM.pomavast"||nvuosi||tunnus3);
povnimi4 = COMPRESS("PARAM.pomavast"||nvuosi||tunnus4);

*Jos tyyppi = SIMUL tai SIMULx, taulukko avataan vain kerran;

IF _N_ = 1 OR taulu_pov1 = . OR SYMGET("TYYPPI") = 'ESIM' THEN taulu_pov1 = OPEN(povnimi1, "i");
IF _N_ = 1 OR taulu_pov2 = . OR SYMGET("TYYPPI") = 'ESIM' THEN taulu_pov2 = OPEN(povnimi2, "i");
IF _N_ = 1 OR taulu_pov3 = . OR SYMGET("TYYPPI") = 'ESIM' THEN taulu_pov3 = OPEN(povnimi3, "i");
IF _N_ = 1 OR taulu_pov4 = . OR SYMGET("TYYPPI") = 'ESIM' THEN taulu_pov4 = OPEN(povnimi4, "i");

%IF &tyyppi = SIMUL OR &tyyppi = SIMULX %THEN %DO;
	RETAIN taulu_pov1;
	RETAIN taulu_pov2;
	RETAIN taulu_pov3;
	RETAIN taulu_pov4;
%END;


*Selataan taulukkoa, kunnes henkilˆn lukum‰‰r‰‰ osoittavasta
sarakkeesta lˆytyy ensimm‰inen rivi, jossa testitulo >= tuloraja;
*Sarakkeen numero = henkilˆiden lukum‰‰r‰ + 1, paitsi jos henkilˆit‰ > 8;
*T‰ss‰ tarvitaan joka kuntaryhm‰lle oma koodi koska eri kuntaryhmien
tiedot haetaan eri taulukoista;

SELECT (&kryhma);
    WHEN (1) DO;	
		w = 0;
		raja = 0;
		w = REWIND(taulu_pov1);
		w = FETCHOBS(taulu_pov1, 1);
		IF testi = 0 THEN &tulos = &minf * GETVARN(taulu_pov1, MIN(&henk + 1, 9)) / &valuutta;
		ELSE DO WHILE (raja < testi AND w = 0);
			IF w = 0 THEN raja = GETVARN(taulu_pov1, 1) / &valuutta;
			IF w = 0 AND  raja <= testi THEN &tulos = &minf * GETVARN(taulu_pov1, MIN(&henk + 1, 9)) / &valuutta;
			IF w = -1 THEN &tulos = 9999/&valuutta;
			w = FETCH(taulu_pov1);
		END;
	END;
	WHEN (2) DO;
		w = 0;
		raja = 0;
		w = REWIND(taulu_pov2);
		w = FETCHOBS(taulu_pov2, 1);
		IF testi = 0 THEN &tulos = &minf * GETVARN(taulu_pov2, MIN(&henk + 1, 9)) / &valuutta;
		ELSE DO WHILE(raja <  testi AND w = 0);
			IF w = 0 THEN raja = GETVARN(taulu_pov2, 1) / &valuutta;
			IF w = 0 AND  raja <= testi THEN &tulos = &minf * GETVARN(taulu_pov2, MIN(&henk + 1, 9)) / &valuutta;
			IF w = -1 THEN &tulos = 9999/&valuutta;
			w = FETCH(taulu_pov2);
		END;
	END;
	WHEN (3) DO;
		w = 0;
		raja = 0;
		w = REWIND(taulu_pov3);
		w = FETCHOBS(taulu_pov3, 1);
		IF testi = 0 THEN &tulos = &minf * GETVARN(taulu_pov3, MIN(&henk + 1, 9)) / &valuutta;
		DO WHILE(raja <  testi AND w = 0);
			IF w = 0 THEN raja = GETVARN(taulu_pov3, 1) / &valuutta;
			IF w = 0 AND  raja <= testi THEN &tulos = &minf * GETVARN(taulu_pov3, MIN(&henk + 1, 9)) / &valuutta;
			IF w = -1 THEN &tulos = 9999/&valuutta;
			w = FETCH(taulu_pov3);
		END;
	END;
	WHEN (4) DO;
		w = 0;
		raja = 0;
		w = REWIND(taulu_pov4);
		w = FETCHOBS(taulu_pov4, 1);
		IF testi = 0 THEN &tulos = &minf * GETVARN(taulu_pov4, MIN(&henk + 1, 9)) / &valuutta;
		DO WHILE(raja < testi AND w = 0);
		    IF w = 0 THEN raja = GETVARN(taulu_pov4, 1) / &valuutta;
			IF w = 0 AND  raja <= testi THEN &tulos = &minf * GETVARN(taulu_pov4, MIN(&henk + 1, 9)) / &valuutta;
			IF w = -1 THEN &tulos = 9999/&valuutta;
   		     w = FETCH(taulu_pov4);
		END;
	END;
	OTHERWISE;
END;

*Jos tyyppi = ESIM, taulukot avataan ja suljetaan joka rivill‰ erikseen;

%IF &tyyppi = ESIM %THEN %DO;
	W = CLOSE (taulu_pov1);
	W = CLOSE (taulu_pov2);
	W = CLOSE (taulu_pov3);
	W = CLOSE (taulu_pov4);
	DROP taulu_pov1 taulu_pov2 taulu_pov3 taulu_pov4;
%END;

DROP w raja testi tunnus1 tunnus2 tunnus3 tunnus4 povnimi1 povnimi2 povnimi3 povnimi4 nvuosi;

IF &tulos = . THEN &tulos  = 9999/&valuutta;

%MEND PerusOmaVastS;


/* 10. Asumisuki kuukaudessa vuokra-asunnossa. 
       Perusomavastuu valmiiksi laskettu ja annetaan yhten‰ muuttujana */

*Makron parametrit:
	tulos: Makron tulosmuuttuja, asumistuki vuokra-asunnossa, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kryhma: Asumistuen kuntaryhma (1-4)
	lryhma: l‰mmitysryhma (1 -3)
	kesklamm: Keskusl‰mmmitys (on/ei, 1/0)
	vesijohto: Vesijohto (on/ei, 1/0)
	henk: Ruokakuntaan kuuluvien henkilˆiden lukum‰‰r‰
	vamm: Ruokakuntaan kuuluu vammainen (on/ei, 1/0)
	valmvuosi: Asunnon valmistumis- tai perusparannusvuosi
	ala: Asunnon pinta-ala
	perusomavast: Perusomavastuu, e/kk
	vuokra: Vuokra, e/kk
	vesi: Vesimaksu, e/kk
	lammkust: Erilliset l‰mmityskustannukset, e/kk;

%MACRO AsumTukiVuokS(tulos, mvuosi, minf, kryhma, lryhma, kesklamm, vesijohto, henk, vamm, 
valmvuosi, ala, perusomavast, vuokra, vesi, lammkust)/STORE
DES = 'ASUMTUKI: Asumisuki kuukaudessa vuokra-asunnossa';

%HaeParam_AsumTuki&tyyppi (&mvuosi, &minf);

%NormiNeliotS(hyvneliot, &mvuosi, &henk, &vamm);

hyvala = MIN(&ala, hyvneliot);

hyvvesi = MIN(&vesi, &henk * &VesiMaksu);

%HoitonormiS(hyvlamm, &mvuosi, &minf, 0, &lryhma, 0, &ala);

hyvlamm = MIN(hyvlamm, &lammkust);

askust = &vuokra + hyvvesi + hyvlamm;

IF &ala > 0 THEN neliokust = askust / &ala;

ELSE neliokust = 0;

%Normivuokra&tyyppi(hyvkust, &mvuosi, &minf, &kryhma, &kesklamm, &vesijohto, &valmvuosi, hyvala);

hyvkust2 = MIN(hyvkust, neliokust);

hyvkust3 = hyvala * hyvkust2;

&tulos = &ATukiPros * (hyvkust3 - &perusomavast);

IF &tulos <  &APieninTuki THEN &tulos = 0;

DROP hyvneliot hyvala hyvlamm hyvvesi askust neliokust hyvkust hyvkust2 hyvkust3;

%MEND AsumtukiVuokS;


/* 11. Asumisuki kuukaudessa omistusasunnossa. 
       Perusomvastuu valmiiksi laskettu ja annetaan yhten‰ muuttujana */

*Makron parametrit:
	tulos: Makron tulosmuuttuja, asumistuki omistusasunnossa, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kryhma: Asumistuen kuntaryhma (1-4)
	lryhma: l‰mmitysryhma (1 -3)
	omakoti: Onko omakotitalo (on/ei, 1/0)
	kesklamm: Keskusl‰mmmitys (on/ei, 1/0)
	vesijohto: Vesijohto (on/ei, 1/0)
	henk: Ruokakuntaan kuuluvien henkilˆiden lukum‰‰r‰
	vamm: Ruokakuntaan kuuluu vammainen (on/ei, 1/0)
	valmvuosi: Asunnon valmistumis- tai perusparannusvuosi
	ala: Asunnon pinta-ala
	omavast: Perusomavastuu, e/kk
	yhtvast: Yhtiˆvastike, e/kk
	vesi: Vesimaksu, e/kk
	lammkust: Erilliset l‰mmityskustannukset, e/kk
	korot: Asuntolainan korot, e/kk
	vuosimaksu: Aravalainan vuosimaksu, e/kk;

%MACRO AsumTukiOmS(tulos, mvuosi, minf, kryhma, lryhma, omakoti, kesklamm, vesijohto, henk, vamm, valmvuosi, 
ala, omavast, yhtvast, vesi, lammkust, korot, vuosimaksu)/STORE
DES = 'ASUMTUKI: Asumituki kuukaudessa omistusasunnossa';

%HaeParam_AsumTuki&tyyppi (&mvuosi, &minf);

%NormiNeliotS(hyvneliot, &mvuosi, &henk, &vamm);

hyvala = MIN(&ala, hyvneliot);

hyvvesi = MIN(&vesi, &henk * &VesiMaksu);

hyvkorot = &KorkoTukiPros * &korot;

hyvvuosimaksu = &AravaPros * &vuosimaksu;

%HoitonormiS(hyvlamm, &mvuosi, &minf, &omakoti, &lryhma, &henk, &ala);

IF &omakoti NE 0 THEN asmeno = hyvkorot + hyvvuosimaksu + hyvlamm;

ELSE asmeno = &yhtvast + hyvkorot + hyvvuosimaksu + hyvvesi + MIN(hyvlamm, &lammkust);

IF &ala > 0 THEN neliokust = asmeno / &ala;

ELSE neliokust = 0;

%Normivuokra&tyyppi(hyvkust, &mvuosi, &minf, &kryhma, &kesklamm, &vesijohto, &valmvuosi, hyvala);

hyvkust2 = MIN(hyvkust, neliokust);

asmeno2 = hyvala * hyvkust2;

&tulos = &ATukiPros * (asmeno2 - &omavast);

IF &tulos < &APieninTuki THEN &tulos = 0;

DROP hyvneliot hyvala hyvvesi hyvkorot hyvvuosimaksu hyvlamm asmeno asmeno2 neliokust hyvkust hyvkust2 ;

%MEND AsumTukiOmS;


/* 12. Asumisuki kuukaudessa osa-asunnossa.
       Perusomavastuu valmiiksi laskettu ja annetaan yhten‰ muuttujana */

*Makron parametrit:
	tulos: Makron tulosmuuttuja, asumisuki osa-asunnossa, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kryhma: Asumistuen kuntaryhma (1-4)
	henk: Ruokakuntaan kuuluvien henkilˆiden lukum‰‰r‰
	vamm: Ruokakuntaan kuuluu vammainen (on/ei, 1/0)
	perusomavast: Perusomavastuu, e/kk
	vuokra: Vuokra, e/kk
	vesi: Vesimaksu, e/kk;

%MACRO AsumTukiOsaS(tulos, mvuosi, minf, kryhma, henk, vamm, perusomavast, vuokra, vesi)/STORE
DES = 'ASUMTUKI: Asumisuki kuukaudessa osa-asunnossa';

luku = &henk;

*Vammaisille normi yht‰ suuremman henkilˆluvun mukaan:;

IF (&mvuosi > 1997) AND (&vamm NE 0) THEN luku = &henk + 1;

%HaeParam_AsumTuki&tyyppi (&mvuosi, &minf);

hyvvesi = MIN(&vesi, &henk * &VesiMaksu);

%EnimmVuokra&tyyppi(hyvvuokra, &mvuosi, &minf, &kryhma, luku);

hyvvuokra = MIN(&vuokra + hyvvesi, hyvvuokra);

&tulos = &ATukiPros * (hyvvuokra - &perusomavast);

IF &tulos < &APieninTuki THEN &tulos = 0;

DROP luku hyvvesi hyvvuokra;

%MEND AsumtukiOsaS;



	














