/****************************************************/
/* Autor: Amadeus T. Seilert						*/
/* Arquivo: parser.y	                            */
/* Arquivo de definições para o Bison, que			*/
/* produzirá o parser do compilador					*/
/****************************************************/

%{
/* Distingui o output do Yacc dos outros arquivos de código */
#define YYPARSER
/* Define que o parser pode estrar no modo de depuração. A flag que efetivamente
habilita a tarefa é a 'DEBUG_PARSE' em 'globals.h' */
#define YYDEBUG 1

#include "globals.h"
#include "util.h"
#include "scanner.h"
#include "parser.h"
/* Em caso de modificações na gramática para atribuição de expressão direto
na declaração de variáveis, é necessário utilizar um vetor de nomes salvos */
static char * savedName; /* Usado em Mid-Rule para expressões*/
/* Em caso de modificações na gramática para a possibilidade da utilização de
funções anônimas, é necessário utilizar um vetor de nomes salvos.*/
static char * savedFunctionName; /* Usado em Mid-Rule para expressões */
static int savedValue; /* Usado em Mid-Rule */

/* Armazena a árvore de sintaxe para uso posterior. */
static YYSTYPE savedTree = NULL;
/* Armazena um nó que corresponde a declaração de uma função. Será usado
posteriormente na análise semântica em valores de escopo */
static YYSTYPE enclosingFunction = NULL;


/*

error-verbose = mostra mensagens de erro com mais informações.
Abaixo está definido qual é a regra inicial da análise de sintaxe.
Em seguida, estão definidos a totalidade dos tokens usados na gramática.
Por fim, a declaração '%nonassoc' estabelece quais tokens não são associativos.
E '%left' estabelece a ordem de precedência mais a esquerda do grupo.

http://dinosaur.compilertools.net/bison/bison_6.html#SEC57
*/
%}

%error-verbose
%start program

%token IF ELSE WHILE RETURN INT VOID
%token ID NUM
%token ASSIGN EQ LT GT LTE GTE DIF PLUS MINUS TIMES OVER
%token LPAREN RPAREN SEMI COMA LBRCKT RBRCKT LBRACE RBRACE
%token ERROR OC CC

%nonassoc LT LTE GT GTE EQ DIF
%left PLUS MINUS
%left TIMES OVER

%%

program : 	declaration_list { savedTree = $1; }
        	;

declaration_list : declaration_list  declaration
			{
				/* Itera por todos os nós previamentes reconhecidos como
				declaration, o último nó reconhecido se torna irmão do nó que
				acabou de ser reconhecido */
				YYSTYPE t = $1;
                if( t != NULL ){
					while (t->sibling != NULL)
						t = t->sibling;
                    t->sibling = $2;
                    $$ = $1;
            	} else
                	$$ = $2;
            }
			| declaration { $$ = $1; }
			;

declaration : var_declaration { $$ = $1; }
		  	| fun_declaration { $$ = $1; }
      		| error { $$ = NULL; }
		  	;

var_declaration : type_specifier ID
			{
				/* Aqui define-se um caso de Mid-Rule Action. É de interesse
				guardar o valor do token ID, pois se usar a variável
				lastTokenString no final da regra (End-Rule Action), ela teria o
				valor do último lexema da regra, que neste caso, seria ';'
				(SEMI).
				https://www.gnu.org/software/bison/manual/html_node/Using-Mid_002dRule-Actions.html#Using-Mid_002dRule-Actions
				*/
				savedName = copyString(lastTokenString);
			}
					SEMI
			{
				$$ = $1;
				$$->nodekind = DeclK;
				$$->kind.decl = VarK;
				$$->name = savedName;
				/* O escopo de uma variável pode ser global (enclosingFunction
				= NULL) ou local (última declaração de função armazenada em
				enclosingFunction) */
				$$->enclosingFunction = enclosingFunction;
				$$->idtype = Simple;
			}
			| type_specifier ID
			{
				savedName = copyString(lastTokenString);
			}
					LBRCKT NUM
			{
				/* Aqui define-se outro caso de Mid-Rule Action. É de interesse
				guardar o valor do token NUM, pois se usar a variável
				lastTokenString no final da regra (End-Rule Action), ela teria o
				valor do último lexema da regra, que neste caso, seria ';'
				(SEMI).
				*/
				savedValue = atoi(tokenString);
			}
					RBRCKT SEMI
			{
				$$ = $1;
				$$->nodekind = DeclK;
				$$->kind.decl = VarK;
				$$->name = savedName;
				$$->enclosingFunction = enclosingFunction;
				$$->val = savedValue;
				$$->idtype = Array;
			}
			;

type_specifier : INT
			{
				$$ = newNode();
				$$->type = Integer;
			}
	        | VOID
			{
				$$ = newNode();
				$$->type = Void;
			}
		    ;

