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

/* O registro na lista de buckets para cada variável, o qual mantém informações
do nó da árovre e localização na memória. É importante notar que um
bucket possui referência encadeada também, para tratar colisões na função
hash */
typedef struct BucketListRec {
	TreeNode * node;
	int location; /* Posição de memória usado para geração de código */
	struct BucketListRec * next;
} * BucketList;

/* Executa uma busca na tabela por um nome e nome de escopo em comum. Se for
encontrado, o símbolo é retornado, caso contrário, retorna NULL. Caso scope
seja NULL, considera-se que o escopo de busca é apenas global */
BucketList st_lookup (char * name, TreeNode * scope);

/* Insere um símbolo na tabela, caso a função hash retorne um índice já ocupado,
utiliza-se a lista encadeada na posição percorrendo até uma referência livre */
void st_insert (TreeNode * node, int loc);

/* Procedimento que imprime a tabela de símbolos no arquivo de depuração
'listing' */
void st_print ();

/* Libera a memória de um bucket da tabela */
void st_free_bucket (BucketList l);

/* Libera a memória da tabela de símbolos por completo */
void st_free ();


#endif
