#ifndef __LINEAR_SCAN_  //TYPEDEFINE
#define __LINEAR_SCAN_

//#define __DEBUG
#ifdef __DEBUG
#define dprintf(format,...) fprintf(stderr,format,##__VA_ARGS__)
#else
#define dprintf(format,...)
#endif

#define MAXINT 2147483647
typedef enum OP2Type{
	AND,
	OR,
	EQ,
	NE,
	ADD,
	MINUS,
	MULTI,
	DIV,
	MOD,
	LESS,
	GREATER,
} OP2Type;

typedef enum OP1Type{
	ZERO,
	NEG,
} OP1Type;

typedef enum EeyoreType{
	VAR,
	VART,  // array
	F_BEGIN,
	F_END,
	CALL,   // assignment call
	CALL_S, // statement call
	OP2,
	OP1,
	ASSIGN,
	ASSIGN_LEFT, // [] =
	ASSIGN_RIGHT,  // = [] 
	GOTO,
	IF,   // only "==" used in LogicalOP of if SMT
	LABEL,
	PARAM,
	RETURN,
} EeyoreType;

#define EEYORESMTMAXSIZE 20
#define MAXEEYORESMT 4000   
typedef struct EeyoreSMT{
	EeyoreType type;
	int lineno;
	char attr[3][EEYORESMTMAXSIZE];
	union{ OP1Type op1; OP2Type op2;} op;
	char tigger[200];
} EeyoreSMT;

#define VARTABMAXSIZE 4000
typedef struct VarTab{
	char name[40];  // attr
	//int id;   // index
	int begin;  // interval begin
	int end;	// interval end
	int status; // 1 for global; 0 for local
	int location; // location for those point: global variable, local array, stack location
	int reg; // allocated register(status changed with time): **0 for none**, >0 for register[reg], -1 for stack or global location
} VarTab;

typedef struct SpillStack{
	int save_flag; // 0 for not saved; 1 for saved something
	int saved;  // >0 for caller & callee saved registers; <=0 for saved vartab index
} SpillStack;
typedef struct FuncStack{
	char name[40];
	int pcnt;    //param count
	int vartsize;   // /4
	int spillcnt; 
	SpillStack spillstack[200]; //stacksize = vartsize + spillcnt
} FuncStack;

#endif
