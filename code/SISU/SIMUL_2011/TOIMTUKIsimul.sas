/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyödyntää Tilastokeskuksen yleisten
* käyttöehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto päähakemistossa.
******************************************************************************/

/************************************************************************
* Kuvaus: Toimeentulotuen simulointimalli 2011							*
* Tekijä: Elina Ahola / KELA											*
* Luotu: 07.09.2011														*
* Viimeksi päivitetty: 19.05.2013										*
* Päivittäjä: Elina Ahola / KELA 										*
*************************************************************************/


/* 0. Yleisiä vakioiden määrittelyjä (älä muuta näitä!) */

%LET START = &OUT;

%LET MALLI = TOIMTUKI;

%LET alkoi1&MALLI = %SYSFUNC(TIME());


/* 1. Mallia ohjaavat makromuuttujat */

%MACRO Aloitus;

%IF &START = 1 %THEN %DO;
	%LET TYYPPI = &TYYPPI_KOKO;
	%LET TULOKSET = &TULOKSET_KOKO;
%END;

%IF &START NE 1 %THEN %DO;
		
	/* Jos mallia käytetään käyttöliittymästä (&EG = 1), niin seuraavia vaiheita ei ajeta */

	%IF &EG NE 1 %THEN %DO;

	%LET AVUOSI = 2011;		* Aineistovuosi (vvvv);

	%LET LVUOSI = 2011;		* Lainsäädäntövuosi (vvvv);

	%LET TYYPPI = SIMUL;	* Parametrien hakutyyppi: SIMUL (vuosikeskiarvo) tai SIMULX (parametrit haetaan tietylle kuukaudelle);

	%LET LKUUK = 12;        * Lainsäädäntökuukausi, jos parametrit haetaan tietylle kuukaudelle;

	%LET AINEISTO = PALV ;  * Käytettävä aineisto (PALV = Palveluaineisto, REK = Rekisteriaineisto);

	%LET TULOSNIMI_TO = toimtuki_simul_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi;

	/* Simuloidaanko toimeentulotuki myös yrittäjätalouksille.
  	   Jos toimeentulotukea ei simuloida yrittäjätalouksille, tämä on 0.
       Jos toimeentulotuki simuloidaan yrittäjätalouksille, tämä on 1. */

	%LET YRIT = 0; 

	* Inflaatiokorjaus. Parametrien deflatoinnissa käytettävän kertoimen voi syöttää itse
	  INF-makromuuttujaan (HUOM! desimaalit erotettava pisteellä .). Jos puolestaan haluaa käyttää automaattista 
	  elinkustannusindeksiin perustuvaa parametrien muunnoskerrointa, 
	  tulee INF-makromuuttujalle antaa arvoksi 999.; 	

	%LET INF = 1.00; * Syötä arvo tai 999;
	%LET PINDEKSI_VUOSI = pindeksi_vuosi; *Käytettävä indeksien parametritaulukko;		

	* Ajettavat osavaiheet ; 

	%LET LAKIMAKROT = 1;    				* Lakimakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
	%LET LAKIMAK_TIED_TO = TOIMTUKIlakimakrot;	* Lakimakroissa käytettävän tiedoston nimi;
	%LET LAKIMAK_TIED_OT = OPINTUKIlakimakrot;
	%LET APUMAKROT = 1;   					* Apumakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
	%LET APUMAK_TIED_TO = TOIMTUKIapumakrot; 	* Apumakroissa käytettävän tiedoston nimi;
	%LET APUMAK_TIED_OT = OPINTUKIapumakrot;
	%LET POIMINTA = 1;  					* Muuttujien poiminta (1 jos ajetaan, 0 jos ei);
	%LET TULOKSET = 1;						* Yhteenvetotaulukot (1 jos ajetaan, 0 jos ei);

	* Käytettävien parametritiedostojen nimet ;

	%LET PTOIMTUKI = ptoimtuki;
	%LET POPINTUKI = popintuki;

	* Tulostaulukoiden esivalinnat ; 

	%LET TULOSLAAJ = 1 ; 	 				* Mikrotason tulosaineiston laajuus (1=suppea, 2 = laaja (palveluaineisto));
	%LET MUUTTUJAT = TOIMTUKI TOIMTUKIREK ; * Taulukoitavat muuttujat (summataulukot) ;
	%LET YKSIKKO = 1;		 * Tulostaulukoiden yksikkö (1 = henkilö, 2 = kotitalous) ;
	%LET LUOK_HLO1 = desmod; * Taulukoinnin 1. henkilöluokitus (jos YKSIKKO = 1)
							   Vaihtoehtoina: 
							     desmod (tulodesiilit, ekvivalentit tulot (modoecd), hlöpainot)
							     ikavu (henkilön mukaiset ikäryhmät)
							     elivtu (kotitalouden elinvaihe)
							     koulas (henkilön koulutusaste TK1997)
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

	%LET EXCEL = 0; 		  * Viedäänkö tulostaulukko automaattisesti Exceliin (1 = Kyllä, 0 = Ei);

	* Laskettavat tunnusluvut (jos tyhjä, niin ei lasketa);
	%LET SUMWGT = SUMWGT; * N eli lukumäärät ;
	%LET SUM = SUM; 
	%LET MIN = ; 
	%LET MAX = ;
	%LET RANGE =  ;
	%LET MEAN = ;
	%LET MEDIAN = ;
	%LET MODE =  ;
	%LET VAR = ;
	%LET CV =  ;
	%LET STD =  ;

	%LET PAINO = ykor ; 	* Käytettävä painokerroin (jos tyhjä, niin lasketaan painottamattomana);
	%LET RAJAUS =  ; 		* Rajauslause tunnuslukujen laskentaan (jos tyhjä, niin ei rajauksia);

	%END;

	/* Osamallien ohjausparametrien arvot asetetaan nolliksi, jos mallia ajetaan erillisajossa (= ei KOKO-mallista) */

	%LET SAIRVAK = 0; %LET TTURVA = 0; %LET OPINTUKI = 0; %LET KOTIHTUKI = 0; %LET KANSEL = 0; 
	%LET ASUMTUKI = 0; %LET ELASUMTUKI = 0; %LET VERO = 0; %LET PHOITO = 0; %LET LLISA = 0; %LET KIVERO = 0;

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
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_TO..sas";
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_OT..sas";
%END;

/* Ajetaan apumakrot ja tallennetaan ne (optio) */

%IF &APUMAKROT = 1 %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&APUMAK_TIED_TO..sas";
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&APUMAK_TIED_OT..sas";
%END;

%MEND TeeMakrot;

%TeeMakrot;


/* 3. Datan poiminta ja apumuuttujien luominen (optio) */

%MACRO ToimTuki_Muutt_Poiminta;

