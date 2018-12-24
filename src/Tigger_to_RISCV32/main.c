#include <stdio.h>
#include "y.tab.h"

extern FILE*yyin;
extern FILE*yyout;

int main(int argc,char *argv[])
{
	yyparse();
	return 0;
}
