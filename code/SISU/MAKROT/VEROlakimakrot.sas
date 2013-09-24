/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyödyntää Tilastokeskuksen yleisten
* käyttöehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto päähakemistossa.
******************************************************************************/

/*******************************************************************
*  Kuvaus: Tuloverotuksen lainsäädäntöä makroina                   * 
*  Tekijä: Pertti Honkanen/ KELA                                   *
*  Luotu: 12.09.2011                                               *
*  Viimeksi päivitetty: 7.2.2012 							       * 
*  Päivittäjä: Filip Kjellberg, Pertti Honkanen/ Kela			   *
*******************************************************************/

/* 1. SISÄLLYS */

/* Tiedosto sisältää seuraavat makrot */

/* 
2. TulonHankVahS = Tulonhankkimisvähennys
3. TyoMatkaVahS = Työmatkakuluvähennys
4. AsuntoVahennysS = Asuntovähennys (ns. kakkosasunnon verovähennys)
5. TulonHankKulutS = Tulonankkimisvähennys, työmatkakuluvähkennys ja ay-jäsenmaksujen vähennys yhdistettynä
6. TyoelMaksuS = Palkansaajan työeläkemaksu
7. TyotMaksuS = Palkansaajan työttömyysvakuutusmaksu
8. PalkVakMaksuS = Palkansaajat työeläkemaksu ja työttömyysvakuutusmaksu yhdistettynä
9. SvPRahaMaksuS = Sairausvakuutuksen päivärahamaksu, perusversio
10. SvPRahaMaksuYS = Sairausvakuutuksen päivärahamaksu, yritystulon korotettu maksu huomioon otettuna
11. KunnAnsVahS = Kunnallisverotuksen ansiotulovähennys
12. KunnElTulVahS = Kunnallisverotuksen eläketulovähennys
13. KunnOpRahVahS = Kunnallisverotuksen opintorahavähennys
14. KunnVerInvVahS = Kunnallisverotuksen invalidivähennys
15. KunnPerVahS = Kunnallisverotuksen perusvähennys
16. SairVakMaksuS = Sairausvakuutusmaksu, lyhennetty kaava
17. KanselVakMaksuS = Kansaneläkevakuutusmaksu, lyhennetty kaava
18. KunnVeroS = Kunnallisvero: joko keskimääräinen tai valittu veroprosentti
19. KirkVeroS = Kirkollisvero: joko keskimääräinen tai valittu veroprosentti
20. ValtTyoTuloVahS = Valtionverotuksen työtulovähennys
21. ValtElTulVahS = Valtionverotuksen eläketulovähennys
22. ValtVerAnsVahS = Valtionverotuksen ansiotulovähennys/työtulovähennys (vähennys verosta)
23. ValtVerInvVahS = Valtionverotuksen invalidivähennys (vähennys verosta)
24. ValtVerElVelvVahS = Valtionverotuksen elatusvelvollisuusvähennys (vähennys verosta)
25. LahjoitusVahS = Lahjoitusvähennys, väliaikainen vähennys 2009-
26. ValtTuloVeroS = Valtion tulovero (veroasteikko)
27. TuloVerot_SimpleS = Tuloverot palkkaverotuksen yksinkertaisessa perustapauksessa
28. TuloVerot_SimpleMargS = Marginaaliveroaste palkkaverotuksen yksinkertaisessa perustapauksessa
29. BruttotuloS = Nettokuukausitulosta johdettu bruttotulo palkansaajalla
30. TuloVerot_Simple_ElakeS = Eläketulon verot yksinkertaisessa perustapauksessa
31. TuloVerot_Simple_PRahaS = Päivärahatulon tai muun ansiotulon verot yksinkertaisessa perustapauksessa
32. PomaOsuusS = Jaettavan yritystulon tai muun kuin pörssiyhtiön osingon tai siihen liittyvän yhtiöveron hyvityksen pääomatulo-osuus
33. OsinkojenJakoS  = Osinkotulojen jakaminen pääomatuloksi, ansiotuloiksi ja verottomiksi tuloksi
34. AlijHyvS = Alijäämähyvitys
35. AlijHyvEritS = Erityinen alijäämähyvitys
36. YhtHyvS = Yhtiöveron hyvitys
37. POTulonVeroS = Pääomatulon vero
38. VahAsKorotS = Vähennyskelpoiset asuntolainan korot
39. POTulonVeroEritS = Pääomatulon vero, vapaaeht. eläkevakuutusmaksut huomioon otettuna
40. KotiTalVahS = Kotitalousvähennys
41. VahennJakoS = Vähennysten jakaminen eri verolajeille
42. AlijHyvJakoS = Alijäämähyvityksen jakaminen eri verolajeille
43. YhtHyvJakoS = Yhtiöveron hyvityksen jakaminen eri verolajeille
44. ValtLapsVahS = Valtionverotuksen lapsenhoitovähennys (nimenä myös ylimääräinen työtulovähennys)
45. KunnLapsVahS = Kunnallisverotuksen lapsenhoitovähennys (huom! sisältää myös yksinhuoltajavähennyksen) 
46. KunnYksVahS = Kunnallisverotuksen yksinhuoltajavähennys
47. VarallVeroS = Varallisuusvero
48. KunnElTulVahMaxS = Kunnallisverotuksen eläketulovähennyksen maksimiarvo = täysi eläketulovähennys
49. ValtElTulVahMaxS = Valtionverotuksen eläketulovähennyksen maksimiarvo = täysi eläketulovähennys
50. ElVeroRajaS = Raja, josta eläketulon verotus alkaa
51. ValtVerRajaS =  Valtion tuloverotuksen alaraja
52. KunnVerRajaS = Kunnan tuloverotuksen alaraja
53. YleVeroS = YLE-vero
54. ValtVero_Final = Valtionvero kun verotuksen kattosäännös otetaan huomioon
55. ElakeLisaVero = Eläketulon lisävero
*/


/* 2. Tulonhankkimisvähennys. 
	  Tuottaa palkkatuloista automaattisen vähennyksen. 
      Jos tulonhankkimiskulut ovat suurempia kuin automaattinen vähennys, 
      edelliset määrittelevät vähennyksen suuruuden */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Tulonhankkimisvähennys
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	palkkatulo: Palkkatulot
	tulhankkulut: Tulonhankkimiskulut;

%MACRO TulonHankVahS(tulos, mvuosi, minf, palkkatulo, tulonhankkulut)/STORE
DES = 'VERO: Tulonhankkimisvähennys';

%HAKU;

&tulos = &TulonHankkAlaRaja + &TulonHankPros * &palkkatulo;

IF &tulos > &TulonHankk THEN &tulos = &TulonHankk;

IF &tulos > &palkkatulo THEN &tulos = &palkkatulo;

IF &tulonhankkulut> &tulos THEN &tulos = &tulonhankkulut;
	
%MEND TulonHankVahS;


/* 3. Työmatkakuluvähennys.
	  Vähennyksessä otetaan huomioon alennettu omavastuu työttömille, joka
	  on ollut parametreissa vuodesta 1999 lähtien */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Työmatkakuluvähennys
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	tyomatkakulut: Ilmoitetut työmatkakulut
	tyotkuuk: Työttömyyskuukaudet;

%MACRO TyoMatkaVahS(tulos, mvuosi, minf, tyomatkakulut, tyotkuuk)/STORE
DES = 'VERO: Työmatkakuluvähennys';

%HAKU;

omavast = &MatkOmaVast;

IF &tyotkuuk > 0 THEN DO;
	omavast = &MatkOmaVast - &tyotkuuk * &TyotMatkOmVast;

	IF (omavast < &MatkOmVastVahimm) THEN omavast = &MatkOmVastVahimm;
END;

&tulos = &tyomatkakulut - omavast;

IF &tulos < 0 THEN &tulos = 0;

IF &tulos > &MatkYlaRaja THEN &tulos = &MatkYlaRaja;

DROP omavast;

%MEND TyoMatkaVahS;


/* 4. Asuntovähennys (ns. kakkosasunnon vähennys).
      Parametreissa vuodesta 2008 */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Asuntovähennys 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	kuukausia: Kakkosasunnon käyttökuukausien lukumäärä
	vuokra: Vähennykseen ilmoitettu vuokra;

%MACRO AsuntoVahennysS(tulos, mvuosi, minf, kuukausia, vuokra)/STORE
DES = 'VERO: Asuntovähennys (ns. kakkosasunnon verovähennys)';

%HAKU;

IF &mvuosi < 2008 THEN &tulos = 0;

ELSE DO; 

	IF &vuokra > &TyoAsVah THEN &tulos = &kuukausia * &TyoAsVah;

	ELSE &tulos = &kuukausia * &vuokra;

END;

%MEND AsuntoVahennysS;


/* 5. Yhdistetty vähennys: tulonhannkimisvähennys, työmatkavähennys ja ay-jäsenmaksut.
	  Kaava ottaa huomioon sen, että nykyisin nämä vähennykset ovat itsenäisiä kun
	  taas aikaisemmin ne olivat osittain toisiinsa kytkettyjä */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Tulonankkimisvähennys, työmatkakuluvähkennys ja ay-jäsenmaksujen vähennys
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	anstulo: Ansiotulot
	palkkatulo: Palkkatulot
	tulhankkulut: Tulonhankkimiskulut
	aymaksut: Työmarkkinajärjestön vähennyskelpoiset jäsenmaksut
	tyomatkakulut: Ilmoitetut työmatkakulut
	tyotkuuk: Työttömyyskuukaudet;

%MACRO TulonHankKulutS(tulos, mvuosi, minf, anstulo, palkkatulo, tulhankkulut, aymaksut, tyomatkakulut, tyotkuuk)/STORE
DES = 'VERO: Tulonankkimisvähennys, työmatkakuluvähkennys ja ay-jäsenmaksujen vähennys yhdistettynä';

%TyoMatkaVahS(tyom, &mvuosi, &minf, &tyomatkakulut, &tyotkuuk);

IF &mvuosi < 1989 THEN kulut = &tulhankkulut + tyom;

ELSE IF &mvuosi >= 1989 THEN kulut = &tulhankkulut;

%TulonHankVahS(tulvah, &mvuosi, &minf, &palkkatulo, kulut);

IF &mvuosi < 1989 THEN &tulos = tulvah + &aymaksut;

IF &mvuosi >= 1989 THEN &tulos = tyom + tulvah + &aymaksut;

DROP tyom kulut tulvah;

%MEND TulonHankKulutS;


/* 6. Palkansaajan työeläkemaksu.
	  Parametreissa vuodesta 1993 lähtien */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Palkansaajan työeläkemaksu
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	v53: On 53 vuotta täyttänyt (0/1)
	palkkatulo: Palkkatulo;

%MACRO TyoelMaksuS (tulos, mvuosi, v53, palkkatulo)/STORE
DES = 'VERO: Palkansaajan työeläkemaksu';

%HAKU1;

&tulos = IFN(&V53 = 0, &ElVakMaksu * &palkkatulo, &ElVakMaksu53 * &palkkatulo);

%MEND TyoelMaksuS;


/* 7. Palkansaajan työttömyysvakuutusmaksu 
	  Parametreissa vuodesta 1993 */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Palkansaajan työttömyysvakuutusmaksu
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	palkkatulo: Palkkatulo;

%MACRO TyotMaksuS (tulos, mvuosi, palkkatulo)/STORE
DES = 'VERO: Palkansaajan työttömyysvakuutusmaksu';

%HAKU1;

&tulos = &TyotVakMaksu * &palkkatulo;

%MEND TyotMaksuS;


/* 8. Palkansaajan yhdistettu työeläke- ja työttömyysvakuutusmaksu */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Palkansaajan työeläkemaksu ja työttömyysvakuutusmaksu
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	v53: On 53 vuotta täyttänyt (0/1)
	palkkatulo: Palkkatulo;

%MACRO PalkVakMaksuS ( tulos, mvuosi, v53, palkkatulo)/STORE
DES = 'VERO: Palkansaajan työeläkemaksu ja työttömyysvakuutusmaksu yhdistettynä';

%HAKU1;

&tulos = IFN(&V53 = 0, (&ElVakMaksu + &TyotVakMaksu) * &palkkatulo, (&ElVakMaksu53 + &TyotVakMaksu) * &palkkatulo);

%MEND PalkVakMaksuS;


/* 9. Sairausvakuutuksen päivärahamaksu: vain normaaleista palkka- ja työtulosta.
	  Parametreissa vuodesta 2006 lähtien */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Sairausvakuutuksen päivärahamaksu 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	palkkatulo: Palkkatulo tai muu työtulo;

%MACRO SvPRahaMaksuS (tulos, mvuosi, palkkatulo)/STORE
DES = 'VERO: Sairausvakuutuksen päivärahamaksu, perusversio';

%HAKU1;

&tulos = &SvPrMaksu * &palkkatulo;

%MEND SvPRahaMaksuS;


/* 10. Sairausvakuutuksen päivärahamaksu.
	   Otetaan huomioon yritystulon korotettu maksu. 
	   (Huom! Korotettu maksu kohdistuu vain yrittäjien eläkelain mukaiseen työtuloon) */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Sairausvakuutuksen päivärahamaksu
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	yrit = On yrittäjä (1/0) 
	tyotulo = Työtulo;

%MACRO SvPRahaMaksuYS (tulos, mvuosi, yrit, tyotulo)/STORE
DES = 'VERO: Sairausvakuutuksen päivärahamaksu, yritystulon korotettu maksu huomioon otettuna';

%HAKU1;

&tulos = IFN(&yrit = 0, &SvPrMaksu  * &tyotulo, SUM(&SvPrMaksu, &SairVakYrit)* &tyotulo);

%MEND SvPRahaMaksuYS;


/* 11. Kunnallisverotuksen ansiotulovähennys. 
	   Parametreissa vuodesta 1991 lähtien.
	   Kaavassa otetaan huomioon tulokäsitteiden muutos */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Kunnallisverotuksen ansiotulovähennys
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	puhdanstulo: Puhdas ansiotulo
	anstulo2: Muu ansiotulo kuin eläketulo
	tyotulo: Työtulo
	palkkatulo: Palkkatulo
	kokontulo: Kokonaistulo;

%MACRO KunnAnsVahS(tulos, mvuosi, minf,  puhdanstulo, anstulo2, tyotulo, palkkatulo, kokontulo)/STORE
DES = 'VERO: Kunnallisverotuksen ansiotulovähennys';

