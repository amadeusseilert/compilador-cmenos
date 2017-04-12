/****************************************************/
/* Autor: Amadeus T. Seilert						*/
/* Arquivo: util.c                                	*/
/* Implementação das funções de utilidade do 		*/
/* compilador       								*/
/****************************************************/

#include "globals.h"
#include "util.h"

/*
Procedimento que imprime um token e seu lexema no arquivo listitng
*/
void printToken(TokenType token, const char* tokenString ) {
    switch (token){
        case IF:
        case ELSE:
        case WHILE:
        case RETURN:
        case INT:
        case VOID:
            fprintf(listing, "reserved word: %s\n", tokenString);
            break;
        case ASSIGN: fprintf(listing, "=\n"); break;
        case LT: fprintf(listing, "<\n"); break;
        case GT: fprintf(listing, ">\n"); break;
        case LTE: fprintf(listing, "<=\n"); break;
        case GTE: fprintf(listing, ">=\n"); break;
        case DIF: fprintf(listing, "!=\n"); break;
        case EQ: fprintf(listing, "==\n"); break;
        case LPAREN: fprintf(listing, "(\n"); break;
        case RPAREN: fprintf(listing, ")\n"); break;
        case LBRCKT: fprintf(listing, "[\n"); break;
        case RBRCKT: fprintf(listing, "]\n"); break;
        case LBRACE: fprintf(listing, "{\n"); break;
        case RBRACE: fprintf(listing, "}\n"); break;
        case SEMI: fprintf(listing, ";\n"); break;
        case COMA: fprintf(listing, ",\n"); break;
        case PLUS: fprintf(listing, "+\n"); break;
        case MINUS: fprintf(listing, "-\n"); break;
        case TIMES: fprintf(listing, "*\n"); break;
        case OVER: fprintf(listing, "/\n"); break;
        case NUM:
            fprintf(listing, "NUM, val= %s\n", tokenString);
            break;
        case ID:
            fprintf(listing,  "ID, name= %s\n", tokenString);
            break;
        case ERROR:
            fprintf(listing,  "ERROR: %s\n", tokenString);
            break;
		case EOF:
			fprintf(listing, "EOF\n");
			break;
        default: /* Este caso nunca deve acontecer */
            fprintf(listing, "Unknown token: %d\n",token);
    }
}

/*
Esta função cria um nó do tipo statement para a construção da árvore de sintaxe.
*/
TreeNode * newStmtNode(StmtKind kind) {
    TreeNode * t = (TreeNode *) malloc(sizeof(TreeNode));
    int i;
    if (t == NULL)
        fprintf(listing, "Out of memory error at line %d\n", lineno);
    else {
        for (i = 0; i < MAXCHILDREN; i++) t->child[i] = NULL;
            t->sibling = NULL;
            t->nodekind = StmtK;
            t->kind.stmt = kind;
            t->lineno = lineno;
			t->idtype = None;
    }
    return t;
}

/*
Esta função cria um nó do tipo expressão para a construção da árvore de sintaxe.
*/
TreeNode * newExpNode(ExpKind kind) {
    TreeNode * t = (TreeNode *) malloc(sizeof(TreeNode));
    int i;
    if (t == NULL)
        fprintf(listing, "Out of memory error at line %d\n", lineno);
    else {
        for (i = 0; i < MAXCHILDREN; i++) t->child[i] = NULL;
        t->sibling = NULL;
        t->nodekind = ExpK;
        t->kind.exp = kind;
        t->lineno = lineno;
        t->type = Void;
		t->idtype = None;
    }
    return t;
}

/*
Esta função cria um nó do tipo declaração para a construção da árvore de sintaxe.
*/
TreeNode * newDeclNode(DeclKind kind) {
    TreeNode * t = (TreeNode *) malloc(sizeof(TreeNode));
    int i;
    if (t == NULL)
        fprintf(listing, "Out of memory error at line %d\n", lineno);
    else {
        for (i = 0; i < MAXCHILDREN; i++) t->child[i] = NULL;
        t->sibling = NULL;
        t->nodekind = DeclK;
        t->kind.decl = kind;
        t->lineno = lineno;
        t->type = Void;
		t->idtype = None;
    }
    return t;
}

