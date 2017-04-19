/****************************************************/
/* Autor: Amadeus T. Seilert						*/
/* Arquivo: analyze.h                               */
/* Interface para os procedimentos que farão		*/
/* análises de semântica sobre a árvore de sintaxe.	*/
/****************************************************/

#ifndef _ANALYZE_H_
#define _ANALYZE_H_

/* Procedimento que verifica tipos dos nós da árvore de sintaxe. O percurso na
árvore é definido pela transversal em pós-ordem. */
void typeCheck(TreeNode *);

/* Função que cria na tabela os símbolos pré definidos, que são as funções de
entrada e saída de um programa padrão. */
void declarePredefines();

/* Procedimento que constroi a tabela de símbolos. O percurso na árvore é
definido pela transversal em pré-ordem. */
void buildSymtab(TreeNode *);

#endif
