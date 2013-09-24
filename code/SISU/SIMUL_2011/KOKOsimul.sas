/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hy�dynt�� Tilastokeskuksen yleisten
* k�ytt�ehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto p��hakemistossa.
******************************************************************************/

/****************************************************
* KOKO-mallin simulointiohjelma 2011                *
* Tekij�: Pertti Honkanen / KELA                    *
* Luotu: 31.08.2011				       				*
* Viimeksi p�ivitetty: 26.8.2013		     			*
* P�ivitt�j�: Olli Kannas / TK		                *
*****************************************************/

/******************************************************************************************************************/

/* 0. Yleisi� vakioiden m��rittelyj� (�l� muuta n�it�!) */

%LET MALLI = KOKO;

%LET alkoi1KOKO = %SYSFUNC(TIME());

* Antamalla OUT-makromuuttujalle arvo 1, varmistetaan, ett� osamallit ottavat ohjausparametrit t�st� KOKO-mallista. 
  Asetetaan &TULOKSET_KOKO arvoon 0, jotta osamallien summataulukoita ei luotaisi. 
  Asetetaan &TULOSLAAJ-makromuuttuja arvoon 1, jotta osamallien tulostaulukoiden koko olisi mahd. pieni ;	 

%LET OUT = 1;
%LET TULOSLAAJ = 1;
%LET TULOKSET_KOKO = 0;	

* Osamallien simuloitujen tulostiedostojen nimet (n�m� poistetaan simuloinnin lopuksi);

%LET TULOSNIMI_SV = SV_TULOS;
%LET TULOSNIMI_KT = KT_TULOS;
%LET TULOSNIMI_TT = TT_TULOS;
%LET TULOSNIMI_LL = LL_TULOS;
%LET TULOSNIMI_TO = TO_TULOS;
%LET TULOSNIMI_KE = KE_TULOS;
%LET TULOSNIMI_VE = VE_TULOS;
%LET TULOSNIMI_KV = KV_TULOS;
%LET TULOSNIMI_YA = YA_TULOS;
%LET TULOSNIMI_EA = EA_TULOS;
%LET TULOSNIMI_OT = OT_TULOS;
%LET TULOSNIMI_PH = PH_TULOS;

/******************************************************************************************************************/

/* 1. Mallia ohjaavat makromuuttujat */

%MACRO Aloitus;

/* Jos mallia k�ytet��n k�ytt�liittym�st� (&EG = 1), niin seuraavia vaiheita ei ajeta */

%IF &EG NE 1 %THEN %DO;

%LET AVUOSI = 2011;		* Aineistovuosi (vvvv);

%LET LVUOSI = 2013;		* Lains��d�nt�vuosi (vvvv);

%LET TYYPPI_KOKO = SIMUL;	* Parametrien hakutyyppi: SIMUL (vuosikeskiarvo) tai SIMULX (parametrit haetaan tietylle kuukaudelle);

%LET LKUUK = 12;         * Lains��d�nt�kuukausi, jos parametrit haetaan tietylle kuukaudelle;

%LET AINEISTO = PALV ;  * K�ytett�v� aineisto (PALV = Palveluaineisto, REK = Rekisteriaineisto) ;

%LET TULOSNIMI_KOKO = koko_simul_&SYSDATE._3 ; * Simuloidun tulostiedoston nimi ;

* Inflaatiokorjaus. Parametrien deflatoinnissa k�ytett�v�n kertoimen voi sy�tt�� itse
  INF-makromuuttujaan (HUOM! desimaalit erotettava pisteell� .). Jos puolestaan haluaa k�ytt�� automaattista 
  elinkustannusindeksiin perustuvaa parametrien muunnoskerrointa, 
  tulee INF-makromuuttujalle antaa arvoksi 999 ; 	

%LET INF = 1.00; * Sy�t� arvo tai 999 ;
%LET PINDEKSI_VUOSI = pindeksi_vuosi; *K�ytett�v� indeksien parametritaulukko;

/* KOKO-mallissa ajettavat osavaiheet */

%LET KOKOpoiminta = 1; 		* Muuttujien poiminta (1 jos ajetaan, 0 jos ei) ;
%LET KOKOsummat = 1;		* Summataulukot (1 jos ajetaan, 0 jos ei) ;
%LET KOKOindikaattorit = 1; * Tulonjakoindikaattorit (1 jos ajetaan, 0 jos ei) ;

/* Ajettavien osamallien valinta.
   Jos osamalli ajetaan, niin sit� seuraavissa malleissa k�ytet��n kyseisen mallin simuloituja tietoja. 
   Jos osamallia ei ajeta, niin sit� seuraavissa malleissa k�ytet��n kyseisen mallin osalta datassa olevia tietoja.
   Mallit ajetaan alla olevassa j�rjestyksess�.  

   RAJOITUKSET: 
   1) Jos joku tai jotkut malleista (SAIRVAK, TTURVA, KANSEL, KOTIHTUKI tai OPINTUKI) 
	  ajetaan, niin my�s VERO-malli on ajettava.
   2) ELASUMTUKI-malli pit�� ajaa aina, jos ASUMTUKI-malli ajetaan. 
   3) KIVERO-malli ajetaan vain, jos &AVUOSI = 2011. 	
*/

* Jos arvo = 1, niin malli ajetaan, jos 0, niin mallia ei ajeta ja k�ytet��n datan tietoja. ;

%LET SAIRVAK = 1;
%LET TTURVA = 1;
%LET KOTIHTUKI = 1;
%LET KANSEL = 1;
%LET OPINTUKI = 1;
%LET VERO = 1;
%LET KIVERO = 0;
%LET LLISA = 1; 
%LET ELASUMTUKI = 1; 
%LET ASUMTUKI = 1;
%LET PHOITO = 1;
%LET TOIMTUKI = 0; 

/* Osamallien ohjausparametreja */

%LET POIMINTA = 1;   	* Muuttujien poiminta osamalleissa (1 jos ajetaan, 0 jos ei). HUOM! APUMUUTTUJIA EI SAA LUODA JOS PARAMETREJA ON MUUTETTU;
%LET APUMAKROT = 1;  	* Apumakro-ohjelmien ajo osamalleissa (1 jos ajetaan, 0 jos ei);
%LET LAKIMAKROT = 1;	* Lakimakro-ohjelmien ajo osamalleissa (1 jos ajetaan, 0 jos ei) ;

%LET KDATATULO = 0; 	* K�ytet��nk� KANSEL-mallissa datan tulotietoja = 1 vai laskennallisia tulotietoja = 0 ;
%LET SDATATULO = 0;  	* K�ytet��nk� SAIRVAK-mallissa datan tulotietoja = 1 vai laskennallisia tulotietoja = 0; 
%LET TTDATATULO = 0;  	* K�ytet��nk� TTURVA-mallissa datan tulotietoja = 1 vai laskennallisia tulotietoja = 0 ;
%LET TARKPVM = 1;    	* Jos t�m�n arvo = 1, VERO-mallissa sairausvakuutuksen p�iv�rahamaksun
						  laskentaa tarkennetaan k��nteisell� p��ttelyll� ;
%LET YRIT = 0; 			* Simuloidaanko toimeentulotuki my�s yritt�j�talouksille (1 = Kyll�, 0 = Ei);
%LET YDINP = 1;			* Simuloidaanko el�kkeensaajien asumistuki my�s ns. ei-ydinperhe-el�kel�isille (1 = Kyll�, 0 = Ei);


* Osamallien simuloinnissa k�ytett�vien apu- ja lakimakrotiedostojen nimet ;

%LET LAKIMAK_TIED_OT = OPINTUKIlakimakrot;
%LET APUMAK_TIED_OT = OPINTUKIapumakrot;
%LET LAKIMAK_TIED_TT = TTURVAlakimakrot;
%LET APUMAK_TIED_TT = TTURVAapumakrot;
%LET LAKIMAK_TIED_SV = SAIRVAKlakimakrot;
%LET APUMAK_TIED_SV = SAIRVAKapumakrot;
%LET LAKIMAK_TIED_KT = KOTIHTUKIlakimakrot;
%LET APUMAK_TIED_KT = KOTIHTUKIapumakrot;
%LET LAKIMAK_TIED_LL = LLISAlakimakrot;
%LET APUMAK_TIED_LL = LLISAapumakrot;
%LET LAKIMAK_TIED_TO = TOIMTUKIlakimakrot;
%LET APUMAK_TIED_TO = TOIMTUKIapumakrot;
%LET LAKIMAK_TIED_KE = KANSELlakimakrot;
%LET APUMAK_TIED_KE = KANSELapumakrot;
%LET LAKIMAK_TIED_VE = VEROlakimakrot;
%LET APUMAK_TIED_VE = VEROapumakrot;
%LET LAKIMAK_TIED_KV = KIVEROlakimakrot;
%LET APUMAK_TIED_KV = KIVEROapumakrot;
%LET LAKIMAK_TIED_YA = ASUMTUKIlakimakrot;
%LET APUMAK_TIED_YA = ASUMTUKIapumakrot;
%LET LAKIMAK_TIED_EA = ELASUMTUKIlakimakrot;
%LET APUMAK_TIED_EA = ELASUMTUKIapumakrot;
%LET LAKIMAK_TIED_PH = KOTIHTUKIlakimakrot;
%LET APUMAK_TIED_PH = KOTIHTUKIapumakrot;

* Osamallien simuloinnissa k�ytett�vien simulointitiedostojen nimet ;

%LET SIMUL_TIED_OT = OPINTUKIsimul.sas;
%LET SIMUL_TIED_TT = TTURVAsimul.sas;
%LET SIMUL_TIED_SV = SAIRVAKsimul.sas;
%LET SIMUL_TIED_KT = KOTIHTUKIsimul.sas;
%LET SIMUL_TIED_LL = LLISAsimul.sas;
%LET SIMUL_TIED_TO = TOIMTUKIsimul.sas;
%LET SIMUL_TIED_KE = KANSELsimul.sas;
%LET SIMUL_TIED_VE = VEROsimul.sas;
%LET SIMUL_TIED_KV = KIVEROsimul.sas;
%LET SIMUL_TIED_YA = ASUMTUKIsimul.sas;
%LET SIMUL_TIED_EA = ELASUMTUKIsimul.sas;
%LET SIMUL_TIED_PH = PHOITOsimul.sas;