%HAKU;

vahtulo = &tyotulo;

IF &mvuosi <= 1996 THEN vahtulo = &anstulo2;

IF &mvuosi = 1991 THEN vahtulo = &palkkatulo;

IF vahtulo <  &KunnAnsRaja1 THEN &tulos = 0;

ELSE IF vahtulo >= &KunnAnsRaja1 THEN &tulos = &KunnAnsPros1 * (vahtulo - &KunnAnsRaja1);

IF vahtulo >= &KunnAnsRaja2 
THEN &tulos = &KunnAnsPros1 * (&KunnAnsRaja2 - &KunnAnsRaja1) + &KunnAnsPros2 * (vahtulo -  &KunnAnsRaja2);

IF &tulos > &KunnAnsEnimm THEN &tulos = &KunnAnsEnimm;

verttulo = &puhdanstulo;

IF &mvuosi < 1993 THEN verttulo = &kokontulo;

IF verttulo > &KunnAnsRaja3 THEN &tulos = &tulos - &KunnAnsPros3 * (verttulo -  &KunnAnsRaja3);

IF &tulos < 0 THEN &tulos = 0;

IF &tulos > verttulo THEN &tulos = verttulo;

DROP vahtulo verttulo;

%MEND KunnAnsVahS;


/* 12. Kunnallisverotuksen eläketulovähennys.
	   Parametreissa vuodesta 1983 lähtien.
	   Kaavassa otetaan huomioon tulokäsitteiden muutos. */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Kunnallisverotuksen eläketulovähennys
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	puoliso: On puoliso (1/0)
	oikeusyksi96: On ollut oikeus yksinäisen vähennykseen, vaikka puoliso vuonna 1996 (1/0)
	elaketulo: Eläketulo
	puhdansiotulo: Puhdas ansiotulo
	kokontulo: Kokonaistulo;

%MACRO KunnElTulVahS (tulos, mvuosi, minf, puoliso, oikeusyks96, elaketulo, puhdansiotulo, kokontulo)/STORE
DES = 'VERO: Kunnallisverotuksen eläketulovähennys';

%HAKU;

IF &mvuosi < 2010 THEN perusvah = &KunnPerEnimm;
ELSE perusvah = &KunnElVakio;

IF &puoliso = 0 THEN taysivah = &KunnElKerr * &KelaYks - perusvah;

IF &puoliso NE 0 THEN taysivah = &KunnElKerr * &KelaPuol - perusvah;

IF (&puoliso NE 0) AND (&oikeusyks96 NE 0) AND (&mvuosi > 1996) 
THEN taysivah = &KunnElKerr * &KelaYks - perusvah;

IF taysivah < 0 THEN taysivah = 0;

IF &mvuosi < 2002 THEN DO;
	%pyoristys100mk(utaysivah, taysivah);
END;

ELSE DO;
	%pyoristys10e(utaysivah, taysivah);
END;

/* Erilaiset tulokäsitteet ennen ja jälkeen vuoden 1993 uudistuksen */
iF &mvuosi >=  1993 THEN tulo = &puhdansiotulo;

ELSE IF &mvuosi < 1993 THEN tulo = &kokontulo;

/* Vähennystä pienennetään eri tavoin ennen vuotta 1989 ja v:sta 1989 lähtien */
IF (&mvuosi < 1989) THEN DO;

	IF tulo > (2 * perusvah + utaysivah) THEN utaysivah = utaysivah - (tulo - 2 * perusvah - utaysivah);

END;

ELSE IF (&mvuosi >= 1989) THEN DO;

	IF tulo > utaysivah THEN utaysivah = utaysivah - &KunnElPros * (tulo - utaysivah);

END;

IF (utaysivah < 0) OR (&mvuosi < 1983) THEN utaysivah = 0;

/* Vähennys ei voi olla eläketuloa suurempi */

vah = utaysivah;

IF vah > &elaketulo THEN vah = &elaketulo;

IF &elaketulo > 0 THEN vah = vah + &KunnVanhVah;

&tulos = vah;

DROP perusvah tulo taysivah utaysivah vah;

%MEND KunnElTulVahS;


/* 13. Kunnallisverotuksen opintorahavähennys.
	   Huom! Jos opisk-muuttuja <> 0, laskee opiskelijavähennyksen ennen vuotta 1993 */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Kunnallisverotuksen opintorahavähennys 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	opisk: On opiskelija (1/0)
	opraha: Opintoraha (veronalainen opintukilain mukainen opintoraha)
	anstulo: Ansiotulo
	puhdanstulo: Puhdas ansiotulo;

%MACRO KunnOpRahVahS (tulos, mvuosi, minf, opisk, opraha, anstulo, puhdanstulo)/STORE
DES = 'VERO: Kunnallisverotuksen opintorahavähennys';

%HAKU;

IF &mvuosi  < 1993 AND &opisk = 0 THEN &tulos = 0;

ELSE DO;

	IF &mvuosi  > 1992 AND &opraha = 0 THEN &tulos = 0;

	ELSE DO;

		IF &mvuosi < 1993 AND &opisk NE 0 THEN &tulos = &KunnOpiskVah;

	       IF &mvuosi > 1992 THEN DO;

			&tulos = &OpRahVah;

			tulo = &puhdanstulo;

			IF &mvuosi < 1995 THEN tulo = &anstulo;
			
			IF tulo > &OpRahVah THEN  &tulos =  &OpRahVah - &OpRahPros * (tulo  - &OpRahVah);

			IF &tulos < 0 THEN &tulos = 0;

			IF &tulos > &opraha THEN &tulos = &opraha;
		END;
	END;
END;

DROP tulo;

%MEND KunnOpRahVahS;


/* 14. Kunnallisverotuksen invalidivähennys */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Kunnallisverotuksen invalidivähennys 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	oikeus_1982: Oikeus eläketulosta tehtyyn invalidivähennykseen vuonna 1982 (1/0)
	invpros: Invaliditeettiprosentti eli haitta-aste (kokonaislukuna 0-100)
	puhdanstulo: Puhdas ansiotulo
	elaketulo: Eläketulo;

%MACRO KunnVerInvVahS(tulos, mvuosi, minf, oikeus_1982, invpros, puhdanstulo, elaketulo)/STORE
DES = 'VERO: Kunnallisverotuksen invalidivähennys';

%HAKU;

IF &invpros < 30 THEN &TULOS = 0;

ELSE DO;
	vah = 0.01 * &invpros *  &KunnInvVah;

	*Vuodesta 1983 lähtien vähennys vain muusta ansiotulosta kuin eläketulosta.
	 Siirtymäsäännös otettiin käyttöön 1984: vähennys myös eläketulosta, jos oikeus vähennykseen vuonna 1982;
	IF &mvuosi > 1982 THEN DO;

		IF vah > &puhdanstulo THEN vah = &puhdanstulo;

		IF &mvuosi = 1983 AND vah > MAX((&puhdanstulo - &elaketulo), 0)
		THEN vah = MAX((&puhdanstulo - &elaketulo), 0);

		IF &mvuosi > 1983 AND &oikeus_1982 = 0 AND vah > MAX((&puhdanstulo - &elaketulo), 0)
		THEN vah = MAX((&puhdanstulo - &elaketulo), 0);

	END;

	&tulos = vah;

END;

DROP vah;

%MEND KunnVerInvVahS;


/* 15. Kunnallisverotuksen perusvähennys */	

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Kunnallisverotuksen perusvähennys
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	kunnvertuloA: Kunnallisverotuksessa verotettava tulo ennen perusvähennystä;

%MACRO KunnPerVahS(tulos, mvuosi, minf, kunnvertuloA)/STORE
DES = 'VERO: Kunnallisverotuksen perusvähennys';

%HAKU;

IF &kunnvertuloA <= &KunnPerEnimm THEN &tulos = &kunnvertuloA;

ELSE &tulos =  &KunnPerEnimm - &KunnPerPros * (&kunnvertuloA - &KunnPerEnimm);

IF &tulos < 0 THEN &tulos = 0;

%MEND KunnPerVahS;


/* 16. Sairausvakuutusmaksu.
	   Makro ottaa huomioon 1990- ja 2000-luvun korotetut maksut sekä
	   muusta kuin työtulosta perittävät korotetut maksut 2006- */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Sairausvakuutusmaksu 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	kunnvertulo: Kunnallisverotuksessa verotettava tulo
	elaketulo: Eläketulo
	prahamtulo: Sair.vak. päivärahamaksun perusteena oleva tulo;

%MACRO SairVakMaksuS(tulos, mvuosi, minf, kunnvertulo, elaketulo, prahamtulo)/STORE
DES = 'VERO: Sairausvakuutusmaksu, lyhennetty kaava';

%HAKU;

&tulos = &SvPros * &kunnvertulo;

*Sairausvakuutusmaksun korotus, parametrien mukaan ollut voimassa 1991-1998;

IF &kunnvertulo >  &KorSvMaksuRaja 
THEN &tulos = (&SvPros + &SvKorotus) * (&kunnvertulo - &KorSvMaksuRaja) + &SvPros * &KorSvMaksuRaja;

*Eläketulon korotettu maksu, parametrien mukaan ollut voimassa 1993-2002.
 Huom! Samaa parametria &ElKorSvMaksu käytetään eri tarkoitukseen vuodesta 2006 lähtien;

elkor = 0;

IF &mvuosi < 2006 THEN DO;

	IF &kunnvertulo > &elaketulo THEN elkor = &ElKorSvMaksu * &elaketulo;
	ELSE elkor = &ElKorSvMaksu * &kunnvertulo;

END;

*Muusta kuin työtulosta perittävä korotettu maksu;

IF (&mvuosi > 2005) THEN DO;

	IF &kunnvertulo > &prahamtulo THEN elkor = &ElKorSvMaksu * (&kunnvertulo - &prahamtulo);

END;

&tulos = &tulos + elkor;

DROP elkor;

%MEND SairVakMaksuS;


/* 17. Kansaneläkevakuutusmaksu.
	   Huom! Poistunut lainsäädännnöstä ja parametreista vuonna 1996. */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Kansaneläkevakuutusmaksu 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	kunnvertulo: Kunnallisverotuksessa verotettava tulo
	elaketulo: Eläketulo;

%MACRO KanselVakMaksuS (tulos, mvuosi, kunnvertulo, elaketulo)/STORE
DES = 'VERO: Kansaneläkevakuutusmaksu, lyhennetty kaava';

%HAKU1;

*Eläketulon korotettu maksu, parametrien mukaan ollut voimassa 1993-1995;

&tulos = &KevPros * &kunnvertulo;

elkorkev = 0;

IF (&mvuosi < 1996) AND (&kunnvertulo > &elaketulo) THEN  elkorkev = &ElKorKevMaksu * &elaketulo;
ELSE elkorkev = &ElKorKevMaksu * &kunnvertulo;

&tulos = &tulos + elkorkev;

DROP elkorkev;

%MEND KanselVakMaksuS;


/* 18. Kunnallisvero */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Kunnallisvero 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	keskimm: Käytetäänkö keskimääräistä veroprosenttia (1/0)
	kunnpros: Kunnallisveroprosentti (desimaaliluku satakertaisena, esim. 18,75)
	kunnvertulo: Kunnallisverotuksessa verotettava tulo;

%MACRO KunnVeroS(tulos, mvuosi, keskimm, kunnpros, kunnvertulo)/STORE
DES = 'VERO: Kunnallisvero: joko keskimääräinen tai valittu veroprosentti';

%HAKU1;

IF &keskimm = 0 THEN &tulos = 0.01 * &kunnpros * &kunnvertulo;

ELSE &tulos = &KeskKunnPros * 0.01 * &kunnvertulo;

%MEND KunnVeroS;


/* 19. Kirkollisvero */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Kirkollisvero
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	keskimm: Käytetäänkö keskimääräistä veroprosenttia (1/0)
	kirkpros: Kirkollisveroprosentti (desimaaliluku satakertaisena, esim. 18,75)
	kunnvertulo: Kunnallisverotuksessa verotettava tulo;

%MACRO KirkVeroS(tulos, mvuosi, keskimm, kirkpros, kunnvertulo)/STORE
DES = 'VERO: Kirkollisvero: joko keskimääräinen tai valittu veroprosentti';

%HAKU1;

IF &keskimm = 0 THEN &tulos = 0.01 * &kirkpros * &kunnvertulo;

ELSE &tulos = &KirkVeroPros * 0.01 * &kunnvertulo;

%MEND KirkVeroS;


/* 20. Valtion verotuksen työtulovähennys.
	   Makro laskee myös palkkavähennyksen.
	   Huom! Poistunut vähennys, lainsäädännössä vuoteen 1988 asti. */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Valtionverotuksen työtulovähennys 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	ansiotulo: Ansiotulo
	palkkatulo: Palkkatulo;

%MACRO ValtTyoTuloVahS(tulos, mvuosi, minf, ansiotulo, palkkatulo)/STORE
DES = 'VERO: Valtionverotuksen työtulovähennys';

%HAKU;

temp = &ValtTyotVahPros * &ansiotulo;

IF temp > &ValtTyotVahYlaRaja THEN temp = &ValtTyotVahYlaRaja;

temp2 = &PalkVahPros * &palkkatulo;

IF temp2 > &PalkVahYlaRaja THEN temp2 = &PalkVahYlaRaja;

&tulos = temp + temp2;

DROP temp temp2;

%MEND ValtTyoTuloVahS;

/* 21. Valtionverotuksen eläketulovähennys.
	   Lainsäädännössä ja parametreissa vuodesta 1983 lähtien */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Valtionverotuksen eläketulovähennys 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	elaketulo: Eläketulo
	puhdansiotulo: Puhdas ansiotulo
	kokontulo: Kokonaistulo;

%MACRO ValtElTulVahS(tulos, mvuosi, minf, elaketulo, puhdansiotulo, kokontulo)/STORE
DES = 'VERO: Valtionverotuksen eläketulovähennys';

%HAKU;

%ValtTyoTuloVahS(ttvah, &mvuosi, &minf, ( &KelaYks), 0);

taysivah = &ValtElKerr * ( &KelaYks) - ttvah -  &ValtAlaRaja;

IF taysivah < 0 THEN taysivah = 0;

IF &mvuosi < 2002 THEN DO;
	%pyoristys100mk(utaysivah, taysivah);
END;

