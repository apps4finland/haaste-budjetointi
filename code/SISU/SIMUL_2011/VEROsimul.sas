/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hy�dynt�� Tilastokeskuksen yleisten
* k�ytt�ehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto p��hakemistossa.
******************************************************************************/

/*********************************************************** *
*  Kuvaus: Tuloverotuksen simulointimalli 2011		         * 
*  Tekij�: Pertti Honkanen/ Kela                             *
*  Luotu: 12.09.2011                                         *
*  Viimeksi p�ivitetty: 7.5.2013  		 					 * 
*  P�ivitt�j�: Olli Kannas / TK                       	 	 *
* ***********************************************************/

/* 0. Yleisi� vakioiden m��rittelyj� (�l� muuta n�it�!) */

%LET START = &OUT;

%LET MALLI = VERO;

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
	
	%LET AVUOSI = 2010;		/* Aineistovuosi (vvvv)*/

	%LET LVUOSI = 2010;		/* Lains��d�nt�vuosi (vvvv) */

	%LET AINEISTO = PALV; 	/* K�ytett�v� aineisto (PALV = tulonjaon palveluaineisto, REK = mikrosimuloinnin rekisteriaineisto) */

	%LET TULOSNIMI_VE = vero_simul_&SYSDATE._1; /* Simuloidun tulostiedoston nimi */

	%LET TARKPVM = 1;    	/* Jos t�m�n arvo = 1, sairausvakuutuksen p�iv�rahamaksun
						       laskentaa tarkennetaan k��nteisell� p��ttelyll� */

	/* Inflaatiokorjaus. Parametrien deflatoinnissa k�ytett�v�n kertoimen voi sy�tt�� itse
	  INF-makromuuttujaan (HUOM! desimaalit erotettava pisteell� .). Jos puolestaan haluaa k�ytt�� automaattista 
	  elinkustannusindeksiin perustuvaa parametrien muunnoskerrointa, 
	  tulee INF-makromuuttujalle antaa arvoksi 999 */

	%LET INF = 1.00; 	/* Sy�t� arvo tai 999 */
	%LET PINDEKSI_VUOSI = pindeksi_vuosi; /* K�ytett�v� indeksien parametritaulukko */	

	/* Ajettavat osavaiheet */

	%LET LAKIMAKROT = 1;    /* Lakimakro-ohjelman ajo (1 jos ajetaan, 0 jos ei) */
	%LET LAKIMAK_TIED_VE = VEROlakimakrot;	/* Lakimakroissa k�ytett�v�n tiedoston nimi */
	%LET APUMAKROT = 1;   	/* Apumakro-ohjelman ajo (1 jos ajetaan, 0 jos ei) */
	%LET APUMAK_TIED_VE = VEROapumakrot; /* Apumakroissa k�ytett�v�n tiedoston nimi */
	%LET POIMINTA = 1;  	/* Muuttujien poiminta (1 jos ajetaan, 0 jos ei) */
	%LET TULOKSET = 1;		/* Yhteenvetotaulukot (1 jos ajetaan, 0 jos ei) */

	/* K�ytett�vien parametritiedostojen nimet */

	%LET PVERO = pvero;
	%LET PVERO_VARALL = pvero_varall; 
			
	/* Tulostaulukoiden esivalinnat */

	%LET TULOSLAAJ = 1; 	/* Mikrotason tulosaineiston laajuus (1 = suppea, 2 = laaja (palveluaineisto)) */
	%LET MUUTTUJAT = ANSIOT POTULOT KOKONTULO ltva VALTVEROF ltvp POVEROB lkuve KUNNVEROE lkive KIRKVEROE lshma SAIRVAKE lelvak PALKVAK 
					 lpvma PRAHAMAKSU YLEVERO KAIKKIVEROT KAIKKIVEROT_DATA verot MAKSP_VEROT ; /* Taulukoitavat muuttujat (summataulukot) */
	%LET YKSIKKO = 1;		/* Tulostaulukoiden yksikk� (1 = henkil�, 2 = kotitalous) */
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

	%LET EXCEL = 0; 		/* Vied��nk� tulostaulukko automaattisesti Exceliin (1 = Kyll�, 0 = Ei) */

	/* Laskettavat tunnusluvut (jos tyhj�, niin ei lasketa) */

	%LET SUMWGT = SUMWGT; 	/* N eli lukum��r�t */
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

	%LET PAINO = ykor ; 	/* K�ytett�v� painokerroin (jos tyhj�, niin lasketaan painottamattomana) */
	%LET RAJAUS =  ; 		/* Rajauslause tunnuslukujen laskentaan (jos tyhj�, niin ei rajauksia) */

	%END;

	/* Osamallien ohjausparametrien arvot asetetaan nolliksi, jos mallia ajetaan erillisajossa (= ei KOKO-mallista) */

	%LET SAIRVAK = 0; %LET TTURVA = 0; %LET OPINTUKI = 0; %LET KANSEL = 0; %LET KOTIHTUKI = 0;

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
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_VE..sas";
%END;

/* Ajetaan apumakrot ja tallennetaan ne (optio) */

%IF &APUMAKROT = 1 %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&APUMAK_TIED_VE..sas";
%END;

%MEND TeeMakrot;

%TeeMakrot;


/* 3. Datan poiminta ja apumuuttujien luominen (optio) */


/* 3.1 Haetaan muuttujapoimintaa ja apumuuttujien luomista varten parametrit makromuuttujiksi */  

%HaeParam_VeroSIMUL(&AVUOSI, 1);


%MACRO Vero_Muutt_Poiminta;

