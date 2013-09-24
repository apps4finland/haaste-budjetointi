/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyˆdynt‰‰ Tilastokeskuksen yleisten
* k‰yttˆehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto p‰‰hakemistossa.
******************************************************************************/

/***********************************************************
* Kuvaus: Opintotuen simulointimalli 2011             	   *
* Tekij‰: Olli Kannas / TK		                		   *
* Luotu: 31.08.2011				       					   *
* Viimeksi p‰ivitetty: 18.4.2013		     		       *
* P‰ivitt‰j‰: Jukka Mattila / TK			     		   *
************************************************************/ 


/* 0. Yleisi‰ vakioiden m‰‰rittelyj‰ (‰l‰ muuta n‰it‰!) */

%LET START = &OUT;

%LET MALLI = OPINTUKI;

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

	%LET TULOSNIMI_OT = opintuki_simul_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;

	* Inflaatiokorjaus. Parametrien deflatoinnissa k‰ytett‰v‰n kertoimen voi syˆtt‰‰ itse
	  INF-makromuuttujaan (HUOM! desimaalit erotettava pisteell‰ .). Jos puolestaan haluaa k‰ytt‰‰ automaattista 
	  elinkustannusindeksiin perustuvaa parametrien muunnoskerrointa, 
	  tulee INF-makromuuttujalle antaa arvoksi 999 ; 	

	%LET INF = 1.00; * Syˆt‰ arvo tai 999 ;		
	%LET PINDEKSI_VUOSI = pindeksi_vuosi; *K‰ytett‰v‰ indeksien parametritaulukko;		

	* Ajettavat osavaiheet ; 

	%LET LAKIMAKROT = 1;    * Lakimakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
	%LET LAKIMAK_TIED_OT = OPINTUKIlakimakrot;	* Lakimakroissa k‰ytett‰v‰n tiedoston nimi ;
	%LET APUMAKROT = 1;   	* Apumakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
	%LET APUMAK_TIED_OT = OPINTUKIapumakrot; * Apumakroissa k‰ytett‰v‰n tiedoston nimi ;
	%LET POIMINTA = 1;  	* Muuttujien poiminta (1 jos ajetaan, 0 jos ei);
	%LET TULOKSET = 1;		* Yhteenvetotaulukot (1 jos ajetaan, 0 jos ei);

	%LET POPINTUKI = popintuki; * K‰ytett‰v‰n parametritiedoston nimi ;

	* Tulostaulukoiden esivalinnat ; 

	%LET TULOSLAAJ = 1 ; 	 * Mikrotason tulosaineiston laajuus (1 = suppea, 2 = laaja (palveluaineisto)) ;
	%LET MUUTTUJAT = TUKIKESK opirake TUKIKOR opirako ASUMLISA hasuli OPLAIN hopila ; * Taulukoitavat muuttujat (summataulukot) ;
	%LET YKSIKKO = 1;		 * Tulostaulukoiden yksikkˆ (1 = henkilˆ, 2 = kotitalous) ;
	%LET LUOK_HLO1 = desmod; * Taulukoinnin 1. henkilˆluokitus (jos YKSIKKO = 1)
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
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_OT..sas";
%END;

/* Ajetaan apumakrot ja tallennetaan ne (optio) */

%IF &APUMAKROT = 1 %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&APUMAK_TIED_OT..sas";
%END;

%MEND TeeMakrot;

%TeeMakrot;


/* 3. Datan poiminta ja apumuuttujien luominen (optio) */

%MACRO OpinTuki_Muutt_Poiminta; 

