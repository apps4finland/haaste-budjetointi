/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyˆdynt‰‰ Tilastokeskuksen yleisten
* k‰yttˆehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto p‰‰hakemistossa.
******************************************************************************/

/***********************************************************
* Kuvaus: Opintotuen lains‰‰d‰ntˆ‰ makroina                *
* Tekij‰: Olli Kannas / TK		                		   *
* Luotu: 16.08.2011				       					   *
* Viimeksi p‰ivitetty: 25.11.2011		     		       *
* P‰ivitt‰j‰: Olli Kannas / TK			     			   *
************************************************************/ 


/* 1. SISƒLLYS */

/* Tiedosto sis‰lt‰‰ seuraavat makrot */

/*
2. VanhKorotusS = Opintorahaan vanhempien tulojen perusteella laskettava korotus
3. VanhAlennusS = Opintorahaan vanhempien tulojen perusteella laskettava alennus
4. AsumLisaKS = Asumislis‰ kuukausitasolla 
5. AsumLisaVS = Asumislis‰ kuukausitasolla vuosikeskiarvona
6. OpRahaKS = Opintoraha kuukausitasolla
7. OpRahaVS = Opintoraha kuukausitasolla vuosikeskiarvona
8. OpRahaAsumLisaKS = Opintorahan ja asumislis‰n summa kuukausitasolla
9. AikOpinRahaKS = Aikuisopintoraha kuukausitasolla
10. AikOpinRahaVS = Aikuisopintoraha kuukausitasolla vuosikeskiarvona
11. AikKoulTukiKS = Aikuiskoulutustuki kuukausitasolla
12. AikKoulTukiVS = Aikuiskoulutustuki kuukausitasolla vuosikeskiarvona
13. OpLainaKS = Opintolainan valtiontakaus kuukausitasolla
14. OpLainaVS = Opintolainan valtiontakaus kuukausitasolla vuosikeskiarvona
15. OpTukiTakaisinS = Opintotuen takaisinperint‰ vuositasolla
16. AsumLisaVuokraKS = Asumislis‰n k‰‰nteisfunktio, joka p‰‰ttelee asumislis‰n suuruudesta vuokran suuruuden kuukausitasolla
17. AsumLisaVuokraVS = Asumislis‰n k‰‰nteisfunktio, joka p‰‰ttelee asumislis‰n suuruudesta vuokran suuruuden kuukausitasolla vuosikeskiarvona
*/


/* 2. Makro laskee opintorahaan vanhempien tulojen (ja varallisuuden) perusteella laskettavan korotuksen */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, opintorahaan vanhempien tulojen perusteella laskettava korotus, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kork: 1 = korkeakouluopiskelija, 0 = keskiasteen opiskelija
	vanh: Vanhempien luona asuminen (1 = tosi, 0 = ep‰tosi)
	ika: Ik‰ vuosina
	vanhtulo: Vanhempien veronalaiset tulot, e/vuosi
	vanhvarall: Vanhempien veronalainen varallisuus, e;

%MACRO VanhKorotusS(tulos, mvuosi, mkuuk, minf, kork, vanh, ika, vanhtulo, vanhvarall)/STORE
DES = 'OPINTUKI: Opintorahaan vanhempien tulojen perusteella laskettava korotus';

%HaeParam_OpinTuki&tyyppi (&mvuosi, &mkuuk, &minf);
%KuuNro_Opintuki&tyyppi (kuuid, &mvuosi, &mkuuk);	

IF (kuuid < 12 * (1992 - &paramalkuot) + 7) OR (kuuid < 12 * (1994 - &paramalkuot) + 7 AND &kork = 0) THEN temp = 0;

