/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hy�dynt�� Tilastokeskuksen yleisten
* k�ytt�ehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto p��hakemistossa.
******************************************************************************/

/***********************************************************************
* Kuvaus: Kiinteist�veron lains��d�nt�� makroina 					   *
* Tekij�: Anne Per�lahti / TK		                		   		   *
* Luotu: 29.5.2012				       					   			   *
* Viimeksi p�ivitetty: 23.10.2012	     		       			       *
* P�ivitt�j�: Anne Per�lahti / TK			   					       *
************************************************************************/ 


/* 1. SIS�LLYS */

/* Tiedosto sis�lt�� seuraavat makrot */

/*
2.  PtVerotusArvoS	= Pientalon verotusarvo
3.  VapVerotusArvoS	= Vapaa-ajan asunnon verotusarvo
4.  KiVeroPtS		= Pientalon kiinteist�vero
5.  KiVeroVapS		= Vapaa-ajan asunnon kiinteist�vero
*/


/* 2. Pientalon verotusarvo */

*Makron parametrit:
    tulos: 			Makron tulosmuuttuja, Pientalon verotusarvo
	mvuosi: 		Vuosi, jonka lains��d�nt�� k�ytet��n
	minf: 			Deflaattori eurom��r�isten parametrien kertomiseksi 
	raktyyppi: 		Rakennustyyppi (1=pientalo)
	valmvuosi: 		Rakennuksen valmistumisvuosi
	ikavuosi:		Rakentamisvuodesta poikkeava ik�alennuksen alkamisvuosi
	kantarakenne:	Kantava rakenne (1=puu, 2=kivi)
	rakennuspa:		Rakennuksen pinta-ala, m2
	kellaripa:		Pientalon viimeistelem�tt�m�n kellarin pinta-ala, m2
	vesik:			Vesijohtotieto (0=ei, 1=kyll�)
	lammitysk:		L�mmityskoodi (1=keskusl�mmitys, 2=ei keskusl�mmityst�, 3=s�hk�l�mmitys)
	sahkok:			S�hk�koodi (0=ei, 1=kyll�)
	jhvalarvokoodi:	J�lleenhankinta-arvon valmiskoodi (1 = laskettu, 2 = annettu valmisarvona verovuodeksi, 3 = annettu valmisarvona pysyv�sti);

%MACRO PtVerotusArvoS(tulos, mvuosi, minf, raktyyppi, valmvuosi, ikavuosi, kantarakenne, rakennuspa, kellaripa, vesik, lammitysk, sahkok, jhvalarvokoodi)/STORE 
DES = 'KIVERO: Pientalon verotusarvo';

%HaeParam_KiVeroESIM(&mvuosi, &minf);