%IF &POIMINTA = 1 %THEN %DO;

	%LOCAL TYYPPI;
	%LET TYYPPI = SIMUL;

	/* 3.1 Poimitaan tarvittavat palveluaineiston muuttujat taulukkoon START_TOIMTUKI_HENKI */
	
	DATA STARTDAT.START_TOIMTUKI_HENKI;
	SET POHJADAT.&AINEISTO&AVUOSI;
	KEEP hnro knro 
	asko ikakk ikavu svatva svatvp verot ltvp
    lahdever omakkiiv elama korotv
	llmk kokorve kellaps rili riyl
	amstipe lbeltuki lbdpperi hsotav hasepr elasa rahsa
	ulkelve ulkelmuu hsotvkor
	hastuki hasuli maksvuok kaytkorv
	yhtiovas lisalamm omalamm omamaks
	tontvuok aslaikor sahko apuraha
	hlakav vtyomj vthm vmatk vevm lpvma
	tnoosvvb teinovvb tuosvvap topkb
	topkver teinovv lassa muusa paasoss
	hulkpa trpl trplkor tulkp tulkp6 tmpt
	tkust tepalk tmeri tlue2 tpalv trespa
	tpturva tpalv2 telps1 telps2
	telps5 ttyoltuk	tmaat1 tmaat1p
	tliik1 tliikp tporo1 tyhtat
	tyhthav hoiaikak hoimaksk hoiaikao
	hoimakso hoiaikay hoimaksy
	opirake opirako tukiaika optukk
	tpjta
	aemkm 	
	hoiaikap hoimaksp
	varm lveru
	anstukor mamutuki;	
	RUN;
	
	/* 3.2 Määritetään aikuisten ja eri ikäisten lasten määrät kotitaloudessa */

	/* 3.2.1 Määritetään henkilön perheasema */

	DATA TEMP.TOIMTUKI_PERHEASEMA_MUOK;
	SET STARTDAT.START_TOIMTUKI_HENKI;

	IKAKUUKAUSINA = SUM(ikavu * 12, ikakk);

	IF asko = 1 THEN ONVIITE = 1;
	ELSE ONVIITE = 0;

	IF asko = 2 THEN ONPUOLISO = 1;
	ELSE ONPUOLISO = 0;

	IF asko = 3 AND IKAKUUKAUSINA <= 0 THEN ONPUUTTUVA = 1;
	ELSE ONPUUTTUVA = 0;

	IF asko = 3 AND IKAKUUKAUSINA > 0 AND IKAKUUKAUSINA < 36 THEN ONLAPSIALLE3 = 1;
	ELSE ONLAPSIALLE3 = 0;

	IF asko = 3 AND IKAKUUKAUSINA >= 36 AND IKAKUUKAUSINA < 120 THEN ONLAPSI3_9 = 1;
	ELSE ONLAPSI3_9 = 0;

	IF asko = 3 AND IKAKUUKAUSINA >= 120 AND IKAKUUKAUSINA < 192 THEN ONLAPSI10_15 = 1;
	ELSE ONLAPSI10_15 = 0;

	IF asko = 3 AND IKAKUUKAUSINA >= 192 AND IKAKUUKAUSINA < 204 THEN ONLAPSI16 = 1;
	ELSE ONLAPSI16 = 0;

	IF asko = 3 AND IKAKUUKAUSINA >= 204 AND IKAKUUKAUSINA < 216 THEN ONLAPSI17 = 1;
	ELSE ONLAPSI17 = 0;

	IF asko = 3 AND IKAKUUKAUSINA >= 216 THEN ONAIKLAPSI = 1;
	ELSE ONAIKLAPSI = 0;

	IF asko NE 1 AND asko NE 2 AND asko NE 3 THEN ONMUUAIK = 1;
	ELSE ONMUUAIK = 0;

	KEEP hnro knro ONVIITE ONPUOLISO ONPUUTTUVA ONLAPSIALLE3 ONLAPSI3_9 ONLAPSI10_15
	     ONLAPSI16 ONLAPSI17 ONAIKLAPSI ONMUUAIK;

	RUN;

	/* 3.2.2 Määritetään eri perheasemia edustavien lukumäärät kotitaloudessa */

	PROC SQL;
	CREATE TABLE TEMP.TOIMTUKI_KOTIT_PERHEASEMA 
	AS SELECT knro, 
	SUM(ONVIITE) AS ONVIITES, SUM(ONPUOLISO) AS ONPUOLISOS,
	SUM(ONMUUAIK) AS ONMUUAIKS,
	SUM(ONAIKLAPSI) AS ONAIKLAPSIS,
	SUM(ONLAPSI17) AS ONLAPSI17S,
	SUM(ONLAPSI16) AS ONLAPSI16S, SUM(ONLAPSI10_15) AS ONLAPSI10_15S,
	SUM(ONLAPSI3_9) AS ONLAPSI3_9S, SUM(ONLAPSIALLE3) AS ONLAPSIALLE3S
	FROM TEMP.TOIMTUKI_PERHEASEMA_MUOK
	GROUP BY knro;
	QUIT;

	/* 3.2.3 Tiivistetään edellistä esitystä */

	DATA TEMP.TOIMTUKI_KOTIT_PERHEASEMA;
	SET TEMP.TOIMTUKI_KOTIT_PERHEASEMA;

	ONAIKS = SUM(ONVIITES, ONPUOLISOS, ONMUUAIKS);
	ONLAPSI10_16S = SUM(ONLAPSI10_15S, ONLAPSI16S);
	ONLAPSIALLE10S = SUM(ONLAPSI3_9S, ONLAPSIALLE3S);

	KEEP knro ONAIKS ONAIKLAPSIS ONLAPSI17S ONLAPSI10_16S ONLAPSIALLE10S;
	RUN;

	/* 3.3 Muodostetaan laskennassa tarvittavat yksilötason muuttujat */

	DATA TEMP.TOIMTUKI_YKS;
	SET STARTDAT.START_TOIMTUKI_HENKI;

	* Rajoitetaan ilmoitetut matkakulut verotuksessa hyväksyttävään maksimiin (ml. omavastuu)
	  rekisteriaineiston poikkeavien havaintojen vuoksi.;
	VMATKR = MIN(SUM(vmatk, 0), 7600);

	* Niiden kuukausien osuus, jona henkilö ei ole ollut armeijassa tai siviilipalveluksessa;
	EIAMSI = (12-varm)/12;

	* Veronalainen työtulo;
	VERTYOTULO = SUM(trpl, trplkor, MAX(tulkp - tulkp6, 0), tmpt, tkust,
			tepalk, tmeri, tlue2, tpalv, trespa, tpturva, tpalv2, telps1,
			telps2, telps5, ttyoltuk, tmaat1, tmaat1p, tpjta, tliik1,
			tliikp, tporo1, tyhtat, tyhthav, anstukor);

	* Verovapaa työtulo;
	VEROTTYOTULO = SUM(tulkp6, hulkpa);	

	* Päivähoitomaksut yhteensä;
	PHOITO_DATA = SUM(hoiaikak * hoimaksk, hoiaikao * hoimakso,
			hoiaikay * hoimaksy, hoiaikap * hoimaksp);

	* Yksityiset päivähoitomaksut;
	PHOITO_YKS = SUM(hoiaikay * hoimaksy, hoiaikap * hoimaksp);

	* Opintotukiaika kuukausina;

	* Lasketaan aluksi tukiaika suoraan datan optukk-muuttujasta;
	IF opirake > 0 AND opirako = 0 THEN DO;
		OPAIKAKESK = optukk;
		OPAIKAKORK = 0;
	END;
	ELSE DO;
		IF opirake = 0 AND opirako > 0 THEN DO;
			OPAIKAKESK = 0;
			OPAIKAKORK = optukk;
		END;
		ELSE DO;
			IF opirake > 0 AND opirako > 0 AND tukiaika = 3 THEN DO;
				OPAIKAKESK = MIN(5, optukk);
				OPAIKAKORK = MIN(4, optukk);
			END;
			ELSE DO;
				OPAIKAKESK = 0;
				OPAIKAKORK = 0;
			END;
		END;
	END;

	* Katsotaan sitten, saadaanko tukiaikaa pääteltyä opintorahan perusteella;

	* Lasketaan ikä;
	IKAKUUKAUSINA = 12 * ikavu + ikakk;
	IF IKAKUUKAUSINA < 222 THEN IKA = 17;
	ELSE IF IKAKUUKAUSINA < 246 THEN IKA = 19;
	ELSE IKA = ikavu;

	* A. Täysimääräinen opintotuki keskiasteella;

	* A.1. Ei asu vanhempien kanssa;
	%OpRahaV&F(TOPINTOKESKEV, &AVUOSI, 1, 0, 0, IKA, 0, 0, 0, 0);
	* A.2. Asuu vanhempien kanssa;
	%OpRahaV&F(TOPINTOKESKV, &AVUOSI, 1, 0, 1, IKA, 0, 0, 0, 0);

	* B. Täysimääräinen opintotuki korkea-asteella;

	* B.1. Ei asu vanhempien kanssa;
	%OpRahaV&F(TOPINTOKORKEV, &AVUOSI, 1, 1, 0, IKA, 0, 0, 0, 0);
	* B.2. Asuu vanhenpien kanssa;
	%OpRahaV&F(TOPINTOKORKV, &AVUOSI, 1, 1, 1, IKA, 0, 0, 0, 0);

	* Katsotaan, vastaako saatu opintoraha jotakin täysimääräisen opintotuen monikertaa.
	Jos vastaa, korvataan optukk-muuttujan perusteella saatu arvo tällä uudella arvolla.;
	DO i = 1 TO 12;
		IF opirake = (i * TOPINTOKESKEV) THEN OPAIKAKESK = i;
		IF opirake = (i * TOPINTOKESKV) THEN OPAIKAKESK = i;
		IF opirako = (i * TOPINTOKORKEV) THEN OPAIKAKORK = i;
		IF opirako = (i * TOPINTOKORKV) THEN OPAIKAKORK = i;
	END;
		
	* Potentiaalinen opintolaina;
	%OpLainaV&F(OPLAINAKESK, &AVUOSI, &INF, 0, 0, IKA);
	%OpLainaV&F(OPLAINAKORK, &AVUOSI, &INF, 1, 0, IKA);

	OPINTOLAINA = SUM(OPAIKAKESK * OPLAINAKESK, OPAIKAKORK * OPLAINAKORK); 

	KEEP hnro knro VMATKR EIAMSI VERTYOTULO VEROTTYOTULO PHOITO_DATA PHOITO_YKS OPINTOLAINA;
	RUN;

	/* 3.4 Muodostetaan laskennassa tarvittavat kotitaloustason muuttujat */

	/* 3.4.1 Muokataan alkuperäisiä tietoja kotitaloustasolle */

	PROC SQL;
	CREATE TABLE TEMP.TOIMTUKI_KOTIT_SUMMAUS
	AS SELECT knro, paasoss,
	COUNT(hnro) AS KOTITALOUSKOKO,
	SUM(svatva) AS SVATVAS, SUM(svatvp) AS SVATVPS,
	SUM(hastuki) AS HASTUKIS, SUM(hasuli) AS HASULIS,
	SUM(llmk) AS LLMKS,
	SUM(kokorve) AS KOKORVES,
	SUM(kellaps) AS KELLAPSS,
	SUM(rili) AS RILIS, SUM(riyl) AS RIYLS,
	SUM(amstipe) AS AMSTIPES,
	SUM(lbeltuki) AS LBELTUKIS, SUM(lbdpperi) AS LBDPPERIS, SUM(hlakav) AS HLAKAVS,
	SUM(SUM(ulkelve, ulkelmuu)) AS MUULKTUS,
	SUM(hsotvkor) AS HSOTVKORS,
	SUM(hsotav) AS HSOTAVS,
	SUM(verot) AS VEROTS, SUM(ltvp) AS LTVPS,
	SUM(vevm) AS VEVMS, SUM(lpvma) AS LPVMAS,
	SUM(lahdever) AS LAHDEVERS,
	SUM(omakkiiv) AS OMAKKIIVS, SUM(elama) AS ELAMAS,
	SUM(korotv) AS KOROTVS,
	SUM(maksvuok) AS MAKSVUOKS, SUM(kaytkorv) AS KAYTKORVS,
	SUM(yhtiovas) AS YHTIOVASS, SUM(aslaikor) AS ASLAIKORS,
	SUM(lisalamm) AS LISALAMMS, SUM(omalamm) AS OMALAMMS,
	SUM(omamaks) AS OMAMAKSS, SUM(sahko) AS SAHKOS,
	SUM(tontvuok) AS TONTVUOKS,
	SUM(apuraha) AS APURAHAS, 
	SUM(vtyomj) AS VTYOMJS, SUM(vthm) AS VTHMS,
	SUM(tnoosvvb) AS TNOOSVVBS,
	SUM(teinovvb) AS TEINOVVBS,
	SUM(tuosvvap) AS TUOSVVAPS, SUM(topkb) AS TOBKBS,
	SUM(topkver) AS TOPKVERS, SUM(teinovv) AS TEINOVVS,
	SUM(elasa) AS ELASAS, SUM(rahsa) AS RAHSAS,
	SUM(lassa) AS LASSAS, SUM(muusa) AS MUUSAS,
	SUM(hasepr) AS HASEPRS,
	SUM(aemkm) AS AEMKMS, SUM(lveru) AS LVERUS,
	SUM(mamutuki) AS MAMUTUKIS
	FROM STARTDAT.START_TOIMTUKI_HENKI
	GROUP BY knro, paasoss;
	QUIT;

	/* 3.4.2 Muunnetaan muodostetut yksilötason muuttujat kotitalouden tasolle */

	PROC SQL;
	CREATE TABLE TEMP.TOIMTUKI_KOTIT_MUOK1
	AS SELECT knro, SUM(VMATKR) AS VMATKRS, SUM(EIAMSI) AS EIAMSIS, SUM(VERTYOTULO) AS VERTYOTULO, SUM(VEROTTYOTULO) AS VEROTTYOTULO, SUM(PHOITO_DATA) AS PHOITO_DATA, SUM(PHOITO_YKS) AS PHOITO_YKS,
	SUM(OPINTOLAINA) AS OPINTOLAINA			
	FROM TEMP.TOIMTUKI_YKS
	GROUP BY knro;
	QUIT;

	/* 3.4.3 Yhdistetään tähän mennessä muodostetut kotitaloustason tiedot taulukkoon START_TOIMTUKI_KOTI */

	PROC SQL;
	CREATE TABLE STARTDAT.START_TOIMTUKI_KOTI
	AS SELECT *
	FROM TEMP.TOIMTUKI_KOTIT_SUMMAUS AS a, TEMP.TOIMTUKI_KOTIT_PERHEASEMA AS b,
	TEMP.TOIMTUKI_KOTIT_MUOK1 AS c
	WHERE a.knro = b.knro AND a.knro = c.knro;
	QUIT;

	/* 3.4.4 Sitten muodostetaan lisää muuttujia suoraan kotitalouden tasolle */ 

	DATA STARTDAT.START_TOIMTUKI_KOTI;
	SET STARTDAT.START_TOIMTUKI_KOTI;

	*Toimeentulotuen määrän kerroin, kun poistetaan armeijassa tai siviilipalveluksessa olemisen ajat.;
	KERROIN = EIAMSIS/KOTITALOUSKOKO;

	*Veronalaiset ansiotulot;
	ANSIOT_DATA = SVATVAS;

	*Veronalaiset pääomatulot;
	POTULOT_DATA = SVATVPS;

	*Työeläke- ja työttömyysvakuutusmaksut;
	PALKVAK_DATA = VEVMS;

	*Sairausvakuutuksen päivärahamaksut;
	PRAHAMAKSU_DATA = LPVMAS;

	*Kaikki verot ml. sairausvakuutuksen sairaanhoitomaksu;
	MAKSVEROT_DATA = SUM(VEROTS, -PRAHAMAKSU_DATA, LVERUS);

	*Veronalaisten ansiotulojen verot ml. sairausvakuutuksen sairaanhoitomaksu;
	ANSIOVEROT_DATA = SUM(MAKSVEROT_DATA, -LTVPS);

	*Tulonhankkimiskulut;
	THANKK = SUM(VTYOMJS, VTHMS, VMATKRS);

	*Eläkkeensaajan asumistuki;
	ELASUMTUKI_DATA = AEMKMS; 

	*Opiskelijan asumislisä;
	ASUMLISA_DATA = HASULIS;

	*Yleinen asumistuki;
	ASUMTUKI_DATA = HASTUKIS;

	*Lapsilisät kuukautta kohden;
	LLISAT_DATA = LLMKS / 12;

	*Elatustuki;
	ELTUKI_DATA = SUM(LBELTUKIS, LBDPPERIS);

	*Eläkkeenlisät;
	ELLISAT_DATA = SUM(KELLAPSS, RILIS, RIYLS);

	*Maahanmuuttajan erityistuki.;
	MAMUTUKI_DATA = MAMUTUKIS;

	*Toimeentulotukeen vaikuttavat verottomat osinkotulot;
	OSINGOT_VEROVAP_DATA = SUM(TNOOSVVBS, TEINOVVBS, TUOSVVAPS, TOBKBS, -TOPKVERS, TEINOVVS);
		
	*Toimeentulotukeen vaikuttavat muut verovapaat tulot;

	VEROTTUL_MUU = SUM(KOKORVES, -LAHDEVERS, AMSTIPES, APURAHAS, HLAKAVS,	
			HSOTVKORS, HSOTAVS, ELASAS, RAHSAS, LASSAS, MUUSAS,
			HASEPRS, MUULKTUS, OPINTOLAINA);	

	*Kiinteistövero;
	KIVERO_DATA = OMAKKIIVS;

	*Sekalaisia veroja;
	SEKALVERO = KOROTVS;

	*Maksetut elatusmaksut;
	ELMAKSUT = ELAMAS;
	
	*Asumiskulut kuukaudessa;
	ASUMISKULUT = SUM(MAKSVUOKS, KAYTKORVS, YHTIOVASS, ASLAIKORS / 12,
			LISALAMMS / 12, OMALAMMS / 12, OMAMAKSS / 12, TONTVUOKS / 12,
			SAHKOS / 12);

	*Harkinnanvaraiset menot kuukaudessa;
	HARKINMENOT_DATA = SUM(ELMAKSUT, PHOITO_DATA) / 12; 	

	*Yksityiset päivähoitomaksut;
	PHOITO_YKS = PHOITO_YKS / 12;


	/* 3.5 Tehdään apumuuttujille labelit */

	LABEL	
		KERROIN = "Toimeentulotuen määrän kerroin, kun poistetaan armeijassa tai siviilipalveluksessa olemisen ajat, DATA"
		VERTYOTULO = "Kotitalouden veronalainen työtulo (e/v), DATA"
		VEROTTYOTULO = "Kotitalouden verovapaa työtulo (e/v), DATA"
		ONAIKS = "Aikuisten lukumäärä kotitaloudessa, DATA"
		ONAIKLAPSIS = "18-vuotiaiden tai vanhempien lasten lukumäärä kotitaloudessa, DATA"
		ONLAPSI17S = "17-vuotiaiden lasten lukumäärä kotitaloudessa, DATA"
		ONLAPSI10_16S = "10-16-vuotiaiden lasten lukumäärä kotitaloudessa, DATA"
		ONLAPSIALLE10S = "Alle 10-vuotiaiden lasten lukumäärä kotitaloudessa, DATA"
		ANSIOT_DATA = "Kotitalouden veronalaiset ansiotulot (e/v), DATA"
		POTULOT_DATA = "Kotitalouden veronalaiset pääomatulot (e/v), DATA"
		MAKSVEROT_DATA = "Kotitalouden kaikki verot ml. sairausvakuutuksen sairaanhoitomaksu (e/v), DATA"
		ANSIOVEROT_DATA = "Kotitalouden veronalaisten ansiotulojen verot ml. sairausvakuutuksen sairaanhoitomaksu (e/v), DATA"
		PALKVAK_DATA = "Kotitalouden työeläke- ja työttömyysvakuutusmaksut (e/v), DATA"
		PRAHAMAKSU_DATA = "Kotitalouden sairausvakuutuksen päivärahamaksut (e/v), DATA"
		THANKK = "Kotitalouden tulonhankkimiskulut (e/v), DATA"
		ELASUMTUKI_DATA = "Kotitalouden saama eläkkeensaajan asumistuki (e/v), DATA"
		ASUMLISA_DATA = "Kotitalouden saama opiskelijan asumislisä (e/v), DATA"
		ASUMTUKI_DATA = "Kotitalouden saama yleinen asumistuki (e/v), DATA"
		LLISAT_DATA = "Kotitalouteen maksettu lapsilisä (e/kk), DATA"
		ELTUKI_DATA = "Kotitalouden saama elatustuki (e/v), DATA"
		ELLISAT_DATA = "Kotitalouden saamat eläkkeenlisät (e/v), DATA"
		MAMUTUKI_DATA = "Kotitalouden saama maahanmuuttajan erityistuki (e/v), DATA"
		OSINGOT_VEROVAP_DATA = "Kotitalouden saamat toimeentulotukeen vaikuttavat verovapaat osinkotulot (e/v), DATA"
		VEROTTUL_MUU = "Kotitalouden saamat muut toimeentulotukeen vaikuttavat verovapaat tulot (e/v), DATA"
		KIVERO_DATA = "Kiinteistövero (e/v), DATA"
		SEKALVERO = "Kotitaloudelta perittyjä sekalaisia veroja (e/v), DATA"
		ELMAKSUT = "Kotitalouden maksamat elatusmaksut (e/v), DATA"
		ASUMISKULUT = "Toimeentulotukeen vaikuttavat kotitalouden asumiskulut (e/kk), DATA"
		HARKINMENOT_DATA = "Kotitalouden harkinnanvaraiset menot (e/kk), DATA"
		PHOITO_YKS = "Kotitaloudet maksamat yksityiset päivähoitomaksut (e/kk), DATA";

	KEEP knro paasoss KERROIN VERTYOTULO VEROTTYOTULO ONAIKS ONAIKLAPSIS ONLAPSI17S ONLAPSI10_16S ONLAPSIALLE10S ANSIOT_DATA
		POTULOT_DATA MAKSVEROT_DATA ANSIOVEROT_DATA PALKVAK_DATA PRAHAMAKSU_DATA THANKK ELASUMTUKI_DATA
		ASUMLISA_DATA ASUMTUKI_DATA LLISAT_DATA ELTUKI_DATA ELLISAT_DATA MAMUTUKI_DATA OSINGOT_VEROVAP_DATA
		VEROTTUL_MUU KIVERO_DATA SEKALVERO ELMAKSUT ASUMISKULUT HARKINMENOT_DATA PHOITO_YKS;
	
	RUN;

