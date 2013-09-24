/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyˆdynt‰‰ Tilastokeskuksen yleisten
* k‰yttˆehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto p‰‰hakemistossa.
******************************************************************************/

/*******************************************************************
*  Kuvaus: Tuloverotuksen simuloinninapumakroja          		   * 
*  Tekij‰: Pertti Honkanen / Kela                                  *
*  Luotu: 12.09.2011                                               *
*  Viimeksi p‰ivitetty: 7.2.2012 							       * 
*  P‰ivitt‰j‰: Filip Kjellberg, Pertti Honkanen / Kela             *
********************************************************************/


/* 1. SISƒLLYS */

/* Tiedosto sis‰lt‰‰ seuraavat makrot */

/*
2.1 Parametrien hakua ohjaavia makroja
2.2 HaeParam_VeroSIMUL = Makro, joka tekee VERO-mallin parametreista makromuuttujia, simulointilaskelmat
2.3 HaeParam_VeroESIM = Makro, joka tekee VERO-mallin parametreista makromuuttujia, esimerkkilaskelmat
2.4.HaeParam_VarallVero_ESIM = Makro, joka tekee VERO-mallin varallisuusveroasteikon parametreista makromuuttujia, esimerkkilaskelmiin
3.1 KunnVerKerroin = Makro, jonka avulla tuotetaan kunnallisen ja kirkollisen veroprosentin muuntamiseen tarvittavat kertoimet
3.2 VahennysSwap = Makro, jonka avulla v‰hennyksi‰ siirret‰‰n puolisoiden kesken veromallissa
3.3 Tarkkuus = Makro tarkkuusvertailua varten VERO-mallissa
3.4 pyoristyssXXmk/e = Apumakroja pyˆristykseen VERO-mallissa (l‰hinn‰ el‰ketulov‰hennyksi‰ varten)
*/


/* 2. Parametrien muuttaminen makromuuttujiksi */

/* 2.1 Makrot, jotka vaikuttavat siihen, miten kussakin lakimakrossa haetaan parametrit. 
	   Jos tyyppi = ESIM, parametrit haetaan joka makrokutsulla erikseen.
	   Muuten parametrit on haettava makromuuttujiksi ennen simulointi-data-askeeleen ajamista. */

*Makrojen parametrit:
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi ;

%MACRO HAKU/STORE;
%IF &TYYPPI = ESIM %THEN %DO;
%HaeParam_VeroESIM(&mvuosi, &minf);
%END;
%MEND HAKU;


%MACRO HAKU1/STORE;
%IF &TYYPPI = ESIM  %THEN %DO;
%HaeParam_VeroESIM(&mvuosi, 1);
%END;
%MEND HAKU1;


%MACRO HAKUVV/STORE;
%IF &TYYPPI = ESIM  %THEN %DO;
%HaeParam_VarallVero_ESIM (&mvuosi, &minf);
%END;
%MEND HAKUVV;

/* 2.2 Makro, joka hakee halutun vuoden parametrit ja tekee niist‰ makromuuttujat.
	   Jos vuosi, jota tarjotaan ei esiinny parametritaulukossa, valitaan l‰hin mahdollinen ajankohta.
       T‰m‰ makro on itsen‰isesti toimiva makro, jota voi k‰ytt‰‰ myˆs data-askeleen ulkopuolella. 
	   Makroa k‰ytet‰‰n varsinaisissa simulointilaskelmissa (tyyppi = SIMUL). 
	   Inflaatio- ja valuuttakurssimuunnokset tehd‰‰n t‰ss‰ vaiheessa */

* Makron parametrit:
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi ;

%MACRO HaeParam_VeroSIMUL (mvuosi, minf)/STORE
DES = 'VERO, SIMUL: Makro, joka tekee VERO-mallin parametreista makromuuttujia, simulointilaskelmat';

%LET valuutta = %SYSFUNC(IFN(&mvuosi < 2002, &euro, 1));

%LET taulua = %SYSFUNC(OPEN(PARAM.&PVERO, i));
%SYSCALL SET(taulua);
%LET w = %SYSFUNC(FETCH(&taulua));
%IF &mvuosi >= %SYSFUNC(GETVARN(&taulua, 1)) %THEN;
%ELSE %DO %UNTIL (%SYSFUNC(GETVARN(&taulua, 1)) = &mvuosi OR &w = -1);
	%LET w = %SYSFUNC(FETCH(&taulua));
%END;
%LET w = %SYSFUNC(CLOSE(&taulua));

%LET taulue = %SYSFUNC(OPEN(PARAM.&PVERO_VARALL, i));
%SYSCALL SET(taulue);
%LET w = %SYSFUNC(FETCH(&taulue));
%IF &mvuosi >= %SYSFUNC(GETVARN(&taulue, 1)) %THEN;
%ELSE %DO %UNTIL (%SYSFUNC(GETVARN(&taulue, 1)) = &mvuosi OR &w = -1);
	%LET w = %SYSFUNC(FETCH(&taulue));
%END;
%LET w = %SYSFUNC(CLOSE(&taulue));

%LET YleAlaRaja = (&YleAlaRaja / &valuutta) * &minf;
%LET YleYlaRaja = (&YleYlaRaja / &valuutta) * &minf;

