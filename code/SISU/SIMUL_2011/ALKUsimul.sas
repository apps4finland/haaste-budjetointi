/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyödyntää Tilastokeskuksen yleisten
* käyttöehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto päähakemistossa.
******************************************************************************/

/* *****************************************************************
* Kuvaus: Simulointiohjelmien ajossa tarvittavia makromuuttujien   *
*         ja kirjastojen määrittelyjä.                             *
* Tekijä: Pertti Honkanen / KELA		                		   *
* Luotu: 31.11.2011				       					   		   *
* Viimeksi päivitetty: 15.1.2013		     		       		   *
* Päivittäjä: Olli Kannas / TK			     			   	 	   *
********************************************************************/

/* SISÄLLYS 
  0. Yleiset optiot ja SAS-asetukset
  1. Hakemisto- ja kirjastoviittaukset 
	1.1 Levyasema ja kansio, jossa malli ja aineistot sijaitsevat 
	1.2 Tallennetaan käyttöliittymän tarvitsemat tiedot Windows-rekisteriin 
	1.3 Määritellään kirjastoviittaukset 
	1.4 Määritellään kirjasto, johon makrot tallennetaan 
   2. Makro, jolla voi säädellä lokin kirjoitusta 
   3. Määritellään mallin ohjausparametrit globaaleiksi makromuuttujiksi 
	3.1 Mallin ohjausparametrit 
	3.2 Osamallien nimet ohjausparametreina 
   4. Määritellään mallissa käytettäviä vakioita 
	 4.1 Parametritaulukoiden alkuvuodet 
	 4.2 Euron arvo 
   5. Määritellään osamallien lainsäädännön parametrit globaaleiksi makromuuttujiksi
 	5.1 SAIRVAK-mallin parametrit 
 	5.2 TTURVA-mallin parametrit 
 	5.3 KANSEL-mallin parametrit 
 	5.4 KOTIHTUKI-mallin parametrit 
 	5.5 OPINTUKI-mallin parametrit 
 	5.6 VERO-mallin parametrit 
    5.7 Varallisuusveroon liittyvät parametrit (VERO-malli)
	5.8 KIVERO-mallin parametrit
	5.9 LLISA-mallin parametrit 
 	5.10 ELASUMTUKI-malli parametrit 
 	5.11 ASUMTUKI-mallin parametrit 
	5.12 TOIMTUKI-mallin parametrit 
   6. Luokituksissa käytettävät formaatit 
   7. Tallennetaan INDEKSImakro, KOYHINDmakro ja DESIILITmakro -tiedostojen sisältämät makrot talteen
   8. Tarkistusohjelma onko AlLKUsimul.sas ajettu 
*/


/* 0. Yleiset optiot ja SAS-asetukset */

%GLOBAL EG F;
%LET EG = 0; * Jos mallia käytetään SAS EG-käyttöliittymän kautta, tulee arvon olla 1.
			   Jos mallia käytetään käyttöliittymän ulkopuolelta, tulee arvon olla 0; 

%LET F = S ; * Käytetäänkö SAS-makroja (S) vai C-funkioita (C) ;

OPTIONS COMPRESS=YES;


/* 1. Hakemisto- ja kirjastoviittaukset */

/* 1.1 Mallivuosi ja tilapäistiedostojen sijainti */

%GLOBAL HAKEM LEVY MVUOSI TEMP;

%LET HAKEM = SISU; /* Kansio, jossa malli sijaitsee */

%LET LEVY = C: ; /* Levyasema, jossa malli sijaitsee */

%LET MVUOSI = 2011; /* Mallivuosi (aineiston perusvuosi) */

%LET TEMP = TEMP; /* Jos halutaan kirjoittaa välitiedostot SAS:n WORK-kansioon niin kirjoitetaan tähän WORK */

/* 1.1.1 Ohjelma, joka määrittää sijaintilevyn ja hakemiston sekä kenoviivan ympäristön mukaan */

%MACRO SYSCHECK;
%GLOBAL KENO UI_LEVY;
%IF &SYSSCPL = AIX 
	%THEN %DO;
		%LET HAKEM = USER/SISU; /* Kansio, jossa ohjelmakansiot ovat */
		%LET LEVY = %SYSGET(HOME) ; /* Levyasema, jossa ohjelma sijaitsee */
		%LET KENO = /;
		%LET UI_LEVY = K: ; /* Levyasema käyttöliittymälle, RW */
	%END;
	%ELSE %DO;
		%LET KENO = \;
		%LET UI_LEVY = &LEVY ; /* Levyasema käyttöliittymälle */
	%END;
%MEND SYSCHECK;
%SYSCHECK;

/* 1.2 Tallennetaan käyttöliittymän käynnistykselle Windows-rekisteriin 
		- käyttöliittymän juuripolku ohjelmalle, 
		- mallivuosi, 
		- hakemistoerotin sas-ohjelmille, 
		- juuripolku sas-ohjelmille         
*/

%MACRO MAKE_ROOTPATHS;
%GLOBAL SAS_USERPATH UI_USERPATH;
%LET SAS_USERPATH = &LEVY&KENO&HAKEM;
%LET UI_USERPATH = &UI_LEVY\&HAKEM;
%IF &SYSSCPL = AIX 
	%THEN %DO;
		%let UI_USERPATH = &UI_LEVY\SISU;
	%END;
%MEND MAKE_ROOTPATHS;
%MAKE_ROOTPATHS;

%MACRO WINDOWS_REGISTRY;
%IF &SYSSCPL ne AIX 
	%THEN %DO;
		x "reg add HKCU\Software\SISU /v SisuUserPath /d &UI_USERPATH /f";
		x "reg add HKCU\Software\SISU /v SisuSimulationYear /d &MVUOSI /f";
		x "reg add HKCU\Software\SISU /v SasDirectorySeparator /d &KENO /f";
		x "reg add HKCU\Software\SISU /v SasUserPath /d &SAS_USERPATH /f";
	%END;
%MEND WINDOWS_REGISTRY;
%WINDOWS_REGISTRY;

/* 1.3 Määritellään kirjastoviittaukset */

LIBNAME P_ALKUP  "&SAS_USERPATH&KENO.PARAM_ALKUP"; /* Alkuperäisten parametritiedostojen kirjasto */
LIBNAME PARAM  "&SAS_USERPATH&KENO.PARAM"; /* Muokattujen parametritiedostojen kirjasto */
LIBNAME MAKROT "&SAS_USERPATH&KENO.MAKROT"; /* Lakimakrojen ja apumakrojen kirjasto */
LIBNAME POHJADAT "&SAS_USERPATH&KENO.DATA&KENO.POHJADAT"; /* Pohja-aineistojen kirjasto (perusvuoden ja ajantasaistetut aineistot) */
LIBNAME STARTDAT "&SAS_USERPATH&KENO.DATA&KENO.STARTDAT"; /* Lähtöaineiston (poiminta ja muokkaukset tehty) kirjasto */
LIBNAME TEMP  "&SAS_USERPATH&KENO.TULOS&KENO.TEMP"; /* Apu- ja välitaulukkojen kansio */ 
LIBNAME OUTPUT  "&SAS_USERPATH&KENO.TULOS&KENO.OUTPUT"; /* Tulostaulukkojen kirjasto */
LIBNAME AJANT "&SAS_USERPATH&KENO.DATA&KENO.AJANTASAISTUS"; /* Ajantasaistusohjelmien- ja taulujen kirjasto */
LIBNAME KAYTLIIT "&SAS_USERPATH&KENO.KAYTLIIT"; /* Käyttöliittymän tiedostojen kirjasto */
LIBNAME SIMUL  "&SAS_USERPATH&KENO.SIMUL_&MVUOSI"; /* Mallivuoden &MVUOSI aineistosimulointiohjelmien kirjasto */
LIBNAME ESIM  "&SAS_USERPATH&KENO.ESIM"; /* Esimerkkilaskelmien simulointiohjelmien kirjasto */
LIBNAME JUTTA "&SAS_USERPATH&KENO.JUTTA"; /* Jutta-mallin C-funktioiden kirjasto */
LIBNAME DOKUM "&SAS_USERPATH&KENO.DOKUM"; /* Mallin dokumenttien kirjasto */