%END;

%MEND ToimTuki_Muutt_Poiminta;

%ToimTuki_Muutt_Poiminta;

%LET alkoi2&malli = %SYSFUNC(TIME());

/* 4. Makro hakee tietoja muista osamalleista ja liittää ne mallin dataan */

%MACRO OsaMallit_ToimTuki;

/* 4.1 Opintotuen asumislisä */

%IF &OPINTUKI = 1 %THEN %DO;

	PROC MEANS DATA = OUTPUT.&TULOSNIMI_OT SUM NOPRINT;
	VAR ASUMLISA;
	BY knro;
	OUTPUT OUT = TEMP.TOIMTUKI_OPINTUKI_KOTIT SUM( )=;
	RUN;

	DATA STARTDAT.START_TOIMTUKI_KOTI;
	UPDATE STARTDAT.START_TOIMTUKI_KOTI (IN = C) TEMP.TOIMTUKI_OPINTUKI_KOTIT (KEEP = knro ASUMLISA)
	UPDATEMODE=NOMISSINGCHECK;
	BY knro;
	IF C;
	RUN;

%END;

/* 4.2 Kansaneläkkeen lisiä ja maahanmuuttajan erityistuki */

%IF &KANSEL = 1 %THEN %DO;

	PROC MEANS DATA = OUTPUT.&TULOSNIMI_KE SUM NOPRINT;
	VAR LAPSIKOROT RILISA YLIMRILI MMTUKI;
	BY knro;
	OUTPUT OUT = TEMP.TOIMTUKI_KANSEL_KOTIT SUM( )=;
	RUN;

	DATA STARTDAT.START_TOIMTUKI_KOTI;
	UPDATE STARTDAT.START_TOIMTUKI_KOTI (IN = C) TEMP.TOIMTUKI_KANSEL_KOTIT (KEEP = knro LAPSIKOROT RILISA YLIMRILI MMTUKI)
	UPDATEMODE=NOMISSINGCHECK;
	BY knro;
	IF C;
	RUN;

