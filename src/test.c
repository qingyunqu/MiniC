int getint();
int putint(int x);
int n;
int a[10];
int f(int m,int mm){
	n = putint(m+mm);
}
int main(){
	n = getint();
	if(n>10)
		return 1;
	int s;
	int i;
	i = 0;
	s = i;
	while(i<n){
		a[i] = getint();
		s = s+a[i];
		i = i+1;
	}
	n = putint(s);
	n = f(s,i);
	return 0;
}
