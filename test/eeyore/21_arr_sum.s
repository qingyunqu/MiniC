	.file	"21_arr_sum.c"
	.option nopic
	.comm	a,20,8
	.text
	.align	1
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-32
	sd	ra,24(sp)
	sd	s0,16(sp)
	addi	s0,sp,32
	call	getint
	mv	a5,a0
	mv	a4,a5
	lui	a5,%hi(a)
	sw	a4,%lo(a)(a5)
	call	getint
	mv	a5,a0
	mv	a4,a5
	lui	a5,%hi(a)
	addi	a5,a5,%lo(a)
	sw	a4,4(a5)
	call	getint
	mv	a5,a0
	mv	a4,a5
	lui	a5,%hi(a)
	addi	a5,a5,%lo(a)
	sw	a4,8(a5)
	call	getint
	mv	a5,a0
	mv	a4,a5
	lui	a5,%hi(a)
	addi	a5,a5,%lo(a)
	sw	a4,12(a5)
	call	getint
	mv	a5,a0
	mv	a4,a5
	lui	a5,%hi(a)
	addi	a5,a5,%lo(a)
	sw	a4,16(a5)
	li	a5,4
	sw	a5,-20(s0)
	sw	zero,-24(s0)
	j	.L2
.L3:
	lui	a5,%hi(a)
	lw	a4,-20(s0)
	slli	a4,a4,2
	addi	a5,a5,%lo(a)
	add	a5,a4,a5
	lw	a5,0(a5)
	lw	a4,-24(s0)
	addw	a5,a4,a5
	sw	a5,-24(s0)
	lw	a5,-20(s0)
	addiw	a5,a5,-1
	sw	a5,-20(s0)
.L2:
	lw	a5,-20(s0)
	sext.w	a4,a5
	li	a5,1
	bgt	a4,a5,.L3
	lw	a5,-24(s0)
	mv	a0,a5
	ld	ra,24(sp)
	ld	s0,16(sp)
	addi	sp,sp,32
	jr	ra
	.size	main, .-main
	.ident	"GCC: (GNU) 7.2.0"
