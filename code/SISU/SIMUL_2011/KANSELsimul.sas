/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyödyntää Tilastokeskuksen yleisten
* käyttöehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto päähakemistossa.
******************************************************************************/

/***********************************************************
* Kuvaus: Kansaneläkkeen simulointimalli 2011          	   *
* Tekijä: Jussi Tervola / KELA		                	   *
* Luotu: 25.9.2012				       					   *
* Viimeksi päivitetty: 12.8.2013			   		       *
* Päivittäjä: Jussi Tervola / KELA		     			   *
************************************************************; 

/*	
	Kommentit: 

	Datan tulotiedot eivät sovellu hyvin varsinkaan perhe-eläkkeisiin, joten hyvä käyttää laskennallisia tulotietoja.

	Datassa on niin suuria eläkkeitä, jotka ei ole vuoden aikana mahdollisia (suurempia kuin 1 000e/kk)(takautuvasti maksettuja?).
	Sama juttu maahanmuuttajan erityistuessa. Tämä tekee mallin tuottamista estimaateista keskimäärin pienempiä.

	Sotilasavustusta ei ole koodattu.

	Hoitotuen datamuuttujissa jonkin verran ristiriitaa: maksettuja hoitotukia löytyy vaikka hoitotukiluokka on 'Ei hoitotukea'. Tämä aiheuttaa pienen eron datan ja mallin arvoissa.
	
	-Jussi 
*/

/* 0. Yleisiä vakioiden määrittelyjä (älä muuta näitä!) */

%LET START = &OUT;

%LET MALLI = KANSEL;

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

	%LET LKUUK = 12;         * Lainsäädäntökuukausi, jos parametrit haetaan tietylle kuukaudelle;

	%LET AINEISTO = PALV ;  * Käytettävä aineisto (PALV = Palveluaineisto, REK = Rekisteriaineisto) ;

	%LET TULOSNIMI_KE = kansel_simul_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;

	%LET KDATATULO = 0; 	 * Käytetäänkö KANSEL-mallissa datan tulotietoja = 1 vai laskennallisia tulotietoja = 0 ;

	* Inflaatiokorjaus. Parametrien deflatoinnissa käytettävän kertoimen voi syöttää itse
	  INF-makromuuttujaan (HUOM! desimaalit erotettava pisteellä .). Jos puolestaan haluaa käyttää automaattista 
	  elinkustannusindeksiin perustuvaa parametrien muunnoskerrointa, 
	  tulee INF-makromuuttujalle antaa arvoksi 999 ; 	

	%LET INF = 999; * Syötä arvo tai 999 ;	
	%LET PINDEKSI_VUOSI = pindeksi_vuosi; *Käytettävä indeksien parametritaulukko;		

	* Ajettavat osavaiheet ; 

	%LET LAKIMAKROT = 1;    * Lakimakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
	%LET LAKIMAK_TIED_KE = KANSELlakimakrot;	* Lakimakroissa käytettävän tiedoston nimi ;
	%LET APUMAKROT = 1;   	* Apumakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
	%LET APUMAK_TIED_KE = KANSELapumakrot; * Apumakroissa käytettävän tiedoston nimi ;
	%LET POIMINTA = 1;  	* Muuttujien poiminta (1 jos ajetaan, 0 jos ei);
	%LET TULOKSET = 1;		* Yhteenvetotaulukot (1 jos ajetaan, 0 jos ei);

	%LET PKANSEL = pkansel; * Käytettävän parametritiedoston nimi ;

	* Tulostaulukoiden esivalinnat ; 

	%LET TULOSLAAJ = 1 ; 	 * Mikrotason tulosaineiston laajuus (1 = suppea, 2 = laaja (palveluaineisto)) ;
	%LET MUUTTUJAT = takelake TAKUUELA kelkan KANSANELAKE kellaps LAPSIKOROT rili RILISA riyl YLIMRILI kelapu EHOITUKI hlaho LVTUKI 
				     hvamtuk VTUKI rvvm KTUKI mamutuki MMTUKI LAELAKEDATA LAPSENELAKE LEELAKEDATA LESKENELAKE; * Taulukoitavat muuttujat (summataulukot) ;
	%LET YKSIKKO = 1;		 * Tulostaulukoiden yksikkö (1 = henkilö, 2 = kotitalous) ;
	%LET LUOK_HLO1 = ; * Taulukoinnin 1. henkilöluokitus (jos YKSIKKO = 1)
							   Vaihtoehtoina: 
							     desmod (tulodesiilit, ekvivalentit tulot (modoecd), hlöpainot)
							     ikavu (henkilön mukaiset ikäryhmät)
							     elivtu (kotitalouden elinvaihe)
							     koulas (henkilön koulutusaste TK1997)
							     soss (henkilön sosioekonominen asema AML2001)
							     rake (kotitalouden rakenne) ;
	%LET LUOK_HLO2 = ;		 * Taulukoinnin 2. henkilöluokitus ;
	%LET LUOK_HLO3 = ;		 * Taulukoinnin 3. henkilöluokitus ;

	%LET LUOK_KOTI1 = ; * Taulukoinnin 1. kotitalousluokitus (jos YKSIKKO = 2) 
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
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_KE..sas";
%END;