/* 1.4 Määritellään kirjasto, johon makrot tallennetaan */

OPTIONS MSTORED SASMSTORE = MAKROT REPLACE;


/* 2. Tällä makrolla voi säädellä lokin kirjoitusta, kun valitaan arvo optio-muuttujalle:
	  0 = ei lokia;
	  1 = NOTES, SOURCE ja SOURCE2;
	  2 = myös makroihin liittyvät lokioptiot;
	  Varoitus: Kaikkien makrolokioptioiden käyttö tuottaa hyvin pitkän lokin. */

%MACRO Loki(optio);

%LET PREFIX = NO;

%IF &optio = 0 %THEN %DO;
	%LET &PREFIX = NO;
	OPTIONS SQLUNDOPOLICY = NONE;
%END;

%ELSE %IF &optio = 2 %THEN %DO;
	%LET PREFIX = ;
%END;

OPTIONS &PREFIX.NOTES;
OPTIONS &PREFIX.SOURCE &PREFIX.SOURCE2;
OPTIONS &PREFIX.MPRINT;
OPTIONS &PREFIX.MPRINTNEST; 
OPTIONS &PREFIX.SYMBOLGEN; 
OPTIONS &PREFIX.MEXECNOTE;
OPTIONS &PREFIX.MLOGIC &PREFIX.MLOGICNEST;

%IF &optio = 1  %THEN %DO;
	OPTIONS NOTES SOURCE SOURCE2;
%END;

%MEND Loki;

%Loki(1);


/* 3. Määritellään mallin ohjausparametrit globaaleiksi makromuuttujiksi */

/* 3.1 Mallin ohjausparametrit */

%GLOBAL OUT POIMINTA APUMUUT TULOKSET TULOKSET_KOKO 

		APUMAKROT LAKIMAKROT APUMAK_TIED LAKIMAK_TIED 
		LAKIMAK_TIED_OT APUMAK_TIED_OT LAKIMAK_TIED_PH APUMAK_TIED_PH 
	 	LAKIMAK_TIED_TT APUMAK_TIED_TT LAKIMAK_TIED_SV APUMAK_TIED_SV LAKIMAK_TIED_KT APUMAK_TIED_KT 
		LAKIMAK_TIED_LL APUMAK_TIED_LL LAKIMAK_TIED_TO APUMAK_TIED_TO LAKIMAK_TIED_KE APUMAK_TIED_KE 
		LAKIMAK_TIED_VE APUMAK_TIED_VE LAKIMAK_TIED_KV APUMAK_TIED_KV LAKIMAK_TIED_YA APUMAK_TIED_YA 
		LAKIMAK_TIED_EA APUMAK_TIED_EA 
		
		SIMUL_TIED_OT SIMUL_TIED_TT SIMUL_TIED_SV SIMUL_TIED_KT SIMUL_TIED_LL SIMUL_TIED_TO 
		SIMUL_TIED_KE SIMUL_TIED_VE SIMUL_TIED_KV SIMUL_TIED_YA SIMUL_TIED_EA SIMUL_TIED_PH SIMUL_TIED_KOKO

		ESIM_TIED_OT ESIM_TIED_TT ESIM_TIED_SV ESIM_TIED_KT ESIM_TIED_LL ESIM_TIED_TO 
		ESIM_TIED_KE ESIM_TIED_VE ESIM_TIED_KV ESIM_TIED_YA ESIM_TIED_EA ESIM_TIED_PH ESIM_TIED_KOKO

		POPINTUKI PTTURVA PSAIRVAK PKOTIHTUKI PLLISA PTOIMTUKI PKANSEL PVERO 
	    PVERO_VARALL PKIVERO PASUMTUKI PASUMTUKI_VUOKRANORMIT 
		PASUMTUKI_ENIMMMENOT PELASUMTUKI PINDEKSI_VUOSI PINDEKSI_KUUK
		KOKOpoiminta KOKOsummat KOKOindikaattorit

		INF MVUOSI AVUOSI LVUOSI LKUUK AINEISTO KIVERO_AINEISTO TULOSNIMI_SV TULOSNIMI_KT TULOSNIMI_TT
		TULOSNIMI_LL TULOSNIMI_TO TULOSNIMI_KE TULOSNIMI_VE TULOSNIMI_KV TULOSNIMI_YA TULOSNIMI_EA 
		TULOSNIMI_OT TULOSNIMI_PH TULOSNIMI_KOKO 

		TYYPPI TYYPPI_KOKO EXCEL TULOSLAAJ TULOSLAAJ_KOKO 
		MUUTTUJAT YKSIKKO LUOK_HLO LUOK_HLO1 
		LUOK_HLO2 LUOK_HLO3 LUOK_KOTI LUOK_KOTI1 LUOK_KOTI2 LUOK_KOTI3
		SUMWGT SUM MIN MAX RANGE MEAN MEDIAN MODE VAR STD CV PAINO RAJAUS
		VUOSIKA VALITUT RAJALKM KRAJA1 KRAJA2 KRAJA3 TULO KULUYKS
	
		KDATATULO SDATATULO TTDATATULO YRIT KOTASU TARKPVM TARKKUUS YDINP 

		MINIMI_VERO_PUOLISO MAKSIMI_VERO_PUOLISO

		MINIMI_KOKO_PUOLISO MINIMI_KOKO_LAPSIA_ALLE3 MINIMI_KOKO_LAPSIA_3_6 MINIMI_KOKO_LAPSIA_3_9 
        MINIMI_KOKO_LAPSIA_10_15 MINIMI_KOKO_LAPSIA_16 MINIMI_KOKO_LAPSIA_17 MINIMI_KOKO_TILANNE
	    MINIMI_KOKO_TILANNE_PUOL MINIMI_KOKO_KUNNVERO MINIMI_KOKO_KIRKVERO MINIMI_KOKO_OMISTUS

		TTURVA_KOR;

/* 3.2 Osamallien nimet ohjausparametreina */

%GLOBAL SAIRVAK TTURVA KANSEL KOTIHTUKI OPINTUKI VERO KIVERO LLISA ASUMTUKI ELASUMTUKI PHOITO TOIMTUKI;


/* 4 Määritellään mallissa käytettäviä vakioita */

/* 4.1 Parametritaulukoiden alkuvuodet (ja ASUMTUKI-mallin loppuvuosi) */