%END;

/* 4.3 Lapsilisät */

%IF &LLISA = 1 %THEN %DO;

	DATA STARTDAT.START_TOIMTUKI_KOTI;
	UPDATE STARTDAT.START_TOIMTUKI_KOTI (IN = C) OUTPUT.&TULOSNIMI_LL (KEEP = knro LLISA_HH ELATUSTUET_HH)
	UPDATEMODE=NOMISSINGCHECK;
	BY knro;
	IF C;
    RUN;

%END;


/* 4.4 Veromalli */

%IF %SYSFUNC(SUM(&SAIRVAK, &TTURVA, &KANSEL, &OPINTUKI, &KOTIHTUKI, &VERO)) > 0 %THEN %DO;

	PROC MEANS DATA = OUTPUT.&TULOSNIMI_VE SUM MIN NOPRINT;
	VAR ANSIOT POTULOT OSINKOVAP PRAHAMAKSU PALKVAK ANSIOVEROT POVEROB YLEVERO;
	BY knro;
	OUTPUT OUT = TEMP.TOIMTUKI_VERO_KOTIT SUM( )=;
	RUN;
	
	DATA STARTDAT.START_TOIMTUKI_KOTI;
	UPDATE STARTDAT.START_TOIMTUKI_KOTI (IN = C) TEMP.TOIMTUKI_VERO_KOTIT (KEEP = knro ANSIOT POTULOT
		OSINKOVAP PRAHAMAKSU PALKVAK ANSIOVEROT POVEROB YLEVERO)
	UPDATEMODE=NOMISSINGCHECK;
	BY knro;
	IF C;
	RUN;