IF &raktyyppi = 1 THEN DO;

	/* Rakennuksen pinta-alasta erotetaan kellarin pinta-ala */

	asuinpa = &rakennuspa - &kellaripa;
	IF &rakennuspa LT &kellaripa THEN asuinpa = &rakennuspa;

	/* Ensimm�iseksi lasketaan pientalon perusarvo */

	IF &kantarakenne = 1 AND &valmvuosi LT 1960 THEN ptperarvo = &PtPuuVanh;
	ELSE IF &kantarakenne = 1 AND (1960 LE &valmvuosi LT 1970) THEN ptperarvo = &PtPuuUusi;
	ELSE ptperarvo = &PtPerusArvo;

		/* Silloin kun valmistumisvuosi puuttuu, perusarvoksi annetaan korkein perusarvo */
	IF &valmvuosi = 0 THEN ptperarvo = &PtPerusArvo;

	/* Toiseksi lasketaan vesijohdon/viem�rin, keskusl�mmityksen ja s�hk�n 
	   puuttumisesta ja rakennuksen koosta teht�v�t perusarvon v�hennykset */

	IF &vesik = 0 THEN vahvesi = &PtEiVesi;
	IF &vesik = 1 THEN vahvesi = 0;

	IF &lammitysk GT 1 THEN vahkesk = &PtEiKesk;
	IF &lammitysk = 1 THEN vahkesk = 0;

	IF &sahkok = 0 THEN vahsahko = &PtEiSahko;
	IF &sahkok = 1 THEN vahsahko = 0;

	IF &PtNelioRaja1 LT &rakennuspa LE &PtNelioRaja2 THEN DO;
	vahpapala = (&rakennuspa - &PtNelioRaja1);
	vahpap = vahpapala * &PtVahPieni;
	END;

	IF &rakennuspa GT &PtNelioRaja2 THEN vahpas = &PtVahSuuri;

	/* Kolmanneksi lasketaan j�lleenhankinta-arvo v�hent�m�ll� perusarvosta ed. v�hennykset
	ja lis�t��n j�lleenhankinta-arvoon viimeistelem�tt�m�n kellarin arvo*/

	vahsum = SUM(vahvesi, vahkesk, vahsahko, vahpap, vahpas);

	pthankarvoala = SUM(ptperarvo, -vahsum);

	kelparvo = &kellaripa * &KellArvo;

	pthankarvo = pthankarvoala * asuinpa + kelparvo;

	/* Nelj�nneksi lasketaan verotusarvo v�hent�m�ll� j�lleenhankinta-arvosta ik�alennukset */
		/* Lasketaan rakennuksen korjattu ik� */

	IF &ikavuosi GT &valmvuosi THEN korjvuosi = &ikavuosi;
	ELSE IF &valmvuosi GE &ikavuosi THEN korjvuosi = &valmvuosi;
	IF korjvuosi GE &mvuosi THEN korjvuosi = &valmvuosi;
	IF &ikavuosi = 0 AND &valmvuosi = 0 THEN korjvuosi = 0; 

	rakika = (&mvuosi - korjvuosi + 1);
	IF korjvuosi = 0 THEN rakika = 0;

		/* Lasketaan ik�v�hennykset puu- ja kivirakenteisille rakennuksille */

	IF &kantarakenne = 1 THEN ikavahpt = &IkaAlePuu / 100 * rakika;
	
	IF &kantarakenne = 2 THEN ikavahpt = &IkaAleKivi / 100 * rakika;
	
	IF ikavahpt GE (1 - &IkaVahRaja) THEN ikavahpt2 = &IkaVahRaja;
	IF ikavahpt LT (1 - &IkaVahRaja) THEN ikavahpt2 = 1 - ikavahpt;

	/* Keskener�isen rakennuksen valmiusastetta ei tiedet�. Vuonna 2010 keskener�isten rakennusten valmiusaste oli keskim��rin 
	62 prosenttia, jota k�ytet��n my�s t�ss� laskennassa. */ 

	IF korjvuosi GT &mvuosi THEN valmaste = 0.62;

	/* Lopuksi lasketaan verotusarvo */

	IF korjvuosi GT &mvuosi THEN temp = (valmaste * pthankarvo);
	IF &jhvalarvokoodi > 1 then temp = valopullinen;
	ELSE temp = pthankarvo * ikavahpt2;

END;

&tulos = temp;

DROP asuinpa ptperarvo vahvesi vahkesk vahsahko vahpapala vahpap vahpas vahsum pthankarvoala kelparvo pthankarvo 
korjvuosi rakika ikavahpt ikavahpt2 valmaste temp;
%MEND PtVerotusArvoS;


/* 3. Vapaa-ajan asunnon verotusarvo */

*Makron parametrit:
    tulos: 			Makron tulosmuuttuja, Vapaa-ajan asunnon verotusarvo
	mvuosi: 		Vuosi, jonka lains��d�nt�� k�ytet��n
	minf: 			Deflaattori eurom��r�isten parametrien kertomiseksi 
	raktyyppi: 		Rakennustyyppi (7=vapaa-ajan asunto)
	valmvuosi: 		Rakennuksen valmistumisvuosi
	ikavuosi:		Rakentamisvuodesta poikkeava ik�alennuksen alkamisvuosi
	kantarakenne:	Kantava rakenne (1=puu, 2=kivi)
	rakennuspa:		Rakennuksen pinta-ala, m2
	talviask:		Vapaa-ajan asunnon talviasuttavuus (0=ei, 1=kyll�)
	sahkok:			S�hk�koodi (0=ei, 1=kyll�)
	viemarik:		Viem�ritieto (0=ei, 1=kyll�)
	vesik:			Vesijohtotieto (0=ei, 1=kyll�)
	wck:			Vapaa-ajan asunnon wc-tieto (0 = ei, 1=kyll�)
	saunak:			Vapaa-ajan asunnon saunatieto (0=ei, 1=kyll�)
	jhvalarvokoodi:	J�lleenhankinta-arvon valmiskoodi (1 = laskettu, 2 = annettu valmisarvona verovuodeksi, 3 = annettu valmisarvona pysyv�sti);

%MACRO VapVerotusArvoS(tulos, mvuosi, minf, raktyyppi, valmvuosi, ikavuosi, kantarakenne, rakennuspa, 
talviask, sahkok, viemarik, vesik, wck, saunak, jhvalarvokoodi)/STORE  
DES = 'KIVERO: Vapaa-ajan asunnon verotusarvo';

%HaeParam_KiVeroESIM(&mvuosi, &minf);

