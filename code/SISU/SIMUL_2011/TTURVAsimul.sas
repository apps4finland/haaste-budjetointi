/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyˆdynt‰‰ Tilastokeskuksen yleisten
* k‰yttˆehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto p‰‰hakemistossa.
******************************************************************************/

/***********************************************************
* Kuvaus: Tyˆttˆmyysturvan simulointimalli 2011            *
* Tekij‰: Jussi Tervola / KELA		                	   *
* Luotu: 25.9.2012				       					   *
* Viimeksi p‰ivitetty: 17.4.2013		     		       *
* P‰ivitt‰j‰: Jussi Tervola / KELA		     			   *
************************************************************/ 

/* 0. Yleisi‰ vakioiden m‰‰rittelyj‰ (‰l‰ muuta n‰it‰!) */

%LET START = &OUT;

%LET MALLI = TTURVA;

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

	%LET AVUOSI = 2011;		* Aineistovuosi (vvvv);

	%LET LVUOSI = 2011;		* Lains‰‰d‰ntˆvuosi (vvvv);

	%LET TYYPPI = SIMUL;	* Parametrien hakutyyppi: SIMUL (vuosikeskiarvo) tai SIMULX (parametrit haetaan tietylle kuukaudelle);

	%LET LKUUK = 12;         * Lains‰‰d‰ntˆkuukausi, jos parametrit haetaan tietylle kuukaudelle;

	%LET AINEISTO = PALV ;  * K‰ytett‰v‰ aineisto (PALV = Palveluaineisto, REK = Rekisteriaineisto) ;

	%LET TULOSNIMI_TT = tturva_simul_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;

	%LET TTDATATULO = 0;  * K‰ytet‰‰nkˆ datan tulotietoja = 1 vai laskennallisia tulotietoja = 0 ;

	* Inflaatiokorjaus. Parametrien deflatoinnissa k‰ytett‰v‰n kertoimen voi syˆtt‰‰ itse
	  INF-makromuuttujaan (HUOM! desimaalit erotettava pisteell‰ .). Jos puolestaan haluaa k‰ytt‰‰ automaattista 
	  elinkustannusindeksiin perustuvaa parametrien muunnoskerrointa, 
	  tulee INF-makromuuttujalle antaa arvoksi 999 ; 	

	%LET INF = 1.00; * Syˆt‰ arvo tai 999 ;	
	%LET PINDEKSI_VUOSI = pindeksi_vuosi; *K‰ytett‰v‰ indeksien parametritaulukko;		

	* Ajettavat osavaiheet ; 

	%LET LAKIMAKROT = 1;    * Lakimakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
	%LET LAKIMAK_TIED_TT = TTURVAlakimakrot;	* Lakimakroissa k‰ytett‰v‰n tiedoston nimi ;
	%LET APUMAKROT = 1;   	* Apumakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
	%LET APUMAK_TIED_TT = TTURVAapumakrot; * Apumakroissa k‰ytett‰v‰n tiedoston nimi ;
	%LET POIMINTA = 1;  	* Muuttujien poiminta (1 jos ajetaan, 0 jos ei);
	%LET TULOKSET = 1;		* Yhteenvetotaulukot (1 jos ajetaan, 0 jos ei);

	%LET PTTURVA = ptturva; * K‰ytett‰v‰n parametritiedoston nimi ;

	* Tulostaulukoiden esivalinnat ; 

	%LET TULOSLAAJ = 1 ; 	 * Mikrotason tulosaineiston laajuus (1 = suppea, 2 = laaja (palveluaineisto)) ;
	%LET MUUTTUJAT = TMTUKIDAT YHTTMTUKI KTTUKIDAT KOTOUTUKI YPITOKDAT YPITOK ptmk KOULPTUKI PERPRDAT PERUSPR vvvmk1 ANSIOPR 
			         vvvmk3 VUORKORV VVVMKX5 AKTIIVAPR ; * Taulukoitavat muuttujat (summataulukot) ;
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

	%LET LUOK_KOTI1 = ; * Taulukoinnin 1. kotitalousluokitus (jos YKSIKKO = 2) 
							    Vaihtoehtoina: 
							     desmod (tulodesiilit, ekvivalentit tulot (modoecd), hlˆpainot)
							     ikavuV (viitehenkilˆn mukaiset ik‰ryhm‰t)
							     elivtu (kotitalouden elinvaihe)
							     koulas (viitehenkilˆn koulutusaste TK1997)
							     paasoss (kotitalouden sosioekonominen asema AML2001)
							     rake (kotitalouden rakenne) ;
	%LET LUOK_KOTI2 = ; 	  * Taulukoinnin 2. kotitalousluokitus ;
	%LET LUOK_KOTI3 = ; 	  * Taulukoinnin 3. kotitalousluokitus ;

	%LET EXCEL = 0; 		  * Vied‰‰nkˆ tulostaulukko automaattisesti Exceliin (1 = Kyll‰, 0 = Ei) ;

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
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_TT..sas";
%END;

/* Ajetaan apumakrot ja tallennetaan ne (optio) */

%IF &APUMAKROT = 1 %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&APUMAK_TIED_TT..sas";
%END;

%MEND TeeMakrot;

%TeeMakrot;


/* 3. Datan poiminta ja apumuuttujien luominen (optio) */

%MACRO TTurva_Muut_Poiminta;

