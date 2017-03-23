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

#define YYSTYPE TreeNode *
static char * savedName; /* for use in assignments */
static int savedLineNo;  /* ditto */
static TreeNode * savedTree; /* stores syntax tree for later return */

%}

%token IF ELSE WHILE RETURN INT VOID
%token ID NUM
%token ASSIGN EQ LT GT LTE GTE DIF PLUS MINUS TIMES OVER
%token LPAREN RPAREN SEMI LBRCKT RBRCKT LBRACE RBRACE
%token ERROR
%token OC CC

%%

program : 			declaration_list
					;

declaration_list : 	declaration_list declaration
                 	| declaration
					| ERROR
                 	;

declaration :		var_declaration
	           		| fun_declaration
             		;

var_declaration :	type_specifier ID SEMI
                	| type_specifier ID LBRCKT NUM RBRCKT SEMI
					;

type_specifier :	INT
               		| VOID
	             	;

fun_declaration : 	type_specifier ID LPAREN params RPAREN compound_stmt
					;

params : 			param_list
					| VOID
					;

param_list : 		param_list COMA param
					| param 
					;

param : 			type_specifier ID
					| type_specifier ID '[' ']'   {parsedSymbolAttributes.parameters = NumOfParams + 1;
                                     parsedSymbolAttributes.array = 1;
                                     parsedSymbolAttributes.initialized = 1;
                                     insertSym($2, parsedSymbolAttributes, VAR);
                                     resetparsedSymbolAttributes();
                                    }
      ;

                    /* A function's scope is initilized before its parameters are
                     * read. Here we check to see if the compound_stmt is the
                     * function's body or a nested scope, since we already initalized
                     * function body scope.
                     */

compound_stmt : '{'                                     {if(!inFunctionBody())
                                                            initializeScope();
                                                        }
                 local_declarations statement_list '}'  {if(!inFunctionBody())
                                                            finalizeScope();}
              ;

local_declarations : local_declarations var_declaration {emitDeclaration(VAR, $2);}
                   | /* empty */ ;

statement_list : statement_list statement
               | /* empty */ ;

statement : expression_stmt
          | compound_stmt
          | selection_stmt
          | iteration_stmt
          | return_stmt ;

expression_stmt : expression ';'
                | ';'
				;

selection_stmt : ifsubroutine  statement        {fprintf(fp, "EndIf%i:\n", $1);}
               | ifsubroutine  statement ELSE	  {fprintf(fp, "jmp EndIfElse%i\n", $1);
                              					         fprintf(fp, "EndIf%i:\n", $1);
                      							            }
				         statement					 	          {fprintf(fp, "EndIfElse%i:\n", $1);}
               ;

ifsubroutine : IF  '(' expression ')'  {$$ = LabelSeed; LabelSeed++;
                     					          fprintf(fp, "cmp %s, 1\n", regToString($3));
                                        fprintf(fp, "jne EndIf%i\n", $$);
                                        releaseOneRegister();
                                       }
		   ;

iteration_stmt : whilesubroutine

                '(' expression ')' {fprintf(fp, "cmp %s, 1\n", regToString($<n>3));
                                     fprintf(fp, "jne EndWhile%i\n", $1);
                                     releaseOneRegister();
                                    }
                 statement          {fprintf(fp, "jmp While%i\n", $1);
                                     fprintf(fp, "EndWhile%i:\n", $1);
                                    }
                ;
whilesubroutine : WHILE    {$$ = LabelSeed; LabelSeed++;
                            fprintf(fp, "While%i:\n", $$);
                           }

return_stmt : RETURN ';'              {emitEpilogue();}

            | RETURN expression ';'   {if($2 == EAX){
										                    emitPrintReturn();
                                        emitEpilogue();
									                     }
                                       else{
                                        fprintf(fp, "mov eax, %s\n", regToString($2));
										                    emitPrintReturn();
                                        emitEpilogue();
                                       }
                                       releaseOneRegister();
                                      }

            ;

expression : var '=' expression     {$$=9;
                                     emitMemOp(STORE,$1,$3);
                                     releaseOneRegister();
                                    }
           | simple_expression      {$$ = $1;}
           ;