/*
Função que aloca e cria uma copia de uma string existente.
*/
char * copyString(char * s) {
    int n;
    char * t;
    if (s == NULL)
        return NULL;
    n = strlen(s) + 1;
    t = malloc(n);
    if (t == NULL)
        fprintf(listing, "Out of memory error at line %d\n", lineno);
    else strcpy(t,s);
    return t;
}

/*
Variável auxiliar que armazena o número de caráctere de espaço usada na
identação
*/
static int indentno = 0;

/*
macros para aumentar/diminuir a identação
*/
#define INDENT indentno+=2
#define UNINDENT indentno-=2

/*
Imprime espaços no listing conforme a quantidade armazena em indentno
*/
static void printSpaces(void) {
    int i;
    for (i = 0; i < indentno; i++)
        fprintf(listing, " ");
}

/* Procedimento para imprimir um nó do tipo var */
void printVarId(TreeNode * tree) {
	switch (tree->type) {
		case Integer:
			fprintf(listing, "Var: %s INTEGER ",tree->name);
			if (tree->idtype == Array)
				fprintf(listing, "[%d]",tree->val);
			fprintf(listing, "\n");
			break;
		default:
			fprintf(listing, "Unknown Var kind\n");
			break;
	}
}

/* Procedimento para imprimir um nó do tipo param */
void printParamId(TreeNode * tree) {
	switch (tree->type) {
		case Integer:
			fprintf(listing, "Param: %s INTEGER ",tree->name);
			if (tree->idtype == Array)
				fprintf(listing, "[%d]",tree->val);
			fprintf(listing, "\n");
			break;
		default:
			fprintf(listing, "Unknown Var kind\n");
			break;
	}
}

/* Procedimento para imprimir um nó do tipo function */
void printFunctionId(TreeNode * tree) {
	switch (tree->type) {
		case Integer:
			fprintf(listing, "Function: %s INTEGER\n",tree->name);
			break;
		case Void:
			fprintf(listing, "Function: %s VOID\n",tree->name);
			break;
		default:
			fprintf(listing, "Unknown Function kind\n");
			break;
	}
}

/* procedure printTree prints a syntax tree to the
 * listing file using indentation to indicate subtrees
 */
void printTree(TreeNode * tree){
	int i;
  	INDENT;
  	while (tree != NULL) {
    	printSpaces();
    	if (tree->nodekind == StmtK){
			switch (tree->kind.stmt) {
				case CmpdK:
					fprintf(listing, "Compound Stmt\n");
					break;
        		case IfK:
          			fprintf(listing, "If\n");
          			break;
        		case WhileK:
          			fprintf(listing, "While\n");
          			break;
        		case AssignK:
          			fprintf(listing, "Assign\n");
          			break;
				case CallK:
					fprintf(listing, "Call: %s\n",tree->name);
					break;
        		case ReturnK:
          			fprintf(listing, "Return\n");
          			break;
        		default:
          			fprintf(listing, "Unknown StmtNode kind\n");
          			break;
      		}
    	} else if (tree->nodekind == ExpK) {
			switch (tree->kind.exp) {
        		case OpK:
          			fprintf(listing, "Op: ");
          			printToken(tree->op, "\0");
          			break;
	        	case ConstK:
	          		fprintf(listing, "Const: %d\n",tree->val);
	          		break;
	        	case IdK:
	          		fprintf(listing, "Id: %s\n",tree->name);
	          		break;
	        	default:
	          		fprintf(listing, "Unknown ExpNode kind\n");
	          		break;
      		}
    	} else if (tree->nodekind == DeclK) {
			switch (tree->kind.decl) {
				case VarK:
					printVarId(tree);
					break;
				case FunK:
					printFunctionId(tree);
					break;
				case ParamK:
					printParamId(tree);
					break;
				default:
					fprintf(listing, "Unknown DeclNode kind\n");
					break;
			}
		} else
			fprintf(listing, "Unknown node kind\n");
    	for (i = 0; i < MAXCHILDREN ;i++)
         	printTree(tree->child[i]);
    	tree = tree->sibling;
  	}
  	UNINDENT;
}
