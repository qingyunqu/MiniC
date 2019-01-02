#include <stdio.h>
#include <string.h>
#include "typedefine.h"

extern FILE* optimize_in;
extern FILE* optimize_out;

SMT smt[4000];
int smt_cnt = 0;

int optimize_status = 0;// 0 for no optimization; 1 for optimized

void out_optimize_smt();

void print_origin_smt(){
	printf("smt_cnt: %d\n",smt_cnt);
	for(int i=0;i<smt_cnt;i++){
		printf("%s\n",smt[i].text);
		printf("%s %s %s %s\n",smt[i].attr[0],smt[i].attr[1],smt[i].attr[2],smt[i].attr[3]);
	}
}
int is_integer(char *str){
	if(str[0]>='0' && str[0]<='9')
		return 1;
	return 0;
}

void init_smt(SMT* smt_){
	//smt_->status = 1;

	char tmp[6][FUNCMAXSIZE];
	sscanf(smt_->text,"%s",tmp[0]);
	switch(tmp[0][0]){
		case 'v':
			sscanf(smt_->text,"%s %s",tmp[0],tmp[1]);
			if(is_integer(tmp[1])){
				sscanf(smt_->text,"%s %s %s",tmp[0],tmp[1],tmp[2]);
				smt_->type = VART;
				strcpy(smt_->attr[0],tmp[1]);
				strcpy(smt_->attr[1],tmp[2]);
			}
			else{
				smt_->type = VAR;
				strcpy(smt_->attr[0],tmp[1]);
			}
			break;
		case 'f':
			sscanf(smt_->text,"%s %s",tmp[0],tmp[1]);
			smt_->type = FUNCBEGIN;
			strcpy(smt_->attr[0],tmp[0]);
			strcpy(smt_->attr[1],tmp[1]);
			break;
		case 'e':
			sscanf(smt_->text,"%s %s",tmp[0],tmp[1]);
			smt_->type = FUNCEND;
			strcpy(smt_->attr[0],tmp[1]);
			break;
		case 'i':
			sscanf(smt_->text,"%s %s %s %s %s %s",tmp[0],tmp[1],tmp[2],tmp[3],tmp[4],tmp[5]);
			smt_->type = IF;
			strcpy(smt_->attr[0],tmp[1]);
			strcpy(smt_->attr[1],tmp[2]);
			strcpy(smt_->attr[2],tmp[3]);
			strcpy(smt_->attr[3],tmp[5]);
			break;
		case 'g':
			sscanf(smt_->text,"%s %s",tmp[0],tmp[1]);
			smt_->type = GOTO;
			strcpy(smt_->attr[0],tmp[1]);
			break;
		case 'l':
			smt_->type = LABEL;
			strcpy(smt_->attr[0],tmp[0]);
			break;
		case 'p':
			sscanf(smt_->text,"%s %s",tmp[0],tmp[1]);
			smt_->type = PARAM;
			strcpy(smt_->attr[0],tmp[1]);
			break;
		case 'r':
			sscanf(smt_->text,"%s %s",tmp[0],tmp[1]);
			smt_->type = RETURN;
			strcpy(smt_->attr[0],tmp[1]);
			break;
		case 't':
		case 'T':
			sscanf(smt_->text,"%s %s %s",tmp[0],tmp[1],tmp[2]);
			if(tmp[1][0]=='['){
				sscanf(smt_->text,"%s %s %s %s",tmp[0],tmp[1],tmp[2],tmp[3]);
				smt_->type = ASSIGN_LEFT;
				strcpy(smt_->attr[0],tmp[0]);
				strcpy(smt_->attr[1],&tmp[1][1]);
				smt_->attr[1][strlen(smt_->attr[1])-1] = '\0';  // remove ']'
				strcpy(smt_->attr[2],tmp[3]);
			}
			else if(tmp[1][0]=='='){
				if(tmp[2][0]=='c'){
					sscanf(smt_->text,"%s %s %s %s",tmp[0],tmp[1],tmp[2],tmp[3]);
					smt_->type = CALL;
					strcpy(smt_->attr[0],tmp[0]);
					strcpy(smt_->attr[1],tmp[3]);
				}
				else if(tmp[2][0]=='-' || tmp[2][0]=='!'){
					sscanf(smt_->text,"%s %s %s %s",tmp[0],tmp[1],tmp[2],tmp[3]);
					smt_->type = OP1;
					strcpy(smt_->attr[0],tmp[0]);
					strcpy(smt_->attr[1],tmp[2]);
					strcpy(smt_->attr[2],tmp[3]);
				}
				else if(tmp[2][0]=='t' || tmp[2][0]=='T' || is_integer(tmp[2])){
					if(strlen(tmp[0])+strlen(tmp[1])+strlen(tmp[2])+2==strlen(smt_->text)){
						smt_->type = ASSIGN;
						strcpy(smt_->attr[0],tmp[0]);
						strcpy(smt_->attr[1],tmp[2]);
					}
					else{
						sscanf(smt_->text,"%s %s %s %s",tmp[0],tmp[1],tmp[2],tmp[3]);
						if(tmp[3][0]=='['){
							smt_->type = ASSIGN_RIGHT;
							strcpy(smt_->attr[0],tmp[0]);
							strcpy(smt_->attr[1],tmp[2]);
							strcpy(smt_->attr[2],&tmp[3][1]);
							smt_->attr[2][strlen(smt_->attr[2])-1] = '\0'; // remove ']'
						}
						else{
							sscanf(smt_->text,"%s %s %s %s %s",tmp[0],tmp[1],tmp[2],tmp[3],tmp[4]);
							smt_->type = OP2;
							strcpy(smt_->attr[0],tmp[0]);
							strcpy(smt_->attr[1],tmp[2]);
							strcpy(smt_->attr[2],tmp[3]);
							strcpy(smt_->attr[3],tmp[4]);
						}
					}
				}
			}
	}
}

