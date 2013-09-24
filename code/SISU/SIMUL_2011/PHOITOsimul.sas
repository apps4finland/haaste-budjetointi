/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyˆdynt‰‰ Tilastokeskuksen yleisten
* k‰yttˆehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto p‰‰hakemistossa.
******************************************************************************/

/***********************************************************
* Kuvaus: Lasten p‰iv‰hoitomaksujen simulointimalli 2011   *
* Tekij‰: Maria Valaste / KELA	                		   *
* Luotu: 25.11.2011			       					  	   *
* Viimeksi p‰ivitetty: 4.7.2013		     		           *
* P‰ivitt‰j‰: Jukka Mattila / TK	     			   	   *
***********************************************************/ 


/* 0. Yleisi‰ vakioiden m‰‰rittelyj‰ (‰l‰ muuta n‰it‰!) */

%LET START = &OUT;

%LET MALLI = PHOITO;

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

	%LET TULOSNIMI_PH = phoito_simul_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi;

	* Inflaatiokorjaus. Parametrien deflatoinnissa k‰ytett‰v‰n kertoimen voi syˆtt‰‰ itse
	  INF-makromuuttujaan (HUOM! desimaalit erotettava pisteell‰ .). Jos puolestaan haluaa k‰ytt‰‰ automaattista 
	  elinkustannusindeksiin perustuvaa parametrien muunnoskerrointa, 
	  tulee INF-makromuuttujalle antaa arvoksi 999 ; 	

	%LET INF = 1.00; * Syˆt‰ arvo tai 999 ;	
	%LET PINDEKSI_VUOSI = pindeksi_vuosi; *K‰ytett‰v‰ indeksien parametritaulukko;		

	* Ajettavat osavaiheet ; 

	%LET LAKIMAKROT = 1;    * Lakimakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
	%LET LAKIMAK_TIED_PH = KOTIHTUKIlakimakrot;	* Lakimakroissa k‰ytett‰v‰n tiedoston nimi ;
	%LET APUMAKROT = 1;   	* Apumakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
	%LET APUMAK_TIED_PH = KOTIHTUKIapumakrot; * Apumakroissa k‰ytett‰v‰n tiedoston nimi ;
	%LET POIMINTA = 1;  	* Muuttujien poiminta (1 jos ajetaan, 0 jos ei);
	%LET TULOKSET = 1;		* Yhteenvetotaulukot (1 jos ajetaan, 0 jos ei);

	%LET PKOTIHTUKI = pkotihtuki; * K‰ytett‰v‰n parametritiedoston nimi ;

	* Tulostaulukoiden esivalinnat ; 

	%LET TULOSLAAJ = 1 ; 	 * Mikrotason tulosaineiston laajuus (1 = suppea, 2 = laaja (palveluaineisto)) ;
	%LET MUUTTUJAT =  HMAKSU_KOKO PHMAKSU_KOK HMAKSU_OSA PHMAKSU_OS ; * Taulukoitavat muuttujat (summataulukot) ;
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

	/* Osamallien ohjausparametrien arvot asetetaan nolliksi, jos mallia ajetaan erillisajossa (= ei KOKO-mallista) */

	%LET SAIRVAK = 0; %LET TTURVA = 0; %LET OPINTUKI = 0; %LET KANSEL = 0; %LET KOTIHTUKI = 0; %LET VERO = 0; %LET LLISA = 0;

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
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_PH..sas";
%END;

/* Ajetaan apumakrot ja tallennetaan ne (optio) */

%IF &APUMAKROT = 1 %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&APUMAK_TIED_PH..sas";
%END;

%MEND TeeMakrot;

%TeeMakrot;


/* 3. Datan poiminta ja apumuuttujien luominen (optio) */

%MACRO PHoito_Muutt_Poiminta;

