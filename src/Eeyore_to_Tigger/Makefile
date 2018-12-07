all : tigger
tigger : eeyore.lex eeyore.y main.c gen_tigger.c
	lex eeyore.lex
	yacc -d eeyore.y
	gcc -o tigger lex.yy.c y.tab.c main.c gen_tigger.c

clean :
	rm tigger lex.yy.c y.tab.c y.tab.h

