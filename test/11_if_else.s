	.global	v0
	.section	.sdata
	.align	2
	.type	v0,@object
	.size	v0,4
v0:
	.word	0
	.text
	.align	2
	.global	main
	.type	main,@function
main:
	addi	sp,sp,-16
	sd	ra,12(sp)
	li	t0,10
	lui	t1,%hi(v0)
	add	t1,t1,%lo(v0)
	sw	t0,0(t1)
	sgt	t1,t0,x0
	beq	t1,x0,.l0
	li	a0,1
	ld	ra,12(sp)
	addi	sp,sp,16
	jr	ra
	j	.l1
.l0:
	mv	a0,x0
	ld	ra,12(sp)
	addi	sp,sp,16
	jr	ra
.l1:
	.size	main,.-main
