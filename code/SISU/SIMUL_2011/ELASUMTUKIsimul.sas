/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyödyntää Tilastokeskuksen yleisten
* käyttöehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto päähakemistossa.
******************************************************************************/

/***********************************************************
* Kuvaus: Eläkkeensaajan asumistuen simulointimalli 2011   *
* Tekijä: Petri Eskelinen / KELA		                   *
* Luotu: 30.11.2011			       					   	   *
* Viimeksi päivitetty: 7.5.2013		     		       	   *
* Päivittäjä: Olli Kannas / TK	     	   		   		   *
************************************************************/ 

/* 1. Mallia ohjaavat makromuuttujat */

%LET START = &OUT;

%LET MALLI = ELASUMTUKI;

%LET TYYPPI = SIMUL;

%LET alkoi1&MALLI = %SYSFUNC(TIME());


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

	%LET TULOSNIMI_EA = elasum_simul_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;

	/* Simuloidaanko eläkkeensaajien asumistuki myös ns. ei-ydinperhe-eläkeläisille.
  	   Jos eläkkeensaajien asumistukea ei simuloida ei-ydinperhe-eläkeläisille, tämä on 0.
       Jos eläkkeensaajien asumistukea simuloidaan ei-ydinperhe-eläkeläisille, tämä on 1. */

	%LET YDINP = 1;

	* Inflaatiokorjaus. Parametrien deflatoinnissa käytettävän kertoimen voi syöttää itse
	  INF-makromuuttujaan (HUOM! desimaalit erotettava pisteellä .). Jos puolestaan haluaa käyttää automaattista 
	  elinkustannusindeksiin perustuvaa parametrien muunnoskerrointa, 
	  tulee INF-makromuuttujalle antaa arvoksi 999 ; 	

	%LET INF = 1.00; * Syötä arvo tai 999 ;	
	%LET PINDEKSI_VUOSI = pindeksi_vuosi; *Käytettävä indeksien parametritaulukko;		

	* Ajettavat osavaiheet ; 

	%LET LAKIMAKROT = 1;    * Lakimakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
	%LET LAKIMAK_TIED_EA = ELASUMTUKIlakimakrot;	* Lakimakroissa käytettävän tiedoston nimi ;
	%LET APUMAKROT = 1;   	* Apumakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
	%LET APUMAK_TIED_EA = ELASUMTUKIapumakrot; * Apumakroissa käytettävän tiedoston nimi ;
	%LET POIMINTA = 1;  	* Muuttujien poiminta (1 jos ajetaan, 0 jos ei);
	%LET TULOKSET = 1;		* Yhteenvetotaulukot (1 jos ajetaan, 0 jos ei);

	%LET PELASUMTUKI = pelasumtuki; * Käytettävän parametritiedoston nimi ;

	* Tulostaulukoiden esivalinnat ; 

	%LET TULOSLAAJ = 1 ; 	 * Mikrotason tulosaineiston laajuus (1 = suppea, 2 = laaja (palveluaineisto)) ;
	%LET MUUTTUJAT = aemkm ELAKASUMTUKI; * Taulukoitavat muuttujat (summataulukot) ;
	%LET YKSIKKO = 1;		 * Tulostaulukoiden yksikkö (1 = henkilö, 2 = kotitalous) ;
	%LET LUOK_HLO1 = desmod; * Taulukoinnin 1. henkilöluokitus (jos YKSIKKO = 1)
							   Vaihtoehtoina: 
							     desmod (tulodesiilit, ekvivalentit tulot (modoecd), hlöpainot)
							     ikavu (ikäryhmät)
							     elivtu (kotitalouden elinvaihe)
							     koulas (koulutusaste TK1997)
							     soss (henkilön sosioekonominen asema AML2001)
							     rake (kotitalouden rakenne) ;
	%LET LUOK_HLO2 = ;		 * Taulukoinnin 2. henkilöluokitus ;
	%LET LUOK_HLO3 = ;		 * Taulukoinnin 3. henkilöluokitus ;

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

	%LET EXCEL = 0; 		 * Viedäänkö tulostaulukko automaattisesti Exceliin (1 = Kyllä, 0 = Ei) ;

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
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_EA..sas";
%END;

/* Ajetaan apumakrot ja tallennetaan ne (optio) */

%IF &APUMAKROT = 1 %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&APUMAK_TIED_EA..sas";
%END;

%MEND TeeMakrot;

%TeeMakrot;


/* 3. Datan poiminta ja apumuuttujien luominen (optio) */

%MACRO ElAsumTuki_Muut_Poiminta;

