/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hy�dynt�� Tilastokeskuksen yleisten
* k�ytt�ehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto p��hakemistossa.
******************************************************************************/

/*********************************************************************
* Kuvaus: P��mallin (KOKO) esimerkkilaskelmien pohja 			     *
* Tekij�: Pertti Honkanen / KELA		               	   			 *
* Luotu: 2.11.2012 			       					   	  			 *
* Viimeksi p�ivitetty: 7.11.2012			     		  			 *
* P�ivitt�j�: Olli Kannas / TK			     			   			 *
**********************************************************************/ 

/*
Lasketaan etuuksia ja ansiotulojen veroja       		
henkil�lle ja puolisolle sek� lapsilisi�, elatustukea 
asumistukia, p�iv�hoitomaksuja ja toimeentulotukea    
kotitalouksille.

Seitsem�n osaa:

1) Makro "Aloitus": Yhteisi� oletuksia makromuuttujina.
   Jos oletukset annetaan t�m�n ohjelman ulkopuolelta, t�t� ei ajeta.
2) Makro "TeeMakrot": S��dell��n laki- ja apumakro-ohjelmien ajoa. 
3) Makro "Generoi_Muuttujat": Fiktiivisen datan generointi, makromuuttujien johdonmukaisuutta tarkistetaan.
   Jos oletukset annetaan t�m�n ohjelman ulkopuolelta, t�t� ei ajeta.
4) Makro KOKO_LASKENTA yksil�tason laskentaa varten.
	KOKO_LASKENTA (0) laskee henkil�lle
	KOKO_LASKENTA (1) laskee puolisolle.
	Puolisot erotetaan suff-makromuuttujan avulla antamalla muuttujille nimet muodossa nimi  ja  nimi_puol.
5) Makro KOKO_LASKENTA_KOTIT kotitaloustason laskentaa varten
6) Ajetaan kuusi makroa: Aloitus, TeeMakrot, KOKO_LASKENTA (0), KOKO_LASKENTA (1) ja KOKO_LASKENTA_KOTIT.  
7) Lasketaan marginaaliveroasteet.	
*/


/* 1. Esimerkkilaskentaa ohjaavat makromuuttujat */

%MACRO Aloitus;

%LET TYYPPI = ESIM; * Parametrien hakutapa, aina ESIM ;

/* Jos mallia k�ytet��n k�ytt�liittym�st� (&EG = 1), niin seuraavia vaiheita ei ajeta */

%IF &EG NE 1 %THEN %DO;

%LET TULOSNIMI_KOKO = koko_esim_&SYSDATE._1 ; * Simuloidun tulostiedoston nimi ;
%LET VUOSIKA = 1; 				* 1 = Vuosikeskiarvo, 2 = datassa annetun kuukauden lains��d�nt� ;
%LET VALITUT =  _ALL_; 			* Tulostaulukossa n�ytett�v�t muuttujat ;

* Inflaatiokorjaus. Parametrien deflatoinnissa k�ytett�v�n kertoimen voi sy�tt�� itse
  INF-makromuuttujaan (HUOM! desimaalit erotettava pisteell� .). Jos puolestaan haluaa k�ytt�� automaattista 
  elinkustannusindeksiin perustuvaa parametrien muunnoskerrointa, 
  tulee INF-makromuuttujalle antaa arvoksi 999.
  T�ll�in on annettava my�s perusvuosi, johon aineiston lains��d�nt�vuotta verrataan; 	

%LET INF = 1; * Sy�t� arvo tai 999 ;
%LET AVUOSI = 2013; * Perusvuosi inflaatiokorjausta varten ;
%LET PINDEKSI_VUOSI = pindeksi_vuosi; * K�ytett�v� indeksien parametritaulukko ;
	
* Laki- ja apumakro-ohjelmien ajon s��t�minen ; 

%LET LAKIMAKROT = 1;    * Lakimakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
%LET APUMAKROT = 1;   	* Apumakro-ohjelman ajo (1 jos ajetaan, 0 jos ei);
%LET EXCEL = 1; 		* Vied��nk� tulostaulukko automaattisesti Exceliin (1 = Kyll�, 0 = Ei) ;

* Simuloinnissa k�ytett�vien apu- ja lakimakrotiedostojen nimet ;

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

* Simuloinnissa k�ytett�vien parametritaulukoiden nimet ;

%LET POPINTUKI = popintuki;
%LET PTTURVA = ptturva;
%LET PSAIRVAK = psairvak;
%LET PKOTIHTUKI = pkotihtuki;
%LET PLLISA = pllisa;
%LET PTOIMTUKI = ptoimtuki;
%LET PKANSEL = pkansel;
%LET PVERO = pvero;
%LET PVERO_VARALL = pvero_varall;
%LET PASUMTUKI = pasumtuki;
%LET PASUMTUKI_VUOKRANORMIT = pasumtuki_vuokranormit;
%LET PASUMTUKI_ENIMMMENOT = pasumtuki_enimmmenot;
%LET PELASUMTUKI = pelasumtuki;

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
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_SV..sas";
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_TT..sas";
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_KT..sas";
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_OT..sas";
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_KE..sas";
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_LL..sas";
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_YA..sas";
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_EA..sas";
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_TO..sas";
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&LAKIMAK_TIED_PH..sas";
%END;

/* Ajetaan apumakrot ja tallennetaan ne (optio) */

%IF &APUMAKROT = 1 %THEN %DO;
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&APUMAK_TIED_VE..sas";
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&APUMAK_TIED_SV..sas";
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&APUMAK_TIED_TT..sas";
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&APUMAK_TIED_KT..sas";
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&APUMAK_TIED_OT..sas";
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&APUMAK_TIED_KE..sas";
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&APUMAK_TIED_LL..sas";
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&APUMAK_TIED_YA..sas";
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&APUMAK_TIED_EA..sas";
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&APUMAK_TIED_TO..sas";
	%INCLUDE "&LEVY&KENO&HAKEM&KENO.MAKROT&KENO&APUMAK_TIED_PH..sas";
%END;

%MEND TeeMakrot;

%TeeMakrot;


/* 3. Datan generointia ohjaavat makromuuttujat */

%MACRO Generoi_Muuttujat;

/* Jos mallia k�ytet��n k�ytt�liittym�st� (&EG = 1), niin seuraavia vaiheita ei ajeta */

%IF &EG NE 1 %THEN %DO;

/* 3.0 Lains��d�nt�vuosi ja -kuukausi*/

%LET MINIMI_KOKO_VUOSI = 2011;
%LET MAKSIMI_KOKO_VUOSI = 2013;

%LET MINIMI_KOKO_KUUK = 1;
%LET MAKSIMI_KOKO_KUUK = 1;

/* 3.1 Perhett� koskevia tietoja */

/*
PUOLISO = 0 tai 1
LAPSIA_ALLE3: Alle 3-vuotiaiden lasten lukum��r�
LAPSIA_3_6: 3-6-vuotiaiden lasten lukum��r�
LAPSIA_3_9: 3-9-vuotiaiden lasten lukum��r�
LAPSIA_10_15: 10-15-vuotiaiden lasten lukum��r�
LAPSIA_16: 16-vuotiaiden lasten lukum��r�
LAPSIA_17: 17-vuotiaiden lasten lukum��r�

Eri ik�ryhmiin kuuluvien lasten lukum��r�t:
 - Alle 3-vuotiaiden ja 3-6-vuotiaden lasten lukum��r�t tarvitaan
   lasten kotihoidon tuen ja p�iv�hoitomaksujen laskentaan.
 - Alle 10-vuotiaat ja 10 v t�ytt�neet lapset on eritelt�v� toimeentulotukea varten.
 - 16-vuotiaiden ja 17-vuotiaiden lasten lukum��r� tarvitaan, jos
   eri j�rjestelmien (lapsilis�t, asumistuki, el�kkeensaajien
   lapsikorotus, verotus, ty�tt�myysturva) ik�rajat ja niiden muutokset
   1990-luvulta l�htien halutaan ottaa huomioon.
 - Jos kiinnostus liittyy vain normaalin nykyisen lain 
   lapsilis��n riitt�� esim. muuttuja lapsia_10_15.
 - 18 vuotta t�ytt�neit� lapsia ei oteta malliin.
 - Jos TILANNE = 3, alle 3-vuotiaat lapset ovat hoitolapsia.
*/

%LET MINIMI_KOKO_PUOLISO = 0;
%LET MINIMI_KOKO_LAPSIA_ALLE3 = 0;
%LET MINIMI_KOKO_LAPSIA_3_6 = 1;
%LET MINIMI_KOKO_LAPSIA_3_9 = 1;
%LET MINIMI_KOKO_LAPSIA_10_15 = 0;
%LET MINIMI_KOKO_LAPSIA_16 = 0;
%LET MINIMI_KOKO_LAPSIA_17 = 0;

/* 3.2 Ik� */

/*
IKA: Henkil�n ik�
IKA_PUOL: Puolison ik�
Vaikuttaa mm. opintotukeen ja ty�el�kemaksuihin. 
*/

%LET MINIMI_KOKO_IKA = 32;
%LET MINIMI_KOKO_IKA_PUOL = 32;

/* 3.3 Asuinpaikkaan kytkeytyvi� tietoja */

/*
ASKRYHMA: Asumistuen kuntaryhm� 1 - 4 (mallin kuntaryhm�,
joka voi poiketa lains��d�nn�n numeroinnista)

KELRYHMA: Kalleusluokka 1 tai 2: merkityst� vain
jos sovelletaan vuotta 2008 vanhempaa lains��d�nt��

LAMMRYHMA: Yleisen ja el�kkeensaajien asumistuen
l�mmitysryhm�, vaikutusta l�hinn� omistusoasunnoissa.

KUNNVERO: Kunnallinen veroprosentti desimaaliprosenttilukuna, > 0, esim. 19.3
Jos 999, sovelletaan keskim��r�ist� veroprosenttia.
KIKRVERO: Kirkollinen veroprosentti desimaaliprosenttilukuna >= 0, esim. 1.2
Jos = 0, kirkollisveroa ei lasketa.
Jos = 999, sovelletaan keskim��r�ist� veroprosenttia.
*/

%LET MINIMI_KOKO_ASKRYHMA = 1;
%LET MINIMI_KOKO_KELRYHMA = 1;
%LET MINIMI_KOKO_LAMMRYHMA = 1;
%LET MINIMI_KOKO_KUNNVERO = 18.5;
%LET MINIMI_KOKO_KIRKVERO = 0;

/* 3.4 Asuntoon liittyvi� tietoja */

/*
VALMVUOSI: Asunnon valmistumis- tai perusparannusvuosi
PINTALA: Asunnon pinta-ala, m2
OMISTUS: Omistusasunto: 0 tai 1: jos 0 asunto tulkitaan vuokra-asunnoksi
OMAKOTI: Omakotitalo: 0 tai 1: jos OMISTUS = 0, ei vaikutusta.
VUOKRA_VASTIKE: e/kk, tulkitaan vuokraksi tai yhti�vasikkeeksi makromuuttujan OMISTUS mukaisesti;
VESI: Vesimaksu, e/kk
ASKORKO = Asuntolainan korko e/kk; Jos OMISTUS = 0, t�ll� ei ole vaikutusta
*/

