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
extern FILE* code; /* Arquivo output para a C-Machine */

extern int lineno; /* Contador de linhas para listagem */

/**************************************************/
/***********   Árvore de Sintaxe 	   ************/
/**************************************************/

typedef enum {StmtK, ExpK, DeclK} NodeKind;
typedef enum {CmpdK, IfK, WhileK, AssignK, CallK, ReturnK} StmtKind;
typedef enum {OpK, ConstK, IdK} ExpKind;
typedef enum {VarK, FunK, ParamK} DeclKind;

/* ExpType será usado para análise semântica. Verificação de tipo. */
typedef enum {Void, Integer, Boolean} Type;

typedef enum {Simple, Array, Function} IdType;

/* Estrutura de um nó da árvore */
typedef struct treeNode {
	struct treeNode * child[MAXCHILDREN]; // nós filhos
    struct treeNode * sibling; // regras em fechamento
	struct treeNode * enclosingFunction; // última declaração de função
    int lineno; // referência do número da linha
    NodeKind nodekind; // tipo do nó

    union {
		StmtKind stmt;
		ExpKind exp;
		DeclKind decl;
	} kind; // tipo do tipo do nó

	TokenType op; // caso o nó for do tipo OpK, armazena a operação
	int val; // caso o nó for um vetor ou constante, armazena o valor
    char * name; // caso o nó for um identificador, armazena o nome
    Type type; // armazena a classificação de valor do nó
	IdType idtype; // caso o nó for um identificador
} TreeNode;

/**************************************************/
/***********   Flags para debug       ************/
/**************************************************/

/*
Esta flag define se ocorrerá a depuração do processo de análise sintática  pelo
Bison. É impresso no stdout a sequencia de estados da árvore e ações tomadas
ao longo do reconhecimento de regras.

http://dinosaur.compilertools.net/bison/bison_11.html
*/
#define DEBUG_PARSE 0

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
extern int TraceParse;

/*
TraceAnalyze = TRUE faz com que a tabela de símbolos seja impressa no arquivo
listing
*/
extern int TraceAnalyze;

/*
TraceCode = TRUE faz com que comentários sejam gerados no arquivo code conforme
o código é gerado.
*/
//extern int TraceCode;

/*
Error = TRUE todos os erros são reportados ná análise
*/

extern int Error;

/* Algumas macros para imprimir texto colorido no listing */
#define ANSI_COLOR_RED     "\x1b[31m"
#define ANSI_COLOR_GREEN   "\x1b[32m"
#define ANSI_COLOR_YELLOW  "\x1b[33m"
#define ANSI_COLOR_RESET   "\x1b[0m"
#endif
