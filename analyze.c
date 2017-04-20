/****************************************************/
/* Autor: Amadeus T. Seilert						*/
/* Arquivo: analyze.c                               */
/* Implementação dos procedimentos que farão		*/
/* análises de semântica sobre a árvore de sintaxe.	*/
/****************************************************/
#include "globals.h"
#include "symtab.h"
#include "analyze.h"
#include "util.h"

/* Usado para saber se uma função precisa de return*/
static int hasReturn = FALSE;
/* Usado para saber se ocorreu a declaração da função main */
static int hasMain = FALSE;
/* Contador de valor de endereço virtual de memória, será usado posteriormente
para a geração de código */
static int location = 0x0;

/* Procedimento "faz nada", possibilitando gerar execuções de pré-ordem apenas,
ou pós-ordem. */
static void nullProc(TreeNode * t) {
	if (t == NULL) return;
	else return;
}

/* Procedimento que aponta um erro semântico de tipo. */
static void printSemanticError(TreeNode * t, char * message) {
	fprintf(listing, ANSI_COLOR_RED "Semantic Error" ANSI_COLOR_RESET" at line %d: %s\n", t->lineno, message);
	Error = TRUE;
}

/* Procedimento que permite percorrer a árvore de sintaxe apontado por t. Aplica
o protótipo de Procedimento preProc para execução em pré-ordem, postProc para
pós-ordem. */
static void traverse( TreeNode * t,
	void (* preProc) (TreeNode *),
	void (* postProc) (TreeNode *) ) {
		if (t != NULL) {
			preProc(t);
			{
				int i;
				for (i = 0; i < MAXCHILDREN; i++)
					traverse(t->child[i], preProc, postProc);
			}
			postProc(t);
			traverse(t->sibling, preProc, postProc);
		}
}

/* Função que verifica se os argumentos de um nó de invocação "callNode" de
função ou´procedimento está de acordo com os parâmetros do nó de declaração
"functionNode" */
static int checkCallArguments (TreeNode * callNode, TreeNode * functionNode) {

	TreeNode * arg, * param;
	arg = callNode->child[0];
	param = functionNode->child[0];

	while (arg != NULL && param != NULL) {
		/* Como os argumentos e parâmetros devem seguir a mesma ordem, basta
		verificar os tipos */
		if (arg->type != param->type || arg->idtype != param->idtype)
			return FALSE;
		arg = arg->sibling;
		param = param->sibling;
	}
	if (arg == NULL && param == NULL)
		return TRUE;
	else
		return FALSE;
}

/* Procedimento que executa a inserção de símbolos na tabela e também realiza
verificações de regularidade de declarações. */
static void insertNode(TreeNode * t){
	BucketList temp;
	switch (t->nodekind){
		case DeclK:
			temp = st_lookup(t->name, t->enclosingFunction);
			if (temp != NULL){
				/* temp não é nulo, significa que já ocorreu a declaração
				com o mesmo nome e mesmo escopo anteriormente */
				printSemanticError(t, "duplicate identifier declared");
			} else {
				/* Nova declaração, insere na tabela de símbolos */
				st_insert(t, location++);
				/* Verifica se ocorreu a declaração da função main*/
				if (t->kind.decl == FunK && hasMain == FALSE)
					if (strcmp(t->name, "main") == 0)
						hasMain = TRUE;
			}
			break;
		case ExpK:
			/* Verifica se o uso de um identificador é legal */
			if (t->kind.exp == IdK) {
				/* Busca na tabela se existe a declaração da variável no
				escopo local */
				temp = st_lookup(t->name, t->enclosingFunction);
				if (temp == NULL){
					/* Busca a declaração no escopo global */
					temp = st_lookup(t->name, NULL);
					if (temp == NULL)
						printSemanticError(t, "undeclared variable");
				}
			}
			break;
		case StmtK:
			/* Verifica se ocorre uma invocação de uma função que existe */
			if (t->kind.stmt == CallK) {
				/* Todas as funções possuem escopo global. Eventuais mudanças
				na gramática para funções anônimas implicam a alteração nesta
				lógica. */
				temp = st_lookup(t->name, NULL);
				if (temp == NULL) {
					printSemanticError(t, "undefined function or procedure call");
				} else {
					/* Anexa a assinatura da função ao nó de invocação para
					poder verificar os argumentos na próxima verificação de
					tipo */
					t->enclosingFunction = temp->node;
				}
			}
			break;
		default:
			break;
	}
}