%IF &POIMINTA = 1 %THEN %DO; 

	%LOCAL TYYPPI;
	%LET TYYPPI = SIMUL;

	/* 3.1 M‰‰ritell‰‰n tarvittavat palveluaineiston muuttujat taulukkoon START_PHOITO_LAPSET */

		* Datasta poimittuja tietoja, p‰iv‰hoitomaksut ym.;
		* Jos halutaan tutkia suhdetta yksityiseen hoitoon ym.
		voidaan valita myˆs muuttujat hoiaikay hoimaksy hoisum;
		* muut = muu toiminta, esim. alle kouluik‰nen lapsi;


	DATA STARTDAT.START_PHOITO_LAPSET;
	SET POHJADAT.&AINEISTO&AVUOSI;
	KEEP hnro knro ykor desmod ikavu syvu syntkk asko hoimaksk hoiaikak hoimakso hoiaikao;  
	WHERE hoimaksk > 0 OR hoiaikak > 0 OR hoimakso > 0 OR hoiaikao > 0 OR hoimaksy > 0 OR hoiaikay > 0 OR hoisum > 0 OR ikavu < 8;
	RUN;
 
	/* 3.2 Poimitaan tietoja p‰iv‰hoitolapsien perheist‰ taulukkoon START_PHOITO_PERHEET */

	DATA TEMP.PHOITO_PERHEET;
	MERGE STARTDAT.START_PHOITO_LAPSET (IN = A KEEP = knro hnro) POHJADAT.&AINEISTO&AVUOSI;
	BY knro;
	IF A;
	KEEP hnro knro asko syvu syntkk ikavu ikakk svatva svatvp tkotihtu lbeltuki elasa opis tkopira;
	RUN;

	*Lajitellaan lapset ik‰j‰rjestykeen;

	PROC SORT DATA = STARTDAT.START_PHOITO_LAPSET;
	BY knro syvu syntkk; 
	RUN;

	*Lasketaan hoitolapsille j‰rjestysnumero;
	
	DATA STARTDAT.START_PHOITO_LAPSET;
	SET STARTDAT.START_PHOITO_LAPSET (WHERE = (hoiaikak > 0 OR hoiaikao > 0));
    RETAIN SISAR;
	BY knro;
   		
	IF FIRST.knro THEN SISAR = 1;

	ELSE SISAR = SISAR + 1;

	LABEL SISAR = 'Hoitolapsen j‰rjestysnumero, DATA';
  
	RUN;

	PROC SORT DATA = STARTDAT.START_PHOITO_LAPSET;
	BY knro hnro; 
	RUN;

	* Lasketaan lapsille ik‰kuukausia muuttujiin LAPSI_KUUK_17, LAPSI_KUUK_7, LAPSI_KUUK_1_5 ja PHOITO_LAPSI.
	  K‰ytet‰‰n laskennassa apumakroa Ika_Kuuk;

	DATA TEMP.PHOITO_PERHEET;
	MERGE TEMP.PHOITO_PERHEET (KEEP = knro hnro asko ikavu ikakk opis svatva svatvp tkotihtu lbeltuki elasa tkopira)
	STARTDAT.START_PHOITO_LAPSET (KEEP = knro hnro hoiaikak hoiaikao);
	BY knro hnro;

	%IkaKuuk_Phoito(IKA_KUUK1, 0, 16, (12 * ikavu + ikakk));
	LAPSI_KUUK_17 = IKA_KUUK1;

	%IkaKuuk_Phoito(IKA_KUUK2, 0, 6, (12 * ikavu + ikakk));
	LAPSI_KUUK_7 = MAX(IKA_KUUK2 - opis, 0);

	KEEP hnro knro asko svatva svatvp lbeltuki elasa tkotihtu LAPSI_KUUK_17 LAPSI_KUUK_7;

	LABEL LAPSI_KUUK_17 = 'Kuukausien lukum‰‰r‰ vuoden aikana, jolloin alle 17-vuotias, DATA'
		  LAPSI_KUUK_7 = 'Kuukausien lukum‰‰r‰ vuoden aikana, jolloin alle 7-vuotias, DATA';

	RUN;

	* Summataan ik‰kuukausia kotitalouksittain taulukkoon PHOITO_PERH_LAPSET ;

	PROC SUMMARY DATA = TEMP.PHOITO_PERHEET;
	BY knro;
	OUTPUT OUT = TEMP.PHOITO_PERH_LAPSET(DROP = _TYPE_ _FREQ_) 
	SUM(LAPSI_KUUK_17 LAPSI_KUUK_7) = ;
	RUN;

	* Lasketaan eri-ik‰isten lasten lukum‰‰r‰t ;

	DATA STARTDAT.START_PHOITO_PERH_LAPSET;
	SET TEMP.PHOITO_PERH_LAPSET;
	LUKUM_17 = ROUND(LAPSI_KUUK_17 / 12, 1); 
	LUKUM_7  = ROUND(LAPSI_KUUK_7 / 12, 1);

	LABEL 
	LUKUM_17 = 'Alle 17-vuotiaita lasten lkm, DATA'
	LUKUM_7 = 'Alle 7-vuotiaita lasten lkm, DATA';	

	RUN;

	* Luodaan lapsen vanhempina olevista puolisoista tiedosto START_PHOITO_PERH_PUOLISOT ;

 	DATA STARTDAT.START_PHOITO_PERH_PUOLISOT (KEEP = hnro knro asko VEROT_TULOT_DATA KOTIHTULO_DATA ELATTUKI_DATA ELATAPU elasa);
	SET TEMP.PHOITO_PERHEET;
	WHERE asko = 1 OR asko = 2;

	VEROT_TULOT_DATA = MAX(SUM(svatva, svatvp) / 12, 0);
	ELATTUKI_DATA = lbeltuki / 12;
	KOTIHTULO_DATA = tkotihtu / 12;
	ELATAPU = elasa / 12;

	LABEL 
	VEROT_TULOT_DATA = 'Veronalaiset tulot (e/kk), DATA'
	ELATTUKI_DATA = 'Elatustuki (e/kk), DATA'
	KOTIHTULO_DATA = 'Kotihoidon tuki (e/kk), DATA'
	ELATAPU = 'Elatusapu (e/kk), DATA';

	RUN;
	
