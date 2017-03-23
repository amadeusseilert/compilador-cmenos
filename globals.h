
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAXCHILDREN 3

typedef enum {Opk, NUMk, REALk, IDk, IFk, WHILEk, INTk, VOIDk, FLOATk, ATRk, RETURNk} Tipo;
typedef enum {MAIORk, MAIORIGLk, MENORk, MENORIGLk, IGLk, DIFk, SUMk, SUBk, MULk, DIVk, NoOPK} TipoOp;

//create a linked list to store the lines each variable appears
typedef struct linha{
	int linenumber;
	struct linha* next;
} Linha;

//create a linked list to store the variables
typedef struct simbolo{
	Linha* lineNumber;
	char* id;
	int type;
	int isFunction;
	int isVector;
	char* scope;
	struct simbolo* next;
} Simbolo;

typedef struct treeNode{
     struct treeNode * child[MAXCHILDREN];
     struct treeNode * sibling;
     int lineno;
     Tipo tipo;
     TipoOp tipoOp;
     int valNum;
     float valFloat;
     char* text;
     int isVector;
     int isIndex;
     int isFunction;
} TreeNode;

#define YYPARSER // distinguishes Yacc output from other code files
#define YYSTYPE TreeNode*

extern Simbolo** tabelaSimbolos;
extern int numLine;
extern char* yytext;
extern YYSTYPE savedTree;
extern YYSTYPE parse();
extern FILE * yyin;
extern int getToken();
extern void imprime_tabela_simbolos();
extern void inicia_tabela();
extern void check_main();
