/*
Arquivo global de cabeçalhos do módulo Scanner do Compilador C-.

Autor: Amadeus Torezam Seilert
*/

#include <stdio.h>
#include <stdlib.h>

#define MAX_ERR_BUFFER_SIZE 128

// Neste módulo que somente apresenta o Scanner como funcionalidade, é necessário definir um enumerador para os tokens existentes.
typedef enum {
    NUM, ID,
    SUM, SUB, MUL, DIV, ATR, OPR, CPR,
    EQ, GT, LT, GET, LET, DIF,
    SC, COM, OBK, CBK, OBC, CBC, OCM, CCM,
    ERR, TAB, SPC, END, LINE,
    INT, IF, ELSE, VOID, WHILE, RETURN
} Token;

/*
Esta variável será útil em mensagens de erro, pois será possivel apontar o número da linha a qual um lexema inválido for identificado.
Atenção: Embora o Flex forneça a variável yylineno, não é aconselhável exportá-la na sua gramática, pois a lógica de extração do Flex eventualmente utiliza lookahead, causando inconsistencias no valor armazenado.
*/
extern int num_line;

