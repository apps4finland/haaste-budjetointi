/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyödyntää Tilastokeskuksen yleisten
* käyttöehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto päähakemistossa.
******************************************************************************/

/***********************************************************
* Kuvaus: Lapsilisän simulointimalli 2011            	   *
* Tekijä: Maria Valaste / KELA 		                	   *
* Luotu: 14.11.2011 			       					   *
* Viimeksi päivitetty: 23.10.2012		     		       *
* Päivittäjä: Maria Valaste / KELA	   					   *
************************************************************/ 


/* 0. Yleisiä vakioiden määrittelyjä (älä muuta näitä!) */

%LET START = &OUT;

%LET MALLI = LLISA;

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

	%LET AVUOSI = 2010;		* Aineistovuosi (vvvv);

	%LET LVUOSI = 2010;		* Lainsäädäntövuosi (vvvv);

	%LET TYYPPI = SIMUL;	* Parametrien hakutyyppi: SIMUL (vuosikeskiarvo) tai SIMULX (parametrit haetaan tietylle kuukaudelle);

	%LET LKUUK = 12;         * Lainsäädäntökuukausi, jos parametrit haetaan tietylle kuukaudelle;

	%LET AINEISTO = PALV ;  * Käytettävä aineisto (PALV = Palveluaineisto, REK = Rekisteriaineisto) ;

	%LET TULOSNIMI_LL = llisa_simul_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;

	* Inflaatiokorjaus. Parametrien deflatoinnissa käytettävän kertoimen voi syöttää itse
	  INF-makromuuttujaan (HUOM! desimaalit erotettava pisteellä .). Jos puolestaan haluaa käyttää automaattista 
	  elinkustannusindeksiin perustuvaa parametrien muunnoskerrointa, 
	  tulee INF-makromuuttujalle antaa arvoksi 999 ; 	

	%LET INF = 1.00; * Syötä arvo tai 999 ;
	%LET PINDEKSI_VUOSI = pindeksi_vuosi; *Käytettävä indeksien parametritaulukko;		

	* Ajettavat osavaiheet ; 

	%LET LAKIMAKROT = 1;    * Lakimakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
	%LET LAKIMAK_TIED_LL = LLISAlakimakrot;	* Lakimakroissa käytettävän tiedoston nimi ;
	%LET APUMAKROT = 1;   	* Apumakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
	%LET APUMAK_TIED_LL = LLISAapumakrot; * Apumakroissa käytettävän tiedoston nimi ;
	%LET POIMINTA = 1;  	* Muuttujien poiminta (1 jos ajetaan, 0 jos ei);
	%LET TULOKSET = 1;		* Yhteenvetotaulukot (1 jos ajetaan, 0 jos ei);

	%LET PLLISA = pllisa; * Käytettävän parametritiedoston nimi ;

	* Tulostaulukoiden esivalinnat ; 

	%LET TULOSLAAJ = 1 ; 	 * Mikrotason tulosaineiston laajuus (1 = suppea, 2 = laaja (palveluaineisto)) ;
	%LET MUUTTUJAT = llmk LLISA_HH lbeltuki ELATUSTUET_HH aitav AITAVUST ; * Taulukoitavat muuttujat (summataulukot) ;
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
	%LET MODE =  ;
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
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_LL..sas";
%END;

/* Ajetaan apumakrot ja tallennetaan ne (optio) */

%IF &APUMAKROT = 1 %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&APUMAK_TIED_LL..sas";
%END;

%MEND TeeMakrot;

%TeeMakrot;


/* 3. Datan poiminta ja apumuuttujien luominen (optio) */

%MACRO LLisa_Muutt_Poiminta; 