* Osamallien simuloinnissa k�ytett�vien parametritaulukoiden nimet ;

%LET POPINTUKI = popintuki;
%LET PTTURVA = ptturva;
%LET PSAIRVAK = psairvak;
%LET PKOTIHTUKI = pkotihtuki;
%LET PLLISA = pllisa;
%LET PTOIMTUKI = ptoimtuki;
%LET PKANSEL = pkansel;
%LET PVERO = pvero;
%LET PVERO_VARALL = pvero_varall;
%LET PKIVERO = pkivero;
%LET PASUMTUKI = pasumtuki;
%LET PASUMTUKI_VUOKRANORMIT = pasumtuki_vuokranormit;
%LET PASUMTUKI_ENIMMMENOT = pasumtuki_enimmmenot;
%LET PELASUMTUKI = pelasumtuki;

/* Tulostaulukoiden esivalinnat */ 

%LET TULOSLAAJ_KOKO = 1 ; * Mikrotason tulosaineiston laajuus (1 = suppea, 2 = laaja (palveluaineisto)) ;

* Taulukoitavat muuttujat (summataulukko) ;

%LET MUUTTUJAT = SAIRVAK_SIMUL SAIRVAK_DATA TTURVA_SIMUL TTURVA_DATA KOTIHTUKI_SIMUL KOTIHTUKI_DATA
		KANSEL_PERHEL_SIMUL KANSEL_PERHEL_DATA VEROTT_KANSEL_SIMUL VEROTT_KANSEL_DATA ASUMLISA_DATA
		ASUMLISA_SIMUL OPLAINA_SIMUL OPLAINA_DATA OPINTUKI_SIMUL OPINTUKI_DATA PALKVAK_SIMUL PALKVAK_DATA
		PRAHAMAKSU_SIMUL PRAHAMAKSU_DATA KUNNVE_SIMUL KUNNVE_DATA KIRKVE_SIMUL KIRKVE_DATA
		SAIRVAKMAKSU_SIMUL SAIRVAKMAKSU_DATA KEVE_SIMUL VALTVERO_SIMUL VALTVERO_DATA
		POVERO_SIMUL POVERO_DATA YLEVERO_SIMUL VEROTYHT_SIMUL VEROTYHT_DATA MAKSP_VEROT_SIMUL MAKSP_VEROT_DATA
		PTVARVO_SIMUL PTKIVERO_SIMUL VAPVARVO_SIMUL VAPKIVERO_SIMUL ASOYKIVERO_SIMUL MPKIVE_SIMUL KIVEROYHT_SIMUL KIVEROYHT2_SIMUL KIVEROYHT_DATA
		LAPSIP_DATA LAPSIP_SIMUL ELASUMTUKI_DATA ELASUMTUKI_SIMUL ASUMTUKI_SIMUL ASUMTUKI_DATA
		PHOITO_SIMUL PHOITO_DATA TOIMTUKI_DATA TOIMTUKI_SIMUL PALKAT MUUT_EL MUU_ANSIO PANSIO_SIMUL PANSIO_DATA 
		PPOMA_DATA PPOMA_SIMUL YRIT_ANSIO YRIT_POTULO SEKAL_PRAHAT SEKAL_POTULO SEKAL_VEROT SEKAL_VEROTT_TULO
		EI_SIMULTULOT ASUNTOTULO METSATULO SEKAL_VAHENN OSVEROVAP_DATA OSVEROVAP_SIMUL 
		OSINGOTP_DATA OSINGOTP_SIMUL OSINGOTA_DATA OSINGOTA_SIMUL 
		YHTHYV_SIMUL PRAHAT_DATA PRAHAT_SIMUL ASUMTUET_DATA ASUMTUET_SIMUL VERONAL_TULOT_DATA 
		VERONAL_TULOT_SIMUL VEROTT_TULOT_DATA VEROTT_TULOT_SIMUL BRUTTORAHATULO_DATA BRUTTORAHATULO_SIMUL 
		KAYTRAHATULO_DATA kturaha KAYTRAHATULO_SIMUL KAYTTULO_DATA ktu KAYTTULO_SIMUL ; 	 

%LET YKSIKKO = 1;		 * Tulostaulukoiden yksikk� (1 = henkil�, 2 = kotitalous) ;
%LET LUOK_HLO1 = ; * Taulukoinnin 1. henkil�luokitus (jos YKSIKKO = 1)
							   Vaihtoehtoina: 
								 DESMOD_MALLI (mallissa uudelleen tuotetut tulodesiilit, ekvivalentit tulot (modoecd), hl�painot)
							     desmod (alkuper�iset tulodesiilit, ekvivalentit tulot (modoecd), hl�painot)
							     ikavu (henkil�n mukaiset ik�ryhm�t)
							     elivtu (kotitalouden elinvaihe)
							     koulas (henkil�n koulutusaste TK1997)
							     soss (henkil�n sosioekonominen asema AML2001)
							     rake (kotitalouden rakenne) ;
%LET LUOK_HLO2 = ;		 	* Taulukoinnin 2. henkil�luokitus ;
%LET LUOK_HLO3 = ;		 	* Taulukoinnin 3. henkil�luokitus ;

%LET LUOK_KOTI1 = DESMOD_MALLI; * Taulukoinnin 1. kotitalousluokitus (jos YKSIKKO = 2) 
							    Vaihtoehtoina: 
							     DESMOD_MALLI (mallissa uudelleen tuotetut tulodesiilit, ekvivalentit tulot (modoecd), hl�painot)
							     desmod (alkuper�iset tulodesiilit, ekvivalentit tulot (modoecd), hl�painot)
							     ikavuV (viitehenkil�n mukaiset ik�ryhm�t)
							     elivtu (kotitalouden elinvaihe)
							     koulas (viitehenkil�n koulutusaste TK1997)
							     paasoss (kotitalouden sosioekonominen asema AML2001)
							     rake (kotitalouden rakenne) ;
%LET LUOK_KOTI2 = ; 	  	* Taulukoinnin 2. kotitalousluokitus ;
%LET LUOK_KOTI3 = ; 	  	* Taulukoinnin 3. kotitalousluokitus ;

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

* Tulonjakoindikaattoreiden esivalinnat ;

%LET RAJALKM = 3; * K�ytett�vien k�yhyysrajojen m��r� ;
%LET KRAJA1 = 60; * 1. k�yhyysraja (% mediaanitulosta) ;
%LET KRAJA2 = 50; * 2. k�yhyysraja (% mediaanitulosta) ;
%LET KRAJA3 = 40; * 3. k�yhyysraja (% mediaanitulosta) ;
%LET TULO = KAYTTULO_SIMUL;  * K�ytett�v� tulok�site: 
							   - BRUTTORAHATULO_SIMUL (Rahatulot ennen veroja ja v�hennyksi�)
							   - KAYTRAHATULO_SIMUL eli k�ytett�viss� olevat rahatulot)
				   			   - tai KAYTTULO_SIMUL (K�ytett�viss� olevat tulot) ;
%LET KULUYKS = modoecd ; * Kulutusyksik�n m��ritelm�:
							- jasenia (J�senten lukum��r�)
							- kulyks (OECD:n kulutusyksikk�m��ritelm�) 
							- tai modoecd (Modifioitu OECD:n kulutusyksikk�m��ritelm�);
%END;

%LET KOTASU = 0;  		* Voiko kotona asuvilla v�hint��n 18-vuotiailla lapsilla olla asumiskustannuksia (1 = Kyll�, 0 = Ei); 

/* Ajetaan mahdollinen inflaatiokorjaus */	

%IF &INF = 999 %THEN %DO;
	%IF &LVUOSI = &AVUOSI %THEN %DO;
		%LET INF = 1;
	%END;
	%ELSE %DO;
		%IndKerroin (&AVUOSI, &LVUOSI);
	%END;
%END;

%LET KIVERO_AINEISTO = KIVE_&AINEISTO&AVUOSI; 	* K�ytett�v� kiinteist�verorekisterin aineisto (aina KIVE_&AINEISTO);


%MEND Aloitus;

%Aloitus;

/******************************************************************************************************************/


/* 2. Datan poiminta ja apumuuttujien luominen (optio) */

%MACRO KoKo_Muutt_Poiminta;