%END;

/* 4.5 Eläkkeensaajien asumistuki */

%IF &ELASUMTUKI = 1 %THEN %DO;

	PROC MEANS DATA = OUTPUT.&TULOSNIMI_EA SUM NOPRINT;
	VAR ELAKASUMTUKI;
	BY knro;
	OUTPUT OUT = TEMP.TOIMTUKI_ELASUMTUKI_KOTIT SUM( )=;
	RUN;

	DATA STARTDAT.START_TOIMTUKI_KOTI;
	UPDATE STARTDAT.START_TOIMTUKI_KOTI (IN = C) TEMP.TOIMTUKI_ELASUMTUKI_KOTIT (keep = knro ELAKASUMTUKI)
	UPDATEMODE=NOMISSINGCHECK;
	BY knro;
	IF C;
	RUN;

%END;

/* 4.6 Yleinen asumistuki */

%IF &ASUMTUKI = 1 %THEN %DO;

	DATA STARTDAT.START_TOIMTUKI_KOTI;
	UPDATE STARTDAT.START_TOIMTUKI_KOTI (IN = C) OUTPUT.&TULOSNIMI_YA (KEEP = knro TUKISUMMA)
	UPDATEMODE=NOMISSINGCHECK;
	BY knro;
	IF C;
	RUN;

%END;

/* 4.7 Lasten päivähoitomaksut */

%IF &PHOITO = 1 %THEN %DO;

	DATA STARTDAT.START_TOIMTUKI_KOTI;
	UPDATE STARTDAT.START_TOIMTUKI_KOTI (IN = C) OUTPUT.&TULOSNIMI_PH (KEEP = knro PHMAKSU_KOK PHMAKSU_OS)
	UPDATEMODE=NOMISSINGCHECK;
	BY knro;
	IF C;
	RUN;

