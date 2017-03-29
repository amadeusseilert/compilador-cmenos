/****************************************************/
/* Autor: Amadeus T. Seilert						*/
/* Arquivo: parser.y	                            */
/* Arquivo de definições para o Bison, que			*/
/* produzirá o parser do compilador					*/
/****************************************************/

%{
#define YYPARSER /* Distingui o output do Yacc dos outros arquivos de código */

#include "globals.h"
#include "util.h"
#include "scanner.h"
#include "parser.h"

#define YYSTYPE TreeNode *
static char * savedName; /* Usado em atribuições */
static int savedLineNo;  /* Usado em atribuições */

/*
Armazena a árvore de sintaxe para uso posterior.
*/
static TreeNode * savedTree;

%}

%token IF ELSE WHILE RETURN INT VOID
%token ID NUM
%token ASSIGN EQ LT GT LTE GTE DIF PLUS MINUS TIMES OVER
%token LPAREN RPAREN SEMI COMA LBRCKT RBRCKT LBRACE RBRACE
%token ERROR
%token OC CC

%%

program : 				declaration_list
						{
							/*
							Atribui o valor semântico do programa como uma
							lista de declarações no nó inicial da árvore
							*/
							savedTree = $1;
						}
						;

declaration_list : 		declaration_list declaration
						{
							/*
							Enquanto existem regras de declarações reconhecidas,
							percorre os "irmãos" do nó corrente.
							*/
							YYSTYPE t = $1;
							if (t != NULL) {
								while (t->sibling != NULL)
									t = t->sibling;

								/*
								Encontra o final da lista de declarações e
								adiciona a mais nova declaração como irmão
								do último elemento
								*/
								t->sibling = $2;
								$$ = $1;
							} else {
								$$ = $2;
							}
						}
                 		| declaration
						{
							$$ = $1;
						}
                 		;

declaration :			var_declaration
						{
							$$ = $1;
						}
	           			| fun_declaration
						{
							$$ = $1;
						}
						| ERROR
						{
							$$ = NULL;
						}
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

compound_stmt : 		LBRACE local_declarations statement_list RBRACE
						;

local_declarations :	local_declarations var_declaration
                   		| /* vazio */ ;

statement_list : 		statement_list statement
               			| /* vazio */ ;

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
						| /* vazio */
						;

arg_list : 				arg_list COMA expression
         				| expression
         				;
%%
/*
Função responsável em emitir as mensagens de erro de sintaxe no listing.
*/
int yyerror (char * message) {
	fprintf(listing,"Syntax error at line %d: %s\n", lineno, message);
	fprintf(listing,"Current token: ");
	printToken(yychar, tokenString);
	Error = TRUE;
	return 0;
}

/*
Esta função invoca a função getToken para criar um output do Yacc/Bison
compatível com versões mais antigas do Lex.
*/
static int yylex (void) {
	return getToken();
}

/*
Esta função inicia a análise e constroi a árvore de sintaxe.
 */
TreeNode * parse (void) {
	yyparse();
	return savedTree;
}