%END;
	
%MEND PHoito_Muutt_Poiminta;

%PHoito_Muutt_Poiminta;

%LET alkoi2&malli = %SYSFUNC(time());


/* 4. Makro hakee tietoja muista osamalleista ja liitt‰‰ ne mallin dataan */

%MACRO OsaMallit_PHoito;

/* 4.1 Veromalli */

%IF &SAIRVAK = 1 OR &TTURVA = 1 OR &KANSEL = 1 OR &OPINTUKI = 1 OR &KOTIHTUKI = 1 OR &VERO = 1 %THEN %DO;

	DATA STARTDAT.START_PHOITO_PERH_PUOLISOT;
	MERGE STARTDAT.START_PHOITO_PERH_PUOLISOT (IN = A) OUTPUT.&TULOSNIMI_VE (KEEP = hnro ANSIOT POTULOT);
	BY hnro;
	IF A;
	RUN;

%END;

/* 4.2 Kotihoidontuki */

%IF &KOTIHTUKI = 1 %THEN %DO;

	DATA STARTDAT.START_PHOITO_PERH_PUOLISOT;
	MERGE STARTDAT.START_PHOITO_PERH_PUOLISOT (IN = A) OUTPUT.&TULOSNIMI_KT (KEEP = hnro KOTIHTUKI OSHOIT);
	BY hnro;
	IF A;
	RUN;

%END;

/* 4.3 Elatustuki lapsilis‰-mallista */

