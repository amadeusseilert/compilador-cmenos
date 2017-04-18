/****************************************************/
/* Autor: Amadeus T. Seilert						*/
/* Arquivo: analyse.h                               */
/* Interface para os procedimentos que farão		*/
/* análises de semântica sobre a árvore de sintaxe.	*/
/****************************************************/

#ifndef _ANALYZE_H_
#define _ANALYZE_H_

extern int hasMain;

/* Procedimento que constroi a tabela de símbolos. O percurso na árvore é
definido pela transversal em pré-ordem. */
void buildSymtab(TreeNode *);

/* Procedimento que verifica tipos dos nós da árvore de sintaxe. O percurso na
árvore é definido pela transversal em pós-ordem. */
void typeCheck(TreeNode *);

#endif