%LET MatkYlaraja = (&MatkYlaraja / &valuutta) * &minf;
%LET MatkOmaVast = (&MatkOmaVast / &valuutta) * &minf;
%LET TulonHankk = (&TulonHankk / &valuutta) * &minf;
%LET KelaYks = (&KelaYks / &valuutta) * &minf;
%LET KelaPuol = (&KelaPuol / &valuutta) * &minf;
%LET ValtAlaraja = (&ValtAlaraja / &valuutta) * &minf;
%LET KunnAnsEnimm = (&KunnAnsEnimm / &valuutta) * &minf;
%LET KunnAnsRaja1 = (&KunnAnsRaja1 / &valuutta) * &minf;
%LET KunnAnsRaja2 = (&KunnAnsRaja2 / &valuutta) * &minf;
%LET KunnAnsRaja3 = (&KunnAnsRaja3 / &valuutta) * &minf;
%LET KunnPerEnimm = (&KunnPerEnimm / &valuutta) * &minf;
%LET ValtLapsiVah = (&ValtLapsiVah / &valuutta) * &minf;
%LET KunnLapsiVah = (&KunnLapsiVah / &valuutta) * &minf;
%LET KunnYksHuoltVah = (&KunnYksHuoltVah / &valuutta) * &minf;
%LET KorSVMaksuRaja = (&KorSVMaksuRaja / &valuutta) * &minf;
%LET AlijYlaRaja = (&AlijYlaRaja / &valuutta) * &minf;
%LET AlijLapsiKor = (&AlijLapsiKor / &valuutta) * &minf;
%LET AlijKulLuot = (&AlijKulLuot / &valuutta) * &minf;
%LET KunnInvVah = (&KunnInvVah / &valuutta) * &minf;
%LET ValtInvVah = (&ValtInvVah / &valuutta) * &minf;
%LET OpRahVah = (&OpRahVah / &valuutta) * &minf;
%LET ValtElVelvVah = (&ValtElVelvVah / &valuutta) * &minf;
%LET VerMaksAlentEnimm = (&VerMaksAlentEnimm / &valuutta) * &minf;
%LET KotitVahEnimm = (&KotitVahEnimm / &valuutta) * &minf;
%LET KotitVahAlaRaja = (&KotitVahAlaRaja / &valuutta) * &minf;
%LET VarAlaRaja = (&VarAlaRaja / &valuutta) * &minf;
%LET VarVakio = (&VarVakio / &valuutta) * &minf;
%LET VarPuolVah = (&VarPuolVah / &valuutta) * &minf;
%LET VarLapsiVah = (&VarLapsiVah / &valuutta) * &minf;
%LET VakAs = (&VakAs / &valuutta) * &minf;
%LET VapEhtRaja1 = (&VapEhtRaja1 / &valuutta) * &minf;
%LET VapEhtRaja2 = (&VapEhtRaja2 / &valuutta) * &minf;
%LET VapEhtRaja3 = (&VapEhtRaja3 / &valuutta) * &minf;
%LET SairKulOmaVast = (&SairKulOmaVast / &valuutta) * &minf;
%LET SairKulYlaRaja = (&SairKulYlaRaja / &valuutta) * &minf;
%LET SairKulLapsiVah = (&SairKulLapsiVah / &valuutta) * &minf;
%LET TulonHankkAlaRaja = (&TulonHankkAlaRaja / &valuutta) * &minf;
%LET PalkVahYlaraja = (&PalkVahYlaraja / &valuutta) * &minf;
%LET ValtYhVahYlaraja = (&ValtYhVahYlaraja / &valuutta) * &minf;
%LET ValtPuolVahYlaRaja = (&ValtPuolVahYlaRaja / &valuutta) * &minf;
%LET ValtPuolVahKorotus = (&ValtPuolVahKorotus / &valuutta) * &minf;
%LET KunnElVelvVah = (&KunnElVelvVah / &valuutta) * &minf;
%LET KunnLapsVah2 = (&KunnLapsVah2 / &valuutta) * &minf;
%LET KunnLapsVah3 = (&KunnLapsVah3 / &valuutta) * &minf;
%LET KunnLapsVah4 = (&KunnLapsVah4 / &valuutta) * &minf;
%LET KunnLapsVahMuu = (&KunnLapsVahMuu / &valuutta) * &minf;
%LET KunnOpiskVah = (&KunnOpiskVah / &valuutta) * &minf;
%LET KunnVanhVah = (&KunnVanhVah / &valuutta) * &minf;
%LET ValtTyotVahYlaRaja = (&ValtTyotVahYlaRaja / &valuutta) * &minf;
%LET ValtKoulVah = (&ValtKoulVah / &valuutta) * &minf;
%LET ValtLapsKorotus = (&ValtLapsKorotus / &valuutta) * &minf;
%LET ValtHuoltVah1 = (&ValtHuoltVah1 / &valuutta) * &minf;
%LET ValtHuoltVah2 = (&ValtHuoltVah2 / &valuutta) * &minf;
%LET ValtHuoltVah3 = (&ValtHuoltVah3 / &valuutta) * &minf;
%LET ValtHuoltVah4 = (&ValtHuoltVah4 / &valuutta) * &minf;
%LET ValtHuoltVahMuu = (&ValtHuoltVahMuu / &valuutta) * &minf;
%LET OmVahRaja1 = (&OmVahRaja1 / &valuutta) * &minf;
%LET OmVahRaja2 = (&OmVahRaja2 / &valuutta) * &minf;
%LET OmVahEiVuokraRaja = (&OmVahEiVuokraRaja / &valuutta) * &minf;
%LET OmVahKorkoRaja = (&OmVahKorkoRaja / &valuutta) * &minf;
%LET KorkoVahYlaRaja = (&KorkoVahYlaRaja / &valuutta) * &minf;
%LET KorkoVahYlaRajaMuut = (&KorkoVahYlaRajaMuut / &valuutta) * &minf;
%LET KorkoVahYlaRajaMuutPuol = (&KorkoVahYlaRajaMuutPuol / &valuutta) * &minf;
%LET KorkoVahOmaVast = (&KorkoVahOmaVast / &valuutta) * &minf;
%LET KorkoVahPuolisot = (&KorkoVahPuolisot / &valuutta) * &minf;
%LET KorkoVahLapsiKor1 = (&KorkoVahLapsiKor1 / &valuutta) * &minf;
%LET KorkoVahLapsiKor2 = (&KorkoVahLapsiKor2 / &valuutta) * &minf;
%LET ValtVanhVah = (&ValtVanhVah / &valuutta) * &minf;
%LET PuolPORaja = (&PuolPORaja / &valuutta) * &minf;
%LET TyotMatkOmVast = (&TyotMatkOmVast / &valuutta) * &minf;
%LET MatkOmVastVahimm = (&MatkOmVastVahimm / &valuutta) * &minf;
%LET ValtAnsAlaRaja = (&ValtAnsAlaRaja / &valuutta) * &minf;
%LET ValtAnsEnimm = (&ValtAnsEnimm / &valuutta) * &minf;
%LET ValtAnsYlaRaja = (&ValtAnsYlaRaja / &valuutta) * &minf;
%LET OpLainaVahRaja = (&OpLainaVahRaja / &valuutta) * &minf;
%LET TyoAsVah = (&TyoAsVah / &valuutta) * &minf;
%LET LahjVahVahimm = (&LahjVahVahimm / &valuutta) * &minf;
%LET LahjVahEnimm = (&LahjVahEnimm / &valuutta) * &minf;
%LET ElLisaVRaja = (&ElLisaVRaja / &valuutta) * &minf;
%LET HenkYhtVapRaja = (&HenkYhtVapRaja / &valuutta) * &minf;
%LET PORaja2 = (&PORaja / &valuutta) * &minf;
%LET Raja1 = (&Raja1 / &valuutta) * &minf;
%LET Raja2 = (&Raja2 / &valuutta) * &minf;
%LET Raja3 = (&Raja3 / &valuutta) * &minf;
%LET Raja4 = (&Raja4 / &valuutta) * &minf;
%LET Raja5 = (&Raja5 / &valuutta) * &minf;
%LET Raja6 = (&Raja6 / &valuutta) * &minf;
%LET Raja7 = (&Raja7 / &valuutta) * &minf;
%LET Raja8 = (&Raja8 / &valuutta) * &minf;
%LET Raja9 = (&Raja9 / &valuutta) * &minf;
%LET Raja10 = (&Raja10 / &valuutta) * &minf;
%LET Raja11 = (&Raja11 / &valuutta) * &minf;
%LET Raja12 = (&Raja12 / &valuutta) * &minf;
%LET Vakio1 = (&Vakio1 / &valuutta) * &minf;
%LET Vakio2 = (&Vakio2 / &valuutta) * &minf;
%LET Vakio3 = (&Vakio3 / &valuutta) * &minf;
%LET Vakio4 = (&Vakio4 / &valuutta) * &minf;
%LET Vakio5 = (&Vakio5 / &valuutta) * &minf;
%LET Vakio6 = (&Vakio6 / &valuutta) * &minf;
%LET Vakio7 = (&Vakio7 / &valuutta) * &minf;
%LET Vakio8 = (&Vakio8 / &valuutta) * &minf;
%LET Vakio9 = (&Vakio9 / &valuutta) * &minf;
%LET Vakio10 = (&Vakio10 / &valuutta) * &minf;
%LET Vakio11 = (&Vakio11 / &valuutta) * &minf;
%LET Vakio12 = (&Vakio12 / &valuutta) * &minf;
%LET VarRaja1 = &minf * &VarRaja1/&valuutta;
%LET VarRaja2 = &minf * &VarRaja2/&valuutta;
%LET VarRaja3 = &minf * &VarRaja3/&valuutta;
%LET VarRaja4 = &minf * &VarRaja4/&valuutta;
%LET VarRaja5 = &minf * &VarRaja5/&valuutta;
%LET VarRaja6 = &minf * &VarRaja6/&valuutta;
%LET VarVakio1 = &minf * &VarVakio1/&valuutta;
%LET VarVakio2 = &minf * &VarVakio2/&valuutta;
%LET VarVakio3 = &minf * &VarVakio3/&valuutta;
%LET VarVakio4 = &minf * &VarVakio4/&valuutta;
%LET VarVakio5 = &minf * &VarVakio5/&valuutta;
%LET VarVakio6 = &minf * &VarVakio6/&valuutta;

