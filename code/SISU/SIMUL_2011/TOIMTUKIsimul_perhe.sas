/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hy�dynt�� Tilastokeskuksen yleisten
* k�ytt�ehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto p��hakemistossa.
******************************************************************************/

/********************************************************************************************************
* Kuvaus: Toimeentulotuen simulointimalli 2011 (perhekohtainen simulointikokeilu)				        *
* Tekij�: Elina Ahola / KELA																			*
* Luotu: 07.09.2011																						*
* Viimeksi p�ivitetty: 19.05.2013																		*
* P�ivitt�j�: Elina Ahola / KELA 																		*
********************************************************************************************************/


/* 0. Yleisi� vakioiden m��rittelyj� (�l� muuta n�it�!) */

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
		
	/* Jos mallia k�ytet��n k�ytt�liittym�st� (&EG = 1), niin seuraavia vaiheita ei ajeta */

	%IF &EG NE 1 %THEN %DO;

	%LET AVUOSI = 2011;		* Aineistovuosi (vvvv);

	%LET LVUOSI = 2011;		* Lains��d�nt�vuosi (vvvv);

	%LET TYYPPI = SIMUL;	* Parametrien hakutyyppi: SIMUL (vuosikeskiarvo) tai SIMULX (parametrit haetaan tietylle kuukaudelle);

	%LET LKUUK = 12;        * Lains��d�nt�kuukausi, jos parametrit haetaan tietylle kuukaudelle;

	%LET AINEISTO = PALV ;  * K�ytett�v� aineisto (PALV = Palveluaineisto, REK = Rekisteriaineisto);

	%LET TULOSNIMI_TO = toimtuki_simul_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi;

	/* Simuloidaanko toimeentulotuki my�s yritt�j�talouksille.
  	   Jos toimeentulotukea ei simuloida yritt�j�talouksille, t�m� on 0.
       Jos toimeentulotuki simuloidaan yritt�j�talouksille, t�m� on 1. */

	%LET YRIT = 0;

	* Inflaatiokorjaus. Parametrien deflatoinnissa k�ytett�v�n kertoimen voi sy�tt�� itse
	  INF-makromuuttujaan (HUOM! desimaalit erotettava pisteell� .). Jos puolestaan haluaa k�ytt�� automaattista 
	  elinkustannusindeksiin perustuvaa parametrien muunnoskerrointa, 
	  tulee INF-makromuuttujalle antaa arvoksi 999.; 	

	%LET INF = 1.00; * Sy�t� arvo tai 999;
	%LET PINDEKSI_VUOSI = pindeksi_vuosi; *K�ytett�v� indeksien parametritaulukko;		

	* Ajettavat osavaiheet ; 

	%LET LAKIMAKROT = 1;    				* Lakimakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
	%LET LAKIMAK_TIED_TO = TOIMTUKIlakimakrot;	* Lakimakroissa k�ytett�v�n tiedoston nimi;
	%LET LAKIMAK_TIED_OT = OPINTUKIlakimakrot;
	%LET APUMAKROT = 1;   					* Apumakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
	%LET APUMAK_TIED_TO = TOIMTUKIapumakrot; 	* Apumakroissa k�ytett�v�n tiedoston nimi;
	%LET APUMAK_TIED_OT = OPINTUKIapumakrot;
	%LET POIMINTA = 1;  					* Muuttujien poiminta (1 jos ajetaan, 0 jos ei);
	%LET TULOKSET = 1;						* Yhteenvetotaulukot (1 jos ajetaan, 0 jos ei);

	* K�ytett�vien parametritiedostojen nimet ;

	%LET PTOIMTUKI = ptoimtuki;
	%LET POPINTUKI = popintuki;

	* Tulostaulukoiden esivalinnat ; 

	%LET TULOSLAAJ = 1 ; 	 				* Mikrotason tulosaineiston laajuus (1=suppea, 2 = laaja (palveluaineisto));
	%LET MUUTTUJAT = TOIMTUKI TOIMTUKIREK ; * Taulukoitavat muuttujat (summataulukot) ;
	%LET YKSIKKO = 1;		 * Tulostaulukoiden yksikk� (1 = henkil�, 2 = kotitalous) ;
	%LET LUOK_HLO1 = desmod; * Taulukoinnin 1. henkil�luokitus (jos YKSIKKO = 1)
							   Vaihtoehtoina: 
							     desmod (tulodesiilit, ekvivalentit tulot (modoecd), hl�painot)
							     ikavu (henkil�n mukaiset ik�ryhm�t)
							     elivtu (kotitalouden elinvaihe)
							     koulas (henkil�n koulutusaste TK1997)
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

	%LET EXCEL = 0; 		  * Vied��nk� tulostaulukko automaattisesti Exceliin (1 = Kyll�, 0 = Ei);

	* Laskettavat tunnusluvut (jos tyhj�, niin ei lasketa);
	%LET SUMWGT = SUMWGT; * N eli lukum��r�t ;
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

	%LET PAINO = ykor ; 	* K�ytett�v� painokerroin (jos tyhj�, niin lasketaan painottamattomana);
	%LET RAJAUS =  ; 		* Rajauslause tunnuslukujen laskentaan (jos tyhj�, niin ei rajauksia);

	%END;

	/* Voiko kotona asuvilla v�hint��n 18-vuotiailla lapsilla olla asumiskustannuksia.
	   Jos ei voi olla, t�m� on 0.
	   Jos voi olla, t�m� on 1. */

	%LET KOTASU = 0; 

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

	/* 3.1 Poimitaan tarvittavat palveluaineiston muuttujat taulukkoon TEMP.TOIMTUKI_HENKI_POIMINTA */

	DATA TEMP.TOIMTUKI_HENKI_POIMINTA;
	SET POHJADAT.&AINEISTO&AVUOSI;
	KEEP hnro knro jasen puoliso aiti isa
	ikakk ikavu svatva svatvp verot ltvp
    lahdever omakkiiv elama korotv
	llmk kokorve kellaps rili riyl
	amstipe hsotav hasepr elasa rahsa
	ulkelve ulkelmuu hsotvkor hastuki hasuli maksvuok
	kaytkorv yhtiovas lisalamm omalamm omamaks
	tontvuok aslaikor sahko apuraha
	hlakav vtyomj vthm vmatk vevm lpvma
	tnoosvvb teinovvb tuosvvap topkb
	topkver teinovv lassa muusa paasoss
	hulkpa trpl trplkor tulkp tulkp6 tmpt
	tkust tepalk tmeri tlue2 tpalv trespa
	tpturva tpalv2 telps1 telps2
	telps5 ttyoltuk	tmaat1 tmaat1p 
	tliik1 tliikp tporo1 tyhtat
	tyhthav hoiaikak hoimaksk 
	hoiaikao hoimakso hoiaikay hoimaksy
	hoiaikap hoimaksp opirake opirako tukiaika optukk
	lbeltuki lbdpperi aemkm
	varm asko lveru
	anstukor mamutuki tpjta;
	RUN;

	/* 3.2 Tarvittavat henkil�tason muuttujat */

	/* 3.2.1 Lasketaan taulukkoon TEMP.TOIMTUKI_HENKI_MUOK3 jokaiselle henkil�lle niiden h�nen lastensa m��r�, jotka asuvat samassa kotitaloudessa */

	PROC SQL;
		CREATE TABLE TEMP.TOIMTUKI_HENKI_MUOK1
		AS SELECT a.hnro, b.hnro AS HNRO_LAPSI
		FROM TEMP.TOIMTUKI_HENKI_POIMINTA AS a
		LEFT JOIN TEMP.TOIMTUKI_HENKI_POIMINTA AS b	ON (a.knro = b.knro AND (a.jasen = b.aiti OR a.jasen = b.isa));
	QUIT;
	PROC SQL;
		CREATE TABLE TEMP.TOIMTUKI_HENKI_MUOK2
		AS SELECT hnro, COUNT(HNRO_LAPSI) AS LAPSIAKOT
		FROM TEMP.TOIMTUKI_HENKI_MUOK1
		GROUP BY hnro;
	QUIT;
	PROC SQL;
		CREATE TABLE TEMP.TOIMTUKI_HENKI_MUOK3
		AS SELECT a.*, b.LAPSIAKOT
		FROM TEMP.TOIMTUKI_HENKI_POIMINTA AS a, TEMP.TOIMTUKI_HENKI_MUOK2 AS b
		WHERE a.hnro = b.hnro;
	QUIT;

	/* 3.2.2 Muokataan henkil�tasoisia tietoja taulukkoon TEMP.TOIMTUKI_HENKI_MUOK4 */
	 
	DATA TEMP.TOIMTUKI_HENKI_MUOK4;
	SET TEMP.TOIMTUKI_HENKI_MUOK3;

	* Rajoitetaan ilmoitetut matkakulut verotuksessa hyv�ksytt�v��n maksimiin (ml. omavastuu)
	  rekisteriaineiston poikkeavien havaintojen vuoksi;
	VMATKR = MIN(SUM(vmatk, 0), 7600);

	* Ik�ryhmittely;
	IF (ikavu = . ) OR (ikavu >= 18 AND aiti = 0 AND isa = 0) OR (puoliso NE 0 OR LAPSIAKOT NE 0) THEN ONAIK = 1;
	ELSE ONAIK = 0;

	IF ikavu >= 18 AND (aiti NE 0 OR isa NE 0) AND puoliso = 0 AND LAPSIAKOT = 0 THEN ONAIKLAPSI = 1;
	ELSE ONAIKLAPSI = 0; 

	IF ikavu = 17 AND puoliso = 0 AND LAPSIAKOT = 0 THEN ONLAPSI17 = 1;
	ELSE ONLAPSI17 = 0;

	IF ikavu >= 10 AND ikavu < 17 AND puoliso = 0 AND LAPSIAKOT = 0 THEN ONLAPSI1016 = 1;
	ELSE ONLAPSI1016 = 0;

	IF ikavu >= 0 AND ikavu < 10 AND puoliso = 0 AND LAPSIAKOT = 0 THEN ONLAPSIALLE10 = 1;
	ELSE ONLAPSIALLE10 = 0;

	* Niiden kuukausien osuus, jona henkil� ei ole ollut armeijassa tai siviilipalveluksessa;
	EIAMSI = (12-varm)/12;

	* Veronalainen ty�tulo;
	VERTYOTULO = SUM(trpl, trplkor, MAX(tulkp - tulkp6, 0), tmpt, tkust,
			tepalk, tmeri, tlue2, tpalv, trespa, tpturva, tpalv2, telps1,
			telps2, telps5, ttyoltuk, tmaat1, tmaat1p, tpjta, tliik1,
			tliikp, tporo1, tyhtat, tyhthav, anstukor);

	* Verovapaa ty�tulo;
	VEROTONTYOTULO = SUM(tulkp6, hulkpa);	

	* P�iv�hoitomaksut yhteens�;
	PHOITOKAIKKI = SUM(hoiaikak * hoimaksk, hoiaikao * hoimakso,
			hoiaikay * hoimaksy, hoiaikap * hoimaksp);

	* Yksityiset p�iv�hoitomaksut;
	PHOITOYKS = SUM(hoiaikay * hoimaksy, hoiaikap * hoimaksp);

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

	* Katsotaan sitten, saadaanko tukiaikaa p��telty� opintorahan perusteella;

	* Lasketaan opintorahan kannalta relevantti ik�;
	OPIKAKUUKAUSINA = 12 * ikavu + ikakk;
	IF OPIKAKUUKAUSINA < 222 THEN OPIKA = 17;
	ELSE IF OPIKAKUUKAUSINA < 246 THEN OPIKA = 19;
	ELSE OPIKA = ikavu;

	* A. T�ysim��r�inen opintoraha keskiasteella;

	* A.1. Ei asu vanhempien kanssa;
	%OpRahaV&F(TOPINTOKESKEV, &AVUOSI, 1, 0, 0, OPIKA, 0, 0, 0, 0);
	* A.2. Asuu vanhempien kanssa;
	%OpRahaV&F(TOPINTOKESKV, &AVUOSI, 1, 0, 1, OPIKA, 0, 0, 0, 0);

	* B. T�ysim��r�inen opintoraha korkea-asteella;

	* B.1. Ei asu vanhempien kanssa;
	%OpRahaV&F(TOPINTOKORKEV, &AVUOSI, 1, 1, 0, OPIKA, 0, 0, 0, 0);
	* B.2. Asuu vanhenpien kanssa;
	%OpRahaV&F(TOPINTOKORKV, &AVUOSI, 1, 1, 1, OPIKA, 0, 0, 0, 0);

	* Katsotaan, vastaako saatu opintoraha jotakin t�ysim��r�isen opintorahan monikertaa.
	Jos vastaa, korvataan optukk-muuttujan perusteella saatu arvo t�ll� uudella arvolla.;
	DO i = 1 TO 12;
		IF opirake = (i * TOPINTOKESKEV) THEN OPAIKAKESK = i;
		IF opirake = (i * TOPINTOKESKV) THEN OPAIKAKESK = i;
		IF opirako = (i * TOPINTOKORKEV) THEN OPAIKAKORK = i;
		IF opirako = (i * TOPINTOKORKV) THEN OPAIKAKORK = i;
	END;
		
	* Potentiaalinen opintolaina;
	%OpLainaV&F(OPLAINAKESK, &AVUOSI, &INF, 0, 0, OPIKA);
	%OpLainaV&F(OPLAINAKORK, &AVUOSI, &INF, 1, 0, OPIKA);

	OPINTOLAINA = SUM(OPAIKAKESK * OPLAINAKESK, OPAIKAKORK * OPLAINAKORK); 

	KEEP hnro VMATKR EIAMSI ONAIK ONAIKLAPSI ONLAPSI17 ONLAPSI1016 ONLAPSIALLE10 VERTYOTULO VEROTONTYOTULO PHOITOKAIKKI PHOITOYKS OPINTOLAINA;

	RUN;

	/* 3.2.3 Jaetaan kotitaloustasoiset er�t henkil�iden m��r�ll� ja tallennetaan saadut luvut taulukkoon TEMP.TOIMTUKI_KOTI_HENKIKOHTI */

	PROC SQL;
		CREATE TABLE TEMP.TOIMTUKI_KOTI_HENKIKOHTI
		AS SELECT knro,
			SUM(kokorve) / COUNT(hnro) AS KOKORVEJ,
			SUM(lahdever) / COUNT(hnro)  AS LAHDEVERJ,
			SUM(omakkiiv) / COUNT(hnro) AS OMAKKIIVJ,
			SUM(elasa) / COUNT(hnro) AS ELASAJ, 
			SUM(rahsa) / COUNT(hnro) AS RAHSAJ,
			SUM(lassa) / COUNT(hnro) AS LASSAJ, 
			SUM(muusa) / COUNT(hnro) AS MUUSAJ,
			SUM(maksvuok) / COUNT(hnro) AS MAKSVUOKJ,
			SUM(kaytkorv) / COUNT(hnro) AS KAYTKORVJ,
			SUM(yhtiovas) / COUNT(hnro) AS YHTIOVASJ,
			SUM(aslaikor) / COUNT(hnro) AS ASLAIKORJ,
			SUM(lisalamm) / COUNT(hnro) AS LISALAMMJ,
			SUM(omalamm) / COUNT(hnro) AS OMALAMMJ,
			SUM(omamaks) / COUNT(hnro) AS OMAMAKSJ,
			SUM(sahko) / COUNT(hnro) AS SAHKOJ,
			SUM(tontvuok) / COUNT(hnro) AS TONTVUOKJ
		FROM TEMP.TOIMTUKI_HENKI_POIMINTA
		GROUP BY knro;
	QUIT;

	/* 3.2.4 M��ritet��n toimeentulotukilain mukaiset perheet */

	/* 3.2.4.1 M��ritet��n puolisot, �idit ja is�t hnro-tunnuksilla taulukkoon TEMP.TOIMTUKI_HENKI_PERHEMAARITYS1 */

	PROC SQL;
		CREATE TABLE TEMP.TOIMTUKI_HENKI_PERHEMAARITYS1
		AS SELECT a.hnro, b.hnro AS HNRO_PUOLISO, c.hnro AS HNRO_AITI, d.hnro AS HNRO_ISA
		FROM TEMP.TOIMTUKI_HENKI_MUOK3 AS a
		LEFT JOIN TEMP.TOIMTUKI_HENKI_MUOK3 AS b ON (a.knro = b.knro AND a.puoliso NE 0 AND a.puoliso = b.jasen)
		LEFT JOIN TEMP.TOIMTUKI_HENKI_MUOK3 AS c ON (a.knro = c.knro AND a.puoliso = 0 AND a.LAPSIAKOT = 0 AND a.aiti NE 0 AND a.ikavu < 18 AND a.aiti = c.jasen)
		LEFT JOIN TEMP.TOIMTUKI_HENKI_MUOK3 AS d ON (a.knro = d.knro AND a.puoliso = 0 AND a.LAPSIAKOT = 0 AND a.isa NE 0 AND a.ikavu < 18 AND a.isa = d.jasen);
	QUIT;

	/* 3.2.4.2 Muodostetaan yksinel�vist� ja pariskunnista perheille pohjat taulukkoon TEMP.TOIMTUKI_HENKI_PERHEMAARITYS2 */

	DATA TEMP.TOIMTUKI_HENKI_PERHEMAARITYS2;
		SET TEMP.TOIMTUKI_HENKI_PERHEMAARITYS1;
		TOIMPERHE_APU = MAX(hnro, HNRO_PUOLISO);
		WHERE HNRO_AITI = . AND HNRO_ISA = .;
		DROP HNRO_PUOLISO;
	RUN;

	/* 3.2.4.3 Lis�t��n lapset perheiden pohjiin taulukkoon TEMP.TOIMTUKI_HENKI_PERHEMAARITYS3 */

	PROC SQL;
		CREATE TABLE TEMP.TOIMTUKI_HENKI_PERHEMAARITYS3
		AS SELECT a.hnro, b.TOIMPERHE_APU AS TOIMPERHE_APU1, c.TOIMPERHE_APU AS TOIMPERHE_APU2, d.TOIMPERHE_APU AS TOIMPERHE_APU3	
		FROM TEMP.TOIMTUKI_HENKI_PERHEMAARITYS1 AS a
		LEFT JOIN TEMP.TOIMTUKI_HENKI_PERHEMAARITYS2 AS b ON (a.hnro = b.hnro)
		LEFT JOIN TEMP.TOIMTUKI_HENKI_PERHEMAARITYS2 AS c ON (a.HNRO_AITI = c.hnro)
		LEFT JOIN TEMP.TOIMTUKI_HENKI_PERHEMAARITYS2 AS d ON (a.HNRO_ISA = d.hnro);
	QUIT;

	DATA TEMP.TOIMTUKI_HENKI_PERHEMAARITYS3;
		SET TEMP.TOIMTUKI_HENKI_PERHEMAARITYS3;
		TOIMPERHE_APU = MAX(TOIMPERHE_APU1, TOIMPERHE_APU2, TOIMPERHE_APU3);
		DROP TOIMPERHE_APU1 TOIMPERHE_APU2 TOIMPERHE_APU3;
	RUN;

	/* 3.2.4.4 Muokataan perheen tunnusta ja poistetaan turhat muuttujat taulukossa TEMP.TOIMTUKI_HENKI_PERHEMAARITYS3*/

	PROC SORT DATA = TEMP.TOIMTUKI_HENKI_PERHEMAARITYS3;
		BY TOIMPERHE_APU;
	RUN;

	DATA TEMP.TOIMTUKI_HENKI_PERHEMAARITYS3;
		SET TEMP.TOIMTUKI_HENKI_PERHEMAARITYS3;
		RETAIN TOIMPERHE;
		TOIMPERHE_APU_LAG = LAG(TOIMPERHE_APU);
		IF _N_ = 1 THEN TOIMPERHE = 1;
		ELSE IF TOIMPERHE_APU = TOIMPERHE_APU_LAG THEN TOIMPERHE = TOIMPERHE;
		ELSE TOIMPERHE = TOIMPERHE + 1;
		DROP TOIMPERHE_APU TOIMPERHE_APU_LAG;
	RUN;

	/* 3.2.5 M��ritet��n tulojen ja menojen jakoa varten perheet my�s niin, ett� aikuiset lapst kuuluvat perheeseen.
			 Kutsutaan n�it� perheit� aikuislapsiperheiksi. */

	/* 3.2.5.1 M��ritet��n puolisot, �idit ja is�t hnro-tunnuksilla taulukkoon TEMP.TOIMTUKI_HENKI_PERHEMAARITYS1_2 */

	PROC SQL;
		CREATE TABLE TEMP.TOIMTUKI_HENKI_PERHEMAARITYS1_2
		AS SELECT a.hnro, b.hnro AS HNRO_PUOLISO, c.hnro AS HNRO_AITI, d.hnro AS HNRO_ISA
		FROM TEMP.TOIMTUKI_HENKI_MUOK3 AS a
		LEFT JOIN TEMP.TOIMTUKI_HENKI_MUOK3 AS b ON (a.knro = b.knro AND a.puoliso NE 0 AND a.puoliso = b.jasen)
		LEFT JOIN TEMP.TOIMTUKI_HENKI_MUOK3 AS c ON (a.knro = c.knro AND a.puoliso = 0 AND a.LAPSIAKOT = 0 AND a.aiti NE 0 AND a.aiti = c.jasen)
		LEFT JOIN TEMP.TOIMTUKI_HENKI_MUOK3 AS d ON (a.knro = d.knro AND a.puoliso = 0 AND a.LAPSIAKOT = 0 AND a.isa NE 0 AND a.isa = d.jasen);
	QUIT;

	/* 3.2.5.2 Muodostetaan yksinel�vist� ja pariskunnista perheille pohjat taulukkoon TEMP.TOIMTUKI_HENKI_PERHEMAARITYS2_2 */

	DATA TEMP.TOIMTUKI_HENKI_PERHEMAARITYS2_2;
		SET TEMP.TOIMTUKI_HENKI_PERHEMAARITYS1_2;
		TOIMPERHE_APU = MAX(hnro, HNRO_PUOLISO);
		WHERE HNRO_AITI = . AND HNRO_ISA = .;
		DROP HNRO_PUOLISO;
	RUN;

	/* 3.2.5.3 Lis�t��n lapset perheiden pohjiin taulukkoon TEMP.TOIMTUKI_HENKI_PERHEMAARITYS3_2 */

	PROC SQL;
		CREATE TABLE TEMP.TOIMTUKI_HENKI_PERHEMAARITYS3_2
		AS SELECT a.hnro, b.TOIMPERHE_APU AS TOIMPERHE_APU1, c.TOIMPERHE_APU AS TOIMPERHE_APU2, d.TOIMPERHE_APU AS TOIMPERHE_APU3	
		FROM TEMP.TOIMTUKI_HENKI_PERHEMAARITYS1_2 AS a
		LEFT JOIN TEMP.TOIMTUKI_HENKI_PERHEMAARITYS2_2 AS b ON (a.hnro = b.hnro)
		LEFT JOIN TEMP.TOIMTUKI_HENKI_PERHEMAARITYS2_2 AS c ON (a.HNRO_AITI = c.hnro)
		LEFT JOIN TEMP.TOIMTUKI_HENKI_PERHEMAARITYS2_2 AS d ON (a.HNRO_ISA = d.hnro);
	QUIT;

	DATA TEMP.TOIMTUKI_HENKI_PERHEMAARITYS3_2;
		SET TEMP.TOIMTUKI_HENKI_PERHEMAARITYS3_2;
		TOIMPERHE_APU = MAX(TOIMPERHE_APU1, TOIMPERHE_APU2, TOIMPERHE_APU3);
		DROP TOIMPERHE_APU1 TOIMPERHE_APU2 TOIMPERHE_APU3;
	RUN;

	/* 3.2.5.4 Muokataan perheen tunnusta ja poistetaan turhat muuttujat taulukossa TEMP.TOIMTUKI_HENKI_PERHEMAARITYS3_2*/

	PROC SORT DATA = TEMP.TOIMTUKI_HENKI_PERHEMAARITYS3_2;
		BY TOIMPERHE_APU;
	RUN;

	DATA TEMP.TOIMTUKI_HENKI_PERHEMAARITYS3_2;
		SET TEMP.TOIMTUKI_HENKI_PERHEMAARITYS3_2;
		RETAIN TOIMPERHE;
		TOIMPERHE_APU_LAG = LAG(TOIMPERHE_APU);
		IF _N_ = 1 THEN TOIMPERHE = 1;
		ELSE IF TOIMPERHE_APU = TOIMPERHE_APU_LAG THEN TOIMPERHE = TOIMPERHE;
		ELSE TOIMPERHE = TOIMPERHE + 1;
		DROP TOIMPERHE_APU TOIMPERHE_APU_LAG;
	RUN;

	/* 3.2.6 Yhdistet��n kaikki henkil�tasoiset tiedot taulukkoon STARTDAT.START_TOIMTUKI_PERHE_HENKI */

	PROC SQL;
		CREATE TABLE STARTDAT.START_TOIMTUKI_PERHE_HENKI
		AS SELECT a.*, b.*, c.*, d.TOIMPERHE, e.TOIMPERHE AS TOIMPERHE_AIKLAP
		FROM TEMP.TOIMTUKI_HENKI_POIMINTA AS a, TEMP.TOIMTUKI_HENKI_MUOK4 AS b, TEMP.TOIMTUKI_KOTI_HENKIKOHTI AS c,
			TEMP.TOIMTUKI_HENKI_PERHEMAARITYS3 AS d, TEMP.TOIMTUKI_HENKI_PERHEMAARITYS3_2 AS e
		WHERE a.hnro = b.hnro AND a.knro = c.knro AND a.hnro = d.hnro AND a.hnro = e.hnro;
	QUIT;

	/* 3.3 Tarvittavat perhetason muuttujat */

	/* 3.3.1 M��ritet��n perhetasoisia tietoja taulukkoon TEMP.TOIMTUKI_PERHE_MUOK1 */

	PROC SQL;
	CREATE TABLE TEMP.TOIMTUKI_PERHE_MUOK1
	AS SELECT TOIMPERHE,
		TOIMPERHE_AIKLAP,
		knro,
		paasoss,
		COUNT(hnro) AS PERHEKOKO,
		MIN(asko) AS ASKOMIN,
		MIN(hnro) AS HNROMIN,
		SUM(svatva) AS SVATVAS,
		SUM(svatvp) AS SVATVPS,
		SUM(hastuki) AS HASTUKIS,
		SUM(hasuli) AS HASULIS,
		SUM(aemkm) AS AEMKMS,
		SUM(llmk) AS LLMKS,	
		SUM(kellaps) AS KELLAPSS,
		SUM(rili) AS RILIS,
		SUM(riyl) AS RIYLS,
		SUM(amstipe) AS AMSTIPES,
		SUM(hlakav) AS HLAKAVS,
		SUM(SUM(ulkelve, ulkelmuu)) AS MUULKTUS,
		SUM(hsotvkor) AS HSOTVKORS,
		SUM(hsotav) AS HSOTAVS,
		SUM(verot) AS VEROTS,
		SUM(ltvp) AS LTVPS,
		SUM(vevm) AS VEVMS,
		SUM(lpvma) AS LPVMAS,	
		SUM(elama) AS ELAMAS,
		SUM(korotv) AS KOROTVS,
		SUM(apuraha) AS APURAHAS, 
		SUM(vtyomj) AS VTYOMJS,
		SUM(vthm) AS VTHMS,
		SUM(tnoosvvb) AS TNOOSVVBS,
		SUM(teinovvb) AS TEINOVVBS,
		SUM(tuosvvap) AS TUOSVVAPS,
		SUM(topkb) AS TOBKBS,
		SUM(topkver) AS TOPKVERS, 
		SUM(teinovv) AS TEINOVVS,	
		SUM(hasepr) AS HASEPRS,
		SUM(lbeltuki) AS LBELTUKIS,
		SUM(lbdpperi) AS LBDPPERIS,
		SUM(lveru) AS LVERUS,
		SUM(mamutuki) AS MAMUTUKIS,
		SUM(VMATKR) AS VMATKRS,
		SUM(EIAMSI) AS EIAMSIS,
		SUM(ONAIK) AS ONAIKS,
		SUM(ONAIKLAPSI) AS ONAIKLAPSIS,
		SUM(ONLAPSI17) AS ONLAPSI17S,
		SUM(ONLAPSI1016) AS ONLAPSI1016S,
		SUM(ONLAPSIALLE10) AS ONLAPSIALLE10S,
		SUM(VERTYOTULO) AS VERTYOTULOS,
		SUM(VEROTONTYOTULO) AS VEROTONTYOTULOS,
		SUM(PHOITOKAIKKI) AS PHOITOKAIKKIS,
		SUM(PHOITOYKS) AS PHOITOYKSS,
		SUM(OPINTOLAINA) AS OPINTOLAINAS,
		SUM(KOKORVEJ) AS KOKORVEJS,
		SUM(LAHDEVERJ) AS LAHDEVERJS,
		SUM(OMAKKIIVJ) AS OMAKKIIVJS,
		SUM(ELASAJ) AS ELASAJS, 
		SUM(RAHSAJ) AS RAHSAJS,
		SUM(LASSAJ) AS LASSAJS, 
		SUM(MUUSAJ) AS MUUSAJS
	FROM STARTDAT.START_TOIMTUKI_PERHE_HENKI
	GROUP BY TOIMPERHE, TOIMPERHE_AIKLAP, knro, paasoss;
	QUIT;

	/* 3.3.2 M��ritet��n aikuislapsiperhetasoisia tietoja taulukkoon TEMP.TOIMTUKI_PERHE_AIKLAP */

	PROC SQL;
	CREATE TABLE TEMP.TOIMTUKI_PERHE_AIKLAP
	AS SELECT TOIMPERHE_AIKLAP,
		COUNT(hnro) AS PERHEKOKO_AIKLAP
	FROM STARTDAT.START_TOIMTUKI_PERHE_HENKI
	GROUP BY TOIMPERHE_AIKLAP;
	QUIT;

	/* 3.3.3 M��ritet��n kotitaloustasoisia tietoja taulukkoon TEMP.TOIMTUKI_KOTI */

	PROC SQL;
	CREATE TABLE TEMP.TOIMTUKI_KOTI
	AS SELECT knro,
		SUM(ONAIK) AS ONAIKSK
	FROM STARTDAT.START_TOIMTUKI_PERHE_HENKI
	GROUP BY knro;
	QUIT;

	/* 3.3.4 Yhdistet��n nelj� edellist� taulukkoa taulukkoon STARTDAT.START_TOIMTUKI_PERHE */

	PROC SQL;
		CREATE TABLE STARTDAT.START_TOIMTUKI_PERHE
		AS SELECT DISTINCT a.*, b.*, c.*,
			d.MAKSVUOKJ,
			d.KAYTKORVJ,
			d.YHTIOVASJ,
			d.ASLAIKORJ,
			d.LISALAMMJ,
			d.OMALAMMJ,
			d.OMAMAKSJ,
			d.SAHKOJ,
			d.TONTVUOKJ
		FROM TEMP.TOIMTUKI_PERHE_MUOK1 AS a, TEMP.TOIMTUKI_PERHE_AIKLAP AS b, TEMP.TOIMTUKI_KOTI AS c, 
			STARTDAT.START_TOIMTUKI_PERHE_HENKI AS d
		WHERE a.TOIMPERHE_AIKLAP = b.TOIMPERHE_AIKLAP AND a.knro = c.knro AND a.knro = d.knro;
	QUIT;
	
	/* 3.3.5 Muodostetaan lis�� muuttujia perhetasolle taulukossa STARTDAT.START_TOIMTUKI_PERHE */ 

	DATA STARTDAT.START_TOIMTUKI_PERHE;
	SET STARTDAT.START_TOIMTUKI_PERHE;

	*Toimeentulotuen m��r�n kerroin, kun poistetaan armeijassa tai siviilipalveluksessa olemisen ajat.;
	KERROIN = EIAMSIS/PERHEKOKO;

	*Ydinperhe (1) vai ei (0). Ydinperhe on kyseess�, jos perheess� asuu vanhempi/vanhemmat eik� kotitaloudessa asu muita aikuisia.;
	IF ONAIKS = ONAIKSK THEN YDINPERHE = 1;
	ELSE YDINPERHE = 0;

	*Veronalainen ty�tulo;
	VERTYOTULO_DATA = VERTYOTULOS;

	*Verovapaa ty�tulo;
	VEROTONTYOTULO_DATA = VEROTONTYOTULOS;

	*Veronalaiset ansiotulot;
	ANSIOT_DATA = SVATVAS;

	*Veronalaiset p��omatulot;
	POTULOT_DATA = SVATVPS;

	*Ty�el�ke- ja ty�tt�myysvakuutusmaksut;
	PALKVAK_DATA = VEVMS;

	*Sairausvakuutuksen p�iv�rahamaksut;
	PRAHAMAKSU_DATA = LPVMAS;

	*Kaikki verot ml. sairausvakuutuksen sairaanhoitomaksu;
	MAKSVEROT_DATA = SUM(VEROTS, -PRAHAMAKSU_DATA, LVERUS);

	*Veronalaisten ansiotulojen verot ml. sairausvakuutuksen sairaanhoitomaksu;
	ANSIOVEROT_DATA = SUM(MAKSVEROT_DATA, -LTVPS);

	*Tulonhankkimiskulut;
	THANKK_DATA = SUM(VTYOMJS, VTHMS, VMATKRS);

	*El�kkeensaajan asumistuki;
	ELASUMTUKI_DATA = AEMKMS;

	*Opiskelijan asumislis�;
	ASUMLISA_DATA = HASULIS;

	*Yleinen asumistuki;
	ASUMTUKI_DATA = HASTUKIS;

	*Lapsilis�t;
	LLISAT_DATA = LLMKS;

	*Elatustuki;
	ELTUKI_DATA = SUM(LBELTUKIS, LBDPPERIS);

	*El�kkeenlis�t;
	ELLISAT_DATA = SUM(KELLAPSS, RILIS, RIYLS);

	*Maahanmuuttajan erityistuki.;
	MAMUTUKI_DATA = MAMUTUKIS;

	*Toimeentulotukeen vaikuttavat verovapaat osinkotulot;
	VEROTONOSINKO_DATA = SUM(TNOOSVVBS, TEINOVVBS, TUOSVVAPS, TOBKBS, -TOPKVERS, TEINOVVS);
		
	*Toimeentulotukeen vaikuttavat muut verovapaat tulot;
	VEROTONMUU_DATA = SUM(KOKORVEJS, -LAHDEVERJS, AMSTIPES, APURAHAS, HLAKAVS,	
			HSOTVKORS, HSOTAVS, ELASAJS, RAHSAJS, LASSAJS, MUUSAJS,
			HASEPRS, MUULKTUS, OPINTOLAINAS);	

	*Kiinteist�vero;
	KIVERO_DATA = OMAKKIIVJS;

	*Sekalaisia veroja;
	SEKALVERO_DATA = KOROTVS;

	*Maksetut elatusmaksut;
	ELMAKSUT_DATA = ELAMAS;
	
	*Asumiskulut kuukaudessa;
	ASUMISKULUT_KOTI_HENKIKOHTI = SUM(MAKSVUOKJ, KAYTKORVJ, YHTIOVASJ, ASLAIKORJ / 12,
			LISALAMMJ / 12, OMALAMMJ / 12, OMAMAKSJ / 12, SAHKOJ / 12, TONTVUOKJ / 12);
	%IF &KOTASU = 0 %THEN %DO;
		IF ONAIKS >= 1 THEN ASUMISKULUT_DATA = PERHEKOKO_AIKLAP * ASUMISKULUT_KOTI_HENKIKOHTI;
		ELSE ASUMISKULUT_DATA = (PERHEKOKO - ONAIKLAPSIS) * ASUMISKULUT_KOTI_HENKIKOHTI;
	%END;
	%IF &KOTASU = 1 %THEN %DO;
		ASUMISKULUT_DATA = PERHEKOKO * ASUMISKULUT_KOTI_HENKIKOHTI;
	%END;

	*Harkinnanvaraiset menot kuukaudessa;
	HARKINMENOT_DATA = SUM(ELMAKSUT_DATA, PHOITOKAIKKIS) / 12; 	

	*Yksityiset p�iv�hoitomaksut kuukaudessa;
	PHOITOYKS_DATA = PHOITOYKSS / 12;

	/* 3.3.6 Tehd��n perhetason apumuuttujille labelit */

	LABEL
		TOIMPERHE = "Perheen tunnus, DATA"
		TOIMPERHE_AIKLAP = "Perheen tunnus, jos aikuiset lapset luetaan perheeseen, DATA"
		PERHEKOKO = "Perheen j�senten m��r�, DATA"
		PERHEKOKO_AIKLAP = "Perheen j�senten m��r�, jos aikuiset lapset luetaan perheeseen, DATA"
		ASKOMIN = "Perheen pienin asko-tunnus, DATA"
		HNROMIN = "Perheen pienin henkil�numero, DATA"
		KERROIN = "Perheen toimeentulotuen m��r�n kerroin, kun poistetaan armeijassa tai siviilipalveluksessa olemisen ajat, DATA"
		ONAIKS = "Aikuisten lukum��r� perheess�, DATA"
		ONAIKLAPSIS = "18-vuotiaiden tai vanhempien lasten lukum��r� perheess�, DATA"
		ONLAPSI17S = "17-vuotiaiden lasten lukum��r� perheess�, DATA"
		ONLAPSI1016S = "10-16-vuotiaiden lasten lukum��r� perheess�, DATA"
		ONLAPSIALLE10S = "Alle 10-vuotiaiden lasten lukum��r� perheess�, DATA"
		YDINPERHE = "Onko kyseess� ydinperhe (1) vai ei (0). Ydinperhe on kyseess�, jos perheess� asuu vanhempi/vanhemmat eik� kotitaloudessa asu muita aikuisia. DATA."
		VERTYOTULO_DATA = "Perheen veronalainen ty�tulo (e/v), DATA"
		VEROTONTYOTULO_DATA = "Perheen verovapaa ty�tulo (e/v), DATA"
		ANSIOT_DATA = "Perheen veronalaiset ansiotulot (e/v), DATA"
		POTULOT_DATA = "Perheen veronalaiset p��omatulot (e/v), DATA"
		MAKSVEROT_DATA = "Perheen kaikki verot ml. sairausvakuutuksen sairaanhoitomaksu (e/v), DATA"
		ANSIOVEROT_DATA = "Perheen veronalaisten ansiotulojen verot ml. sairausvakuutuksen sairaanhoitomaksu (e/v), DATA"
		PALKVAK_DATA = "Perheen ty�el�ke- ja ty�tt�myysvakuutusmaksut (e/v), DATA"
		PRAHAMAKSU_DATA = "Perheen sairausvakuutuksen p�iv�rahamaksut (e/v), DATA"
		THANKK_DATA = "Perheen tulonhankkimiskulut (e/v), DATA"
		ELASUMTUKI_DATA = "Perheen saama el�kkeensaajan asumistuki (e/v), DATA"
		ASUMLISA_DATA = "Perheen saama opiskelijan asumislis� (e/v), DATA"
		ASUMTUKI_DATA = "Perheen saama yleinen asumistuki (e/v), DATA"
		LLISAT_DATA = "Perheelle maksettu lapsilis� (e/v), DATA"
		ELTUKI_DATA = "Perheen saama elatustuki (e/v), DATA"
		ELLISAT_DATA = "Perheen saamat toimeentulotukeen vaikuttavat verottomat el�kkeenlis�t (e/v), DATA"
		MAMUTUKI_DATA = "Kotitalouden saama maahanmuuttajan erityistuki (e/v), DATA"
		VEROTONOSINKO_DATA = "Perheen saamat toimeentulotukeen vaikuttavat verovapaat osinkotulot (e/v), DATA"
		VEROTONMUU_DATA = "Perheen saamat muut toimeentulotukeen vaikuttavat verovapaat tulot (e/v), DATA"
		KIVERO_DATA = "Kiinteist�vero (e/v), DATA"
		SEKALVERO_DATA = "Perheelt� perittyj� sekalaisia veroja (e/v), DATA"
		ELMAKSUT_DATA = "Perheen maksamat elatusmaksut (e/v), DATA"
		ASUMISKULUT_DATA = "Toimeentulotukeen vaikuttavat perheen asumiskulut (e/kk), DATA"
		HARKINMENOT_DATA = "Perheen harkinnanvaraiset menot (elatusmaksut ja lasten p�iv�hoitomaksut) (e/kk), DATA"
		PHOITOYKS_DATA = "Perheen maksamat yksityiset p�iv�hoitomaksut (e/kk), DATA";

	KEEP TOIMPERHE TOIMPERHE_AIKLAP knro paasoss PERHEKOKO PERHEKOKO_AIKLAP ASKOMIN HNROMIN KERROIN ONAIKS ONAIKLAPSIS ONLAPSI17S ONLAPSI1016S ONLAPSIALLE10S YDINPERHE 
		VERTYOTULO_DATA VEROTONTYOTULO_DATA ANSIOT_DATA POTULOT_DATA MAKSVEROT_DATA ANSIOVEROT_DATA PALKVAK_DATA PRAHAMAKSU_DATA THANKK_DATA ELASUMTUKI_DATA
		ASUMLISA_DATA ASUMTUKI_DATA LLISAT_DATA ELTUKI_DATA ELLISAT_DATA MAMUTUKI_DATA VEROTONOSINKO_DATA
		VEROTONMUU_DATA KIVERO_DATA SEKALVERO_DATA ELMAKSUT_DATA ASUMISKULUT_DATA HARKINMENOT_DATA PHOITOYKS_DATA;
	
	RUN;

