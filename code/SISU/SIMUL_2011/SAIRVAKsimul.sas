/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hy�dynt�� Tilastokeskuksen yleisten
* k�ytt�ehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto p��hakemistossa.
******************************************************************************/

/*******************************************************************
*  Kuvaus: Sairausvakuutuksen p�iv�rahojen simuloimalli 2011       * 
*  Tekij�: Pertti Honkanen/ Kela                                   *
*  Luotu: 12.09.2011                                               *
*  Viimeksi p�ivitetty: 12.1.2012 							       * 
*  P�ivitt�j�: Olli Kannas / TK		                               *
********************************************************************/


/* 0. Yleisi� vakioiden m��rittelyj� (�l� muuta n�it�!) */

%LET START = &OUT;

%LET MALLI = SAIRVAK;

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

	%LET AVUOSI = 2010;		* Aineistovuosi (vvvv);

	%LET LVUOSI = 2010;		* Lains��d�nt�vuosi (vvvv);

	%LET TYYPPI = SIMUL;	* Parametrien hakutyyppi: SIMUL (vuosikeskiarvo) tai SIMULX (parametrit haetaan tietylle kuukaudelle);

	%LET LKUUK = 12;         * Lains��d�nt�kuukausi, jos parametrit haetaan tietylle kuukaudelle;

	%LET AINEISTO = PALV ;  * K�ytett�v� aineisto (PALV = Palveluaineisto, REK = Rekisteriaineisto) ;

	%LET TULOSNIMI_SV = sairvak_simul_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;

	%LET SDATATULO = 0;  * K�ytet��nk� SAIRVAK-mallissa datan tulotietoja = 1 vai laskennallisia tulotietoja = 0. 
					       Jos 1, niin k�ytet��n datan tulotietoja tulosrt ja tuloprt, muuten
			               k�ytet��n k��nteisfunktiolla m��riteltyj� tulotietoja. ;

	* Inflaatiokorjaus. Parametrien deflatoinnissa k�ytett�v�n kertoimen voi sy�tt�� itse
	  INF-makromuuttujaan (HUOM! desimaalit erotettava pisteell� .). Jos puolestaan haluaa k�ytt�� automaattista 
	  elinkustannusindeksiin perustuvaa parametrien muunnoskerrointa, 
	  tulee INF-makromuuttujalle antaa arvoksi 999 ; 	

	%LET INF = 1.00; * Sy�t� arvo tai 999 ;
	%LET PINDEKSI_VUOSI = pindeksi_vuosi; *K�ytett�v� indeksien parametritaulukko;		

	* Ajettavat osavaiheet ; 

	%LET LAKIMAKROT = 1;    * Lakimakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
	%LET LAKIMAK_TIED_SV = SAIRVAKlakimakrot;	* Lakimakroissa k�ytett�v�n tiedoston nimi ;
	%LET LAKIMAK_TIED_TT = TTURVAlakimakrot;	
	%LET APUMAKROT = 1;   	* Apumakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
	%LET APUMAK_TIED_SV = SAIRVAKapumakrot; * Apumakroissa k�ytett�v�n tiedoston nimi ;
	%LET APUMAK_TIED_TT = TTURVAapumakrot; 
	%LET POIMINTA = 1;  	* Muuttujien poiminta (1 jos ajetaan, 0 jos ei);
	%LET TULOKSET = 1;		* Yhteenvetotaulukot (1 jos ajetaan, 0 jos ei);

	%LET PSAIRVAK = psairvak; * K�ytett�v�n parametritiedoston nimi ;
	%LET PTTURVA = ptturva; * K�ytett�v�n parametritiedoston nimi ;

	* Tulostaulukoiden esivalinnat ; 

	%LET TULOSLAAJ = 1 ; 	 * Mikrotason tulosaineiston laajuus (1 = suppea, 2 = laaja (palveluaineisto)) ;
	%LET MUUTTUJAT = hsaiprva SAIRPR haiprva VANHPR pmkyt SAIRPR_TYONANT amkyt VANHPR_TYONANT hwmky ERITHOITR; * Taulukoitavat muuttujat (summataulukot) ;
	%LET YKSIKKO = 1;		 * Tulostaulukoiden yksikk� (1 = henkil�, 2 = kotitalous) ;
	%LET LUOK_HLO1 = ; * Taulukoinnin 1. henkil�luokitus (jos YKSIKKO = 1)
							   Vaihtoehtoina: 
							     desmod (tulodesiilit, ekvivalentit tulot (modoecd), hl�painot)
							     ikavu (henkil�n mukaiset ik�ryhm�t)
							     elivtu (kotitalouden elinvaihe)
							     koulas (henkil�n koulutusaste TK1997)
							     soss (henkil�n sosioekonominen asema AML2001)
							     rake (kotitalouden rakenne) ;
	%LET LUOK_HLO2 = ;		 * Taulukoinnin 2. henkil�luokitus ;
	%LET LUOK_HLO3 = ;		 * Taulukoinnin 3. henkil�luokitus ;

	%LET LUOK_KOTI1 = ; * Taulukoinnin 1. kotitalousluokitus (jos YKSIKKO = 2) 
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
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_SV..sas";
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_TT..sas";
%END;