%MEND HaeParam_VeroSIMUL;

/* 2.3 T‰m‰ makro tekee saman asian kuin edellinen (pl. valtionveroasteikko), mutta se toimii vain osana data-askelta.
       Makro luo useita muuttujia data-taulukkoon. Makroa k‰ytet‰‰n esimerkkilaskelmissa (tyyppi = ESIM).
	   Inflaatio- ja valuuttakurssimuunnokset tehd‰‰n t‰ss‰ vaiheessa */

* Makron parametrit:
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi ;

%MACRO HaeParam_VeroESIM (mvuosi, minf)/STORE
DES = 'VERO, ESIM: Makro, joka tekee VERO-mallin parametreista makromuuttujia, esimerkkilaskelmat';

%IF &TYYPPI = ESIM %THEN %DO;

	%LET valuutta = IFN(&mvuosi < 2002, &euro,  1);
	IF _N_ = 1 OR taulua = . THEN taulua = OPEN ("PARAM.&PVERO", "i");
	RETAIN taulua;
	X = REWIND(taulua);
	X = FETCHOBS(taulua, 1);
	IF GETVARN(taulua, 1) <= &mvuosi THEN;
	ELSE DO UNTIL (GETVARN(taulua, 1) = &mvuosi OR X = -1);
		X = FETCH(taulua);
	END;
	IF X = -1 THEN DO;
		%LET riveja = ATTRN(taulua, "NLOBS");
		X = FETCHOBS(taulua, &riveja);
	END;

	/* Ensin monetaariset parametrit */

	%LET YleAlaRaja = (GETVARN(taulua, VARNUM(taulua, 'YleAlaRaja')) / &valuutta) * &minf ;
	%LET YleYlaRaja = (GETVARN(taulua, VARNUM(taulua, 'YleYlaRaja')) / &valuutta) * &minf ;

	%LET MatkYlaraja = (GETVARN(taulua, VARNUM(taulua, 'MatkYlaraja')) / &valuutta) * &minf ;
	%LET MatkOmaVast = (GETVARN(taulua, VARNUM(taulua, 'MatkOmaVast')) / &valuutta) * &minf ;
	%LET TulonHankk = (GETVARN(taulua, VARNUM(taulua, 'TulonHankk')) / &valuutta) * &minf ;
	%LET KelaYks = (GETVARN(taulua, VARNUM(taulua, 'KelaYks')) / &valuutta) * &minf ;
	%LET KelaPuol = (GETVARN(taulua, VARNUM(taulua, 'KelaPuol')) / &valuutta) * &minf ;
	%LET ValtAlaraja = (GETVARN(taulua, VARNUM(taulua, 'ValtAlaraja')) / &valuutta) * &minf ;
	%LET KunnAnsEnimm = (GETVARN(taulua, VARNUM(taulua, 'KunnAnsEnimm')) / &valuutta) * &minf ;
	%LET KunnAnsRaja1 = (GETVARN(taulua, VARNUM(taulua, 'KunnAnsRaja1')) / &valuutta) * &minf ;
	%LET KunnAnsRaja2 = (GETVARN(taulua, VARNUM(taulua, 'KunnAnsRaja2')) / &valuutta) * &minf ;
	%LET KunnAnsRaja3 = (GETVARN(taulua, VARNUM(taulua, 'KunnAnsRaja3')) / &valuutta) * &minf ;
	%LET KunnPerEnimm = (GETVARN(taulua, VARNUM(taulua, 'KunnPerEnimm')) / &valuutta) * &minf ;
	%LET ValtLapsiVah = (GETVARN(taulua, VARNUM(taulua, 'ValtLapsiVah')) / &valuutta) * &minf ;
	%LET KunnLapsiVah = (GETVARN(taulua, VARNUM(taulua, 'KunnLapsiVah')) / &valuutta) * &minf ;
	%LET KunnYksHuoltVah = (GETVARN(taulua, VARNUM(taulua, 'KunnYksHuoltVah')) / &valuutta) * &minf ;
	%LET KorSVMaksuRaja = (GETVARN(taulua, VARNUM(taulua, 'KorSVMaksuRaja')) / &valuutta) * &minf ;
	%LET AlijYlaRaja = (GETVARN(taulua, VARNUM(taulua, 'AlijYlaRaja')) / &valuutta) * &minf ;
	%LET AlijLapsiKor = (GETVARN(taulua, VARNUM(taulua, 'AlijLapsiKor')) / &valuutta) * &minf ;
	%LET AlijKulLuot = (GETVARN(taulua, VARNUM(taulua, 'AlijKulLuot')) / &valuutta) * &minf ;
	%LET KunnInvVah = (GETVARN(taulua, VARNUM(taulua, 'KunnInvVah')) / &valuutta) * &minf ;
	%LET ValtInvVah = (GETVARN(taulua, VARNUM(taulua, 'ValtInvVah')) / &valuutta) * &minf ;
	%LET OpRahVah = (GETVARN(taulua, VARNUM(taulua, 'OpRahVah')) / &valuutta) * &minf ;
	%LET ValtElVelvVah = (GETVARN(taulua, VARNUM(taulua, 'ValtElVelvVah')) / &valuutta) * &minf ;
	%LET VerMaksAlentEnimm = (GETVARN(taulua, VARNUM(taulua, 'VerMaksAlentEnimm')) / &valuutta) * &minf ;
	%LET KotitVahEnimm = (GETVARN(taulua, VARNUM(taulua, 'KotitVahEnimm')) / &valuutta) * &minf ;
	%LET KotitVahAlaRaja = (GETVARN(taulua, VARNUM(taulua, 'KotitVahAlaRaja')) / &valuutta) * &minf ;
	%LET VarAlaRaja = (GETVARN(taulua, VARNUM(taulua, 'VarAlaRaja')) / &valuutta) * &minf ;
	%LET VarVakio = (GETVARN(taulua, VARNUM(taulua, 'VarVakio')) / &valuutta) * &minf ;
	%LET VarPuolVah = (GETVARN(taulua, VARNUM(taulua, 'VarPuolVah')) / &valuutta) * &minf ;
	%LET VarLapsiVah = (GETVARN(taulua, VARNUM(taulua, 'VarLapsiVah')) / &valuutta) * &minf ;
	%LET VakAs = (GETVARN(taulua, VARNUM(taulua, 'VakAs')) / &valuutta) * &minf ;
	%LET VapEhtRaja1 = (GETVARN(taulua, VARNUM(taulua, 'VapEhtRaja1')) / &valuutta) * &minf ;
	%LET VapEhtRaja2 = (GETVARN(taulua, VARNUM(taulua, 'VapEhtRaja2')) / &valuutta) * &minf ;
	%LET VapEhtRaja3 = (GETVARN(taulua, VARNUM(taulua, 'VapEhtRaja3')) / &valuutta) * &minf ;
	%LET SairKulOmaVast = (GETVARN(taulua, VARNUM(taulua, 'SairKulOmaVast')) / &valuutta) * &minf ;
	%LET SairKulYlaRaja = (GETVARN(taulua, VARNUM(taulua, 'SairKulYlaRaja')) / &valuutta) * &minf ;
	%LET SairKulLapsiVah = (GETVARN(taulua, VARNUM(taulua, 'SairKulLapsiVah')) / &valuutta) * &minf ;
	%LET TulonHankkAlaRaja = (GETVARN(taulua, VARNUM(taulua, 'TulonHankkAlaRaja')) / &valuutta) * &minf ;
	%LET PalkVahYlaraja = (GETVARN(taulua, VARNUM(taulua, 'PalkVahYlaraja')) / &valuutta) * &minf ;
	%LET ValtYhVahYlaraja = (GETVARN(taulua, VARNUM(taulua, 'ValtYhVahYlaraja')) / &valuutta) * &minf ;
	%LET ValtPuolVahYlaRaja = (GETVARN(taulua, VARNUM(taulua, 'ValtPuolVahYlaRaja')) / &valuutta) * &minf ;
	%LET ValtPuolVahKorotus = (GETVARN(taulua, VARNUM(taulua, 'ValtPuolVahKorotus')) / &valuutta) * &minf ;
	%LET KunnElVelvVah = (GETVARN(taulua, VARNUM(taulua, 'KunnElVelvVah')) / &valuutta) * &minf ;
	%LET KunnLapsVah2 = (GETVARN(taulua, VARNUM(taulua, 'KunnLapsVah2')) / &valuutta) * &minf ;
	%LET KunnLapsVah3 = (GETVARN(taulua, VARNUM(taulua, 'KunnLapsVah3')) / &valuutta) * &minf ;
	%LET KunnLapsVah4 = (GETVARN(taulua, VARNUM(taulua, 'KunnLapsVah4')) / &valuutta) * &minf ;
	%LET KunnLapsVahMuu = (GETVARN(taulua, VARNUM(taulua, 'KunnLapsVahMuu')) / &valuutta) * &minf ;
	%LET KunnOpiskVah = (GETVARN(taulua, VARNUM(taulua, 'KunnOpiskVah')) / &valuutta) * &minf ;
	%LET KunnVanhVah = (GETVARN(taulua, VARNUM(taulua, 'KunnVanhVah')) / &valuutta) * &minf ;
	%LET ValtTyotVahYlaRaja = (GETVARN(taulua, VARNUM(taulua, 'ValtTyotVahYlaRaja')) / &valuutta) * &minf ;
	%LET ValtKoulVah = (GETVARN(taulua, VARNUM(taulua, 'ValtKoulVah')) / &valuutta) * &minf ;
	%LET ValtLapsKorotus = (GETVARN(taulua, VARNUM(taulua, 'ValtLapsKorotus')) / &valuutta) * &minf ;
	%LET ValtHuoltVah1 = (GETVARN(taulua, VARNUM(taulua, 'ValtHuoltVah1')) / &valuutta) * &minf ;
	%LET ValtHuoltVah2 = (GETVARN(taulua, VARNUM(taulua, 'ValtHuoltVah2')) / &valuutta) * &minf ;
	%LET ValtHuoltVah3 = (GETVARN(taulua, VARNUM(taulua, 'ValtHuoltVah3')) / &valuutta) * &minf ;
	%LET ValtHuoltVah4 = (GETVARN(taulua, VARNUM(taulua, 'ValtHuoltVah4')) / &valuutta) * &minf ;
	%LET ValtHuoltVahMuu = (GETVARN(taulua, VARNUM(taulua, 'ValtHuoltVahMuu'))/&valuutta) * &minf ;
	%LET OmVahRaja1 = (GETVARN(taulua, VARNUM(taulua, 'OmVahRaja1')) / &valuutta) * &minf ;
	%LET OmVahRaja2 = (GETVARN(taulua, VARNUM(taulua, 'OmVahRaja2')) / &valuutta) * &minf ;
	%LET OmVahEiVuokraRaja = (GETVARN(taulua, VARNUM(taulua, 'OmVahEiVuokraRaja')) / &valuutta) * &minf ;
	%LET OmVahKorkoRaja = GETVARN(taulua, VARNUM(taulua, 'OmVahKorkoRaja')) / &valuutta) * &minf ;
	%LET KorkoVahYlaRaja = (GETVARN(taulua, VARNUM(taulua, 'KorkoVahYlaRaja')) / &valuutta) * &minf ;
	%LET KorkoVahYlaRajaMuut = (GETVARN(taulua, VARNUM(taulua, 'KorkoVahYlaRajaMuut')) / &valuutta) * &minf ;
	%LET KorkoVahYlaRajaMuutPuol = (GETVARN(taulua, VARNUM(taulua, 'KorkoVahYlaRajaMuutPuol')) / &valuutta) * &minf ;
	%LET KorkoVahOmaVast = (GETVARN(taulua, VARNUM(taulua, 'KorkoVahOmaVast')) / &valuutta) * &minf ;
	%LET KorkoVahPuolisot = (GETVARN(taulua, VARNUM(taulua, 'KorkoVahPuolisot')) / &valuutta) * &minf ;
	%LET KorkoVahLapsiKor1 = (GETVARN(taulua, VARNUM(taulua, 'KorkoVahLapsiKor1')) / &valuutta) * &minf ;
	%LET KorkoVahLapsiKor2 = (GETVARN(taulua, VARNUM(taulua, 'KorkoVahLapsiKor2')) / &valuutta) * &minf ;
	%LET ValtVanhVah = (GETVARN(taulua, VARNUM(taulua, 'ValtVanhVah')) / &valuutta) * &minf ;
	%LET PuolPORaja = (GETVARN(taulua, VARNUM(taulua, 'PuolPORaja')) / &valuutta) * &minf ;
	%LET TyotMatkOmVast = (GETVARN(taulua, VARNUM(taulua, 'TyotMatkOmVast')) / &valuutta) * &minf ;
	%LET MatkOmVastVahimm = (GETVARN(taulua, VARNUM(taulua, 'MatkOmVastVahimm')) / &valuutta) * &minf ;
	%LET ValtAnsAlaRaja = (GETVARN(taulua, VARNUM(taulua, 'ValtAnsAlaRaja')) / &valuutta) * &minf ;
	%LET ValtAnsEnimm = (GETVARN(taulua, VARNUM(taulua, 'ValtAnsEnimm')) / &valuutta) * &minf ;
	%LET ValtAnsYlaRaja = (GETVARN(taulua, VARNUM(taulua, 'ValtAnsYlaRaja')) / &valuutta) * &minf ;
	%LET OpLainaVahRaja = (GETVARN(taulua, VARNUM(taulua, 'OpLainaVahRaja')) / &valuutta) * &minf ;
	%LET TyoAsVah = (GETVARN(taulua, VARNUM(taulua, 'TyoAsVah')) / &valuutta) * &minf ;
	%LET LahjVahVahimm = (GETVARN(taulua, VARNUM(taulua, 'LahjVahVahimm')) / &valuutta) * &minf ;
	%LET LahjVahEnimm = (GETVARN(taulua, VARNUM(taulua, 'LahjVahEnimm')) / &valuutta) * &minf ;
	%LET PORaja = (GETVARN(taulua, VARNUM(taulua, 'PORaja')) / &valuutta) * &minf ;
	%LET ElLisaVRaja = (GETVARN(taulua, VARNUM(taulua, 'ElLisaVRaja')) / &valuutta) * &minf  ; 
	%LET HenkYhtVapRaja = (GETVARN(taulua, VARNUM(taulua, 'HenkYhtVapRaja')) / &valuutta) * &minf ;

	%LET Raja1 = (GETVARN(taulua, VARNUM(taulua, 'Raja1')) / &valuutta) * &minf ;
	%LET Raja2 = (GETVARN(taulua, VARNUM(taulua, 'Raja2')) / &valuutta) * &minf ;
	%LET Raja3 = (GETVARN(taulua, VARNUM(taulua, 'Raja3')) / &valuutta) * &minf ;
	%LET Raja4 = (GETVARN(taulua, VARNUM(taulua, 'Raja4')) / &valuutta) * &minf ;
	%LET Raja5 = (GETVARN(taulua, VARNUM(taulua, 'Raja5')) / &valuutta) * &minf ;
	%LET Raja6 = (GETVARN(taulua, VARNUM(taulua, 'Raja6')) / &valuutta) * &minf ;
	%LET Raja7 = (GETVARN(taulua, VARNUM(taulua, 'Raja7')) / &valuutta) * &minf ;
	%LET Raja8 = (GETVARN(taulua, VARNUM(taulua, 'Raja8')) / &valuutta) * &minf ;
	%LET Raja9 = (GETVARN(taulua, VARNUM(taulua, 'Raja9')) / &valuutta) * &minf ;
	%LET Raja10 = (GETVARN(taulua, VARNUM(taulua, 'Raja10')) / &valuutta) * &minf ;
	%LET Raja11 = (GETVARN(taulua, VARNUM(taulua, 'Raja11')) / &valuutta) * &minf ;
	%LET Raja12 = (GETVARN(taulua, VARNUM(taulua, 'Raja12')) / &valuutta) * &minf ;

	%LET Vakio1 = (GETVARN(taulua, VARNUM(taulua, 'Vakio1')) / &valuutta) * &minf ;
	%LET Vakio2 = (GETVARN(taulua, VARNUM(taulua, 'Vakio2')) / &valuutta) * &minf ;
	%LET Vakio3 = (GETVARN(taulua, VARNUM(taulua, 'Vakio3')) / &valuutta) * &minf ;
	%LET Vakio4 = (GETVARN(taulua, VARNUM(taulua, 'Vakio4')) / &valuutta) * &minf ;
	%LET Vakio5 = (GETVARN(taulua, VARNUM(taulua, 'Vakio5')) / &valuutta) * &minf ;
	%LET Vakio6 = (GETVARN(taulua, VARNUM(taulua, 'Vakio6')) / &valuutta) * &minf ;
	%LET Vakio7 = (GETVARN(taulua, VARNUM(taulua, 'Vakio7')) / &valuutta) * &minf ;
	%LET Vakio8 = (GETVARN(taulua, VARNUM(taulua, 'Vakio8')) / &valuutta) * &minf ;
	%LET Vakio9 = (GETVARN(taulua, VARNUM(taulua, 'Vakio9')) / &valuutta) * &minf ;
	%LET Vakio10 = (GETVARN(taulua, VARNUM(taulua, 'Vakio10')) / &valuutta) * &minf ;
	%LET Vakio11 = (GETVARN(taulua, VARNUM(taulua, 'Vakio11')) / &valuutta) * &minf ;
	%LET Vakio12 = (GETVARN(taulua, VARNUM(taulua, 'Vakio12')) / &valuutta) * &minf ;

	/* Skalaaariparametrit  */

    %LET YlePros = GETVARN(taulua, VARNUM(taulua, 'YlePros'));
    %LET YleIkaRaja = GETVARN(taulua, VARNUM(taulua, 'YleIkaRaja'));

	%LET TulonHankPros = GETVARN(taulua, VARNUM(taulua, 'TulonHankPros'));
	%LET ValtElKerr = GETVARN(taulua, VARNUM(taulua, 'ValtElKerr'));
	%LET ValtElPros = GETVARN(taulua, VARNUM(taulua, 'ValtElPros'));
	%LET KunnElKerr = GETVARN(taulua, VARNUM(taulua, 'KunnElKerr'));
	%LET KunnElPros = GETVARN(taulua, VARNUM(taulua, 'KunnElPros'));
	%LET EnsAsKor = GETVARN(taulua, VARNUM(taulua, 'EnsAsKor'));
	%LET SvPros = GETVARN(taulua, VARNUM(taulua, 'SvPros'));
	%LET KevPros = GETVARN(taulua, VARNUM(taulua, 'KevPros'));
	%LET SvKorotus = GETVARN(taulua, VARNUM(taulua, 'SvKorotus'));
	%LET YhtHyvPros = GETVARN(taulua, VARNUM(taulua, 'YhtHyvPros'));
	%LET PaaomaVeroPros = GETVARN(taulua, VARNUM(taulua, 'PaaomaVeroPros'));
	%LET ElVakMaksu = GETVARN(taulua, VARNUM(taulua, 'ElVakMaksu'));
	%LET TyotVakMaksu = GETVARN(taulua, VARNUM(taulua, 'TyotVakMaksu'));
	%LET ElKorSvMaksu = GETVARN(taulua, VARNUM(taulua, 'ElKorSvMaksu'));
	%LET ElKorKevMaksu = GETVARN(taulua, VARNUM(taulua, 'ElKorKevMaksu'));
	%LET KunnAnsPros1 = GETVARN(taulua, VARNUM(taulua, 'KunnAnsPros1'));
	%LET KunnAnsPros2 = GETVARN(taulua, VARNUM(taulua, 'KunnAnsPros2'));
	%LET KunnAnsPros3 = GETVARN(taulua, VARNUM(taulua, 'KunnAnsPros3'));
	%LET KunnPerPros = GETVARN(taulua, VARNUM(taulua, 'KunnPerPros'));
	%LET OpRahPros = GETVARN(taulua, VARNUM(taulua, 'OpRahPros'));
	%LET ElVakMaksu53 = GETVARN(taulua, VARNUM(taulua, 'ElVakMaksu53'));
	%LET Kattovero = GETVARN(taulua, VARNUM(taulua, 'Kattovero'));
	%LET ValtAlijOsuus = GETVARN(taulua, VARNUM(taulua, 'ValtAlijOsuus'));
	%LET ValtPuolVahPros = GETVARN(taulua, VARNUM(taulua, 'ValtPuolVahPros'));
	%LET ValtTyotVahPros = GETVARN(taulua, VARNUM(taulua, 'ValtTyotVahPros'));
	%LET ValtYhPros = GETVARN(taulua, VARNUM(taulua, 'ValtYhPros'));
	%LET ValtLapsPros = GETVARN(taulua, VARNUM(taulua, 'ValtLapsPros'));
	%LET PalkVahPros = GETVARN(taulua, VARNUM(taulua, 'PalkVahPros'));
	%LET KeskKunnPros = GETVARN(taulua, VARNUM(taulua, 'KeskKunnPros'));
	%LET OmVahPros = GETVARN(taulua, VARNUM(taulua, 'OmVahPros'));
	%LET KorkoVahPros = GETVARN(taulua, VARNUM(taulua, 'KorkoVahPros'));
	%LET VarPros = GETVARN(taulua, VARNUM(taulua, 'VarPros'));
	%LET VapEhtAnsioRaja = GETVARN(taulua, VARNUM(taulua, 'VapEhtAnsioRaja'));
	%LET VapEhtPros2 = GETVARN(taulua, VARNUM(taulua, 'VapEhtPros2'));
	%LET VarallKattoPros = GETVARN(taulua, VARNUM(taulua, 'VarallKattoPros'));
	%LET POOsuus = GETVARN(taulua, VARNUM(taulua, 'POOsuus'));
	%LET OsPOOsuus = GETVARN(taulua, VARNUM(taulua, 'OsPOOsuus'));
	%LET VaihtPOOsuus = GETVARN(taulua, VARNUM(taulua, 'VaihtPOOsuus'));
	%LET PalkPOOsuus = GETVARN(taulua, VARNUM(taulua, 'PalkPOOsuus'));
	%LET JulkPOOsuus = GETVARN(taulua, VARNUM(taulua, 'JulkPOOsuus'));
	%LET HenkYhtOsVapOsuus = GETVARN(taulua, VARNUM(taulua, 'HenkYhtOsVapOsuus'));
	%LET HenkYhtOsAnsOsuus = GETVARN(taulua, VARNUM(taulua, 'HenkYhtOsAnsOsuus'));
	%LET ValtAnsPros1 = GETVARN(taulua, VARNUM(taulua, 'ValtAnsPros1'));
	%LET ValtAnsPros2 = GETVARN(taulua, VARNUM(taulua, 'ValtAnsPros2'));
	%LET SvPrMaksu = GETVARN(taulua, VARNUM(taulua, 'SvPrMaksu'));
	%LET ElVelvPros = GETVARN(taulua, VARNUM(taulua, 'ElVelvPros'));
	%LET OpLainaVahPros = GETVARN(taulua, VARNUM(taulua, 'OpLainaVahPros'));
	%LET OspKorVeroVap = GETVARN(taulua, VARNUM(taulua, 'OspKorVeroVap'));
	%LET SairVakYrit = GETVARN(taulua, VARNUM(taulua, 'SairVakYrit'));
	%LET KunnElVakio = &minf * GETVARN(taulua, VARNUM(taulua, 'KunnElVakio'));
	%LET KirkVeroPros = GETVARN(taulua, VARNUM(taulua, 'KirkVeroPros'));
	%LET AsKorkoOsuus = GETVARN(taulua, VARNUM(taulua, 'AsKorkoOsuus'));
	%LET POPros2 = GETVARN(taulua, VARNUM(taulua, 'PORaja2'));
	%LET ElLisaVPros = GETVARN(taulua, VARNUM(taulua, 'ElLisaVPros'));

	%LET Pros1 = GETVARN(taulua, VARNUM(taulua, 'Pros1'));
	%LET Pros2 = GETVARN(taulua, VARNUM(taulua, 'Pros2'));
	%LET Pros3 = GETVARN(taulua, VARNUM(taulua, 'Pros3'));
	%LET Pros4 = GETVARN(taulua, VARNUM(taulua, 'Pros4'));
	%LET Pros5 = GETVARN(taulua, VARNUM(taulua, 'Pros5'));
	%LET Pros6 = GETVARN(taulua, VARNUM(taulua, 'Pros6'));
	%LET Pros7 = GETVARN(taulua, VARNUM(taulua, 'Pros7'));
	%LET Pros8 = GETVARN(taulua, VARNUM(taulua, 'Pros8'));
	%LET Pros9 = GETVARN(taulua, VARNUM(taulua, 'Pros9'));
	%LET Pros10 = GETVARN(taulua, VARNUM(taulua, 'Pros10'));
	%LET Pros11 = GETVARN(taulua, VARNUM(taulua, 'Pros11'));
	%LET Pros12 = GETVARN(taulua, VARNUM(taulua, 'Pros12'));