%END;

%MEND ToimTuki_Muutt_Poiminta;

%ToimTuki_Muutt_Poiminta;

%LET alkoi2&malli = %SYSFUNC(TIME());

/* 4. Makro hakee tietoja muista osamalleista ja liitt�� ne mallin dataan */

%MACRO OsaMallit_ToimTuki;

/* 4.1 Opintotuen asumislis� */

%IF &OPINTUKI = 1 %THEN %DO;

	PROC SORT DATA = STARTDAT.START_TOIMTUKI_PERHE_HENKI;
		BY hnro;
	RUN;

	DATA STARTDAT.START_TOIMTUKI_PERHE_HENKI;
	UPDATE STARTDAT.START_TOIMTUKI_PERHE_HENKI (IN = C) OUTPUT.&TULOSNIMI_OT (KEEP = hnro ASUMLISA)
	UPDATEMODE=NOMISSINGCHECK;
	BY hnro;
	IF C;
	RUN;

	PROC SORT DATA = STARTDAT.START_TOIMTUKI_PERHE_HENKI;
		BY TOIMPERHE;
	RUN;

	PROC MEANS DATA = STARTDAT.START_TOIMTUKI_PERHE_HENKI SUM NOPRINT;
	BY TOIMPERHE;
	VAR ASUMLISA;
	OUTPUT OUT = TEMP.TOIMTUKI_PERHE_SUMMAUS_SIMUL (DROP = _TYPE_ _FREQ_)
		SUM(ASUMLISA) = ;
	RUN;
	
	DATA STARTDAT.START_TOIMTUKI_PERHE;
	UPDATE STARTDAT.START_TOIMTUKI_PERHE (IN = C) TEMP.TOIMTUKI_PERHE_SUMMAUS_SIMUL
	UPDATEMODE=NOMISSINGCHECK;
	BY TOIMPERHE;
	IF C;
	RUN;

