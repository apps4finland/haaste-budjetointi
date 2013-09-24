/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyödyntää Tilastokeskuksen yleisten
* käyttöehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto päähakemistossa.
******************************************************************************/

/*********************************************************** *
*  Kuvaus: Yleisen asumistuen simulointimalli 2011	         * 
*  Tekijä: Pertti Honkanen/ Kela                             *
*  Luotu: 12.09.2011                                         *
*  Viimeksi päivitetty: 7.5.2013							 * 
*  Päivittäjä: Olli Kannas / TK			                     *
**************************************************************/


/* 0. Yleisiä vakioiden määrittelyjä (älä muuta näitä!) */

%LET START = &OUT;

%LET MALLI = ASUMTUKI;

%LET TYYPPI = SIMUL;

%LET alkoi1&MALLI = %SYSFUNC(TIME());


/* 1. Mallia ohjaavat makromuuttujat */

%MACRO Aloitus;

%IF &START = 1 %THEN %DO;
	%LET TULOKSET = &TULOKSET_KOKO;
%END;

%IF &START NE 1 %THEN %DO;

	/* Jos mallia käytetään käyttöliittymästä (&EG = 1), niin seuraavia vaiheita ei ajeta */

	%IF &EG NE 1 %THEN %DO;

	%LET AVUOSI = 2010;		* Aineistovuosi (vvvv);

	%LET LVUOSI = 2010;		* Lainsäädäntövuosi (vvvv);

	%LET AINEISTO = PALV ;  * Käytettävä aineisto (PALV = Palveluaineisto, REK = Rekisteriaineisto) ;

	%LET TULOSNIMI_YA = asumtuki_simul_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;

	* Inflaatiokorjaus. Parametrien deflatoinnissa käytettävän kertoimen voi syöttää itse
	  INF-makromuuttujaan (HUOM! desimaalit erotettava pisteellä .). Jos puolestaan haluaa käyttää automaattista 
	  elinkustannusindeksiin perustuvaa parametrien muunnoskerrointa, 
	  tulee INF-makromuuttujalle antaa arvoksi 999 ; 	

	%LET INF = 1.00; * Syötä arvo tai 999 ;	
	%LET PINDEKSI_VUOSI = pindeksi_vuosi; *Käytettävä indeksien parametritaulukko;	

	* Ajettavat osavaiheet ; 

	%LET LAKIMAKROT = 1;    * Lakimakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
	%LET LAKIMAK_TIED_YA = ASUMTUKIlakimakrot;	* Lakimakroissa käytettävän tiedoston nimi ;
	%LET APUMAKROT = 1;   	* Apumakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
	%LET APUMAK_TIED_YA = ASUMTUKIapumakrot; * Apumakroissa käytettävän tiedoston nimi ;
	%LET POIMINTA = 1;  	* Muuttujien poiminta (1 jos ajetaan, 0 jos ei);
	%LET TULOKSET = 1;		* Yhteenvetotaulukot (1 jos ajetaan, 0 jos ei);

	/* Käytettävien parametritiedostojen nimet */

	%LET PASUMTUKI = pasumtuki;
	%LET PASUMTUKI_VUOKRANORMIT = pasumtuki_vuokranormit;
	%LET PASUMTUKI_ENIMMMENOT = pasumtuki_enimmmenot;

	* Tulostaulukoiden esivalinnat ; 

	%LET TULOSLAAJ = 1 ; 	 * Mikrotason tulosaineiston laajuus (1 = suppea, 2 = laaja (palveluaineisto)) ;
	%LET MUUTTUJAT = TUKIVUOK TUKIOM TUKIOSA TUKISUMMA hastuki; * Taulukoitavat muuttujat (summataulukot) ;
	%LET LUOK_KOTI1 = desmod; * Taulukoinnin 1. kotitalousluokitus (jos YKSIKKO = 2) 
							    Vaihtoehtoina: 
							     desmod (tulodesiilit, ekvivalentit tulot (modoecd), hlöpainot)
							     ikavuV (viitehenkilön mukaiset ikäryhmät)
							     elivtu (kotitalouden elinvaihe)
							     koulas (viitehenkilön koulutusaste TK1997)
							     paasoss (kotitalouden sosioekonominen asema AML2001)
							     rake (kotitalouden rakenne) ;
	%LET LUOK_KOTI2 = ; 	  * Taulukoinnin 2. kotitalousluokitus ;
	%LET LUOK_KOTI3 = ; 	  * Taulukoinnin 3. kotitalousluokitus ;

	%LET EXCEL = 0; 		  * Viedäänkö tulostaulukko automaattisesti Exceliin (1 = Kyllä, 0 = Ei) ;

	* Laskettavat tunnusluvut (jos tyhjä, niin ei lasketa);

	%LET SUMWGT = SUMWGT; * N eli lukumäärät ;
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

	%LET PAINO = ykor ; 	* Käytettävä painokerroin (jos tyhjä, niin lasketaan painottamattomana) ;
	%LET RAJAUS =  ; 		* Rajauslause tunnuslukujen laskentaan (jos tyhjä, niin ei rajauksia);

	%END;

	/* Osamallien ohjausparametrien arvot asetetaan nolliksi, jos mallia ajetaan erillisajossa (= ei KOKO-mallista) */

	%LET SAIRVAK = 0; %LET TTURVA = 0; %LET OPINTUKI = 0; %LET KANSEL = 0; %LET KOTIHTUKI = 0; %LET VERO = 0;

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