%END;

%MEND HaeParam_VeroESIM;

/* 2.4 Osana data-askelta toimiva makro, joka hakee halutun vuoden varallisuusveroasteikon parametrit 
       ja tekee niist‰ makromuuttujat. 
	   Jos vuosi, jota tarjotaan ei esiinny parametritaulukossa, valitaan l‰hin mahdollinen ajankohta.
	   Makro luo useita muuttujia data-taulukkoon. Makroa k‰ytet‰‰n esimerkkilaskelmissa (tyyppi = ESIM).
	   Inflaatio- ja valuuttakurssimuunnokset tehd‰‰n t‰ss‰ vaiheessa */

* Makron parametrit:
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi ;

%MACRO HaeParam_VarallVero_ESIM (mvuosi, minf)/STORE;

%IF &tyyppi = ESIM %THEN %DO;

	%LET valuutta = IFN(&mvuosi < 2002, &euro,  1);
	IF _N_ = 1 OR taulue = . THEN taulue = OPEN ("PARAM.&PVERO_VARALL" , "i");
	RETAIN taulue;
	X = REWIND(taulue);
	X = FETCHOBS(taulue, 1);
	IF GETVARN(taulue, 1) <= &mvuosi THEN;
	ELSE DO UNTIL (GETVARN(taulue, 1) = &mvuosi OR X = -1);
		X = FETCH(taulue);
	END;
	IF X = -1 THEN DO;
			%LET riveja = ATTRN(taulue, "NLOBS");
		X = FETCHOBS(taulue, &riveja);
	END;

	%LET VarRaja1 = &minf * GETVARN(taulue, VARNUM(taulue, 'VarRaja1'))/&valuutta;
	%LET VarRaja2 = &minf * GETVARN(taulue, VARNUM(taulue, 'VarRaja2'))/&valuutta;
	%LET VarRaja3 = &minf * GETVARN(taulue, VARNUM(taulue, 'VarRaja3'))/&valuutta;
	%LET VarRaja4 = &minf * GETVARN(taulue, VARNUM(taulue, 'VarRaja4'))/&valuutta;
	%LET VarRaja5 = &minf * GETVARN(taulue, VARNUM(taulue, 'VarRaja5'))/&valuutta;
	%LET VarRaja6 = &minf * GETVARN(taulue, VARNUM(taulue, 'VarRaja6'))/&valuutta;
	%LET VarVakio1 = &minf * GETVARN(taulue, VARNUM(taulue, 'VarVakio1'))/&valuutta;
	%LET VarVakio2 = &minf * GETVARN(taulue, VARNUM(taulue, 'VarVakio2'))/&valuutta;
	%LET VarVakio3 = &minf * GETVARN(taulue, VARNUM(taulue, 'VarVakio3'))/&valuutta;
	%LET VarVakio4 = &minf * GETVARN(taulue, VARNUM(taulue, 'VarVakio4'))/&valuutta;
	%LET VarVakio5 = &minf * GETVARN(taulue, VARNUM(taulue, 'VarVakio5'))/&valuutta;
	%LET VarVakio6 = &minf * GETVARN(taulue, VARNUM(taulue, 'VarVakio6'))/&valuutta;
	%LET VarPros1 = GETVARN(taulue, VARNUM(taulue, 'VarPros1'));
	%LET VarPros2 = GETVARN(taulue, VARNUM(taulue, 'VarPros2'));
	%LET VarPros3 = GETVARN(taulue, VARNUM(taulue, 'VarPros3'));
	%LET VarPros4 = GETVARN(taulue, VARNUM(taulue, 'VarPros4'));
	%LET VarPros5 = GETVARN(taulue, VARNUM(taulue, 'VarPros5'));
	%LET VarPros6 = GETVARN(taulue, VARNUM(taulue, 'VarPros6'));
	