%END;

/* 4.2 Kansanel�kkeen lisi� ja maahanmuuttajan erityistuki */

%IF &KANSEL = 1 %THEN %DO;

	PROC SORT DATA = STARTDAT.START_TOIMTUKI_PERHE_HENKI;
		BY hnro;
	RUN;

	DATA STARTDAT.START_TOIMTUKI_PERHE_HENKI;
	UPDATE STARTDAT.START_TOIMTUKI_PERHE_HENKI (IN = C) OUTPUT.&TULOSNIMI_KE (KEEP = hnro LAPSIKOROT RILISA YLIMRILI MMTUKI)
	UPDATEMODE=NOMISSINGCHECK;
	BY hnro;
	IF C;
    RUN;

	PROC SORT DATA = STARTDAT.START_TOIMTUKI_PERHE_HENKI;
		BY TOIMPERHE;
	RUN;

	PROC MEANS DATA = STARTDAT.START_TOIMTUKI_PERHE_HENKI SUM NOPRINT;
	BY TOIMPERHE;
	VAR LAPSIKOROT RILISA YLIMRILI;
	OUTPUT OUT = TEMP.TOIMTUKI_PERHE_SUMMAUS_SIMUL (DROP = _TYPE_ _FREQ_)
		SUM(LAPSIKOROT RILISA YLIMRILI MMTUKI) = ;
	RUN;
	
	DATA STARTDAT.START_TOIMTUKI_PERHE;
	UPDATE STARTDAT.START_TOIMTUKI_PERHE (IN = C) TEMP.TOIMTUKI_PERHE_SUMMAUS_SIMUL
	UPDATEMODE=NOMISSINGCHECK;
	BY TOIMPERHE;
	IF C;
	RUN;

