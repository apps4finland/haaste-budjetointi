/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hy�dynt�� Tilastokeskuksen yleisten
* k�ytt�ehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto p��hakemistossa.
******************************************************************************/

/******************************************************************************
* Kuvaus: Parametritaulujen sek� indeksien hallinnointiohjelmat
* Tekij�: Jukka Mattila / TK		   			           
* Luotu: 3.9.2012				     					   
* Viimeksi p�ivitetty: 15.3.2013 			 		   	   
* P�ivitt�j�: Jukka Mattila / TK (4.4.2013 Anne Per�lahti)			     		   
******************************************************************************/

/*=============================================================================
Sis�lt��:

- Massap�ivitt�misohjelman, jolla kaikki parametritaulut voidaan p�ivitt��
tulevaisuuteen indeksisidonnaisten parametrien osalta.
- Yksitt�isrivip�ivityksen, jolla voi p�ivitt�� yksitt�isi� parametritaulun
rivej�.

Apuohjelmat:
- Indeksien lukemiseen liittyv� apuohjelma IndArvot
- Parametrien sidonnaisuuksiin liittyv� apuohjelma ParamTaulut
-----------------------------------------------------------------------------*/






/*=============================================================================
#1: IndArvot -apumakro


Makro indeksien arvojen noutamiseksi. T�t� kutsutaan osana indeksien 
p�ivitysmakroja. T�t� muokkaamalla voidaan vaihtaa indeksien sis�lt�j�,
tai noutaa uusia indeksej� taulusta. Makro saa tarvittavat arvot
ohjelmassa, jossa sit� kutsutaan.
-----------------------------------------------------------------------------*/
%macro IndArvot(INDTAULU) /
		DES = 'Indeksien arvojen noutaminen indeksitauluista';
	
	proc sql noprint;

		select min(vuosi) into :ALKU
		from &INDTAULU;

		select max(vuosi) into :LOPPU
		from &INDTAULU;
 	

	%do QZ = &ALKU %to &LOPPU;
		%GLOBAL ansio64&QZ IndKel&QZ TEL8020&QZ
				ind51&QZ ind51loka&QZ IndSth2000&QZ palkvahpros&QZ
				IndKelX&QZ IndKelO&QZ elvakmaks&QZ elvakmaks53&QZ 
				svpro&QZ svprmaks&QZ elkorsvmaks&QZ tyotvakmaks&QZ;
	%end;

		/*=====================================================================
		Ansiotasoindeksi
		---------------------------------------------------------------------*/
		%do QZ = &ALKU %to &LOPPU;
		select ansio64 into :ansio64&QZ
			from &indtaulu
			where vuosi = &QZ;
		%put NOTE: ANSIOTASOINDEKSI &QZ: &&ansio64&QZ;
		%end;

		/*=====================================================================
		Kansanel�keindeksi
		---------------------------------------------------------------------*/
		%do QZ = &ALKU %to &LOPPU;
		select IndKel into :IndKel&QZ
			from &indtaulu
			where vuosi = &QZ;
		%put NOTE: KANSANEL�KEINDEKSI &QZ: &&IndKel&QZ;
		%end;

		/*=====================================================================
		Kansanel�keindeksi, 2013 erityiskorotettu
		---------------------------------------------------------------------*/
		%do QZ = &ALKU %to &LOPPU;
		select IndKelX into :IndKelX&QZ
			from &indtaulu
			where vuosi = &QZ;
		%put NOTE: 2013 Erityiskorotettu kansanel�keindeksi &QZ: &&IndKelX&QZ;
		%end;

		/*=====================================================================
		Kansanel�keindeksi, 2013 j��dytetty
		---------------------------------------------------------------------*/
		%do QZ = &ALKU %to &LOPPU;
		select IndKelO into :IndKelO&QZ
			from &indtaulu
			where vuosi = &QZ;
		%put NOTE: 2013 J��dytetty kansanel�keindeksi  &QZ: &&IndKelO&QZ;
		%end;

		/*=====================================================================
		Palkkakerroin
		---------------------------------------------------------------------*/
		%do QZ = &ALKU %to &LOPPU;
		select TEL8020 into :TEL8020&QZ
			from &indtaulu
			where vuosi = &QZ;
		%put NOTE: PALKKAKERROIN &QZ: &&TEL8020&QZ;
		%end;

		/*=====================================================================
		Elinkustannusindeksi
		---------------------------------------------------------------------*/
		%do QZ = &ALKU %to &LOPPU;
		select ind51 into :ind51&QZ
			from &indtaulu
			where vuosi = &QZ;
		%put NOTE: ELINKUSTANNUSINDEKSI &QZ: &&ind51&QZ;
		%end;

		/*=====================================================================
		Elinkustannusindeksi: lokakuu
		---------------------------------------------------------------------*/
		%do QZ = &ALKU %to &LOPPU;
		select ind51loka into :ind51loka&QZ
			from &indtaulu
			where vuosi = &QZ;
		%put NOTE: ELINKUSTANNUSINDEKSI LOKAKUU &QZ: &&ind51loka&QZ;
		%end;

		/*=====================================================================
		Sosiaali- ja terveystoimen hintaindeksi
		---------------------------------------------------------------------*/
		%do QZ = &ALKU %to &LOPPU;
		select IndSth2000 into :IndSth2000&QZ
			from &indtaulu
			where vuosi = &QZ;
		%put NOTE: SOSIAALI- JA TERVEYSTOIMEN HINTAINDEKSI &QZ: &&IndSth2000&QZ;
		%end;

		/*=====================================================================
		Ty�el�keindeksi 20-80
		---------------------------------------------------------------------*/
		%do QZ = &ALKU %to &LOPPU;
		select TEL2080 into :TEL20&QZ
			from &indtaulu
			where vuosi = &QZ;
		%put NOTE: TY�EL�KEINDEKSI &QZ: &&TEL20&QZ;
		%end;

		/*=====================================================================
		Vakuutuspalkan prosenttiv�hennys
		---------------------------------------------------------------------*/
		%do QZ = &ALKU %to &LOPPU;
		select palkvahpros into :palkvahpros&QZ
			from &indtaulu
			where vuosi = &QZ;
		%put NOTE: Vakuutuspalkan prosenttiv�hennys &QZ: &&palkvahpros&QZ;
		%end;

		/*=====================================================================
		Ty�el�kemaksu alle/= 53v. ty�ntekij�ll�
		---------------------------------------------------------------------*/
		%do QZ = &ALKU %to &LOPPU;
		select elvakmaks into :elvakmaks&QZ
			from &indtaulu
			where vuosi = &QZ;
		%put NOTE: Ty�el�kemaksu alle 53v. ty�ntekij�ll� &QZ: &&elvakmaks&QZ;
		%end;
		
		/*=====================================================================
		Ty�el�kemaksu yli 53v. ty�ntekij�ll�
		---------------------------------------------------------------------*/
		%do QZ = &ALKU %to &LOPPU;
		select elvakmaks53 into :elvakmaks53&QZ
			from &indtaulu
			where vuosi = &QZ;
		%put NOTE: Ty�el�kemaksu yli 53v. ty�ntekij�ll� &QZ: &&elvakmaks53&QZ;
		%end;
		
		/*=====================================================================
		Sairaanhoitomaksu palkansaajilla ja yritt�jill�
		---------------------------------------------------------------------*/
		%do QZ = &ALKU %to &LOPPU;
		select svpro into :svpro&QZ
			from &indtaulu
			where vuosi = &QZ;
		%put NOTE: Sairaanhoitomaksu palkansaajilla ja yritt�jill� &QZ: &&svpro&QZ;
		%end;
		
		/*=====================================================================
		P�iv�rahamaksu palkansaajilla
		---------------------------------------------------------------------*/
		%do QZ = &ALKU %to &LOPPU;
		select svprmaks into :svprmaks&QZ
			from &indtaulu
			where vuosi = &QZ;
		%put NOTE: P�iv�rahamaksu palkansaajilla &QZ: &&svprmaks&QZ;
		%end;

		/*=====================================================================
		Sairaanhoitomaksun lis�prosentti el�kel�isill�
		---------------------------------------------------------------------*/
		%do QZ = &ALKU %to &LOPPU;
		select elkorsvmaks into :elkorsvmaks&QZ
			from &indtaulu
			where vuosi = &QZ;
		%put NOTE: Sairaanhoitomaksun lis�prosentti el�kel�isill� &QZ: &&elkorsvmaks&QZ;
		%end;
		
		/*=====================================================================
		Ty�tt�myysvakuutusmaksu ty�ntekij�ll�
		---------------------------------------------------------------------*/
		%do QZ = &ALKU %to &LOPPU;
		select tyotvakmaks into :tyotvakmaks&QZ
			from &indtaulu
			where vuosi = &QZ;
		%put NOTE: Ty�tt�myysvakuutusmaksu ty�ntekij�ll� &QZ: &&tyotvakmaks&QZ;
		%end;	

	
	quit;

