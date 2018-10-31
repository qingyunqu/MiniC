%{
#include <stdio.h>
#include <string.h>
//#include "typedefine.h"

extern int lineno;
extern FILE*yyout;
void yyerror(const char*);
int yylex(void);
void gen_eeyore();

int nodecnt = 0;
%}
%code requires{
#include "typedefine.h"
TreeNode* root;
TreeNode node[MAXTREENODE];
void insert(TreeNode*f,TreeNode*c);
}
%union{
	int		int_value;
	char *	string_value;
	TreeNode * node_value;
}
%token <int_value> INT_CONSTANT
%token <string_value> IDENTIFIER
%token INT
%token MAIN
%token BREAK CONTINUE ELSE IF WHILE
%token RETURN
%token OP_AND OP_OR OP_EQ OP_NE
%type <node_value> integer identifier expression callparam funccall goal mainfunc defn vardefn funcdecl assignment funcdefn paramdecl vardecl funccontext statements statement
%left OP_AND OP_OR
%left OP_EQ OP_NE
%left '<' '>'
%left '+' '-'
%left '*' '/' '%'
//%right
%start goal

%%

goal:
	  mainfunc	{ 	node[nodecnt].nodekind = GOAL;
					node[nodecnt].childcnt = 0;
					$$ = &node[nodecnt++];
					insert($$,$1);
					root = $$;
					gen_eeyore(); }
	| defn mainfunc { 	node[nodecnt].nodekind = GOAL;
						node[nodecnt].childcnt = 0;
						$$ = &node[nodecnt++];
						insert($$,$1);
						insert($$,$2);
						root = $$;
						gen_eeyore();}
	;
defn:
	  vardefn { node[nodecnt].nodekind = DEFN;   //
				node[nodecnt].childcnt = 0;
				$$ = &node[nodecnt++];
				insert($$,$1); }
	| funcdefn {node[nodecnt].nodekind = DEFN;
				node[nodecnt].childcnt = 0;
				$$ = &node[nodecnt++];
				insert($$,$1);}
	| funcdecl {node[nodecnt].nodekind = DEFN;
				node[nodecnt].childcnt = 0;
				$$ = &node[nodecnt++];
				insert($$,$1);}
	| assignment {	node[nodecnt].nodekind = DEFN;   //
					node[nodecnt].childcnt = 0;
					$$ = &node[nodecnt++];
					insert($$,$1);}
	| defn vardefn { insert($$,$2); }
	| defn funcdefn { insert($$,$2); }
	| defn funcdecl { insert($$,$2);}
	| defn assignment { insert($$,$2); }
	;
vardefn:
	  type identifier ';' { node[nodecnt].nodekind = VARDEFN;
							node[nodecnt].childcnt = 0;
							$$ = &node[nodecnt++];
							insert($$,$2);}
	| type identifier '[' integer ']' ';' { node[nodecnt].nodekind = VARDEFN;
											node[nodecnt].childcnt = 0;
											$$ = &node[nodecnt++];
											insert($$,$2);
											insert($$,$4);
											}
	;
funcdefn:
	  type identifier '(' paramdecl ')' '{' funccontext '}' {	node[nodecnt].nodekind = FUNCDEFN;
																node[nodecnt].childcnt = 0;
																$$ = &node[nodecnt++];
																insert($$,$2);
																insert($$,$4);
																insert($$,$7);
																}
	;
funcdecl:
	  type identifier '(' paramdecl ')' ';' {	node[nodecnt].nodekind = FUNCDECL;
												node[nodecnt].childcnt = 0;
												$$ = &node[nodecnt++];
												insert($$,$2);
												insert($$,$4);
												}
	;
assignment:
	  identifier '=' integer ';' {	node[nodecnt].nodekind = ASSIGNMENT;
									node[nodecnt].childcnt = 0;
									$$ = &node[nodecnt++];
									insert($$,$1);
									insert($$,$3);
									}
	| identifier '[' integer ']' '=' integer ';' {	node[nodecnt].nodekind = ASSIGNMENT;
													node[nodecnt].childcnt = 0;
													$$ = &node[nodecnt++];
													insert($$,$1);
													insert($$,$3);
													insert($$,$6);
													}
	;
