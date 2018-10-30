int getint();
int putchar(int c);
int putint(int i);
int getchar();
int a;
a = 0;
int b;
b = 0;
int f(int x){
	if(x < 2)
		return 1;
	else{
		a = x - 1;
		b = x - 2;
		return f(a) + f(b);
	}
}
int g(int x){
	int a[40];
	a[0] = 1;
	a[1] = 1;
	int i;
	i = b+4*5+a;
	while(i < x + 1){
		a[i] = a[i - 1] + a[i - 2];
		i = i + 1;
	}
	return a[x];
}
int n;
int main(){
	n = getint();
	if (n < 0 || n > 30)
		return 1; 
	putint(f(n));
	putchar(10);
	putint(g(n));
	putchar(10);
	return 0;
}
