/****************************************************/
/* Autor: Amadeus T. Seilert						*/
/* Arquivo: cgen.h		                            */
/* Interface dos procedimentos que farão a geração	*/
/* de código.										*/
/****************************************************/

#ifndef _CGEN_H_
#define _CGEN_H_

/* Definições que auxiliam na geração de código de funções. Vide Capítulo 7
do livro Compiler Construction P, K.C Louden. */

/* ofpFO = "old frame pointer frame offset". Indica o deslocamento de controle
do frame atual.*/
#define ofpFO 0
/* retFo = "return frame offset". Deslocamento do valor de retorno. */
#define retFO -1
/* initFO = "initialization frame offser". Indica o ínicio do frame, onde devem
serão armazenados os parâmetros e variáveis locais. */
#define initFO -2

 /* Procedimento que gera código a partir da árvore de sintaxe transversalmente.
 Também é passado como parâmetro o nome do arquivo que será impresso o código
 gerado. */
void codeGen(TreeNode * syntaxTree, char * codefile);

#endif
