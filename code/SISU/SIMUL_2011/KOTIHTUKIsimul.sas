/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyˆdynt‰‰ Tilastokeskuksen yleisten
* k‰yttˆehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto p‰‰hakemistossa.
******************************************************************************/

/***********************************************************
* Kuvaus: Kotihoidon tuen simulointimalli 2011             *
* Tekij‰: Maria Valaste / KELA	                		   *
* Luotu: 25.11.2011			       					  	   *
* Viimeksi p‰ivitetty: 25.4.2013		     		       *
* P‰ivitt‰j‰: Jukka Mattila  / TK	   					   *
***********************************************************/ 


/* 0. Yleisi‰ vakioiden m‰‰rittelyj‰ (‰l‰ muuta n‰it‰!) */

%LET START = &OUT;

%LET MALLI = KOTIHTUKI;

%LET alkoi1&MALLI = %SYSFUNC(TIME());


/* 1. Mallia ohjaavat makromuuttujat */

%MACRO Aloitus;

%IF &START = 1 %THEN %DO;
	%LET TYYPPI = &TYYPPI_KOKO;
	%LET TULOKSET = &TULOKSET_KOKO;
%END;

%IF &START NE 1 %THEN %DO;

	/* Jos mallia k‰ytet‰‰n k‰yttˆliittym‰st‰ (&EG = 1), niin seuraavia vaiheita ei ajeta */

	%IF &EG NE 1 %THEN %DO;
		
	%LET AVUOSI = 2010;		* Aineistovuosi (vvvv);

	%LET LVUOSI = 2010;		* Lains‰‰d‰ntˆvuosi (vvvv);

	%LET TYYPPI = SIMUL;	* Parametrien hakutyyppi: SIMUL (vuosikeskiarvo) tai SIMULX (parametrit haetaan tietylle kuukaudelle);

	%LET LKUUK = 12;         * Lains‰‰d‰ntˆkuukausi, jos parametrit haetaan tietylle kuukaudelle;

	%LET AINEISTO = PALV ;  * K‰ytett‰v‰ aineisto (PALV = Palveluaineisto, REK = Rekisteriaineisto) ;

	%LET TULOSNIMI_KT = kotihtuki_simul_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;

	* Inflaatiokorjaus. Parametrien deflatoinnissa k‰ytett‰v‰n kertoimen voi syˆtt‰‰ itse
	  INF-makromuuttujaan (HUOM! desimaalit erotettava pisteell‰ .). Jos puolestaan haluaa k‰ytt‰‰ automaattista 
	  elinkustannusindeksiin perustuvaa parametrien muunnoskerrointa, 
	  tulee INF-makromuuttujalle antaa arvoksi 999 ; 	

	%LET INF = 1.00; * Syˆt‰ arvo tai 999 ;
	%LET PINDEKSI_VUOSI = pindeksi_vuosi; *K‰ytett‰v‰ indeksien parametritaulukko;		

	* Ajettavat osavaiheet ; 

	%LET LAKIMAKROT = 1;    * Lakimakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
	%LET LAKIMAK_TIED_KT = KOTIHTUKIlakimakrot;	* Lakimakroissa k‰ytett‰v‰n tiedoston nimi ;
	%LET APUMAKROT = 1;   	* Apumakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
	%LET APUMAK_TIED_KT = KOTIHTUKIapumakrot; * Apumakroissa k‰ytett‰v‰n tiedoston nimi ;
	%LET POIMINTA = 1;  	* Muuttujien poiminta (1 jos ajetaan, 0 jos ei);
	%LET TULOKSET = 1;		* Yhteenvetotaulukot (1 jos ajetaan, 0 jos ei);

	%LET PKOTIHTUKI = pkotihtuki; * K‰ytett‰v‰n parametritiedoston nimi ;

	* Tulostaulukoiden esivalinnat ; 

	%LET TULOSLAAJ = 1 ; 	 * Mikrotason tulosaineiston laajuus (1 = suppea, 2 = laaja (palveluaineisto)) ;
	%LET MUUTTUJAT =  tkotihtu KOTIHTUKI_DATA KOTIHTUKI oshr OSHOIT ; * Taulukoitavat muuttujat (summataulukot) ;
	%LET YKSIKKO = 1;		 * Tulostaulukoiden yksikkˆ (1 = henkilˆ, 2 = kotitalous) ;
	%LET LUOK_HLO1 = ; * Taulukoinnin 1. henkilˆluokitus (jos YKSIKKO = 1)
							   Vaihtoehtoina: 
							     desmod (tulodesiilit, ekvivalentit tulot (modoecd), hlˆpainot)
							     ikavu (henkilˆn mukaiset ik‰ryhm‰t)
							     elivtu (kotitalouden elinvaihe)
							     koulas (henkilˆn koulutusaste TK1997)
							     soss (henkilˆn sosioekonominen asema AML2001)
							     rake (kotitalouden rakenne) ;
	%LET LUOK_HLO2 = ;		 * Taulukoinnin 2. henkilˆluokitus ;
	%LET LUOK_HLO3 = ;		 * Taulukoinnin 3. henkilˆluokitus ;

	%LET LUOK_KOTI1 = desmod; * Taulukoinnin 1. kotitalousluokitus (jos YKSIKKO = 2) 
							    Vaihtoehtoina: 
							     desmod (tulodesiilit, ekvivalentit tulot (modoecd), hlˆpainot)
							     ikavuV (viitehenkilˆn mukaiset ik‰ryhm‰t)
							     elivtu (kotitalouden elinvaihe)
							     koulas (viitehenkilˆn koulutusaste TK1997)
							     paasoss (kotitalouden sosioekonominen asema AML2001)
							     rake (kotitalouden rakenne) ;
	%LET LUOK_KOTI2 = ; 	  * Taulukoinnin 2. kotitalousluokitus ;
	%LET LUOK_KOTI3 = ; 	  * Taulukoinnin 3. kotitalousluokitus ;

	%LET EXCEL = 0; 		 * Vied‰‰nkˆ tulostaulukko automaattisesti Exceliin (1 = Kyll‰, 0 = Ei) ;

	* Laskettavat tunnusluvut (jos tyhj‰, niin ei lasketa);

	%LET SUMWGT = SUMWGT; * N eli lukum‰‰r‰t ;
	%LET SUM = SUM; 
	%LET MIN = ; 
	%LET MAX = ;
	%LET RANGE = ;
	%LET MEAN = ;
	%LET MEDIAN = ;
	%LET MODE = ;
	%LET VAR = ;
	%LET CV =  ;
	%LET STD =  ;

	%LET PAINO = ykor ; 	* K‰ytett‰v‰ painokerroin (jos tyhj‰, niin lasketaan painottamattomana) ;
	%LET RAJAUS =  ; 		* Rajauslause tunnuslukujen laskentaan (jos tyhj‰, niin ei rajauksia);

	%END;

	/* Ajetaan mahdollinen inflaatiokorjaus */	

	%IF &INF = 999 %THEN %DO;
		%IF &LVUOSI = &AVUOSI %THEN %DO;
			%LET INF = 1;
		%END;
		%ELSE %DO;
			%IndKerroin (&AVUOSI, &LVUOSI);
		%END;
	%END;