%IF &POIMINTA = 1 %THEN %DO;

	%LOCAL TYYPPI;
	%LET TYYPPI = SIMUL;

	/* 3.1 M‰‰ritell‰‰n tarvittavat palveluaineiston muuttujat taulukkoon START_TTURVA */

	%HaeParam_TTurvaSIMUL(&AVUOSI, 1, &INF);

	DATA STARTDAT.START_TTURVA;
	MERGE POHJADAT.&AINEISTO&AVUOSI (
	KEEP = hnro knro asko vvvmk1 vvvpvt1 vvvsomk1 vvvpal1 vvvsopv1 mkorpvt1 mtolpvt1 vvvllkm1
	vvvmk2 vvvpvt2 vvvsomk2 vvvpal2 vvvsopv2 mkorpvt2 mtolpvt2 vvvllkm2	vvvmk3 vvvpvt3 vvvsomk3 vvvpal3 vvvsopv3 
	vvvmk4 vvvpvt4 vvvsomk4 vvvpal4 vvvsopv4 mkorpvt4 mtolpvt4 vvvllkm4	vvvmk5 vvvpvt5 vvvsomk5 vvvsopv5 mkorpvt5 mtolpvt5 vvvllkm5 vvvpal5
	yhtez tmtukimk tmtukipv palkmz htyotper palkm ptpv ptmk ttyotpr dtvpv dtvyhte dttayspv dtospv dtovlkm dtopalkk dtpuopal
	dttspv dtomapal dtvpv dtthyhte dttsyhte dtosyhte dtpspv dtpspalk dtpsyhte dtyllae dtyllapv dttllkm dtthpv dttspalk 
	dtthpvz dtyhtep dttayspvz dtospvz dtvpvz dttspvz palkmz dtthyhtez dtosyhtez dttsyhtez dtvyhtez dtyllaez dtyllapvp dtyllapvz dtzllkm dtovlkmz
	dtpuopalz dtomapalz dttspalkz dtopalkkz koropvtkg koropvtkf koropvzkg koropvzkf mtlisa korosapks mtlisapv 
	korosapkw koropvpkw koropvpks korosatkg korosatkf korosazkg korosazkf
	
	LAPSKORMAKS DTOMAPALX2 DTPUOPALX2 DTOPALKKX2 SOSETUVAH SOVPELK SOVOS
	SOVTARV SOVVAH SOVKOR SOVPALKKATM SOVPALKKAPR SOVKORPA SOVKORPM PRKORPVA
	TMKORPV PELKSOPV1 PELKSOPV5 PELKTAYSPV1 PELKTAYSPV3 PELKTAYSPV5
	SOVKORPV1 SOVKORPV5 SOVTOLPV1 SOVTOLPV5 TAYSTOLPV1 TAYSTOLPV5 TAYSKORPV1
	TAYSKORPV5 LASKPALKKA LASKPALKKA3 LASKPALKKA5 SOVPALKKA SOVPALKKA3 SOVPALKKA5
	SOVKORVAH KORVAH PELKVAH PELKKOR SOVPELKP PELKKORP TAYSPVP
	VUORKOR YPITOKORPV AILMKOR1DAT AILMKOR5DAT YPITOKDAT DTTAYSPVX
 
	WHERE = (vvvmk5 > 0 OR vvvmk4 > 0 OR ttyotpr > 0 OR ptmk > 0));

	ARRAY PISTE 
	tmtukimk dtyllae ptmk htyotper vvvmk1-vvvmk5 yhtez vvvsomk1 vvvsopv1;
	DO OVER PISTE;
		IF PISTE <= 0 THEN PISTE = .;
	END;

	VVVPALX1 = vvvpal1 / (1 - &VahPros);
	VVVPALX3 = vvvpal3 / (1 - &VahPros);
	VVVPALX5 = MAX(vvvpal2, vvvpal4, vvvpal5) / (1 - &VahPros);

	VVVMKX5 = SUM(vvvmk2, vvvmk4, vvvmk5);
	VVVPVTX5 = SUM(vvvpvt2, vvvpvt4, vvvpvt5);
	VVVSOPVX5 = SUM(vvvsopv2, vvvsopv4, vvvsopv5);
	MKORPVTX5 = SUM(mkorpvt2, mkorpvt4, mkorpvt5);
	MTOLPVTX5 = SUM(mtolpvt2, mtolpvt4, mtolpvt5);
	VVVLLKMX5 = MAX(vvvllkm2, vvvllkm4, vvvllkm5);

   /* Kotoutumistuen tyˆmarkkinatuki lasketaan samoin kun normaali tyˆmarkkinatuki, joten liitet‰‰n kotoutumistuen z-muuttujat yleisiin tmtuki-muuttujiin */

	DTTHPVX = SUM(dtthpv, dtthpvz);
	DTOSPVX = SUM(dtospv, dtospvz);
	DTVPVX = SUM(dtvpv, dtvpvz);
	DTTSPVX = SUM(dttspv, dttspvz);
	TMTUKIPVX = SUM(tmtukipv, palkmz);
	DTYLLAEX = SUM(dtyllae, dtyllaez);
	DTYLLAPVX = SUM(dtyllapv, dtyllapvz);

	DTTLLKMX = MAX(dttllkm, dtzllkm);
	DTOVLKMX = MAX(dtovlkm, dtovlkmz);
	DTPUOPALX = MAX(dtpuopal, dtpuopalz);
	DTOMAPALX = MAX(dtomapal, dtomapalz);
	DTTSPALKX = MAX(dttspalk, dttspalkz);
	DTOPALKKX = MAX(dtopalkk, dtopalkkz);

	TMKORPV = SUM(koropvtkg, koropvtkf, koropvzkg, koropvzkf);
	PRKORPVA = SUM(mtlisapv, koropvpkw);

	TMTUKIDAT = SUM(tmtukimk, korosatkg, korosatkf);
	PERPRDAT = SUM(dtyhtep, mtlisa, korosapks, korosapkw);
	KTTUKIDAT = SUM(yhtez, korosazkg, korosazkf);

	DROP vvvpal1-vvvpal5 vvvmk2 vvvmk4 vvvmk5 vvvpvt2 vvvpvt4 vvvpvt5 
	vvvsomk2 vvvsomk4 vvvsomk5 vvvsopv2 vvvsopv4 vvvsopv5 mkorpvt2 mkorpvt4 mkorpvt5 
	mtolpvt2 mtolpvt4 mtolpvt5 vvvllkm2 vvvllkm4 vvvllkm5 dtthpvz dttayspvz 
	dtospvz dtvpvz dttspvz dtthyhtez dtosyhtez dttsyhtez dtvyhtez dtyllaez dtyllapvz dtzllkm dtovlkmz
	dtpuopalz dtomapalz dttspalkz dtopalkkz dtthpv dttayspv dtospv dtvpv 
	dttspv dtthyhte dtosyhte dttsyhte dtvyhte dtyllae dtyllapv 
	dttllkm dtovlkm dtpuopal dtomapal dttspalk dtopalkk tmtukipv
	koropvtkg koropvtkf koropvzkg koropvzkf mtlisapv koropvpkw korosatkg 
	korosatkf korosazkg korosazkf htyotper mtlisapv koropvpkw
	;

	LABEL
	VVVPALX1 = 'Ansiop‰iv‰rahan perusteena oleva vakuutuspalkka, DATA'
	VVVPALX3 = 'Vuorottelukorvauksen perusteena oleva vakuutuspalkka, DATA'
	VVVPALX5 = 'Aktiiviajan ansiop‰iv‰rahan perusteena oleva vakuutuspalkka, DATA'
	VVVMKX5 = 'Aktiiviajan ansiop‰iv‰rahat, DATA'
	VVVLLKMX5 = 'Aktiiviajan ansiop‰iv‰rahan lapsikorotukset, DATA'
	VVVSOPVX5 = 'Aktiiviajan ansiop‰iv‰rahan soviteltujen p‰ivien lukum‰‰r‰'
	MKORPVTX5 = 'Aktiiviajan ansiop‰iv‰rahan korotettujen p‰ivien lukum‰‰r‰'
	MTOLPVTX5 = 'Aktiiviajan ansiop‰iv‰rahan muutosturvalis‰p‰ivien lukum‰‰r‰'
	VVVPVTX5 = 'Aktiiviajan ansiop‰iv‰rahan p‰ivien lkm, DATA'
	DTTHPVX = 'Tyˆmarkkinatuen tarveharkittujen p‰ivien lkm, sis. KT, DATA'
	DTTAYSPVX = 'Tyˆmarkkinatuen t‰ysien p‰ivien lkm, sis. KT, DATA'
	DTOSPVX = 'Tyˆmarkkinatuen ositettujen p‰ivien lkm, sis. KT, DATA'
	DTTSPVX = 'Tyˆmarkkinatuen soviteltujen p‰ivien lkm, sis. KT, DATA'
	DTVPVX = 'Tyˆmarkkinatuen muulla sosiaalietuudella v‰hennettyjen p‰ivien lkm, sis. KT, DATA'
	TMTUKIPVX = 'Tyˆmarkkinatuen p‰ivien lkm, sis. KT, DATA'
	DTYLLAEX = 'Tyˆmarkkinatuen kulukorvaukset, sis. KT, DATA'
	DTYLLAPVX = 'Tyˆmarkkinatuen kulukorvausp‰iv‰t, sis. KT, DATA'
	DTTLLKMX = 'Tyˆmarkkinatuen lapsikorotukset, sis. KT, DATA'
	DTOVLKMX = 'Ositetun tyˆmarkkinatuen huollettavien lkm, sis. KT, DATA'
	DTPUOPALX = 'Puolison tulot tarveharkitussa tm-tuessa, sis. KT, DATA'
	DTOMAPALX = 'Omat (p‰‰oma)tulot tarveharkitussa tm-tuessa, sis. KT, DATA'
	DTTSPALKX = 'Omat tyˆtulot sovitellussa tm-tuessa, sis. KT, DATA'
	DTOPALKKX = 'Vanhehmpien tyˆtulot ositetussa tm-tuessa, sis. KT, DATA'
	TMTUKIDAT = 'Tyˆmarkkinatuki, DATA'
	KTTUKIDAT = 'Kotoutumistuen tyˆmarkkinatuki, DATA'
	PERPRDAT = 'Perusp‰iv‰raha, DATA'
	;