fun_declaration : type_specifier ID

			{
				savedFunctionName = copyString(lastTokenString);
				enclosingFunction = $1; /* "Abre" um escopo */
			}
					LPAREN params RPAREN compound_stmt
			{
				/* Uma nó do tipo declaração de função possui como nós filhos
				os argumentos e uma composição de declarações e expressões.
				*/
 			    $$ = $1;
				$$->nodekind = DeclK;
				$$->kind.decl = FunK;
 			    $$->name = savedFunctionName;
				$$->idtype = Function;
 				$$->child[0] = $5;
 				$$->child[1] = $7;
				/* Como todos os nós dentro da regra coupound_stmt já foram
				processados, podemos "Fechar" o escopo aqui. */
				enclosingFunction = NULL;
 			}
 			;

params : 	param_list { $$ = $1; }
	  		| VOID {$$ = NULL; }
	  		;

param_list : param_list COMA param
			{
				/*
				Itera sobre os argumentos e associa os nós irmãos do último
				parâmetro reconhecido.
				*/
			  	YYSTYPE t = $1;
			  	if (t != NULL){
					while (t->sibling != NULL)
						t = t->sibling;
					t->sibling = $3;
					$$ = $1;
			  	} else {
					$$ = $3;
				}
			}
			| param { $$ = $1; }
			;

param : 	type_specifier ID
			{
				$$ = $1;
				$$->nodekind = DeclK;
				/* A declaração de um parâmetro associa ao escopo corrente */
				$$->enclosingFunction = enclosingFunction;
				$$->kind.decl = ParamK;
				$$->name = copyString(lastTokenString);
				$$->idtype = Simple;

			}
			| type_specifier ID
			{
				savedName = copyString(lastTokenString);
			}
				LBRCKT RBRCKT
			{
				/* Um parâmetro é do tipo array se possui '[]' em seguida do
				identificador */
				$$ = $1;
				$$->nodekind = DeclK;
				$$->enclosingFunction = enclosingFunction;
				$$->kind.decl = ParamK;
				$$->name = savedName;
				$$->idtype = Array;
            }
	  		;

compound_stmt : LBRACE local_declarations statement_list RBRACE
			{
				/* Essa regra define que, dentro de um escopo, sempre deve ser
				feito declaração das variáveis antes da utilização delas em
				eventuais expressões. */
            	$$ = newNode();
				$$->nodekind = StmtK;
				$$->kind.stmt = CmpdK;
				$$->enclosingFunction = enclosingFunction;
            	$$->child[0] = $2;
				$$->child[1] = $3;
			}
			;

local_declarations : local_declarations var_declaration
			{
				if( $1 != NULL ){
    				$$ = $1;
    				YYSTYPE t = $$;
    				while (t->sibling != NULL)
    					t = t->sibling;
    				t->sibling = $2;
    			} else {
    				$$ = $2;
    			}
    		}
			| { $$ = NULL; }
			;

statement_list : statement_list statement
			{
            	if( $1 != NULL ){
                    $$ = $1;
    				YYSTYPE t = $$;
    				while(t->sibling != NULL)
    					t = t->sibling;
    				t->sibling = $2;
    			} else {
    				$$ = $2;
    			}
    		}
            | { $$ = NULL; }
            ;

statement : expression_decl { $$ = $1; }
         	| compound_stmt { $$ = $1; }
         	| selection_decl { $$ = $1; }
         	| iteration_decl { $$ = $1; }
         	| return_decl { $$ = $1; }
            | error { $$ = NULL; }
         	;

expression_decl : expression SEMI { $$ = $1; }
			| SEMI { $$ = NULL; }
			;

selection_decl : IF LPAREN expression RPAREN statement else_decl
			{
				/* A gramática define que o 'else' é opcional */
                $$ = newNode();
				$$->nodekind = StmtK;
				$$->kind.stmt = IfK;
                $$->child[0] = $3;
            	$$->child[1] = $5;
                $$->child[2] = $6;
            }
            ;

else_decl : ELSE statement { $$ = $2; }
         	| { $$ = NULL; }
        	;

iteration_decl : WHILE LPAREN expression RPAREN statement
			{
				$$ = newNode();
				$$->nodekind = StmtK;
				$$->kind.stmt = WhileK;
				$$->child[0] = $3;
				$$->child[1] = $5;
			}
			;

return_decl : RETURN SEMI
			{
				$$ = newNode();
				$$->nodekind = StmtK;
				/* A partir desta atribuição, será possível avaliar se o retorno
				é válido semânticamente */
				$$->enclosingFunction = enclosingFunction;
				$$->kind.stmt = ReturnK;
			}
			| RETURN expression SEMI
			{
				$$ = newNode();
				$$->nodekind = StmtK;
				$$->kind.stmt = ReturnK;
				$$->enclosingFunction = enclosingFunction;
				$$->child[0] = $2;
			}
			;