%END;

%MEND Aloitus;

%Aloitus;
			
 
/* 2. T‰ll‰ makrolla s‰‰dell‰‰n laki- ja apumakro-ohjelmien ajoa. 
	  Jos makrot on jo tallennettu tai otettu k‰yttˆˆn, makro-ohjelmia ei ole pakko ajaa uudestaan. 
	  C-funktioita k‰ytett‰ess‰ SASCBTBL-m‰‰ritys on joka tapauksessa pakko tehd‰. */

%MACRO TeeMakrot;

%IF &F = C %THEN %DO;
	FILENAME SASCBTBL "&LEVY&KENO&HAKEM&KENO.JUTTA&KENO.juttamodul.txt";
%END;

/* Ajetaan lakimakrot ja tallennetaan ne (optio) */

%IF (&LAKIMAKROT = 1 AND &F = C) %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.JUTTA&KENO.juttafunkc.sas";
%END;

%ELSE %IF (&LAKIMAKROT = 1 AND &F = S) %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_KT..sas";
%END;

/* Ajetaan apumakrot ja tallennetaan ne (optio) */

%IF &APUMAKROT = 1 %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&APUMAK_TIED_KT..sas";
%END;

%MEND TeeMakrot;

%TeeMakrot;


/* 3. Datan poiminta ja apumuuttujien luominen (optio) */