%LET MINIMI_KOKO_VALMVUOSI = 1970;
%LET MINIMI_KOKO_PINTALA = 55;
%LET MINIMI_KOKO_OMISTUS = 0;
%LET MINIMI_KOKO_OMAKOTI = 0;
%LET MINIMI_KOKO_VUOKRA_VASTIKE = 750;
%LET MINIMI_KOKO_VESI = 0;
%LET MINIMI_KOKO_ASKOROT = 0;

/* 3.5 Henkil�iden el�m�ntilanne (suluissa olevia vaihtoehtoja ei ole viel� otettu huomioon)  */ 

/* 3.5.1 Henkil�n status */

/*
1 Palkansaaja
2 Ty�t�n (oletus: ansiosidonnainen)
21 Perusp�iv�raha
22 Ty�markkinatuki
3 Sairausvakuutuksen p�iv�raha (oletus: normaali)
31 Vanhempainp�iv�raha (oletus: normaali)
311 Korotettu vanhempainp�iv�raha (90 %)
312 Korotettu vanhempainp�iv�raha (75 %)
(32 Osap�iv�raha)
4 Lasten kotihoidon tuki
(41 Osittainen kotihoidon tuki)
5 Opiskelija (oletus: korkeakoulu, itsen�isesti asuva)
52 Opiskelija: keskiaste, itsen�inen
6 El�kel�inen

Huomautuksia TILANNE-makromuuttujasta:
 - Jos TILANNE = 1 ja palkkatulot = 0, malli laskee tulottoman
   henkil�n tai kotitalouden lapsietuudet, yleisen asumistuen ja toimeentulotuen.
 - Eri tilanteet ovat toisensa poissulkevia.
   Se ei kuitenkaan tarkoita kaikilta osin eri tyyppisten tulojen poissulkevuutta:
	- ty�tt�m�ll�, lasten kotihoidon tuen saajalla, el�kel�isell� ja opiskelijalla voi olla palkkatuloa
	- sairaus- tai vanhempainp�iv�rahan saajalla ei voi olla palkkatuloa
*/

%LET MINIMI_KOKO_TILANNE = 1;

/* 3.5.2 Puolison status */

/*
Jos PUOLISO = 0, ei vaikutusta.
Samat arvot kuin TILANNE-muuttujassa.
*/

%LET MINIMI_KOKO_TILANNE_PUOL = 1;

/* 3.5.3 Lis�oletuksia ty�tt�myysturvaa varten */

/*
KOROTUS: Korotusosa, 0 tai 1
MTURVA: Muutostuvalis�/ty�llist�misohjelmalis�, 0 tai 1
*/

%LET MINIMI_KOKO_KOROTUS = 0;
%LET MINIMI_KOKO_MTURVA = 0;


/* 3.6 Palkkatulo (e/kk) */

/*
- Jos TILANNE = 2 tai 3, t�m� tulkitaan
  ns. vakuutuspalkaksi, johon p�iv�raha perustuu.
  Silloin t�t� palkkaa ei oteta muuten tulona huomioon.
- Jos TILANNE = 2 tai 3 ja PALKKA = 0,
  lasketaan perusp�iv�raha tai alin p�iv�raha.
- Jos TILANNE = 4, t�m� palkka on mahdollinen samanaikaisesti
  lasten kotihoidon tuen kanssa.
- Jos TILANNE = 5, t�ll� ei ole vaikutusta.
*/

%LET MINIMI_KOKO_PALKKA = 1700;
%LET MAKSIMI_KOKO_PALKKA = 1700; 
%LET KYNNYS_KOKO_PALKKA = 500;

/* Sama puolisolle. Ei vaikutusta, jos puoliso = 0 */

%LET MINIMI_KOKO_PALKKA_PUOL = 500;
%LET MAKSIMI_KOKO_PALKKA_PUOL = 1000; 
%LET KYNNYS_KOKO_PALKKA_PUOL = 500;

/* 3.6.1 Tulonhankkimiskulut, Ay-maksut ja ty�matkakulut */

/* Tulonhankkimiskulut (e/kk) */
%LET MINIMI_KOKO_TULONHANKKULUT = 10;
%LET MAKSIMI_KOKO_TULONHANKKULUT = 10;
%LET KYNNYS_KOKO_TULONHANKKULUT = 100;

/* Tulonhankkimiskulut, puoliso (e/kk) */

%LET MINIMI_KOKO_TULONHANKKULUT_PUOL = 0;
%LET MAKSIMI_KOKO_TULONHANKKULUT_PUOL = 0;
%LET KYNNYS_KOKO_TULONHANKKULUT_PUOL = 100;

/* Ay-j�senmaksut (e/kk) */
%LET MINIMI_KOKO_AYMAKSUT = 0;
%LET MAKSIMI_KOKO_AYMAKSUT = 0; 
%LET KYNNYS_KOKO_AYMAKSUT = 10;

/* Ay-j�senmaksut (e/kk), puoliso */
%LET MINIMI_KOKO_AYMAKSUT_PUOL = 0;
%LET MAKSIMI_KOKO_AYMAKSUT_PUOL = 0; 
%LET KYNNYS_KOKO_AYMAKSUT_PUOL = 10;

/* Ty�matkakulut (e/kk) */
%LET MINIMI_KOKO_TYOMATKAKULUT = 0;
%LET MAKSIMI_KOKO_TYOMATKAKULUT = 0; 
%LET KYNNYS_KOKO_TYOMATKAKULUT = 100;

/* Ty�matkakulut (e/kk), puoliso */
%LET MINIMI_KOKO_TYOMATKAKULUT_PUOL = 0;
%LET MAKSIMI_KOKO_TYOMATKAKULUT_PUOL = 0; 
%LET KYNNYS_KOKO_TYOMATKAKULUT_PUOL = 100;


/* 3.6.2 Tuloaskel, jolla tuloa korotetaan marginaaliveroastetta laskettaessa (e/kk) */

%LET MINIMI_KOKO_ASKEL = 1;
%LET MAKSIMI_KOKO_ASKEL = 1; 
%LET KYNNYS_KOKO_ASKEL = 1;

/* 3.7 Ansioel�ke (e/kk) */

/* T�ll� on vaikutusta vain, jos tilanne = 6 */

%LET MINIMI_KOKO_ELAKE = 0;
%LET MAKSIMI_KOKO_ELAKE = 0; 
%LET KYNNYS_KOKO_ELAKE = 250;

/* Sama puolisolle. Ei vaikutusta, jos puoliso = 0 */

%LET MINIMI_KOKO_ELAKE_PUOL = 0;
%LET MAKSIMI_KOKO_ELAKE_PUOL = 0; 
%LET KYNNYS_KOKO_ELAKE_PUOL = 250;


/* 3.8 Soviteltava palkka (e/kk) */

/*
- Jos TILANNE = 1, t�t� ei oteta huomioon.
- Jos TILANNE = 2, t�st� lasketaan soviteltu ty�tt�myysp�iv�raha.
- Jos TILANNE = 3, t�t� ei oteta huomioon.
- Jos TILANNE = 4, t�t� ei oteta huomioon.
- Jos TILANNE = 5, t�m� on opintotukikuukausien aikana saatua palkkaa.
- Jos TILANNE = 6, t�m� on el�kekuukausien aikana saatua palkkaa.
*/

%LET MINIMI_KOKO_SOVPALKKA = 0;
%LET MAKSIMI_KOKO_SOVPALKKA = 0;
%LET KYNNYS_KOKO_SOVPALKKA = 10;

/* Sama puolisolle. Ei vaikutusta, jos PUOLISO = 0 */

%LET MINIMI_KOKO_SOVPALKKA_PUOL = 600;
%LET MAKSIMI_KOKO_SOVPALKKA_PUOL = 600; 
%LET KYNNYS_KOKO_SOVPALKKA_PUOL = 100;

%END;

/* 3.9 Tarkistuksia TILANNE-muuttujan mukaisesti */

/* Jos TILANNE = 5 tai 6, PALKKA = 0 */

%IF &MINIMI_KOKO_TILANNE = 5 OR &MINIMI_KOKO_TILANNE = 6 %THEN %DO;
	%LET MINIMI_KOKO_PALKKA = 0;
	%LET MAKSIMI_KOKO_PALKKA = 0;
%END;

%IF &MINIMI_KOKO_TILANNE_PUOL = 5 OR &MINIMI_KOKO_TILANNE_PUOL = 6 %THEN %DO;
	%LET MINIMI_KOKO_PALKKA_PUOL = 0;
	%LET MAKSIMI_KOKO_PALKKA_PUOL = 0;
%END;

/* El�ketuloa vain, jos TILANNE = 6 */

%IF &MINIMI_KOKO_TILANNE NE 6 %THEN %DO;
	%LET MINIMI_KOKO_ELAKE = 0;
	%LET MAKSIMI_KOKO_ELAKE = 0;

%END;

%IF &MINIMI_KOKO_TILANNE_PUOL NE 6 %THEN %DO;
	%LET MINIMI_KOKO_ELAKE_PUOL = 0;
	%LET MAKSIMI_KOKO_ELAKE_PUOL = 0;
%END;

/* Jos PUOLISO = 0, puolison tulot nollataan varmuuden vuoksi */
	
%IF &MINIMI_KOKO_PUOLISO = 0 %THEN %DO;
	%LET MINIMI_KOKO_PALKKA_PUOL = 0;
	%LET MAKSIMI_KOKO_PALKKA_PUOL = 0;
	%LET MINIMI_KOKO_SOVPALKKA_PUOL = 0;
	%LET MAKSIMI_KOKO_SOVPALKKA_PUOL = 0;
	%LET MINIMI_KOKO_ELAKE_PUOL = 0;
	%LET MAKSIMI_KOKO_ELAKE_PUOL = 0;
%END;

/* SOVPALKKA ei liity tilanteisiin 1, 3, 31, 311, 312 ja 4 */

%IF &MINIMI_KOKO_TILANNE = 1 OR  &MINIMI_KOKO_TILANNE = 3 OR %SUBSTR(&MINIMI_KOKO_TILANNE, 1, 2) = 31  OR &MINIMI_KOKO_TILANNE = 4 %THEN %DO;
	%LET MINIMI_KOKO_SOVPALKKA = 0;
	%LET MAKSIMI_KOKO_SOVPALKKA = 0;
%END;

%IF &MINIMI_KOKO_TILANNE_PUOL = 1 OR &MINIMI_KOKO_TILANNE_PUOL = 3 
OR %SUBSTR(&MINIMI_KOKO_TILANNE_PUOL, 1, 2) = 31 OR &MINIMI_KOKO_TILANNE_PUOL = 4 %THEN %DO;
	%LET MINIMI_KOKO_SOVPALKKA_PUOL = 0;
	%LET MAKSIMI_KOKO_SOVPALKKA_PUOL = 0;
%END;

/* 3.10 Makromuuttujien johdonmukaisuuden varmistaminen */

/* Asuntolainan korot otetaan huomioon vain omistusasunnosa */

%IF &MINIMI_KOKO_OMISTUS = 0 %THEN %LET MINIMI_KOKO_ASKOROT = 0;

/* Helsinki on aina kuulunut kalleusluokkaan 1 */

