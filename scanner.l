%{
#include "globals.h"
#include "parser.tab.h"
#define MAXTOKENLEN 256
#define HASHING	32
#define ESCOPOGLOBAL "GLOBAL"

int numLine=1;
int ultimoToken=-1;
int antesUltimoToken=-1;
int abreChaves=0;

typedef enum {int_var=INT, void_var=VOID, float_var=FLOAT, unknown} typeT;

//last var or function type
typeT ultimoTipo=unknown;

//last changed variable
Simbolo *ultimoSimbolo=NULL;

//escopo atual
char *scopeID=ESCOPOGLOBAL;

//hash table
Simbolo **tabelaSimbolos = NULL;

//case an assigment is been done
int initASG = 0;

//case an return is executed
int initRETURN = 0;

//para identificar erro semantico
int typeCheck=unknown;

//inside function
int OpenP=0;
Linha* nova_linha(int number);
void inicia_tabela();
Simbolo* novo_simbolo(char* id, int linenumber, typeT type);
void imprime_tabela_simbolos();
int hashing(char* id);
Simbolo*  mesmo_id_escopo(Simbolo* first, char* id);
Simbolo*  mesmo_id_escopo_GLOBAL(Simbolo* first, char* id);
Simbolo* ultimo_simbolo(Simbolo* first);
Simbolo* adiciona_simbolo(Simbolo* first, char* id, int linenumber, typeT type);
void id_valido(char* text);
void abre_escopo();
void check_function();
void define_tipo();
void check_void_invalido();
void check_main();
void fecha_escopo();
void check_vector();
void lex_error();


%}

digito          [0-9]
letra           [a-zA-Z]
linha           \n
tab             \t
branco          [ ]+
palavra         {letra}+
numero          {digito}+

%%

"if"                                 return IF;
"else"                               return ELSE;
"int"                                {ultimoTipo = int_var;return INT;}
"float"                              {ultimoTipo = float_var;return FLOAT;}
"while"                              return WHILE;
"void"                               {ultimoTipo = void_var;return VOID;}
"return"                             {initRETURN=1;define_tipo("RETURN");return RETURN;}

{numero}                             return NUM;
{palavra}({palavra}|{numero})*	     {id_valido(yytext);return ID;/*identifier*/}
{numero}.{numero}                    return REAL;

">"                                  return MAIOR;
"<"                                  return MENOR;
"<="                                 return MENORIGL;
">="                                 return MAIORIGL;

"+"				                     return SUM;
"-"				                     return SUB;
"*"				                     return MUL;
"/"				                     return DIV;

"="				                     {initASG=1;define_tipo("ATR");return ATR;}
"!="                                 return DIF;
"=="                                 return IGL;

";"				                     {check_void_invalido();initASG=0;initRETURN=0;typeCheck=unknown;return PEV;/*semicolon*/}
"("				                     {check_function();OpenP=1;return APR;/*open parenthesis*/}
")"				                     {OpenP=0;return FPR;/*close parenthesis*/}
"["                                  {check_void_invalido();check_vector();return ACC;/*open index*/}
"]"                                  return FCC;
"{"                                  {abreChaves+=1;return ACH;/*open block*/}
"}"                                  {abreChaves-=1;fecha_escopo();return FCH;/*close block*/}

"/*"                                 { char c1; int c2 = 0;
                                          do
                                          { c1 = input();
                                              if (c1 == EOF) break;
                                              if (c1 == '\n')
                                                numLine++;
                                      		    if (c2 == 0 && c1 == '*')
                                                c2 = 1;
                                      		    else if (c2 == 1 && c1 == '*')
                                                c2 = 1;
                                      		    else if (c2 == 1 && c1 == '/')
                                                c2 = 2;
                                      		    else
                                                c2 = 0;
                                          } while (c2 != 2);
                                     }

","                                  return VGL;

{linha}                              numLine++;
{tab}
{branco}
.			                         {lex_error();return ERR;/*error detected*/}

%%

int getToken(){//utilizado na analise sintatica(arquivo .bison)
    //printf("getToken chamado, INT %d FLOAT %d VOID %d - ultimoToken %d\n", INT, FLOAT, VOID, ultimoToken);
	int i;
	i = yylex();
	antesUltimoToken=ultimoToken;
	ultimoToken=i;
	return i;
}

//creates new line number
Linha* nova_linha(int number){
	Linha *ll = (Linha*)malloc(sizeof(Linha));
	ll->linenumber=number;
	ll->next=NULL;
	return ll;
}

