.data
.balign	4
str0:
	.asciz	"%d\n"
.text
.balign	4
.global	main
Foo_init:
	push	{fp, lr}
	mov	r0, #0
	str	r0, [sp, #-4]
	sub	sp, sp, #4
	mov	r0, #4
	bl	malloc
	add	sp, sp, #4
	mov	r2, r0
	ldr	r0, [sp, #-4]
	str	r0, [r2, #0]
	mov	r0, r2
	pop	{fp, pc}
	bx	lr
Foo_foo:
	push	{fp, lr}
	str	r0, [sp, #-4]
	str	r1, [sp, #-8]
	ldr	r0, [sp, #-8]
	mov	r5, r0
	add	r0, r0, #1
	lsl	r0, r0, #2
	sub	sp, sp, #8
	bl	malloc
	str	r5, [r0, #0]
	add	r0, r0, #4
	add	sp, sp, #8
	str	r0, [sp, #-12]
	ldr	r1, [sp, #-12]
	ldr	r0, [sp, #-4]
	str	r1, [r0, #0]
	ldr	r0, .int0
	str	r0, [sp, #-16]
	b	.loopend0
.loopbegin0:
	ldr	r0, [sp, #-4]
	add	r0, r0, #0
	str	r0, [sp, #-20]
	ldr	r1, [sp, #-16]
	lsl	r1, r1, #2
	ldr	r0, [sp, #-20]
	add	r0, r0, r1
	ldr	r2, [sp, #-16]
	str	r2, [r0, #0]
	ldr	r0, .int1
	str	r0, [sp, #-24]
	ldr	r0, [sp, #-16]
	ldr	r1, [sp, #-24]
	add	r0, r0, r1
	str	r0, [sp, #-28]
	ldr	r1, [sp, #-28]
	str	r1, [sp, #-16]
.loopend0:
	ldr	r0, [sp, #-16]
	ldr	r1, [sp, #-8]
	mov	r2, r1
	mov	r1, r0
	mov	r0, #0
	cmp	r1, r2
	movlt	r0, #1
	str	r0, [sp, #-20]
	ldr	r1, [sp, #-20]
	cmp	r1, #0
	bne	.loopbegin0
Foo_foo_return:
	pop	{fp, pc}
	bx	lr
main:
	push	{fp, lr}
	str	r0, [sp, #-4]
	add	r1, r1, #4
	str	r1, [sp, #-8]
	sub	sp, sp, #8
	bl	Foo_init
	add	sp, sp, #8
	str	r0, [sp, #-12]
	ldr	r0, .int2
	str	r0, [sp, #-16]
	ldr	r1, [sp, #-16]
	ldr	r0, [sp, #-12]
	sub	sp, sp, #16
	bl	Foo_foo
	add	sp, sp, #16
	ldr	r0, .int0
	str	r0, [sp, #-20]
	b	.loopend1
.loopbegin1:
	ldr	r0, [sp, #-12]
	add	r0, r0, #0
	str	r0, [sp, #-24]
	ldr	r1, [sp, #-20]
	lsl	r1, r1, #2
	ldr	r0, [sp, #-24]
	add	r0, r0, r1
	ldr	r0, [r0, #0]
	str	r0, [sp, #-28]
	ldr	r0, =str0
	ldr	r1, [sp, #-28]
	sub	sp, sp, #28
	bl	printf
	add	sp, sp, #28
	ldr	r0, .int1
	str	r0, [sp, #-32]
	ldr	r0, [sp, #-20]
	ldr	r1, [sp, #-32]
	add	r0, r0, r1
	str	r0, [sp, #-36]
	ldr	r1, [sp, #-36]
	str	r1, [sp, #-20]
.loopend1:
	ldr	r0, .int2
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
	bne	.loopbegin1
	pop	{fp, pc}
	bx	lr
.int2:
	.word	23
.int0:
	.word	0
.int1:
	.word	1
