/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hy�dynt�� Tilastokeskuksen yleisten
* k�ytt�ehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto p��hakemistossa.
******************************************************************************/

/***********************************************************
* Kuvaus: El�kkeensaajan asumistuen simulointimalli 2011   *
* Tekij�: Petri Eskelinen / KELA		                   *
* Luotu: 30.11.2011			       					   	   *
* Viimeksi p�ivitetty: 7.5.2013		     		       	   *
* P�ivitt�j�: Olli Kannas / TK	     	   		   		   *
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

	/* Jos mallia k�ytet��n k�ytt�liittym�st� (&EG = 1), niin seuraavia vaiheita ei ajeta */

	%IF &EG NE 1 %THEN %DO;

	%LET AVUOSI = 2010;		* Aineistovuosi (vvvv);

	%LET LVUOSI = 2010;		* Lains��d�nt�vuosi (vvvv);

	%LET AINEISTO = PALV ;  * K�ytett�v� aineisto (PALV = Palveluaineisto, REK = Rekisteriaineisto) ;

	%LET TULOSNIMI_EA = elasum_simul_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;

	/* Simuloidaanko el�kkeensaajien asumistuki my�s ns. ei-ydinperhe-el�kel�isille.
  	   Jos el�kkeensaajien asumistukea ei simuloida ei-ydinperhe-el�kel�isille, t�m� on 0.
       Jos el�kkeensaajien asumistukea simuloidaan ei-ydinperhe-el�kel�isille, t�m� on 1. */

	%LET YDINP = 1;

	* Inflaatiokorjaus. Parametrien deflatoinnissa k�ytett�v�n kertoimen voi sy�tt�� itse
	  INF-makromuuttujaan (HUOM! desimaalit erotettava pisteell� .). Jos puolestaan haluaa k�ytt�� automaattista 
	  elinkustannusindeksiin perustuvaa parametrien muunnoskerrointa, 
	  tulee INF-makromuuttujalle antaa arvoksi 999 ; 	

	%LET INF = 1.00; * Sy�t� arvo tai 999 ;	
	%LET PINDEKSI_VUOSI = pindeksi_vuosi; *K�ytett�v� indeksien parametritaulukko;		

	* Ajettavat osavaiheet ; 

	%LET LAKIMAKROT = 1;    * Lakimakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
	%LET LAKIMAK_TIED_EA = ELASUMTUKIlakimakrot;	* Lakimakroissa k�ytett�v�n tiedoston nimi ;
	%LET APUMAKROT = 1;   	* Apumakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
	%LET APUMAK_TIED_EA = ELASUMTUKIapumakrot; * Apumakroissa k�ytett�v�n tiedoston nimi ;
	%LET POIMINTA = 1;  	* Muuttujien poiminta (1 jos ajetaan, 0 jos ei);
	%LET TULOKSET = 1;		* Yhteenvetotaulukot (1 jos ajetaan, 0 jos ei);

	%LET PELASUMTUKI = pelasumtuki; * K�ytett�v�n parametritiedoston nimi ;

	* Tulostaulukoiden esivalinnat ; 

	%LET TULOSLAAJ = 1 ; 	 * Mikrotason tulosaineiston laajuus (1 = suppea, 2 = laaja (palveluaineisto)) ;
	%LET MUUTTUJAT = aemkm ELAKASUMTUKI; * Taulukoitavat muuttujat (summataulukot) ;
	%LET YKSIKKO = 1;		 * Tulostaulukoiden yksikk� (1 = henkil�, 2 = kotitalous) ;
	%LET LUOK_HLO1 = desmod; * Taulukoinnin 1. henkil�luokitus (jos YKSIKKO = 1)
							   Vaihtoehtoina: 
							     desmod (tulodesiilit, ekvivalentit tulot (modoecd), hl�painot)
							     ikavu (ik�ryhm�t)
							     elivtu (kotitalouden elinvaihe)
							     koulas (koulutusaste TK1997)
							     soss (henkil�n sosioekonominen asema AML2001)
							     rake (kotitalouden rakenne) ;
	%LET LUOK_HLO2 = ;		 * Taulukoinnin 2. henkil�luokitus ;
	%LET LUOK_HLO3 = ;		 * Taulukoinnin 3. henkil�luokitus ;

	%LET LUOK_KOTI1 = desmod; * Taulukoinnin 1. kotitalousluokitus (jos YKSIKKO = 2) 
							    Vaihtoehtoina: 
							     desmod (tulodesiilit, ekvivalentit tulot (modoecd), hl�painot)
							     ikavuV (viitehenkil�n mukaiset ik�ryhm�t)
							     elivtu (kotitalouden elinvaihe)
							     koulas (viitehenkil�n koulutusaste TK1997)
							     paasoss (kotitalouden sosioekonominen asema AML2001)
							     rake (kotitalouden rakenne) ;
	%LET LUOK_KOTI2 = ; 	  * Taulukoinnin 2. kotitalousluokitus ;
	%LET LUOK_KOTI3 = ; 	  * Taulukoinnin 3. kotitalousluokitus ;

	%LET EXCEL = 0; 		 * Vied��nk� tulostaulukko automaattisesti Exceliin (1 = Kyll�, 0 = Ei) ;

	* Laskettavat tunnusluvut (jos tyhj�, niin ei lasketa);

	%LET SUMWGT = SUMWGT; * N eli lukum��r�t ;
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

	%LET PAINO = ykor ; 	* K�ytett�v� painokerroin (jos tyhj�, niin lasketaan painottamattomana) ;
	%LET RAJAUS =  ; 		* Rajauslause tunnuslukujen laskentaan (jos tyhj�, niin ei rajauksia);

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