%IF &LLISA = 1 %THEN %DO;

	DATA STARTDAT.START_PHOITO_PERH_PUOLISOT;
	MERGE STARTDAT.START_PHOITO_PERH_PUOLISOT (IN = A) OUTPUT.&TULOSNIMI_LL (KEEP = hnro ELATUSTUET_HH);
	BY hnro;
	IF A;
	RUN;

%END;

/* 4.4 Opintotuki opintuki -mallista */

%IF &OPINTUKI = 1 %THEN %DO;

	DATA STARTDAT.START_PHOITO_PERH_PUOLISOT;
	MERGE STARTDAT.START_PHOITO_PERH_PUOLISOT (IN = A) OUTPUT.&TULOSNIMI_OT (KEEP = hnro TUKIKESK TUKIKOR);
	BY hnro;
	IF A;
	RUN;

%END;


%MEND OsaMallit_PHoito;

%OsaMallit_PHoito;


/* 5. Simulointivaihe */

/* 5.1 Jos parametrit luetaan makromuuttujiksi ennen simulontia, ajetaan t‰m‰ makro, erillisajossa */

%MACRO KuukSimul;

%IF &F = S AND &TYYPPI = SIMULX %THEN %DO;

	%HaeParam_KotihTukiSIMUL(&LVUOSI, &LKUUK, &INF);

%END;

%MEND KuukSimul;

%KuukSimul;


/* 5.2 Varsinainen simulointivaihe */

%MACRO PHoito_Simuloi_Data;
	
DATA TEMP.PHOITO_PERH_PUOLISOT (KEEP = hnro knro asko TULOT_YHT);
SET STARTDAT.START_PHOITO_PERH_PUOLISOT;

%IF (&SAIRVAK = 1 OR &TTURVA = 1 OR &KANSEL = 1 OR &OPINTUKI = 1 OR &KOTIHTUKI = 1 OR &VERO = 1) %THEN %DO;
	VEROT_TULOT = SUM(ANSIOT, POTULOT) / 12;
%END;

%ELSE %DO;
	VEROT_TULOT = VEROT_TULOT_DATA;
%END;

%IF &OPINTUKI = 1 %THEN %DO;
	OPTUKI = SUM(TUKIKESK, TUKIKOR)/12;
%END;

%ELSE %DO;
	OPTUKI = tkopira/12;
%END;

%IF &KOTIHTUKI = 1 %THEN %DO;
	KOTIHTULO = SUM(KOTIHTUKI, OSHOIT) / 12;
%END;

%ELSE %DO;
	KOTIHTULO = KOTIHTULO_DATA;
%END;

%IF &LLISA = 1 %THEN %DO;
	ELATTUET = SUM(ELATUSTUET_HH / 12, ELATAPU);
%END;

%ELSE %DO;
	ELATTUET = SUM(ELATTUKI_DATA, ELATAPU);
%END;

*Tulok‰site: veronalaiset tulot + elatustuki ja elasapu - kotihoidon tuki;

TULOT_YHT = MAX(SUM(VEROT_TULOT, ELATTUET, -KOTIHTULO, -OPTUKI), 0);

LABEL 
OPTUKI = 'Opintotuki e/kk, DATA'
VEROT_TULOT = 'Veronalaiset tulot e/kk, DATA'
KOTIHTULO ='Kotihoidon tuki e/kk, DATA'
ELATTUET = 'Elatustuki ja elatusapu e/kk, DATA'
TULOT_YHT = 'Tulot yhteens‰ e/kk, DATA';

RUN;

PROC SUMMARY DATA = TEMP.PHOITO_PERH_PUOLISOT;
BY knro;
OUTPUT OUT = TEMP.PHOITO_PERH_PUOL_YHT (DROP = _TYPE_ _FREQ_)
SUM(asko)=SASKO SUM(TULOT_YHT) = TULOT_YHT;
RUN;

DATA OUTPUT.&TULOSNIMI_PH;
MERGE STARTDAT.START_PHOITO_LAPSET STARTDAT.START_PHOITO_PERH_LAPSET;
BY knro;
RUN;

