/****************************************************/
/* Autor: Amadeus T. Seilert						*/
/* Arquivo: scanner.h                               */
/* Interface para o arquivo scanner.l   			*/
/****************************************************/

#ifndef _SCAN_H_
#define _SCAN_H_

/* Tamanho máximo que um token pode comportar */
#define MAXTOKENLEN 40

/* Lexema de um identificador ou palavra reservada */
extern char tokenString[MAXTOKENLEN+1];
/*
Procedimento responsável por ignorar a leitura de qualquer string que estiver
entre os tokens OC ("Open Commentary") e CC ("Close Commentary").
*/
void ignore (TokenType currentToken);
/*
Procedimento responsável em emitir as mensagens de erro léxico no listing.
*/
void printLexicalError (TokenType currentToken);

/*
Função responsável pela obtenção de um token do arquivo source, caso a flag
TraceScan for TRUE, todo token identificado será impresso no listing.
*/
TokenType getToken(void);

#endif
