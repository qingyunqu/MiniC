#include <stdio.h>
#include "y.tab.h"
#include <stdlib.h>

extern FILE*yyin;

int main(int argc, char *argv[])
{
	if(argc < 2){
		printf("Usage: eeyore <input> <output>");
		exit(1);
	}
	FILE* fp1 = fopen(argv[1],"r");
	//freopen(argv[1],"r",stdin);
	//freopen(argv[2],'w',stdout);
	
	yyin = fp1;
	
	yyparse();
	return 0;
}
