/****************************************************/
/* Autor: Amadeus T. Seilert						*/
/* Arquivo: util.c                                	*/
/* Implementação das funções de utilidade do 		*/
/* compilador       								*/
/****************************************************/

#include "globals.h"
#include "util.h"

static char invalid[] = "<<unk>>";

static char i[] = "int";
static char v[] = "void";
static char b[] = "bool";

static char var[] = "var";
static char fun[] = "fun";
static char par[] = "par";

static char g[] = "_global_";

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

char * declKindName(DeclKind kind){
	switch (kind) {
		case VarK:
			return var;
			break;
		case FunK:
			return fun;
			break;
		case ParamK:
			return par;
			break;
		default:
			return invalid;
	}
}

char * scopeName(TreeNode * node){
	char * scopeName;

	if (node == NULL)
		return g;
	else {
		scopeName = copyString("_");
		strcat(scopeName, node->name);
		strcat(scopeName, "_");
		return scopeName;
	}
}

/* Função que retorna a string do nome de um tipo */
char * typeName(Type type){
    switch (type) {
    	case Integer:
		 	return i;
			break;
    	case Void:
			return v;
			break;
		case Boolean:
			return b;
			break;
    	default:
			return invalid;
			break;
    }
}

/*
Esta função cria um nó da árvore de sintaxe.
*/
TreeNode * newNode() {
    TreeNode * t = (TreeNode *) malloc(sizeof(TreeNode));
    int i;
    if (t == NULL)
        fprintf(listing, "Out of memory error at line %d\n", lineno);
    else {

        for (i = 0; i < MAXCHILDREN; i++) t->child[i] = NULL;
        t->sibling = NULL;
		t->enclosingFunction = NULL;
        t->lineno = lineno;
    }
    return t;
}
/*
Função que aloca e cria uma copia de uma string existente.
*/
char * copyString(char * s) {
	char * copy = (char*) malloc ((strlen(s) + 1) * sizeof(char) );
	strcpy(copy, s);
	return copy;
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
	          		fprintf(listing, "Const: %d\n", tree->val);
	          		break;
	        	case IdK:
	          		fprintf(listing, "Id: %s\n", tree->name);
	          		break;
				case AssignK:
					fprintf(listing, "Assign\n");
					break;
				case CallK:
					fprintf(listing, "Call: %s\n", tree->name);
					break;
	        	default:
	          		fprintf(listing, "Unknown ExpNode kind\n");
	          		break;
      		}
    	} else if (tree->nodekind == DeclK) {
			switch (tree->kind.decl) {
				case VarK:
					fprintf(listing, "Variable: %s Type: %s\n", tree->name, typeName(tree->type));
					break;
				case FunK:
					fprintf(listing, "Function: %s Type: %s\n", tree->name, typeName(tree->type));
					break;
				case ParamK:
					fprintf(listing, "Parameter: %s Type: %s\n", tree->name, typeName(tree->type));
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

/* CORRIGIR */
void freeNode(TreeNode * node) {
	free(node->name);
	free(node);
}

/*
Program received signal SIGSEGV, Segmentation fault.
freeTree (tree=0x3d3340) at util.c:226
226                     for (i = 0; i < MAXCHILDREN; i++)

CORRIGIR
*/
void freeTree(TreeNode * tree) {

	// int i;
	//
	// if (tree == NULL)
	// 	return;
	//
	// for (i = 0; i < MAXCHILDREN; i++)
	// 	freeTree(tree->child[i]);
	// freeTree(tree->sibling);
	// freeNode(tree);

	free(tree);
}