/* Ajetaan apumakrot ja tallennetaan ne (optio) */

%IF &APUMAKROT = 1 %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&APUMAK_TIED_KE..sas";
%END;

%MEND TeeMakrot;

%TeeMakrot;


/* 3. Datan poiminta ja apumuuttujien luominen (optio) */

%MACRO KansEl_Muut_Poiminta;

%IF &POIMINTA = 1 %THEN %DO;

	DATA STARTDAT.START_KANSEL;
	SET POHJADAT.&AINEISTO&AVUOSI 
	(WHERE = (takelake > 0 OR elak > 0 OR kellaps > 0 OR rili > 0 OR lelake > 0 OR hvamtuk > 0 OR rvvm > 0 OR hlaho > 0 OR mamulkm > 0));

	IF rili <= 0 THEN rili = .;
	IF kelkan <= 0 THEN kelkan = .;
	IF takelake <= 0 THEN takelake = .;
	IF kellaps <= 0 THEN kellaps = .;
	IF riyl <= 0 THEN riyl = .;
	IF hvamtuk <= 0 THEN hvamtuk = .;
	IF rvvm <= 0 THEN rvvm = .;
	IF hlaho <= 0 THEN hlaho = .;
	IF kelapu <= 0 THEN kelapu = .;
	IF mamutuki <= 0 THEN mamutuki = .;
	IF hpelake <= 0 THEN hpelake = .;

	* Näitä tietoja ei ole datassa, eikä niillä ole merkitystä vuoden 2008 jälkeisessä lainsäädännössä. 
	  Asetetaan oletusarvot ;

	KUNRY = 2; 
	LAITOS = max(0, lasmu); 

	LAELAKEDATA = SUM(lapper, laptay);
	IF hlepe > 0 OR hleto > 0 THEN DO;;
	LEELAKEDATA = hpelake;
	END;

	*Lapseneläke;
	IF lapper > 0 THEN DO;
		IF laptay <= 0 THEN laptay = 0;
		ELSE perlaji = 6;
		IF laptay = 0 AND perlaji NOT IN (4, 5) THEN perlaji = 4;
	END;

	/* Luodaan uusille apumuuttujille selkokieliset kuvaukset */

	LABEL
	LAELAKEDATA = 'Lapseneläke (e/v), DATA'
	LEELAKEDATA = 'Leskeneläke (e/v), DATA'	

	KUNRY = 'Kuntaryhmä (1/2), DATA'
	LAITOS = 'Laitosasuja (0/1), DATA';

	KEEP  hnro knro asko perlaji kelkan kelapu kellaps rili riyl helakyht hlepe hleto ikakk
 	hvamtuk	rvvm hlaho mamutuki mamulkm ehtm lhtm hpelake velaji tklaji tylaji 
	lelake tansel tmuuel ttapel tpotel hrelake htperhe tuntelpe hpalktu hrelake htperhe tuntelpe svatvp
	lapper pe_perus alku pe_perus mlispvt1-mlispvt4 jatko laptay lapel tayde tluokke takelake ikavu omalaji 

	LAELAKEDATA LEELAKEDATA ELAKTULO KANSEL_TULO LAPSETULO LESK_JATKOTULO
	MAMUTULOT KPUOLISO KUNRY LAITOS TAYSORPO ELAKUUK LAPSKUUK RILIKUUK
	EHOITOKUUK LVTUKIKUUK VTUKIKUUK KTUKIKUUK KORJ_LAPEL KORJ_ALKU TAKUUEL_TULO VARHENP ASUSUHT LYKKAYSK
	;

	RUN;