ELSE DO;

	* Ei korotusta, jos ei asu vanhempien luona ja ylitt‰‰ ik‰rajan ;
	IF (&vanh = 0 AND &ika >= &ORaja2) THEN temp = 0;

	ELSE DO;

		* Lasketaan vanhempien tuloihin korotus, jos varallisuusraja ylittyy ;
		IF &vanhvarall > &VanhVarRaja
		THEN vanhtulo = &vanhtulo + (&VanhVarPros * (&vanhvarall - &VanhVarRaja));
		ELSE vanhtulo = &vanhtulo;

		IF vanhtulo <= &VanhTuloYlaRaja THEN DO;
			IF &kork = 1 THEN DO;
				IF &vanh = 1 THEN DO;
					IF &ika < &ORaja1 THEN temp = &KorkVanhAlle20b;
					ELSE temp = &KorkVanh20b;
				END;
				ELSE temp = &KorkMuuAlle20b;
			END;
			ELSE DO;
				IF &vanh = 1 THEN DO;
					IF &ika < &ORaja1 THEN temp = &MuuVanhAlle20b;
					ELSE temp = &MuuVanh20b;
				END;
				ELSE temp = &MuuMuuAlle20b;
			END;
		END;

		IF vanhtulo > &VanhTuloRaja THEN DO;

			IF vanhtulo > &VanhTuloYlaRaja THEN temp = 0;
			ELSE IF &VanhKynnys > 0 THEN DO;
				vah = FLOOR((vanhtulo - &VanhTuloRaja) / SUM(&VanhKynnys));
				vah = vah * &VanhPros * temp;
    			temp = SUM(temp, -vah);
				IF temp < 0 THEN temp = 0;
			END;
			ELSE temp = 0;
		END;
	END;
END;
&tulos = temp;
DROP vanhtulo vah temp kuuid;
%MEND VanhKorotusS;


/* 3. Makro laskee opintorahan alennuksen vanhempien tulojen perusteella */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, opintorahaan vanhempien tulojen perusteella laskettava alennus, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	alisa: Onko kyse asumislis‰st‰ vai opintorahasta teht‰v‰st‰ alennuksesta (1 = asumislis‰, 0 = opintoraha)
	kork: 1 = korkeakouluopiskelija, 0 = keskiasteen opiskelija
	vanh: Vanhempien luona asuminen (1 = tosi, 0 = ep‰tosi) HUOM! Muuttujaa vanh ei tarvita! 
	ika: Ik‰ vuosina
	sisaria: Sisaruksia (1 = tosi, 0 = ep‰tosi)
	vanhtulo: Vanhempien veronalaiset tulot, e/vuosi
	opraha: Asumislis‰ tai opintoraha, e/kk ;

%MACRO VanhAlennusS(tulos, mvuosi, mkuuk, minf, alisa, kork, vanh, ika, sisaria, vanhtulo, opraha)/STORE
DES = 'OPINTUKI: Opintorahaan vanhempien tulojen perusteella laskettava alennus';

%HaeParam_OpinTuki&tyyppi (&mvuosi, &mkuuk, &minf);
%KuuNro_Opintuki&tyyppi (kuuid, &mvuosi, &mkuuk);	

IF (kuuid < 12 * (1992 - &paramalkuot) + 7) OR (kuuid < 12 * (1994 - &paramalkuot) + 7 AND &kork = 0) THEN temp = 0;

ELSE DO;

	* Ei alennusta, jos korkeakouluopiskelija;
	IF &kork = 1 THEN temp = 0;

	* Opintorahassa ik‰raja on alle 20-v., asumislis‰ss‰ alle 18-v.;

	ELSE IF (&ika < &ORaja1) OR (&alisa = 1 AND &ika < &ORaja3) THEN DO; 
		IF &vanhtulo <= &VanhTuloRaja2 THEN temp = 0;
		ELSE IF &VanhTuloRaja2Kynnys > 0 THEN DO;
			temp = FLOOR((&vanhtulo - &VanhTuloRaja2) / SUM(&VanhTuloRaja2Kynnys));
			temp = temp * &VanhTuloPros2 * &opraha;
			IF temp > &opraha THEN temp = &opraha;
		END;
		ELSE temp = 0;
	END;
	ELSE temp = 0;
END;
&tulos = temp;
DROP temp kuuid;
%MEND VanhAlennusS;
	
/* 4. Makro laskee asumislis‰n kuukausitasolla */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, asumislis‰, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kork: 1 = korkeakouluopiskelija, 0 = keskiasteen opiskelija
	vanh: Vanhempien luona aSUMinen (1 = tosi, 0 = ep‰tosi).
	ika: Ik‰ vuosina
	sisaria: Sisaruksia (1 = tosi, 0 = ep‰tosi)
	asmenot: Asumismenot, e/kk
	omatulo: Henkilˆn omat veronalaiset tulot (ja apurahat), e/vuosi
	vanhtulo: Vanhempien veronalaiset tulot, e/vuosi
	puoltulo: Puolison veronalaiset tulot, e/vuosi ;

