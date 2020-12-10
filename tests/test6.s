.data
.balign	4
str0:
	.asciz	"%d\n"
.text
.balign	4
.global	main
A_init:
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
A_setx:
	push	{fp, lr}
	str	r0, [sp, #-4]
	str	r1, [sp, #-8]
	ldr	r0, [sp, #-4]
	add	r0, r0, #0
	ldr	r2, [sp, #-8]
	str	r2, [r0, #0]
A_setx_return:
	pop	{fp, pc}
	bx	lr
C_init:
	push	{fp, lr}
	mov	r0, #0
	str	r0, [sp, #-4]
	mov	r0, #0
	str	r0, [sp, #-8]
	sub	sp, sp, #8
	mov	r0, #8
	bl	malloc
	add	sp, sp, #8
	mov	r2, r0
	ldr	r0, [sp, #-8]
	str	r0, [r2, #4]
	ldr	r0, [sp, #-4]
	str	r0, [r2, #0]
	mov	r0, r2
	pop	{fp, pc}
	bx	lr
C_sety:
	push	{fp, lr}
	str	r0, [sp, #-4]
	str	r1, [sp, #-8]
	ldr	r0, [sp, #-4]
	add	r0, r0, #0
	ldr	r2, [sp, #-8]
	str	r2, [r0, #0]
C_sety_return:
	pop	{fp, pc}
	bx	lr
C_setx:
	push	{fp, lr}
	str	r0, [sp, #-4]
	str	r1, [sp, #-8]
	ldr	r0, [sp, #-4]
	add	r0, r0, #4
	ldr	r2, [sp, #-8]
	str	r2, [r0, #0]
C_setx_return:
	pop	{fp, pc}
	bx	lr
B_init:
	push	{fp, lr}
	mov	r0, #0
	str	r0, [sp, #-4]
	mov	r0, #0
	str	r0, [sp, #-8]
	sub	sp, sp, #8
	mov	r0, #8
	bl	malloc
	add	sp, sp, #8
	mov	r2, r0
	ldr	r0, [sp, #-8]
	str	r0, [r2, #4]
	ldr	r0, [sp, #-4]
	str	r0, [r2, #0]
	mov	r0, r2
	pop	{fp, pc}
	bx	lr
B_sety:
	push	{fp, lr}
	str	r0, [sp, #-4]
	str	r1, [sp, #-8]
	ldr	r0, [sp, #-4]
	add	r0, r0, #0
	ldr	r2, [sp, #-8]
	str	r2, [r0, #0]
B_sety_return:
	pop	{fp, pc}
	bx	lr
B_setx:
	push	{fp, lr}
	str	r0, [sp, #-4]
	str	r1, [sp, #-8]
	ldr	r0, [sp, #-4]
	add	r0, r0, #4
	ldr	r2, [sp, #-8]
	str	r2, [r0, #0]
B_setx_return:
	pop	{fp, pc}
	bx	lr
main:
	push	{fp, lr}
	str	r0, [sp, #-4]
	add	r1, r1, #4
	str	r1, [sp, #-8]
	sub	sp, sp, #8
	bl	C_init
	add	sp, sp, #8
	str	r0, [sp, #-12]
	ldr	r0, .int0
	str	r0, [sp, #-16]
	ldr	r1, [sp, #-16]
	ldr	r0, [sp, #-12]
	sub	sp, sp, #16
	bl	C_setx
	add	sp, sp, #16
	ldr	r0, .int1
	str	r0, [sp, #-20]
	ldr	r1, [sp, #-20]
	ldr	r0, [sp, #-12]
	sub	sp, sp, #20
	bl	C_sety
	add	sp, sp, #20
	ldr	r0, [sp, #-12]
	add	r0, r0, #4
	ldr	r0, [r0, #0]
	str	r0, [sp, #-24]
	ldr	r0, =str0
	ldr	r1, [sp, #-24]
	sub	sp, sp, #24
	bl	printf
	add	sp, sp, #24
	ldr	r0, [sp, #-12]
	add	r0, r0, #0
	ldr	r0, [r0, #0]
	str	r0, [sp, #-28]
	ldr	r0, =str0
	ldr	r1, [sp, #-28]
	sub	sp, sp, #28
	bl	printf
	add	sp, sp, #28
	pop	{fp, pc}
	bx	lr
.int1:
	.word	456
.int0:
	.word	123