%mend IndArvot;


/*=============================================================================
#2 ParamTaulut -apumakro

ParamTaulut -ohjelma sis�lt�� parametritaulujen indeksisidonnaiset
parametrit, niihin liittyv�n indeksin, sek� py�ristystarkkuuden. Ohjelmaa
kutsutaan osana massa- ja yksitt�isp�ivityksi�, eik� se n�in ole standalone.

Makro saa kutsun ja tiedon parametritaulun sijainnista makrosta, jossa se 
ajetaan. T�t� muokkaamalla voidaan vaihtaa indeksisidonnaisuuksia, 
lis�t� tauluihin p�ivitett�vi� indeksej�, sek� muokata py�ristystarkkuutta.
-----------------------------------------------------------------------------*/
%macro ParamTaulut /DES = 'Parametrien listaukset tauluissa';

	/*=========================================================================
	P�ivitys: opintotuki (ei indeksip�ivitett�vi� parametreja)
	-------------------------------------------------------------------------*/
	%if %length (&POPINTUKI) > 0 %then %do;
		%luo(&POPINTUKI)
	%end;

	/*=========================================================================
	P�ivitys: toimeentulotuki
	-------------------------------------------------------------------------*/
	%if %length(&PTOIMTUKI) > 0 %then %do;
		%luo(&PTOIMTUKI)
		%paivita(YksinKR1, IndKelX, &PTOIMTUKI, .01, 2011, 444.26)
		%paivita(YksinKR2, IndKelX, &PTOIMTUKI, .01, 2011, 444.26)
	%end;

	/*=========================================================================
	P�ivitys: ty�tt�myysturva
	-------------------------------------------------------------------------*/
	%if %length(&PTTURVA) > 0 %then %do;
		%luo(&PTTURVA);
		%paivita(KorotusOsa, IndKelX, &PTTURVA, .01, 2001, 3.82)
		%paivita(TTPerus, IndKelX, &PTTURVA, .01, 2001, 26.09)
		%paivita(TTLaps1, IndKelX, &PTTURVA, .01, 2001, 4.21)
		%paivita(TTLaps2, IndKelX, &PTTURVA, .01, 2001, 6.18)
		%paivita(TTLaps3, IndKelX, &PTTURVA, .01, 2001, 7.97)
		%kytkentaSVTT1(VahPros, palkvahpros, &PTTURVA)
	%end;

	/*=========================================================================
	P�ivitys: asumistuki (ei indeksip�ivitett�vi� parametreja)
	-------------------------------------------------------------------------*/
	%if %length(&PASUMTUKI) > 0 %then %do;
		%luo(&PASUMTUKI)
	%end;

	/*=========================================================================
	P�ivitys: el�kkeensaajan asumistuki
	-------------------------------------------------------------------------*/
	%if %length(&PELASUMTUKI) > 0 %then %do;
		%luo(&PELASUMTUKI)
		%paivita(EPieninTuki, IndKel, &PELASUMTUKI, .01, 2001, 64.56)
		%paivita(LisOVRaja, IndKel, &PELASUMTUKI, 1, 2001, 6986)
		%paivita(LisOVRaja2, IndKel, &PELASUMTUKI, 1, 2001, 10240)
		%paivita(LisOVRaja3, IndKel, &PELASUMTUKI, 1, 2001, 11221)
		%paivita(LisOVRaja4, IndKel, &PELASUMTUKI, 1, 2001, 6986)
		%paivita(LisOVRaja5, IndKel, &PELASUMTUKI, 1, 2001, 11221)
		%paivita(OmRaja, IndKel, &PELASUMTUKI, 1, 2001, 13205)
		%paivita(OmRaja2, IndKel, &PELASUMTUKI, 1, 2001, 21128)
		%paivita(PerusOVast, IndKel, &PELASUMTUKI, .01, 2001, 491.51)
	%end;

	/*=========================================================================
	P�ivitys: kansanel�ke
	-------------------------------------------------------------------------*/
	%if %length(&PKANSEL) > 0 %then %do;
		%luo(&PKANSEL)
		%paivita(ApuLis, IndKelX, &PKANSEL, .01, 2001, 72.57)
		%paivita(HoitoLis, IndKelX, &PKANSEL, .01, 2001, 106.89)
		%paivita(HoitTukiNorm, IndKelX, &PKANSEL, .01, 2001, 49.69)
		%paivita(HoitTukiKor, IndKelX, &PKANSEL, .01, 2001, 123.70)
		%paivita(HoitTukiErit, IndKelX, &PKANSEL, .01, 2001, 261.57)
		%paivita(KELaps, IndKelX, &PKANSEL, .01, 2001, 17.66)
		%paivita(KEMinimi, IndKelX, &PKANSEL, .01, 2001, 5.38)
		%paivita(KERaja, IndKelX, &PKANSEL, 1, 2001, 536)
		%paivita(LaitosTaysiY1, IndKelX, &PKANSEL, .01, 2001, 506.35)
		%paivita(LaitosTaysiY2, IndKelX, &PKANSEL, .01, 2001, 506.35)
		%paivita(LaitosTaysiP1, IndKelX, &PKANSEL, .01, 2001, 449.13)
		%paivita(LaitosTaysiP2, IndKelX, &PKANSEL, .01, 2001, 449.13)
		%paivita(LapsElPerus, IndKelX, &PKANSEL, .01, 2001, 48.05)
		%paivita(LapsElTayd, IndKelX, &PKANSEL, .01, 2001, 72.68)
		%paivita(LapsElMinimi, IndKelX, &PKANSEL, .01, 2001, 5.38)
		%paivita(LapsHoitTukNorm, IndKelX, &PKANSEL, .01, 2001, 74.19)
		%paivita(LapsHoitTukKorot, IndKelX, &PKANSEL, .01, 2001, 173.12)
		%paivita(LapsHoitTukErit, IndKelX, &PKANSEL, .01, 2001, 335.69)
		%paivita(LeskAlku, IndKelX, &PKANSEL, .01, 2001, 261.15)
		%paivita(LeskPerus, IndKelX, &PKANSEL, .01, 2001, 81.80)
		%paivita(LeskTaydY1, IndKelX, &PKANSEL, .01, 2001, 424.55)
		%paivita(LeskTaydY2, IndKelX, &PKANSEL, .01, 2001, 424.55)
		%paivita(LeskTaydP1, IndKelX, &PKANSEL, .01, 2001, 367.33)
		%paivita(LeskTaydP2, IndKelX, &PKANSEL, .01, 2001, 367.33)
		%paivita(LeskMinimi, IndKelX, &PKANSEL, .01, 2001, 5.38)
		%paivita(RiLi, IndKelX, &PKANSEL, .01, 2001, 39.56)
		%paivita(TakuuEl, IndKelX, &PKANSEL, .01, 2001, 593.79)
		%paivita(TaysKEY1, IndKelX, &PKANSEL, .01, 2001, 506.35)
		%paivita(TaysKEY2, IndKelX, &PKANSEL, .01, 2001, 506.35)
		%paivita(TaysKEP1, IndKelX, &PKANSEL, .01, 2001, 449.13)
		%paivita(TaysKEP2, IndKelX, &PKANSEL, .01, 2001, 449.13)
		%paivita(VammNorm, IndKelX, &PKANSEL, .01, 2001, 74.19)
		%paivita(VammKorot, IndKelX, &PKANSEL, .01, 2001, 173.12)
		%paivita(VammErit, IndKelX, &PKANSEL, .01, 2001, 335.69)
		%paivita(VeterLisa, IndKelX, &PKANSEL, .01, 2001, 83.92)
		%paivita(YliRiliMinimi, IndKelX, &PKANSEL, .01, 2001, 5.07)
		%paivita(YliRiliRaja, IndKelX, &PKANSEL, .01, 2001, 981.60)
		%paivita(YliRiliAskel, IndKelX, &PKANSEL, .01, 2001, 58.36)
		%paivita(YliRiliAskel2, IndKelX, &PKANSEL, .01, 2001, 144.38)
	%end;

	/*=========================================================================
	P�ivitys: kotihoidon tuki
	-------------------------------------------------------------------------*/
	%if %length(&PKOTIHTUKI) > 0 %then %do;
		%luo(&PKOTIHTUKI)
		%paivita(Lisa, IndKel, &PKOTIHTUKI, .01, 2010, 168.19)
		%paivita(OsRaha, IndKel, &PKOTIHTUKI, .01, 2010, 90.00)
		%paivita(Perus, IndKel, &PKOTIHTUKI, .01, 2010, 314.28)
		%paivita(Sisar, IndKel, &PKOTIHTUKI, .01, 2010, 94.09)
		%paivita(Sisarmuu, IndKel, &PKOTIHTUKI, .01, 2010, 60.46)

		/*=====================================================================
		P�iv�hoitoa koskeva osa taulusta
		---------------------------------------------------------------------*/

			%PaivitaPhoito(PHRaja1, ansio64, &PKOTIHTUKI, 1, 2008, 1099)
			%PaivitaPhoito(PHRaja2, ansio64, &PKOTIHTUKI, 1, 2008, 1355)
			%PaivitaPhoito(PHRaja3, ansio64, &PKOTIHTUKI, 1, 2008, 1609)
			%PaivitaPhoito(PHRaja4, ansio64, &PKOTIHTUKI, 1, 2008, 1716)
			%PaivitaPhoito(PHRaja5, ansio64, &PKOTIHTUKI, 1, 2008, 1823)
			%PaivitaPhoito(PHVahenn, ansio64, &PKOTIHTUKI, 1, 2008, 107)
			%PaivitaPhoito(PHYlaRaja, IndSth2000, &PKOTIHTUKI, 1, 2008, 233)
			%PaivitaPhoito(PHYlaRaja2, IndSth2000, &PKOTIHTUKI, 1, 2008, 210)
			%PaivitaPhoito(PHAlaRaja, IndSth2000, &PKOTIHTUKI, 1, 2008, 21)

	%end;

	/*=========================================================================
	P�ivitys: lapsilis�
	-------------------------------------------------------------------------*/
	%if %length (&PLLISA) > 0 %then %do;
		%luo(&PLLISA)
		%paivitall(AlenElatTuki, Ind51loka, &PLLISA, .01, &PVUOSI)
		%paivitall(ElatTuki, Ind51loka, &PLLISA, .01, &PVUOSI)
		%paivita(Lapsi1, IndKelO, &PLLISA, .01, 2012, 104.19)
		%paivita(Lapsi2, IndKelO, &PLLISA, .01, 2012, 115.13)
		%paivita(Lapsi3, IndKelO, &PLLISA, .01, 2012, 146.91)
		%paivita(Lapsi4, IndKelO, &PLLISA, .01, 2012, 168.27)
		%paivita(Lapsi5, IndKelO, &PLLISA, .01, 2012, 189.63)
		%paivita(YksHuolt, IndKelO, &PLLISA, .01, 2012, 48.55)
	%end;

	/*=========================================================================
	P�ivitys: sairausvakuutus
	-------------------------------------------------------------------------*/
	%if %length (&PSAIRVAK) > 0 %then %do;
		%luo(&PSAIRVAK)
		%paivita(Minimi, IndKelX, &PSAIRVAK, .01, 2010, 22.04)
		%paivita(SRaja1, TEL8020, &PSAIRVAK, 1, 2010, 1264)
		%paivita(SRaja2, TEL8020, &PSAIRVAK, 1, 2010, 32892)
		%paivita(SRaja3, TEL8020, &PSAIRVAK, 1, 2010, 50606)
		%paivita(VanhMin, IndKelX, &PSAIRVAK, .01, 2010, 22.04)
		%kytkentaSVTT1(PalkVah, palkvahpros, &PSAIRVAK)
	%end;

	/*=========================================================================
	P�ivitys: kiinteist�vero (ei indeksip�ivitett�vi� parametreja)
	-------------------------------------------------------------------------*/
	%if %length(&PKIVERO) > 0 %then %do;

	%end;

	/*=========================================================================
	P�ivitys: vero
	-------------------------------------------------------------------------*/
	%if %length (&PVERO) > 0 %then %do;
		%luo(&PVERO)
		%tulorajat(Ind51)
		%kytkentaSVTT1(ElVakMaksu, elvakmaks, &PVERO)
		%kytkentaSVTT1(ElVakMaksu53, elvakmaks53, &PVERO)
		%kytkentaSVTT1(SvPros, svpro, &PVERO)
		%kytkentaSVTT1(SvPrMaksu, svprmaks, &PVERO)
		%kytkentaSVTT1(ElKorSvMaksu, elkorsvmaks, &PVERO)
		%kytkentaSVTT1(TyotVakMaksu, tyotvakmaks, &PVERO)

		/*=====================================================================
		N�m� kytkenn�t liittyv�t KANSEL -mallin p�ivityksiin. 
		Kansanel�kkeen noustessa kunnallisverotuksen el�ketulov�hennyst�
		korjataan.
		---------------------------------------------------------------------*/
			%if %length (&PKANSEL) > 0 %then %do;
			%kytkentaV1(KelaPuol, &PKANSEL, &PVERO)
			%kytkentaV1(KelaYks, &PKANSEL, &PVERO)
			%end;
	%end;