%MACRO AsumLisaKS (tulos, mvuosi, mkuuk, minf, kork, ika, sisaria, asmeno, omatulo, vanhtulo, puoltulo)/STORE
DES = 'OPINTUKI: Asumislis‰ kuukausitasolla';

%HaeParam_OpinTuki&tyyppi (&mvuosi, &mkuuk, &minf);
%KuuNro_Opintuki&tyyppi (kuuid, &mvuosi, &mkuuk);	

IF ((kuuid < 12 * (1992 - &paramalkuot) + 7) OR (kuuid < (12 * (1994 - &paramalkuot) + 7) AND &kork = 0)) 
THEN temp2 = 0; 

ELSE DO;

	* Pienin huomioon otettava asumismeno ;
	IF &asmeno < &VuokraMinimi THEN temp2 = 0; 

	ELSE DO;

		* Vuokra otetaan huomioon vain vuokrakattoon asti ;
		IF &asmeno > &VuokraKatto THEN asmenot = &VuokraKatto;
		ELSE asmenot = &asmeno;

		* Peruskaava ;
		temp2 = &AsLisaPerus + (&AsLisaPros * (asmenot - &VuokraRaja));

		* V‰hennys opiskelijan omien tulojen perusteella ennen 1.1.1998 ;
		IF &mvuosi < 1998 THEN DO;
			IF &omatulo > &AsLisaTuloRaja THEN IF &AsLisaVanhKynnys > 0  
			THEN vah1 = FLOOR((&omatulo - &AsLisaTuloRaja) / SUM(&AsLisaVanhKynnys));
			vah1 = vah1 * &AsLisavahPros * temp2;
		END;
		temp2 = SUM(temp2, -vah1);

		* V‰hennys puolison tulojen perusteella 1.5.2000 l‰htien 31.12.2008 asti, jos
  		puoliso asuu samassa asunnossa ;
		IF kuuid > (12 * (2000 - &paramalkuot) + 4) THEN IF &mvuosi < 2009 THEN DO;
			IF &puoltulo > &AsLisaPuolTuloRaja THEN IF &AsLisaPuolTuloKynnys > 0 
			THEN vah2 = FLOOR((&puoltulo - &AsLisaPuolTuloRaja) / SUM(&AsLisaPuolTuloKynnys));
			vah2 = vah2 * &AsLisaPuolVahPros * temp2;
		END;
		temp2 = SUM(temp2, -vah2);
		IF (temp2 < 0) THEN temp2 = 0;

		* V‰hennys vanhempien tulojen perusteella ;
		%VanhAlennusS(asalennus, &mvuosi, &mkuuk, &minf, 1, &kork, 0, &ika, &sisaria, &vanhtulo, temp2);
		temp2 = SUM(temp2, -asalennus);
	END;
END;
&tulos = temp2;
DROP vah1 vah2 temp2 asalennus asmenot kuuid;
%MEND AsumLisaKS;

/* 5. Makro laskee asumislis‰n kuukausitasolla vuosikeskiarvona */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, asumislis‰, e/kk (vuosikeskiarvo) 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kork: 1 = korkeakouluopiskelija, 0 = keskiasteen opiskelija
	vanh: Vanhempien luona asuminen (1 = tosi, 0 = ep‰tosi)
	ika: Ik‰ vuosina
	sisaria: Sisaruksia (1 = tosi, 0 = ep‰tosi)
	asmenot: Asumismenot, e/kk
	omatulo: Henkilˆn omat veronalaiset tulot (ja apurahat), e/vuosi
	vanhtulo: Vanhempien veronalaiset tulot, e/vuosi
	puoltulo: Puolison veronalaiset tulot, e/vuosi ;

%MACRO AsumLisaVS (tulos, mvuosi, minf, kork, ika, sisaria, asmeno, omatulo, vanhtulo, puoltulo)/STORE
DES = 'OPINTUKI: Asumislis‰ kuukausitasolla vuosikeskiarvona';

