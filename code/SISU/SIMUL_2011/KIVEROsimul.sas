/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hy�dynt�� Tilastokeskuksen yleisten
* k�ytt�ehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto p��hakemistossa.
******************************************************************************/

/*********************************************************** *
*  Kuvaus: Kiinteist�verotuksen simulointimalli	2011	     * 
*  Tekij�: Anne Per�lahti / TK	                             *
*  Luotu: 6.6.2012                                           *
*  Viimeksi p�ivitetty: 5.9.2012	  		 				 * 
*  P�ivitt�j�: Anne Per�lahti / TK			                 *
* ***********************************************************/


/* 0. Yleisi� vakioiden m��rittelyj� (�l� muuta n�it�!) */

%LET START = &OUT;

%LET MALLI = KIVERO;

%LET TYYPPI = SIMUL;	

%LET alkoi1&malli = %SYSFUNC(TIME());

/* 1. Mallia ohjaavat makromuuttujat */

%MACRO Aloitus;

%IF &START = 1 %THEN %DO;
	%LET TULOKSET = &TULOKSET_KOKO;
%END;
	
%IF &START NE 1 %THEN %DO;

	/* Jos mallia k�ytet��n k�ytt�liittym�st� (&EG = 1), niin seuraavia vaiheita ei ajeta */

	%IF &EG NE 1 %THEN %DO;
	
	%LET AVUOSI = 2011;		* Aineistovuosi (vvvv);

	%LET LVUOSI = 2011;		* Lains��d�nt�vuosi (vvvv);

	%LET AINEISTO = PALV; 	* K�ytett�v� aineisto (aina PALV);

	%LET TULOSNIMI_KV = kivero_simul_&SYSDATE._1;  * Simuloidun tulostiedoston nimi;

	/* Inflaatiokorjaus. Parametrien deflatoinnissa k�ytett�v�n kertoimen voi sy�tt�� itse
	  INF-makromuuttujaan (HUOM! desimaalit erotettava pisteell� .). Jos puolestaan haluaa k�ytt�� automaattista 
	  elinkustannusindeksiin perustuvaa parametrien muunnoskerrointa, 
	  tulee INF-makromuuttujalle antaa arvoksi 999 */

	%LET INF = 1.00; 	* Sy�t� arvo tai 999;
	%LET PINDEKSI_VUOSI = pindeksi_vuosi; * K�ytett�v� indeksien parametritaulukko;

	/* Ajettavat osavaiheet */

	%LET LAKIMAKROT = 1;    * Lakimakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
	%LET LAKIMAK_TIED_KV = KIVEROlakimakrot;	* Lakimakroissa k�ytett�v�n tiedoston nimi;
	%LET APUMAKROT = 1;   	* Apumakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
	%LET APUMAK_TIED_KV = KIVEROapumakrot; * Apumakroissa k�ytett�v�n tiedoston nimi;
	%LET POIMINTA = 1;  	* Muuttujien poiminta (1 jos ajetaan, 0 jos ei);
	%LET TULOKSET = 1;		* Yhteenvetotaulukot (1 jos ajetaan, 0 jos ei);

	/* K�ytett�vien parametritiedostojen nimet */

	%LET PKIVERO = pkivero; * K�ytett�v�n parametritiedoston nimi;
		
	/* Tulostaulukoiden esivalinnat */

	%LET TULOSLAAJ = 1; 	* Mikrotason tulosaineiston laajuus (1 = suppea, 2 = laaja (palveluaineisto));
	%LET MUUTTUJAT = VALOPULLINENPT valopullinenptd VALOPULLINENVA valopullinenvad 
					 RAK_KVEROPT rak_kveroptd RAK_KVEROVA rak_kverovad
					 verotusarvo KVTONTTIS kvtontti 
					 ASOYKIVERO VERARVODATA omakkiiv KIVEDATA KIVEROYHT2 KIVEROYHT; 	* Taulukoitavat muuttujat (summataulukot);
	%LET YKSIKKO = 1;		* Tulostaulukoiden yksikk� (1 = henkil�, 2 = kotitalous);
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

	%LET EXCEL = 0; 		* Vied��nk� tulostaulukko automaattisesti Exceliin (1 = Kyll�, 0 = Ei);

	/* Laskettavat tunnusluvut (jos tyhj�, niin ei lasketa) */

	%LET SUMWGT = SUMWGT; 	* N eli lukum��r�t;
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

	%LET PAINO = ykor; 	* K�ytett�v� painokerroin (jos tyhj�, niin lasketaan painottamattomana);
	%LET RAJAUS = ; 	* Rajauslause tunnuslukujen laskentaan (jos tyhj�, niin ei rajauksia);

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

	%LET KIVERO_AINEISTO = KIVE_&AINEISTO&AVUOSI; 	* K�ytett�v� kiinteist�verorekisterin aineisto (aina KIVE_&AINEISTO&AVUOSI);

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
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_KV..sas";
%END;

