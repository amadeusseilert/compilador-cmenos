/****************************************************/
/* Autor: Amadeus T. Seilert						*/
/* Arquivo: cgen.c		                            */
/* Implementação dos procedimentos que farão		*/
/* a geração de código a partir dos dados contidos	*/
/* na árvore de análise sintática.					*/
/****************************************************/
#include "globals.h"
#include "symtab.h"
#include "code.h"
#include "cgen.h"

/* Armazena uma string temporária para a impressão de comentários */
static char buffer[1000];

/* Deslocamento de utilização do escopo global. Toda declaração de uma variável
ou função global, implica no incremento deste valor */
static int globalOffset = 0;
/* Ideia semelhante ao globalOffset, porém, este valor é sempre inicializado em
cada escopo */
static int localOffset = initFO;

/* Número de parâmetros dentro do frame corrente */
static int nParams = 0;

/* inFunc is the flag that shows if current node
   is in a function block. This flag is used when
   calculating localOffset of a function declaration.
*/

/* Indica se o nó corrente na geração de código está dentro de um bloco de
função. Esta vairável será usada para calcular o localOffset */
static int inFunc = FALSE;

/* Local da função main */
static int mainLoc = 0;

/* Protótipo da recursão interna da geração de código */
static void cGen (TreeNode * tree);

/* Function getBlockOffset returns the offset for
 * temp variables in the block where list is */

/* Função que determina o valor de deslocamento das variáveis internas ao bloco
list. Parametros também incrementam o deslocamento */
static int getBlockOffset(TreeNode * list) {
	int offset = 0;

	if (list != NULL) {
		if (list->nodekind == DeclK){
			TreeNode * node = list;
			while (node != NULL) {
				switch (node->kind.decl) {
					case VarK:
						/* Caso a variável for um vetor, o deslocamento é o
						tamanho dele */
						if (node->idtype == Array) {
							offset += node->val;
						} else {
							++offset;
						}
						break;
					case ParamK:
						/* O deslocamento de parametros é sempre unitário. Em
						caso de um parâmetro vetor, o parâmetro representará uma
						posição na memória, ou seja, um endereço de memória */
						++offset;
						break;
					default:
						break;
				}
				node = node->sibling;
			}
		}

	}

	return offset;
}

/* Procedimento que gera código para nós do tipo Stament */
static void genStmt( TreeNode * tree){
	TreeNode * p1, * p2, * p3;

  	int loc1, loc2, currentLoc;
  	int offset;

  	switch (tree->kind.stmt) {
		case CmpdK:
			if (TraceCode) emitComment("-> compound");

			p1 = tree->child[0]; /* Declarações */
			p2 = tree->child[1]; /* Lista de expressões e statements */

			/* Atualiza localOffset a partir das declarações do bloco */
			offset = getBlockOffset(p1);
			localOffset -= offset;

			/* Carrega o escopo da função corrente */
			sc_push(sc_find(tree->enclosingFunction->name));

			/* Gera o código do corpo */
			cGen(p2);

			/* Desempilha o escopo */
			sc_pop();

			/* Restaura localOffset */
			localOffset -= offset;

			if (TraceCode) emitComment("<- compound");
			break;
		case IfK:
			if (TraceCode) emitComment("-> if");

			p1 = tree->child[0];
			p2 = tree->child[1];
			p3 = tree->child[2];

			/* Gera código para a parte do teste booleano */
			cGen(p1);

			loc1 = emitSkip(1);
			emitComment("if: jump to else belongs here");

			/* Gera código da parte "então" */
			cGen(p2);

			loc2 = emitSkip(1);
			emitComment("if: jump to end belongs here");

			currentLoc = emitSkip(0);
			emitBackup(loc1);
			emitRM_Abs("JEQ", ac, currentLoc, "if: jmp to else");
			emitRestore();

			/* Gera código da parte "else" */
			cGen(p3);
			currentLoc = emitSkip(0);
			emitBackup(loc2);
			emitRM_Abs("LDA",pc,currentLoc,"jmp to end");
			emitRestore();
			if (TraceCode)  emitComment("<- if");
			break;
		case WhileK:
			if (TraceCode) emitComment("-> while.");

	        p1 = tree->child[0];
	        p2 = tree->child[1];

	        loc1 = emitSkip(0);
	        emitComment("while: jump after body comes back here");

			/* Gera código para a parte do teste booleano */
	        cGen(p1);

	        loc2 = emitSkip(1);
	        emitComment("while: jump to end belongs here");

	        /* Gera código para o corpo */
	        cGen(p2);
	        emitRM_Abs("LDA", pc, loc1, "while: jmp back to test");

	        /* Ponto de retorno */
	        currentLoc = emitSkip(0);
	        emitBackup(loc2);
	        emitRM_Abs("JEQ", ac, currentLoc, "while: jmp to end");
	        emitRestore();

	        if (TraceCode)  emitComment("<- while.");
			break;

		case ReturnK:
			if (TraceCode) emitComment("-> return");

			p1 = tree->child[0];

			/* Gera código para a expressão */
			cGen(p1);
			emitRM("LD", pc, retFO, mp, "return: to caller");

			if (TraceCode) emitComment("<- return");
			break;
		default:
			break;
	}
}