%IF &MINIMI_KOKO_ASKRYHMA = 1 %THEN %LET MINIMI_KOKO_KELRYHMA = 1;

/* Kotihoidon tukea voi saada puolisoista vain toinen */
/* Jos kyse on puolisoista, viitehenkil� ei voi saada kotihoidon tukea */

%IF &MINIMI_KOKO_PUOLISO = 1 AND &MINIMI_KOKO_TILANNE = 4 %THEN %LET MINIMI_KOKO_TILANNE = 1;

/* Kotihoidon tuen laskennassa ei ole mielt�, ellei kotitaloudessa ole alle 3-vuotiaita lapsia */

%IF (&MINIMI_KOKO_TILANNE = 4 OR &MINIMI_KOKO_TILANNE_PUOL = 4) AND &MINIMI_KOKO_LAPSIA_ALLE3 = 0 %THEN %LET MINIMI_KOKO_TILANNE = 1;

/* Korotusosa ja muutosturva eiv�t p�de yht�aikaa */

%IF &MINIMI_KOKO_KOROTUS = 1 %THEN %LET MINIMI_KOKO_MTURVA = 0;

/* 4. Fiktiivisen aineiston luominen ja simulointi */

/* 4.1 Generoidaan data makromuuttujien arvojen mukaisesti */ 

DATA OUTPUT.&TULOSNIMI_KOKO;

DO KOKO_VUOSI = &MINIMI_KOKO_VUOSI TO &MAKSIMI_KOKO_VUOSI;
DO KOKO_KUUK = &MINIMI_KOKO_KUUK TO &MAKSIMI_KOKO_KUUK;
DO KOKO_PUOLISO = &MINIMI_KOKO_PUOLISO ;
DO KOKO_LAPSIA_ALLE3 = &MINIMI_KOKO_LAPSIA_ALLE3;
DO KOKO_LAPSIA_3_6 = &MINIMI_KOKO_LAPSIA_3_6;
DO KOKO_LAPSIA_3_9 = &MINIMI_KOKO_LAPSIA_3_9;
DO KOKO_LAPSIA_10_15 = &MINIMI_KOKO_LAPSIA_10_15;
DO KOKO_LAPSIA_16 = &MINIMI_KOKO_LAPSIA_16;
DO KOKO_LAPSIA_17 = &MINIMI_KOKO_LAPSIA_17;
DO KOKO_IKA = &MINIMI_KOKO_IKA;
DO KOKO_IKA_PUOL = &MINIMI_KOKO_IKA_PUOL;
DO KOKO_ASKRYHMA = &MINIMI_KOKO_ASKRYHMA;
DO KOKO_KELRYHMA = &MINIMI_KOKO_KELRYHMA;
DO KOKO_LAMMRYHMA = &MINIMI_KOKO_LAMMRYHMA;
DO KOKO_KUNNVERO = &MINIMI_KOKO_KUNNVERO;
DO KOKO_KIRKVERO = &MINIMI_KOKO_KIRKVERO;
DO KOKO_VALMVUOSI = &MINIMI_KOKO_VALMVUOSI;
DO KOKO_PINTALA = &MINIMI_KOKO_PINTALA;
DO KOKO_OMISTUS = &MINIMI_KOKO_OMISTUS;
DO KOKO_OMAKOTI = &MINIMI_KOKO_OMAKOTI;
DO KOKO_VUOKRA_VASTIKE = &MINIMI_KOKO_VUOKRA_VASTIKE;
DO KOKO_VESI = &MINIMI_KOKO_VESI;
DO KOKO_ASKOROT = &MINIMI_KOKO_ASKOROT;
DO KOKO_TILANNE = &MINIMI_KOKO_TILANNE;
DO KOKO_TILANNE_PUOL = &MINIMI_KOKO_TILANNE_PUOL;
DO KOKO_KOROTUS = &MINIMI_KOKO_KOROTUS;
DO KOKO_MTURVA = &MINIMI_KOKO_MTURVA;

DO KOKO_PALKKA = &MINIMI_KOKO_PALKKA TO &MAKSIMI_KOKO_PALKKA BY &KYNNYS_KOKO_PALKKA;
DO KOKO_TULONHANKKULUT = &MINIMI_KOKO_TULONHANKKULUT TO &MAKSIMI_KOKO_TULONHANKKULUT BY &KYNNYS_KOKO_TULONHANKKULUT;
DO KOKO_AYMAKSUT = &MINIMI_KOKO_AYMAKSUT TO &MAKSIMI_KOKO_AYMAKSUT BY &KYNNYS_KOKO_AYMAKSUT;
DO KOKO_TYOMATKAKULUT = &MINIMI_KOKO_TYOMATKAKULUT TO &MAKSIMI_KOKO_TYOMATKAKULUT BY &KYNNYS_KOKO_TYOMATKAKULUT;
DO KOKO_ELAKE = &MINIMI_KOKO_ELAKE TO &MAKSIMI_KOKO_ELAKE BY &KYNNYS_KOKO_ELAKE;
DO KOKO_SOVPALKKA = &MINIMI_KOKO_SOVPALKKA TO &MAKSIMI_KOKO_SOVPALKKA BY &KYNNYS_KOKO_SOVPALKKA;
DO KOKO_ASKEL = &MINIMI_KOKO_ASKEL TO &MAKSIMI_KOKO_ASKEL BY &KYNNYS_KOKO_ASKEL;
DO KOKO_PALKKA_PUOL = &MINIMI_KOKO_PALKKA_PUOL TO &MAKSIMI_KOKO_PALKKA_PUOL BY &KYNNYS_KOKO_PALKKA_PUOL;
DO KOKO_TULONHANKKULUT_PUOL = &MINIMI_KOKO_TULONHANKKULUT_PUOL TO &MAKSIMI_KOKO_TULONHANKKULUT_PUOL BY &KYNNYS_KOKO_TULONHANKKULUT_PUOL;
DO KOKO_AYMAKSUT_PUOL = &MINIMI_KOKO_AYMAKSUT_PUOL TO &MAKSIMI_KOKO_AYMAKSUT_PUOL BY &KYNNYS_KOKO_AYMAKSUT_PUOL;
DO KOKO_TYOMATKAKULUT_PUOL = &MINIMI_KOKO_TYOMATKAKULUT_PUOL TO &MAKSIMI_KOKO_TYOMATKAKULUT_PUOL BY &KYNNYS_KOKO_TYOMATKAKULUT_PUOL;
DO KOKO_SOVPALKKA_PUOL = &MINIMI_KOKO_SOVPALKKA_PUOL TO &MAKSIMI_KOKO_SOVPALKKA_PUOL BY &KYNNYS_KOKO_SOVPALKKA_PUOL;
DO KOKO_ELAKE_PUOL = &MINIMI_KOKO_ELAKE_PUOL TO &MAKSIMI_KOKO_ELAKE_PUOL BY &KYNNYS_KOKO_ELAKE_PUOL;

/* 4.2 Inflaatiokerron */

%IF &INF = 999 %THEN %DO;
%IndKerroin_ESIM(&AVUOSI, KOKO_VUOSI);
%END;
%ELSE %DO; 
	INF = &INF;
%END;

OUTPUT;
END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;
END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;END;

RUN;

%MEND Generoi_Muuttujat;

%Generoi_Muuttujat;


/* 4. Yksil�tason laskenta */

%MACRO KOKO_LASKENTA(onkopuoliso);

/* onkopuoliso-parametri lis�� muuttujien nimeen _puol-liitteen.
   Jos oletusten mukaan puolisoa ei ole, t�ll� ei ole vaikutusta */

%IF &onkopuoliso = 1 %THEN %LET suff = _PUOL;
%ELSE %LET suff = ;

/* Jos puolisoa ei sittenk��n ole ohitetaan jatko ja menn��n loppuun */

%IF &onkopuoliso = 1 AND &MINIMI_KOKO_PUOLISO = 0 %THEN %GOTO loppu;


DATA OUTPUT.&TULOSNIMI_KOKO;
SET OUTPUT.&TULOSNIMI_KOKO;

/* Nollataan sellaisia muuttujia, joita ei v�ltt�m�tt� aina tuoteta */
TYOTPR&suff = 0;
SAIRPR&suff = 0;
KOTIHTU&suff = 0;
OPRAHA&suff = 0;
OPLAINA&suff = 0;
ASUMLISA&suff = 0;
KANSEL&suff = 0;
TAKUUEL&suff = 0;
ELAKYHT&suff = 0;
LAPSIKOR&suff = 0;
KOKO_VAKPALKKA&suff = 0;

/* Jotta alkuper�ist� palkkatuloa ei laskettaisi mukaan verotettaviin tuloihin silloin,
   kun siit� on vain johdettu ty�tt�myysp�iv�raha tai sairausvakuutuksen p�iv�raha,
   KOKO_PALKKA-MUUTTUJA MUUTETTAAN KOKO_VAKPALKKA-nimiseksi muuttujaksi */

SELECT (KOKO_TILANNE&suff);
WHEN(2, 21, 22, 3, 31, 311, 312) DO;
	KOKO_VAKPALKKA&suff = KOKO_PALKKA&suff;
	KOKO_PALKKA&suff = 0;
END;
OTHERWISE;
END;

/* 4.1 Ty�tt�myysp�iv�rahat */