%MACRO KotihTuki_Muutt_Poiminta;

%IF &POIMINTA = 1 %THEN %DO; 

	%LOCAL TYYPPI;
	%LET TYYPPI = SIMUL;

	/* 3.1 M‰‰ritell‰‰n tarvittavat palveluaineiston muuttujat taulukkoon START_KOTIHTUKI ja START_KOTIHTUKI_VERO */

	*Jos selvitet‰‰n suhdetta yksityisen hoidon tukeen ja kunnalliseen kotihoidon tukeen voidaan ottaa mukaan
	muuttujat ytku hkotihm ktku *
	*Kela-lis‰aineistosta voidaan poimia myˆs hokk = osittaisen hoitorahan kuukaudet;
	*Muuttajat apv amyky selitt‰isiv‰t suhdetta vanhempainp‰iv‰rahoihin;

	* Summataan tarvittavia muuttujia kotitaloustasolle ;

	PROC SUMMARY DATA = POHJADAT.&AINEISTO&AVUOSI;
	BY knro; 
	ID elivtu hnro;
	OUTPUT OUT = TEMP.KOTIHTUKI_T1 (DROP = _TYPE_ _FREQ_
	WHERE = (kthr > 0 OR kthl > 0 OR htkk > 0 OR oshr > 0
	OR hltulo >= 0 OR hlkk NE . OR  la1 NE . OR la2 NE . OR la3 NE . OR la4 NE . OR la5 NE . OR 
	la6 NE . OR la7 NE . OR la8 NE . OR la9 NE .)) 
	SUM(kthr kthl tkotihtu htkk oshr hltulo hlkk la1 la2 la3 la4 la5 la6 la7 la8 la9 
		PTULO OSTUKIKUUK TAYSIHR TAYSIHR_1 TAYSIHR_0_1 TAYSIHR_0_2
		VAJAAHR VAHENNYS VAHENNYS2) = ;
	RUN;
	
	* Poimitaan palveluaineiston tieto veronalaisesta kotihoidon tuesta (tkotihtu = Lasten kotihoidon 
	tuki ja osittainen hoitoraha ansiotulona) ;

	DATA STARTDAT.START_KOTIHTUKI_VERO;
	SET POHJADAT.&AINEISTO&AVUOSI
	(KEEP = hnro knro tkotihtu); 
	WHERE tkotihtu > 0; 
	RUN;

	DATA STARTDAT.START_KOTIHTUKI_VERO_oshr;
	SET POHJADAT.&AINEISTO&AVUOSI
	(KEEP = hnro knro oshr); 
	WHERE oshr > 0; 
	RUN;
	
	/* 3.2 Lis‰t‰‰n aineistoon apumuuttujia */

	DATA STARTDAT.START_KOTIHTUKI;
	SET TEMP.KOTIHTUKI_T1;
	
	* P‰‰tell‰‰n perheen koko hoitolis‰‰ varten: 2, 3 tai 4 muuttujaan PKOKO ;

	IF elivtu > 39 AND elivtu < 61 OR elivtu = 82 THEN OSAKOKO1 = 2; 
	ELSE OSAKOKO1 = 1;
	IF la2 > 0 THEN OSAKOKO2 = 2; 
	ELSE OSAKOKO2 = 1;
	PKOKO = SUM(OSAKOKO1, OSAKOKO2);

	* Etsit‰‰n t‰ydet yhden lapsen hoitorahat: jos aineiston hoitoraha jaettuna yhden lapsen hoitorahakuukausilla
  	on yht‰ suuri kuin mallilla (makrolla HoitoRahaV) laskettu yhden lapsen hoitoraha, TAYSIHR = 1 ;

	RUN;

%END;

%MEND KotihTuki_Muutt_Poiminta;

%KotihTuki_Muutt_Poiminta;


/* 4. Simulointivaihe */

%LET alkoi2&malli = %SYSFUNC(TIME());

/* 4.1 Jos parametrit luetaan makromuuttujiksi ennen simulontia, ajetaan t‰m‰ makro, erillisajossa */

%MACRO KuukSimul;

