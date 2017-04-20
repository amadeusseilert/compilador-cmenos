/****************************************************/
/* Autor: Amadeus T. Seilert						*/
/* Arquivo: scanner.h                               */
/* Interface para o arquivo scanner.l   			*/
/****************************************************/

#ifndef _SCAN_H_
#define _SCAN_H_

/* Tamanho máximo que um token pode comportar */
#define MAXTOKENLEN 128

/* Lexema de um token */
extern char tokenString[MAXTOKENLEN + 1];
extern char lastTokenString[MAXTOKENLEN + 1];
/*
Procedimento responsável por ignorar a leitura de qualquer string que estiver
entre as string de comentário.
*/
void ignore ();
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
