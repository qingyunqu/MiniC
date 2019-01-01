	.file	"11_if_else.c"
	.option nopic
	.comm	a,4,4
	.text
	.align	1
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-16
	sd	s0,8(sp)
	addi	s0,sp,16
	lui	a5,%hi(a)
	li	a4,10
	sw	a4,%lo(a)(a5)
	lui	a5,%hi(a)
	lw	a5,%lo(a)(a5)
	blez	a5,.L2
	li	a5,1
	j	.L3
.L2:
	li	a5,0
.L3:
	mv	a0,a5
	ld	s0,8(sp)
	addi	sp,sp,16
	jr	ra
	.size	main, .-main
	.ident	"GCC: (GNU) 7.2.0"
