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
void printToken( TokenType, const char* );

/*
Esta função cria um nó do tipo statement para a construção da árvore de sintaxe.
*/
TreeNode * newStmtNode(StmtKind);

/*
Esta função cria um nó do tipo expressão para a construção da árvore de sintaxe.
*/
TreeNode * newExpNode(ExpKind);

/*
Esta função cria um nó do tipo declaração para a construção da árvore de sintaxe.
*/
TreeNode * newDeclNode(DeclK kind);

/*
Função que aloca e cria uma copia de uma string existente.
*/
char * copyString( char * );

/* procedure printTree prints a syntax tree to the
 * listing file using indentation to indicate subtrees
 */
void printTree( TreeNode * );

#endif