%END;

/* 4.8 Kiinteistöverotus */

%IF &KIVERO = 1 AND &AVUOSI = 2010 %THEN %DO;

	PROC MEANS DATA = OUTPUT.&TULOSNIMI_KV SUM NOPRINT;
	VAR KIVEROYHT2;
	BY knro;
	OUTPUT OUT = TEMP.TOIMTUKI_KIVERO_KOTIT SUM( )=;
	RUN;

	DATA STARTDAT.START_TOIMTUKI_KOTI;
	UPDATE STARTDAT.START_TOIMTUKI_KOTI (IN = C) TEMP.TOIMTUKI_KIVERO_KOTIT (keep = knro KIVEROYHT2)
	UPDATEMODE=NOMISSINGCHECK;
	BY knro;
	IF C;
	RUN;

%END;

%MEND OsaMallit_ToimTuki;

%OsaMallit_ToimTuki;


/* 5. Simulointivaihe */

/* 5.1 Jos parametrit luetaan makromuuttujiksi ennen simulontia, ajetaan tämä makro, erillisajossa */

%MACRO KuukSimul;

%IF &F = S AND &TYYPPI = SIMULX %THEN %DO;

	%HaeParam_ToimTukiSIMUL(&LVUOSI, &LKUUK, &INF);

%END;

%MEND KuukSimul;

%KuukSimul;

/* 5.2 Varsinainen simulointivaihe */

%MACRO ToimTuki_Simuloi_Data;

DATA OUTPUT.&TULOSNIMI_TO;
SET STARTDAT.START_TOIMTUKI_KOTI;

/* 5.2.1 Päätellään käytetäänkö simuloituja tietoja muista osamalleista vai alkuperäisen datan tietoja */

/* Opintotuen asumislisä: data vs. simuloitu */

%IF &OPINTUKI = 0 %THEN %DO; ASUMLISA_SIMUL = ASUMLISA_DATA;%END;
%ELSE %DO; ASUMLISA_SIMUL = ASUMLISA;%END;

/* Toimeentulotukeen vaikuttavat verottomat eläkkeenlisät ja maahanmuuttajan erityistuki: data vs. simuloitu */

%IF &KANSEL = 0 %THEN %DO;
	ELLISAT_SIMUL = ELLISAT_DATA;
	MAMUTUKI_SIMUL = MAMUTUKI_DATA;
%END;
%ELSE %DO; 
	ELLISAT_SIMUL = SUM(LAPSIKOROT,  RILISA, YLIMRILI);
	MAMUTUKI_SIMUL = MMTUKI;
%END;

/* Toimeentulotukeen vaikuttavat lapsilisät: data vs. simuloitu */

%IF &LLISA = 0 %THEN %DO; LLISAT_SIMUL = LLISAT_DATA;%END;
%ELSE %DO; LLISAT_SIMUL = LLISA_HH / 12;%END;

/* Toimeentulotukeen vaikuttavat elatustuet: data vs. simuloitu */

%IF &LLISA = 0 %THEN %DO; ELTUKI_SIMUL = ELTUKI_DATA;%END;
%ELSE %DO; ELTUKI_SIMUL = ELATUSTUET_HH ;%END;

/* Veronalaiset tulonsiirrot: Niiden vaikutus tulee VERO-mallin kautta;
   VERO-mallista haetaan myös veronalaiset pääomatulot, verottomat
   osinkotulot sekä eri verolajit */
		
%IF %SYSFUNC(SUM(&SAIRVAK, &TTURVA, &KANSEL, &OPINTUKI, &KOTIHTUKI, &VERO)) > 0 %THEN %DO; 

	/* Veronalaiset ansiotulot VERO-mallista */
	ANSIOT_SIMUL = ANSIOT;

	/* Veronalaiset pääomatulot VERO-mallista */
	POTULOT_SIMUL = POTULOT;

	/* Kaikki verot ml. sairausvakuutuksen sairaanhoitomaksu */
	MAKSVEROT_SIMUL = SUM(ANSIOVEROT, POVEROB, YLEVERO);

	/* Veronalaisten ansiotulojen verot ml. sairausvakuutuksen sairaanhoitomaksu */
	ANSIOVEROT_SIMUL = ANSIOVEROT;

	/* Työeläke- ja työttömyysvakuutusmaksut */
	PALKVAK_SIMUL = PALKVAK;

	/* Sairausvakuutuksen päivärahamaksut */
	PRAHAMAKSU_SIMUL = PRAHAMAKSU;

	/* Verottomat osinkotulot */
	OSINGOT_VEROVAP_SIMUL = OSINKOVAP;

%END;

%ELSE %DO;

	/* Jos veronalaisten tulonsiirtojen malleja tai VERO-mallia ei
	   ole ajettu, vastaavat tiedot otetaan datasta */
		
	ANSIOT_SIMUL = ANSIOT_DATA;

	POTULOT_SIMUL = POTULOT_DATA;

	MAKSVEROT_SIMUL = MAKSVEROT_DATA;

	ANSIOVEROT_SIMUL = ANSIOVEROT_DATA;

	PALKVAK_SIMUL = PALKVAK_DATA;

	PRAHAMAKSU_SIMUL = PRAHAMAKSU_DATA;

	OSINGOT_VEROVAP_SIMUL = OSINGOT_VEROVAP_DATA;

%END;

/* Eläkkeensaajien asumistuki: data vs. simuloitu */

%IF &ELASUMTUKI = 0 %THEN %DO; ELASUMTUKI_SIMUL = ELASUMTUKI_DATA;%END;
%ELSE %DO; ELASUMTUKI_SIMUL = ELAKASUMTUKI;%END;

/* Yleinen asumistuki: data vs. simuloitu */

%IF &ASUMTUKI = 0 %THEN %DO; ASUMTUKI_SIMUL = ASUMTUKI_DATA;%END;
%ELSE %DO; ASUMTUKI_SIMUL = TUKISUMMA;%END;

/* Harkinnanvaraiset menot (elatusmaksut ja lasten päivähoitomaksut): data vs. simuloitu */

%IF &PHOITO = 0 %THEN %DO; HARKINMENOT_SIMUL = HARKINMENOT_DATA;%END;
%ELSE %DO; HARKINMENOT_SIMUL = SUM((SUM(ELMAKSUT, PHMAKSU_KOK, PHMAKSU_OS) / 12), PHOITO_YKS);%END;

/* Kiinteistövero: data vs. simuloitu */

%IF &KIVERO = 1 AND &AVUOSI = 2010 %THEN %DO; KIVERO_SIMUL = KIVEROYHT2;%END;
%ELSE %DO; KIVERO_SIMUL = KIVERO_DATA; %END;

*Verojen suhteellinen osuus veronalaisista työtuloista;
IF ANSIOT_SIMUL > 0 THEN VERTYOTULOVEROOS = ANSIOVEROT_SIMUL / ANSIOT_SIMUL;
ELSE VERTYOTULOVEROOS = 0;	