RUN;

%END;

%MEND TTurva_Muut_Poiminta;

%TTurva_Muut_Poiminta;


/* 4. Simulointivaihe */

%LET alkoi2&malli = %SYSFUNC(TIME());

/* 4.1 Jos parametrit luetaan makromuuttujiksi ennen simulontia, ajetaan t‰m‰ makro, erillisajossa */

%MACRO KuukSimul;

%IF &F = S AND &TYYPPI = SIMULX %THEN %DO;

	%HaeParam_TTurvaSIMUL(&LVUOSI, &LKUUK, &INF);

%END;

%MEND KuukSimul;

%KuukSimul;

/* 4.2 Varsinainen simulointivaihe */

%MACRO TTurva_Simuloi_Data;

DATA OUTPUT.&TULOSNIMI_TT;
SET STARTDAT.START_TTURVA;

* Tarveharkitut tyˆmarkkinatuet ;

IF DTTHPVX > 0 THEN DO;

	IF &TTDATATULO NE 0 THEN DO;
		%TyomTukiV&F(THTMTUKI, &LVUOSI, &INF, 1, 0, DTPUOPALX, DTTLLKMX, 0, DTOMAPALX, DTPUOPALX, 0, 0, 0);
		IF SOVTARV > 0 THEN DO; %SoviteltuK&F(SOVTARVTUKI, &LVUOSI, 1, &INF, 0, 0, DTTLLKMX, THTMTUKI, DTTSPALKX, 0, 0); END;
	END;

	ELSE DO;
		%TyomTukiV&F(THTMTUKI, &LVUOSI, &INF, 1, 0, DTPUOPALX, DTTLLKMX, 0, DTOMAPALX2, DTPUOPALX2, 0, 0, 0);
		IF SOVTARV > 0 THEN DO; %SoviteltuK&F(SOVTARVTUKI, &LVUOSI, 1, &INF, 0, 0, DTTLLKMX, THTMTUKI, SOVPALKKATM, 0, 0); END;
	END;

	THTMTUKI = SUM(SUM(DTTHPVX, -SOVTARV) * THTMTUKI, SOVTARV * SOVTARVTUKI) / &TTPaivia;
	DROP SOVTARVTUKI;