ELSE DO;
	%pyoristys10e(utaysivah, taysivah);
END;

tulo = &puhdansiotulo;

IF &mvuosi < 1993 THEN tulo = &kokontulo;

IF tulo > utaysivah THEN utaysivah = utaysivah - &ValtElPros * (tulo - utaysivah);

IF utaysivah < 0 THEN utaysivah = 0;

IF utaysivah > &elaketulo THEN utaysivah = &elaketulo;

&tulos = utaysivah;

DROP ttvah taysivah utaysivah tulo;

%MEND ValtElTulVahS;


/* 22. Valtionverotuksen ansiotulovähennys/työtulovähennys.
	   Huom! Verosta tehtävä vähennys.
	   Lainsäädännössä vuodesta 2006 lähtien. Vähennyksen nimeä muutettu tuloverolaissa. */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Valtionverotuksen ansiotulovähennys/työtulovähennys
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	tyotulo: Työtulo
	puhdanstulo: Puhdas ansiotulo;

%MACRO ValtVerAnsVahS(tulos, mvuosi, minf, tyotulo, puhdanstulo)/STORE
DES = 'VERO: Valtionverotuksen ansiotulovähennys/työtulovähennys (vähennys verosta)';

%HAKU;

&tulos = 0;

IF &tyotulo > &ValtAnsAlaRaja THEN &tulos = &ValtAnsPros1 * (&tyotulo -  &ValtAnsAlaRaja);

IF &tulos > &ValtAnsEnimm THEN &tulos = &ValtAnsEnimm;

IF &puhdanstulo > &ValtAnsYlaRaja THEN &tulos = &tulos - &ValtAnsPros2 * (&puhdanstulo - &ValtAnsYlaRaja);

IF &tulos < 0 THEN &tulos = 0;

%MEND ValtVerAnsVahS;


/* 23. Valtionverotuksen invalidivähennys.
	   Huom! Verosta tehtävä vähennys.
	   Makro laskee myös laissa ennen vuotta 1983 olleen vanhuusvähennyksen, jos elaketulo > 0 */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Valtionverotuksen invalidivähennys
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	invpros: Invaliditeettiprosentti eli haitta-aste, kokonaislukuna 0 - 100
	elaketulo: Eläketulo;

%MACRO ValtVerInvVahS(tulos, mvuosi, minf, invpros, elaketulo)/STORE
DES = 'VERO: Valtionverotuksen invalidivähennys (vähennys verosta)';

%HAKU;

IF &invpros < 30 THEN &tulos = 0;

ELSE &tulos = 0.01 * &invpros * &ValtInvVah;

IF &elaketulo > 0 THEN &tulos = &tulos + &ValtVanhVah;

%MEND ValtVerInvVahS;


/* 24. Valtionverotuksen elatusvelvollisuusvähennys.
	   Huom! Verosta tehtävä vähennys */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Valtionverotuksen elatusvelvollisuusvähennys
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	evlapsia: Elatusvelvollisten lasten lukumäärä
	elmaksut: Elatusmaksut;

%MACRO ValtVerElVelvVahS(tulos, mvuosi, minf, evlapsia, elmaksut)/STORE
DES = 'VERO: Valtionverotuksen elatusvelvollisuusvähennys (vähennys verosta)';

%HAKU;

IF &evlapsia = 0 OR &elmaksut = 0 THEN &tulos = 0;

ELSE DO;

	&tulos = &ElVelvPros * &elmaksut;

	IF &tulos > &evlapsia * &ValtElVelvVah THEN &tulos = &evlapsia * &ValtElVelvVah;

END;

%MEND ValtVerElVelvVahS;


/* 25. Lahjoitusvähennys
	   Väliaikainen vähennys laissa vuodesta 2009 lähtien */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Lahjoitusvähennys 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	lahjoitus: Ilmoitettu lahjoitusvähennykseen oikettava lahjoitus;

%MACRO LahjoitusVahS(tulos, mvuosi, minf, lahjoitus)/STORE
DES = "VERO: Lahjoitusvähennys, väliaikainen vähennys 2009-";

%HAKU;

IF &lahjoitus > &LahjVahEnimm THEN &tulos = &LahjVahEnimm;

ELSE IF &lahjoitus < &LahjVahVahimm THEN &tulos = 0;

ELSE &tulos = &lahjoitus;

%MEND LahjoitusVahS;


/* 26. Valtion tulovero */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Valtion tulovero 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	tulo = Valtion verotuksessa verotettava tulo eli tulo vähennysten jälkeen 
	      (vuodesta 1993 lähtien koskee vain ansiotuloa);

%MACRO ValtTuloVeroS(tulos, mvuosi, minf, tulo)/STORE
DES = 'VERO: Valtion tulovero (veroasteikko)';

%HAKU;

IF &tulo <= 0 THEN &tulos = 0;

ELSE DO;

	IF &tulo GE  &Raja12 THEN
		&tulos =  &Vakio12 + &Pros12 * (&tulo -  &Raja12);

	ELSE IF &tulo GE  &Raja11 THEN
		&tulos =  &Vakio11 + &Pros11 * (&tulo -  &Raja11);

	ELSE IF &tulo GE  &Raja10 THEN
		&tulos =  &Vakio10 + &Pros10 * (&tulo -  &Raja10);

	ELSE IF &tulo GE  &Raja9 THEN
		&tulos =  &Vakio9 + &Pros9 * (&tulo -  &Raja9);

	ELSE IF &tulo GE  &Raja8 THEN
		&tulos =  &Vakio8 + &Pros8 * (&tulo -  &Raja8);

	ELSE IF &tulo GE  &Raja7 THEN
		&tulos =  &Vakio7 + &Pros7 * (&tulo -  &Raja7);

	ELSE IF &tulo GE  &Raja6 THEN
		&tulos =  &Vakio6 + &Pros6 * (&tulo -  &Raja6);

	ELSE IF &tulo GE  &Raja5 THEN
		&tulos =  &Vakio5 + &Pros5 * (&tulo -  &Raja5);

	ELSE IF &tulo GE  &Raja4 THEN
		&tulos =  &Vakio4 + &Pros4 * (&tulo -  &Raja4);

	ELSE IF &tulo GE  &Raja3 THEN
		&tulos =  &Vakio3 + &Pros3 * (&tulo -  &Raja3);

	ELSE IF &tulo GE  &Raja2 THEN
		&tulos =  &Vakio2 + &Pros2 * (&tulo -  &Raja2);

	ELSE IF &tulo GE  &Raja1 THEN
		&tulos =  &Vakio1 + &Pros1 * (&tulo -  &Raja1);

END;

%MEND ValtTuloVeroS;


/* 27. Tuloverot yksinkertaisessa perustapauksessa, kun tulot ovat vain palkkatuloa */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Tuloverot
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	palkkatulo: Palkkatulo;

%MACRO TuloVerot_SimpleS(tulos, mvuosi, minf, palkkatulo)/STORE
DES = 'VERO: Tuloverot palkkaverotuksen yksinkertaisessa perustapauksessa';


%TulonHankKulutS(tulhanksums2, &mvuosi, &minf, &palkkatulo, &palkkatulo, 0, 0, 0, 0);

puhdanstulos2 = &palkkatulo - tulhanksums2;

IF puhdanstulos2 < 0 THEN puhdanstulos2 = 0;

%TyoElMaksuS (elmaksus2, &mvuosi, 0, &palkkatulo);

%TyotMaksuS(tyotvaks2, &mvuosi, &palkkatulo);

%SvPrahaMaksuS(spmaksus2, &mvuosi, &palkkatulo);

%KunnAnsVahS(kunnanss2, &mvuosi, &minf, puhdanstulos2, &palkkatulo, &palkkatulo, &palkkatulo, &palkkatulo);

kunnvtuloAs2 = puhdanstulos2 - elmaksus2 - tyotvaks2 - spmaksus2 - kunnanss2;

IF kunnvtuloAs2 < 0 THEN kunnvtuloAs2 = 0;

%KunnPerVahS (pervahs2, &mvuosi, &minf, kunnvtuloAs2);

kunnvertulos2 = kunnvtuloAs2 - pervahs2;

%SairVakMaksuS(svmaksus2, &mvuosi, &minf, kunnvertulos2, 0, &palkkatulo);

%KansElVakMaksuS(kevmaksus2, &mvuosi, kunnvertulos2, 0);

%KunnVeroS(kunnveros2, &mvuosi, 1, 18, kunnvertulos2);

%ValtTyoTuloVahS(valttvahs2, &mvuosi, &minf, &palkkatulo, &palkkatulo);

valtvertulos2 = puhdanstulos2 - elmaksus2 - tyotvaks2 - spmaksus2 - valttvahs2;

IF valtvertulos2 < 0 THEN valtvertulos2 = 0;

%ValtTuloVeroS(valttuloveros2, &mvuosi, &minf, valtvertulos2);

%ValtVerAnsVahS(valtansvahss2, &mvuosi, &minf,  &palkkatulo, puhdanstulos2);

valttuloveros2 = valttuloveros2 - valtansvahss2;

&tulos = elmaksus2 + tyotvaks2 + spmaksus2 + MAX(svmaksus2 + kevmaksus2 + kunnveros2 + valttuloveros2, 0);

DROP tulhanksums2 puhdanstulos2 elmaksus2 tyotvaks2 spmaksus2 kunnanss2 kunnvtuloAs2 pervahs2
	 kunnvertulos2 svmaksus2 kevmaksus2 kunnveros2 valttvahs2 valtvertulos2 valttuloveros2 valtansvahss2;

%MEND TuloVerot_SimpleS;



%MACRO TuloVerot_Simple_Palkka_OsinkoS(tulos, mvuosi, minf, palkkatulo, osinkotulo)/STORE
DES = 'VERO: Tuloverot palkkaverotuksen yksinkertaisessa perustapauksessa';

%TulonHankKulutS(tulhanksums2, &mvuosi, &minf, &palkkatulo, &palkkatulo, 0, 0, 0, 0);

puhdanstulos2 = SUM(&palkkatulo, &osinkotulo) - tulhanksums2;

IF puhdanstulos2 < 0 THEN puhdanstulos2 = 0;

%TyoElMaksuS (elmaksus2, &mvuosi, 0, &palkkatulo);

%TyotMaksuS(tyotvaks2, &mvuosi, &palkkatulo);

%SvPrahaMaksuS(spmaksus2, &mvuosi, &palkkatulo);

%KunnAnsVahS(kunnanss2, &mvuosi, &minf, puhdanstulos2, SUM(&palkkatulo, &osinkotulo), SUM(&palkkatulo, &osinkotulo), &palkkatulo, SUM(&palkkatulo, &osinkotulo));

kunnvtuloAs2 = puhdanstulos2 - elmaksus2 - tyotvaks2 - spmaksus2 - kunnanss2;

IF kunnvtuloAs2 < 0 THEN kunnvtuloAs2 = 0;

%KunnPerVahS (pervahs2, &mvuosi, &minf, kunnvtuloAs2);

kunnvertulos2 = kunnvtuloAs2 - pervahs2;

%SairVakMaksuS(svmaksus2, &mvuosi, &minf, kunnvertulos2, 0, &palkkatulo);

%KansElVakMaksuS(kevmaksus2, &mvuosi, kunnvertulos2, 0);

%KunnVeroS(kunnveros2, &mvuosi, 1, 18, kunnvertulos2);

%ValtTyoTuloVahS(valttvahs2, &mvuosi, &minf, &palkkatulo, &palkkatulo);

valtvertulos2 = puhdanstulos2 - elmaksus2 - tyotvaks2 - spmaksus2 - valttvahs2;

IF valtvertulos2 < 0 THEN valtvertulos2 = 0;

%ValtTuloVeroS(valttuloveros2, &mvuosi, &minf, valtvertulos2);

%ValtVerAnsVahS(valtansvahss2, &mvuosi, &minf,  SUM(&palkkatulo, &osinkotulo), puhdanstulos2);

valttuloveros2 = valttuloveros2 - valtansvahss2;

&tulos = elmaksus2 + tyotvaks2 + spmaksus2 + MAX(svmaksus2 + kevmaksus2 + kunnveros2 + valttuloveros2, 0);

DROP tulhanksums2 puhdanstulos2 elmaksus2 tyotvaks2 spmaksus2 kunnanss2 kunnvtuloAs2 pervahs2
	 kunnvertulos2 svmaksus2 kevmaksus2 kunnveros2 valttvahs2 valtvertulos2 valttuloveros2 valtansvahss2;

%MEND TuloVerot_Simple_Palkka_OsinkoS;



%MACRO TuloVerot_Simple_OsinkoS(tulos, mvuosi, minf, osinkotulo)/STORE
DES = 'VERO: Tuloverot ansiotulo-osingosta, jos se on ainoa tulolaji';

%KunnAnsVahS(kunnanss2, &mvuosi, &minf, &osinkotulo, &osinkotulo, &osinkotulo, &osinkotulo, &osinkotulo);

kunnvtuloAs2 = &osinkotulo - kunnanss2;

IF kunnvtuloAs2 < 0 THEN kunnvtuloAs2 = 0;

%KunnPerVahS (pervahs2, &mvuosi, &minf, kunnvtuloAs2);

kunnvertulos2 = kunnvtuloAs2 - pervahs2;

%SairVakMaksuS(svmaksus2, &mvuosi, &minf, kunnvertulos2, 0, 0);

%KansElVakMaksuS(kevmaksus2, &mvuosi, kunnvertulos2, 0);

%KunnVeroS(kunnveros2, &mvuosi, 1, 18, kunnvertulos2);

valtvertulo = &osinkotulo;

%ValtTuloVeroS(valttuloveros2, &mvuosi, &minf, valtvertulo);

%ValtVerAnsVahS(valtansvahss2, &mvuosi, &minf,  &osinkotulo, &osinkotulo);

valttuloveros2 = valttuloveros2 - valtansvahss2;

&tulos = MAX(svmaksus2 + kevmaksus2 + kunnveros2 + valttuloveros2, 0);

DROP kunnanss2 kunnvtuloAs2 pervahs2
	 kunnvertulos2 svmaksus2 kevmaksus2 kunnveros2 valttuloveros2 valtansvahss2;

%MEND TuloVerot_Simple_OsinkoS;


/* 28. Marginaaliveroaste yksinkertaisessa perustapauksessa */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Marginaaliveroaste 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	palkkatulo: Palkkatulo
	askel: Tuloaskel, jolla tuloa korotetaan marginaaliveroastetta laskettaessa;