%IF &F = S AND &TYYPPI = SIMULX %THEN %DO;

	%HaeParam_KotihTukiSIMUL(&LVUOSI, &LKUUK, &INF);

%END;

%MEND KuukSimul;

%KuukSimul;


/* 4.2 Varsinainen simulointivaihe */

%MACRO KotihTuki_Simuloi_Data;

DATA OUTPUT.&TULOSNIMI_KT; 
SET STARTDAT.START_KOTIHTUKI;

* Lasketaan tapaukset, jotka edell‰ oli m‰‰ritelty t‰ysiksi hoitorahoiksi, HOITORAHA ;

IF TAYSIHR = 1 OR TAYSIHR_1 = 1 OR TAYSIHR_0_1 = 1 OR TAYSIHR_0_2 = 1 THEN DO;
	SISARK = 0;
	MUUKOR = 0;
	IF TAYSIHR_1 = 1 THEN SISARK = 1;
	IF TAYSIHR_0_1 = 1 THEN MUUKOR = 1;
	IF TAYSIHR_0_2 = 1 THEN MUUKOR = 2;

    %HoitoRahaV&F(HOITOR, &LVUOSI, &INF, SISARK, MUUKOR);

	HOITORAHA = la1 * HOITOR; 
END;

* Lasketaan tapaukset, jotka oli todettu vajaiksi ja tekem‰ll‰ v‰hennys;

%HoitoRahaV&F(HOITOR, &LVUOSI, &INF, 0, 0);
IF VAJAAHR = 1 THEN HOITORAHA = la1 * SUM(HOITOR, -VAHENNYS); 	

* Lasketaan hoitoraha muissa kuin em. tapauksissa, kun hoitolapsia on vain 1 ;

IF 	TAYSIHR NE 1 AND TAYSIHR_1 NE 1 AND TAYSIHR_0_1 NE 1 AND TAYSIHR_0_2 NE 1 AND VAJAAHR NE 1 AND
SUM(la2, la3, la4, la5, la6) = 0 THEN DO;
    HOITORAHA = SUM(la1 * hoitor, -VAHENNYS2);
END;

* Lasketaan hoitoraha muissa kuin em. tapauksissa, kun hoitolapsia on 2 ;

IF 	TAYSIHR NE 1 AND TAYSIHR_1 NE 1 AND TAYSIHR_0_1 NE 1 AND TAYSIHR_0_2 NE 1 AND VAJAAHR NE 1 AND
la2 > 0 AND la1 >= la2 AND SUM(la3, la4, la5, la6) = 0 THEN DO;
	%HoitoRahaV&F(hoitor, &LVUOSI, &INF, 1, 0);
	HOITORAHA = la2 * SUM(HOITOR, -VAHENNYS2);
END;

* Lasketaan hoitoraha muissa kuin em. tapauksissa, kun hoitolapsia on 3;
IF 	TAYSIHR NE 1 AND TAYSIHR_1 NE 1 AND TAYSIHR_0_1 NE 1 AND TAYSIHR_0_2 NE 1 AND VAJAAHR NE 1 AND
la2 > 0 AND la3 >0 AND la1 >= la2 AND la1 >= la3 AND SUM(la4, la5, la6) = 0 THEN DO;
	%HoitoRahaV&F(HOITOR, &LVUOSI, &INF, 1, 1);
	HOITORAHA = la3 * SUM(HOITOR, -VAHENNYS2);
END;

* Lasketaan hoitoraha muissa kuin em. tapauksissa, kun hoitolapsia on 4;
IF 	TAYSIHR NE 1 AND TAYSIHR_1 NE 1 AND TAYSIHR_0_1 NE 1 AND TAYSIHR_0_2 NE 1 AND VAJAAHR NE 1 AND
la2 > 0 AND la3 >0 AND la4 >0 AND la1 >= la2 AND la1 >= la3 AND la1 >= la4 AND SUM(la5, la6) = 0 THEN DO;
	%HoitoRahaV&F(HOITOR, &LVUOSI, &INF, 1, 2);
	HOITORAHA = la4 * SUM(HOITOR, -VAHENNYS2); 
END;

* Lasketaan hoitoraha muissa kuin em. tapauksissa, kun hoitolapsia on 5 ;