%END;
%MEND HaeParam_VarallVero_ESIM;



/* 3 Simuloinnissa tarvittavat apumakrot */

/* 3.1 Makro, jonka avulla tuotetaan kunnallisen ja kirkollisen
	   veroprosentin muuntamiseen tarvittavat kertoimet */

* Makron parametrit:
	ainvuosi: Aineiston perusvuosi 
	lsvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n ;

%MACRO KunnVerKerroin(ainvuosi, lsvuosi)/STORE
DES = 'VERO: Makro, jonka avulla tuotetaan kunnallisen ja kirkollisen
veroprosentin muuntamiseen tarvittavat kertoimet';

PROC MEANS DATA = PARAM.&PVERO MAX MIN NOPRINT;
VAR vuosi;
OUTPUT OUT = VEROVUODET MAX(vuosi) = maxvuosi MIN(vuosi) = minvuosi;
RUN;

DATA _NULL_;
SET VEROVUODET;
CALL SYMPUT ('maxvuosi', maxvuosi);
CALL SYMPUT ('minvuosi', minvuosi);
RUN;

DATA _NULL_;
SET PARAM.&PVERO;
IF vuosi = MIN(MAX(&ainvuosi, &minvuosi), &maxvuosi) THEN DO;
	CALL SYMPUT ('ayria', KeskKunnPros);
	CALL SYMPUT ('kayria', KirkVeroPros);
