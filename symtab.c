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
					found = TRUE;
			} else if (scope == NULL && l->node->enclosingFunction == NULL)
				found = TRUE;
		}
		l = l->next;
	}

	if (found == TRUE)
		return l;
	else
		return NULL;
}

void st_insert (BucketList newBucket) {
	int h = hash(newBucket->node->name);
	BucketList l =  hashTable[h];

	while (l != NULL) {
		l = l->next;
	}

	l = newBucket;
}

BucketList st_allocate (TreeNode * node) {
    struct BucketListRec * temp;

    temp = (struct BucketListRec *) malloc(sizeof(BucketList));
    if (temp == NULL){
		Error = TRUE;
		fprintf(listing,
			"*** Out of memory allocating memory for symbol table\n");
    } else {
		temp->node = node;
		temp->next = NULL;
    }
    return temp;
}

/* Procedimento que imprime a tabela de símbolos no arquivo de depuração
'listing' */
void st_print () {
	int i;
	fprintf(listing,"Variable Name\tType\tScope Name\tLine Number\n");
	fprintf(listing,"----------\t------\t----------\t---\n");
	for (i=0;i<SIZE;++i) {
		if (hashTable[i] != NULL) {
			BucketList l = hashTable[i];
			while (l != NULL) {
				fprintf(listing,"%-14s ", l->node->name);
				fprintf(listing,"%-7s ", typeName(l->node->type));
				fprintf(listing,"%-14s ", scopeName(l->node->enclosingFunction));
				fprintf(listing,"%d ", l->node->lineno);
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