%IF &POIMINTA = 1 %THEN %DO;

	/* 3.2 M��ritell��n tarvittavat palveluaineiston muuttujat taulukkoon START_VERO */

	DATA STARTDAT.START_VERO;
	SET POHJADAT.&AINEISTO&AVUOSI (KEEP = 
	 hnro knro ykor soss maakunta
	 asko ayri11 ayri12 ayri13 ceinv
	 cinv cllkm csivs cvakm cvah dtyllae 
	 fluotap ftapakk ftapep ftapepp ftapot
	 ftappm ftappmp ftyhmt ikakk
	 ikavu kayri11 kayri12 kayri13 lalu3 lalu7 lapsiev
	 lautta lelake lelvak lkive lkuve
	 lpakelva lpvma lshma ltva ltvp
	 lveru lvrtk lvrtp mamutuki nmuut
	 svatkp svatva svatvap svatpp tansel
	 teanstu teinova teinovab teinovv teinovvb
	 teinoob
	 telps telps1 telps2 telps5 telulko
	 telvpal tenosve tepalk tjmark tjvkork
	 tkansel tkuntra tkust tlakko tliik1
	 tliik2 tliik2p tliikp tlue tlue1
	 tlue2 tlue3 tmaat1 tmaat1p tmaat2
	 tmaat2p tmeri tmets tmetsp tmetspp
	 tmluoko tmpt tmtatt tmuuel tmuukor
	 tmuupr tmuut tmuutp tmyynt tmyynt1
	 tnoosvab tnoosvvb tomlis topkb topkva
	 topkver topkvvap topkvvo toptio tpalk1y
	 tpalv tpalv2 tpalv2a tpalv2p tpeito
	 tperhel tpjta tporo1 tporo2 tpotel
	 tpturva trespa trpl trplkor anstukor tsiraho
	 tsktpr tsuurpu ttapel ttappr ttyoel
	 ttyoltuk tulk tulkel tulkk tulkp
	 tulkp6 tulkp61 tulkp6y tulks tulkya1
	 tulkya2 tulkyhp tulosrt tuosvv tuosvvap
	 tvahevas tptmuu tvakpr tvaksp tvlkorp tvtkorp
	 tvuokr tvuokr1 tyht1 tyhtat tyhthav
	 tyhtpot tyot valimh velakk velatk velatv
	 verot vevm vinvk vinvv vkoras vkorep vkortu
	 vkotita vkotitki vkotitku vkotitp vkotitsv
	 vluothm vmatk vmetsa vmtyotk vmtyotv
	 vmuut1 vmuutk vmuutv vohmb vohvah vopintor
	 vpalkk vper vsiirtv vthm vthm2
	 vthm3 vthm4 vthmu vtpv vtyasv vtyasvv
	 vtyomj vvemovk vvemyh vvevah vvvmk1 vvvmk2
	 vvvmk3 vvvmk4 vvvmk5 yhtez ptmk yrtukor
	 hsaiprva haiprva tpar kthr
	 kthl oshr tkotihtu hwmky aiopira
	 htyotper ttyotpr tkoultuk tmtukimk
	 tkuntra opirako opirake tkopira ktku
	 htkapr hkotihm tkansel tperhel takuuel velakv
	 vtyotu oplaikor tjmarkh
	 tvahep50 tptvs tvahep20 tptsu50
	 korosazkg korosazkf korosatkg korosatkf 
	 dtyhtep mtlisa korosapks korosapkw AILMKOR1DAT AILMKOR5DAT

	 PRAHAMAKSUTULO VKERROIN);

	/* Verrataan lains��d�nt�vuotta aineiston �yreihin, valitaan l�hin �yri 
	   ja uudelleennimet��n vero�yrit simulointia vastaaviksi. 
	   Jos lains��d�nt�vuotta vastaavaa �yri� ei l�ydy aineistosta, kerrotaan sit� l�hinn� oleva
	   korotuskertoimella kohdassa 5. 
	   Muista p�ivitt�� t�m� mallivuoden mukaiseksi! */

	%IF ((&LVUOSI GE 2011) AND (&LVUOSI LE 2013)) %THEN %DO; 
		%LET LAYRI = %SUBSTR(&LVUOSI, 3, 2);
		RENAME ayri&LAYRI = AYRI kayri&LAYRI = KAYRI;
	%END;

	%ELSE %IF &LVUOSI < 2011 %THEN %DO;
		RENAME ayri11 = AYRI kayri11 = KAYRI;
	%END;

	%ELSE %IF &LVUOSI > 2013 %THEN %DO;
		RENAME ayri13 = AYRI kayri13 = KAYRI;
	%END;

	RUN;

	/* 3.3 Lis�t��n aineistoon apumuuttujia */

	/* Puolisot */
		
	DATA TEMP.VERO_PUOLISOT;
	SET STARTDAT.START_VERO (KEEP = knro hnro csivs asko);
	WHERE asko = 1 OR asko = 2;
	RUN;

	PROC MEANS DATA = TEMP.VERO_PUOLISOT SUM NOPRINT;
	BY knro;
	VAR asko;
	OUTPUT OUT = TEMP.VERO_PUOLISOT_2 SUM(asko) = PSOTX;
	RUN;

	DATA STARTDAT.START_VERO;
	MERGE STARTDAT.START_VERO TEMP.VERO_PUOLISOT_2 (WHERE = (PSOTX  = 3) KEEP = knro PSOTX);
	BY knro;
	RUN;

	/* Apumuuttujia */

	DATA STARTDAT.START_VERO;
	SET STARTDAT.START_VERO;

	SELECT;
	WHEN (ikavu > 53) KUUK53 = 12;
	WHEN (ikavu = 53) KUUK53 = ikakk;
	WHEN (ikavu < 53) KUUK53 = 0;
	END;

	SAIRVAK_DATA = SUM(hsaiprva, haiprva, hwmky, htkapr);
	TTURVA_DATA = SUM(MAX(vvvmk1, 0), MAX(vvvmk2, 0),MAX(vvvmk3, 0),MAX(vvvmk4, 0),MAX(vvvmk5, 0),
					MAX(0, SUM(dtyhtep, mtlisa, korosapks, korosapkw)), MAX(SUM(yhtez, korosazkg, korosazkf), 0),
				    MAX(ptmk, 0), MAX(SUM(tmtukimk, korosatkg, korosatkf), 0));

	%IF &TTURVA_KOR = 1 %THEN %DO;
		TTURVA_DATA = SUM(MAX(AILMKOR1DAT, 0), MAX(vvvmk3, 0), MAX(AILMKOR5DAT, 0),
						MAX(SUM(dtyhtep, korosapks), 0), MAX(yhtez, 0), MAX(ptmk, 0), MAX(tmtukimk, 0));
	%END;

	MUU_TTURVA_DATA = SUM(MAX(tkoultuk, 0), -MAX(vvvmk4, 0),-MAX(ptmk, 0)); 
	OPTUKI_DATA = tkopira;
	KANSEL_DATA = SUM(tkansel, tperhel, takuuel);

	/* Vero�yrien korjaaminen oikeaan muotoon */
	KAYRI_KORJ = IFN(KAYRI > 0 OR LKIVE > 0, KAYRI / 10000, 0);

	/* Vertailutiedoksi aluksi dataan perustuva tieto verottomista osingoista */
	OSINKOVAP_DATA = SUM(tnoosvvb, teinovvb, tuosvvap, topkvvap, teinovv);
	OSINKOA_DATA = SUM(teinova , tpeito);
	OSINKOP_DATA = SUM(tnoosvab, tenosve, tuosvv, topkver);

	/* Puolison p��ttely� */
	PSOT = IFN(csivs = 2, 1, 0);
	IF PSOTX = 3 AND asko = 1 THEN VEROPUOL = 1;
	ELSE IF PSOTX = 3 AND asko = 2 THEN VEROPUOL = 2;
	ELSE IF PSOTX = . OR asko > 2 THEN VEROPUOL = 0;
	EIKIRK = IFN(KAYRI = 0, 1, 0);

	/* Er�iden tuloerien summia */
	ULKPALKKA = MAX(SUM(tulkp, -tulkp6), 0);
	PALKKA1 = SUM(trpl, trplkor, anstukor, ulkpalkka, tmpt, tkust, tepalk, tmeri, tlue2, tpalv, trespa, tpturva, tlue3);
	MUU_TYO = SUM(tpalv2, telps1, telps2, telps5, ttyoltuk);
	YRITYSTA = SUM(tmaat1, tmaat1p, tpjta, tliik1, tliikp, tporo1, tyhtat, tyhthav, yrtukor);
	TYOTULOA = SUM(palkka1, muu_tyo, yritysta);
	YRITYSTP = SUM(tmaat2, tmaat2p, tliik2, tliik2p, tporo2, tyhtpot, tmetsp, tmetspp, tvaksp);
	VAKPALK = SUM(MAX(trpl-toptio, 0), tmpt, tmeri, tlue2);
	MUUT_EL = MAX(SUM(tansel, ttapel, tpotel, teanstu, tmuuel, tulkel, ttyoel, mamutuki),0);
	MUU_ANSIO = SUM(tlakko, tpalv2a, tmuut, tomlis, telvpal, tmluoko, tsuurpu, MUU_TTURVA_DATA);
	THANKK = SUM(vthmu, vthm3, vthm4);
	MUU_VAH_VALT2 = SUM(vmuut1, vmuutv, vmtyotv, MAX(SUM(vevm, -lelvak),0));
	MUU_VAH_KUNN2 = SUM(vmuut1, vmuutk, vmtyotk, ftapakk ,  MAX(SUM(vevm, -lelvak),0));
	POTAPP = SUM(ftapot, ftappm, ftapep, ftappmp, ftapepp, ftyhmt);
	IF svatva > 0 THEN ULK_OSUUS = tulkya2 / svatva; ELSE ULK_OSUUS = 0;
	VUOKRAT = SUM(tvuokr, tvuokr1);
	MUU_PO = SUM(tpalv2p, tjvkork, tmuukor, tjmark, tvlkorp, tvtkorp, tmuutp, tsiraho, 
				MAX(SUM(tmyynt, tmyynt1, -fluotap),0), tvahevas, tptmuu, MAX(SUM(tulkyhp, -tuosvv),0),
					tvahep50, tptvs, tvahep20, tptsu50);

	IF TYOTULOA > 0 AND YRITYSTA > 0.9 * TYOTULOA THEN YRITTAJA = 1; ELSE YRITTAJA = 0;

	PO_VAHENN = SUM(vthm2, POTAPP, vkortu, vmetsa, vohvah);

	/* El�ketulov�hennyksen puolisoita koskevan siirtym�kauden tarkistus, ei toimi aineistovuoden 2009 j�lkeen! */
	IF &AVUOSI < 2009 THEN DO;
		%KunnElTulVah&F (ELTULVAH_K1, &AVUOSI, 1, 1 , 0 , lelake, svatkp, 0)
		ELVAHKORJ = IFN (PSOT = 1 AND velakk - ELTULVAH_K1 > 50, 1, 0);
	END;
	ELSE ELVAHKORJ = 0;

	/* Kotitalousv�hennykset ja datan verot */
	KOTITVAH_MYONN = SUM(vkotita, vkotitku, vkotitsv, vkotitki, vkotitp);
	KAIKKIVEROT_DATA = SUM(lelvak, lpvma, ltva, ltvp, lkuve, lkive, lshma);

	/* 3.4 Luodaan uusille apumuuttujille selkokieliset kuvaukset */

	LABEL 	
	PSOT = 'Puoliso (0/1), DATA'
	PSOTX = 'Puolisotunniste, DATA'
	KUUK53 = 'Ik��n liittyv� apumuuttuja, DATA'
	EIKIRK = 'Ei kuulu kirkkoon (0/1), DATA'
	KAYRI_KORJ = 'Kirkollisvero�yri prosentteina (korjattu muoto), DATA'
	VEROPUOL = 'Puoliso verotuksessa, DATA'
	YRITTAJA = 'Yritt�jyyteen liittyv� apumuuttuja, DATA'

	SAIRVAK_DATA = 'Sairausvakuutuslain mukaiset p�iv�rahat yhteens�, DATA'
	TTURVA_DATA = 'Ty�tt�myysturva ja koulutustuki, DATA'
	MUU_TTURVA_DATA = 'Ei-simuloidut ty�tt�myysturvaetuudet, DATA' 
	OPTUKI_DATA = 'Opintotuki, DATA'
	KANSEL_DATA = 'Kansanel�ke (ml. KE:n perhe-el�ke ja takuuel�ke), DATA'
	OSINKOVAP_DATA = 'Verovapaat osingot, DATA'
	OSINKOA_DATA = 'Osingot ansiotulona, DATA'
	OSINKOP_DATA = 'Osingot p��omatulona, DATA'
				
	ULKPALKKA = 'Ulkomaan palkat, DATA'
	PALKKA1 = 'Palkkatulot, DATA'
	MUU_TYO = 'Muut ty�tulot, DATA'
	YRITYSTA = 'Yritystulot ansiotuloina, DATA'	
	TYOTULOA = 'Ansiotulot, DATA'
	YRITYSTP = 'Yritt�j�tulot p��omatuloina, DATA'
	VAKPALK = 'Vakuutuspalkka, DATA'
	MUUT_EL = 'Muut el�kkeet, DATA'
	MUU_ANSIO = 'Muut ansiotulot, DATA'
	THANKK = 'Ulkomaantulon kuluv�hennys ja tulonhankkimiskulut muista kuin ty�- ja palkkatuloista, DATA'
	MUU_VAH_VALT2 = 'Muita v�h. valtionverotuksessa, DATA'
	MUU_VAH_KUNN2 = 'Muita v�h. kunnallisverotuksessa, DATA'
	POTAPP = 'P��omatulon tappiot, DATA'
	ULK_OSUUS = 'Ulkomaan palkkatulojen osuus ansiotuloista, DATA'
	VUOKRAT = 'Vuokratulot, DATA'
	MUU_PO = 'Muut p��omatulot, DATA'
	PO_VAHENN = 'V�hennykset p��omatuloista, DATA'

	ELTULVAH_K1 = 'Kunnallisverotuksen el�ketulov�hennys, ensimm�inen laskelma, MALLI'
	ELVAHKORJ = 'El�ketulov�hennyksen siirtym�kauden tarkastus, MALLI'

	KOTITVAH_MYONN = 'My�nnetyt kotitalousv�hennykset, DATA'
	KAIKKIVEROT_DATA = 'Kaikki verot, DATA';

	RUN;

%END;

%MEND Vero_Muutt_Poiminta;

%Vero_Muutt_Poiminta;

%LET alkoi2&malli = %SYSFUNC(TIME());

/* 4. Makro hakee tietoja muista osamalleista ja liitt�� ne mallin dataan */

%MACRO OsaMallit_Vero;

%IF &SAIRVAK = 1 OR &TTURVA = 1 OR &KOTIHTUKI = 1 OR &KANSEL = 1 OR &OPINTUKI = 1 %THEN %DO;

	/* 4.1 Sairausvakuutus */
	
	%IF &SAIRVAK = 1 %THEN %DO;
	
		DATA STARTDAT.START_VERO; 
		UPDATE STARTDAT.START_VERO (IN = C) OUTPUT.&TULOSNIMI_SV (KEEP = hnro knro SAIRPR VANHPR ERITHOITR)
		UPDATEMODE=NOMISSINGCHECK;
		BY hnro;
		IF C;
		RUN;

	%END;

	/* 4.2 Ty�tt�myysturva */

	%IF &TTURVA = 1 %THEN %DO;

		DATA STARTDAT.START_VERO;
		UPDATE STARTDAT.START_VERO (IN = C) OUTPUT.&TULOSNIMI_TT 
		(KEEP = hnro knro YHTTMTUKI TMTUKILMKOR KOTOUTUKI KTTUKILMKOR KOULPTUKI PERILMAKOR
       		PERUSPR ANSIOPR ANSIOILMKOR VUORKORV AKTIIVAPR AKTIILMKOR)
		UPDATEMODE=NOMISSINGCHECK;
		BY hnro;
		IF C;
		RUN;

	%END;

	/* 4.3 Kansanel�ke */

	%IF &KANSEL = 1 %THEN %DO;

		DATA STARTDAT.START_VERO;
		UPDATE STARTDAT.START_VERO (IN = C) OUTPUT.&TULOSNIMI_KE (KEEP = hnro TAKUUELA KANSANELAKE LAPSENELAKE LESKENELAKE)
		UPDATEMODE=NOMISSINGCHECK;
		BY hnro;
		IF C;
		RUN;

	%END;

	/* 4.4 Kotihoidontuki */

	%IF &KOTIHTUKI = 1 %THEN %DO;

		DATA STARTDAT.START_VERO;
		UPDATE STARTDAT.START_VERO (IN = C) OUTPUT.&TULOSNIMI_KT (KEEP = hnro KOTIHTUKI OSHOIT)
		UPDATEMODE=NOMISSINGCHECK;
		BY hnro;
		IF C;
		RUN;

	%END;

	/* 4.5 Opintotuki */

	%IF &OPINTUKI = 1 %THEN %DO;

		DATA STARTDAT.START_VERO;
		UPDATE STARTDAT.START_VERO (IN = C) OUTPUT.&TULOSNIMI_OT (KEEP = hnro TUKIKESK TUKIKOR)
		UPDATEMODE=NOMISSINGCHECK;
		BY hnro;
		IF C;
		RUN;

	%END;