%IF &KOKOpoiminta = 1 %THEN %DO;

	/* 2.1 M��ritell��n tarvittavat palveluaineiston muuttujat taulukkoon START_KOKO */

	DATA STARTDAT.START_KOKO;
	SET POHJADAT.&AINEISTO&AVUOSI
	(KEEP = hnro knro asko trpl trplkor anstukor tulkp tulkp6 tmpt tkust tepalk 
     tmeri tlue2 tpalv trespa tpturva tlue3 vthm vthmu tmaat1 tmaat1p tpjta tliik1 tliikp tporo1 
     tyhtat tyhthav yrtukor tpalv2 telps1 telps2 telps5 ttyoltuk tmaat2 tmaat2p tliik2 tliik2p tporo2 
     tyhtpot tmetsp tmetspp tvaksp tvuokr tvuokr1 tpalv2p tjvkork  tmuukor tjmark tvlkorp tvtkorp tmuutp 
     tsiraho tmyynt  tmyynt1 fluotap tvahevas tptmuu tulkyhp hrvanhue  hrtkyvyt hrtyotte hrelake htvanhue htkyvyt 
     htyotte htperhe ttapel mamutuki ttappr tmuupr tvakpr hkkura hmkura kuntoutu kokorve hlakav 
	 tpotel tmuuel tulkel teanstu  tuntelve  tunteltk tuntelty  tuntelpe  maaterel tmluoko tpyspu thanpu 
  	 tpyspu1 thanpu1 lmhm metskust tpjta tmetsp tmetspp tmtatt hkuto amstipe hsotav hasepr hsotvkor vaklis 
	 korav elasa rahsa apuraha lassa lahdever omakkiiv vevm verokor lveru elama astulone muastulo hsaiprva 
	 haiprva hwmky htkapr tmtukimk ptmk htyotper vvvmk1 vvvmk2 vvvmk3 vvvmk4 vvvmk5 yhtez tkoultuk 
	 kelkan takelake hvamtuk kelapu hlaho rvvm kellaps rili riyl kthr kthl ktku oshr hkotihm opirako opirake hasuli hopila 
	 verot svatvap svatpp lpvma lshma ltva ltvp lkuve lkive lelvak tnoosvvb teinovvb tuosvvap topkvvap teinovv tnoosvab  teinovab tuosvv topkver tenosve
	 teinova tpeito llmk aitav lbeltuki kelastu hleas hastuki htoimtuk lapper laptay vakio tayde pe_perus
	 hoimaksk hoimakso hoiaikak hoiaikao hoimaksy hoiaikay
	 tvahep50 tptvs tvahep20 tptsu50 korosazkg korosazkf korosatkg korosatkf 
	 dtyhtep mtlisa korosapks korosapkw aemkm);
	 RUN;

	/* 2.2 Lis�t��n aineistoon apumuuttujia */

	DATA STARTDAT.START_KOKO 
	(KEEP = hnro knro asko htkapr mamutuki ktku hkotihm hoiaikay hoimaksy
	KUNNVE_DATA KIRKVE_DATA PRAHAMAKSU_DATA SAIRVAKMAKSU_DATA PALKVAK_DATA VALTVERO_DATA POVERO_DATA
	PANSIO_DATA PPOMA_DATA MAKSP_VEROT_DATA OPLAINA_DATA
	PALKAT SEKAL_PRAHAT MUUT_EL MUU_ANSIO YRIT_ANSIO YRIT_POTULO SEKAL_POTULO SEKAL_VEROT 
	SEKAL_VAHENN SEKAL_VEROTT_TULO EI_SIMULTULOT METSATULO ASUNTOTULO SAIRVAK_DATA TTURVA_DATA 
	KANSEL_PERHEL_DATA VEROTT_KANSEL_DATA KOTIHTUKI_DATA OPINTUKI_DATA ASUMLISA_DATA 
	PRAHAT_DATA VEROTYHT_DATA VEROT_DATA OSVEROVAP_DATA OSINGOTP_DATA OSINGOTA_DATA LAPSIP_DATA
	ELASUMTUKI_DATA ASUMTUKI_DATA ASUMTUET_DATA PHOITO_DATA TOIMTUKI_DATA VERONAL_TULOT_DATA PRAHAT_DATA 
	ASUMTUET_DATA VERONAL_TULOT_DATA VEROTT_TULOT_DATA
	OSVEROVAP1_DATA OSVEROVAP2_DATA OSVEROVAP3_DATA OSVEROVAP4_DATA OSINGOTP1_DATA OSINGOTP2_DATA OSINGOTP3_DATA
	KIVEROYHT_DATA);

	SET STARTDAT.START_KOKO;

	/* Palkkatulot */

	PALKAT = SUM(trpl, trplkor, anstukor, tulkp, tulkp6, tmpt, tkust, tepalk, tmeri, tlue2, tpalv, trespa, tpturva, tlue3);

	PALKAT = MAX(PALKAT - vthm - vthmu, 0);

	/* Sosiaalietuuksia, joita ei simuoida */

	SEKAL_PRAHAT = SUM(ttappr, tmuupr, tvakpr, hkkura, hmkura, kuntoutu, 0); 

	/* Ansioel�kkeet ym. */

	MUUT_EL = SUM(hrvanhue,  hrtkyvyt, hrtyotte, hrelake, htvanhue, htkyvyt, htyotte, htperhe, ttapel,
		tpotel, tmuuel, tulkel, teanstu, tuntelve, tunteltk, tuntelty, tuntelpe,  MAX(maaterel - tmluoko, 0));

	/* Muita sekalaisia ansiotuloja */

	MUU_ANSIO = SUM(tpalv2, telps1, telps2, telps5, ttyoltuk, SUM(MAX(tkoultuk, 0), -MAX(vvvmk4, 0),-MAX(ptmk, 0)));

	/* Yritystuloja ansiotuloina */

	YRIT_ANSIO = SUM(tmaat1, tmaat1p, tpjta, tliik1, tliikp, tporo1, tyhtat, tyhthav, yrtukor);

	/* Yritystuloja p��omatuloina */

	YRIT_POTULO = SUM(tmaat2, tmaat2p, tliik2, tliik2p, tporo2, tyhtpot, tmetsp, tmetspp, tvaksp);

	/* Mets�tulojen korjaus */

	METSATULO = MAX(SUM(tpyspu, tpyspu1, thanpu, thanpu1, tmtatt, -lmhm, -metskust, -tpjta, -tmetsp, -tmetspp), 0); 

	/* Sekalaisia p��omatuloja */

	SEKAL_POTULO = SUM(tvuokr, tvuokr1, tpalv2p, tjvkork,  tmuukor, tjmark, tvlkorp, tvtkorp, tmuutp, tsiraho, 
		MAX(tmyynt + tmyynt1 - fluotap,  0), tvahevas, tptmuu, MAX(tulkyhp - tuosvv, 0), tvahep50, tptvs, tvahep20, tptsu50);

	/* Sekalaisia, ei-simuloituja, verottomia tuloja */

	SEKAL_VEROTT_TULO = SUM(hkuto, amstipe, hsotav, hasepr, hsotvkor,
		vaklis, korav, elasa, rahsa, apuraha, lassa, kokorve, hlakav);

	/* Sekalaisia, ei-simuloituja veroja */

	SEKAL_VEROT = SUM(lahdever, MAX(vevm - lelvak, 0), verokor, lveru);

	/* Sekalaisia v�hennyksi� tuloista, nyt vain elatusmaksut */

	SEKAL_VAHENN = elama;

	/* Puhdas ansiotulo ja p��omatulo */

	PANSIO_DATA = svatvap;
	PPOMA_DATA = svatpp;

	/* Laskennallinen asuntotulo */

	ASUNTOTULO = SUM(astulone, muastulo);
	
	/* Lasketaan vertailutiedoiksi simuloitavien muuttujasummien arvoja datasta */

	SAIRVAK_DATA = SUM(MAX(hsaiprva, 0), MAX(haiprva, 0), MAX(hwmky, 0), htkapr);

	TTURVA_DATA = SUM(MAX(vvvmk1, 0), MAX(vvvmk2, 0),MAX(vvvmk3, 0),MAX(vvvmk4, 0),MAX(vvvmk5, 0),
					MAX(0, SUM(dtyhtep, mtlisa, korosapks, korosapkw)), MAX(SUM(yhtez, korosazkg, korosazkf), 0),
				    MAX(ptmk, 0),MAX(SUM(tmtukimk, korosatkg, korosatkf), 0));

	KANSEL_PERHEL_DATA = SUM(MAX(kelkan, 0), takelake, vakio, tayde, laptay, lapper, pe_perus);
	VEROTT_KANSEL_DATA = SUM(MAX(hvamtuk, 0), kelapu, hlaho, rvvm, kellaps, rili, riyl, mamutuki);
	KOTIHTUKI_DATA = MAX(kthr, 0) + MAX(kthl, 0) + ktku + oshr + hkotihm;
	OPINTUKI_DATA = SUM(MAX(opirako, 0) , MAX(opirake, 0));
	OPLAINA_DATA = SUM(MAX(hopila, 0));
	ASUMLISA_DATA = SUM(MAX(hasuli, 0), 0);
	PRAHAT_DATA = SUM(SAIRVAK_DATA, TTURVA_DATA, KOTIHTUKI_DATA, OPINTUKI_DATA);
	KUNNVE_DATA = SUM(MAX(lkuve, 0));
	KIRKVE_DATA = SUM(MAX(lkive, 0));
	PRAHAMAKSU_DATA = SUM(MAX(lpvma, 0));
	SAIRVAKMAKSU_DATA = SUM(MAX(lshma, 0));
	PALKVAK_DATA = SUM(MAX(lelvak, 0));
	VALTVERO_DATA = SUM(MAX(ltva, 0));
	POVERO_DATA = SUM(MAX(ltvp, 0));
	VEROTYHT_DATA = SUM(lelvak, lpvma, ltva, ltvp, lkuve, lkive, lshma);
	VEROT_DATA = SUM(verot, -lkive, lelvak);
	MAKSP_VEROT_DATA = SUM(MAX(verot, 0));
	OSVEROVAP_DATA = SUM(tnoosvvb, teinovvb, tuosvvap, topkvvap, teinovv);
	OSVEROVAP1_DATA = SUM(tnoosvvb, tuosvvap);
	OSVEROVAP2_DATA = topkvvap;
	OSVEROVAP3_DATA = teinovvb;
	OSVEROVAP4_DATA = teinovv;
	OSINGOTP_DATA = SUM(tnoosvab,  tenosve, tuosvv, topkver);
	OSINGOTP1_DATA = SUM(tnoosvab, tuosvv);
	OSINGOTP2_DATA = topkver;
	OSINGOTP3_DATA = tenosve;
	OSINGOTA_DATA = SUM(teinova, tpeito);
	LAPSIP_DATA = SUM(MAX(llmk, 0), MAX(aitav, 0) , MAX(lbeltuki, 0));
	ELASUMTUKI_DATA = SUM(MAX(aemkm, 0));
	ASUMTUKI_DATA = SUM(MAX(hastuki, 0), 0);
	ASUMTUET_DATA = SUM(ASUMLISA_DATA, ELASUMTUKI_DATA, ASUMTUKI_DATA);
	PHOITO_DATA = SUM(MAX(hoiaikak * hoimaksk, 0), MAX(hoiaikao * hoimakso, 0), MAX(hoiaikay * hoimaksy, 0));
	TOIMTUKI_DATA = SUM(MAX(htoimtuk, 0));
	VERONAL_TULOT_DATA = SUM(PRAHAT_DATA,  KANSEL_PERHEL_DATA);
	VEROTT_TULOT_DATA = SUM(LAPSIP_DATA, VEROTT_KANSEL_DATA, ASUMTUET_DATA, TOIMTUKI_DATA);

	/* Tulot, joita (normaalisti) ei simuloida, yhteenlaskettuna */

	EI_SIMULTULOT = SUM(PALKAT, MUU_ANSIO, SEKAL_PRAHAT,  MUUT_EL,
		YRIT_ANSIO, YRIT_POTULO, SEKAL_POTULO, SEKAL_VEROTT_TULO, METSATULO);

	/* Maksetut kiinteist�verot */

	KIVEROYHT_DATA = omakkiiv;

	/* Luodaan uusille summamuuttujille selitteet */

	LABEL
	PALKAT = 'Palkkatulot yhteens�, DATA'
	MUUT_EL = 'Ansio ym. el�kkeet yhteens�, DATA'
	MUU_ANSIO = 'Muita sekalaisia ansiotuloja yhteens�, DATA'
	YRIT_ANSIO = 'Yritystulot ansiotuloina yhteens�,, DATA'
	YRIT_POTULO = 'Yritystulot p��omatuloina yhteens�, DATA'
	SEKAL_PRAHAT = 'Sosiaalietuudet yhteens�, joita ei simuoida, DATA'
	SEKAL_POTULO = 'Sekalaisia p��omatuloja yhteens�, DATA'
	SEKAL_VEROT = 'Sekalaisia, ei-simuloituja veroja yhteens�, DATA'
	SEKAL_VEROTT_TULO = 'Sekalaisia, ei-simuloituja, verottomia tuloja yhteens�, DATA'
	ASUNTOTULO = 'Laskennallinen asuntotulo, DATA'
	METSATULO = 'Mets�tulot yhteens� (korjattu), DATA'
	SEKAL_VAHENN = 'Sekalaisia v�hennyksi� tuloista (elatusmaksut), DATA'
	OSVEROVAP_DATA = 'Verottomat osingot yhteens�, DATA'
	OSVEROVAP1_DATA = 'Verottomat osingot: ulkomaan osingot ja listatut yhti�t, DATA'
	OSVEROVAP2_DATA = 'Verottomat osingot: osuusp��oman korko, DATA'
	OSVEROVAP3_DATA = 'Verottomat osingot: listaamaattomat yhti�t (p��omatulo), DATA'
	OSVEROVAP4_DATA = 'Verottomat osingot: listaamattomat yhti�t (ansiotulo), DATA'
	OSINGOTP_DATA = 'P��omatulo-osingot yhteens�, DATA'
	OSINGOTP1_DATA = 'P��omatulo-osingot: ulkomaan osingot ja julkisesti noteeratut osakkeet, DATA'
	OSINGOTP2_DATA = 'P��omatulo-osingot: osuusp��oman korot, DATA'
	OSINGOTP3_DATA = 'P��omatulo-osingot: henkil�yhti�t, DATA'
	OSINGOTA_DATA = 'Ansiotulo-osingot yhteens�, DATA'
	PANSIO_DATA = 'Puhdas ansiotulo, DATA'
	PPOMA_DATA = 'Puhdas p��omatulo, DATA'

	SAIRVAK_DATA = 'Sairausvakuutuslain mukaiset p�iv�rahat yhteens�, DATA'
	TTURVA_DATA = 'Ty�tt�myysturva ja koulutustuki yhteens�, DATA'
	KANSEL_PERHEL_DATA = 'Kansanel�kkeet ja perhe-el�kkeet yhteens� (ml. takuuel�ke), DATA'
	VEROTT_KANSEL_DATA = 'Verottomat el�kelis�t ja vammaistuet yhteens�, DATA'
	KOTIHTUKI_DATA = 'Lasten kotihoidon tuki yhteens�, DATA'
	PHOITO_DATA = 'P�iv�hoitomaksut yhteens�, DATA'
	OPINTUKI_DATA = 'Opintoraha yhteens�, DATA'
	OPLAINA_DATA ='Opintolainan valtiontakaus, DATA'
	PRAHAT_DATA = 'Sosiaaliturvan p�iv�rahat yhteens�, DATA'
	LAPSIP_DATA = 'Lapsilis�t, �itiysavustus ja elatustuki yhteens�, DATA'
	ELASUMTUKI_DATA = 'El�kkeensaajien asumistuki, DATA'
	ASUMTUKI_DATA = 'Yleinen asumistuki yhteens�, DATA'
	ASUMLISA_DATA = 'Opintotuen asumislis�, DATA'
	ASUMTUET_DATA = 'Asumistuet yhteens�, DATA'
	PHOITO_DATA = 'P�iv�hoitomaksut yhteens�, DATA'
	TOIMTUKI_DATA = 'Toimeentulotuki, DATA'

	PALKVAK_DATA = 'Palkansaajan el�ke- ja ty�tt�myysvakuutusmaksu, DATA'
	PRAHAMAKSU_DATA = 'Sairausvakuutuksen p�iv�rahamaksu, DATA'
	KUNNVE_DATA = 'Kunnallisverot, DATA'
	KIRKVE_DATA = 'Kirkollisverot, DATA'
	SAIRVAKMAKSU_DATA = 'Sairaanhoitomaksut, DATA'
	VALTVERO_DATA = 'Valtion tuloverot, DATA'
	POVERO_DATA = 'P��omatulon verot, DATA'
	MAKSP_VEROT_DATA = 'Maksuunpannut verot, DATA' 
	VEROTYHT_DATA = 'Kaikki verot ja maksut yhteens�, DATA'
	VEROT_DATA = 'Verot ja maksut yhteens� (pl. kirkollisvero), DATA'

	VERONAL_TULOT_DATA = 'Veronalaiset tulonsiirrot yhteens�, DATA'
	VEROTT_TULOT_DATA = 'Verottomat tulonsiirrot yhteens�, DATA'

	EI_SIMULTULOT = 'Tulot, joita (normaalisti) ei simuloida, yhteenlaskettuna, DATA'

	KIVEROYHT_DATA = 'Kiinteist�verot (pl. asoy) yhteens� (palveluaineisto), DATA';

	RUN;