%IF &POIMINTA = 1 %THEN %DO;

	%LOCAL TYYPPI;
	%LET TYYPPI = SIMUL;

	/* 3.1 Määritellään tarvittavat palveluaineiston muuttujat taulukkoihin START_LLISA, START_AITAV, START_ELTUKI */

	DATA STARTDAT.START_LLISA; 
  	SET POHJADAT.&AINEISTO&AVUOSI
  	(KEEP = hnro knro asko syvu syntkk lapsia llmk csivs elivtu ikavu syntkk ikakk lalu3); 
	RUN;

	DATA STARTDAT.START_AITAV; 
  	SET POHJADAT.&AINEISTO&AVUOSI
  	(KEEP = knro yh aitav); 
	WHERE aitav > 0;
	RUN;

	DATA STARTDAT.START_ELTUKI (KEEP = hnro knro elivtu elasa lbeltuki
					ELTUKIKUUK APUOLISO)  ;
	SET POHJADAT.&AINEISTO&AVUOSI;
	WHERE ELTUKIKUUK > 0;
	IF elivtu IN (20, 83, 84) THEN APUOLISO = 0; ELSE APUOLISO = 1;
	LABEL 	
	APUOLISO = 'Puoliso (0/1), DATA'
	RUN;

	/* 3.2 Lisätään aineistoon apumuuttujia */

	* Lisätään yksinhuoltajatunnus ja 
	  tieto äitiysavustuksesta jokaiselle kotitalouteen kuuluvalle ;

	DATA STARTDAT.START_LLISA; 
	SET STARTDAT.START_LLISA;

  	* Muuttujien ONPUOLISO ja YKSINHUOLTAJA muodostaminen ;
	IF elivtu IN (20, 83, 84) THEN YKSINHUOLTAJA =  1; 
	ELSE YKSINHUOLTAJA = 0;
	IF YKSINHUOLTAJA = 0 THEN ONPUOLISO = 1; 
	ELSE ONPUOLISO = 0;

	* Lapsilisäkuukaudet lasketaan tutkimalla ikäkuukausia.
	  Jos ikärajan muuttamista kokeillaan, tämä kuuluu varsinaiseen simulointiin eikä
	  apumuuttujien luontiin ;

	 
	
	* Lapsilisäkuukaudet tarkasteluvuoden aikana uuteen muuttujaan LLKUUK ;
	%IkaKuuk_LLisa(IKAKUUK, 0, 16, (12 * ikavu + ikakk));
	LLKUUK = IKAKUUK; 

	DROP IKAKUUK;

	RUN;

	* Muodostetaan osa-aineisto, jossa järjestetään ne lapset, joilla 
  	  lapsilisäkuukausia kotitalouden sisällä iän mukaan laskevaan järjestykseen ;

	PROC SORT DATA =  STARTDAT.START_LLISA OUT = STARTDAT.START_LLISA;
	BY knro DESCENDING ikavu ikakk;
	WHERE LLKUUK > 0;
	RUN;

	* Haetaan lapsilisän parametrit ;

	%HaeParam_LLisaSIMUL(&AVUOSI, 1, &INF);

	* Lasketaan kullekin lapselle eri kuukausille seuraavat tiedot;
	** onko oikeutettu lapsilisaan (LAPS);
	** järjestysluku (JARJ);
	** onko alle 3-vuotias (ALLE3_);
	** onko 16-vuotias (V16_);

	DATA STARTDAT.START_LLISA;
	SET STARTDAT.START_LLISA;
    BY KNRO;
	RETAIN JARJ1 - JARJ12;
    ARRAY JARJ(12) JARJ1 - JARJ12 ;
    ARRAY LAPS(12) LAPS1 - LAPS12 ;
	ARRAY ALLE3_(12) ALLE3_1 - ALLE3_12 ;
	ARRAY V16_(12) V16_1 - V16_12 ;

    IF FIRST.knro THEN
	 DO i = 1 TO 12;
		JARJ(i) = 0;
	 END;

	DO j = 1 TO 12;
			 IKA = 12 * ikavu + ikakk - (12 - j);
			 IF IKA > 0 AND IKA <= 12 * &IRaja THEN DO;
			     LAPS(j) = 1;
				 JARJ(j) = JARJ(j) + 1;
			 END;
			 ELSE LAPS(j) = 0;
			 IF IKA > 0 AND IKA <= 3 * 12 THEN ALLE3_(j) = 1;
			 ELSE ALLE3_(j) = 0;
			 IF IKA > 12 * 16 AND IKA <= 12 * 17 THEN V16_(j) = 1;
			 ELSE V16_(j) = 0;

		 	* Käytetään taulukon LAPS tietoja oikean järjestysluvun hiomiseen ;
			JARJ(j) = LAPS(j) * JARJ(j);
	END;

	DROP IKA i j LAPS1-LAPS12;

	LABEL 	

	JARJ1 	= 'Lapsen järjestysluku tammikuussa, DATA' 		
	JARJ2  	= 'Lapsen järjestysluku helmikuussa, DATA'
	JARJ3  	= 'Lapsen järjestysluku maaliskuussa, DATA'		
	JARJ4  	= 'Lapsen järjestysluku huhtikuussa, DATA'
	JARJ5  	= 'Lapsen järjestysluku toukokuussa, DATA'		
	JARJ6  	= 'Lapsen järjestysluku kesäkuussa, DATA'
	JARJ7  	= 'Lapsen järjestysluku heinäkuussa, DATA'		
	JARJ8  	= 'Lapsen järjestysluku elokuussa, DATA'
	JARJ9  	= 'Lapsen järjestysluku syyskuussa, DATA'		
	JARJ10 	= 'Lapsen järjestysluku lokakuussa, DATA'
	JARJ11 	= 'Lapsen järjestysluku marraskuussa, DATA'		
	JARJ12 	= 'Lapsen järjestysluku joulukuussa, DATA'
	ALLE3_1	= 'Alle 3-vuotias tammikuussa, DATA'			
	ALLE3_2	= 'Alle 3-vuotias helmikuussa, DATA'
	ALLE3_3	= 'Alle 3-vuotias maaliskuussa, DATA'			
	ALLE3_4 = 'Alle 3-vuotias huhtikuussa, DATA'
	ALLE3_5	= 'Alle 3-vuotias toukokuussa, DATA'			
	ALLE3_6	= 'Alle 3-vuotias kesäkuussa, DATA'
	ALLE3_7	= 'Alle 3-vuotias heinäkuussa, DATA'			
	ALLE3_8	= 'Alle 3-vuotias elokuussa, DATA'
	ALLE3_9	= 'Alle 3-vuotias syyskuussa, DATA'				
	ALLE3_10= 'Alle 3-vuotias lokakuussa, DATA'
	ALLE3_11= 'Alle 3-vuotias marraskuussa, DATA'			
	ALLE3_12= 'Alle 3-vuotias joulukuussa, DATA'
	V16_1	= '16-vuotias tammikuussa, DATA'				
	V16_2	= '16-vuotias helmikuussa, DATA'
	V16_3	= '16-vuotias maaliskuussa, DATA'				
	V16_4	= '16-vuotias huhtikuussa, DATA'
	V16_5	= '16-vuotias toukokuussa, DATA'				
	V16_6	= '16-vuotias kesäkuussa, DATA'
	V16_7	= '16-vuotias heinäkuussa, DATA'				
	V16_8	= '16-vuotias elokuussa, DATA'
	V16_9	= '16-vuotias syyskuussa, DATA'					
	V16_10  = '16-vuotias lokakuussa, DATA'
	V16_11	= '16-vuotias marraskuussa, DATA'				
	V16_12	= '16-vuotias joulukuussa, DATA'
	YKSINHUOLTAJA= 'Yksinhuoltajatunnus (0/1), DATA'
	ONPUOLISO = 'Puoliso (0/1), DATA'
	LLKUUK = 'Lapsilisäkuukaudet tarkasteluvuoden aikana, DATA';

    RUN;

	* Muodostetaan taulukko START_AITAV niistä henkilöistä, jotka ovat saaneet äitiysavustusta (muuttuja aitav) ;

	PROC SUMMARY DATA = STARTDAT.START_AITAV;
	BY knro;
	OUTPUT OUT = STARTDAT.START_AITAV (KEEP = knro yh aitav) SUM(yh aitav) = ;
	RUN;

	* Päätellään äitiysavustukseen oikeuttavien lasten lukumäärä muuttujaan AITAVLUKUM jakamalla aineiston
	  äitiysavustus makrolla AitAvustV lasketulla äitiysavustuksella ja käyttämällä tulokseen apumakroa AitLkm.
	  Apumakro päättelee osamäärästä äitiysavustukseen oikeuttavien syntyneiden tai adoptoitujen lasten lukumäärän. ;

	DATA STARTDAT.START_AITAV; 
	SET STARTDAT.START_AITAV (KEEP = knro aitav);

	%AitAvustV&F(T1, &AVUOSI, 1, 1);
	LUKU = aitav / T1;

	%AitLkm(AITAVLUKUM, LUKU)

	KEEP knro aitav AITAVLUKUM;

	LABEL 	
	AITAVLUKUM = 'Laskennallinen äitiysavustukseen oikeuttavien lasten lukumäärä, DATA';

	RUN;

