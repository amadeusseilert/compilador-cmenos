/*
Arquivo de definições dos tokens do módulo Scanner do Compilador C-.

Autor: Amadeus Torezam Seilert
*/

%{
//Cabeçalho global
#include "globals.h"

int num_line = 1;

%}

digit		[0-9]
letter      [a-zA-Z]
line        \n
tab         \t
empty       [ ]+
word  	    {letter}+
number      {digit}+

%%

"if"                                 	return IF;
"else"                               	return ELSE;
"int"                                	return INT;
"while"                              	return WHILE;
"void"                               	return VOID;
"return"                             	return RETURN;

{number}                             	return NUM;
{word}({word}|{number})*	     	 	return ID;

">"                                  	return GT;
"<"                                  	return LT;
"<="                                 	return LET;
">="                                 	return GET;

"+"				                     	return SUM;
"-"				                     	return SUB;
"*"				                     	return MUL;
"/"				                     	return DIV;

"="				                     	return ATR;
"!="                                 	return DIF;
"=="                                 	return EQ;

";"				                     	return SC;
"("				                     	return OPR;
")"				                     	return CPR;
"["                                  	return OBK;
"]"                                  	return CBK;
"{"                                  	return OBC;
"}"                                  	return CBC;

"/*"                                 	return OCM;
"*/"                                 	return CCM;
","                                  	return COM;

{line}                              	return LINE;
{tab}                                   return TAB;
{empty}                                 return SPC;
<<EOF>>                 	          	return END;
.			                         	return ERR;

%%

/*
Procedimento para consumir o arquivo de input quando encontrar um token de inicio de comentário.
Para de ignorar quando encontra o token de fim de comentário ou o fim do arquivo.

@arg token: Token reconhecido.
*/
void ignore ( Token token ){
    while( token != CCM ){
        token = yylex();
    }
}

/*
Procedimento que imprime mensagens de erro léxico.

@arg token: Token reconhecido.
*/
void print_lexical_error (Token token){
    char *err;
	err = (char *) malloc (MAX_ERR_BUFFER_SIZE * sizeof(char));
    while (token == ERR){
        char *s = yytext;
        strcat(err, s);
        token = yylex();
    }
    printf("Lexical error: '%s' at line: %d\n", err, num_line);
}

int main ( int argc, char *argv[] ) {

    Token token;

    FILE *input, *output;

    input = fopen(argv[1],"r");
    if (input != NULL)
    yyin = input;

    output = fopen("scan-result.txt", "w+");
    if (output != NULL)
    yyout = output;

    while( (token = yylex()) != END ){
        switch( token ){
            case NUM:   fprintf(yyout, "NUM");
                        break;
            case ID:    fprintf(yyout, "ID");
                        break;
            case SUM:   fprintf(yyout, "SUM");
                        break;
            case SUB:   fprintf(yyout, "MIN");
                        break;
            case MUL:   fprintf(yyout, "MUL");
                        break;
            case DIV:   fprintf(yyout, "DIV");
                        break;
            case ATR:   fprintf(yyout, "ATR");
                        break;
            case OPR:   fprintf(yyout, "OPR");
                        break;
            case CPR:   fprintf(yyout, "CPR");
                        break;
            case EQ: 	fprintf(yyout, "EQ");
                        break;
            case GT: 	fprintf(yyout, "GT");
                        break;
            case LT:    fprintf(yyout, "LT");
                        break;
            case GET:   fprintf(yyout, "GET");
                        break;
            case LET:   fprintf(yyout, "LET");
                        break;
            case DIF:   fprintf(yyout, "DIF");
                        break;
            case SC:    fprintf(yyout, "SC");
                        break;
            case COM:   fprintf(yyout, "COM");
                        break;
            case OBC:   fprintf(yyout, "OBC");
                        break;
            case CBC:   fprintf(yyout, "CBC");
                        break;
            case OBK:   fprintf(yyout, "OBK");
                        break;
            case CBK:   fprintf(yyout, "CBK");
                        break;
            case OCM:   ignore(token);
                        break;
            case END:   break;

            case ERR:   print_lexical_error(token);
                        break;
            case INT:   fprintf(yyout, "INT");
                        break;
            case IF:    fprintf(yyout, "IF");
                        break;
            case ELSE:  fprintf(yyout, "ELSE");
                        break;
            case VOID:  fprintf(yyout, "VOID");
                        break;
            case WHILE: fprintf(yyout, "WHILE");
                        break;
            case RETURN: fprintf(yyout, "RETURN");
                        break;
            case SPC:   fprintf(yyout, " ");
                        break;
            case TAB: fprintf(yyout, "\t");
                        break;
            case LINE: num_line++; fprintf(yyout, "\n");
                        break;
            }
        }
    return 0;
}
