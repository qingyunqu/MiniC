%{
#include <stdio.h>
#include "y.tab.h"

void yyerror(const char*);
int yywrap();
int lineno = 1; 
%}

number	[0-9]
letter 	[a-zA-Z]
identifier	[a-zA-Z_]([a-zA-Z_0-9])*
whitespace	[ \t]

%%

"//".*		;//single line comment

"break"		{ return BREAK; }
"continue"	{ return CONTINUE; }
"else"		{ return ELSE; }
"int" 		{ return INT; }
"if"		{ return IF; }
"main"		{ return MAIN; }
"return"	{ return RETURN; }
"while"		{ return WHILE; }

{number}+		{ sscanf(yytext,"%d",&yylval.int_value); return INT_CONSTANT; } //???judge yytext is a legal digit
{identifier} 	{ yylval.string_value = strdup(yytext); return IDENTIFIER; }//???check type

"&&"	{ return OP_AND; }
"||"	{ return OP_OR; }
"=="	{ return OP_EQ; }
"!="	{ return OP_NE; }

"!"	{ return '!'; }
"-"	{ return '-'; }
"+"	{ return '+'; }
"*"	{ return '*'; }
"/"	{ return '/'; }
"%"	{ return '%'; }
"<"	{ return '<'; }
">"	{ return '>'; }
"="	{ return '='; }

"{"	{ return '{'; }
"}"	{ return '}'; }
"["	{ return '['; }
"]"	{ return ']'; }
"("	{ return '('; }
")"	{ return ')'; }
";"	{ return ';'; }
"," { return ','; }

{whitespace}+ 	;//whitespace
"\n"	{ lineno++; }

.	{ 	char msg[100];
		sprintf(msg,"unknown symbol '%c'.",*yytext);
		yyerror(msg); 
	}
%%

int yywrap()
{
	return 1;
}