void inicia_tabela(){//inicializando todas as funcoes pre-definidas(output, inputi, inputf)
	tabelaSimbolos = (Simbolo**)malloc(HASHING*sizeof(Simbolo*));
	int i;
	for(i=0;i<HASHING;++i){
		tabelaSimbolos[i]=NULL;
	}
	i = hashing("output");
	tabelaSimbolos[i] = adiciona_simbolo(tabelaSimbolos[i],"output",0,VOID);//adicionando funcao output
	Simbolo* iop = mesmo_id_escopo(tabelaSimbolos[i],"output");
	if(iop!=NULL){
		iop->isFunction = 1;
	}
	i = hashing("inputi");
	tabelaSimbolos[i] = adiciona_simbolo(tabelaSimbolos[i],"inputi",0,INT);//adicionando funcao input para inteiros
	iop = mesmo_id_escopo(tabelaSimbolos[i],"inputi");
	if(iop!=NULL){
		iop->isFunction = 1;
	}
	i = hashing("inputf");
	tabelaSimbolos[i] = adiciona_simbolo(tabelaSimbolos[i],"inputf",0,FLOAT);//adicionando funcao input para ponto flutuante
	iop = mesmo_id_escopo(tabelaSimbolos[i],"inputf");
	if(iop!=NULL){
		iop->isFunction = 1;
	}
}

//creates new variable for the table
Simbolo* novo_simbolo(char* id, int linenumber, typeT type){
	if(type==unknown){
		printf("Unkown type...\n");
	}
	Simbolo* vriable = (Simbolo*)malloc(sizeof(Simbolo));
	vriable->id=id;
	vriable->lineNumber=nova_linha(linenumber);
	vriable->type=type;
	vriable->next=NULL;
	vriable->isFunction=0;
	vriable->isVector=0;
	vriable->scope=(char*)malloc(sizeof(char)*(strlen(scopeID)+1));
	strcpy(vriable->scope,scopeID);
	return vriable;
}


//print current fields table
void imprime_tabela_simbolos(){
	Simbolo* current;
	int i;
	FILE *f;
	f = fopen("tabela.csv","w+");
	for(i=0;i<HASHING;++i){
		current=tabelaSimbolos[i];
		if(current!=NULL){
			while(current!=NULL){
				fprintf(f,"%s,",current->id);

				if(current->isFunction)
					fprintf(f,"fun,");
				else if(current->isVector)
					fprintf(f,"vet,");
				else
					fprintf(f,"var,");

				if(current->type==int_var)
					fprintf(f,"int,");
				else if(current->type==float_var)
					fprintf(f,"float,");
				else
					fprintf(f,"void,");

				fprintf(f,"%s,",current->scope);

				Linha* lines = current->lineNumber;
                fprintf(f,"{");
				while(lines!=NULL){
					if(lines->next!=NULL)
						fprintf(f,"%d ",lines->linenumber);
					else
						fprintf(f,"%d",lines->linenumber);
					lines=lines->next;
				}
				fprintf(f,"}\n");
				current=current->next;
			}
		}
	}
	fclose(f);
}

//hashing function
int hashing(char* id){
	int len = strlen(id)-1;
	int result = 0;
	while(len>=0){
		result+=(len+1)*id[len];
		len--;
	}
	return result%HASHING;
}

Simbolo*  mesmo_id_escopo(Simbolo* first, char* id){
	Simbolo* current = first;
	while(current!=NULL && current->next!=NULL){
		if(strcmp(id,current->id)==0){
			if(strcmp(current->scope,scopeID)==0 /*|| strcmp(current->scope,ESCOPOGLOBAL)==0*/){
				return current;
			}
		}
		current=current->next;
	}

	if(current!=NULL && strcmp(id,current->id)==0){
		if(strcmp(current->scope,scopeID)==0 /*|| strcmp(current->scope,ESCOPOGLOBAL)==0*/){
			return current;
		}
	}
	return NULL;
}

Simbolo*  mesmo_id_escopo_GLOBAL(Simbolo* first, char* id){
	Simbolo* current = mesmo_id_escopo(first, id);
	if(current!=NULL) return current;
	current = first;
	while(current!=NULL && current->next!=NULL){
		if(strcmp(id,current->id)==0){
			if(strcmp(current->scope,scopeID)==0 || strcmp(current->scope,ESCOPOGLOBAL)==0){
				return current;
			}
		}
		current=current->next;
	}

	if(current!=NULL && strcmp(id,current->id)==0){
		if(strcmp(current->scope,scopeID)==0 || strcmp(current->scope,ESCOPOGLOBAL)==0){
			return current;
		}
	}
	return NULL;
}

