.data
.balign	4
.text
.balign	4
.global	main
main:
	push	{fp, lr}
	str	r0, [sp, #-4]
	add	r1, r1, #4
	str	r1, [sp, #-8]
	ldr	r0, .int0
	str	r0, [sp, #-12]
	ldr	r0, .int0
	str	r0, [sp, #-16]
	ldr	r0, [sp, #-12]
	mov	r5, r0
	add	r0, r0, #1
	lsl	r0, r0, #2
	sub	sp, sp, #16
	bl	malloc
	str	r5, [r0, #0]
	add	r0, r0, #4
	add	sp, sp, #16
	b	.matrixend0
.matrixbegin0:
	ldr	r0, [sp, #-16]
	mov	r6, r0
	add	r0, r0, #1
	lsl	r0, r0, #2
	sub	sp, sp, #16
	bl	malloc
	str	r6, [r0, #0]
	add	r0, r0, #4
	add	sp, sp, #16
	ldr	r4, [sp, #-20]
.matrixend0:
	add	r8, r8, #1
	cmp	r8, r5
	blt	.matrixbegin0
	ldr	r0, .int1
	str	r0, [sp, #-24]
	ldr	r0, .int1
	str	r0, [sp, #-28]
	b	.loopend1
.loopbegin1:
	b	.loopend2
.loopbegin2:
	ldr	r0, .int2
	str	r0, [sp, #-32]
	ldr	r1, [sp, #-28]
	lsl	r1, r1, #2
	ldr	r0, [sp, #-20]
	add	r0, r0, r1
	ldr	r2, [sp, #-32]
	str	r2, [r0, #0]
	ldr	r0, .int3
	str	r0, [sp, #-36]
	ldr	r0, [sp, #-28]
	ldr	r1, [sp, #-36]
	add	r0, r0, r1
	str	r0, [sp, #-40]
	ldr	r1, [sp, #-40]
	str	r1, [sp, #-28]
.loopend2:
	ldr	r0, .int0
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
	ldr	r0, .int3
	str	r0, [sp, #-40]
	ldr	r0, [sp, #-24]
	ldr	r1, [sp, #-40]
	add	r0, r0, r1
	str	r0, [sp, #-44]
	ldr	r1, [sp, #-44]
	str	r1, [sp, #-24]
.loopend1:
	ldr	r0, .int0
	str	r0, [sp, #-32]
	ldr	r0, [sp, #-24]
	ldr	r1, [sp, #-32]
	mov	r2, r1
	mov	r1, r0
	mov	r0, #0
	cmp	r1, r2
	movlt	r0, #1
	str	r0, [sp, #-36]
	ldr	r1, [sp, #-36]
	cmp	r1, #0
	bne	.loopbegin1
	pop	{fp, pc}
	bx	lr
.int3:
	.word	1
.int2:
	.word	3
.int0:
	.word	5
.int1:
	.word	0
