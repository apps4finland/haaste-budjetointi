Huomioita SISU-mallin käytöstä
==============================

Yleisiä huomioita

* SISU-malli kokonaisuudessaan on raskas malli ja työläs muuttaa eri
formaatteihin. Jos käyttäjä halua rajoittua johonkin osamalliin, on
tämä mahdollista mutta silloin on pidettävä mielessä se että kaikki osamallit
vaikuttavat kokonaisuuteen (esim. kokonaisverotukseen) ja toinen toisiinsa.
Esimerkiksi pelkkä verotuksen simulointi voi antaa harhaanjohtavan tai
vaikeasti tulkittavan kuvan. Kuluttajakansalaisen näkökulmasta voisi olla
järkevämpää rakentaa jonkinlainen ostovoimamalli tai peli, joka optimoi
ostovoimaa.
* Yksinkertainen peli-idea olisi huomioida pelkän palkkaverotuksen osalta
hallituksen verolakimuutosten vaikutus omaan kukkaroon (ja fiktiivisen
rekisteripopulaation avullla vaikutus valtion kukkaroon). Yksinkertaisimmillaan
tässä vaikutusanalyysissä olisi mukana pelkkä palkkataso mallin
muuttujana. Paljon monimutkaisempaa olisi esim. huomioida palkkatason ja
opintotuen yhdistelmävaikutukset tai puolisoiden vaikutus toistensan
verotukseen.
* SISU-malli ei huomioi kulutusveroja (ALV) tai dynaamisia kerranaisefektejä,
joita verotuksella on kuluttajiin.
* Yksi mahdollisuus olisi rajoittua pelkästään henkiläveromallin käyttöön,
mutta käytännössä kehittäjällä on mahdollisuus valita mikä tahansa sopiva
osakokonaisuus veromallista omaa kilpailutyötään varten. Henkilöveromallista
voi suoraviivaisesti esimerkiksi testata, mitä vaikutuksia erisuuruisella
Yle-verolla olisi valtion verotuloihin.
* Ongelma osamalleihin rajoittumisessa on se, että kaikki osamallit
riippuvat toisistaan ja henkilöverotkin riippuvat esim. saaduista
äitiyspäivärahoista, työttömyyskorvauksista ym. ja nämä kerrannaisefektit
(jotka voivat olla merkittäviä koko kansantalouden tasolla) jäävät
huomioimatta kun ajetaan vain SISU-mallin osamallia
* ALKUsimul-tiedosto sisältää alustukseen tarpeellisia kirjastoviittausia
sekä osamallien ajamisessa tarvittavien makromuuttujien määrittelyjä
* Makroihin luetaan (1) APUmakrot kuten VEROAPUmakro sekä (2) lakimakrot
* Apumakrot imevät isosta laki-tms. lainsäädännön parametritaulukosta olennaiset
rivit ja sarakkeet, jotta laskennasta tulisi kevyempää.
* DATA-kansioon sijoitetaan POHJADATA, (oikea aineisto) ja se pitää myöhemmin
tehdä Public Use Fileksi (PUF). Nyt DATA-kansio on tyhjä koska
rekisteriaineistoista ei ole vielä tehty Public Use-tiedostoja. Tämä
on erittään vaikeaa, sillä välillisen tunnistuksen estäminen sadoista
metamuuttujista koostuvan profiilin takia anonymisointi on hankalaa.
*ESIM-laskenta generoi fiktiivisiä populaatioita (vuoden valinta kuvaa
myös tietyn lainsäädännön valintaa, mikä sillä hetkellä on ollut voimassa)
* VM:n ja STM:n lakimuutoksia tulee viikoittain, joten lakimakroja täytyy
jatkuvasti päivittää. Hallituksen esitykset tuleva VMn ja muiden
ministeriöiden virallisillle sivuille nähtäviksi ja sieltä ne pitää siirtää
lakimakroihin. <br>
ONGELMA: kuinka automatisoda prosessia nopeammaksi?
* Aineistoin projisioiminen tulevaisuuteen eli ns. ajantasaistus on erittäin
haastava homma, asiantuntijahommaa. Ennusteiden vertailukelpoisuus kärsii,
jos ajantasaistusta ei ole tehty yhteismitallisesti.



Henkilöverotuken simulointiin liittyviä asioita

* Jos rajoitutaan henkilöverotukseen, voidaan periaatteessa toisintaa
Verohallinnon-sivuilta löytyvä henkilöverotuslomake (joka ei perustu
SISUun vaan Verottajan omiin ohjelmiin). Tietyt asiat on Verottajan
laskukaavoissa kiinnitetty, mutta niitä voidaan muuttaa SISU-mallissa.
* Puhtaasti jo Verohallinnon sivuilta löytyvän veroilmoituslomakkeen
toisintaminen (yksityiskohtaisemmalla parametrisoinnilla) olisi mielenkiintoinen
harjoitus
*Verolakimakro-27 - olennainan palikka (löytyy kansiosta
MAKROT/VEROlakimakrot.sas). Siihen voi syöttää listaa erilaisista 
palkkatasoista (vähennykset verottajan puolesta) 
*VEROesim.sas -file toimii käyttöliittymänä, jota kilpailijat voivat
hyödyntää graafisen käyttöliittymän sijaan (sen kautta voidaan luoda
fiktiiviset populaatioaineistot ja suorittaa simulointi SISU-mallilla).
* Parametritaulukoista verotukseen tarvitaan pverot.sas
* ALKUsimul.sas tarvitaan aina
* VEROsimul.sas -tiedostoa EI tarvita, koska se hyödyntää oikeaa rekisteriaineistoa,
VEROesim.sas-tiedostoa voidaan käyttää sen sijaan, se hyödyntää
fiktiivistä populaatioaineistoa
* Vielä yksinkertaisempi "käyttöliittymätiedosto" kuin VEROesim.sas on nyt
tallennettu päähakemistoon nimellä Esimerkki.sas. Esimerkki.sas-tiedostolla
pääsee alkuun simuloinnissa!
* poista PVERO-tiedostosta "tulevaisuuden rivit" (v. 2014-2017) PARAM-kansiossa,
ja pidä vain vuoden 2013 rivi.
*t uloveroasteikon kynnystystä voi muuttaa (tämä simuloi lainsäädännön
vaikutusta). Voidaan esim. simuloida eri vuosien vertailu 40-henkilön
verotukseen eri palkkatasoilla
* tuloveroaskteikkoa muuttamalla (PARAM, Pvero) voi tutkia sekä
valtakunnallisen että kunnallisveroprosentin vaikutusta.
* Verottajan veroprosenttilaskuria voisi täydentää niin että voi valita eri
vuodet (veroperusteiden muutokset)
* ONGELMA: käyttäjät eivät hahmota esim. mitä tarkoittaa työtulovähennyksen
minimimäärä ja miksi se on kiinnitetty niin kuin se on. Jonkinmoisen selityksen
voi hakea veroilmoituksen täyttöoppaasta Verottajan sivuilta, mutta syvempi
merkitys, jota tarvitaan politiikkavaihtoehdoista väiteltäessä vaatii
enemmän töitä. Esim. työtulovähennyksen kuvitellaan vaikuttavan kannustavasti
työn tekemiseen.