%mend ParamTaulut;

/*=============================================================================
#3 Param_Paivitys -ohjelma

Ohjelma p�ivitt�� massana perusvuoden (pvuosi) ja tavoitevuoden (tvuosi)
aikav�lin. Hy�dynnett�viss� mm. tulevaisuuteen kohdistuvien muutosten 
p�ivitt�miseksi (indeksiennusteet). Parametrit p�ivitet��n p��osin vuoden
alkuihin (pl. poikkeukselliset tapaukset, kuten p�iv�hoidon parametrit,
joka noudattaa normaalia sykli��n). Parametritauluissa oltava rivit!


Tarvitsee:
	- Perusvuoden ja viimeisen vuoden (ensimm�iset kaksi parametria)
	- Indeksitaulun sijainnin ja nimen
	- Parametritaulujen nimet (param.kansiossa) jotka p�ivitet��n
	- Kaksi viimeist� rivi� m��ritt�v�t kuukauden ja vuoden, jotka p�ivitet��n

Tuottaa:
	- work -kansioon p�ivitetyt parametritaulut
	- jos j�t�t parametritaulun nimen tyhj�ksi, ao. taulua ei p�ivitet�	

%ParamPaivitys(
	pvuosi = 2013, 
	tvuosi = 2017, 
	indtaulu = param.pindeksi_vuosi,
	popintuki = ,
	ptoimtuki = , 
	ptturva = ,
	pasumtuki = ,
	pelasumtuki = ,
	pkansel = pkansel,
	pkotihtuki = ,
	pllisa = ,
	psairvak = ,
	pkivero = ,
	pvero = pvero
	);

-----------------------------------------------------------------------------*/