DATA OUTPUT.&TULOSNIMI_PH;
MERGE OUTPUT.&TULOSNIMI_PH TEMP.PHOITO_PERH_PUOL_YHT;
BY knro;

IF SASKO = 3 THEN PUOLISO = 1;
ELSE PUOLISO = 0;

MUITA_LAPSIA = SUM(LUKUM_17, -LUKUM_7);

%PHoitoMaksuV&F(TULOSP, &LVUOSI, 1, PUOLISO, LUKUM_7, SISAR, MUITA_LAPSIA, TULOT_YHT);

PHMAKSU_KOK = hoiaikak * TULOSP;
PHMAKSU_OS = 0.6 * hoiaikao * TULOSP;

DROP koko TULOSP ;

LABEL 
PUOLISO = 'Onko puolisoa (0/1), DATA'
MUITA_LAPSIA = 'Perheen muiden alaik‰isten lasten lukum‰‰r‰, DATA';

RUN;

PROC SORT DATA = OUTPUT.&TULOSNIMI_PH;
BY hnro;
RUN;

/* 5.3 Yhdistet‰‰n simuloitu data palveluaineistoon (riippuen tulosaineiston laajuden valinnasta) */

DATA OUTPUT.&TULOSNIMI_PH;
	
/* 5.3.1 Suppea tulostiedosto (vain t‰rkeimm‰t luokittelumuuttujat) */

%IF &TULOSLAAJ = 1 %THEN %DO; 
	MERGE POHJADAT.&AINEISTO&AVUOSI 
	(IN = A KEEP = hnro knro &PAINO hoiaikak hoimaksk hoiaikao hoimakso ikavu ikavuV desmod soss paasoss elivtu koulas rake)
	OUTPUT.&TULOSNIMI_PH;
%END;

/* 5.3.2 Laaja tulostiedosto (palveluaineiston mukainen tulostiedosto) */

%IF &TULOSLAAJ = 2 %THEN %DO; 
	MERGE POHJADAT.&AINEISTO&AVUOSI (IN = A) OUTPUT.&TULOSNIMI_PH;
%END;

IF A;
BY hnro;

* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukum‰‰r‰t voidaan laskea suoraan ;

HMAKSU_KOKO = hoiaikak * hoimaksk;
HMAKSU_OSA = hoiaikao * hoimakso;

ARRAY PISTE 
HMAKSU_KOKO PHMAKSU_KOK HMAKSU_OSA PHMAKSU_OS;
DO OVER PISTE;
	IF PISTE <= 0 THEN PISTE = .;
END;

DROP hoiaikak hoimaksk hoiaikao hoimakso;

* Luodaan simuloiduille ja datan muuttujille selitteet ;

LABEL 

HMAKSU_KOKO = 'Hoitomaksu kokop‰iv‰hoidossa, DATA'
PHMAKSU_KOK = 'Hoitomaksu kokop‰iv‰hoidossa, MALLI'
HMAKSU_OSA  = 'Hoitomaksu osap‰iv‰hoidossa, DATA'
PHMAKSU_OS  = 'Hoitomaksu osap‰iv‰hoidossa, MALLI';
	
RUN;

%MEND PHoito_Simuloi_Data;

%PHoito_Simuloi_Data;

%LET loppui2&malli = %SYSFUNC(time());


/* 6. Luodaan summatason tulostaulukot (optio) */

%MACRO PHoito_Tulokset;

/* 6.1 Kotitaloustason tulokset (optio) */

/* 6.1.1 Mikrotason tulosaineiston summaus kotitaloustasolle (optio) */