%IF %SUBSTR(&&MINIMI_KOKO_TILANNE&suff, 1, 1) = 2 %THEN %DO;

	YHTLAPSIATTURVA&suff = SUM(KOKO_LAPSIA_ALLE3, KOKO_LAPSIA_3_9, KOKO_LAPSIA_10_15, KOKO_LAPSIA_16, KOKO_LAPSIA_17);

	%IF &&MINIMI_KOKO_TILANNE&suff = 2 %THEN %DO;

		%IF &VUOSIKA = 2 %THEN %DO;
			%AnsioSidK&F (TYOTPR&suff, KOKO_VUOSI, KOKO_KUUK, INF, YHTLAPSIATTURVA&suff, KOKO_KOROTUS, KOKO_MTURVA, 0, KOKO_VAKPALKKA&suff, 0);
		%END;
		%ELSE %DO;
			%AnsioSidV&F (TYOTPR&suff, KOKO_VUOSI, INF, YHTLAPSIATTURVA&suff, KOKO_KOROTUS, KOKO_MTURVA, 0, KOKO_VAKPALKKA&suff, 0);
		%END;
	%END;


	%ELSE %IF &&MINIMI_KOKO_TILANNE&suff = 21 %THEN %DO;

		%IF &VUOSIKA = 2 %THEN %DO;
			%PerusPRahaK&F (TYOTPR&suff, KOKO_VUOSI, KOKO_KUUK, INF, 0, (KOKO_KOROTUS OR KOKO_MTURVA), KOKO_PUOLISO, YHTLAPSIATTURVA&suff, 0, 0, 0);
		%END;
		%ELSE %DO;
			%PerusPRahaV&F (TYOTPR&suff, KOKO_VUOSI, INF, 0, (KOKO_KOROTUS OR KOKO_MTURVA), KOKO_PUOLISO, YHTLAPSIATTURVA&suff, 0, 0, 0);
		%END;
	%END;


	%ELSE %IF &&MINIMI_KOKO_TILANNE&suff = 22 %THEN %DO; 

    	%IF &VUOSIKA = 2 %THEN %DO; 
			%IF (&onkopuoliso = 0) %THEN %DO;
               	%TyomTukiK&F (TYOTPR&suff, KOKO_VUOSI, KOKO_KUUK, INF, 1, 0, KOKO_PUOLISO, YHTLAPSIATTURVA&suff, 0, 0, SUM(KOKO_PALKKA_PUOL, KOKO_SOVPALKKA_PUOL), 0, (KOKO_KOROTUS OR KOKO_MTURVA), 0); 
			%END;
			%ELSE %DO;
				%TyomTukiK&F (TYOTPR&suff, KOKO_VUOSI, KOKO_KUUK, INF, 1, 0, KOKO_PUOLISO, YHTLAPSIATTURVA&suff, 0, 0, SUM(KOKO_PALKKA, KOKO_SOVPALKKA, TYOTPR), 0, (KOKO_KOROTUS OR KOKO_MTURVA), 0); 
            %END; 
		%END;
        %ELSE %DO; 
			%IF (&onkopuoliso = 0) %THEN %DO;
           		%TyomTukiV&F (TYOTPR&suff, KOKO_VUOSI, INF, 1, 0, KOKO_PUOLISO, YHTLAPSIATTURVA&suff, 0, 0, SUM(KOKO_PALKKA_PUOL, KOKO_SOVPALKKA_PUOL) , 0, (KOKO_KOROTUS OR KOKO_MTURVA), 0); 
			%END;
			%ELSE %DO;
				%TyomTukiV&F (TYOTPR&suff, KOKO_VUOSI, INF, 1, 0, KOKO_PUOLISO, YHTLAPSIATTURVA&suff, 0, 0, SUM(KOKO_PALKKA, KOKO_SOVPALKKA, TYOTPR), 0, (KOKO_KOROTUS OR KOKO_MTURVA), 0); 
			%END;
		 %END; 
      %END; 


	/* 4.1.1 Sovitellut p�iv�rahat */

	IF KOKO_SOVPALKKA&suff > 0 THEN DO;

		%IF &VUOSIKA = 2 %THEN %DO;
			%SoviteltuK&F (TYOTPR&suff, KOKO_VUOSI, KOKO_KUUK, INF, IFN(KOKO_TILANNE&suff = 2, 1, 0), (KOKO_KOROTUS OR KOKO_MTURVA), (YHTLAPSIATTURVA&suff > 0), TYOTPR&suff, KOKO_SOVPALKKA&suff, KOKO_VAKPALKKA&suff, 0);
		%END;
		%ELSE %DO;
			%SoviteltuV&F (TYOTPR&suff, KOKO_VUOSI, INF, IFN(KOKO_TILANNE&suff = 2, 1, 0), (KOKO_KOROTUS OR KOKO_MTURVA), (YHTLAPSIATTURVA&suff > 0), TYOTPR&suff, KOKO_SOVPALKKA&suff, KOKO_VAKPALKKA&suff, 0);
		%END;
	END;
%END;

/* 4.2 Sairausvakuutuksen p�iv�rahat */

%IF %SUBSTR(&&MINIMI_KOKO_TILANNE&suff, 1, 1) = 3 %THEN %DO;

	YHTLAPSIASAIRVAK&suff = SUM(KOKO_LAPSIA_ALLE3, KOKO_LAPSIA_3_9, KOKO_LAPSIA_10_15);

	/* Palkasta v�hennet��n ensin tulonhankkimiskulut */

	%TulonHankKulut&F(SVHANKVAH&suff, KOKO_VUOSI, INF, 12*SUM(KOKO_VAKPALKKA&suff), 12*SUM(KOKO_VAKPALKKA&suff),
		12*KOKO_TULONHANKKULUT&suff, 12*KOKO_AYMAKSUT&suff, 12*KOKO_TYOMATKAKULUT&suff, 0);

	TULO&suff =  MAX(12 * KOKO_VAKPALKKA&suff - SVHANKVAH&suff, 0);


	/* 4.2.1 Tavallinen sairausp�iv�raha tai osap�iv�raha */

	%IF &&MINIMI_KOKO_TILANNE&suff = 3 OR &&MINIMI_KOKO_TILANNE&suff = 32 %THEN %DO;

		%IF &VUOSIKA = 2 %THEN %DO;
			%SairVakPrahaK&F (SAIRPR&suff, KOKO_VUOSI, KOKO_KUUK, INF, 0, YHTLAPSIASAIRVAK&suff, TULO&suff);
		%END;
		%ELSE %DO;
			%SairVakPrahaV&F (SAIRPR&suff, KOKO_VUOSI, INF, 0, YHTLAPSIASAIRVAK&suff, TULO&suff);
		%END;
	%END;

	/* 4.2.2 Normaali vanhempainp�iv�raha */

	%IF &&MINIMI_KOKO_TILANNE&suff = 31 %THEN %DO;

		%IF &VUOSIKA = 2 %THEN %DO;
			%SairVakPrahaK&F (SAIRPR&suff, KOKO_VUOSI, KOKO_KUUK, INF, 1, YHTLAPSIASAIRVAK&suff, TULO&suff);
		%END;
		%ELSE %DO;
			%SairVakPrahav&F (SAIRPR&suff, KOKO_VUOSI, INF, 1, YHTLAPSIASAIRVAK&suff, TULO&suff);
		%END;
	%END;
	
	/* 4.2.3 Korotettu vanhemnpainp�iv�raha; �itiysraha 56 ensimm�iselt� p�iv�lt�; 90 %:n kerroin */

	%IF &&MINIMI_KOKO_TILANNE&suff = 311 %THEN %DO;

		%IF &VUOSIKA = 2 %THEN %DO;
			%KorVanhRahaK&F (SAIRPR&suff, KOKO_VUOSI, KOKO_KUUK, INF, 1, YHTLAPSIASAIRVAK&suff, TULO&suff);
		%END;
		%ELSE %DO;
			%KorVanhRahav&F (SAIRPR&suff, KOKO_VUOSI, INF, 1, YHTLAPSIASAIRVAK&suff, TULO&suff);
		%END;
	%END;

	/* 4.2.4 Korotettu vanhemnpainraha; muut tapaukset; 75 %:n kerroin */

	%IF &&MINIMI_KOKO_TILANNE&suff = 312 %THEN %DO;

		%IF &VUOSIKA = 2 %THEN %DO;
			 %KorVanhRahaK&F (SAIRPR&suff, KOKO_VUOSI, KOKO_KUUK, INF, 0, YHTLAPSIASAIRVAK&suff, TULO&suff);
		%END;
		%ELSE %DO;
			%KorVanhRahaV&F (SAIRPR&suff, KOKO_VUOSI, INF, 0, YHTLAPSIASAIRVAK&suff, TULO&suff);
		%END;
	%END;

	/* 4.2.5 Osap�iv�raha puolet normaalista sairausp�iv�rahasta */

	%IF &&MINIMI_KOKO_TILANNE&suff = 32 %THEN %DO;

	    SAIRPR&suff = 0.5 * SAIRPR&suff;

	%END;


%END;

/* 4.3 Kotihoidon tuki */

/* Kotihoidon tuki voidaan laskea vasta kun kummankin puolison muut veronalaiset tulot ovat tiedossa.
   Jos kyse on puolisoista, laskenta tapahtuu vain kun KOKO_TILANNE_PUOL = 4 ja  &onkopuoliso = 1.
   T�ll�in vain puolisolla voi olla kotihoidon tukea, ei henkil�ll�.
   Lis�ksi edellytet��n, ett� kotitaloudessa on alle 3-vuotiaita lapsia */

%IF ((&MINIMI_KOKO_TILANNE = 4 AND &MINIMI_KOKO_PUOLISO = 0 AND &onkopuoliso = 0) OR (&MINIMI_KOKO_TILANNE_PUOL = 4 
	AND &MINIMI_KOKO_PUOLISO = 1 AND &onkopuoliso = 1)) AND &MINIMI_KOKO_LAPSIA_ALLE3 > 0 %THEN %DO;
		
	KOTIHTULOT = SUM(KOKO_PALKKA, KOKO_PALKKA_PUOL, KOKO_SOVPALKKA, KOKO_SOVPALKKA_PUOL, SAIRPR, SAIRPR_PUOL, TYOTPR, TYOTPR_PUOL, OPRAHA, OPRAHA_PUOL);
	
	SISARIA = MAX(KOKO_LAPSIA_ALLE3 - 1, 0);

	KOKO = SUM(1, KOKO_LAPSIA_ALLE3, KOKO_LAPSIA_3_6, IFN(KOKO_PUOLISO, 1, 0));

	%IF &VUOSIKA = 2 %THEN %DO;
		%KotihTukiK&F (KOTIHTU&suff, KOKO_VUOSI, KOKO_KUUK, INF, SISARIA, KOKO_LAPSIA_3_6, KOKO, KOTIHTULOT, 0);
	%END;
	%ELSE %DO;
		%KotihTukiV&F (KOTIHTU&suff, KOKO_VUOSI, INF, SISARIA, KOKO_LAPSIA_3_6, KOKO, KOTIHTULOT, 0);
	%END;
%END;

/* 4.4 Opintotuki */

/* 4.4.1 Opintoraha ja -laina */

/* Takaisinperint� lasketaan olettamalla, ett� samat tulot ovat 12 kk vuodessa */

/* Lasketaan my�s opintolaina, jota k�ytet��n toimeentulotuen laskennassa */

%IF %SUBSTR(&&MINIMI_KOKO_TILANNE&suff, 1, 1) = 5 %THEN %DO;

	%IF &VUOSIKA = 2 %THEN %DO;
		%OpRahaK&F (OPRAHA&suff, KOKO_VUOSI, KOKO_KUUK, INF, (KOKO_TILANNE&suff = 5), 0, KOKO_IKA&suff, 0, 12* KOKO_SOVPALKKA&suff, 0, 0);
	%END;
	%ELSE %DO;
		%OpRahaV&F (OPRAHA&suff, KOKO_VUOSI, INF, (KOKO_TILANNE&suff = 5), 0, KOKO_IKA&suff, 0, 12* KOKO_SOVPALKKA&suff, 0, 0);
	%END;	
	%OpTukiTakaisin&F (TAKAISIN&suff, KOKO_VUOSI, KOKO_KUUK, INF, 12, 12*KOKO_SOVPALKKA&suff, 12*OPRAHA&suff);

	OPRAHA&suff = MAX(SUM(OPRAHA&suff, - TAKAISIN&suff/12), 0);

	%IF &VUOSIKA = 2 %THEN %DO;
		%OpLainaK&F (OPLAINA&suff, KOKO_VUOSI, KOKO_KUUK, INF, (KOKO_TILANNE&suff = 5), 0, KOKO_IKA&suff);
	%END;
	%ELSE %DO;
		%OpLainaV&F (OPLAINA&suff, KOKO_VUOSI, INF, (KOKO_TILANNE&suff = 5), 0, KOKO_IKA&suff);
	%END;
%END;

/* 4.4.2 Opintotuen asumislis� */

