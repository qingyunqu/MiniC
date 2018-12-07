%{
#include <stdio.h>
#include <string.h>
#include "linear_scan.h"

extern int lineno;
extern FILE*yyout;
void yyerror(const char*);
int yylex(void);

void gen_tigger();

int smtcnt = 0;
EeyoreSMT smt[MAXEEYORESMT];// should judge smtcnt < MAXEEYORESMT

%}
%code requires{
#include "linear_scan.h"
}
%union{
	int 	int_value;
	char *	string_value;
	OP1Type	OP1Type_value;
	OP2Type OP2Type_value;
}
//%token <int_value> 
%token <string_value> FUNC_ VAR_T_ VAR_t_ LABEL_ INT_CONSTANT_
%token VAR_ CALL_ PARAM_ RETURN_ IF_ GOTO_ END_
%token OP_AND OP_OR OP_EQ OP_NE
%type <string_value> variable rightvalue
%type <OP2Type_value> op2
%type <OP1Type_value> op1

%start goal

%%

goal:
	  { gen_tigger(smt,smtcnt); }
	| decl { gen_tigger(smt,smtcnt); }
	;
decl:
	  vardecl
	| funcdecl
	| decl vardecl
	| decl funcdecl
	;
vardecl:
	  VAR_ VAR_T_ {	smt[smtcnt].type = VAR;
					smt[smtcnt].lineno = smtcnt+1;
					sprintf(smt[smtcnt].attr[0],"%s",$2);
					smtcnt++; }
	| VAR_ VAR_t_ { smt[smtcnt].type = VAR;
					smt[smtcnt].lineno = smtcnt+1;
					sprintf(smt[smtcnt].attr[0],"%s",$2);
					smtcnt++; }
	| VAR_ INT_CONSTANT_ VAR_T_ {	smt[smtcnt].type = VART;
									smt[smtcnt].lineno = smtcnt+1;
									sprintf(smt[smtcnt].attr[0],"%s",$2);
									sprintf(smt[smtcnt].attr[1],"%s",$3);
									smtcnt++; }
//	| VAR_ INT_CONSTANT_ VAR_t_ { }
	;
funcdecl:
	  funcbegin funccontext funcend
	;
funcbegin:
	  FUNC_ '[' INT_CONSTANT_ ']' {	smt[smtcnt].type = F_BEGIN;
									smt[smtcnt].lineno = smtcnt+1;
									sprintf(smt[smtcnt].attr[0],"%s",$1);
									sprintf(smt[smtcnt].attr[1],"%s",$3);
									smtcnt++; }
	;
funcend:
	  END_ FUNC_ {	smt[smtcnt].type = F_END;
					smt[smtcnt].lineno = smtcnt+1;
					sprintf(smt[smtcnt].attr[0],"%s",$2);
					smtcnt++; }
	;
funccontext:
	  
	| statement
	| funccontext statement
	;