/* Ajetaan apumakrot ja tallennetaan ne (optio) */

%IF &APUMAKROT = 1 %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&APUMAK_TIED_KV..sas";
%END;

%MEND TeeMakrot;

%TeeMakrot;


/* 3. Datan poiminta ja apumuuttujien luominen (optio) */

%MACRO KiVero_Muutt_Poiminta;

%IF &POIMINTA = 1 %THEN %DO;

	/* 3.1 M��ritell��n tarvittavat muuttujat taulukoihin START_KIVERO_REK ja START_KIVERO_PALV */

	/* Kiinteist�veroaineiston muuttujat */

	DATA STARTDAT.START_KIVERO_REK;
	SET POHJADAT.&KIVERO_AINEISTO
	(KEEP = hnro raktyyppi kvkayttokoodi valmispvm ikavuosi 
	kantarakenne rakennuspa kellaripa vesik lammitysk sahkok 
	talviask viemarik wck saunak verotusarvo valopullinen rak_kvero
	kiintpros veropros kvtontti jhvalarvokoodi omosoittaja omnimittaja);

	/* Lis�t��n aineistoon apumuuttujaksi omistusosuus kiinteist�st� */

	IF omnimittaja = 0 THEN omnimittaja = 1;

	OMOSUUS = omosoittaja / SUM(omnimittaja);

	LABEL 	
	OMOSUUS = 'Omistusosuus, DATA';

	/* M��ritell��n verotusarvo ja kiinteist�vero eri rakennustyypeille
	ja luodaan niille summamuuttujat */

	IF raktyyppi = 1 THEN valopullinenptd = valopullinen;
	IF raktyyppi = 7 THEN valopullinenvad = valopullinen;

	IF raktyyppi = 1 THEN rak_kveroptd = rak_kvero;
	IF raktyyppi = 7 THEN rak_kverovad = rak_kvero;
	
	KIVEDATA = SUM(rak_kveroptd, rak_kverovad, kvtontti);
	VERARVODATA = SUM(valopullinenptd, valopullinenvad, verotusarvo);

	/* Lasketaan datan arvot uudelleen henkil�iden omistusosuuksien suhteen */

	valopullinen = valopullinen * OMOSUUS;
	valopullinenptd = valopullinenptd * OMOSUUS;
	valopullinenvad = valopullinenvad * OMOSUUS;
	rak_kvero = rak_kvero * OMOSUUS;
	rak_kveroptd = rak_kveroptd * OMOSUUS; 
	rak_kverovad = rak_kverovad * OMOSUUS;
	verotusarvo = verotusarvo * OMOSUUS;
	kvtontti = kvtontti * OMOSUUS; 
	VERARVODATA = VERARVODATA * OMOSUUS; 
	KIVEDATA = KIVEDATA * OMOSUUS;

	/* Luodaan datan muuttujille selitteet */

	LABEL
	valopullinen = 'Rakennusten verotusarvo yhteens� (kiinteist�verorek.), DATA'
	valopullinenptd = 'Pientalojen verotusarvo (kiinteist�verorek.), DATA'
	valopullinenvad = 'Vapaa-ajan asuntojen verotusarvo (kiinteist�verorek.), DATA'
	rak_kvero = 'Rakennusten kiinteist�vero yhteens� (e/v) (kiinteist�verorek.), DATA'
	rak_kveroptd = 'Pientalojen kiinteist�vero (e/v) (kiinteist�verorek.), DATA'
	rak_kverovad = 'Vapaa-ajan asuntojen kiinteist�vero (e/v) (kiinteist�verorek.), DATA'
	verotusarvo = 'Maapohjan verotusarvo (kiinteist�verorek.), DATA'
	kvtontti = 'Maapohjan kiinteist�vero (e/v) (kiinteist�verorek.), DATA'
	VERARVODATA = 'Verotusarvo (pl. asoy) yhteens� (e/v) (kiinteist�verorek.), DATA'
	KIVEDATA = 'Kiinteist�verot (pl. asoy) yhteens� (e/v) (kiinteist�verorek.), DATA';

	RUN;

	/* Palveluaineiston muuttujat (k�ytet��n asunto-osakeyhti�iden kiinteist�veron laskentaan) */

	DATA STARTDAT.START_KIVERO_PALV;
	SET POHJADAT.&AINEISTO&AVUOSI 
	(KEEP = hnro knro aslaji talotyyp rakvuosi 
	hoitvast omakkiiv);
	RUN;

	/* Lis�t��n aineistoon apumuuttujaksi rakennuksen valmistumisvuosi */

	DATA STARTDAT.START_KIVERO_REK; 
	SET STARTDAT.START_KIVERO_REK;

	IF LENGTH(valmispvm) = 4 THEN VALMVUOSI = valmispvm;
	IF LENGTH(valmispvm) = 10 THEN VALMVUOSI = substr(valmispvm, 7, 4);

	LABEL 	
	VALMVUOSI = 'Rakennuksen valmistumisvuosi, DATA';

	RUN;