raha = 0;
%DO i = 1 %TO 12;
	%AsumLisaKS(temp, &mvuosi, &i, &minf, &kork, &ika, &sisaria, &asmeno, &omatulo, &vanhtulo, &puoltulo);
	raha = SUM(raha,  temp);
%END;
&tulos = raha / 12;
DROP raha temp;
%MEND AsumLisaVS;


/* 6. Makro laskee opintorahan kuukausitasolla */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, opintoraha, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kork: 1 = korkeakouluopiskelija, 0 = keskiasteen opiskelija
	vanh: Vanhempien luona asuminen (1 = tosi, 0 = ep‰tosi)
	ika: Ik‰ vuosina
	sisaria: Sisaruksia (1 = tosi, 0 = ep‰tosi)
	omatulo: Henkilˆn omat veronalaiset tulot (ja apurahat), e/vuosi
	vanhtulo: Vanhempien veronalaiset tulot, e/vuosi
	vanhvarall: Vanhempien veronalainen varallisuus, e;

%MACRO OpRahaKS (tulos, mvuosi, mkuuk, minf, kork, vanh, ika, sisaria, omatulo, vanhtulo, vanhvarall)/STORE
DES = 'OPINTUKI: Opintoraha kuukausitasolla';

%HaeParam_OpinTuki&tyyppi (&mvuosi, &mkuuk, &minf);
%KuuNro_Opintuki&tyyppi (kuuid, &mvuosi, &mkuuk);	

IF (kuuid < 12 * (1992 - &paramalkuot) + 7) OR (kuuid < 12 * (1994 - &paramalkuot) + 7 AND &kork = 0) THEN temp2 = 0;

ELSE DO;

	* Korkeakouluopiskelijat ;
	IF &kork = 1 THEN DO;
		IF &vanh = 1 THEN DO; 
			IF &ika < &ORaja1 THEN temp2 = &KorkVanhAlle20;
			ELSE temp2 = &KorkVanh20;
    	END;
		ELSE DO;
			IF &ika < &ORaja2 THEN temp2 = &KorkMuuAlle20;
			ELSE temp2 = &KorkMuu20;
    	END;
	END;		
	
	* Muut kuin korkeakouluopiskelijat ;	
	ELSE DO;
		IF &vanh = 1 THEN DO; 
			IF &ika < &ORaja1 THEN temp2 = &MuuVanhAlle20;
			ELSE temp2 = &MuuVanh20;
		END;	
		ELSE DO;
			IF &ika < &ORaja2 THEN temp2 = &MuuMuuAlle20;
			ELSE temp2 = &MuuMuu20;
		END;
	END;		

	* Korotus vanhempien tulojen (ja varallisuuden) perusteella ;	
	%VanhKorotusS(korotus, &mvuosi, &mkuuk, &minf, &kork, &vanh, &ika, &vanhtulo, &vanhvarall);
  	temp2 = SUM(temp2, korotus);

	* V‰hennys vanhempien tulojen perusteella ;
 	%VanhAlennusS(opalennus, &mvuosi, &mkuuk, &minf, 0, &kork, &vanh, &ika, &sisaria, &vanhtulo, temp2);
 	temp2 = SUM(temp2, -opalennus);

	* V‰hennys opiskelijan omien tulojen perusteella ennen 1.1.1998 ;
	IF &mvuosi < 1998 THEN DO;

		IF (&omatulo > &OpTuloRaja AND &OpTuloVahKynnys > 0) THEN DO;
			vah2 = FLOOR((&omatulo - &OpTuloRaja) / SUM(&OpTuloVahKynnys));
			vah2 = vah2 * &OpTuloVahPros  * temp2;
		END;
		ELSE DO; 
			vah2 = 0;
		END;
		temp2 = SUM(temp2, -vah2);
	END;

	IF temp2 < 0 THEN temp2 = 0;

END;

&tulos = temp2;
*DROP vah2 temp2 opalennus korotus kuuid;
%MEND OpRahaKS;