%IF &POIMINTA = 1 %THEN %DO;

	/* 3.1 Määritellään tarvittavat palveluaineiston muuttujat taulukkoon START_ELASUMTUKI */

	/* Rajaukset:
		- 65 vuotta täyttäneitä
		- yli 15-vuotiaita
		- ei lapseneläkettä (hlake)
		- tai saa kansaneläkettä (kelkan), leskenelättä (hleto tai hlepe), ansioeläkettä (helakyht), veronanalaista eläkettä (lelake) tai
		  maahanmuuttajien erityistukea (mamutuki) tai pitkäaikaistyöttömien eläketukea (etmk, etmm) (Ei 2010)
    	- ei saa opintotuten asumislisää (hasuli)
		- ei saa osa-aikaeläkettä (velaji = 6), varhennettu vanhuuseläkettä (velaji = 7) tai kuntoutustukea (tklaji = 9);
		- ei saa vanhuuseläkettä alle 65 vuoden iässä */

	DATA STARTDAT.START_ELASUMTUKI 
	(KEEP = hnro knro asko ikavu ikakk
	ikakk omalaji kelkan hlepe hleto hlake helakyht 
	lelake tylaji tklaji kelastu hleas elak hrelake pera paos hasuli velaji mamutuki 
	tuntelpe hrelake htperhe tulkel
	elak paos halpinta rakvuosi aslaji eastukikr 
	KELTUN VARVANH LESKEL ELAKK LAMMRY VIITEH EI_VIITEH KOODI); 
	SET POHJADAT.&AINEISTO&AVUOSI;
	WHERE (

	/* Lapset ja lapseneläkkeen saajat suljetaan pois */

	((ikavu > 15) AND (hlake <= 0)) 

	/* Valitaan erilaisten eläkkeiden saajia tai 65 vuotta täyttäneitä */

	AND (
	((ikavu >= 65) OR (kelkan > 0) OR (hlepe > 0) OR (hleto > 0) OR (helakyht > 0) OR (lelake > 0) OR (kelastu > 0)
		OR (hleas > 0) OR (aemkm > 0) OR (mamutuki > 0) OR (tulkel > 0))

	/* Suljetaan pois varhaiseläkkeiden saajia (6 = osa-aikaeläke, 7 on varhennettu vanhuuseläke */
		
	AND ((velaji <> 6) AND (velaji <> 7) AND (tklaji <> 9) AND NOT(velaji = 1 AND ikavu < 65))

	/* Suljetaan muita mahdollisia varhaiseläketapauksia pois */

	AND NOT((ikavu < 65) AND (velaji = 0) AND (tklaji = 99) AND (tylaji = 0) AND (kelkan = 0) AND SUM(hlepe, hleto, hleas, hrelake,  htperhe) = 0 AND SUM(helakyht, lelake) > 0)
	
	AND NOT (((omalaji = 2) OR (omalaji = 9)) AND (ikavu < 65))
	
	/* Suljetaan pois opintotuen asumislisän saajat */

	AND (hasuli <= 0)));

	/* Eläkekuukaudet */

	ELAKK = MAX(elak - paos, 0);

	/* Varhennetun vanhuuseläkkeen saaja */

	VARVANH = ((omalaji = 2) AND (ikavu < 65));

	/* Leskeneläkkeen saaja */

	LESKEL = (SUM(hlepe + hleto) > 0);

	/* Lämmitysryhmä */
	
	LAMMRY = vlamm;

	/* Erotellaan tukeen oikeutetut sen mukaan, ovatko he
	   viitehenkilöitä tai viitehenkilön puolisoita tai ei kumpikaan;
	   Viitehenkilöille ja viitehenkilöiden puolisoille
	   otetaan laskelmassa myöhemmin huomioon kotitalouden
	   alle 18-vuotiaat lapset */

	IF asko = 1 OR asko = 2 THEN VIITEH = 1;

	ELSE VIITEH = 0;

	IF asko > 2 THEN EI_VIITEH = 1;

	ELSE EI_VIITEH = 0;

	KELTUN = INPUT(tluokke, 1.0);

	/* Myöhemmissä taulukoissa eläkkeensaajien asumistukeen oikeutetut tunnistetaan tämän muuttujan KOODI avulla */

	KOODI = 1;

	LABEL 
	ELAKK = 'Eläkekuukaudet, DATA'
	VARVANH = 'Varhennetun vanhuuseläkkeen saaja (0/1), DATA'
	LESKEL = 'Leskeneläkkeen saaja (0/1), DATA'
	LAMMRY = 'Lämmitysryhmä (1,2,3), DATA'
	VIITEH = 'Viitehenkilö tai viitehenkilön puoliso (0/1), DATA'
	EI_VIITEH = 'Ei viitehenkilö eikä viitehenkilön puoliso (0/1), DATA'
	KOODI = 'Eläkkeensaajien asumistukeen oikeutettu (0/1), DATA'
	KELTUN = 'Perhesuhde (1=Yksinasuva, 2=Puolisot), DATA';

	RUN;

	/* 3.2 Luodaan tulostaulukon runko poimimalla hnro-muuttujat edell. taulukosta.*/

	DATA TEMP.ELASUMTUKI_TULOS (KEEP = hnro knro);
	SET STARTDAT.START_ELASUMTUKI;
	RUN;

	/* 3.3.Tehdään taulukko kotitalouksista. Ensin erotellaan kotitalouksien numerot */

	PROC SUMMARY DATA = STARTDAT.START_ELASUMTUKI N NOPRINT;
	BY knro;
	OUTPUT OUT = TEMP.ELASUMTUKI_KOTIT (KEEP = knro);
	RUN;

	/* 3.4 Poimitaan kotitalouksien kaikki jäsenet ja heille
	   perustietoja, tietoja tuloista ja asumiskustannuksista */

	DATA STARTDAT.START_ELASUMTUKI_PERHE;
	MERGE TEMP.ELASUMTUKI_KOTIT (IN = A) POHJADAT.&AINEISTO&AVUOSI 
	(KEEP = knro hnro asko ikavu ikakk jasenia hasuli halpinta
	maksvuok kaytkorv hoitvast yhtiovas lisalamm lisamaks omalamm omamaks 
	aslaikor tontvuok svatva svatvp opirake opirake lelake hlepe hleto kokorve
	tnoosvvb teinovab tuosvvap topkvvap teinovv teinovvb opirako opirake
	tpyspu1 thanpu1);
	BY knro;
	IF A;
	RUN;

	/* 3.5 Yhdistetään edellä luotuun taulukkoon myös ensin luodun taulukon tiedot */

    DATA STARTDAT.START_ELASUMTUKI_PERHE 
	(DROP = ikakk IRAJA TMP);
	MERGE STARTDAT.START_ELASUMTUKI_PERHE (IN = A) STARTDAT.START_ELASUMTUKI;
	BY hnro;
	IF A;
	/* Lapsen ikäraja 18 v vuodesta 2008 lähtien ja 16 v sitä ennen */
	IF &LVUOSI < 2008 THEN IRAJA = 12 * 16;
	ELSE IRAJA = 12 * 18;
	TMP = 12 * ikavu + ikakk;
	LAPSIKK = 0;
	IF asko = 3 THEN DO;
		IF TMP LT 12 THEN LAPSIKK = TMP;
		ELSE DO;
			IF TMP LE IRAJA THEN LAPSIKK = 12;
			ELSE LAPSIKK = MAX(0, IRAJA - TMP + 12);
		END;
	END;

	/* Eritellään viitehenkilöt ja heidän puolistot sen mukaan, ovatko he oikeutettuja eläkkeensaajien asumistukeen,
	   saavatko he KEL:n mukaista varhennettua vanhuuseläkettä tai leskeneläkettä 
	   Riittävä ikä rinnastetaan eläkkeen saamiseen */

	IF asko = 1 OR asko = 2 THEN DO;
		MAHD_PUOLISO = 1;
		IF asko = 1 THEN SAA_ELAK1 = KOODI;
		IF asko = 2 THEN SAA_ELAK2 = KOODI;
		IF asko = 1  THEN VARVANH1 = ((omalaji = 2) AND (ikavu < 65));
		IF asko = 2  THEN VARVANH2 = ((omalaji = 2) AND (ikavu < 65));
		IF asko = 1  THEN LESKEL1 = (SUM(hlepe, hleto) > 0);
		IF asko = 2  THEN LESKEL2 = (SUM(hlepe, hleto) > 0);
	END;
	ELSE DO;
		MAHD_PUOLISO = 0;
		SAA_ELAK1 = 0;
		SAA_ELAK2 = 0;
		VARVANH1 = 0;
		VARVANH2 = 0;
		LESKEL1 = 0;
		LESKEL2 = 0;
	END;

    /* Luokitellaan tulot toisaalta viitehenkilöiden ja viitehenkilön puolison ja toisaalta ja ei-viitehenkilön tuloihin;
	   Veronalaisten tulojen ohella otetaan huomioon verottomat osinkotulot ja lähdeveronalaiset korkotulot; opintorahat vähennetään
	   Lisäksi verottomat metsätulot*/

	VERONAL_VIITEH_DATA = IFN (VIITEH = 1 OR asko < 3, SUM(svatva, svatvp), 0);
	VERONAL_EIVIITEH_DATA = IFN (EI_VIITEH = 1 AND KOODI = 1 AND asko > 2, SUM(svatva, svatvp), 0);
	VEROT_OSINGOT_VIITEH_DATA = IFN(VIITEH = 1 OR asko < 3, SUM(tnoosvvb, teinovvb, tuosvvap, topkvvap, teinovv), 0);
	VEROT_OSINGOT_EIVIITEH_DATA = IFN (EI_VIITEH = 1 AND KOODI = 1 AND asko > 2, SUM(tnoosvvb, teinovvb, tuosvvap, topkvvap, teinovv), 0);
	VEROT_METSA_VIITEH_DATA = IFN(VIITEH = 1 OR asko < 3, 0.25 * SUM(tpyspu1, thanpu1), 0);
	VEROT_METSA_EIVIITEH_DATA = IFN(EI_VIITEH = 1 AND KOODI = 1 AND asko > 2, 0.25 * SUM(tpyspu1, thanpu1), 0);
	KOROT_VIITEH = IFN (VIITEH = 1 OR asko < 3, kokorve, 0);
	KOROT_EIVIITEH = IFN (EI_VIITEH = 0 AND KOODI = 1 AND asko > 2, kokorve, 0);
	OPTUKI_VIITEH_DATA = IFN(VIITEH = 1  AND asko < 3, SUM(opirake, opirako), 0);
	OPTUKI_EIVIITEH_DATA = IFN(EI_VIITEH = 1 AND KOODI = 1 AND asko > 2, SUM(opirake, opirako), 0);
	KAIKKI_TULOT_VIITEH_DATA  = MAX(SUM(VERONAL_VIITEH_DATA, VEROT_OSINGOT_VIITEH_DATA, KOROT_VIITEH, -OPTUKI_VIITEH_DATA, VEROT_METSA_VIITEH_DATA), 0);
	KAIKKI_TULOT_EIVIITEH_DATA  = MAX(SUM(VERONAL_EIVIITEH_DATA, VEROT_OSINGOT_EIVIITEH_DATA, KOROT_EIVIITEH, -OPTUKI_EIVIITEH_DATA, VEROT_METSA_EIVIITEH_DATA), 0);

	/* Asumiskulut kuukautta kohden */

	lisalamm = lisalamm / 12;
	lisamaks = lisamaks / 12;
	omalamm = omalamm / 12;
	omamaks = omamaks / 12;
	aslaikor = aslaikor / 12;
	tontvuok = tontvuok / 12;

	LABEL

	LAPSIKK = 'Ikärajan alittavat lapsikuukaudet kalenerivuoden aikana, DATA'
	MAHD_PUOLISO = 'Mahdollinen puoliso (0/1), DATA'
	SAA_ELAK1 = 'Viitehenkilö saa eläkettä (0/1), DATA'
	SAA_ELAK2 = 'Viitehenkilön puoliso saa eläkettä (0/1), DATA'
	VARVANH1 = 'Viitehenkilö saa varhennettu vanhuuseläkettä (0/1), DATA'
	VARVANH2 = 'Viitehenkilön puoliso saa varhennettu vanhuuseläkettä (0/1), DATA'
	LESKEL1 = 'Viitehenkilö saa leskeneläkettä (0/1), DATA'
	LESKEL2 = 'Viitehenkilön puoliso saa leskeneläkettä (0/1), DATA'
	VERONAL_VIITEH_DATA = 'Viitehenkilön tai viitehenkilön puolison veronalaiset tulot (e/v), DATA'
	VERONAL_EIVIITEH_DATA = 'Muun henkilön veronalaiset tulot (e/v), DATA'
	VEROT_OSINGOT_VIITEH_DATA = 'Viitehenkilön tai viitehenkilön puolison verottomat osinkotulot (e/v), DATA'
	VEROT_OSINGOT_EIVIITEH_DATA = 'Muun henkilön verottomat osinkotulot (e/v), DATA'
	VEROT_METSA_VIITEH_DATA = 'Viitehenkilön tai viitehenkilön puolison verottomat metsätulot, (e/v), DATA'
	VEROT_METSA_EIVIITEH_DATA = 'Muun henkilön verottomat metsätulot, (e/v), DATA'
	KOROT_VIITEH = 'Viitehenkilön tai viitehenkilön puolison korkotulot (e/v), DATA'
	KOROT_EIVIITEH = 'Muun henkilön korkotulot (e/v), DATA'
	OPTUKI_VIITEH_DATA =  'Viitehenkilön tai viitehenkilön puolison opintotuki (e/v), DATA'
	OPTUKI_EIVIITEH_DATA = 'Muun henkilön opintotuki (e/v), DATA'
	KAIKKI_TULOT_VIITEH_DATA  = 'Viitehenkilön tai viitehenkilön puolison kaikki tulot (e/v), DATA'
	KAIKKI_TULOT_EIVIITEH_DATA  =  'Muun henkilön kaikki tulot (e/v), DATA';
	
	RUN;

    /* 3.6 Edellä luodun taulukon tietojen summaus kotitalouksittain */
	
	PROC SUMMARY DATA = STARTDAT.START_ELASUMTUKI_PERHE NWAY NOPRINT;
	BY knro;
	VAR VIITEH EI_VIITEH jasenia LAPSIKK MAHD_PUOLISO
	SAA_ELAK1 SAA_ELAK2 VARVANH1 VARVANH2 LESKEL1 LESKEL2 elak
	KAIKKI_TULOT_VIITEH_DATA
	KAIKKI_TULOT_EIVIITEH_DATA 
	maksvuok kaytkorv hoitvast yhtiovas lisalamm lisamaks
	omalamm omamaks aslaikor;
	OUTPUT OUT = STARTDAT.START_ELASUM_KOTIT (DROP = _type_ _freq_)
	MAX(VIITEH) = VIITEH
	SUM(keltun) = KELTUN
	MAX(EI_VIITEH) = EI_VIITEH
	MEAN(jasenia) = jasenia
	SUM(LAPSIKK) = LAPSIKK
	SUM(MAHD_PUOLISO) = MAHD_PUOLISO
	SUM(SAA_ELAK1) = SAA_ELAK1
	SUM(SAA_ELAK2) = SAA_ELAK2
	SUM(VARVANH1) = VARVANH1
	SUM(VARVANH2) = VARVANH2
	SUM(LESKEL1) = LESKEL1
	SUM(LESKEL2) = LESKEL2
	MEAN(elak) = elak
	SUM(KAIKKI_TULOT_VIITEH_DATA) = KAIKKI_TULOT_VIITEH_DATA
	SUM(KAIKKI_TULOT_EIVIITEH_DATA) = KAIKKI_TULOT_EIVIITEH_DATA
	MAX(halpinta) = halpinta
	MAX(maksvuok) = maksvuok
	MAX(tontvuok) = tontvuok
	MAX(kaytkorv) = kaytkorv
	MAX(hoitvast) = hoitvast
	MAX(yhtiovas) = yhtiovas
	MAX(lisalamm) = lisalamm
	MAX(lisamaks) = lisamaks
	MAX(omalamm) = omalamm
	MAX(omamaks) = omamaks
	SUM(aslaikor) = aslaikor;
	RUN;

	/* 3.7 Erotellaan luodusta kotitaloustaulukosta ne tapaukset,
	   joissa asumistukeen oikeutettu ei ole viitehenkilö tai viitehenkilön puoliso */

	DATA STARTDAT.START_ELASUM_KOTIT_EI_YDINP;
	SET STARTDAT.START_ELASUM_KOTIT;
	IF EI_VIITEH = 1;

	/* Jyvitetään henkilölle osuus asumiskustannuksista */

	OSUUS = MIN(100, 100 / jasenia);

	/* Asumiskustannukset */
   
	halpinta = OSUUS * halpinta / 100;
	maksvuok = OSUUS * maksvuok / 100;
	hoitvast = OSUUS * hoitvast / 100;
	yhtiovas = OSUUS * yhtiovas /100;
	lisalamm = OSUUS * lisalamm / 100;
	omalamm = OSUUS * omalamm / 100;
	lisamaks = OSUUS * lisamaks / 100;
	tontvuok = OSUUS * tontvuok / 100;
	kaytkorv = OSUUS * kaytkorv / 100;
	aslaikor = OSUUS * aslaikor/ 100;

	LABEL
	OSUUS = 'Henkilön %-osuus ruokakunnasta, DATA';

	RUN;

	/* 3.8 Erotellaan luodusta kotitaloustaulukosta ne tapaukset,
	  joissa asumistukeen oikeutettu on viitehenkilö tai viitehenkilön puoliso */
	
	
	DATA STARTDAT.START_ELASUM_KOTIT_YDINP ;
	SET STARTDAT.START_ELASUM_KOTIT;

	IF VIITEH = 1;

	/* Päätellään, onko kyse puolisoista */
		
	IF (MAHD_PUOLISO = 2) OR (KELTUN = 4) THEN PUOLISOT = 1;
	ELSE PUOLISOT = 0;

	/* Lasten lukumäärä ja eläkeläisperheen koko */

	LKM = ROUND(LAPSIKK / 12, 1);
	LPERHE = LKM + 1;
	IF PUOLISOT THEN LPERHE = LPERHE + 1;

	DROP LAPSIKK;

	/* Eläkeläisperheen osuus koko ruokakunnasta */

	OSUUS = MIN(100, 100 * LPERHE / jasenia);

	/* Asumiskustannukset */

	halpinta = OSUUS * halpinta / 100;
	maksvuok = OSUUS * maksvuok / 100;
	hoitvast = OSUUS * hoitvast / 100;
	yhtiovas = OSUUS * yhtiovas /100;
	lisalamm = OSUUS * lisalamm / 100;
	omalamm = OSUUS * omalamm / 100;
	lisamaks = OSUUS * lisamaks / 100;
	kaytkorv = OSUUS * kaytkorv / 100;
	aslaikor = OSUUS * aslaikor /100;

	LABEL
	LKM = 'Lasten lukumäärä, DATA'
	LPERHE = 'Eläkeläisperheen koko, DATA'
	PUOLISOT = 'Onko kyse puolisoista (0/1), DATA'
	OSUUS = 'Eläkeläisperheen %-osuus koko ruokakunnasta, DATA';
	
	RUN;

	/* 3.9 Erotetaan alkuperäisestä taulukosta ne eläkeläiset, jotka eivät ole kotitalouden
	viitehenkilöitä tai viitehenkilön puolisoita */

	DATA STARTDAT.START_ELASUMTUKI_EI_YDINP;
	SET STARTDAT.START_ELASUMTUKI;
	IF asko > 2;
	RUN;

	/* 3.10 Rajoitetaan alkuperäinen taulukko viitehenkilöihin ja viitehenkilön puolisoihin */

	DATA STARTDAT.START_ELASUMTUKI;
	SET STARTDAT.START_ELASUMTUKI;
	IF asko = 1 OR asko = 2;
	RUN;

	/* 3.11 Yhdistetään kotitaloustason tiedot em. taulukoihin;
	   Ensin viitehenkilöt ja viitehenkilön puolisot */

	DATA STARTDAT.START_ELASUMTUKI;
	MERGE STARTDAT.START_ELASUMTUKI(IN = A) STARTDAT.START_ELASUM_KOTIT_YDINP;
	BY knro;
	IF A;

	/* Saako jompi kumpi puoliso KEL:n mukaista varhennettua vanhuuseläkettä */
	/* Mahdollisuus, että molemmat saavat, pitäisi olla pois rajattu. */

	IF PUOLISOT = 1 AND SUM(VARVANH1, VARVANH2) = 1 THEN VARVANH = 1;
	ELSE VARVANH = 0;

	/* Selvitetään, ovatko kummatkin puolisot oikeutettuja asumistukeen */
	/* Jos toinen puoliso ei ole, mutta saa varhennettua vanhuuseläkettä, sekin riittää */
	
	IF SUM(SAA_ELAK1, SAA_ELAK2) = 2 OR VARVANH = 1 THEN KUMPIKIN = 1;
	ELSE KUMPIKIN = 0;

	/* Onko kyse leskeneläkkeen saajista */

	IF SUM(LESKEL1, LESKEL2) > 0 THEN LESKEL = 1;
	ELSE LESKEL = 0;

	LABEL
	KUMPIKIN ='Ovatko kummatkin puolisot oikeutettuja asumistukeen (0/1), DATA';

	RUN;

	/* 3.12 Tapaukset, joissa asumistukeen oikeutettu ei ole viitehenkilö tai viitehenkilön puoliso */

	DATA STARTDAT.START_ELASUMTUKI_EI_YDINP;
	MERGE STARTDAT.START_ELASUMTUKI_EI_YDINP (IN = A DROP = halpinta) STARTDAT.START_ELASUM_KOTIT_EI_YDINP (KEEP = knro halpinta  maksvuok hoitvast yhtiovas lisalamm
	omalamm lisamaks tontvuok kaytkorv aslaikor); 
	BY knro;
	IF A;
	RUN;

	/* 3.13 Yhdistetään tulotietoja edellä luotuun taulukkoon */

	DATA STARTDAT.START_ELASUMTUKI_EI_YDINP;
	MERGE STARTDAT.START_ELASUMTUKI_EI_YDINP (IN = A) STARTDAT.START_ELASUMTUKI_PERHE (KEEP = hnro knro svatva svatvp hlepe kokorve tnoosvvb teinovab tuosvvap topkvvap teinovv teinovvb opirake opirako
    tpyspu1 thanpu1);
	BY hnro;
	IF A;
	VERONAL_EIVIITEH_DATA = SUM(svatva, svatvp);
	VEROT_OSINGOT_EIVIITEH_DATA = SUM(tnoosvvb, teinovvb, tuosvvap, topkvvap, teinovv);
	KOROT_EIVIITEH = kokorve;
	OPTUKI_EIVIITEH_DATA = SUM(opirake, opirako);
	VEROT_METSA_EIVIITEH_DATA = IFN(EI_VIITEH = 1 AND KOODI = 1 AND asko > 2, 0.25 * SUM(tpyspu1, thanpu1), 0);
	KAIKKI_TULOT_EIVIITEH_DATA  = MAX(SUM(VERONAL_EIVIITEH_DATA, VEROT_OSINGOT_EIVIITEH_DATA, KOROT_EIVIITEH, -OPTUKI_EIVIITEH_DATA, VEROT_METSA_EIVIITEH_DATA), 0);

	LABEL
	VERONAL_EIVIITEH_DATA = 'Muun henkilön veronalaiset tulot (e/v), DATA'
	VEROT_OSINGOT_EIVIITEH_DATA = 'Muun henkilön verottomat osinkotulot (e/v), DATA'
    VEROT_METSA_EIVIITEH_DATA = 'Muun henkilön verottomat metsätulot, arvio, (e/v), DATA'
	KOROT_EIVIITEH = 'Muun henkilön korkotulot (e/v), DATA'
	OPTUKI_EIVIITEH_DATA = 'Muun henkilön opintotuki (e/v), DATA'
	KAIKKI_TULOT_EIVIITEH_DATA  =  'Muun henkilön kaikki tulot (e/v), DATA';

	RUN;