/* 2. Tällä makrolla säädellään laki- ja apumakro-ohjelmien ajoa. 
	  Jos makrot on jo tallennettu tai otettu käyttöön, makro-ohjelmia ei ole pakko ajaa uudestaan. 
	  C-funktioita käytettäessä SASCBTBL-määritys on joka tapauksessa pakko tehdä. */

%MACRO TeeMakrot;

%IF &F = C %THEN %DO;
	FILENAME SASCBTBL "&LEVY&KENO&HAKEM&KENO.JUTTA&KENO.juttamodul.txt";
%END;

/* Ajetaan lakimakrot ja tallennetaan ne (optio) */

%IF (&LAKIMAKROT = 1 AND &F = C) %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.JUTTA&KENO.juttafunkc.sas";
%END;

%ELSE %IF (&LAKIMAKROT = 1 AND &F = S) %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_YA..sas";
%END;

/* Ajetaan apumakrot ja tallennetaan ne (optio) */

%IF &APUMAKROT = 1 %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&APUMAK_TIED_YA..sas";
%END;

%MEND TeeMakrot;

%TeeMakrot;


/* 3. Datan poiminta ja apumuuttujien luominen (optio) */

%MACRO AsumTuki_Muutt_Poiminta;

%IF &POIMINTA = 1 %THEN %DO;

	/* 3.1 Määritellään tarvittavat palveluaineiston muuttujat taulukkoon START_ASUMTUKI_HENKI */

    /*Rajataan pois henkilöt jotka ovat saaneet opintotuen asumislisää, kuitenkin
	vain jos yleinen asumistuki = 0*/

	DATA STARTDAT.START_ASUMTUKI_HENKI 
	(KEEP = hnro knro elivtu 
	astukikr aslaji
	halpinta maksvuok kaytkorv
	yhtiovas hastuki hasuli
	lisalamm lisamaks omalamm omamaks
	rakvuosi aslaikor
	svatva svatvp opirake opirako
	tnoosvvb teinovvb tuosvvap 
	topkvvap teinovv hulkpa
	tpyspu1 thanpu1
	vlamm);

   	SET POHJADAT.&AINEISTO&AVUOSI;
   	WHERE NOT (hasuli > 0 AND hastuki = 0);
   	RUN;

   	*Käytetään ELASUMTUKI-mallissa tuotettua START_ELASUMTUKI taulukkoa sen selvittämiseen,
   	ketkä ovat oikeutettuja eläkkeensaajien asumistukeen, ja poistetaan nämä;

  	DATA STARTDAT.START_ASUMTUKI_HENKI;
   	MERGE STARTDAT.START_ASUMTUKI_HENKI (IN = C) STARTDAT.START_ELASUMTUKI (KEEP = hnro koodi);
   	IF C;
   	BY hnro;
	RUN;

	DATA STARTDAT.START_ASUMTUKI_HENKI;
   	SET STARTDAT.START_ASUMTUKI_HENKI;
	WHERE koodi NE 1;
	DROP koodi;
   	RUN;

   	/* 3.2 Summataan kotitaloustasolle taulukkoon START_ASUMTUKI_KOTI */

	PROC MEANS DATA = STARTDAT.START_ASUMTUKI_HENKI SUM N MIN NOPRINT;	
	VAR svatva svatvp kaytkorv 	
	lisamaks omalamm lisalamm
	omamaks aslaikor opirake opirako
	tnoosvvb teinovvb tuosvvap 
	topkvvap teinovv hulkpa
	tpyspu1 thanpu1 
	hastuki hnro;	
	ID elivtu astukikr aslaji
	maksvuok yhtiovas rakvuosi halpinta vlamm;
   	BY knro;	
   	OUTPUT OUT = STARTDAT.START_ASUMTUKI_KOTI
	SUM (svatva svatvp kaytkorv	
	lisamaks omalamm lisalamm	
	omamaks aslaikor opirake opirako
	tnoosvvb teinovvb tuosvvap 
	topkvvap teinovv hulkpa tpyspu1 thanpu1 hastuki) = N(hnro) = HENKIL MIN(hnro) = hnro;	
   	RUN;	
   
	/* 3.3 Lisätään aineistoon apumuuttujia ja summataan kotitaloustasolle taulukkoon START_ASUMTUKI_KOTI */

   	DATA STARTDAT.START_ASUMTUKI_KOTI;
   	SET STARTDAT.START_ASUMTUKI_KOTI;
   	LISALAMM = lisalamm / 12;
   	LISAMAKS = lisamaks / 12;
   	OMALAMM = omalamm / 12;
   	OMAMAKS = omamaks / 12;
   	ASLAIKOR = aslaikor / 12;
   	OSVEROVAP_DATA = tnoosvvb + teinovvb + tuosvvap + topkvvap + teinovv;
	METSA_VEROVAP_DATA = 0.25 * SUM(tpyspu1, thanpu1);
   	KUUKTULO_DATA = MAX((svatva + svatvp - opirake - opirako + OSVEROVAP_DATA + METSA_VEROVAP_DATA + hulkpa) / 12, 0);
   	IF maksvuok > 0 THEN VUOKRA_AS = 1;
   	ELSE VUOKRA_AS = 0;
   	IF OMALAMM > 0 THEN KESKLAMM = 0;
   	ELSE KESKLAMM = 1;
   	IF aslaji = 1 OR aslaji = 2 THEN OMAKOTI = 1;
   	ELSE OMAKOTI = 0;
   	IF elivtu = 20 OR elivtu = 84 THEN YKSH = 1;
   	ELSE YKSH = 0;

   	* Lämmitysryhmä ;
   	LAMMR = vlamm;

	 KEEP knro LISALAMM LISAMAKS OMALAMM OMAMAKS ASLAIKOR KUUKTULO_DATA maksvuok VUOKRA_AS KESKLAMM 
		  aslaji OMAKOTI YKSH LAMMR astukikr hulkpa METSA_VEROVAP_DATA OSVEROVAP_DATA HENKIL rakvuosi halpinta yhtiovas maksvuok kaytkorv;  

	LABEL
	HENKIL = 'Henkilöiden lukumäärä kotitaloudessa, DATA'
	LISALAMM = 'Lämmityskulut hoitovastikkeen sijasta (e/kk), DATA'
	LISAMAKS = 'Vesi- yms. maksut hoitovastikkeen sijasta (e/kk), DATA'
	OMALAMM = 'Omakotitalon lämmityskustannukset sähkön lisäksi (e/kk), DATA'
	OMAMAKS = 'Omakotitalon vesi- yms. maksut (e/kk), DATA'
	ASLAIKOR = 'Asuntolainojen korot (e/kk), DATA'
	OSVEROVAP_DATA = 'Verottomat osinkotulot, (e/kk), DATA'
	METSA_VEROVAP_DATA = 'Verottomat metsätulot, (e/kk), DATA'
	KUUKTULO_DATA ='Perusomavastuun tulokäsitteen määrittelyssä huomioon otettava tulo (e/kk), DATA'
	VUOKRA_AS = 'Asuu vuokralla (0/1), DATA'
	KESKLAMM = 'Asunnossa keskuslämmitys (0/1), DATA'
	OMAKOTI = 'Asuu omakotitaloussa (0/1), DATA'
	YKSH = 'Yksinhuoltaja (0/1), DATA'
	LAMMR = 'Lämmitysryhmä (1,2,3), DATA';

	RUN;

