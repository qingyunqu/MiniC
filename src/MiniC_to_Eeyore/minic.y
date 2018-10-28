%{
#include <stdio.h>

void yyerror(const char*);
%}

%union{
	int		int_value;
	char *	string_value;	
}
%token <int_value> INT_CONSTANT
%token <string_value> IDENTIFIER
%token INT
%token MAIN
%token BREAK CONTINUE ELSE IF WHILE
%token RETURN
%token OP_AND OP_OR OP_EQ OP_NE
%left '+' '-'
%left '*' '/'  //extend??
%start goal

%%

goal:
	  mainfunc	{ printf("mainfunc\n"); }
	| defn mainfunc { printf("defn mainfunc\n"); }
	;
defn:
	  { printf("defn\n");}
	| vardefn defn { printf("vardefn defn\n"); }
	| funcdefn defn { printf("funcdefn defn\n"); }
	| funcdecl defn { printf("funcdecl defn\n"); }
	| assignment defn { printf("assignment defn\n"); }
	;
vardefn:
	  type identifier ';'
	| type identifier '[' integer ']' ';'
	;
vardecl:
	  type identifier
	| type identifier '[' integer ']'
	;
funcdefn:
	  type identifier '(' paramdecl ')' '{' funccontext '}'
	;
funcdecl:
	  type identifier '(' paramdecl ')' ';'
	;
mainfunc:
	  INT MAIN '(' ')' '{' funccontext '}'
	;
paramdecl:
	  { ;}
	| vardecl
	//| vardecl ',' paramdecl   //??? multi params
	;
funccontext:
	  return
	| statement return
	;
statement:  //extend
	  assignment
	| vardefn
	| funccall
	;
funccall:
	  identifier '(' expression ')' ';' //??? multi params
	;
assignment:
	  identifier '=' expression ';'
	| identifier '[' integer ']' '=' expression ';'
	;
expression:   //??? previlege
	  expression '+' expression
	| expression '-' expression
	| expression '*' expression
	| expression '/' expression
	| expression '%' expression
	| expression OP_AND expression
	| expression OP_OR expression
	| expression '<' expression
	| expression '>' expression
	| expression OP_EQ expression
	| expression OP_NE expression
	| expression '[' expression ']'
	| integer
	| identifier
	| '!' expression
	| '-' expression
	| '(' expression ')'
	;
return:
	RETURN expression ';'
	;
type:    //? extend
	  INT
	;
integer:
	  INT_CONSTANT
	;
identifier:
	  IDENTIFIER
	;

%%
void yyerror(const char *msg)//??? line number
{
	fprintf(stderr,"Error: %s\n",msg);
}
