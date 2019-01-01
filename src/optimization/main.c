#include <stdio.h>
#include "typedefine.h"

FILE* optimize_in;
FILE* optimize_out;

int main(int argc,char *agrv[])
{
	optimize_in = stdin;
	optimize_out = stdout;
	optimize();
	return 0;
}
