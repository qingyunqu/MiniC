#ifndef __TYPEDEFINE_H_
#define __TYPEDEFINE_H_

//#define __DEBUG_
#ifdef __DEBUG_
#define dprintf(format,...) fprintf(stderr,format,##__VA_ARGS__)
#else
#define dprintf(format,...)
#endif

typedef enum SMTTYPE_{
	VAR,
	VART,
	FUNCBEGIN,
	FUNCEND,
	OP2,
	OP1,
	ASSIGN,
	ASSIGN_LEFT,
	ASSIGN_RIGHT,
	CALL,
	IF,
	GOTO,
	LABEL,
	PARAM,
	RETURN,
	NONE, // removed statements
} SMTTYPE;

#define SMTMAXSIZE 50
#define FUNCMAXSIZE 40
typedef struct SMT_{
	char text[SMTMAXSIZE];
	//int status; // 1 for used; 0 for removed
	SMTTYPE type;
	char attr[4][FUNCMAXSIZE]; //save Function, Variable, RightValue, OP
} SMT;

void optimize(); //realize in optimize.c

#endif
