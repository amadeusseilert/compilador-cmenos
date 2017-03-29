#include "globals.h"

/* set NO_PARSE to TRUE to get a scanner-only compiler */
#define NO_PARSE FALSE
/* set NO_ANALYZE to TRUE to get a parser-only compiler */
// #define NO_ANALYZE FALSE

/* set NO_CODE to TRUE to get a compiler that does not
 * generate code
 */
// #define NO_CODE FALSE

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

/* Aloca as variáveis globais definidas no cabeçalho 'globals.h' */
int lineno = 0;
FILE * source;
FILE * listing;
FILE * code;

/* Define as flags para o uso */
int EchoSource = FALSE;
int TraceScan = FALSE;
int TraceParse = TRUE;
int TraceAnalyze = FALSE;
int TraceCode = FALSE;

int Error = FALSE;

int main( int argc, char * argv[] ) {
	TreeNode * syntaxTree;

	char pgm[120]; /* source code file name */
	if (argc != 2){
		fprintf(stderr,"usage: %s <filename>\n", argv[0]);
		exit(1);
	}

	source = fopen(argv[1], "r");
	if (source == NULL){
		fprintf(stderr, "File %s not found\n", pgm);
		exit(1);
	}

	listing = stdout; /* send listing to screen */
	fprintf(listing,"\nC MINUS COMPILATION: %s\n",pgm);
	syntaxTree = parse();
	fclose(source);
	free(syntaxTree);

	return 0;
}