void get_origin_statement()
{
	while(fscanf(optimize_in,"%[^\n]\n",smt[smt_cnt].text) != EOF)
		smt_cnt++;
	for(int i=0;i<smt_cnt;i++){
		init_smt(&smt[i]);
	}
}

int do_constant_op2(char* num1,char* op2,char* num2)
{
	int num11,num22;
	sscanf(num1,"%d",&num11);
	sscanf(num2,"%d",&num22);
	switch(op2[0]){
		case '+':
			return num11 + num22;
		case '-':
			return num11 - num22;
		case '*':
			return num11 * num22;
		case '/':
			return num11 / num22;
		case '%':
			return num11 % num22;
		case '<':
			return num11 < num22;
		case '>':
			return num11 > num22;
		case '&':
			if(op2[1]=='&')
				return num11 && num22;
		case '|':
			if(op2[1]=='|')
				return num11 || num22;
		case '!':
			if(op2[1]=='=')
				return num11 != num22;
		case '=':
			if(op2[1]=='=')
				return num11 == num22;
	}
}
void constant_calculation(int b_index,int e_index) // how to optimize negtive number?
{
	for(int i=b_index;i<=e_index;i++){  // calculate the answer
		//if(smt[i].status == 0)
		//	continue;
		SMT* smt1 = &smt[i];
		if(smt1->type==OP2){
			if(is_integer(smt1->attr[1]) && is_integer(smt1->attr[3])){
				int constant = do_constant_op2(smt1->attr[1],smt1->attr[2],smt1->attr[3]);
				smt1->type = ASSIGN;
				sprintf(smt1->attr[1],"%d",constant);
				optimize_status = 1;
			}
		}
		else if(smt1->type==OP1){
			if(smt1->attr[1][0]=='!' && is_integer(smt1->attr[2])){
				int constant;
				sscanf(smt1->attr[2],"%d",&constant);
				constant = ! constant;
				smt1->type = ASSIGN;
				sprintf(smt1->attr[1],"%d",constant);
				optimize_status = 1;
			}
		}
	}
}

int is_left(char* variable,SMT* smt1){
	if((smt1->type==OP2 || smt1->type==OP1 || smt1->type==ASSIGN || smt1->type==ASSIGN_LEFT || smt1->type==ASSIGN_RIGHT || smt1->type == CALL) && (strcmp(variable,smt1->attr[0])==0))
		return 1;
	return 0;
}