%END;

/* 4.3 Veromalli */

%IF %SYSFUNC(SUM(&KANSEL, &OPINTUKI, &SAIRVAK, &TTURVA, &KOTIHTUKI, &VERO)) > 0 %THEN %DO;

	PROC SORT DATA = STARTDAT.START_TOIMTUKI_PERHE_HENKI;
		BY hnro;
	RUN;

	DATA STARTDAT.START_TOIMTUKI_PERHE_HENKI;
	UPDATE STARTDAT.START_TOIMTUKI_PERHE_HENKI (IN = C) OUTPUT.&TULOSNIMI_VE (KEEP = hnro ANSIOT POTULOT
		OSINKOVAP PRAHAMAKSU PALKVAK ANSIOVEROT POVEROB YLEVERO)
	UPDATEMODE=NOMISSINGCHECK;
	BY hnro;
	IF C;
	RUN;

	PROC SORT DATA = STARTDAT.START_TOIMTUKI_PERHE_HENKI;
		BY TOIMPERHE;
	RUN;

	PROC MEANS DATA = STARTDAT.START_TOIMTUKI_PERHE_HENKI SUM NOPRINT;
	BY TOIMPERHE;
	VAR ANSIOT POTULOT OSINKOVAP PRAHAMAKSU PALKVAK ANSIOVEROT POVEROB YLEVERO;
	OUTPUT OUT = TEMP.TOIMTUKI_PERHE_SUMMAUS_SIMUL (DROP = _TYPE_ _FREQ_)
		SUM(ANSIOT POTULOT OSINKOVAP PRAHAMAKSU PALKVAK ANSIOVEROT POVEROB YLEVERO) = ;
	RUN;
	
	DATA STARTDAT.START_TOIMTUKI_PERHE;
	UPDATE STARTDAT.START_TOIMTUKI_PERHE (IN = C) TEMP.TOIMTUKI_PERHE_SUMMAUS_SIMUL
	UPDATEMODE=NOMISSINGCHECK;
	BY TOIMPERHE;
	IF C;
	RUN;

