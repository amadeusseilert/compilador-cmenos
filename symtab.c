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

/* Executa uma busca na tabela por um nome e nome de escopo em comum. Se for
encontrado, o símbolo é retornado, caso contrário, retorna NULL. Caso scope
seja NULL, considera-se que o escopo de busca é apenas global */
BucketList st_lookup (char * name, TreeNode * scope) {
	int h = hash(name);
	BucketList l =  hashTable[h];

	while (l != NULL){
		/* Tenta encontrar um símbolo com o mesmo nome */
		if (strcmp(name, l->node->name) == 0){
			/* Verifica se o símbolo encontrado possui escopo local, e se
			o escopo passado também é local */
			if (scope != NULL && l->node->enclosingFunction != NULL) {
				/* Tenta verificar se os nomes dos escopos são iguais */
				if (strcmp(scope->name, l->node->enclosingFunction->name) == 0)
					return l;
			}
			/* Se ambos os escopos são nulos, e os nomes são iguais, significa
			que existe um símbolo em escopo global encontrado */
			else if (scope == NULL && l->node->enclosingFunction == NULL)
				return l;
		}
		l = l->next;
	}

	return NULL;
}

/* Insere um símbolo na tabela, caso a função hash retorne um bucket já ocupado,
utiliza-se a lista encadeada na posição percorrendo até uma referência livre */
void st_insert (TreeNode * node, int loc) {
	int h = hash(node->name);
	BucketList l =  hashTable[h];

	while (l != NULL) {
		l = l->next;
	}

	l = (BucketList) malloc(sizeof(struct BucketListRec));
	l->node = node;
	l->location = loc;
	l->next = hashTable[h];
	hashTable[h] = l;
}

/* Procedimento que imprime a tabela de símbolos no arquivo de depuração
'listing' */
void st_print () {
	int i;
	fprintf(listing,"Variable Name\tType\tScope Name\tLine #\tLocation\n");
	fprintf(listing,"-------------\t----\t----------\t------\t--------\n");
	for (i=0;i<SIZE;++i) {
		if (hashTable[i] != NULL) {
			BucketList l = hashTable[i];
			while (l != NULL) {
				fprintf(listing,"%-15s", l->node->name);
				fprintf(listing,"%-10s", typeName(l->node->type));
				fprintf(listing,"%-15s", scopeName(l->node->enclosingFunction));
				fprintf(listing,"%d\t", l->node->lineno);
				fprintf(listing,"%#06x", l->location);
				fprintf(listing,"\n");
				l = l->next;
			}
		}
	}
}

/* Libera a memória de um bucket da tabela */
void st_free_bucket (BucketList l) {
	l->node = NULL;
	free(l);
}

/* Libera a memória da tabela de símbolos por completo */
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