%END;

%MEND ElAsumTuki_Muut_Poiminta;

%ElAsumTuki_Muut_Poiminta;

%LET alkoi2&malli = %SYSFUNC(TIME());

/* 4. Makro hakee tietoja VERO-mallista ja liittää ne mallin dataan */

%MACRO OsaMallit_ElAsumTuki;

*Jos veronalaisia tulonsiirtoja tai veroja on simuloitu, haetaan
veronalaiset tulot ja verottomat osinkotulot VERO-mallista;

%IF &SAIRVAK = 1 OR &TTURVA = 1 OR &KANSEL = 1 OR &KOTIHTUKI = 1 OR  &OPINTUKI = 1 OR &VERO = 1 %THEN %DO;

	/* 4.1. Haetaan tiedot START_ELASUMTUKI_PERHE_taulukkoon */

	DATA STARTDAT.START_ELASUMTUKI_PERHE;
	MERGE STARTDAT.START_ELASUMTUKI_PERHE (IN = A) 
	OUTPUT.&TULOSNIMI_VE (KEEP = hnro ANSIOT POTULOT OSINKOVAP OPTUKI_SIMUL);
	IF A;
	BY hnro;
	VERONAL_VIITEH_MALLI = IFN (VIITEH = 1 OR asko < 3, SUM(ANSIOT, POTULOT), 0);
	VERONAL_EIVIITEH_MALLI = IFN (EI_VIITEH = 1 AND KOODI = 1 AND asko > 2, SUM(ANSIOT, POTULOT), 0);
	VEROT_OSINGOT_VIITEH_MALLI = IFN(VIITEH = 1 OR asko < 3, OSINKOVAP, 0);
	VEROT_OSINGOT_EIVIITEH_MALLI = IFN (EI_VIITEH = 1 AND KOODI = 1 AND asko > 2, OSINKOVAP, 0);
	OPTUKI_VIITEH_MALLI = IFN(VIITEH = 1  AND asko < 3, OPTUKI_SIMUL, 0);
	OPTUKI_EIVIITEH_MALLI = IFN(EI_VIITEH = 1 AND KOODI = 1 AND asko > 2, OPTUKI_SIMUL, 0);
	KAIKKI_TULOT_VIITEH_MALLI  = MAX(SUM(VERONAL_VIITEH_MALLI, VEROT_OSINGOT_VIITEH_MALLI, KOROT_VIITEH, -OPTUKI_VIITEH_MALLI, VEROT_METSA_VIITEH_DATA ), 0);
	KAIKKI_TULOT_EIVIITEH_MALLI  = MAX(SUM(VERONAL_EIVIITEH_MALLI, VEROT_OSINGOT_EIVIITEH_MALLI, KOROT_EIVIITEH, -OPTUKI_EIVIITEH_MALLI, VEROT_METSA_EIVIITEH_DATA), 0);

	LABEL
	VERONAL_VIITEH_MALLI = 'Viitehenkilön tai viitehenkilön puolison veronalaiset tulot (e/v), DATA'
	VERONAL_EIVIITEH_MALLI = 'Muun henkilön veronalaiset tulot (e/v), DATA'
	VEROT_OSINGOT_VIITEH_MALLI = 'Viitehenkilön tai viitehenkilön puolison verottomat osinkotulot (e/v), DATA'
	VEROT_OSINGOT_EIVIITEH_MALLI = 'Muun henkilön verottomat osinkotulot (e/v), DATA'
	OPTUKI_VIITEH_MALLI =  'Viitehenkilön tai viitehenkilön puolison opintotuki (e/v), DATA'
	OPTUKI_EIVIITEH_MALLI = 'Muun henkilön opintotuki (e/v), DATA'
	KAIKKI_TULOT_VIITEH_MALLI  = 'Viitehenkilön tai viitehenkilön puolison kaikki tulot (e/v), DATA'
	KAIKKI_TULOT_EIVIITEH_MALLI  =  'Muun henkilön kaikki tulot (e/v), DATA';

	RUN;

	/* 4.2. Summataan tulot kotitalouksittain */
	
	PROC MEANS DATA = STARTDAT.START_ELASUMTUKI_PERHE NOPRINT;
	VAR VIITEH EI_VIITEH KAIKKI_TULOT_VIITEH_MALLI KAIKKI_TULOT_EIVIITEH_MALLI;
	BY knro;
	OUTPUT OUT = TEMP.ELASUM_SIMULTULOT_KOTIT
	MAX(VIITEH) = VIITEH
	MAX(EI_VIITEH) = EI_VIITEH
	SUM (KAIKKI_TULOT_VIITEH_MALLI) = KAIKKI_TULOT_VIITEH_MALLI
	SUM (KAIKKI_TULOT_EIVIITEH_MALLI) = KAIKKI_TULOT_EIVIITEH_MALLI;
	RUN; 

	/* 4.3. Erotellaan viitehenkilöt ja viitehenkilön puolisot eri taulukkoon... */
	
	DATA TEMP.ELASUM_SIMULTULOT_KOTIT_YDINP;
	SET TEMP.ELASUM_SIMULTULOT_KOTIT;
	IF VIITEH = 1;
	RUN;

	/* 4.4 ...ja muut henkilöt toiseen taulukkoon */
	
	DATA TEMP.ELASUM_SIMULTULOT_KOTIT_EI_YDINP;
	SET TEMP.ELASUM_SIMULTULOT_KOTIT;
	IF EI_VIITEH = 1;
	RUN;

	/* 4.5 Yhdistetään taulukot lähtödataan, ensin viitehenkilöt ja viitehenkilön puolisot */

	DATA STARTDAT.START_ELASUMTUKI;
	MERGE STARTDAT.START_ELASUMTUKI (IN = A) 
	TEMP.ELASUM_SIMULTULOT_KOTIT_YDINP (KEEP = knro KAIKKI_TULOT_VIITEH_MALLI);
	BY knro;
	IF A;
	RUN;

	/* 4.6 Yhdistetään taulukot lähtödataan, muut henkilöt */

	DATA STARTDAT.START_ELASUMTUKI_EI_YDINP;
	MERGE STARTDAT.START_ELASUMTUKI_EI_YDINP (IN = A)  
	TEMP.ELASUM_SIMULTULOT_KOTIT_EI_YDINP (KEEP = knro KAIKKI_TULOT_EIVIITEH_MALLI);
	BY knro;
	IF A;
	RUN;
	
