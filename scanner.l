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
/* Lexema de um identificador ou palavra reservada */
char tokenString[MAXTOKENLEN + 1];
char * lastIdTokenString;
%}

digit       [0-9]
number      {digit}+
letter      [a-zA-Z]
word  		{letter}+
newline     \n
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
{word}({word}|{number})*    {lastIdTokenString = copyString(yytext); return ID;}
{newline}       			{lineno++;}
{whitespace}    			{/* não toma nenhuma ação */}

"/*"             			{ignore(OC);}
"*/"             			{return CC;}
<<EOF>>						{return EOF;}
.               			{printLexicalError(ERROR);}

%%

/*
Procedimento responsável por ignorar a leitura de qualquer string que estiver
entre os tokens OC ("Open Commentary") e CC ("Close Commentary").
*/
void ignore(TokenType currentToken) {

	while (currentToken != CC){
		currentToken = yylex();
	}
}

/*
Procedimento responsável em emitir as mensagens de erro léxico no listing.
*/
void printLexicalError(TokenType currentToken) {
	strncpy(tokenString, yytext, MAXTOKENLEN);
	printf(ANSI_COLOR_RED "Lexical Error" ANSI_COLOR_RESET " at line %d\n",lineno);
	printf("Token: ");
	printToken(currentToken, tokenString);
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
  	strncpy(tokenString, yytext, MAXTOKENLEN);
  	if (TraceScan) {
    	fprintf(listing,"\t%d: ", lineno);
    	printToken(currentToken, tokenString);
  	}
  	return currentToken;
}