END;

* Osittaiset tyˆmarkkinatuet ;
IF DTOSPVX > 0 THEN DO;

	IF &TTDATATULO NE 0 THEN DO;
		%TyomTukiV&F(OSTMTUKI, &LVUOSI, &INF, 0, 1, 0, DTTLLKMX, DTOVLKMX, 0, 0, DTOPALKKX, 0, 0);
		IF SOVOS > 0 THEN DO; %SoviteltuK&F(SOVOSTUKI, &LVUOSI, 1, &INF, 0, 0, DTTLLKMX, OSTMTUKI, DTTSPALKX, 0, 0); END;
	END;

	ELSE DO;
		%TyomTukiV&F(OSTMTUKI, &LVUOSI, &INF, 0, 1, 0, DTTLLKMX, DTOVLKMX, 0, 0, DTOPALKKX2, 0, 0);
		IF SOVOS > 0 THEN DO; %SoviteltuK&F(SOVOSTUKI, &LVUOSI, 1, &INF, 0, 0, DTTLLKMX, OSTMTUKI, SOVPALKKATM, 0, 0); END;
	END;

	OSTMTUKI = SUM(SUM(DTOSPVX, -SOVOS) * OSTMTUKI, SOVOS * SOVOSTUKI) / &TTPaivia;
	DROP SOVOSTUKI;
END;

* Korotetut tyˆmarkkinatuet;
IF TMKORPV > 0 THEN DO;
	IF PELKKOR > 0 OR SOVKOR > 0 THEN DO;
		%TyomTukiV&F(KRTMTUKI, &LVUOSI, &INF, 0, 0, 0, DTTLLKMX, 0, 0, 0, 0, 1, 0);
	END;
	IF KORVAH > 0 OR SOVKORVAH > 0 THEN DO;
		%TyomTukiV&F(KRSTMTUKI, &LVUOSI, &INF, 0, 0, 0, DTTLLKMX, 0, 0, 0, 0, 1, SOSETUVAH);
		IF KRSTMTUKI > &KorotusOsa * &TTPaivia THEN KRSTILMKOR = KRSTMTUKI - &KorotusOsa * &TTPaivia;
	END;
	IF SOVKOR > 0 OR SOVKORVAH > 0 THEN DO; 
		IF &TTDATATULO NE 0 OR SOVKORVAH > 0 THEN DO;
			IF SOVKORVAH > 0 THEN DO;
				%SoviteltuK&F(SOVKORVTUKI, &LVUOSI, 1, &INF, 0, 0, DTTLLKMX, KRSTMTUKI, DTTSPALKX, 0, 0); 
				IF SOVKORVTUKI > &KorotusOsa * &TTPaivia THEN SOVKVILMKOR = SOVKORVTUKI - &KorotusOsa * &TTPaivia;
			END;
			ELSE DO;
				%SoviteltuK&F(SOVKORTUKI, &LVUOSI, 1, &INF, 0, 0, DTTLLKMX, KRTMTUKI, DTTSPALKX, 0, 0);
			END;
		END;
		ELSE DO;
			%SoviteltuK&F(SOVKORTUKI, &LVUOSI, 1, &INF, 0, 0, DTTLLKMX, KRTMTUKI, SOVPALKKATM, 0, 0); 
		END;
		IF SOVKORTUKI > &KorotusOsa * &TTPaivia THEN SOVKILMKOR = SOVKORTUKI - &KorotusOsa * &TTPaivia;
	END;

	KORTMTUKI = SUM(PELKKOR * KRTMTUKI, SOVKOR * SOVKORTUKI, KORVAH * KRSTMTUKI, SOVKORVAH * SOVKORVTUKI) / &TTPaivia;
	TMILMKOR = SUM(PELKKOR * SUM(KRTMTUKI, -&KorotusOsa * &TTPaivia), KORVAH * KRSTILMKOR, SOVKORVAH * SOVKVILMKOR, SOVKOR * SOVKILMKOR) / &TTPaivia;
	DROP KRTMTUKI SOVKORVTUKI SOVKORTUKI SOVKILMKOR SOVKVILMKOR KRSTILMKOR;
END;

