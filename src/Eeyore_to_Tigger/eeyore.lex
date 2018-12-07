%{
#include <stdio.h>
#include "y.tab.h"
#include "linear_scan.h"

void yyerror(const char*);
int yywrap();
int lineno = 1;
%}

number [0-9]
identifier [a-zA-Z_]([a-zA-Z_0-9])*
whitespace [ \t]

%%
"//".*	{ dprintf("%s",yytext); }

"var"	{ dprintf("%s",yytext);return VAR_; }
"call"	{ dprintf("%s",yytext);return CALL_; }
"param"	{ dprintf("%s",yytext);return PARAM_; }
"return"	{ dprintf("%s",yytext);return RETURN_; }
"if"	{ dprintf("%s",yytext);return IF_; }
"goto"	{ dprintf("%s",yytext);return GOTO_; }
"end"	{ dprintf("%s",yytext);return END_; }

{number}+	{ dprintf("%s",yytext);yylval.string_value = strdup(yytext);return INT_CONSTANT_; } //sscanf(yytext,"%d",&yylval.int_value);  //???free
"T"{number}+	{ dprintf("%s",yytext);yylval.string_value = strdup(yytext);return VAR_T_; }
"t"{number}+	{ dprintf("%s",yytext);yylval.string_value = strdup(yytext);return VAR_t_; }
"p"{number}+	{ dprintf("%s",yytext);yylval.string_value = strdup(yytext);return VAR_t_; }
"l"{number}+	{ dprintf("%s",yytext);yylval.string_value = strdup(yytext);return LABEL_; }
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

.	{ 	char msg[100];
		sprintf(msg,"unknown symbol '%c'.",*yytext);
		yyerror(msg);
	}
%%
int yywrap(){
	return 1;
}