IF 	TAYSIHR NE 1 AND TAYSIHR_1 NE 1 AND TAYSIHR_0_1 NE 1 AND TAYSIHR_0_2 NE 1 AND VAJAAHR NE 1 AND
la2 > 0 AND la3 > 0 AND la4 > 0 AND la5 > 0 AND la1 >= la2 AND la1 >= la3 AND la1 >= la4 AND la1 >= la5 AND SUM(la6) = 0 THEN DO;
	%HoitoRahaV&F(HOITOR, &LVUOSI, &INF, 1, 3);
	HOITORAHA = la5 * SUM(HOITOR, -VAHENNYS2);
END;

* Lasketaan hoitoraha muissa kuin em. tapauksissa, kun hoitolapsia on 6 ;
IF 	TAYSIHR NE 1 AND TAYSIHR_1 NE 1 AND TAYSIHR_0_1 NE 1 AND TAYSIHR_0_2 NE 1 AND VAJAAHR NE 1 AND
la2 > 0 AND la3 > 0 AND la4 > 0 AND la5 > 0 AND la6 > 0 AND la1 >= la2 AND la1 >= la3 AND la1 >= la4 AND la1 >= la5 AND la1 >= la6 THEN DO;
	%HoitoRahaV&F(HOITOR, &LVUOSI, &INF, 1, 4);
	HOITORAHA = la6 * SUM(HOITOR, -VAHENNYS2);
END;

* Lasketaan hoitorahat muissa kuin edell‰ k‰sitellyiss‰ tapauksissa;
IF HOITORAHA = . THEN DO;

	IF KTHR > 0 THEN DO;

		LAMAX1 = MAX(la2, la1); 
		LAMAX2 = MAX(la3, LAMAX1);
		LAMAX3 = MAX(la4, LAMAX2);
		LAMAX4 = MAX(la5, LAMAX3);
		LAMAX5 = MAX(la6, LAMAX4);

		IF la6 > 0 THEN ALLEKOULUIKAISIA = 5; 
		ELSE IF la5 > 0 THEN ALLEKOULUIKAISIA = 4;
		ELSE IF la4 > 0 THEN ALLEKOULUIKAISIA = 3;
		ELSE IF la3 > 0 THEN ALLEKOULUIKAISIA = 2;
		ELSE IF la2 > 0 THEN ALLEKOULUIKAISIA = 1;
		ELSE ALLEKOULUIKAISIA = 0; * Muu alle kouluik‰inen ;

		%HoitoRahaV&F(HOITOR, &LVUOSI, &INF, 0, ALLEKOULUIKAISIA);

		HOITORAHA = LAMAX5 * HOITOR;

		 
	END;
END;

* Lasketaan hoitolis‰ muuttujaan HOITOLISA, k‰ytet‰‰n makroa HoitoLisaV ;

IF HOITORAHA > 0 THEN DO;
%HoitoLisaV&F(HOITOL, &LVUOSI, &INF, 0, 0, PKOKO, PTULO, 0); 
IF hlkk NE . THEN HOITOLISA  = MIN(12, hlkk) * HOITOL; 
END;

* Lasketaan hoitoraha ja hoitolis‰ yhteen, muuttuja TUKI ;

TUKI = SUM(HOITORAHA, HOITOLISA);

* Lasketaan osittainen hoitoraha makrolla OsitHoitRaha, muuttuja OSHOIT ;

%OsitHoitRahaV&F(OSHOITR, &LVUOSI, &INF);
OSHOIT = OSTUKIKUUK * OSHOITR; 

DROP SISARK MUUKOR HOITOR LAMAX1-LAMAX5 temp1 temp2 ALLEKOULUIKAISIA HOITOL OSHOITR; 

RUN;

* Lasketaan kotitalouksien eri henkilˆille suhteellinen osuus maksetusta kotihoidon tuesta:
  lasketaan ensin summa kotitalouksittain tiedostoon KOTIHTUKI_VEROx ;

PROC SUMMARY DATA = STARTDAT.START_KOTIHTUKI_VERO;
BY knro;
WHERE (tkotihtu > 0);
OUTPUT OUT = TEMP.KOTIHTUKI_VEROx (DROP = _TYPE_ _FREQ_) SUM(tkotihtu) = TKOTIHTU_SUM;
RUN;

