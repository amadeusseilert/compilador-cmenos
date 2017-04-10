#
# makefile para o compilador C-
# Amadeus T. Seilert
#

CC = gcc

EXE = c-compiler

CLEAN-CMD = rm -f

CFLAGS = -Wall -g -ggdb3

OBJS = main.o util.o lex.yy.o parser.tab.o

all: parser.tab.c lex.yy.c c-compiler.exe clean

lex.yy.c: scanner.l scanner.h globals.h util.h
	flex scanner.l

parser.tab.c: parser.y parser.h globals.h util.h scanner.h
	bison -d parser.y

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