/* 2. T�ll� makrolla s��dell��n laki- ja apumakro-ohjelmien ajoa. 
	  Jos makrot on jo tallennettu tai otettu k�ytt��n, makro-ohjelmia ei ole pakko ajaa uudestaan. 
	  C-funktioita k�ytett�ess� SASCBTBL-m��ritys on joka tapauksessa pakko tehd�. */

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

	/* 3.1 M��ritell��n tarvittavat palveluaineiston muuttujat taulukkoon START_ELASUMTUKI */

	/* Rajaukset:
		- 65 vuotta t�ytt�neit�
		- yli 15-vuotiaita
		- ei lapsenel�kett� (hlake)
		- tai saa kansanel�kett� (kelkan), leskenel�tt� (hleto tai hlepe), ansioel�kett� (helakyht), veronanalaista el�kett� (lelake) tai
		  maahanmuuttajien erityistukea (mamutuki) tai pitk�aikaisty�tt�mien el�ketukea (etmk, etmm) (Ei 2010)
    	- ei saa opintotuten asumislis�� (hasuli)
		- ei saa osa-aikael�kett� (velaji = 6), varhennettu vanhuusel�kett� (velaji = 7) tai kuntoutustukea (tklaji = 9);
		- ei saa vanhuusel�kett� alle 65 vuoden i�ss� */

	DATA STARTDAT.START_ELASUMTUKI 
	(KEEP = hnro knro asko ikavu ikakk
	ikakk omalaji kelkan hlepe hleto hlake helakyht 
	lelake tylaji tklaji kelastu hleas elak hrelake pera paos hasuli velaji mamutuki 
	tuntelpe hrelake htperhe tulkel
	elak paos halpinta rakvuosi aslaji eastukikr 
	KELTUN VARVANH LESKEL ELAKK LAMMRY VIITEH EI_VIITEH KOODI); 
	SET POHJADAT.&AINEISTO&AVUOSI;
	WHERE (

	/* Lapset ja lapsenel�kkeen saajat suljetaan pois */

	((ikavu > 15) AND (hlake <= 0)) 

	/* Valitaan erilaisten el�kkeiden saajia tai 65 vuotta t�ytt�neit� */

	AND (
	((ikavu >= 65) OR (kelkan > 0) OR (hlepe > 0) OR (hleto > 0) OR (helakyht > 0) OR (lelake > 0) OR (kelastu > 0)
		OR (hleas > 0) OR (aemkm > 0) OR (mamutuki > 0) OR (tulkel > 0))

	/* Suljetaan pois varhaisel�kkeiden saajia (6 = osa-aikael�ke, 7 on varhennettu vanhuusel�ke */
		
	AND ((velaji <> 6) AND (velaji <> 7) AND (tklaji <> 9) AND NOT(velaji = 1 AND ikavu < 65))

	/* Suljetaan muita mahdollisia varhaisel�ketapauksia pois */

	AND NOT((ikavu < 65) AND (velaji = 0) AND (tklaji = 99) AND (tylaji = 0) AND (kelkan = 0) AND SUM(hlepe, hleto, hleas, hrelake,  htperhe) = 0 AND SUM(helakyht, lelake) > 0)
	
	AND NOT (((omalaji = 2) OR (omalaji = 9)) AND (ikavu < 65))
	
	/* Suljetaan pois opintotuen asumislis�n saajat */

	AND (hasuli <= 0)));

	/* El�kekuukaudet */

	ELAKK = MAX(elak - paos, 0);

	/* Varhennetun vanhuusel�kkeen saaja */

	VARVANH = ((omalaji = 2) AND (ikavu < 65));

	/* Leskenel�kkeen saaja */

	LESKEL = (SUM(hlepe + hleto) > 0);

	/* L�mmitysryhm� */
	
	LAMMRY = vlamm;

	/* Erotellaan tukeen oikeutetut sen mukaan, ovatko he
	   viitehenkil�it� tai viitehenkil�n puolisoita tai ei kumpikaan;
	   Viitehenkil�ille ja viitehenkil�iden puolisoille
	   otetaan laskelmassa my�hemmin huomioon kotitalouden
	   alle 18-vuotiaat lapset */

	IF asko = 1 OR asko = 2 THEN VIITEH = 1;

	ELSE VIITEH = 0;

	IF asko > 2 THEN EI_VIITEH = 1;

	ELSE EI_VIITEH = 0;

	KELTUN = INPUT(tluokke, 1.0);

	/* My�hemmiss� taulukoissa el�kkeensaajien asumistukeen oikeutetut tunnistetaan t�m�n muuttujan KOODI avulla */

	KOODI = 1;

	LABEL 
	ELAKK = 'El�kekuukaudet, DATA'
	VARVANH = 'Varhennetun vanhuusel�kkeen saaja (0/1), DATA'
	LESKEL = 'Leskenel�kkeen saaja (0/1), DATA'
	LAMMRY = 'L�mmitysryhm� (1,2,3), DATA'
	VIITEH = 'Viitehenkil� tai viitehenkil�n puoliso (0/1), DATA'
	EI_VIITEH = 'Ei viitehenkil� eik� viitehenkil�n puoliso (0/1), DATA'
	KOODI = 'El�kkeensaajien asumistukeen oikeutettu (0/1), DATA'
	KELTUN = 'Perhesuhde (1=Yksinasuva, 2=Puolisot), DATA';

	RUN;

	/* 3.2 Luodaan tulostaulukon runko poimimalla hnro-muuttujat edell. taulukosta.*/

	DATA TEMP.ELASUMTUKI_TULOS (KEEP = hnro knro);
	SET STARTDAT.START_ELASUMTUKI;
	RUN;

	/* 3.3.Tehd��n taulukko kotitalouksista. Ensin erotellaan kotitalouksien numerot */

	PROC SUMMARY DATA = STARTDAT.START_ELASUMTUKI N NOPRINT;
	BY knro;
	OUTPUT OUT = TEMP.ELASUMTUKI_KOTIT (KEEP = knro);
	RUN;

	/* 3.4 Poimitaan kotitalouksien kaikki j�senet ja heille
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

	/* 3.5 Yhdistet��n edell� luotuun taulukkoon my�s ensin luodun taulukon tiedot */

    DATA STARTDAT.START_ELASUMTUKI_PERHE 
	(DROP = ikakk IRAJA TMP);
	MERGE STARTDAT.START_ELASUMTUKI_PERHE (IN = A) STARTDAT.START_ELASUMTUKI;
	BY hnro;
	IF A;
	/* Lapsen ik�raja 18 v vuodesta 2008 l�htien ja 16 v sit� ennen */
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

	/* Eritell��n viitehenkil�t ja heid�n puolistot sen mukaan, ovatko he oikeutettuja el�kkeensaajien asumistukeen,
	   saavatko he KEL:n mukaista varhennettua vanhuusel�kett� tai leskenel�kett� 
	   Riitt�v� ik� rinnastetaan el�kkeen saamiseen */

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

    /* Luokitellaan tulot toisaalta viitehenkil�iden ja viitehenkil�n puolison ja toisaalta ja ei-viitehenkil�n tuloihin;
	   Veronalaisten tulojen ohella otetaan huomioon verottomat osinkotulot ja l�hdeveronalaiset korkotulot; opintorahat v�hennet��n
	   Lis�ksi verottomat mets�tulot*/

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

	LAPSIKK = 'Ik�rajan alittavat lapsikuukaudet kalenerivuoden aikana, DATA'
	MAHD_PUOLISO = 'Mahdollinen puoliso (0/1), DATA'
	SAA_ELAK1 = 'Viitehenkil� saa el�kett� (0/1), DATA'
	SAA_ELAK2 = 'Viitehenkil�n puoliso saa el�kett� (0/1), DATA'
	VARVANH1 = 'Viitehenkil� saa varhennettu vanhuusel�kett� (0/1), DATA'
	VARVANH2 = 'Viitehenkil�n puoliso saa varhennettu vanhuusel�kett� (0/1), DATA'
	LESKEL1 = 'Viitehenkil� saa leskenel�kett� (0/1), DATA'
	LESKEL2 = 'Viitehenkil�n puoliso saa leskenel�kett� (0/1), DATA'
	VERONAL_VIITEH_DATA = 'Viitehenkil�n tai viitehenkil�n puolison veronalaiset tulot (e/v), DATA'
	VERONAL_EIVIITEH_DATA = 'Muun henkil�n veronalaiset tulot (e/v), DATA'
	VEROT_OSINGOT_VIITEH_DATA = 'Viitehenkil�n tai viitehenkil�n puolison verottomat osinkotulot (e/v), DATA'
	VEROT_OSINGOT_EIVIITEH_DATA = 'Muun henkil�n verottomat osinkotulot (e/v), DATA'
	VEROT_METSA_VIITEH_DATA = 'Viitehenkil�n tai viitehenkil�n puolison verottomat mets�tulot, (e/v), DATA'
	VEROT_METSA_EIVIITEH_DATA = 'Muun henkil�n verottomat mets�tulot, (e/v), DATA'
	KOROT_VIITEH = 'Viitehenkil�n tai viitehenkil�n puolison korkotulot (e/v), DATA'
	KOROT_EIVIITEH = 'Muun henkil�n korkotulot (e/v), DATA'
	OPTUKI_VIITEH_DATA =  'Viitehenkil�n tai viitehenkil�n puolison opintotuki (e/v), DATA'
	OPTUKI_EIVIITEH_DATA = 'Muun henkil�n opintotuki (e/v), DATA'
	KAIKKI_TULOT_VIITEH_DATA  = 'Viitehenkil�n tai viitehenkil�n puolison kaikki tulot (e/v), DATA'
	KAIKKI_TULOT_EIVIITEH_DATA  =  'Muun henkil�n kaikki tulot (e/v), DATA';
	
	RUN;

    /* 3.6 Edell� luodun taulukon tietojen summaus kotitalouksittain */
	
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
	   joissa asumistukeen oikeutettu ei ole viitehenkil� tai viitehenkil�n puoliso */

	DATA STARTDAT.START_ELASUM_KOTIT_EI_YDINP;
	SET STARTDAT.START_ELASUM_KOTIT;
	IF EI_VIITEH = 1;

	/* Jyvitet��n henkil�lle osuus asumiskustannuksista */

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
	OSUUS = 'Henkil�n %-osuus ruokakunnasta, DATA';

	RUN;

	/* 3.8 Erotellaan luodusta kotitaloustaulukosta ne tapaukset,
	  joissa asumistukeen oikeutettu on viitehenkil� tai viitehenkil�n puoliso */
	
	
	DATA STARTDAT.START_ELASUM_KOTIT_YDINP ;
	SET STARTDAT.START_ELASUM_KOTIT;

	IF VIITEH = 1;

	/* P��tell��n, onko kyse puolisoista */
		
	IF (MAHD_PUOLISO = 2) OR (KELTUN = 4) THEN PUOLISOT = 1;
	ELSE PUOLISOT = 0;

	/* Lasten lukum��r� ja el�kel�isperheen koko */

	LKM = ROUND(LAPSIKK / 12, 1);
	LPERHE = LKM + 1;
	IF PUOLISOT THEN LPERHE = LPERHE + 1;

	DROP LAPSIKK;

	/* El�kel�isperheen osuus koko ruokakunnasta */

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
	LKM = 'Lasten lukum��r�, DATA'
	LPERHE = 'El�kel�isperheen koko, DATA'
	PUOLISOT = 'Onko kyse puolisoista (0/1), DATA'
	OSUUS = 'El�kel�isperheen %-osuus koko ruokakunnasta, DATA';
	
	RUN;

	/* 3.9 Erotetaan alkuper�isest� taulukosta ne el�kel�iset, jotka eiv�t ole kotitalouden
	viitehenkil�it� tai viitehenkil�n puolisoita */

	DATA STARTDAT.START_ELASUMTUKI_EI_YDINP;
	SET STARTDAT.START_ELASUMTUKI;
	IF asko > 2;
	RUN;

	/* 3.10 Rajoitetaan alkuper�inen taulukko viitehenkil�ihin ja viitehenkil�n puolisoihin */

	DATA STARTDAT.START_ELASUMTUKI;
	SET STARTDAT.START_ELASUMTUKI;
	IF asko = 1 OR asko = 2;
	RUN;

	/* 3.11 Yhdistet��n kotitaloustason tiedot em. taulukoihin;
	   Ensin viitehenkil�t ja viitehenkil�n puolisot */

	DATA STARTDAT.START_ELASUMTUKI;
	MERGE STARTDAT.START_ELASUMTUKI(IN = A) STARTDAT.START_ELASUM_KOTIT_YDINP;
	BY knro;
	IF A;

	/* Saako jompi kumpi puoliso KEL:n mukaista varhennettua vanhuusel�kett� */
	/* Mahdollisuus, ett� molemmat saavat, pit�isi olla pois rajattu. */

	IF PUOLISOT = 1 AND SUM(VARVANH1, VARVANH2) = 1 THEN VARVANH = 1;
	ELSE VARVANH = 0;

	/* Selvitet��n, ovatko kummatkin puolisot oikeutettuja asumistukeen */
	/* Jos toinen puoliso ei ole, mutta saa varhennettua vanhuusel�kett�, sekin riitt�� */
	
	IF SUM(SAA_ELAK1, SAA_ELAK2) = 2 OR VARVANH = 1 THEN KUMPIKIN = 1;
	ELSE KUMPIKIN = 0;

	/* Onko kyse leskenel�kkeen saajista */

	IF SUM(LESKEL1, LESKEL2) > 0 THEN LESKEL = 1;
	ELSE LESKEL = 0;

	LABEL
	KUMPIKIN ='Ovatko kummatkin puolisot oikeutettuja asumistukeen (0/1), DATA';

	RUN;

	/* 3.12 Tapaukset, joissa asumistukeen oikeutettu ei ole viitehenkil� tai viitehenkil�n puoliso */

	DATA STARTDAT.START_ELASUMTUKI_EI_YDINP;
	MERGE STARTDAT.START_ELASUMTUKI_EI_YDINP (IN = A DROP = halpinta) STARTDAT.START_ELASUM_KOTIT_EI_YDINP (KEEP = knro halpinta  maksvuok hoitvast yhtiovas lisalamm
	omalamm lisamaks tontvuok kaytkorv aslaikor); 
	BY knro;
	IF A;
	RUN;

	/* 3.13 Yhdistet��n tulotietoja edell� luotuun taulukkoon */

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
	VERONAL_EIVIITEH_DATA = 'Muun henkil�n veronalaiset tulot (e/v), DATA'
	VEROT_OSINGOT_EIVIITEH_DATA = 'Muun henkil�n verottomat osinkotulot (e/v), DATA'
    VEROT_METSA_EIVIITEH_DATA = 'Muun henkil�n verottomat mets�tulot, arvio, (e/v), DATA'
	KOROT_EIVIITEH = 'Muun henkil�n korkotulot (e/v), DATA'
	OPTUKI_EIVIITEH_DATA = 'Muun henkil�n opintotuki (e/v), DATA'
	KAIKKI_TULOT_EIVIITEH_DATA  =  'Muun henkil�n kaikki tulot (e/v), DATA';

	RUN;