%END;

%MEND OsaMallit_Vero;

%OsaMallit_Vero;


/* 5. VERO-mallissa (vuositason lains��d�nt�) parametrit luetaan makromuuttujiksi ennen simulontia */

%HaeParam_VeroSIMUL(&LVUOSI, &INF);

/* N�m� m��rittelyt ja makro tuottavat kertoimet
   keskim��r�isen kunnallis- ja kirkollisveroprosentin muunnoskertoimen laskemiseksi
   Muista p�ivitt�� t�m� mallivuoden mukaiseksi! */

%MACRO Vero_Ayrit;

%IF &LVUOSI < 2011 %THEN %DO;
	%KunnVerKerroin(2011, &LVUOSI);
%END;

%IF &LVUOSI > 2013 %THEN %DO;
	%KunnVerKerroin(2013, &LVUOSI);
%END;

%ELSE %DO;
	%LET kunnkerroin = 1;
	%LET kirkkerroin = 1;
%END;

%MEND Vero_Ayrit;

%Vero_Ayrit;

/* 6. Simulointivaihe */


%MACRO Vero_Simuloi_Data;

DATA OUTPUT.&TULOSNIMI_VE;
SET STARTDAT.START_VERO;

	/* Haetaan tarvittaessa muiden osamallien tulostauluista tietoja */
	%IF &SAIRVAK = 0 %THEN %DO; SAIRVAK_SIMUL = SAIRVAK_DATA;%END;
		%ELSE %DO; SAIRVAK_SIMUL = SUM(SAIRPR, VANHPR, ERITHOITR);%END;

	%IF &TTURVA = 0 %THEN %DO; 
		TTURVA_SIMUL = TTURVA_DATA;
	%END;
	%ELSE %DO; 
		TTURVA_SIMUL = SUM(YHTTMTUKI, KOULPTUKI,  PERUSPR,  ANSIOPR, VUORKORV, AKTIIVAPR, KOTOUTUKI);

		%IF &TTURVA_KOR = 1 %THEN %DO;
			TTURVA_SIMUL = SUM(TMTUKILMKOR, KOULPTUKI,  PERILMAKOR,  ANSIOILMKOR, VUORKORV, AKTIILMKOR, KTTUKILMKOR);
		%END;
	%END;

	%IF &KANSEL = 0 %THEN %DO; KANSEL_SIMUL = KANSEL_DATA;%END;
		%ELSE %DO; KANSEL_SIMUL = SUM(TAKUUELA, KANSANELAKE, LAPSENELAKE, LESKENELAKE);%END;

	%IF &KOTIHTUKI = 0 %THEN %DO; KOTIHTUKI_SIMUL = tkotihtu;%END;
		%ELSE %DO; KOTIHTUKI_SIMUL = SUM(KOTIHTUKI, OSHOIT, ktku);%END;

	%IF &OPINTUKI = 0 %THEN %DO; OPTUKI_SIMUL = OPTUKI_DATA;%END;
		%ELSE %DO; OPTUKI_SIMUL = SUM(TUKIKESK, TUKIKOR);%END;

	PRAHAT = SUM(SAIRVAK_SIMUL, TTURVA_SIMUL, KOTIHTUKI_SIMUL, tvakpr, ttappr, tkuntra);
	ELAKE = SUM(KANSEL_SIMUL, MUUT_EL);

	/* Jaetaan osinkotulot eri kategoroihin: ansiotulot, p��omatulot, verottomat tulot */

	/* Ansiotulo-osingot */
	%OsinkojenJako&F(OSINKOA, &LVUOSI, 1, 0 , 3, 0, SUM(teinova, teinovv), 0) ;

	/* P��omatulo-osingot: 1 ulkomaan osingot ja listatut yhti�t, 2 osuusp��oman korot, 3 listaamaattomat yhti�t */
	%OsinkojenJako&F(OSINKOP1, &LVUOSI, 1, 0, 2, SUM(tnoosvab, tnoosvvb, tuosvvap, tuosvv), 0, 0);
	%OsinkojenJako&F(OSINKOP2, &LVUOSI, 1, 1, 2, topkb, 0, 0);
	%OsinkojenJako&F(OSINKOP3, &LVUOSI, 1, 0, 2, 0, SUM(teinovvb, tenosve), -1);

	/* Verottomat osingot: 1 ulkomaan osingot ja listatut yhti�t, 2 osuusp��oman korot, 3 listaamaattomat yhti�t (p��omatulo), 4 listaamattomat yhti�t (ansiotulo) */
	%OsinkojenJako&F(OSINKOVAP1, &LVUOSI, 1, 0, 1, SUM(tnoosvab, tnoosvvb, tuosvvap, tuosvv), 0, 0);
	%OsinkojenJako&F(OSINKOVAP2, &LVUOSI, 1, 1, 1, topkb, 0, 0);
	%OsinkojenJako&F(OSINKOVAP3, &LVUOSI, 1, 0 ,1, 0, SUM(tenosve, teinovvb), -1);
	%OsinkojenJako&F(OSINKOVAP4, &LVUOSI, 1, 0, 1, 0, SUM(teinovv, teinova), 0);

	OSINKOA = SUM(OSINKOA, tpeito);
	OSINKOP = SUM(OSINKOP1, OSINKOP2, OSINKOP3);
	OSINKOVAP = SUM(OSINKOVAP1, OSINKOVAP2, OSINKOVAP3,OSINKOVAP4);

	/* Yhti�veron hyvitys */
	%YhtHyv&F(YHTHYVP, &LVUOSI, OSINKOP);
	%YhtHyv&F(YHTHYVA, &LVUOSI, OSINKOA);

	/* Ansiotulot, p��omatulot, kokonaistulot */
	ANSIOT = SUM(PALKKA1 ,  MUU_TYO ,  YRITYSTA ,  ELAKE ,  PRAHAT ,  OPTUKI_SIMUL ,  MUU_ANSIO ,  OSINKOA, YHTHYVA);
	POTULOT = MAX(SUM(YRITYSTP ,  VUOKRAT ,  MUU_PO ,  OSINKOP,  YHTHYVP), 0);
	PUHD_PO = MAX(SUM(POTULOT, -vthm2, -tjmarkh, -vohvah), 0); 
	KOKONTULO = SUM(ANSIOT,  POTULOT);

	/* Palkansaajan ty�el�kemaksu ja ty�tt�myysvakuutusmaksu yhdistettyn� */
	IF VAKPALK > 0 THEN DO;
		%PalkVakMaksu&F(PALKVAK_53, &LVUOSI, 1, VKERROIN * KUUK53 * VAKPALK / 12);
		%PalkVakMaksu&F(PALKVAK_E53, &LVUOSI, 0, VKERROIN * (12 - KUUK53)* VAKPALK / 12);
		PALKVAK = SUM(PALKVAK_53,  PALKVAK_E53);
	END;
	ELSE PALKVAK = 0;

	/* Sairausvakuutuksen p�iv�rahamaksu, yritystulon korotettu maksu huomioon otettuna */
	IF PRAHAMAKSUTULO > 0 THEN DO;
		%SvPRahaMaksuY&F(PRAHAMAKSU, &LVUOSI, IFN(yrittaja = 1 AND soss > 20 AND soss < 30, 1, 0), PRAHAMAKSUTULO);
	END;
	ELSE PRAHAMAKSU = 0;

	/* Tulonhankkimisv�hennys, ty�matkakuluv�hennys, ay-j�senmaksujen v�hennys */
	%TulonHankKulut&F(THANKKULUT, &LVUOSI, &INF, SUM(PALKKA1, MUU_TYO, YRITYSTA), PALKKA1, SUM(vthm, vluothm), vtyomj, vmatk, tyot); 
	THANKKULUT2 = SUM(THANKKULUT, vtyasvv, THANKK);
	PUHD_ANSIO = MAX(SUM(ANSIOT, - THANKKULUT2), 0);

	/* Kunnallisveron el�ketulov�hennys */
	IF ELAKE > 0 THEN DO;
		%KunnElTulVah&F(ELTULVAH_K, &LVUOSI, &INF,  PSOT , ELVAHKORJ , ELAKE, PUHD_ANSIO, 0);
	END;
	ELSE ELTULVAH_K = 0;

	/* Kunnallisveron ansiotulov�hennys */
	IF SUM(PALKKA1, MUU_TYO, YRITYSTA, IFN(&LVUOSI > 2004, OSINKOA, 0)) > 0 THEN DO;
		%KunnAnsVah&F(ANSIOT_VAH, &LVUOSI, &INF, PUHD_ANSIO, SUM(ANSIOT, - ELAKE), SUM(PALKKA1, MUU_TYO, YRITYSTA, IFN(&LVUOSI > 2004, OSINKOA, 0)), PALKKA1, KOKONTULO);
	END;
	ELSE ANSIOT_VAH = 0;

	/* Kunnallisverotuksen opintorahav�hennys */
	IF OPTUKI_SIMUL > 0 THEN DO;
		%KunnOpRahVah&F(OPRAHVAH, &LVUOSI, &INF, 1, OPTUKI_SIMUL, ANSIOT, PUHD_ANSIO);
	END;
	ELSE OPRAHVAH = 0;

	/* Kunnallisverotuksen invalidiv�hennys */
	IF cinv > 0 OR ceinv > 0 THEN DO;
		%KunnVerInvVah&F(INVVAH_K, &LVUOSI, &INF, IFN(ceinv > 0, 1, 0), IFN(ceinv > cinv, ceinv, cinv), PUHD_ANSIO, ELAKE);
	END;
	ELSE INVVAH_K = 0;

	/* Valtioverotuksen el�ketulov�hennys */
	IF elake > 0 THEN DO;
		%ValtElTulVah&F(ELTULVAH_V, &LVUOSI, &INF, ELAKE, PUHD_ANSIO, KOKONTULO);
	END;
	ELSE ELTULVAH_V = 0;

	KUNNVTULO1 = MAX(SUM(ANSIOT, -PALKVAK, -PRAHAMAKSU, -THANKKULUT2, -ELTULVAH_K, -ANSIOT_VAH, -OPRAHVAH, -INVVAH_K, -MUU_VAH_KUNN2), 0);

	/* Kunnallisverotuksen perusv�hennys */
	IF KUNNVTULO1 > 0 THEN DO;
		%KunnPerVah&F(PERVAH, &LVUOSI, &INF, KUNNVTULO1);
	END;
	ELSE PERVAH = 0;

	/* Kunnallis- ja kirkollisveroja */
	KUNNVTULO2 = MAX(SUM(kunnvtulo1, - pervah), 0);
	KUNNVEROA = &kunnkerroin * 0.01 * AYRI * KUNNVTULO2 / 100;
	KIRKVEROA = &kirkkerroin * KAYRI_KORJ * KUNNVTULO2;

	/* K��nteinen p��ttely sairausvakuutusmaksuihin */ 
	IF &TARKPVM = 1 AND YRITTAJA = 1 THEN DO;
		PUHD_ANSIOSV = SUM(PUHD_ANSIO - YRITYSTA,  PRAHAMAKSUTULO);
		/* Kunnallisverotuksen el�ketulov�hennys */
		%KunnElTulVah&F (ELTULVAH_KSV, &LVUOSI, &INF,  PSOT, ELVAHKORJ, ELAKE, PUHD_ANSIOSV, 0)
		/* Kunnallisveron ansiotulov�hennys */
		%KunnAnsVah&F(ANSIOT_VAHSV, &LVUOSI, &INF, PUHD_ANSIOSV, SUM(ANSIOT, -ELAKE), PRAHAMAKSUTULO, PALKKA1, KOKONTULO);
		/* Kunnallisverotuksen opintorahav�hennys */
		%KunnOpRahVah&F(OPRAHVAHSV, &LVUOSI, &INF, 1, OPTUKI_SIMUL, ANSIOT, PUHD_ANSIOSV);
		/* Kunnallisverotuksen invalidiv�hennys */
		%KunnVerInvVah&F(INVVAH_KSV, &LVUOSI, &INF, IFN(ceinv > 0, 1, 0), IFN(ceinv > cinv, ceinv, cinv), PUHD_ANSIOSV, ELAKE);
		KUNNVTULO1SV = MAX(SUM(ANSIOT, - YRITYSTA, PRAHAMAKSUTULO, - PALKVAK, - PRAHAMAKSU, - THANKKULUT2, - ELTULVAH_KSV, -ANSIOT_VAHSV, -OPRAHVAHSV, -INVVAH_KSV, -MUU_VAH_KUNN2), 0);
		/* Kunnallisverotuksen perusv�hennys */
		%KunnPerVah&F(PERVAHSV, &LVUOSI, &INF, KUNNVTULO1SV);
		KUNNVTULO2SV = MAX(SUM(KUNNVTULO1SV, -PERVAHSV), 0);
		/* Sairausvakuutusmaksu */
		%SairVakMaksu&F(SAIRVAKA, &LVUOSI, &INF, KUNNVTULO2SV, ELAKE, PRAHAMAKSUTULO);
	END;
	ELSE DO;
		/* Sairausvakuutusmaksu, kun ei tehd� k��nteist� p��ttely� */
		IF KUNNVTULO2 > 0 THEN DO;	
			%SairVakMaksu&F(SAIRVAKA, &LVUOSI, &INF, KUNNVTULO2, ELAKE, PRAHAMAKSUTULO);
		END;
	ELSE SAIRVAKA = 0;
	END;

	/* Kansanel�kevakuutusmaksu */
	IF MAX(SUM(KUNNVTULO2, - TULK), 0) > 0 THEN DO;
		
		%KansElVakMaksu&F(KEVA, &LVUOSI, MAX(SUM(KUNNVTULO2, - TULK), 0), ELAKE);
	END;
	ELSE KEVA = 0;

	IF cvakm = 1 THEN SAIRVAKA = 0;

	VALTVERTULO = MAX(SUM(ANSIOT, -PALKVAK, -PRAHAMAKSU, -THANKKULUT2, -ELTULVAH_V, -MUU_VAH_VALT2), 0);

	/* Valtion tulovero */
	IF VALTVERTULO > 0 THEN DO;
		%ValtTuloVero&F(VALTVEROA, &LVUOSI, &INF, VALTVERTULO);
	END;
	ELSE VALTVEROA = 0;

	/* Vuonna 2013 otettiin k�ytt��n el�ketulon lis�veron. Se lis�t��n valtion tuloveroon. */

	IF ELAKE > 0 THEN DO;
		%ElakeLisaVero&F(ELAKELISAVERO, &LVUOSI, &INF, ELAKE, ELTULVAH_V);
	END;

	VALTVEROA = SUM(VALTVEROA, ELAKELISAVERO);

	/* Valtionverotuksen ansiotulov�hennys/ty�tulov�hennys */
	IF SUM(PALKKA1, MUU_TYO, YRITYSTA, IFN(&LVUOSI > 2004, OSINKOA, 0)) > 0 THEN DO;
		%ValtVerAnsVah&F(VALTANSVAH, &LVUOSI, &INF, SUM(PALKKA1, MUU_TYO, YRITYSTA, IFN(&LVUOSI > 2004, OSINKOA, 0)), PUHD_ANSIO);
	END;
	ELSE VALTANSVAH = 0;

	/* Valtionverotuksen invalidiv�hennys */
	IF cinv > 0 THEN DO;
		%ValtVerInvVah&F(INVVAH_V, &LVUOSI, &INF, cinv, ELAKE);
	END;
	ELSE INVVAH_V = 0;

	/* Valtionverotuksen elatusvelvollisuusv�hennys */
	IF lapsiev > 0 THEN DO;
		%ValtVerElVelvVah&F(ELVELV_VAH, &LVUOSI, &INF, lapsiev, velatk);
	END;
	ELSE ELVELV_VAH = 0;

	/*Jos lains��d�nt�vuosi >= 2012 jaetaan vkoras-muuttuja opintolainan korkoihin
	ja asuntokorkoihin. Ei t�ysin virheet�nt�, koska muuttujat eiv�t aina kohdistu samoihin
	henkil�ihin.
	Lis�ksi erotellaan my�s ensiasunnon koroista v�hennyskelpoinen osuus*/

	IF &LVUOSI > 2011 THEN DO;
		%VahAsKorot&F(ASKOROT, &LVUOSI, MAX(vkoras - oplaikor, 0))
		ASKOROT1 = MAX(vkoras - oplaikor, 0);
		%VahAsKorot&F(ENSASKOROT, &LVUOSI, vkorep);
		MUU_VAH = PO_VAHENN + oplaikor;
	END;
	ELSE DO;
		ASKOROT = vkoras;
		ASKOROT1 = vkoras;
		MUU_VAH = PO_VAHENN;
		ENSASKOROT = vkorep;
	END;

	/* P��omatulon vero, vapaaeht. el�kevakuutusmaksut huomioon otettuna */

	%POTulonveroErit&F(POVEROA, &LVUOSI, &INF, OSINKOP, SUM(POTULOT, -OSINKOP), SUM(MUU_VAH, ASKOROT, ENSASKOROT), 0, vvevah);
	IF SUM(MUU_VAH, ASKOROT, ENSASKOROT) > 0 THEN DO;
		%AlijHyv&F(ALIJHYV, &LVUOSI, &INF, 0, cllkm, POTULOT, MUU_VAH, ASKOROT1, vkorep, 0,0);
	END;
	ELSE ALIJHYV = 0;
	
	/* Erityinen alij��m�hyvitys */
	IF SUM( PO_VAHENN, vkoras, vkorep, vvevah) > 0 THEN DO;
		%AlijHyvErit&F(ALIJHYVERIT, &LVUOSI, &INF, POTULOT, MUU_VAH, ASKOROT1, vkorep, vvevah);
	END;
	ELSE ALIJHYVERIT = 0;

		/* Kotitalousv�hennys */
	IF KOTITVAH_MYONN > 0 THEN DO;
		%KotiTalVah&F(KOTITVAHMAX, &LVUOSI, &INF, 100000);
		KOTITVAH = MIN(KOTITVAH_MYONN, KOTITVAHMAX);
	END;
	ELSE KOTITVAH = 0;

	/* Ennen vuotta 2009 valtionverotuksen ansiotulov�hennys v�hennet��n valtion tuloverosta ja yli menev� osuus otetaan huomioon 
	ennankonpid�tyksen� (lopullisten verojen v�hennyksen�). Vuodesta 2009 l�htien v�hennys v�hennet��n ensi sijasta valtion 
	tuloverosta ja yli menev� osuus v�hennet��n muista veroista niiden suhteessa (ei p��omatulon verosta).
	V�hennyksen jakamiseen k�ytet��n samaa kaavaa kuin kotitalousv�hennyksen jakamiseen */

	IF &LVUOSI < 2009 THEN DO;
		VALTVEROB = MAX(SUM(VALTVEROA, - VALTANSVAH), 0);
		ANVAHYLIJ = MAX(SUM(VALTANSVAH, - VALTVEROA), 0);
		KUNNVEROB = KUNNVEROA;
		SAIRVAKB = SAIRVAKA;
		KEVB = KEVA;
		KIRKVEROB = KIRKVEROA;
	END;

	/* V�hennykset verolajeittain */

	ELSE DO;
		/* Ansio- / ty�tulov�hennys */
		IF VALTANSVAH > 0 THEN DO;
		    %VahennJako&F(VALTVEROB, &LVUOSI, VALTANSVAH, 1, VALTVEROA, KUNNVEROA, SAIRVAKA, KEVA, KIRKVEROA, 0); /* valt. ans. vero */
			%VahennJako&F(KUNNVEROB, &LVUOSI, VALTANSVAH, 2, VALTVEROA, KUNNVEROA, SAIRVAKA, KEVA, KIRKVEROA, 0); /* kunnallisvero */
			%VahennJako&F(SAIRVAKB, &LVUOSI, VALTANSVAH, 3, VALTVEROA, KUNNVEROA, SAIRVAKA, KEVA, KIRKVEROA, 0); /* svak-maksu */
			%VahennJako&F(KEVB, &LVUOSI, VALTANSVAH, 4, VALTVEROA, KUNNVEROA, SAIRVAKA, KEVA, KIRKVEROA, 0); /* kev-maksu */
			%VahennJako&F(KIRKVEROB, &LVUOSI, VALTANSVAH, 5, VALTVEROA, KUNNVEROA, SAIRVAKA, KEVA, KIRKVEROA, 0); /* kirkollisvero */
		END;
		ELSE DO;
			VALTVEROB = VALTVEROA;
			KUNNVEROB = KUNNVEROA;
			SAIRVAKB = SAIRVAKA;
			KEVB = KEVA;
			KIRKVEROB = KIRKVEROA;
		END;
		ANVAHYLIJ = 0;
	END;

	IF VEROPUOL = 0 THEN DO;
		VALTVEROC = MAX(VALTVEROB - INVVAH_V - ELVELV_VAH, 0);

		/* Kotitalousv�hennys */
		IF KOTITVAH > 0 THEN DO;
			%VahennJako&F(VALTVEROD, &LVUOSI, KOTITVAH, 1, VALTVEROC, KUNNVEROB, SAIRVAKB, KEVB, KIRKVEROB, POVEROA); /* valt. ans. vero */
			%VahennJako&F(KUNNVEROC, &LVUOSI, KOTITVAH, 2, VALTVEROC, KUNNVEROB, SAIRVAKB, KEVB, KIRKVEROB, POVEROA); /* kunnallisvero */
			%VahennJako&F(SAIRVAKC, &LVUOSI, KOTITVAH, 3, VALTVEROC, KUNNVEROB, SAIRVAKB, KEVB, KIRKVEROB, POVEROA); /* svak-maksu */
			%VahennJako&F(KEVC, &LVUOSI, KOTITVAH, 4, VALTVEROC, KUNNVEROB, SAIRVAKB, KEVB, KIRKVEROB, POVEROA); /* kev-maksu */
			%VahennJako&F(KIRKVEROC, &LVUOSI, KOTITVAH, 5, VALTVEROC, KUNNVEROB, SAIRVAKB, KEVB, KIRKVEROB, POVEROA); /* kirkollisvero */
			%VahennJako&F(POVEROB, &LVUOSI, KOTITVAH, 6, VALTVEROC, KUNNVEROB, SAIRVAKB, KEVB, KIRKVEROB, POVEROA); /* p��omatulo */
		END;
		ELSE DO;
			VALTVEROD = VALTVEROC;
			KUNNVEROC = KUNNVEROB;
			SAIRVAKC = SAIRVAKB;
			KEVC = KEVB;
			KIRKVEROC = KIRKVEROB;
			POVEROB = POVEROA;
		END;
		IF ALIJHYV > 0 THEN DO;
		/* alij��m�hyvityksen jako */
			%AlijHyvJako&F(VALTVEROE, &LVUOSI, 1, ALIJHYV, VALTVEROD, KUNNVEROC, SAIRVAKC, KEVC, KIRKVEROC); /* valt. ans. vero */
			%AlijHyvJako&F(KUNNVEROD, &LVUOSI, 2, ALIJHYV, VALTVEROD, KUNNVEROC, SAIRVAKC, KEVC, KIRKVEROC); /* kunnallisvero */
			%AlijHyvJako&F(SAIRVAKD, &LVUOSI, 3, ALIJHYV, VALTVEROD, KUNNVEROC, SAIRVAKC, KEVC, KIRKVEROC); /* svak-maksu */
			%AlijHyvJako&F(KEVD, &LVUOSI, 4, ALIJHYV, VALTVEROD, KUNNVEROC, SAIRVAKC, KEVC, KIRKVEROC); /* kev-maksu */
			%AlijHyvJako&F(KIRKVEROD, &LVUOSI, 5, ALIJHYV, VALTVEROD, KUNNVEROC, SAIRVAKC, KEVC, KIRKVEROC); /* kirkollisvero */
		END;
		ELSE DO;
			VALTVEROE = VALTVEROD;
			KUNNVEROD = KUNNVEROC;
			SAIRVAKD = SAIRVAKC;
			KEVD = KEVC;
			KIRKVEROD = KIRKVEROC;
		END;
		/* Erityisen alij��m�hyvityksen jako */
		IF ALIJHYVERIT > 0 THEN DO;
			%VahennJako&F(VALTVEROF, &LVUOSI, ALIJHYVERIT, 1, VALTVEROE, KUNNVEROD, SAIRVAKD, KEVD, KIRKVEROD, 0); /* valt. ans. vero */
			%VahennJako&F(KUNNVEROE, &LVUOSI, ALIJHYVERIT, 2, VALTVEROE, KUNNVEROD, SAIRVAKD, KEVD, KIRKVEROD, 0); /* kunnallisvero */
			%VahennJako&F(SAIRVAKE, &LVUOSI, ALIJHYVERIT, 3, VALTVEROE, KUNNVEROD, SAIRVAKD, KEVD, KIRKVEROD, 0); /* svak-maksu */
			%VahennJako&F(KEVE, &LVUOSI, ALIJHYVERIT, 4, VALTVEROE, KUNNVEROD, SAIRVAKD, KEVD, KIRKVEROD, 0); /* kev-maksu */
			%VahennJako&F(KIRKVEROE, &LVUOSI, ALIJHYVERIT, 5, VALTVEROE, KUNNVEROD, SAIRVAKD, KEVD, KIRKVEROD, 0); /* kirkollisvero */
		END;
		ELSE DO;
			/* Summat v�hennysten j�lkeen */
			VALTVEROF = VALTVEROE;
			KUNNVEROE = KUNNVEROD;
			SAIRVAKE = SAIRVAKD;
			KEVE = KEVD;
			KIRKVEROE = KIRKVEROD;
		END;
	END;

	IF VEROPUOL = 1 OR VEROPUOL = 2 THEN DO;
		IF  asko = 1 THEN DO;
			INVVAH_V1 = INVVAH_V;
			ELVELV_VAH1 = ELVELV_VAH;
			KOTITVAH1 = KOTITVAH;	
			ALIJHYV1 = ALIJHYV;
			ALIJHYVERIT1 = ALIJHYVERIT;
			VALTVEROB1 = VALTVEROB;
			KUNNVEROB1 = KUNNVEROB;
			SAIRVAKB1 = SAIRVAKB;
			KEVB1 = KEVB;
			KIRKVEROB1 = KIRKVEROB;
			POVEROA1 = POVEROA;
		END;

		IF ASKO = 2 THEN DO;
			INVVAH_V2 = INVVAH_V;
			ELVELV_VAH2 = ELVELV_VAH;
			KOTITVAH2 = KOTITVAH;	
			ALIJHYV2 = ALIJHYV;
			ALIJHYVERIT2 = ALIJHYVERIT;
			VALTVEROB2 = VALTVEROB;
			KUNNVEROB2 = KUNNVEROB;
			SAIRVAKB2 = SAIRVAKB;
			KEVB2 = KEVB;
			KIRKVEROB2 = KIRKVEROB;
			POVEROA2 = POVEROA;
		END;
	END;

	/* T�ss� kohtaa pudotetaan pois sellaiset apumuuttujat, joita ei jatkossa tarvita */
	DROP 	PSOTX KUUK53 KAYRI_KORJ EIKIRK YRITTAJA
			VAHLAPSIA ALIJENIMM ELAKELISAVERO;
	RUN;
	
	/* Puolisoiden tietoja, aputaulu */

	DATA TEMP.VERO_PUOLISOT;
	SET OUTPUT.&TULOSNIMI_VE (keep = hnro knro VEROPUOL
		INVVAH_V1 ELVELV_VAH1 KOTITVAH1 ALIJHYV1 ALIJHYVERIT1 VALTVEROB1 VALTVEROB1 
		KUNNVEROB1 SAIRVAKB1 KEVB1 KIRKVEROB1 POVEROA1 INVVAH_V2 ELVELV_VAH2 KOTITVAH2 
		ALIJHYV2 ALIJHYVERIT2 VALTVEROB2 VALTVEROB2 KUNNVEROB2 SAIRVAKB2 KEVB2 KIRKVEROB2 POVEROA2); 
	IF VEROPUOL = 1 OR VEROPUOL = 2;
	RUN;

	PROC MEANS DATA = TEMP.VERO_PUOLISOT SUM NOPRINT;
	VAR INVVAH_V1 ELVELV_VAH1 KOTITVAH1 ALIJHYV1 ALIJHYVERIT1 VALTVEROB1 KUNNVEROB1 SAIRVAKB1 KEVB1 KIRKVEROB1 POVEROA1 INVVAH_V2 
		ELVELV_VAH2 KOTITVAH2 ALIJHYV2 ALIJHYVERIT2 VALTVEROB2 KUNNVEROB2 SAIRVAKB2 KEVB2 KIRKVEROB2 POVEROA2;
	BY KNRO;
	OUTPUT OUT = TEMP.VERO_PUOLISOT_SUM
	SUM(INVVAH_V1 )=INVVAH_V1 SUM(ELVELV_VAH1 )=ELVELV_VAH1 SUM(KOTITVAH1 )=KOTITVAH1 SUM(ALIJHYV1 )=ALIJHYV1 SUM(ALIJHYVERIT1 )=ALIJHYVERIT1 
	SUM(VALTVEROB1 )=VALTVEROB1 SUM(KUNNVEROB1 )=KUNNVEROB1 SUM(SAIRVAKB1 )=SAIRVAKB1 SUM(KEVB1)=KEVB1 SUM(KIRKVEROB1 )=KIRKVEROB1 
	SUM(POVEROA1)=POVEROA1 SUM(INVVAH_V2)=INVVAH_V2 SUM(ELVELV_VAH2)=ELVELV_VAH2 SUM(KOTITVAH2)=KOTITVAH2 SUM(ALIJHYV2)=ALIJHYV2 
	SUM(ALIJHYVERIT2)=ALIJHYVERIT2 SUM(VALTVEROB2)=VALTVEROB2 SUM(KUNNVEROB2)=KUNNVEROB2 SUM(SAIRVAKB2)=SAIRVAKB2 SUM(KEVB2)=KEVB2 
	SUM(KIRKVEROB2)=KIRKVEROB2 SUM(POVEROA2)=POVEROA2;
	RUN;

	/* Puolisoiden v�hennysten lajittelu, kuten henkil�ill� */

	DATA TEMP.VERO_PUOLISOT_SUM;
	SET TEMP.VERO_PUOLISOT_SUM;

	%VahennysSwap(INVVAH_V, VALTVEROB);
	VALTVEROC1 = MAX(SUM(VALTVEROB1, -INVVAH_V1FINAL, -ELVELV_VAH1), 0);
	VALTVEROC2 = MAX(SUM(VALTVEROB2, -INVVAH_V2FINAL, -ELVELV_VAH2), 0);
	VEROTYHT1 = SUM(VALTVEROC1 ,  KUNNVEROB1 ,  SAIRVAKB1 ,  KEVB1 ,  KIRKVEROB1 ,  POVEROA1);
	VEROTYHT2 = SUM(VALTVEROC2 ,  KUNNVEROB2 ,  SAIRVAKB2 ,  KEVB2 ,  KIRKVEROB2 ,  POVEROA2);
	%VahennysSwap(KOTITVAH, VEROTYHT);

	IF KOTITVAH1FINAL > 0 THEN DO;
		%VahennJako&F(VALTVEROD1, &LVUOSI, KOTITVAH1FINAL, 1, VALTVEROC1, KUNNVEROB1, SAIRVAKB1, KEVB1, KIRKVEROB1, POVEROA1);
		%VahennJako&F(KUNNVEROC1, &LVUOSI, KOTITVAH1FINAL, 2, VALTVEROC1, KUNNVEROB1, SAIRVAKB1, KEVB1, KIRKVEROB1, POVEROA1);
		%VahennJako&F(SAIRVAKC1, &LVUOSI, KOTITVAH1FINAL, 3, VALTVEROC1, KUNNVEROB1, SAIRVAKB1, KEVB1, KIRKVEROB1, POVEROA1);
		%VahennJako&F(KEVC1, &LVUOSI, KOTITVAH1FINAL, 4, VALTVEROC1, KUNNVEROB1, SAIRVAKB1, KEVB1, KIRKVEROB1, POVEROA1);
		%VahennJako&F(KIRKVEROC1, &LVUOSI, KOTITVAH1FINAL, 5, VALTVEROC1, KUNNVEROB1, SAIRVAKB1, KEVB1, KIRKVEROB1, POVEROA1);
		%VahennJako&F(POVEROB1, &LVUOSI, KOTITVAH1FINAL, 6, VALTVEROC1, KUNNVEROB1, SAIRVAKB1, KEVB1, KIRKVEROB1, POVEROA1);
	END;
	ELSE DO;
		VALTVEROD1 = VALTVEROC1;
		KUNNVEROC1 = KUNNVEROB1;
		SAIRVAKC1 = SAIRVAKB1;
		KEVC1 = KEVB1;
		KIRKVEROC1 = KIRKVEROB1;
		POVEROB1 = POVEROA1;
	END;

	IF KOTITVAH2FINAL > 0 THEN DO;
		%VahennJako&F(VALTVEROD2, &LVUOSI, KOTITVAH2FINAL, 1, VALTVEROC2, KUNNVEROB2, SAIRVAKB2, KEVB2, KIRKVEROB2, POVEROA2);
		%VahennJako&F(KUNNVEROC2, &LVUOSI, KOTITVAH2FINAL, 2, VALTVEROC2, KUNNVEROB2, SAIRVAKB2, KEVB2, KIRKVEROB2, POVEROA2);
		%VahennJako&F(SAIRVAKC2, &LVUOSI, KOTITVAH2FINAL, 3, VALTVEROC2, KUNNVEROB2, SAIRVAKB2, KEVB2, KIRKVEROB2, POVEROA2);
		%VahennJako&F(KEVC2, &LVUOSI, KOTITVAH2FINAL, 4, VALTVEROC2, KUNNVEROB2, SAIRVAKB2, KEVB2, KIRKVEROB2, POVEROA2);
		%VahennJako&F(KIRKVEROC2, &LVUOSI, KOTITVAH2FINAL, 5, VALTVEROC2, KUNNVEROB2, SAIRVAKB2, KEVB2, KIRKVEROB2, POVEROA2);
		%VahennJako&F(POVEROB2, &LVUOSI, KOTITVAH2FINAL, 6, VALTVEROC2, KUNNVEROB2, SAIRVAKB2, KEVB2, KIRKVEROB2, POVEROA2);
	END;
	ELSE DO;
		VALTVEROD2 = VALTVEROC2;
		KUNNVEROC2 = KUNNVEROB2;
		SAIRVAKC2 = SAIRVAKB2;
		KEVC2 = KEVB2;
		KIRKVEROC2 = KIRKVEROB2;
		POVEROB2 = POVEROA2;
	END;

	VEROTYHT1 = SUM(VALTVEROD1, KUNNVEROC1, SAIRVAKC1, KEVC1, KIRKVEROC1);
	VEROTYHT2 = SUM(VALTVEROD2, KUNNVEROC2, SAIRVAKC2, KEVC2, KIRKVEROC2);
	%VahennysSwap(ALIJHYV, VEROTYHT);

	IF ALIJHYV1FINAL > 0 THEN DO;
		%AlijHyvJako&F(VALTVEROE1, &LVUOSI, 1, ALIJHYV1FINAL, VALTVEROD1, KUNNVEROC1, SAIRVAKC1, KEVC1, KIRKVEROC1);
		%AlijHyvJako&F(KUNNVEROD1, &LVUOSI, 2, ALIJHYV1FINAL, VALTVEROD1, KUNNVEROC1, SAIRVAKC1, KEVC1, KIRKVEROC1);
		%AlijHyvJako&F(SAIRVAKD1, &LVUOSI, 3, ALIJHYV1FINAL, VALTVEROD1, KUNNVEROC1, SAIRVAKC1, KEVC1, KIRKVEROC1);
		%AlijHyvJako&F(KEVD1, &LVUOSI, 4, ALIJHYV1FINAL, VALTVEROD1, KUNNVEROC1, SAIRVAKC1, KEVC1, KIRKVEROC1);
		%AlijHyvJako&F(KIRKVEROD1, &LVUOSI, 5, ALIJHYV1FINAL, VALTVEROD1, KUNNVEROC1, SAIRVAKC1, KEVC1, KIRKVEROC1);
	END;
	ELSE DO;
		VALTVEROE1 = VALTVEROD1;
		KUNNVEROD1 = KUNNVEROC1;
		SAIRVAKD1 = SAIRVAKC1;
		KEVD1 = KEVC1;
		KIRKVEROD1 = KIRKVEROC1;
	END;

	IF ALIJHYV2FINAL > 0 THEN DO;
		%AlijHyvJako&F(VALTVEROE2, &LVUOSI, 1, ALIJHYV2FINAL, VALTVEROD2, KUNNVEROC2, SAIRVAKC2, KEVC2, KIRKVEROC2);
		%AlijHyvJako&F(KUNNVEROD2, &LVUOSI, 2, ALIJHYV2FINAL, VALTVEROD2, KUNNVEROC2, SAIRVAKC2, KEVC2, KIRKVEROC2);
		%AlijHyvJako&F(SAIRVAKD2, &LVUOSI, 3, ALIJHYV2FINAL, VALTVEROD2, KUNNVEROC2, SAIRVAKC2, KEVC2, KIRKVEROC2);
		%AlijHyvJako&F(KEVD2, &LVUOSI, 4, ALIJHYV2FINAL, VALTVEROD2, KUNNVEROC2, SAIRVAKC2, KEVC2, KIRKVEROC2);
		%AlijHyvJako&F(KIRKVEROD2, &LVUOSI, 5, ALIJHYV2FINAL, VALTVEROD2, KUNNVEROC2, SAIRVAKC2, KEVC2, KIRKVEROC2);
	END;
	ELSE DO;
		VALTVEROE2 = VALTVEROD2;
		KUNNVEROD2 = KUNNVEROC2;
		SAIRVAKD2 = SAIRVAKC2;
		KEVD2 = KEVC2;
		KIRKVEROD2 = KIRKVEROC2;
	END;

	VEROTYHT1 = SUM(VALTVEROE1, KUNNVEROD1, SAIRVAKD1, KEVD1, KIRKVEROD1);
	VEROTYHT2 = SUM(VALTVEROE2, KUNNVEROD2, SAIRVAKD2, KEVD2, KIRKVEROD2);
	%VahennysSwap(ALIJHYVERIT, VEROTYHT);

	IF ALIJHYVERIT1FINAL > 0 THEN DO;
		%VahennJako&F(VALTVEROF1, &LVUOSI, ALIJHYVERIT1FINAL, 1, VALTVEROE1, KUNNVEROD1, SAIRVAKD1, KEVD1, KIRKVEROD1, 0);
		%VahennJako&F(KUNNVEROE1, &LVUOSI, ALIJHYVERIT1FINAL, 2, VALTVEROE1, KUNNVEROD1, SAIRVAKD1, KEVD1, KIRKVEROD1, 0);
		%VahennJako&F(SAIRVAKE1, &LVUOSI, ALIJHYVERIT1FINAL, 3, VALTVEROE1, KUNNVEROD1, SAIRVAKD1, KEVD1, KIRKVEROD1, 0);
		%VahennJako&F(KEVE1, &LVUOSI, ALIJHYVERIT1FINAL, 4, VALTVEROE1, KUNNVEROD1, SAIRVAKD1, KEVD1, KIRKVEROD1, 0);
		%VahennJako&F(KIRKVEROE1, &LVUOSI, ALIJHYVERIT1FINAL, 5, VALTVEROE1, KUNNVEROD1, SAIRVAKD1, KEVD1, KIRKVEROD1, 0);
	END;
	ELSE DO;
		VALTVEROF1 = VALTVEROE1;
		KUNNVEROE1 = KUNNVEROD1;
		SAIRVAKE1 = SAIRVAKD1;
		KEVE1 = KEVD1;
		KIRKVEROE1 = KIRKVEROD1;
	END;

	IF  ALIJHYVERIT2FINAL > 0 THEN DO;
		%VahennJako&F(VALTVEROF2, &LVUOSI, ALIJHYVERIT2FINAL, 1, VALTVEROE2, KUNNVEROD2, SAIRVAKD2, KEVD2, KIRKVEROD2, 0);
		%VahennJako&F(KUNNVEROE2, &LVUOSI, ALIJHYVERIT2FINAL, 2, VALTVEROE2, KUNNVEROD2, SAIRVAKD2, KEVD2, KIRKVEROD2, 0);
		%VahennJako&F(SAIRVAKE2, &LVUOSI, ALIJHYVERIT2FINAL, 3, VALTVEROE2, KUNNVEROD2, SAIRVAKD2, KEVD2, KIRKVEROD2, 0);
		%VahennJako&F(KEVE2, &LVUOSI, ALIJHYVERIT2FINAL, 4, VALTVEROE2, KUNNVEROD2, SAIRVAKD2, KEVD2, KIRKVEROD2, 0);
		%VahennJako&F(KIRKVEROE2, &LVUOSI, ALIJHYVERIT2FINAL, 5, VALTVEROE2, KUNNVEROD2, SAIRVAKD2, KEVD2, KIRKVEROD2, 0);
	END;
	ELSE DO;
		VALTVEROF2 = VALTVEROE2;
		KUNNVEROE2 = KUNNVEROD2;
		SAIRVAKE2 = SAIRVAKD2;
		KEVE2 = KEVD2;
		KIRKVEROE2 = KIRKVEROD2;
	END;

	RUN;

	DATA OUTPUT.&TULOSNIMI_VE;
	MERGE OUTPUT.&TULOSNIMI_VE TEMP.VERO_PUOLISOT_SUM (KEEP = knro
	VALTVEROF1 KUNNVEROE1 SAIRVAKE1 KEVE1 KIRKVEROE1 POVEROB1
	VALTVEROF2 KUNNVEROE2 SAIRVAKE2 KEVE2 KIRKVEROE2 POVEROB2
	INVVAH_V1FINAL INVVAH_V2FINAL ALIJHYVERIT1FINAL ALIJHYVERIT2FINAL
	ALIJHYV1FINAL ALIJHYV2FINAL KOTITVAH1FINAL KOTITVAH2FINAL);
	BY knro;

	IF VEROPUOL = 1 THEN DO;
		VALTVEROF = VALTVEROF1;
		KUNNVEROE = KUNNVEROE1;
		SAIRVAKE = SAIRVAKE1;
		KEVE = KEVE1;
		KIRKVEROE = KIRKVEROE1;
		POVEROB = POVEROB1;
		INVVAH_V = INVVAH_V1FINAL;
		ALIJHYV= ALIJHYV1FINAL;
		ALIJHYVERIT= ALIJHYVERIT1FINAL;
		KOTITVAH = KOTITVAH1FINAL;
	END;

	IF VEROPUOL = 2 THEN DO;
		VALTVEROF = VALTVEROF2;
		KUNNVEROE = KUNNVEROE2;
		SAIRVAKE = SAIRVAKE2;
		KEVE = KEVE2;
		KIRKVEROE = KIRKVEROE2;
		POVEROB = POVEROB2;
		INVVAH_V = INVVAH_V2FINAL;
		ALIJHYV= ALIJHYV2FINAL;
		ALIJHYVERIT= ALIJHYVERIT2FINAL;
		KOTITVAH = KOTITVAH2FINAL;
	END;

	DROP VALTVEROF1 KUNNVEROE1 SAIRVAKE1 KEVE1 KIRKVEROE1 POVEROB1;
	DROP VALTVEROF2 KUNNVEROE2 SAIRVAKE2 KEVE2 KIRKVEROE2 POVEROB2;

	/* Yle-vero */

	%YleVeroS(YLEVERO, &LVUOSI, &INF, ikavu, SUM(PUHD_ANSIO, PUHD_PO), maakunta); 

	YHTHYV = SUM(YHTHYVA, YHTHYVP);
	VALTVEROF = (1 - ULK_OSUUS)* VALTVEROF;
	KUNNVEROE = (1 - ULK_OSUUS)* KUNNVEROE;
	KIRKVEROE = (1 - ULK_OSUUS)* KIRKVEROE;
	ULKVAH = IFN(ULK_OSUUS = 0, lveru, 0);
	MAKSP_VEROT = SUM(PRAHAMAKSU,  MAX(SUM(VALTVEROF, POVEROB, KUNNVEROE, SAIRVAKE, KEVE, KIRKVEROE, - ULKVAH), 0));
	KAIKKIVEROT = SUM(PALKVAK, MAKSP_VEROT, - ANVAHYLIJ, -YHTHYV, YLEVERO);
	ANSIOVEROT = SUM(VALTVEROF, KUNNVEROE, SAIRVAKE, KEVE, KIRKVEROE, -ANVAHYLIJ);

	KEEP hnro OSINKOP1 OSINKOP2 OSINKOP3 OSINKOVAP1 OSINKOVAP2 OSINKOVAP3 OSINKOVAP4
		 PRAHAT OSINKOP OSINKOA OSINKOVAP PSOT ULKPALKKA ULKVAH
		 PALKKA1 MUU_TYO YRITYSTA YRITYSTP VAKPALK MUUT_EL MUU_ANSIO MUU_PO VUOKRAT
		 THANKK MUU_VAH_VALT2 MUU_VAH_KUNN2 POTAPP ULK_OSUUS PALKVAK_E53 PALKVAK_53
		 OPTUKI_SIMUL SAIRVAK_SIMUL KOTIHTUKI_SIMUL TTURVA_SIMUL KANSEL_SIMUL ELAKE
		 PRAHAMAKSUTULO VKERROIN ANSIOT POTULOT KOKONTULO THANKKULUT2 PO_VAHENN 
		 PUHD_ANSIO PUHD_PO ELTULVAH_K1 ELVAHKORJ KOTITVAH_MYONN ANSIOT_VAH ELTULVAH_K
		 ELTULVAH_V OPRAHVAH INVVAH_K PALKVAK PRAHAMAKSU KUNNVTULO1 PERVAH
		 KUNNVTULO2 KUNNVEROA KUNNVEROB KUNNVEROC KUNNVEROD KUNNVEROE 
		 KIRKVEROA KIRKVEROB KIRKVEROC KIRKVEROD KIRKVEROE SAIRVAKA SAIRVAKB
		 SAIRVAKC SAIRVAKD SAIRVAKE KEVA KEVB KEVC KEVD KEVE VALTVERTULO YHTHYVA YHTHYVP YHTHYV
		 VALTVEROA VALTVEROB VALTVEROC VALTVEROD VALTVEROE VALTVEROF VALTANSVAH
		 INVVAH_V ELVELV_VAH POVEROA POVEROB ALIJHYV ALIJHYVERIT KOTITVAHMAX 
		 KOTITVAH ANSIOVEROT KAIKKIVEROT KAIKKIVEROT_DATA MAKSP_VEROT YLEVERO 
		 ASKOROT ASKOROT1 ENSASKOROT MUU_VAH;

	RUN;

	/* 6.2 Yhdistet��n simuloitu data palveluaineistoon (riippuen tulosaineiston laajuden valinnasta) */


	DATA OUTPUT.&TULOSNIMI_VE;

	/* 6.2.1 Suppea tulostiedosto (vain t�rkeimm�t luokittelumuuttujat) */

	%IF &TULOSLAAJ = 1 %THEN %DO;
		MERGE POHJADAT.&AINEISTO&AVUOSI 
		(KEEP = hnro knro &PAINO ltva ltvp lkuve lkive lshma lelvak lpvma verot svatvap svatpp ikavu ikavuV soss paasoss desmod koulas elivtu rake)
		OUTPUT.&TULOSNIMI_VE;
	%END;

	/* 6.2.2 Laaja tulostiedosto (palveluaineiston mukainen tulostiedosto) */

	%IF &TULOSLAAJ = 2 %THEN %DO;
		MERGE POHJADAT.&AINEISTO&AVUOSI OUTPUT.&TULOSNIMI_VE;
	%END;

	BY hnro;

	/* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukum��r�t voidaan laskea suoraan */

	ARRAY PISTE 
		 ltva ltvp lkuve lkive lshma lelvak lpvma verot svatvap svatpp
		 OSINKOP1 OSINKOP2 OSINKOP3 OSINKOVAP1 OSINKOVAP2 OSINKOVAP3 OSINKOVAP4
		 PRAHAT OSINKOP OSINKOA OSINKOVAP PSOT ULKPALKKA ULKVAH
		 PALKKA1 MUU_TYO YRITYSTA YRITYSTP VAKPALK MUUT_EL MUU_ANSIO MUU_PO VUOKRAT
		 THANKK MUU_VAH_VALT2 MUU_VAH_KUNN2 POTAPP ULK_OSUUS PALKVAK_E53 PALKVAK_53
		 OPTUKI_SIMUL SAIRVAK_SIMUL KOTIHTUKI_SIMUL TTURVA_SIMUL KANSEL_SIMUL ELAKE
		 PRAHAMAKSUTULO VKERROIN ANSIOT POTULOT KOKONTULO THANKKULUT2 PO_VAHENN 
		 PUHD_ANSIO PUHD_PO ELTULVAH_K1 ELVAHKORJ KOTITVAH_MYONN ANSIOT_VAH ELTULVAH_K
		 ELTULVAH_V OPRAHVAH INVVAH_K PALKVAK PRAHAMAKSU KUNNVTULO1 PERVAH
		 KUNNVTULO2 KUNNVEROA KUNNVEROB KUNNVEROC KUNNVEROD KUNNVEROE 
		 KIRKVEROA KIRKVEROB KIRKVEROC KIRKVEROD KIRKVEROE SAIRVAKA SAIRVAKB
		 SAIRVAKC SAIRVAKD SAIRVAKE KEVA KEVB KEVC KEVD KEVE VALTVERTULO YHTHYVA YHTHYVP YHTHYV
		 VALTVEROA VALTVEROB VALTVEROC VALTVEROD VALTVEROE VALTVEROF VALTANSVAH
		 INVVAH_V ELVELV_VAH POVEROA POVEROB ALIJHYV ALIJHYVERIT KOTITVAHMAX 
		 KOTITVAH ULKVAH ANSIOVEROT KAIKKIVEROT KAIKKIVEROT_DATA MAKSP_VEROT YLEVERO
		 ASKOROT ASKOROT1 ENSASKOROT MUU_VAH;
	DO OVER PISTE;
		IF PISTE <= 0 THEN PISTE = .;
	END;

	/* Luodaan simuloiduille ja datan muuttujille selitteet */

	LABEL
	PRAHAT = 'Sosiaaliturvan p�iv�rahat yhteens�, MALLI'
	SAIRVAK_SIMUL = 'Sairausvakuutuslain mukaiset p�iv�rahat yhteens�, MALLI'
	KOTIHTUKI_SIMUL = 'Lasten kotihoidon tuki, MALLI'
	OPTUKI_SIMUL = 'Opintorahat, MALLI'
	TTURVA_SIMUL = 'Ty�tt�myysturva ja koulutustuki, MALLI'
	KANSEL_SIMUL = 'Kansanel�ke (ml. KE:n perhe-el�ke), MALLI'
	ELAKE = 'El�ketulot yhteens�, MALLI'
	OSINKOP = 'P��omatulo-osingot yhteens�, MALLI'
	OSINKOP1 = 'P��omatulo-osingot: ulkomaan osingot ja julkisesti noteeratut osakkeet, MALLI'
	OSINKOP2 = 'P��omatulo-osingot: osuusp��oman korot, MALLI'
	OSINKOP3 = 'P��omatulo-osingot: henkil�yhti�t, MALLI'
	OSINKOA = 'Ansiotulo-osingot, MALLI'
	OSINKOVAP = 'Verottomat osingot yhteens�, MALLI'
	OSINKOVAP1 = 'Verottomat osingot yhteens�: ulkomaan osingot ja listatut yhti�t, MALLI'
	OSINKOVAP2 = 'Verottomat osingot yhteens�: osuusp��oman korko, MALLI'
	OSINKOVAP3 = 'Verottomat osingot yhteens�: listaamaattomat yhti�t (p��omatulo), MALLI'
	OSINKOVAP4 = 'Verottomat osingot yhteens�: listaamattomat yhti�t (ansiotulo), MALLI'
	ANSIOT = 'Ansiotulot yhteens�, MALLI'
	POTULOT = 'P��omatulot yhteens�, MALLI'
	KOKONTULO = 'Kokonaistulot, MALLI'
	THANKKULUT2 = 'Tulonhankkimiskulut, MALLI'
	PUHD_ANSIO = 'Puhdas ansiotulo, MALLI'
	svatvap = 'Puhdas ansiotulo, DATA'
	PUHD_PO = 'Puhdas p��omatulo, MALLI'
	svatpp = 'Puhdas p��omatulo, DATA'
	ANSIOT_VAH = 'Kunnallisverotuksen ansiotulov�hennys, MALLI'
	ELTULVAH_K = 'Kunnallisverotuksen el�ketulov�hennys, MALLI'
	ELTULVAH_V = 'El�ketulov�hennys valtionverotuksessa, MALLI'
	OPRAHVAH = 'Opintorahav�hennys, MALLI'
	INVVAH_K = 'Kunnallisverotuksen invalidiv�hennys, MALLI'
	PALKVAK_E53 = 'Palkansaajan vakuutusmaksut, ei 53 vuotta t�ytt�nyt, MALLI'
	PALKVAK_53 = 'Palkansaajan vakuutusmaksut, 53 vuotta t�ytt�nyt, MALLI'
	PALKVAK = 'Palkansaajan el�ke- ja ty�tt�myysvakuutusmaksu, MALLI'
	lelvak = 'Palkansaajan el�ke- ja ty�tt�myysvakuutusmaksu, DATA'
	PRAHAMAKSU = 'Sairausvakuutuksen p�iv�rahamaksu, MALLI'
	lpvma = 'Sairausvakuutuksen p�iv�rahamaksu, DATA'
	KUNNVTULO1 = 'Kunnallisverotuksessa verotettava tulo ennen perusv�hennyst�, MALLI'
	PERVAH = 'Kunnallisverotuksen perusv�hennys, MALLI'
	KUNNVTULO2 = 'Kunnallisverotuksessa verotettava tulo perusv�hennyksen j�lkeen, MALLI'
	KUNNVEROA = 'Kunnallisvero vaihe 1, ennen v�hennyksi�, MALLI'
	KUNNVEROB = 'Kunnallisvero vaihe 2, ty�/ansiotulov�h, MALLI'
	KUNNVEROC = 'Kunnallisvero vaihe 3, kotit.v�h, MALLI'
	KUNNVEROD = 'Kunnallisvero vaihe 4, alij.hyvit, MALLI'
	KUNNVEROE = 'Kunnallisverot, MALLI'
	lkuve = 'Kunnallisverot, DATA'
	KIRKVEROA = 'Kirkollisvero vaihe 1, ennen v�hennyksi�, MALLI'
	KIRKVEROB = 'Kirkollisvero vaihe 2, ty�/ansiotulov�h, MALLI'
	KIRKVEROC = 'Kirkollisvero vaihe 3, kotit.v�h, MALLI'
	KIRKVEROD = 'Kirkollisvero vaihe 4, alij.hyvit, MALLI'
	KIRKVEROE = 'Kirkollisverot, MALLI'
	lkive = 'Kirkollisverot, DATA'
	SAIRVAKA = 'Sairaanhoitomaksu vaihe 1 ennen v�hennyksi�, MALLI'
	SAIRVAKB = 'Sairaanhoitomaksu vaihe 2 ty�/ansiotulov�h, MALLI'
	SAIRVAKC = 'Sairaanhoitomaksu vaihe 3 kotit.v�h, MALLI'
	SAIRVAKD = 'Sairaanhoitomaksu vaihe 4, alij.hyvit, MALLI'
	SAIRVAKE = 'Sairaanhoitomaksut, MALLI'
	lshma = 'Sairaanhoitomaksut, DATA'
	KEVA = 'Kansanel�kevakuutusmaksu vaihe 1 ennen v�hennyksi�, MALLI'
	KEVB = 'Kansanel�kevakuutusmaksu vaihe 2 ty�/ansiotulov�h, MALLI'
	KEVC = 'Kansanel�kevakuutusmaksu vaihe 3 kotit.v�h, MALLI'
	KEVD = 'Kansanel�kevakuutusmaksu vaihe 4, alij.hyvit, MALLI'
	KEVE = 'Kansanel�kevakuutusmaksut, MALLI'
	VALTVERTULO = 'Valtionverotuksessa verotettava tulo, MALLI'
	YHTHYVA = 'Yhti�veron hyvitys ansiotuloa, MALLI'
	YHTHYVP = 'Yhti�veron hyvitys p��omatuloa, MALLI'
	YHTHYV = 'Yhti�veron hyvitys yhteens�, MALLI'
	VALTVEROA = 'Valtion tulovero 1. vaihe, ennen v�hennyksi�, MALLI'
	VALTVEROB = 'Valtion tulovero 2. vaihe, ty�/ansiotulov�h, MALLI'
	VALTVEROC = 'Valtion tulovero 3. vaihe, kotit.v�h, MALLI'
	VALTVEROD = 'Valtion tulovero 4. vaihe, alij.hyvit, MALLI'
	VALTVEROE = 'Valtion tulovero 5. vaihe, erit.alij.hyvit, MALLI'
	VALTVEROF = 'Valtion tuloverot, MALLI'
	ltva = 'Valtion tuloverot, DATA'
	VALTANSVAH = 'Valtionverotuksen ansiotulov�hennys, MALLI'
	INVVAH_V = 'Valtionverotuksen invalidiv�hennys, MALLI'
	ELVELV_VAH = 'Valtionverotuksen elatusvelvollisuusv�hennys, MALLI'
	POVEROA = 'P��omatulon vero, 1. vaihe ennen v�hennyksi�, MALLI'
	POVEROB = 'P��omatulon verot, MALLI'
	ltvp = 'P��omatulon verot, DATA'
	ASKOROT = 'Asuntolainan korot, v�hennyskelpoinen osuus, MALLI'
	ASKOROT1 = 'Asuntolainan korot, ilman opintolainan korkoja 2012-, MALLI'
	ENSASKOROT = 'Ensiasuntoon kohdistuvan asuntolainan korot, v�hennyskelpoinen osuus, MALLI'
	MUU_VAH = 'Muut v�hennykset p��omatuloista, MALLI'
	ALIJHYV = 'Alij��m�hyvitys, MALLI'
	ALIJHYVERIT = 'Erityinen alij��m�hyvitys, MALLI'
	KOTITVAHMAX = 'Suurin mahdollinen kotitalousv�hennys, MALLI'
	KOTITVAH = 'Kotitalousv�hennys, MALLI'
	ULKVAH = 'Ulkomaan verojen v�hennys'
	ANSIOVEROT = 'Ansiotulon verot yhteens� (sis. sairaanhoitomaksut ja kansanel�kevakuutusmaksut), MALLI'
	YLEVERO = 'Yle-vero, MALLI'
	KAIKKIVEROT_DATA = 'Kaikki verot ja maksut yhteens� (pl. Yle-vero), DATA'
	KAIKKIVEROT = 'Kaikki verot ja maksut yhteens� (ml. Yle-vero), MALLI'
	verot = 'Maksuunpannut verot, DATA' 
	MAKSP_VEROT = 'Maksuunpannut verot, MALLI' ;