%END;

%MEND AsumTuki_Muutt_Poiminta;

%AsumTuki_Muutt_Poiminta;

%LET alkoi2&malli = %SYSFUNC(TIME());


/* 4. Makro hakee tietoja muista osamalleista ja liittää ne mallin dataan */

%MACRO OsaMallit_AsumTuki;

%IF &SAIRVAK = 1 OR &TTURVA = 1 OR &KANSEL = 1 OR &OPINTUKI = 1 OR &KOTIHTUKI = 1 OR &VERO = 1 %THEN %DO;

	DATA TEMP.ASUMTUKI_SIMULVERO (KEEP = hnro knro ANSIOT POTULOT OSINKOVAP OPTUKI_SIMUL);
	UPDATE STARTDAT.START_ASUMTUKI_HENKI (IN = C) OUTPUT.&TULOSNIMI_VE (KEEP = hnro ANSIOT POTULOT OSINKOVAP OPTUKI_SIMUL)
	UPDATEMODE=NOMISSINGCHECK;
	BY hnro;
	IF C;
	RUN;

	PROC MEANS DATA = TEMP.ASUMTUKI_SIMULVERO SUM NOPRINT;
	BY knro;
	VAR ANSIOT POTULOT OSINKOVAP OPTUKI_SIMUL;
	OUTPUT OUT = TEMP.ASUMTUKI_SIMULVERO_KOTIT SUM(ANSIOT POTULOT OSINKOVAP OPTUKI_SIMUL) = ;
	RUN;
	
	DATA STARTDAT.START_ASUMTUKI_KOTI;
	UPDATE STARTDAT.START_ASUMTUKI_KOTI (IN = C) TEMP.ASUMTUKI_SIMULVERO_KOTIT (KEEP = knro ANSIOT POTULOT OSINKOVAP OPTUKI_SIMUL)
	UPDATEMODE=NOMISSINGCHECK;
	BY knro;
	RUN;

