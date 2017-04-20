/****************************************************/
/* Autor: Amadeus T. Seilert						*/
/* Arquivo: symtab.c                                */
/* Implementação da tabela de símbolos do 			*/
/* compilador C-.									*/
/****************************************************/

#include "globals.h"
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

BucketList st_lookup (char * name, TreeNode * scope) {
	int h = hash(name);
	BucketList l =  hashTable[h];
	int found = FALSE;

	while (l != NULL && found == FALSE){
		if (strcmp(name, l->node->name) == 0){
			if (scope != NULL && l->node->enclosingFunction != NULL) {
				if (strcmp(scope->name, l->node->enclosingFunction->name) == 0)
					return l;
			} else if (scope == NULL && l->node->enclosingFunction == NULL)
				return l;
		}
		l = l->next;
	}

	return NULL;
}

void st_insert (TreeNode * node) {
	int h = hash(node->name);
	BucketList l =  hashTable[h];

	while (l != NULL) {
		l = l->next;
	}

	l = (BucketList) malloc(sizeof(struct BucketListRec));
	l->node = node;
	l->next = hashTable[h];
	hashTable[h] = l;
}

/* Procedimento que imprime a tabela de símbolos no arquivo de depuração
'listing' */
void st_print () {
	int i;
	fprintf(listing,"Variable Name\tType\tScope Name\tLine #\n");
	fprintf(listing,"-------------\t----\t----------\t------\n");
	for (i=0;i<SIZE;++i) {
		if (hashTable[i] != NULL) {
			BucketList l = hashTable[i];
			while (l != NULL) {
				fprintf(listing,"%-15s", l->node->name);
				fprintf(listing,"%-10s", typeName(l->node->type));
				fprintf(listing,"%-14s", scopeName(l->node->enclosingFunction));
				fprintf(listing,"%d", l->node->lineno);
				fprintf(listing,"\n");
				l = l->next;
			}
		}
	}
}

/* CORRIGIR */
void st_free_bucket (BucketList l) {
	l->node = NULL;
	free(l);
}

/* CORRIGIR - SIGSEGV, Segmentation fault.*/
void st_free () {

	int i;

	for (i = 0; i < SIZE; i++){
		if (hashTable[i] != NULL){
			BucketList l = hashTable[i];
			while (l->next != NULL){
				l = l->next;
			}
			st_free_bucket(l);
		}
	}
}