statement:
	  vardecl
	| LABEL_ ':' {  smt[smtcnt].type = LABEL;
					smt[smtcnt].lineno = smtcnt+1;
					sprintf(smt[smtcnt].attr[0],"%s",$1);
					smtcnt++; }
	| variable '=' rightvalue op2 rightvalue {	smt[smtcnt].type = OP2;
												smt[smtcnt].lineno = smtcnt+1;
												smt[smtcnt].op.op2 = $4;
												sprintf(smt[smtcnt].attr[0],"%s",$1);
												sprintf(smt[smtcnt].attr[1],"%s",$3);
												sprintf(smt[smtcnt].attr[2],"%s",$5);
												smtcnt++; }
	| variable '=' op1 rightvalue {	smt[smtcnt].type = OP1;
									smt[smtcnt].lineno = smtcnt+1;
									smt[smtcnt].op.op1 = $3;
									sprintf(smt[smtcnt].attr[0],"%s",$1);
									sprintf(smt[smtcnt].attr[1],"%s",$4);
									smtcnt++; }
	| variable '=' rightvalue {	smt[smtcnt].type = ASSIGN;
								smt[smtcnt].lineno = smtcnt+1;  //???why???
								sprintf(smt[smtcnt].attr[0],"%s",$1);
								sprintf(smt[smtcnt].attr[1],"%s",$3);
								smtcnt++; }
	| variable '[' rightvalue ']' '=' rightvalue {	smt[smtcnt].type = ASSIGN_LEFT;
													smt[smtcnt].lineno = smtcnt+1;
													sprintf(smt[smtcnt].attr[0],"%s",$1);
													sprintf(smt[smtcnt].attr[1],"%s",$3);
													sprintf(smt[smtcnt].attr[2],"%s",$6);
													smtcnt++; }
	| variable '=' variable '[' rightvalue ']' {	smt[smtcnt].type = ASSIGN_RIGHT;
													smt[smtcnt].lineno = smtcnt+1;
													sprintf(smt[smtcnt].attr[0],"%s",$1);
													sprintf(smt[smtcnt].attr[1],"%s",$3);
													sprintf(smt[smtcnt].attr[2],"%s",$5);
													smtcnt++; }
	| IF_ rightvalue OP_EQ rightvalue GOTO_ LABEL_ {	smt[smtcnt].type = IF;
														smt[smtcnt].lineno = smtcnt+1;
														sprintf(smt[smtcnt].attr[0],"%s",$2);
														sprintf(smt[smtcnt].attr[1],"%s",$4);
														sprintf(smt[smtcnt].attr[2],"%s",$6);
														smtcnt++; }  // only == 0
	| GOTO_ LABEL_ {	smt[smtcnt].type = GOTO;
						smt[smtcnt].lineno = smtcnt+1;
						sprintf(smt[smtcnt].attr[0],"%s",$2);
						smtcnt++; }
	| PARAM_ rightvalue {	smt[smtcnt].type = PARAM;
							smt[smtcnt].lineno = smtcnt+1;
							sprintf(smt[smtcnt].attr[0],"%s",$2);
							smtcnt++; }
	| variable '=' CALL_ FUNC_ {	smt[smtcnt].type = CALL;
									smt[smtcnt].lineno = smtcnt+1;
									sprintf(smt[smtcnt].attr[0],"%s",$1);
									sprintf(smt[smtcnt].attr[1],"%s",$4);
									smtcnt++; }
	| CALL_ FUNC_ {	smt[smtcnt].type = CALL_S;
					smt[smtcnt].lineno = smtcnt+1;
					sprintf(smt[smtcnt].attr[0],"%s",$2);
					smtcnt++; }
	| RETURN_ rightvalue {	smt[smtcnt].type = RETURN;
							smt[smtcnt].lineno = smtcnt+1;
							sprintf(smt[smtcnt].attr[0],"%s",$2);
							smtcnt++; }
	;
op2:
	  OP_AND { $$ = AND; }
	| OP_OR { $$ = OR; }
	| OP_EQ { $$ = EQ; }
	| OP_NE { $$ = NE; }
	| '+' { $$ = ADD; }
	| '-' { $$ = MINUS; }
	| '*' { $$ = MULTI; }
	| '/' { $$ = DIV; }
	| '%' { $$ = MOD; }
	| '<' { $$ = LESS; }
	| '>' { $$ = GREATER; }
	;
op1:
	  '!' { $$ = ZERO; }
	| '-' { $$ = NEG; }
	;
variable:
	  VAR_T_ { $$ = $1; }
	| VAR_t_ { $$ = $1; }
	;
rightvalue:
	  variable { $$ = $1; }
	| INT_CONSTANT_ { $$ = $1; }
	;
%%

/*void gen_tigger(){
	//print_smt();
}*/
void yyerror(const char *msg){
	fprintf(stderr,"Error: line %d %s\n",lineno,msg);
}