%END;

%MEND Osamallit_ElAsumTuki;

%OsaMallit_ElAsumTuki;


/* 5. ELASUMTUKI-mallissa (vuositason lainsäädäntö) parametrit luetaan makromuuttujiksi ennen simulontia */

%HaeParam_ElAsumTukiSIMUL(&LVUOSI, &INF);


/* 6. Simulointivaihe */

%MACRO ElAsumTuki_Simuloi_Data;

/* 6.1. Viitehenkilöt ja viitehenkilön puolisot */

DATA TEMP.START_ELASUMTUKI;
SET STARTDAT.START_ELASUMTUKI;

%IF &SAIRVAK = 1 OR &TTURVA = 1 OR &KANSEL = 1 OR &OPINTUKI = 1 OR &KOTIHTUKI = 1 OR &VERO = 1 %THEN %DO;
	KAIKKI_TULOT_VIITEH = KAIKKI_TULOT_VIITEH_MALLI;
%END;
%ELSE %DO;
	KAIKKI_TULOT_VIITEH = KAIKKI_TULOT_VIITEH_DATA;
%END;

%ElakAsumTuki&F(TUKI, &LVUOSI, &INF, PUOLISOT, KUMPIKIN, LESKEL, 0, LKM, (aslaji < 3), LAMMRY, 1, 1, 0, (lisalamm > 0),	
	halpinta, rakvuosi, eastukikr, KAIKKI_TULOT_VIITEH, 0, (12 * maksvuok + 12 * kaytkorv + 12 * yhtiovas + 12 * lisamaks), 
	12*aslaikor);

