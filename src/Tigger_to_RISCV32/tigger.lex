%{
#include <stdio.h>
#include "y.tab.h"
#include "typedefine.h"

void yyerror(const char*);
int yywrap();
int lineno = 1;
%}

number [0-9]
identifier [a-zA-Z_]([a-zA-Z_0-9])*
whitespace [ \t]

%%
"//".*	{ dprintf("%s",yytext); }

"if"	{ dprintf("%s",yytext);return IF_; }
"goto"	{ dprintf("%s",yytext);return GOTO_; }
"call"	{ dprintf("%s",yytext);return CALL_; }
"store"	{ dprintf("%s",yytext);return STORE_; }
"load"	{ dprintf("%s",yytext);return LOAD_; }
"loadaddr"	{ dprintf("%s",yytext);return LOADADDR_; }
"return"	{ dprintf("%s",yytext);return RETURN_; }
"malloc"	{ dprintf("%s",yytext);return MALLOC_; }
"end"	{ dprintf("%s",yytext);return END_; }

{number}+	{ dprintf("%s",yytext);yylval.string_value = strdup(yytext);return INTCONSTANT_; }
"v"{number}+ { dprintf("%s",yytext);yylval.string_value = strdup(yytext);return V_; }
"t"{number}+ { dprintf("%s",yytext);yylval.string_value = strdup(yytext);return R_; }
"s"{number}+ { dprintf("%s",yytext);yylval.string_value = strdup(yytext);return R_; }
"a"{number}+ { dprintf("%s",yytext);yylval.string_value = strdup(yytext);return R_; }
"x"{number}+ { dprintf("%s",yytext);yylval.string_value = strdup(yytext);return R_; }
"l"{number}+ { dprintf("%s",yytext);yylval.string_value = strdup(yytext);return LABEL_; }
"f_"{identifier}	{ dprintf("%s",yytext);yylval.string_value = strdup(yytext);return FUNC_; }

":"	{ dprintf("%s",yytext);return ':'; }

"&&"	{ dprintf("%s",yytext);return OP_AND; }
"||"	{ dprintf("%s",yytext);return OP_OR; }
"=="	{ dprintf("%s",yytext);return OP_EQ; }
"!="	{ dprintf("%s",yytext);return OP_NE; }

"!"	{ dprintf("%s",yytext);return '!'; }
"-"	{ dprintf("%s",yytext);return '-'; }
"+"	{ dprintf("%s",yytext);return '+'; }
"*"	{ dprintf("%s",yytext);return '*'; }
"/"	{ dprintf("%s",yytext);return '/'; }
"%"	{ dprintf("%s",yytext);return '%'; }
"<"	{ dprintf("%s",yytext);return '<'; }
">"	{ dprintf("%s",yytext);return '>'; }
"="	{ dprintf("%s",yytext);return '='; }
"["	{ dprintf("%s",yytext);return '['; }
"]"	{ dprintf("%s",yytext);return ']'; }

{whitespace}+	{ dprintf("%s",yytext); }
"\n"	{ dprintf("%s",yytext);lineno++; }

.	{	char msg[100];
		sprintf(msg,"unknown symbol '%c'.",*yytext);
		yyerror(msg);
	}
%%
int yywrap(){
	return 1;
}