IF &raktyyppi = 7 THEN DO;

	/* Ensimm�iseksi lasketaan vapaa-ajan asunnon perusarvo */

	vapperarvo = &VapPerusArvo * &rakennuspa;

	/*Toiseksi lasketaan vapaa-ajan asunnon lis�arvo talviasuttavuudesta, s�hk�st�, viem�rist�, 
	  vesijohdosta, WC:st� ja saunasta sek� rakennuksen koosta teht�v�t v�hennykset */

	/* HUOM! EI VOIDA LASKEA LIS�ARVOA KUISTISTA, KOSKA AINEISTOSSA EI OLE TARVITTAVAA TIETOA */

	IF (&VapNelioRaja1 LT &rakennuspa LE &VapNelioRaja2) THEN DO;
		vahvraja = &rakennuspa - &VapNelioRaja1;
		vahvpap = vahvraja * &VapVahPieni * &rakennuspa;
	END;

	IF &rakennuspa GT &VapNelioRaja2 THEN vahvpas = &rakennuspa * &VapVahSuuri;

	IF &talviask = 1 THEN listalvi = &rakennuspa * &VapLisTalvi;
	ELSE listalvi = 0;
	
	IF &sahkok = 1 THEN lissahko = &VapLisSahko1 + (&rakennuspa * &VapLisSahko2);
	ELSE lissahko = 0;

	IF &viemarik = 1 THEN lisviem = &VapLisViem;
	ELSE lisviem = 0;

	IF &vesik = 1 THEN lisvesi = &VapLisVesi;
	ELSE lisvesi = 0;

	IF &wck = 1 THEN liswc = &VapLisWC;
	ELSE liswc = 0;

	IF &saunak = 1 THEN lissauna = &VapLisSauna;
	ELSE lissauna = 0;

	/* Kolmanneksi lasketaan j�lleenhankinta-arvo v�hent�m�ll� perusarvosta ed. lis�ykset ja v�hennykset */

	lissum = SUM(listalvi, lissahko, lisviem, lisvesi, liswc, lissauna);
	vaphankarvo = SUM(vapperarvo, -vahvpap, -vahvpas, lissum);

	/* Nelj�nneksi lasketaan verotusarvo v�hent�m�ll� j�lleenhankinta-arvosta ik�alennukset */
	/* Lasketaan rakennuksen korjattu ik� */

	IF &ikavuosi GT &valmvuosi THEN korjvuosi = &ikavuosi;
	ELSE IF &valmvuosi GE &ikavuosi THEN korjvuosi = &valmvuosi;
	IF korjvuosi GE &mvuosi THEN korjvuosi = &valmvuosi;
	IF &ikavuosi = 0 AND &valmvuosi = 0 THEN korjvuosi = 0; 

	rakika = (&mvuosi - korjvuosi + 1);
	IF korjvuosi = 0 THEN rakika = 0;

	/* Lasketaan ik�v�hennykset puu- ja kivirakenteisille rakennuksille */

	IF &kantarakenne = 1 THEN DO;
		ikavahvap = (&IkaAlePuu / 100) * rakika;
	END;

	IF &kantarakenne = 2 THEN DO;
		ikavahvap = (&IkaAleKivi / 100) * rakika;
	END;

	IF ikavahvap GE (1 - &IkaVahRaja) THEN ikavahvap2 = &IkaVahRaja;
	IF ikavahvap LT (1 - &IkaVahRaja) THEN ikavahvap2 = (1 - ikavahvap);

	/* UUSI KOODI! Keskener�isen rakennuksen valmiusasteesta ei ole tietoa. Vuonna 2010 keskener�isten rakennusten valmiusaste oli keskim��rin 
	56 prosenttia, jota k�ytet��n t�ss� laskennassa. */ 

	IF korjvuosi GT &mvuosi THEN valmaste = 0.56;

	/* Lopuksi lasketaan verotusarvo */

	IF korjvuosi GT &mvuosi THEN temp = (valmaste * vaphankarvo);
	IF &jhvalarvokoodi > 1 then temp = valopullinen;
	ELSE temp = vaphankarvo * ikavahvap2;

END;

ELSE temp = 0;

&tulos = temp;

DROP vapperarvo vahvraja vahvpap vahvpas listalvi lissahko lisviem lisvesi liswc lissauna lissum vaphankarvo 
korjvuosi rakika ikavahvap ikavahvap2 valmaste temp;
%MEND VapVerotusArvoS;


/* 4. Kiinteist�vero pientalosta */