* Lasketaan henkilˆiden osuudet kotihoidon tuesta, tiedosto KOTIHTUKI_HENK_OSUUDET ja muuttuja OSUUS ;

DATA TEMP.KOTIHTUKI_HENK_OSUUDET;
MERGE STARTDAT.START_KOTIHTUKI_VERO TEMP.KOTIHTUKI_VEROx (KEEP = knro TKOTIHTU_SUM);
BY knro;
OSUUS = SUM(tkotihtu) / SUM(TKOTIHTU_SUM);
RUN;

* Lasketaan kotitalouksien eri henkilˆille suhteellinen osuus osittaisesta hoitorahasta:
  lasketaan ensin summa kotitalouksittain tiedostoon KOTIHTUKI_VERO_oshrx ;

PROC SUMMARY DATA = STARTDAT.START_KOTIHTUKI_VERO_oshr;
BY knro; 
WHERE (oshr > 0);
OUTPUT OUT = TEMP.KOTIHTUKI_VERO_oshrx (DROP = _TYPE_ _FREQ_) SUM(oshr) = oshr_SUM;
RUN;

* Lasketaan henkilˆiden osuudet osittaisesta hoitorahasta, tiedosto KOTIHTUKI_HENK_OSUUDET_oshr ja muuttuja OSUUS_oshr ;

DATA TEMP.KOTIHTUKI_HENK_OSUUDET_oshr;
MERGE STARTDAT.START_KOTIHTUKI_VERO_oshr TEMP.KOTIHTUKI_VERO_oshrx (KEEP = knro oshr_SUM);
BY knro;
OSUUS_oshr = SUM(oshr) / SUM(oshr_SUM);
RUN;

* Lasketaan muuttujat HOITORAHA, HOITOLISA, TUKI ja OSHOIT uudestaan ottamalla huomioon tiedostojen 
  KOTIHTUKI_HENK_OSUUDET ja KOTIHTUKI_HENK_OSUUDET_oshr tiedot ja
  siirret‰‰n samalla tulokset tiedostoon OUTPUT.&TULOSNIMI_KT.
  TUKI-muuttujan nimeksi muutetaan KOTIHTUKI;

DATA OUTPUT.&TULOSNIMI_KT;
MERGE OUTPUT.&TULOSNIMI_KT(KEEP = hnro knro HOITORAHA HOITOLISA TUKI OSHOIT oshr tkotihtu) 
	TEMP.KOTIHTUKI_HENK_OSUUDET;
WHERE (tkotihtu > 0);
BY knro;
RUN;

DATA OUTPUT.&TULOSNIMI_KT;
MERGE OUTPUT.&TULOSNIMI_KT	TEMP.KOTIHTUKI_HENK_OSUUDET_oshr;
BY hnro;
RUN;

DATA OUTPUT.&TULOSNIMI_KT; 
SET OUTPUT.&TULOSNIMI_KT; 
HOITORAHA = OSUUS * HOITORAHA;
HOITOLISA = OSUUS * HOITOLISA;
KOTIHTUKI = OSUUS * TUKI;
OSHOIT = OSUUS_oshr * OSHOIT;
KEEP knro hnro HOITORAHA HOITOLISA KOTIHTUKI OSHOIT OSUUS OSUUS_oshr;
RUN;  


/* 4.3 Yhdistet‰‰n simuloitu data palveluaineistoon (riippuen tulosaineiston laajuden valinnasta) */

DATA OUTPUT.&TULOSNIMI_KT;
	
/* 4.3.1 Suppea tulostiedosto (vain t‰rkeimm‰t luokittelumuuttujat) */

%IF &TULOSLAAJ = 1 %THEN %DO; 
	MERGE POHJADAT.&AINEISTO&AVUOSI 
	(KEEP = hnro knro &PAINO tkotihtu kthr kthl oshr ikavu ikavuV desmod soss paasoss elivtu koulas rake)
	OUTPUT.&TULOSNIMI_KT;
%END;

/* 4.3.2 Laaja tulostiedosto (palveluaineiston mukainen tulostiedosto) */