mainfunc:
	  type MAIN '(' ')' '{' funccontext '}' {	node[nodecnt].nodekind = MAINFUNC;
												node[nodecnt].childcnt = 0;
												$$ = &node[nodecnt++];
												insert($$,$6);
												}
	;
paramdecl:
	  { node[nodecnt].nodekind = PARAMDECL;
		node[nodecnt].childcnt = 0;
		$$ = &node[nodecnt++]; }
	| vardecl {	node[nodecnt].nodekind = PARAMDECL;
				node[nodecnt].childcnt = 0;
				$$ = &node[nodecnt++];
				insert($$,$1); }
	| paramdecl ',' vardecl { insert($$,$3); }
	;
vardecl:
	  type identifier { node[nodecnt].nodekind = VARDECL;
						node[nodecnt].childcnt = 0;
						$$ = &node[nodecnt++];
						insert($$,$2); }
	| type identifier '[' integer ']' { node[nodecnt].nodekind = VARDECL;
										node[nodecnt].childcnt = 0;
										$$ = &node[nodecnt++];
										insert($$,$2);
										insert($$,$4);}
	;
funccontext:
	  {	node[nodecnt].nodekind = FUNCCONTEXT;
		node[nodecnt].childcnt = 0;
		$$ = &node[nodecnt++];}
	| statements { 	node[nodecnt].nodekind = FUNCCONTEXT;
					node[nodecnt].childcnt = 0;
					$$ = &node[nodecnt++];
					insert($$,$1);}
	;
statements:
	  statement { 	node[nodecnt].nodekind = STATEMENTS;
					node[nodecnt].childcnt = 0;
					$$ = &node[nodecnt++];
					insert($$,$1);}
	| statements statement {insert($$,$2);}
	;
statement:  //extend
	  '{' '}' { node[nodecnt].nodekind = STMT;
				node[nodecnt].kind.stmt = kong;
				$$ = &node[nodecnt++];}
	| '{' statements '}' {  node[nodecnt].nodekind = STMT;
							node[nodecnt].kind.stmt = statements_;
							$$ = &node[nodecnt++];
							insert($$,$2); }
	| IF '(' expression ')' statement {	node[nodecnt].nodekind = STMT;
										node[nodecnt].kind.stmt = if_;
										$$ = &node[nodecnt++];
										insert($$,$3);
										insert($$,$5);	}
	| IF '(' expression ')' statement ELSE statement { 	node[nodecnt].nodekind = STMT;
														node[nodecnt].kind.stmt = if_else;
														$$ = &node[nodecnt++];	
														insert($$,$3);
														insert($$,$5);
														insert($$,$7);}
	| WHILE '(' expression ')' statement {	node[nodecnt].nodekind = STMT;
											node[nodecnt].kind.stmt = while_;
											$$ = &node[nodecnt++];
											insert($$,$3);
											insert($$,$5); }
	| identifier '=' expression ';' {	node[nodecnt].nodekind = STMT;
										node[nodecnt].kind.stmt = assign1;
										$$ = &node[nodecnt++];
										insert($$,$1);
										insert($$,$3);}
	| identifier '[' expression ']' '=' expression ';' {	node[nodecnt].nodekind = STMT;
															node[nodecnt].kind.stmt = assign2;
															$$ = &node[nodecnt++];
															insert($$,$1);
															insert($$,$3);
															insert($$,$6);}
	| vardefn { node[nodecnt].nodekind = STMT;
				node[nodecnt].kind.stmt = vardefn_;
				$$ = &node[nodecnt++];
				insert($$,$1);}
	| RETURN expression ';'  {	node[nodecnt].nodekind = STMT;
				node[nodecnt].kind.stmt = return_;
				$$ = &node[nodecnt++];
				insert($$,$2);}
	| funcdecl  // against to BNF?
	| funccall {	node[nodecnt].nodekind = STMT;
					node[nodecnt].kind.stmt  = funccall_;
					$$ = &node[nodecnt++];
					insert($$,$1);}
	;