/* 7. Makro laskee opintorahan kuukausitasolla vuosikeskiarvona */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, opintoraha, e/kk (vuosikeskiarvo) 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kork: 1 = korkeakouluopiskelija, 0 = keskiasteen opiskelija
	vanh: Vanhempien luona asuminen (1 = tosi, 0 = ep‰tosi).
	ika: Ik‰ vuosina
	sisaria: Sisaruksia (1 = tosi, 0 = ep‰tosi)
	omatulo: Henkilˆn omat veronalaiset tulot (ja apurahat), e/vuosi
	vanhtulo: Vanhempien veronalaiset tulot, e/vuosi
	vanhvarall: Vanhempien veronalainen varallisuus, e/vuosi ;

%MACRO OpRahaVS (tulos, mvuosi, minf, kork, vanh, ika, sisaria, omatulo, vanhtulo, vanhvarall)/STORE
DES = 'OPINTUKI: Opintoraha kuukausitasolla vuosikeskiarvona';

raha = 0;
%DO i = 1 %TO 12;
	%OpRahaKS(temp, &mvuosi, &i, &minf, &kork, &vanh, &ika, &sisaria, &omatulo, &vanhtulo, &vanhvarall);
	raha = SUM(raha, temp);
%END;

&tulos = raha / 12;
DROP raha temp;
%MEND OpRahaVS;


/* 8. Makro laskee opintorahan ja asumislis‰n summan kuukausitasolla */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, opintotuki yhteens‰, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kork: 1 = korkeakouluopiskelija, 0 = keskiasteen opiskelija
	vanh: Vanhempien luona asuminen (1 = tosi, 0 = ep‰tosi)
	ika: Ik‰ vuosina
	sisaria: Sisaruksia (1 = tosi, 0 = ep‰tosi)
	omatulo: Henkilˆn omat veronalaiset tulot (ja apurahat), e/vuosi
	vanhtulo: Vanhempien veronalaiset tulot, e/vuosi
	puoltulo: Puolison veronalaiset tulot, e/vuosi
	vanhvarall: Vanhempien veronalainen varallisuus, e
	asummeno: Asumismenot, e/kk ;

%MACRO OpRahaAsumLisaKS (tulos, mvuosi, mkuuk, minf, kork, vanh, ika, sisaria, omatulo, vanhtulo, puoltulo, vanhvarall, asummeno)/STORE
DES = 'OPINTUKI: Opintorahan ja asumislis‰n summa kuukausitasolla';

%OpRahaKS(rahak, &mvuosi, &mkuuk, &minf, &kork, &vanh, &ika, &sisaria, &omatulo, &vanhtulo, &vanhvarall);
temp3 = rahak;

IF &vanh = 0 THEN DO;
	%AsumLisaKS(lisak, &mvuosi, &mkuuk, &minf, &kork, &ika, &sisaria, &aSUMmeno, &omatulo, &vanhtulo, &puoltulo);
	temp3 = SUM(rahak, lisak);
END;

&tulos = temp3;
DROP rahak lisak temp3;
%MEND OpRahaAsumLisaKS;

	
/* 9. Makro laskee aikuisopintorahan kuukausitasolla */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, aikuisopintoraha, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kork: 1 = korkeakouluopiskelija, 0 = keskiasteen opiskelija
	tulo: Henkilˆn omat veronalaiset tulot, e/vuosi ;

%MACRO AikOpinRahaKS (tulos, mvuosi, mkuuk, minf, kork, tulo)/STORE
DES = 'OPINTUKI: Aikuisopintoraha kuukausitasolla';

%HaeParam_OpinTuki&tyyppi (&mvuosi, &mkuuk, &minf);
%KuuNro_Opintuki&tyyppi (kuuid, &mvuosi, &mkuuk);	

IF (kuuid < 12 * (1992 - &paramalkuot) + 7) OR (kuuid > 12 * (2002 - &paramalkuot) + 12) THEN temp = 0;

ELSE DO;

	IF &kork = 1 THEN AikOpAlaRaja = &KorkMuu20;
	ELSE AikOpAlaRaja = &AikOpAlaRaja;

	temp = &AikOpPros * &tulo;
	IF temp < AikOpAlaRaja THEN temp = AikOpAlaRaja;
	IF temp > &AikOpYlaRaja THEN temp = &AikOpYlaRaja;

END;