%IF &POIMINTA = 1 %THEN %DO;

	%LOCAL TYYPPI;
	%LET TYYPPI = SIMUL;

	/* 3.1 M‰‰ritell‰‰n tarvittavat palveluaineiston muuttujat taulukkoon START_OPINTUKI */

	DATA STARTDAT.START_OPINTUKI; 
	SET POHJADAT.&AINEISTO&AVUOSI
	(KEEP = hnro knro ikavu ikakk tkopira opirako opirake hasuli asko svatva svatvp apuraha tukiaika optukk
	ASKUST_LASK TUKIAIKA_KESK TUKIAIKA_KOR TAYSIM_KESK TAYSIM_KOR KOTONA_AS
	);

	WHERE (tkopira > 0 OR opirako NE 0 OR opirake NE 0 OR hasuli NE 0);

	/* 3.2 Lis‰t‰‰n aineistoon apumuuttujia */

	* Lasketaan kuukausia i‰n mukaan ja selvitet‰‰n kotona asumista ;

	%IkaKuuk_OpinTuki(IKA_KUUK1, 0, 17,(12 * ikavu + ikakk)); 
	ALLE18KUUK = IKA_KUUK1;
	%IkaKuuk_OpinTuki(IKA_KUUK2, 18, 19,(12*  ikavu + ikakk)); 
	ALLE20KUUK = IKA_KUUK2;
	%IkaKuuk_OpinTuki(IKA_KUUK3, 20, 100,(12 * ikavu + ikakk)); 
	VAH20KUUK = IKA_KUUK3;

	DROP IKA_KUUK1-IKA_KUUK3 tkopira;

	* M‰‰ritell‰‰n opintotuen ik‰luokka ;

	IF ALLE18KUUK > 6 THEN IKA = 17;
	ELSE IF ALLE20KUUK > 6 THEN IKA = 19;
	ELSE IF VAH20KUUK > 0 THEN IKA = 21; 
	ELSE IKA = ikavu; 

	DROP ALLE18KUUK ALLE20KUUK VAH20KUUK ikavu ikakk;

	* Lasketaan datasta opiskelijan omat veronalaiset tulot ja apurahat ; 

	OMA_TULO = SUM(svatva, svatvp, apuraha);

	RUN;

	/* 3.2.2 Etsit‰‰n kotona asuvien vanhemmat taulukkoon OPINTUKI_VANH */ 

	PROC SQL; 
	CREATE TABLE TEMP.OPINTUKI_VANH AS SELECT knro, asko, svatvap, svatpp, SUM(svatvap, svatpp, 0) AS temp
	FROM POHJADAT.&AINEISTO&AVUOSI
	WHERE asko IN (1, 2) AND knro IN (SELECT knro FROM STARTDAT.START_OPINTUKI WHERE KOTONA_AS = 1);
	QUIT;


	/* 3.2.3 Lasketaan vanhempien veronalaiset tulot yhteen taulukkoon OPINTUKI_VANH2 */ 

	PROC SQL; 
	CREATE TABLE TEMP.OPINTUKI_VANH2 AS SELECT knro, SUM(temp) AS VANH_TULO
	FROM TEMP.OPINTUKI_VANH GROUP BY OPINTUKI_VANH.knro;
	QUIT;


	/* 3.2.4 Siirret‰‰n tieto vanhempien tuloista takaisin taulukkoon START_OPINTUKI */

	DATA STARTDAT.START_OPINTUKI ;
	MERGE STARTDAT.START_OPINTUKI (DROP = asko svatva svatvp apuraha) 
	TEMP.OPINTUKI_VANH2 (KEEP = knro VANH_TULO);
	BY knro;
	IF VANH_TULO = . THEN VANH_TULO = 0;

	/* 3.3 Luodaan uusille apumuuttujille selkokieliset kuvaukset */

	LABEL
	KOTONA_AS = 'Vanhempien luona asuminen (0/1), DATA'
	IKA = 'Opintotuen ik‰luokka (17-v., 19-v. tai 21-v.), DATA'
	TUKIAIKA_KESK = 'Keskiasteen tukikuukaudet, DATA'
	TUKIAIKA_KOR ='Korkeakouluopintojen opintojen tukikuukaudet, DATA'
	TAYSIM_KESK ='Keskiasteen tuen t‰ysi‰ monikertoja vastaavat tukikuukaudet, DATA'
	TAYSIM_KOR ='Korkea-asteen tuen t‰ysi‰ monikertoja vastaavat tukikuukaudet, DATA'
	OMA_TULO = 'Opiskelijan omat veronalaiset tulot ja apurahat (e/v), DATA'
	VANH_TULO = 'Vanhempien veronalaiset tulot (e/v), DATA';

	RUN;

