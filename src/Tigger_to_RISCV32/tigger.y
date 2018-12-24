%{
#include <stdio.h>
#include <string.h>
#include "typedefine.h"

extern int lineno;
extern FILE*yyout;
void yyerror(const char*);
int yylex(void);

int begin_gen_flag = 0;
int text_flag = 0;

int stk = 0;//stack size
%}
%code requires{
#include "typedefine.h"
}
%union{
	char *	string_value;
}
%token <string_value> INTCONSTANT_ V_ R_ LABEL_ FUNC_
%token IF_ GOTO_ CALL_ STORE_ LOAD_ LOADADDR_ RETURN_ MALLOC_ END_
%token OP_AND OP_OR OP_EQ OP_NE
%type <string_value> variable integer reg

%start goal

%%

goal:
	
	| decl
	;
decl:
	  globalvardecl
	| functiondecl
	| decl globalvardecl
	| decl functiondecl
	;
globalvardecl:
	  variable '=' integer	{ int integer;
							  sscanf($3,"%d",&integer);
							  riscprintf("\t.global\t%s\n",$1);
							  riscprintf("\t.section\t.sdata\n");
							  riscprintf("\t.align\t2\n");
							  riscprintf("\t.type\t%s,@object\n",$1);
							  riscprintf("\t.size\t%s,4\n",$1);
							  riscprintf("%s:\n",$1);
							  riscprintf("\t.word\t%d\n",integer); }
	| variable '=' MALLOC_ integer	{ int integer;
							  		  sscanf($4,"%d",&integer);
							  		  riscprintf("\t.comm\t%s,%d,4\n",$1,integer*4); }
	;
functiondecl:
	  functionbegin expressions functionend
	;
functionbegin:
	  FUNC_ '[' integer ']' '[' integer ']'	{ int integer2;
											  sscanf($6,"%d",&integer2);
											  stk = (integer2/4+1)*16;
											  riscprintf("\t.text\n");
											  riscprintf("\t.align\t2\n");
											  riscprintf("\t.global\t%s\n",&$1[2]);
											  riscprintf("\t.type\t%s,@function\n",&$1[2]);
											  riscprintf("%s:\n",&$1[2]);
											  riscprintf("\taddi\tsp,sp,-%d\n",stk);
											  riscprintf("\tsw\tra,%d(sp)\n",stk-4); }
	;
functionend:
	  END_ FUNC_	{ riscprintf("\t.size\t%s,.-%s\n",&$2[2],&$2[2]); }
	;
expressions:
	  
	| expression
	| expressions expression
	;
expression:
	  op2_expression
	| reg '=' '!' reg	{ riscprintf("\tsnez\t%s,%s\n",$1,$4);
						  riscprintf("\tsnez\t%s,%s\n",$1,$1); }
	| reg '=' '-' reg	{ riscprintf("\tneg\t%s,%s\n",$1,$4); } //pseudo sub rd,x0,rs
	| reg '=' reg		{ riscprintf("\tmv\t%s,%s\n",$1,$3); }
	| reg '=' integer	{ riscprintf("\tli\t%s,%s\n",$1,$3); }	//pseudo addi rd,x0,imm
	| reg '[' integer ']' '=' reg	{ riscprintf("\tsw\t%s,%s(%s)\n",$6,$3,$1); }//
	| reg '=' reg '[' integer ']'	{ riscprintf("\tlw\t%s,%s(%s)\n",$1,$5,$3); }//
	| if_expression
	| GOTO_ LABEL_		{ riscprintf("\tj\t.%s\n",$2); }
	| LABEL_ ':'		{ riscprintf(".%s:\n",$1); }
	| CALL_ FUNC_		{ riscprintf("\tcall\t%s\n",&$2[2]); }
	| STORE_ reg integer	{ int integer;
							  sscanf($3,"%d",&integer);
							  riscprintf("\tsw\t%s,%d(sp)\n",$2,integer*4); }
	| LOAD_ integer reg		{ int integer;
							  sscanf($2,"%d",&integer);
							  riscprintf("\tlw\t%s,%d(sp)\n",$3,integer*4); }
	| LOAD_ variable reg	{ riscprintf("\tlui\t%s,%%hi(%s)\n",$3,$2);
							  riscprintf("\tlw\t%s,%%lo(%s)(%s)\n",$3,$2,$3); }
	| LOADADDR_ integer reg	{ int integer;
							  sscanf($2,"%d",&integer);
							  riscprintf("\taddi\t%s,sp,%d\n",$3,integer*4); }
	| LOADADDR_ variable reg	{ riscprintf("\tlui\t%s,%%hi(%s)\n",$3,$2);
								  riscprintf("\tadd\t%s,%s,%%lo(%s)\n",$3,$3,$2); }
	| RETURN_	{ riscprintf("\tlw\tra,%d(sp)\n",stk-4);
				  riscprintf("\taddi\tsp,sp,%d\n",stk);
				  riscprintf("\tjr\tra\n"); }
	;