*Makron parametrit:
    tulos: 			Makron tulosmuuttuja, Kiinteist�vero pientalosta
	mvuosi: 		Vuosi, jonka lains��d�nt�� k�ytet��n
	minf: 			Deflaattori eurom��r�isten parametrien kertomiseksi 
	raktyyppi: 		Rakennustyyppi
	valmvuosi: 		Rakennuksen valmistumisvuosi
	ikavuosi:		Rakentamisvuodesta poikkeava ik�alennuksen alkamisvuosi
	kantarakenne:	Kantava rakenne (1=puu, 2=kivi)
	rakennuspa:		Rakennuksen pinta-ala, m2
	kellaripa:		Pientalon viimeistelem�tt�m�n kellarin pinta-ala, m2
	vesik:			Vesijohtotieto (0=ei, 1=kyll�)
	lammitysk:		L�mmityskoodi (1=keskusl�mmitys, 2=ei keskusl�mmityst�, 3=s�hk�l�mmitys)
	sahkok:			S�hk�koodi (0=ei, 1=kyll�)
	jhvalarvokoodi:	J�lleenhankinta-arvon valmiskoodi (1 = laskettu, 2 = annettu valmisarvona verovuodeksi, 3 = annettu valmisarvona pysyv�sti)
	veropros:		Rakennukselle m��r�tty kiinteist�veroprosentti;

%MACRO KiVeroPtS(tulos, mvuosi, minf, raktyyppi, valmvuosi, ikavuosi, kantarakenne, rakennuspa, 
kellaripa, vesik, lammitysk, sahkok, jhvalarvokoodi, veropros)/STORE
DES = 'KIVERO: Kiinteist�vero pientalosta';

%HaeParam_KiVeroESIM(&mvuosi, &minf);

%PtVerotusArvoS(ptvarvo, &mvuosi, &minf, &raktyyppi, &valmvuosi, &ikavuosi, &kantarakenne, &rakennuspa, 
&kellaripa, &vesik, &lammitysk, &sahkok, &jhvalarvokoodi);

IF &raktyyppi = 1 THEN DO;

	temp = ptvarvo * (&veropros / 100);

END;

ELSE temp = 0;

&tulos = temp;

DROP temp ptvarvo;
%MEND KiVeroPtS;


/* 5. Vapaa-ajan asunnon kiinteist�vero */

*Makron parametrit:
    tulos: 			Makron tulosmuuttuja, Kiinteist�vero vapaa-ajan asunnosta
	mvuosi: 		Vuosi, jonka lains��d�nt�� k�ytet��n
	minf: 			Deflaattori eurom��r�isten parametrien kertomiseksi 
	raktyyppi: 		Rakennustyyppi
	valmvuosi: 		Rakennuksen valmistumisvuosi
	ikavuosi:		Laskentavuosi. Rakentamisvuodesta poikkeava ik�alennuksen alkamisvuosi
	kantarakenne:	Kantava rakenne (1=puu, 2=kivi)
	rakennuspa:		Rakennuksen pinta-ala, m2
	talviask:		Vapaa-ajan asunnon talviasuttavuus (0=ei, 1=kyll�)
	sahkok:			S�hk�koodi (0=ei, 1=kyll�)
	viemarik:		Viem�ritieto (0=ei, 1=kyll�)
	vesik:			Vesijohtotieto (0=ei, 1=kyll�)
	wck:			Vapaa-ajan asunnon wc-tieto (0 = ei, 1=kyll�)
	saunak:			Vapaa-ajan asunnon saunatieto (0=ei, 1=kyll�)
	jhvalarvokoodi:	J�lleenhankinta-arvon valmiskoodi (1 = laskettu, 2 = annettu valmisarvona verovuodeksi, 3 = annettu valmisarvona pysyv�sti)
	veropros:		Rakennukselle m��r�tty kiinteist�veroprosentti;

%MACRO KiVeroVapS(tulos, mvuosi, minf, raktyyppi, valmvuosi, ikavuosi, kantarakenne, rakennuspa, talviask, sahkok, 
viemarik, vesik, wck, saunak, jhvalarvokoodi, veropros)/STORE 
DES = 'KIVERO: Vapaa-ajan asunnon kiinteist�vero';

%HaeParam_KiVeroESIM(&mvuosi, &minf);

%VapVerotusArvoS(vapvarvo, &mvuosi, &minf, &raktyyppi, &valmvuosi, &ikavuosi, &kantarakenne, &rakennuspa, 
&talviask, &sahkok, &viemarik, &vesik, &wck, &saunak, &jhvalarvokoodi);

IF &raktyyppi = 7 THEN DO;

	temp = vapvarvo * (&veropros / 100);

END;

ELSE temp = 0;

&tulos = temp;

DROP temp vapvarvo; 
%MEND KiVeroVapS;






