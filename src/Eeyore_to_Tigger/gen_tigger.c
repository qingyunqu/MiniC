#include <stdio.h>
#include "y.tab.h"
#include "linear_scan.h"
#include <string.h>

int smtcnt_;
EeyoreSMT *smt_;

int vartabcnt = 0;
VarTab vartab[VARTABMAXSIZE];
int funccnt = 0;
FuncStack funcstack[100];

int registers[32];    // index of vartab; -1 for no allocated; -2 for used and free
// 0:x0=0    1-7:t0-t6,caller   8-19:s0-s11,callee    20-27:a0-a7,caller
// usable: 0-27
const int treg = 1;
const int sreg = 8;
const int areg = 20;
const int minreg = 1;
const int maxreg = 27;

int tigger_status = 1; // 1 for global; 0 for local
char state[40] = "global";  // function name length
int vcnt = 0;  // global v0 v1 v2

void print_smt();
void print_interval();
void print_funcstack();
void print_tigger_code();
void generror(const char*msg);

void sprint_op2(char *tigger,OP2Type op2);
void sprint_reg(char *tigger,int reg);
int judgeint(char *attr);

void get_variable_interval();
void gen_tigger_code();

int find_a_vartab(char *name);
int find_a_funcstack(char *name);
int add_a_vartab(char *name);

void set_interval(int varid,int smtid);

void load_a_int(char *tigger,char *num,int reg); //add "reg = num"
void load_a_address(char *tigger,int varid,int reg);  // add "loadaddr 0/v0 reg"