/* Ajetaan apumakrot ja tallennetaan ne (optio) */

%IF &APUMAKROT = 1 %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&APUMAK_TIED_SV..sas";
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&APUMAK_TIED_TT..sas";
%END;

%MEND TeeMakrot;

%TeeMakrot;


/* 3. Datan poiminta ja apumuuttujien luominen (optio) */
%MACRO SairVak_Muut_Poiminta;

%IF &POIMINTA = 1 %THEN %DO;

	/* 3.1 M��ritell��n tarvittavat palveluaineiston muuttujat taulukkoon START_SAIRVAK */

	DATA STARTDAT.START_SAIRVAK;

	SET POHJADAT.&AINEISTO&AVUOSI;
	WHERE ppv > 0 OR ppvt > 0 OR apvt > 0 OR apv > 0 OR tulosrt > 0 OR tuloprt > 0 OR haiprva > 0
	OR hsaiprva > 0 OR amkyt > 0 OR hwmky > 0 OR wpv > 0;

	KEEP hnro knro ppv ppvt apv apvt tulosrt tuloprt haiprva hsaiprva pmkyt amkyt hwmky wpv
	muuperu aivpvkt aivpvt2 aivpvvk aivpvk aivpv2 aivpv aivpvt

	SAIR_PVX VANH_PVX SAIR_PER_PV VANH_PER_PV SAIR_TULO VANH_TULO SAIR_PV_TYONANT
	VANH_PV_TYONANT SAIRTULO_TYONANT VANHTULO_TYONANT EIKOROTUS 
	EIKOROTUS_TA VANHTULO_SPESIAL ERITHOIT_PER_PV  ERITHOIT_TULO 
	ONMINIMI ANSPALKKA;

	LABEL 
	SAIR_PVX = 'Vakuutetun sairausp�iv�rahap�iv�t, DATA'
	VANH_PVX = 'Vakuutetun vanhempainp�iv�rahap�iv�t, DATA'
	SAIR_PER_PV = 'Vakuutetun sairausp�iv�rahat p�iv�� kohden, DATA'
	VANH_PER_PV = 'Vakuutetun vanhempainp�iv�rahat p�iv�� kohden, DATA'
	SAIR_TULO = 'Laskennallinen vakuutetun sairausp�iv�rahan perusteena oleva tulo (e/v), DATA'
	VANH_TULO = 'Laskennallinen vakuutetun vanhemnpainp�iv�rahan perusteena oleva tulo (e/v), DATA'
	SAIR_PV_TYONANT = 'Ty�nantajalle maksettu sairausp�iv�raha p�iv�� kohden, DATA'
	VANH_PV_TYONANT = 'Ty�nantajalle maksettu vanhempainp�iv�raha p�iv�� kohden, DATA'
	SAIRTULO_TYONANT = 'Laskennallinen ty�nantajalle maksettavan sairausp�iv�rahan perusteena oleva tulo (e/v), DATA'
	VANHTULO_TYONANT = 'Laskennallinen ty�nantajalle maksettavanvanhemnpainp�iv�rahan perusteena oleva tulo (e/v), DATA'
	EIKOROTUS = 'Ei korotettuja vanhempainrahoja vakuutetuille (0/1), DATA'
	EIKOROTUS_TA = 'Ei korotettuja vanhempainp�iv�rahoja ty�nantajalle (0/1), DATA'
	VANHTULO_SPESIAL = 'K��nteisfunktiolla johdettu vanhempainp�iv�rahojen perusteena oleva tulo (e/kk), DATA'
	ERITHOIT_PER_PV = 'Erityishoitoraha p�iv�� kohden, DATA'
	ERITHOIT_TULO = 'Erityishoitorahan perusteena oleva tulo (e/kk), DATA'
	ONMINIMI = 'P�iv�raha on minimivanhempainp�iv�raha (1=tosi), DATA'
	ANSPALKKA = 'Johdettu palkka, kun p�iv�rahan oletetaan perustuvan ty�tt�myysturvaan, DATA';


	RUN;
	
