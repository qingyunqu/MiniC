%{
#include <stdio.h>

#define __DEBUG__
#ifdef __DEBUG__
#define dprintf(format,...)  printf(format,##__VA_ARGS__)
#else
#define dprintf(format,...)
#endif

extern int lineno;
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
%left '*' '/' '%'  //extend??
%start goal

%%

goal:
	  mainfunc	{ dprintf("mainfunc\n"); }
	| defn mainfunc { dprintf("defn mainfunc\n"); }
	;
defn:
	  vardefn { dprintf("vardefn\n");}
	| funcdefn {dprintf("funcdefn\n");}
	| funcdecl {dprintf("funcdecl\n");}
	| assignment {dprintf("assignment\n");}
	| defn vardefn { dprintf("defn vardefn\n"); }
	| defn funcdefn { dprintf("defn funcdefn\n"); }
	| defn funcdecl { dprintf("defn funcdecl\n"); }
	| defn assignment { dprintf("defn assignment\n"); }
	;
vardefn:
	  type identifier ';' {dprintf("vardefn 1\n");}
	| type identifier '[' integer ']' ';' {dprintf("vardefn 2\n");}
	;
funcdefn:
	  type identifier '(' paramdecl ')' '{' funccontext '}' {dprintf("funcdefn\n");}
	;
funcdecl:
	  type identifier '(' paramdecl ')' ';' {dprintf("funcdecl\n");}
	;
mainfunc:
	  type MAIN '(' ')' '{' funccontext '}' {dprintf("mainfunc\n");}
	;
paramdecl:
	  
	| vardecl
	| paramdecl ',' vardecl
	;
vardecl:
	  type identifier
	| type identifier '[' integer ']'
	;
funccontext:
	  {dprintf("funccontext 1\n");}
	| statements {dprintf("funccontext 2\n");}
	;
statements:
	  statement {dprintf("statements 1\n");}
	| statements statement {dprintf("statements 2\n");}
	;
statement:  //extend
	  '{' '}'
	| '{' statements '}'
	| IF '(' expression ')' statement    { dprintf("if statement\n");}
	| IF '(' expression ')' statement ELSE statement { dprintf("if else statement\n");}
	| WHILE '(' expression ')' statement
	| assignment
	| vardefn
	| return
	| funcdecl  // against to BNF?
	| funccall  
	;
funccall:
	  identifier '(' callparam ')' ';'  {dprintf("funccall\n");}
	;
assignment:
	  identifier '=' expression ';' {dprintf("assignment 1\n");}
	| identifier '[' expression ']' '=' expression ';' {dprintf("assignment 2\n");}
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
	| expression '[' expression ']'   // what's this?
	| integer
	| identifier
	| '!' expression
	| '-' expression
	| '(' expression ')'
	| identifier '(' callparam ')'
	;
callparam:
	  
	| expression
	| callparam ',' expression 
	;
return:
	RETURN expression ';'
	;
type:    //can be extended
	  INT
	;
integer:
	  INT_CONSTANT
	;
identifier:
	  IDENTIFIER
	;

%%
void yyerror(const char *msg)
{
	fprintf(stderr,"Error: line %d %s\n",lineno,msg);
}