%END;

/* 4.4 Lapsilis�t */

%IF &LLISA = 1 %THEN %DO;

	PROC SORT DATA = STARTDAT.START_TOIMTUKI_PERHE_HENKI;
		BY hnro;
	RUN;

	PROC SQL;
		CREATE TABLE TEMP.TOIMTUKI_KOTI_HENKIKOHTI_SIMUL
		AS SELECT knro, 
				SUM(LLISA_HH) / COUNT(hnro) AS LLISA_HHJ,
				SUM(ELATUSTUET_HH) / COUNT(hnro) AS ELATUSTUET_HHJ
		FROM OUTPUT.&TULOSNIMI_LL
		GROUP BY knro;
	QUIT;

	PROC SQL;
		CREATE TABLE STARTDAT.START_TOIMTUKI_PERHE_HENKI
		AS SELECT a.*, b.LLISA_HHJ, b.ELATUSTUET_HHJ
		FROM STARTDAT.START_TOIMTUKI_PERHE_HENKI AS a, TEMP.TOIMTUKI_KOTI_HENKIKOHTI_SIMUL AS b
		WHERE a.knro = b.knro;
	QUIT;

	PROC SORT DATA = STARTDAT.START_TOIMTUKI_PERHE_HENKI;
		BY TOIMPERHE;
	RUN;

	PROC MEANS DATA = STARTDAT.START_TOIMTUKI_PERHE_HENKI SUM NOPRINT;
	BY TOIMPERHE;
	VAR LLISA_HHJ ELATUSTUET_HHJ;
	OUTPUT OUT = TEMP.TOIMTUKI_PERHE_SUMMAUS_SIMUL (DROP = _TYPE_ _FREQ_)
		SUM(LLISA_HHJ ELATUSTUET_HHJ) = ;
	RUN;
	
	DATA STARTDAT.START_TOIMTUKI_PERHE;
	UPDATE STARTDAT.START_TOIMTUKI_PERHE (IN = C) TEMP.TOIMTUKI_PERHE_SUMMAUS_SIMUL
	UPDATEMODE=NOMISSINGCHECK;
	BY TOIMPERHE;
	IF C;
	RUN;

