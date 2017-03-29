#
# makefile para o compilador C-
# GCC
# Amadeus T. Seilert
#

CC = gcc

CFLAGS =

OBJS = util.o symtab.o lex.yy.o analyze.o parser.tab.o

parser.tab.c: parser.y parser.h globals.h util.h scanner.h
	bison -d -v -g parser.y

lex.yy.c: scanner.l scanner.h globals.h util.h
	flex scanner.l

util.o: util.c util.h globals.h
	$(CC) $(CFLAGS) util.c

symtab.o: symtab.c symtab.h
	$(CC) $(CFLAGS) symtab.c

lex.yy.o: lex.yy.c globals.h
	$(CC) $(CFLAGS) lex.yy.c

analyze.o: analyze.c globals.h symtab.h analyze.h
	$(CC) $(CFLAGS) -c analyze.c

parser.tab.o: parser.tab.c parser.tab.h globals.h util.h scanner.h
	gcc -c parser.tab.c

main.exe: $(OBJS)
	$(CC) $(CFLAGS) -o main $(OBJS)

clean:
	-del util.o
	-del symtab.o
	-del lex.yy.o
	-del analyze.o
	-del parser.tab.o
	-del parser.tab.c
	-del parser.tab.h
	-del lex.yy.c
