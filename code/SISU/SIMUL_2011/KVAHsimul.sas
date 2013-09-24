/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hy�dynt�� Tilastokeskuksen yleisten
* k�ytt�ehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto p��hakemistossa.
******************************************************************************/

/******************************************************************************
* Kuvaus: Kotitalousv�hennyksen erillistaulun simulointimokkula
* Tekij�: Jukka Mattila / TK		   			           
* Luotu: 14.5.2012				     					   
* Viimeksi p�ivitetty: 14.5.2012 			 		   	   
* P�ivitt�j�: Jukka Mattila / TK			     		   
******************************************************************************/

/* X. Kotitalousv�hennyksen erillistaulun laskentamakro.
	Laskee kotitalousv�hennyksen tarkemman erittelyn sis�lt�v�st�
	erillistaulusta.

Parametrit:
    tulos: Makron tulosmuuttuja, kotitalousv�hennysoikeus
	mvuosi: Vuosi, jonka lains��d�nt�� k�ytet��n
	minf: Deflaattori eurom��r�isten parametrien kertomiseksi 
	palksiku: palkatun ty�ntekij�n palkan sivukulut, oma osuus
	palkomos: palkatun ty�ntekij�n palkka, oma osuus
	tyonosuu: ty�n osuus yrityksen ty�st�
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

/* 3.1. Poimitaan perusaineistosta kotitalousv�hennyksiin liittyv�t tiedot */

data temp._temp_kvahdata; set pohjadat.&aineisto&avuosi
	(keep = hnro &paino vkotita vkotitki vkotitku vkotitsv vkotitp);

	/* Summataan datan verotuksen kotitalousv�hennykset vertailutiedoksi */
	KVAH = sum(vkotita, vkotitki, vkotitku, vkotitsv, vkotitp, 0);

	keep hnro &paino &MUUTTUJAT KVAH;
run;

/* 3.2 Kotitalousv�hennyksen laskenta */

data temp._temp_kvah; set pohjadat.&vahdata;

	%KotitVahErillS(KVAH_SIMUL, &lvuosi, &inf, palksiku, palkomos, tyonosuu)

run;

/* 3.5 Liitet��n tulokset pohja-aineistosta poimittuun
	verotuksen vertailumuuttujaan */

data output.&tulosnimi_kve;
	merge 	temp._temp_kvahdata
			temp._temp_kvah (keep = hnro KVAH_SIMUL vahoikus VAHOIKUS_SIMUL);
	by hnro;

	/* Tyhj�t��n nollat SUMWGT:t� varten */
	array piste KVAH--VAHOIKUS_SIMUL;
		do over piste;
			if piste = 0 then piste = .;
		end;

	/* Nimet��n muuttujat */
	label 	KVAH 			= "Kotitalousv�hennykset verotuksessa, data"
			KVAH_SIMUL		= "Kotitalousv�hennysoikeus verotuksessa, simuloitu"
			vahoikus		= "V�hennysoikeus ennen omavastuuta ja kattoa, data"
			VAHOIKUS_SIMUL	= "V�hennysoikeus ennen omavastuuta ja kattoa, simuloitu";

run;

%mend KotitVahErill_Simul;

%KotitVahErill_Simul;
