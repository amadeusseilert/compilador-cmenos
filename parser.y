/****************************************************/
/* File: tiny.y                                     */
/* The TINY Yacc/Bison specification file           */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/
%{
#define YYPARSER /* distinguishes Yacc output from other code files */

#include "globals.h"
#include "util.h"
#include "scanner.h"
#include "parser.h"

#define YYSTYPE TreeNode *
static char * savedName; /* for use in assignments */
static int savedLineNo;  /* ditto */
static TreeNode * savedTree; /* stores syntax tree for later return */

/* allocate global variables */
int lineno = 0;
FILE * source;
FILE * listing;
FILE * code;

/* allocate and set tracing flags */
int EchoSource = FALSE;
int TraceScan = FALSE;
int TraceParse = TRUE;
int TraceAnalyze = FALSE;
int TraceCode = FALSE;

int Error = FALSE;

%}

%token IF ELSE WHILE RETURN INT VOID
%token ID NUM
%token ASSIGN EQ LT GT LTE GTE DIF PLUS MINUS TIMES OVER
%token LPAREN RPAREN SEMI COMA LBRCKT RBRCKT LBRACE RBRACE
%token ERROR
%token OC CC

%%

program : 				declaration_list
						;

declaration_list : 		declaration_list declaration
                 		| declaration
						| ERROR
                 		;

declaration :			var_declaration
	           			| fun_declaration
             			;

var_declaration :		type_specifier ID SEMI
                		| type_specifier ID LBRCKT NUM RBRCKT SEMI
						;

type_specifier :		INT
               			| VOID
	             		;

fun_declaration : 		type_specifier ID LPAREN params RPAREN compound_stmt
						;

params : 				param_list
						| VOID
						;

param_list : 			param_list COMA param
						| param
						;

param : 				type_specifier ID
						| type_specifier ID LBRCKT RBRCKT
      					;

	                    /* A function's scope is initilized before its parameters are
	                     * read. Here we check to see if the compound_stmt is the
	                     * function's body or a nested scope, since we already initalized
	                     * function body scope.
	                     */

compound_stmt : 		LBRACE local_declarations statement_list RBRACE
						;

local_declarations :	local_declarations var_declaration
                   		| /* empty */ ;

statement_list : 		statement_list statement
               			| /* empty */ ;

statement : 			expression_stmt
          				| compound_stmt
          				| selection_stmt
          				| iteration_stmt
          				| return_stmt ;

expression_stmt : 		expression SEMI
                		| SEMI
						;

selection_stmt : 		ifsubroutine  statement
               			| ifsubroutine  statement ELSE statement
               			;

ifsubroutine : 			IF  LPAREN expression RPAREN
						;

iteration_stmt : 		whilesubroutine LPAREN expression RPAREN statement
						;

whilesubroutine : 		WHILE
						;

return_stmt : 			RETURN SEMI
						| RETURN expression SEMI
						;

expression : 			var ASSIGN expression
						| simple_expression
						;

var : 					ID
						| ID LBRCKT expression RBRCKT
						;

simple_expression 		: additive_expression relop additive_expression
                  		| additive_expression
                  		;

relop : 				LTE
						| GTE
						| LT
						| GT
						| EQ
						| DIF
						;

additive_expression : 	additive_expression addop term
						| term
						;

addop : 				PLUS
      					| MINUS
      					;

term : 					term mulop factor
     					| factor
     					;

mulop : 				TIMES
      					| OVER
      					;

factor : 				LPAREN expression RPAREN
       					| var
       					| call
       					| NUM
       					;

call : 					ID LPAREN args RPAREN
     					;

args : 					arg_list
						| /* empty */
						;

arg_list : 				arg_list COMA expression
         				| expression
         				;
%%

int yyerror (char * message) {
	fprintf(listing,"Syntax error at line %d: %s\n", lineno, message);
	fprintf(listing,"Current token: ");
	printToken(yychar, tokenString);
	Error = TRUE;
	return 0;
}

/* yylex calls getToken to make Yacc/Bison output
* compatible with ealier versions of the TINY scanner
*/
static int yylex (void) {
	return getToken();
}

TreeNode * parse (void) {
	yyparse();
	return savedTree;
}

int main( int argc, char * argv[] ) {
	TreeNode * syntaxTree;

	char pgm[120]; /* source code file name */
	if (argc != 2){
		fprintf(stderr,"usage: %s <filename>\n", argv[0]);
		exit(1);
	}

	strcpy(pgm, argv[1]) ;
	if (strchr (pgm, '.') == NULL)
		strcat(pgm, ".cm");

	source = fopen(pgm, "r");
	if (source == NULL){
		fprintf(stderr, "File %s not found\n", pgm);
		exit(1);
	}

	listing = stdout; /* send listing to screen */
	fprintf(listing,"\nC MINUS COMPILATION: %s\n",pgm);
	/*#if NO_PARSE
	while (getToken()!=ENDFILE);
	#else*/
	syntaxTree = parse();

	/*if (TraceParse) {
		fprintf(listing,"\nSyntax tree:\n");
		printTree(syntaxTree);
	}*/
	/*#if !NO_ANALYZE
	if (! Error)
	{ if (TraceAnalyze) fprintf(listing,"\nBuilding Symbol Table...\n");
	buildSymtab(syntaxTree);
	if (TraceAnalyze) fprintf(listing,"\nChecking Types...\n");
	typeCheck(syntaxTree);
	if (TraceAnalyze) fprintf(listing,"\nType Checking Finished\n");
	}
	#if !NO_CODE
	if (! Error)
	{ char * codefile;
		int fnlen = strcspn(pgm,".");
		codefile = (char *) calloc(fnlen+4, sizeof(char));
		strncpy(codefile,pgm,fnlen);
		strcat(codefile,".tm");
		code = fopen(codefile,"w");
		if (code == NULL)
		{ printf("Unable to open %s\n",codefile);
		exit(1);
	}
	codeGen(syntaxTree,codefile);*/
	fclose(source);

	return 0;
}