&tulos = temp;
DROP temp kuuid AikOpAlaRaja;
%MEND AikOpinRahaKS;


/* 10. Makro laskee aikuisopintorahan kuukausitasolla vuosikeskiarvona */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, aikuisopintoraha, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kork: 1 = korkeakouluopiskelija, 0 = keskiasteen opiskelija
	tulo: Henkilˆn omat veronalaiset tulot, e/vuosi ;

%MACRO AikOpinRahaVS (tulos, mvuosi, minf, kork, tulo)/STORE
DES = 'OPINTUKI: Aikuisopintoraha kuukausitasolla (vuosikeskiarvo)';

raha = 0;
%DO i = 1 %TO 12;
	%AikOpinRahaKS (temp2, &mvuosi, &i, &minf, &kork, &tulo);
	raha = SUM(raha, temp2);
%END;
&tulos = raha / 12;
DROP raha temp2;
%MEND AikOpinRahaVS;


/* 11. Makro laskee aikuiskoulutustuen kuukausitasolla */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, aikuisopintotuki, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	tulo: Henkilˆn omat veronalaiset tulot, e/vuosi ;

%MACRO AikKoulTukiKS (tulos, mvuosi, mkuuk, minf, tulo)/STORE
DES = 'OPINTUKI: Aikuiskoulutustuki kuukausitasolla';

%HaeParam_OpinTuki&tyyppi (&mvuosi, &mkuuk, &minf);
%KuuNro_Opintuki&tyyppi (kuuid, &mvuosi, &mkuuk);	

IF (kuuid < 12 * (2001 - &paramalkuot) + 8) OR (kuuid > 12 * (2010 - &paramalkuot) + 7) THEN temp = 0;

ELSE DO;

	temp = &AikKoulPerus;
	IF &tulo < &AikKoulTuloRaja
	THEN temp = temp + (&AikKoulPros1 * &tulo);

	ELSE DO;
		temp = temp + (&AikKoulPros1 * &AikKoulTuloRaja);
		temp = temp + (&AikKoulPros2 * (&tulo - &AikKoulTuloRaja));
	END;

END;

&tulos = temp;
DROP temp kuuid;
%MEND AikKoulTukiKS ;


/* 12. Makro laskee aikuiskoulutustuen kuukausitasolla vuosikeskiarvona */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, aikuisopintotuki, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	tulo: Henkilˆn omat veronalaiset tulot, e/vuosi ;

%MACRO AikKoulTukiVS (tulos, mvuosi, minf, tulo)/STORE
DES = 'OPINTUKI: Aikuiskoulutustuki kuukausitasolla (vuosikeskiarvo)';

raha = 0;
%DO i = 1 %TO 12;
	%AikKoulTukiKS (temp2, &mvuosi, &i, &minf, &tulo);
	raha = SUM(raha, temp2);
%END;
&tulos = raha / 12;
DROP raha temp2;
%MEND AikKoulTukiVS ;


/* 13. Makro laskee kuukausitasolla opintolainan valtiontakauksen m‰‰r‰n */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, (potentiaalinen) opintolainan valtiontakaus, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kork: 1 = korkeakouluopiskelija, 0 = keskiasteen opiskelija
	aikkoul: Aikuiskoulutusopiskelija (1 = tosi, 0 = ep‰tosi)
	ika: Ik‰ vuosina ;

%MACRO OpLainaKS (tulos, mvuosi, mkuuk, minf, kork, aikkoul, ika)/STORE
DES = 'OPINTUKI: Opintolainan valtiontakaus kuukausitasolla';

%HaeParam_OpinTuki&tyyppi (&mvuosi, &mkuuk, &minf);

IF &aikkoul = 1 THEN temp = &OpLainaAikKoul;

ELSE DO;

	IF &kork = 1 THEN DO;
		IF &ika < &ORaja3 THEN temp = &OpLainaKorAlle18;
		ELSE temp = &OpLainaKor;
	END;

	ELSE DO;
		IF &ika < &ORaja3 THEN temp = &OpLainaMuuAlle18;
		ELSE temp = &OpLainaMuu;
	END;

END;

&tulos = temp;
DROP temp;
%MEND OpLainaKS;