END;
IF vuosi = MIN(MAX(&lsvuosi, &minvuosi), &maxvuosi) THEN DO;
	CALL SYMPUT  ('ayrib', KeskKunnPros);
	CALL SYMPUT  ('kayrib', KirkVeroPros);
END;
RUN;

%LET KunnKerroin = %SYSEVALF(&ayrib/&ayria);
%LET KirkKerroin = %SYSEVALF(&kayrib/&kayria);

%MEND KunnVerKerroin;


/* 3.2 Makro, jonka avulla v‰hennyksi‰ siirret‰‰n puolisoiden kesken veromallissa */

* Makron parametrit:
	vahennys: Jaettavan v‰hennyksen m‰‰r‰, e/vuosi
	vero: Vero, josta v‰hennys tehd‰‰n, e/vuosi ;

%MACRO VahennysSwap (vahennys, vero)/STORE
DES = 'Makro, jonka avulla v‰hennyksi‰ siirret‰‰n puolisoiden kesken veromallissa';

IF &VAHENNYS.1 > 0 OR &VAHENNYS.2 > 0 THEN DO;
			&VAHENNYS.1FINAL = MIN(&VERO.1, &VAHENNYS.1);
			&VAHENNYS.1SIIRT = MAX(&VAHENNYS.1 - &VERO.1, 0);
			&VAHENNYS.2FINAL = MIN(&VERO.2, &VAHENNYS.2);
			&VAHENNYS.2SIIRT = MAX(&VAHENNYS.2 - &VERO.2, 0);
			&VAHENNYS.1FINAL = &VAHENNYS.1FINAL + &VAHENNYS.2SIIRT;
			&VAHENNYS.2FINAL = &VAHENNYS.2FINAL + &VAHENNYS.1SIIRT;
			*&VERO.1 = MAX(&VERO.1 - &VAHENNYS.1FINAL, 0);
			*&VERO.2 = MAX(&VERO.2 - &VAHENNYS.2FINAL, 0);
