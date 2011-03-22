/*
 * Autor: Kamil Pluszczewicz, program implementujacy szyfr Vigenere'a 
 * czyli bardzo sprytny szyfr dlugo uwazany za nie do zlamania 
 *
 */

#include <stdio.h>
#include <getopt.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>


#define NAZWA_PLIKU "enigma"
#define N 26
#define FILE_IN "plain.txt"
#define FILE_OUT "crypto.txt"
#define FILE_KEY "key.txt"
#define FILE_BLUE "blue.txt"

//wirniki I-V
int rot[5][26] = {
	{ 'K','M','F','L','G','D','Q','V','Z','N','T','O','W','Y','H','X','U','S','P','A','I','B','R','C','J','E'},
	{ 'A','J','D','K','S','I','R','U','X','B','L','H','W','T','M','C','Q','G','Z','N','P','Y','F','V','O','E'},
	{ 'B','D','F','H','J','L','C','P','R','T','X','V','Z','N','Y','E','I','W','G','A','K','M','U','S','Q','O'},
	{ 'E','S','O','V','P','Z','J','A','Y','Q','U','I','R','H','X','L','N','F','T','G','K','D','C','M','W','B'},
	{ 'V','Z','B','R','G','I','T','Y','U','P','S','D','N','H','L','X','A','W','M','J','Q','O','F','E','C','K'}
};

//beben odwracajacy
int R[26] = 
	{ 'F','V','P','J','I','A','O','Y','E','D','R','Z','X','W','G','C','T','K','U','Q','S','B','N','M','H','L'};

//funkcja wyliczajaca odwrotne wirniki
int rot_odwr(int x, int s, int off) {
	int i;
	for(i= 0 ; i< N; ++i) if(rot[x][i] == s + 'A') return (i - off < 0) ? i - off + 26: i - off; 
	return 0;
}

	
//funkcja stwierdzajaca, czy plik istnieje czy nie
int file_exists(const char* fileName) {
	FILE* plik;
	plik = fopen(fileName, "r");  /* ważne, by nie tworzyć pliku, jeśli nie istnieje, tryb "r" (tylko odczyt) */
	if ( plik )
		return 1;
	return 0;
}

/* prosta funkcja do bledow */
int blad(char *komunikat, int i) {
	printf("%s\n", komunikat);
	exit(i);
}

/* funkcja czyszczaca plik ze smieci */
int prepare_file(char * f) {
	if(!file_exists(f)) 
		blad("Plik z tekstem jawnym nie istnieje. Prosze utworzyc wczesniej", 1);

	FILE *f_in = fopen(f, "r");
	int i;
	int j=0;
	char buf[BUFSIZ];
	char temp[BUFSIZ];
	while(fgets(buf, sizeof buf, f_in)) {
		for(i = 0; i< strlen(buf);++i) if(isalpha(buf[i])) temp[j++] = toupper(buf[i]);	
	}
	temp[j] = '\0';
	fclose(f_in);
	f_in = fopen(FILE_IN, "w");
	fprintf(f_in, "%s", temp);
	fclose(f_in);
	return 0;
}

int generate_perms() {
	if (file_exists(FILE_BLUE)) {
		printf("Plik istnieje. Nadpisać (T/n)?");
		char opcja;
		scanf("%c", &opcja);
		if(opcja != 'T') 
			blad("Rezygnuje z nadpisania pliku", 1 );
	}

      	FILE * f_blue = fopen(FILE_BLUE, "w");


	char a,b,c;
	for(a = 'a'; a<='z'; ++a)
		for(b = 'a'; b <= 'z'; ++b)
			for(c = 'a'; c <= 'z'; ++c)
				fprintf(f_blue, "%c%c%c\n", a,b,c);
	fclose(f_blue);	
	return 0;
}

//Funkcja szyfrujaca/deszyfrujaca
int crypt(char *tekst, int *rotors, char *pos) {
	char wynik[6];

	int a = toupper(pos[0]) - 'A', b = toupper(pos[1]) - 'A', c = toupper(pos[2]) - 'A';
	int x = rotors[0] -1;
       	int y = rotors[1] -1;	
	int z = rotors[2] -1;

	/*printf("--------- Ustawienia poczatkowe: ----------\n");
	printf("Wybieram kola nr: %d %d %d\n", x, y, z);
	printf("Ustawiam pozycje poczatkowe: %c %c %c\n\n", a + 'A', b + 'A', c + 'A');*/

	
	int i;
	int znak;
	int q;
	//dla calej dlugosci wiadomosci
	for(i = 0; i<strlen(tekst); ++i) {
		znak = tekst[i] - 'A';

		q = rot[x][(znak + a) % 26] - 'A';
		q = rot[y][(q + b) % 26] - 'A';
		q = rot[z][(q + c) % 26] - 'A';

		q = R[q] - 'A';
		q = rot_odwr(z, q, c);
		q = rot_odwr(y,q , b);
		q = rot_odwr(x,q ,a);

		wynik[i] = q + 'A'; 

		c++;
		if(c == N) {
			b++;
			c = 0;
		}
		if(b == N) {
			a++;
			b = 0;
			if(a == N) a = 0;
		}
	}
	wynik[i] = '\0';

	//printf("\n-------- Przetworzono --------\n");
	if(strlen(wynik) < 70) {
		//printf("we:\t%s\n", tekst);	
		printf("%s\n", wynik);
	}

	return 0;
}