%END;

%MEND KansEl_Muut_Poiminta;

%KansEl_Muut_Poiminta;


/* 4. Simulointivaihe */

%LET alkoi2&malli = %SYSFUNC(TIME());

/* 4.1 Jos parametrit luetaan makromuuttujiksi ennen simulontia, ajetaan tämä makro, erillisajossa */

%MACRO KuukSimul;

%IF &F = S AND &TYYPPI = SIMULX %THEN %DO;

	%HaeParam_KansElSIMUL(&LVUOSI, &LKUUK, &INF);

%END;

%MEND KuukSimul;

%KuukSimul;

/* 4.2 Varsinainen simulointivaihe */

%MACRO KansEl_Simuloi_Data;

DATA OUTPUT.&TULOSNIMI_KE;
SET STARTDAT.START_KANSEL;

*Lasketaan kansaneläkkeet;

*Kansaneläke lasketaan siihen oikeutetuille. Ennen vuotta 1997 pohjaosa siis simuloidaan kaikille eläkeläisille;
/* Vanhuuseläkkeet*/ IF ((ikavu > 65 OR (ikavu = 65 AND ikakk > 0) OR
/* Varhaiseläkkeet*/ ((ikavu > 62 OR ikavu = 62 AND ikakk > 0) AND ((MAX(OF mlispvt1-mlispvt4) > 0 AND &LVUOSI >= 2011) OR velaji = 7 OR omalaji = 2)) OR
/* Työkyvyttömyys */ ((16 <= ikavu < 65 OR ikavu = 65 AND ikakk < 11) AND (omalaji IN (3,4,5) OR tklaji IN (2,8,9))) OR
/* Työttömyyseläke*/ (tylaji = 4 OR omalaji = 8)) AND
/* Ei osa-aikaisia*/ velaji NE 6 AND
/* Eläkkeelläolo  */ ELAKUUK > 0 AND ELAKTULO > 0 AND 
					 (takelake NOT > 0 OR kelkan > 0)) OR 

/* Vanha pohjaosa */ (&LVUOSI <= 1996 AND ELAKTULO > 0) THEN DO;


	IF &KDATATULO = 0 AND kelkan > 0 THEN DO;
		%Kansanelake_SimpleV&F(KANSANELAKE, &LVUOSI, &INF, LAITOS, KPUOLISO, KUNRY, KANSEL_TULO, ASUSUHT);
	END;
	ELSE DO;
		%Kansanelake_SimpleV&F(KANSANELAKE, &LVUOSI, &INF, LAITOS, KPUOLISO, KUNRY, SUM(ELAKTULO, -kelkan, -takelake)/ ELAKUUK * 12, ASUSUHT);
	END;
	KANSANELAKE = KANSANELAKE * (LYKKAYSK * VARHENP) * ELAKUUK;
END;

*Lapsikorotukset;
IF kellaps > 0 THEN DO;
	%KanseLLisatV&F(LAPSIKOROT, &LVUOSI, &INF, 1, 0, 0, 0, 0, 0, 0, 0, KUNRY, 1);
	LAPSIKOROT = LAPSKUUK * LAPSIKOROT;
	IF &LVUOSI < 2002 AND KANSANELAKE = 0 THEN LAPSIKOROT = 0;
END;