TUKI = elakk * TUKI / 12;
IF KUMPIKIN THEN TUKI = TUKI / 2;

RUN;

/* 6.2. Muut asumistukeen oikeutetut */

DATA TEMP.START_ELASUMTUKI_EI_YDINP (DROP = TUKI);
SET STARTDAT.START_ELASUMTUKI_EI_YDINP;

%IF &SAIRVAK = 1 OR &TTURVA = 1 OR &KANSEL = 1 OR &OPINTUKI = 1 OR &VERO = 1 %THEN %DO;
	KAIKKI_TULOT_EIVIITEH = KAIKKI_TULOT_EIVIITEH_MALLI;
%END;
%ELSE %DO;
	KAIKKI_TULOT_EIVIITEH = KAIKKI_TULOT_EIVIITEH_DATA;
%END;

%ElakAsumTuki&F(TUKI, &LVUOSI, &INF, 0, 0, LESKEL, 0, 0, (aslaji < 3), LAMMRY, 1, 1, 0,
	(lisalamm > 0), halpinta, rakvuosi, eastukikr, KAIKKI_TULOT_EIVIITEH, 0, (12 * maksvuok + 12 * yhtiovas), 12*aslaikor);

TUKI2 = elakk * TUKI / 12;

* Poistetaan eläkkeensaajien asumistuki "ei-ydinperhe-eläkeläisiltä" tarvittaessa ;