%GLOBAL euro paramloppuyat paramalkusv paramalkukt paramalkutt paramalkull paramalkuto paramalkuke paramalkuve paramalkuyat paramalkueat paramalkuot;

%LET paramalkusv = 1982;  /* Sairausvakuutuksen parametritaulukon lähtövuosi */
%LET paramalkuot = 1992;  /* Opintotuen parametritaulukon lähtövuosi */
%LET paramalkukt = 1985;  /* Kotihoidontuen parametritaulukon lähtövuosi */
%LET paramalkutt = 1985;  /* Työttömyysturvan parametritaulukon lähtövuosi */
%LET paramalkull = 1948;  /* Lapsilisän parametritaulukon lähtövuosi */
%LET paramalkuto = 1989;  /* Toimeentulotuen parametritaulukon lähtövuosi */
%LET paramalkuke = 1957;  /* Kansaneläkkeen parametritaulukon lähtövuosi */
%LET paramalkuve = 1980;  /* Veromallin parametritaulukon lähtövuosi */
%LET paramalkukv = 2009;  /* Kiinteistöveron parametritaulukon lähtövuosi */
%LET paramalkuyat = 1990; /* Yleisen asumistuen parametritaulukon lähtövuosi */
%LET paramalkueat = 1990; /* Eläkkeensaajien asumistuen parametritaulukon lähtövuosi */

%LET paramloppuyat = 2013; /* Yleisen asumistuen parametritaulukon loppuvuosi */

/* 4.2 Euron arvo */

%LET euro = 5.94573;


/* 5. Määritellään osamallien lainsäädännön parametrit globaaleiksi makromuuttujiksi */

/* 5.1 SAIRVAK-mallin parametrit */

%GLOBAL Minimi VanhMin SRaja1 SRaja2 SRaja3 LapsiKor SPros1 SPros2 SPros3
SPros4 SPros5 PalkVah PoikRaja1 PoikRaja2 PoikPros HarkRaja HarkPuol
VarRaja KorProsAit KorPros1 KorPros2 OsaPRaha SPaivat MaxPaiv SMaksLaps;

/* 5.2 TTURVA-mallin parametrit */

%GLOBAL TTMaksLaps TTPaivia TTPerus	TTTaite	TTPros1	TTPros2	Proskor1 Proskor2 ProsYlaraja TTLaps1
TTLaps2	TTLaps3	RajaYks	RajaHuolt RajaLaps PuolVah TarvPros1 TarvPros2 TyomLapsPros VahPros OsPros	OsRaja	
OsRajakor OsTarvPros SovSuoja SovPros SovRaja YPiTOk KorotusOsa MuutTurvaPros1 MuutTurvaPros2 VuorKorvPros VuorKorvPros2	
VuorKorvYlaRaja	SovSuojaKoul SovProsKoul;

/* 5.3 KANSEL-mallin parametrit */

%GLOBAL PerPohja LeikPohja TaysKEY1	TaysKEY2 TaysKEP1 TaysKEP2 TukOsY1 TukOsY2 TukOsP1 TukOsY3	
TukOsP2	KERaja KEPros ApuLis HoitoLis RiLi KELaps PuolisoLis HoitTukiNorm	HoitTukiKor	
HoitTukiErit Keliak	VammNorm VammKorot VammErit	LapsHoitTukNorm	LapsHoitTukKorot LapsHoitTukErit KEMinimi	
Laitosraja1	Laitosraja2	LaitosTaysiY1 LaitosTaysiY2 LaitosTaysiP1 LaitosTaysiP2	PohjRajaY1 PohjRajaY2	
PohjRajaP1 PohjRajaP2 PuolAlenn YliRiliPros YliRiliPros2 YliRiliMinimi YliRiliRaja YliRiliAskel	YliRiliAskel2 
LapsElPerus LapsElTayd LapsElMinimi LeskPerus LeskTaydY1 LeskTaydY2 LeskTaydP1 LeskTaydP2 PerhElOmRaja	
PerhElOmPros LeskMinimi	LeskalkuMinimi1	LeskalkuMinimi2	Leskalku LeskTyoTuloOsuus VeterLisa	TakuuEl TukiLisPP TukiLisY
SotAvMinimi	SotAvPros1 SotAvPros2 SotAvPros3;

/* 5.4 KOTIHTUKI-mallin parametrit */

%GLOBAL Perus Sisar	Lisa KHRaja1 KHRaja2 KHRaja3 SisarMuu	
SisarKerr Kerr1	Kerr2 Kerr3 OsKerr OsRaha PHRaja1 PHRaja2 PHRaja3 
PHKerr1 PHKerr2 PHKerr3 PHVahenn PHAlennus PHYlaraja PHYlaraja2 
PHAlaraja PHRaja4 PHRaja5 PHKerr4 PHKerr5;

/* 5.5 OPINTUKI-mallin parametrit */

%GLOBAL ORaja1 ORaja2 ORaja3 KorkVanh20 KorkVanhAlle20 KorkMuu20 KorkMuuAlle20 MuuVanh20
MuuVanhAlle20 MuuMuu20 MuuMuuAlle20 VuokraKatto VuokraRaja VuokraMinimi
AsLisaPros AsLisaPerus AsLisaTuloRaja AsLisavahPros AsLisaVanhKynnys 
AsLisaPuolTuloRaja AsLisaPuolvahPros AsLisaPuolTuloKynnys VanhTuloRaja
VanhKynnys VanhPros VanhTuloYlaRaja SisarAlennus AikOpPros AikOpAlaRaja
AikOpYlaRaja OpTuloRaja OpTuloVahPros OpTuloVahKynnys VanhVarRaja
VanhVarPros VanhTuloRaja2 VanhTuloRaja2Kynnys VanhTuloPros2 KorkVanh20b
KorkVanhAlle20b KorkMuu20b KorkMuuAlle20b MuuVanh20b MuuVanhAlle20b
MuuMuu20b MuuMuuAlle20b OpTuloRaja2 AikKoulPerus AikKoulTuloRaja AikKoulPros1
AikKoulPros2 OpLainaKor OpLainaKorAlle18 OpLainaMuu OpLainaMuuAlle18
OpLainaAikKoul TakPerRaja TakPerPros TakPerAlaRaja TakPerKorotus;

/* 5.6 VERO-mallin parametrit */