%END;

/* 4.5 Lasten p�iv�hoitomaksut */

%IF &PHOITO = 1 %THEN %DO;

	PROC SORT DATA = STARTDAT.START_TOIMTUKI_PERHE_HENKI;
		BY hnro;
	RUN;

	DATA STARTDAT.START_TOIMTUKI_PERHE_HENKI;
	UPDATE STARTDAT.START_TOIMTUKI_PERHE_HENKI (IN = C) OUTPUT.&TULOSNIMI_PH (KEEP = hnro PHMAKSU_KOK PHMAKSU_OS)
	UPDATEMODE=NOMISSINGCHECK;
	BY hnro;
	IF C;
	RUN;

	PROC SORT DATA = STARTDAT.START_TOIMTUKI_PERHE_HENKI;
		BY TOIMPERHE;
	RUN;

	PROC MEANS DATA = STARTDAT.START_TOIMTUKI_PERHE_HENKI SUM NOPRINT;
	BY TOIMPERHE;
	VAR PHMAKSU_KOK PHMAKSU_OS;
	OUTPUT OUT = TEMP.TOIMTUKI_PERHE_SUMMAUS_SIMUL (DROP = _TYPE_ _FREQ_)
		SUM(PHMAKSU_KOK PHMAKSU_OS) = ;
	RUN;
	
	DATA STARTDAT.START_TOIMTUKI_PERHE;
	UPDATE STARTDAT.START_TOIMTUKI_PERHE (IN = C) TEMP.TOIMTUKI_PERHE_SUMMAUS_SIMUL
	UPDATEMODE=NOMISSINGCHECK;
	BY TOIMPERHE;
	IF C;
	RUN;

%END;

/* 4.6 El�kkeensaajien asumistuki */

%IF &ELASUMTUKI = 1 %THEN %DO;

	PROC SORT DATA = STARTDAT.START_TOIMTUKI_PERHE_HENKI;
		BY hnro;
	RUN;

	DATA STARTDAT.START_TOIMTUKI_PERHE_HENKI;
	UPDATE STARTDAT.START_TOIMTUKI_PERHE_HENKI (IN = C) OUTPUT.&TULOSNIMI_EA (KEEP = hnro ELAKASUMTUKI)
	UPDATEMODE=NOMISSINGCHECK;
	BY hnro;
	IF C;
	RUN;

	PROC SORT DATA = STARTDAT.START_TOIMTUKI_PERHE_HENKI;
		BY TOIMPERHE;
	RUN;

	PROC MEANS DATA = STARTDAT.START_TOIMTUKI_PERHE_HENKI SUM NOPRINT;
	BY TOIMPERHE;
	VAR ELAKASUMTUKI;
	OUTPUT OUT = TEMP.TOIMTUKI_PERHE_SUMMAUS_SIMUL (DROP = _TYPE_ _FREQ_)
		SUM(ELAKASUMTUKI) = ;
	RUN;
	
	DATA STARTDAT.START_TOIMTUKI_PERHE;
	UPDATE STARTDAT.START_TOIMTUKI_PERHE (IN = C) TEMP.TOIMTUKI_PERHE_SUMMAUS_SIMUL
	UPDATEMODE=NOMISSINGCHECK;
	BY TOIMPERHE;
	IF C;
	RUN;

%END;

/* 4.7 Yleinen asumistuki */

%IF &ASUMTUKI = 1 %THEN %DO;

	PROC SORT DATA = STARTDAT.START_TOIMTUKI_PERHE_HENKI;
		BY hnro;
	RUN;

	PROC SQL;
		CREATE TABLE TEMP.TOIMTUKI_KOTI_HENKIKOHTI_SIMUL
		AS SELECT knro, 
				SUM(TUKISUMMA) / COUNT(hnro) AS TUKISUMMAJ
		FROM OUTPUT.&TULOSNIMI_YA
		GROUP BY knro;
	QUIT;

	PROC SQL;
		CREATE TABLE STARTDAT.START_TOIMTUKI_PERHE_HENKI
		AS SELECT a.*, b.TUKISUMMAJ
		FROM STARTDAT.START_TOIMTUKI_PERHE_HENKI AS a, TEMP.TOIMTUKI_KOTI_HENKIKOHTI_SIMUL AS b
		WHERE a.knro = b.knro;
	QUIT;

	PROC SQL;
		CREATE TABLE STARTDAT.START_TOIMTUKI_PERHE
		AS SELECT DISTINCT a.*, b.TUKISUMMAJ
		FROM STARTDAT.START_TOIMTUKI_PERHE a, STARTDAT.START_TOIMTUKI_PERHE_HENKI AS b
		WHERE a.knro = b.knro;
	QUIT;

%END;

/* 4.8 Kiinteist�verotus */