void constant_propagation_block(int b_index,int e_index){ // also copy_propagation
	if(b_index >= e_index)
		return;
	for(int i=b_index;i<e_index;i++){
		//if(smt[i].status==0)
		//	continue;
		if(smt[i].type==ASSIGN){// && is_integer(smt[i].attr[1])){
			for(int j=i+1;j<=e_index;j++){
				if(smt[j].type==NONE)
					continue;
				if(is_left(smt[i].attr[0],&smt[j]))
					break;
				switch(smt[j].type){
					case OP2:
						if(strcmp(smt[i].attr[0],smt[j].attr[1])==0){
							sprintf(smt[j].attr[1],"%s",smt[i].attr[1]);
							optimize_status = 1;
						}
						if(strcmp(smt[i].attr[0],smt[j].attr[3])==0){
							sprintf(smt[j].attr[3],"%s",smt[i].attr[1]);
							optimize_status = 1;
						}
						break;
					case OP1:
						if(strcmp(smt[i].attr[0],smt[j].attr[2])==0){
							sprintf(smt[j].attr[2],"%s",smt[i].attr[1]);
							optimize_status = 1;
						}
						break;
					case ASSIGN:
						if(strcmp(smt[i].attr[0],smt[j].attr[1])==0){
							sprintf(smt[j].attr[1],"%s",smt[i].attr[1]);
							optimize_status = 1;
						}
						break;
					case ASSIGN_LEFT:
						if(strcmp(smt[i].attr[0],smt[j].attr[1])==0){
							sprintf(smt[j].attr[1],"%s",smt[i].attr[1]);
							optimize_status = 1;
						}
						if(strcmp(smt[i].attr[0],smt[j].attr[2])==0){
							sprintf(smt[j].attr[2],"%s",smt[i].attr[1]);
							optimize_status = 1;
						}
						break;
					case ASSIGN_RIGHT:
						if(strcmp(smt[i].attr[0],smt[j].attr[2])==0){
							sprintf(smt[j].attr[2],"%s",smt[i].attr[1]);
							optimize_status = 1;
						}
						// variable [rightvalue]  variable ??
						break;
					case IF:
						if(strcmp(smt[i].attr[0],smt[j].attr[0])==0){
							sprintf(smt[j].attr[0],"%s",smt[i].attr[1]);
							optimize_status = 1;
						}
						if(strcmp(smt[i].attr[0],smt[j].attr[2])==0){
							sprintf(smt[j].attr[2],"%s",smt[i].attr[1]);
							optimize_status = 1;
						}
						break;
					case PARAM:
						if(strcmp(smt[i].attr[0],smt[j].attr[0])==0){
							sprintf(smt[j].attr[0],"%s",smt[i].attr[1]);
							optimize_status = 1;
						}
						break;
					case RETURN:
						if(strcmp(smt[i].attr[0],smt[j].attr[0])==0){
							sprintf(smt[j].attr[0],"%s",smt[i].attr[1]);
							optimize_status = 1;
						}
						break;
					default:
						break;
				}
			}
		}
	}
}

int is_right(char* variable,SMT* smt1){
	switch(smt1->type){
		case OP2:
			if(strcmp(variable,smt1->attr[1])==0 || strcmp(variable,smt1->attr[3])==0)
				return 1;
			return 0;
		case OP1:
			if(strcmp(variable,smt1->attr[2])==0)
				return 1;
			return 0;
		case ASSIGN:
			if(strcmp(variable,smt1->attr[1])==0)
				return 1;
			return 0;
		case ASSIGN_LEFT:
			if(strcmp(variable,smt1->attr[1])==0 || strcmp(variable,smt1->attr[2])==0)
				return 1;
			return 0;
		case ASSIGN_RIGHT:
			if(strcmp(variable,smt1->attr[1])==0 || strcmp(variable,smt1->attr[2])==0)
				return 1;
			return 0;
		case IF:
			if(strcmp(variable,smt1->attr[0])==0 || strcmp(variable,smt1->attr[2])==0)
				return 1;
			return 0;
		case PARAM:
			if(strcmp(variable,smt1->attr[0])==0)
				return 1;
			return 0;
		case RETURN:
			if(strcmp(variable,smt1->attr[0])==0)
				return 1;
			return 0;
		default:
			return 0;
	}
}

void remove_unused_t(int b_index,int e_index){  // like "var t1", not "var T2" or "var 40 T3"
	if(b_index >= e_index)
		return;
	for(int i=b_index;i<e_index;i++){
		//if(smt[i].status==0)
		//	continue;
		if(smt[i].type==VAR && smt[i].attr[0][0]=='t'){
			int left_flag = -1;
			int right_flag = -1;
			for(int j=i+1;j<=e_index;j++){
				if(smt[j].type==NONE)
					continue;
				if(is_right(smt[i].attr[0],&smt[j]))
					right_flag = j;
				if(is_left(smt[i].attr[0],&smt[j]))
					left_flag = j;
			}
			//printf("right_flag: %d\nleft_flag: %d\n",right_flag,left_flag);
			if(right_flag == -1){
				smt[i].type = NONE;
				optimize_status = 1;
			}
			if(right_flag<left_flag && left_flag!=-1){
				for(int j=left_flag;j<=e_index;j++){
					if(smt[j].type==NONE)
						continue;
					if(is_left(smt[i].attr[0],&smt[j])){
						smt[j].type = NONE;
						optimize_status = 1;
					}
				}
			}
		}
	}
}
void reverse_propagation_block(int b_index,int e_index){ // OP or CALL + ASSIGN
	if(b_index >= e_index)
		return;
	for(int i=b_index;i<e_index;i++){
		if(smt[i].type==NONE)
			continue;
		if((smt[i].type==OP2 || smt[i].type==OP1 || smt[i].type==CALL) && smt[i+1].type==ASSIGN && strcmp(smt[i].attr[0],smt[i+1].attr[1])==0){
			smt[i+1].type=NONE;
			sprintf(smt[i].attr[0],"%s",smt[i+1].attr[0]);
			optimize_status = 1;
		}
	}
}

