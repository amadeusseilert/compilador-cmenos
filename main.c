/****************************************************/
/* Autor: Amadeus T. Seilert						*/
/* Arquivo: main.c                          	    */
/* Arquivo com função main do compilador C-.		*/
/****************************************************/

#include "globals.h"

/* NO_PARSE = TRUE : Gera um compilador com apenas analise léxica */
#define NO_PARSE FALSE
/* NO_ANALYZE = TRUE : Gera um compilador com apenas analise léxica e
sintática */
#define NO_ANALYZE FALSE
/* NO_CODE = TRUE : Gera um compilador com todas as análises mas não gera
código */
#define NO_CODE FALSE

#include "util.h"
#if NO_PARSE
#include "scanner.h"
#else
#include "parser.h"
#if !NO_ANALYZE
#include "analyze.h"
#include "symtab.h"
#if !NO_CODE
#include "cgen.h"
#endif
#endif
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


/* Defina aqui as flags de depuração descritas no globals.h */
int TraceScan = FALSE;
int TraceParse = FALSE;
int DebugParse = FALSE;
int TraceAnalyze = FALSE;
int TraceCode = FALSE;

/* Flag global que indica ocorrencia de erros */
int Error = FALSE;

/*
O executável deve ser chamado passando um argumento, que será o
arquivo de entrada 'source'.
*/
int main(int argc, char * argv[]) {

	YYSTYPE syntaxTree; /*árvore de sintaxe */

	char inputName[128];
	char outputName[128];

	if (argc != 3){ /* Verifica se a quantidade de argumentos é válida */
		fprintf(stderr,"usage: %s <input> <output>\n", argv[0]);
        exit(1);
    }

	strcpy(inputName, argv[1]);
	source = fopen(inputName, "r"); /* Tenta abrir o arquivo de entrada */
	if (source == NULL){
		fprintf(stderr, ANSI_COLOR_RED "Error at openning file %s" ANSI_COLOR_RESET "\n" , inputName);
		exit(1);
	}

	listing = stdout; /* Envia o arquivo de depuração para o stdout */
	fprintf(listing, "\n" ANSI_COLOR_YELLOW "C MINUS COMPILATION" ANSI_COLOR_RESET ": %s\n", inputName);
	fprintf(listing, "\n"ANSI_COLOR_YELLOW "Identified Tokens: "ANSI_COLOR_RESET "\n");
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
#if !NO_ANALYZE
  	if (!Error){
    	buildSymtab(syntaxTree);
		if (!Error) {
			if (TraceAnalyze) fprintf(listing,"\nChecking Types...\n");
	    	typeCheck(syntaxTree);
	    	if (TraceAnalyze) fprintf(listing,"\nType Checking Finished\n");
		}
  	}
#if !NO_CODE
	if (! Error) {

	    strcpy(outputName, argv[2]);
	    code = fopen(outputName, "w+");
	    if (code == NULL){
			printf("Unable to open %s\n", outputName);
	      	exit(1);
	    }
	    codeGen(syntaxTree, outputName);
	    fclose(code);
	  }
#endif
#endif
	freeTree(syntaxTree);
#endif
	fclose(source);

	if (!Error) {
		fprintf(listing, ANSI_COLOR_GREEN "\nCompilation Successful!\n" ANSI_COLOR_RESET);
	} else {
		fprintf(listing, ANSI_COLOR_RED "\nCompilation Unsuccessful!\n" ANSI_COLOR_RESET);
	}
	return 0;
}