%macro ParamPaivitys (PVUOSI, TVUOSI, INDTAULU,
		POPINTUKI, PTOIMTUKI, PTTURVA, PASUMTUKI, PELASUMTUKI, PKANSEL, 
		PKOTIHTUKI, PLLISA, PSAIRVAK, PKIVERO, PVERO) /
		DES = 'Parametritaulujen massap�ivitysohjelma';

		%let _notes = %sysfunc(getoption(NOTES));
		options nonotes;

		/*=====================================================================
		Virheabortit (p�ivitysrajoitukset, jotka katkaisevat ohjelman
		jos virheellisi� asetuksia on annettu)
		---------------------------------------------------------------------*/
		%if %length(&PKANSEL) > 0 and %length(&PVERO) < 1 %then %do;
		%put WARNING: Vero -parametrit parametritaulun nimi puuttuu.;
		%put WARNING: Kansel -parametreja p�ivitett�ess� VERO p�ivitett�v�.;
		%put WARNING: VERO-parametrit KelaYks ja KelaPuol p�ivitt�m�tt�.;
		%put WARNING: PARAMETRITAULUJEN P�IVITYST� JATKETAAN.;

		%end;

		/*=====================================================================
		Indeksitaulun tarkastus		
		---------------------------------------------------------------------*/
		proc sql noprint;
			select max(vuosi) into :cap from &indtaulu;
			select min(vuosi) into :floor from &indtaulu;
		quit;

		%if (&pvuosi < &floor or &tvuosi > &cap) %then %do;
			%if &pvuosi < &floor %then %do;
			%put WARNING: Indeksikorjausten vuosi alle taulussa olevan vuoden.;
			%end;

			%if &tvuosi > &cap %then %do;
			%put WARNING: Indeksikorjausten vuosi yli taulussa olevan vuoden.;
			%end;

			%put WARNING: PARAMETRITAULJEN P�IVITYS KESKEYTETTY.;
			%goto exit;
		%end;

	/*========================================================================
	Apumakro: Indeksien arvojen noutaminen
	-------------------------------------------------------------------------*/
	%IndArvot(&INDTAULU);

	/*=========================================================================
	Apumakro: p�ivityksen pohjataulut work -kansioon
	-------------------------------------------------------------------------*/
	%macro Luo(LUOTAULU) / DES = 'Apumakro taulujen luomiseen work -kansioon';
		proc sql noprint;
				create table &LUOTAULU as select * from PARAM.&LUOTAULU;

		/*=====================================================================
		Tarkastetaan vuoden olemassaolo, luodaan tarvittaessa
		---------------------------------------------------------------------*/
			%let MAX = %sysevalf(&TVUOSI-&PVUOSI);
			%do QD = 1 %to &MAX;  
			%let LVUOSI = %sysevalf(&PVUOSI+&QD);

				select max(vuosi) into :VUOSICHECK
				from &LUOTAULU;

				%if &VUOSICHECK < &LVUOSI %then %do;

					%put WARNING: Parametritaulussa &LUOTAULU ei kaikkia vuosia.;
					%put WARNING: Vuoden &LVUOSI lains��d�nn�n pohja;
					%put WARNING: on kopio vuodesta &VUOSICHECK.;

		/*=====================================================================
		Tavalliset parametritaulut
		---------------------------------------------------------------------*/
					%if &LUOTAULU ^= &PKOTIHTUKI %then %do;

						create table _temp as select * from &LUOTAULU
						where vuosi = &VUOSICHECK;

						update _temp set vuosi = &LVUOSI;
						insert into &LUOTAULU select * from _temp;
						drop table _temp;
					%end;

		/*=====================================================================
		Kotihoidon tuen taulun erityistapaus
		---------------------------------------------------------------------*/
					%if &LUOTAULU = &PKOTIHTUKI %then %do;

						select vuosi into :check from &LUOTAULU
						where vuosi = %sysevalf(&LVUOSI-1) and kuuk = 8;

						create table _temp as select * from &LUOTAULU
						where vuosi = &VUOSICHECK
						%if %symexist(check) = 1 %then %do;
							%if &check = %sysevalf(&LVUOSI-1) %then %do;
							and kuuk = 8
							%end;
						%end;;
						
						update _temp set vuosi = &LVUOSI;
						update _temp set kuuk = 1;
						insert into &LUOTAULU select * from _temp;

		/*=====================================================================
		Lis�t��n rivi ja 8. kuukausi, jos p�ivitysvuosi
		---------------------------------------------------------------------*/
							%if %symexist(check) = 0
								%then %do;
								update _temp set kuuk = 8;
								insert into &LUOTAULU select * from _temp;
							%end;
							%else %do;
								%if &check = %sysevalf(&LVUOSI-2) %then %do;
								update _temp set kuuk = 8;
								insert into &LUOTAULU select * from _temp;
								%end;
							%end;
						%end;
					%end;
				%end;
		quit;

		/*=====================================================================
		J�rjestet��n taulut
		---------------------------------------------------------------------*/
		%if &LUOTAULU ^= &PKOTIHTUKI %then %do;
			proc sort data = &LUOTAULU; by descending vuosi;run;
		%end;

		%if &LUOTAULU = &PKOTIHTUKI %then %do;
			proc sort data = &LUOTAULU; by descending vuosi descending kuuk;run;
		%end;
