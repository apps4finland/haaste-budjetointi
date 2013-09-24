/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyödyntää Tilastokeskuksen yleisten
* käyttöehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto päähakemistossa.
******************************************************************************/

/***********************************************************
* Kuvaus: Kansaneläkkeiden esimerkkilaskelmien pohja       *
* Tekijä: Jussi Tervola / KELA	                		   *
* Luotu: 16.12.2011				       					   *
* Viimeksi päivitetty: 25.9.2012			     		   *
* Päivittäjä: Jussi Tervola / KELA		     		   	   *
************************************************************/  

/* 1. Esimerkkilaskentaa ohjaavat makromuuttujat */

%MACRO Aloitus;

%LET TYYPPI = ESIM; * Parametrien hakutapa, aina ESIM ;

/* Jos mallia käytetään käyttöliittymästä (&EG = 1), niin seuraavia vaiheita ei ajeta */

%IF &EG NE 1 %THEN %DO;

%LET TULOSNIMI_KE = kansel_esim_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;
%LET VUOSIKA = 2; 				* 1 = Vuosikeskiarvo, 2 = datassa annetun kuukauden lainsäädäntö ;
%LET VALITUT =  _ALL_; 			* Tulostaulukossa näytettävät muuttujat ;

* Inflaatiokorjaus. Parametrien deflatoinnissa käytettävän kertoimen voi syöttää itse
  INF-makromuuttujaan (HUOM! desimaalit erotettava pisteellä .). Jos puolestaan haluaa käyttää automaattista 
  elinkustannusindeksiin perustuvaa parametrien muunnoskerrointa, 
  tulee INF-makromuuttujalle antaa arvoksi 999.
  Tällöin on annettava myös perusvuosi, johon aineiston lainsäädäntövuotta verrataan; 	

%LET INF = 1.00; * Syötä arvo tai 999 ;
%LET AVUOSI = 2012; * Perusvuosi inflaatiokorjausta varten ;
%LET PINDEKSI_VUOSI = pindeksi_vuosi; * Käytettävä indeksien parametritaulukko ;

* Laki- ja apumakro-ohjelmien ajon säätäminen ; 

%LET LAKIMAKROT = 1;    * Lakimakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
%LET LAKIMAK_TIED_KE = KANSELlakimakrot;	* Lakimakroissa käytettävän tiedoston nimi ;
%LET APUMAKROT = 1;   	* Apumakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
%LET APUMAK_TIED_KE = KANSELapumakrot; * Apumakroissa käytettävän tiedoston nimi ;
%LET EXCEL = 1; 		 * Viedäänkö tulostaulukko automaattisesti Exceliin (1 = Kyllä, 0 = Ei) ;

%LET PKANSEL = pkansel; * Käytettävän parametritiedoston nimi ;

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
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_KE..sas";
%END;

/* Ajetaan apumakrot ja tallennetaan ne (optio) */

%IF &APUMAKROT = 1 %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&APUMAK_TIED_KE..sas";
%END;

%MEND TeeMakrot;

%TeeMakrot;


/* 3. Datan generointia ohjaavat makromuuttujat */

%MACRO Generoi_Muuttujat;

/* Jos mallia käytetään käyttöliittymästä (&EG = 1), niin seuraavia vaiheita ei ajeta */

%IF &EG NE 1 %THEN %DO;

/* 3.1 Fiktiivinen data */

*Lainsäädäntövuosi (1991-, täydet kansaneläkkeet 1957-);
%LET MINIMI_KANSEL_VUOSI = 1957;
%LET MAKSIMI_KANSEL_VUOSI = 2012;

*Lainsäädäntökuukausi (1-12);
%LET MINIMI_KANSEL_KUUK = 12;
%LET MAKSIMI_KANSEL_KUUK = 12;

*Henkilön ikä;
%LET MINIMI_KANSEL_IKA = 70 ; 
%LET MAKSIMI_KANSEL_IKA = 70 ;
%LET KYNNYS_KANSEL_IKA = 1; 