/* Opintorahan asumislis� lasketaan henkil�kohtaisena tulona, jos TILANNE on  (5, 51),
   jos asunto vuokra-asunto ja jos henkil�ll� tai puolisoilla ei ole lapsia.
   Yhteislaskennassa hyv�ksyt��n puolisoille vain jos kumpikin puoliso on opiskelija.
   Omistusasuntoon asumislis�� ei lasketa. */

%IF %SUBSTR(&&MINIMI_KOKO_TILANNE&suff, 1, 1) = 5 AND &MINIMI_KOKO_OMISTUS = 0 AND 
	%SYSFUNC(SUM(&MINIMI_KOKO_LAPSIA_ALLE3, &MINIMI_KOKO_LAPSIA_3_9, &MINIMI_KOKO_LAPSIA_10_15, &MINIMI_KOKO_LAPSIA_16, &MINIMI_KOKO_LAPSIA_17)) = 0
%THEN %DO;

	/* Puolisoilla vuokra puolitetaan asumislis�n erikseen laskemista varten */

	IF KOKO_PUOLISO = 1 THEN VUOKRA = KOKO_VUOKRA_VASTIKE/2;
	ELSE VUOKRA = KOKO_VUOKRA_VASTIKE;

	%IF &VUOSIKA = 2 %THEN %DO;
		%AsumLisaK&F (ASUMLISA&suff, KOKO_VUOSI, KOKO_KUUK, INF, (KOKO_TILANNE&suff = 5), KOKO_IKA&suff, 0, VUOKRA, KOKO_SOVPALKKA&suff, 0, 0);
	%END;
	%ELSE %DO;
		%AsumLisaV&F (ASUMLISA&suff, KOKO_VUOSI, INF, (KOKO_TILANNE&suff = 5), KOKO_IKA&suff, 0, VUOKRA, KOKO_SOVPALKKA&suff, 0, 0);
	%END;
	%OpTukiTakaisin&F (TAKAISIN_AL&suff, KOKO_VUOSI, KOKO_KUUK, INF, 12, 12*KOKO_SOVPALKKA&suff, 12*ASUMLISA&suff);

	ASUMLISA&suff = MAX(SUM(ASUMLISA&suff, - TAKAISIN_AL&suff/12), 0);

%END;

/* 4.5 Kansanel�ke, takuuel�ke ja el�kkeensaajan lapsikorotukset */

%IF &&MINIMI_KOKO_TILANNE&suff = 6 %THEN %DO;

	%IF &VUOSIKA = 2 %THEN %DO;
		%Kansanelake_SimpleK&F (KANSEL&suff, KOKO_VUOSI, KOKO_KUUK, INF, 0, KOKO_PUOLISO, KOKO_KELRYHMA, 12*KOKO_ELAKE&suff, 1);
		%TakuuElakeK&F (TAKUUEL&suff, KOKO_VUOSI, KOKO_KUUK, INF, SUM(KOKO_ELAKE&suff, KANSEL&suff), 1);
	%END;
	%ELSE %DO;
		%Kansanelake_SimpleV&F (KANSEL&suff, KOKO_VUOSI, INF, 0, KOKO_PUOLISO, KOKO_KELRYHMA, 12*KOKO_ELAKE&suff, 1);
		%TakuuElakeV&F (TAKUUEL&suff, KOKO_VUOSI, INF, SUM(KOKO_ELAKE&suff, KANSEL&suff), 1);

	%END;
	ELAKYHT&suff = SUM(KOKO_ELAKE&suff, KANSEL&suff, TAKUUEL&suff);

	/* Lasketaan el�kkeensaajien lapsikorotukset */
	/* Vain alle 16-vuotiaat lapset otetaan huomioon */

	ELLAPSIA = SUM(KOKO_LAPSIA_ALLE3, KOKO_LAPSIA_3_9, KOKO_LAPSIA_10_15);

	%IF &VUOSIKA = 2 %THEN %DO;
		%KanselLisatK&F (LAPSIKOR&suff, KOKO_VUOSI, KOKO_KUUK, INF, 1, 0, 0, 0, 0,0, 0, 0, KOKO_KELRYHMA, ELLAPSIA); 
	%END;
	%ELSE %DO;
		%KanselLisatV&F (LAPSIKOR&suff, KOKO_VUOSI, INF, 1, 0, 0, 0, 0,0, 0, 0, KOKO_KELRYHMA, ELLAPSIA);
	%END;
%END;

/* 4.6 Verotus */

/* 4.6.1 El�kevakuutusmaksu ja muut palkasta peritt�v�t maksut */

%TyoelMaksu&F (TYOEL&suff, KOKO_VUOSI, (KOKO_IKA&suff > 52), 12*SUM(KOKO_PALKKA&suff, KOKO_SOVPALKKA&suff));

%TyotMaksu&F (TYOTMAKSU&suff, KOKO_VUOSI, 12*SUM(KOKO_PALKKA&suff, KOKO_SOVPALKKA&suff));

%SvPRahaMaksu&F (SVPRMAKSU&suff, KOKO_VUOSI, 12*SUM(KOKO_PALKKA&suff, KOKO_SOVPALKKA&suff));

PALKVAK&suff = SUM(TYOEL&suff, TYOTMAKSU&suff, SVPRMAKSU&suff);

/* 4.6.2 Tulonhankkimisv�hennys */

IF SUM(KOKO_PALKKA&suff, KOKO_SOVPALKKA&suff) > 0 THEN DO;
	
	%TulonHankKulut&f(HANKVAH&suff, KOKO_VUOSI, INF, 12*SUM(KOKO_PALKKA&suff, KOKO_SOVPALKKA&suff ), 12*SUM(KOKO_PALKKA&suff, KOKO_SOVPALKKA&suff),
		12*KOKO_TULONHANKKULUT&suff, 12*KOKO_AYMAKSUT&suff, 12*KOKO_TYOMATKAKULUT&suff, 0);

END;
ELSE DO;
	HANKVAH&suff = 0;
END;

ANSIOTULO&suff = 12*SUM(KOKO_PALKKA&suff, KOKO_SOVPALKKA&suff, TYOTPR&suff, SAIRPR&suff, KOTIHTU&suff, OPRAHA&suff, ELAKYHT&suff);

PUHDANSIOTULO&suff = MAX(ANSIOTULO&suff - HANKVAH&suff, 0);

/* 4.6.3 Kunnallisverotuksen ansiotulov�hennys */

%KunnAnsVah&F (KUNNANS&suff, KOKO_VUOSI, INF,  PUHDANSIOTULO&suff, ANSIOTULO&suff, 12*SUM(KOKO_PALKKA&suff, KOKO_SOVPALKKA&suff), 12*SUM(KOKO_PALKKA&suff, KOKO_SOVPALKKA&suff), ANSIOTULO&suff);

/* 4.6.4 Opintorahav�hennys */

%KunnOpRahVah&F (OPRAHVAH&suff, KOKO_VUOSI, INF, 1, 12*OPRAHA&suff, ANSIOTULO&suff, PUHDANSIOTULO&suff);

/* 4.6.5 Kunnallisverotuksen el�ketulov�hennys */

%KunnElTulVah&F (KUNNELVAH&suff, KOKO_VUOSI, INF, KOKO_PUOLISO, 0, 12*ELAKYHT&suff, PUHDANSIOTULO&suff, ANSIOTULO&suff);

/* 4.6.6 Kunnalliverotuksessa verotettava tulo ennen perusv�hennyst� */

KUNNVERTULO1&suff = MAX(SUM(ANSIOTULO&suff, -PALKVAK&suff, -HANKVAH&suff, -KUNNANS&suff, -OPRAHVAH&suff, -KUNNELVAH&suff), 0);

/* 4.6.7 Perusv�hennys */

%KunnPerVah&F (KUNNPER&suff, KOKO_VUOSI, INF, KUNNVERTULO1&suff);

/* 4.6.8 Kunnallisverotuksessa verotettava tulo */

KUNNVERTULO2&suff = MAX(KUNNVERTULO1&suff - KUNNPER&suff, 0);

/* 4.6.9 Kunnallisvero */

%IF &MINIMI_KOKO_KUNNVERO = 999 %THEN %DO;
	
  %KunnVero&F (KUNNVERO&suff, KOKO_VUOSI, 1, 18, KUNNVERTULO2&suff);

%END;

%ELSE %DO;

  %KunnVero&F (KUNNVERO&suff, KOKO_VUOSI, 0, KOKO_KUNNVERO, KUNNVERTULO2&suff);

%END;

/* 4.6.10 Kirkollisvero */

%IF &MINIMI_KOKO_KIRKVERO = 999 %THEN %DO;
	
  %KirkVero&F (KIRKVERO&suff, KOKO_VUOSI, 1, 18, KUNNVERTULO2&suff);

%END;

%ELSE %DO;

  %KirkVero&F (KIRKVERO&suff, KOKO_VUOSI, 0, KOKO_KIRKVERO, KUNNVERTULO2&suff);

%END;

/* 4.6.11 Sairaanhoitomaksu/sairausvakuutusmaksu */

%SairVakMaksu&F (SAIRVAKM&suff, KOKO_VUOSI, INF, KUNNVERTULO2&suff, ELAKYHT&suff, 12*SUM(KOKO_PALKKA&suff, KOKO_SOVPALKKA&suff));

/* 4.6.12 Kansanel�kevakuutusmaksu */

%KanselVakMaksu&F (KANSELM&suff, KOKO_VUOSI, KUNNVERTULO2&suff, 0);

/* 4.6.14 Valtionverotuksen el�ketulov�hennys */

%ValtElTulVah&F (VALTELVAH&suff, KOKO_VUOSI, INF, 12*ELAKYHT&suff, PUHDANSIOTULO&suff, ANSIOTULO&suff)

/* 4.6.15 Valtionverotuksessa verotettava tulo */

VALTVERTULO&suff = MAX(SUM(ANSIOTULO&suff, - PALKVAK&suff, - HANKVAH&suff, -VALTELVAH&suff), 0);

/* 4.6.16 Valtionvero ennen verosta teht�vi� v�hennyksi� */

%ValtTuloVero&F (VALTVERO&suff, KOKO_VUOSI, INF, VALTVERTULO&suff);

%ElakeLisaVero&F(ELAKELISAVERO&suff, KOKO_VUOSI, INF, 12*ELAKYHT&suff, VALTELVAH&suff);

VALTVERO&suff = SUM(VALTVERO&suff, ELAKELISAVERO&suff);

/* 4.6.17 Ansiotulov�hennys/ty�tulov�hennys valtionverosta */

%ValtVerAnsVah&F (VALTANS&suff, KOKO_VUOSI, INF, 12*SUM(KOKO_PALKKA&suff, KOKO_SOVPALKKA&suff), PUHDANSIOTULO&suff);

/* 4.6.18 Lasketaan verot yhteens� ja v�hennet��n ansiotulov�hennys veroista. 
		  Jakoa eri verolajien kesken ei tehd�. Yksil�tasolla ei oteta huomioon alij��m�hyvityst� */

VARSVEROTYHT&suff = MAX(SUM(VALTVERO&suff, KUNNVERO&suff, KIRKVERO&suff, SAIRVAKM&suff, KANSELM&suff, - VALTANS&suff), 0);

VEROTYHT&suff = SUM(VARSVEROTYHT&suff, PALKVAK&suff);