%END;

%MEND ElAsumTuki_Muut_Poiminta;

%ElAsumTuki_Muut_Poiminta;

%LET alkoi2&malli = %SYSFUNC(TIME());

/* 4. Makro hakee tietoja VERO-mallista ja liitt�� ne mallin dataan */

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
	VERONAL_VIITEH_MALLI = 'Viitehenkil�n tai viitehenkil�n puolison veronalaiset tulot (e/v), DATA'
	VERONAL_EIVIITEH_MALLI = 'Muun henkil�n veronalaiset tulot (e/v), DATA'
	VEROT_OSINGOT_VIITEH_MALLI = 'Viitehenkil�n tai viitehenkil�n puolison verottomat osinkotulot (e/v), DATA'
	VEROT_OSINGOT_EIVIITEH_MALLI = 'Muun henkil�n verottomat osinkotulot (e/v), DATA'
	OPTUKI_VIITEH_MALLI =  'Viitehenkil�n tai viitehenkil�n puolison opintotuki (e/v), DATA'
	OPTUKI_EIVIITEH_MALLI = 'Muun henkil�n opintotuki (e/v), DATA'
	KAIKKI_TULOT_VIITEH_MALLI  = 'Viitehenkil�n tai viitehenkil�n puolison kaikki tulot (e/v), DATA'
	KAIKKI_TULOT_EIVIITEH_MALLI  =  'Muun henkil�n kaikki tulot (e/v), DATA';

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

	/* 4.3. Erotellaan viitehenkil�t ja viitehenkil�n puolisot eri taulukkoon... */
	
	DATA TEMP.ELASUM_SIMULTULOT_KOTIT_YDINP;
	SET TEMP.ELASUM_SIMULTULOT_KOTIT;
	IF VIITEH = 1;
	RUN;

	/* 4.4 ...ja muut henkil�t toiseen taulukkoon */
	
	DATA TEMP.ELASUM_SIMULTULOT_KOTIT_EI_YDINP;
	SET TEMP.ELASUM_SIMULTULOT_KOTIT;
	IF EI_VIITEH = 1;
	RUN;

	/* 4.5 Yhdistet��n taulukot l�ht�dataan, ensin viitehenkil�t ja viitehenkil�n puolisot */

	DATA STARTDAT.START_ELASUMTUKI;
	MERGE STARTDAT.START_ELASUMTUKI (IN = A) 
	TEMP.ELASUM_SIMULTULOT_KOTIT_YDINP (KEEP = knro KAIKKI_TULOT_VIITEH_MALLI);
	BY knro;
	IF A;
	RUN;

	/* 4.6 Yhdistet��n taulukot l�ht�dataan, muut henkil�t */

	DATA STARTDAT.START_ELASUMTUKI_EI_YDINP;
	MERGE STARTDAT.START_ELASUMTUKI_EI_YDINP (IN = A)  
	TEMP.ELASUM_SIMULTULOT_KOTIT_EI_YDINP (KEEP = knro KAIKKI_TULOT_EIVIITEH_MALLI);
	BY knro;
	IF A;
	RUN;
	