%END;

%MEND LLisa_Muutt_Poiminta;

%LLisa_Muutt_Poiminta;


/* 4. Simulointivaihe */

%LET alkoi2&malli = %SYSFUNC(TIME());

/* 4.1 Jos parametrit luetaan makromuuttujiksi ennen simulontia, ajetaan tämä makro, erillisajossa */

%MACRO KuukSimul;

%IF &F = S AND &TYYPPI = SIMULX %THEN %DO;

	%HaeParam_LLisaSIMUL(&LVUOSI, &LKUUK, &INF);

%END;

%MEND KuukSimul;

%KuukSimul;

/* 4.2 Varsinainen simulointivaihe */

%MACRO LLisa_Simuloi_Data;

/* 4.2.1 Lapsilisät */

* Lasketaan lapsilisä kaikille kuukausille erikseen järjestysluvun mukaan ;

DATA TEMP.LLISA_HH; 
SET STARTDAT.START_LLISA;

ARRAY JARJ(12) JARJ1-JARJ12;
ARRAY LAPS(12) LAPS1 - LAPS12;
ARRAY ALLE3_(12) ALLE3_1 - ALLE3_12;
ARRAY V16_ (12) V16_1 - V16_12;
LLISAK1 = 0;
LLISA = 0;

%DO K = 1 %TO 12;
		%LLisaK1&F(LLISAK1, &LVUOSI, &K, &INF, ONPUOLISO, ALLE3_(&K), V16_(&K), JARJ{&K}); 
		LLISA = SUM(LLISA, LLISAK1);
