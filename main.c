#include "globals.h"
#include "util.h"
#include "scanner.h"
#include "parser.h"

//#define YYDEBUG 1

/* Aloca as variáveis globais definidas no cabeçalho 'globals.h' */
int lineno = 0;
FILE * source;
FILE * listing;
//FILE * code;

int TraceScan = TRUE;

int Error = FALSE;

int main( int argc, char * argv[] ) {
	YYSTYPE syntaxTree;
	char pgm[128]; /* source code file name */
	//yydebug = 0;
	if (argc != 2){
		fprintf(stderr,"usage: %s <filename>\n", argv[0]);
        exit(1);
    }

	strcpy(pgm, argv[1]) ;
    if (strchr (pgm, '.') == NULL)
       strcat(pgm,".cm");
	   
	source = fopen(pgm, "r");
	if (source == NULL){
		fprintf(stderr, "File %s not found\n", argv[1]);
		exit(1);
	}

	listing = stdout;
	fprintf(listing, "\nC MINUS COMPILATION\n");
	syntaxTree = parse();
	printTree(syntaxTree);
	fclose(source);
	free(syntaxTree);

	return 0;
}
