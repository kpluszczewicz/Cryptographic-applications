#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <getopt.h>
#include <string.h>

#define F_PLAIN "plain.txt"
#define F_CRYPTO "crypto.txt"
#define F_KEY "key.txt"

#define N 26

double probs[] = {
	0.082, //a
	0.015, //b
	0.028, //c
	0.043, //d
	0.127, //e
	0.022, //f
	0.020, //g
	0.061, //h
	0.070, //i
	0.002, //j
	0.008, //k
	0.040, //l
	0.024, //m
	0.067, //n
	0.075, //o
	0.029, //p
	0.001, //q
	0.060, //r
	0.063, //s
	0.091, //t
	0.028, //u
	0.010, //v
	0.023, //w
	0.001, //x
	0.020, //y
	0.001 //z
};

//funkcja max zwracajaca indeks najwiekszego el w tablicy
int max(double *tab, int size) {
	int i = 1, i_max = 0;
	double max = tab[0];
	while(i < size) {
		if (max < tab[i]) {
			max = tab[i];
			i_max = i;	
		}
	}	
	return i;
}

//zwykla srednia arytmetyczna
double avg(double *tab, int size) {
	int i;
	double pom = 0;
	for(i = 0; i< size; ++i)
		pom += tab[i];
	return pom / size;
}

//ot standartowy iloczyn skalarny, mnozy tablice o 26 elementach
double il_scal(double *v, double *u) {
	double pom = 0;
	int i = 0;
	for(; i< N ; ++i) pom =+ pom + v[i] * u[i];
	return pom;
}

//iloczyn skalarny z mozliwoscia dzialania na przesunietym drugim wektorze
double il_scal_mod(double *v, double *u, int offset) {
	double pom = 0;
	int i;
	for(i=0; i< N; ++i) pom += v[i] * u[(offset + i) % N];
	return pom;
}



//funkcja analizujaca szyfrogram, zwraca zlamany klucz
int* analyze() {
	double I = il_scal(probs, probs);	//indeks ko dla eng
	int i, j;
	int d, l, klucz;	
	char buf[1024];

	FILE *f_crypto = fopen(F_CRYPTO, "r");

	double *indeksy;
	double indeks = 0;

	fgets(buf, sizeof buf, f_crypto);
	l = strlen(buf);

	if (l < 500) printf("Dla krotkich dlugosci kryptogramu analiza moze sie nie powiesc.\n");

	/* podac tutaj orientacyjna dlugosc klucza */
	for(d = 1; d < 20; ++d) {
	
		printf("Dla d = %d\n", d);
		indeksy = malloc(sizeof(double) *  d);
		for( i = 0; i< d ; i++) indeksy[i] = 0;
		for( j = 0; j < d; j++) {
			int f[N] = {};
			
			//oblicz wartosci f dla poszczegolnych kolumn
			for( i = 0; i < l / d; ++i) 
				f[buf[d*i + j] - 'a']++;
			
			//Wylicz indeks koincydencji dla kolumny
			
			for( i= 0; i < N; ++i) 
				indeksy[j] += f[i]*(f[i] -1);

			indeksy[j] = indeksy[j] /(l/(double)d*(l/(double)d -1));
		}
		double srednia = avg(indeksy, d);
		printf("Sredni indeks koincydencji %lf\n", srednia);
		if( I - srednia < I - indeks ) {
		       indeks = srednia;
		       klucz = d;
		}
		free(indeksy);


	}
	printf("\n\nPodejrzewana dlugosc klucza to %d\n", klucz);
	printf("Obliczam kolejne pozycje klucza\n");

	/* Faza II znajdowanie liter klucza */
	
	int *wsk = malloc(sizeof(int) * klucz);

	for(d=0; d<klucz; ++d) {
		double czest[N] = {};	
		double max = 0;
		int i_max = 0;

		for(i=0;i<l/klucz;++i) 
			czest[buf[i*klucz+d] - 'a'] += 1;

		for(i=0; i<N; ++i) 
			 czest[i] = czest[i] / (l/klucz);

		for(i=0; i<N; ++i) {
			double pom = il_scal_mod(probs, czest, i);
			if(pom > max) {
				max = pom;
				i_max = i;
			}
		}
		printf("%d. litera klucza = %c\n",d, i_max + 'a');
		wsk[d] = i_max + 'a';
	}

	return wsk;
}

