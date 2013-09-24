/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyödyntää Tilastokeskuksen yleisten
* käyttöehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto päähakemistossa.
******************************************************************************/

/******************************************************************************
* Kuvaus: Kotitalousvähennyksen erillistaulun simulointimokkula
* Tekijä: Jukka Mattila / TK		   			           
* Luotu: 14.5.2012				     					   
* Viimeksi päivitetty: 14.5.2012 			 		   	   
* Päivittäjä: Jukka Mattila / TK			     		   
******************************************************************************/

/* X. Kotitalousvähennyksen erillistaulun laskentamakro.
	Laskee kotitalousvähennyksen tarkemman erittelyn sisältävästä
	erillistaulusta.

Parametrit:
    tulos: Makron tulosmuuttuja, kotitalousvähennysoikeus
	mvuosi: Vuosi, jonka lainsäädäntöä käytetään
	minf: Deflaattori euromääräisten parametrien kertomiseksi 
	palksiku: palkatun työntekijän palkan sivukulut, oma osuus
	palkomos: palkatun työntekijän palkka, oma osuus
	tyonosuu: työn osuus yrityksen työstä
*/

%macro KotitVahErillS(tulos, mvuosi, minf, palksiku, palkomos, tyonosuu);

	if &tyonosuu > 0 then do;
		temp1 = 0 + &tyonosuu * &kvtyokerroin;
	end;

	if &palkomos > 0 then do;
		temp2 = 0 + &palksiku + &palkomos * &kvpalkerroin;
	end;

	&tulos = sum(temp1, temp2);

	VAHOIKUS_SIMUL = &tulos;
	
	if sum(&tulos, -&kvomavas) > &kvmax then &tulos = &kvmax;
	else if sum(&tulos, -&kvomavas) < 0 then &tulos = 0;
	else &tulos = &tulos - &kvomavas;

%mend KotitVahErillS;


* Simulointi;
%let inf = 1;
%let avuosi = 2011;
%let aineisto = rek;
%let lvuosi = 2011;
%let kvpalkerroin = 0.30;
%let kvtyokerroin = 0.60;
%let kvmax = 3000;
%let kvomavas = 100;
%let vahdata = r11_kvah;
%let tulosnimi_kve = kvaherill;
%let paino = ykor;


%Macro KotitVahErill_Simul;

/* 3.1. Poimitaan perusaineistosta kotitalousvähennyksiin liittyvät tiedot */

data temp._temp_kvahdata; set pohjadat.&aineisto&avuosi
	(keep = hnro &paino vkotita vkotitki vkotitku vkotitsv vkotitp);

	/* Summataan datan verotuksen kotitalousvähennykset vertailutiedoksi */
	KVAH = sum(vkotita, vkotitki, vkotitku, vkotitsv, vkotitp, 0);

	keep hnro &paino &MUUTTUJAT KVAH;
run;

/* 3.2 Kotitalousvähennyksen laskenta */

data temp._temp_kvah; set pohjadat.&vahdata;

	%KotitVahErillS(KVAH_SIMUL, &lvuosi, &inf, palksiku, palkomos, tyonosuu)

run;

/* 3.5 Liitetään tulokset pohja-aineistosta poimittuun
	verotuksen vertailumuuttujaan */

data output.&tulosnimi_kve;
	merge 	temp._temp_kvahdata
			temp._temp_kvah (keep = hnro KVAH_SIMUL vahoikus VAHOIKUS_SIMUL);
	by hnro;

	/* Tyhjätään nollat SUMWGT:tä varten */
	array piste KVAH--VAHOIKUS_SIMUL;
		do over piste;
			if piste = 0 then piste = .;
		end;

	/* Nimetään muuttujat */
	label 	KVAH 			= "Kotitalousvähennykset verotuksessa, data"
			KVAH_SIMUL		= "Kotitalousvähennysoikeus verotuksessa, simuloitu"
			vahoikus		= "Vähennysoikeus ennen omavastuuta ja kattoa, data"
			VAHOIKUS_SIMUL	= "Vähennysoikeus ennen omavastuuta ja kattoa, simuloitu";

run;

%mend KotitVahErill_Simul;

%KotitVahErill_Simul;