%END;

%MEND SairVak_Muut_Poiminta;

%SairVak_Muut_Poiminta;


/* 4. Simulointivaihe */

%LET alkoi2&malli = %SYSFUNC(TIME());

/* 4.1 Jos parametrit luetaan makromuuttujiksi ennen simulontia, ajetaan t�m� makro, erillisajossa */

%MACRO KuukSimul;

%IF &F = S AND &TYYPPI = SIMULX %THEN %DO;

	%HaeParam_SairVakSIMUL(&LVUOSI, &LKUUK, &INF);
	%HaeParam_TTurvaSIMUL(&LVUOSI, &LKUUK, &INF);

%END;

%MEND KuukSimul;

%KuukSimul;

/* 4.2 Varsinainen simulointivaihe */

%MACRO SairVak_Simuloi_Data;

DATA OUTPUT.&TULOSNIMI_SV;
SET STARTDAT.START_SAIRVAK;

/* 4.2.1 Vaihtoehtoiset simulointitavat */

/* 4.2.1.1 K��nteisesti johdettuja tuloja k�ytt�v� laskenta */

IF &SDATATULO NE 1 OR tulosrt = 0 THEN DO;
	%SairVakPRahaV&F(SAIRPR, &LVUOSI, &INF, 0, 0, SAIR_TULO);
	%SairVakPRahaV&F(SAIRPR_TYONANT, &LVUOSI, &INF, 0, 0, SAIRTULO_TYONANT);
END;
IF &SDATATULO NE 1 OR tuloprt = 0 THEN DO;
	%SairVakPRahaV&F(VANHPR1, &LVUOSI, &INF, 1, 0, VANH_TULO);
	%SairVakPRahaV&F(VANHPR_TYONANT1, &LVUOSI, &INF, 1, 0, VANHTULO_TYONANT);
END;

/* 4.2.1.2 Datan valmiita tulotietoja k�ytt�v� laskenta */

IF &SDATATULO = 1 THEN DO;
	%SairVakPRahaV&F(SAIRPR, &LVUOSI, &INF, 0, 0, tulosrt / (1 - &PalkVah));
	%SairVakPRahaV&F(VANHPR1, &LVUOSI, &INF, 1, 0, tuloprt / (1 - &PalkVah));
	%SairVakPRahaV&F(SAIRPR_TYONANT, &LVUOSI, &INF, 0, 0, tulosrt / (1 - &PalkVah));
	%SairVakPRahaV&F(VANHPR_TYONANT1, &LVUOSI, &INF, 1, 0, tuloprt / (1 - &PalkVah));
END;

/* Kerrotaan lasketut p�iv�rahat p�ivien lukum��r�ll� */

SAIRPR = SAIR_PVX * SAIRPR / &SPaivat;
VANHPR1 = VANH_PVX * VANHPR1 / &SPaivat;
SAIRPR_TYONANT = ppvt * SAIRPR_TYONANT / &SPaivat;
VANHPR_TYONANT1 = apvt * VANHPR_TYONANT1 / &SPaivat;

/* Lasketaan korotuksen sis�lt�v�t vanhempainp�iv�rahat */

IF EIKOROTUS NE 1 AND (aivpvk > 0 OR aivpvvk > 0 OR aivpvkt > 0) THEN DO;
	IF &SDATATULO NE 1 OR tuloprt = 0 THEN DO;
		%VanhPRahaK&F(PROS90VANH, &LVUOSI, 1, &INF, 1, 0, 0, 0, VANHTULO_SPESIAL);
	END;
	ELSE DO;
		%VanhPRahaK&F(PROS90VANH, &LVUOSI, 1, &INF, 1, 0, 0, 0, tuloprt /(1 - &PalkVah));
	END;
	PROS90VANH = aivpvk * PROS90VANH;
	VANHPR1 = 0;