funccall:
	  identifier '(' callparam ')' ';'  { 	node[nodecnt].nodekind = FUNCCALL;
											$$ = &node[nodecnt++];
											insert($$,$1);
											insert($$,$3); }
	;

expression:   //??? previlege  //??child count
	  expression '+' expression {	node[nodecnt].nodekind = EXP;
									node[nodecnt].kind.exp = add;
									$$ = &node[nodecnt++];
									insert($$,$1);
									insert($$,$3); }
	| expression '-' expression {	node[nodecnt].nodekind = EXP;
									node[nodecnt].kind.exp = minus;
									$$ = &node[nodecnt++];
									insert($$,$1);
									insert($$,$3); }
	| expression '*' expression {	node[nodecnt].nodekind = EXP;
									node[nodecnt].kind.exp = multiply;
									$$ = &node[nodecnt++];
									insert($$,$1);
									insert($$,$3); }
	| expression '/' expression	{	node[nodecnt].nodekind = EXP;
									node[nodecnt].kind.exp = divide;
									$$ = &node[nodecnt++];
									insert($$,$1);
									insert($$,$3); }
	| expression '%' expression {	node[nodecnt].nodekind = EXP;
									node[nodecnt].kind.exp = mod;
									$$ = &node[nodecnt++];
									insert($$,$1);
									insert($$,$3); }
	| expression OP_AND expression {node[nodecnt].nodekind = EXP;
									node[nodecnt].kind.exp = op_and;
									$$ = &node[nodecnt++];
									insert($$,$1);
									insert($$,$3); }
	| expression OP_OR expression {	node[nodecnt].nodekind = EXP;
									node[nodecnt].kind.exp = op_or;
									$$ = &node[nodecnt++];
									insert($$,$1);
									insert($$,$3); }
	| expression '<' expression	{	node[nodecnt].nodekind = EXP;
									node[nodecnt].kind.exp = op_less;
									$$ = &node[nodecnt++];
									insert($$,$1);
									insert($$,$3); }
	| expression '>' expression {	node[nodecnt].nodekind = EXP;
									node[nodecnt].kind.exp = op_greater;
									$$ = &node[nodecnt++];
									insert($$,$1);
									insert($$,$3); }
	| expression OP_EQ expression {	node[nodecnt].nodekind = EXP;
									node[nodecnt].kind.exp = op_eq;
									$$ = &node[nodecnt++];
									insert($$,$1);
									insert($$,$3); }
	| expression OP_NE expression {	node[nodecnt].nodekind = EXP;
									node[nodecnt].kind.exp = op_ne;
									$$ = &node[nodecnt++];
									insert($$,$1);
									insert($$,$3); }
//	| expression '[' expression ']'   // what's this?
	| expression '[' expression ']' {	node[nodecnt].nodekind = EXP;
										node[nodecnt].kind.exp =  op_index;
										$$ = &node[nodecnt++];
										insert($$,$1);
										insert($$,$3); }
	| integer { /*node[nodecnt].nodekind = EXP;
				node[nodecnt].kind.exp = integer;
				$$ = &node[nodecnt++];
				insert($$,$1); }*/
				$1->nodekind = EXP;
				$1->kind.exp = integer;
				$$ = $1; }
	| identifier { 	/*node[nodecnt].nodekind = EXP;
					node[nodecnt].kind.exp = identifier;
					$$ = &node[nodecnt++];
					insert($$,$1); }*/
					$1->nodekind = EXP;
					$1->kind.exp = identifier;
					$$ = $1; }
	| '!' expression { 	node[nodecnt].nodekind = EXP;
						node[nodecnt].kind.exp = op_judge;
						$$ = &node[nodecnt++];
						insert($$,$2); }
	| '-' expression { 	node[nodecnt].nodekind = EXP;
						node[nodecnt].kind.exp = op_neg;
						$$ = &node[nodecnt++];
						insert($$,$2); }
	| '(' expression ')' {	node[nodecnt].nodekind = EXP;
							node[nodecnt].kind.exp = bracket;
							$$ = &node[nodecnt++];
							insert($$,$2); }
	| identifier '(' callparam ')' {	node[nodecnt].nodekind = EXP;
										node[nodecnt].kind.exp = funccall;
										$$ = &node[nodecnt++];
										insert($$,$1);
										insert($$,$3); }
	;