*Työtulojen netto-osuus;
TYOTULONETTO = SUM(VERTYOTULO, -VERTYOTULOVEROOS * VERTYOTULO, -PALKVAK_SIMUL, -PRAHAMAKSU_SIMUL, -THANKK, VEROTTYOTULO);

*Työtulojen netto-osuus kuukautta kohden;
TYOTULONETTO = MAX(TYOTULONETTO / 12, 0);

*Veronalaisten ei-työtulojen netto-osuus;
MUUTVERTULOTNETTO = SUM(ANSIOT_SIMUL, -VERTYOTULO, POTULOT_SIMUL, -MAKSVEROT_SIMUL, VERTYOTULOVEROOS * VERTYOTULO);

*Toimeentulotukeen vaikuttavat verovapaat ei-työtulot;
VEROTTUL = SUM(VEROTTUL_MUU, ELTUKI_SIMUL, ELLISAT_SIMUL, MAMUTUKI_SIMUL, ASUMLISA_SIMUL, ELASUMTUKI_SIMUL, ASUMTUKI_SIMUL, OSINGOT_VEROVAP_SIMUL);

*Ei-työtulojen netto-osuus;
MUUTTULOTNETTO =  SUM(MUUTVERTULOTNETTO, VEROTTUL, -SEKALVERO, -KIVERO_SIMUL);

*Muiden tulojen netto-osuus kuukautta kohden;
MUUTTULOTNETTO = MAX(MUUTTULOTNETTO / 12, 0);

/* 5.2.2 Lasketaan toimeentulotuki kotitalouksittain */

%ToimtukiV&F(TOIMTUKIV, &LVUOSI, &INF, 1, 1, ONAIKS, ONAIKLAPSIS,
ONLAPSI17S, ONLAPSI10_16S, ONLAPSIALLE10S, LLISAT_SIMUL, TYOTULONETTO,
MUUTTULOTNETTO, ASUMISKULUT, HARKINMENOT_SIMUL);

TOIMTUKI = KERROIN * (12 * TOIMTUKIV);

KEEP knro paasoss KERROIN ONAIKS ONAIKLAPSIS ONLAPSI17S ONLAPSI10_16S ONLAPSIALLE10S
ASUMLISA_SIMUL ELLISAT_SIMUL MAMUTUKI_SIMUL LLISAT_SIMUL ELTUKI_SIMUL
ANSIOT_SIMUL POTULOT_SIMUL MAKSVEROT_SIMUL ANSIOVEROT_SIMUL PALKVAK_SIMUL PRAHAMAKSU_SIMUL
OSINGOT_VEROVAP_SIMUL ELASUMTUKI_SIMUL ASUMTUKI_SIMUL HARKINMENOT_SIMUL KIVERO_SIMUL
VERTYOTULOVEROOS TYOTULONETTO MUUTVERTULOTNETTO VEROTTUL MUUTTULOTNETTO ASUMISKULUT
TOIMTUKI; 

RUN;

*Siirretään samansuuruinen simuloitu toimeentulotuki kaikille saman talouden henkilöille;
PROC SQL;
CREATE TABLE OUTPUT.&TULOSNIMI_TO
AS SELECT a.hnro, a.knro, b.*
FROM POHJADAT.&AINEISTO&AVUOSI AS a 
LEFT JOIN OUTPUT.&TULOSNIMI_TO AS b ON a.knro = b.knro
ORDER BY knro, hnro;
QUIT;

/* 5.3 Yhdistetään simuloitu data palveluaineistoon (riippuen tulosaineiston laajuden valinnasta) */

DATA OUTPUT.&TULOSNIMI_TO;
	
/* 5.3.1 Suppea tulostiedosto (vain tärkeimmät luokittelumuuttujat) */

%IF &TULOSLAAJ = 1 %THEN %DO; 
	MERGE POHJADAT.&AINEISTO&AVUOSI 
	(KEEP = hnro knro asko htoimtuk &PAINO ikavu ikavuV desmod soss paasoss elivtu koulas rake)
	OUTPUT.&TULOSNIMI_TO;
%END;

/* 5.3.2 Laaja tulostiedosto (palveluaineiston mukainen tulostiedosto) */

%IF &TULOSLAAJ = 2 %THEN %DO; 
	MERGE POHJADAT.&AINEISTO&AVUOSI OUTPUT.&TULOSNIMI_TO;
%END;

BY hnro;

* Poistetaan simuloitu toimeentulotuki muilta kuin talouden viitehenkilöltä;
IF asko NE 1 THEN DO;
	KERROIN = .;
	ONAIKS = .;
	ONAIKLAPSIS = .;
	ONLAPSI17S = .;
	ONLAPSI10_16S = .;
	ONLAPSIALLE10S = .;
	ASUMLISA_SIMUL = .;
	ELLISAT_SIMUL = .;
	MAMUTUKI_SIMUL = .;
	LLISAT_SIMUL = .;
	ELTUKI_SIMUL = .;
	ANSIOT_SIMUL = .;
	POTULOT_SIMUL = .;
	MAKSVEROT_SIMUL = .;
	ANSIOVEROT_SIMUL = .;
	PALKVAK_SIMUL = .;
	PRAHAMAKSU_SIMUL = .;
	OSINGOT_VEROVAP_SIMUL = .;
	ELASUMTUKI_SIMUL = .;
	ASUMTUKI_SIMUL = .;
	HARKINMENOT_SIMUL= .;
	KIVERO_SIMUL = .;
	VERTYOTULOVEROOS = .;
	TYOTULONETTO = .;
	MUUTVERTULOTNETTO = .;
	VEROTTUL = .;
	MUUTTULOTNETTO = .;
	ASUMISKULUT = .;
	TOIMTUKI = 0;
END;

* Datasta saatu toimeentulotuki merkitään henkilölle, joka todellisuudessa tuen saanut;
TOIMTUKIREK = MAX(htoimtuk, 0);

* Poistetaan toimeentulotuki yrittäjiltä tarvittaessa ;
IF &YRIT = 0 THEN DO;
	IF paasoss < 30 THEN TOIMTUKI = 0;
END;

* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukumäärät voidaan laskea suoraan;
ARRAY PISTE 
	TOIMTUKI TOIMTUKIREK;
DO OVER PISTE;
	IF PISTE <= 0 THEN PISTE = .;
END;

