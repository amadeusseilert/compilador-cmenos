#
# makefile para o compilador C-
# Amadeus T. Seilert

# CC = compilador escolhido
# EXE = nome do executável para o compilador
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

EXE = c-compiler

CLEAN-CMD = rm -f

CFLAGS = -Wall

OBJS = main.o util.o lex.yy.o parser.tab.o

all: parser.tab.c lex.yy.c c-compiler.exe clean

parser.tab.c: parser.y parser.h globals.h util.h scanner.h
	bison -d parser.y

lex.yy.c: scanner.l scanner.h globals.h util.h
	flex scanner.l

c-compiler.exe: $(OBJS)
	$(CC) $(CFLAGS) -o $(EXE) $(OBJS)

main.o: main.c util.h globals.h parser.h scanner.h
	$(CC) $(CFLAGS) -c main.c

util.o: util.c util.h globals.h
	$(CC) $(CFLAGS) -c util.c

lex.yy.o: lex.yy.c globals.h util.h
	$(CC) $(CFLAGS) -c lex.yy.c

parser.tab.o: parser.tab.c parser.tab.h globals.h util.h scanner.h
	$(CC) $(CFLAGS) -c parser.tab.c

clean:
	$(CLEAN-CMD) util.o
	$(CLEAN-CMD) lex.yy.o
	$(CLEAN-CMD) parser.tab.o
	$(CLEAN-CMD) parser.tab.c
	$(CLEAN-CMD) parser.tab.h
	$(CLEAN-CMD) lex.yy.c
	$(CLEAN-CMD) main.o