* Sovitellut t‰ydet tmtuet ;
IF SOVPELK > 0 THEN DO;

	IF &TTDATATULO NE 0 THEN DO;
		%TyomTukiV&F(TAYSPRAHA, &LVUOSI, &INF, 0, 0, 0, DTTLLKMX, 0, 0, 0, 0, 0, 0);
		%SoviteltuK&F(SOVTMTUKI, &LVUOSI, 1, &INF, 0, 0, DTTLLKMX, TAYSPRAHA, DTTSPALKX, 0, 0);
	END;

	ELSE DO;
		%TyomTukiV&F(TAYSPRAHA, &LVUOSI, &INF, 0, 0, 0, DTTLLKMX, 0, 0, 0, 0, 0, 0);
		%SoviteltuK&F(SOVTMTUKI, &LVUOSI, 1, &INF, 0, 0, DTTLLKMX, TAYSPRAHA, SOVPALKKATM, 0, 0);
	END;

	SOVTMTUKI = SOVPELK * SOVTMTUKI / &TTPaivia;
	DROP TAYSPRAHA;
	
END;

* T‰ydet tmtuet ;
IF DTTAYSPVX > 0 THEN DO;
	%TyomTukiV&F(TAYSTMTUKI, &LVUOSI, &INF, 0, 0, 0, DTTLLKMX, 0, 0, 0, 0, 0, 0);
	TAYSTMTUKI = DTTAYSPVX * TAYSTMTUKI / &TTPaivia;
END;


* Tuet joista on v‰hennetty muuta sosiaalietuutta ;
IF PELKVAH > 0 OR SOVVAH > 0 THEN DO; 
	%TyomTukiV&F(VAHTMTUKI, &LVUOSI, &INF, 0, 0, 0, DTTLLKMX, 0, 0, 0, 0, 0, SOSETUVAH); 

	IF SOVVAH > 0 THEN DO;
		%SoviteltuK&F(SVAHTMTUKI, &LVUOSI, 1, &INF, 0, 0, DTTLLKMX, VAHTMTUKI, DTTSPALKX, 0, 0);
	END;

	VAHTMTUKI = SUM(VAHTMTUKI * PELKVAH, SVAHTMTUKI * SOVVAH) / &TTPaivia;
	DROP SVAHTMTUKI;
END;

* Kotoutumistuen simulointi. Kotoutumistuessa ei ole tarveharkintatietoja, joten k‰ytet‰‰n laskennallisia tietoja;

* Yll‰pitokorvaukset (sis. kotoutumistuen yll‰pitokorvaukset) ;

IF DTYLLAPVX > 0 OR dtyllapvp > 0 THEN DO;
	IF YPITOKORPV > 0 THEN DO;
		%YPitoKorvS(YPITOKOR, &LVUOSI, 1, &INF, 1);
	END;
	IF SUM(DTYLLAPVX, dtyllapvp) > YPITOKORPV THEN DO;
		%YPitoKorvS(YPITOK, &LVUOSI, 1, &INF, 0);
	END;
	YPITOK = SUM(YPITOK * SUM(DTYLLAPVX, dtyllapvp, -YPITOKORPV), YPITOKOR * YPITOKORPV) / &TTPaivia;
END;

YHTTMTUKI = SUM(THTMTUKI, OSTMTUKI, SOVTMTUKI, TAYSTMTUKI, VAHTMTUKI, KORTMTUKI);
TMTUKILMKOR = SUM(THTMTUKI, OSTMTUKI, SOVTMTUKI, TAYSTMTUKI, VAHTMTUKI, TMILMKOR);

IF palkmz > 0 THEN DO;
	KOTOUTUKI = palkmz / TMTUKIPVX * YHTTMTUKI;
	KTTUKILMKOR = palkmz / TMTUKIPVX * TMTUKILMKOR;
	YHTTMTUKI = SUM(YHTTMTUKI, -KOTOUTUKI);
	TMTUKILMKOR = SUM(TMTUKILMKOR, -KTTUKILMKOR);
END;


* Koulutustuen perustuki ;

IF ptpv > 0 THEN DO;
	%PerusPRahaV&F(KOULPTUKI, &LVUOSI, &INF, 0, 0, 0, LAPSKORMAKS, 0, 0, 0);
	KOULPTUKI = ptpv * KOULPTUKI / &TTPaivia;
END;

 * Perusp‰iv‰raha;

IF palkm > 0 THEN DO;
	%PerusPRahaV&F(PERUSPR, &LVUOSI, &INF, 0, 0, 0, LAPSKORMAKS, 0, 0, 0);
	IF PRKORPVA > 0 OR koropvpks > 0 THEN DO;
		%PerusPRahaV&F(PERKORPR, &LVUOSI, &INF, 0, 1, 0, LAPSKORMAKS, 0, 0, 0);
	END;

	IF dtpspv > 0 THEN DO;
		IF &TTDATATULO NE 0 THEN DO; 
			IF SOVPELKP > 0 THEN DO; %SoviteltuK&F(SOVPERUSPR, &LVUOSI, 1, &INF, 0, 0, LAPSKORMAKS, PERUSPR, dtpspalk, 0, 0); END;
			IF SOVKORPM >0 OR SOVKORPA > 0 THEN DO; %SoviteltuK&F(SOVKPERUSPR, &LVUOSI, 1, &INF, 0, 0, LAPSKORMAKS, PERKORPR, dtpspalk, 0, 0); END;
		END;

		ELSE DO;
			IF SOVPELKP > 0 THEN DO; %SoviteltuK&F(SOVPERUSPR, &LVUOSI, 1, &INF, 0, 0, LAPSKORMAKS, PERUSPR, SOVPALKKAPR, 0, 0); END;
			IF SOVKORPM >0 OR SOVKORPA > 0 THEN DO; %SoviteltuK&F(SOVKPERUSPR, &LVUOSI, 1, &INF, 0, 0, LAPSKORMAKS, PERKORPR, SOVPALKKAPR, 0, 0); END;
		END;
		IF 0 < SOVKPERUSPR < &KorotusOsa * &TTPaivia AND SOVKORPA > 0 THEN PERILMAKOR = SOVKPERUSPR; 
		ELSE IF SOVKORPA > 0 THEN PERILMAKOR = SOVKPERUSPR - &KorotusOsa * &TTPaivia;
	END;
	PERUSPR = SUM(TAYSPVP * PERUSPR, PELKKORP * PERKORPR, SOVPELKP * SOVPERUSPR, SUM(SOVKORPM, SOVKORPA) * SOVKPERUSPR) / &TTPaivia;
	PERILMAKOR = SUM(PERUSPR, -SUM(PRKORPVA, -SOVKORPA) * &KorotusOsa, (-PERILMAKOR / &TTPaivia) * SOVKORPA);