callparam:
	  {	node[nodecnt].nodekind = CALLP;
		node[nodecnt].childcnt = 0;
		$$ = &node[nodecnt++];	}
	| expression {	node[nodecnt].nodekind = CALLP;
					node[nodecnt].childcnt = 0;
					$$ = &node[nodecnt++];
					insert($$,$1); }
	| callparam ',' expression { insert($$,$3); } //maybe error?
	;
type:    //can be extended
	  INT { ;}
	;
integer:
	  INT_CONSTANT { 	node[nodecnt].nodekind = NUM;
						node[nodecnt].attr.val = $1;
						$$ = &node[nodecnt++];}
						//dprintf("integer nodecnt: %d\n",nodecnt-1); }
	;
identifier:
	  IDENTIFIER {	node[nodecnt].nodekind  = IDEN;
					node[nodecnt].attr.name = $1;
					$$ = &node[nodecnt++];}
					//dprintf("identifier nodecnt: %d\n",nodecnt-1); }
	;

%%
void insert(TreeNode*f,TreeNode*c){
	f->child[f->childcnt++] = c;
}

typedef enum SymType{
	func_global,
	var_global,
	var_local,
	param_decl,
	int_type,
	var_type, //t
}SymType;
#define SYMNAMELEN 50
typedef struct SymTab{
	char name[SYMNAMELEN];
	SymType type;
	int num;   //T%d for var, param%d for func
}SymTab;
SymTab symtab[1000];
char dfs_state[20];
void set_state(char* s){
	sprintf(dfs_state,"%s",s);
}
int Tcnt,tcnt,lcnt,symcnt;
void insert_symtab(char* identifier,SymType type,int num){
	symtab[symcnt].type = type;
	symtab[symcnt].num = num;
	sprintf(symtab[symcnt++].name,"%s",identifier);
}
void print_symtab(){
	//fprintf(stderr,"\n");
	for(int i=0;i<symcnt;i++){
		if(symtab[i].type == var_global){
			fprintf(stderr,"%s var_global T%d\n",symtab[i].name,symtab[i].num);
		}
		if(symtab[i].type == func_global){
			fprintf(stderr,"%s func_global param%d\n",symtab[i].name,symtab[i].num);
		}
		if(symtab[i].type == param_decl){
			fprintf(stderr,"%s func_param p%d\n",symtab[i].name,symtab[i].num);
		}
		if(symtab[i].type == var_local){
			fprintf(stderr,"%s var_local T%d\n",symtab[i].name,symtab[i].num);
		}
	}
}
SymTab *look_symtab(char* identifier){
	for(int i=0;i<symcnt;i++){
		if(strcmp(symtab[i].name,identifier)==0){
			return &symtab[i];
		}
	}
	return NULL;
}