%MACRO TuloVerot_SimpleMargS(tulos, mvuosi, minf, palkkatulo, askel)/STORE
DES = 'VERO: Marginaaliveroaste palkkaverotuksen yksinkertaisessa perustapauksessa';

%TuloVerot_SimpleS(temp1, &mvuosi, &minf, &palkkatulo);

%TuloVerot_SimpleS(temp2, &mvuosi, &minf, (&palkkatulo + &askel));

&tulos = (temp2-temp1) / &askel;

DROP temp1 temp2;

%MEND TuloVerot_SimpleMargS;


/* 29. Bruttokuukausitulo johdettuna nettokuukausitulosta,
	   kun tulo on palkkatuloa ja erityisiä vähennyksiä ei ole */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Bruttotulo, e/kk
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	nettokuuktulo: Nettopalkka, e/kk;

%MACRO BruttotuloS(tulos, mvuosi, minf, nettokuuktulo)/STORE
DES = 'VERO: Nettokuukausitulosta johdettu bruttotulo palkansaajalla';

IF &nettokuuktulo > 100000 THEN &tulos = -1;

ELSE DO;

	DO i = 1 TO 20 UNTIL (i*10000 - testi/12 >= &nettokuuktulo);

		%TuloVerot_SimpleS(testi, &mvuosi, &minf, 12*i*10000);

	END;

	DO j = -9 TO 10 UNTIL (i*10000 + j*1000 - testi/12 >= &nettokuuktulo);

		%TuloVerot_SimpleS(testi, &mvuosi, &minf, 12*(i*10000 + j*1000));

	END;

	DO k = -9 TO 10 UNTIL (i*10000 + j*1000 + k* 100 - testi/12 >= &nettokuuktulo);

		%TuloVerot_SimpleS(testi, &mvuosi, &minf, 12*(i*10000 + j*1000 + k*100));

	END;
	DO l = -9 TO 10 UNTIL (i*10000 + j*1000 + k* 100 + l*10 - testi/12 >= &nettokuuktulo);

		%TuloVerot_SimpleS(testi, &mvuosi, &minf, 12*(i*10000 + j*1000 + k*100 + l*10));

	END;

	DO m = -9 TO 10 UNTIL (i*10000 + j*1000 + k* 100 + l*10 + m -testi/12 >= &nettokuuktulo);

		%TuloVerot_SimpleS(testi, &mvuosi, &minf, 12*(i*10000 + j*1000 + k*100 + l*10 + m));

	END;

	DO n = -9 TO 10 UNTIL (i*10000 + j*1000 + k* 100 + l*10 + m + n/10 -testi/12 >= &nettokuuktulo);

		%TuloVerot_SimpleS(testi, &mvuosi, &minf, 12*(i*10000 + j*1000 + k*100 + l*10 + m + n/10));

	END;

	&tulos = i*10000 + j*1000 + k* 100 + l*10 + m + n/10;

END;

DROP i j k l m n testi;

%MEND BruttotuloS;


/* 30. Tuloverot yksinkertaisessa perustapauksessa, kun tulot ovat pelkästään eläketuloa */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Eläketulon verot 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	puoliso: On puoliso (1/0)
	elaketulo: Eläketulo;

%MACRO TuloVerot_Simple_ElakeS(tulos, mvuosi, minf, puoliso, elaketulo)/STORE 
DES = 'VERO: Eläketulon verot yksinkertaisessa perustapauksessa';

%KunnElTulVahS (elvahk, &mvuosi, &minf, &puoliso, 0, &elaketulo, &elaketulo, &elaketulo);

%KunnPerVahS (pervahse, &mvuosi, &minf, MAX(&elaketulo - elvahk, 0));

kunnvertuloe = &elaketulo - elvahk - pervahse;

IF kunnvertuloe < 0 THEN kunnvertuloe = 0;

%SairVakMaksuS(svmaksuse, &mvuosi, &minf, kunnvertuloe, &elaketulo, 0);

%KansElVakMaksuS(kevmaksuse, &mvuosi, kunnvertuloe, &elaketulo);

%KunnVeroS(kunnverose, &mvuosi, 1, 18, kunnvertuloe);

%ValtTyoTuloVahS(valttvahse, &mvuosi, &minf, &elaketulo, 0);

%ValtElTulVahS(valtelvahse, &mvuosi, &minf, &elaketulo, &elaketulo, &elaketulo);

valtvertuloE = &elaketulo - valttvahse - valtelvahse;

IF valtvertuloE < 0 THEN valtvertuloE = 0;

%ValtTuloVeroS(valttuloverose, &mvuosi, &minf, valtvertuloE);

%ElakeLisaVeroS(elakelvero, &mvuosi, &minf, &elaketulo, valtelvahse);

&tulos = svmaksuse + kevmaksuse + kunnverose + valttuloverose + elakelvero;

DROP elvahk pervahse kunnvertuloe svmaksuse kevmaksuse kunnverose valttvahse valtelvahse valtvertuloE valttuloverose elakelvero;

%MEND TuloVerot_Simple_ElakeS;


/* 31. Tuloverot yksinkertaisessa perustapauksessa, kun tulot
	   ovat pelkästään työttömyysturvaa tai muuta vastaavaa sosiaalietuutta (ei työtuloa eikä eläkettä) */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Päivärahatulon tai muun ansiotulon verot 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	prahatulo: Päivärahatulo, esim. työttömyysturva;

%MACRO TuloVerot_Simple_PRahaS(tulos, mvuosi, minf, prahatulo)/STORE
DES = 'VERO: Päivärahatulon tai muun ansiotulon verot yksinkertaisessa perustapauksessa';

%KunnAnsVahS(kunnanss, &mvuosi, &minf, &prahatulo, &prahatulo, 0, 0, &prahatulo);

%KunnPerVahS (pervahsp, &mvuosi, &minf, MAX(&prahatulo - kunnanss,0));

kunnvertulop = &prahatulo - kunnanss - pervahsp;

IF kunnvertulop < 0 THEN kunnvertulop = 0;

%SairVakMaksuS(svmaksusp, &mvuosi, &minf, kunnvertulop, 0, 0);

%KansElVakMaksuS(kevmaksusp, &mvuosi, kunnvertulop, 0);

%KunnVeroS(kunnverosp, &mvuosi, 1, 18, kunnvertulop);

%ValtTyoTuloVahS(valttvahsp, &mvuosi, &minf, &prahatulo, 0);

valtvertulop = &prahatulo - valttvahsp;

IF valtvertulop < 0 THEN valtvertulop = 0;

%ValtTuloVeroS(valttuloverosp, &mvuosi, &minf, valtvertulop);

&tulos = svmaksusp + kevmaksusp + kunnverosp + valttuloverosp;

DROP kunnanss pervahsp kunnvertulop svmaksusp kevmaksusp kunnverosp valtvertulop valttuloverosp valttvahsp;

%MEND TuloVerot_Simple_PRahaS;


/* 32. Pääomatulo-osuus: jaettavan yritystulon tai muun kuin pörssiyhtiön osingon tai 
	   siihen liittyvän yhtiöveron hyvityksen pääomatulo-osuus. */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Pääomatulo-osuus 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	tulolaji: 1 = Jaettava yritystulos, 2 = osinkotulo, 3 = yhtiöveron hyvitys
	vaiht: 1/0, jos <> 0 jos on valittu vaihtoehtoinen alhaisempi pääomatulo-osuus
	tulo: Tulo, jota jaetaan eri osiin
	yritvarall: Yrityksen nettovarallisuus tai osakkeiden arvo osinkoja jaettaessa
	palkat: Palkkasumma;

%MACRO PomaOsuusS(tulos, mvuosi, tulolaji, vaiht, tulo, yritvarall, palkat) /STORE
DES = 'VERO: Jaettavan yritystulon tai muun kuin pörssiyhtiön osingon tai 
siihen liittyvän yhtiöveron hyvityksen pääomatulo-osuus';

%HAKU1;

tempx = 0;

IF &tulo = 0 THEN &tulos = 0;

ELSE DO;

	SELECT (&tulolaji);

	*JAETTAVA YRITYSTULO;

	WHEN (1) DO; 

		tmposuus = &POOsuus;

		/* Voidaan valita vaihtoehtoisesti alempi pääomatulon osuus (2001 -) */
			
		IF (&vaiht NE 0) THEN tmposuus = &VaihtPOOsuus;
					
		/* Yritysvarallisuuteen lisätään osuus palkoista (1997 -) */

		varall = &yritvarall + tmposuus * &palkat;

		*Mahdollinen pääomatulon osuus tulosta;

		tempx = tmposuus * varall;

		*Pääomatulo ei voi olla koko tuloa suurempi;

		IF tempx > &tulo THEN tempx = &tulo;

		END;	
	
	*OSINKOTULO EI-JULKISESTI NOTEERATUISTA YHTIÖISTÄ;

	WHEN (2) DO; 

		*Kriteerinä on osingon ja yhtiöveron hyvityksen suhde yritysvarallisuuden
		 määriteltyyn osuuteen;
			
		%YhtHyvS(hyvit, &mvuosi, &tulo);

		summa = &tulo + hyvit;

		tempx = &OsPOOsuus * &yritvarall;

		IF tempx >= summa THEN temp = &tulo;

		ELSE tempx = tempx * &tulo / summa;
			
	END;

	*YHTIÖVERON HYVITYS;

	WHEN (3) DO; 

	%YhtHyvS(hyvit, &mvuosi, &tulo);

		summa = &tulo + hyvit;

		tempx = &OsPOOsuus * &yritvarall;
			
	 	IF tempx >= summa THEN temp = hyvit;
		
		ELSE  tempx = tempx * hyvit / summa;

	END;

END;

&tulos = tempx;

END;

DROP tempx summa tmposuus varall;

%MEND PomaOsuusS;


/* 33. Osinkojen jako eri tulolajeihin uudessa järjestelmässä 2005- */ 

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Tulolajiin kuuluvan osingon määrä 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	ospkorko: Onko tulo osuuspäääoman korkoa (1/0)
	tulolaji: 1 = verovapaa, 2 = pääomatulo, 3 = ansiotulo
	julkosinko: Julkisesti noteeratusta yhtiöstä saatu osinko
	eijulkosinko: Ei julkisesti noteeratusta yhtiöstä saatu osinko
	osakkarvo: Osakkeiden arvo;

%MACRO OsinkojenJakoS (tulos, mvuosi, minf, ospkorko, tulolaji, julkosinko, eijulkosinko, osakkarvo)/STORE
DES = 'VERO: Osinkotulojen jakaminen pääomatuloksi, ansiotuloiksi ja verottomiksi tuloksi';

%HAKU;

temp = 0;
%LET huojosuus = 1;

*Jos ei osinkoja, annetaan heti tulokseksi 0;
IF &julkosinko + &eijulkosinko = 0 THEN &tulos = 0;

