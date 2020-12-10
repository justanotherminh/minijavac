.data
.balign	4
str0:
	.asciz	"%d\n"
.text
.balign	4
.global	main
RandomGenerator_init:
	push	{fp, lr}
	mov	r0, #0
	str	r0, [sp, #-4]
	ldr	r0, .int0
	str	r0, [sp, #-8]
	ldr	r0, .int1
	str	r0, [sp, #-12]
	ldr	r0, .int2
	str	r0, [sp, #-16]
	sub	sp, sp, #16
	mov	r0, #16
	bl	malloc
	add	sp, sp, #16
	mov	r2, r0
	ldr	r0, [sp, #-12]
	str	r0, [r2, #8]
	ldr	r0, [sp, #-8]
	str	r0, [r2, #4]
	ldr	r0, [sp, #-16]
	str	r0, [r2, #12]
	ldr	r0, [sp, #-4]
	str	r0, [r2, #0]
	mov	r0, r2
	pop	{fp, pc}
	bx	lr
RandomGenerator_setSeed:
	push	{fp, lr}
	str	r0, [sp, #-4]
	str	r1, [sp, #-8]
	ldr	r0, [sp, #-4]
	add	r0, r0, #0
	ldr	r2, [sp, #-8]
	str	r2, [r0, #0]
	ldr	r0, .int3
	str	r0, [sp, #-12]
	ldr	r0, [sp, #-12]
	b	RandomGenerator_setSeed_return
RandomGenerator_setSeed_return:
	pop	{fp, pc}
	bx	lr
RandomGenerator_sample:
	push	{fp, lr}
	str	r0, [sp, #-4]
	ldr	r0, [sp, #-4]
	ldr	r0, [r0, #8]
	str	r0, [sp, #-8]
	ldr	r0, [sp, #-4]
	ldr	r0, [r0, #0]
	str	r0, [sp, #-12]
	ldr	r0, [sp, #-8]
	ldr	r1, [sp, #-12]
	mul	r0, r0, r1
	str	r0, [sp, #-16]
	ldr	r0, [sp, #-4]
	ldr	r0, [r0, #4]
	str	r0, [sp, #-20]
	ldr	r0, [sp, #-16]
	ldr	r1, [sp, #-20]
	add	r0, r0, r1
	str	r0, [sp, #-24]
	ldr	r1, [sp, #-24]
	ldr	r0, [sp, #-4]
	str	r1, [r0, #0]
	ldr	r0, [sp, #-4]
	ldr	r0, [r0, #0]
	str	r0, [sp, #-28]
	ldr	r0, [sp, #-4]
	ldr	r0, [r0, #0]
	str	r0, [sp, #-32]
	ldr	r0, [sp, #-4]
	ldr	r0, [r0, #12]
	str	r0, [sp, #-36]
	ldr	r0, [sp, #-32]
	ldr	r1, [sp, #-36]
	bl	__aeabi_idiv
	str	r0, [sp, #-40]
	ldr	r0, [sp, #-4]
	ldr	r0, [r0, #12]
	str	r0, [sp, #-44]
	ldr	r0, [sp, #-40]
	ldr	r1, [sp, #-44]
	mul	r0, r0, r1
	str	r0, [sp, #-48]
	ldr	r0, [sp, #-28]
	ldr	r1, [sp, #-48]
	sub	r0, r0, r1
	str	r0, [sp, #-52]
	ldr	r1, [sp, #-52]
	ldr	r0, [sp, #-4]
	str	r1, [r0, #0]
	ldr	r0, [sp, #-4]
	ldr	r0, [r0, #0]
	str	r0, [sp, #-56]
	ldr	r0, [sp, #-56]
	b	RandomGenerator_sample_return
RandomGenerator_sample_return:
	pop	{fp, pc}
	bx	lr
main:
	push	{fp, lr}
	str	r0, [sp, #-4]
	add	r1, r1, #4
	str	r1, [sp, #-8]
	sub	sp, sp, #8
	bl	RandomGenerator_init
	add	sp, sp, #8
	str	r0, [sp, #-12]
	ldr	r0, .int4
	str	r0, [sp, #-16]
	ldr	r1, [sp, #-16]
	ldr	r0, [sp, #-12]
	sub	sp, sp, #16
	bl	RandomGenerator_setSeed
	add	sp, sp, #16
	ldr	r0, .int3
	str	r0, [sp, #-20]
	b	.loopend0
.loopbegin0:
	ldr	r0, [sp, #-12]
	sub	sp, sp, #20
	bl	RandomGenerator_sample
	add	sp, sp, #20
	str	r0, [sp, #-24]
	ldr	r0, =str0
	ldr	r1, [sp, #-24]
	sub	sp, sp, #24
	bl	printf
	add	sp, sp, #24
	ldr	r0, .int5
	str	r0, [sp, #-28]
	ldr	r0, [sp, #-20]
	ldr	r1, [sp, #-28]
	add	r0, r0, r1
	str	r0, [sp, #-32]
	ldr	r1, [sp, #-32]
	str	r1, [sp, #-20]
.loopend0:
	ldr	r0, .int6
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
	pop	{fp, pc}
	bx	lr
.int3:
	.word	0
.int5:
	.word	1
.int4:
	.word	23
.int6:
	.word	100
.int1:
	.word	8121
.int0:
	.word	28411
.int2:
	.word	134456