%mend Luo;

	/*=========================================================================
	Parametritaulujen p�ivitysmakro
	-------------------------------------------------------------------------*/
	%macro Paivita(PARAM, IND, PTAULU, RND, LPVUOSI, LPTASO) 
	/ DES = 'Taulujen p�ivitysmakro';

	/*=========================================================================
	P�ivitysohjelman runko: taulujen p�ivitt�minen
	-------------------------------------------------------------------------*/
		%let MAX = %sysevalf(&TVUOSI-&PVUOSI);
		%do QD = 1 %to &MAX;  

		%let LVUOSI = %sysevalf(&PVUOSI+&QD);
		%let EVUOSI = %sysevalf(&LVUOSI-1);

		/*=====================================================================
		Jatketaan p�ivitt�mist�
		HUOM! T�ss� kohtaa eritelty sairausvakuutuksen tulorajojen
		eurokatkaisut (parametria ei py�ristet�, vaan katkaistaan 
		kokonaiseuroon, ts. int).
		---------------------------------------------------------------------*/
		proc sql noprint;

				update &PTAULU
					set &PARAM = 

					%if (&PARAM = SRaja1 or &PARAM = SRaja2 or &PARAM = SRaja3)
					%then %do;
						int(						
							((&&&IND&LVUOSI)/(&&&IND&LPVUOSI)) * &LPTASO
							)
					%end;

					%else %do;
						round(
						((&&&IND&LVUOSI)/(&&&IND&LPVUOSI)) * &LPTASO
						, &RND)
					%end;

					where vuosi = &LVUOSI;
			quit;

		%end;

	%mend Paivita;

	/*=========================================================================
	Lapsilis� -taulun elatustuki tarvitsee oman p�ivitysmakron
	ketjutetun laskennan johdosta.
	-------------------------------------------------------------------------*/

	%macro PaivitaLL(PARAM, IND, PTAULU, RND, PVUOSI) 
	/ DES = 'Lapsilis�taulun elatustuen p�ivitysmakro';

	/*=========================================================================
	P�ivitysohjelman runko: taulujen p�ivitt�minen
	-------------------------------------------------------------------------*/
		%let MAX = %sysevalf(&TVUOSI-&PVUOSI);
		%do QD = 1 %to &MAX;  

		%let EVUOSI = %sysevalf(&PVUOSI+&QD-1);
		%let LVUOSI = %sysevalf(&PVUOSI+&QD);

		%let P1VUOSI = %sysevalf(&PVUOSI+&QD-1);
		%let P2VUOSI = %sysevalf(&PVUOSI+&QD-2);

		/*=====================================================================
		Jatketaan p�ivitt�mist�
		---------------------------------------------------------------------*/
		proc sql noprint;

				select &PARAM into :UPD from &PTAULU
				where vuosi = &EVUOSI;

				update &PTAULU
					set &PARAM = 
						round(
						((&&&IND&P1VUOSI)/(&&&IND&P2VUOSI)) * &UPD
						, &RND)
					where vuosi = &LVUOSI;
			quit;

		%end;

	%mend PaivitaLL;

	/*=========================================================================
	P�iv�hoito -taulu tarvitsee oman p�ivitysaliohjelman p�iv�hoitoihin
	liittyvien elokuutarkastusten johdosta.
	-------------------------------------------------------------------------*/
	%macro PaivitaPhoito(PARAM, IND, PTAULU, RND, LPVUOSI, LPTASO) / DES = 'Erityismakro
		P�iv�hoito -parametrien p�ivitt�miseksi elokuusykli� varten';

		%let MAX = %sysevalf(&TVUOSI-&PVUOSI);

	/*=========================================================================
	K�ynnistet��n p�iv�hoitotaulun p�ivitysluuppi
	-------------------------------------------------------------------------*/
	%do QD = 1 %to &MAX;

		%let LVUOSI = %sysevalf(&PVUOSI+&QD);
		%let EVUOSI = %sysevalf(&PVUOSI+&QD-1);
		%let E2VUOSI = %sysevalf(&PVUOSI+&QD-2);
		%let E4VUOSI = %sysevalf(&PVUOSI+&QD-4);

		/*=====================================================================
		Tarkastetaan, onko indeksi p�ivitetty edellisen vuoden elokuussa
		---------------------------------------------------------------------*/
		proc sql noprint;

			select kuuk into :check from
			&PTAULU where vuosi = &EVUOSI and kuuk = 8;		

		/*=====================================================================
		Kuukausi = 1 saa arvon edellisen vuoden 
			1. elokuun (p�ivitetty edellisen� vuotena)
			2. tammikuun (ei p�ivitetty edellisen� vuotena)
		arvosta
		---------------------------------------------------------------------*/
				select &PARAM into :UPD from &PTAULU
				where vuosi = &EVUOSI and kuuk = 8;

		/*=====================================================================
		Jos elokuun indeksip�ivitys on edellisen� vuonna, t�m�n vuoden
		parametreille ei tehd� indeksimuutosta
		---------------------------------------------------------------------*/
		%if %symexist(check) = 1 %then %do;

				select &PARAM into :UPD from &PTAULU 
				where vuosi = &EVUOSI and kuuk = 
				%if &EVUOSI = 2011 %then %do; 3;%end;
				%else %do; 8;%end;;
	
				update &PTAULU
				set &PARAM = round(&UPD, &RND)
				where vuosi = &LVUOSI and kuuk = 1;

		%end;

		/*=====================================================================
		Jos elokuun p�ivityst� ei ole, se tehd��n t�n� vuonna.
		Kuukausi = 8 saa indeksikorjatun arvon
		HUOM! kuitenkin EDELLISEN vuoden indeksin mukaisesti!
		---------------------------------------------------------------------*/

				select &PARAM into :upd from &PTAULU
				where vuosi = &EVUOSI;

				update &PTAULU
				set &PARAM =
					round(
				((&&&IND&E2VUOSI)/(&&&IND&E4VUOSI)) * &UPD
				, &RND)
				where vuosi = &LVUOSI 
				and kuuk = 8;
	
		quit;
					
	%end;

	%mend PaivitaPhoito;

	/*=========================================================================
	Kytkent� VERO- ja KANSEL -parametrien v�lill�: el�ketulov�hennys
	-------------------------------------------------------------------------*/
	%macro KytkentaV1(PARAM, PKANSEL, PVERO) / DES = 'Verotuksen
		el�ketulov�hennyksen ja kansanel�kkeen maksimin huomioiva kytkent�';
		%let MAX = %sysevalf(&TVUOSI-&PVUOSI);
		%do QD = 1 %to &MAX;  

			%let LVUOSI = %sysevalf(&PVUOSI+&QD);

		/*=====================================================================
		T�m� p�ivitt�� vero -taulun parametrin vastaamaan koko vuoden
		py�ristetty� kansanel�kkeen enimm�ism��r��.

		Vero -taulun parametri ValtElKerr vastaa lains��d�nn�n kerrointa.
		T�t� parametri� pit�� tn. inflaatiokorjata, kun verotuksen 
		taulukkoja inflaatiokorjataan.
		---------------------------------------------------------------------*/
			proc sql noprint;

				select round((TaysKEY1*12),1) into :UPD1
				from &PKANSEL where vuosi = &LVUOSI;

				update &PVERO
				set &PARAM = &UPD1
				where vuosi = &LVUOSI;

			quit;

		%end;

	%mend KytkentaV1;

	/*=========================================================================
	Kytkent� SAIRVAK ja TTURVA -parametreist� vakuutuspalkan
	prosenttiv�hennykseen, ja VERO -parametreist� TyEl-maksuun, 
	sairausvakuutusmaksuun ja ty�tt�myysvakuutusmaksuun.
	-------------------------------------------------------------------------*/
	%macro kytkentaSVTT1(PARAM, IND, PTAULU) / DES = 'Vakuutuspalkan 
		prosenttiv�hennyksen, TyEl-maksun, sairausvakuutusmaksun ja
		ty�tt�myysvakuutusmaksun huomioiva kytkent�';
		%let MAX = %sysevalf(&TVUOSI-&PVUOSI);
		%do QD = 1 %to &MAX;  

			%let LVUOSI = %sysevalf(&PVUOSI+&QD);

			proc sql noprint;

		/*=====================================================================
		Asettaa vakuutuspalkan prosenttiv�hennyksen indeksitaulun
		mukaiseksi
		---------------------------------------------------------------------*/
				update &PTAULU
				set &PARAM = &&&IND&LVUOSI
				where vuosi = &LVUOSI;

			quit;

		%end;

	%mend kytkentaSVTT1;

	/*=========================================================================
	Verotuksen tulorajojen inflaatiokorjausta varten luotu makro.
	Infl -parametri m��ritt��, mit� indeksi� inflaatiokorjaukseen k�ytet��n.
	-------------------------------------------------------------------------*/
	%macro tulorajat(infl) / DES = 'Verotuksen tulorajojen inflaatiokorjaus';

	/*=========================================================================
	Poimitaan talteen perusvuoden mukaiset tulorajat ja vakioverot
	-------------------------------------------------------------------------*/
	proc sql noprint;
		%do VRAJ = 1 %to 12;
			select raja&VRAJ, pros&VRAJ into 
				:xraja&VRAJ,
				:xpros&VRAJ
			from &PVERO
			where vuosi = &PVUOSI;
		%end;;
	quit;

	/*=========================================================================
	Tulorajojen inflaatiokorjaus:
	-------------------------------------------------------------------------*/
		%let MAX = %sysevalf(&TVUOSI-&PVUOSI);
		%do QD = 1 %to &MAX;  
		%let upvuosi = %sysevalf(&pvuosi+&qd);

		/*=====================================================================
		Parametritaulussa on 12 tulorajaa. M��ritet��n ensimm�inen
		(nolla) manuaalisesti ja mystinen 8 euroa vakiom��r�ksi.
		---------------------------------------------------------------------*/
			%do vraj = 2 %to 12;
					%let kierros = %sysevalf(&VRAJ-1);
					%let vakiov1 = 8;
					%let xrajab1 = 0;

		/*=====================================================================
		Lasketaan tulorajat uudelleen
		---------------------------------------------------------------------*/
					%let xrajab&vraj = %sysfunc(round 
							(%sysevalf(
							(&&&infl&upvuosi/&&&infl&pvuosi)*&&xraja&vraj)
							,100));
							
		/*=====================================================================
		Lasketaan tulorajoja vastaavat veron vakiom��r�t uudelleen
		---------------------------------------------------------------------*/
					%let vakiov&vraj = %sysevalf(
							(&&xrajab&vraj-&&xrajab&kierros)*&&xpros&kierros
							+&&vakiov&kierros
							);

		/*=====================================================================
		P�ivitet��n verotuksen parametritaulua
		---------------------------------------------------------------------*/
					proc sql noprint; 
						update &pvero
							set raja&vraj = &&xrajab&vraj
								where vuosi = &upvuosi;
						update &pvero
							set vakio&vraj = &&vakiov&vraj
								where vuosi = &upvuosi;
					quit;
			%end;
		%end;

	%mend tulorajat;

	/*=========================================================================
	P�ivitet��n parametritaulut
	-------------------------------------------------------------------------*/
	%ParamTaulut;

		/*=====================================================================
		Virhepoistuminen
		---------------------------------------------------------------------*/
		%exit:;