%IF &TULOSLAAJ = 2 %THEN %DO; 
	MERGE POHJADAT.&AINEISTO&AVUOSI OUTPUT.&TULOSNIMI_KT;
%END;

BY hnro;

* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukum‰‰r‰t voidaan laskea suoraan ;

KOTIHTUKI_DATA = SUM(kthr, kthl);

ARRAY PISTE 
tkotihtu KOTIHTUKI_DATA KOTIHTUKI oshr OSHOIT HOITORAHA HOITOLISA;
DO OVER PISTE;
	IF PISTE <= 0 THEN PISTE = .;
END;

DROP kthr kthl;

* Luodaan simuloiduille ja datan muuttujille selitteet ;

LABEL 	
OSUUS = 'Henkilˆn osuus kotihoidon tuesta, MALLI'
OSUUS_oshr = 'Henkilˆn osuus osittaisesta hoitorahasta, MALLI'
tkotihtu = 'Lasten kotihoidon tuki yhteens‰ verotuksessa, DATA'
KOTIHTUKI_DATA = 'Lasten kotihoidon tuki, DATA'
KOTIHTUKI = 'Lasten kotihoidon tuki, MALLI'
HOITORAHA = 'Hoitoraha, MALLI'
HOITOLISA = 'Hoitolis‰, MALLI'
oshr = 'Osittainen hoitoraha, DATA'
OSHOIT = 'Osittainen hoitoraha, MALLI';

RUN;

%MEND KotihTuki_Simuloi_Data;

%KotihTuki_Simuloi_Data;

%LET loppui2&malli = %SYSFUNC(time());


/* 5. Luodaan summatason tulostaulukot (optio) */

%MACRO KotihTuki_Tulokset;

/* 5.1 Kotitaloustason tulokset (optio) */

/* 5.1.1 Mikrotason tulosaineiston summaus kotitaloustasolle (optio) */

%IF &YKSIKKO = 2 AND &START NE 1 %THEN %DO; 

	PROC SUMMARY DATA=OUTPUT.&TULOSNIMI_KT (DROP = hnro);
	BY knro ;
	ID &PAINO ikavuV desmod paasoss elivtu koulas rake;
	VAR &MUUTTUJAT _NUMERIC_;
	OUTPUT OUT = OUTPUT.&TULOSNIMI_KT (DROP = ikavu soss _TYPE_ _FREQ_)  SUM = ;
	RUN;

%END;

/* 5.1.2 Summatason tulostaulukko (optio) */