%END;

%MEND Osamallit_ElAsumTuki;

%OsaMallit_ElAsumTuki;


/* 5. ELASUMTUKI-mallissa (vuositason lains��d�nt�) parametrit luetaan makromuuttujiksi ennen simulontia */

%HaeParam_ElAsumTukiSIMUL(&LVUOSI, &INF);


/* 6. Simulointivaihe */

%MACRO ElAsumTuki_Simuloi_Data;

/* 6.1. Viitehenkil�t ja viitehenkil�n puolisot */

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

* Poistetaan el�kkeensaajien asumistuki "ei-ydinperhe-el�kel�isilt�" tarvittaessa ;

IF &YDINP = 0 THEN TUKI2 = 0;

RUN;

/* 6.3 Yhdistet��n laskelmien tulokset valmiiseen tulostaulukon runkoon */

DATA OUTPUT.&TULOSNIMI_EA (KEEP = hnro knro KAIKKI_TULOT_VIITEH KAIKKI_TULOT_EIVIITEH TUKI TUKI2 ELAKASUMTUKI);
MERGE TEMP.ELASUMTUKI_TULOS TEMP.START_ELASUMTUKI TEMP.START_ELASUMTUKI_EI_YDINP;
BY hnro;
ELAKASUMTUKI = SUM(TUKI, TUKI2);
RUN;