*Rintamalisät;
IF rili > 0 THEN DO;
	%KanseLLisatV&F(RILISA, &LVUOSI, &INF, 1, 0, 0, 0, 0, 0, 1, 0, KUNRY, 0);
	RILISA = RILIKUUK * RILISA;
END;

*Ylimääräiset rintamalisät;
IF riyl > 0 THEN DO;
	IF &KDATATULO = 0 THEN DO;
		LASKLISAOSA = 0;
		IF &LVUOSI < 1997 THEN DO;
			%Kansanelake_SimpleV&F(LASKLISAOSA, &LVUOSI, &INF, LAITOS, KPUOLISO, KUNRY, KANSEL_TULO, ASUSUHT);
			LASKLISAOSA = LASKLISAOSA - &PerPohja;
		END;
		%YlimRintLisaV&F(YLIMRILI, &LVUOSI, &INF, LASKLISAOSA, KANSANELAKE / ELAKUUK, KANSEL_TULO);
	END;

	ELSE DO;
		LISAOSA = 0;
		IF &LVUOSI < 1997 THEN DO;
			%Kansanelake_SimpleV&F(LISAOSA, &LVUOSI, &INF, LAITOS, KPUOLISO, KUNRY, SUM(ELAKTULO, -kelkan, -takelake), ASUSUHT);
			LISAOSA = LISAOSA - &PerPohja;
		END;
		%YlimRintLisaV&F(YLIMRILI, &LVUOSI, &INF, LISAOSA, kelkan / ELAKUUK, SUM(ELAKTULO, -kelkan, -takelake) / 12);
	END;

	YLIMRILI = RILIKUUK * YLIMRILI;

	DROP LASKLISAOSA LISAOSA; 
END;

*Hoitotuet ja veteraanilisä;
IF kelapu > 0 THEN DO;
	%KanseLLisatV&F(EHOITUKI, &LVUOSI, &INF, 1, (ehtm = 4 OR (YLIMRILI > 0 AND ehtm IN (2,3))), (ehtm = 5), (ehtm = 1), (ehtm = 2), (ehtm = 3), 0, 0, KUNRY, 0);
	EHOITUKI = EHOITUKI * EHOITOKUUK;
END;

*Vammaistuet;
IF hlaho > 0 THEN DO;
	%VammTukiV&F(LVTUKI, &LVUOSI, &INF, 0, 1, 0, lhtm);
	LVTUKI = LVTUKI * LVTUKIKUUK;
END;
IF hvamtuk > 0 THEN DO;
	%VammTukiV&F(VTUKI, &LVUOSI, &INF, 1, 0, 0, lhtm);
	VTUKI = VTUKI * VTUKIKUUK;
	IF VTUKI <= 0 THEN VTUKI = .;
END;
IF rvvm > 0 THEN DO;
	%VammTukiV&F(KTUKI, &LVUOSI, &INF, 0, 0, 1, 1);
	KTUKI = KTUKI * KTUKIKUUK;
END;
DROP lhtm;

*Maahanmuuttajan erityistuki;
IF mamulkm > 0 THEN DO;
	%MaMuErTukiV&F(MMTUKI, &LVUOSI, &INF, LAITOS, KPUOLISO, KUNRY, MAMUTULOT, 0);

	*Tuki on alkanut ja päättynyt keskellä vuotta (10/2003 - 2/2011), mikä otetaan seuraavassa huomioon;
	%IF &LVUOSI = 2003 %THEN %DO;
		%IF &TYYPPI = SIMULX %THEN %DO;
			IF &LKUUK < 10 THEN MMTUKI = .;
			ELSE MMTUKI = MMTUKI * 4 * mamulkm;
		%END;	
		%ELSE %DO; MMTUKI = MMTUKI * 4 * MIN(mamulkm, 3); %END;
	%END;
	%ELSE %IF &LVUOSI = 2011 %THEN %DO;
		%IF &TYYPPI = SIMULX %THEN %DO;
			IF &LKUUK > 2 THEN MMTUKI = .;
			ELSE MMTUKI = MMTUKI * 6 * ELAKUUK;
		%END;
		%ELSE %DO; MMTUKI = MMTUKI * 6 * MIN(mamulkm, 2); %END;
	%END;
	%ELSE %DO; MMTUKI = MMTUKI * mamulkm; %END;

