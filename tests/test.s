.data
.balign	4
str0:
	.asciz	"%d\n"
.text
.balign	4
.global	main
VectorOp_init:
	push	{fp, lr}
	sub	sp, sp, #0
	mov	r0, #0
	bl	malloc
	add	sp, sp, #0
	mov	r2, r0
	mov	r0, r2
	pop	{fp, pc}
	bx	lr
VectorOp_dotProduct:
	push	{fp, lr}
	str	r0, [sp, #-4]
	str	r1, [sp, #-8]
	str	r2, [sp, #-12]
	ldr	r0, .int0
	str	r0, [sp, #-16]
	ldr	r0, .int0
	str	r0, [sp, #-20]
	b	.loopend0
.loopbegin0:
	ldr	r1, [sp, #-20]
	lsl	r1, r1, #2
	ldr	r0, [sp, #-8]
	add	r0, r0, r1
	ldr	r0, [r0, #0]
	str	r0, [sp, #-24]
	ldr	r1, [sp, #-20]
	lsl	r1, r1, #2
	ldr	r0, [sp, #-12]
	add	r0, r0, r1
	ldr	r0, [r0, #0]
	str	r0, [sp, #-28]
	ldr	r0, [sp, #-24]
	ldr	r1, [sp, #-28]
	mul	r0, r0, r1
	str	r0, [sp, #-32]
	ldr	r0, [sp, #-16]
	ldr	r1, [sp, #-32]
	add	r0, r0, r1
	str	r0, [sp, #-36]
	ldr	r1, [sp, #-36]
	str	r1, [sp, #-16]
	ldr	r0, .int1
	str	r0, [sp, #-40]
	ldr	r0, [sp, #-20]
	ldr	r1, [sp, #-40]
	add	r0, r0, r1
	str	r0, [sp, #-44]
	ldr	r1, [sp, #-44]
	str	r1, [sp, #-20]
.loopend0:
	ldr	r0, [sp, #-8]
	ldr	r0, [r0, #-4]
	str	r0, [sp, #-24]
	ldr	r0, [sp, #-20]
	ldr	r1, [sp, #-24]
	mov	r2, r1
	mov	r1, r0
	mov	r0, #0
	cmp	r1, r2
	movlt	r0, #1
	str	r0, [sp, #-28]
	ldr	r1, [sp, #-28]
	cmp	r1, #0
	bne	.loopbegin0
	ldr	r0, [sp, #-16]
	b	VectorOp_dotProduct_return
VectorOp_dotProduct_return:
	pop	{fp, pc}
	bx	lr
VectorOp_elemProduct:
	push	{fp, lr}
	str	r0, [sp, #-4]
	str	r1, [sp, #-8]
	str	r2, [sp, #-12]
	ldr	r0, [sp, #-8]
	ldr	r0, [r0, #-4]
	str	r0, [sp, #-16]
	ldr	r0, [sp, #-16]
	mov	r5, r0
	add	r0, r0, #1
	lsl	r0, r0, #2
	sub	sp, sp, #16
	bl	malloc
	str	r5, [r0, #0]
	add	r0, r0, #4
	add	sp, sp, #16
	str	r0, [sp, #-20]
	ldr	r0, .int0
	str	r0, [sp, #-24]
	b	.loopend1
.loopbegin1:
	ldr	r1, [sp, #-24]
	lsl	r1, r1, #2
	ldr	r0, [sp, #-8]
	add	r0, r0, r1
	ldr	r0, [r0, #0]
	str	r0, [sp, #-28]
	ldr	r1, [sp, #-24]
	lsl	r1, r1, #2
	ldr	r0, [sp, #-12]
	add	r0, r0, r1
	ldr	r0, [r0, #0]
	str	r0, [sp, #-32]
	ldr	r0, [sp, #-28]
	ldr	r1, [sp, #-32]
	mul	r0, r0, r1
	str	r0, [sp, #-36]
	ldr	r1, [sp, #-24]
	lsl	r1, r1, #2
	ldr	r0, [sp, #-20]
	add	r0, r0, r1
	ldr	r2, [sp, #-36]
	str	r2, [r0, #0]
	ldr	r0, .int1
	str	r0, [sp, #-40]
	ldr	r0, [sp, #-24]
	ldr	r1, [sp, #-40]
	add	r0, r0, r1
	str	r0, [sp, #-44]
	ldr	r1, [sp, #-44]
	str	r1, [sp, #-24]
.loopend1:
	ldr	r0, [sp, #-8]
	ldr	r0, [r0, #-4]
	str	r0, [sp, #-28]
	ldr	r0, [sp, #-24]
	ldr	r1, [sp, #-28]
	mov	r2, r1
	mov	r1, r0
	mov	r0, #0
	cmp	r1, r2
	movlt	r0, #1
	str	r0, [sp, #-32]
	ldr	r1, [sp, #-32]
	cmp	r1, #0
	bne	.loopbegin1
	ldr	r0, [sp, #-20]
	b	VectorOp_elemProduct_return
VectorOp_elemProduct_return:
	pop	{fp, pc}
	bx	lr
main:
	push	{fp, lr}
	str	r0, [sp, #-4]
	add	r1, r1, #4
	str	r1, [sp, #-8]
	ldr	r0, .int2
	str	r0, [sp, #-12]
	ldr	r0, [sp, #-12]
	mov	r5, r0
	add	r0, r0, #1
	lsl	r0, r0, #2
	sub	sp, sp, #12
	bl	malloc
	str	r5, [r0, #0]
	add	r0, r0, #4
	add	sp, sp, #12
	str	r0, [sp, #-16]
	ldr	r0, .int2
	str	r0, [sp, #-20]
	ldr	r0, [sp, #-20]
	mov	r5, r0
	add	r0, r0, #1
	lsl	r0, r0, #2
	sub	sp, sp, #20
	bl	malloc
	str	r5, [r0, #0]
	add	r0, r0, #4
	add	sp, sp, #20
	str	r0, [sp, #-24]
	ldr	r0, .int0
	str	r0, [sp, #-28]
	b	.loopend2
.loopbegin2:
	ldr	r1, [sp, #-28]
	lsl	r1, r1, #2
	ldr	r0, [sp, #-16]
	add	r0, r0, r1
	ldr	r2, [sp, #-28]
	str	r2, [r0, #0]
	ldr	r0, .int3
	str	r0, [sp, #-32]
	ldr	r0, [sp, #-32]
	ldr	r1, [sp, #-28]
	sub	r0, r0, r1
	str	r0, [sp, #-36]
	ldr	r1, [sp, #-28]
	lsl	r1, r1, #2
	ldr	r0, [sp, #-24]
	add	r0, r0, r1
	ldr	r2, [sp, #-36]
	str	r2, [r0, #0]
	ldr	r0, .int1
	str	r0, [sp, #-40]
	ldr	r0, [sp, #-28]
	ldr	r1, [sp, #-40]
	add	r0, r0, r1
	str	r0, [sp, #-44]
	ldr	r1, [sp, #-44]
	str	r1, [sp, #-28]
.loopend2:
	ldr	r0, [sp, #-16]
	ldr	r0, [r0, #-4]
	str	r0, [sp, #-32]
	ldr	r0, [sp, #-28]
	ldr	r1, [sp, #-32]
	mov	r2, r1
	mov	r1, r0
	mov	r0, #0
	cmp	r1, r2
	movlt	r0, #1
	str	r0, [sp, #-36]
	ldr	r1, [sp, #-36]
	cmp	r1, #0
	bne	.loopbegin2
	sub	sp, sp, #36
	bl	VectorOp_init
	add	sp, sp, #36
	str	r0, [sp, #-40]
	ldr	r1, [sp, #-16]
	ldr	r2, [sp, #-24]
	ldr	r0, [sp, #-40]
	sub	sp, sp, #40
	bl	VectorOp_dotProduct
	add	sp, sp, #40
	str	r0, [sp, #-44]
	ldr	r0, =str0
	ldr	r1, [sp, #-44]
	sub	sp, sp, #44
	bl	printf
	add	sp, sp, #44
	sub	sp, sp, #44
	bl	VectorOp_init
	add	sp, sp, #44
	str	r0, [sp, #-48]
	ldr	r1, [sp, #-16]
	ldr	r2, [sp, #-24]
	ldr	r0, [sp, #-48]
	sub	sp, sp, #48
	bl	VectorOp_elemProduct
	add	sp, sp, #48
	str	r0, [sp, #-52]
	ldr	r0, .int0
	str	r0, [sp, #-56]
	ldr	r1, [sp, #-56]
	str	r1, [sp, #-28]
	b	.loopend3
.loopbegin3:
	ldr	r1, [sp, #-28]
	lsl	r1, r1, #2
	ldr	r0, [sp, #-52]
	add	r0, r0, r1
	ldr	r0, [r0, #0]
	str	r0, [sp, #-60]
	ldr	r0, =str0
	ldr	r1, [sp, #-60]
	sub	sp, sp, #60
	bl	printf
	add	sp, sp, #60
	ldr	r0, .int1
	str	r0, [sp, #-64]
	ldr	r0, [sp, #-28]
	ldr	r1, [sp, #-64]
	add	r0, r0, r1
	str	r0, [sp, #-68]
	ldr	r1, [sp, #-68]
	str	r1, [sp, #-28]
.loopend3:
	ldr	r0, [sp, #-16]
	ldr	r0, [r0, #-4]
	str	r0, [sp, #-60]
	ldr	r0, [sp, #-28]
	ldr	r1, [sp, #-60]
	mov	r2, r1
	mov	r1, r0
	mov	r0, #0
	cmp	r1, r2
	movlt	r0, #1
	str	r0, [sp, #-64]
	ldr	r1, [sp, #-64]
	cmp	r1, #0
	bne	.loopbegin3
	pop	{fp, pc}
	bx	lr
.int0:
	.word	0
.int1:
	.word	1
.int3:
	.word	9
.int2:
	.word	10