expression : var ASSIGN expression
			{
				$$ = newNode();
				$$->nodekind = StmtK;
				$$->kind.stmt = AssignK;
                $$->child[0] = $1;
                $$->child[1] = $3;
            }
         	| simple_expression { $$ = $1; }
         	;

 var : 		var_id
 			{
				$$ = $1;
				$$->idtype = Simple;
         	}
			| var_id LBRCKT expression RBRCKT
			{
				$$ = $1;
				$$->idtype = Array;
				$$->child[0] = $3;
			}
    		;

var_id:		ID
			{
				$$ = newNode();
				$$->nodekind = ExpK;
				$$->kind.exp = IdK;
				$$->name = copyString(lastTokenString);
				$$->enclosingFunction = enclosingFunction;
			}

simple_expression : additive_expression relop additive_expression
			{
				$$ = $2;
                $$->child[0] = $1;
                $$->child[1] = $3;
            }
            | additive_expression { $$ = $1; }
            ;

relop : 	LTE
			{
				$$ = newNode();
				$$->nodekind = ExpK;
				$$->kind.exp = OpK;
            	$$->op = LTE;
            }
          	| GTE
			{
				$$ = newNode();
				$$->nodekind = ExpK;
				$$->kind.exp = OpK;
                $$->op = GTE;
            }
          	| LT
			{
				$$ = newNode();
				$$->nodekind = ExpK;
				$$->kind.exp = OpK;
                $$->op = LT;
            }
          	| GT
			{
				$$ = newNode();
				$$->nodekind = ExpK;
				$$->kind.exp = OpK;
				$$->op = GT;
            }
          	| EQ
			{
				$$ = newNode();
				$$->nodekind = ExpK;
				$$->kind.exp = OpK;
				$$->op = EQ;
            }
          	| DIF
			{
				$$ = newNode();
				$$->nodekind = ExpK;
				$$->kind.exp = OpK;
				$$->op = DIF;
            }
          	;

additive_expression : additive_expression addop term
			{
				$$ = $2;
				$$->child[0] = $1;
				$$->child[1] = $3;
			}
            | term { $$ = $1; }
            ;

addop :   	PLUS
			{
				$$ = newNode();
				$$->nodekind = ExpK;
				$$->kind.exp = OpK;
    			$$->op = PLUS;
	    	}
			| MINUS
			{
				$$ = newNode();
				$$->nodekind = ExpK;
				$$->kind.exp = OpK;
				$$->op = MINUS;
			}
			;

term : 		term mulop factor
			{
    			$$ = $2;
    			$$->child[0]=$1;
    			$$->child[1]=$3;
    		}
     		|  		factor { $$ = $1; }
			;

mulop : 	TIMES
			{
				$$ = newNode();
				$$->nodekind = ExpK;
				$$->kind.exp = OpK;
    			$$->op = TIMES;
    		}
    		| OVER
			{
				$$ = newNode();
				$$->nodekind = ExpK;
				$$->kind.exp = OpK;
				$$->op = OVER;
			}
			;

factor : 	LPAREN expression RPAREN { $$ = $2; }
     		| call { $$ = $1; }
     		| NUM
			{
				$$ = newNode();
				$$->nodekind = ExpK;
				$$->kind.exp = ConstK;
				$$->val = atoi(tokenString);
    		}
     		| var { $$ = $1; }
     		;

call : 		call_id LPAREN args RPAREN
			{
				/* Aqui define-se o nó de invocação para funções */
				$$ = $1;
                $$->child[0] = $3;
            }
        	;

call_id:	ID
			{
				$$ = newNode();
				$$->nodekind = StmtK;
				$$->kind.stmt = CallK;
				$$->name = copyString(lastTokenString);
				$$->idtype = Function;
				$$->lineno = lineno;
			}
			;

args : 		arg_list { $$ = $1; }
    		| { $$ = NULL; }
    		;

arg_list :	arg_list COMA expression
			{
                YYSTYPE t = $1;
			  	if (t != NULL){
					while (t->sibling != NULL)
						t = t->sibling;
					t->sibling = $3;
					$$ = $1;
			  	} else {
					$$ = $3;
				}
            }
         	| expression { $$ = $1; }
         	;

%%
/*
Função responsável em emitir as mensagens de erro de sintaxe no listing.
*/
int yyerror(char * message) {
	printf(ANSI_COLOR_RED "Syntax Error" ANSI_COLOR_RESET " at line %d: %s\n", lineno, message);
	printf("Current token: ");
	printToken(yychar, tokenString);
	Error = TRUE;
	return 0;
}

/*
Esta função invoca a função getToken para criar um output do Yacc/Bison
compatível com versões mais antigas do Lex.
*/
static int yylex(void) {
	return getToken();
}

/*
Esta função inicia a análise e constroi a árvore de sintaxe.
 */
YYSTYPE parse(void) {
	yydebug = DEBUG_PARSE; //define se o bison fará depuração da análise
	yyparse();
	return savedTree;
}