END;

* Ansiosidonnainen p‰iv‰raha ;

IF vvvpvt1 > 0 THEN DO;
	IF &TTDATATULO = 0 THEN PALKKA = LASKPALKKA; 
	ELSE PALKKA = VVVPALX1;

	%AnsioSidV&F(TAYSANSPR, &LVUOSI, &INF, vvvllkm1, 0, 0, 0, PALKKA, 0);
	IF vvvsopv1 > 0 THEN DO;
		%SoviteltuK&F(SOVANSPR, &LVUOSI, 1, &INF, 1, 0, vvvllkm1, TAYSANSPR, SOVPALKKA, PALKKA, 0);
	END;

	 * Lasketaan ei-korotetut p‰iv‰rahat;
	IF  PELKTAYSPV1 > 0 THEN TAYSAPR = PELKTAYSPV1 * TAYSANSPR / &TTPaivia;
		
	IF PELKSOPV1 > 0 THEN SOVAPR = PELKSOPV1 * SOVANSPR / &TTPaivia;
	
	* Lasketaan korotetut p‰iv‰rahat ;
	IF mkorpvt1 > 0 THEN DO;
		%AnsioSidV&F(TAYSKORPR, &LVUOSI, &INF, vvvllkm1, 1, 0, 0, PALKKA, 0);

		IF SOVKORPV1 > 0 THEN DO;
			%SoviteltuK&F(SOVKORPR, &LVUOSI, 1, &INF, 1, 1, vvvllkm1, TAYSKORPR, SOVPALKKA, PALKKA, 0);
			SOVKORPR = SOVKORPV1 * SOVKORPR / &TTPaivia;
		END;

		TAYSKORPR = TAYSKORPV1 * TAYSKORPR / &TTPaivia;
	END;

	 * Lasketaan tyˆllistymisohjelmatuen p‰iv‰rahat ;
	IF mtolpvt1 > 0 THEN DO;
		%AnsioSidV&F(TAYSTOLPR, &LVUOSI, &INF, vvvllkm1, 0, 1, 0, PALKKA, 0);

		IF SOVTOLPV1 > 0 THEN DO;
			%SoviteltuK&F(SOVTOLPR, &LVUOSI, 1, &INF, 1, 0, vvvllkm1, TAYSTOLPR, SOVPALKKA, PALKKA, 0);
			SOVTOLPR = SOVTOLPV1 * SOVTOLPR / &TTPaivia;
		END;

		TAYSTOLPR = TAYSTOLPV1 * TAYSTOLPR / &TTPaivia;
	END;

	ANSIOPR = SUM(TAYSAPR, SOVAPR, SOVKORPR, TAYSKORPR, SOVTOLPR, TAYSTOLPR);
	ANSIOILMKOR = SUM(TAYSAPR, SOVAPR, SOVKORPR, SOVTOLPV1 * SOVANSPR / &TTPaivia, TAYSKORPR, TAYSTOLPV1 * TAYSANSPR / &TTPaivia);

	DROP TAYSAPR SOVAPR SOVKORPR TAYSKORPR SOVTOLPR TAYSTOLPR SOVANSPR TAYSANSPR;
END;

* Vuorottelukorvaukset. 
  Datassa ei ole perusp‰iv‰rahasta maksettuja vuorottelukorvauksia, 
  jotka haetaan KELA:sta (niit‰ on eritt‰in v‰h‰n). ;

IF vvvpvt3 > 0 THEN DO;
	IF &TTDATATULO = 0 THEN PALKKA3 = LASKPALKKA3; 
	ELSE PALKKA3 = VVVPALX3;

	%VuorVapKorvK&F(VKORV, &LVUOSI, 1, &INF, 0, VUORKOR, PALKKA3);
	IF vvvsopv3 > 0 THEN DO; 
		%SoviteltuK&F(SOVVKORV, &LVUOSI, 1, &INF, 1, 0, 0, VKORV, SOVPALKKA3, PALKKA3, 0);
	END;
	VUORKORV = SUM(PELKTAYSPV3 * VKORV, vvvsopv3 * SOVVKORV) / &TTPaivia;
	DROP SOVVKORV VKORV VUORKOR;
END;


* Aktiiviajan ansiop‰iv‰raha;