/* 14. Makro laskee opintolainan valtiontakauksen m‰‰r‰n kuukausitasolla vuosikeskiarvona */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, (potentiaalinen) opintolainan valtiontakaus, e/kk (vuosikeskiarvo) 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	kork: 1 = korkeakouluopiskelija, 0 = keskiasteen opiskelija
	aikkoul: Aikuiskoulutusopiskelija (1 = tosi, 0 = ep‰tosi)
	ika: Ik‰ vuosina¥;

%MACRO OpLainaVS (tulos, mvuosi, minf, kork, aikkoul, ika)/STORE
DES = 'OPINTUKI: Opintolainan valtiontakaus kuukausitasolla vuosikeskiarvona';

raha = 0;
%DO i = 1 %TO 12;
	%OpLainaKS (temp2, &mvuosi, &i, &minf, &kork, &aikkoul, &ika);
	raha = SUM(raha, temp2);
%END;
&tulos = raha / 12;
DROP raha temp2;
%MEND OpLainaVS;


/* 15. Makro laskee opintotuen takaisinperinn‰n 1.1.1998 l‰htien vuositasolla */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, takaisinperitt‰v‰n opintotuen m‰‰r‰, e/vuosi
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	optukikuuk: Opintotukikuukaudet vuodessa
	tulo: Henkilˆn omat veronalaiset tulot (ml. apurahat, pl. opintoraha), e/vuosi
	tuki: Opintoraha, e/vuosi ;

%MACRO OpTukiTakaisinS (tulos, mvuosi, mkuuk, minf, optukikuuk, tulo, tuki)/STORE
DES = 'OPINTUKI: Opintotuen takaisinperint‰ vuositasolla';

%HaeParam_OpinTuki&tyyppi (&mvuosi, &mkuuk, &minf);

* Ei takaisinperint‰‰, jos ei tukea tai jos ei tuloja.
  Funktio k‰sittelee vain lains‰‰d‰ntˆ‰ 1.1.1998 l‰htien ;
IF (&tuki <= 0) OR (&tulo <= 0) OR (&mvuosi < 1998) THEN temp = 0;

ELSE DO;

	tukikuuk=&optukikuuk;	
	IF tukikuuk < 0 THEN tukikuuk = 1;
	IF tukikuuk > 12 THEN tukikuuk = 12;

	* Tuloraja opintotukikuukausille: OpTuloRaja
  	Tuloraja muille kuukausille: OpTuloRaja2   ;
	
	* Vapaa tulo ;
	vapaa = (tukikuuk * &OpTuloRaja) + ((12 - tukikuuk) * &OpTuloRaja2);

	IF &tulo < vapaa THEN temp = 0;

	ELSE DO;

		* Vapaan tulon ylitys ;
		ylitys = &tulo - vapaa;

		* Lains‰‰d‰ntˆ ennen 1.1.2001: laissa m‰‰ritellyn 
 		rajan alittavasta tulosta perit‰‰n tietty osuus 
  		ja sen ylitt‰v‰st‰ osuudesta kokonaan ;

		IF &mvuosi < 2001 THEN DO;
			IF ylitys < &TakPerRaja THEN temp = &TakPerPros * ylitys;
			ELSE temp = (ylitys - &TakPerRaja) + (&TakPerPros * &TakPerRaja);
		END;

		* Lains‰‰d‰ntˆ 1.1.2001 l‰htien: takaisin peritt‰v‰ m‰‰r‰
  		riippuu siit‰, kuinka monikertainen ylitys on m‰‰riteltyyn
  		rajaan n‰hden. Tukea kuukautta kohden perit‰‰n takaisin t‰m‰n 
  		monikerran verran, mutta ei kuitenkaan tietyn alarajan alittavaa ylityst‰ ;

		ELSE IF &mvuosi > 2001 THEN DO;
			IF ylitys < &TakPerAlaRaja OR &TakPerRaja <= 0 THEN temp = 0;
			ELSE DO;
				luku = FLOOR(ylitys / SUM(&TakPerRaja)); 
				IF luku = 0 THEN luku = 1;
				IF tukikuuk > 0 THEN temp = luku * (&tuki / SUM(tukikuuk));
				ELSE temp = 0;
			 END;
		END;

	END;   
 
	* Takaisin peritt‰v‰ summa ei voi olla opintotukea suurempi ;
	IF temp > &tuki THEN temp = &tuki;

	* Mutta takaisin peritt‰v‰‰ summaa korotetaan tietyll‰ prosentilla ;
	temp  = temp * (1 + &TakPerKorotus) ; 