%END;

KEEP knro LLISA;
RUN;

* Lapsilisät kotitaloustasolla ;

PROC SUMMARY DATA = TEMP.LLISA_HH;
BY knro;
OUTPUT OUT = TEMP.LLISA_HH (KEEP = knro LLISA_HH) SUM(LLISA) = LLISA_HH;
RUN;

/* 4.2.2 Elatustuki */

DATA TEMP.ELTUKI_HH;
SET STARTDAT.START_ELTUKI;

* Lasketaan elatustuki kertomalla elatustukikuukausilla mallilla laskettu elatustuki,
josta vähennetään elatusapu;

%ElatTukiV&F(ELATUSV, &LVUOSI, &INF, APUOLISO, 1);
ELATUSTUET_HH = MAX(ELTUKIKUUK * ELATUSV - elasa, 0);

KEEP knro elasa lbeltuki ELTUKIKUUK APUOLISO ELATUSTUET_HH;
RUN;

* Elatustuet kotitaloustasolla ;

PROC SUMMARY DATA = TEMP.ELTUKI_HH;
BY knro;
OUTPUT OUT = TEMP.ELTUKI_HH (KEEP = knro ELATUSTUET_HH) 
SUM(ELATUSTUET_HH) = ELATUSTUET_HH;
RUN;

/* 4.2.3 Äitiysavustus */

* Lasketaan mallinnettu äitiysavustus muuttujaan AITAVUST makrolla AitAvutV;

DATA TEMP.AITAV_HH;
SET STARTDAT.START_AITAV;
		
%AitAvustV&F(AITAVUST, &LVUOSI, &INF, AITAVLUKUM);

KEEP knro aitav AITAVLUKUM AITAVUST;

RUN;

* Yhdistetään laskelmat;

DATA OUTPUT.&TULOSNIMI_LL;
MERGE TEMP.LLISA_HH TEMP.ELTUKI_HH TEMP.AITAV_HH;
BY knro;
RUN;

* Siirretään samansuuruinen lapsilisä kaikille saman talouden henkilöille ;

PROC SQL;
CREATE TABLE OUTPUT.&TULOSNIMI_LL
AS SELECT a.hnro, a.knro, b.LLISA_HH, b.ELATUSTUET_HH, b.AITAVUST
FROM POHJADAT.&AINEISTO&AVUOSI AS a 
LEFT JOIN OUTPUT.&TULOSNIMI_LL AS b ON a.knro = b.knro
ORDER BY knro, hnro;
QUIT;

/* 4.3 Yhdistetään simuloitu data palveluaineistoon (riippuen tulosaineiston laajuden valinnasta) */

DATA OUTPUT.&TULOSNIMI_LL;
	