/* 6.4 Yhdistet��n simuloitu data palveluaineistoon (riippuen tulosaineiston laajuden valinnasta) */

DATA OUTPUT.&TULOSNIMI_EA;
	
/* 6.4.1 Suppea tulostiedosto (vain t�rkeimm�t luokittelumuuttujat) */

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

* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukum��r�t voidaan laskea suoraan ;

ARRAY PISTE 
TUKI TUKI2 aemkm ELAKASUMTUKI;
DO OVER PISTE;
	IF PISTE <= 0 THEN PISTE = .;
END;

* Luodaan simuloiduille ja datan muuttujille selitteet ;

LABEL 
KAIKKI_TULOT_VIITEH = 'Viitehenkil�n tai viitehenkil�n puolison kaikki tulot (e/v), MALLI'
KAIKKI_TULOT_EIVIITEH = 'Muun henkil�n kaikki tulot (e/v), MALLI'
TUKI = 'El�kkeensaajien asumistuki: viitehenkil�t ja viitehenkil�n puolisot, MALLI'
TUKI2 = 'El�kkeensaajien asumistuki: ei-ydinperhe-el�kel�iset, MALLI'
aemkm = 'El�kkeensaajien asumistuki, DATA'
ELAKASUMTUKI = 'El�kkeensaajien asumistuki, MALLI';

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

		/* Siirret��n tiedot Exceliin (optio) */

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
	
	/* 7.2 Henkil�tason tulokset (oletus) */

	%ELSE %DO;

		/* Siirret��n tiedot Exceliin (optio) */

		%IF &EXCEL = 1 %THEN %DO;

			ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_EA._SUMMAT.xls" STYLE = MINIMAL;

		%END;

		PROC MEANS DATA=OUTPUT.&TULOSNIMI_EA &SUMWGT &SUM &MIN &MAX &RANGE &MEAN &MEDIAN &MODE &STD &VAR &CV NONOBS ORDER=DATA NWAY MAXDEC = 0;
		TITLE "TUNNUSLUVUT (HENKIL�TASO), &MALLI";
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