ELSE DO;

	ospkorverovap = &OspKorVeroVap; *Osuuspääoman korkojen verovapaa osuus;

	*Lähtökohtana ei-julk. noteeratuissa yhtiöissä tietty suhde osakkeiden arvoon.
 	 Se määrittelee, miten osingot jaetaan pääoma- ja ansiotuloiksi;
	
	vert = &HenkYhtOsVapOsuus * &osakkarvo;
	
	*Jos osakkeiden arvoa ei tiedetä, voidaan muuttujalle osakkaarvo antaa
  	 negatiivinen arvo, jolloin oletetaan, että ei-julkisesti noteeratun
 	 yhtiön osinko on kokonaisuudessaan pääomatuloa;

	IF &EiJulkOsinko > 0 AND &OsakkArvo < 0 THEN vert =&EiJulkOsinko;

	SELECT (&tulolaji);

	*VEROVAPAAT OSINGOT;

	WHEN (1) DO;

		*Ennen vuotta 2005 verovapaita osinkoja ei ole;
		IF  (&mvuosi  < 2005) THEN temp = 0; 

		ELSE DO;
			*Suhde kiinteään euromääräiseen rajaan ja tuottorajaan;
			IF vert > &HenkYhtVapRaja THEN DO;

				IF (&eijulkosinko <= vert AND &eijulkosinko <= &HenkYhtVapRaja) THEN temp = &eijulkosinko;

				IF (&eijulkosinko <= vert AND &eijulkosinko > &HenkYhtVapRaja) THEN temp = &HenkYhtVapRaja + (1 - &JulkPOOsuus)*(&eijulkosinko - &HenkYhtVapRaja);

				IF &eijulkosinko > vert THEN temp = &HenkYhtVapRaja + (1 - &JulkPOOsuus)*(vert - &HenkYhtVapRaja) ;
			END;

			ELSE IF vert <= &HenkYhtVapRaja THEN temp = MIN(vert, &eijulkosinko);


			
			*Muuten verotonta on myös rajan ylittävästä osingosta parametrin määräämä prosenttiosuus;
			IF &eijulkosinko > vert THEN  temp = SUM(temp, (1 - &JulkPOOsuus) * (&eijulkosinko - vert));

			IF &mvuosi = 2014 then do;

				IF vert > &HenkYhtVapRaja THEN DO;

					IF (&eijulkosinko <= vert AND &eijulkosinko <= &HenkYhtVapRaja) THEN temp = (1 - &huojosuus) * &eijulkosinko;

					IF (&eijulkosinko <= vert AND &eijulkosinko > &HenkYhtVapRaja) THEN temp =(1 - &huojosuus)* &HenkYhtVapRaja + (1 - &JulkPOOsuus) * (&eijulkosinko - &HenkYhtVapRaja);

					IF &eijulkosinko > vert THEN temp = (1 - &huojosuus)* &HenkYhtVapRaja + (1 - &JulkPOOsuus) * (vert - &HenkYhtVapRaja);

				END;

			    ELSE IF vert <= &HenkYhtVapRaja THEN temp = (1 - &huojosuus) * MIN(vert, &eijulkosinko);

				IF &eijulkosinko > vert THEN  temp = SUM(temp, (1 - &henkyhtosansosuus) * (&eijulkosinko - vert));
			END;
				

			*Jos kyse ei ole osuuspääoman korosta, sille ei lasketa verovapaata osuutta;
			IF &ospkorko = 0 THEN ospkorverovap = 0;
			
			*Tutkitaan noteeratun osingon tai osuuspääoman koron suhde rajaan sekä lasketaan prosenttiosuus;
			IF &julkosinko <= ospkorverovap THEN temp = SUM(temp, &julkosinko);

			ELSE temp = SUM(temp, (1 - &JulkPOOsuus) * (&julkosinko - ospkorverovap) + ospkorverovap);
			
		END;
	END;

	*PÄÄOMATULOT;

	WHEN (2) DO;

		*Lasketaan ei-julkosinkgon pääomatuloiksi laskettava osuus makron PomaOsuusS avulla;
		%PomaOsuusS(paaomaosuus, &mvuosi, 2, 0, &eijulkosinko, &osakkarvo, 0);

		*Ennen vuotta 2005 edellä laskettu osuus on pääomatuloa ja se lisätään julkisesti
		 noteerattujen yhtiöiden osinkoihin;
		IF &mvuosi < 2005 THEN &tulos = &JulkOsinko + paaomaosuus;

		ELSE DO;
			*Jos julkosinko on osuuspääoman korkoa kiinteän rajan ylittävä osuus lasketaan pääomatuloksi;
			IF &ospkorko NE 0 THEN  temp  = &JulkPOosuus * MAX(&julkosinko - ospkorverovap, 0);

			*Muuten koko osingosta vastaava souus;
			ELSE temp = &JulkPOOsuus * &julkosinko;

			*Ei-julkisesti noteerattujen osakkeiden osingoista katsotaan ENSIN kiinteän rajan
			 ylittävä osuus, josta määrätty prosenttiosuus on verollista;

			IF vert > &HenkYhtVapRaja THEN  DO;
				IF &eijulkosinko > &HenkYhtVapRaja AND &eijulkosinko <= vert THEN temp = SUM(temp, &JulkPOOsuus * (&eijulkosinko - &HenkYhtVapRaja));
				IF &eijulkosinko > vert THEN temp = SUM(temp, &JulkPOOsuus * (vert - &HenkYhtVapRaja));
			END;
			
			IF &mvuosi = 2014 THEN DO;
				IF vert > &HenkYhtVapRaja THEN  DO;
					IF &eijulkosinko <= &HenkYhtVapRaja THEN temp = SUM(temp, &HUOJOSUUS * &eijulkosinko);
					IF &eijulkosinko > &HenkYhtVapRaja AND &eijulkosinko <= vert THEN temp = SUM(temp, &JulkPOOsuus * (&eijulkosinko - &HenkYhtVapRaja) + &HUOJOSUUS * &HenkYhtVapRaja);
					IF &eijulkosinko > vert THEN temp = SUM(temp, &JulkPOOsuus * (vert - &HenkYhtVapRaja) + &HuojOsuus * &HenkYhtVapRaja);
				END;
				ELSE temp = SUM(temp, &HUOJOSUUS * MIN (&eijulkosinko, vert));
			END;

	
		  END;
	END;

	*ANSIOTULOT;
	
	WHEN (3) DO;

		*Ennen vuotta 2005 katsotaan ei-julk. noteerattujen osakkeiden osinkojen pääomatulo-osuus
		 ja vähennetään se koko osingosta;
		IF &mvuosi < 2005 THEN DO;
			%PomaOsuusS(paaomaosuus, &mvuosi, 2, 0, &eijulkosinko, &osakkarvo, 0);
			temp = &eijulkosinko - paaomaosuus;
		END;

		*Muuten katsotaan kiinteän rajan ylittävästä osuudesta ansiotulojen osuus;
		IF &mvuosi > 2004 AND &eijulkosinko > vert THEN temp = &henkyhtosansosuus * (&eijulkosinko - vert);

		ELSE temp = 0;
	END;

	OTHERWISE temp = 0;

	END;
END;

&tulos = temp;

DROP temp vert paaomaosuus;
%MEND OsinkojenJakoS;


/* 34. Alijäämähyvitys */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Alijäämähyvitys
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	puoliso: Onko puoliso (1/0)
	lapsia: Alaikäisten lasten lukumäärä
	potulo: Veronalainen pääomatulo
	povahenn: Pääomatulon hankkimiseen liittyvät vähennykset
	askorot: Asuntolainan korot
	ensaskorot: Ensiasunnon lainaan kohdistuvat korot
	kulkorot: Kulutusluoton korot (vaikutusta vain 1994 ja 1995)
	puolalij: Puolisolta siirtyvä alijäämähyvitys;

%MACRO AlijHyvS(tulos, mvuosi, minf, puoliso, lapsia, potulo, povahenn, askorot, ensaskorot, kulkorot, puolalij)/STORE
DES = 'VERO: Alijäämähyvitys';

%HAKU;

vahlapsia = MIN (&lapsia, 2);

alijenimm = (&AlijYlaRaja + vahlapsia * &AlijLapsiKor);

IF (&puoliso NE 0) THEN alijenimm = alijenimm + &puolalij;

/* Kulutusluottojen korot eivät vaikuta alijäämähyvitykseen vuoden 1994 jälkeen */

kulkorotx = &KulKorot;

IF &mvuosi > 1994 THEN kulkorotx = 0;

temp = 0;
	
IF &potulo = 0 THEN DO;

	temp = &PaaomaVeroPros * kulkorotx;

	IF temp >  &AlijKulLuot THEN temp =  &AlijKulLuot;

	temp = temp + &PaaomaVeroPros * &povahenn + &AsKorkoOsuus * (&PaaomaVeroPros  * &askorot + &EnsAsKor * &ensaskorot);

END;

IF &potulo > 0 AND &potulo <= &povahenn THEN DO;

	temp = &PaaomaVeroPros * kulkorotx;

	IF temp >  &AlijKulLuot THEN temp =  &AlijKulLuot;

	temp = temp + &PaaomaVeroPros *(&povahenn - &potulo) +  &AsKorkoOsuus *(&PaaomaVeroPros * &askorot + &EnsAsKor  * &ensaskorot);

END;
IF (&potulo > &povahenn) AND (&potulo <= &povahenn + kulkorotx) THEN DO;

	 temp = &PaaomaVeroPros * (&povahenn + kulkorotx - &potulo);

	 IF temp >  &AlijKulLuot THEN temp =  &AlijKulLuot;

	 temp = temp +  &AsKorkoOsuus * (&PaaomaVeroPros * &askorot + &EnsAsKor  * &ensaskorot);

END;

IF (&potulo > &povahenn + kulkorotx) AND (&potulo <= &povahenn + kulkorotx +  &AsKorkoOsuus * &askorot) THEN DO;

     temp = &PaaomaVeroPros *  (&povahenn + kulkorotx + &askorot - &potulo);

	 temp = temp +  &AsKorkoOsuus * &EnsAsKor * &ensaskorot;
END;

IF (&potulo > &povahenn + kulkorotx +  &AsKorkoOsuus * &askorot) AND (&potulo <= &povahenn + kulkorotx +  &AsKorkoOsuus * (&askorot + &ensaskorot)) THEN DO;

	 temp =  &AsKorkoOsuus * &EnsAsKor * (&povahenn + kulkorotx + &askorot + &ensaskorot - &potulo);

END;

IF (&potulo > &povahenn + kulkorotx +  &AsKorkoOsuus * &askorot +  &AsKorkoOsuus * &ensaskorot) THEN temp = 0;

IF temp > alijenimm THEN temp = alijenimm;

&tulos = temp;

DROP temp;

%MEND AlijHyvS;


/* 35. Erityinen alijäämähyvitys.
	   Lainsäädännössä vuodesta 2005 lähtien */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Erityinen alijäämähyvitys 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	potulo: Pääomatulot
	povahenn: Pääomatulon hankkimiseen liittyvät vähennykset
	askorot: Asuntolainan korot
	ensaskorot: Ensiasunnon lainaan kohdistuvat korot
	elvakuutusmaksu: Pääomatulosta vähennettävät vähennyskelpoiset vapaaehtoiset eläkevakuutusmaksut;

%MACRO AlijHyvEritS (tulos, mvuosi, minf, potulo, povahenn, askorot, ensaskorot, elvakuutusmaksu)/STORE
DES = 'VERO: Erityinen alijäämähyvitys';

IF &mvuosi < 2005 THEN &tulos = 0;
ELSE DO;

	%HAKU;

	vahmaksu = &elvakuutusmaksu;

	IF vahmaksu > &VapEhtRaja1 THEN vahmaksu = &VapEhtRaja1;

	IF &potulo = 0 Or &potulo <= &povahenn +  &AsKorkoOsuus * (&askorot + &ensaskorot)  THEN &tulos = &PaaomaVeroPros * vahmaksu;

	IF &potulo > &povahenn +  &AsKorkoOsuus * (&askorot + &ensaskorot)  AND &potulo <= &povahenn +  &AsKorkoOsuus * (&askorot + &ensaskorot) + vahmaksu
	THEN &tulos = &PaaomaVeroPros * (&povahenn +  &AsKorkoOsuus * (&askorot + &ensaskorot) + vahmaksu - &potulo);

	IF &potulo > &povahenn +  &AsKorkoOsuus * (&askorot + &ensaskorot) + vahmaksu THEN &tulos = 0;

END;

DROP vahmaksu;

%MEND AlijHyvEritS;


/* 36. Yhtiöveron hyvitys.
	   Lainsäädännössä vuoteen 2004 lähtien. 
	   Huom! Makrossa oletetaan, että osingot ovat lainsäädäntövuotta edeltävältä tilivuodelta */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Yhtiöveron hyvitys
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	osinkotulo: Hyvitykseen oikeuttava osinkotulo;

%MACRO YhtHyvS(tulos, mvuosi, osinkotulo)/STORE
DES = 'VERO: Yhtiöveron hyvitys';

%HAKU1;

&tulos = &YhtHyvPros * &osinkotulo;

IF &mvuosi = 1993 THEN &tulos = &PaaomaVeroPros * &osinkotulo / (1 - &PaaomaVeroPros);

%MEND YhtHyvS;


/* 37. Pääomatulon vero.
	   Huom! Makro lisää tuloihin yhtiöveron hyvityksen */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Pääomatulon vero
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	osinkotulo: Osinkotulo
	muupotulo: Muu pääomastulo
	povahenn: Pääomatulosta tehtävät vähennykset (muut kuin kulutusluoton korot)
	kulkorot: Kulutusluoton korot (vaikutusta 1994 ja 1995);

%MACRO POTulonVeroS (tulos, mvuosi, osinkotulo, muupotulo, povahenn, kulkorot)/STORE
DES = 'VERO: Pääomatulon vero';

%HAKU1;

%YhtHyvS(hyvit, &mvuosi, &osinkotulo);

IF &mvuosi > 1994 THEN kulkorotx = 0;

ELSE IF &mvuosi < 1995 THEN kulkorotx = &kulkorot;

vertulo = MAX(&osinkotulo + hyvit + &muupotulo - &povahenn - kulkorotx, 0);

IF &mvuosi > 2011 AND vertulo > &PORaja THEN
	&tulos = &PaaomaVeroPros * &PORaja + &POPros2 * (vertulo - &PORaja);
	
ELSE
	&tulos = &PaaomaVeroPros * vertulo;
	
%MEND PoTulonVeroS;

/*38. Vähennyskelpoinen osuus asuntolainan koroista;
*Makron parametrit:
    tulos: Makron tulosmuuttuja, Pääomatulon vero
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	asuntokorot: Asuntolainan korot
Huomautus: uusi makro, jolla otetaan huomioon korko-oikeuden
rajoitus vuodesta 2012 lähtien;
*/


%MACRO VahAsKorotS (tulos, mvuosi, asuntokorot)/STORE
DES = 'Vähennyskelpoiset asuntolainan korot pääomatulon verotuksessa';

%HAKU1;

&tulos = &AsKorkoOsuus * &asuntokorot;

%MEND VahAsKorotS;


/* 39. Pääomatulon vero: makro joka ottaa huomioon vapaaehtoiset eläkevakuutusmaksut. 
	   Huom! Makro lisää tuloihin yhtiöveron hyvityksen. */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Pääomatulon vero
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	osinkotulo: Osinkotulo
	muupotulo: Muu pääomastulo
	povahenn: Pääomatulosta tehtävät vähennykset (muut kuin kulutusluoton korot)
	kulkorot: Kulutusluoton korot (vaikutusta 1994 ja 1995)
	elvakuutusmaksu: Pääomatulosta vähennettävät vapaaehtoiset eläkevakuutusmaksut;

%MACRO POTulonVeroEritS (tulos, mvuosi, minf, osinkotulo, muupotulo, povahenn, kulkorot, elvakuutusmaksu)/STORE
DES = 'VERO: Pääomatulon vero, vapaaeht. eläkevakuutusmaksut huomioon otettuna';

%HAKU;

%YhtHyvS(hyvit, &mvuosi, &osinkotulo);

IF &mvuosi > 1994 THEN kulkorotx = 0;

ELSE kulkorotx = &kulkorot;

IF &mvuosi < 2005 THEN elvakmaksux = 0;

ELSE elvakmaksux = MIN(&elvakuutusmaksu,  &VapEhtRaja1);

vertulo = MAX(&osinkotulo + hyvit + &muupotulo - &povahenn - kulkorotx - elvakmaksux, 0);

IF &mvuosi > 2011 AND vertulo > &PORaja THEN

	&tulos = &PaaomaVeroPros * &PORaja + &POPros2 * (vertulo - &PORaja);
	
ELSE
	&tulos = &PaaomaVeroPros * vertulo;

DROP hyvit kulkorotx vertulo;

%MEND PoTulonVeroEritS;


/* 40. Kotitalousvähennys
	   Huom! Makro ottaa huomioon pelkästään vähennyksen alarajan
       ja ylärajan, mutta ei vähennyksen muodostumista eri menolajeista */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Kotitalousvähennys 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	kotitmeno: Kotitalousvähennykseen oikeuttavat menot;

%MACRO KotiTalVahS(tulos, mvuosi, minf, kotitmeno)/STORE
DES = 'VERO: Kotitalousvähennys';

%HAKU;

&tulos = MAX(&kotitmeno - &KotitVahAlaRaja, 0);

IF &tulos > &KotitVahEnimm THEN &tulos = &KotitVahEnimm;

%MEND KotiTalVahS;