END;

*Lapseneläke;
IF KORJ_LAPEL > 0 THEN DO;
	IF &KDATATULO = 0 THEN DO;	
		%LapsenElakeAV&F(LAPSENELAKE, &LVUOSI, &INF, TAYSORPO, LAPSETULO, (perlaji IN (4,5)));
	END;
	ELSE DO;
		%LapsenElakeAV&F(LAPSENELAKE, &LVUOSI, &INF, TAYSORPO, SUM(hrelake, htperhe, tuntelpe) / 12, (perlaji IN (4,5)));
	END;
	LAPSENELAKE = KORJ_LAPEL * LAPSENELAKE;
END;

*Lesken alku- ja jatkoeläke;
IF KORJ_ALKU > 0 THEN DO;
	%LeskenElakeAV&F(LEALKUE, &LVUOSI, &INF, 1, KPUOLISO, KUNRY, 0, hpalktu, svatvp, SUM(ELAKTULO, -hpelake), 0);
	LEALKUE = LEALKUE * KORJ_ALKU;
END;
IF jatko > 0 THEN DO;
	IF &KDATATULO = 0 THEN DO;
		%LeskenElakeAV&F(LEJATKOE, &LVUOSI, &INF, 0, KPUOLISO, KUNRY, (pe_perus > 0), 0, 0, LESK_JATKOTULO, 0);
	END;
	ELSE DO;
		%LeskenElakeAV&F(LEJATKOE, &LVUOSI, &INF, 0, KPUOLISO, KUNRY, (pe_perus > 0), hpalktu, svatvp, SUM(ELAKTULO, -hpelake), 0);
	END;
	LEJATKOE = LEJATKOE * jatko;
END;

LESKENELAKE = SUM(LEALKUE, LEJATKOE);


*Takuueläke;

*Takuueläke simuloidaan siihen oikeutetuille, ei etuuden saamisen mukaan;
IF (mamulkm > 0 OR KANSANELAKE > 0 OR velaji IN (1,7) OR tklaji IN (2,8,9) OR tylaji = 4 OR ttapel > 0 or takelake>0) AND &LVUOSI >= 2011 AND ELAKUUK > 0 THEN DO; 


	IF &KDATATULO = 0 and takelake > 0 THEN DO;
		%TakuuElakeV&F(TAKUUELA, &LVUOSI, &INF, SUM(TAKUUEL_TULO, KANSANELAKE, LEALKUE, LEJATKOE, LAPSENELAKE) / 12, VARHENP);
	END;
	ELSE DO;
		%TakuuElakeV&F(TAKUUELA, &LVUOSI, &INF, SUM(ELAKTULO, -takelake, -kelkan, -hpelake, KANSANELAKE, LESKENELAKE, LAPSENELAKE) / ELAKUUK, VARHENP);
	END;

	%IF &TYYPPI = SIMULX %THEN %DO;
		IF &LKUUK < 3 AND &LVUOSI = 2011 THEN TAKUUELA = .;
		ELSE TAKUUELA = ELAKUUK * TAKUUELA;
	%END;
	%ELSE %DO;
		*Vuonna 2011 vuoden kuukausien keskiarvo aliarvioi todellista kuukausikeskiarvoa, joten summaa korotetaan 20 %;
		IF &LVUOSI = 2011 THEN TAKUUELA = MIN(10, ELAKUUK) * 1.2 * TAKUUELA;
		ELSE TAKUUELA = ELAKUUK * TAKUUELA;
	%END;
END;

KEEP hnro knro kelkan kellaps rili riyl kelapu hlaho hvamtuk rvvm mamutuki takelake
TAKUUELA KANSANELAKE LAPSIKOROT RILISA YLIMRILI EHOITUKI LVTUKI VTUKI KTUKI MMTUKI 
LAELAKEDATA LAPSENELAKE LEELAKEDATA LESKENELAKE LEALKUE LEJATKOE;