%END;

%MEND OsaMallit_AsumTuki;

%OsaMallit_AsumTuki;


/* 5. ASUMTUKI-mallissa (vuositason lainsäädäntö) parametrit luetaan makromuuttujiksi ennen simulontia */
 
%HaeParam_AsumTukiSIMUL(&LVUOSI, &INF);
%HaeParam_VuokraNormit(&LVUOSI);
%HaeParam_EnimmVuokra(&LVUOSI);


/* 6. Simulointivaihe */

/* 6.1 Varsinainen simulointivaihe */

%MACRO AsumTuki_Simuloi_Data;

DATA OUTPUT.&TULOSNIMI_YA;
SET STARTDAT.START_ASUMTUKI_KOTI;

* Päätellään käytetäänkö simuloituja tietoja muista osamalleista vai alkuperäisen datan tietoja ;

%IF &SAIRVAK = 1 OR &TTURVA = 1 OR &KANSEL = 1 OR &OPINTUKI = 1 OR &KOTIHTUKI = 1 OR &VERO = 1 %THEN %DO;
	OSVEROVAP = OSINKOVAP;
	OPINTUKI = OPTUKI_SIMUL;
	KUUKTULO = SUM(ANSIOT, POTULOT, -OPTUKI_SIMUL, OSINKOVAP, hulkpa, METSA_VEROVAP_DATA) / 12;