%IF &TULOKSET = 1 %THEN %DO;

	%IF &YKSIKKO = 2 %THEN %DO; 

		/* Siirret‰‰n tiedot Exceliin (optio) */

		%IF &EXCEL = 1 %THEN %DO;

			ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_KT._SUMMAT.xls" STYLE = MINIMAL;

		%END;

		PROC MEANS DATA=OUTPUT.&TULOSNIMI_KT &SUMWGT &SUM &MIN &MAX &RANGE &MEAN &MEDIAN &MODE &STD &VAR &CV NONOBS ORDER=DATA NWAY MAXDEC = 0; 
		TITLE "TUNNUSLUVUT (KOTITALOUSTASO), &MALLI";
		CLASS &LUOK_KOTI1 &LUOK_KOTI2 &LUOK_KOTI3 / MLF PRELOADFMT;
		VAR &MUUTTUJAT ;
		FORMAT _NUMERIC_ tuhat. ;
		%DO I = 1 %TO 3; 
		%IF %LENGTH (&&LUOK_KOTI&I) >0 %THEN %DO;
			FORMAT &&LUOK_KOTI&I &&LUOK_KOTI&I... ;
		%END;%END;
		OUTPUT OUT = OUTPUT.&TULOSNIMI_KT._SUMMAT (DROP = _TYPE_ _FREQ_)
		%IF %LENGTH (&SUMWGT) >0 %THEN %DO; SUMWGT = %END;  
		%IF %LENGTH (&SUM) >0 %THEN %DO; SUM = %END;
		%IF %LENGTH (&MIN) >0 %THEN %DO; MIN = %END;  
		%IF %LENGTH (&MAX) >0 %THEN %DO; MAX = %END;
		%IF %LENGTH (&RANGE) >0 %THEN %DO; RANGE = %END;  
		%IF %LENGTH (&MEAN) >0 %THEN %DO; MEAN = %END;
		%IF %LENGTH (&MEDIAN) >0 %THEN %DO; MEDIAN = %END;  
		%IF %LENGTH (&MODE) >0 %THEN %DO; MODE = %END; 
		%IF %LENGTH (&STD) >0 %THEN %DO; STD = %END;  
		%IF %LENGTH (&VAR) >0 %THEN %DO; VAR = %END; 
		%IF %LENGTH (&CV) >0 %THEN %DO; CV = %END; / AUTONAME AUTOLABEL;
		WHERE &RAJAUS ;
		WEIGHT &PAINO ;
		RUN;

		%IF &EXCEL = 1 %THEN %DO;

			ODS HTML3 CLOSE;

		%END;

	%END;
	
	/* 5.2 Henkilˆtason tulokset (oletus) */

	%ELSE %DO;

		/* Siirret‰‰n tiedot Exceliin (optio) */

		%IF &EXCEL = 1 %THEN %DO;

			ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_KT._SUMMAT.xls" STYLE = MINIMAL;

		%END;

		PROC MEANS DATA=OUTPUT.&TULOSNIMI_KT &SUMWGT &SUM &MIN &MAX &RANGE &MEAN &MEDIAN &MODE &STD &VAR &CV NONOBS ORDER=DATA NWAY MAXDEC = 0;
		TITLE "TUNNUSLUVUT (HENKIL÷TASO), &MALLI";
		CLASS &LUOK_HLO1 &LUOK_HLO2 &LUOK_HLO3 / MLF PRELOADFMT;
		VAR &MUUTTUJAT ;
		FORMAT _NUMERIC_ tuhat. ;
		%DO I = 1 %TO 3; 
		%IF %LENGTH (&&LUOK_HLO&I) >0 %THEN %DO;
			FORMAT &&LUOK_HLO&I &&LUOK_HLO&I... ;
		%END;%END;
		OUTPUT OUT = OUTPUT.&TULOSNIMI_KT._SUMMAT (DROP = _TYPE_ _FREQ_)
		%IF %LENGTH (&SUMWGT) >0 %THEN %DO; SUMWGT = %END;  
		%IF %LENGTH (&SUM) >0 %THEN %DO; SUM = %END;
		%IF %LENGTH (&MIN) >0 %THEN %DO; MIN = %END;  
		%IF %LENGTH (&MAX) >0 %THEN %DO; MAX = %END;
		%IF %LENGTH (&RANGE) >0 %THEN %DO; RANGE = %END;  
		%IF %LENGTH (&MEAN) >0 %THEN %DO; MEAN = %END;
		%IF %LENGTH (&MEDIAN) >0 %THEN %DO; MEDIAN = %END;  
		%IF %LENGTH (&MODE) >0 %THEN %DO; MODE = %END; 
		%IF %LENGTH (&STD) >0 %THEN %DO; STD = %END;  
		%IF %LENGTH (&VAR) >0 %THEN %DO; VAR = %END; 
		%IF %LENGTH (&CV) >0 %THEN %DO; CV = %END; / AUTONAME AUTOLABEL;
		WHERE &RAJAUS ;
		WEIGHT &PAINO ;
		RUN;

		%IF &EXCEL = 1 %THEN %DO;

			ODS HTML3 CLOSE;

		%END;

	%END;
%END;

%MEND KotihTuki_Tulokset;

%KotihTuki_Tulokset;


/* 6. Mitataan kuinka kauan osavaiheisiin kului aikaa */

%LET loppui1&malli = %SYSFUNC(TIME());

%LET kului1&malli = %SYSEVALF(&&loppui1&malli - &&alkoi1&malli);

%LET kului2&malli = %SYSEVALF(&&loppui2&malli - &&alkoi2&malli);

%LET kului1&malli = %SYSFUNC(PUTN(&&kului1&malli, time10.2));

%LET kului2&malli = %SYSFUNC(PUTN(&&kului2&malli, time10.2));


%PUT &malli. Koko laskenta. Aikaa kului (hh:mm:ss.00) &&kului1&malli;

%PUT &malli. Varsinainen simulointi. Aikaa kului (hh:mm:ss.00) &&kului2&malli;