IF VVVPVTX5 > 0 THEN DO;
	IF &TTDATATULO = 0 THEN PALKKA5 = LASKPALKKA5; 
	ELSE PALKKA5 = VVVPALX5;

	%AnsioSidV&F(TAYSANSPR5, &LVUOSI, &INF, VVVLLKMX5, 0, 0, 0, PALKKA5, 0);
	IF VVVSOPVX5 > 0 THEN DO;
		%SoviteltuK&F(SOVANSPR5, &LVUOSI, 1, &INF, 1, 0, VVVLLKMX5, TAYSANSPR5, SOVPALKKA5, PALKKA5, 1);
	END;

	 * Lasketaan ei-korotetut p‰iv‰rahat;
	IF  PELKTAYSPV5 > 0 THEN TAYSAPR5 = PELKTAYSPV5 * TAYSANSPR5 / &TTPaivia;
		
	IF PELKSOPV5 > 0 THEN SOVAPR5 = PELKSOPV5 * SOVANSPR5 / &TTPaivia;

	* Lasketaan korotetut p‰iv‰rahat ;
	IF MKORPVTX5 > 0 THEN DO;
		%AnsioSidV&F(TAYSKORPR5, &LVUOSI, &INF, VVVLLKMX5, 1, 0, 0, PALKKA5, 0);

		IF SOVKORPV5 > 0 THEN DO;
			%SoviteltuK&F(SOVKORPR5, &LVUOSI, 1, &INF, 1, 1, VVVLLKMX5, TAYSKORPR5,  SOVPALKKA5, PALKKA5, 1);

			SOVKORPR5 = SOVKORPV5 * SOVKORPR5 / &TTPaivia;
		END;

		TAYSKORPR5 = TAYSKORPV5 * TAYSKORPR5 / &TTPaivia;
	END;

 	* Lasketaan tyˆllistymisohjelmatuen p‰iv‰rahat ;
	IF MTOLPVTX5 > 0 THEN DO;
		%AnsioSidV&F(TAYSTOLPR5, &LVUOSI, &INF, VVVLLKMX5, 0, 1, 0, PALKKA5, 0);

		IF SOVTOLPV5 > 0 THEN DO;
			%SoviteltuK&F(SOVTOLPR5, &LVUOSI, 1, &INF, 1, 1, VVVLLKMX5, TAYSTOLPR5, SOVPALKKA5, PALKKA5, 1);
			SOVTOLPR5 = SOVTOLPV5 * SOVTOLPR5 / &TTPaivia;
		END;

		TAYSTOLPR5 = TAYSTOLPV5 * TAYSTOLPR5 / &TTPaivia;
	END;

	AKTIIVAPR = SUM(TAYSAPR5, SOVAPR5, SOVKORPR5, TAYSKORPR5, SOVTOLPR5, TAYSTOLPR5);
	AKTIILMKOR = SUM(TAYSAPR5, SOVAPR5, SUM(SOVKORPV5, SOVTOLPV5) * SOVANSPR5 / &TTPaivia, SUM(TAYSKORPV5, TAYSTOLPV5) * TAYSANSPR5 / &TTPaivia);
	DROP SOVAPR5 TAYSAPR5 SOVKORPR5 TAYSKORPR5 SOVTOLPR5 TAYSTOLPR5 SOVANSPR5 TAYSANSPR5;
END;


KEEP hnro knro TMTUKIDAT tmtukimk YHTTMTUKI TMTUKILMKOR KTTUKIDAT KTTUKILMKOR yhtez KOTOUTUKI YPITOKDAT YPITOK 
ptmk KOULPTUKI PERPRDAT dtyhtep PERUSPR PERILMAKOR AILMKOR1DAT vvvmk1 ANSIOPR ANSIOILMKOR vvvmk3 VUORKORV AILMKOR5DAT VVVMKX5 AKTIIVAPR AKTIILMKOR;

RUN;

/* 4.3 Yhdistet‰‰n simuloitu data palveluaineistoon (riippuen tulosaineiston laajuden valinnasta) */

DATA OUTPUT.&TULOSNIMI_TT;
	
/* 4.3.1 Suppea tulostiedosto (vain t‰rkeimm‰t luokittelumuuttujat) */

%IF &TULOSLAAJ = 1 %THEN %DO; 
	MERGE POHJADAT.&AINEISTO&AVUOSI 
	(KEEP = hnro knro ykor ikavu ikavuV desmod soss paasoss elivtu koulas rake)
	OUTPUT.&TULOSNIMI_TT;
%END;

/* 4.3.2 Laaja tulostiedosto (palveluaineiston mukainen tulostiedosto) */

%IF &TULOSLAAJ = 2 %THEN %DO; 
	MERGE POHJADAT.&AINEISTO&AVUOSI OUTPUT.&TULOSNIMI_TT;
%END;

BY hnro;

* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukum‰‰r‰t voidaan laskea suoraan ;

ARRAY PISTE 
ptmk--AKTIILMKOR;
DO OVER PISTE;
	IF PISTE <= 0 THEN PISTE = .;
END;

* Luodaan simuloiduille ja datan muuttujille selitteet ;