%END;
%ELSE %DO; 
	KUUKTULO = KUUKTULO_DATA;
%END;

* Muokataan tulo perusomavastuun laskentaa varten  ;

%TuloMuokkaus&F(MUOKTULO, &LVUOSI, &INF, YKSH, HENKIL, 0, KUUKTULO);

* Lasketaan perusomavastuu ;

%Perusomavast&F(OMAVAST, &LVUOSI, &INF, astukikr, HENKIL, MUOKTULO);

* Asumistuki vuokra-asunnoissa ;

IF VUOKRA_AS NE 0 and aslaji NE 5 THEN DO;
	%AsumTukiVuok&F(TUKIVUOK, &LVUOSI, &INF, astukikr, LAMMR, KESKLAMM, 1, HENKIL, 0,
	rakvuosi, halpinta, OMAVAST, maksvuok, (kaytkorv + OMAMAKS + LISAMAKS), (OMALAMM + LISALAMM));
END;

* Asumistuki omistusasunnoissa ;

IF VUOKRA_AS = 0 THEN DO;
	%AsumTukiOm&F(TUKIOM, &LVUOSI, &INF, astukikr, LAMMR, OMAKOTI, KESKLAMM, 1, HENKIL, 0,
	rakvuosi, halpinta, OMAVAST, yhtiovas, (OMAMAKS + LISAMAKS), (OMALAMM + LISALAMM), ASLAIKOR, 0);
END;

* Asumistuki osa-asunnoissa (alivuokralaisasunnoissa) ;

IF aslaji = 5 THEN DO;
	%AsumtukiOsa&F(TUKIOSA, &LVUOSI, &INF, astukikr, HENKIL, 0, OMAVAST, maksvuok, 0);
END;

TUKIVUOK = 12 * TUKIVUOK;
TUKIOM = 12 * TUKIOM;
TUKIOSA = 12 * TUKIOSA;
TUKISUMMA = SUM(TUKIVUOK , TUKIOM , TUKIOSA);

*KEEP knro TUKIVUOK TUKIOM TUKIOSA TUKISUMMA KUUKTULO MUOKTULO OMAVAST;

RUN;



* Siirretään samansuuruinen asumistuki kaikille saman talouden henkilöille ;

PROC SQL;
CREATE TABLE OUTPUT.&TULOSNIMI_YA
AS SELECT a.hnro, a.knro, b.TUKIVUOK, b.TUKIOM, b.TUKIOSA, b.TUKISUMMA, b.KUUKTULO, b.MUOKTULO, b.OMAVAST
FROM POHJADAT.&AINEISTO&AVUOSI AS a 
LEFT JOIN OUTPUT.&TULOSNIMI_YA AS b ON a.knro = b.knro
ORDER BY knro, hnro;
QUIT;

/* 6.2 Yhdistetään simuloitu data palveluaineistoon (riippuen tulosaineiston laajuden valinnasta) */

DATA OUTPUT.&TULOSNIMI_YA;
	
/* 6.2.1 Suppea tulostiedosto (vain tärkeimmät luokittelumuuttujat) */

%IF &TULOSLAAJ = 1 %THEN %DO; 
	MERGE POHJADAT.&AINEISTO&AVUOSI 
	(KEEP = hnro knro asko &PAINO hastuki ikavuV desmod paasoss elivtu koulas rake)
	OUTPUT.&TULOSNIMI_YA;
%END;

/* 6.2.2 Laaja tulostiedosto (palveluaineiston mukainen tulostiedosto) */

%IF &TULOSLAAJ = 2 %THEN %DO; 
	MERGE POHJADAT.&AINEISTO&AVUOSI OUTPUT.&TULOSNIMI_YA;
%END;

BY hnro;