%END;

%MEND OpinTuki_Muutt_Poiminta;

%OpinTuki_Muutt_Poiminta;


/* 4. Simulointivaihe */

%LET alkoi2&malli = %SYSFUNC(TIME());

/* 4.1 Jos parametrit luetaan makromuuttujiksi ennen simulontia, ajetaan t‰m‰ makro, erillisajossa */

%MACRO KuukSimul;

%IF &F = S AND &TYYPPI = SIMULX %THEN %DO;

	%HaeParam_OpinTukiSIMUL(&LVUOSI, &LKUUK, &INF);

%END;

%MEND KuukSimul;

%KuukSimul;

/* 4.2 Varsinainen simulointivaihe */

%MACRO OpinTuki_Simuloi_Data;

DATA OUTPUT.&TULOSNIMI_OT;
SET STARTDAT.START_OPINTUKI;

* Lasketaan keskiasteen opiskelijan opintoraha ;

IF opirake > 0 THEN DO;

	IF TAYSIM_KESK = 1 THEN DO;
	%OpRahaV&F(OPRAHAKES1, &LVUOSI, &INF, 0, KOTONA_AS, IKA, 0, 0, 0, 0);
	TUKIKESK = TUKIAIKA_KESK * OPRAHAKES1;
	END;

	ELSE DO;
	%OpRahaV&F(OPRAHAKES2, &LVUOSI, &INF, 0, KOTONA_AS, IKA, 0, 0, VANH_TULO, 0);
	TUKIKESK = TUKIAIKA_KESK * OPRAHAKES2;
	END;

	DROP OPRAHAKES1 OPRAHAKES2;

END;

* Lasketaan korkeakouluopiskelijan opintoraha ;

IF  opirako > 0 THEN DO;

	IF TAYSIM_KOR = 1 THEN DO;
		%OpRahaV&F(OPRAHAKOR1, &LVUOSI, &INF, 1, KOTONA_AS, IKA, 0, 0, 0, 0);
		TUKIKOR = TUKIAIKA_KOR * OPRAHAKOR1;
	END;
		
	ELSE DO; 
		%OpRahaV&F(OPRAHAKOR2, &LVUOSI, &INF, 1, KOTONA_AS, IKA, 0, 0, VANH_TULO, 0);
		TUKIKOR = TUKIAIKA_KOR * OPRAHAKOR2;
	END;

	DROP OPRAHAKOR1 OPRAHAKOR2;

END;

* Lasketaan opintotuen asumislis‰ (jos 9 kk) ;

IF TUKIKOR > 0 THEN TUKIKORAPU = 1;
ELSE TUKIKORAPU = 0;

IF (hasuli NE 0 AND optukk = 9) THEN DO;

	%AsumLisaK&F(ASLIS1, &LVUOSI, 1, &INF, TUKIKORAPU, IKA, 0, ASKUST_LASK, 0, 0, 0); 
	%AsumLisaK&F(ASLIS2, &LVUOSI, 12, &INF, TUKIKORAPU, IKA, 0, ASKUST_LASK, 0, 0, 0);

	ASUMLISA = (7 * ASLIS1) + (2 * ASLIS2);

	DROP ASLIS1 ASLIS2;

END;

* Lasketaan opintotuen asumislis‰ (jos ei 9 kk, keskiarvo) ;

ELSE IF (hasuli NE 0 AND optukk NE 9 AND optukk > 0 AND tukiaika = 3) THEN DO;

	%AsumLisaV&F(ASLIS3, &LVUOSI, &INF, TUKIKORAPU, IKA, 0, ASKUST_LASK, 0, 0, 0);

	ASUMLISA = optukk * ASLIS3;

	DROP ASLIS3;