//czyta klucz z pliku
int get_key_from_file(int *r, char *p) {

	if(!file_exists(FILE_KEY)) blad("Plik z kluczem nie istnieje! Prosze utworzyc\n", 1);
	FILE *f_key = fopen(FILE_KEY, "r");
	int x,y,z;
	char a,b,c;

	fscanf(f_key, "%d", &x);
	fscanf(f_key, "%d", &y);
	fscanf(f_key, "%d\n", &z);

	fscanf(f_key, "%c %c %c", &a, &b, &c);

	if( x < 1 || x > 5 || y < 1 || y > 5 || z < 1 || z > 5) blad("Podano zle wartosci wirnikow. Mozliwe wartosci: 1-5, format pliku klucza:\n[1-5] [1-5] [1-5]\n[A-Z] [A-Z] [A-Z]\nOddzielenie spacjami i bez spacji na końcu", 1);

	if( !isalpha(a) || !isalpha(b) || !isalpha(c)) blad("Podano zle ustawienie poczatkowe wirnikow. Prawidlowy format pliku klucza:\n[1-5] [1-5] [1-5]\n[A-Z] [A-Z] [A-Z]\nOddzielenie spacjami i bez spacji na końcu", 1);
	a = toupper(a);
	b = toupper(b);
	c = toupper(c);

	r[0] = x;
	r[1] = y;
	r[2] = z;

	p[0] = a;
	p[1] = b;
	p[2] = c;

	fclose(f_key);
	return 0;
}

//No i wreszcie piekny, glowny fragment kodu
int main(int argc, char **argv) {

	int c;

	int eflag = 0;
	int pflag = 0;
	int dflag = 0;
	int kflag = 0;
	int hflag = 0;
	int aflag = 0;
	int gflag = 0;

	int s1[N];
	int s2[N];
	int s3[N];


	//przetwarzanie opcji
	while ((c = getopt( argc, argv, "rpegdkah")) != -1) {
		switch (c) {
			case 'e':
				eflag = 1;
				break;
			case 'd':
				dflag = 1;
				break;
			case 'k':
				kflag = 1;
				break;
			case 'p':
				pflag = 1;
				break;
			case 'h':
				hflag = 1;
				break;
			case 'a':
				aflag = 1;
				break;
			case 'g':
				gflag = 1;
				break;
			default:
				hflag = 1;
		}

	}

	if (argc == 1) {
		hflag = 1;
		printf("Nie podano zadnych opcji!\n");
	}

	if (hflag) {
		printf("Uzycie: ./%s opcje\n", NAZWA_PLIKU);
		printf("\t-p\toczyszczenie tekstu jawnego z niedozwolonych znakow\n");
		printf("\t-e\tszyfrowanie\n");
		printf("\t-d\tdeszyfrowanie\n");
		printf("\t-a\tprzygotowanie zestawu permutacji\n");
		printf("\t-k\tkryptoanaliza w oparciu o kryptogram\n");
		printf("\t-h\twyswietl pomoc\n");
		printf("\t-g\tgeneracja 100 losowych szyfrogramow z kluczami sesyjnymi\n");
		return 0;
	}

	if(pflag) {
		prepare_file(FILE_IN);
		printf("Oczyszczono\n");
	}

	if(aflag) {
		generate_perms();
		printf("Wygenerowano permutacje\n");
	}

	if(gflag) {
		int rotors[3];
		char pos[3];
		get_key_from_file(rotors, pos);

		srand(time(NULL));
		int i, j;
		char tab[100][7];
		for(i = 0; i<100; ++i) 
		{
			for(j = 0; j< 6; ++j) tab[i][j] = 'A' + rand() % 26;
			tab[i][6] = '\0';
			//printf("%s\n", tab[i]);
			crypt(tab[i], rotors, pos);
		}
		
	}

	return 0;
}
