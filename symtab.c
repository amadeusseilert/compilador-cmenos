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
#include "util.h"

/* Função hashing. Responsável por gerar um índice a partir de um nome de
variável 'key' */
static int hash (char * key) {
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

BucketList st_lookup (char * name, * scope) {
	int h = hash(name);
	BucketList l =  hashTable[h];
	int found = FALSE;

	while (l != NULL && found == FALSE){
		if (strcmp(name, l->name) == 0 && strcmp(scope, l->scope) == 0)
			found = TRUE;
		l = l->next;
	}

	if (found == TRUE)
		return l;
	else
		return NULL;
}

void st_insert (BucketList newBucket) {
	int h = hash(name);
	BucketList l =  hashTable[h];

	while (l != NULL) {
		l = l->next;
	}
	
	l->next = newBucket;
}

BucketList st_allocate (char * name, char * scope, char * type, int lineno) {
    struct BucketListRec * temp;

    temp = (struct BucketListRec *) malloc(sizeof(BucketList));
    if (temp == NULL){
		Error = TRUE;
		fprintf(listing,
			"*** Out of memory allocating memory for symbol table\n");
    } else {
		temp->name = copyString(name);
		temp->scope = copyString(scope);
		temp->type = copyString(type);
		temp->lineFirstReferenced = lineno;
		temp->next = NULL;
    }
    return temp;
}

/* Procedimento que imprime a tabela de símbolos no arquivo de depuração
'listing' */
void st_print (FILE * listing) {
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