%END;

%MEND KoKo_Muutt_Poiminta;

%KoKo_Muutt_Poiminta;


/* 3. Simulointivaihe */

%LET alkoi2&MALLI = %SYSFUNC(TIME());

/* 3.1 Jos parametrit luetaan makromuuttujiksi ennen simulontia, ajetaan t�m� makro */

%MACRO KuukSimul;

%IF &F = S AND &TYYPPI_KOKO = SIMULX %THEN %DO;

	%IF &SAIRVAK = 1 %THEN %DO;
		%HaeParam_SairVakSIMUL(&LVUOSI, &LKUUK, &INF);
		%HaeParam_TTurvaSIMUL(&LVUOSI, &LKUUK, &INF);
	%END;

	%IF &TTURVA = 1 %THEN %DO;
		%HaeParam_TTurvaSIMUL(&LVUOSI, &LKUUK, &INF);
	%END;

	%IF  &KANSEL = 1 %THEN %DO;
		%HaeParam_KanselSIMUL(&LVUOSI, &LKUUK, &INF);
	%END;
	
	%IF (&KOTIHTUKI = 1 OR &PHOITO = 1) %THEN %DO;
		%HaeParam_KotihTukiSIMUL(&LVUOSI, &LKUUK, &INF);
	%END;

	%IF &OPINTUKI = 1 %THEN %DO;
		%HaeParam_OpinTukiSIMUL(&LVUOSI, &LKUUK, &INF);
	%END;

	%IF &LLISA = 1 %THEN %DO;
		%HaeParam_LLisaSIMUL(&LVUOSI, &LKUUK, &INF);
	%END;

	%IF &TOIMTUKI = 1 %THEN %DO;
		%HaeParam_ToimTukiSIMUL(&LVUOSI, &LKUUK, &INF);
	%END;

%END;

%MEND KuukSimul;

%KuukSimul;

/* 4.2 Varsinainen simulointivaihe (osamallien ajo ja tietojen siirto osamalleista) */

%MACRO KoKo_Simuloi_Data;

/* 4.2.1 Sairausvakuutus */

%IF &SAIRVAK = 1 %THEN %DO;
	
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.SIMUL_&MVUOSI&KENO&SIMUL_TIED_SV";

	DATA STARTDAT.START_KOKO;
	UPDATE STARTDAT.START_KOKO (IN = C) OUTPUT.&TULOSNIMI_SV 
	(KEEP = hnro knro SAIRPR VANHPR SAIRPR_TYONANT VANHPR_TYONANT ERITHOITR)
	UPDATEMODE=NOMISSINGCHECK;
	BY hnro;
	IF C;
	RUN;

%END;

/* 4.2.2 Ty�tt�myysturva */

%IF &TTURVA = 1 %THEN %DO;

	%INCLUDE "&LEVY&KENO&HAKEM&KENO.SIMUL_&MVUOSI&KENO&SIMUL_TIED_TT";

	DATA STARTDAT.START_KOKO;
	UPDATE STARTDAT.START_KOKO (IN = C) OUTPUT.&TULOSNIMI_TT
	(KEEP = hnro knro YHTTMTUKI TMTUKILMKOR KOTOUTUKI KTTUKILMKOR YPITOKDAT YPITOK KOULPTUKI PERILMAKOR
       PERUSPR ANSIOPR ANSIOILMKOR VUORKORV AKTIIVAPR AKTIILMKOR)
	UPDATEMODE=NOMISSINGCHECK;
	BY hnro;
	IF C;
	RUN;