%GLOBAL YleAlaRaja YleIkaRaja YleYlaRaja YlePros 
MatkYlaraja MatkOmaVast TulonHankk KelaYks KelaPuol
ValtAlaraja KunnAnsEnimm KunnAnsRaja1 KunnAnsRaja2 KunnAnsRaja3
KunnPerEnimm ValtLapsiVah KunnLapsiVah KunnYksHuoltVah KorSVMaksuRaja
AlijYlaRaja AlijLapsiKor AlijKulLuot KunnInvVah ValtInvVah
OpRahVah ValtElVelvVah VerMaksAlentEnimm KotitVahEnimm KotitVahAlaRaja
VarAlaRaja VarVakio VarPuolVah VarLapsiVah VakAs
VapEhtRaja1 VapEhvpertRaja2 VapEhtRaja3 SairKulOmaVast SairKulYlaRaja
SairKulLapsiVah TulonHankkAlaRaja PalkVahYlaraja ValtYhVahYlaraja ValtPuolVahYlaRaja
ValtPuolVahKorotus KunnElVelvVah KunnLapsVah2 KunnLapsVah3 KunnLapsVah4
KunnLapsVahMuu KunnOpiskVah KunnVanhVah ValtTyotVahYlaRaja ValtKoulVah
ValtLapsKorotus ValtHuoltVah1 ValtHuoltVah2 ValtHuoltVah3 ValtHuoltVah4
ValtHuoltVahMuu OmVahRaja1 OmVahRaja2 OmVahEiVuokraRaja OmVahKorkoRaja
KorkoVahYlaRaja KorkoVahYlaRajaMuut KorkoVahYlaRajaMuutPuol KorkoVahOmaVast KorkoVahPuolisot
KorkoVahLapsiKor1 KorkoVahLapsiKor2 ValtVanhVah PuolPORaja TulonHankPros
ValtElKerr ValtElPros KunnElKerr KunnElPros EnsAsKor
SvPros KevPros SvKorotus YhtHyvPros PaaomaVeroPros
ElVakMaksu TyotVakMaksu ElKorSvMaksu ElKorKevMaksu KunnAnsPros1
KunnAnsPros2 KunnAnsPros3 KunnPerPros OpRahPros ElVakMaksu53
Kattovero ValtAlijOsuus ValtPuolVahPros ValtTyotVahPros ValtYhPros
ValtLapsPros PalkVahPros KeskKunnPros OmVahPros KorkoVahPros
VarPros VapEhtAnsioRaja VapEhtPros2 VarallKattoPros POOsuus
OsPOOsuus VaihtPOOsuus PalkPOOsuus JulkPOOsuus HenkYhtOsVapOsuus
HenkYhtVapRaja HenkYhtOsAnsOsuus TyotMatkOmVast MatkOmVastVahimm ValtAnsAlaRaja
ValtAnsEnimm ValtAnsYlaRaja ValtAnsPros1 ValtAnsPros2 SvPrMaksu
ElVelvPros OpLainaVahRaja OpLainaVahPros OspKorVeroVap TyoAsVah
SairVakYrit KunnElVakio KunnKerroin KirkKerroin KirkVeroPros
PORaja POPros2 AsKorkoOsuus 
Raja1 Raja2 Raja3 Raja4 Raja5 Raja6 Raja7 Raja8 Raja9 Raja10 Raja11 Raja12
Vakio1 Vakio2 Vakio3 Vakio4 Vakio5 Vakio6 Vakio7 Vakio8 Vakio9 Vakio10 Vakio11 Vakio12
Pros1 Pros2 Pros3 Pros4 Pros5 Pros6 Pros7 Pros8 Pros9 Pros10 Pros11 Pros12
ElLisaVRaja ElLisaVPros;

/* 5.7 Varallisuusveroon liittyvät parametrit (VERO-malli) */

%GLOBAL VarRaja1 VarRaja2  VarRaja3  VarRaja4  VarRaja5  VarRaja6
VarVakio1 VarVakio2 VarVakio3 VarVakio4 VarVakio5 VarVakio6
VarPros1 VarPros2 VarPros3  VarPros4 VarPros5 VarPros6;

/* 5.8 KIVERO-mallin parametrit */
 
%GLOBAL PtPerusArvo PtPuuVanh PtPuuUusi VuosiRaja1 VuosiRaja2 KellArvo PtVahPieni PtVahSuuri PtEiVesi PtEiKesk 
PtEiSahko PtNelioRaja1 PtNelioRaja2 VapPerusArvo VapVahPieni VapVahSuuri VapNelioRaja1 VapNelioRaja2  
VapLisTalvi VapLisSahko1 VapLisSahko2 VapLisViem VapLisVesi VapLisWC VapLisSauna IkaAlePuu IkaAleKivi IkaVahRaja ;

/* 5.9 LLISA-mallin parametrit */

%GLOBAL Vuosi Kuuk IRaja Lapsi1 Lapsi2 Lapsi3 Lapsi4 Lapsi5 
Alle3v YksHuolt AitAv ElatTuki AlenElatTuki;

/* 5.10 ELASUMTUKI-malli parametrit */

%GLOBAL ETukiPros LapsiKor1 LapsiKor2 EPieninTuki PerusOVast LisOVastPros LisOVRaja
LisOVRaja2 LisOVRaja3 LisOVRaja4 LisOVRaja5 RintSotVah OmPros OmRaja OmRaja2 Lamm1 
Lamm2 Lamm3 MuuLamm1 MuuLamm2 MuuLamm3 Vesi1 Vesi2 KunnPito Kor1974 YksRaja PerhRaja 
Enimm1 Enimm2 Enimm3 Enimm4;

/* 5.11 ASUMTUKI-mallin parametrit */

%GLOBAL ATukiPros KorkoTukiPros AravaPros EnimmN1 EnimmN2
EnimmN3 EnimmN4 EnimmN5 EnimmN6 EnimmN7
EnimmN8 EnimmNplus YksHVah OmaVastVah APieninTuki
AVarRaja1 AVarRaja2 AVarRaja3 AVarRaja4 AVarRaja5
AVarRaja6 VesiMaksu HoitoMenoAs HoitoMenoHenk HoitoMeno1
HoitoMeno2 HoitoMeno3 VarallPros ;

/* 5.12 TOIMTUKI-mallin parametrit */

%GLOBAL YksinKR1 YksinKR2 YksPros Yksinhuoltaja Aik18Plus AikLapsi18Plus 
Lapsi17 Lapsi10_16 LapsiAlle10 LapsiVah2 LapsiVah3 LapsiVah4
LapsiVah5 AsOmaVast VapaaOs VapaaOsRaja;

/* 6. Luokituksissa käytettävät formaatit */

/* TUHATEROTIN */

ODS PATH work.templat(UPDATE) sasuser.templat(READ) sashelp.tmplmst(READ);

PROC TEMPLATE;
EDIT BASE.SUMMARY;
DEFINE N;
FORMAT = tuhat.;
END;
DEFINE SUMWGT;
FORMAT = tuhat.;
END;
DEFINE SUM;
format=tuhat.;
END;
DEFINE MIN;
FORMAT = tuhat.;
END;
DEFINE MAX;
FORMAT = tuhat.;
END;
DEFINE RANGE;
FORMAT = tuhat.;
END;
DEFINE MEAN;
FORMAT = tuhat.;
END;
DEFINE MEDIAN;
FORMAT = tuhat.;
END;
DEFINE MODE;
FORMAT = tuhat.;
END;
DEFINE VAR;
FORMAT = tuhat.;
END;
DEFINE CV;
FORMAT = tuhat.;
END;
DEFINE STDDEV;
FORMAT = tuhat.;
END;
DEFINE NOBS;
FORMAT = tuhat.;
END;
END;
RUN;

PROC FORMAT; 

/* TUHATEROTIN */

PICTURE tuhat (ROUND)
low - <0 = '0 000 000 000 000 009' (DECSEP=',' PREFIX='-')
0 - high = '0 000 000 000 000 009' (DECSEP=',');

/* DESIILIT */

