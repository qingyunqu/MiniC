	.text
	.align	2
	.global	main
	.type	main,@function
main:
	addi	sp,sp,-16
	sd	ra,12(sp)
	mv	a0,x0
	ld	ra,12(sp)
	addi	sp,sp,16
	jr	ra
	.size	main,.-main