%END;

%MEND KiVero_Muutt_Poiminta;

%KiVero_Muutt_Poiminta;


/* 4. KIVERO-mallissa (vuositason lains��d�nt�) parametrit luetaan makromuuttujiksi ennen simulontia */

%HaeParam_KiVeroSIMUL(&LVUOSI, &INF);


/* 5. Simulointivaihe */

%LET alkoi2&malli = %SYSFUNC(TIME());

%MACRO KiVero_Simuloi_Data;

DATA TEMP.KIVERO_REK;
SET STARTDAT.START_KIVERO_REK;

/* 5.1 Lasketaan ensin kiinteist�verorekisterin tiedot */

/* Lasketaan pientalon verotusarvo */

%PtVerotusArvoS(VALOPULLINENPT, &LVUOSI, &INF, raktyyppi, valmvuosi, ikavuosi, kantarakenne, rakennuspa, kellaripa, vesik, lammitysk, sahkok, jhvalarvokoodi);

/* Lasketaan pientalon kiinteist�vero */

%KiVeroPtS(RAK_KVEROPT, &LVUOSI, &INF, raktyyppi, valmvuosi, ikavuosi, kantarakenne, rakennuspa, kellaripa, vesik, lammitysk, sahkok, jhvalarvokoodi, veropros);

/* Lasketaan vapaa-ajan asunnon verotusarvo */

%VapVerotusArvoS(VALOPULLINENVA, &LVUOSI, &INF, raktyyppi, valmvuosi, ikavuosi, kantarakenne, rakennuspa, 
talviask, sahkok, viemarik, vesik, wck, saunak, jhvalarvokoodi);

/* Lasketaan vapaa-ajan asunnon kiinteist�vero */

%KiVeroVapS(RAK_KVEROVA, &LVUOSI, &INF, raktyyppi, valmvuosi, ikavuosi, kantarakenne, rakennuspa, talviask, sahkok, 
viemarik, vesik, wck, saunak, jhvalarvokoodi, veropros);

/* Lasketaan kiinteist�vero maapohjasta */

KVTONTTIS = verotusarvo * (kiintpros / 100);

/* Lasketaan verotusarvo ja kiinteist�vero omistusosuuden suhteen */

VALOPULLINENPT = VALOPULLINENPT * OMOSUUS;
RAK_KVEROPT = RAK_KVEROPT * OMOSUUS;
VALOPULLINENVA = VALOPULLINENVA * OMOSUUS;
RAK_KVEROVA = RAK_KVEROVA * OMOSUUS;

/* Luodaan tulosmuuttujille selitteet */

LABEL
VALOPULLINENPT = 'Pientalojen verotusarvo, MALLI'
RAK_KVEROPT = 'Pientalojen kiinteist�vero (e/v), MALLI'
VALOPULLINENVA = 'Vapaa-ajan asuntojen verotusarvo, MALLI'
RAK_KVEROVA = 'Vapaa-ajan asuntojen kiinteist�vero (e/v), MALLI'
KVTONTTIS = 'Maapohjan kiinteist�vero (e/v), MALLI';
RUN;

/* 5.2 Lasketaan kiinteist�vero asunto-osakeyhti�iss� palveluaineiston perusteella */

DATA TEMP.KIVERO_PALV;
SET STARTDAT.START_KIVERO_PALV (KEEP = hnro knro aslaji talotyyp rakvuosi hoitvast omakkiiv);

/* M��ritell��n kiinteist�veron osuus hoitovastikkeista "Asunto-osakeyhti�iden talous 2010" -raportin mukaan
   ja eritell��n kerrostalo- ja rivitaloyhti�ihin asunnon i�n mukaan. */