void expire_a_reg(int reg){
	registers[reg] = -2;
}
int get_a_spillstack(int funcid){
	int tmp_stack = -1;
	FuncStack *fs = &funcstack[funcid];
	for(int i=0;i<fs->spillcnt;i++){
		if(fs->spillstack[i].save_flag == 0){
			tmp_stack = i;
			break;
		}
	}
	if(tmp_stack!=-1){
		return tmp_stack+fs->vartsize;
	}
	else{
		fs->spillcnt++;
		return fs->vartsize + fs->spillcnt - 1;
	}
}
int spill_a_reg(char *tigger){
	int max = -1;
	int tmp_i = -1;
	for(int i=minreg;i<=maxreg;i++){
		if(registers[i]<0)
			return i;
		if((vartab[registers[i]].name[0]=='T' && max<vartab[registers[i]].end){
			max = vartab[registers[i].end;
			tmp_i = i;
		}
		/*if(vartab[registers[i]].status == 1){
			vartab[registers[i]].reg = -1;
			registers[i] = -2;
			return i;
		}
		else{
			if(vartab[registers[i]].name[0]=='T'){
				vartab[registers[i]].reg = -1;
				registers[i] = -2;
				return i;
			}
			else{
				continue;//need
			}
		}*/
	}
	
}
int get_a_reg(char *tigger){
	int tmp_reg = -1;
	for(int i=minreg;i<=maxreg;i++){
		if(registers[i]<0){
			tmp_reg = i;
			break;
		}
	}
	if(tmp_reg!=-1){
		if(tmp_reg>=sreg+0 && tmp_reg<=sreg+11 && registers[tmp_reg]==-1){
			strcat(tigger,"store ");
			sprint_reg(tigger,tmp_reg);
			
			int funcid = find_a_funcstack(state);
			int stackid = get_a_spillstack(funcid);
			char stack_index[20] = "\0";
			sprintf(stack_index," %d\n",stackid);
			funcstack[funcid].spillstack[stackid- funcstack[funcid].vartsize].save_flag = 1;
			funcstack[funcid].spillstack[stackid- funcstack[funcid].vartsize].saved = tmp_reg;
			
			strcat(tigger,stack_index);
			return tmp_reg;
		}
		else
			return tmp_reg;
	}
	else{
		return spill_a_reg(tigger);//???  // local? global?
	}
	return -1;
}
int get_a_areg(char *tigger,int paramcnt){  // get a0 or a1 or ax
	if(registers[areg+paramcnt]>=0){
		//spill this reg
	}
	return areg+paramcnt;
}
void load_a_variable(char *tigger,int varid,int reg,int left){  // only var not vart and release local var stack
	VarTab *vt = &vartab[varid];
	//
		if(vt->status==1){
			if(left)
				return;
			char tmp[20] = "\0";
			sprintf(tmp,"load v%d ",vt->location);
			strcat(tigger,tmp);
			sprint_reg(tigger,reg);
			strcat(tigger,"\n");
			return;
		}
		else if(vt->status==0){
			int funcid = find_a_funcstack(state);
			FuncStack *fs = &funcstack[funcid];
			//fs->spillstack[vt->location - fs->vartsize].save_flag == 0;   // release local var stack
			if(left)
				return;
			char tmp[20] = "\0";
			sprintf(tmp,"load %d ",vt->location);
			strcat(tigger,tmp);
			sprint_reg(tigger,reg);
			strcat(tigger,"\n");
			return;
		}
	//
}
void store_a_variable(char *tigger,int varid){
	VarTab *vt = &vartab[varid];
	if(vt->status==0 && vt->name[0]=='T'){
		
		strcat(tigger,"store ");
		sprint_reg(tigger,vt->reg);
		char tmp[20] = "\0";
		sprintf(tmp," %d\n",vt->location);
		strcat(tigger,tmp);
		
		expire_a_reg(vt->reg);
		vt->reg = -1;
	}
}
void load_a_variable_param(char *tigger,int varid,int reg){
	VarTab *vt = &vartab[varid];
	if(vt->status==1){
		char tmp[20] = "\0";
		sprintf(tmp,"load v%d ",vt->location);
		strcat(tigger,tmp);
		sprint_reg(tigger,reg);
		strcat(tigger,"\n");
		return;
	}
	else if(vt->status==0){
		char tmp[20] = "\0";
		sprintf(tmp,"load %d ",vt->location);
		strcat(tigger,tmp);
		sprint_reg(tigger,reg);
		strcat(tigger,"\n");
		return;
	}
}

void pop_callee_saved_registers(char *tigger){
	int funcid = find_a_funcstack(state);
	FuncStack *fs = &funcstack[funcid];
	char stackid[20] = "\0";
	for(int i=0;i<fs->spillcnt;i++){
		if(fs->spillstack[i].save_flag==1 && fs->spillstack[i].saved>=sreg && fs->spillstack[i].saved<=sreg+11){
			strcat(tigger,"load ");
			sprintf(stackid,"%d ",i+fs->vartsize);
			strcat(tigger,stackid);
			sprint_reg(tigger,fs->spillstack[i].saved);
			strcat(tigger,"\n");
		}
	}
}
void save_caller_saved_registers(char *tigger,int call_param_cnt){
	int funcid = find_a_funcstack(state);
	FuncStack *fs = &funcstack[funcid];
	int stackid;
	char stack_index[20] = "\0";
	
	for(int i=minreg;i<=maxreg;i++){
		if((i>=treg+0 && i<=treg+6)||(i>=areg+call_param_cnt && i<=areg+7)){
			if(registers[i]>=0){
				if(vartab[registers[i]].status==0){  // ??? local vart
					strcat(tigger,"store ");
					sprint_reg(tigger,i);
				
					stackid = get_a_spillstack(funcid);
					sprintf(stack_index," %d\n",stackid);
					funcstack[funcid].spillstack[stackid- funcstack[funcid].vartsize].save_flag = 1;
					funcstack[funcid].spillstack[stackid- funcstack[funcid].vartsize].saved = i;
			
					strcat(tigger,stack_index);

					vartab[registers[i]].reg = -1;
					vartab[registers[i]].location = stackid;
					registers[i] = -2;
				}
				else if(vartab[registers[i]].status==1){ // ??? global vart
					vartab[registers[i]].reg = -1;
					//vartab[registers[i]].location = stackid;
					registers[i] = -2;
				}
			}
		}
	}
}
void expire(int lineno){
	VarTab *vt;
	for(int i=0;i<vartabcnt;i++){
		vt = &vartab[i];
		if(vt->end <= lineno){
			if(vt->status==1){
				if(vt->reg > 0){
					expire_a_reg(vt->reg);
					vt->reg = -1;
				}
			}
			else if(vt->status==0){
				if(vt->reg > 0){
					expire_a_reg(vt->reg);
					vt->reg = 0;
				}
				else{
					int funcid = find_a_funcstack(state);
					FuncStack *fs = &funcstack[funcid];
					if(vt->location >= fs->vartsize){
						fs->spillstack[vt->location - fs->vartsize].save_flag = 0;
						vt->reg = 0;
					}
				}
			}
		}
	}
}
void expire_T(int smtcnt){
	for(int i=0;i<vartabcnt;i++){
		VarTab *vt = &vartab[i];
		if(vt->status == 0 && vt->name[0]=='T'){
			if(vt->reg > 0)
				registers[vt->reg] = -2;
			vt->reg = -1;
		}
	}
}

void gen_tigger(EeyoreSMT *smt__,int smtcnt__){
	smt_ = smt__;
	smtcnt_ = smtcnt__;
	//print_smt();
	for(int i=0;i<32;i++)
		registers[i] = -1;  //init registers
	get_variable_interval();
	//print_interval();
	//print_funcstack();
	gen_tigger_code();
	print_tigger_code();
}


void gen_tigger_code(){
	int call_param_cnt = 0;
	int varid;
	int reg;
	int reg1;
	int reg2;
	int reg_expire_flag;
	int reg1_expire_flag;  // RightValue = Variable 0 or INTEGER 1
	int reg2_expire_flag;
	for(int i=0;i<smtcnt_;i++){
		switch(smt_[i].type){
			case VAR:
				if(tigger_status==0){
				}
				if(tigger_status==1){
					varid = find_a_vartab(smt_[i].attr[0]);
					if(varid == -1)
						generror("gen tigger error");
					sprintf(smt_[i].tigger,"v%d = 0\n",vartab[varid].location);
				}
				break;
			case VART:
				if(tigger_status==0){
				}
				if(tigger_status==1){
					varid = find_a_vartab(smt_[i].attr[1]);
					if(varid == -1)
						generror("gen tigger error");
					sprintf(smt_[i].tigger,"v%d = malloc %s\n",vartab[varid].location,smt_[i].attr[0]);
				}
				break;
			case F_BEGIN:
				for(int j=minreg;j<=maxreg;j++){
					registers[j] = -1;
				}
				for(int j=0;j<vartabcnt;j++){
					if(vartab[j].status == 1)
						vartab[j].reg = -1;
				}
				sprintf(smt_[i].tigger,"%s [%s] ",smt_[i].attr[0],smt_[i].attr[1]);
				sprintf(state,"%s",smt_[i].attr[0]);
				tigger_status = 0;
				int p_num;
				sscanf(smt_[i].attr[1],"%d",&p_num);
				for(int i=0;i<p_num;i++){
					char p_tmp[20];
					sprintf(p_tmp,"p%d",i);
					varid = find_a_vartab(p_tmp);
					if(varid == -1)
						generror("gen tigger error");
					//vartab[varid].location = areg+i;
					registers[areg+i] = varid;
					vartab[varid].reg = areg+i;
				}
				break;
			case F_END:
				sprintf(smt_[i].tigger,"end %s\n",smt_[i].attr[0]);
				sprintf(state,"global");
				tigger_status = 1;
				break;
			case CALL:
				// save caller saved???
				save_caller_saved_registers(smt_[i].tigger,call_param_cnt);
				
				strcat(smt_[i].tigger,"call ");
				strcat(smt_[i].tigger,smt_[i].attr[1]);
				strcat(smt_[i].tigger,"\n");
				
				// pop caller saved???
				//pop_caller_saved_registers(smt_[i].tigger);
				
				varid = find_a_vartab(smt_[i].attr[0]);
				if(varid == -1)
					generror("gen tigger error");
				if(vartab[varid].reg<=0){  // not in regsiter
					reg = get_a_reg(smt_[i].tigger);
					registers[reg] = varid;
					load_a_variable(smt_[i].tigger,varid,reg,1);
					vartab[varid].reg = reg;
				}
				else
					reg = vartab[varid].reg;
				
				sprint_reg(smt_[i].tigger,reg);
				strcat(smt_[i].tigger," = ");
				sprint_reg(smt_[i].tigger,areg);
				strcat(smt_[i].tigger,"\n");
				
				store_a_variable(smt_[i].tigger,varid);
				
				for(int j=0;j<call_param_cnt;j++){
					registers[areg+j] = -2;
				}
				call_param_cnt = 0;
				break;
			case PARAM:
				reg = get_a_areg(smt_[i].tigger,call_param_cnt);  // a0 a1 ax
				
				if(judgeint(smt_[i].attr[0])==0){ //variable
					varid = find_a_vartab(smt_[i].attr[0]);
					if(varid == -1)
						generror("gen tigger error");
					if(vartab[varid].reg<=0){  // not in registers
						load_a_variable_param(smt_[i].tigger,varid,reg); // maybe load address?
						//vartab[varid].reg = reg1;
						registers[reg] = MAXINT;
					}
					else{
						sprint_reg(smt_[i].tigger,reg);
						strcat(smt_[i].tigger," = ");
						sprint_reg(smt_[i].tigger,vartab[varid].reg);
						strcat(smt_[i].tigger,"\n");
						registers[reg] = MAXINT;
					}
				}
				else{  // int
					if(strcmp(smt_[i].attr[0],"0")==0){
						sprint_reg(smt_[i].tigger,reg);
						strcat(smt_[i].tigger," = ");
						sprint_reg(smt_[i].tigger,0);
						strcat(smt_[i].tigger,"\n");
						registers[reg] = MAXINT;
					}
					else{
						sprint_reg(smt_[i].tigger,reg);
						strcat(smt_[i].tigger," = ");
						strcat(smt_[i].tigger,smt_[i].attr[0]);
						strcat(smt_[i].tigger,"\n");
						registers[reg] = MAXINT;
					}
				}

				call_param_cnt++;
				break;
			case CALL_S:
				// ignore this now
				break;
			case OP2:
				if(judgeint(smt_[i].attr[1])==0){  // varible
					varid = find_a_vartab(smt_[i].attr[1]);
					if(varid == -1)
						generror("gen tigger error");
					if(vartab[varid].reg<=0){  // not in regsiter
						reg1 = get_a_reg(smt_[i].tigger);
						registers[reg1] = varid;
						load_a_variable(smt_[i].tigger,varid,reg1,0);
						vartab[varid].reg = reg1;
					}
					else
						reg1 = vartab[varid].reg;
					reg1_expire_flag = 0;
				}
				else{  // int
					if(strcmp(smt_[i].attr[1],"0")==0){
						reg1 = 0;
					}
					else{
						reg1 = get_a_reg(smt_[i].tigger);
						registers[reg1] = MAXINT;
						load_a_int(smt_[i].tigger,smt_[i].attr[1],reg1);
					}
					reg1_expire_flag = 1;
				}
				
				if(judgeint(smt_[i].attr[2])==0){  // varible
					varid = find_a_vartab(smt_[i].attr[2]);
					if(varid == -1)
						generror("gen tigger error");
					if(vartab[varid].reg<=0){  // not in regsiter
						reg2 = get_a_reg(smt_[i].tigger);
						registers[reg2] = varid;
						load_a_variable(smt_[i].tigger,varid,reg2,0);
						vartab[varid].reg = reg2;
					}
					else{
						//
						if(vartab[varid].status == 1){
							strcat(smt_[i].tigger,"load ");
							char tmp[20] = "\0";
							sprintf(tmp,"v%d ",vartab[varid].location);
							strcat(smt_[i].tigger,tmp);
							sprint_reg(smt_[i].tigger,vartab[varid].reg);
							strcat(smt_[i].tigger,"\n");
						}
						reg2 = vartab[varid].reg;
					}
					reg2_expire_flag = 0;
				}
				else{ // int
					if(strcmp(smt_[i].attr[2],"0")==0){
						reg2 = 0;
					}
					else{
						reg2 = get_a_reg(smt_[i].tigger);
						registers[reg2] = MAXINT;
						load_a_int(smt_[i].tigger,smt_[i].attr[2],reg2);
					}
					reg2_expire_flag = 1;
				}
				
				varid = find_a_vartab(smt_[i].attr[0]);
				if(varid == -1)
					generror("gen tigger error");
				if(vartab[varid].reg<=0){  // not in regsiter
					reg = get_a_reg(smt_[i].tigger);
					registers[reg] = varid;
					load_a_variable(smt_[i].tigger,varid,reg,1);
					vartab[varid].reg = reg;
				}
				else
					reg = vartab[varid].reg;
				
				sprint_reg(smt_[i].tigger,reg);
				strcat(smt_[i].tigger," = ");
				sprint_reg(smt_[i].tigger,reg1);
				sprint_op2(smt_[i].tigger,smt_[i].op.op2);
				sprint_reg(smt_[i].tigger,reg2);
				strcat(smt_[i].tigger,"\n");
				
				if(reg1_expire_flag)
					expire_a_reg(reg1);
				if(reg2_expire_flag)
					expire_a_reg(reg2);
				if(vartab[varid].status == 1){
					char store_v[100] = "\0";
					int reg3 = get_a_reg(store_v);
					sprintf(store_v,"loadaddr v%d ", vartab[varid].location);
					sprint_reg(store_v,reg3);
					strcat(store_v,"\n");
					sprint_reg(store_v,reg3);
					strcat(store_v,"[0] = ");
					sprint_reg(store_v,reg);
					strcat(store_v,"\n");
					strcat(smt_[i].tigger,store_v);
					expire_a_reg(reg3);
				}

				store_a_variable(smt_[i].tigger,varid);
				break;
			case OP1:
				if(judgeint(smt_[i].attr[1])==0){  // varible
					varid = find_a_vartab(smt_[i].attr[1]);
					if(varid == -1)
						generror("gen tigger error");
					if(vartab[varid].reg<=0){  // not in regsiter
						reg1 = get_a_reg(smt_[i].tigger);
						registers[reg1] = varid;
						load_a_variable(smt_[i].tigger,varid,reg1,0);
						vartab[varid].reg = reg1;
					}
					else
						reg1 = vartab[varid].reg;
					reg1_expire_flag = 0;
				}
				else{
					if(strcmp(smt_[i].attr[1],"0")==0){
						reg1 = 0;
					}
					else{
						reg1 = get_a_reg(smt_[i].tigger);
						registers[reg1] = MAXINT;
						load_a_int(smt_[i].tigger,smt_[i].attr[1],reg1);
					}
					reg1_expire_flag = 1;
				}
				
				varid = find_a_vartab(smt_[i].attr[0]);
				if(varid == -1)
					generror("gen tigger error");
				if(vartab[varid].reg<=0){  // not in regsiter
					reg = get_a_reg(smt_[i].tigger);
					registers[reg] = varid;
					load_a_variable(smt_[i].tigger,varid,reg,1);
					vartab[varid].reg = reg;
				}
				else
					reg = vartab[varid].reg;
				
				sprint_reg(smt_[i].tigger,reg);
				strcat(smt_[i].tigger," = ");
				if(smt_[i].op.op1 == ZERO)
					strcat(smt_[i].tigger," ! ");
				else if(smt_[i].op.op1 == NEG)
					strcat(smt_[i].tigger," - ");
				sprint_reg(smt_[i].tigger,reg1);
				strcat(smt_[i].tigger,"\n");
				
				if(reg1_expire_flag)
					expire_a_reg(reg1);
				if(vartab[varid].status == 1){
					char store_v[100] = "\0";
					int reg3 = get_a_reg(store_v);
					sprintf(store_v,"loadaddr v%d ", vartab[varid].location);
					sprint_reg(store_v,reg3);
					strcat(store_v,"\n");
					sprint_reg(store_v,reg3);
					strcat(store_v,"[0] = ");
					sprint_reg(store_v,reg);
					strcat(store_v,"\n");
					strcat(smt_[i].tigger,store_v);
					expire_a_reg(reg3);
				}
				
				store_a_variable(smt_[i].tigger,varid);
				break;
			case ASSIGN:
				if(judgeint(smt_[i].attr[1])==0){  // varible
					varid = find_a_vartab(smt_[i].attr[1]);
					if(varid == -1)
						generror("gen tigger error");
					if(vartab[varid].reg<=0){  // not in regsiter
						reg1 = get_a_reg(smt_[i].tigger);
						registers[reg1] = varid;
						load_a_variable(smt_[i].tigger,varid,reg1,0);
						vartab[varid].reg = reg1;
					}
					else
						reg1 = vartab[varid].reg;
					reg1_expire_flag = 0;
				}
				else{
					reg1_expire_flag = 1;
				}
				
				varid = find_a_vartab(smt_[i].attr[0]);
				if(varid == -1)
					generror("gen tigger error");
				if(vartab[varid].reg<=0){  // not in regsiter
					reg = get_a_reg(smt_[i].tigger);
					registers[reg] = varid;
					load_a_variable(smt_[i].tigger,varid,reg,1);
					vartab[varid].reg = reg;
				}
				else
					reg = vartab[varid].reg;
			
				sprint_reg(smt_[i].tigger,reg);
				strcat(smt_[i].tigger," = ");
				if(reg1_expire_flag){
					if(strcmp(smt_[i].attr[1],"0")==0){
						sprint_reg(smt_[i].tigger,0);
					}
					else{
						strcat(smt_[i].tigger,smt_[i].attr[1]);
					}
				}
				else{
					sprint_reg(smt_[i].tigger,reg1);
				}
				strcat(smt_[i].tigger,"\n");
				
				if(vartab[varid].status == 1){
					char store_v[100] = "\0";
					int reg3 = get_a_reg(store_v);
					sprintf(store_v,"loadaddr v%d ", vartab[varid].location);
					sprint_reg(store_v,reg3);
					strcat(store_v,"\n");
					sprint_reg(store_v,reg3);
					strcat(store_v,"[0] = ");
					sprint_reg(store_v,reg);
					strcat(store_v,"\n");
					strcat(smt_[i].tigger,store_v);
					expire_a_reg(reg3);
				}
				
				store_a_variable(smt_[i].tigger,varid);
				break;
			case ASSIGN_LEFT:
				if(judgeint(smt_[i].attr[1])==0){  // varible
					varid = find_a_vartab(smt_[i].attr[1]);
					if(varid == -1)
						generror("gen tigger error");
					if(vartab[varid].reg<=0){  // not in regsiter
						reg1 = get_a_reg(smt_[i].tigger);
						registers[reg1] = varid;
						load_a_variable(smt_[i].tigger,varid,reg1,0);
						vartab[varid].reg = reg1;
					}
					else
						reg1 = vartab[varid].reg;
					reg1_expire_flag = 0;
				}
				else{
					if(strcmp(smt_[i].attr[1],"0")==0){
						reg1 = 0;
					}
					else{
						reg1 = get_a_reg(smt_[i].tigger);
						registers[reg1] = MAXINT;
						load_a_int(smt_[i].tigger,smt_[i].attr[1],reg1);
					}
					reg1_expire_flag = 1;
				}
				
				if(judgeint(smt_[i].attr[2])==0){  // varible
					varid = find_a_vartab(smt_[i].attr[2]);
					if(varid == -1)
						generror("gen tigger error");
					if(vartab[varid].reg<=0){  // not in regsiter
						reg2 = get_a_reg(smt_[i].tigger);
						registers[reg2] = varid;
						load_a_variable(smt_[i].tigger,varid,reg2,0);
						vartab[varid].reg = reg2;
					}
					else
						reg2 = vartab[varid].reg;
					reg2_expire_flag = 0;
				}
				else{
					if(strcmp(smt_[i].attr[2],"0")==0){
						reg2 = 0;
					}
					else{
						reg2 = get_a_reg(smt_[i].tigger);
						registers[reg2] = MAXINT;
						load_a_int(smt_[i].tigger,smt_[i].attr[2],reg2);
					}
					reg2_expire_flag = 1;
				}
				
				varid = find_a_vartab(smt_[i].attr[0]);
				if(varid == -1)
					generror("gen tigger error");
				if(vartab[varid].reg<=0){  // not in regsiter
					reg = get_a_reg(smt_[i].tigger);
					registers[reg] = varid;
					// load_a_variable(smt_[i].tigger,varid,reg,1);
					// vartab[varid].reg = reg;
					load_a_address(smt_[i].tigger,varid,reg);
				}
				else
					reg = vartab[varid].reg;
				
				sprint_reg(smt_[i].tigger,reg);
				strcat(smt_[i].tigger," = ");
				sprint_reg(smt_[i].tigger,reg);
				strcat(smt_[i].tigger," + ");
				sprint_reg(smt_[i].tigger,reg1);
				strcat(smt_[i].tigger,"\n");

				sprint_reg(smt_[i].tigger,reg);
				strcat(smt_[i].tigger,"[0] = ");
				sprint_reg(smt_[i].tigger,reg2);
				strcat(smt_[i].tigger,"\n");
				
				if(reg1_expire_flag)
					expire_a_reg(reg1);
				if(reg2_expire_flag)
					expire_a_reg(reg2);
				expire_a_reg(reg);
				break;
			case ASSIGN_RIGHT:
				varid = find_a_vartab(smt_[i].attr[1]);
				if(varid == -1)
					generror("gen tigger error");
				if(vartab[varid].reg<=0){
					reg1 = get_a_reg(smt_[i].tigger);
					registers[reg1] = varid;
					//load_a_variable(smt_[i].tigger,varid,reg1,0);
					//vartab[varid].reg = reg1;
					load_a_address(smt_[i].tigger,varid,reg1);
				}
				else
					reg1 = vartab[varid].reg;
				
				if(judgeint(smt_[i].attr[2])==0){  // varible
					varid = find_a_vartab(smt_[i].attr[2]);
					if(varid == -1)
						generror("gen tigger error");
					if(vartab[varid].reg<=0){  // not in regsiter
						reg2 = get_a_reg(smt_[i].tigger);
						registers[reg2] = varid;
						load_a_variable(smt_[i].tigger,varid,reg2,0);
						vartab[varid].reg = reg2;
					}
					else
						reg2 = vartab[varid].reg;
					reg2_expire_flag = 0;
				}
				else{
					if(strcmp(smt_[i].attr[2],"0")==0){
						reg2 = 0;
					}
					else{
						reg2 = get_a_reg(smt_[i].tigger);
						registers[reg2] = MAXINT;
						load_a_int(smt_[i].tigger,smt_[i].attr[2],reg2);
					}
					reg2_expire_flag = 1;
				}
				
				varid = find_a_vartab(smt_[i].attr[0]);
				if(varid == -1)
					generror("gen tigger error");
				if(vartab[varid].reg<=0){  // not in regsiter
					reg = get_a_reg(smt_[i].tigger);
					registers[reg] = varid;
					load_a_variable(smt_[i].tigger,varid,reg,1);
					vartab[varid].reg = reg;
				}
				else
					reg = vartab[varid].reg;
				
				sprint_reg(smt_[i].tigger,reg1);
				strcat(smt_[i].tigger," = ");
				sprint_reg(smt_[i].tigger,reg1);
				strcat(smt_[i].tigger," + ");
				sprint_reg(smt_[i].tigger,reg2);
				strcat(smt_[i].tigger,"\n");

				sprint_reg(smt_[i].tigger,reg);
				strcat(smt_[i].tigger," = ");
				sprint_reg(smt_[i].tigger,reg1);
				strcat(smt_[i].tigger,"[0]\n");
				
				expire_a_reg(reg1);
				if(reg2_expire_flag)
					expire_a_reg(reg2);
				if(vartab[varid].status == 1){
					char store_v[50] = "\0";
					int reg3 = get_a_reg(store_v);
					sprintf(store_v,"loadaddr v%d ", vartab[varid].location);
					sprint_reg(store_v,reg3);
					strcat(store_v,"\n");
					sprint_reg(store_v,reg3);
					strcat(store_v,"[0] = ");
					sprint_reg(store_v,reg);
					strcat(store_v,"\n");
					strcat(smt_[i].tigger,store_v);
					expire_a_reg(reg3);
				}
				
				store_a_variable(smt_[i].tigger,varid);
				break;
			case GOTO:
				sprintf(smt_[i].tigger,"goto %s\n",smt_[i].attr[0]);
				break;
			case IF:
				if(judgeint(smt_[i].attr[0])==0){  // varible
					varid = find_a_vartab(smt_[i].attr[0]);
					if(varid == -1)
						generror("gen tigger error");
					if(vartab[varid].reg<=0){  // not in regsiter
						reg = get_a_reg(smt_[i].tigger);
						registers[reg] = varid;
						load_a_variable(smt_[i].tigger,varid,reg,0);
						vartab[varid].reg = reg;
					}
					else
						reg = vartab[varid].reg;
					reg_expire_flag = 0;
				}
				else{
					if(strcmp(smt_[i].attr[0],"0")==0){
						reg = 0;
					}
					else{
						reg = get_a_reg(smt_[i].tigger);
						registers[reg] = MAXINT;
						load_a_int(smt_[i].tigger,smt_[i].attr[0],reg);
					}
					reg_expire_flag = 1;
				}
				
				if(judgeint(smt_[i].attr[1])==0){  // varible
					varid = find_a_vartab(smt_[i].attr[1]);
					if(varid == -1)
						generror("gen tigger error");
					if(vartab[varid].reg<=0){  // not in regsiter
						reg1 = get_a_reg(smt_[i].tigger);
						registers[reg1] = varid;
						load_a_variable(smt_[i].tigger,varid,reg1,0);
						vartab[varid].reg = reg1;
					}
					else
						reg1 = vartab[varid].reg;
					reg1_expire_flag = 0;
				}
				else{
					if(strcmp(smt_[i].attr[1],"0")==0){
						reg1 = 0;
					}
					else{
						reg1 = get_a_reg(smt_[i].tigger);
						registers[reg1] = MAXINT;
						load_a_int(smt_[i].tigger,smt_[i].attr[1],reg1);
					}
					reg1_expire_flag = 1;
				}
				
				strcat(smt_[i].tigger,"if ");
				sprint_reg(smt_[i].tigger,reg);
				strcat(smt_[i].tigger," == ");
				sprint_reg(smt_[i].tigger,reg1);
				strcat(smt_[i].tigger," goto ");
				strcat(smt_[i].tigger,smt_[i].attr[2]);
				strcat(smt_[i].tigger,"\n");
				
				if(reg_expire_flag)
					expire_a_reg(reg);
				if(reg1_expire_flag)
					expire_a_reg(reg1);
				break;
			case LABEL:
				sprintf(smt_[i].tigger,"%s:\n",smt_[i].attr[0]);
				break;
			case RETURN:
				// pop callee saved ???
				pop_callee_saved_registers(smt_[i].tigger);
				if(judgeint(smt_[i].attr[0])==0){  // varible
					varid = find_a_vartab(smt_[i].attr[0]);
					if(varid == -1)
						generror("gen tigger error");
					if(vartab[varid].reg<=0){  // not in regsiter
						reg = areg;
						registers[reg] = varid;
						load_a_variable(smt_[i].tigger,varid,reg,0);
						vartab[varid].reg = reg;
					}
					else{
						reg = vartab[varid].reg;
						sprint_reg(smt_[i].tigger,areg);
						strcat(smt_[i].tigger," = ");
						sprint_reg(smt_[i].tigger,reg);
						strcat(smt_[i].tigger,"\n");
					}
					reg_expire_flag = 0;
				}
				else{
					if(strcmp(smt_[i].attr[0],"0")==0){
						reg = 0;
						sprint_reg(smt_[i].tigger,areg);
						strcat(smt_[i].tigger," = ");
						sprint_reg(smt_[i].tigger,reg);
						strcat(smt_[i].tigger,"\n");
					}
					else{
						reg = areg;
						registers[reg] = MAXINT;
						load_a_int(smt_[i].tigger,smt_[i].attr[0],reg);
					}
					reg_expire_flag = 1;
				}
				
				strcat(smt_[i].tigger,"return\n");
				if(reg_expire_flag)
					expire_a_reg(reg);
				break;
			default:
				break;
		}
		
		expire_T(i);
		expire(smt_[i].lineno);//???
	}
}
void get_variable_interval(){
	int varcnt;
	int paramcnt;
	int p;
	for(int i=0;i<smtcnt_;i++){
		switch(smt_[i].type){
			case VAR:
				if(tigger_status==0){
					varcnt = add_a_vartab(smt_[i].attr[0]);
					vartab[varcnt].status = 0;
					vartab[varcnt].begin = -1;
					vartab[varcnt].end = -1;
					vartab[varcnt].reg = 0;
					if(smt_[i].attr[0][0]=='T'){
						int funcid = find_a_funcstack(state);
						FuncStack *fs=&funcstack[funcid];
						vartab[varcnt].reg = -1;
						vartab[varcnt].location = fs->vartsize;
						fs->vartsize++;
					}
				}
				if(tigger_status==1){
					varcnt = add_a_vartab(smt_[i].attr[0]);
					vartab[varcnt].status = 1;
					vartab[varcnt].begin = -1;
					vartab[varcnt].end = -1;
					vartab[varcnt].reg = -1;
					vartab[varcnt].location = vcnt;
					vcnt++;
				}
				break;
			case VART:
				if(tigger_status==0){
					int funcindex = find_a_funcstack(state);
					if(funcindex==-1)
						generror("funccnt error");
					int vartsize;
					sscanf(smt_[i].attr[0],"%d",&vartsize);
					funcstack[funcindex].vartsize += vartsize/4;
					
					varcnt = add_a_vartab(smt_[i].attr[1]);
					vartab[varcnt].status = 0;
					vartab[varcnt].begin = -1;
					vartab[varcnt].end = -1;
					vartab[varcnt].reg = -1;
					vartab[varcnt].location = funcstack[funcindex].vartsize - vartsize/4;
				}
				if(tigger_status==1){
					varcnt = add_a_vartab(smt_[i].attr[1]);
					vartab[varcnt].status = 1;
					vartab[varcnt].begin = -1;
					vartab[varcnt].end = -1;
					vartab[varcnt].reg = -1;
					vartab[varcnt].location = vcnt;
					vcnt++;
				}
				break;
			case F_BEGIN:
				sprintf(funcstack[funccnt].name,"%s",smt_[i].attr[0]);
				funcstack[funccnt].vartsize = 0;
				funcstack[funccnt].spillcnt = 0;
				
				sscanf(smt_[i].attr[1],"%d",&paramcnt);
				funcstack[funccnt].pcnt = paramcnt;
				funccnt++;
				
				for(p=0;p<paramcnt;p++){
					char tmp[40];
					sprintf(tmp,"%s-p%d",smt_[i].attr[0],p);
					varcnt = add_a_vartab(tmp);
					vartab[varcnt].status = 0;
					vartab[varcnt].begin = smt_[i].lineno;
					vartab[varcnt].end = -1;
					vartab[varcnt].reg = areg+p;
				}
				sprintf(state,"%s",smt_[i].attr[0]);
				tigger_status = 0;
				break;
			case F_END:
				sprintf(state,"global");
				tigger_status = 1;
				break;
			case CALL:
				varcnt = find_a_vartab(smt_[i].attr[0]);
				if(varcnt==-1)
					generror("varcnt error");
				set_interval(varcnt,smt_[i].lineno);
				break;
			case CALL_S:
				//ignore now
				break;
			case OP2:
				varcnt = find_a_vartab(smt_[i].attr[0]);
				if(varcnt==-1)
					generror("varcnt error");
				set_interval(varcnt,smt_[i].lineno);
				if(judgeint(smt_[i].attr[1])==0){
					varcnt = find_a_vartab(smt_[i].attr[1]);
					if(varcnt==-1)
						generror("varcnt error");
					set_interval(varcnt,smt_[i].lineno);
				}
				if(judgeint(smt_[i].attr[2])==0){
					varcnt = find_a_vartab(smt_[i].attr[2]);
					if(varcnt==-1)
						generror("varcnt error");
					set_interval(varcnt,smt_[i].lineno);
				}
				break;
			case OP1:
				varcnt = find_a_vartab(smt_[i].attr[0]);
				if(varcnt==-1)
					generror("varcnt error");
				set_interval(varcnt,smt_[i].lineno);
				if(judgeint(smt_[i].attr[1])==0){
					varcnt = find_a_vartab(smt_[i].attr[1]);
					if(varcnt==-1)
						generror("varcnt error");
					set_interval(varcnt,smt_[i].lineno);
				}
				break;
			case ASSIGN:
				varcnt = find_a_vartab(smt_[i].attr[0]);
				if(varcnt==-1)
					generror("varcnt error");
				set_interval(varcnt,smt_[i].lineno);
				if(judgeint(smt_[i].attr[1])==0){
					varcnt = find_a_vartab(smt_[i].attr[1]);
					if(varcnt==-1)
						generror("varcnt error");
					set_interval(varcnt,smt_[i].lineno);
				}
				break;
			case ASSIGN_LEFT:
				varcnt = find_a_vartab(smt_[i].attr[0]);
				if(varcnt==-1)
					generror("varcnt error");
				set_interval(varcnt,smt_[i].lineno);
				if(judgeint(smt_[i].attr[1])==0){
					varcnt = find_a_vartab(smt_[i].attr[1]);
					if(varcnt==-1)
						generror("varcnt error");
					set_interval(varcnt,smt_[i].lineno);
				}
				if(judgeint(smt_[i].attr[2])==0){
					varcnt = find_a_vartab(smt_[i].attr[2]);
					if(varcnt==-1)
						generror("varcnt error");
					set_interval(varcnt,smt_[i].lineno);
				}
				break;
			case ASSIGN_RIGHT:
				varcnt = find_a_vartab(smt_[i].attr[0]);
				if(varcnt==-1)
					generror("varcnt error");
				set_interval(varcnt,smt_[i].lineno);
				varcnt = find_a_vartab(smt_[i].attr[1]);
				if(varcnt==-1)
					generror("varcnt error");
				set_interval(varcnt,smt_[i].lineno);
				if(judgeint(smt_[i].attr[2])==0){
					varcnt = find_a_vartab(smt_[i].attr[2]);
					if(varcnt==-1)
						generror("varcnt error");
					set_interval(varcnt,smt_[i].lineno);
				}
				break;
			case GOTO:
				break;
			case IF:
				if(judgeint(smt_[i].attr[0])==0){
					varcnt = find_a_vartab(smt_[i].attr[0]);
					if(varcnt==-1)
						generror("varcnt error");
					set_interval(varcnt,smt_[i].lineno);
				}
				if(judgeint(smt_[i].attr[1])==0){
					varcnt = find_a_vartab(smt_[i].attr[1]);
					if(varcnt==-1)
						generror("varcnt error");
					set_interval(varcnt,smt_[i].lineno);
				}
				break;
			case LABEL:
				break;
			case PARAM:
				if(judgeint(smt_[i].attr[0])==0){
					varcnt = find_a_vartab(smt_[i].attr[0]);
					if(varcnt==-1)
						generror("varcnt error");
					set_interval(varcnt,smt_[i].lineno);
				}
				break;
			case RETURN:
				if(judgeint(smt_[i].attr[0])==0){
					varcnt = find_a_vartab(smt_[i].attr[0]);
					if(varcnt==-1)
						generror("varcnt error");
					set_interval(varcnt,smt_[i].lineno);
				}
				break;
			default:
				fprintf(stderr,"Unknown EeyoreSMT %d.\n",smt_[i].type);
				break;
		}
	}
}

void sprint_op2(char *tigger,OP2Type op2){
	switch(op2){
		case AND:
			strcat(tigger," && ");
			break;
		case OR:
			strcat(tigger," || ");
			break;
		case EQ:
			strcat(tigger," == ");
			break;
		case NE:
			strcat(tigger," != ");
			break;
		case ADD:
			strcat(tigger," + ");
			break;
		case MINUS:
			strcat(tigger," - ");
			break;
		case MULTI:
			strcat(tigger," * ");
			break;
		case DIV:
			strcat(tigger," / ");
			break;
		case MOD:
			strcat(tigger," % ");
			break;
		case LESS:
			strcat(tigger," < ");
			break;
		case GREATER:
			strcat(tigger," > ");
			break;
		default:
			break;
	}
}

int find_a_vartab(char *name){
	if(name[0]=='p'){
		char tmp[40];
		sprintf(tmp,"%s-%s",state,name);
		for(int i=0;i<vartabcnt;i++){
			if(strcmp(tmp,vartab[i].name)==0)
				return i;
		}
	}
	else{
		for(int i=0;i<vartabcnt;i++){
			if(strcmp(name,vartab[i].name) == 0)
				return i;
		}
	}
	return -1;
}
int find_a_funcstack(char *name){
	for(int i=0;i<funccnt;i++){
		if(strcmp(name,funcstack[i].name) == 0)
			return i;
	}
	return -1;
}
int add_a_vartab(char *name){
	strcpy(vartab[vartabcnt].name,name);
	vartabcnt++;
	return vartabcnt-1;
}

void set_interval(int varid,int smtid){
	vartab[varid].end = smtid;
	if(vartab[varid].begin == -1){
		vartab[varid].begin = smtid;
	}
}

void load_a_int(char *tigger,char *num,int reg){ //add "reg = num"
	sprint_reg(tigger,reg);
	strcat(tigger," = ");
	strcat(tigger,num);
	strcat(tigger,"\n");
}
void load_a_address(char *tigger,int varid,int reg){  // add "loadaddr 0/v0 reg"
	VarTab *vt = &vartab[varid];
	strcat(tigger,"loadaddr ");
	char tmp[20] = "\0";
	if(vt->status==1){
		sprintf(tmp,"v%d ",vt->location);
	}
	else if(vt->status==0){
		sprintf(tmp,"%d",vt->location);
	}
	strcat(tigger,tmp);
	sprint_reg(tigger,reg);
	strcat(tigger,"\n");
}
void sprint_reg(char *tigger,int reg){
	char tmp_tigger[10] = "\0";
	if(reg==0){
		strcat(tigger,"x0");
		return;
	}
	else if(reg>=sreg+0 && reg<=sreg+11){
		sprintf(tmp_tigger,"s%d",reg-sreg);
		strcat(tigger,tmp_tigger);
		return;
	}
	else if(reg>=treg+0 && reg<=treg+6){
		sprintf(tmp_tigger,"t%d",reg-treg);
		strcat(tigger,tmp_tigger);
		return;
	}
	else if(reg>=areg+0 && reg<=areg+7){
		sprintf(tmp_tigger,"a%d",reg-areg);
		strcat(tigger,tmp_tigger);
		return;
	}
}
int judgeint(char *attr){
	if(attr[0]>='0' && attr[0]<='9')
		return 1;
	return 0;
}

void print_smt(){
	for(int i=0;i<smtcnt_;i++){
		printf("%d : %s %s %s\n",smt_[i].lineno,smt_[i].attr[0],smt_[i].attr[1],smt_[i].attr[2]);
	}
}
void print_interval(){
	for(int i=0;i<vartabcnt;i++){
		printf("%s : %d-%d\n",vartab[i].name,vartab[i].begin,vartab[i].end);
	}
}
void print_funcstack(){
	for(int i=0;i<funccnt;i++){
		printf("%s : vartsize %d spillsize %d\n",funcstack[i].name,funcstack[i].vartsize,funcstack[i].spillcnt);
	}
}
void print_tigger_code(){
	for(int i=0;i<smtcnt_;i++){
		if(smt_[i].type == F_BEGIN){
			char tmp[20] = "\0";
			int funcid = find_a_funcstack(smt_[i].attr[0]);
			sprintf(tmp,"[%d]\n",funcstack[funcid].spillcnt+funcstack[funcid].vartsize);
			strcat(smt_[i].tigger,tmp);
		}
		printf("%s",smt_[i].tigger);
	}
}
void generror(const char*msg){
	fprintf(stderr,"%s\n",msg);
}
