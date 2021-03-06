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


"//".*		{dprintf(stderr,"%s",yytext);} //single line comment

"break"		{ return BREAK; } // wait to realize
"continue"	{ return CONTINUE; } // wait to realize
"else"		{ dprintf(stderr,"else");return ELSE; }
"int" 		{ dprintf(stderr,"int");return INT; }
"if"		{ dprintf(stderr,"if");return IF; }
"main"		{ dprintf(stderr,"main");return MAIN; }
"return"	{ dprintf(stderr,"return");return RETURN; }
"while"		{ dprintf(stderr,"while");return WHILE; }

{number}+		{ dprintf(stderr,"%s",yytext);sscanf(yytext,"%d",&yylval.int_value); return INT_CONSTANT; } //???judge yytext is a legal digit
{identifier} 	{ dprintf(stderr,"%s",yytext);yylval.string_value = strdup(yytext); return IDENTIFIER; }//???check type  ???free

"&&"	{ dprintf(stderr,"&&");return OP_AND; }
"||"	{ dprintf(stderr,"||");return OP_OR; }
"=="	{ dprintf(stderr,"==");return OP_EQ; }
"!="	{ dprintf(stderr,"!=");return OP_NE; }

"!"	{ dprintf(stderr,"!");return '!'; }
"-"	{ dprintf(stderr,"-");return '-'; }
"+"	{ dprintf(stderr,"+");return '+'; }
"*"	{ dprintf(stderr,"*");return '*'; }
"/"	{ dprintf(stderr,"/");return '/'; }
"%"	{ dprintf(stderr,"%%");return '%'; }
"<"	{ dprintf(stderr,"<");return '<'; }
">"	{ dprintf(stderr,">");return '>'; }
"="	{ dprintf(stderr,"=");return '='; }
"["	{ dprintf(stderr,"[");return '['; }
"]"	{ dprintf(stderr,"]");return ']'; }

"{"	{ dprintf(stderr,"{");return '{'; }
"}"	{ dprintf(stderr,"}");return '}'; }
"("	{ dprintf(stderr,"(");return '('; }
")"	{ dprintf(stderr,")");return ')'; }
";"	{ dprintf(stderr,";");return ';'; }
"," { dprintf(stderr,",");return ','; }

{whitespace}+ 	{dprintf(stderr,"%s",yytext);}
"\n"	{ dprintf(stderr,"\n");lineno++; }

.	{ 	char msg[100];
		sprintf(msg,"unknown symbol '%c'.",*yytext);
		yyerror(msg); 
	}
%%

int yywrap()
{
	return 1;
}