/* Procedimento que gera código para nós do tipo Expressão. isAddr define se
deve ser considerado como manuseio em endereço de memória */
static void genExp( TreeNode * tree, int isAddr){
	TreeNode * p1, * p2;

	/* Usado para verificar se o argumento de uma invocação é vetor */
	BucketList symTemp;

	int loc;
  	int varOffset;
	int nArgs;

  	switch (tree->kind.exp) {
    	case OpK:
	  		if (TraceCode) emitComment("-> Op");

	  		p1 = tree->child[0];
	  		p2 = tree->child[1];

			/* Gera código para a parte esquerda da operação */
		  	cGen(p1);
			/* Salva o operando esquerdo */
		  	emitRM("ST", ac, localOffset--, mp, "op: push left");

		  	/* Gera código para a parte direita da operação */
		  	cGen(p2);
		  	/* Carrega o operando esquerdo */
		  	emitRM("LD", ac1, ++localOffset, mp, "op: load left");

	  		switch (tree->op) {
	    		case PLUS:
	      			emitRO("ADD", ac, ac1, ac, "op +");
	      			break;
	    		case MINUS:
	      			emitRO("SUB", ac, ac1, ac, "op -");
	      			break;
	    		case TIMES:
	      			emitRO("MUL", ac, ac1, ac, "op *");
	      			break;
	    		case OVER:
	      			emitRO("DIV", ac, ac1, ac, "op /");
	      			break;
			    case LT:
					emitRO("SUB", ac, ac1, ac, "op <");
					emitRM("JLT", ac, 2, pc, "br if true");
					emitRM("LDC", ac, 0, ac, "false case");
					emitRM("LDA", pc, 1, pc, "unconditional jmp");
					emitRM("LDC", ac, 1, ac, "true case");
					break;
				case LTE:
					emitRO("SUB", ac, ac1, ac, "op <=");
					emitRM("JLE", ac, 2, pc, "br if true");
					emitRM("LDC", ac, 0, ac, "false case");
					emitRM("LDA", pc, 1, pc, "unconditional jmp");
					emitRM("LDC", ac, 1, ac, "true case");
					break;
				case GT:
					emitRO("SUB", ac, ac1, ac, "op >");
					emitRM("JGT", ac, 2, pc, "br if true");
					emitRM("LDC", ac, 0, ac, "false case");
					emitRM("LDA", pc, 1, pc, "unconditional jmp");
					emitRM("LDC", ac, 1, ac, "true case");
					break;
				case GTE:
					emitRO("SUB", ac, ac1, ac, "op >=");
					emitRM("JGE", ac, 2, pc, "br if true");
					emitRM("LDC", ac, 0, ac, "false case");
					emitRM("LDA", pc, 1, pc, "unconditional jmp");
					emitRM("LDC", ac, 1, ac, "true case");
					break;
				case EQ:
					emitRO("SUB", ac, ac1, ac, "op ==");
					emitRM("JEQ", ac, 2, pc, "br if true");
					emitRM("LDC", ac, 0, ac, "false case");
					emitRM("LDA", pc, 1, pc, "unconditional jmp");
					emitRM("LDC", ac, 1, ac, "true case");
					break;
				case DIF:
					emitRO("SUB", ac, ac1, ac, "op !=");
					emitRM("JNE", ac, 2, pc, "br if true");
					emitRM("LDC", ac, 0, ac, "false case");
					emitRM("LDA", pc, 1, pc, "unconditional jmp");
					emitRM("LDC", ac, 1, ac, "true case");
					break;
				default:
					emitComment("BUG: Unknown operator");
					break;
			}

			if (TraceCode)  emitComment("<- Op");
			break;

		case ConstK:
			if (TraceCode) emitComment("-> Const") ;
			/* Carrega o valor de uma constante no acumulador */
			emitRM("LDC", ac, tree->val, 0, "load const");
			if (TraceCode)  emitComment("<- Const") ;
			break;

		case IdK:
			if (TraceCode) {
			  sprintf(buffer, "-> Id (%s)", tree->name);
			  emitComment(buffer);
			}

			/* Busca a localização do identificador no escopo local. Caso não
			encontrar, o identificador é global */
			loc = st_lookup_top(tree->name);
			if (loc >= 0)
				varOffset = initFO - loc;
			else
				varOffset = -(st_lookup(tree->name));

			/* Gera uma constante que representa o valor de deslocamento da
			variável */
			emitRM("LDC", ac, varOffset, 0, "id: load varOffset");

			if (tree->idtype == Array && tree->child[0] != NULL) {
				/* O nó corrente é um vetor. Verifica  */

				if (loc >= 0 && loc < nParams) {

				  /* generate code to push address */
				  emitRO("ADD", ac, mp, ac, "id: load the memory address of base address of array to ac");
				  emitRO("LD", ac, 0, ac, "id: load the base address of array to ac");
				} else {
				 	/* global or local variable */

				  	/* generate code for address */
				  	if (loc >= 0)
				    	/* symbol found in current frame */
				    	emitRO("ADD", ac, mp, ac, "id: calculate the address");
				  	else
					    /* symbol found in global scope */
					    emitRO("ADD", ac, gp, ac, "id: calculate the address");
				}

				/* generate code to push localOffset */
				emitRM("ST", ac, localOffset--, mp, "id: push base address");

				/* generate code for index expression */
				p1 = tree->child[0];
				genExp(p1, FALSE);
				/* gen code to get correct varOffset */
				emitRM("LD", ac1, ++localOffset, mp, "id: pop base address");
				emitRO("SUB", ac, ac1, ac, "id: calculate element address with index");
			} else {
				/* kind of node is for non-array id */

				/* generate code for address */
				if (loc >= 0)
				  	/* symbol found in current frame */
					emitRO("ADD", ac, mp, ac, "id: calculate the address");
				else
				  	/* symbol found in global scope */
					emitRO("ADD", ac, gp, ac, "id: calculate the address");
			}

			symTemp = st_bucket_top(tree->name);

			if (symTemp != NULL && isAddr){
				if (symTemp->node->kind.decl == ParamK && tree->idtype == Array && tree->child[0] == NULL){
					emitRM("LD", ac, 0, ac, "load id address value");
				}
			} else if (isAddr) {
				emitRM("LDA", ac, 0, ac, "load id address");
			} else {
				emitRM("LD", ac, 0, ac, "load id value");
			}

			if (TraceCode)  emitComment("<- Id");

			break; /* IdK */
		case AssignK:
			if (TraceCode) emitComment("-> assign");

			p1 = tree->child[0];
			p2 = tree->child[1];

			/* generate code for ac = address of lhs */
			genExp(p1, TRUE);
			/* generate code to push lhs */
			emitRM("ST", ac, localOffset--, mp, "assign: push left (address)");

			/* generate code for ac = rhs */
			cGen(p2);
			/* now load lhs */
			emitRM("LD", ac1, ++localOffset, mp, "assign: load left (address)");

			emitRM("ST", ac, 0, ac1, "assign: store value");

			if (TraceCode) emitComment("<- assign");
			break; /* assign_k */
		case CallK:
			if (TraceCode) emitComment("-> Call");

			/* init */
			nArgs = 0;

			p1 = tree->child[0];

			/* for each argument */
			while (p1 != NULL) {

				if (p1->idtype == Array && p1->child[0] == NULL){
					genExp(p1, TRUE);
				} else  {
					genExp(p1, FALSE);
				}

				/* generate code to push argument value */
				emitRM("ST", ac, localOffset + initFO - (nArgs++), mp, "call: push argument");

				p1 = p1->sibling;
			}

			if (strcmp(tree->name, "input") == 0) {
				/* generate code for input() function */
				emitRO("IN",ac,0,0,"read integer value");
			} else if (strcmp(tree->name, "output") == 0) {
				/* generate code for output(arg) function */
				/* generate code for value to write */
				emitRM("LD", ac, localOffset + initFO, mp, "load arg to ac");
				/* now output it */
				emitRO("OUT", ac, 0, 0, "write ac");
			} else {
				/* generate code to store current mp */
				emitRM("ST", mp, localOffset + ofpFO, mp, "call: store current mp");
				/* generate code to push new frame */
				emitRM("LDA", mp, localOffset, mp, "call: push new frame");
				/* generate code to save return in ac */
				emitRM("LDA", ac, 1, pc, "call: save return in ac");

				/* generate code to relative-jump to function entry */
				loc = -(st_lookup(tree->name));
				emitRM("LD", pc, loc, gp, "call: relative jump to function entry");

				/* generate code to pop current frame */
				emitRM("LD", mp, ofpFO, mp, "call: pop current frame");
			}

			if (TraceCode)  emitComment("<- Call");
			break;
		default:
			break;
	}
} /* genExp */