/* prosta funkcja do bledow */
int err_msg(char *komunikat, int i) {
	printf("%s\n", komunikat);
	exit(i);
}

/* funkcja czyszczaca plik ze smieci */
int prepare_file() {
	FILE *f_in = fopen(F_PLAIN, "r");
	int i;
	int j=0;
	char buf[1024];
	char temp[1024];
	while(fgets(buf, sizeof buf, f_in)) {
		for(i = 0; i< strlen(buf) - 1;++i) if(isalpha(buf[i])) temp[j++] = tolower(buf[i]);	
	}
	temp[j] = '\0';
	fclose(f_in);
	f_in = fopen(F_PLAIN, "w");
	fprintf(f_in, "%s", temp);
	fclose(f_in);
	return 0;
}

int decrypt(int y, int key) {
	return	'a' + (y - key + N) % N; 
}
int encrypt(int x, int key) {
	return 'a' + (x + key - 2 * 'a') % N;
}

//Funkcja szyfrujaca/deszyfrujaca
int crypt(char *key, int mode) {
	FILE *f_in = fopen(mode == 'e' ? F_PLAIN : F_CRYPTO, "r+");
	FILE *f_out = fopen(mode == 'e' ? F_CRYPTO : F_PLAIN, "r+");

	int i;
	int (*fun)(int,int) = mode == 'e' ? encrypt : decrypt;
	int k = strlen(key);
	printf("%d\n", k);
	char buf[1024], cipher[1024];
	fgets(buf, sizeof buf, f_in);
	if(buf[strlen(buf) -1] == '\n') buf[strlen(buf) - 1] = '\0';
	printf("%s\n" , buf);
	cipher[strlen(buf) - 1] = '\0';
	
	for(i = 0; i < strlen(buf) ; ++i) {
		//aktualny klucz key[i % k]	
		printf("%c ", buf[i]);
		buf[i] = fun(buf[i] ,key[i % k]);
		printf("%c ", key[i%k]);
		printf("%c \n", buf[i]);

	}
	printf("%d\n" , strlen(buf));
	buf[i] = '\0';
	
	fprintf(f_out, "%s", buf);
	fclose(f_out);
	fclose(f_in);
	return 0;
}

//czyta klucz z pliku
int get_key_from_file(char *key) {
	FILE *f_key = fopen(F_KEY, "r");
	char buf[128];
	fgets(buf, sizeof buf, f_key);
	buf[strlen(buf) - 1] = '\0';
	printf("%s \n", buf);
	strcpy(key, buf);
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


	//przetwarzanie opcji
	while ((c = getopt( argc, argv, "pedk")) != -1) {
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
			default:
				hflag = 1;
		}

	}

	if (argc == 1) {
		hflag = 1;
		printf("Nie podano zadnych opcji!\n");
	}

	if (hflag) {
		printf("Uzycie: ./szyfrator opcje\n");
		printf("\t-e\tszyfrowanie\n");
		printf("\t-d\tdeszyfrowanie\n");
		printf("\t-k\tkryptoanaliza w oparciu o kryptogram\n");
		printf("\t-h\twyswietl pomoc\n");
		return 0;
	}

	if(pflag) {
		prepare_file();
		printf("Oczyszczono\n");
	}

	char key[128];

	if(dflag) {
		get_key_from_file(key);
		crypt(key, 'd');
	}
	if(eflag) {
		get_key_from_file(key);
		crypt(key, 'e');
	}
	if(kflag) 
		analyze();

	return 0;
}