/* Procedimento que executa a verificação de tipo de um nó da árvore */
static void checkNode(TreeNode * t) {
	BucketList temp;

	switch (t->nodekind){
		case ExpK:
			/* Nós do tipo expressão precisam realizar a verificação dos tipos
			de seus nós filhos e em seguida atribuir o tipo ao nó raiz */
			switch (t->kind.exp){
				/* verifica se um nó do tipo operação possui ambos os filhos
				nós de tipo inteiro */
				case OpK:
					if ((t->child[0]->type != Integer) || (t->child[1]->type != Integer))
						printSemanticError(t, "Op applied to non-integer");
					/* Atribui tipo booleano a operações de comparação */
					if ((t->op == EQ) ||
						(t->op == DIF) ||
						(t->op == LT) ||
						(t->op == GT) ||
						(t->op == LTE) ||
						(t->op == GTE))
						t->type = Boolean;
					else
						/* O restantante das operações  */
						t->type = Integer;
					break;
				case ConstK:
					t->type = Integer;
					break;
				case IdK:
					if (t->idtype == Simple) {
						t->type = Integer;
					} else if (t->idtype == Array){
						if (t->child[0]->type != Integer)
							printSemanticError(t, "array must be indexed by an integer value");
						else
							t->type = Integer;
					} else {
						printSemanticError(t, "illegal identifier type");
					}
					break;
			}
		break;
		case StmtK:
			/* Nós do tipo statement não precisam ter valor de tipo (exceto
			call), apenas seus filhos, como é o caso, por exemplo, do nó if, que
			deve possuir uma expressão do tipo booleana como filho */
			switch (t->kind.stmt) {
				case CmpdK:
					/* Não verifica nada */
					break;
				case IfK:
					/* A expressão dentro do teste do if deve ser do tipo
					booleano */
					if (t->child[0]->type != Boolean)
						printSemanticError(t->child[0], "if test is not Boolean");
					break;
				case AssignK:
					/* Como só é possível a declaração de variáveis do tipo
					inteiro, a atribuição deve ser dada a uma variável inteira */
					if (t->child[0]->type != Integer &&
						t->child[1]->type != Integer)
						printSemanticError(t->child[0], "assignment of non-integer value");
					else
						t->type = Integer;
					break;
				case WhileK:
					/* A expressão dentro do teste do laço deve ser do tipo
					booleano */
					if (t->child[0]->type != Boolean)
						printSemanticError(t->child[0], "while test is not Boolean");
					break;
				case CallK:
					/* Tipo de retorno da invocação é o mesmo da assinatura da
					função ou procedimento anexada ao nó */
					t->type = t->enclosingFunction->type;
					/* Assumindo que os argumentos de uma chamada de função já
					possuem atribuição de tipo por conta da execução em
					pós-ordem desta análise, basta agora verificar se
					os argumentos são equivalentes à assinatura da função ou
					procedimento */
					temp = st_lookup(t->name, NULL);
					if (temp != NULL){
						if (checkCallArguments(t, temp->node) == FALSE) {
							printSemanticError(t, "arguments of function call does not match");
						}
					}
					break;
				case ReturnK:
					/* Como a varredura é em pós-ordem, os nós internos de um
					compound_stmt são vasculhadas primeiramente. Deste modo,
					ao encontrar o nó return, mudamos a flag. Quando retroceder
					na pilha de recursão para um nó do tipo declaração de função,
					é desejável verificar se a função precisa de retorno. */
					hasReturn = TRUE;
					/* Verifica se o tipo de retorno é equivalente à função
					anexada. */
					if (t->child[0] == NULL && t->enclosingFunction->type != Void) {
						printSemanticError(t->child[0], "return type of function does not match");
					} else if (t->child[0] != NULL) {
						if (t->child[0]->type != t->enclosingFunction->type) {
							printSemanticError(t->child[0], "return type of function does not match");
						}
					}
					break;
			}
			break;
		case DeclK:
			switch (t->kind.decl) {
				case VarK:
					if (t->type != Integer)
						printSemanticError(t->child[0], "variable type is not integer");
					break;
				case ParamK:
					if (t->type != Integer)
						printSemanticError(t->child[0], "parameter type is not integer");
					break;
				case FunK:
					if (t->type != Integer && t->type != Void)
						printSemanticError(t, "function type must be either integer or void");
					else if (t->type == Integer && hasReturn == FALSE) {
						printSemanticError(t, "return statement not found in non-void function");
					}
					hasReturn = FALSE;
					break;
			}
		default:
			break;

	}
}

/* Procedimento em pós-ordem para verificar os tipos dos nós da árvore */
void typeCheck(TreeNode * syntaxTree) {
	traverse(syntaxTree, nullProc, checkNode);
}

/* Função que cria na tabela os símbolos pré definidos, que são as funções de
entrada e saída de um programa padrão. */
void declarePredefines( ) {

	TreeNode * inputNode = NULL;
	TreeNode * temp = NULL;
	TreeNode * outputNode = NULL;

	/* define "int input()" */
	inputNode = newNode();
	inputNode->lineno = 0;
	inputNode->name = copyString("input");
	inputNode->idtype = Function;
	inputNode->type = Integer;

    /* define o argumento do procedimento "output" */
    temp = newNode();
	temp->lineno = 0;
    temp->name = copyString("arg");
    temp->type = Integer;
    temp->idtype = Simple;

	/* define "void output(int)" */
    outputNode = newNode();
	outputNode->lineno = 0;
    outputNode->name = copyString("output");
    outputNode->type = Void;
    outputNode->idtype = Function;
    outputNode->child[0] = temp;

	st_insert(inputNode, location++);
	st_insert(outputNode, location++);
}

/* Procedimento que constroi a tabela de símbolos. O percurso na árvore é
definido pela transversal em pré-ordem. */
void buildSymtab(TreeNode * syntaxTree) {
	declarePredefines();
	traverse(syntaxTree,insertNode,nullProc);

	if (!hasMain) {
		printSemanticError(syntaxTree, "no main function declared");
	}
	if (TraceAnalyze){
		fprintf(listing, ANSI_COLOR_YELLOW "\nSymbol table:\n\n" ANSI_COLOR_RESET);
		st_print();
	}
}