END;
ELSE DO;
	&VAHENNYS.1FINAL = 0;
	&VAHENNYS.2FINAL = 0;
END;
%MEND VahennysSwap;


/* 3.3 Makro tarkkuusvertailua varten VERO-mallissa */

%MACRO Tarkkuus/STORE
DES = 'VERO: Makro tarkkuusvertailua varten VERO-mallissa';

%IF &TARKKUUS = 1 %THEN %DO;

		DATA TARKKUUS (keep = hnro ykor ABS0 ABS1 ABS10 ABS100 ABS1000 ABS10000 ABS100000 ABSyli100000);
		SET UUSIMALL.DVERO;
		ABS0 = IFN(kaikkiverot = kaikkiverot_data, 1, 0);
		ABS1 = IFN(ABS(kaikkiverot - kaikkiverot_data) <= 1 AND ABS(kaikkiverot - kaikkiverot_data) > 0, 1, 0);
		ABS10 = IFN(ABS(kaikkiverot - kaikkiverot_data) <= 10 AND ABS(kaikkiverot - kaikkiverot_data) > 1, 1, 0);
		ABS100 = IFN(ABS(kaikkiverot - kaikkiverot_data) <= 100 AND ABS(kaikkiverot - kaikkiverot_data) > 10, 1, 0);
		ABS1000 = IFN(ABS(kaikkiverot - kaikkiverot_data) <= 1000 AND ABS(kaikkiverot - kaikkiverot_data) > 100, 1, 0);
		ABS10000 = IFN(ABS(kaikkiverot - kaikkiverot_data) <= 10000 AND ABS(kaikkiverot - kaikkiverot_data) > 1000, 1, 0);
		ABS100000 = IFN(ABS(kaikkiverot - kaikkiverot_data) <= 100000 AND ABS(kaikkiverot - kaikkiverot_data) > 10000, 1, 0);
		ABSyli100000 = IFN(ABS(kaikkiverot - kaikkiverot_data) > 100000, 1, 0);
		RUN;

		DATA TARKKUUS2 (keep = hnro ykor ABS0 ABS1 ABS10 ABS100 ABS1000 ABS10000 ABS100000 ABSyli100000);
		SET UUSIMALL.DVERO;
		ABS0 = IFN(maksp_verot = verot, 1, 0);
		ABS1 = IFN(ABS(maksp_verot - verot) <= 1 AND ABS(maksp_verot - verot) > 0, 1, 0);
		ABS10 = IFN(ABS(maksp_verot - verot) <= 10 AND ABS(maksp_verot - verot) > 1, 1, 0);
		ABS100 = IFN(ABS(maksp_verot - verot) <= 100 AND ABS(maksp_verot - verot) > 10, 1, 0);
		ABS1000 = IFN(ABS(maksp_verot - verot) <= 1000 AND ABS(maksp_verot - verot) > 100, 1, 0);
		ABS10000 = IFN(ABS(maksp_verot - verot) <= 10000 AND ABS(maksp_verot - verot) > 1000, 1, 0);
		ABS100000 = IFN(ABS(maksp_verot - verot) <= 100000 AND ABS(maksp_verot - verot) > 10000, 1, 0);
		ABSyli100000 = IFN(ABS(maksp_verot - verot) >= 100000, 1, 0);
		RUN;


		PROC MEANS DATA = WORK.TARKKUUS SUM;
		VAR  ABS0 ABS1 ABS10 ABS100 ABS1000 ABS10000 ABS100000 ABSyli100000;
		OUTPUT OUT = UUSIMALL.VEROANAL1ABS SUM =;
		RUN;

		PROC MEANS DATA = WORK.TARKKUUS SUM;
		VAR  ABS0 ABS1 ABS10 ABS100 ABS1000 ABS10000 ABS100000 ABSyli100000;
		WEIGHT ykor;
		OUTPUT OUT = UUSIMALL.VEROANAL1ABSTOT SUM =;
		RUN;

		PROC MEANS DATA = WORK.TARKKUUS2 SUM;
		VAR  ABS0 ABS1 ABS10 ABS100 ABS1000 ABS10000 ABS100000 ABSyli100000;
		OUTPUT OUT = UUSIMALL.VEROANAL2ABS SUM =;
		RUN;

		PROC MEANS DATA = WORK.TARKKUUS2 SUM;
		VAR  ABS0 ABS1 ABS10 ABS100 ABS1000 ABS10000 ABS100000 ABSyli100000;
		WEIGHT ykor;
		OUTPUT OUT = UUSIMALL.VEROANAL2ABSTOT SUM =;
		RUN;

		DATA TARKKUUS3 (keep = hnro ykor suhtx suht0_01 suht0_1 suht1 suht10 suhtyli10);
		SET UUSIMALL.DVERO;
		IF kaikkiverot_data NE 0 THEN DO;
			suht0_01 = IFN(ABS(kaikkiverot - kaikkiverot_data) / kaikkiverot_data < = 0.0001 , 1, 0);
			suht0_1 = IFN(ABS(kaikkiverot - kaikkiverot_data) / kaikkiverot_data < = 0.001 AND ABS(kaikkiverot - kaikkiverot_data) / kaikkiverot_data > = 0.0001, 1, 0);
			suht1 = IFN(ABS(kaikkiverot - kaikkiverot_data) / kaikkiverot_data < = 0.01 AND ABS(kaikkiverot - kaikkiverot_data) / kaikkiverot_data > = 0.001, 1, 0);
			suht10 = IFN(ABS(kaikkiverot - kaikkiverot_data) / kaikkiverot_data < = 0.1 AND ABS(kaikkiverot - kaikkiverot_data) / kaikkiverot_data > = 0.01, 1, 0);
			suhtyli10 = IFN(ABS(kaikkiverot - kaikkiverot_data) / kaikkiverot_data > 0.1, 1, 0);
		END;
		ELSE DO;
			suhtx = 1;
			suht0_01 = 0;
			suht0_1 = 0;
			suht1 = 0;
			suht10 = 0;
			suhtyli10 = 0;
		END;
		RUN;

		PROC MEANS DATA = WORK.TARKKUUS3 SUM;
		VAR  suhtx suht0_01 suht0_1 suht1 suht10 suhtyli10;
		OUTPUT OUT = UUSIMALL.VEROANAL1SUHT SUM =;
		RUN;

		PROC MEANS DATA = WORK.TARKKUUS3 SUM;
		VAR  suhtx suht0_01 suht0_1 suht1 suht10 suhtyli10;
		WEIGHT ykor;
		OUTPUT OUT = UUSIMALL.VEROANAL1SUHTTOT SUM =;
		RUN;

		DATA TARKKUUS4 (keep = hnro ykor suhtx suht0_01 suht0_1 suht1 suht10 suhtyli10);
		SET UUSIMALL.DVERO;
		IF verot NE 0 THEN DO;
			suht0_01 = IFN(ABS(maksp_verot - verot) / verot < = 0.0001 , 1, 0);
			suht0_1 = IFN(ABS(maksp_verot - verot) / verot < = 0.001 AND ABS(maksp_verot - verot) / verot > = 0.0001, 1, 0);
			suht1 = IFN(ABS(maksp_verot - verot) / verot < = 0.01 AND ABS(maksp_verot - verot) / verot > = 0.001, 1, 0);
			suht10 = IFN(ABS(maksp_verot - verot) / verot < = 0.1 AND ABS(maksp_verot - verot) / verot > = 0.01, 1, 0);
			suhtyli10 = IFN(ABS(maksp_verot - verot) / verot > 0.1, 1, 0);
		END;
		ELSE DO;
			suhtx = 1;
			suht0_01 = 0;
			suht0_1 = 0;
			suht1 = 0;
			suht10 = 0;
			suhtyli10 = 0;
		END;
	RUN;

	PROC MEANS DATA = WORK.TARKKUUS4 SUM;
	VAR  suhtx suht0_01 suht0_1 suht1 suht10 suhtyli10;
	OUTPUT OUT = UUSIMALL.VEROANAL2SUHT SUM =;
	RUN;

	PROC MEANS DATA = WORK.TARKKUUS4 SUM;
	VAR  suhtx suht0_01 suht0_1 suht1 suht10 suhtyli10;
	OUTPUT OUT = UUSIMALL.VEROANAL2SUHTTOT SUM =;
	WEIGHT ykor;
	RUN;

%END;

%MEND Tarkkuus;


/* 3.4 Apumakroja pyˆristykseen (l‰hinn‰ el‰ketulov‰hennyksi‰ varten:
	   laissa on nykyisin maininta pyˆrist‰misest‰ "seuraavaan t‰yteen 10 euron m‰‰r‰‰n") */

%MACRO Pyoristys100mk (tulos, arvo)/STORE;
&tulos = &euro * &arvo / 100;
&tulos = CEIL(&tulos);
&tulos = 100 * &tulos;
&tulos = &tulos / &euro;
%MEND Pyoristys100mk;

%MACRO Pyoristys1000mk (tulos, arvo)/STORE;
&tulos = &euro * &arvo / 1000;
&tulos = CEIL(&tulos);
&tulos = 1000 * &tulos;
&tulos = &tulos / &euro;
%MEND Pyoristys1000mk;

%MACRO Pyoristys10e(tulos, arvo)/STORE;
&tulos = CEIL(&arvo / 10);
&tulos = 10 * (&tulos);
%MEND Pyoristys10e;

%MACRO Pyoristys100e(tulos, arvo)/STORE;
&tulos = CEIL(&arvo / 100);
&tulos = 100 * &tulos;
%MEND Pyoristys100e;