/* Procedure genDecl generates code at a declaration node */
static void genDecl( TreeNode * tree){
	TreeNode * p1, * p2;

  	int loc, loadFuncLoc, jmpLoc, funcBodyLoc, nextDeclLoc;
  	int size;

  	switch (tree->kind.decl) {
  		case FunK:
    		if (TraceCode) {
      			sprintf(buffer, "-> Function (%s)", tree->name);
      			emitComment(buffer);
    		}

		    p1 = tree->child[0];
		    p2 = tree->child[1];

		    inFunc = TRUE;

		    /* generate code to store the location of func. entry */
		    loc = -(st_lookup(tree->name));
		    loadFuncLoc = emitSkip(1);
		    emitRM("ST", ac1, loc, gp, "func: store the location of func. entry");
		    /* decrease global offset by 1 */
		    --globalOffset;

		    /* generate code to unconditionally jump to next declaration */
		    jmpLoc = emitSkip(1);
		    emitComment(
		        "func: unconditional jump to next declaration belongs here");

		    /* skip code generation to allow jump to here
		       when the function was called */
		    funcBodyLoc = emitSkip(0);
		    emitComment("func: function body starts here");

		    /* backpatch */
		    emitBackup(loadFuncLoc);
		    emitRM("LDC", ac1, funcBodyLoc, 0, "func: load function location");
		    emitRestore();

		    /* generate code to store return address */
		    emitRM("ST", ac, retFO, mp, "func: store return address");

		    /* calculate localOffset and nParams */
		    localOffset = initFO;
		    nParams = 0;
		    cGen(p1);

		    /* generate code for function body */
		    if (strcmp(tree->name, "main") == 0)
		      mainLoc = funcBodyLoc;

		    cGen(p2);

		    /* generate code to load pc with return address */
		    emitRM("LD", pc, retFO, mp, "func: load pc with return address");

		    /* backpatch */
		    nextDeclLoc = emitSkip(0);
		    emitBackup(jmpLoc);
		    emitRM_Abs("LDA", pc, nextDeclLoc,
		        "func: unconditional jump to next declaration");
		    emitRestore();

		    inFunc = FALSE;

		    if (TraceCode) {
		      	sprintf(buffer, "<- Function (%s)", tree->name);
		      	emitComment(buffer);
		    }

    		break;

  		case VarK:
    		if (TraceCode) emitComment("-> var. decl.");

		    if (tree->idtype == Array)
		      	size = tree->val;
		    else
		      	size = 1;

    		if (inFunc == TRUE)
      			localOffset -= size;
    		else
      			globalOffset -= size;

    		if (TraceCode) emitComment("<- var. decl.");
    		break;
		case ParamK:
			if (TraceCode) emitComment("-> param");
			emitComment(tree->name);

			--localOffset;
			++nParams;

			if (TraceCode) emitComment("<- param");

			break;

  		default:
     		break;
  	}
} /* genDecl */

