/****************************************************/
/* Autor: Amadeus T. Seilert						*/
/* Arquivo: analyse.c                               */
/* Implementação dos procedimentos que farão		*/
/* análises de semântica sobre a árvore de sintaxe.	*/
/****************************************************/
#include "globals.h"
#include "symtab.h"
#include "analyze.h"
#include "util.c"

/* Contador de localização de memória obsoluta */
static int location = 0;

int hasMain = FALSE;

static char * currentScope;
static const char globalScopeName = "_global";
static const char localScopeName = "_local";

void setScope (char * name) {

	if (name == NULL) {
		currentScope = copyString(globalScopeName);
	} else {
		currentScope = copyString(localScopeName);
		strcat(currentScope, name);
	}
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
			traverse(t->sibling,preProc,postProc);
		}
}

/* Procedimento "faz nada", possibilitando gerar execuções de pré-ordem apenas,
ou pós-ordem. */
static void nullProc(TreeNode * t) {
	if (t==NULL) return;
	else return;
}

static void insertNode( TreeNode * t){

	BucketList temp;
	switch (t->nodekind){
		case DeclK:
			temp = st_lookup(t->name, currentScope);
			if (temp != NULL){
				printSemanticError(t, "duplicate identifier declared");
			} else {
				temp = st_allocate(t->name, currentScope, typeName(t->type), t->lineno);
				st_insert(temp);
				if (t->idtype == Function){
					setScope(t->name);
				}
			}
			break;
		case ExpK:

		default:
			break;
	}
}

void declarePredefines( ) {

	BucketList input;
	BucketList output;

    /* define "int input(void)" */
    input->name = copyString("input");
    input->type = Integer;
    input->scope = copyString("global");

    /* define "void output(int)" */
    temp = newNode();
    temp->name = copyString("arg");
    temp->type = Integer;
    temp->idtype = Simple;

    output = newNode();
    output->name = copyString("output");
    output->type = Void;
    output->idtype = Function;
    output->child[0] = temp;

    insertSymbol("input", input, 0);
    insertSymbol("output", output, 0);
}

/* Procedimento que constroi a tabela de símbolos. O percurso na árvore é
definido pela transversal em pré-ordem. */
void buildSymtab(TreeNode * syntaxTree) {
	currentScope = copyString("global");
	traverse(syntaxTree,insertNode,nullProc);
	if (TraceAnalyze){
		fprintf(listing, "\nSymbol table:\n\n");
		printSymTab(listing);
	}
}

/* Procedimento que aponta um erro semântico de tipo. */
static void printSemanticError(TreeNode * t, char * message) {
	fprintf(listing, "Semantic error at line %d: %s\n", t->lineno, message);
	Error = TRUE;
}

static int checkArguments(TreeNode * callNode){

	return TRUE;
}

/* Procedimento que executa a verificação de tipo de um nó da árvore */
static void checkNode(TreeNode * t) {
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
					if ((t->attr.op == EQ) ||
						(t->attr.op == DIF) ||
						(t->attr.op == LT) ||
						(t->attr.op == GT) ||
						(t->attr.op == LTE) ||
						(t->attr.op == GTE) ||)
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

				case ReturnK:
					/* Se */
					if (t->child[0] != NULL && t->child[0]->type != Integer)
						printSemanticError(t->child[1],"function returns non-integer value");
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
						printSemanticError(t->child[0], "function type must be either integer or void");
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