void yyout_exp(SymType type,int ret){
	switch(type){
		case int_type:
			fprintf(yyout,"%d",ret);
			break;
		case var_global:
			fprintf(yyout,"T%d",ret);
			break;
		case var_local:
			fprintf(yyout,"T%d",ret);
			break;
		case param_decl:
			fprintf(yyout,"p%d",ret);
			break;
		case var_type:
			fprintf(yyout,"t%d",ret);
			break;
		case func_global:
			fprintf(yyout,"call f_");
			break;
		default:
			break;
	}
}
void dfs(TreeNode*p);
SymType rettype;
int dfs_exp(TreeNode*p){
	int t,tt,ret,ret1,ret2;
	SymType type,type1,type2;
	SymTab *tab = NULL;
	char symname[SYMNAMELEN];
	switch(p->kind.exp){
		case op_index:
			fprintf(yyout,"var t%d\n",tcnt++);
			t = tcnt - 1;
			fprintf(yyout,"var t%d\n",tcnt++);
			tt = tcnt - 1;
			ret1 = dfs_exp(p->child[0]);  //expression [ expression ] ?
			type1 = rettype;
			ret2 = dfs_exp(p->child[1]);
			type2 = rettype;
			fprintf(yyout,"t%d = 4 * ",tt);
			yyout_exp(type2,ret2);
			fprintf(yyout,"\n");
			fprintf(yyout,"t%d = ",t);
			yyout_exp(type1,ret1);
			fprintf(yyout,"[");
			//yyout_exp(type2,ret2);
			fprintf(yyout,"t%d",tt);
			fprintf(yyout,"]\n");
			rettype = var_type;
			return t;
			break;
		case op_and:
			fprintf(yyout,"var t%d\n",tcnt++);
			t = tcnt-1;
			ret1 = dfs_exp(p->child[0]);
			type1 = rettype;
			ret2 = dfs_exp(p->child[1]);
			type2 = rettype;
			fprintf(yyout,"t%d = ",t);
			yyout_exp(type1,ret1);
			fprintf(yyout,"&&");
			yyout_exp(type2,ret2);
			fprintf(yyout,"\n");
			rettype = var_type;
			return t;
			break;
		case op_or:
			fprintf(yyout,"var t%d\n",tcnt++);
			t = tcnt-1;
			ret1 = dfs_exp(p->child[0]);
			type1 = rettype;
			ret2 = dfs_exp(p->child[1]);
			type2 = rettype;
			fprintf(yyout,"t%d = ",t);
			yyout_exp(type1,ret1);
			fprintf(yyout," || ");
			yyout_exp(type2,ret2);
			fprintf(yyout,"\n");
			rettype = var_type;
			return t;
			break;
		case op_less:
			fprintf(yyout,"var t%d\n",tcnt++);
			t = tcnt-1;
			ret1 = dfs_exp(p->child[0]);
			type1 = rettype;
			ret2 = dfs_exp(p->child[1]);
			type2 = rettype;
			fprintf(yyout,"t%d = ",t);
			yyout_exp(type1,ret1);
			fprintf(yyout," < ");
			yyout_exp(type2,ret2);
			fprintf(yyout,"\n");
			rettype = var_type;
			return t;
			break;
		case op_greater:
			fprintf(yyout,"var t%d\n",tcnt++);
			t = tcnt-1;
			ret1 = dfs_exp(p->child[0]);
			type1 = rettype;
			ret2 = dfs_exp(p->child[1]);
			type2 = rettype;
			fprintf(yyout,"t%d = ",t);
			yyout_exp(type1,ret1);
			fprintf(yyout," > ");
			yyout_exp(type2,ret2);
			fprintf(yyout,"\n");
			rettype = var_type;
			return t;
			break;
		case op_eq:
			fprintf(yyout,"var t%d\n",tcnt++);
			t = tcnt-1;
			ret1 = dfs_exp(p->child[0]);
			type1 = rettype;
			ret2 = dfs_exp(p->child[1]);
			type2 = rettype;
			fprintf(yyout,"t%d = ",t);
			yyout_exp(type1,ret1);
			fprintf(yyout," == ");
			yyout_exp(type2,ret2);
			fprintf(yyout,"\n");
			rettype = var_type;
			return t;
			break;
		case op_ne:
			fprintf(yyout,"var t%d\n",tcnt++);
			t = tcnt-1;
			ret1 = dfs_exp(p->child[0]);
			type1 = rettype;
			ret2 = dfs_exp(p->child[1]);
			type2 = rettype;
			fprintf(yyout,"t%d = ",t);
			yyout_exp(type1,ret1);
			fprintf(yyout," != ");
			yyout_exp(type2,ret2);
			fprintf(yyout,"\n");
			rettype = var_type;
			return t;
			break;
		case add:
			fprintf(yyout,"var t%d\n",tcnt++);
			t = tcnt-1;
			ret1 = dfs_exp(p->child[0]);
			type1 = rettype;
			ret2 = dfs_exp(p->child[1]);
			type2 = rettype;
			fprintf(yyout,"t%d = ",t);
			yyout_exp(type1,ret1);
			fprintf(yyout," + ");
			yyout_exp(type2,ret2);
			fprintf(yyout,"\n");
			rettype = var_type;
			return t;
			break;
		case minus:
			fprintf(yyout,"var t%d\n",tcnt++);
			t = tcnt-1;
			ret1 = dfs_exp(p->child[0]);
			type1 = rettype;
			ret2 = dfs_exp(p->child[1]);
			type2 = rettype;
			fprintf(yyout,"t%d = ",t);
			yyout_exp(type1,ret1);
			fprintf(yyout," - ");
			yyout_exp(type2,ret2);
			fprintf(yyout,"\n");
			rettype = var_type;
			return t;
			break;
		case multiply:
			fprintf(yyout,"var t%d\n",tcnt++);
			t = tcnt-1;
			ret1 = dfs_exp(p->child[0]);
			type1 = rettype;
			ret2 = dfs_exp(p->child[1]);
			type2 = rettype;
			fprintf(yyout,"t%d = ",t);
			yyout_exp(type1,ret1);
			fprintf(yyout,"*");
			yyout_exp(type2,ret2);
			fprintf(yyout,"\n");
			rettype = var_type;
			return t;
			break;
		case divide:
			fprintf(yyout,"var t%d\n",tcnt++);
			t = tcnt-1;
			ret1 = dfs_exp(p->child[0]);
			type1 = rettype;
			ret2 = dfs_exp(p->child[1]);
			type2 = rettype;
			fprintf(yyout,"t%d = ",t);
			yyout_exp(type1,ret1);
			fprintf(yyout," / ");
			yyout_exp(type2,ret2);
			fprintf(yyout,"\n");
			rettype = var_type;
			return t;
			break;
		case mod:
			fprintf(yyout,"var t%d\n",tcnt++);
			t = tcnt-1;
			ret1 = dfs_exp(p->child[0]);
			type1 = rettype;
			ret2 = dfs_exp(p->child[1]);
			type2 = rettype;
			fprintf(yyout,"t%d = ",t);
			yyout_exp(type1,ret1);
			fprintf(yyout," %% ");
			yyout_exp(type2,ret2);
			fprintf(yyout,"\n");
			rettype = var_type;
			return t;
			break;
		case integer:
			rettype = int_type;
			return p->attr.val;
			break;
		case identifier:
			sprintf(symname,"%s-%s",dfs_state,p->attr.name);
			tab = look_symtab(symname);
			if(tab == NULL){
				tab = look_symtab(p->attr.name);
				if(tab == NULL){
					yyerror("Undeclared symbol.");
				}
			}
			rettype = tab->type;
			return tab->num;
			break;
		case funccall:
			fprintf(yyout,"var t%d\n",tcnt++);
			t = tcnt-1;
			for(int i=0;i<p->child[1]->childcnt;i++){
				ret = dfs_exp(p->child[1]->child[i]);
				type = rettype;
				fprintf(yyout,"param ");
				yyout_exp(type,ret);
				fprintf(yyout,"\n");
			}
			fprintf(yyout,"t%d = ",t);
			yyout_exp(func_global,-1);
			fprintf(yyout,"%s\n",p->child[0]->attr.name);
			rettype = var_type;
			return t;
			break;
		case op_judge:
			fprintf(yyout,"var t%d\n",tcnt++);
			t = tcnt - 1;
			ret = dfs_exp(p->child[0]);
			type = rettype;
			fprintf(yyout,"t%d = ! ",t);
			yyout_exp(type,ret);
			fprintf(yyout,"\n");
			rettype = var_type;
			return t;
			break;
		case op_neg:
			fprintf(yyout,"var t%d\n",tcnt++);
			t = tcnt - 1;
			ret = dfs_exp(p->child[0]);
			type = rettype;
			fprintf(yyout,"t%d = - ",t);
			yyout_exp(type,ret);
			fprintf(yyout,"\n");
			rettype = var_type;
			return t;
			break;
		case bracket:
			ret = dfs_exp(p->child[0]);
			type = rettype;
			rettype = type;
			return ret;
			break;
		default:
			break;
	}
}
int dfs_stmt(TreeNode*p){
	SymTab *tab = NULL;
	char symname[SYMNAMELEN];
	int ret,ret1,ret2;
	SymType type,type1,type2;
	switch(p->kind.stmt){
		case kong:
			return 0;
			break;
		case statements_:
			dfs(p->child[0]);
			break;
		case if_:
			ret = dfs_exp(p->child[0]);
			type = rettype;
			fprintf(yyout,"if ");
			yyout_exp(type,ret);
			fprintf(yyout," == 0 goto l%d\n",lcnt++);
			int lcnt_if_end = lcnt-1;
			dfs_stmt(p->child[1]);
			fprintf(yyout,"l%d:\n",lcnt_if_end);
			break;
		case if_else:
			ret = dfs_exp(p->child[0]);
			type = rettype;
			fprintf(yyout,"if ");
			yyout_exp(type,ret);
			fprintf(yyout," == 0 goto l%d\n",lcnt++);
			int lcnt_if_else_header = lcnt - 1;
			dfs_stmt(p->child[1]);
			fprintf(yyout,"goto l%d\n",lcnt++);
			int lcnt_if_else_end = lcnt - 1;
			fprintf(yyout,"l%d:\n",lcnt_if_else_header);
			dfs_stmt(p->child[2]);
			fprintf(yyout,"l%d:\n",lcnt_if_else_end);
			break;
		case while_:
			fprintf(yyout,"l%d:\n",lcnt++);
			int lcnt_while_head = lcnt-1;
			ret = dfs_exp(p->child[0]);
			type = rettype;
			fprintf(yyout,"if ");
			yyout_exp(type,ret);
			fprintf(yyout," == 0 goto l%d\n",lcnt++);
			int lcnt_while_end = lcnt-1;
			dfs_stmt(p->child[1]);
			fprintf(yyout,"goto l%d\n",lcnt_while_head);
			fprintf(yyout,"l%d:\n",lcnt_while_end);
			break;
		case assign1:
			//dprintf("assign1\n");
			sprintf(symname,"%s-%s",dfs_state,p->child[0]->attr.name);
			tab = look_symtab(symname);
			if(tab == NULL){
				tab = look_symtab(p->child[0]->attr.name);
				if(tab == NULL){
					yyerror("Undeclared symbol.");
				}
			}
			ret = dfs_exp(p->child[1]);
			yyout_exp(tab->type,tab->num);
			fprintf(yyout," = ");
			yyout_exp(rettype,ret);
			fprintf(yyout,"\n");
			break;
		case assign2:
			//dprintf("assign2\n");
			sprintf(symname,"%s-%s",dfs_state,p->child[0]->attr.name);
			tab = look_symtab(symname);
			if(tab == NULL){
				tab = look_symtab(p->child[0]->attr.name);
				if(tab == NULL){
					yyerror("Undeclared symbol.");
				}
			}
			ret1 = dfs_exp(p->child[1]);
			type1 = rettype;
			ret2 = dfs_exp(p->child[2]);
			type2 = rettype;

			fprintf(yyout,"var t%d\n",tcnt);
			fprintf(yyout,"t%d = 4 * ",tcnt);
			yyout_exp(type1,ret1);
			fprintf(yyout,"\n");
			yyout_exp(tab->type,tab->num);
			fprintf(yyout,"[");
			fprintf(yyout,"t%d",tcnt++);
			fprintf(yyout,"]");
			fprintf(yyout," = ");
			yyout_exp(type2,ret2);
			fprintf(yyout,"\n");
			break;
		case return_:
			dprintf("return_\n");
			ret = dfs_exp(p->child[0]);
			type = rettype;
			fprintf(yyout,"return ");
			yyout_exp(type,ret);
			fprintf(yyout,"\n");
			break;
		case vardefn_:
			dprintf("vardefn_\n");
			char name[SYMNAMELEN];
			TreeNode* pp = p->child[0]; //vardefn
			if(pp->childcnt == 1){
				fprintf(yyout,"var T%d\n",Tcnt++);
				sprintf(name,"%s-%s",dfs_state,pp->child[0]->attr.name);
				insert_symtab(name,var_local,Tcnt-1);
			}else if(pp->childcnt == 2){
				fprintf(yyout,"var %d T%d\n",pp->child[1]->attr.val*4,Tcnt++);
				sprintf(name,"%s-%s",dfs_state,pp->child[0]->attr.name);
				insert_symtab(name,var_local,Tcnt-1);
			}else{
				yyerror("vardefn_ child count");
			}
			break;
		case funccall_: // ignore this now
			break;
		default:
			break;
	}
}
void dfs(TreeNode*p){
	switch(p->nodekind){
		case GOAL:
			//dprintf("GOAL\n");
			if(p->childcnt == 2){
				dfs(p->child[0]);
				dfs(p->child[1]);
			}else if(p->childcnt == 1){
				dfs(p->child[0]);
			}else{
				yyerror("GOAL child count");
			}
			break;
		case DEFN:
			//dprintf("DEFN: %d\n",p->childcnt);
			for(int i=0;i<p->childcnt;i++){
				dfs(p->child[i]);
			}
			break;
		case FUNCDECL: //ignore
			break;
		case STMT:
			dfs_stmt(p);
			break;
		case STATEMENTS:
			for(int i=0;i<p->childcnt;i++){
				dfs(p->child[i]);
			}
			break;
		case FUNCCONTEXT:
			//dprintf("FUNCCONTEXT\n");
			if(p->childcnt == 0){
				break;
			}else if(p->childcnt == 1){
				dfs(p->child[0]);
			}else{
				yyerror("FUNCCONTEXT child count");
			}
			break;
		case PARAMDECL:
			dprintf("PARAMDECL\n");
			int pcnt = 0 ;
			for(int i=0;i<p->childcnt;i++){
				char name[SYMNAMELEN];
				sprintf(name,"%s-%s",dfs_state,p->child[i]->child[0]->attr.name);
				insert_symtab(name,param_decl,pcnt++);
			}
			break;
		case FUNCDEFN:
			dprintf("FUNCDEFN\n");
			fprintf(yyout,"f_%s [%d]\n",p->child[0]->attr.name,p->child[1]->childcnt);
			insert_symtab(p->child[0]->attr.name,func_global,p->child[1]->childcnt);
			set_state(p->child[0]->attr.name);
			
			dfs(p->child[1]);  //paramdecl
			dfs(p->child[2]);  //funccontext

			fprintf(yyout,"end f_%s\n",p->child[0]->attr.name);			
			set_state("global");
			break;
		case MAINFUNC:
			//dprintf("MAINFUNC\n");
			fprintf(yyout,"f_main [0]\n");
			insert_symtab("main",func_global,0);
			set_state("main");
			
			dfs(p->child[0]); //funccontext
			
			fprintf(yyout,"end f_main\n");
			set_state("global");
			break;
		case VARDEFN:
			//dprintf("VARDEFN\n");
			if(p->childcnt == 1){
				fprintf(yyout,"var T%d\n",Tcnt++);
				insert_symtab(p->child[0]->attr.name,var_global,Tcnt-1);
			}else if(p->childcnt == 2){
				fprintf(yyout,"var %d T%d\n",p->child[1]->attr.val*4,Tcnt++);
				insert_symtab(p->child[0]->attr.name,var_global,Tcnt-1);
			}else{
				yyerror("VARDEFN child count");
			}
			break;
		case ASSIGNMENT:
			dprintf("ASSIGNMENT\n");
			SymTab *tab = look_symtab(p->child[0]->attr.name);
			if(tab!=NULL){
				if(p->childcnt == 2){
					fprintf(yyout,"T%d = %d\n",tab->num,p->child[1]->attr.val);
				}else if(p->childcnt == 3){
					fprintf(yyout,"T%d [%d] = %d\n",tab->num,p->child[1]->attr.val*4,p->child[2]->attr.val);	
				}
			}else{
				yyerror("ASSIGNMENT tab NULL");
			}
			break;
		case IDEN:
			break;
		case NUM:
			break;
		default:
			break;
	}
}
void gen_eeyore(){
	Tcnt = 0;
	tcnt = 0;
	lcnt = 0;
	symcnt = 0;
	set_state("global");
	dfs(root);
	print_symtab();
	dprintf("node count: %d\n",nodecnt);
}
void yyerror(const char *msg){
	fprintf(stderr,"Error: line %d %s\n",lineno,msg);
}
