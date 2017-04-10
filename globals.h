/****************************************************/
/* Autor: Amadeus T. Seilert						*/
/* Arquivo: globals.h                               */
/* Interface global para o compilador. Aqui são		*/
/* incluídos as bibliotecas padrões e as definições	*/
/* gerais do compilador.				       		*/
/****************************************************/

#ifndef _GLOBALS_H_
#define _GLOBALS_H_

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

/*
Yacc/Bison gera internamente seus próprios valores para os tokens (usualmete
valores inteiros);. Outros arquivos podem acessar estes valores pela inclusão
do cabeçalho 'tab.h' gerado pela opção '-d' ("gerar cabeçalho") no ato de
invocação do Yacc/Bison.

Definir a flag YYPARSER previne a inclusão do 'tab.h' dentro dos próprios
arquivos output do Yacc/Bison.
*/
#ifndef YYPARSER

/*
Cabeçalho gerado a partir do 'parser.y'. Este cabeçalho vai permitir que os
valores dos tokens possuam visibilidade global.
*/
#include "parser.tab.h"

#endif

/* Definições auxiliares*/
#ifndef FALSE
#define FALSE 0
#endif

#ifndef TRUE
#define TRUE 1
#endif

/* Número máximo de palavras reservadas na gramática*/
#define MAXRESERVED 6
/* Número máximo de filhos que um nó da árvore de sintaxe pode ter*/
#define MAXCHILDREN 3

/* Definir um nome para os valores inteiros que o Yacc/Bison atribuir aos
tokens*/
typedef int TokenType;

extern FILE* source; /* Código fonte, arquivo de entrada */
extern FILE* listing; /* Arquivo para listagem e debug */
//extern FILE* code; /* Arquivo output para a C-Machine */

extern int lineno; /* Contador de linhas para listagem */

/**************************************************/
/***********   Árvore de Sintaxe 	   ************/
/**************************************************/

typedef enum {StmtK, ExpK, DeclK} NodeKind;
typedef enum {IfK, WhileK, AssignK, ReturnK} StmtKind;
typedef enum {OpK, ConstK, IdK} ExpKind;
typedef enum {VarK, FunK, ParamK} DeclKind;

/* ExpType será usado para análise semântica. Verificação de tipo. */
typedef enum {Void, Integer, Boolean} ExpType;

typedef enum {Simple, Array, Function, None} IdType;

/* Estrutura de um nó da árvore */
typedef struct treeNode {
	struct treeNode * child[MAXCHILDREN];
    struct treeNode * sibling;
    int lineno;
    NodeKind nodekind;

    union {
		StmtKind stmt;
		ExpKind exp;
		DeclK decl;
	} kind;

	TokenType op;
	int val;
    char * name;
    ExpType type;
	IdType idtype;
   } TreeNode;

/**************************************************/
/***********   Flags para debug       ************/
/**************************************************/

/*
EchoSource = TRUE faz com que o arquivo de entrada seja impresso no arquivo
listing com a numeração de linhas durante a análise sintática.
*/
//extern int EchoSource;

/*
TraceScan = TRUE faz com que os tokens identidicados durante o scan sejam
impressos no arquivo listing.
*/
extern int TraceScan;

/*
TraceParse = TRUE faz com que a árvore de sintaxe seja impressa no arquivo
listing na forma linear (utilizando identação para os filhos)
*/
//extern int TraceParse;

/*
TraceAnalyze = TRUE faz com que a tabela de símbolos seja impressa no arquivo
listing
*/
//extern int TraceAnalyze;

/*
TraceCode = TRUE faz com que comentários sejam gerados no arquivo code conforme
o código é gerado.
*/
//extern int TraceCode;

/*
Error = TRUE todos os erros são reportados ná análise
*/

extern int Error;
#endif
