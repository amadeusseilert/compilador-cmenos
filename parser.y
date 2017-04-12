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

static char * savedName; /* Usado em atribuições */
static int savedLineNo;  /* Usado em atribuições */

static ExpType lastType; /* Usado em declarações */

/*
Armazena a árvore de sintaxe para uso posterior.
*/
static YYSTYPE savedTree = NULL;


/*
Abaixo está definido qual é a regra inicial da análise de sintaxe.
Em seguida, estão definidos a totalidade dos tokens usados na gramática.
Por fim, a declaração '%nonassoc' estabelece quais tokens não são associativos.
E '%left' estabelece a ordem de precedência mais a esquerda do grupo.

http://dinosaur.compilertools.net/bison/bison_6.html#SEC57
*/
%}

%start program

%token IF ELSE WHILE RETURN INT VOID
%token ID NUM
%token ASSIGN EQ LT GT LTE GTE DIF PLUS MINUS TIMES OVER
%token LPAREN RPAREN SEMI COMA LBRCKT RBRCKT LBRACE RBRACE
%token ERROR
%token OC CC

%nonassoc LT LTE GT GTE EQ DIF
%left PLUS MINUS
%left TIMES OVER

%%

program:    		declaration_list
			{
                savedTree = $1; /* Define o nó raiz da árvore */
            }
        	;

declaration_list:	declaration_list  declaration
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
			|		declaration
			{
				$$ = $1;
			}
			;

declaration:		var_declaration
 			{
				$$ = $1;
			}
		  	|		fun_declaration
			{
				$$ = $1;
			}
      		| 		error
			{
        		$$ = NULL;
      		}
		  	;

var_declaration:   	type_specifier ID SEMI
 			{
				/* Uma declaração de variável simples */
              	$$ = newDeclNode(VarK);
				$$->name = copyString(tokenString);
				$$->idtype = Simple;
				$$->type = lastType;

			}
			|		type_specifier ID
			{
				/* Como é de interesse obter a string armazenada no token ID e
				a variável tokenString ('scanner.h') guarda a string do último
				token lido, faz aqui, o uso de ações em meio de regras
				('Mid-Rule Actions').*/
				savedName = copyString(tokenString);
				savedLineNo = lineno;
			}
					LBRCKT NUM RBRCKT SEMI
			{
				$$ = newDeclNode(VarK);
				$$->name = savedName;
				$$->val = atoi(tokenString);
				$$->type = lastType;
				$$->lineno = savedLineNo;
				$$->idtype = Array;
			}
			;

type_specifier:  	INT
			{
				lastType = Integer
			}
	        |  		VOID
			{
			    lastType = Void
			}
		    ;

fun_declaration:    type_specifier ID
			{
				savedName = copyString(tokenString);
				savedLineNo = lineno;
			}
					LPAREN params RPAREN compound_stmt
			{
				/* Uma nó do tipo declaração de função possui como nós filhos
				os argumentos e uma composição de declarações e expressões.
				*/
 			    $$ = newDeclNode(FunK);
 			    $$->name = savedName;
				$$->lineno = savedLineNo;
				$$->idtype = Function;
				$$->type = lastType;
 				$$->child[0] = $5;
 				$$->child[1] = $7;
 			}
 			;

params:    			param_list
			{
	           $$ = $1;
		   	}
	  		|    	VOID
	  		;

param_list:     	param_list COMA param

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
			|   	param
			{
				$$ = $1;
			}
			;

param:           	type_specifier ID
			{
				$$ = newDeclNode(ParamK);
				$$->name = copyString(tokenString);
				$$->type = lastType;
				$$->idtype = Simple;

			}
			|		type_specifier ID
			{
				savedName = copyString(tokenString);
				savedLineNo = lineno;
			}
					LBRCKT RBRCKT
			{
				/* Um parâmetro é do tipo array se possui '[]' em seguida do
				identificador */
				$$ = newDeclNode(ParamK);
				$$->name = savedName;
				$$->lineno = savedLineNo;
				$$->type = lastType;
				$$->idtype = Array;
            }
	  		;

compound_stmt:  	LBRACE local_declarations statement_list RBRACE
			{
				/* Essa regra define que, dentro de uma função, sempre deve ser
				feito declaração das variáveis antes da utilização delas em
				eventuais expressões. */
            	$$ = newStmtNode(CmpdK);
            	$$->child[0] = $2;
				$$->child[1] = $3;
			}
			;

local_declarations:  local_declarations  var_declaration
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
			|
			{
		    	$$ = NULL;
			}
			;

statement_list:		statement_list statement
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
            |
			{
            	$$ = NULL;
            }
            ;

statement:     		expression_decl
			{
            	$$ = $1;
            }
         	|     	compound_stmt
			{
                $$ = $1;
            }
         	|   	selection_decl
			{
                $$ = $1;
       		}
         	|	   	iteration_decl
			{
            	$$ = $1;
            }
         	|		return_decl
			{
                $$ = $1;
            }
            | 		error
			{
            	$$ = NULL;
            }
         	;