/* 41. Vähennysten jakaminen eri verolajeille:
	   Makroa voi käyttää jaettaessa kotitalousvähennystä, valtionverotuksen
	   ansiotulovähennystä ja erityistä alijäämähyvitystä eri verolajeille */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Verolajiin kuuluvan veron määrä 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	vahennys: Vähennys, jota jaetaan
	verolaji: 1 = valt. ans.vero, 2 = kunn.vero, 3 = sv-maksu, 4 = kev-maksu, 5 = kirkvero, 6 = po-tulon vero
	valtansvero: Ansiotulon valtionvero ennen vähennystä
	kunnvero: Kunnallinen tulovero ennen vähennystä
	svmaksu: Sairausvakuutusmaksu/sairaanhoitomaksu ennen vähennystä
	kevmaksu: Kansaneläkevakuutusmaksu ennen vähennystä (koska kevmaksua ei peritä vuoden 1995 jälkeen, tämä muuttuja on yleensä = 0)
	kirkvero: Kirkollisvero
	potulonvero: Pääomatulon vero (jos jaetaan ansiotulovähennystä tai erityistä alijäämähyvitystä, tämä = 0);

%MACRO VahennJakoS (tulos, mvuosi, vahennys, verolaji, valtansvero, kunnvero, svmaksu, kevmaksu, kirkvero, potulonvero)/STORE
DES = 'VERO: Vähennysten jakaminen eri verolajeille';

/* Verolajit */

valt =  &valtansvero + &potulonvero;

muutverot = &kunnvero + &svmaksu + &kevmaksu + &kirkvero;

*Jos ei veroja, tulos on aina 0;

IF valt = 0 AND  muutverot = 0 THEN DO;
	&tulos = 0;
END;

ELSE DO;

	/* Lasketaan vähennys eri verolajeille, ensi sijassa valtion verosta 
   	   ansiotulojen valtionverolle ja pääomatulon verolle näiden verolajien suhteessa.
       Jos valtionverot eivät riitä, loppuosa muille verolajeille niiden suhteessa.
       Ennen vuotta 2001 vähennys vain valtionverosta */
	
	/* Verolajit: 1 = valt. ans.vero, 2 = kunn.vero, 3 = sv-maksu, 4 = kev-maksu, 5 = kirkvero, 6 = po-tulon vero */

	SELECT (&verolaji);

		*VALT. ANS.VERO;

		WHEN (1) DO;

			IF &vahennys = 0 THEN &tulos = &valtansvero;

			IF valt = 0 OR &valtansvero = 0 THEN &tulos = 0;

			IF &valtansvero >= 0 and valt > 0 AND &vahennys > 0 AND &vahennys <= valt THEN DO;

				suhde = &valtansvero / valt;

				&tulos = &valtansvero - suhde* &vahennys;

			END;

			IF &vahennys > valt AND valt >= 0 THEN &tulos = 0;

			IF valt < 0 or &valtansvero < 0 THEN &tulos = &valtansvero;

		END;

		*KUNN.VERO;

		WHEN (2) DO;

			IF &mvuosi < 2001 OR &vahennys = 0 OR &vahennys <= valt THEN &tulos = &kunnvero;

			IF &kunnvero = 0 THEN &tulos = 0;

			IF &mvuosi > 2000 AND &vahennys > valt AND muutverot > 0 THEN DO;

				suhde = &kunnvero / muutverot;

				&tulos = &kunnvero - suhde * (&vahennys - valt);

			END;

		END;

		*SV-MAKSU;

		WHEN (3) DO;

		    IF &mvuosi < 2001 OR &vahennys = 0 OR &vahennys <= valt THEN &tulos = &svmaksu;

			IF &svmaksu = 0 THEN &tulos = 0;

			IF &mvuosi > 2000 AND &vahennys > valt AND muutverot > 0 THEN DO;

				suhde = &svmaksu / muutverot;

				&tulos = &svmaksu - suhde * (&vahennys - valt);

			END;

		END;

		*KEV-MAKSU;

		WHEN (4) DO;

		    IF &mvuosi < 2001 OR &vahennys = 0 OR &vahennys <= valt THEN &tulos = &kevmaksu;

			IF &kevmaksu = 0 THEN &tulos = 0;

			IF &mvuosi > 2000 AND &vahennys > valt AND muutverot > 0 THEN DO;

				suhde = &kevmaksu / muutverot;

				&tulos = &kevmaksu - suhde * (&vahennys - valt);

			END;

		END;

		*KIRK.VERO;

		WHEN (5) DO;

		    IF &mvuosi < 2001 OR &vahennys = 0 OR &vahennys <= valt THEN &tulos = &kirkvero;

			IF &kirkvero = 0 THEN &tulos = 0;

			IF &mvuosi > 2000 AND &vahennys > valt AND muutverot > 0 THEN DO;

				suhde = &kirkvero / muutverot;

				&tulos = &kirkvero - suhde * (&vahennys - valt);

			END;

		END;

		*PO-TULO;

		WHEN (6) DO;

			IF &vahennys = 0 THEN &tulos = &potulonvero;

			IF &potulonvero = 0 OR valt = 0 OR &vahennys > valt THEN &tulos = 0;

			IF &vahennys > 0 AND &vahennys < valt THEN DO;

				suhde = &potulonvero / valt;

				&tulos = &potulonvero - suhde * &vahennys;

			END; 
		END;

		OTHERWISE &tulos = 0;

	END;

	IF &tulos < 0 THEN &tulos = 0;

END;

DROP valt muutverot suhde;

%MEND VahennJakoS;


/* 42. Alijäämähyvityksen jakaminen eri verolajeille;
	   Hyvityksen jakamista valtionveron ja muiden verojen kesken säätelee laissa oleva parametri */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Verolajiin kuuluvan veron määrä
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	verolaji: 1 = valt. ans.vero, 2 = kunn.vero, 3 = sv-maksu, 4 = kev-maksu, 5 = kirkvero
	alijhyv: Alijäämähyvitys, jota jaetaan
	valtansvero: Ansiotulon valtionvero ennen vähennystä
	kunnvero: Kunnallinen tulovero ennen vähennystä
	svmaksu: Sairausvakuutusmaksu/sairaanhoitomaksu ennen vähennystä
	kevmaksu: Kansaneläkevakuutusmaksu ennen vähennystä (koska kevmaksua ei peritä vuoden 1995 jälkeen, tämä muuttuja on yleensä = 0)
	kirkvero: Kirkollisvero;

%MACRO AlijHyvJakoS (tulos, mvuosi, verolaji, alijhyv, valtansvero, kunnvero, svmaksu, kevmaksu, kirkvero)/STORE
DES = 'VERO: Alijäämähyvityksen jakaminen eri verolajeille';

IF SUM(&valtansvero + &kunnvero + &svmaksu + &kevmaksu + &kirkvero) = 0 THEN &tulos = 0;

ELSE DO;

	%haeparam_vero&tyyppi(&mvuosi, 1);

	valtos = &ValtAlijOsuus * &alijhyv;

	IF valtos < &valtansvero THEN jaettava = MAX(&alijhyv - valtos, 0);

	ELSE jaettava = &alijhyv - &valtansvero;
	
	jakopohja = MAX(&valtansvero - valtos, 0) + &kunnvero + &svmaksu + &kevmaksu + &kirkvero;

	/* Verolajit: 1 = valt. ans.vero, 2 = kunn.vero, 3 = sv-maksu, 4 = kev-maksu, 5 = kirkvero */
		
	SELECT (&verolaji);

		*VALT. ANS.VERO;

		WHEN (1) DO;
	
			IF jakopohja > 0 THEN tmposuus = MAX(&valtansvero - valtos, 0) / jakopohja;

			ELSE tmposuus = 0;
			
			&tulos = MAX(&valtansvero - valtos,  0)- tmposuus * jaettava;
       	END;

		*KUNN.VERO;

		WHEN (2) DO;

			IF jakopohja > 0 THEN tmposuus = &kunnvero / jakopohja;

			ELSE tmposuus = 0;

			&tulos = &kunnvero - tmposuus * jaettava;

		END;

		*SV-MAKSU;
					
		WHEN (3) DO;

			IF jakopohja > 0 THEN tmposuus = &svmaksu / jakopohja;

			ELSE tmposuus = 0;

			&tulos = &svmaksu - tmposuus * jaettava;

		END;

		*KEV-MAKSU;

		WHEN (4) DO;

			IF jakopohja > 0 THEN tmposuus = &kevmaksu / jakopohja;

			ELSE tmposuus = 0;

			&tulos = &kevmaksu - tmposuus * jaettava;

		END;
			
		*KIRK.VERO;

		WHEN (5) DO;

			IF jakopohja > 0 THEN tmposuus = &kirkvero / jakopohja;

			ELSE tmposuus = 0;

			&tulos = &kirkvero - tmposuus * jaettava;

		END;

		OTHERWISE  &tulos = 0;
		
	END;

END;

IF &tulos < 0 THEN &tulos = 0;

DROP valtos jaettava jakopohja tmposuus;

%MEND AlijHyvJakoS;


/* 43. Yhtiöveron hyvityksen jakaminen eri verolajeille. 
       Huom! Lainsäädäntövuodesta riippumaton makro. */

*Makron parametrit:
	tulos: Makron tulosmuuttuja, Verolajiin kuuluvan veron määrä 
	verolaji: 1 = valt. ans.vero, 2 = kunn.vero, 3 = sv-maksu, 4 = kev-maksu, 5 = kirkvero
	yhthyvans: Ansiotulo-osinkoon kohdistuva yhtiöveron hyvitys
	yhthyvpo: Pääomatulo-osinkoon kohdistuva yhtiöveron hyvitys
	valtvero: Valtionverot
	valtansvero: Ansiotulon valtionvero ennen vähennystä
	kunnvero: Kunnallinen tulovero ennen vähennystä
	svmaksu: Sairausvakuutusmaksu/sairaanhoitomaksu ennen vähennystä
	kevmaksu: Kansaneläkevakuutusmaksu ennen vähennystä (koska kevmaksua ei peritä vuoden 1995 jälkeen, tämä muuttuja on yleensä = 0)
	kirkvero: Kirkollisvero;

%MACRO YhtHyvJakoS(tulos, verolaji, yhthyvans, yhthyvpo, valtvero, valtansvero, kunnvero, svmaksu, kevmaksu, kirkvero)/STORE
DES = 'VERO: Yhtiöveron hyvityksen jakaminen eri verolajeille';

IF (&valtansvero >= 0) AND (&kunnvero >= 0) AND  (&svmaksu >= 0) AND
	(&kevmaksu >= 0) AND  (&kirkvero >= 0) THEN
	ansverosumma = &valtansvero + &kunnvero + &svmaksu + &kevmaksu + &kirkvero;

ELSE ansverosumma = 0;

/* Verolajit: 1 = valt. ans.vero, 2 = kunn.vero, 3 = sv-maksu, 4 = kev-maksu, 5 = kirkvero */

SELECT(&verolaji);

	*VALT. ANS.VERO;

	WHEN (1) DO;

		IF ansverosumma > 0 THEN &tulos = &valtvero - &yhthyvpo - &valtansvero * &yhthyvans / ansverosumma;

		ELSE &tulos = &valtvero - &yhthyvpo - &yhthyvans;

	END;

	*KUNN.VERO;

	WHEN (2) DO;

		IF ansverosumma > 0 THEN &tulos = &kunnvero - &kunnvero * &yhthyvans / ansverosumma;

		ELSE &tulos = &kunnvero;

	END;

	*SV-MAKSU;

	WHEN (3) DO;

		IF ansverosumma > 0 THEN &tulos = &svmaksu - &svmaksu * &yhthyvans / ansverosumma;

		ELSE &tulos = &svmaksu;

	END;

	*KEV-MAKSU;

	WHEN (4) DO;

		IF ansverosumma > 0 THEN &tulos = &kevmaksu - &kevmaksu * &yhthyvans / ansverosumma;

		ELSE &tulos = &kevmaksu;

	END;

	*KIRK.VERO;

	WHEN (5) DO;

		IF ansverosumma > 0 THEN &tulos = &kirkvero - &kirkvero * &yhthyvans / ansverosumma;

		ELSE &tulos = &kirkvero;

	END;

	OTHERWISE &tulos = -100;
END;

DROP ansverosumma;

%MEND YhtHyvJakoS;


/* 44. Valtionverotuksen lapsenhoitovähennys (nimenä myös ylimääräinen työtulovähennys) */

*Makron parametrit:
		tulos: Makron tulosmuuttuja, Valtionverotuksen lapsenhoitovähennys
		mvuosi: Vuosi, jonka lainsäädäntöa käytetään
		minf: Deflaattori euromääräisten parametrien kertomiseksi
		puoliso: Onko henkilöllä puoliso (0/1)
		lapsia: Huollettavina olevia alaikäisiä lapsia (0/1)
		lapsia_3_7_v: 3-7-vuotiaita lapsia (0/1)
		lapsia_7_v: Alle 7-vuotiaita lapsia (0/1)
		puhdanstulo: Puhdas ansiotulo,  
		kokontulo: Kokonaistulo
		puolisonos: Puolison osuus valtionverotuksen lapsenhoitovähennyksestä;

%MACRO ValtLapsVahS(tulos, mvuosi, minf, puoliso, pientul, lapsia, lapsia_3_7_v, lapsia_7_v, puhdanstulo, kokontulo, puolisonos)/STORE 
DES = 'VERO: Valtionverotuksen lapsivähennys';

%HAKU;

* Ennen vuotta 1989 vähennyksen voi saada puolisoista vain pienituloisempi ;
IF &mvuosi < 1989 AND &puoliso NE 0 AND &pientul NE 1 THEN &tulos = 0;

