int getint();
int a[5];
int main(){
	a[0] = getint();
	a[1] = getint();
	int cnt;
	cnt = 1;
	int sum;
	sum = 0;
	while( cnt > -1 ){
		sum = sum + a[cnt];
		cnt = cnt - 1;
	}
	cnt = putint(sum);
	return sum;
}