/* 4.6.19 Yleisradiovero */

%YleVero&F (YLEVERO&suff, KOKO_VUOSI, INF, 50, PUHDANSIOTULO&suff, 0);

/* 4.6.20 Nettokuukausitulo verojen j�lkeen */

VEROTYHT&suff = SUM(VEROTYHT&suff, YLEVERO&suff);

NETTOTULO&suff = MAX(SUM(ANSIOTULO&suff, -VEROTYHT&suff), 0)/12;

/* 4.6.21 Verojen osuus tuloista */

VEROJENOSUUS&suff = VEROTYHT&suff / ANSIOTULO&suff * 100;

DROP taulua taulu_ke testi kuuid taulu_ot taulu_sv 
     kuuknro X w y z taulu_kt KOKO SISARIA taulu_tt ELAKELISAVERO&suff;  

RUN;

%loppu: 

%MEND KOKO_LASKENTA;

%KOKO_LASKENTA(0);
%KOKO_LASKENTA(1);


/* 5. Kotitaloustason laskenta */

/* Haetaan vuokranormiparametrit 2011 tasolla, jotta er��t taulukot syntyv�t
(ongelma, mik�li asumistukia ei ole ajettu mallilla aiemmin */
%HaeParam_VuokraNormit(2011);

%MACRO KOKO_LASKENTA_KOTIT;

DATA OUTPUT.&TULOSNIMI_KOKO;
SET OUTPUT.&TULOSNIMI_KOKO;

/* Nollataan muuttujia, joita ei v�ltt�m�tt� aina lasketa */
LAPSLIS = 0;
ASUMTUKI = 0;
ASUMLISAYHT = 0;
ELATTUKI = 0;
OIKELASUM = 0;
ELASUMTUKI = 0;
TOIMTUKI = 0;
PHMAKSUT = 0;

/* 5.1 Lapsilis�t ja elatustuki */

%IF &VUOSIKA = 2 %THEN %DO;
	%LLisaK&F (LAPSLIS, KOKO_VUOSI, KOKO_KUUK, INF, KOKO_PUOLISO, KOKO_LAPSIA_ALLE3, SUM(KOKO_LAPSIA_3_9, KOKO_LAPSIA_10_15), KOKO_LAPSIA_16);
%END;
%ELSE %DO;
	%LLisaV&F (LAPSLIS, KOKO_VUOSI, INF, KOKO_PUOLISO, KOKO_LAPSIA_ALLE3, SUM(KOKO_LAPSIA_3_9, KOKO_LAPSIA_10_15), KOKO_LAPSIA_16);
%END;

/* Lasten lukum��r� elatustukea (ja asumistukia) varten */

LAPSIAYHT = SUM(KOKO_LAPSIA_ALLE3, KOKO_LAPSIA_3_9, KOKO_LAPSIA_10_15, KOKO_LAPSIA_16, KOKO_LAPSIA_17);

/* Jos yksinhuoltaja, lasketaan elatustuki */

IF KOKO_PUOLISO = 0 AND LAPSIAYHT > 0 THEN DO;

	%IF &VUOSIKA = 2 %THEN %DO;
		%ElatTukiK&F (ELATTUKI, KOKO_VUOSI, KOKO_KUUK, INF, 0, LAPSIAYHT);
	%END;
	%ELSE %DO;
		%ElatTukiV&F (ELATTUKI, KOKO_VUOSI, INF, 0, LAPSIAYHT);
	%END;
END;

/* 5.2 Asuntolainan korkoihin perustuva alij��m�hvyitys lasketaan kotitaloustasolla.
       N�in v�hennyksen mahdollinen siirto ja optimointi puolisoiden kesken otetaan implisiittisesti huomioon */

/* 5.2.1 V�hennyskelpoiset korot (rajoitus vuodesta 2012 l�htien) */

%VahAsKorot&F (VAHKOROT, KOKO_VUOSI, 12*KOKO_ASKOROT);

/* 5.2.2 Lasten lukum��r� vaikuttaa alij��m�hyvityksen. Verotuksessa alle 17-vuotiaat lapset. */

VEROLAPS = SUM(KOKO_LAPSIA_ALLE3, KOKO_LAPSIA_3_9, KOKO_LAPSIA_10_15, KOKO_LAPSIA_16);
	
%AlijHyv&F(ALIJHYV, KOKO_VUOSI, INF, KOKO_PUOLISO, VEROLAPS, 0, 0, 12*KOKO_ASKOROT, 0, 0, 0);

/* 5.3 Muodostetaan kotitalouden verot ottamalla huomioon, ett� alij��m�hyvitys voidaan v�hent��
       vain 'varsinaisista' veroista. */

KOTITVARSVEROT = MAX(SUM(VARSVEROTYHT, VARSVEROTYHT_PUOL, -ALIJHYV), 0);

KOTITVEROTYHT = SUM(KOTITVARSVEROT, YLEVERO, YLEVERO_PUOL, PALKVAK, PALKVAK_PUOL);

/* 5.4 Lopullinen verotettu NETTOTULO kotitaloustasolla */

KOTITNETTOTULO = MAX(SUM(ANSIOTULO, ANSIOTULO_PUOL, -KOTITVEROTYHT), 0)/12;

/* 5.5 Laskettu opintotuen asumislis� otetaan puolisoilla huomioon vain jos kumpikin on opiskelija */

%IF &MINIMI_KOKO_PUOLISO = 1 AND %SUBSTR(&MINIMI_KOKO_TILANNE, 1, 1) = 5 AND %SUBSTR(&MINIMI_KOKO_TILANNE_PUOL, 1, 1) = 5 %THEN %DO;

	ASUMLISAYHT = SUM(ASUMLISA, ASUMLISA_PUOL);

%END;

%ELSE %IF &MINIMI_KOKO_PUOLISO = 0 %THEN %DO;
	
	ASUMLISAYHT = ASUMLISA;
	
%END;

%ELSE %DO;

	ASUMLISAYHT = 0;

%END;

/* 5.6 El�kkeensaajien asumistuki; lasketaan puolisoille vain, jos kumpikin saa el�ketuloa */

%IF (&MINIMI_KOKO_PUOLISO = 0 AND &MINIMI_KOKO_TILANNE = 6) OR (&MINIMI_KOKO_PUOLISO = 1 AND &MINIMI_KOKO_TILANNE = 6 AND &MINIMI_KOKO_TILANNE_PUOL = 6) %THEN %DO;

	OIKELASUM = 1;	
	
	%ElakAsumTuki&F (ELASUMTUKI, KOKO_VUOSI, INF, KOKO_PUOLISO, KOKO_PUOLISO, 0, 0, LAPSIAYHT, KOKO_OMAKOTI, 
		KOKO_LAMMRYHMA, 1, 1, 0, 0, KOKO_PINTALA, KOKO_VALMVUOSI, KOKO_ASKRYHMA, SUM(ANSIOTULO, ANSIOTULO_PUOL), 0, 12*KOKO_VUOKRA_VASTIKE, 12*KOKO_ASKOROT);

	ELASUMTUKI = ELASUMTUKI/12;

%END;


/* 5.7 Yleinen asumistuki; ehtona, ett� opintotuen asumislis� = 0 ja oikeutta el�kkeensaajien asumistukeen ole */

IF ASUMLISAYHT = 0 AND (OIKELASUM = 0 OR OIKELASUM = .) THEN DO;

	/* Kotitalouden henkil�iden lukum��r� */

	HENK = LAPSIAYHT + IFN(KOKO_PUOLISO, 2, 1);

	/* Asumistuen perusomavastuun laskemista  varten muodostettu tulo */
	/* Opintorahaa ei oteta huomioon */

	%TuloMuokkaus&F (ASUMTULO, KOKO_VUOSI, INF, LAPSIAYHT , HENK, 0, MAX(SUM(ANSIOTULO/12, ANSIOTULO_PUOL/12, -OPRAHA, -OPRAHA_PUOL), 0));

	/* Perusomavastuu */

	%PerusOmaVast&F (PERUSOM, KOKO_VUOSI, INF, KOKO_ASKRYHMA, HENK, ASUMTULO);

	%IF &MINIMI_KOKO_OMISTUS = 0 %THEN %DO;

		%AsumTukiVuok&F (ASUMTUKI, KOKO_VUOSI, INF, KOKO_ASKRYHMA, 1, 1, 1, HENK, 0, 
				KOKO_VALMVUOSI, KOKO_PINTALA, PERUSOM, KOKO_VUOKRA_VASTIKE, 0, 0);
	%END;

	%ELSE %DO;

		%AsumTukiOm&F (ASUMTUKI, KOKO_VUOSI, INF, KOKO_ASKRYHMA, KOKO_LAMMRYHMA, KOKO_OMAKOTI, 1, 1, HENK, 0, KOKO_VALMVUOSI, 
				KOKO_PINTALA, PERUSOM, KOKO_VUOKRA_VASTIKE, KOKO_VESI, 0, KOKO_ASKOROT, 0);
	%END;


END;

/* 5.8 P�iv�hoitomaksut */ 

/* Ehtona on, ett� kotitaloudessa on p�iv�hoitoik�isi� lapsia ja ett� henkil� on palkkaty�ss� (TILANNE = 1)
   tai opiskelija (TILANNE = 5) kun puolisoa ei ole tai kumpikin puoliso on palkkaty�ss� tai opiskelija.
   Lis�ksi perheess� on oltava alle kouluik�isi� lapsia. */

%IF (&MINIMI_KOKO_PUOLISO = 0 AND (&MINIMI_KOKO_TILANNE = 1 OR %SUBSTR(&MINIMI_KOKO_TILANNE, 1,1) = 5)) 
     OR (&MINIMI_KOKO_PUOLISO = 1 AND (&MINIMI_KOKO_TILANNE = 1 OR &MINIMI_KOKO_TILANNE = 5)
     AND (&MINIMI_KOKO_TILANNE_PUOL = 1 OR %SUBSTR(&MINIMI_KOKO_TILANNE_PUOL, 1, 1) = 5)) %THEN %DO;
	
	%IF %SYSFUNC(SUM(&MINIMI_KOKO_LAPSIA_ALLE3, &MINIMI_KOKO_LAPSIA_3_6)) > 0 %THEN %DO;

		PHTULO = SUM(ANSIOTULO/12, ANSIOTULO_PUOL/12, -OPRAHA, -OPRAHA_PUOL, ELATTUKI);

		%IF &VUOSIKA = 2 %THEN %DO;
			%SumPHoitoMaksu&F(PHMAKSUT, KOKO_VUOSI, KOKO_KUUK, INF, KOKO_PUOLISO, SUM(KOKO_LAPSIA_ALLE3, KOKO_LAPSIA_3_6),  
                      SUM(KOKO_LAPSIA_3_9, -KOKO_LAPSIA_3_6, KOKO_LAPSIA_10_15, KOKO_LAPSIA_16), PHTULO);
		%END; 
		%ELSE %DO;
			%SumPHoitoMaksuV&F(PHMAKSUT, KOKO_VUOSI, INF, KOKO_PUOLISO, SUM(KOKO_LAPSIA_ALLE3, KOKO_LAPSIA_3_6),  
                       SUM(KOKO_LAPSIA_3_9, -KOKO_LAPSIA_3_6, KOKO_LAPSIA_10_15, KOKO_LAPSIA_16), PHTULO);
		%END;
	%END;

