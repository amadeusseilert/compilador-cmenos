/****************************************************/
/* Autor: Amadeus T. Seilert						*/
/* Arquivo: symtab.c                                */
/* Implementação da tabela de símbolos do 			*/
/* compilador C-.									*/
/****************************************************/

#include "globals.h"
#include "symtab.h"
#include "util.h"


/* Escopo global */
Scope globalScope;
/* Armazena todos os escopos identificados na  análise semântica */
static Scope scopes[MAX_SCOPE];
/* Quantidade total de escopos econtrados */
static int nScope = 0;
/* Pilha que armazena o aninhamento de escopos. O escopo começa na base da
pilha */
static Scope scopeStack[MAX_SCOPE];
/* Quantidade de escopos na pilha scopeStack */
static int nScopeStack = 0;
/* Armazena os contadores de localizações de memória virtual de cada escopo.
Cada novo escopo começa com o valor 0x0 */
static int location[MAX_SCOPE];

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

void sc_init( void ){
	int i;
	for (i = 0; i < MAX_SCOPE; i++){
		scopes[i] = NULL;
		scopeStack[i] = NULL;
	}
}

/* Retorna o escopo no topo da pilha de escopos */
Scope sc_top( void ){
	return scopeStack[nScopeStack - 1];
}

/* Desempilha o topo da pilha */
void sc_pop( void ){
  	--nScopeStack;
}

/* Retorna a localização mais alta do escopo no topo da pilha */
int sc_location( void ){
  	return location[nScopeStack - 1]++;
}

/* Empilha um escopo na pilha */
void sc_push( Scope scope ){
	scopeStack[nScopeStack] = scope;
  	location[nScopeStack++] = 0;
}

Scope sc_find(char * funcName){
	int i;
	for (i = 0; i < MAX_SCOPE; i++){
		Scope temp = scopes[i];
		if (strcmp(temp->name, funcName) == 0)
			return temp;
	}

	return NULL;
}

/* Cria um novo escopo a partir de um nome de uma função ou procedimento */
Scope sc_create(char * funcName){
	int i;
	Scope newScope;

  	newScope = (Scope) malloc(sizeof(struct ScopeRec));
  	newScope->name = funcName;
  	newScope->nestedLevel = nScopeStack;
  	newScope->parent = sc_top();

	for (i = 0; i < SIZE; i++)
		newScope->hashTable[i] = NULL;

  	scopes[nScope++] = newScope;
  	return newScope;
}

 /* Busca pela posição na memória de um símbolo em todos os escopos */
int st_lookup ( char * name ){
	BucketList l = st_bucket(name);
  	if (l != NULL)
		return l->location;
  	return -1;
}

int st_lookup_top (char * name){
	int h = hash(name);
	Scope sc = sc_top();
	if (sc){
		BucketList l = sc->hashTable[h];
		while ((l != NULL) && (strcmp(name,l->node->name) != 0))
	  		l = l->next;
		if (l != NULL)
			return l->location;
	}
	return -1;
}

/* Executa uma busca na tabela por um nome em todos os escopos. Se for
encontrado, o símbolo é retornado, caso contrário, retorna NULL.*/
BucketList st_bucket (char * name) {
	int h = hash(name);
	Scope sc = sc_top();
	while(sc) {
		BucketList l = sc->hashTable[h];

		while ((l != NULL) && (strcmp(name, l->node->name) != 0))
	  		l = l->next;
		if (l != NULL)
			return l;
		sc = sc->parent;
	}
	return NULL;
}

/* Executa uma busca na tabela por um nome em no escopo no topo da pilha. Se for
encontrado, o símbolo é retornado, caso contrário, retorna NULL.*/
BucketList st_bucket_top (char * name) {
	int h = hash(name);
	Scope sc = sc_top();

	if (sc != NULL){
		BucketList l = sc->hashTable[h];

		while ((l != NULL) && (strcmp(name, l->node->name) != 0))
	  		l = l->next;
		if (l != NULL)
			return l;
	}
	return NULL;
}

/* Insere um símbolo na tabela, caso a função hash retorne um bucket já ocupado,
utiliza-se a lista encadeada na posição percorrendo até uma referência livre */
void st_insert (TreeNode * node, int loc) {
	int h = hash(node->name);
	Scope top = sc_top();

	BucketList l =  top->hashTable[h];

	while (l != NULL)
    	l = l->next;

	if (l == NULL){
		l = (BucketList) malloc(sizeof(struct BucketListRec));
		l->node = node;
		l->location = loc;
		l->next = top->hashTable[h];
		top->hashTable[h] = l;
	}
}

/* Procedimento que imprime a tabela de símbolos no arquivo de depuração
'listing' */
void st_print () {
	int i, j;

	for (i = 0; i < nScope; i++){
		Scope scope = scopes[i];
		BucketList * hashTable = scope->hashTable;
		fprintf(listing, "Scope: <%s> - Nested level: %d\n", scope->name, scope->nestedLevel);
		fprintf(listing,"-----------------------------------------------\n");
		fprintf(listing,"       Name        Type       Line #   Location\n");
		fprintf(listing,"-----------------------------------------------\n");
		for (j = 0; j < SIZE; ++j) {
			if (hashTable[j] != NULL) {
				BucketList l = hashTable[j];
				while (l != NULL) {
					fprintf(listing,"(%s) ", declKindName(l->node->kind.decl));
					fprintf(listing,"%-13s", l->node->name);
					fprintf(listing,"%-11s", typeName(l->node->type));
					fprintf(listing,"%.4d%-5s%#06x", l->node->lineno," ", l->location);
					fprintf(listing,"\n");
					l = l->next;
				}
			}
		}
		fprintf(listing,"-----------------------------------------------\n");

	}
}