%IF &KIVERO = 1 AND &AVUOSI = 2010 %THEN %DO;

	PROC SORT DATA = STARTDAT.START_TOIMTUKI_PERHE_HENKI;
		BY hnro;
	RUN;

	PROC SQL;
		CREATE TABLE TEMP.TOIMTUKI_KOTI_HENKIKOHTI_SIMUL
		AS SELECT knro, 
				SUM(KIVEROYHT2) / COUNT(hnro) AS KIVEROYHT2J
		FROM OUTPUT.&TULOSNIMI_KV
		GROUP BY knro;
	QUIT;

	PROC SQL;
		CREATE TABLE STARTDAT.START_TOIMTUKI_PERHE_HENKI
		AS SELECT a.*, b.KIVEROYHT2J
		FROM STARTDAT.START_TOIMTUKI_PERHE_HENKI AS a, TEMP.TOIMTUKI_KOTI_HENKIKOHTI_SIMUL AS b
		WHERE a.knro = b.knro;
	QUIT;

	PROC SORT DATA = STARTDAT.START_TOIMTUKI_PERHE_HENKI;
		BY TOIMPERHE;
	RUN;

	PROC MEANS DATA = STARTDAT.START_TOIMTUKI_PERHE_HENKI SUM NOPRINT;
	BY TOIMPERHE;
	VAR KIVEROYHT2J;
	OUTPUT OUT = TEMP.TOIMTUKI_PERHE_SUMMAUS_SIMUL (DROP = _TYPE_ _FREQ_)
		SUM(KIVEROYHT2J) = ;
	RUN;
	
	DATA STARTDAT.START_TOIMTUKI_PERHE;
	UPDATE STARTDAT.START_TOIMTUKI_PERHE (IN = C) TEMP.TOIMTUKI_PERHE_SUMMAUS_SIMUL
	UPDATEMODE=NOMISSINGCHECK;
	BY TOIMPERHE;
	IF C;
	RUN;

%END;

%MEND OsaMallit_ToimTuki;

%OsaMallit_ToimTuki;


/* 5. Simulointivaihe */

/* 5.1 Jos parametrit luetaan makromuuttujiksi ennen simulontia, ajetaan t�m� makro, erillisajossa */

%MACRO KuukSimul;

%IF &F = S AND &TYYPPI = SIMULX %THEN %DO;

	%HaeParam_ToimTukiSIMUL(&LVUOSI, &LKUUK, &INF);

%END;

%MEND KuukSimul;

%KuukSimul;

/* 5.2 Varsinainen simulointivaihe */

%MACRO ToimTuki_Simuloi_Data;

DATA OUTPUT.&TULOSNIMI_TO;
SET STARTDAT.START_TOIMTUKI_PERHE;

/* 5.2.1 P��tell��n k�ytet��nk� simuloituja tietoja muista osamalleista vai alkuper�isen datan tietoja */

/* Opintotuen asumislis�: data vs. simuloitu */

%IF &OPINTUKI = 0 %THEN %DO; ASUMLISA_SIMUL = ASUMLISA_DATA; %END;
%ELSE %DO; ASUMLISA_SIMUL = ASUMLISA; %END;

/* Toimeentulotukeen vaikuttavat verottomat el�kkeenlis�t ja maahanmuuttajan erityistuki: data vs. simuloitu */

%IF &KANSEL = 0 %THEN %DO;
	ELLISAT_SIMUL = ELLISAT_DATA;
	MAMUTUKI_SIMUL = MAMUTUKI_DATA;
%END;
%ELSE %DO; 
	ELLISAT_SIMUL = SUM(LAPSIKOROT,  RILISA, YLIMRILI);
	MAMUTUKI_SIMUL = MMTUKI;
%END;

/* Toimeentulotukeen vaikuttavat lapsilis�t: data vs. simuloitu */

%IF &LLISA = 0 %THEN %DO; LLISAT_SIMUL = LLISAT_DATA; %END;
%ELSE %DO; LLISAT_SIMUL = LLISA_HHJ; %END;

/* Toimeentulotukeen vaikuttavat elatustuet: data vs. simuloitu */

%IF &LLISA = 0 %THEN %DO; ELTUKI_SIMUL = ELTUKI_DATA; %END;
%ELSE %DO; ELTUKI_SIMUL = ELATUSTUET_HHJ; %END;

/* Veronalaiset tulonsiirrot: Niiden vaikutus tulee VERO-mallin kautta;
   VERO-mallista haetaan my�s veronalaiset p��omatulot, verottomat
   osinkotulot sek� eri verolajit */
		
%IF %SYSFUNC(SUM(&SAIRVAK, &TTURVA, &KANSEL, &OPINTUKI, &KOTIHTUKI, &VERO)) > 0 %THEN %DO; 

	/* Veronalaiset ansiotulot VERO-mallista */
	ANSIOT_SIMUL = ANSIOT;

	/* Veronalaiset p��omatulot VERO-mallista */
	POTULOT_SIMUL = POTULOT;

	/* Kaikki verot ml. sairausvakuutuksen sairaanhoitomaksu */
	MAKSVEROT_SIMUL = SUM(ANSIOVEROT, POVEROB, YLEVERO);

	/* Veronalaisten ansiotulojen verot ml. sairausvakuutuksen sairaanhoitomaksu */
	ANSIOVEROT_SIMUL = ANSIOVEROT;

	/* Ty�el�ke- ja ty�tt�myysvakuutusmaksut */
	PALKVAK_SIMUL = PALKVAK; 

	/* Sairausvakuutuksen p�iv�rahamaksut */
	PRAHAMAKSU_SIMUL = PRAHAMAKSU;

	/* Verottomat osinkotulot */
	VEROTONOSINKO_SIMUL = OSINKOVAP;

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

	VEROTONOSINKO_SIMUL = VEROTONOSINKO_DATA;

%END;

/* El�kkeensaajien asumistuki: data vs. simuloitu */

%IF &ELASUMTUKI = 0 %THEN %DO; ELASUMTUKI_SIMUL = ELASUMTUKI_DATA; %END;
%ELSE %DO; ELASUMTUKI_SIMUL = ELAKASUMTUKI; %END;

/* Yleinen asumistuki: data vs. simuloitu */

%IF &ASUMTUKI = 0 %THEN %DO; 
	ASUMTUKI_SIMUL = ASUMTUKI_DATA; 
%END;
%ELSE %DO; 
	%IF &KOTASU = 0 %THEN %DO;
		IF ONAIKS >= 1 THEN ASUMTUKI_SIMUL = PERHEKOKO_AIKLAP * TUKISUMMAJ;
		ELSE ASUMTUKI_SIMUL = (PERHEKOKO - ONAIKLAPSIS) * TUKISUMMAJ;
	%END;
	%IF &KOTASU = 1 %THEN %DO;
		ASUMTUKI_SIMUL = PERHEKOKO * TUKISUMMAJ;
	%END;
%END;

/* Harkinnanvaraiset menot kuukaudessa (elatusmaksut ja lasten p�iv�hoitomaksut): data vs. simuloitu */

%IF &PHOITO = 0 %THEN %DO; HARKINMENOT_SIMUL = HARKINMENOT_DATA; %END;
%ELSE %DO; HARKINMENOT_SIMUL = SUM((SUM(ELMAKSUT_DATA, PHMAKSU_KOK, PHMAKSU_OS) / 12), PHOITOYKS_DATA); %END;

/* Kiinteist�vero: data vs. simuloitu */

%IF &KIVERO = 1 AND &AVUOSI = 2010 %THEN %DO; KIVERO_SIMUL = KIVEROYHT2J; %END;
%ELSE %DO; KIVERO_SIMUL = KIVERO_DATA; %END;

*Lapsilis�n m��r� kuukautta kohden;
LLISATKK = MAX(LLISAT_SIMUL / 12, 0);

*Verojen suhteellinen osuus veronalaisista ansiotuloista;
IF ANSIOT_SIMUL > 0 THEN VERTYOTULOVEROOS = ANSIOVEROT_SIMUL / ANSIOT_SIMUL;
ELSE VERTYOTULOVEROOS = 0;	

*Ty�tulojen nettom��r�;
TYOTULONETTO = SUM(VERTYOTULO_DATA, -VERTYOTULOVEROOS * VERTYOTULO_DATA, -PALKVAK_SIMUL, -PRAHAMAKSU_SIMUL, -THANKK_DATA, VEROTONTYOTULO_DATA);

*Ty�tulojen nettom��r� kuukautta kohden;
TYOTULONETTO = MAX(TYOTULONETTO / 12, 0);

*Veronalaisten ei-ty�tulojen nettom��r�;
MUUTVERTULOTNETTO = SUM(ANSIOT_SIMUL, -VERTYOTULO_DATA, POTULOT_SIMUL, -MAKSVEROT_SIMUL, VERTYOTULOVEROOS * VERTYOTULO_DATA);

*Toimeentulotukeen vaikuttavien verovapaiden ei-ty�tulojen m��r�;
VEROTONTUL = SUM(VEROTONMUU_DATA, ELTUKI_SIMUL, ELLISAT_SIMUL, MAMUTUKI_SIMUL, ASUMLISA_SIMUL, ELASUMTUKI_SIMUL, ASUMTUKI_SIMUL, VEROTONOSINKO_SIMUL);

*Ei-ty�tulojen nettom��r�;
MUUTTULOTNETTO =  SUM(MUUTVERTULOTNETTO, VEROTONTUL, -SEKALVERO_DATA, -KIVERO_SIMUL);

*Ei-ty�tulojen nettom��r� kuukautta kohden;
MUUTTULOTNETTO = MAX(MUUTTULOTNETTO / 12, 0);