%END;


/* 5.9 Toimeentulotuki, e/kk */

/* Lasketaan ty�tulojen osuus nettoansiotuloista.
   Sit� varten muut verot kuin palkansaajamaksut jaetaan tulojen suhteessa */

/* Ty�tulot, e/v */

TYOTULOT =  12*SUM(KOKO_PALKKA, KOKO_PALKKA_PUOL, KOKO_SOVPALKKA, KOKO_SOVPALKKA_PUOL);

/* Ty�tulojen osuus veronalaisista tuloista */

IF SUM(ANSIOTULO, ANSIOTULO_PUOL) > 0 THEN DO;

	TYO_OSUUS = TYOTULOT/SUM(ANSIOTULO, ANSIOTULO_PUOL);
END;
ELSE TYO_OSUUS = 0;

/* Ty�tulojen verot, e/v */

TYO_VEROT = TYO_OSUUS * SUM(KOTITVARSVEROT, YLEVERO, YLEVERO_PUOL);

/* Muiden tulojen verot, e/v */

MUUT_VEROT = (1 - TYO_OSUUS)* SUM(KOTITVARSVEROT, YLEVERO, YLEVERO_PUOL);

/* Nettoty�tulo: v�hennet��n my�s palkansaajan sotu-maksut, e/kk */

NETTOTYOTULO = MAX(SUM(TYOTULOT/12, -TYO_VEROT/12, -PALKVAK/12, -PALKVAK_PUOL/12), 0);

/* Muu nettotulo erotuksena, e/kk */

MUUNETTOTULO = MAX(SUM(KOTITNETTOTULO, -NETTOTYOTULO), 0);

/* Muita verottomia tuloja */

MUUSEKALTULO = SUM(ELATTUKI, ASUMTUKI, ASUMLISAYHT, ELASUMTUKI, OPLAINA, OPLAINA_PUOL, LAPSIKOR, LAPSIKOR_PUOL);

%IF &VUOSIKA = 2 %THEN %DO;
	%ToimTukiK&F (TOIMTUKI, KOKO_VUOSI, KOKO_KUUK, INF, KOKO_KELRYHMA, 1, IFN(KOKO_PUOLISO, 2, 1), 0, KOKO_LAPSIA_17,
		SUM(KOKO_LAPSIA_10_15, KOKO_LAPSIA_16), SUM(KOKO_LAPSIA_ALLE3, KOKO_LAPSIA_3_9), LAPSLIS, NETTOTYOTULO, SUM(MUUNETTOTULO, MUUSEKALTULO), SUM(KOKO_VUOKRA_VASTIKE, KOKO_VESI), PHMAKSUT);
%END;
%ELSE %DO;
	%ToimTukiV&F (TOIMTUKI, KOKO_VUOSI, INF, KOKO_KELRYHMA, 1, IFN(KOKO_PUOLISO, 2, 1), 0, KOKO_LAPSIA_17,
		SUM(KOKO_LAPSIA_10_15, KOKO_LAPSIA_16), SUM(KOKO_LAPSIA_ALLE3, KOKO_LAPSIA_3_9), LAPSLIS, NETTOTYOTULO, SUM(MUUNETTOTULO, MUUSEKALTULO), SUM(KOKO_VUOKRA_VASTIKE, KOKO_VESI), PHMAKSUT);
%END;

/* 5.10 Kotitalouden k�ytett�viss� oleva tulo, e/kk */

/* HUOM! T�m� ei sis�ll� opintolainaa eik� siit� v�hennet� p�iv�hoitomaksuja */

KAYT_TULO = SUM(NETTOTULO, NETTOTULO_PUOL, LAPSLIS, ELATTUKI, ASUMTUKI, ASUMLISAYHT, ELASUMTUKI, LAPSIKOR, LAPSIKOR_PUOL, TOIMTUKI);

DROP taulua X taulu_ya taulu_ea taulu_ke testi kuuid taulu_to taulu_ot taulu_ll taulu_sv taulu_ns taulu_vn 
     sarake kuuknro tunnus1-tunnus4 w y z povnimi1-povnimi4 taulu_pov1-taulu_pov4 taulu_kt lapsia KOKO taulu_tt 
	 VEROLAPS vahlapsia alijenimm kulkorotx HENK SISARIA YHTLAPSIATTURVA YHTLAPSIATTURVA_PUOL 
     YHTLAPSIASAIRVAK YHTLAPSIASAIRVAK_PUOL ELLAPSIA VUOKRA;  

RUN;

%MEND KOKO_LASKENTA_KOTIT;

%KOKO_LASKENTA_KOTIT;

/* 6. Lasketaan marginaaliveroasteet */

%MACRO Koko_Simuloi_MargVero;

/* 6.1 Otetaan talteen alkuper�iset tulokset ja nimet��n 
       laskennassa tarvittavat tulo- ja verotiedot uudelleen */

DATA TEMP.KOKO_ESIM_MARGVERO ;
SET OUTPUT.&TULOSNIMI_KOKO;
VEROT = VEROTYHT;
KTU = KAYT_TULO;
RUN;

/* 6.2 Simuloidaan malli uudestaan lis��m�ll� palkkatuloihin askeleen mukainen palkanlis� */

%Generoi_Muuttujat;

DATA OUTPUT.&TULOSNIMI_KOKO;
SET OUTPUT.&TULOSNIMI_KOKO;
KOKO_PALKKA = SUM(KOKO_PALKKA, KOKO_ASKEL);
RUN;

%KOKO_LASKENTA(0);
%KOKO_LASKENTA_KOTIT;

/* 6.3 Otetaan talteen uudelleen simuloidut tulokset ja nimet��n 
       laskennassa tarvittavat tulo- ja verotiedot uudelleen */

DATA OUTPUT.&TULOSNIMI_KOKO;
SET OUTPUT.&TULOSNIMI_KOKO;
VEROT2 = VEROTYHT;
KTU2 = KAYT_TULO;
KEEP VEROT2 KTU2;
RUN;

/* 6.4 Lasketaan marginaaliveroaste ja efektiivinen marginaaliveroaste */

DATA OUTPUT.&TULOSNIMI_KOKO;
MERGE OUTPUT.&TULOSNIMI_KOKO  TEMP.KOKO_ESIM_MARGVERO ;
MARGIVERO = 100 * SUM(VEROT2, -VEROT) / (12 * KOKO_ASKEL); /* HUOM! KOKO-mallissa palkka on kuukausitasolla, jonka vuoksi my�s askel on kerrottava 12:sta */
EFMARGIVERO = 100 * (1 - (SUM(KTU2, -KTU) / KOKO_ASKEL));

DROP VEROT VEROT2 KTU2 KTU;

/* 6.5 M��ritell��n muuttujille selkokieliset selitteet */

LABEL 
KOKO_VUOSI = 'Lains��d�nt�vuosi'
KOKO_KUUK = 'Lains��d�nt�kuukausi'
KOKO_PUOLISO = 'Onko puolisoa (0/1)'
KOKO_LAPSIA_ALLE3 = 'Alle 3-vuotiaiden lasten lukum��r�'
KOKO_LAPSIA_3_6 = '3-6-vuotiaiden lasten lukum��r�'
KOKO_LAPSIA_3_9 = '3-9-vuotiaiden lasten lukum��r�'
KOKO_LAPSIA_10_15 = '10-15-vuotiaiden lasten lukum��r�'
KOKO_LAPSIA_16 = '16-vuotiaiden lasten lukum��r�'
KOKO_LAPSIA_17 = '17-vuotiaiden lasten lukum��r�'
LAPSIAYHT = 'Lasten (alle 18-v.) lukum��r� kotitaloudessa'
KOKO_IKA = 'Henkil�n ik�'
KOKO_IKA_PUOL = 'Puolison ik�'
KOKO_ASKRYHMA = 'Asumistuen kuntaryhm�'
KOKO_KELRYHMA = 'Kalleusluokka'
KOKO_LAMMRYHMA = 'Yleisen ja el�kkeensaajien asumistuen l�mmitysryhm�'
KOKO_KUNNVERO = 'Kunnallisveroprosentti (999=keskim. veropros.)'
KOKO_KIRKVERO = 'Kirkollisveroprosentti (999=keskim. veropros.)'
KOKO_VALMVUOSI = 'Asunnon valmistumis- tai perusparannusvuosi'
KOKO_PINTALA = 'Asunnon pinta-ala, m2'
KOKO_OMISTUS = 'Omistusasunto (0/1)'
KOKO_OMAKOTI = 'Omakotitalo (0/1)'
KOKO_VUOKRA_VASTIKE = 'Vuokra tai yhti�vasike (e/kk)'
KOKO_VESI = 'Vesimaksu (e/kk)'
KOKO_ASKOROT = 'Asuntolainan korot (e/kk)'
KOKO_TILANNE = 'Henkil�n status'
KOKO_TILANNE_PUOL = 'Puolison status'
KOKO_KOROTUS = 'Ty�tt�myysturvan korotusosa (0/1)'
KOKO_MTURVA = 'Ty�tt�myysturvan muutostuvalis� / ty�llist�misohjelmalis� (0/1)'
KOKO_PALKKA = 'Palkkatulo (e/kk)'
KOKO_ASKEL = 'Tuloaskel, jolla tuloa korotetaan marginaaliveroastetta laskettaessa, e/kk'
KOKO_VAKPALKKA = 'Vakuutuspalkka (e/kk)'
KOKO_TULONHANKKULUT = 'Tulonhankkimiskulut, (e/kk)'
KOKO_AYMAKSUT = 'Ay-j�senmaksut, (e/kk)'
KOKO_TYOMATKAKULUT = 'Ty�matkakulut, (e/kk)'
KOKO_ELAKE = 'Ansioel�ke (e/kk)'
KOKO_SOVPALKKA = 'Soviteltava palkka tai opinto-/el�kekuukausien aikana saatu palkka (e/kk)'

KOKO_PALKKA_PUOL = 'Puolison palkkatulo (e/kk)'
KOKO_VAKPALKKA_PUOL = 'Puolison vakuutuspalkka (e/kk)'
KOKO_TULONHANKKULUT_PUOL = 'Puolison tulonhankkimiskulut, (e/kk)'
KOKO_AYMAKSUT_PUOL = 'Puoliston ay-j�senmaksut, (e/kk)'
KOKO_TYOMATKAKULUT_PUOL = 'Puolison ty�matkakulut, (e/kk)'
KOKO_SOVPALKKA_PUOL = 'Puolison soviteltava palkka tai opinto-/el�kekuukausien aikana saatu palkka (e/kk)'
KOKO_ELAKE_PUOL = 'Puolison ansioel�ke (e/kk)'

INF = 'Inflaatiokorjauksessa k�ytett�v� kerroin'

