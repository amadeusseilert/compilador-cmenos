#
# makefile para o compilador C-
# Amadeus T. Seilert

# CC = compilador escolhido
# CLEAN-CMD = comando de terminal que consegue deletar arquivos do SO
# CFLAGS = flags do compilador
# OBJS = objetos gerados a partir de cada módulo do compilador.

# all = regra alvo para gerar o compilador, primeiro executa-se a regra
#		parser.tab.c que invoca o Yacc/Bison para criar o parser e o cabeçalho
#		parser.tab.h. Em seguida, a regra lex.yy.c invoca o Flex, para criar o
# 		scanner. Por fim, invoca-se a regra alvo para o executável, que por sua
#		vez, necessita da compilação dos objetos definidos nas regras adiante.
#

CC = gcc

CLEAN-CMD = rm -f

CFLAGS = -g

OBJS = main.o util.o analyze.o symtab.o lex.yy.o parser.tab.o code.o cgen.o

all: parser.tab.c lex.yy.c c-compiler.exe clean

parser.tab.c: parser.y parser.h globals.h util.h scanner.h
	bison -d -v parser.y

lex.yy.c: scanner.l scanner.h globals.h util.h
	flex scanner.l

c-compiler.exe: $(OBJS)
	$(CC) $(CFLAGS) -o c-compiler $(OBJS)

main.o: main.c util.h analyze.h symtab.h globals.h parser.h scanner.h cgen.h
	$(CC) $(CFLAGS) -c main.c

util.o: util.c util.h globals.h
	$(CC) $(CFLAGS) -c util.c

symtab.o: symtab.c symtab.h util.h globals.h
	$(CC) $(CFLAGS) -c symtab.c

analyze.o: analyze.c analyze.h symtab.h util.h globals.h
	$(CC) $(CFLAGS) -c analyze.c

code.o: code.c code.h globals.h
	$(CC) $(CFLAGS) -c code.c

cgen.o: cgen.c globals.h symtab.h code.h cgen.h
	$(CC) $(CFLAGS) -c cgen.c

lex.yy.o: lex.yy.c globals.h util.h
	$(CC) $(CFLAGS) -c lex.yy.c

parser.tab.o: parser.tab.c parser.tab.h globals.h util.h scanner.h
	$(CC) $(CFLAGS) -c parser.tab.c

clean:
	$(CLEAN-CMD) parser.tab.c
	$(CLEAN-CMD) parser.tab.h
	$(CLEAN-CMD) lex.yy.c
	$(CLEAN-CMD) $(OBJS)