RUN;

/* 4.3 Yhdistetään simuloitu data palveluaineistoon (riippuen tulosaineiston laajuden valinnasta) */

DATA OUTPUT.&TULOSNIMI_KE;

/* 4.3.1 Suppea tulostiedosto (vain tärkeimmät luokittelumuuttujat) */

%IF &TULOSLAAJ = 1 %THEN %DO; 
	MERGE POHJADAT.&AINEISTO&AVUOSI 
	(KEEP = hnro knro &PAINO ikavu ikavuV desmod soss paasoss elivtu koulas rake)
	OUTPUT.&TULOSNIMI_KE;
%END;

/* 4.3.2 Laaja tulostiedosto (palveluaineiston mukainen tulostiedosto) */

%IF &TULOSLAAJ = 2 %THEN %DO; 
	MERGE POHJADAT.&AINEISTO&AVUOSI OUTPUT.&TULOSNIMI_KE;
%END;

BY hnro;

* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukumäärät voidaan laskea suoraan ;

ARRAY PISTE 
	kelkan kellaps rili riyl kelapu hlaho hvamtuk rvvm mamutuki takelake
	TAKUUELA KANSANELAKE LAPSIKOROT RILISA YLIMRILI EHOITUKI LVTUKI VTUKI KTUKI MMTUKI 
	LAELAKEDATA LAPSENELAKE LEELAKEDATA LESKENELAKE LEALKUE LEJATKOE;
DO OVER PISTE;
	IF PISTE <= 0 THEN PISTE = .;
END;

* Luodaan simuloiduille ja datan muuttujille selitteet ;

LABEL 
TAKUUELA = 'Takuueläke, MALLI'
takelake = 'Takuueläke, DATA'
kelkan = 'Kansaneläkkeet, DATA'
KANSANELAKE = 'Kansaneläkkeet, MALLI'
kellaps = 'Lapsikorotukset, DATA'
LAPSIKOROT = 'Lapsikorotukset, MALLI'
rili = 'Rintamalisät, DATA'
RILISA = 'Rintamalisät, MALLI'
riyl = 'Ylimääräiset rintamalisät, DATA'
YLIMRILI = 'Ylimääräiset rintamalisät, MALLI'
kelapu = 'Eläkkeensaajan hoitotuet, DATA'
EHOITUKI = 'Eläkkeensaajan hoitotuet, MALLI'
hlaho = 'Alle 16-vuotiaan vammaistuki, DATA'
LVTUKI = 'Alle 16-vuotiaan vammaistuki, MALLI'
hvamtuk = 'Vammaistuki, DATA'
VTUKI = 'Vammaistuki, MALLI'
rvvm = 'Ruokavaliokorvaus, DATA'
KTUKI = 'Ruokavaliokorvaus, MALLI'
mamutuki = 'Maahanmuuttajan erityistuki, DATA'
MMTUKI = 'Maahanmuuttajan erityistuki, MALLI'
LAELAKEDATA = 'Lapseneläke, DATA'
LAPSENELAKE = 'Lapseneläke, MALLI'
LEELAKEDATA = 'Leskeneläke, DATA'
LESKENELAKE = 'Leskeneläke, MALLI'
LEALKUE = 'Lesken alkueläke, MALLI'
LEJATKOE = 'Lesken jatkoeläke, MALLI';

RUN;

%MEND KansEl_Simuloi_Data;

%KansEl_Simuloi_Data;

%LET loppui2&malli = %SYSFUNC(TIME());


/* 5. Luodaan summatason tulostaulukot (optio) */

%MACRO KansEl_Tulokset;

/* 5.1 Kotitaloustason tulokset (optio) */

/* 5.1.1 Mikrotason tulosaineiston summaus kotitaloustasolle (optio) */

