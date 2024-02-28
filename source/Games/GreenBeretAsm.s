#ifdef __arm__

	.global paletteInitGreenBeret
	.global paletteTxAllGreenBeret

	.syntax unified
	.arm

	.section .text
	.align 2
;@----------------------------------------------------------------------------
paletteInitGreenBeret:		;@ r0-r3 modified.
;@----------------------------------------------------------------------------
	stmfd sp!,{r4-r9,lr}
	mov r1,r0					;@ Gamma value = 0 -> 4
	ldr r8,=promBase			;@ Proms
	ldr r8,[r8]
	mov r7,#0xE0
	ldr r6,=MAPPED_RGB
	mov r4,#32					;@ Green Beret bgr, r1=R, r2=G, r3=B
.loop:							;@ Map 00000000bbgggrrr  ->  0bbbbbgggggrrrrr
	ldrb r9,[r8],#1
	and r0,r9,#0xC0				;@ Blue ready
	bl gPrefix
	mov r5,r0

	and r0,r7,r9,lsl#2			;@ Green ready
	bl gPrefix
	orr r5,r0,r5,lsl#5

	and r0,r7,r9,lsl#5			;@ Red ready
	bl gPrefix
	orr r5,r0,r5,lsl#5

	strh r5,[r6],#2
	subs r4,r4,#1
	bne .loop

	ldmfd sp!,{r4-r9,lr}
	bx lr

;@----------------------------------------------------------------------------
gPrefix:
	orr r0,r0,r0,lsr#3
	orr r0,r0,r0,lsr#6
	b gammaConvert
;@----------------------------------------------------------------------------
paletteTxAllGreenBeret:				;@ Called from ui.c
;@----------------------------------------------------------------------------
	stmfd sp!,{r4-r5}

	ldr r2,=promBase			;@ Proms
	ldr r2,[r2]
	add r2,r2,#32
	ldr r3,=MAPPED_RGB
	ldr r4,=EMUPALBUFF
	add r5,r4,#512
	mov r1,#256
.loop2:
	ldrb r0,[r2],#1
	mov r0,r0,lsl#1
	ldrh r0,[r3,r0]
	strh r0,[r5],#2
	subs r1,r1,#1
	bne .loop2

	add r3,r3,#32
	mov r1,#256
.loop3:
	ldrb r0,[r2],#1
	mov r0,r0,lsl#1
	ldrh r0,[r3,r0]
	strh r0,[r4],#2
	subs r1,r1,#1
	bne .loop3

	ldmfd sp!,{r4-r5}
	bx lr

;@----------------------------------------------------------------------------
	.end
#endif // #ifdef __arm__