IF &YDINP = 0 THEN TUKI2 = 0;

RUN;

/* 6.3 Yhdistetään laskelmien tulokset valmiiseen tulostaulukon runkoon */

DATA OUTPUT.&TULOSNIMI_EA (KEEP = hnro knro KAIKKI_TULOT_VIITEH KAIKKI_TULOT_EIVIITEH TUKI TUKI2 ELAKASUMTUKI);
MERGE TEMP.ELASUMTUKI_TULOS TEMP.START_ELASUMTUKI TEMP.START_ELASUMTUKI_EI_YDINP;
BY hnro;
ELAKASUMTUKI = SUM(TUKI, TUKI2);
RUN;

/* 6.4 Yhdistetään simuloitu data palveluaineistoon (riippuen tulosaineiston laajuden valinnasta) */

DATA OUTPUT.&TULOSNIMI_EA;
	
/* 6.4.1 Suppea tulostiedosto (vain tärkeimmät luokittelumuuttujat) */

%IF &TULOSLAAJ = 1 %THEN %DO; 
	MERGE POHJADAT.&AINEISTO&AVUOSI 
	(KEEP = hnro knro &PAINO aemkm ikavu ikavuV desmod soss paasoss elivtu koulas rake)
	OUTPUT.&TULOSNIMI_EA;