%END;

/* 4.2.3 Kansanel�ke */

%IF &KANSEL = 1 %THEN %DO;

	%INCLUDE "&LEVY&KENO&HAKEM&KENO.SIMUL_&MVUOSI&KENO&SIMUL_TIED_KE";

	DATA STARTDAT.START_KOKO;
	UPDATE STARTDAT.START_KOKO (IN = C) OUTPUT.&TULOSNIMI_KE 
	(KEEP = hnro TAKUUELA KANSANELAKE LAPSIKOROT RILISA YLIMRILI EHOITUKI LVTUKI VTUKI KTUKI MMTUKI 
	    LAPSENELAKE LAELAKEDATA LESKENELAKE LEELAKEDATA)
	UPDATEMODE=NOMISSINGCHECK;
	BY hnro;
	IF C;
	RUN;

%END;

/* 4.2.4 Kotihoidontuki */

%IF &KOTIHTUKI = 1 %THEN %DO;

	%INCLUDE "&LEVY&KENO&HAKEM&KENO.SIMUL_&MVUOSI&KENO&SIMUL_TIED_KT";

	DATA STARTDAT.START_KOKO;
	UPDATE STARTDAT.START_KOKO (IN = C) OUTPUT.&TULOSNIMI_KT 
	(KEEP = hnro KOTIHTUKI OSHOIT HOITORAHA HOITOLISA)
	UPDATEMODE=NOMISSINGCHECK;
	BY hnro;
	IF C;
	RUN;

%END;

/* 4.2.5 Opintotuki */
 
%IF &OPINTUKI = 1 %THEN %DO;
	
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.SIMUL_&MVUOSI&KENO&SIMUL_TIED_OT";

	DATA STARTDAT.START_KOKO;
	UPDATE STARTDAT.START_KOKO (IN = C) OUTPUT.&TULOSNIMI_OT 
	(KEEP = hnro TUKIKESK TUKIKOR ASUMLISA OPLAIN)
	UPDATEMODE=NOMISSINGCHECK;
	BY hnro;
	IF C;
	RUN;

%END;

/* 4.2.6 Veromalli */

%IF &VERO = 1 %THEN %DO;

	%INCLUDE "&LEVY&KENO&HAKEM&KENO.SIMUL_&MVUOSI&KENO&SIMUL_TIED_VE";

	DATA STARTDAT.START_KOKO;
	UPDATE STARTDAT.START_KOKO (IN = C) OUTPUT.&TULOSNIMI_VE 
	(KEEP = hnro 
		 PALKVAK_E53 PALKVAK_53 PALKVAK THANKKULUT2
		 PUHD_ANSIO PUHD_PO ANSIOT_VAH ELTULVAH_K
		 ELTULVAH_V OPRAHVAH INVVAH_K PRAHAMAKSU KUNNVTULO1 PERVAH
		 KUNNVTULO2 KUNNVEROA KUNNVEROB KUNNVEROC KUNNVEROD KUNNVEROE 
		 KIRKVEROA KIRKVEROB KIRKVEROC KIRKVEROD KIRKVEROE SAIRVAKA SAIRVAKB
		 SAIRVAKC SAIRVAKD SAIRVAKE KEVA KEVB KEVC KEVD KEVE VALTVERTULO YHTHYVA YHTHYVP YHTHYV
		 VALTVEROA VALTVEROB VALTVEROC VALTVEROD VALTVEROE VALTVEROF VALTANSVAH
		 INVVAH_V ELVELV_VAH POVEROA POVEROB ALIJHYV ALIJHYVERIT KOTITVAHMAX 
		 KOTITVAH ULKVAH OSINKOVAP OSINKOP OSINKOA OSINKOP1 OSINKOP2 OSINKOP3 
		 OSINKOVAP1 OSINKOVAP2 OSINKOVAP3 OSINKOVAP4 ASKOROT ASKOROT1 ENSASKOROT MUU_VAH
		 ANSIOVEROT KAIKKIVEROT MAKSP_VEROT YLEVERO)
	UPDATEMODE=NOMISSINGCHECK;
	BY hnro;
	IF C;
	RUN;

%END;

/* 4.2.7 Kiinteist�veromalli */

%IF (&KIVERO = 1 AND (&AVUOSI = 2011)) %THEN %DO;

	%INCLUDE "&LEVY&KENO&HAKEM&KENO.SIMUL_&MVUOSI&KENO&SIMUL_TIED_KV";

	DATA STARTDAT.START_KOKO;
	UPDATE STARTDAT.START_KOKO (IN = C) OUTPUT.&TULOSNIMI_KV 
	(KEEP = hnro VALOPULLINENPT RAK_KVEROPT RAK_KVEROPT VALOPULLINENVA RAK_KVEROVA ASOYKIVERO KVTONTTIS KIVEROYHT KIVEROYHT2)
	UPDATEMODE=NOMISSINGCHECK;
	BY hnro;
	IF C;
	RUN;

%END;

/* 4.2.8 Lapsilis�t */

%IF &LLISA = 1 %THEN %DO;

	%INCLUDE "&LEVY&KENO&HAKEM&KENO.SIMUL_&MVUOSI&KENO&SIMUL_TIED_LL";

	DATA TEMP.KOKOX;
	SET STARTDAT.START_KOKO;
	IF asko = 1;
	RUN;

	DATA TEMP.KOKOX (KEEP = knro hnro LLISA_HH AITAVUST ELATUSTUET_HH);
	UPDATE TEMP.KOKOX (IN = C) OUTPUT.&TULOSNIMI_LL 
	(KEEP = knro LLISA_HH AITAVUST ELATUSTUET_HH);
	BY knro;
	IF C;
	RUN;

	DATA STARTDAT.START_KOKO;
	UPDATE STARTDAT.START_KOKO (IN = C) TEMP.KOKOX (KEEP = knro hnro LLISA_HH AITAVUST ELATUSTUET_HH)
	UPDATEMODE=NOMISSINGCHECK;
	BY hnro;
	IF C;
	RUN;

%END;

/* 4.2.9 El�kkeensaajien asumistuki */

%IF &ELASUMTUKI = 1 %THEN %DO;

	%INCLUDE "&LEVY&KENO&HAKEM&KENO.SIMUL_&MVUOSI&KENO&SIMUL_TIED_EA";

	DATA STARTDAT.START_KOKO;
	UPDATE STARTDAT.START_KOKO (IN = C) OUTPUT.&TULOSNIMI_EA (KEEP = hnro ELAKASUMTUKI)
	UPDATEMODE=NOMISSINGCHECK;
	BY hnro;
	RUN;

%END;

/* 4.2.10 Yleinen asumistuki */

%IF &ASUMTUKI = 1 %THEN %DO;
	
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.SIMUL_&MVUOSI&KENO&SIMUL_TIED_YA";

	DATA STARTDAT.START_KOKO;
	UPDATE STARTDAT.START_KOKO (IN = C) OUTPUT.&TULOSNIMI_YA 
	(KEEP = hnro TUKIVUOK TUKIOM TUKIOSA TUKISUMMA)
	UPDATEMODE=NOMISSINGCHECK;
	BY hnro;
	IF C;
	RUN;

%END;

/* 4.2.11 P�iv�hoitomaksut */
	
%IF &PHOITO = 1 %THEN %DO;
	
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.SIMUL_&MVUOSI&KENO&SIMUL_TIED_PH";

	DATA STARTDAT.START_KOKO;
	UPDATE STARTDAT.START_KOKO (IN = C) OUTPUT.&TULOSNIMI_PH (KEEP = hnro PHMAKSU_KOK PHMAKSU_OS)
	UPDATEMODE=NOMISSINGCHECK;
	BY hnro;
	IF C;
	RUN;

%END;

/* 4.2.12 Toimeentulotuki */

%IF &TOIMTUKI = 1 %THEN %DO;

	%IF &VERO = 1 AND &LVUOSI GE 2013 %THEN %DO;

		%LET TTURVA_KOR = 1;

		%INCLUDE "&LEVY&KENO&HAKEM&KENO.SIMUL_&MVUOSI&KENO&SIMUL_TIED_VE";

	%END;
	
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.SIMUL_&MVUOSI&KENO&SIMUL_TIED_TO";

	DATA STARTDAT.START_KOKO;
	UPDATE STARTDAT.START_KOKO (IN = C) OUTPUT.&TULOSNIMI_TO (KEEP = hnro TOIMTUKI)
	UPDATEMODE=NOMISSINGCHECK;
	BY hnro;
	IF C;
	RUN;

%END;

/* Poistetaan osamallien tulostaulukot levytilan s��st�miseksi */

PROC DELETE DATA = 
OUTPUT.&TULOSNIMI_TT 
OUTPUT.&TULOSNIMI_TO 
OUTPUT.&TULOSNIMI_KE
OUTPUT.&TULOSNIMI_PH 
OUTPUT.&TULOSNIMI_YA 
OUTPUT.&TULOSNIMI_EA
OUTPUT.&TULOSNIMI_LL
TEMP.KOKOX 
OUTPUT.&TULOSNIMI_VE 
OUTPUT.&TULOSNIMI_KV
OUTPUT.&TULOSNIMI_OT 
OUTPUT.&TULOSNIMI_KT 
OUTPUT.&TULOSNIMI_SV;

/* 4.3 Lasketaan simuloitujen muuttujien summia henkil�itt�in.
       Jos muuttujatietoja ei ole simuloitu, lasketaan vastaavat arvot datasta */

DATA OUTPUT.&TULOSNIMI_KOKO; 
SET STARTDAT.START_KOKO;

/* Sairausvakuutuksen p�iv�rahat */

%IF &SAIRVAK = 0 %THEN %DO; SAIRVAK_SIMUL = SAIRVAK_DATA;%END;
%ELSE %DO; SAIRVAK_SIMUL = SUM(SAIRPR, VANHPR, ERITHOITR, htkapr);%END;