IF aslaji = 3 and talotyyp = 4 THEN DO;
	IF rakvuosi LT 1960 THEN HOITOSUUS = 0.0559;
	IF (1960 LE rakvuosi LT 1970) THEN HOITOSUUS = 0.0539;
	IF (1970 LE rakvuosi LT 1980) THEN HOITOSUUS = 0.0529;
	IF (1980 LE rakvuosi LT 1990) THEN HOITOSUUS = 0.0689;
	IF (1990 LE rakvuosi LT 2000) THEN HOITOSUUS = 0.0699;
	IF rakvuosi GE 2000 THEN HOITOSUUS = 0.0970;
END;
 
IF aslaji = 3 and talotyyp LT 4 THEN DO;
	IF rakvuosi LT 1960 THEN HOITOSUUS = 0.0610;
	IF (1960 LE rakvuosi LT 1970) THEN HOITOSUUS = 0.0706;
	IF (1970 LE rakvuosi LT 1980) THEN HOITOSUUS = 0.0508;
	IF (1980 LE rakvuosi LT 1990) THEN HOITOSUUS = 0.0735;
	IF (1990 LE rakvuosi LT 2000) THEN HOITOSUUS = 0.0798;
	IF rakvuosi GE 2000 THEN HOITOSUUS = 0.1055;
END;

ASOYKIVERO =(hoitvast * HOITOSUUS) * 12;

LABEL
HOITOSUUS = 'Kiinteist�veron osuus hoitovastikkeesta (%), MALLI'
ASOYKIVERO = 'Kiinteist�vero asunto-osakeyhti�ss� (e/v), MALLI';

RUN;

/*5.3 Summataan kiinteist�veroaineisto henkil�tasolle, yhdistet��n tulokset palveluaineistoon 
	ja lasketaan kiinteist�vero yhteens� */

PROC SUMMARY DATA = TEMP.KIVERO_REK ;
VAR VALOPULLINENPT RAK_KVEROPT VALOPULLINENVA RAK_KVEROVA KVTONTTIS verotusarvo kvtontti  
    valopullinenptd valopullinenvad rak_kveroptd rak_kverovad KIVEDATA VERARVODATA;
BY hnro;
OUTPUT OUT = TEMP.KIVERO_SUMMAT (DROP = _TYPE_ _FREQ_) SUM=;
RUN;

DATA OUTPUT.&TULOSNIMI_KV;
MERGE TEMP.KIVERO_PALV TEMP.KIVERO_SUMMAT;
BY hnro;
	
KIVEROYHT = SUM(RAK_KVEROPT, RAK_KVEROVA, KVTONTTIS, ASOYKIVERO);
KIVEROYHT2 = SUM(RAK_KVEROPT, RAK_KVEROVA, KVTONTTIS);

LABEL
KIVEROYHT = 'Kiinteist�verot (ml. asoy) yhteens� (e/v), MALLI'
KIVEROYHT2 = 'Kiinteist�verot (pl. asoy) yhteens� (e/v), MALLI';

RUN;

/* 5.4 Yhdistet��n simuloitu data palveluaineistoon (riippuen tulosaineiston laajuden valinnasta) */

DATA OUTPUT.&TULOSNIMI_KV;

/* 5.4.1 Suppea tulostiedosto (vain t�rkeimm�t luokittelumuuttujat) */

%IF &TULOSLAAJ = 1 %THEN %DO;
	MERGE POHJADAT.&AINEISTO&AVUOSI 
	(KEEP = hnro knro &PAINO ikavu ikavuV soss paasoss desmod koulas elivtu rake)
	OUTPUT.&TULOSNIMI_KV;
%END;

/* 5.4.2 Laaja tulostiedosto (palveluaineiston mukainen tulostiedosto) */

%IF &TULOSLAAJ = 2 %THEN %DO;
	MERGE POHJADAT.&AINEISTO&AVUOSI OUTPUT.&TULOSNIMI_KV;
%END;

BY hnro;

/* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukum��r�t voidaan laskea suoraan */

ARRAY PISTE 
	 VALOPULLINENPT RAK_KVEROPT VALOPULLINENVA RAK_KVEROVA KVTONTTIS ASOYKIVERO KIVEROYHT KIVEROYHT2
	 valopullinenptd valopullinenvad rak_kveroptd rak_kverovad  
	 verotusarvo kvtontti omakkiiv KIVEDATA VERARVODATA;