var : ID                    {lookUpSym($1)->attr.references++; strcpy($$, $1);}

    | ID '[' expression ']' {struct symbolEntry *tmp = lookUpSym($1);
                             if(!tmp->attr.array)
                             printf("error - %s is not an array", tmp->id);
                             tmp->attr.references++;
                             tmp->attr.regContainingArrIndex = $3;
                             strcpy($$, $1);
                            }
    ;

simple_expression : additive_expression relop additive_expression  {$$=$1;
                                                                    emitRelOp($2,$1,$3);
                                                                    releaseOneRegister();
                                                                   }
                  | additive_expression                            {$$ = $1;
                                                                   }
                  ;

relop : LTE {$$=LTEQU;}| '<'{$$=LESS;} | '>' {$$=GTR;}| GTE{$$=GTEQU;} | EQUAL{$$=EQU;} | NOTEQUAL {$$=NEQU;};

additive_expression : additive_expression addop term    {$$ = $1;
                                                         emitAluOp($2,$1,$3);
                                                         releaseOneRegister();
                                                        }
                    | term                              {$$ = $1;}
                    ;

addop : '+' {$$ = ADD;}
      | '-' {$$ = SUB;}
      ;

term : term mulop factor    {$$ = $1;
                             emitAluOp($2,$1,$3);
                             releaseOneRegister();
                            }
     | factor               {$$ = $1;}
     ;

mulop : '*' {$$ = MULT;}
      | '/' {$$ = DIV;}
      ;

factor : '(' expression ')' {$$ = $2;}
       | var                {
                             $$ = nextFreeRegister();
                             emitMemOp(LOAD,$1,$$);
                            }

       | call               {$$ = $1;}
       | NUM                {$$=nextFreeRegister();
                             emitLoadConst($$, $1);
                            }
       ;

call : ID '(' args ')'  {
                         emitCall($1, ArgList);
                         $$=nextFreeRegister();
                         NumOfParams=0;
                        }
     ;

args : arg_list | /* empty */ ;

arg_list : arg_list ',' expression {ArgList[NumOfParams++] = $3;}
         | expression              {ArgList[NumOfParams++] = $1;}
         ;
%%

int yyerror(char * message)
{ fprintf(listing,"Syntax error at line %d: %s\n",lineno,message);
  fprintf(listing,"Current token: ");
  printToken(yychar,tokenString);
  Error = TRUE;
  return 0;
}

/* yylex calls getToken to make Yacc/Bison output
 * compatible with ealier versions of the TINY scanner
 */
static int yylex(void)
{ return getToken(); }

TreeNode * parse(void)
{ yyparse();
  return savedTree;
}