LABEL 
tmtukimk = 'Tyˆmarkkinatuki ilman korotusosia, DATA'
YHTTMTUKI = 'Tyˆmarkkinatuki, MALLI'
TMTUKILMKOR = 'Tyˆmarkkinatuki ilman korotusosia, MALLI'
yhtez = 'Kotoutumistuen tyˆmarkkinatuki ilman korotusosia, DATA'
KOTOUTUKI = 'Kotoutumistuen tyˆmarkkinatuki, MALLI'
KTTUKILMKOR = 'Kotoutumistuen tyˆmarkkinatuki ilman korotusosia, MALLI'
YPITOK = 'Yll‰pitokorvaukset, MALLI'
ptmk = 'Koulutustuen perustuki, DATA'
KOULPTUKI = 'Koulutustuen perustuki, MALLI'
dtyhtep = 'Perusp‰iv‰raha ilman korotusosia, DATA'
PERILMAKOR = 'Perusp‰iv‰raha ilman korotusosia, MALLI'
PERUSPR = 'Perusp‰iv‰raha, MALLI'
vvvmk1 = 'Ansiop‰iv‰raha, DATA'
AILMKOR1DAT = 'Ansiop‰iv‰raha ilman muutosturvalis‰‰, DATA'
ANSIOPR = 'Ansiop‰iv‰raha, MALLI'
ANSIOILMKOR = 'Ansiop‰iv‰raha ilman muutosturvalis‰‰, MALLI'
vvvmk3 = 'Vuorottelukorvaukset, DATA'
VUORKORV = 'Vuorottelukorvaukset, MALLI'
VVVMKX5 = 'Aktiiviajan ansiop‰iv‰raha, DATA'
AILMKOR5DAT = 'Aktiivajan ansiop‰iv‰raha ilman korotusosia, DATA'
AKTIIVAPR = 'Aktiiviajan ansiop‰iv‰raha, MALLI'
AKTIILMKOR = 'Aktiivajan ansiop‰iv‰raha ilman korotusosia, MALLI'

;	

RUN;

%MEND TTurva_Simuloi_Data;

%TTurva_Simuloi_Data;

%LET loppui2&malli = %SYSFUNC(TIME());


/* 5. Luodaan summatason tulostaulukot (optio) */

%MACRO TTurva_Tulokset;

/* 5.1 Kotitaloustason tulokset (optio) */

/* 5.1.1 Mikrotason tulosaineiston summaus kotitaloustasolle (optio) */

%IF &YKSIKKO = 2 AND &START NE 1 %THEN %DO; 

	PROC SUMMARY DATA=OUTPUT.&TULOSNIMI_TT (DROP = hnro);
	BY knro ;
	ID &PAINO ikavuV desmod paasoss elivtu koulas rake;
	VAR &MUUTTUJAT _NUMERIC_;
	OUTPUT OUT = OUTPUT.&TULOSNIMI_TT (DROP = soss ikavu _TYPE_ _FREQ_)  SUM = ;
	RUN;	

%END;

/* 5.1.2 Summatason tulostaulukko (optio) */

%IF &TULOKSET = 1 %THEN %DO;

	%IF &YKSIKKO = 2 %THEN %DO; 

		/* Siirret‰‰n tiedot Exceliin (optio) */

		%IF &EXCEL = 1 %THEN %DO;

			ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_TT._SUMMAT.xls" STYLE = MINIMAL;

		%END;

		PROC MEANS DATA=OUTPUT.&TULOSNIMI_TT &SUMWGT &SUM &MIN &MAX &RANGE &MEAN &MEDIAN &MODE &STD &VAR &CV NONOBS ORDER=DATA NWAY MAXDEC = 0; 
		TITLE "TUNNUSLUVUT (KOTITALOUSTASO), &MALLI";
		CLASS &LUOK_KOTI1 &LUOK_KOTI2 &LUOK_KOTI3 / MLF PRELOADFMT;
		VAR &MUUTTUJAT ;
		FORMAT _NUMERIC_ tuhat. ;
		%DO I = 1 %TO 3; 
		%IF %LENGTH (&&LUOK_KOTI&I) >0 %THEN %DO;
			FORMAT &&LUOK_KOTI&I &&LUOK_KOTI&I... ;
		%END;%END;
		OUTPUT OUT = OUTPUT.&TULOSNIMI_TT._SUMMAT (DROP = _TYPE_ _FREQ_)
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

			ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_TT._SUMMAT.xls" STYLE = MINIMAL;

		%END;

		PROC MEANS DATA=OUTPUT.&TULOSNIMI_TT &SUMWGT &SUM &MIN &MAX &RANGE &MEAN &MEDIAN &MODE &STD &VAR &CV NONOBS ORDER=DATA NWAY MAXDEC = 0;
		TITLE "TUNNUSLUVUT (HENKIL÷TASO), &MALLI";
		CLASS &LUOK_HLO1 &LUOK_HLO2 &LUOK_HLO3 / MLF PRELOADFMT;
		VAR &MUUTTUJAT ;
		FORMAT _NUMERIC_ tuhat. ;
		%DO I = 1 %TO 3; 
		%IF %LENGTH (&&LUOK_HLO&I) >0 %THEN %DO;
			FORMAT &&LUOK_HLO&I &&LUOK_HLO&I... ;
		%END;%END;
		OUTPUT OUT = OUTPUT.&TULOSNIMI_TT._SUMMAT (DROP = _TYPE_ _FREQ_)
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

%MEND TTurva_Tulokset;

%TTurva_Tulokset;


/* 6. Mitataan kuinka kauan osavaiheisiin kului aikaa */

%LET loppui1 = %SYSFUNC(TIME());

%LET loppui1&malli = %SYSFUNC(TIME());

%LET kului1&malli = %SYSEVALF(&&loppui1&malli - &&alkoi1&malli);

%LET kului2&malli = %SYSEVALF(&&loppui2&malli - &&alkoi2&malli);

%LET kului1&malli = %SYSFUNC(PUTN(&&kului1&malli, time10.2));

%LET kului2&malli = %SYSFUNC(PUTN(&&kului2&malli, time10.2));


%PUT &malli. Koko laskenta. Aikaa kului (hh:mm:ss.00) &&kului1&malli;

%PUT &malli. Varsinainen simulointi. Aikaa kului (hh:mm:ss.00) &&kului2&malli;
