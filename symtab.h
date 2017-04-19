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
como o nome, as linhas e localização na memória. É importante notar que um
bucket possui referência encadeada também, para tratar colisões na função
hash */
typedef struct BucketListRec {
	TreeNode * node;
	struct BucketListRec * next;
} * BucketList;

BucketList st_lookup (char * name, TreeNode * scope);

void st_insert (BucketList newBucket);

BucketList st_allocate (TreeNode * node);

/* Procedimento que imprime a tabela de símbolos no arquivo de depuração
'listing' */
void st_print ();

void st_free_bucket (BucketList l);

void st_free ();


#endif