ELSE DO;
	* Korjataan lapsimuuttujien mahdollinen epäjohdonmukaisuus ;
	IF &lapsia_3_7_v NE 0 OR &lapsia_7_v NE 0 THEN DO;
		%LET lapsia = 1;
	END;
	IF &lapsia_3_7_v NE 0 THEN DO;
		%LET lapsia_7_v = 1;
	END;

	* Ennen vuotta 1989 alle 7-vuotiaat lapset korottavat vähennyksen enimmäismäärää ;
	IF &mvuosi < 1989 THEN DO;
		IF &lapsia_7_v NE 0 THEN vah1 = &ValtLapsiVah + &ValtLapsKorotus;
	END;

	* Ennen vuotta 1989 vähennys lasketaan puhtaasta ansiotulosta, sen jälkeen 
	  kokonaistulosta ja vuodesta 1993 lähtien puhtaasta ansiotulosta ;
	IF &mvuosi < 1989 THEN tulo = &puhdanstulo;
	IF &mvuosi > 1988 AND &mvuosi < 1993 THEN tulo = &kokontulo;
	IF &mvuosi > 1992 THEN tulo = &puhdanstulo;

	* Vuoden 1989 jälkeen vain 3-7-vuotiaat lapset oikeuttavat vähennykseen, sitä ennen kaikki lapset ;
	IF &mvuosi > 1989 THEN DO;
		IF &lapsia_3_7_v NE 0 THEN vah2 = &ValtLapsPros * &ValtLapsiVah;
	END;

	ELSE DO; 
		IF &lapsia NE 0 THEN vah2 = &ValtLapsPros * tulo;
	END;

	* Rajoitetaan vähennys vähennyksen enimmäismäärään ;
	IF vah2 > &ValtLapsiVah THEN vah2 = &ValtLapsiVah;

	* Vuodesta 1989 lähtien vähennys voidaan jakaa puolisoiden kesken ;
	IF &mvuosi > 1988 AND &puoliso NE 0 THEN vah2 = vah2 - &puolisonos;
	IF vah2 < 0 THEN vah2 = 0;

	* Varmistetaan, ettei vähennys ole suurempi kuin se tulo, josta se voidaan myöntää ;
	IF vah2 > tulo THEN vah2 = tulo;

END;

&tulos = vah2;

DROP vah1 vah2 tulo;

%MEND ValtLapsVahS;

/* 45. Kunnallisverotuksen lapsenhoitovähennys (huom! sisältää myös yksinhuoltajavähennyksen) */

*Makron parametrit:
		tulos: Makron tulosmuuttuja, Kunnallisverotuksen lapsenhoitovähennys
		mvuosi: Vuosi, jonka lainsäädäntöa käytetään
		minf: Deflaattori euromääräisten parametrien kertomiseksi
		puoliso: Onko henkilöllä puoliso (0/1)
		pientul: Pienituloisempi puoliso (0/1)
		lapsia: Huollettavina olevien alaikäisten lasten lukumäärä
		puhdanstulo: Puhdas ansiotulo 
		kokontulo: Kokonaistulo
		puolisonos: Puolison osuus kunnallisverotuksen lapsivähennyksestä;

%MACRO KunnLapsVahS(tulos, mvuosi, minf, puoliso, pientul, lapsia, puhdanstulo, kokontulo, puolisonos)/STORE 
DES = 'VERO: Kunnallisverotuksen lapsivähennys';

%HAKU;

temp = 0;
kerroin = 0;

* Ennen vuotta 1989 vähennyksen voi saada puolisoista vain suurempituloisempi ;
IF &mvuosi < 1989 AND &puoliso = 1 AND &pientul = 1 THEN temp = 0;

ELSE DO;

	SELECT (&lapsia);

		WHEN (0) DO;
			temp = 0;
		END;

		WHEN (1) DO;
			temp = &KunnLapsiVah;
		END;

		WHEN (2) DO;
			temp = &KunnLapsiVah + &KunnLapsVah2;
		END;

		WHEN (3) DO;
			temp = &KunnLapsiVah + &KunnLapsVah2 + &KunnLapsVah3;
		END;

		WHEN (4) DO;
			temp = &KunnLapsiVah + &KunnLapsVah2 + &KunnLapsVah3 + &KunnLapsVah4;
		END;

		OTHERWISE temp = &KunnLapsiVah + &KunnLapsVah2 + &KunnLapsVah3 + &KunnLapsVah4 + ((&lapsia - 4) * &KunnLapsVahMuu);

	END;
	
	* Yksinhuoltajavähennys otetaan huomioon kertoimella 1 ;
	IF &puoliso NE 1 AND &lapsia NE 0 THEN DO;
		kerroin = 1; 
		&puolisonos = 0;
	END;

	temp = temp + kerroin * &KunnYksHuoltVah;
	temp = temp - (temp * &puolisonos);

	IF temp < 0 THEN temp = 0;
	IF &mvuosi < 1993 AND temp > &kokontulo THEN temp = &kokontulo;
	IF &mvuosi > 1992 AND temp > &puhdanstulo THEN temp = &puhdanstulo;

&tulos = temp;

END;

DROP temp kerroin;

%MEND KunnLapsVahS;

/* 46. Kunnallisverotuksen yksinhuoltajavähennys */
 
*Makron parametrit:
		tulos: Makron tulosmuuttuja, Kunnallisverotuksen yksinhuoltajavähennys
		mvuosi: Vuosi, jonka lainsäädäntöa käytetään
		minf: Deflaattori euromääräisten parametrien kertomiseksi
		puoliso: Onko henkilöllä puoliso (0/1)
		lapsia: Huollettavina olevien alaikäisten lasten lukumäärä
		puhdanstulo: Puhdas ansiotulo; 

%MACRO KunnYksVahS(tulos, mvuosi, minf, puoliso, lapsia, puhdanstulo)/STORE
DES = 'VERO: Kunnallisverotuksen yksinhuoltajavähennys';

%HAKU;

IF &lapsia <= 0 OR &puoliso NE 0 THEN &tulos = 0;

ELSE DO;

	vah = &KunnYksHuoltVah;

	IF &mvuosi > 1992 THEN DO;

		IF vah > &puhdanstulo THEN vah = &puhdanstulo;

	END;

&tulos = vah;

END;

DROP vah;

%MEND KunnYksVahS;

/* 47. Varallisuusvero */ 

*Makron parametrit:
		tulos: Makron tulosmuuttuja, Varallisuusvero
		mvuosi: Vuosi, jonka lainsäädäntöa käytetään
		minf: Deflaattori euromääräisten parametrien kertomiseksi
		puoliso: Onko henkilöllä puoliso (0/1)
		lapsia: Huollettavina olevien alaikäisten lasten lukumäärä
		vakasu: Vakituinen asunto varallisuuden osana (0/1)
		nettovarall: Nettovarallisuus, e;

%MACRO VarallVeroS(tulos, mvuosi, minf , puoliso, lapsia, vakasu, nettovarall)/STORE 
DES = 'VERO: Varallisuusvero';

%HAKU;
%HAKUVV;

puolvah = 0;
vaka = 0;

IF &puoliso NE 0 THEN puolvah = &VarPuolVah;

IF &vakasu NE 0 THEN vaka = &VakAs;

* Otetaan huomioon puoliso- ja lapsivähennykset sekä vähennys vakituisesta asunnosta ;
temp = &nettovarall - puolvah - (&lapsia * &VarLapsiVah) - vaka;

IF temp <= 0 THEN &tulos = 0;

* Lasketaan varallisuusverotaulukon avulla varallisuusvero ;
ELSE DO;

	IF temp GE &VarRaja6 THEN
		temp = &VarPros6 * (temp - &VarRaja6) + &VarVakio6;
	
	ELSE IF temp GE &VarRaja5 THEN
		temp = &VarPros5 * (temp - &VarRaja5) + &VarVakio5;
	
	ELSE IF temp GE &VarRaja4 THEN
		temp = &VarPros4 * (temp - &VarRaja4) + &VarVakio4;
	
	ELSE IF temp GE &VarRaja3 THEN
		temp = &VarPros3 * (temp - &VarRaja3) + &VarVakio3;
	
	ELSE IF temp GE &VarRaja2 THEN
		temp = &VarPros2 * (temp - &VarRaja2) + &VarVakio2;

	ELSE IF temp GE &VarRaja1 THEN
		temp = &VarPros1 * (temp - &VarRaja1) + &VarVakio1;

	&tulos = temp;

END; 

DROP temp puolvah vaka;

%MEND VarallVeroS;

/* 48. Kunnallisverotuksen eläketulovähennyksen maksimiarvo = täysi eläketulovähennys */
 
*Makron parametrit:
		tulos: Makron tulosmuuttuja, Kunnallisverotuksen täysi eläketulovähennys
		mvuosi: Vuosi, jonka lainsäädäntöa käytetään
		minf: Deflaattori euromääräisten parametrien kertomiseksi
		puoliso: Onko henkilöllä puoliso (0/1);

%MACRO KunnElTulVahMaxS (tulos, mvuosi, minf, puoliso)/STORE
DES = 'VERO: Kunnallisverotuksen eläketulovähennyksen maksimiarvo (täysi eläketulovähennys)';

tulo = 0;
erotus = 1;

DO TULO = 0 TO 50000 BY 1000;
	%KunnElTulVahS (t, &mvuosi, &minf, &puoliso, 0, tulo, tulo, tulo);
	%KunnElTulVahS (t1, &mvuosi, &minf, &puoliso, 0, (tulo - 1), (tulo - 1), (tulo - 1));
	EROTUS = T - T1;
	IF EROTUS < 0.01 THEN LEAVE;
END;

DO TULO = TULO -1000 TO TULO + 1000 BY 100;
	%KunnElTulVahS (t, &mvuosi, &minf, &puoliso, 0, tulo, tulo, tulo);
	%KunnElTulVahS (t1, &mvuosi, &minf, &puoliso, 0, (tulo - 1), (tulo - 1), (tulo - 1));
	EROTUS = T - T1;
	IF EROTUS < 0.01 THEN LEAVE;
END;

DO TULO =  TULO -100 TO TULO + 100 BY 10;
	%KunnElTulVahS (t, &mvuosi, &minf, &puoliso, 0, tulo, tulo, tulo);
	%KunnElTulVahS (t1, &mvuosi, &minf, &puoliso, 0, (tulo - 1), (tulo - 1), (tulo - 1));
	EROTUS = T - T1;
	IF EROTUS < 0.01 THEN LEAVE;
END;

DO TULO = TULO - 10 TO TULO + 10 BY 2;
	%KunnElTulVahS (t, &mvuosi, &minf, &puoliso, 0, tulo, tulo, tulo);
	%KunnElTulVahS (t1, &mvuosi, &minf, &puoliso, 0, (tulo - 1), (tulo - 1), (tulo - 1));
	EROTUS = T - T1;
	IF EROTUS < 0.01 THEN LEAVE;
END;

&tulos = tulo;

DROP tulo t t1 ;

%MEND KunnElTulVahMaxS;

/* 49. Valtionverotuksen eläketulovähennyksen maksimiarvo = täysi eläketulovähennys */
 
*Makron parametrit:
		tulos: Makron tulosmuuttuja, Valtionverotuksen täysi eläketulovähennys
		mvuosi: Vuosi, jonka lainsäädäntöa käytetään
		minf: Deflaattori euromääräisten parametrien kertomiseksi;

%MACRO ValtElTulVahMaxS (tulos, mvuosi, minf)/STORE
DES = 'VERO: Valtionverotuksen eläketulovähennyksen maksimiarvo (täysi eläketulovähennys)';

tulo = 0;
erotus = 1;
	
DO TULO = 1000 TO 50000 BY 1000;
	%ValtElTulVahS (t, &mvuosi, &minf, tulo, tulo, tulo);
	%ValtElTulVahS (t1, &mvuosi, &minf, (tulo - 1), (tulo - 1), (tulo - 1));
	EROTUS = T - T1;
	IF EROTUS <= 1 THEN LEAVE;
END;

DO TULO = TULO - 1000 TO TULO + 1000 BY 100;
	%ValtElTulVahS (t, &mvuosi, &minf, tulo, tulo, tulo);
	%ValtElTulVahS (t1, &mvuosi, &minf, (tulo - 1), (tulo - 1), (tulo - 1));
	EROTUS = T - T1;
	IF EROTUS <= 1 THEN LEAVE;
END;

DO TULO = TULO - 100 TO TULO + 100 BY 10;
	%ValtElTulVahS (t, &mvuosi, &minf, tulo, tulo, tulo);
	%ValtElTulVahS (t1, &mvuosi, &minf, (tulo - 1), (tulo - 1), (tulo - 1));
	EROTUS = T - T1;
	IF EROTUS <= 1 THEN LEAVE;
END;

DO TULO = TULO - 10 TO TULO + 10 BY 2;
	%ValtElTulVahS (t, &mvuosi, &minf, tulo, tulo, tulo);
	%ValtElTulVahS (t1, &mvuosi, &minf, (tulo - 1), (tulo - 1), (tulo - 1));
	EROTUS = T - T1;
	IF EROTUS <= 1 THEN LEAVE;
END;

&tulos = tulo;

DROP tulo t t1;

%MEND ValtElTulVahMaxS;

/* 50. Raja, josta eläketulon verotus alkaa */
 
*Makron parametrit:
		tulos: Makron tulosmuuttuja, Raja josta eläketulon verotus alkaa
		mvuosi: Vuosi, jonka lainsäädäntöa käytetään
		minf: Deflaattori euromääräisten parametrien kertomiseksi
		puoliso: Onko henkilöllä puoliso (0/1);

%MACRO ElVeroRajaS (tulos, mvuosi, minf, puoliso)/STORE
DES = 'VERO: Raja, josta eläketulon verotus alkaa';

tulo = 0;
vero = 0;

DO TULO = 0 TO 50000 BY 1000;
	%TuloVerot_Simple_ElakeS (vero, &mvuosi, &minf, &puoliso, tulo); 
	IF VERO > 0 THEN LEAVE;
END;

DO TULO = TULO - 1000 TO TULO + 1000 BY 100;
%TuloVerot_Simple_ElakeS (vero, &mvuosi, &minf, &puoliso, tulo); 
	IF VERO > 0 THEN LEAVE;
END;

DO TULO = TULO - 100 TO TULO + 100 BY 10;
%TuloVerot_Simple_ElakeS (vero, &mvuosi, &minf, &puoliso, tulo); 
	IF VERO > 0 THEN LEAVE;
END;

DO TULO = TULO - 10 TO TULO + 10 BY 1;
%TuloVerot_Simple_ElakeS (vero, &mvuosi, &minf, &puoliso, tulo); 
	IF VERO > 0 THEN LEAVE;
END;

DO TULO = TULO - 1 TO TULO + 1 BY 0.1;
%TuloVerot_Simple_ElakeS (vero, &mvuosi, &minf, &puoliso, tulo); 
	IF VERO > 0 THEN LEAVE;
END;

&tulos = tulo;

DROP tulo vero;

%MEND ElVeroRajaS;

/* 51. Valtion tuloverotuksen alaraja */
 