VALUE desmod (NOTSORTED MULTILABEL)
0 = 'I'
1 = 'II'
2 = 'III'
3 = 'IV'
4 = 'V'
5 = 'VI'
6 = 'VII'
7 = 'VIII'
8 = 'IX'
9 = 'X'
low-high = 'I-X';

VALUE desmod_malli (NOTSORTED MULTILABEL)
0 = 'I'
1 = 'II'
2 = 'III'
3 = 'IV'
4 = 'V'
5 = 'VI'
6 = 'VII'
7 = 'VIII'
8 = 'IX'
9 = 'X'
low-high = 'I-X';

/* IKÄLUOKITUS */

VALUE ikavu (NOTSORTED MULTILABEL)
low-24 = '-24'
25-34 = '25-34'
35-44 = '35-44'
45-54 = '45-54'
55-64 = '55-64'
65-74 = '65-74'
75-high = '75-'
low-high = 'Yhteensä' ;

VALUE ikavuV (NOTSORTED MULTILABEL)
low-24 = '-24'
25-34 = '25-34'
35-44 = '35-44'
45-54 = '45-54'
55-64 = '55-64'
65-74 = '65-74'
75-high = '75-'
low-high = 'Yhteensä' ;

/* SOSIOEKONOMINEN ASEMA (KOTITALOUS) */

VALUE paasoss (NOTSORTED MULTILABEL)
10-29 = '1. Yrittäjät ja maatalousyrittäjät'
10-19 = '1.1 Maatalousyrittäjät'
20-29 = '1.2 Muut yrittäjät'
31-59 = '2. Palkansaajat'
31-39 = '2.1. Ylemmät toimihenkilöt'
41-49 = '2.2. Alemmat toimihenkilöt'
50-59 = '2.3. Työntekijät'
60 = '3. Opiskelijat ja koululaiset'
70-79 = '4. Eläkeläiset'
81 = '5. Työttömät'
80,82,99 = '6. Muut'
low-high = 'Yhteensä';

/* SOSIOEKONOMINEN ASEMA (HENKILÖ) */

VALUE soss (NOTSORTED MULTILABEL)
10-29 = '1. Yrittäjät ja maatalousyrittäjät'
10-19 = '1.1 Maatalousyrittäjät'
20-29 = '1.2 Muut yrittäjät'
31-59 = '2. Palkansaajat'
31-39 = '2.1. Ylemmät toimihenkilöt'
41-49 = '2.2. Alemmat toimihenkilöt'
50-59 = '2.3. Työntekijät'
60 = '3. Opiskelijat ja koululaiset'
70-79 = '4. Eläkeläiset'
81 = '5. Työttömät'
80,82,99 = '6. Muut'
low-high = 'Yhteensä';

VALUE elivtu (NOTSORTED MULTILABEL)
11-16 = '1. Yhden hengen taloudet'
11,12 = '1.1 Yhden hengen talous, ikä<35'
13,14,15 = '1.2 Yhden hengen talous, ikä 35-64'
16 = '1.3 Yhden hengen talous, ikä 65-'	
31-36 = '2. Lapsettomat parit'
31,32 = '2.1 Lapsettomat parit, ikä <35'
33,34,35 = '2.2 Lapsettomat parit, ikä 35-64'
36 = '2.3 Lapsettomat parit, ikä 65-'
40-70,82 = '3. Parit, joilla lapsia'
40 = '3.1 Parit, joilla lapsia, kaikki alle 7v'
50 = '3.2 Parit, joilla lapsia, nuorin alle 7v'
60 = '3.3 Parit, joilla lapsia, nuorin 7-12'
70 = '3.4 Parit, joilla lapsia, nuorin 13-17'
82 = '3.5 Parit, joilla sekä alle että yli 18-v lapsia'
20,84 = '4. Yksinhuoltajataloudet'
20,40-70,82,84 = '5. Kotitaloudet, joissa lapsia'   /* Lisätty luokitukseen vuonna 2008 */
81,83,90,99 = '6. Muut taloudet'
low-high = 'Yhteensä';

/* KOULUTUSLUOKITUS (1997 MUKAINEN) */

VALUE koulas (NOTSORTED MULTILABEL)
0 = '1. Perusaste, ei suoritettua tutkintoa tai tuntematon'
3 = '2. Keskiaste'
5 = '3. Alin korkea-aste'
6 = '4. Alempi korkeakouluaste'
7 = '5. Ylempi korkeakouluaste'
8 = '6. Tutkijakoulutusaste'
low-high = 'Yhteensä';

/* KOTITALOUDEN RAKENNE */

VALUE rake (NOTSORTED MULTILABEL)
10 = '1 aikuinen'
22 = '2 aikuista'
33 = '3 aikuista'
44 = '4 aikuista'
21 = '1 aikuinen, 1 lapsi'
31 = '1 aikuinen, 2 lasta'
32 = '2 aikuista, 1 lapsi'
42 = '2 aikuista, 2 lasta'
52 = '2 aikuista, 3 lasta'
62 = '2 aikuista, vähintään 4 lasta'
43 = '3 aikuista, 1 lapsi'
53 = '3 aikuista, 2 lasta'
63 = '3 aikuista, vähintään 3 lasta'
54 = '4 aikuista, 1 lapsi'
41,51,55,61,64,65,66,99 = 'Muut'
low-high = 'Yhteensä';

/* ASUINKUNTA (2011) */