%IF &YKSIKKO = 2 AND &START NE 1 %THEN %DO;

	PROC SUMMARY DATA=OUTPUT.&TULOSNIMI_KE (DROP = hnro);
	BY knro ;
	ID &PAINO ikavuV desmod paasoss elivtu koulas rake;
	VAR &MUUTTUJAT _NUMERIC_;
	OUTPUT OUT = OUTPUT.&TULOSNIMI_KE (DROP = ikavu soss _TYPE_ _FREQ_)  SUM = ;
	RUN;

%END;

/* 5.1.2 Summatason tulostaulukko (optio) */

%IF &TULOKSET = 1 %THEN %DO;

	%IF &YKSIKKO = 2 %THEN %DO; 

		/* Siirretään tiedot Exceliin (optio) */

		%IF &EXCEL = 1 %THEN %DO;

			ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_KE._SUMMAT.xls" STYLE = MINIMAL;

		%END;

		PROC MEANS DATA=OUTPUT.&TULOSNIMI_KE &SUMWGT &SUM &MIN &MAX &RANGE &MEAN &MEDIAN &MODE &STD &VAR &CV NONOBS ORDER=DATA NWAY MAXDEC = 0; 
		TITLE "TUNNUSLUVUT (KOTITALOUSTASO), &MALLI";
		CLASS &LUOK_KOTI1 &LUOK_KOTI2 &LUOK_KOTI3 / MLF PRELOADFMT;
		VAR &MUUTTUJAT ;
		FORMAT _NUMERIC_ tuhat. ;
		%DO I = 1 %TO 3; 
		%IF %LENGTH (&&LUOK_KOTI&I) >0 %THEN %DO;
			FORMAT &&LUOK_KOTI&I &&LUOK_KOTI&I... ;
		%END;%END;
		OUTPUT OUT = OUTPUT.&TULOSNIMI_KE._SUMMAT (DROP = _TYPE_ _FREQ_)
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
	
	/* 5.2 Henkilötason tulokset (oletus) */

	%ELSE %DO;

		/* Siirretään tiedot Exceliin (optio) */

		%IF &EXCEL = 1 %THEN %DO;

			ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_KE._SUMMAT.xls" STYLE = MINIMAL;

		%END;

		PROC MEANS DATA=OUTPUT.&TULOSNIMI_KE &SUMWGT &SUM &MIN &MAX &RANGE &MEAN &MEDIAN &MODE &STD &VAR &CV NONOBS ORDER=DATA NWAY MAXDEC = 0;
		TITLE "TUNNUSLUVUT (HENKILÖTASO), &MALLI";
		CLASS &LUOK_HLO1 &LUOK_HLO2 &LUOK_HLO3 / MLF PRELOADFMT;
		VAR &MUUTTUJAT ;
		FORMAT _NUMERIC_ tuhat. ;
		%DO I = 1 %TO 3; 
		%IF %LENGTH (&&LUOK_HLO&I) >0 %THEN %DO;
			FORMAT &&LUOK_HLO&I &&LUOK_HLO&I... ;
		%END;%END;
		OUTPUT OUT = OUTPUT.&TULOSNIMI_KE._SUMMAT (DROP = _TYPE_ _FREQ_)
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

%MEND KansEl_Tulokset;

%KansEl_Tulokset;


/* 6. Mitataan kuinka kauan osavaiheisiin kului aikaa */

%LET loppui1 = %SYSFUNC(TIME());

%LET loppui1&malli = %SYSFUNC(TIME());

%LET kului1&malli = %SYSEVALF(&&loppui1&malli - &&alkoi1&malli);

%LET kului2&malli = %SYSEVALF(&&loppui2&malli - &&alkoi2&malli);

%LET kului1&malli = %SYSFUNC(PUTN(&&kului1&malli, time10.2));

%LET kului2&malli = %SYSFUNC(PUTN(&&kului2&malli, time10.2));


%PUT &malli. Koko laskenta. Aikaa kului (hh:mm:ss.00) &&kului1&malli;

%PUT &malli. Varsinainen simulointi. Aikaa kului (hh:mm:ss.00) &&kului2&malli;