END;

* Lasketaan opintotuen asumislis‰ (4 kk syyslukukausi) ;

ELSE IF (hasuli NE 0 AND optukk = 4 AND tukiaika = 1) THEN DO;

	%AsumLisaK&F(ASLIS4, &LVUOSI, 9, &INF, TUKIKORAPU, IKA, 0, ASKUST_LASK, 0, 0, 0)
	%AsumLisaK&F(ASLIS5, &LVUOSI, 11, &INF, TUKIKORAPU, IKA, 0, ASKUST_LASK, 0, 0, 0)

	ASUMLISA = (2 * ASLIS4) + (2 * ASLIS5);

	DROP ASLIS4 ASLIS5;

END;

* Lasketaan opintotuen asumislis‰ (1-5 kk kev‰tlukukausi) ;

ELSE IF (hasuli NE 0 AND (0 < optukk < 7)  AND tukiaika = 2) THEN DO;

	%AsumLisaK&F(ASLIS6, &LVUOSI, 1, &INF, TUKIKORAPU, IKA, 0, ASKUST_LASK, 0, 0, 0)

	ASUMLISA = optukk * ASLIS6;

	DROP ASLIS6;

END;

* Lasketaan opintotuen asumislis‰ (syyslukukausi, ei 4 kk);

ELSE IF hasuli NE 0 AND optukk > 0 AND optukk NE 4 AND tukiaika = 1 THEN DO;

	%AsumLisaV&F(ASLIS7, &LVUOSI, &INF, TUKIKORAPU, IKA, 0, ASKUST_LASK, 0, 0, 0)

	ASUMLISA = optukk * ASLIS7;

	DROP ASLIS7 TUKIKORAPU;

END;

* Lasketaan mahdollinen (potentiaalinen) opintolainan valtiontakaus ;

%OpLainaV&F(OPLAIV1, &LVUOSI, &INF, 0, 0, IKA);
%OpLainaV&F(OPLAIV2, &LVUOSI, &INF, 1, 0, IKA);

OPLAIN = (TUKIAIKA_KESK * OPLAIV1) + (OPLAIV2 * TUKIAIKA_KOR);

DROP OPLAIV1 OPLAIV2;

* Lasketaan opintotuen takaisinperint‰ ; 

IF tukiaika < 3 THEN DO;

	%OpTukiTakaisin&F(TAKPER1, &LVUOSI, 1, &INF, TUKIAIKA_KOR, 0.5 * (OMA_TULO - TUKIKOR), TUKIKOR);

	TUKIKOR_TAK = TAKPER1;

	%OpTukiTakaisin&F(TAKPER2, &LVUOSI, 1, &INF, TUKIAIKA_KESK, 0.5 * (OMA_TULO - TUKIKESK), TUKIKESK);

	TUKIKESK_TAK = TAKPER2;

	%OpTukiTakaisin&F(TAKPER3, &LVUOSI, 1, &INF, optukk, 0.5 * (OMA_TULO - TUKIKOR - TUKIKESK), ASUMLISA);

	ASUMLISA_TAK = TAKPER3;

	DROP TAKPER1 TAKPER2 TAKPER3;

END;

ELSE DO;

	%OpTukiTakaisin&F(TAKPER4, &LVUOSI, 1, &INF, TUKIAIKA_KOR, OMA_TULO - TUKIKOR, TUKIKOR);

	TUKIKOR_TAK = TAKPER4;

	%OpTukiTakaisin&F(TAKPER5, &LVUOSI, 1, &INF, TUKIAIKA_KESK, OMA_TULO - TUKIKESK, TUKIKESK);

	TUKIKESK_TAK = TAKPER5;

	%OpTukiTakaisin&F(TAKPER6, &LVUOSI, 1, &INF, optukk, OMA_TULO - TUKIKOR - TUKIKESK, ASUMLISA);

	ASUMLISA_TAK = TAKPER6;

	DROP TAKPER4 TAKPER5 TAKPER6;

