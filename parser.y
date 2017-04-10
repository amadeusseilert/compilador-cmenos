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

//static char * savedName; /* Usado em atribuições */
//static int savedLineNo;  /* Usado em atribuições */

/*
Armazena a árvore de sintaxe para uso posterior.
*/
static YYSTYPE savedTree = NULL;

%}

%start program

%token IF ELSE WHILE RETURN INT VOID
%token ID NUM
%token ASSIGN EQ LT GT LTE GTE DIF PLUS MINUS TIMES OVER
%token LPAREN RPAREN SEMI COMA LBRCKT RBRCKT LBRACE RBRACE
%token ERROR
%token OC CC

%%

program:    		declaration_list
			{
                savedTree = $1;
            }
        	;

declaration_list:	declaration_list  declaration
			{
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
              	$$ = newDeclNode(VarK);
				$$->name = copyString(tokenString);
				$$->idtype = Simple;

			}
			|		type_specifier ID LBRCKT index RBRCKT SEMI
			{
				$$ = newDeclNode(VarK);
				$$->name = copyString(tokenString);
				$$->idtype = Array;
			}
			;

index: 				NUM
			{
				$$->val = atoi(tokenString);
			}


type_specifier:  	INT
			{
				$$->type = Integer
			}
	        |  		VOID
			{
			    $$->type = Void
			}
		    ;

fun_declaration:    type_specifier ID LPAREN params RPAREN compound_stmt
			{
 			    $$ = newDeclNode(FunK);
 			    $1->child[0] = $2;
				$1->child[0]->idtype = Function;
				$1->child[0]->type = $1->type;
 				YYSTYPE t = $1->child[0];
 				t->child[0] = $4;
 				t->child[1] = $6;
 			}
 			;

params:    			param_list
			{
	           $$ = $1;
		   	}
	  		|    	VOID
			{
		       $$ = $1;
	       	}
	  		;

param_list:     	param_list COMA param
			{
				$$ = $1;
				$1->sibling = $3;
			}
			|   	param {
				$$ = $1;
			}
			;

param:           	type_specifier var_ID
			{
				$$ = $1;
				$1->child[0] = $2;
				$1->child[0]->type = $1->type;
				$1->child[0]->idtype = Simple;

			}
			|		type_specifier var_ID LBRCKT RBRCKT
			{
				$$ = $1;
				$1->child[0] = $2;
				$1->child[0]->type = $1->type;
				$1->child[0]->idtype = Array;
            }
	  		;

compound_stmt:  	LBRACE local_declarations statement_list RBRACE
			{
            	$$ = $2;
            	YYSTYPE t = $$;
				if( t != NULL){
					while( t->sibling != NULL )
						t = t->sibling;
					t->sibling = $3;
				} else {
					$$ = $3;
				}
			}
			;

local_declarations:  local_declarations  var_declaration
			{
				if( $1 != NULL ){
    				$$ = $1;
    				YYSTYPE t = $$;
    				while ( t->sibling != NULL )
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
    				while( t->sibling != NULL )
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
            	$$ = NULL;
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

 var:   			var_ID
 			{
            	$$ = $1;
				$$->idtype = Simple;
         	}
			| 		var_ID LBRCKT expression RBRCKT
			{
				$$ = $1;
				$$->idtype = Array;
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
            	$$->attr.op = LTE;
            }
          	|     	GTE
			{
                $$ = newExpNode(OpK);
                $$->attr.op = GTE;
            }
          	|     	LT
			{
                $$ = newExpNode(OpK);
                $$->attr.op = LT;
            }
          	|     	GT
			{
                $$ = newExpNode(OpK);
				$$->attr.op = GT;
            }
          	|     	EQ
			{
                $$ = newExpNode(OpK);
				$$->attr.op = EQ;
            }
          	|     	DIF
			{
                $$ = newExpNode(OpK);
				$$->attr.op = DIF;
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
    			$$->attr.op = PLUS;
	    	}
			|   	MINUS
			{
				$$ = newExpNode(OpK);
				$$->attr.op = MINUS;
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
    			$$->attr.op = TIMES;
    		}
    		|   	OVER
			{
				$$ = newExpNode(OpK);
				$$->attr.op = OVER;
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
     		|  		var_NUM
			{
    			$$ = $1;
    		}
     		|  		var_ID
			{
       			$$ = $1;
       		}
     		;

call:   			var_ID LPAREN args RPAREN
			{
                $$ = $1;
                $$->idtype = Function;
                $1->child[0] = $3;
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
                $$ = $1;
                $$->sibling=$3;
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
int yyerror (char * message) {
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
static int yylex (void) {
	return getToken();
}

/*
Esta função inicia a análise e constroi a árvore de sintaxe.
 */
YYSTYPE parse (void) {
	yyparse();
	return savedTree;
}