END;
IF EIKOROTUS NE 1 AND (aivpvk > 0 OR aivpvvk > 0 OR aivpvkt > 0) THEN DO;
	IF &SDATATULO NE 1 OR tuloprt = 0 THEN DO;
		%VanhPRahaK&F(PROS75VANH, &LVUOSI, 1, &INF, 0, 1, 0, 0, VANHTULO_SPESIAL);
	END;
	ELSE DO;
		%VanhPRahaK&F(PROS75VANH, &LVUOSI, 1, &INF, 0, 1, 0, 0, tuloprt / (1 - &PalkVah));
	END;
	PROS75VANH = aivpvvk * PROS75VANH;
	VANHPR1 = 0;
END;
IF EIKOROTUS_TA NE 1 AND (aivpvk > 0 OR aivpvvk > 0 OR aivpvkt > 0) THEN DO;
	IF &SDATATULO NE 1 OR tuloprt = 0 THEN DO;
		%VanhPRahaK&F(PROS90VANH_TANT, &LVUOSI, 1, &INF, 1, 0, 0, 0, VANHTULO_SPESIAL);
	END;
	ELSE DO;
		%VanhPRahaK&F(PROS90VANH_TANT, &LVUOSI, 1, &INF, 1, 0, 0, 0, tuloprt / (1 - &PalkVah));
	END;
	PROS90VANH_TANT = aivpvkt * PROS90VANH_TANT;
	VANHPR_TYONANT1 = 0;
END;
IF EIKOROTUS NE 1 AND (aivpvk > 0 OR aivpvvk > 0) THEN DO;
	IF &SDATATULO NE 1 OR tuloprt = 0 THEN DO;
		%VanhPRahaK&F(NORMVANH, &LVUOSI, 1, &INF, 0, 0, 1, 0, VANHTULO_SPESIAL);
	END;
	ELSE DO;
		%VanhPRahaK&F(NORMVANH, &LVUOSI, 1, &INF, 0, 0, 1, 0, tuloprt / (1 - &PalkVah));
	END;
	NORMVANH = aivpv2 * NORMVANH;
	VANHPR1 = 0;
END;
IF EIKOROTUS_TA NE 1 AND aivpvkt > 0 THEN DO;
	IF &SDATATULO NE 1 OR tuloprt = 0 THEN DO;
		%VanhPRahaK&F(NORMVANH_TYONANT, &LVUOSI, 1, &INF, 0, 0, 1, 0, VANHTULO_SPESIAL);
    END;
	ELSE DO;
		%VanhPRahaK&F(NORMVANH_TYONANT, &LVUOSI, 1, &INF, 0, 0, 1, 0, tuloprt / (1 - &PalkVah));
	END;
	NORMVANH_TYONANT =  aivpvt2 * NORMVANH_TYONANT;
	VANHPR_TYONANT1 = 0;
END;
IF EIKOROTUS = 1 AND VANH_PVX > 1 THEN DO;
	%SairVakPRahaV&F(VANHPR1, &LVUOSI, &INF, 1, 0, tuloprt /( 1 - &PalkVah));
	VANHPR1 = VANH_PVX * VANHPR1 / &SPaivat;
	PROS90VANH = 0;
	PROS75VANH = 0;
END;
IF EIKOROTUS_TA = 1 AND apvt > 1 THEN DO;
	%SairVakPRahaV&F(VANHPR_TYONANT1, &LVUOSI, &INF, 1, 0, tuloprt / ( 1 - &PalkVah));
	VANHPR_TYONANT1 = apvt * VANHPR_TYONANT1 / &SPaivat;
	PROS90VANH_TANT = 0;
	NORMVANH_TYONANT = 0;
END;

/* Lasketaan minimip�iv�rahat */

IF ONMINIMI = 1 THEN DO;
	%SairVakPRahaV&F(VANHPR1, &LVUOSI, &INF, 1, 0, 0);
	VANHPR1 = VANH_PVX * VANHPR1 / &SPaivat;
	PROS90VANH = 0;
	PROS75VANH = 0;
	NORMVANH = 0;
END;

/* Lasketaan erityishoitoraha */

IF wpv > 0 THEN DO;
	%SairVakPRahaV&F(ERITHOITR, &LVUOSI, &INF, 1, 0, ERITHOIT_TULO)
	ERITHOITR = wpv * ERITHOITR / &SPaivat;
END;

VANHPR = SUM(VANHPR1, NORMVANH,  PROS90VANH, PROS75VANH, 0);
NORMVANH = SUM(VANHPR1, NORMVANH);


/* Jos vanhempainp�iv�raha ei perustu ty�tuloon (muuperu <> "   ") eik� ole minimip�iv�raha, 
   johdetaan p�iv�raha ty�tt�myysp�iv�rahasta k�ytt�m�ll� apumuuttujaa ANSPALKKA.
   Huom! T�m� sivuuttaa mahdollisesti aikaisemmin lasketut muuttujat NORMVANH, PROS90VANH ja PROS75VANH */

