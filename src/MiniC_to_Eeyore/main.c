#include <stdio.h>
#include "y.tab.h"

int main(int argc, char *argv[])
{
	if(argc != 3){
		printf("Usage: eeyore <input> <output>");
		exit(1);
	}
	freopen(argv[1],"r",stdin);
	//freopen(argv[2],'w',stdout);  // or yyin = fopen(argv[1]);
	
	yyparse();
	return 0;
}
