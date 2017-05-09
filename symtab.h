/****************************************************/
/* Autor: Amadeus T. Seilert						*/
/* Arquivo: symtab.h                                */
/* Interface da tabela de símbolos do 				*/
/* compilador C-.									*/
/****************************************************/

#ifndef _SYMTAB_H_
#define _SYMTAB_H_

/* Tamanho máximo de símbolos diferentes que a tabela poderá comportar */
#define SIZE 211

/* Potência de dois para o deslocamento como multiplicador na função de hash */
#define SHIFT 4
/* Quantidade máxima de escopos que podem existir em um código */
#define MAX_SCOPE 64

/* Definição de um bucket para uma tabela de símbolos. É importante notar que um
bucket possui referência encadeada também, para tratar colisões na função
hash */
typedef struct BucketListRec {
	TreeNode * node; /* Ref. do nó da árvore de sintaxe */
	int location; /* Posição de memória usado para geração de código */
	struct BucketListRec * next; /* Ref. do próximo bucket */
} * BucketList;

/* Definição de um escopo. Este possui uma tabela de símbolo própria. Na
gramática do C-, só é possível ocorrer declarações de funções no escopo global,
entretanto, esta estrutura já está pronta para eventuais modificações. */
typedef struct ScopeRec {
	char * name; /* Nome da função ou procedimento */
	int nestedLevel; /* Nível de aninhamento */
	struct ScopeRec * parent; /* Escopo 'pai'*/
	BucketList hashTable[SIZE]; /* Tabela de símbolos do escopo */
} * Scope;

/* A exportação do escopo global ocorre por conta que sua inicialização ocorrerá
no começo da construção das tabelas de símbolos */
extern Scope globalScope;

void sc_init( void );

/* Retorna o escopo no topo da pilha de escopos */
Scope sc_top( void );

/* Desempilha o topo da pilha */
void sc_pop( void );

/* Retorna a localização mais alta do escopo no topo da pilha */
int sc_location( void );

/* Empilha um escopo na pilha */
void sc_push( Scope scope );

Scope sc_find(char * funcName);

/* Cria um novo escopo a partir de um nome de uma função ou procedimento */
Scope sc_create(char * funcName);

/* Busca pela posição na memória de um símbolo em todos os escopos */
int st_lookup (char * name);

int st_lookup_top (char * name);

/* Executa uma busca na tabela por um nome em todos os escopos. Se for
encontrado, o símbolo é retornado, caso contrário, retorna NULL.*/
BucketList st_bucket (char * name);

/* Executa uma busca na tabela por um nome em no escopo no topo da pilha. Se for
encontrado, o símbolo é retornado, caso contrário, retorna NULL.*/
BucketList st_bucket_top (char * name);

/* Insere um símbolo na tabela, caso a função hash retorne um índice já ocupado,
utiliza-se a lista encadeada na posição percorrendo até uma referência livre */
void st_insert (TreeNode * node, int loc);

/* Procedimento que imprime a tabela de símbolos no arquivo de depuração
'listing' */
void st_print ();


#endif