IF (muuperu NE "  ") AND (ONMINIMI NE 1) THEN DO;

	%AnsioSidV&F(ANSIOSID, &LVUOSI, &INF, 0, 0, 0, 0, ANSPALKKA, 0);
	%LET KORJKERROIN = %SYSEVALF(&TTPaivia / &SPaivat);
	VANHPR = &KORJKERROIN * VANH_PVX * ANSIOSID /&TTPaivia;

END;

VANHPR_TYONANT = SUM(VANHPR_TYONANT1, NORMVANH_TYONANT, PROS90VANH_TANT, 0);
NORMVANH_TYONANT = SUM(VANHPR_TYONANT1, NORMVANH_TYONANT);

KEEP hnro hsaiprva SAIRPR haiprva VANHPR pmkyt SAIRPR_TYONANT amkyt VANHPR_TYONANT hwmky ERITHOITR
	 PROS90VANH PROS75VANH NORMVANH PROS90VANH_TANT NORMVANH_TYONANT;

RUN;

/* 4.3 Yhdistet��n simuloitu data palveluaineistoon (riippuen tulosaineiston laajuden valinnasta) */

DATA OUTPUT.&TULOSNIMI_SV;
	
/* 4.3.1 Suppea tulostiedosto (vain t�rkeimm�t luokittelumuuttujat) */

%IF &TULOSLAAJ = 1 %THEN %DO; 
	MERGE POHJADAT.&AINEISTO&AVUOSI 
	(KEEP = hnro knro &PAINO hsaiprva haiprva pmkyt amkyt hwmky
	ikavu ikavuV desmod soss paasoss elivtu koulas rake)
	OUTPUT.&TULOSNIMI_SV;
%END;

/* 4.3.2 Laaja tulostiedosto (palveluaineiston mukainen tulostiedosto) */

%IF &TULOSLAAJ = 2 %THEN %DO; 
	MERGE POHJADAT.&AINEISTO&AVUOSI OUTPUT.&TULOSNIMI_SV;
%END;

BY hnro;

* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukum��r�t voidaan laskea suoraan ;

ARRAY PISTE 
	hsaiprva SAIRPR haiprva VANHPR
	pmkyt SAIRPR_TYONANT amkyt
	VANHPR_TYONANT hwmky ERITHOITR
	PROS90VANH PROS75VANH NORMVANH PROS90VANH_TANT NORMVANH_TYONANT;
DO OVER PISTE;
	IF PISTE <= 0 THEN PISTE = .;
END;

* Luodaan simuloiduille ja datan muuttujille selitteet ;

LABEL 
hsaiprva = 'Vakuutetuille maksetut sairausp�iv�rahat, DATA'
SAIRPR = 'Vakuutetuille maksetut sairausp�iv�rahat, MALLI'
haiprva = 'Vakuutetuille maksetut vanhempainp�iv�rahat, DATA'
VANHPR = 'Vakuutetuille maksetut vanhempainp�iv�rahat, MALLI'
PROS90VANH = 'Vakuutetuille maksetut korotetut vanhempainp�iv�rahat (90% korvausaste), MALLI'
PROS75VANH = 'Vakuutetuille maksetut korotetut vanhempainp�iv�rahat (75% korvausaste), MALLI'
NORMVANH = 'Vakuutetuille maksetut korottamattomat vanhempainp�iv�rahat, MALLI'
pmkyt = 'Ty�nantajille maksetut sairausp�iv�rahat, DATA'
SAIRPR_TYONANT = 'Ty�nantajille maksetut sairausp�iv�rahat, MALLI'
amkyt = 'Ty�nantajille maksetut vanhempainp�iv�rahat, DATA'
VANHPR_TYONANT = 'Ty�nantajille maksetut vanhempainp�iv�rahat, MALLI'
PROS90VANH_TANT = 'Ty�nantajille maksetut korotetut vanhempainp�iv�rahat (90% korvausaste), MALLI'
NORMVANH_TYONANT = 'Ty�nantajille maksetut korottamattomat vanhempainp�iv�rahat, MALLI'
hwmky = 'Erityishoitorahat, DATA'
ERITHOITR = 'Erityishoitorahat, MALLI';

RUN;

%MEND SairVak_Simuloi_Data;

%SairVak_Simuloi_Data;