/*

%{

#include "globals.h"

#define YYDEBUG 1

YYSTYPE savedTree = NULL;
YYSTYPE novo_stmnt(Tipo k);
char* cpy(char* txt);
void yyerror(char *msg);
static int yylex(void);

int tok;
%}

%start programa

%token NUM ID REAL
%token SUM SUB MUL DIV ATR APR FPR
%token IGL MAIOR MENOR MAIORIGL MENORIGL DIF
%token PEV VGL ACH FCH ACC FCC
%token ERR
%token INT FLOAT IF ELSE VOID WHILE RETURN

%%

programa:   declaracao_lista {
                savedTree = $1;
            }
        ;

declaracao_lista:   declaracao_lista declaracao {
				        YYSTYPE t = $1;
                        if( t != NULL ){
					        while (t->sibling != NULL)
						        t = t->sibling;
                     		t->sibling = $2;
                     		$$ = $1;
                   		}
                        else
                            $$ = $2;
                	}
			    |   declaracao {
					    $$ = $1;
				    }
			    ;

declaracao:     var_declaracao {
					$$ = $1;
				}
		  |     fun_declaracao {
					$$ = $1;
				}
      | error {
        $$ = NULL;
      }
		  ;

var_declaracao:   tipo_especificador varID tipo PEV {
		              $$ = $1;
					  $1->child[0] = $2;
					  $1->child[0]->child[0] = $3;
					  if( $3 != NULL ){
					      $2->isVector = 1;
						  $3->isIndex = 1;
					  }
				  }
			  ;

tipo:     ACC varNUM FCC {
             $$ = $2;
          }
    |     {
             $$ = NULL;
          }
    ;

tipo_especificador:  INT {
				        $$ = novo_stmnt(INTk);
			         }
	              |  VOID {
					    $$ = novo_stmnt(VOIDk);
				     }
		          |  FLOAT {
					    $$ = novo_stmnt(FLOATk);
				     }
		         ;

fun_declaracao:    tipo_especificador varID APR params FPR composto_decl {
 					      $$ = $1;
 					      $1->child[0] = $2;
 					      $2->isFunction = 1;
 					      YYSTYPE t = $1->child[0];
 					      t->child[0] = $4;
 					      t->child[1] = $6;
 				    }
 			    ;

params:    param_list {
	           $$ = $1;
		   }
	  |    VOID {
		       $$ = novo_stmnt(VOIDk);
	       }
	  ;

param_list:     param_list VGL param {
					$$ = $1;
					$1->sibling = $3;
				}
			|   param {
					$$ = $1;
				}
			;

param:      tipo_especificador varID ACC FCC {
				$$ = $1;
				$1->child[0] = $2;
				$1->child[0]->isVector = 1;
            }
      |     tipo_especificador varID {
				$$ = $1;
				$1->child[0] = $2;
			}
	  ;

composto_decl:  ACH local_declaracoes statement_lista FCH {
            	   $$ = $2;
            	   YYSTYPE t = $$;
				   if( t != NULL){
						while( t->sibling != NULL ){
							t = t->sibling;
						}
						t->sibling = $3;
					} else {
						$$ = $3;
					}
				}
			;

local_declaracoes:  local_declaracoes var_declaracao {
				        if( $1 != NULL ){
    						$$ = $1;
    						YYSTYPE t = $$;
    						while( t->sibling != NULL ){
    							t = t->sibling;
    						}
    						t->sibling = $2;
    					} else {
    						$$ = $2;
    					}
    				}
			     |  {
					    $$ = NULL;
				    }
			     ;

statement_lista:    statement_lista statement {
                        if( $1 != NULL ){
                            $$ = $1;
    						YYSTYPE t = $$;
    						while( t->sibling != NULL ){
    							t = t->sibling;
    						}
    						t->sibling = $2;
    					} else {
    						$$ = $2;
    					}
    				}
               |    {
            		    $$ = NULL;
            		}
               ;

statement:     expressao_decl {
                    $$ = $1;
               }
         |     composto_decl {
                    $$ = $1;
               }
         |     selecao_decl  {
                    $$ = $1;
               }
         |     iteracao_decl  {
                    $$ = $1;
               }
         |     retorno_decl  {
                    $$ = $1;
               }
               | error {
                $$ = NULL;
               }
         ;

expressao_decl:     expressao PEV {
					    $$ = $1;
				    }
			  |     PEV {
				        $$ = NULL;
				    }
			  ;

selecao_decl:       IF APR expressao FPR statement else_decl {
                        $$ = novo_stmnt(IFk);
                        $$->child[0] = $3;
                        $$->child[1] = $5;
                        $$->child[2] = $6;
                    }
            ;

else_decl:  ELSE statement {
                $$ = $2;
            }
         |  {
            	$$ = NULL;
            }
        ;

iteracao_decl:  WHILE APR expressao FPR statement {
					$$ = novo_stmnt(WHILEk);
					$$->child[0] = $3;
					$$->child[1] = $5;
				}
			;

retorno_decl:   RETURN PEV {
					$$ = novo_stmnt(RETURNk);
				}
			|   RETURN expressao PEV {
					$$ = novo_stmnt(RETURNk);
					$$->child[0] = $2;
				}
			;

expressao:  var ATR expressao {
                $$ = novo_stmnt(ATRk);
                $$->child[0] = $1;
                $$->child[1] = $3;
            }
         |  simples_expressao {
                $$ = $1;
            }
         ;

 var:    varID vetor {
             $$ = $1;
             $$->child[0] = $2;
             if( $2 != NULL ){
                 $1->isVector = 1;
                 $2->isIndex = 1;
             }
         }
    ;

vetor: ACC expressao FCC {
	       $$ = $2;
	   }
	 | {
		   $$ = NULL;
	   }
	 ;

simples_expressao:  soma_expressao relacional soma_expressao {
                        $$ = $2;
                        $$->child[0] = $1;
                        $$->child[1] = $3;
                    }
                 |  soma_expressao {
                        $$ = $1;
                    }
                 ;

relacional:     MENORIGL {
                    $$ = novo_stmnt(Opk);
                    $$->tipoOp = MENORIGLk;
                }
          |     MAIORIGL {
                    $$ = novo_stmnt(Opk);
                    $$->tipoOp = MAIORIGLk;
                }
          |     MENOR {
                    $$ = novo_stmnt(Opk);
                    $$->tipoOp = MENORk;
                }
          |     MAIOR {
                    $$ = novo_stmnt(Opk);
                    $$->tipoOp = MAIORk;
                }
          |     IGL {
                    $$ = novo_stmnt(Opk);
                    $$->tipoOp = IGLk;
                }
          |     DIF {
                    $$ = novo_stmnt(Opk);
                    $$->tipoOp = DIFk;
                }
          ;

soma_expressao: soma_expressao soma termo {
					$$ = $2;
					$$->child[0] = $1;
					$$->child[1] = $3;
				}
              | termo {
            		$$ = $1;
            	}
              ;

soma:   SUM {
    		$$ = novo_stmnt(Opk);
    		$$->tipoOp = SUMk;
	    }
	|   SUB {
			$$ = novo_stmnt(Opk);
			$$->tipoOp = SUBk;
		}
	;

termo:  termo mult fator {
    		$$ = $2;
    		$$->child[0]=$1;
    		$$->child[1]=$3;
    	}
     |  fator {
			$$ = $1;
	    }

mult:   MUL {
    		$$ = novo_stmnt(Opk);
    		$$->tipoOp = MULk;
    	}
    |   DIV {
			$$ = novo_stmnt(Opk);
			$$->tipoOp = DIVk;
		}
	;

fator:  APR expressao FPR {
    		$$ = $2;
        }
     |  ativacao {
    		$$ = $1;
    	}
     |  varNUM {
    		$$ = $1;
    	}
     |  varREAL {
    		$$ = $1;
    	}
     |  varID {
       		$$ = $1;
       	}
     ;

ativacao:   varID APR args FPR {
                $$ = $1;
                $$->isFunction = 1;
                $1->child[0] = $3;
            }
        ;

args: arg_lista {
            $$ = $1;
        }
    |   {
            $$ = NULL;
        }
    ;

arg_lista:  arg_lista VGL expressao {
                $$ = $1;
                $$->sibling=$3;
            }
         |  expressao {
                $$ = $1;
            }
         ;

varNUM: NUM {
			$$ = novo_stmnt(NUMk);
			$$->valNum=atoi(yytext);
        }
	   ;

varID: ID {
			$$ = novo_stmnt(IDk);
			$$->text = cpy(yytext);
	   }
	 ;

varREAL: REAL {
			$$ = novo_stmnt(REALk);
			$$->valFloat = atof(yytext);
		 }
	   ;

%%

char* cpy(char* txt){
	char* copy = (char*)malloc((strlen(txt)+1)*sizeof(char));
	strcpy(copy,txt);
	return copy;
}

YYSTYPE novo_stmnt(Tipo k){
	YYSTYPE node = (YYSTYPE) malloc (sizeof(TreeNode));
	node->child[0] = NULL;
	node->child[1] = NULL;
	node->child[2] = NULL;
	node->sibling = NULL;
	node->lineno = numLine;
	node->tipo = k;
	node->tipoOp = NoOPK;
	node->valNum = 0;
	node->valFloat = 0.0;
	node->text = NULL;
	node->isVector = 0;
	node->isFunction = 0;
	node->isIndex = 0;
	return node;
}

void printToken(int token){
	switch(token){
		case IF:
			printf("IF");
			break;
		case ELSE:
			printf("ELSE");
			break;
		case INT:
			printf("INT");
			break;
		case VOID:
			printf("VOID");
			break;
		case WHILE:
			printf("WHILE");
			break;
		case RETURN:
			printf("RETURN");
			break;
		case ATR:
			printf("=");
			break;
		case NUM:
			printf("%s",yytext);
			break;
		case PEV:
			printf(";");
			break;
		case FPR:
			printf(")");
			break;
		case APR:
			printf("(");
			break;
		case DIV:
			printf("/");
			break;
		case MUL:
			printf("*");
			break;
		case SUB:
			printf("-");
			break;
		case SUM:
			printf("+");
			break;
		case MENOR:
			printf("<");
			break;
		case MAIOR:
			printf(">");
			break;
		case DIF:
			printf("!=");
			break;
		case MAIORIGL:
			printf(">=");
			break;
		case MENORIGL:
			printf("<=");
			break;
		case IGL:
			printf("==");
			break;
		case ID:
			printf("%s",yytext);
			break;
		case ACH:
			printf("{");
			break;
		case FCH:
			printf("}");
			break;
		case ACC:
			printf("[");
			break;
		case FCC:
			printf("]");
			break;
		case ERR:
			printf("ERROR: %s",yytext);
			break;
		case VGL:
			printf(",");
			break;
		default:
			printf("Token nao pertecente a linguagem");
	}
}

void yyerror(char *msg){
  printf("\n%s near the line '%d': %s\n", msg, numLine, yytext);
}

int indentno = 0;

#define INDENT indentno+=2
#define UNINDENT indentno-=2

void printSpaces(void){
	int i;
	for (i=0;i<indentno;i++)
		printf(" ");
}


void printTree( TreeNode * tree ){
	int i;
	INDENT;
	while (tree != NULL) {
		printSpaces();
		switch (tree->tipo) {
			case Opk:
				printf("Operacao : ");
				switch(tree->tipoOp){
					case MAIORk:
						printf(" > \n");
						break;
					case MAIORIGLk:
						printf(" >= \n");
						break;
					case MENORk:
						printf(" < \n");
						break;
					case MENORIGLk:
						printf(" <= \n");
						break;
					case IGLk:
						printf(" ==\n");
						break;
					case DIFk:
						printf(" !=\n");
						break;
					case SUMk:
						printf(" +\n");
						break;
					case SUBk:
						printf(" -\n");
						break;
					case MULk:
						printf(" *\n");
						break;
					case DIVk:
						printf(" /\n");
						break;
					case NoOPK:
						printf("Sem operando\n");
						break;
					default:
						printf("operacao desconhecida\n");
						break;
				}
				break;
			case NUMk:
				printf("Número, valor=%d\n",tree->valNum);
				break;
			case REALk:
				printf("Número, valor=%f\n",tree->valFloat);
				break;
			case IDk:
				printf("ID, valor=%s, %s\n",tree->text,(tree->isFunction?"(funcao)":(tree->isVector?"(array)":"(variable)")));
				break;
			case IFk:
				printf("IF\n");
				break;
			case WHILEk:
				printf("WHILE\n");
				break;
			case INTk:
				printf("INT\n");
				break;
			case VOIDk:
				printf("VOID\n");
				break;
			case FLOATk:
				printf("FLOAT\n");
				break;
			case ATRk:
				printf("=\n");
				break;
			case RETURNk:
				printf("RETURN\n");
				break;
			default:
				printf("Token desconhecido\n");
				break;
		}
		for (i=0;i<MAXCHILDREN;i++){
			printTree(tree->child[i]);
		}
		tree = tree->sibling;
	}
	UNINDENT;
}

static int yylex(void){
	tok = getToken();
	return tok;
}

TreeNode * parse(){
	yyparse();
	return savedTree;
}

int main(){
    yydebug = 0;
    FILE *input;
    input = fopen("input.cm", "r");
    if (input == NULL){
        printf("Não foi possível abrir o arquivo de leitura\nExit(0)\n");
        exit(0);
    }

    yyin = input;
	inicia_tabela();
	YYSTYPE tree = parse();
    check_main();
    printf("Analise Completa e sem erros...");
	imprime_tabela_simbolos();
	printf("\n");
	printf("Tree:\n");
	printTree(tree);
	printf("\n");
}*/
