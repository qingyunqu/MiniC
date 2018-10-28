int getint();
int putchar(int c);
int putint(int i);
int getchar();
int a;
a = 0;
int b;
b = 0;
int f(int x){
	return x;
}
int a[40];
a[0] = 1;
a[1] = 1;
int n;
int main(){
	n = getint();
	putint(f(n));
	putint(10);
	return 0;
}