*Toimintataluokka (1 = työkyvytön, 2 = pitkäaikaistyötön, 3 = varusmies, 0 = muu);
%LET MINIMI_KANSEL_TOIMINTA = 0 ; 
%LET MAKSIMI_KANSEL_TOIMINTA = 0 ;

*Maahanmuuttaja (1 = tosi, 0 = epätosi) (asunut yli 20 % ajastaan ulkomailla ikävälillä 16-65v, HUOM. vaikutusta vain maahanmuuttajan erityistukeen);
%LET MINIMI_KANSEL_MAMU = 0 ; 
%LET MAKSIMI_KANSEL_MAMU = 0 ;

*Kuntaryhmä (1 tai 2) (Ei merkitystä vuoden 2008 jälkeisessä lainsäädännössä);
%LET MINIMI_KANSEL_KUNRY = 1 ; 
%LET MAKSIMI_KANSEL_KUNRY = 1 ;

*Onko puolisoa (0 = ei puolisoa, 1 = on puoliso, huom. ennen 9/1991 tarkoittaa, että puoliso saa myös kansaneläkettä;
%LET MINIMI_KANSEL_PUOLISO = 0 ; 
%LET MAKSIMI_KANSEL_PUOLISO = 0 ; 

*Onko leski (1 = tosi, 0 = epätosi);
%LET MINIMI_KANSEL_PUOLKUOL = 0 ; 
%LET MAKSIMI_KANSEL_PUOLKUOL = 0 ; 

*Puolison kuolemasta alle 6kk (1 = tosi, 0 = epätosi);
%LET MINIMI_KANSEL_LESKALKU = 0 ;
%LET MAKSIMI_KANSEL_LESKALKU = 0 ;

*Asuuko henkilö laitoksessa (1 = tosi, 0 = epätosi);
%LET MINIMI_KANSEL_LAITOS = 0 ;
%LET MAKSIMI_KANSEL_LAITOS = 0 ; 

*Onko vanhempi/vanhemmat kuolleet (0, 1 = toinen vanhempi, 2 = kummatkin vanhemmat);
%LET MINIMI_KANSEL_LAPSEL = 0 ; 
%LET MAKSIMI_KANSEL_LAPSEL = 0 ;

*Muut eläketulot yhteensä (pl. perhe-eläkkeet) (e/v);
%LET MINIMI_KANSEL_MUUELTULO = 0 ; 
%LET MAKSIMI_KANSEL_MUUELTULO = 0 ;
%LET KYNNYS_KANSEL_MUUELTULO = 2000; 

*Yksityiset perhe-eläketulot yhteensä  (e/v);
%LET MINIMI_KANSEL_MUUPELTULO = 0 ; 
%LET MAKSIMI_KANSEL_MUUPELTULO = 0 ;
%LET KYNNYS_KANSEL_MUUPELTULO = 2000; 

*Alle 18-v. lasten lkm;
%LET MINIMI_KANSEL_18vLAPSIA = 0 ;
%LET MAKSIMI_KANSEL_18vLAPSIA = 0 ; 

*Alle 16-v. lasten lkm;
%LET MINIMI_KANSEL_16vLAPSIA = 0 ;
%LET MAKSIMI_KANSEL_16vLAPSIA = 0 ; 

*Työtulot, brutto (e/v) (Leskeneläke);
%LET MINIMI_KANSEL_TYOTULO = 0 ; 
%LET MAKSIMI_KANSEL_TYOTULO = 0 ;
%LET KYNNYS_KANSEL_TYOTULO = 2000; 

*Työtulot, netto (e/kk) (Maahanmuuttaja, varusmies);
%LET MINIMI_KANSEL_OMATULO = 0 ; 
%LET MAKSIMI_KANSEL_OMATULO = 0 ;
%LET KYNNYS_KANSEL_OMATULO = 500;

*Pääomatulot, (e/v) (Leskeneläke, maahanmuuttaja);
%LET MINIMI_KANSEL_POTULO = 0 ; 
%LET MAKSIMI_KANSEL_POTULO = 0 ;
%LET KYNNYS_KANSEL_POTULO = 2000; 

*Puolison tulot, netto (e/kk) (Maahanmuuttaja, varusmies);
%LET MINIMI_KANSEL_PUOLTULO = 0 ; 
%LET MAKSIMI_KANSEL_PUOLTULO = 0 ;
%LET KYNNYS_KANSEL_PUOLTULO = 500;

*Asumismenot (e/kk) (Varusmies);
%LET MINIMI_KANSEL_ASUMMENOT = 0 ; 
%LET MAKSIMI_KANSEL_ASUMMENOT = 0 ;
%LET KYNNYS_KANSEL_ASUMMENOT = 100;

*Varallisuus (e) (Leskeneläke);
%LET MINIMI_KANSEL_VARALL = 0 ; 
%LET MAKSIMI_KANSEL_VARALL = 0 ;
%LET KYNNYS_KANSEL_VARALL = 2000;

*Vammaistuen aste (0= ei vammaisuutta, 1, 2, 3);
%LET MINIMI_KANSEL_VAMASTE = 0 ;
%LET MAKSIMI_KANSEL_VAMASTE = 0 ;

*Keliakia (1 = tosi, 0 = epätosi);
%LET MINIMI_KANSEL_KELIAK = 0 ;
%LET MAKSIMI_KANSEL_KELIAK = 0 ;

*Eläkkeensaajan hoitotukityyppi
0 = ei hoitotukea
1 = alin hoitotuki
2 = korotettu hoitotuki
3 = erityishoitotuki
4 = suojattu hoitotuki (apulisä) (Ei makseta enää vuoden 1988 jälkeen alkaviin eläkkeisiin)
5 = suojattu hoitotuki (hoitolisä) (Ei makseta enää vuoden 1988 jälkeen alkaviin eläkkeisiin);
%LET MINIMI_KANSEL_HOITUKI = 2 ;
%LET MAKSIMI_KANSEL_HOITUKI = 2 ;

*Onko rintamaveteraani/miinanraivaaja (1 = tosi, 0 = epätosi);
%LET MINIMI_KANSEL_RINTAMA = 1 ;
%LET MAKSIMI_KANSEL_RINTAMA = 1 ;


%END;


/* 4. Fiktiivisen aineiston luominen ja simulointi */

/* 4.1 Generoidaan data makromuuttujien arvojen mukaisesti */ 

DATA OUTPUT.&TULOSNIMI_KE;

DO KANSEL_VUOSI = &MINIMI_KANSEL_VUOSI TO &MAKSIMI_KANSEL_VUOSI;
DO KANSEL_KUUK = &MINIMI_KANSEL_KUUK TO &MAKSIMI_KANSEL_KUUK;

DO KANSEL_IKA = &MINIMI_KANSEL_IKA TO &MAKSIMI_KANSEL_IKA BY &KYNNYS_KANSEL_IKA ;
DO KANSEL_TOIMINTA = &MINIMI_KANSEL_TOIMINTA TO &MAKSIMI_KANSEL_TOIMINTA;
DO KANSEL_PUOLISO = &MINIMI_KANSEL_PUOLISO TO &MAKSIMI_KANSEL_PUOLISO;
DO KANSEL_LAITOS = &MINIMI_KANSEL_LAITOS TO &MAKSIMI_KANSEL_LAITOS;
DO KANSEL_KUNRY = &MINIMI_KANSEL_KUNRY TO &MAKSIMI_KANSEL_KUNRY;
DO KANSEL_MAMU = &MINIMI_KANSEL_MAMU TO &MAKSIMI_KANSEL_MAMU;

DO KANSEL_MUUELTULO = &MINIMI_KANSEL_MUUELTULO TO &MAKSIMI_KANSEL_MUUELTULO BY &KYNNYS_KANSEL_MUUELTULO ;

DO KANSEL_PUOLKUOL = &MINIMI_KANSEL_PUOLKUOL TO &MAKSIMI_KANSEL_PUOLKUOL;
DO KANSEL_LAPSEL = &MINIMI_KANSEL_LAPSEL TO &MAKSIMI_KANSEL_LAPSEL;

%IF &MAKSIMI_KANSEL_PUOLKUOL NE 0 OR &MAKSIMI_KANSEL_LAPSEL NE 0 %THEN %DO;
	DO KANSEL_MUUPELTULO = &MINIMI_KANSEL_MUUPELTULO TO &MAKSIMI_KANSEL_MUUPELTULO BY &KYNNYS_KANSEL_MUUPELTULO ;
%END;

%IF &MAKSIMI_KANSEL_PUOLKUOL NE 0 %THEN %DO;
	DO KANSEL_LESKALKU = &MINIMI_KANSEL_LESKALKU TO &MAKSIMI_KANSEL_LESKALKU;
%END;


DO KANSEL_TYOTULO = &MINIMI_KANSEL_TYOTULO TO &MAKSIMI_KANSEL_TYOTULO BY &KYNNYS_KANSEL_TYOTULO; 
DO KANSEL_POTULO = &MINIMI_KANSEL_POTULO TO &MAKSIMI_KANSEL_POTULO BY &KYNNYS_KANSEL_POTULO; 
DO KANSEL_VARALL = &MINIMI_KANSEL_VARALL TO &MAKSIMI_KANSEL_VARALL BY &KYNNYS_KANSEL_VARALL; 

DO KANSEL_18VLAPSIA = MAX(&MINIMI_KANSEL_18VLAPSIA, &MINIMI_KANSEL_16VLAPSIA) TO MAX(&MAKSIMI_KANSEL_16VLAPSIA, &MAKSIMI_KANSEL_18VLAPSIA);


DO KANSEL_VAMASTE = &MINIMI_KANSEL_VAMASTE TO &MAKSIMI_KANSEL_VAMASTE;
DO KANSEL_KELIAK = &MINIMI_KANSEL_KELIAK TO &MAKSIMI_KANSEL_KELIAK;

DO KANSEL_HOITUKI = &MINIMI_KANSEL_HOITUKI TO &MAKSIMI_KANSEL_HOITUKI;
DO KANSEL_16VLAPSIA = &MINIMI_KANSEL_16VLAPSIA TO &MAKSIMI_KANSEL_16VLAPSIA;
DO KANSEL_RINTAMA = &MINIMI_KANSEL_RINTAMA TO &MAKSIMI_KANSEL_RINTAMA;

DO KANSEL_OMATULO = &MINIMI_KANSEL_OMATULO TO &MAKSIMI_KANSEL_OMATULO BY &KYNNYS_KANSEL_OMATULO ;

%IF &MAKSIMI_KANSEL_PUOLISO NE 0 %THEN %DO;
	DO KANSEL_PUOLTULO = &MINIMI_KANSEL_PUOLTULO TO &MAKSIMI_KANSEL_PUOLTULO BY &KYNNYS_KANSEL_PUOLTULO ; 
%END;

DO KANSEL_ASUMMENOT = &MINIMI_KANSEL_ASUMMENOT TO &MAKSIMI_KANSEL_ASUMMENOT BY &KYNNYS_KANSEL_ASUMMENOT ; 


%IF &INF = 999 %THEN %DO;
%IndKerroin_ESIM(&AVUOSI, KANSEL_VUOSI);
%END;
%ELSE %DO; 
	INF = &INF;
%END;

OUTPUT;
END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;

%IF &MAKSIMI_KANSEL_PUOLKUOL NE 0 OR &MAKSIMI_KANSEL_LAPSEL NE 0 %THEN %DO;
	END;
%END;

%IF &MAKSIMI_KANSEL_PUOLKUOL NE 0 %THEN %DO;
	END;
%END;

%IF &MAKSIMI_KANSEL_PUOLISO NE 0 %THEN %DO;
	END; 
%END;

DATA OUTPUT.&TULOSNIMI_KE; 
SET OUTPUT.&TULOSNIMI_KE;

IF KANSEL_PUOLISO = 0 THEN KANSEL_PUOLTULO = .;
IF KANSEL_PUOLKUOL = 0 THEN KANSEL_LESKALKU = .;
IF KANSEL_PUOLKUOL = 0 AND KANSEL_LAPSEL = 0 THEN KANSEL_MUUPELTULO = .;

	
RUN;

%MEND Generoi_Muuttujat;

%Generoi_Muuttujat;


/* 4.2 Simuloidaan valitut muuttujat esimerkkiaineistolla */

%MACRO KansEl_Simuloi_Esimerkki;

DATA OUTPUT.&TULOSNIMI_KE;
SET OUTPUT.&TULOSNIMI_KE;

/* 4.2.1 Kansaneläke */

IF (KANSEL_IKA >= 65  OR (KANSEL_VUOSI - KANSEL_IKA < 1950 AND KANSEL_TOIMINTA = 2) OR (16<= KANSEL_IKA < 65 AND KANSEL_TOIMINTA = 1)) THEN DO;

IF &VUOSIKA = 2 THEN DO;
	%Kansanelake_SimpleK&F(KANSELK, KANSEL_VUOSI, KANSEL_KUUK, INF, KANSEL_LAITOS, KANSEL_PUOLISO, KANSEL_KUNRY, SUM(KANSEL_MUUELTULO, KANSEL_MUUPELTULO), 1);
END;
ELSE DO;
	%Kansanelake_SimpleV&F(KANSELK, KANSEL_VUOSI, INF, KANSEL_LAITOS, KANSEL_PUOLISO, KANSEL_KUNRY, SUM(KANSEL_MUUELTULO, KANSEL_MUUPELTULO), 1);
END;

KANSELV = KANSELK * 12;

END;

/* 4.2.2 Takuueläke */

IF KANSELK > 0 OR (KANSEL_MUUELTULO > 0 AND (KANSEL_TOIMINTA = 1 OR KANSEL_IKA >=65)) THEN DO;

IF &VUOSIKA = 2 THEN DO;
	%TakuuElakeK&F(TAKUUELK, KANSEL_VUOSI, KANSEL_KUUK, INF, SUM(KANSEL_MUUELTULO/12, KANSEL_MUUPELTULO/12, KANSELK), 1);
END;
ELSE DO;
	%TakuuElakeV&F(TAKUUELK, KANSEL_VUOSI, INF, SUM(KANSEL_MUUELTULO/12, KANSEL_MUUPELTULO/12, KANSELK), 1);
END;

TAKUUELV = TAKUUELK * 12;

END;

/* 4.2.3 Kansaneläkkeen lisät */

IF &VUOSIKA = 2 THEN DO;

	IF KANSEL_PUOLISO NE 0 AND KANSEL_VUOSI < 2001 THEN DO;
		%KanselLisatK&F(PUOLISOLISK, KANSEL_VUOSI, KANSEL_KUUK, INF, 1, 0, 0, 0, 0, 0, 0, 1, KANSEL_KUNRY, 0);
	END;

	IF KANSEL_RINTAMA NE 0 THEN DO;
		%KanselLisatK&F(RINTAMLISK, KANSEL_VUOSI, KANSEL_KUUK, INF, 0, 0, 0, 0, 0, 0, 1, 0, KANSEL_KUNRY, 0);

		IF KANSEL_VUOSI < 1997 THEN DO;
			%Kansanelake_SimpleK&F(LISAOSA, KANSEL_VUOSI, KANSEL_KUUK, INF, KANSEL_LAITOS, KANSEL_PUOLISO, KANSEL_KUNRY, 0, 1);
			LISAOSA = LISAOSA - &PerPohja;
		END;
		%YlimRintLisaK&F(YRINTAMLISK, KANSEL_VUOSI, KANSEL_KUUK, INF, LISAOSA, KANSELK, KANSEL_MUUELTULO);

	END;

	IF KANSEL_HOITUKI NE 0 THEN DO;
		%KanselLisatK&F(HOITOTUKIK, KANSEL_VUOSI, KANSEL_KUUK, INF, 1, (KANSEL_HOITUKI = 4 OR (YRINTAMLISK > 0 AND KANSEL_HOITUKI IN (2, 3))), (KANSEL_HOITUKI = 5), (KANSEL_HOITUKI = 1), (KANSEL_HOITUKI = 2),(KANSEL_HOITUKI = 3), 0, 0, KANSEL_KUNRY, 0);
	END;

	IF KANSEL_16VLAPSIA NE 0 AND KANSEL_MAMU NE 1 AND (KANSEL_IKA >=65  OR (KANSEL_VUOSI - KANSEL_IKA < 1950 AND KANSEL_TOIMINTA = 2) OR (16<= KANSEL_IKA <= 64 AND KANSEL_TOIMINTA = 1)) THEN DO;
		%KanselLisatK&F(LAPSIKORK, KANSEL_VUOSI, KANSEL_KUUK, INF, 1, 0, 0, 0, 0, 0, 0, 0, KANSEL_KUNRY, KANSEL_16VLAPSIA);
	END;
END;
		
ELSE DO;
	IF KANSEL_PUOLISO NE 0 AND KANSEL_VUOSI < 2001 THEN DO;
		%KanselLisatV&F(PUOLISOLISK, KANSEL_VUOSI, INF, 1, 0, 0, 0, 0, 0, 0, 1, KANSEL_KUNRY, 0);
	END;

	IF KANSEL_RINTAMA NE 0 THEN DO;
		%KanselLisatV&F(RINTAMLISK, KANSEL_VUOSI, INF, 0, 0, 0, 0, 0, 0, 1, 0, KANSEL_KUNRY, 0);

		IF KANSEL_VUOSI < 1997 THEN DO;
			%Kansanelake_SimpleV&F(LISAOSA, KANSEL_VUOSI, INF, KANSEL_LAITOS, KANSEL_PUOLISO, KANSEL_KUNRY, 0, 1);
			LISAOSA = LISAOSA - &PerPohja;
		END;
		%YlimRintLisaV&F(YRINTAMLISK, KANSEL_VUOSI, INF, LISAOSA, KANSELK, KANSEL_MUUELTULO);

	END;

	IF KANSEL_HOITUKI NE 0 THEN DO;
		%KanselLisatv&F(HOITOTUKIK, KANSEL_VUOSI, INF, 1, (KANSEL_HOITUKI = 4 OR (YRINTAMLISK > 0 AND KANSEL_HOITUKI IN (2, 3))), (KANSEL_HOITUKI = 5), (KANSEL_HOITUKI = 1), (KANSEL_HOITUKI = 2),(KANSEL_HOITUKI = 3), 0, 0, KANSEL_KUNRY, 0);
	END;

	IF KANSEL_16VLAPSIA NE 0 AND KANSEL_MAMU NE 1 AND (KANSEL_IKA >=65  OR (KANSEL_VUOSI - KANSEL_IKA < 1950 AND KANSEL_TOIMINTA = 2) OR (16<= KANSEL_IKA <= 64 AND KANSEL_TOIMINTA = 1)) THEN DO;
		%KanselLisatV&F(LAPSIKORK, KANSEL_VUOSI, INF, 1, 0, 0, 0, 0, 0, 0, 0, KANSEL_KUNRY, KANSEL_16VLAPSIA);
	END;
END;

KANSELLISATK = SUM(HOITOTUKIK, PUOLISOLISK, RINTAMLISK, YRINTAMLISK, LAPSIKORK);
KANSELLISATV = KANSELLISATK * 12;
DROP LISAOSA;

/* 4.2.4 Vammaistuet */

IF (KANSEL_VAMASTE > 0 AND KANSELK NG 0) OR KANSEL_KELIAK NE 0 THEN DO;

IF &VUOSIKA = 2 THEN DO;
	%VammTukiK&F(VAMTUKIK, KANSEL_VUOSI, KANSEL_KUUK, INF, (KANSEL_IKA >= 16 AND KANSELK NG 0), (KANSEL_IKA < 16 AND KANSELK NG 0), (KANSEL_KELIAK NE 0), KANSEL_VAMASTE);
END;
ELSE DO;
	%VammTukiV&F(VAMTUKIK, KANSEL_VUOSI, INF, (KANSEL_IKA >= 16 AND KANSELK NG 0), (KANSEL_IKA < 16 AND KANSELK NG 0), (KANSEL_KELIAK NE 0), KANSEL_VAMASTE);
END;

VAMTUKIV = VAMTUKIK * 12;

END;

/* 4.2.5 Leskeneläke */

IF KANSEL_PUOLKUOL NE 0 AND KANSEL_IKA < 65 THEN DO;

IF &VUOSIKA = 2 THEN DO;
	%LeskenElakeAK&F(LESKENELK, KANSEL_VUOSI, KANSEL_KUUK, INF, KANSEL_LESKALKU, KANSEL_PUOLISO, KANSEL_KUNRY, KANSEL_18VLAPSIA, KANSEL_TYOTULO, KANSEL_POTULO, SUM(KANSEL_MUUELTULO, KANSEL_MUUPELTULO), KANSEL_VARALL);
END;
ELSE DO;
	%LeskenElakeAV&F(LESKENELK, KANSEL_VUOSI, INF, KANSEL_LESKALKU, KANSEL_PUOLISO, KANSEL_KUNRY, KANSEL_18VLAPSIA, KANSEL_TYOTULO, KANSEL_POTULO, SUM(KANSEL_MUUELTULO, KANSEL_MUUPELTULO), KANSEL_VARALL);
END;

IF KANSELK > 0 THEN LESKENELK = .;
IF KANSEL_LESKALKU NE 0 THEN LESKENELV = LESKENELK * 6;
ELSE LESKENELV = LESKENELK * 12;

END;

/* 4.2.6 Lapseneläke */

IF KANSEL_LAPSEL > 0 AND KANSEL_IKA < 21 THEN DO;

IF &VUOSIKA = 2 THEN DO;
	%LapsenelakeAK&F(LAPSENELK, KANSEL_VUOSI, KANSEL_KUUK, INF, (KANSEL_LAPSEL = 2), KANSEL_MUUPELTULO, (KANSEL_IKA >= 18));
END;
ELSE DO;
	%LapsenelakeAV&F(LAPSENELK, KANSEL_VUOSI, INF, (KANSEL_LAPSEL = 2), KANSEL_MUUPELTULO, (KANSEL_IKA >= 18));
END;

LAPSENELV = LAPSENELK * 12;

END;

/* 4.2.7 Sotilasavustus */

IF KANSEL_TOIMINTA = 3 THEN DO;

IF &VUOSIKA = 2 THEN DO;
	%SotilasAvK&F(SOTILAVK, KANSEL_VUOSI, KANSEL_KUUK, INF, KANSEL_KUNRY, SUM(KANSEL_PUOLISO, KANSEL_18VLAPSIA), KANSEL_ASUMMENOT, SUM(KANSEL_OMATULO, KANSEL_PUOLTULO));
END;
ELSE DO;
	%SotilasAvV&F(SOTILAVK, KANSEL_VUOSI, INF, KANSEL_KUNRY, SUM(KANSEL_PUOLISO, KANSEL_18VLAPSIA), KANSEL_ASUMMENOT, SUM(KANSEL_OMATULO, KANSEL_PUOLTULO));
END;

SOTILAVV = SOTILAVK * 12;

END;

/* 4.2.8 Maahanmuuttajan erityistuki */

IF KANSEL_MAMU NE 0 AND (KANSEL_TOIMINTA = 1 OR KANSEL_IKA >=65) THEN DO;

IF &VUOSIKA = 2 THEN DO;
	%MaMuErTukiK&F(MAMUERITK, KANSEL_VUOSI, KANSEL_KUUK, INF, KANSEL_LAITOS, KANSEL_PUOLISO, KANSEL_KUNRY, SUM(KANSEL_OMATULO, KANSEL_POTULO/12), KANSEL_PUOLTULO);
END;
ELSE DO;
	%MaMuErTukiV&F(MAMUERITK, KANSEL_VUOSI, INF, KANSEL_LAITOS, KANSEL_PUOLISO, KANSEL_KUNRY, SUM(KANSEL_OMATULO, KANSEL_POTULO/12), KANSEL_PUOLTULO);
END;

MAMUERITV = MAMUERITK * 12;

END;

DROP kuuknro taulu_ke w y z testi kuuid;


/* 4.3 Määritellään muuttujille selkokieliset selitteet */

LABEL 
KANSEL_VUOSI = 'Lainsäädäntövuosi'
KANSEL_KUUK = 'Lainsäädäntökuukausi'
KANSEL_IKA = 'Henkilön ikä'
KANSEL_TOIMINTA = 'Toimintaluokka'
KANSEL_MAMU = 'Asunut Suomessa alle 3 vuotta (0/1)'
KANSEL_18VLAPSIA = 'Alle 18-v. lapsien lkm'
KANSEL_PUOLISO = 'Onko puolisoa (0/1)'
KANSEL_PUOLKUOL = 'Onko puoliso kuollut (0/1)'
KANSEL_LAITOS = 'Asuuko henkilö laitoksessa (0/1)'
KANSEL_KUNRY = 'Kuntaryhmä (1/2)'
KANSEL_MUUELTULO = 'Muut eläketulot yhteensä (pl. perhe-eläkkeet), e/v' 
KANSEL_MUUPELTULO = 'Yksityiset perhe-eläketulot, e/v' 
KANSEL_LESKALKU = 'Puolison kuolemasta alle 6kk (0/1)'
KANSEL_TYOTULO = 'Lesken työtulot, brutto e/v' 
KANSEL_OMATULO = 'Maahanmuuttajan/ varusmiehen työtulot, netto e/kk' 
KANSEL_PUOLTULO = 'Puolison tulot, netto e/kk'
KANSEL_ASUMMENOT = 'Asumismenot, e/kk' 
KANSEL_POTULO = 'Pääomatulot, e/v' 
KANSEL_VARALL = 'Lesken varallisuus e' 
KANSEL_LAPSEL = 'Montako vanhempaa kuollut (0-2)'
KANSEL_KELIAK = 'Keliakia (0/1)'
KANSEL_VAMASTE = 'Vammaisuusaste (0-3)'
KANSEL_HOITUKI = 'Hoitotukityyppi (0=ei hoitotukea, 1=alin hoitotuki, 2=korotettu hoitotuki, 3=erityishoitotuki, 4=suojattu hoitotuki (apulisä), 5=suojattu hoitotuki (hoitolisä)'
KANSEL_16VLAPSIA = 'Alle 16-v. lapsien lkm'
KANSEL_RINTAMA = 'Rintamaveteraani (0/1)'

INF = 'Inflaatiokorjauksessa käytettävä kerroin'

KANSELK = 'Kansaneläke e/kk'
KANSELV = 'Kansaneläke e/v'
TAKUUELK = 'Takuueläke e/kk'
TAKUUELV = 'Takuueläke e/v'

HOITOTUKIK ='Hoitotuet e/kk'
PUOLISOLISK ='Puolisolisä e/kk'
LAPSIKORK ='Lapsikorotukset e/kk'
RINTAMLISK = 'Rintamalisä e/kk'
YRINTAMLISK = 'Ylimääräinen rintamalisä e/kk'
KANSELLISATK = 'Kansaneläkkeen lisät yht e/kk'
KANSELLISATV = 'Kansaneläkkeen lisät yht e/v'

VAMTUKIK = 'Vammaistuet e/kk'
VAMTUKIV = 'Vammaistuet e/v'
LESKENELK = 'Leskeneläke e/kk'
LESKENELV = 'Leskeneläke e/v'
LAPSENELK = 'Lapseneläke e/kk'
LAPSENELV = 'Lapseneläke e/v'
SOTILAVK = 'Sotilasavustus e/kk'
SOTILAVV = 'Sotilasavustus e/v'
MAMUERITK = 'Maahanmuuttajan erityistuki e/kk'
MAMUERITV = 'Maahanmuuttajan erityistuki e/v';


KEEP &VALITUT;
%IF &VUOSIKA NE 2 %THEN %DO;
	DROP KANSEL_KUUK;
%END;

RUN;

%IF &EXCEL = 1 %THEN %DO;
	ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_KE..xls"  STYLE = MINIMAL;
%END;

PROC PRINT NOOBS LABEL DATA = OUTPUT.&TULOSNIMI_KE;
TITLE "ESIMERKKILASKELMA, KANSEL";
RUN;

%IF &EXCEL = 1 %THEN %DO;
	ODS HTML3 CLOSE;
%END;

%MEND KansEl_Simuloi_Esimerkki;

%KansEl_Simuloi_Esimerkki;
