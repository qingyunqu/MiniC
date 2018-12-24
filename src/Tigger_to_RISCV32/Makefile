all : riscv
riscv : tigger.lex tigger.y main.c
	lex tigger.lex
	yacc -d tigger.y
	gcc -o riscv32 lex.yy.c y.tab.c main.c

clean :
	rm riscv32 lex.yy.c y.tab.c y.tab.h
