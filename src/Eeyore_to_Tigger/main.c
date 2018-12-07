#include <stdio.h>
#include "y.tab.h"

extern FILE*yyin;
extern FILE*yyout;

int main(int argc,char *agrv[])
{
	yyparse();
	return 0;
}