END;

* V‰hennet‰‰n opintotuen takaisinperint‰ (keskiaste) ; 

IF (opirake > 0 AND TAYSIM_KESK NE 1) THEN TUKIKESK = TUKIKESK - TUKIKESK_TAK ;

* V‰hennet‰‰n opintotuen takaisinperint‰ (korkea-aste) ; 

IF(opirako > 0 AND TAYSIM_KOR NE 1) THEN TUKIKOR = TUKIKOR - TUKIKOR_TAK;

* V‰hennet‰‰n asumislis‰n takaisinperint‰ ; 

IF hasuli > 0 THEN ASUMLISA = ASUMLISA - ASUMLISA_TAK;

KEEP hnro knro TUKIKESK_TAK TUKIKOR_TAK ASUMLISA_TAK TUKIKESK TUKIKOR ASUMLISA OPLAIN;

RUN;

/* 4.3 Yhdistet‰‰n simuloitu data palveluaineistoon (riippuen tulosaineiston laajuden valinnasta) */

DATA OUTPUT.&TULOSNIMI_OT;
	
/* 4.3.1 Suppea tulostiedosto (vain t‰rkeimm‰t luokittelumuuttujat) */

%IF &TULOSLAAJ = 1 %THEN %DO; 
	MERGE POHJADAT.&AINEISTO&AVUOSI 
	(KEEP = hnro knro &PAINO opirake opirako hasuli hopila ikavu ikavuV desmod soss paasoss elivtu koulas rake)
	OUTPUT.&TULOSNIMI_OT;
%END;

/* 4.3.2 Laaja tulostiedosto (palveluaineiston mukainen tulostiedosto) */

%IF &TULOSLAAJ = 2 %THEN %DO; 
	MERGE POHJADAT.&AINEISTO&AVUOSI OUTPUT.&TULOSNIMI_OT;
%END;

BY hnro;

* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukum‰‰r‰t voidaan laskea suoraan ;

ARRAY PISTE 
opirake opirako hasuli hopila TUKIKESK TUKIKOR ASUMLISA OPLAIN TUKIKESK_TAK TUKIKOR_TAK ASUMLISA_TAK;
DO OVER PISTE;
	IF PISTE <= 0 THEN PISTE = .;
END;

* Luodaan simuloiduille ja datan muuttujille selitteet ;

LABEL 
TUKIKESK = 'Keskiasteen opiskelijan opintoraha, MALLI'  
opirake = 'Keskiasteen opiskelijan opintoraha, DATA'  
TUKIKOR = 'Korkeakouluopiskelijan opintoraha, MALLI'
opirako = 'Korkeakouluopiskelijan opintoraha, DATA'
ASUMLISA = 'Opintotuen asumislis‰, MALLI'
hasuli = 'Opintotuen asumislis‰, DATA'
OPLAIN = 'Opintolainan valtiontakaus, MALLI'
hopila = 'Opintolainan valtiontakaus, DATA'
TUKIKESK_TAK = 'Keskiasteen opintorahan takaisinperint‰, MALLI'
TUKIKOR_TAK = 'Korkea-asteen opintorahan takaisinperint‰, MALLI' 
ASUMLISA_TAK = 'Asumislis‰n takaisinperint‰, MALLI';

RUN;

%MEND OpinTuki_Simuloi_Data;

%OpinTuki_Simuloi_Data;

%LET loppui2&malli = %SYSFUNC(TIME());


/* 5. Luodaan summatason tulostaulukot (optio) */

%MACRO OpinTuki_Tulokset;

/* 5.1 Kotitaloustason tulokset (optio) */

/* 5.1.1 Mikrotason tulosaineiston summaus kotitaloustasolle (optio) */