* Luodaan simuloiduille ja datan muuttujille selitteet ;
LABEL 
TOIMTUKI = "Kotitalouden toimeentulotuki (e/v), MALLI"  
ASUMLISA_SIMUL = "Kotitalouden opintotuen asumislisä (e/v), MALLI"
ELLISAT_SIMUL = "Kotitalouden toimeentulotukeen vaikuttavat verottomat eläkkeenlisät (e/v), MALLI"
MAMUTUKI_SIMUL = "Kotitalouden saama maahanmuuttajan erityistuki (e/v), MALLI"
LLISAT_SIMUL = "Kotitalouden toimeentulotukeen vaikuttavat lapsilisät (e/v), MALLI"
ELTUKI_SIMUL = "Kotitalouden toimeentulotukeen vaikuttavat elatustuet (e/v), MALLI"
ANSIOT_SIMUL = "Kotitalouden Veronalaiset ansiotulot (e/v), MALLI"
POTULOT_SIMUL = "Kotitalouden veronalaiset pääomatulot(e/v), MALLI"
MAKSVEROT_SIMUL = "Kotitalouden kaikki verot ml. sairausvakuutuksen sairaanhoitomaksu (e/v), MALLI"
ANSIOVEROT_SIMUL = "Kotitalouden veronalaisten ansiotulojen verot ml. sairausvakuutuksen sairaanhoitomaksu (e/v), MALLI"
PALKVAK_SIMUL = "Kotitalouden työeläke- ja työttömyysvakuutusmaksut (e/v), MALLI"
PRAHAMAKSU_SIMUL = "Kotitalouden sairausvakuutuksen päivärahamaksut (e/v), MALLI"
OSINGOT_VEROVAP_SIMUL = "Kotitalouden verottomat osinkotulot (e/v), MALLI"
ELASUMTUKI_SIMUL = "Kotitalouden eläkkeensaajien asumistuki (e/v), MALLI"
ASUMTUKI_SIMUL = "Kotitalouden yleinen asumistuki (e/v), MALLI"
HARKINMENOT_SIMUL= "Kotitalouden harkinnanvaraiset menot (elatusmaksut ja lasten päivähoitomaksut) (e/v), MALLI"
KIVERO_SIMUL = "Kotitalouden kiinteistövero (e/v), MALLI"
VERTYOTULOVEROOS = "Kotitalouden verojen suhteellinen osuus veronalaisista työtuloista, MALLI"
TYOTULONETTO = "Kotitalouden työtulojen netto-osuus (e/kk), MALLI"
MUUTVERTULOTNETTO = "Kotitalouden veronalaisten ei-työtulojen netto-osuus (e/v), MALLI"
VEROTTUL = "Kotitalouden toimeentulotukeen vaikuttavat verovapaat ei-työtulot (e/v), MALLI"
MUUTTULOTNETTO = "Kotitalouden muiden tulojen netto-osuus kuukautta kohden (e/kk), MALLI"
TOIMTUKIREK = "Toimeentulotuki (e/v), DATA";

DROP htoimtuk;

RUN;

%MEND ToimTuki_Simuloi_Data;

%ToimTuki_Simuloi_Data;

%LET loppui2&malli = %SYSFUNC(TIME());


/* 6. Luodaan summatason tulostaulukot (optio) 
	  HUOM! Toimeentulotuki simuloidaan aina kotitaloustasolla ja simuloitu toimeentulotuki viedään kotitalouden viitehenkilölle. 
	        Datasta saatu toimeentulotuki on aina sen henkilön kohdalla, joka on sen todellisuudessa saanut. */

%MACRO ToimTuki_Tulokset;

/* 6.1 Kotitaloustason tulokset (optio) */

/* 6.1.1 Mikrotason tulosaineiston summaus kotitaloustasolle (optio) */

%IF &YKSIKKO = 2 AND &START NE 1 %THEN %DO; 

	PROC SUMMARY DATA=OUTPUT.&TULOSNIMI_TO (DROP = hnro);
	BY knro ;
	ID &PAINO ikavuV desmod paasoss elivtu koulas rake;
	VAR &MUUTTUJAT _NUMERIC_;
	OUTPUT OUT = OUTPUT.&TULOSNIMI_TO (DROP = soss ikavu _TYPE_ _FREQ_)  SUM = ;
	RUN;

%END;

/* 6.1.2 Summatason tulostaulukko (optio) */

%IF &TULOKSET = 1 %THEN %DO;

	%IF &YKSIKKO = 2 %THEN %DO; 

		/* Siirretään tiedot Exceliin (optio) */

		%IF &EXCEL = 1 %THEN %DO;

			ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_TO._SUMMAT.xls" STYLE = MINIMAL;

		%END;

		PROC MEANS DATA=OUTPUT.&TULOSNIMI_TO &SUMWGT &SUM &MIN &MAX &RANGE &MEAN &MEDIAN &MODE &STD &VAR &CV NONOBS ORDER=DATA NWAY MAXDEC = 0; 
		TITLE "TUNNUSLUVUT (KOTITALOUSTASO), &MALLI";
		CLASS &LUOK_KOTI1 &LUOK_KOTI2 &LUOK_KOTI3 / MLF PRELOADFMT;
		VAR &MUUTTUJAT ;
		FORMAT _NUMERIC_ tuhat. ;
		%DO I = 1 %TO 3; 
		%IF %LENGTH (&&LUOK_KOTI&I) >0 %THEN %DO;
			FORMAT &&LUOK_KOTI&I &&LUOK_KOTI&I... ;
		%END;%END;
		OUTPUT OUT = OUTPUT.&TULOSNIMI_TO._SUMMAT (DROP = _TYPE_ _FREQ_)
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
	
	/* 6.2 Henkilötason tulokset (oletus) */

	%ELSE %DO;

		/* Siirretään tiedot Exceliin (optio) */

		%IF &EXCEL = 1 %THEN %DO;

			ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_TO._SUMMAT.xls" STYLE = MINIMAL;

		%END;

		PROC MEANS DATA=OUTPUT.&TULOSNIMI_TO &SUMWGT &SUM &MIN &MAX &RANGE &MEAN &MEDIAN &MODE &STD &VAR &CV NONOBS ORDER=DATA NWAY MAXDEC = 0;
		TITLE "TUNNUSLUVUT (HENKILÖTASO), &MALLI";
		CLASS &LUOK_HLO1 &LUOK_HLO2 &LUOK_HLO3 / MLF PRELOADFMT;
		VAR &MUUTTUJAT ;
		FORMAT _NUMERIC_ tuhat. ;
		%DO I = 1 %TO 3; 
		%IF %LENGTH (&&LUOK_HLO&I) >0 %THEN %DO;
			FORMAT &&LUOK_HLO&I &&LUOK_HLO&I... ;
		%END;%END;
		OUTPUT OUT = OUTPUT.&TULOSNIMI_TO._SUMMAT (DROP = _TYPE_ _FREQ_)
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

%MEND ToimTuki_Tulokset;

%ToimTuki_Tulokset;


/* 7. Mitataan kuinka kauan osavaiheisiin kului aikaa */

%LET loppui1 = %SYSFUNC(TIME());

%LET loppui1&malli = %SYSFUNC(TIME());

%LET kului1&malli = %SYSEVALF(&&loppui1&malli - &&alkoi1&malli);

%LET kului2&malli = %SYSEVALF(&&loppui2&malli - &&alkoi2&malli);

%LET kului1&malli = %SYSFUNC(PUTN(&&kului1&malli, time10.2));

%LET kului2&malli = %SYSFUNC(PUTN(&&kului2&malli, time10.2));


%PUT &malli. Koko laskenta. Aikaa kului (hh:mm:ss.00) &&kului1&malli;

%PUT &malli. Varsinainen simulointi. Aikaa kului (hh:mm:ss.00) &&kului2&malli;