VALUE $kunta_vanha (NOTSORTED MULTILABEL)
'020' =	'Akaa'
'005'=	'Alajärvi'
'009'=	'Alavieska'
'010'=	'Alavus'
'016'=	'Asikkala'
'018'=	'Askola'
'019'=	'Aura'
'035'=	'Brändö'
'043'=	'Eckerö'
'046'=	'Enonkoski'
'047'=	'Enontekiö'
'049'=	'Espoo'
'050'=	'Eura'
'051'=	'Eurajoki'
'052'=	'Evijärvi'
'060'=	'Finström'
'061'=	'Forssa'
'062'=	'Föglö'
'065'=	'Geta'
'069'=	'Haapajärvi'
'071'=	'Haapavesi'
'072'=	'Hailuoto'
'074'=	'Halsua'
'075'=	'Hamina'
'076'=	'Hammarland'
'077'=	'Hankasalmi'
'078'=	'Hanko'
'079'=	'Harjavalta'
'081'=	'Hartola'
'082'=	'Hattula'
'084'=	'Haukipudas'
'086'=	'Hausjärvi'
'111'=	'Heinola'
'090'=	'Heinävesi'
'091'=	'Helsinki'
'097'=	'Hirvensalmi'
'098'=	'Hollola'
'099'=	'Honkajoki'
'102'=	'Huittinen'
'103'=	'Humppila'
'105'=	'Hyrynsalmi'
'106'=	'Hyvinkää'
'283'=	'Hämeenkoski'
'108'=	'Hämeenkyrö'
'109'=	'Hämeenlinna'
'139'=	'Ii'
'140'=	'Iisalmi'
'142'=	'Iitti'
'143'=	'Ikaalinen'
'145'=	'Ilmajoki'
'146'=	'Ilomantsi'
'153'=	'Imatra'
'148'=	'Inari'
'149'=	'Inkoo'
'151'=	'Isojoki'
'152'=	'Isokyrö'
'164'=	'Jalasjärvi'
'165'=	'Janakkala'
'167'=	'Joensuu'
'169'=	'Jokioinen'
'170'=	'Jomala'
'171'=	'Joroinen'
'172'=	'Joutsa'
'174'=	'Juankoski'
'176'=	'Juuka'
'177'=	'Juupajoki'
'178'=	'Juva'
'179'=	'Jyväskylä'
'181'=	'Jämijärvi'
'182'=	'Jämsä'
'186'=	'Järvenpää'
'202'=	'Kaarina'
'204'=	'Kaavi'
'205'=	'Kajaani'
'208'=	'Kalajoki'
'211'=	'Kangasala'
'213'=	'Kangasniemi'
'214'=	'Kankaanpää'
'216'=	'Kannonkoski'
'217'=	'Kannus'
'218'=	'Karijoki'
'223'=	'Karjalohja'
'224'=	'Karkkila'
'226'=	'Karstula'
'230'=	'Karvia'
'231'=	'Kaskinen'
'232'=	'Kauhajoki'
'233'=	'Kauhava'
'235'=	'Kauniainen'
'236'=	'Kaustinen'
'239'=	'Keitele'
'240'=	'Kemi'
'320'=	'Kemijärvi'
'241'=	'Keminmaa'
'322'=	'Kemiönsaari'
'244'=	'Kempele'
'245'=	'Kerava'
'246'=	'Kerimäki'
'248'=	'Kesälahti'
'249'=	'Keuruu'
'250'=	'Kihniö'
'254'=	'Kiikoinen'
'255'=	'Kiiminki'
'256'=	'Kinnula'
'257'=	'Kirkkonummi'
'260'=	'Kitee'
'261'=	'Kittilä'
'263'=	'Kiuruvesi'
'265'=	'Kivijärvi'
'271'=	'Kokemäki'
'272'=	'Kokkola'
'273'=	'Kolari'
'275'=	'Konnevesi'
'276'=	'Kontiolahti'
'280'=	'Korsnäs'
'284'=	'Koski Tl'
'285'=	'Kotka'
'286'=	'Kouvola'
'287'=	'Kristiinankaupunki'
'288'=	'Kruunupyy'
'290'=	'Kuhmo'
'291'=	'Kuhmoinen'
'295'=	'Kumlinge'
'297'=	'Kuopio'
'300'=	'Kuortane'
'301'=	'Kurikka'
'304'=	'Kustavi'
'305'=	'Kuusamo'
'312'=	'Kyyjärvi'
'316'=	'Kärkölä'
'317'=	'Kärsämäki'
'318'=	'Kökar'
'319'=	'Köyliö'
'398'=	'Lahti'
'399'=	'Laihia'
'400'=	'Laitila'
'407'=	'Lapinjärvi'
'402'=	'Lapinlahti'
'403'=	'Lappajärvi'
'405'=	'Lappeenranta'
'408'=	'Lapua'
'410'=	'Laukaa'
'413'=	'Lavia'
'416'=	'Lemi'
'417'=	'Lemland'
'418'=	'Lempäälä'
'420'=	'Leppävirta'
'421'=	'Lestijärvi'
'422'=	'Lieksa'
'423'=	'Lieto'
'425'=	'Liminka'
'426'=	'Liperi'
'444'=	'Lohja'
'430'=	'Loimaa'
'433'=	'Loppi'
'434'=	'Loviisa'
'435'=	'Luhanka'
'436'=	'Lumijoki'
'438'=	'Lumparland'
'440'=	'Luoto'
'441'=	'Luumäki'
'442'=	'Luvia'
'445'=	'Länsi-Turunmaa'
'475'=	'Maalahti'
'476'=	'Maaninka'
'478'=	'Maarianhamina - Mariehamn'
'480'=	'Marttila'
'481'=	'Masku'
'483'=	'Merijärvi'
'484'=	'Merikarvia'
'489'=	'Miehikkälä'
'491'=	'Mikkeli'
'494'=	'Muhos'
'495'=	'Multia'
'498'=	'Muonio'
'499'=	'Mustasaari'
'500'=	'Muurame'
'503'=	'Mynämäki'
'504'=	'Myrskylä'
'505'=	'Mäntsälä'
'508'=	'Mänttä-Vilppula'
'507'=	'Mäntyharju'
'529'=	'Naantali'
'531'=	'Nakkila'
'532'=	'Nastola'
'534'=	'Nilsiä'
'535'=	'Nivala'
'536'=	'Nokia'
'538'=	'Nousiainen'
'540'=	'Nummi-Pusula'
'541'=	'Nurmes'
'543'=	'Nurmijärvi'
'545'=	'Närpiö'
'560'=	'Orimattila'
'561'=	'Oripää'
'562'=	'Orivesi'
'563'=	'Oulainen'
'564'=	'Oulu'
'567'=	'Oulunsalo'
'309'=	'Outokumpu'
'576'=	'Padasjoki'
'577'=	'Paimio'
'578'=	'Paltamo'
'580'=	'Parikkala'
'581'=	'Parkano'
'599'=	'Pedersören kunta'
'583'=	'Pelkosenniemi'
'854'=	'Pello'
'584'=	'Perho'
'588'=	'Pertunmaa'
'592'=	'Petäjävesi'
'593'=	'Pieksämäki'
'595'=	'Pielavesi'
'598'=	'Pietarsaari'
'601'=	'Pihtipudas'
'604'=	'Pirkkala'
'607'=	'Polvijärvi'
'608'=	'Pomarkku'
'609'=	'Pori'
'611'=	'Pornainen'
'638'=	'Porvoo'
'614'=	'Posio'
'615'=	'Pudasjärvi'
'616'=	'Pukkila'
'618'=	'Punkaharju'
'619'=	'Punkalaidun'
'620'=	'Puolanka'
'623'=	'Puumala'
'624'=	'Pyhtää'
'625'=	'Pyhäjoki'
'626'=	'Pyhäjärvi'
'630'=	'Pyhäntä'
'631'=	'Pyhäranta'
'635'=	'Pälkäne'
'636'=	'Pöytyä'
'678'=	'Raahe'
'710'=	'Raasepori'
'680'=	'Raisio'
'681'=	'Rantasalmi'
'683'=	'Ranua'
'684'=	'Rauma'
'686'=	'Rautalampi'
'687'=	'Rautavaara'
'689'=	'Rautjärvi'
'691'=	'Reisjärvi'
'694'=	'Riihimäki'
'696'=	'Ristiina'
'697'=	'Ristijärvi'
'698'=	'Rovaniemi'
'700'=	'Ruokolahti'
'702'=	'Ruovesi'
'704'=	'Rusko'
'707'=	'Rääkkylä'
'729'=	'Saarijärvi'
'732'=	'Salla'
'734'=	'Salo'
'736'=	'Saltvik'
'790'=	'Sastamala'
'738'=	'Sauvo'
'739'=	'Savitaipale'
'740'=	'Savonlinna'
'742'=	'Savukoski'
'743'=	'Seinäjoki'
'746'=	'Sievi'
'747'=	'Siikainen'
'748'=	'Siikajoki'
'791'=	'Siikalatva'
'749'=	'Siilinjärvi'
'751'=	'Simo'
'753'=	'Sipoo'
'755'=	'Siuntio'
'758'=	'Sodankylä'
'759'=	'Soini'
'761'=	'Somero'
'762'=	'Sonkajärvi'
'765'=	'Sotkamo'
'766'=	'Sottunga'
'768'=	'Sulkava'
'771'=	'Sund'
'775'=	'Suomenniemi'
'777'=	'Suomussalmi'
'778'=	'Suonenjoki'
'781'=	'Sysmä'
'783'=	'Säkylä'
'831'=	'Taipalsaari'
'832'=	'Taivalkoski'
'833'=	'Taivassalo'
'834'=	'Tammela'
'837'=	'Tampere'
'838'=	'Tarvasjoki'
'844'=	'Tervo'
'845'=	'Tervola'
'846'=	'Teuva'
'848'=	'Tohmajärvi'
'849'=	'Toholampi'
'850'=	'Toivakka'
'851'=	'Tornio'
'853'=	'Turku'
'857'=	'Tuusniemi'
'858'=	'Tuusula'
'859'=	'Tyrnävä'
'863'=	'Töysä'
'886'=	'Ulvila'
'887'=	'Urjala'
'889'=	'Utajärvi'
'890'=	'Utsjoki'
'892'=	'Uurainen'
'893'=	'Uusikaarlepyy'
'895'=	'Uusikaupunki'
'785'=	'Vaala'
'905'=	'Vaasa'
'908'=	'Valkeakoski'
'911'=	'Valtimo'
'092'=	'Vantaa'
'915'=	'Varkaus'
'918'=	'Vehmaa'
'921'=	'Vesanto'
'922'=	'Vesilahti'
'924'=	'Veteli'
'925'=	'Vieremä'
'926'=	'Vihanti'
'927'=	'Vihti'
'931'=	'Viitasaari'
'934'=	'Vimpeli'
'935'=	'Virolahti'
'936'=	'Virrat'
'941'=	'Vårdö'
'942'=	'Vähäkyrö'
'946'=	'Vöyri'
'972'=	'Yli-Ii'
'976'=	'Ylitornio'
'977'=	'Ylivieska'
'980'=	'Ylöjärvi'
'981'=	'Ypäjä'
'989'=	'Ähtäri'
'992'=	'Äänekoski'
'X' = 'Ei kuntakoodia ed. vuoden lopussa'
low-high = 'Yhteensä';