/* Ty�tt�myysturvan p�iv�rahat */

%IF &TTURVA = 0 %THEN %DO; TTURVA_SIMUL = TTURVA_DATA;%END;
%ELSE %DO; TTURVA_SIMUL = SUM(YHTTMTUKI, KOULPTUKI, PERUSPR, ANSIOPR, VUORKORV, AKTIIVAPR, KOTOUTUKI);%END;

/* Kansanel�kkeet ym. */

%IF &KANSEL = 0 %THEN %DO;
	KANSEL_PERHEL_SIMUL = KANSEL_PERHEL_DATA;
	VEROTT_KANSEL_SIMUL = VEROTT_KANSEL_DATA;
%END;
%ELSE %DO;
	KANSEL_PERHEL_SIMUL = SUM(TAKUUELA, KANSANELAKE, LESKENELAKE, LAPSENELAKE); 
	VEROTT_KANSEL_SIMUL = SUM(LAPSIKOROT, RILISA, YLIMRILI, EHOITUKI, LVTUKI, VTUKI, KTUKI, MMTUKI);
%END;

/* Lasten kotihoidon tuki */

%IF &KOTIHTUKI = 0 %THEN %DO; KOTIHTUKI_SIMUL = KOTIHTUKI_DATA;%END;
%ELSE %DO; KOTIHTUKI_SIMUL = SUM(KOTIHTUKI, OSHOIT, ktku, hkotihm);%END;

/* Opintorahat ja asumislis� */

%IF &OPINTUKI = 0 %THEN %DO;
	OPINTUKI_SIMUL = OPINTUKI_DATA;
	ASUMLISA_SIMUL = ASUMLISA_DATA;
	OPLAINA_SIMUL = OPLAINA_DATA;
%END;
%ELSE %DO;
	OPINTUKI_SIMUL = SUM(TUKIKESK, TUKIKOR);
	ASUMLISA_SIMUL = ASUMLISA;
	OPLAINA_SIMUL = OPLAIN;
	DROP ASUMLISA OPLAIN;
%END;

/* Veronalaiset p�iv�rahatulot yhteens� */

PRAHAT_SIMUL = SUM(SAIRVAK_SIMUL, TTURVA_SIMUL, KOTIHTUKI_SIMUL, OPINTUKI_SIMUL);

/* Verot ja muita VERO-mallilla laskettuja tietoja */

%IF &VERO = 0 %THEN %DO;
	PANSIO_SIMUL = PANSIO_DATA;
	PPOMA_SIMUL = PPOMA_DATA;
	KUNNVE_SIMUL = KUNNVE_DATA;
	KIRKVE_SIMUL = KIRKVE_DATA;
	PRAHAMAKSU_SIMUL = PRAHAMAKSU_DATA;
	SAIRVAKMAKSU_SIMUL = SAIRVAKMAKSU_DATA;
	KEVE_SIMUL = .;
	PALKVAK_SIMUL = PALKVAK_DATA;
	VALTVERO_SIMUL = VALTVERO_DATA;
	POVERO_SIMUL = POVERO_DATA;
	VEROTYHT_SIMUL = VEROTYHT_DATA;
	VEROT_SIMUL = VEROT_DATA;
	MAKSP_VEROT_SIMUL = MAKSP_VEROT_DATA;
	OSVEROVAP_SIMUL = OSVEROVAP_DATA;
	OSVEROVAP1_SIMUL = OSVEROVAP1_DATA;
	OSVEROVAP2_SIMUL = OSVEROVAP2_DATA; 
	OSVEROVAP3_SIMUL = OSVEROVAP3_DATA; 
	OSVEROVAP4_SIMUL = OSVEROVAP4_DATA;
	YHTHYV_SIMUL = .;
	OSINGOTP_SIMUL = OSINGOTP_DATA;
	OSINGOTP1_SIMUL = OSINGOTP1_DATA;
	OSINGOTP2_SIMUL = OSINGOTP2_DATA;
	OSINGOTP3_SIMUL = OSINGOTP3_DATA;
	OSINGOTA_SIMUL = OSINGOTA_DATA;
	YLEVERO_SIMUL = .;
%END;
%ELSE %DO;
	PANSIO_SIMUL = PUHD_ANSIO;
	PPOMA_SIMUL = PUHD_PO;
	KUNNVE_SIMUL = KUNNVEROE;
	KIRKVE_SIMUL = KIRKVEROE;
	PRAHAMAKSU_SIMUL = PRAHAMAKSU;
	SAIRVAKMAKSU_SIMUL = SAIRVAKE;
	KEVE_SIMUL = KEVE;
	PALKVAK_SIMUL = PALKVAK;
	VALTVERO_SIMUL = VALTVEROF;
	POVERO_SIMUL = POVEROB;
	VEROTYHT_SIMUL = SUM(KAIKKIVEROT);
	VEROT_SIMUL = SUM(KAIKKIVEROT, -KIRKVEROE);
	MAKSP_VEROT_SIMUL = MAKSP_VEROT;
	OSVEROVAP_SIMUL = OSINKOVAP;
	OSVEROVAP1_SIMUL = OSINKOVAP1;
	OSVEROVAP2_SIMUL = OSINKOVAP2; 
	OSVEROVAP3_SIMUL = OSINKOVAP3; 
	OSVEROVAP4_SIMUL = OSINKOVAP4;
	OSINGOTP_SIMUL = OSINKOP;
	OSINGOTP1_SIMUL = OSINKOP1;
	OSINGOTP2_SIMUL = OSINKOP2;
	OSINGOTP3_SIMUL = OSINKOP3;
	OSINGOTA_SIMUL = OSINKOA;
	YHTHYV_SIMUL = YHTHYV;
	YLEVERO_SIMUL = YLEVERO;

	DROP KUNNVEROE KIRKVEROE PRAHAMAKSU SAIRVAKE PALKVAK VALTVEROF POVEROB
	     KAIKKIVEROT OSINKOVAP OSINKOP OSINKOA OSINKOP1 OSINKOP2 OSINKOP3 
		 OSINKOVAP1 OSINKOVAP2 OSINKOVAP3 OSINKOVAP4 YHTHYV YLEVERO MAKSP_VEROT PUHD_ANSIO PUHD_PO KEVE;
%END;

/* Kiinteist�vero */

%IF &KIVERO = 1 AND &AVUOSI = 2011 %THEN %DO; 

	PTVARVO_SIMUL = VALOPULLINENPT;
	PTKIVERO_SIMUL = RAK_KVEROPT;
	VAPVARVO_SIMUL = VALOPULLINENVA;
	VAPKIVERO_SIMUL = RAK_KVEROVA;
	ASOYKIVERO_SIMUL = ASOYKIVERO;
	MPKIVE_SIMUL =  KVTONTTIS ;
	KIVEROYHT_SIMUL = KIVEROYHT;
	KIVEROYHT2_SIMUL = KIVEROYHT2;
 
	DROP VALOPULLINENPT RAK_KVEROPT RAK_KVEROPT VALOPULLINENVA RAK_KVEROVA ASOYKIVERO KVTONTTIS KIVEROYHT KIVEROYHT2;

%END;
%ELSE %DO;			  	  
	KIVEROYHT2_SIMUL = KIVEROYHT_DATA; 
%END;

/* Lapsilis�t ym. */

%IF &LLISA = 0 %THEN %DO; LAPSIP_SIMUL = LAPSIP_DATA;%END;
%ELSE %DO; LAPSIP_SIMUL = SUM(LLISA_HH, AITAVUST, ELATUSTUET_HH);%END;

/* El�kkeensaajien asumistuki */

%IF &ELASUMTUKI = 0 %THEN %DO; ELASUMTUKI_SIMUL = ELASUMTUKI_DATA;%END;
%ELSE %DO; ELASUMTUKI_SIMUL = ELAKASUMTUKI;
DROP ELAKASUMTUKI; %END;

/* Yleinen asumistuki */

%IF &ASUMTUKI = 0 %THEN %DO; ASUMTUKI_SIMUL = ASUMTUKI_DATA;%END;
%ELSE %DO; ASUMTUKI_SIMUL = SUM(TUKISUMMA, 0);
DROP TUKISUMMA; %END;

/* Asumistuet yhteens� */

ASUMTUET_SIMUL =  SUM(ASUMLISA_SIMUL, ELASUMTUKI_SIMUL, ASUMTUKI_SIMUL);

/* P�iv�hoitomaksut yhteens� */

%IF &PHOITO = 0 %THEN %DO; PHOITO_SIMUL = PHOITO_DATA;%END;
%ELSE %DO; PHOITO_SIMUL = SUM(PHMAKSU_KOK, PHMAKSU_OS, (hoiaikay * hoimaksy), 0);
%END;

/* Toimeentulotuki */

%IF &TOIMTUKI = 0 %THEN %DO; TOIMTUKI_SIMUL = TOIMTUKI_DATA;%END;
%ELSE %DO; TOIMTUKI_SIMUL = TOIMTUKI; DROP TOIMTUKI; %END;

/* Veronalaiset tulonsiirrot */

VERONAL_TULOT_SIMUL = SUM(PRAHAT_SIMUL, KANSEL_PERHEL_SIMUL);

/* Verottomat tulonsiirrot */

VEROTT_TULOT_SIMUL = SUM(LAPSIP_SIMUL, VEROTT_KANSEL_SIMUL, ASUMTUET_SIMUL, TOIMTUKI_SIMUL);

/* Muodostetaan kokonaissummia */

BRUTTORAHATULO_DATA = SUM(EI_SIMULTULOT, VERONAL_TULOT_DATA, VEROTT_TULOT_DATA,  OSVEROVAP_DATA, OSINGOTA_DATA, OSINGOTP_DATA);

