/****************************************************/
/* File: tiny.l                                     */
/* Lex specification for TINY                       */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/

%{
#include "globals.h"
#include "util.h"
/* lexeme of identifier or reserved word */
char tokenString[MAXTOKENLEN+1];
%}

digit       [0-9]
number      {digit}+
letter      [a-zA-Z]
word  		{letter}+
newline     \n
whitespace  [ \t]+

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
{word}({word}|{number})*    {return ID;}
{newline}       			{lineno++;}
{whitespace}    			{/* skip whitespace */}

"/*"             			{ignore(OC);}
"*/"             			{return CC;}
.               			{lexicalError(ERROR);}

%%

void ignore (TokenType currentToken) {

	while (currentToken != CC){
		currentToken = yylex();
	}
}

void lexicalError (TokenType currentToken) {
	strncpy(tokenString, yytext, MAXTOKENLEN);
	fprintf(listing, "Syntax error at line %d\n",lineno);
	fprintf(listing, "Token: ");
	printToken(currentToken, tokenString);
}

TokenType getToken (void) {
	TokenType currentToken;
  	currentToken = yylex();
  	strncpy(tokenString, yytext, MAXTOKENLEN);
  	if (TraceScan) {
    	fprintf(listing, "\t%d: ", lineno);
    	printToken(currentToken, tokenString);
  	}
  	return currentToken;
}