/* ASUINKUNTA (2012) */

VALUE $kunta_uusi (NOTSORTED MULTILABEL)
'020'=	'Akaa'
'005'=	'Alajärvi'
'009'=	'Alavieska'
'010'=	'Alavus'
'016'=	'Asikkala'
'018'=	'Askola'
'019'=	'Aura'
'035'=	'Brändö'
'043'=	'Eckerö'
'046'=	'Enonkoski'
'047'=	'Enontekiö'
'049'=	'Espoo'
'050'=	'Eura'
'051'=	'Eurajoki'
'052'=	'Evijärvi'
'060'=	'Finström'
'061'=	'Forssa'
'062'=	'Föglö'
'065'=	'Geta'
'069'=	'Haapajärvi'
'071'=	'Haapavesi'
'072'=	'Hailuoto'
'074'=	'Halsua'
'075'=	'Hamina'
'076'=	'Hammarland'
'077'=	'Hankasalmi'
'078'=	'Hanko'
'079'=	'Harjavalta'
'081'=	'Hartola'
'082'=	'Hattula'
'084'=	'Haukipudas'
'086'=	'Hausjärvi'
'111'=	'Heinola'
'090'=	'Heinävesi'
'091'=	'Helsinki'
'097'=	'Hirvensalmi'
'098'=	'Hollola'
'099'=	'Honkajoki'
'102'=	'Huittinen'
'103'=	'Humppila'
'105'=	'Hyrynsalmi'
'106'=	'Hyvinkää'
'283'=	'Hämeenkoski'
'108'=	'Hämeenkyrö'
'109'=	'Hämeenlinna'
'139'=	'Ii'
'140'=	'Iisalmi'
'142'=	'Iitti'
'143'=	'Ikaalinen'
'145'=	'Ilmajoki'
'146'=	'Ilomantsi'
'153'=	'Imatra'
'148'=	'Inari'
'149'=	'Inkoo'
'151'=	'Isojoki'
'152'=	'Isokyrö'
'164'=	'Jalasjärvi'
'165'=	'Janakkala'
'167'=	'Joensuu'
'169'=	'Jokioinen'
'170'=	'Jomala'
'171'=	'Joroinen'
'172'=	'Joutsa'
'174'=	'Juankoski'
'176'=	'Juuka'
'177'=	'Juupajoki'
'178'=	'Juva'
'179'=	'Jyväskylä'
'181'=	'Jämijärvi'
'182'=	'Jämsä'
'186'=	'Järvenpää'
'202'=	'Kaarina'
'204'=	'Kaavi'
'205'=	'Kajaani'
'208'=	'Kalajoki'
'211'=	'Kangasala'
'213'=	'Kangasniemi'
'214'=	'Kankaanpää'
'216'=	'Kannonkoski'
'217'=	'Kannus'
'218'=	'Karijoki'
'223'=	'Karjalohja'
'224'=	'Karkkila'
'226'=	'Karstula'
'230'=	'Karvia'
'231'=	'Kaskinen'
'232'=	'Kauhajoki'
'233'=	'Kauhava'
'235'=	'Kauniainen'
'236'=	'Kaustinen'
'239'=	'Keitele'
'240'=	'Kemi'
'320'=	'Kemijärvi'
'241'=	'Keminmaa'
'322'=	'Kemiönsaari'
'244'=	'Kempele'
'245'=	'Kerava'
'246'=	'Kerimäki'
'248'=	'Kesälahti'
'249'=	'Keuruu'
'250'=	'Kihniö'
'254'=	'Kiikoinen'
'255'=	'Kiiminki'
'256'=	'Kinnula'
'257'=	'Kirkkonummi'
'260'=	'Kitee'
'261'=	'Kittilä'
'263'=	'Kiuruvesi'
'265'=	'Kivijärvi'
'271'=	'Kokemäki'
'272'=	'Kokkola'
'273'=	'Kolari'
'275'=	'Konnevesi'
'276'=	'Kontiolahti'
'280'=	'Korsnäs'
'284'=	'Koski Tl'
'285'=	'Kotka'
'286'=	'Kouvola'
'287'=	'Kristiinankaupunki'
'288'=	'Kruunupyy'
'290'=	'Kuhmo'
'291'=	'Kuhmoinen'
'295'=	'Kumlinge'
'297'=	'Kuopio'
'300'=	'Kuortane'
'301'=	'Kurikka'
'304'=	'Kustavi'
'305'=	'Kuusamo'
'312'=	'Kyyjärvi'
'316'=	'Kärkölä'
'317'=	'Kärsämäki'
'318'=	'Kökar'
'319'=	'Köyliö'
'398'=	'Lahti'
'399'=	'Laihia'
'400'=	'Laitila'
'407'=	'Lapinjärvi'
'402'=	'Lapinlahti'
'403'=	'Lappajärvi'
'405'=	'Lappeenranta'
'408'=	'Lapua'
'410'=	'Laukaa'
'413'=	'Lavia'
'416'=	'Lemi'
'417'=	'Lemland'
'418'=	'Lempäälä'
'420'=	'Leppävirta'
'421'=	'Lestijärvi'
'422'=	'Lieksa'
'423'=	'Lieto'
'425'=	'Liminka'
'426'=	'Liperi'
'444'=	'Lohja'
'430'=	'Loimaa'
'433'=	'Loppi'
'434'=	'Loviisa'
'435'=	'Luhanka'
'436'=	'Lumijoki'
'438'=	'Lumparland'
'440'=	'Luoto'
'441'=	'Luumäki'
'442'=	'Luvia'
'475'=	'Maalahti'
'476'=	'Maaninka'
'478'=	'Maarianhamina - Mariehamn'
'480'=	'Marttila'
'481'=	'Masku'
'483'=	'Merijärvi'
'484'=	'Merikarvia'
'489'=	'Miehikkälä'
'491'=	'Mikkeli'
'494'=	'Muhos'
'495'=	'Multia'
'498'=	'Muonio'
'499'=	'Mustasaari'
'500'=	'Muurame'
'503'=	'Mynämäki'
'504'=	'Myrskylä'
'505'=	'Mäntsälä'
'508'=	'Mänttä-Vilppula'
'507'=	'Mäntyharju'
'529'=	'Naantali'
'531'=	'Nakkila'
'532'=	'Nastola'
'534'=	'Nilsiä'
'535'=	'Nivala'
'536'=	'Nokia'
'538'=	'Nousiainen'
'540'=	'Nummi-Pusula'
'541'=	'Nurmes'
'543'=	'Nurmijärvi'
'545'=	'Närpiö'
'560'=	'Orimattila'
'561'=	'Oripää'
'562'=	'Orivesi'
'563'=	'Oulainen'
'564'=	'Oulu'
'567'=	'Oulunsalo'
'309'=	'Outokumpu'
'576'=	'Padasjoki'
'577'=	'Paimio'
'578'=	'Paltamo'
'445'=	'Parainen'
'580'=	'Parikkala'
'581'=	'Parkano'
'599'=	'Pedersören kunta'
'583'=	'Pelkosenniemi'
'854'=	'Pello'
'584'=	'Perho'
'588'=	'Pertunmaa'
'592'=	'Petäjävesi'
'593'=	'Pieksämäki'
'595'=	'Pielavesi'
'598'=	'Pietarsaari'
'601'=	'Pihtipudas'
'604'=	'Pirkkala'
'607'=	'Polvijärvi'
'608'=	'Pomarkku'
'609'=	'Pori'
'611'=	'Pornainen'
'638'=	'Porvoo'
'614'=	'Posio'
'615'=	'Pudasjärvi'
'616'=	'Pukkila'
'618'=	'Punkaharju'
'619'=	'Punkalaidun'
'620'=	'Puolanka'
'623'=	'Puumala'
'624'=	'Pyhtää'
'625'=	'Pyhäjoki'
'626'=	'Pyhäjärvi'
'630'=	'Pyhäntä'
'631'=	'Pyhäranta'
'635'=	'Pälkäne'
'636'=	'Pöytyä'
'678'=	'Raahe'
'710'=	'Raasepori'
'680'=	'Raisio'
'681'=	'Rantasalmi'
'683'=	'Ranua'
'684'=	'Rauma'
'686'=	'Rautalampi'
'687'=	'Rautavaara'
'689'=	'Rautjärvi'
'691'=	'Reisjärvi'
'694'=	'Riihimäki'
'696'=	'Ristiina'
'697'=	'Ristijärvi'
'698'=	'Rovaniemi'
'700'=	'Ruokolahti'
'702'=	'Ruovesi'
'704'=	'Rusko'
'707'=	'Rääkkylä'
'729'=	'Saarijärvi'
'732'=	'Salla'
'734'=	'Salo'
'736'=	'Saltvik'
'790'=	'Sastamala'
'738'=	'Sauvo'
'739'=	'Savitaipale'
'740'=	'Savonlinna'
'742'=	'Savukoski'
'743'=	'Seinäjoki'
'746'=	'Sievi'
'747'=	'Siikainen'
'748'=	'Siikajoki'
'791'=	'Siikalatva'
'749'=	'Siilinjärvi'
'751'=	'Simo'
'753'=	'Sipoo'
'755'=	'Siuntio'
'758'=	'Sodankylä'
'759'=	'Soini'
'761'=	'Somero'
'762'=	'Sonkajärvi'
'765'=	'Sotkamo'
'766'=	'Sottunga'
'768'=	'Sulkava'
'771'=	'Sund'
'775'=	'Suomenniemi'
'777'=	'Suomussalmi'
'778'=	'Suonenjoki'
'781'=	'Sysmä'
'783'=	'Säkylä'
'831'=	'Taipalsaari'
'832'=	'Taivalkoski'
'833'=	'Taivassalo'
'834'=	'Tammela'
'837'=	'Tampere'
'838'=	'Tarvasjoki'
'844'=	'Tervo'
'845'=	'Tervola'
'846'=	'Teuva'
'848'=	'Tohmajärvi'
'849'=	'Toholampi'
'850'=	'Toivakka'
'851'=	'Tornio'
'853'=	'Turku'
'857'=	'Tuusniemi'
'858'=	'Tuusula'
'859'=	'Tyrnävä'
'863'=	'Töysä'
'886'=	'Ulvila'
'887'=	'Urjala'
'889'=	'Utajärvi'
'890'=	'Utsjoki'
'892'=	'Uurainen'
'893'=	'Uusikaarlepyy'
'895'=	'Uusikaupunki'
'785'=	'Vaala'
'905'=	'Vaasa'
'908'=	'Valkeakoski'
'911'=	'Valtimo'
'092'=	'Vantaa'
'915'=	'Varkaus'
'918'=	'Vehmaa'
'921'=	'Vesanto'
'922'=	'Vesilahti'
'924'=	'Veteli'
'925'=	'Vieremä'
'926'=	'Vihanti'
'927'=	'Vihti'
'931'=	'Viitasaari'
'934'=	'Vimpeli'
'935'=	'Virolahti'
'936'=	'Virrat'
'941'=	'Vårdö'
'942'=	'Vähäkyrö'
'946'=	'Vöyri'
'972'=	'Yli-Ii'
'976'=	'Ylitornio'
'977'=	'Ylivieska'
'980'=	'Ylöjärvi'
'981'=	'Ypäjä'
'989'=	'Ähtäri'
'992'=	'Äänekoski'
low-high = 'Yhteensä';

RUN;

/* 7. Tallennetaan INDEKSImakrot ja KOYHINDmakrot -tiedostojen sisältämät makrot talteen */

%MACRO TeeMakrot;

%INCLUDE "&SAS_USERPATH&KENO.MAKROT&KENO.INDEKSImakro.sas";

%INCLUDE "&SAS_USERPATH&KENO.MAKROT&KENO.KOYHINDmakro.sas";

%INCLUDE "&SAS_USERPATH&KENO.MAKROT&KENO.DESIILITmakro.sas";

%MEND TeeMakrot;

%TeeMakrot;


/* 8. Tätä makromuuttujaa tutkimalla voi selvittää, onko tämä ohjelma ajettu */

%GLOBAL XALKU;
%LET XALKU = 1;