/* Procedure cGen recursively generates code by
 * tree traversal
 */
static void cGen( TreeNode * tree){
	if (tree != NULL) {
		switch (tree->nodekind) {
      		case StmtK:
        		genStmt(tree);
        		break;
			case ExpK:
				genExp(tree, FALSE);
				break;
			case DeclK:
				genDecl(tree);
				break;
			default:
				break;
		}
		cGen(tree->sibling);
  	}
}

void genMainCall() {
	emitRM("LDC", ac, globalOffset, 0, "init: load globalOffset");
	emitRO("ADD", mp, mp, ac, "init: initialize mp with globalOffset");

	if (TraceCode) emitComment("-> Call");

	/* generate code to store current mp */
	emitRM("ST", mp, ofpFO, mp, "call: store current mp");
	/* generate code to push new frame */
	emitRM("LDA", mp, 0, mp, "call: push new frame");
	/* generate code to save return in ac */
	emitRM("LDA", ac, 1, pc, "call: save return in ac");

	/* generate code for unconditional jump to function entry */
	emitRM("LDC", pc, mainLoc, 0, "call: unconditional jump to main() entry");

	/* generate code to pop current frame */
	emitRM("LD", mp, ofpFO, mp, "call: pop current frame");

	if (TraceCode) emitComment("<- Call");
}

/* Procedimento que gera código a partir da árvore de sintaxe transversalmente.
Também é passado como parâmetro o nome do arquivo que será impresso o código
gerado. */
void codeGen(TreeNode * syntaxTree, char * codefile) {
	/* Gera comentários iniciais */
	char * s = malloc(strlen(codefile) + 7);
   	strcpy(s, "File: ");
   	strcat(s, codefile);
   	emitComment("C- Compilation to TM Code");
   	emitComment(s);
   	/* Gera instruções que inicializam os registradores */
   	emitComment("Standard prelude:");
   	emitRM("LD", gp, 0, ac, "load gp with maxaddress");
   	emitRM("LDA", mp, 0, gp, "copy gp to mp");
   	emitRM("ST", ac, 0, ac, "clear location 0");
   	emitComment("End of standard prelude.");
   	/* Carrega o escopo global */
   	sc_push(globalScope);
   	/* Gera código para a máquina virtual */
   	cGen(syntaxTree);
   	/* pop global scope */
   	sc_pop();
   	/* call main() function */
   	genMainCall();
   	/* finish */
   	emitComment("End of execution.");
   	emitRO("HALT", 0, 0, 0, "");
}