options &_notes;

%mend ParamPaivitys;





/*=============================================================================
#4 ParamRivi

Yksitt�isen vuoden p�ivitt�minen. T�ll� voidaan p�ivitt�� my�s k�ytt�j�n
tekemi� parametririvej� (ts. itsenimettyj�).

Tauluvuosi ja tkuuk ovat parametritaulun p�ivityskohteena olevat rivit.
N�iss� voidaan k�ytt�� omia nimikkeit� (esim. tauluvuosi = 20165). T�ll�in
ohjelma p�ivitt�� ao. rivi�, tvuosi (tavoitevuosi) ja pvuosi (perusvuosi)
mukaisten indeksimuutosten perusteella.

%ParamRivi(
	tauluvuosi = 20161,
	pvuosi = 2013, 
	tvuosi = 2016, 
	indtaulu = param.pindeksi_vuosi,
	popintuki = ,
	ptoimtuki = , 
	ptturva = ,
	pasumtuki = ,
	pelasumtuki = ,
	pkansel = pkansel,
	pkotihtuki = ,
	pllisa = ,
	psairvak = ,
	pkivero = ,
	pvero = pvero
	);
-----------------------------------------------------------------------------*/

%macro ParamRivi(TAULUVUOSI, PVUOSI, TVUOSI, INDTAULU,
		POPINTUKI, PTOIMTUKI, PTTURVA, PASUMTUKI, PELASUMTUKI, PKANSEL, 
		PKOTIHTUKI, PLLISA, PSAIRVAK, PKIVERO, PVERO) /
		DES = 'Ohjelma parametritaulun yksitt�isten rivien p�ivitt�miseksi';

		%let _notes = %sysfunc(getoption(NOTES));
		options nonotes;

		/*=====================================================================
		Virheabortit (kuten massap�ivityksiss�)
		---------------------------------------------------------------------*/
		%if %length(&PKANSEL) > 0 and %length(&PVERO) < 1 %then %do;
		%put WARNING: Vero -parametrit parametritaulun nimi puuttuu.;
		%put WARNING: Kansel -parametreja p�ivitett�ess� VERO p�ivitett�v�.;
		%put WARNING: VERO-parametrit KelaYks ja KelaPuol p�ivitt�m�tt�.;
		%put WARNING: PARAMETRITAULUJEN P�IVITYST� JATKETAAN.;

		%end;

		/*=====================================================================
		Indeksitaulun tarkastus
		---------------------------------------------------------------------*/
		proc sql noprint;
			select max(vuosi) into :cap from &indtaulu;
			select min(vuosi) into :floor from &indtaulu;
		quit;

		%if (&tvuosi > &cap OR &pvuosi < &floor) %then %do;

		%if &tvuosi > &cap %then %do;
		%put WARNING: Indeksikorjausten vuosi yli taulussa olevan vuoden.;
		%end;

		%if &pvuosi < &floor %then %do;
		%put WARNING: Indeksikorjausten vuosi alle taulussa olevan vuoden.;
		%end;

		%put WARNING: PARAMETRITAULJEN P�IVITYS KESKEYTETTY.;
			
			%goto exit;
		%end;

	/*=========================================================================
	Haetaan indeksien arvot symboleiksi
	-------------------------------------------------------------------------*/
	%IndArvot(&INDTAULU);

	/*=========================================================================
	Apumakro: p�ivityksen pohjataulut work -kansioon
	-------------------------------------------------------------------------*/
	%macro Luo(LUOTAULU) / DES = 'Apumakro taulujen luomiseen work -kansioon';
		proc sql noprint;
			create table &LUOTAULU as select * from PARAM.&LUOTAULU;

			select vuosi into :VUOSICHECK
				from &LUOTAULU where vuosi = &TAULUVUOSI;

				%if %symexist(VUOSICHECK)=0 %then %do;

					select max(vuosi) into :MAXVUOSI
					from &LUOTAULU;

					%put WARNING: Parametritaulussa &LUOTAULU ei kaikkia vuosia.;
					%put WARNING: Rivin &TAULUVUOSI lains��d�nn�n pohja;
					%put WARNING: on kopio vuodesta &MAXVUOSI.;

		/*=====================================================================
		Distinct valitsee t�ss� p��llimm�isen rivin, joten
		p�iv�hoito ei tarvinne omaa ohjelmanp�tk��.
		---------------------------------------------------------------------*/

					create table _temp as select distinct * from &LUOTAULU
						where vuosi = &MAXVUOSI;

						update _temp set vuosi = &TAULUVUOSI;
						insert into &LUOTAULU select * from _temp;
						drop table _temp;
					quit;
				%end;

		proc sort data = &LUOTAULU; by descending vuosi;run;

	%mend Luo;


	/*=========================================================================
	Rivip�ivitysohjelma
	-------------------------------------------------------------------------*/
	%Macro Paivita(PARAM, IND, PTAULU, RND, LPVUOSI, LPTASO) 
		/ DES = 'Taulujen p�ivitysmakro';

		proc sql noprint;

			update &PTAULU
					set &PARAM = 

					%if (&PARAM = SRaja1 or &PARAM = SRaja2 or &PARAM = SRaja3)
					%then %do;
						int(						
							((&&&IND&LVUOSI)/(&&&IND&LPVUOSI)) * &LPTASO
							)
					%end;

					%else %do;
						round(
						((&&&IND&LVUOSI)/(&&&IND&LPVUOSI)) * &LPTASO
						, &RND)
					%end;

					where vuosi = &TAULUVUOSI;
			quit;

	%Mend Paivita;

	/*=========================================================================
	P�iv�hoitotaulun rivip�ivitysohjelma
	-------------------------------------------------------------------------*/
	%Macro PaivitaPhoito(PARAM, IND, PTAULU, RND, LPVUOSI, LPTASO) 
	/ DES = 'Erityismakro P�iv�hoito -parametrien p�ivitt�miseksi 
	elokuusykli� varten';

		%let EVUOSI = %sysevalf(&TVUOSI-1);
		%let E2VUOSI = %sysevalf(&TVUOSI-2);
		%let E4VUOSI = %sysevalf(&TVUOSI-4);

		proc sql noprint;

			select &PARAM into :abort
				from &PTAULU 
				where vuosi = &E2VUOSI;

			select kuuk into :check from
			&PTAULU where vuosi = &TVUOSI and kuuk = 8;	

		quit;

		%if %symexist(abort) = 0 %then %do;
			%put WARNING: &E2VUOSI puuttuu parametritaulusta &PTAULU.;
			%put WARNING: P�iv�hoidon parametreja ei voida p�ivitt��.;
			%put WARNING: Ohjelma keskeytetty.;
			%goto lopeta;
		%end;

		/*=====================================================================
		T�ss� tarkastellaan, onko edellisess� vuodessa 
		---------------------------------------------------------------------*/
		proc sql noprint;
			%if %symexist(check) = 1 %then %do;
				%if &check = 8 %then %do;

					select &PARAM into :UPD from &PTAULU
					where vuosi = &EVUOSI;

					update &PTAULU
					set &PARAM = 
						round(
							((&&&IND&E4VUOSI)/(&&&IND&E2VUOSI)) * &UPD
							, &RND)
					where vuosi = &TAULUVUOSI
					and kuuk = 8;

					update &PTAULU
					set &PARAM = &UPD
							where vuosi = &TAULUVUOSI
							and kuuk = 1;
				%end;
			%end;

			%else %do;				

					select &PARAM into :upd from &PTAULU
					where vuosi = &EVUOSI;

					update &PTAULU
					set &PARAM = 
						round(
							((&&&IND&E4VUOSI)/(&&&IND&E2VUOSI)) * &UPD
							, &RND)
					where vuosi = &TAULUVUOSI
					and kuuk = 1;
			%end;

			quit;

			%lopeta:;

	%Mend PaivitaPhoito;

	/*=========================================================================
	Kytkent� VERO- ja KANSEL -parametrien v�lill�: el�ketulov�hennys
	-------------------------------------------------------------------------*/
	%macro KytkentaV1(PARAM, PKANSEL, PVERO)/ DES = 'Verotuksen
		el�ketulov�hennyksen ja kansanel�kkeen maksimin huomioiva kytkent�';

		/*=====================================================================
		T�m� p�ivitt�� vero -taulun parametrin vastaamaan koko vuoden
		py�ristetty� kansanel�kkeen enimm�ism��r��.
		---------------------------------------------------------------------*/
			proc sql noprint;

				select round((TaysKEY1*12),1) into :UPD
				from &PKANSEL where vuosi = &TAULUVUOSI;

				update &PVERO
				set &PARAM = &UPD
				where vuosi = &TAULUVUOSI;

			quit;

	%mend KytkentaV1;

	/*=========================================================================
	Kytkent� SAIRVAK ja TTURVA -parametreist� vakuutuspalkan
	prosenttiv�hennykseen.
	-------------------------------------------------------------------------*/

	%macro kytkentaSVTT1(PARAM, IND, PTAULU)/ DES = 'Vakuutuspalkan 
		prosenttiv�hennyksen huomioiva kytkent�';

			proc sql noprint;

		/*=====================================================================
		Asettaa vakuutuspalkan prosenttiv�hennyksen indeksitaulun
		mukaiseksi
		---------------------------------------------------------------------*/
				update &PTAULU
				set &PARAM = &&&IND&TVUOSI
				where vuosi = &TAULUVUOSI;

			quit;

	%mend kytkentaSVTT1;

	/*=========================================================================
	Verotuksen tulorajojen inflaatiokorjausta varten luotu makro.
	Infl -parametri m��ritt��, mit� indeksi� inflaatiokorjaukseen k�ytet��n.
	-------------------------------------------------------------------------*/
	%macro tulorajat(infl) / DES = 'Verotuksen tulorajojen inflaatiokorjaus';

	/*=========================================================================
	Poimitaan talteen perusvuoden mukaiset tulorajat ja vakioverot
	-------------------------------------------------------------------------*/
	proc sql noprint;
		%do VRAJ = 1 %to 12;
			select raja&VRAJ, pros&VRAJ into 
				:xraja&VRAJ,
				:xpros&VRAJ
			from &PVERO
			where vuosi = &PVUOSI;
		%end;;
	quit;

	/*=========================================================================
	Tulorajojen inflaatiokorjaus:
	-------------------------------------------------------------------------*/
  		%let upvuosi = &tvuosi;

		/*=====================================================================
		Parametritaulussa on 12 tulorajaa. M��ritet��n ensimm�inen
		(nolla) manuaalisesti ja mystinen 8 euroa vakiom��r�ksi.
		---------------------------------------------------------------------*/
			%do vraj = 2 %to 12;
					%let kierros = %sysevalf(&VRAJ-1);
					%let vakiov1 = 8;
					%let xrajab1 = 0;

		/*=====================================================================
		Lasketaan tulorajat uudelleen
		---------------------------------------------------------------------*/
					%let xrajab&vraj = %sysfunc(round 
							(%sysevalf(
							(&&&infl&upvuosi/&&&infl&pvuosi)*&&xraja&vraj)
							,100));
							
		/*=====================================================================
		Lasketaan tulorajoja vastaavat veron vakiom��r�t uudelleen
		---------------------------------------------------------------------*/
					%let vakiov&vraj = %sysevalf(
							(&&xrajab&vraj-&&xrajab&kierros)*&&xpros&kierros
							+&&vakiov&kierros
							);

		/*=====================================================================
		P�ivitet��n verotuksen parametritaulua
		---------------------------------------------------------------------*/
					proc sql noprint; 
						update &pvero
							set raja&vraj = &&xrajab&vraj
								where vuosi = &tauluvuosi;
						update &pvero
							set vakio&vraj = &&vakiov&vraj
								where vuosi = &tauluvuosi;
					quit;
			%end;


	%mend tulorajat;

	/*=========================================================================
	P�ivitet��n parametritaulut
	-------------------------------------------------------------------------*/
	%ParamTaulut;

		/*=====================================================================
		Virhepoistumispiste
		---------------------------------------------------------------------*/
		%exit:;

	options &_notes;

%mend ParamRivi;



	/*=========================================================================
	Parametrien vanhat laintasot (muutokset vuodesta 2012 l�htien)
	-------------------------------------------------------------------------*/
/*		%paivita(Lapsi1, IndKelO, &PLLISA, .01, 2010, 100.00)
		%paivita(Lapsi2, IndKelO, &PLLISA, .01, 2010, 110.50)
		%paivita(Lapsi3, IndKelO, &PLLISA, .01, 2010, 141.00)
		%paivita(Lapsi4, IndKelO, &PLLISA, .01, 2010, 161.50)
		%paivita(Lapsi5, IndKelO, &PLLISA, .01, 2010, 182.00)
		%paivita(YksHuolt, IndKelO, &PLLISA, .01, 2010, 46.60)
*/