*Makron parametrit:
		tulos: Makron tulosmuuttuja, Valtion tuloverotuksen alaraja
		mvuosi: Vuosi, jonka lainsäädäntöa käytetään
		minf: Deflaattori euromääräisten parametrien kertomiseksi
		tulolaji: 1 = palkka, 2 = eläke, 3 = muu tulo;

%MACRO ValtVerRajaS (tulos, mvuosi, minf, tulolaji)/STORE
DES = 'VERO: Valtion tuloverotuksen alaraja';

IF &tulolaji = 3 THEN DO;

	%HAKU;
	&tulos = &ValtAlaraja;
END;

IF &tulolaji = 2 THEN DO;

DO TULO = 0 TO 50000 BY 1000;
	%ValtElTulVahS (temp1, &mvuosi, &minf, tulo, tulo, tulo);
	vertulo = TULO - TEMP1;
	IF vertulo >= &ValtAlaraja THEN LEAVE;
END;

DO TULO = TULO - 1000 TO TULO + 1000 BY 100;
	%ValtElTulVahS (temp1, &mvuosi, &minf, tulo, tulo, tulo);
	vertulo = TULO - TEMP1;
	IF vertulo >= &ValtAlaraja THEN LEAVE;
END;

DO TULO = TULO - 100 TO TULO + 100 BY 10;
	%ValtElTulVahS (temp1, &mvuosi, &minf, tulo, tulo, tulo);
	vertulo = TULO - TEMP1;
	IF vertulo >= &ValtAlaraja THEN LEAVE;
END;

DO TULO = TULO - 10 TO TULO + 10 BY 1;
	%ValtElTulVahS (temp1, &mvuosi, &minf, tulo, tulo, tulo);
	vertulo = TULO - TEMP1;
	IF vertulo >= &ValtAlaraja THEN LEAVE;
END;

DO TULO = TULO - 1 TO TULO + 1 BY 0.1;
	%ValtElTulVahS (temp1, &mvuosi, &minf, tulo, tulo, tulo);
	vertulo = TULO - TEMP1;
	IF vertulo >= &ValtAlaraja THEN LEAVE;
END;

&tulos = tulo;

END;

IF &tulolaji = 1 THEN DO;

DO TULO = 0 TO 50000 BY 1000;
	%TulonHankKulutS (temp2, &mvuosi, &minf, tulo, tulo, 0, 0, 0, 0);
	%PalkVakMaksuS (temp3, &mvuosi, 0, tulo);
	%SvPRahaMaksuS (temp4, &mvuosi, tulo);
	vertulo = tulo - temp2 - temp3 - temp4;
	IF vertulo < 0 THEN vertulo = 0;
	%ValtTuloVeroS (vero, &mvuosi, &minf, vertulo);
	%ValtVerAnsVahS (temp5, &mvuosi, &minf, tulo, (tulo - temp2));
	vero2 = vero - temp5;
	IF vero2 < 0 THEN vero2 = 0;
	IF vero2 > 0 THEN LEAVE;
END;

DO TULO = TULO - 1000 TO TULO + 1000 BY 100;
	%TulonHankKulutS (temp2, &mvuosi, &minf, tulo, tulo, 0, 0, 0, 0);
	%PalkVakMaksuS (temp3, &mvuosi, 0, tulo);
	%SvPRahaMaksuS (temp4, &mvuosi, tulo);
	vertulo = tulo - temp2 - temp3 - temp4;
	IF vertulo < 0 THEN vertulo = 0;
	%ValtTuloVeroS (vero, &mvuosi, &minf, vertulo);
	%ValtVerAnsVahS (temp5, &mvuosi, &minf, tulo, (tulo - temp2));
	vero2 = vero - temp5;
	IF vero2 < 0 THEN vero2 = 0;
	IF vero2 > 0 THEN LEAVE;
END;

DO TULO = TULO - 100 TO TULO + 100 BY 10;
	%TulonHankKulutS (temp2, &mvuosi, &minf, tulo, tulo, 0, 0, 0, 0);
	%PalkVakMaksuS (temp3, &mvuosi, 0, tulo);
	%SvPRahaMaksuS (temp4, &mvuosi, tulo);
	vertulo = tulo - temp2 - temp3 - temp4;
	IF vertulo < 0 THEN vertulo = 0;
	%ValtTuloVeroS (vero, &mvuosi, &minf, vertulo);
	%ValtVerAnsVahS (temp5, &mvuosi, &minf, tulo, (tulo - temp2));
	vero2 = vero - temp5;
	IF vero2 < 0 THEN vero2 = 0;
	IF vero2 > 0 THEN LEAVE;
END;

DO TULO = TULO - 10 TO TULO + 10 BY 1;
	%TulonHankKulutS (temp2, &mvuosi, &minf, tulo, tulo, 0, 0, 0, 0);
	%PalkVakMaksuS (temp3, &mvuosi, 0, tulo);
	%SvPRahaMaksuS (temp4, &mvuosi, tulo);
	vertulo = tulo - temp2 - temp3 - temp4;
	IF vertulo < 0 THEN vertulo = 0;
	%ValtTuloVeroS (vero, &mvuosi, &minf, vertulo);
	%ValtVerAnsVahS (temp5, &mvuosi, &minf, tulo, (tulo - temp2));
	vero2 = vero - temp5;
	IF vero2 < 0 THEN vero2 = 0;
	IF vero2 > 0 THEN LEAVE;
END;

DO TULO = TULO - 1 TO TULO + 1 BY 0.1;
	%TulonHankKulutS (temp2, &mvuosi, &minf, tulo, tulo, 0, 0, 0, 0);
	%PalkVakMaksuS (temp3, &mvuosi, 0, tulo);
	%SvPRahaMaksuS (temp4, &mvuosi, tulo);
	vertulo = tulo - temp2 - temp3 - temp4;
	IF vertulo < 0 THEN vertulo = 0;
	%ValtTuloVeroS (vero, &mvuosi, &minf, vertulo);
	%ValtVerAnsVahS (temp5, &mvuosi, &minf, tulo, (tulo - temp2));
	vero2 = vero - temp5;
	IF vero2 < 0 THEN vero2 = 0;
	IF vero2 > 0 THEN LEAVE;
END;

&tulos = tulo;

END;

DROP tulo temp1 temp2 temp3 temp4 temp5 vertulo vero vero2;

%MEND ValtVerRajaS;

/* 52. Kunnan tuloverotuksen alaraja */
 
*Makron parametrit:
		tulos: Makron tulosmuuttuja, Kunnan tuloverotuksen alaraja
		mvuosi: Vuosi, jonka lainsäädäntöa käytetään
		minf: Deflaattori euromääräisten parametrien kertomiseksi
		tulolaji: 1 = palkka, 2 = eläke, 3 = muu tulo;

%MACRO KunnVerRajaS (tulos, mvuosi, minf, puoliso, tulolaji)/STORE
DES = 'VERO: Kunnan tuloverotuksen alaraja';

IF &tulolaji = 3 THEN DO;

	%HAKU;

	&tulos = &KunnPerEnimm;

END;

IF &tulolaji = 2 THEN DO;

	%ElVeroRajaS (elraja, &mvuosi, &minf, &puoliso);

	&tulos = elraja;

END;

IF &tulolaji = 1 THEN DO;
	
	DO TULO = 0 TO 50000 BY 1000;
		%TulonHankKulutS (temp1, &mvuosi, &minf, tulo, tulo, 0, 0, 0, 0);
		%KunnAnsVahS (temp2, &mvuosi, &minf, (tulo - temp1), tulo, tulo, tulo, tulo);
		%PalkVakMaksuS (temp3, &mvuosi, 0, tulo);
		%SvPRahaMaksuS (temp4, &mvuosi, tulo);
		vertulo = tulo - temp1 - temp2 - temp3 -temp4;	
		IF vertulo < 0 THEN vertulo = 0;
		%KunnPerVahS (temp5, &mvuosi, &minf, vertulo);
		vertulo1 = vertulo - temp5;
		IF vertulo1 > 0 THEN LEAVE;
	END;

	DO TULO = TULO - 1000 TO TULO + 1000 BY 100;
		%TulonHankKulutS (temp1, &mvuosi, &minf, tulo, tulo, 0, 0, 0, 0);
		%KunnAnsVahS (temp2, &mvuosi, &minf, (tulo - temp1), tulo, tulo, tulo, tulo);
		%PalkVakMaksuS (temp3, &mvuosi, 0, tulo);
		%SvPRahaMaksuS (temp4, &mvuosi, tulo);
		vertulo = tulo - temp1 - temp2 - temp3 -temp4;	
		IF vertulo < 0 THEN vertulo = 0;
		%KunnPerVahS (temp5, &mvuosi, &minf, vertulo);
		vertulo1 = vertulo - temp5;
		IF vertulo1 > 0 THEN LEAVE;
	END;

	DO TULO = TULO - 100 TO TULO + 100 BY 10;
		%TulonHankKulutS (temp1, &mvuosi, &minf, tulo, tulo, 0, 0, 0, 0);
		%KunnAnsVahS (temp2, &mvuosi, &minf, (tulo - temp1), tulo, tulo, tulo, tulo);
		%PalkVakMaksuS (temp3, &mvuosi, 0, tulo);
		%SvPRahaMaksuS (temp4, &mvuosi, tulo);
		vertulo = tulo - temp1 - temp2 - temp3 -temp4;	
		IF vertulo < 0 THEN vertulo = 0;
		%KunnPerVahS (temp5, &mvuosi, &minf, vertulo);
		vertulo1 = vertulo - temp5;
		IF vertulo1 > 0 THEN LEAVE;
	END;

	DO TULO = TULO - 10 TO TULO + 10 BY 1;
		%TulonHankKulutS (temp1, &mvuosi, &minf, tulo, tulo, 0, 0, 0, 0);
		%KunnAnsVahS (temp2, &mvuosi, &minf, (tulo - temp1), tulo, tulo, tulo, tulo);
		%PalkVakMaksuS (temp3, &mvuosi, 0, tulo);
		%SvPRahaMaksuS (temp4, &mvuosi, tulo);
		vertulo = tulo - temp1 - temp2 - temp3 -temp4;	
		IF vertulo < 0 THEN vertulo = 0;
		%KunnPerVahS (temp5, &mvuosi, &minf, vertulo);
		vertulo1 = vertulo - temp5;
		IF vertulo1 > 0 THEN LEAVE;
	END;

	DO TULO = TULO - 1 TO TULO + 1 BY 0.1;
		%TulonHankKulutS (temp1, &mvuosi, &minf, tulo, tulo, 0, 0, 0, 0);
		%KunnAnsVahS (temp2, &mvuosi, &minf, (tulo - temp1), tulo, tulo, tulo, tulo);
		%PalkVakMaksuS (temp3, &mvuosi, 0, tulo);
		%SvPRahaMaksuS (temp4, &mvuosi, tulo);
		vertulo = tulo - temp1 - temp2 - temp3 -temp4;	
		IF vertulo < 0 THEN vertulo = 0;
		%KunnPerVahS (temp5, &mvuosi, &minf, vertulo);
		vertulo1 = vertulo - temp5;
		IF vertulo1 > 0 THEN LEAVE;	
	END;

	&tulos = tulo;

END;

DROP tulo elraja temp1 temp2 temp3 temp4 temp5 vertulo vertulo1;

%MEND KunnVerRajaS;

/* 53. Yle-vero */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Yle-vero 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
    ika: Henkilön ikä vuosina
	tulo = Puhdas ansio- ja pääomatulo yhteensä
	maakunta = Henkilön kotikunta;

%MACRO YleVeroS(tulos, mvuosi, minf, ika, tulo, maakunta)/STORE
DES = 'VERO: Yle-vero';

%HAKU;

* Ei yle-maksua alle 18-vuotiaille eikä henkilöille, joiden kotikunta on Ahvenanmaa ;
IF &ika < &YleIkaRaja OR &maakunta = 21 THEN temp = 0;

ELSE temp = &tulo * &YlePros;

IF temp < &YleAlaRaja THEN temp = 0;

IF temp > &YleYlaRaja THEN temp = &YleYlaRaja;

&tulos = temp;

DROP temp;

%MEND YleVeroS;

/* 54. Makro, joka laskee valtionveron, kun verotuksen kattosäännös otetaan huomioon */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Valtionvero kun verotuksen kattosäännös on otettu huomioon
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	valtvertulot: Valtionverotuksessa verotettava tulo 
	valttulovero: Valtion tulovero
	varallvero: Varallisuusvero
	muutverot: Kunnallisvero, Sairausvakuutusmaksu/sairaanhoitomaku, Kansaneläkevakuutusmaksu,
	           Kirkollisvero, Pääomatulon vero;

%MACRO ValtVero_FinalS(tulos, mvuosi, valtvertulot, valttuloverot, varallvero, muutverot)/STORE
DES = 'VERO: Valtionvero, kun verotuksen kattosäännös otetaan huomioon';

temp = &valttuloverot + &varallvero;

/* Kattoverosäännöstä ei ole vuodesta 2006 lähtien */

IF &mvuosi > 2005 THEN &tulos = temp;

IF temp = 0 THEN &tulos = 0;

/* Lasketaan verokatto */

osuus = &Kattovero * &valtvertulot;

verot = temp + &muutverot;

IF verot > osuus THEN temp = osuus - &muutverot;

/* Osa varallisuusverosta silti maksettava (vuoteen 1986)*/

IF temp <= (1 - &VarallKattoPros) * &varallvero 
THEN temp = (1- &VarallKattoPros) * &varallvero;

IF temp < 0 THEN temp = 0;

&tulos = temp;

DROP temp osuus verot;

%MEND ValtVero_FinalS;


/* 55. Eläketulon lisävero */

*Makron parametrit:
    tulos: Makron tulosmuuttuja, Eläketulon verot 
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi
	elaketulo: Eläketulo
	eltulvah: Valtioverotuksen eläketulovähennys;

%MACRO ElakeLisaVeroS(tulos, mvuosi, minf, elaketulo, eltulvah)/STORE
DES = 'VERO: Eläketulon lisävero';

%HAKU;

temp = 0;

IF &mvuosi > 2012 THEN DO; 

	elakevvah = &elaketulo - &eltulvah;

	IF elakevvah > &ElLisaVRaja THEN DO;
		temp = (elakevvah - &ElLisaVRaja) * &ElLisaVPros;
	END;

END;

&tulos = temp;

DROP elakevvah temp;

%MEND ElakeLisaVeroS;