%END;

/* 6.4.2 Laaja tulostiedosto (palveluaineiston mukainen tulostiedosto) */

%IF &TULOSLAAJ = 2 %THEN %DO; 
	MERGE POHJADAT.&AINEISTO&AVUOSI OUTPUT.&TULOSNIMI_EA;
%END;

BY hnro;

* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukumäärät voidaan laskea suoraan ;

ARRAY PISTE 
TUKI TUKI2 aemkm ELAKASUMTUKI;
DO OVER PISTE;
	IF PISTE <= 0 THEN PISTE = .;
END;

* Luodaan simuloiduille ja datan muuttujille selitteet ;

LABEL 
KAIKKI_TULOT_VIITEH = 'Viitehenkilön tai viitehenkilön puolison kaikki tulot (e/v), MALLI'
KAIKKI_TULOT_EIVIITEH = 'Muun henkilön kaikki tulot (e/v), MALLI'
TUKI = 'Eläkkeensaajien asumistuki: viitehenkilöt ja viitehenkilön puolisot, MALLI'
TUKI2 = 'Eläkkeensaajien asumistuki: ei-ydinperhe-eläkeläiset, MALLI'
aemkm = 'Eläkkeensaajien asumistuki, DATA'
ELAKASUMTUKI = 'Eläkkeensaajien asumistuki, MALLI';