/* 4.3.1 Suppea tulostiedosto (vain tärkeimmät luokittelumuuttujat) */

%IF &TULOSLAAJ = 1 %THEN %DO; 
	MERGE POHJADAT.&AINEISTO&AVUOSI 
	(KEEP = hnro knro asko &PAINO llmk lbeltuki aitav ikavu ikavuV desmod soss paasoss elivtu koulas rake)
	OUTPUT.&TULOSNIMI_LL;
%END;

/* 4.3.2 Laaja tulostiedosto (palveluaineiston mukainen tulostiedosto) */

%IF &TULOSLAAJ = 2 %THEN %DO; 
	MERGE POHJADAT.&AINEISTO&AVUOSI OUTPUT.&TULOSNIMI_LL;
%END;

BY hnro;

* Poistetaan simuloidut tulonsiirrot muilta, kuin talouden viitehenkilöltä ;

IF asko NE 1 THEN DO;
	LLISA_HH = 0; 
	ELATUSTUET_HH = 0;
	AITAVUST = 0;
END;

DROP asko;

* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukumäärät voidaan laskea suoraan ;

ARRAY PISTE 
	llmk LLISA_HH lbeltuki 
	ELATUSTUET_HH aitav AITAVUST;
DO OVER PISTE;
	IF PISTE <= 0 THEN PISTE = .;
END;

* Luodaan simuloiduille ja datan muuttujille selitteet ;

LABEL 	
llmk = 'Lapsilisät, DATA'
LLISA_HH = 'Lapsilisät, MALLI'
lbeltuki = 'Elatustuet, DATA'
ELATUSTUET_HH = 'Elatustuet, MALLI'
aitav = 'Äitiysavustukset, DATA'
AITAVUST = 'Äitiysavustukset, MALLI';

RUN;

%MEND LLisa_Simuloi_Data;

%LLisa_Simuloi_Data;

%LET loppui2&malli = %SYSFUNC(TIME());


/* 5. Luodaan summatason tulostaulukot (optio) 
	  HUOM! Lapsilisä-mallissa aina kotitaloustasolla viitehenkilön mukaan */

%MACRO LLisa_Tulokset;

%IF &TULOKSET = 1 %THEN %DO;

	/* Siirretään tiedot Exceliin (optio) */

	%IF &EXCEL = 1 %THEN %DO;

		ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_LL._SUMMAT.xls" STYLE = MINIMAL;

	%END;

	PROC MEANS DATA=OUTPUT.&TULOSNIMI_LL &SUMWGT &SUM &MIN &MAX &RANGE &MEAN &MEDIAN &MODE &STD &VAR &CV NONOBS ORDER=DATA NWAY MAXDEC = 0; 
	TITLE "TUNNUSLUVUT (KOTITALOUSTASO), &MALLI";
	CLASS &LUOK_KOTI1 &LUOK_KOTI2 &LUOK_KOTI3 / MLF PRELOADFMT;
	VAR &MUUTTUJAT ;
	FORMAT _NUMERIC_ tuhat. ;
	%DO I = 1 %TO 3; 
	%IF %LENGTH (&&LUOK_KOTI&I) >0 %THEN %DO;
		FORMAT &&LUOK_KOTI&I &&LUOK_KOTI&I... ;
	%END;%END;
	OUTPUT OUT = OUTPUT.&TULOSNIMI_LL._SUMMAT (DROP = _TYPE_ _FREQ_)
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

%MEND LLisa_Tulokset;

%LLisa_Tulokset;


/* 6. Mitataan kuinka kauan osavaiheisiin kului aikaa */

%LET loppui1 = %SYSFUNC(TIME());

%LET loppui1&malli = %SYSFUNC(TIME());

%LET kului1&malli = %SYSEVALF(&&loppui1&malli - &&alkoi1&malli);

%LET kului2&malli = %SYSEVALF(&&loppui2&malli - &&alkoi2&malli);

%LET kului1&malli = %SYSFUNC(PUTN(&&kului1&malli, time10.2));

%LET kului2&malli = %SYSFUNC(PUTN(&&kului2&malli, time10.2));


%PUT &malli. Koko laskenta. Aikaa kului (hh:mm:ss.00) &&kului1&malli;

%PUT &malli. Varsinainen simulointi. Aikaa kului (hh:mm:ss.00) &&kului2&malli;