BRUTTORAHATULO_SIMUL = SUM(EI_SIMULTULOT, VERONAL_TULOT_SIMUL, VEROTT_TULOT_SIMUL, OSVEROVAP_SIMUL, OSINGOTA_SIMUL, OSINGOTP_SIMUL);

KAYTRAHATULO_DATA = MAX(SUM(BRUTTORAHATULO_DATA, -VEROT_DATA, -SEKAL_VEROT, -SEKAL_VAHENN, -KIVEROYHT_DATA), 1);

KAYTRAHATULO_SIMUL = MAX(SUM(BRUTTORAHATULO_SIMUL, -VEROT_SIMUL, -SEKAL_VEROT, -SEKAL_VAHENN, -KIVEROYHT2_SIMUL), 1);

KAYTTULO_DATA = MAX(SUM(KAYTRAHATULO_DATA, ASUNTOTULO), 0);

KAYTTULO_SIMUL = MAX(SUM(KAYTRAHATULO_SIMUL, ASUNTOTULO), 0);


RUN;


/* 4.4 Yhdistet��n simuloitu data palveluaineistoon (riippuen tulosaineiston laajuden valinnasta) */

DATA OUTPUT.&TULOSNIMI_KOKO;
	
/* 4.4.1 Suppea tulostiedosto (vain t�rkeimm�t luokittelumuuttujat) */

%IF &TULOSLAAJ_KOKO = 1 %THEN %DO; 
	MERGE POHJADAT.&AINEISTO&AVUOSI 
	(KEEP = hnro knro &PAINO jasenia modoecd kulyks ikavu ikavuV desmod soss paasoss elivtu koulas rake
	ktu kturaha)
	OUTPUT.&TULOSNIMI_KOKO;
%END;

/* 4.4.2 Laaja tulostiedosto (palveluaineiston mukainen tulostiedosto) */

%IF &TULOSLAAJ_KOKO = 2 %THEN %DO; 
	MERGE POHJADAT.&AINEISTO&AVUOSI OUTPUT.&TULOSNIMI_KOKO;
%END;

BY hnro;

* Asetetaan muuttujien 0-arvot tyhjiksi, jotta lukum��r�t voidaan laskea suoraan ;

ARRAY PISTE 
	PALKAT MUUT_EL MUU_ANSIO YRIT_ANSIO YRIT_POTULO SEKAL_POTULO SEKAL_VEROT 
	EI_SIMULTULOT METSATULO ASUNTOTULO SEKAL_VAHENN OSVEROVAP_DATA OSVEROVAP_SIMUL OSINGOTP_DATA 
	OSINGOTP_SIMUL OSINGOTA_DATA OSINGOTA_SIMUL SAIRVAK_DATA SAIRVAK_SIMUL TTURVA_DATA
	TTURVA_SIMUL KANSEL_PERHEL_DATA KANSEL_PERHEL_SIMUL KOTIHTUKI_DATA KOTIHTUKI_SIMUL 
	OPINTUKI_DATA OPINTUKI_SIMUL PRAHAT_DATA PRAHAT_SIMUL VEROT_DATA VEROT_SIMUL 
	YHTHYV_SIMUL LAPSIP_DATA LAPSIP_SIMUL VEROTT_KANSEL_DATA VEROTT_KANSEL_SIMUL 
	ELASUMTUKI_DATA ELASUMTUKI_SIMUL ASUMTUKI_DATA ASUMTUKI_SIMUL ASUMLISA_DATA ASUMLISA_SIMUL 
	ASUMTUET_DATA ASUMTUET_SIMUL PHOITO_DATA PHOITO_SIMUL TOIMTUKI_DATA TOIMTUKI_SIMUL VERONAL_TULOT_DATA VERONAL_TULOT_SIMUL 
	VEROTT_TULOT_DATA VEROTT_TULOT_SIMUL BRUTTORAHATULO_DATA BRUTTORAHATULO_SIMUL KAYTRAHATULO_DATA
	KAYTRAHATULO_SIMUL KAYTTULO_DATA KAYTTULO_SIMUL ktu kturaha
	VALTVERO_DATA VALTVERO_SIMUL POVERO_DATA POVERO_SIMUL KUNNVE_DATA KUNNVE_SIMUL KIRKVE_DATA KIRKVE_SIMUL 
	SAIRVAKMAKSU_DATA SAIRVAKMAKSU_SIMUL 
	PALKVAK_DATA PALKVAK_SIMUL PRAHAMAKSU_DATA PRAHAMAKSU_SIMUL VEROTYHT_SIMUL VEROTYHT_DATA YLEVERO_SIMUL 
	PANSIO_DATA PANSIO_SIMUL PPOMA_DATA PPOMA_SIMUL MAKSP_VEROT_DATA MAKSP_VEROT_SIMUL OPLAINA_SIMUL OPLAINA_DATA
	OSVEROVAP1_DATA OSVEROVAP2_DATA OSVEROVAP3_DATA OSVEROVAP4_DATA OSINGOTP1_DATA OSINGOTP2_DATA OSINGOTP3_DATA
	OSVEROVAP1_SIMUL OSVEROVAP2_SIMUL OSVEROVAP3_SIMUL OSVEROVAP4_SIMUL OSINGOTP1_SIMUL OSINGOTP2_SIMUL OSINGOTP3_SIMUL
	PTVARVO_SIMUL PTKIVERO_SIMUL VAPVARVO_SIMUL VAPKIVERO_SIMUL ASOYKIVERO_SIMUL MPKIVE_SIMUL KIVEROYHT2_SIMUL 
    KIVEROYHT_SIMUL KIVEROYHT_DATA;
DO OVER PISTE;
	IF PISTE <= 0 THEN PISTE = .;
END;

/* Luodaan simuloitujen ja datan muuttujien summille selitteet */

LABEL 
PANSIO_SIMUL = 'Puhdas ansiotulo, MALLI'
PPOMA_SIMUL = 'Puhdas p��omatulo, MALLI'
OSVEROVAP_SIMUL = 'Verottomat osingot yhteens�, MALLI'
OSVEROVAP1_SIMUL = 'Verottomat osingot: ulkomaan osingot ja listatut yhti�t, MALLI'
OSVEROVAP2_SIMUL = 'Verottomat osingot: osuusp��oman korko, MALLI'
OSVEROVAP3_SIMUL = 'Verottomat osingot: listaamaattomat yhti�t (p��omatulo), MALLI'
OSVEROVAP4_SIMUL = 'Verottomat osingot: listaamattomat yhti�t (ansiotulo), MALLI'
OSINGOTP_SIMUL = 'P��omatulo-osingot yhteens�, MALLI'
OSINGOTP1_SIMUL = 'P��omatulo-osingot: ulkomaan osingot ja julkisesti noteeratut osakkeet, MALLI'
OSINGOTP2_SIMUL = 'P��omatulo-osingot: osuusp��oman korot, MALLI'
OSINGOTP3_SIMUL = 'P��omatulo-osingot: henkil�yhti�t, MALLI'
OSINGOTA_SIMUL = 'Ansiotulo-osingot yhteens�, MALLI'
SAIRVAK_SIMUL = 'Sairausvakuutuslain mukaiset p�iv�rahat yhteens�, MALLI'
TTURVA_SIMUL = 'Ty�tt�myysturva ja koulutustuki yhteens�, MALLI'
KOTIHTUKI_SIMUL = 'Lasten kotihoidon tuki yhteens�, MALLI'
PHOITO_SIMUL = 'P�iv�hoitomaksut yhteens�, MALLI'
OPINTUKI_SIMUL = 'Opintoraha yhteens�, MALLI'
OPLAINA_SIMUL ='Opintolainan valtiontakaus, MALLI'
PRAHAT_SIMUL = 'Sosiaaliturvan p�iv�rahat yhteens�, MALLI'
PRAHAMAKSU_SIMUL = 'Sairausvakuutuksen p�iv�rahamaksu, MALLI'
PALKVAK_SIMUL = 'Palkansaajan el�ke- ja ty�tt�myysvakuutusmaksu, MALLI'
KUNNVE_SIMUL = 'Kunnallisverot, MALLI'
KIRKVE_SIMUL = 'Kirkollisverot, MALLI'
SAIRVAKMAKSU_SIMUL = 'Sairaanhoitomaksut, MALLI'
KEVE_SIMUL = 'Kansanel�kevakuutusmaksut, MALLI'
VALTVERO_SIMUL = 'Valtion tuloverot, MALLI'
POVERO_SIMUL = 'P��omatulon verot, MALLI'
YLEVERO_SIMUL = 'Yle-vero, MALLI'
VEROTYHT_SIMUL = 'Kaikki verot ja maksut yhteens�, MALLI'
VEROT_SIMUL = 'Verot ja maksut yhteens� (pl. kirkollisvero), MALLI'
MAKSP_VEROT_SIMUL = 'Maksuunpannut verot, MALLI' 
YHTHYV_SIMUL = 'Yhti�veron hyvitys, MALLI'
LAPSIP_SIMUL = 'Lapsilis�t, �itiysavustus ja elatustuki yhteens�, MALLI'
VEROTT_KANSEL_SIMUL = 'Verottomat el�kelis�t ja vammaistuet yhteens�, MALLI'
KANSEL_PERHEL_SIMUL = 'Kansanel�kkeet ja perhe-el�kkeet yhteens� (ml. takuuel�ke), MALLI'
ELASUMTUKI_SIMUL = 'El�kkeensaajien asumistuki, MALLI'
ASUMTUKI_SIMUL = 'Yleinen asumistuki yhteens�, MALLI'
ASUMLISA_SIMUL = 'Opintotuen asumislis�, MALLI'
ASUMTUET_SIMUL = 'Asumistuet yhteens�, MALLI'
TOIMTUKI_SIMUL = 'Toimeentulotuki, MALLI'
VERONAL_TULOT_SIMUL = 'Veronalaiset tulonsiirrot yhteens�, MALLI'
VEROTT_TULOT_SIMUL = 'Verottomat tulonsiirrot yhteens�, MALLI'
BRUTTORAHATULO_SIMUL = 'Rahatulot ennen veroja ja v�hennyksi�, MALLI'
BRUTTORAHATULO_DATA = 'Rahatulot ennen veroja ja v�hennyksi�, DATA'
KAYTRAHATULO_SIMUL = 'K�ytett�viss� olevat rahatulot, MALLI'
KAYTRAHATULO_DATA = 'K�ytett�viss� olevat rahatulot (rekonstruoitu), DATA'
kturaha = 'K�ytett�viss� olevat rahatulot (palveluaineisto), DATA'
KAYTTULO_SIMUL = 'K�ytett�viss� olevat tulot, MALLI'
KAYTTULO_DATA = 'K�ytett�viss� olevat tulot (rekonstruoitu), DATA'
ktu = 'K�ytett�viss� olevat tulot (palveluaineisto), DATA'
PTKIVERO_SIMUL = 'Kiinteist�vero pientalosta, MALLI'
PTVARVO_SIMUL = 'Verotusarvo pientalosta, MALLI'
VAPKIVERO_SIMUL = 'Kiinteist�vero vapaa-ajan asunnosta, MALLI'
VAPVARVO_SIMUL = 'Verotusarvo vapaa-ajan asunnosta, MALLI'
MPKIVE_SIMUL = 'Kiinteist�vero maapohjasta, MALLI'
ASOYKIVERO_SIMUL = 'Kiinteist�vero asunto-osakeyhti�iss�, MALLI'
KIVEROYHT_SIMUL = 'Kiinteist�verot (ml. asoy) yhteens�, MALLI'
KIVEROYHT2_SIMUL = 'Kiinteist�verot (pl. asoy) yhteens�, MALLI';
RUN;

