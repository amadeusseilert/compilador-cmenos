/****************************************************/
/* Autor: Amadeus T. Seilert						*/
/* Arquivo: parser.h                                */
/* Interface para o arquivo parser.y       			*/
/****************************************************/

#ifndef _PARSE_H_
#define _PARSE_H_

/*
Função responsável em emitir as mensagens de erro de sintaxe no listing.
*/
int yyerror (char * message);

/*
Esta função invoca a função getToken para criar um output do Yacc/Bison
compatível com versões mais antigas do Lex.
*/
static int yylex (void);

/*
Esta função inicia a análise e constroi a árvore de sintaxe.
 */
TreeNode * parse(void);

#endif
