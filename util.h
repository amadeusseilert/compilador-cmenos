/****************************************************/
/* Autor: Amadeus T. Seilert						*/
/* Arquivo: util.h                                	*/
/* Interface das funções de utilidade do 			*/
/* compilador       								*/
/****************************************************/

#ifndef _UTIL_H_
#define _UTIL_H_

/*
Procedimento que imprime um token e seu lexema no arquivo listitng
*/
void printToken(TokenType, const char* );

/*
Esta função cria um nó da árvore de sintaxe.
*/
TreeNode * newNode();

/*
Função que aloca e cria uma copia de uma string existente.
*/
char * copyString(char * );

/* Procedimento para imprimir um nó do tipo var ou param */
void printVarParamId(TreeNode * tree);

/* Procedimento para imprimir um nó do tipo param */
void printParamId(TreeNode * tree);

/* Procedimento para imprimir um nó do tipo function */
void printFunctionId(TreeNode * tree);

/* procedure printTree prints a syntax tree to the
 * listing file using indentation to indicate subtrees
 */
void printTree(TreeNode * );

#endif