END;

&tulos = temp;
DROP tukikuuk vapaa ylitys luku temp;
%MEND OpTukiTakaisinS;


/* 16. Asumlis‰n k‰‰nteisfunktio, joka p‰‰ttelee asumislis‰n suuruudesta
       vuokran suuruuden kuukausitasolla. Toimii hein‰kuusta 1993 l‰htien,
       jos opiskelijan ja puolison tuloja ei oteta huomioon */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, vuokran suuruus, e/kk 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	aslisa: Asumislis‰, e/kk ;

%MACRO AsumLisaVuokraKS (tulos, mvuosi, mkuuk, minf, aslisa)/STORE
DES = 'OPINTUKI: Asumislis‰n k‰‰nteisfunktio, joka p‰‰ttelee asumislis‰n suuruudesta vuokran suuruuden kuukausitasolla';

%HaeParam_OpinTuki&tyyppi (&mvuosi, &mkuuk, &minf);

* Jos ei asumislis‰‰, ei lasketa pidemm‰lle. 
  Ei lasketa myˆsk‰‰n ennen hein‰kuuta 1993 ;

%KuuNro_OpinTuki&tyyppi (kuuid, &mvuosi, &mkuuk);
IF (&aslisa <= 0) OR (kuuid < 12 * (1993 - &paramalkuot) + 7) THEN temp = 0;

ELSE DO;

	* Maksimilis‰ ;
	maksimi = &AsLisaPros * &Vuokrakatto;

	* Jos maksimiasumilisa, annetaan tulokseksi &VuokraKatto + (200 * satunnaisluku v‰lilt‰ (0,1)). 
	  Vakion suuruutta voi kokeilla;

	IF &aslisa >= maksimi THEN temp = (RAND('UNIFORM') * 200) + &Vuokrakatto;

	ELSE DO;
		IF &aslisa < maksimi THEN IF &aslisa >= &AsLisaPros * &VuokraMinimi THEN IF &AsLisaPros > 0
		THEN temp = &aslisa / SUM(&AsLisaPros);
    	IF &aslisa < &AsLisaPros * &VuokraMinimi 
		THEN temp = &VuokraMinimi;
	END;
END;

&tulos = temp;
DROP maksimi temp kuuid;
%MEND AsumLisaVuokraKS;
		

/* 17. Asumlis‰n k‰‰nteisfunktio, joka p‰‰ttelee asumislis‰n suuruudesta
       vuokran suuruuden kuukausitasolla vuosikeskiarvona.
       HUOM! keskiarvo lasketaan 9 kuukaudelle (tammi-toukokuu ja syys-joulukuu) */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, vuokran suuruus, e/kk (vuosikeskiarvo) 
	mvuosi: Vuosi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n
	mkuuk: Kuukausi, jonka lains‰‰d‰ntˆ‰ k‰ytet‰‰n 
	minf: Deflaattori eurom‰‰r‰isten parametrien kertomiseksi 
	aslisa: Asumislis‰, e/kk ;
 
%MACRO AsumLisaVuokraVS (tulos, mvuosi, minf, aslisa)/STORE
DES = 'OPINTUKI: Asumislis‰n k‰‰nteisfunktio, joka p‰‰ttelee asumislis‰n suuruudesta vuokran suuruuden kuukausitasolla vuosikeskiarvona';

raha = 0;
%DO i = 1 %TO 5;
	%AsumLisaVuokraKS(vuokra1, &mvuosi, &i, &minf,  &aslisa);
	raha = SUM(raha, vuokra1);
%END;
%DO j = 9 %TO 12;
	%AsumLisaVuokraKS(vuokra2, &mvuosi, &j, &minf, &aslisa);
	raha = SUM(raha, vuokra2);
%END;

&tulos = raha / 9;
DROP raha vuokra1 vuokra2;		
%MEND AsumLisaVuokraVS;

		
			
		