RUN;

%MEND ElAsumTuki_Simuloi_Data;

%ElAsumTuki_Simuloi_Data;

%LET loppui2&malli = %SYSFUNC(TIME());


/* 7. Luodaan summatason tulostaulukot (optio) */

%MACRO ElAsumTuki_Tulokset;

/* 7.1 Kotitaloustason tulokset (optio) */

/* 7.1.1 Mikrotason tulosaineiston summaus kotitaloustasolle (optio) */

%IF &YKSIKKO = 2 AND &START NE 1 %THEN %DO; 

	PROC SUMMARY DATA=OUTPUT.&TULOSNIMI_EA (DROP = hnro);
	BY knro ;
	ID &PAINO ikavuV desmod paasoss elivtu koulas rake;
	VAR &MUUTTUJAT _NUMERIC_;
	OUTPUT OUT = OUTPUT.&TULOSNIMI_EA (DROP = ikavu soss _TYPE_ _FREQ_)  SUM = ;
	RUN;

%END;

/* 7.1.2 Summatason tulostaulukko (optio) */

%IF &TULOKSET = 1 %THEN %DO;

	%IF &YKSIKKO = 2 %THEN %DO; 

		/* Siirretään tiedot Exceliin (optio) */

		%IF &EXCEL = 1 %THEN %DO;

			ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_EA._SUMMAT.xls" STYLE = MINIMAL;

		%END;

		PROC MEANS DATA=OUTPUT.&TULOSNIMI_EA &SUMWGT &SUM &MIN &MAX &RANGE &MEAN &MEDIAN &MODE &STD &VAR &CV NONOBS ORDER=DATA NWAY MAXDEC = 0; 
		TITLE "TUNNUSLUVUT (KOTITALOUSTASO), &MALLI";
		CLASS &LUOK_KOTI1 &LUOK_KOTI2 &LUOK_KOTI3 / MLF PRELOADFMT;
		VAR &MUUTTUJAT ;
		FORMAT _NUMERIC_ tuhat. ;
		%DO I = 1 %TO 3; 
		%IF %LENGTH (&&LUOK_KOTI&I) >0 %THEN %DO;
			FORMAT &&LUOK_KOTI&I &&LUOK_KOTI&I... ;
		%END;%END;
		OUTPUT OUT = OUTPUT.&TULOSNIMI_EA._SUMMAT (DROP = _TYPE_ _FREQ_)
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
	
	/* 7.2 Henkilötason tulokset (oletus) */

	%ELSE %DO;

		/* Siirretään tiedot Exceliin (optio) */

		%IF &EXCEL = 1 %THEN %DO;

			ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_EA._SUMMAT.xls" STYLE = MINIMAL;

		%END;

		PROC MEANS DATA=OUTPUT.&TULOSNIMI_EA &SUMWGT &SUM &MIN &MAX &RANGE &MEAN &MEDIAN &MODE &STD &VAR &CV NONOBS ORDER=DATA NWAY MAXDEC = 0;
		TITLE "TUNNUSLUVUT (HENKILÖTASO), &MALLI";
		CLASS &LUOK_HLO1 &LUOK_HLO2 &LUOK_HLO3 / MLF PRELOADFMT;
		VAR &MUUTTUJAT ;
		FORMAT _NUMERIC_ tuhat. ;
		%DO I = 1 %TO 3; 
		%IF %LENGTH (&&LUOK_HLO&I) >0 %THEN %DO;
			FORMAT &&LUOK_HLO&I &&LUOK_HLO&I... ;
		%END;%END;
		OUTPUT OUT = OUTPUT.&TULOSNIMI_EA._SUMMAT (DROP = _TYPE_ _FREQ_)
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

%MEND ElAsumTuki_Tulokset;

%ElAsumTuki_Tulokset;


/* 8. Mitataan kuinka kauan osavaiheisiin kului aikaa */

%LET loppui1 = %SYSFUNC(TIME());

%LET loppui1&malli = %SYSFUNC(TIME());

%LET kului1&malli = %SYSEVALF(&&loppui1&malli - &&alkoi1&malli);

%LET kului2&malli = %SYSEVALF(&&loppui2&malli - &&alkoi2&malli);

%LET kului1&malli = %SYSFUNC(PUTN(&&kului1&malli, time10.2));

%LET kului2&malli = %SYSFUNC(PUTN(&&kului2&malli, time10.2));


%PUT &malli. Koko laskenta. Aikaa kului (hh:mm:ss.00) &&kului1&malli;

%PUT &malli. Varsinainen simulointi. Aikaa kului (hh:mm:ss.00) &&kului2&malli;





