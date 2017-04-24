/****************************************************/
/* Autor: Amadeus T. Seilert						*/
/* Arquivo: scanner.l                               */
/* Arquivo de definições para o Flex, que produzirá	*/
/* o scanner para o compilador		    			*/
/****************************************************/

%{
#include "globals.h"
#include "util.h"
#include "scanner.h"
/* Lexema de um token */
char tokenString[MAXTOKENLEN + 1];
char lastTokenString[MAXTOKENLEN + 1];

%}

digit       [0-9]
number      {digit}+
letter      [a-zA-Z]
word  		{letter}+
identifier	{word}({word}|{number})*
unix_newline \n
windows_newline \r\n
mac_newline	\r
newline {unix_newline}|{windows_newline}|{mac_newline}
whitespace  [ \t]+

%option noyywrap

%%

"if"            			{return IF;}
"else"          			{return ELSE;}
"int"          				{return INT;}
"void"           			{return VOID;}
"while"        				{return WHILE;}
"return"         			{return RETURN;}

"="            				{return ASSIGN;}
"=="             			{return EQ;}
"!="             			{return DIF;}
"<"             			{return LT;}
">"             			{return GT;}
"<="             			{return LTE;}
">="             			{return GTE;}
"+"             			{return PLUS;}
"-"             			{return MINUS;}
"*"             			{return TIMES;}
"/"             			{return OVER;}
"("            				{return LPAREN;}
")"             			{return RPAREN;}
"["            				{return LBRCKT;}
"]"             			{return RBRCKT;}
"{"            				{return LBRACE;}
"}"             			{return RBRACE;}
";"             			{return SEMI;}
","             			{return COMA;}

{number}        			{return NUM;}
{identifier}			    {return ID;}
{newline}       			{lineno++;}
{whitespace}    			{/* não toma nenhuma ação */}

"/*"             			{ignore();}
<<EOF>>						{return EOF;}
.               			{printLexicalError(ERROR);}

%%

/*
Procedimento responsável por ignorar a leitura de qualquer string que estiver
entre as string de comentário.
*/
void ignore() {

	char c1 = 0, c2 = 0;

	c1 = input();

	do {
		c2 = c1;
		c1 = input();
	  	if (c1 == EOF) break;
	  	if (c1 == '\n') lineno++;
	} while (c1 != '/' && c2 != '*');
}

/*
Procedimento responsável em emitir as mensagens de erro léxico no listing.
*/
void printLexicalError(TokenType currentToken) {
	strncpy(tokenString, yytext, MAXTOKENLEN);
	printf(ANSI_COLOR_RED "Lexical Error" ANSI_COLOR_RESET " at line %d\n",lineno);
	printf("Token: %s", yytext);
	printToken(currentToken, tokenString);
	Error = TRUE;
}

/*
Função responsável pela obtenção de um token do arquivo source, caso a flag
TraceScan for TRUE, todo token identificado será impresso no listing.
*/
TokenType getToken(void){
	static int firstTime = TRUE;
  	TokenType currentToken;
  	if (firstTime) {
		firstTime = FALSE;
    	lineno++;
    	yyin = source;
    	yyout = listing;
  	}
  	currentToken = yylex();

	if (firstTime) {
		strncpy(tokenString, yytext, MAXTOKENLEN);
		strncpy(lastTokenString, tokenString, MAXTOKENLEN);
	} else {
		strncpy(lastTokenString, tokenString, MAXTOKENLEN);
		strncpy(tokenString, yytext, MAXTOKENLEN);
	}
  	if (TraceScan) {
    	fprintf(listing,"\t%d: ", lineno);
    	printToken(currentToken, tokenString);
  	}
  	return currentToken;
}