/* 5.2.2 Lasketaan toimeentulotuki perheit�in */

%ToimtukiV&F(TOIMTUKIV, &LVUOSI, &INF, 1, YDINPERHE, ONAIKS, ONAIKLAPSIS,
ONLAPSI17S, ONLAPSI1016S, ONLAPSIALLE10S, LLISATKK, TYOTULONETTO,
MUUTTULOTNETTO, ASUMISKULUT_DATA, HARKINMENOT_SIMUL);

TOIMTUKI = KERROIN * (12 * TOIMTUKIV);

KEEP TOIMPERHE knro paasoss ASKOMIN HNROMIN KERROIN ONAIKS ONAIKLAPSIS ONLAPSI17S ONLAPSI1016S ONLAPSIALLE10S YDINPERHE ASUMISKULUT_DATA
ASUMLISA_SIMUL ELLISAT_SIMUL MAMUTUKI_SIMUL LLISAT_SIMUL ELTUKI_SIMUL
ANSIOT_SIMUL POTULOT_SIMUL MAKSVEROT_SIMUL ANSIOVEROT_SIMUL PALKVAK_SIMUL PRAHAMAKSU_SIMUL
VEROTONOSINKO_SIMUL ELASUMTUKI_SIMUL ASUMTUKI_SIMUL HARKINMENOT_SIMUL KIVERO_SIMUL
LLISATKK VERTYOTULOVEROOS TYOTULONETTO MUUTVERTULOTNETTO VEROTONTUL MUUTTULOTNETTO
TOIMTUKI; 

RUN;

*Siirret��n samansuuruinen simuloitu toimeentulotuki kaikille saman perheen henkil�ille;
PROC SQL;
CREATE TABLE OUTPUT.&TULOSNIMI_TO
AS SELECT a.hnro, a.TOIMPERHE, b.*
FROM STARTDAT.START_TOIMTUKI_PERHE_HENKI AS a 
LEFT JOIN OUTPUT.&TULOSNIMI_TO AS b ON a.TOIMPERHE = b.TOIMPERHE
ORDER BY a.hnro, a.TOIMPERHE;
QUIT;

/* 5.3 Yhdistet��n simuloitu data palveluaineistoon (riippuen tulosaineiston laajuden valinnasta) */

DATA OUTPUT.&TULOSNIMI_TO;
	
/* 5.3.1 Suppea tulostiedosto (vain t�rkeimm�t luokittelumuuttujat) */

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

* Jos perheess� on viitehenkil�, niin poistetaan simuloitu toimeentulotuki muilta kuin viitehenkil�ilt�;
IF (ASKOMIN = 1) AND (asko NE 1) THEN DO; 
	KERROIN = .;
	ONAIKS = .;
	ONAIKLAPSIS = .;
	ONLAPSI17S = .;
	ONLAPSI1016S = .;
	ONLAPSIALLE10S = .;
	YDINPERHE = .;
	ASUMISKULUT_DATA = .;
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
	VEROTONOSINKO_SIMUL = .;
	ELASUMTUKI_SIMUL = .;
	ASUMTUKI_SIMUL = .;
	HARKINMENOT_SIMUL = .;
	KIVERO_SIMUL = .;
	LLISATKK = .;
	VERTYOTULOVEROOS = .;
	TYOTULONETTO = .;
	MUUTVERTULOTNETTO = .;
	VEROTONTUL =.;
	MUUTTULOTNETTO = .;
	TOIMTUKI = 0;
END;
* Jos perheess� ei ole viitehenkil��, niin poistetaan simuloitu toimeentulotuki muilta kuin henkil�lt�, jolla perheess� on pienin hnro-arvo.;
ELSE IF (ASKOMIN NE 1) AND (hnro NE HNROMIN) THEN DO;
	KERROIN = .;
	ONAIKS = .;
	ONAIKLAPSIS = .;
	ONLAPSI17S = .;
	ONLAPSI1016S = .;
	ONLAPSIALLE10S = .;
	YDINPERHE = .;
	ASUMISKULUT_DATA = .;
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
	VEROTONOSINKO_SIMUL = .;
	ELASUMTUKI_SIMUL = .;
	ASUMTUKI_SIMUL = .;
	HARKINMENOT_SIMUL = .;
	KIVERO_SIMUL = .;
	LLISATKK = .;
	VERTYOTULOVEROOS = .;
	TYOTULONETTO = .;
	MUUTVERTULOTNETTO = .;
	VEROTONTUL =.;
	MUUTTULOTNETTO = .;
	TOIMTUKI = 0;
END; 

* Datasta saatu toimeentulotuki merkit��n henkil�lle, joka todellisuudessa tuen saanut.;
TOIMTUKIREK = MAX(htoimtuk, 0);

* Poistetaan simuloitu toimeentulotuki yritt�jilt� tarvittaessa ;
%IF &YRIT = 0 %THEN %DO;
	IF paasoss < 30 THEN TOIMTUKI = 0;
%END;

* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukum��r�t voidaan laskea suoraan ;
ARRAY PISTE 
	TOIMTUKI TOIMTUKIREK;
DO OVER PISTE;
	IF PISTE <= 0 THEN PISTE = .;
END;

/* 5.3.3 Luodaan simuloiduille ja datan muuttujille selitteet */

LABEL
	TOIMPERHE = "Perheen tunnus, DATA"
	ASUMLISA_SIMUL = "Perheen saama opiskelijan asumislis� (e/v), MALLI"
	ELLISAT_SIMUL = "Perheen saamat toimeentulotukeen vaikuttavat verottomat el�kkeenlis�t (e/v), MALLI"
	MAMUTUKI_SIMUL = "Kotitalouden saama maahanmuuttajan erityistuki (e/v), MALLI"
	LLISAT_SIMUL = "Perheelle maksettu lapsilis� (e/v), MALLI"
	ELTUKI_SIMUL = "Perheen saama elatustuki (e/v), MALLI"
	ANSIOT_SIMUL = "Perheen veronalaiset ansiotulot (e/v), MALLI"
	POTULOT_SIMUL = "Perheen veronalaiset p��omatulot (e/v), MALLI"
	MAKSVEROT_SIMUL = "Perheen kaikki verot ml. sairausvakuutuksen sairaanhoitomaksu (e/v), MALLI"
	ANSIOVEROT_SIMUL = "Perheen veronalaisten ansiotulojen verot ml. sairausvakuutuksen sairaanhoitomaksu (e/v), MALLI"
	PALKVAK_SIMUL = "Perheen ty�el�ke- ja ty�tt�myysvakuutusmaksut (e/v), MALLI"
	PRAHAMAKSU_SIMUL = "Perheen sairausvakuutuksen p�iv�rahamaksu (e/v), MALLI"
	VEROTONOSINKO_SIMUL = "Perheen saamat toimeentulotukeen vaikuttavat verovapaat osinkotulot (e/v), MALLI"
	ELASUMTUKI_SIMUL = "Perheen saama el�kkeensaajien asumistuki (e/v), MALLI"
	ASUMTUKI_SIMUL = "Perheen saama yleinen asumistuki (e/v), MALLI"
	HARKINMENOT_SIMUL= "Perheen harkinnanvaraiset menot (elatusmaksut ja lasten p�iv�hoitomaksut) (e/kk), MALLI"
	KIVERO_SIMUL = "Kiinteist�vero (e/v), MALLI"
	LLISATKK = "Perheelle maksettu lapsilis� (e/kk), MALLI"
	VERTYOTULOVEROOS = "Perheen verojen suhteellinen osuus veronalaisista ansiotuloista, MALLI"
	TYOTULONETTO = "Perheen ty�tulojen nettom��r� (e/kk), MALLI"
	MUUTVERTULOTNETTO = "Perheen veronalaisten ei-ty�tulojen nettom��r� (e/v), MALLI"
	VEROTONTUL = "Perheen toimeentulotukeen vaikuttavien verovapaiden ei-ty�tulojen m��r� (e/v), MALLI"
	MUUTTULOTNETTO = "Perheen ei-ty�tulojen nettom��r� (e/kk), MALLI"
	TOIMTUKIREK = "Toimeentulotuki (e/v), DATA"
	TOIMTUKI = "Perheen toimeentulotuki (e/v), MALLI";

DROP ASKOMIN HNROMIN htoimtuk;

RUN;

%MEND ToimTuki_Simuloi_Data;

%ToimTuki_Simuloi_Data;

%LET loppui2&malli = %SYSFUNC(TIME());


/* 6. Luodaan summatason tulostaulukot (optio) */

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

		/* Siirret��n tiedot Exceliin (optio) */

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
	
	/* 6.2 Henkil�tason tulokset (oletus) */

	%ELSE %DO;

		/* Siirret��n tiedot Exceliin (optio) */

		%IF &EXCEL = 1 %THEN %DO;

			ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_TO._SUMMAT.xls" STYLE = MINIMAL;

		%END;

		PROC MEANS DATA=OUTPUT.&TULOSNIMI_TO &SUMWGT &SUM &MIN &MAX &RANGE &MEAN &MEDIAN &MODE &STD &VAR &CV NONOBS ORDER=DATA NWAY MAXDEC = 0;
		TITLE "TUNNUSLUVUT (HENKIL�TASO), &MALLI";
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