%IF &YKSIKKO = 2 AND &START NE 1 %THEN %DO; 

	PROC SUMMARY DATA=OUTPUT.&TULOSNIMI_OT (DROP = hnro);
	BY knro ;
	ID &PAINO ikavuV desmod paasoss elivtu koulas rake;
	VAR &MUUTTUJAT _NUMERIC_;
	OUTPUT OUT = OUTPUT.&TULOSNIMI_OT (DROP = ikavu soss _TYPE_ _FREQ_)  SUM = ;
	RUN;

%END;

/* 5.1.2 Summatason tulostaulukko (optio) */

%IF &TULOKSET = 1 %THEN %DO;

	%IF &YKSIKKO = 2 %THEN %DO;

		/* Siirret‰‰n tiedot Exceliin (optio) */

		%IF &EXCEL = 1 %THEN %DO;

			ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_OT._SUMMAT.xls" STYLE = MINIMAL;

		%END;

		PROC MEANS DATA=OUTPUT.&TULOSNIMI_OT &SUMWGT &SUM &MIN &MAX &RANGE &MEAN &MEDIAN &MODE &STD &VAR &CV NONOBS ORDER=DATA NWAY MAXDEC = 0; 
		TITLE "TUNNUSLUVUT (KOTITALOUSTASO), &MALLI";
		CLASS &LUOK_KOTI1 &LUOK_KOTI2 &LUOK_KOTI3 / MLF PRELOADFMT;
		VAR &MUUTTUJAT ;
		FORMAT _NUMERIC_ tuhat. ;
		%DO I = 1 %TO 3; 
		%IF %LENGTH (&&LUOK_KOTI&I) >0 %THEN %DO;
			FORMAT &&LUOK_KOTI&I &&LUOK_KOTI&I... ;
		%END;%END;
		OUTPUT OUT = OUTPUT.&TULOSNIMI_OT._SUMMAT (DROP = _TYPE_ _FREQ_)
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

			ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_OT._SUMMAT.xls" STYLE = MINIMAL;

		%END;

		PROC MEANS DATA=OUTPUT.&TULOSNIMI_OT &SUMWGT &SUM &MIN &MAX &RANGE &MEAN &MEDIAN &MODE &STD &VAR &CV NONOBS ORDER=DATA NWAY MAXDEC = 0;
		TITLE "TUNNUSLUVUT (HENKIL÷TASO), &MALLI";
		CLASS &LUOK_HLO1 &LUOK_HLO2 &LUOK_HLO3 / MLF PRELOADFMT;
		VAR &MUUTTUJAT ;
		FORMAT _NUMERIC_ tuhat. ;
		%DO I = 1 %TO 3; 
		%IF %LENGTH (&&LUOK_HLO&I) >0 %THEN %DO;
			FORMAT &&LUOK_HLO&I &&LUOK_HLO&I... ;
		%END;%END;
		OUTPUT OUT = OUTPUT.&TULOSNIMI_OT._SUMMAT (DROP = _TYPE_ _FREQ_)
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

%MEND OpinTuki_Tulokset;

%OpinTuki_Tulokset;


/* 6. Mitataan kuinka kauan osavaiheisiin kului aikaa */

%LET loppui1 = %SYSFUNC(TIME());

%LET loppui1&malli = %SYSFUNC(TIME());

%LET kului1&malli = %SYSEVALF(&&loppui1&malli - &&alkoi1&malli);

%LET kului2&malli = %SYSEVALF(&&loppui2&malli - &&alkoi2&malli);

%LET kului1&malli = %SYSFUNC(PUTN(&&kului1&malli, time10.2));

%LET kului2&malli = %SYSFUNC(PUTN(&&kului2&malli, time10.2));


%PUT &malli. Koko laskenta. Aikaa kului (hh:mm:ss.00) &&kului1&malli;

%PUT &malli. Varsinainen simulointi. Aikaa kului (hh:mm:ss.00) &&kului2&malli;