%LET loppui2&malli = %SYSFUNC(TIME());


/* 5. Luodaan summatason tulostaulukot (optio) */

%MACRO SairVak_Tulokset;

/* 5.1 Kotitaloustason tulokset (optio) */

/* 5.1.1 Mikrotason tulosaineiston summaus kotitaloustasolle (optio) */

%IF &YKSIKKO = 2 AND &START NE 1 %THEN %DO; 

	PROC SUMMARY DATA=OUTPUT.&TULOSNIMI_SV (DROP = hnro);
	BY knro ;
	ID &PAINO ikavuV desmod paasoss elivtu koulas rake;
	VAR &MUUTTUJAT _NUMERIC_;
	OUTPUT OUT = OUTPUT.&TULOSNIMI_SV (DROP = soss ikavu _TYPE_ _FREQ_)  SUM = ;
	RUN;

%END;

/* 5.1.2 Summatason tulostaulukko (optio) */

%IF &TULOKSET = 1 %THEN %DO;

	%IF &YKSIKKO = 2 %THEN %DO; 

		/* Siirret��n tiedot Exceliin (optio) */

		%IF &EXCEL = 1 %THEN %DO;

			ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_SV._SUMMAT.xls" STYLE = MINIMAL;

		%END;

		PROC MEANS DATA=OUTPUT.&TULOSNIMI_SV &SUMWGT &SUM &MIN &MAX &RANGE &MEAN &MEDIAN &MODE &STD &VAR &CV NONOBS ORDER=DATA NWAY MAXDEC = 0; 
		TITLE "TUNNUSLUVUT (KOTITALOUSTASO), &MALLI";
		CLASS &LUOK_KOTI1 &LUOK_KOTI2 &LUOK_KOTI3 / MLF PRELOADFMT;
		VAR &MUUTTUJAT ;
		FORMAT _NUMERIC_ tuhat. ;
		%DO I = 1 %TO 3; 
		%IF %LENGTH (&&LUOK_KOTI&I) >0 %THEN %DO;
			FORMAT &&LUOK_KOTI&I &&LUOK_KOTI&I... ;
		%END;%END;
		OUTPUT OUT = OUTPUT.&TULOSNIMI_SV._SUMMAT (DROP = _TYPE_ _FREQ_)
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
	
	/* 5.2 Henkil�tason tulokset (oletus) */

	%ELSE %DO;

		/* Siirret��n tiedot Exceliin (optio) */

		%IF &EXCEL = 1 %THEN %DO;

			ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_SV._SUMMAT.xls" STYLE = MINIMAL;

		%END;

		PROC MEANS DATA=OUTPUT.&TULOSNIMI_SV &SUMWGT &SUM &MIN &MAX &RANGE &MEAN &MEDIAN &MODE &STD &VAR &CV NONOBS ORDER=DATA NWAY MAXDEC = 0;
		TITLE "TUNNUSLUVUT (HENKIL�TASO), &MALLI";
		CLASS &LUOK_HLO1 &LUOK_HLO2 &LUOK_HLO3 / MLF PRELOADFMT;
		VAR &MUUTTUJAT ;
		FORMAT _NUMERIC_ tuhat. ;
		%DO I = 1 %TO 3; 
		%IF %LENGTH (&&LUOK_HLO&I) >0 %THEN %DO;
			FORMAT &&LUOK_HLO&I &&LUOK_HLO&I... ;
		%END;%END;
		OUTPUT OUT = OUTPUT.&TULOSNIMI_SV._SUMMAT (DROP = _TYPE_ _FREQ_)
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

%MEND SairVak_Tulokset;

%SairVak_Tulokset;


/* 6. Mitataan kuinka kauan osavaiheisiin kului aikaa */

%LET loppui1 = %SYSFUNC(TIME());

%LET loppui1&malli = %SYSFUNC(TIME());

%LET kului1&malli = %SYSEVALF(&&loppui1&malli - &&alkoi1&malli);

%LET kului2&malli = %SYSEVALF(&&loppui2&malli - &&alkoi2&malli);

%LET kului1&malli = %SYSFUNC(PUTN(&&kului1&malli, time10.2));

%LET kului2&malli = %SYSFUNC(PUTN(&&kului2&malli, time10.2));


%PUT &malli. Koko laskenta. Aikaa kului (hh:mm:ss.00) &&kului1&malli;

%PUT &malli. Varsinainen simulointi. Aikaa kului (hh:mm:ss.00) &&kului2&malli;