/* 4.5 Lasketaan desiiliryhm�t (desmod) uudestaan muuttujaan DESMOD_MALLI */

%Desiilit(knro, &TULO, jasenia, &KULUYKS, &PAINO, OUTPUT.&TULOSNIMI_KOKO)


%MEND KoKo_Simuloi_Data;

%KoKo_Simuloi_Data;

%LET loppui2KOKO = %SYSFUNC(TIME());


/* 5. Luodaan summatason tulostaulukot (optio) */

%MACRO KoKo_Tulokset;

/* 5.1 Kotitaloustason tulokset (optio) */

%IF &YKSIKKO = 2 %THEN %DO; 

	/* 5.1.1 Tulonjakoindikaattorit (optio) */

	%IF &KOKOindikaattorit = 1 %THEN %DO;

		%IF &EXCEL = 1 %THEN %DO;

			ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_KOKO._IND.xls" STYLE = MINIMAL;

		%END;

		%Indikaattorit(&RAJALKM, &KRAJA1, &KRAJA2, &KRAJA3, OUTPUT.&TULOSNIMI_KOKO, jasenia, &PAINO, &TULO, &KULUYKS, knro, DESMOD_MALLI, 1);

		%IF &EXCEL = 1 %THEN %DO;

			ODS HTML3 CLOSE;

		%END;

	%END;

	/* 5.1.2 Mikrotason tulosaineiston summaus kotitaloustasolle (optio) */

	PROC SUMMARY DATA=OUTPUT.&TULOSNIMI_KOKO (DROP = hnro);
	BY knro ;
	ID &PAINO ikavuV desmod paasoss elivtu koulas rake DESMOD_MALLI;
	VAR &MUUTTUJAT _NUMERIC_;
	OUTPUT OUT = OUTPUT.&TULOSNIMI_KOKO (DROP = ikavu soss _TYPE_ _FREQ_)  SUM = ;
	RUN;

	/* 5.1.3 Summatason tulostaulukko (optio) */

	%IF &KOKOsummat = 1 %THEN %DO;

		%IF &EXCEL = 1 %THEN %DO;

			ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_KOKO._SUMMAT.xls" STYLE = MINIMAL;

		%END;

		PROC MEANS DATA=OUTPUT.&TULOSNIMI_KOKO &SUMWGT &SUM &MIN &MAX &RANGE &MEAN &MEDIAN &MODE &STD &VAR &CV NONOBS ORDER=DATA NWAY MAXDEC = 0; 
		TITLE "TUNNUSLUVUT (KOTITALOUSTASO), KOKOMALLI";
		CLASS &LUOK_KOTI1 &LUOK_KOTI2 &LUOK_KOTI3 / MLF PRELOADFMT;
		VAR &MUUTTUJAT ;
		FORMAT _NUMERIC_ tuhat. ;
		%DO I = 1 %TO 3; 
		%IF %LENGTH (&&LUOK_KOTI&I) >0 %THEN %DO;
			FORMAT &&LUOK_KOTI&I &&LUOK_KOTI&I... ;
		%END;%END;
		OUTPUT OUT = OUTPUT.&TULOSNIMI_KOKO._SUMMAT (DROP = _TYPE_ _FREQ_)
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
	
/* 5.2 Henkil�tason tulokset (oletus) */

%ELSE %DO;

	/* 5.2.1 Tulonjakoindikaattorit (optio) */

	%IF &KOKOindikaattorit = 1 %THEN %DO;

		%IF &EXCEL = 1 %THEN %DO;

			ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_KOKO._IND.xls" STYLE = MINIMAL;

		%END;

		%Indikaattorit(&RAJALKM, &KRAJA1, &KRAJA2, &KRAJA3, OUTPUT.&TULOSNIMI_KOKO, jasenia, &PAINO, &TULO, &KULUYKS, knro, DESMOD_MALLI, 1);

		%IF &EXCEL = 1 %THEN %DO;

			ODS HTML3 CLOSE;

		%END;

	%END;

	/* 5.2.2 Summatason tulostaulukko (optio) */

	%IF &KOKOsummat = 1 %THEN %DO;

		%IF &EXCEL = 1 %THEN %DO;

			ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_KOKO._SUMMAT.xls" STYLE = MINIMAL;

		%END;

		PROC MEANS DATA=OUTPUT.&TULOSNIMI_KOKO &SUMWGT &SUM &MIN &MAX &RANGE &MEAN &MEDIAN &MODE &STD &VAR &CV NONOBS ORDER=DATA NWAY MAXDEC = 0;
		TITLE "TUNNUSLUVUT (HENKIL�TASO), KOKOMALLI";
		CLASS &LUOK_HLO1 &LUOK_HLO2 &LUOK_HLO3 / MLF PRELOADFMT;
		VAR &MUUTTUJAT ;
		FORMAT _NUMERIC_ tuhat. ;
		%DO I = 1 %TO 3; 
		%IF %LENGTH (&&LUOK_HLO&I) >0 %THEN %DO;
			FORMAT &&LUOK_HLO&I &&LUOK_HLO&I... ;
		%END;%END;
		OUTPUT OUT = OUTPUT.&TULOSNIMI_KOKO._SUMMAT (DROP = _TYPE_ _FREQ_)
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

%MEND KoKo_Tulokset;

%KoKo_Tulokset;

/* 6. Mitataan kuinka kauan osavaiheisiin kului aikaa ja tulostetaan lokiin ajetusta kokonaisuudesta */

%LET loppui1 = %SYSFUNC(TIME());

%LET loppui1KOKO = %SYSFUNC(TIME());

%LET kului1KOKO = %SYSEVALF(&loppui1KOKO - &alkoi1KOKO);

%LET kului2KOKO = %SYSEVALF(&loppui2KOKO - &alkoi2KOKO);

%LET kului1KOKO = %SYSFUNC(PUTN(&kului1KOKO, time10.2));

%LET kului2KOKO = %SYSFUNC(PUTN(&kului2KOKO, time10.2));

%PUT KOKO. Koko laskenta. Aikaa kului (hh:mm:ss.00) &kului1KOKO;

%PUT KOKO. Varsinainen simulointi. Aikaa kului (hh:mm:ss.00) &kului2KOKO;

%PUT C-Funktiot (F) / SAS-Makrot (S): &F;
%PUT Makrojen tyyppi: &TYYPPI_KOKO;


%MACRO INFO;
%PUT Ajettiin mallit;
%PUT %SYSFUNC(IFC(&SAIRVAK = 1 ,   SAIRVAK      kyll�, SAIRVAK      ei));
%PUT %SYSFUNC(IFC(&TTURVA = 1 ,    TTURVA       kyll�, TTURVA       ei));
%PUT %SYSFUNC(IFC(&KANSEL = 1 ,    KANSEL       kyll�, KANSEL       ei));
%PUT %SYSFUNC(IFC(&KOTIHTUKI = 1 , KOTIHTUKI    kyll�, KOTIHTUKI    ei));
%PUT %SYSFUNC(IFC(&OPINTUKI = 1 ,  OPINTUKI     kyll�, OPINTUKI     ei));
%PUT %SYSFUNC(IFC(&VERO = 1 ,      VERO         kyll�, VERO         ei));
%PUT %SYSFUNC(IFC(&KIVERO = 1 AND &AVUOSI = 2011,    KIVERO       kyll�, KIVERO       ei));
%PUT %SYSFUNC(IFC(&LLISA = 1 ,     LLISA        kyll�, LLISA        ei));
%PUT %SYSFUNC(IFC(&ELASUMTUKI = 1, ELASUMTUKI   kyll�, ELASUMTUKI   ei));
%PUT %SYSFUNC(IFC(&ASUMTUKI = 1 ,  ASUMTUKI     kyll�, ASUMTUKI     ei));
%PUT %SYSFUNC(IFC(&PHOITO = 1 ,    PHOITO     	kyll�, PHOITO	    ei));
%PUT %SYSFUNC(IFC(&TOIMTUKI = 1 ,  TOIMTUKI     kyll�, TOIMTUKI     ei));
%MEND INFO;

%INFO;

/* 7. Palautetaan OUT-makromuuttujan arvoksi 0 */

%LET OUT = 0;