expression_decl:	expression SEMI
			{
				$$ = $1;
			}
			|		SEMI
			{
				$$ = NULL;
			}
			;

selection_decl:		IF LPAREN expression RPAREN statement else_decl
			{
				/* A gramática define que o 'else' é opcional */
                $$ = newStmtNode(IfK);
                $$->child[0] = $3;
            	$$->child[1] = $5;
                $$->child[2] = $6;
            }
            ;

else_decl:  		ELSE statement
			{
                $$ = $2;
            }
         	|
			{
            	$$ = NULL; /* else opcional */
            }
        	;

iteration_decl:  	WHILE LPAREN expression RPAREN statement
			{
				$$ = newStmtNode(WhileK);
				$$->child[0] = $3;
				$$->child[1] = $5;
			}
			;

return_decl:   		RETURN SEMI
			{
				$$ = newStmtNode(ReturnK);
			}
			|   	RETURN expression SEMI
			{
				$$ = newStmtNode(ReturnK);
				$$->child[0] = $2;
			}
			;

expression:  		var ASSIGN expression
			{
                $$ = newStmtNode(AssignK);
                $$->child[0] = $1;
                $$->child[1] = $3;
            }
         	|  		simple_expression
			{
                $$ = $1;
            }
         	;

 var:   			ID
 			{
            	$$ = newExpNode(IdK);
				$$->name = copyString(tokenString);
				$$->idtype = Simple;
         	}
			| 		ID
			{
				savedLineNo = lineno;
				savedName = copyString(tokenString);
			}
					LBRCKT expression RBRCKT
			{
				$$ = newExpNode(IdK);
				$$->name = savedName;
				$$->lineno = savedLineNo;
				$$->idtype = Array;
				$$->child[0] = $4;
			}
    		;

simple_expression: 	additive_expression relop additive_expression
			{
				$$ = $2;
                $$->child[0] = $1;
                $$->child[1] = $3;
            }
            |  		additive_expression
			{
                $$ = $1;
            }
            ;

relop:     			LTE
			{
				$$ = newExpNode(OpK);
            	$$->op = LTE;
            }
          	|     	GTE
			{
				$$ = newExpNode(OpK);
                $$->op = GTE;
            }
          	|     	LT
			{
				$$ = newExpNode(OpK);
                $$->op = LT;
            }
          	|     	GT
			{
				$$ = newExpNode(OpK);
				$$->op = GT;
            }
          	|     	EQ
			{
				$$ = newExpNode(OpK);
				$$->op = EQ;
            }
          	|     	DIF
			{
				$$ = newExpNode(OpK);
				$$->op = DIF;
            }
          	;

additive_expression: additive_expression addop term
			{
				$$ = $2;
				$$->child[0] = $1;
				$$->child[1] = $3;
			}
            | 		term
			{
            	$$ = $1;
            }
            ;

addop:   			PLUS
			{
    			$$ = newExpNode(OpK);
    			$$->op = PLUS;
	    	}
			|   	MINUS
			{
				$$ = newExpNode(OpK);
				$$->op = MINUS;
			}
			;

term:  				term mulop factor
			{
    			$$ = $2;
    			$$->child[0]=$1;
    			$$->child[1]=$3;
    		}
     		|  		factor
			{
				$$ = $1;
	    	}
			;

mulop:   			TIMES
			{
    			$$ = newExpNode(OpK);
    			$$->op = TIMES;
    		}
    		|   	OVER
			{
				$$ = newExpNode(OpK);
				$$->op = OVER;
			}
			;

factor:  			LPAREN expression RPAREN
			{
    			$$ = $2;
        	}
     		|  		call
			{
    			$$ = $1;
    		}
     		|  		NUM
			{
    			$$ = newExpNode(ConstK);
				$$->val = atoi(tokenString);
    		}
     		|  		var
			{
       			$$ = $1;
       		}
     		;

call:   			ID
 			{
				savedName = copyString(tokenString);
				savedLineNo = lineno;
			}
					LPAREN args RPAREN
			{
				/* Aqui define-se o nó de invocação para funções */
                $$ = newStmtNode(CallK);
				$$->name = savedName;
				$$->lineno = savedLineNo;
                $$->idtype = Function;
                $$->child[0] = $4;
            }
        	;

args: 				arg_list
			{
            	$$ = $1;
        	}
    		|
			{
            	$$ = NULL;
        	}
    		;

arg_list:  			arg_list COMA expression
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
         	|  		expression
			{
                $$ = $1;
            }
         	;




%%
/*
Função responsável em emitir as mensagens de erro de sintaxe no listing.
*/
int yyerror(char * message) {
	printf("Syntax error at line %d: %s\n", lineno, message);
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
	yyparse();
	return savedTree;
}
