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
	char * name; //id
	char * type; //tipo
	char * scope; //escopo
	int lineFirstReferenced;// número da linha onde ocorre a primeira incidencia
	struct BucketListRec * next;
} * BucketList;

 /* Procedimento de inserção um símbolo na tabela. Adiciona também a referência
 do número da linha e na posição na memória. loc é ignorado após a primeira
 inserção do mesmo símbolo */
void st_insert(char * name, int lineno, int loc );

 /* Função que retorna a posição na memória de uma variável. Retorna -1 se não
 encontrada. */
int st_lookup(char * name );

/* Procedimento que imprime a tabela de símbolos no arquivo de depuração
'listing' */
void printSymTab(FILE * listing);

#endif