DO OVER PISTE;
	IF PISTE <= 0 THEN PISTE = .;
END;

LABEL 
omakkiiv = 'Kiinteist�verot (pl. asoy) yhteens� (e/v) (palveluaineisto), DATA';

RUN;

%MEND;

%KiVero_Simuloi_data;

%LET loppui2&malli = %SYSFUNC(TIME());


/* 6. Luodaan summatason tulostaulukot (optio) */ 

%MACRO KiVero_Tulokset;

/* 6.1 Kotitaloustason tulokset (optio) */

/* 6.1.1 Mikrotason tulosaineiston summaus kotitaloustasolle (optio) */

%IF &YKSIKKO = 2 AND &START NE 1 %THEN %DO;

	PROC SUMMARY DATA=OUTPUT.&TULOSNIMI_KV;
	BY knro;
	ID &PAINO ikavuV desmod paasoss elivtu koulas rake;
	VAR &MUUTTUJAT _NUMERIC_;
	OUTPUT OUT = OUTPUT.&TULOSNIMI_KV (DROP = soss ikavu _TYPE_ _FREQ_)  SUM = ;
	RUN;

%END;

%IF &TULOKSET = 1 %THEN %DO;

	%IF &YKSIKKO = 2 %THEN %DO; 

		/* Siirret��n tiedot Exceliin (optio) */

		%IF &EXCEL = 1 %THEN %DO;

			ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_KV._SUMMAT.xls" STYLE = MINIMAL;

		%END;

		PROC MEANS DATA=OUTPUT.&TULOSNIMI_KV &SUMWGT &SUM &MIN &MAX &RANGE &MEAN &MEDIAN &MODE &STD &VAR &CV NONOBS ORDER=DATA NWAY MAXDEC = 0; 
		TITLE "TUNNUSLUVUT (KOTITALOUSTASO), &MALLI";
		CLASS &LUOK_KOTI1 &LUOK_KOTI2 &LUOK_KOTI3 / MLF PRELOADFMT;
		VAR &MUUTTUJAT ;
		FORMAT _NUMERIC_ tuhat. ;
		%DO I = 1 %TO 3; 
		%IF %LENGTH (&&LUOK_KOTI&I) >0 %THEN %DO;
			FORMAT &&LUOK_KOTI&I &&LUOK_KOTI&I... ;
		%END;%END;
		OUTPUT OUT = OUTPUT.&TULOSNIMI_KV._SUMMAT (DROP = _TYPE_ _FREQ_)
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

			ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_KV._SUMMAT.xls" STYLE = MINIMAL;

		%END;

		PROC MEANS DATA=OUTPUT.&TULOSNIMI_KV &SUMWGT &SUM &MIN &MAX &RANGE &MEAN &MEDIAN &MODE &STD &VAR &CV NONOBS ORDER=DATA NWAY MAXDEC = 0;
		TITLE "TUNNUSLUVUT (HENKIL�TASO), &MALLI";
		CLASS &LUOK_HLO1 &LUOK_HLO2 &LUOK_HLO3 / MLF PRELOADFMT;
		VAR &MUUTTUJAT ;
		FORMAT _NUMERIC_ tuhat. ;
		%DO I = 1 %TO 3; 
		%IF %LENGTH (&&LUOK_HLO&I) >0 %THEN %DO;
			FORMAT &&LUOK_HLO&I &&LUOK_HLO&I... ;
		%END;%END;
		OUTPUT OUT = OUTPUT.&TULOSNIMI_KV._SUMMAT (DROP = _TYPE_ _FREQ_)
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


%MEND KiVero_Tulokset;

%KiVero_Tulokset;


/* 7. Mitataan kuinka kauan osavaiheisiin kului aikaa */

%LET loppui1 = %SYSFUNC(TIME());

%LET loppui1&malli = %SYSFUNC(TIME());

%LET kului1&malli = %SYSEVALF(&&loppui1&malli - &&alkoi1&malli);

%LET kului2&malli = %SYSEVALF(&&loppui2&malli - &&alkoi2&malli);

%LET kului1&malli = %SYSFUNC(PUTN(&&kului1&malli, time10.2));

%LET kului2&malli = %SYSFUNC(PUTN(&&kului2&malli, time10.2));


%PUT &malli. Koko laskenta. Aikaa kului (hh:mm:ss.00) &&kului1&malli;

%PUT &malli. Varsinainen simulointi. Aikaa kului (hh:mm:ss.00) &&kului2&malli;





