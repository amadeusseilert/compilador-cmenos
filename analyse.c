/****************************************************/
/* Autor: Amadeus T. Seilert						*/
/* Arquivo: analyse.c                               */
/* Implementação dos procedimentos que farão		*/
/* análises de semântica sobre a árvore de sintaxe.	*/
/****************************************************/
#include "globals.h"
#include "symtab.h"
#include "analyze.h"

/* Contador de localização de memória obsoluta */
static int location = 0;


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

/* Procedure insertNode inserts
* identifiers stored in t into
* the symbol table
*/
static void insertNode( TreeNode * t){
	switch (t->nodekind){
		case StmtK:
			switch (t->kind.stmt){
				case AssignK:
				case ReadK:
					if (st_lookup(t->attr.name) == -1)
						/* not yet in table, so treat as new definition */
						st_insert(t->attr.name,t->lineno,location++);
					else
						/* already in table, so ignore location,
						add line number of use only */
						st_insert(t->attr.name,t->lineno,0);
					break;
				default:
					break;
			}
			break;
		case ExpK:
			switch (t->kind.exp){
				case IdK:
					if (st_lookup(t->attr.name) == -1)
						/* not yet in table, so treat as new definition */
						st_insert(t->attr.name,t->lineno,location++);
					else
						/* already in table, so ignore location,
						add line number of use only */
						st_insert(t->attr.name,t->lineno,0);
					break;
				default:
					break;
			}
			break;
		default:
			break;
	}
}

/* Procedimento que constroi a tabela de símbolos. O percurso na árvore é
definido pela transversal em pré-ordem. */
void buildSymtab(TreeNode * syntaxTree) {
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

/* Procedimento que executa a verificação de tipo de um nó da árvore */
static void checkNode(TreeNode * t) {
	switch (t->nodekind){
		case ExpK:
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
				case IdK:
					t->type = Integer;
					break;
				default:
					break;
			}
		break;
		case StmtK:
			switch (t->kind.stmt) {
				case IfK:
					/* A expressão dentro do teste do if deve ser do tipo
					booleano */
					if (t->child[0]->type != Boolean)
						printSemanticError(t->child[0], "if test is not Boolean");
					break;
				case AssignK:
					/* Como só é possível a declaração de variáveis do tipo
					inteiro, a atribuição deve ser dada a uma variável inteira */
					if (t->child[0]->type != Integer)
						printSemanticError(t->child[0], "assignment of non-integer value");
					break;
				case WhileK:
					/* A expressão dentro do teste do laço deve ser do tipo
					booleano */
					if (t->child[0]->type != Boolean)
						printSemanticError(t->child[0], "while test is not Boolean");
					break;
				case ReturnK:
					/* Se */
					if (t->child[0] != NULL && t->child[0]->type != Integer)
						printSemanticError(t->child[1],"function returns non-integer value");
				break;
				default:
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
					if (t->type != Integer || t->type != Void)
						printSemanticError(t->child[0], "function type must be either integer or void");
					break;
			}
		default:
			break;

	}
}

/* Procedimento em pré-ordem para verificar os tipos dos nós da árvore */
void typeCheck(TreeNode * syntaxTree) {
	traverse(syntaxTree, nullProc, checkNode);
}
