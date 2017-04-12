/****************************************************/
/* Autor: Amadeus T. Seilert						*/
/* Arquivo: main.c                          	    */
/* Arquivo com função main do compilador C-.		*/
/****************************************************/

#include "globals.h"

/* set NO_PARSE to TRUE to get a scanner-only compiler */
#define NO_PARSE FALSE
/* set NO_ANALYZE to TRUE to get a parser-only compiler */
//#define NO_ANALYZE FALSE

/* set NO_CODE to TRUE to get a compiler that does not
 * generate code
 */
//#define NO_CODE FALSE

#include "util.h"
#if NO_PARSE
#include "scanner.h"
#else
#include "parser.h"
// #if !NO_ANALYZE
// #include "analyze.h"
// #if !NO_CODE
// #include "cgen.h"
// #endif
// #endif
#endif

/****************************************************/
/* ---------- Configurações de execução -----------	*/
/* Aloca as variáveis globais definidas no 			*/
/* cabeçalho 'globals.h'. OBS: leia 'globals.h' 	*/
/****************************************************/
int lineno = 0;
FILE * source;
FILE * listing;
FILE * code;

int TraceScan = TRUE;
int TraceParse = TRUE;

int Error = FALSE;

/*
O executável deve ser chamado passando um argumento, que será o
arquivo de entrada 'source'.
*/
int main(int argc, char * argv[]) {

	YYSTYPE syntaxTree; /*árvore de sintaxe */

	char inputName[128];

	if (argc != 2){ /* Verifica se a quantidade de argumentos é válida */
		fprintf(stderr,"usage: %s <input>\n", argv[0]);
        exit(1);
    }

	strcpy(inputName, argv[1]);
	source = fopen(inputName, "r"); /* Tenta abrir o arquivo de entrada */
	if (source == NULL){
		fprintf(stderr, ANSI_COLOR_RED "Error at openning file %s" ANSI_COLOR_RESET "\n" , inputName);
		exit(1);
	}

	listing = stdout; /* Envia o arquivo de depuração para o stdout */
	fprintf(listing, "\n" ANSI_COLOR_YELLOW "C MINUS COMPILATION" ANSI_COLOR_RESET "\n");
	fprintf(listing, "\nIdentified Tokens:\n");
#if NO_PARSE
	while (getToken() != EOF);
#else
	syntaxTree = parse();

	if (TraceParse) {
		/* Caso a flag de TraceScan for TRUE, a árvore de sintaxe é impressa no
		listing */

      	fprintf(listing, "\n"ANSI_COLOR_YELLOW "Syntax tree:"ANSI_COLOR_RESET"\n");
      	printTree(syntaxTree);
    }

	// code = fopen("output.cmm", "w+"); /* Tenta abrir o arquivo de saída */
	// if (code == NULL) {
	// 	fprintf(stderr, "Error at openning file output.cmm\n");
	// 	exit(1);
	// }
	// fclose(code);
	free(syntaxTree);
#endif
	fclose(source);
	return 0;
}
