%{
#include <stdio.h>
#include "y.tab.h"
//#include "typedefine.h"

void yyerror(const char*);
int yywrap();
//extern TreeNode* node;
//extern int nodecnt;

int lineno = 1; 
%}

number	[0-9]
letter 	[a-zA-Z]
identifier	[a-zA-Z_]([a-zA-Z_0-9])*
whitespace	[ \t]

%%


"//".*		{fprintf(stderr,"%s",yytext);} //single line comment

"break"		{ return BREAK; } // wait to realize
"continue"	{ return CONTINUE; } // wait to realize
"else"		{ fprintf(stderr,"else");return ELSE; }
"int" 		{ fprintf(stderr,"int");return INT; }
"if"		{ fprintf(stderr,"if");return IF; }
"main"		{ fprintf(stderr,"main");return MAIN; }
"return"	{ fprintf(stderr,"return");return RETURN; }
"while"		{ fprintf(stderr,"while");return WHILE; }

{number}+		{ fprintf(stderr,"%s",yytext);sscanf(yytext,"%d",&yylval.int_value); return INT_CONSTANT; } //???judge yytext is a legal digit
{identifier} 	{ fprintf(stderr,"%s",yytext);yylval.string_value = strdup(yytext); return IDENTIFIER; }//???check type  ???free

"&&"	{ fprintf(stderr,"&&");return OP_AND; }
"||"	{ fprintf(stderr,"||");return OP_OR; }
"=="	{ fprintf(stderr,"==");return OP_EQ; }
"!="	{ fprintf(stderr,"!=");return OP_NE; }

"!"	{ fprintf(stderr,"!");return '!'; }
"-"	{ fprintf(stderr,"-");return '-'; }
"+"	{ fprintf(stderr,"+");return '+'; }
"*"	{ fprintf(stderr,"*");return '*'; }
"/"	{ fprintf(stderr,"/");return '/'; }
"%"	{ fprintf(stderr,"%%");return '%'; }
"<"	{ fprintf(stderr,"<");return '<'; }
">"	{ fprintf(stderr,">");return '>'; }
"="	{ fprintf(stderr,"=");return '='; }
"["	{ fprintf(stderr,"[");return '['; }
"]"	{ fprintf(stderr,"]");return ']'; }

"{"	{ fprintf(stderr,"{");return '{'; }
"}"	{ fprintf(stderr,"}");return '}'; }
"("	{ fprintf(stderr,"(");return '('; }
")"	{ fprintf(stderr,")");return ')'; }
";"	{ fprintf(stderr,";");return ';'; }
"," { fprintf(stderr,",");return ','; }

{whitespace}+ 	{fprintf(stderr,"%s",yytext);}
"\n"	{ fprintf(stderr,"\n");lineno++; }

.	{ 	char msg[100];
		sprintf(msg,"unknown symbol '%c'.",*yytext);
		yyerror(msg); 
	}
%%

int yywrap()
{
	return 1;
}
