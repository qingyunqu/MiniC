all : eeyore
eeyore : minic.lex minic.y
	lex minic.lex
	yacc -d minic.y
	gcc -o eeyore lex.yy.c y.tab.c main.c

clean :
	rm eeyore lex.yy.c y.tab.c y.tab.h