TYOTPR = 'Ty�tt�myysp�iv�rahat (e/kk)'
TYOTPR_PUOL = 'Puoliso: Ty�tt�myysp�iv�rahat (e/kk)'
TULO = 'Sairausvakuutuksen p�iv�rahan perusteena oleva tulo (e/kk)'
TULO_PUOL = 'Puoliso: Sairausvakuutuksen p�iv�rahan perusteena oleva tulo (e/kk)'
SAIRPR = 'Sairausvakuutuksen p�iv�rahat (e/kk)'
SAIRPR_PUOL = 'Puoliso: Sairausvakuutuksen p�iv�rahat (e/kk)'
KOTIHTULOT = 'Kotihoidon tuen perusteena olevat kotitalouden tulot (e/kk)' 
KOTIHTU = 'Kotihoidon tuki (e/kk)'
KOTIHTU_PUOL = 'Puoliso: Kotihoidon tuki (e/kk)'
OPRAHA = 'Opintoraha (e/kk)'
OPRAHA_PUOL = 'Puoliso: Opintoraha (e/kk)'
TAKAISIN = 'Opintorahan takaisinperint� (e/v)'
TAKAISIN_PUOL = 'Puoliso: Opintorahan takaisinperint� (e/v)'
TAKAISIN_AL = 'Opintotuen asumislis�n takaisinperint� (e/v)'
TAKAISIN_AL_PUOL = 'Puoliso: Opintotuen asumislis�n takaisinperint� (e/v)'
OPLAINA = 'Opintolaina (e/kk)'
OPLAINA_PUOL = 'Puoliso: Opintolaina (e/kk)'
ASUMLISA = 'Opintotuen asumislis� (e/kk)'
ASUMLISA_PUOL = 'Puoliso: Opintotuen asumislis� (e/kk)'
KANSEL = 'Kansanel�ke (e/kk)'
KANSEL_PUOL = 'Puoliso: Kansanel�ke (e/kk)'
TAKUUEL = 'Takuuel�ke (e/kk)'
TAKUUEL_PUOL = 'Puoliso: Takuuel�ke (e/kk)'
ELAKYHT = 'Ansioel�ke, kansanel�ke ja takuuel�ke yhteens� (e/kk)'
ELAKYHT_PUOL = 'Puoliso: Ansioel�ke, kansanel�ke ja takuuel�ke yhteens� (e/kk)'
LAPSIKOR = 'El�kkeensaajan lapsikorotukset (e/kk)'
LAPSIKOR_PUOL = 'Puoliso: El�kkeensaajan lapsikorotukset (e/kk)'

TYOEL = 'Palkansaajan ty�el�kemaksu (e/v)'
TYOEL_PUOL = 'Puoliso: Palkansaajan ty�el�kemaksu (e/v)'
TYOTMAKSU = 'Palkansaajan ty�tt�myysvakuutusmaksu (e/v)'
TYOTMAKSU_PUOL = 'Puoliso: Palkansaajan ty�tt�myysvakuutusmaksu (e/v)'
SVPRMAKSU = 'Sairausvakuutuksen p�iv�rahamaksu (e/v)'
SVPRMAKSU_PUOL = 'Puoliso: Sairausvakuutuksen p�iv�rahamaksu (e/v)'
PALKVAK = 'Palkansaajan el�ke-, ty�tt�myysvakuutusmaksu ja sairausvakuutuksen p�iv�rahamaksu yhteens� (e/v)'
PALKVAK_PUOL = 'Puoliso: Palkansaajan el�ke-, ty�tt�myysvakuutusmaksu ja sairausvakuutuksen p�iv�rahamaksu yhteens� (e/v)'
HANKVAH = 'Tulonhankkimisv�hennys (e/v)'
HANKVAH_PUOL = 'Puoliso: Tulonhankkimisv�hennys (e/v)'
ANSIOTULO = 'Ansiotulot yhteens� (e/v)'
ANSIOTULO_PUOL = 'Puoliso: Ansiotulot yhteens� (e/v)'
PUHDANSIOTULO = 'Puhdas ansiotulo (e/v)'
PUHDANSIOTULO_PUOL = 'Puoliso: Puhdas ansiotulo (e/v)'
KUNNANS = 'Kunnallisverotuksen ansiotulov�hennys (e/v)'
KUNNANS_PUOL = 'Puoliso: Kunnallisverotuksen ansiotulov�hennys (e/v)'
OPRAHVAH = 'Opintorahav�hennys (e/v)'
OPRAHVAH_PUOL = 'Puoliso: Opintorahav�hennys (e/v)'
KUNNELVAH = 'Kunnallisverotuksen el�ketulov�hennys (e/v)'
KUNNELVAH_PUOL = 'Puoliso: Kunnallisverotuksen el�ketulov�hennys (e/v)'
KUNNVERTULO1 = 'Kunnalliverotuksessa verotettava tulo ennen perusv�hennyst� (e/v)'
KUNNVERTULO1_PUOL = 'Puoliso: Kunnalliverotuksessa verotettava tulo ennen perusv�hennyst� (e/v)'
KUNNPER = 'Kunnallisverotuksen perusv�hennys (e/v)'
KUNNPER_PUOL = 'Puoliso: Kunnallisverotuksen perusv�hennys (e/v)'
KUNNVERTULO2 = 'Kunnallisverotuksessa verotettava tulo (e/v)'
KUNNVERTULO2_PUOL = 'Puoliso: Kunnallisverotuksessa verotettava tulo (e/v)'
KUNNVERO = 'Kunnallisvero (e/v)'
KUNNVERO_PUOL = 'Puoliso: Kunnallisvero (e/v)' 
KIRKVERO = 'Kirkollisvero (e/v)'
KIRKVERO_PUOL = 'Puoliso: Kirkollisvero (e/v)'
SAIRVAKM = 'Sairaanhoitomaksu/sairausvakuutusmaksu (e/v)'
SAIRVAKM_PUOL = 'Puoliso: Sairaanhoitomaksu/sairausvakuutusmaksu (e/v)'
KANSELM = 'Kansanel�kevakuutusmaksu (e/v)'
KANSELM_PUOL = 'Puoliso: Kansanel�kevakuutusmaksu (e/v)'
VALTELVAH = 'Valtionverotuksen el�ketulov�hennys (e/v)'
VALTELVAH_PUOL = 'Puoliso: Valtionverotuksen el�ketulov�hennys (e/v)'
VALTVERTULO = 'Valtionverotuksessa verotettava tulo (e/v)'
VALTVERTULO_PUOL = 'Puoliso: Valtionverotuksessa verotettava tulo (e/v)'
VALTVERO = 'Valtionvero ennen verosta teht�vi� v�hennyksi� (e/v)'
VALTVERO_PUOL = 'Puoliso: Valtionvero ennen verosta teht�vi� v�hennyksi� (e/v)'
VALTANS = 'Ansiotulov�hennys/ty�tulov�hennys valtionverosta (e/v)'
VALTANS_PUOL = 'Puoliso: Ansiotulov�hennys/ty�tulov�hennys valtionverosta (e/v)'
VARSVEROTYHT = 'Verot yhteens� ansiotulov�hennyksen j�lkeen (e/v)'
VARSVEROTYHT_PUOL = 'Puoliso: Verot yhteens� ansiotulov�hennyksen j�lkeen (e/v)'
YLEVERO = 'YLE-vero (e/v)'
YLEVERO_PUOL = 'Puoliso: YLE-vero (e/v)'
VEROTYHT = 'Verot ja veroluontoiset maksut yhteens� (e/v)'
VEROTYHT_PUOL = 'Puoliso: Verot ja veroluontoiset maksut yhteens� (e/v)'
NETTOTULO = 'Nettotulo verojen j�lkeen (e/kk)'
NETTOTULO_PUOL = 'Puoliso: Nettotulo verojen j�lkeen (e/kk)'
VEROJENOSUUS = 'Verojen osuus tuloista, %'
VEROJENOSUUS_PUOL = 'Puoliso: Verojen osuus tuloista, %'

LAPSLIS = 'Kotitalous: Lapsilis�t (e/kk)'
ELATTUKI ='Kotitalous: Elatustuki (e/kk)'
VAHKOROT = 'Kotitalous: V�hennyskelpoiset korot (e/v)'
ALIJHYV = 'Kotitalous: Alij��m�hyvitys (e/v)'
KOTITVARSVEROT = 'Kotitalous: Verot yhteens� ansiotulov�hennyksen ja alij��m�hyvityksen j�lkeen (e/v)'
KOTITVEROTYHT = 'Kotitalous: Verot ja veroluontoiset maksut yhteens� (e/v)'
KOTITNETTOTULO = 'Kotitalous: Verotettu nettotulo (e/kk)'
ASUMLISAYHT = 'Kotitalous: Opintotuen asumislis� (e/kk)'
OIKELASUM = 'Kotitalous: Oikeus el�kkeensaajien asumistukeen (0/1)' 
ELASUMTUKI = 'Kotitalous: El�kkeensaajien asumistuki (e/kk)'
ASUMTULO = 'Kotitalous: Yleisen asumistuen perusomavastuun laskemista varten muodostettu tulo (e/kk)'
PERUSOM = 'Kotitalous: Yleisen asumistuen perusomavastuu (e/kk)'
ASUMTUKI = 'Kotitalous: Yleinen asumistuki (e/kk)'
PHTULO = 'Kotitalous: P�iv�hoitomaksujen perusteena oleva tulo (e/kk)'
PHMAKSUT = 'Kotitalous: P�iv�hoitomaksut (e/kk)'
TYOTULOT = 'Kotitalous: Tyotulot toimeentulotuessa (e/v)'
TYO_OSUUS = 'Kotitalous: Ty�tulojen osuus veronalaisista tuloista toimeentulotuessa'
TYO_VEROT = 'Kotitalous: Ty�tulojen verot toimeentulotuessa (e/v)'
MUUT_VEROT = 'Kotitalous: Muiden tulojen verot toimeentulotuessa (e/v)'
NETTOTYOTULO = 'Kotitalous: Nettoty�tulo toimeentulotuessa (e/kk)'
MUUNETTOTULO = 'Kotitalous: Muu nettotulo toimeentulotuessa (e/kk)'
MUUSEKALTULO = 'Kotitalous: Muut verottomat tulot toimeentulotuessa (e/kk)'
TOIMTUKI = 'Kotitalous: Toimeentulotuki (e/kk)'
KAYT_TULO = 'Kotitalous: K�ytett�viss� oleva tulo (e/kk)'

MARGIVERO = 'Marginaaliveroaste, %'
EFMARGIVERO = 'Kotitalous: Efektiivinen marginaaliveroaste, %'
;

KEEP KOKO_VAKPALKKA KOKO_VAKPALKKA_PUOL &VALITUT;
%IF &VUOSIKA NE 2 %THEN %DO;
	DROP KOKO_KUUK;
%END;

RUN;

%IF &EXCEL = 1 %THEN %DO;
	ODS HTML3 BODY = "&LEVY&KENO&HAKEM&KENO.TULOS&KENO.OUTPUT&KENO&TULOSNIMI_KOKO..xls" STYLE = MINIMAL;
%END;

PROC PRINT NOOBS LABEL DATA = OUTPUT.&TULOSNIMI_KOKO;
TITLE "ESIMERKKILASKELMA, KOKO";
RUN;

%IF &EXCEL = 1 %THEN %DO;
	ODS HTML3 CLOSE;
%END;

%MEND Koko_Simuloi_MargVero;

%Koko_Simuloi_MargVero;