%IF &YKSIKKO = 2 AND &START NE 1 %THEN %DO; 

	PROC SUMMARY DATA=OUTPUT.&TULOSNIMI_PH (DROP = hnro);
	BY knro ;
	ID &PAINO ikavuV desmod paasoss elivtu koulas rake;
	VAR &MUUTTUJAT _NUMERIC_;
	OUTPUT OUT = OUTPUT.&TULOSNIMI_PH (DROP = ikavu soss _TYPE_ _FREQ_)  SUM = ;
	RUN;

%END;

/* 6.1.2 Summatason tulostaulukko (optio) */

%IF &TULOKSET = 1 %THEN %DO;

	%IF &YKSIKKO = 2 %THEN %DO; 

		/* Siirret‰‰n tiedot Exceliin (optio) */

		%IF &EXCEL = 1 %THEN %DO;

			ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_PH._SUMMAT.xls" STYLE = MINIMAL;

		%END;

		PROC MEANS DATA=OUTPUT.&TULOSNIMI_PH &SUMWGT &SUM &MIN &MAX &RANGE &MEAN &MEDIAN &MODE &STD &VAR &CV NONOBS ORDER=DATA NWAY MAXDEC = 0; 
		TITLE "TUNNUSLUVUT (KOTITALOUSTASO), &MALLI";
		CLASS &LUOK_KOTI1 &LUOK_KOTI2 &LUOK_KOTI3 / MLF PRELOADFMT;
		VAR &MUUTTUJAT ;
		FORMAT _NUMERIC_ tuhat. ;
		%DO I = 1 %TO 3; 
		%IF %LENGTH (&&LUOK_KOTI&I) >0 %THEN %DO;
			FORMAT &&LUOK_KOTI&I &&LUOK_KOTI&I... ;
		%END;%END;
		OUTPUT OUT = OUTPUT.&TULOSNIMI_PH._SUMMAT (DROP = _TYPE_ _FREQ_)
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
	
	/* 6.2 Henkilˆtason tulokset (oletus) */

	%ELSE %DO;

		/* Siirret‰‰n tiedot Exceliin (optio) */

		%IF &EXCEL = 1 %THEN %DO;

			ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_PH._SUMMAT.xls" STYLE = MINIMAL;

		%END;

		PROC MEANS DATA=OUTPUT.&TULOSNIMI_PH &SUMWGT &SUM &MIN &MAX &RANGE &MEAN &MEDIAN &MODE &STD &VAR &CV NONOBS ORDER=DATA NWAY MAXDEC = 0;
		TITLE "TUNNUSLUVUT (HENKIL÷TASO), &MALLI";
		CLASS &LUOK_HLO1 &LUOK_HLO2 &LUOK_HLO3 / MLF PRELOADFMT;
		VAR &MUUTTUJAT ;
		FORMAT _NUMERIC_ tuhat. ;
		%DO I = 1 %TO 3; 
		%IF %LENGTH (&&LUOK_HLO&I) >0 %THEN %DO;
			FORMAT &&LUOK_HLO&I &&LUOK_HLO&I... ;
		%END;%END;
		OUTPUT OUT = OUTPUT.&TULOSNIMI_PH._SUMMAT (DROP = _TYPE_ _FREQ_)
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

%MEND PHoito_Tulokset;

%PHoito_Tulokset;


/* 7. Mitataan kuinka kauan osavaiheisiin kului aikaa */

%LET loppui1&malli = %SYSFUNC(TIME());

%LET kului1&malli = %SYSEVALF(&&loppui1&malli - &&alkoi1&malli);

%LET kului2&malli = %SYSEVALF(&&loppui2&malli - &&alkoi2&malli);

%LET kului1&malli = %SYSFUNC(PUTN(&&kului1&malli, time10.2));

%LET kului2&malli = %SYSFUNC(PUTN(&&kului2&malli, time10.2));


%PUT &malli. Koko laskenta. Aikaa kului (hh:mm:ss.00) &&kului1&malli;

%PUT &malli. Varsinainen simulointi. Aikaa kului (hh:mm:ss.00) &&kului2&malli;




