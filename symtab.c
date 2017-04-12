/****************************************************/
/* Autor: Amadeus T. Seilert						*/
/* Arquivo: symtab.c                                */
/* Implementação da tabela de símbolos do 			*/
/* compilador C-.									*/
/****************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symtab.h"

/* Função hashing. Responsável por gerar um índice a partir de um nome de
variável 'key' */
static int hash (char * key ) {
	int temp = 0;
	int i = 0;
	while (key[i] != '\0') {
		temp = ((temp << SHIFT) + key[i]) % SIZE;
		++i;
	}
	return temp;
}

/* Tabela de símbolos */
static BucketList hashTable[SIZE];

/* Procedimento de inserção um símbolo na tabela. Adiciona também a referência
do número da linha e na posição na memória. loc é ignorado após a primeira
inserção do mesmo símbolo */
void st_insert(char * name, int lineno, int loc ) {
	int h = hash(name);
	BucketList l =  hashTable[h];
	/* Mesmo estando no mesmo índice do bucket, pode ser que o primeiro símbolo
	seja uma variável diferente. Portanto, deve ser inserido na referência do
	próximo bucket */
	while ((l != NULL) && (strcmp(name,l->name) != 0))
		l = l->next;
	if (l == NULL) {/* Variável ainda não presente na tabela */
		l = (BucketList) malloc(sizeof(struct BucketListRec));
		l->name = name;
		l->lines = (LineList) malloc(sizeof(struct LineListRec));
		l->lines->lineno = lineno;
		l->memloc = loc;
		l->lines->next = NULL;
		l->next = hashTable[h];
		hashTable[h] = l;
	}
	else {/* Variável já presente, adiciona uma ocorrência nas linhas */
	 	LineList t = l->lines;
		while (t->next != NULL)
			t = t->next;
		t->next = (LineList) malloc(sizeof(struct LineListRec));
		t->next->lineno = lineno;
		t->next->next = NULL;
	}
}

/* Função que retorna a posição na memória de uma variável. Retorna -1 se não
encontrada. */
int st_lookup (char * name ) {
	int h = hash(name);
	BucketList l =  hashTable[h];
	while ((l != NULL) && (strcmp(name,l->name) != 0))
		l = l->next;
	if (l == NULL) return -1;
	else return l->memloc;
}

/* Procedimento que imprime a tabela de símbolos no arquivo de depuração
'listing' */
void printSymTab(FILE * listing) {
	int i;
	fprintf(listing,"Variable Name  Location   Line Numbers\n");
	fprintf(listing,"-------------  --------   ------------\n");
	for (i=0;i<SIZE;++i) {
		if (hashTable[i] != NULL) {
			BucketList l = hashTable[i];
			while (l != NULL) {
				LineList t = l->lines;
				fprintf(listing,"%-14s ",l->name);
				fprintf(listing,"%-8d  ",l->memloc);
				while (t != NULL){
					fprintf(listing,"%4d ",t->lineno);
					t = t->next;
				}
				fprintf(listing,"\n");
				l = l->next;
			}
		}
	}
}