* Poistetaan simuloitu asumistuki muilta, kuin talouden viitehenkilöltä ;

IF asko NE 1 THEN DO;
	KUUKTULO = .;
	MUOKTULO = .;
	OMAVAST = .;
	TUKIVUOK = 0;
	TUKIOM = 0;
	TUKIOSA = 0;
	TUKISUMMA = 0;
END;

* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukumäärät voidaan laskea suoraan ;

ARRAY PISTE 
TUKIVUOK TUKIOM TUKIOSA TUKISUMMA hastuki;
DO OVER PISTE;
	IF PISTE <= 0 THEN PISTE = .;
END;

* Luodaan simuloiduille ja datan muuttujille selitteet ;

LABEL 

KUUKTULO = 'Ruokakunnan huomioon otettavat tulot (e/kk), MALLI'
MUOKTULO = 'Perusomavastuun määrittelyssä tarvittava tulo (e/kk), MALLI'
OMAVAST = 'Perusomavastuu (e/kk), MALLI'
TUKIVUOK = 'Asumistuki vuokra-asunnoissa, MALLI'
TUKIOM = 'Asumistuki omistusasunnoissa, MALLI'
TUKIOSA = 'Asumistuki osa-asunnoissa, MALLI'
TUKISUMMA = 'Yleinen asumistuki yhteensä, MALLI'  
hastuki = 'Yleinen asumistuki yhteensä, DATA'; 

DROP asko;

RUN;

%MEND AsumTuki_Simuloi_Data;

%AsumTuki_Simuloi_Data;

%LET loppui2&malli = %SYSFUNC(TIME());


/* 7. Luodaan summatason tulostaulukot (optio) 
	  HUOM! Yleisessä asumistuessa aina kotitaloustasolla viitehenkilön mukaan */

%MACRO AsumTuki_Tulokset;

%IF &TULOKSET = 1 %THEN %DO;

	/* Siirretään tiedot Exceliin (optio) */

	%IF &EXCEL = 1 %THEN %DO;

		ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_YA._SUMMAT.xls" STYLE = MINIMAL;

	%END;

	PROC MEANS DATA=OUTPUT.&TULOSNIMI_YA &SUMWGT &SUM &MIN &MAX &RANGE &MEAN &MEDIAN &MODE &STD &VAR &CV NONOBS ORDER=DATA NWAY MAXDEC = 0; 
	TITLE "TUNNUSLUVUT (KOTITALOUSTASO), &MALLI";
	CLASS &LUOK_KOTI1 &LUOK_KOTI2 &LUOK_KOTI3 / MLF PRELOADFMT;
	VAR &MUUTTUJAT ;
	FORMAT _NUMERIC_ tuhat. ;
	%DO I = 1 %TO 3; 
	%IF %LENGTH (&&LUOK_KOTI&I) >0 %THEN %DO;
		FORMAT &&LUOK_KOTI&I &&LUOK_KOTI&I... ;
	%END;%END;
	OUTPUT OUT = OUTPUT.&TULOSNIMI_YA._SUMMAT (DROP = _TYPE_ _FREQ_)
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

%MEND AsumTuki_Tulokset;

%AsumTuki_Tulokset;


/* 8. Mitataan kuinka kauan osavaiheisiin kului aikaa */

%LET loppui1 = %SYSFUNC(TIME());

%LET loppui1&malli = %SYSFUNC(TIME());

%LET kului1&malli = %SYSEVALF(&&loppui1&malli - &&alkoi1&malli);

%LET kului2&malli = %SYSEVALF(&&loppui2&malli - &&alkoi2&malli);

%LET kului1&malli = %SYSFUNC(PUTN(&&kului1&malli, time10.2));

%LET kului2&malli = %SYSFUNC(PUTN(&&kului2&malli, time10.2));


%PUT &malli. Koko laskenta. Aikaa kului (hh:mm:ss.00) &&kului1&malli;

%PUT &malli. Varsinainen simulointi. Aikaa kului (hh:mm:ss.00) &&kului2&malli;