RUN;

%MEND;

%Vero_Simuloi_data;

%LET loppui2&malli = %SYSFUNC(TIME());


/* 7. Luodaan summatason tulostaulukot (optio) */ 

%MACRO Vero_Tulokset;

/* 7.1 Kotitaloustason tulokset (optio) */

/* 7.1.1 Mikrotason tulosaineiston summaus kotitaloustasolle (optio) */

%IF &YKSIKKO = 2 AND &START NE 1 %THEN %DO; 

	PROC SUMMARY DATA=OUTPUT.&TULOSNIMI_VE (DROP = hnro);
	BY knro ;
	ID &PAINO ikavuV desmod paasoss elivtu koulas rake;
	VAR &MUUTTUJAT _NUMERIC_;
	OUTPUT OUT = OUTPUT.&TULOSNIMI_VE (DROP = soss ikavu _TYPE_ _FREQ_)  SUM = ;
	RUN;

%END;

/* 7.1.2 Summatason tulostaulukko (optio) */

%IF &TULOKSET = 1 %THEN %DO;

	%IF &YKSIKKO = 2 %THEN %DO; 

		/* Siirret��n tiedot Exceliin (optio) */

		%IF &EXCEL = 1 %THEN %DO;

			ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_VE._SUMMAT.xls" STYLE = MINIMAL;

		%END;

		PROC MEANS DATA=OUTPUT.&TULOSNIMI_VE &SUMWGT &SUM &MIN &MAX &RANGE &MEAN &MEDIAN &MODE &STD &VAR &CV NONOBS ORDER=DATA NWAY MAXDEC = 0; 
		TITLE "TUNNUSLUVUT (KOTITALOUSTASO), &MALLI";
		CLASS &LUOK_KOTI1 &LUOK_KOTI2 &LUOK_KOTI3 / MLF PRELOADFMT;
		VAR &MUUTTUJAT ;
		FORMAT _NUMERIC_ tuhat. ;
		%DO I = 1 %TO 3; 
		%IF %LENGTH (&&LUOK_KOTI&I) >0 %THEN %DO;
			FORMAT &&LUOK_KOTI&I &&LUOK_KOTI&I... ;
		%END;%END;
		OUTPUT OUT = OUTPUT.&TULOSNIMI_VE._SUMMAT (DROP = _TYPE_ _FREQ_)
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

			ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_VE._SUMMAT.xls" STYLE = MINIMAL;

		%END;

		PROC MEANS DATA=OUTPUT.&TULOSNIMI_VE &SUMWGT &SUM &MIN &MAX &RANGE &MEAN &MEDIAN &MODE &STD &VAR &CV NONOBS ORDER=DATA NWAY MAXDEC = 0;
		TITLE "TUNNUSLUVUT (HENKIL�TASO), &MALLI";
		CLASS &LUOK_HLO1 &LUOK_HLO2 &LUOK_HLO3 / MLF PRELOADFMT;
		VAR &MUUTTUJAT ;
		FORMAT _NUMERIC_ tuhat. ;
		%DO I = 1 %TO 3; 
		%IF %LENGTH (&&LUOK_HLO&I) >0 %THEN %DO;
			FORMAT &&LUOK_HLO&I &&LUOK_HLO&I... ;
		%END;%END;
		OUTPUT OUT = OUTPUT.&TULOSNIMI_VE._SUMMAT (DROP = _TYPE_ _FREQ_)
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


%MEND Vero_Tulokset;

%Vero_Tulokset;


/* 8. Mitataan kuinka kauan osavaiheisiin kului aikaa */

%LET loppui1 = %SYSFUNC(TIME());

%LET loppui1&malli = %SYSFUNC(TIME());

%LET kului1&malli = %SYSEVALF(&&loppui1&malli - &&alkoi1&malli);

%LET kului2&malli = %SYSEVALF(&&loppui2&malli - &&alkoi2&malli);

%LET kului1&malli = %SYSFUNC(PUTN(&&kului1&malli, time10.2));

%LET kului2&malli = %SYSFUNC(PUTN(&&kului2&malli, time10.2));


%PUT &malli. Koko laskenta. Aikaa kului (hh:mm:ss.00) &&kului1&malli;

%PUT &malli. Varsinainen simulointi. Aikaa kului (hh:mm:ss.00) &&kului2&malli;