op2_expression:
	  reg '=' reg '+' integer	{ riscprintf("\taddi\t%s,%s,%s\n",$1,$3,$5); }
	| reg '=' reg '<' integer	{ riscprintf("\tslti\t%s,%s,%s\n",$1,$3,$5); }
	| reg '=' reg '+' reg	{ riscprintf("\tadd\t%s,%s,%s\n",$1,$3,$5); }
	| reg '=' reg '-' reg	{ riscprintf("\tsub\t%s,%s,%s\n",$1,$3,$5); }
	| reg '=' reg '*' reg	{ riscprintf("\tmul\t%s,%s,%s\n",$1,$3,$5); }
	| reg '=' reg '/' reg	{ riscprintf("\tdiv\t%s,%s,%s\n",$1,$3,$5); }
	| reg '=' reg '%' reg	{ riscprintf("\trem\t%s,%s,%s\n",$1,$3,$5); }
	| reg '=' reg '<' reg	{ riscprintf("\tslt\t%s,%s,%s\n",$1,$3,$5); }
	| reg '=' reg '>' reg	{ riscprintf("\tsgt\t%s,%s,%s\n",$1,$3,$5); }
	| reg '=' reg OP_AND reg	{ riscprintf("\tseqz\t%s,%s\n",$1,$3);
								  riscprintf("\tadd\t%s,%s,-1\n",$1,$1);
								  riscprintf("\tand\t%s,%s,%s\n",$1,$1,$5);
								  riscprintf("\tsnez\t%s,%s\n",$1,$1); }
	| reg '=' reg OP_OR reg	{ riscprintf("\tor\t%s,%s,%s\n",$1,$3,$5);
							  riscprintf("\tsnez\t%s,%s\n",$1,$1); }
	| reg '=' reg OP_EQ reg	{ riscprintf("\txor\t%s,%s,%s\n",$1,$3,$5);
							  riscprintf("\tseqz\t%s,%s\n",$1,$1); }
	| reg '=' reg OP_NE reg	{ riscprintf("\txor\t%s,%s,%s\n",$1,$3,$5);
							  riscprintf("\tsnez\t%s,%s\n",$1,$1); }
	;
if_expression:
	  IF_ reg OP_AND reg GOTO_ LABEL_ //{ riscprintf("\t
	| IF_ reg OP_OR reg GOTO_ LABEL_  //
	| IF_ reg OP_EQ reg GOTO_ LABEL_  { riscprintf("\tbeq\t%s,%s,.%s\n",$2,$4,$6); }
	| IF_ reg OP_NE reg GOTO_ LABEL_  { riscprintf("\tbne\t%s,%s,.%s\n",$2,$4,$6); }
	| IF_ reg '<' reg GOTO_ LABEL_	  { riscprintf("\tblt\t%s,%s,.%s\n",$2,$4,$6); }
	| IF_ reg '>' reg GOTO_ LABEL_	  { riscprintf("\tbgt\t%s,%s,.%s\n",$2,$4,$6); }
	;
variable:
	  V_	{ $$ = $1; }
	;
reg:
	  R_	{ $$ = $1; }
	;
integer:
	  INTCONSTANT_	{ $$ = $1; }
	;

%%

void yyerror(const char *msg){
	fprintf(stderr,"Error: line %d %s\n",lineno,msg);
}
