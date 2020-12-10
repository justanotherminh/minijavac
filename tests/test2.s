.data
.balign	4
str0:
	.asciz	"%d\n"
.text
.balign	4
.global	main
Sequences_init:
	push	{fp, lr}
	sub	sp, sp, #0
	mov	r0, #0
	bl	malloc
	add	sp, sp, #0
	mov	r2, r0
	mov	r0, r2
	pop	{fp, pc}
	bx	lr
Sequences_Fib:
	push	{fp, lr}
	str	r0, [sp, #-4]
	str	r1, [sp, #-8]
	ldr	r0, .int0
	str	r0, [sp, #-12]
	ldr	r0, [sp, #-8]
	ldr	r1, [sp, #-12]
	mov	r2, r1
	mov	r1, r0
	mov	r0, #0
	cmp	r1, r2
	movlt	r0, #1
	str	r0, [sp, #-16]
	ldr	r1, [sp, #-16]
	cmp	r1, #0
	beq	.endthen0
	ldr	r0, [sp, #-8]
	b	Sequences_Fib_return
	b	.endelse0
.endthen0:
	ldr	r0, .int1
	str	r0, [sp, #-20]
	ldr	r0, [sp, #-8]
	ldr	r1, [sp, #-20]
	sub	r0, r0, r1
	str	r0, [sp, #-24]
	ldr	r1, [sp, #-24]
	ldr	r0, [sp, #-4]
	sub	sp, sp, #24
	bl	Sequences_Fib
	add	sp, sp, #24
	str	r0, [sp, #-28]
	ldr	r0, .int0
	str	r0, [sp, #-32]
	ldr	r0, [sp, #-8]
	ldr	r1, [sp, #-32]
	sub	r0, r0, r1
	str	r0, [sp, #-36]
	ldr	r1, [sp, #-36]
	ldr	r0, [sp, #-4]
	sub	sp, sp, #36
	bl	Sequences_Fib
	add	sp, sp, #36
	str	r0, [sp, #-40]
	ldr	r0, [sp, #-28]
	ldr	r1, [sp, #-40]
	add	r0, r0, r1
	str	r0, [sp, #-44]
	ldr	r0, [sp, #-44]
	b	Sequences_Fib_return
.endelse0:
Sequences_Fib_return:
	pop	{fp, pc}
	bx	lr
Sequences_FibNoRC:
	push	{fp, lr}
	str	r0, [sp, #-4]
	str	r1, [sp, #-8]
	ldr	r0, .int1
	str	r0, [sp, #-12]
	ldr	r0, .int1
	str	r0, [sp, #-16]
	ldr	r0, .int2
	str	r0, [sp, #-20]
	b	.loopend1
.loopbegin1:
	ldr	r0, .int0
	str	r0, [sp, #-24]
	ldr	r0, [sp, #-20]
	ldr	r1, [sp, #-24]
	bl	__aeabi_idiv
	str	r0, [sp, #-28]
	ldr	r0, .int0
	str	r0, [sp, #-32]
	ldr	r0, [sp, #-28]
	ldr	r1, [sp, #-32]
	mul	r0, r0, r1
	str	r0, [sp, #-36]
	ldr	r0, [sp, #-20]
	ldr	r1, [sp, #-36]
	sub	r0, r0, r1
	str	r0, [sp, #-40]
	ldr	r0, .int1
	str	r0, [sp, #-44]
	ldr	r0, [sp, #-40]
	ldr	r1, [sp, #-44]
	sub	r0, r0, r1
	rsbs	r1, r0, #0
	adc	r0, r0, r1
	str	r0, [sp, #-48]
	ldr	r1, [sp, #-48]
	cmp	r1, #0
	beq	.endthen2
	ldr	r0, [sp, #-12]
	ldr	r1, [sp, #-16]
	add	r0, r0, r1
	str	r0, [sp, #-52]
	ldr	r1, [sp, #-52]
	str	r1, [sp, #-12]
	b	.endelse2
.endthen2:
	ldr	r0, [sp, #-12]
	ldr	r1, [sp, #-16]
	add	r0, r0, r1
	str	r0, [sp, #-52]
	ldr	r1, [sp, #-52]
	str	r1, [sp, #-16]
.endelse2:
	ldr	r0, .int1
	str	r0, [sp, #-52]
	ldr	r0, [sp, #-20]
	ldr	r1, [sp, #-52]
	add	r0, r0, r1
	str	r0, [sp, #-56]
	ldr	r1, [sp, #-56]
	str	r1, [sp, #-20]
.loopend1:
	ldr	r0, [sp, #-20]
	ldr	r1, [sp, #-8]
	mov	r2, r1
	mov	r1, r0
	mov	r0, #0
	cmp	r1, r2
	movle	r0, #1
	str	r0, [sp, #-24]
	ldr	r1, [sp, #-24]
	cmp	r1, #0
	bne	.loopbegin1
	ldr	r0, [sp, #-12]
	ldr	r1, [sp, #-16]
	mov	r2, r1
	mov	r1, r0
	mov	r0, #0
	cmp	r1, r2
	movgt	r0, #1
	str	r0, [sp, #-28]
	ldr	r1, [sp, #-28]
	cmp	r1, #0
	beq	.endthen3
	ldr	r0, [sp, #-12]
	b	Sequences_FibNoRC_return
	b	.endelse3
.endthen3:
	ldr	r0, [sp, #-16]
	b	Sequences_FibNoRC_return
.endelse3:
Sequences_FibNoRC_return:
	pop	{fp, pc}
	bx	lr
main:
	push	{fp, lr}
	str	r0, [sp, #-4]
	add	r1, r1, #4
	str	r1, [sp, #-8]
	mov	r0, #0
	str	r0, [sp, #-12]
	ldr	r0, =str0
	ldr	r1, [sp, #-12]
	sub	sp, sp, #12
	bl	printf
	add	sp, sp, #12
	ldr	r0, .int3
	str	r0, [sp, #-16]
	ldr	r1, [sp, #-16]
	lsl	r1, r1, #2
	ldr	r0, [sp, #-8]
	add	r0, r0, r1
	ldr	r0, [r0, #0]
	str	r0, [sp, #-20]
	ldr	r0, [sp, #-20]
	sub	sp, sp, #20
	bl	atoi
	add	sp, sp, #20
	str	r0, [sp, #-24]
	ldr	r1, [sp, #-24]
	str	r1, [sp, #-12]
	sub	sp, sp, #24
	bl	Sequences_init
	add	sp, sp, #24
	str	r0, [sp, #-28]
	ldr	r1, [sp, #-12]
	ldr	r0, [sp, #-28]
	sub	sp, sp, #28
	bl	Sequences_Fib
	add	sp, sp, #28
	str	r0, [sp, #-32]
	ldr	r0, =str0
	ldr	r1, [sp, #-32]
	sub	sp, sp, #32
	bl	printf
	add	sp, sp, #32
	sub	sp, sp, #32
	bl	Sequences_init
	add	sp, sp, #32
	str	r0, [sp, #-36]
	ldr	r1, [sp, #-12]
	ldr	r0, [sp, #-36]
	sub	sp, sp, #36
	bl	Sequences_FibNoRC
	add	sp, sp, #36
	str	r0, [sp, #-40]
	ldr	r0, =str0
	ldr	r1, [sp, #-40]
	sub	sp, sp, #40
	bl	printf
	add	sp, sp, #40
	pop	{fp, pc}
	bx	lr
.int3:
	.word	0
.int1:
	.word	1
.int0:
	.word	2
.int2:
	.word	3