void do_optimize_block(int b_index,int e_index) // how to optimize through the whole block ???
{
	if(b_index >= e_index)
		return;
	int block_index = b_index;
	for(int i=b_index;i<=e_index;i++){  // optimize block by block
		if(smt[i].type == IF){
			constant_propagation_block(block_index,i);
			remove_unused_t(block_index,i);
			reverse_propagation_block(block_index,i);
			block_index = i+1;
		}
		if(smt[i].type == GOTO){
			constant_propagation_block(block_index,i-1);
			remove_unused_t(block_index,i-1);
			reverse_propagation_block(block_index,i-1);
			block_index = i+1;
		}
		if(smt[i].type == LABEL){
			constant_propagation_block(block_index,i-1);
			remove_unused_t(block_index,i-1);
			reverse_propagation_block(block_index,i-1);
			block_index = i+1;
		}
	}
	if(block_index <= e_index){
		constant_propagation_block(block_index,e_index);
		remove_unused_t(block_index,e_index);
		reverse_propagation_block(block_index,e_index);
	}
}

void do_optimize(int b_index,int e_index) // the very optimization
{
	constant_calculation(b_index,e_index);
	do_optimize_block(b_index,e_index);
	// OP or call + ASSIGN
	// if reduce calculate
}

void begin_optimize()
{
	for(int i=0;i<smt_cnt;i++){
		if(smt[i].type==FUNCBEGIN){
			int j;
			for(j=i+1;j<smt_cnt;j++)
				if(smt[j].type==FUNCEND)
					break;
			if(i+1>j-1) // no statement
				continue;

			do{
				optimize_status = 0;
				do_optimize(i+1,j-1);
				//out_optimize_smt();
				//printf("\n");
			}while(optimize_status);
		}
	}
}

void optimize()
{
	get_origin_statement();
	//print_origin_smt();
	begin_optimize();
	out_optimize_smt();
}

void out_optimize_smt()
{
	for(int i=0;i<smt_cnt;i++){
		//if(smt[i].status==0)
		//	continue;
		SMT* smt1 = &smt[i];
		switch(smt1->type){
			case VAR:
				fprintf(optimize_out,"var %s\n",smt1->attr[0]);
				break;
			case VART:
				fprintf(optimize_out,"var %s %s\n",smt1->attr[0],smt1->attr[1]);
				break;
			case FUNCBEGIN:
				fprintf(optimize_out,"%s %s\n",smt1->attr[0],smt1->attr[1]);
				break;
			case FUNCEND:
				fprintf(optimize_out,"end %s\n",smt1->attr[0]);
				break;
			case OP2:
				fprintf(optimize_out,"%s = %s %s %s\n",smt1->attr[0],smt1->attr[1],smt1->attr[2],smt1->attr[3]);
				break;
			case OP1:
				fprintf(optimize_out,"%s = %s %s\n",smt1->attr[0],smt1->attr[1],smt1->attr[2]);
				break;
			case ASSIGN:
				fprintf(optimize_out,"%s = %s\n",smt1->attr[0],smt1->attr[1]);
				break;
			case ASSIGN_LEFT:
				fprintf(optimize_out,"%s [%s] = %s\n",smt1->attr[0],smt1->attr[1],smt1->attr[2]);
				break;
			case ASSIGN_RIGHT:
				fprintf(optimize_out,"%s = %s [%s]\n",smt1->attr[0],smt1->attr[1],smt1->attr[2]);
				break;
			case CALL:
				fprintf(optimize_out,"%s = call %s\n",smt1->attr[0],smt1->attr[1]);
				break;
			case IF:
				fprintf(optimize_out,"if %s %s %s goto %s\n",smt1->attr[0],smt1->attr[1],smt1->attr[2],smt1->attr[3]);
				break;
			case GOTO:
				fprintf(optimize_out,"goto %s\n",smt1->attr[0]);
				break;
			case LABEL:
				fprintf(optimize_out,"%s\n",smt1->attr[0]);
				break;
			case PARAM:
				fprintf(optimize_out,"param %s\n",smt1->attr[0]);
				break;
			case RETURN:
				fprintf(optimize_out,"return %s\n",smt1->attr[0]);
				break;
			case NONE:
				break;
			default:
				break;
		}
	}
} 
