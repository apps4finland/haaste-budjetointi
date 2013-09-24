/****************************************************************************
* SISU-mikrosimulointimalli
* Copyright (C) 2013 Tilastokeskus
* Mallikoodia voi jakaa, modifioida ja hyödyntää Tilastokeskuksen yleisten
* käyttöehtojen mukaisesti,
* ks. http://www.stat.fi/org/lainsaadanto/yleiset_kayttoehdot.html tai
* LICENSE.TXT-tiedosto päähakemistossa.
******************************************************************************/

/* Tämä laskee yleveron testi-aineiston riveille */

%LET PVERO = pvero;
%LET PVERO_VARALL = pvero_varall; 	
%LET TYYPPI = ESIM;

/* Luodaan testi-niminen data, jossa on kolme muuttujaa */

DATA testi;

DO VERO_VUOSI = 2013 TO 2013;
DO IKA = 40 TO 40;
DO PALKKA = 1000 TO 50000 BY 1000;

OUTPUT;
END;END;END;
RUN;

/* Kutsutaan yleveron laskumakroa, ja lasketaan se testi-aineistoon */

data testi;
set testi;
	%YleVeroS(YLEVERO, VERO_VUOSI, 1, IKA, PALKKA, 2); 
run;