Simbolo* ultimo_simbolo(Simbolo* first){
	while(first!=NULL && first->next!=NULL){
		first=first->next;
	}
	return first;
}

Simbolo* adiciona_simbolo(Simbolo* first, char* id, int linenumber, typeT type){
	//printf("Adding variable %s %s, with line number=%d and scope=%s\n",(type==int_var?"int":"void"),id,linenumber,scopeID);
	if(first==NULL){ //there is no variable in the linked list
		first = novo_simbolo(id,linenumber,type);
	} else {//there is at least one variable in the linked list
		Simbolo *last=ultimo_simbolo(first);
		last->next = novo_simbolo(id,linenumber,type);
	}
	return first;
}

void id_valido(char* text){
	Simbolo* iop;
	int i = hashing(text);
	if(ultimoToken == INT || ultimoToken == VOID || ultimoToken == FLOAT){//add new id
		if((iop = mesmo_id_escopo_GLOBAL(tabelaSimbolos[i],text))!=NULL){
			if(iop->isFunction)
				printf("Erro semantico, declarando variavel que ja eh funcao \'%s\' na linha \'%d\'...\n",text,numLine);
			else
				printf("Erro semantico, redeclaracao de variavel \'%s\' na linha \'%d\'...\n",text,numLine);
			exit(-1);
		}
		char* id=(char*)malloc(sizeof(char)*(strlen(text)+1));
		strcpy(id,text);
		tabelaSimbolos[i] = adiciona_simbolo(tabelaSimbolos[i],id,numLine,ultimoToken);
	} else {									//add line count
		Simbolo* identifierNode = mesmo_id_escopo_GLOBAL(tabelaSimbolos[i],text);
		if(identifierNode==NULL){
			printf("Erro semantico, variavel \'%s\' usada mas nao declarada na linha \'%d\'...\n",text,numLine);
			exit(-1);
		}
		if(initASG && OpenP!=1)
			if(identifierNode->type!=typeCheck){
				printf("Erro semantico, a atribuicao de \'%s\' nao esta utilizando tipos corretos na linha \'%d\'...\n",text,numLine);
				exit(-1);
			}
		if(initRETURN && OpenP!=1)
			if(identifierNode->type!=typeCheck){
				printf("Erro semantico, o retorno de \'%s\' nao eh referente ao tipo do escopo na linha \'%d\'...\n",text,numLine);
				exit(-1);
			}

		Linha* last=identifierNode->lineNumber;
		while(last->next!=NULL){
			last=last->next;
		}
		last->next=nova_linha(numLine);
	}
	ultimoSimbolo = mesmo_id_escopo(tabelaSimbolos[i],text);
}

void abre_escopo(){
	scopeID = (char*)malloc(sizeof(char)*(strlen(ultimoSimbolo->id)+1));
	strcpy(scopeID,ultimoSimbolo->id);
}

void check_function(){
	if(ultimoToken==ID && (antesUltimoToken == INT || antesUltimoToken==VOID || antesUltimoToken==FLOAT || 1==0)){
		ultimoSimbolo->isFunction=1;
		abre_escopo();
	}
}

void define_tipo(char *s){
	if(ultimoSimbolo!=NULL)
		if(strcmp(s,"ATR")==0)
			typeCheck = ultimoSimbolo->type;
		else if(strcmp(s,"RETURN")==0){
			int i = hashing(scopeID);
			Simbolo* iop = mesmo_id_escopo_GLOBAL(tabelaSimbolos[i],scopeID);
			typeCheck = iop->type;
		}
}

void check_void_invalido(){
	if(ultimoToken==ID && antesUltimoToken==VOID){
		printf("Erro semantico, variavel \'%s\' declarada como void na linha \'%d\'...\n",ultimoSimbolo->id,numLine);
		exit(-1);
	}
}

void fecha_escopo(){
	if(abreChaves==0){
		scopeID=ESCOPOGLOBAL;
	}
}

void check_vector(){
	if(ultimoToken==ID && (antesUltimoToken==INT || antesUltimoToken==FLOAT)){
		ultimoSimbolo->isVector=1;
	}
}

void check_main(){
	int i;
	i = hashing("main");
	if(mesmo_id_escopo_GLOBAL(tabelaSimbolos[i],"main")==NULL){//this will return once
		printf("Erro semantico, funcao main nao foi declarada...\n");
		exit(-1);
	}
}

void lex_error(){
	printf("Erro lexico\n\ttoken: \'%s\'\n\tlinha: %d\nAbortando...\n",yytext,numLine);
	exit(0);
}
