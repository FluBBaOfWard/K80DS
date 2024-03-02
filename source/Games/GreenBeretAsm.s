#ifdef __arm__

#include "../ARMZ80/ARMZ80.i"

	.global doCpuMappingGreenBeret
	.global paletteInitGreenBeret
	.global paletteTxAllGreenBeret
	.global gberetMapRom

	.syntax unified
	.arm

	.section .text
	.align 2


;@----------------------------------------------------------------------------
doCpuMappingGreenBeret:
;@----------------------------------------------------------------------------
	ldr r0,=Z80OpTable
	ldr r1,=mainCpu
	ldr r1,[r1]
	adr r2,greenBeretMapping
	b z80Mapper
;@----------------------------------------------------------------------------
greenBeretMapping:						;@ Green Beret
	.long 0x00, memZ80R0, rom_W									;@ ROM
	.long 0x01, memZ80R1, rom_W									;@ ROM
	.long 0x02, memZ80R2, rom_W									;@ ROM
	.long 0x03, memZ80R3, rom_W									;@ ROM
	.long 0x04, memZ80R4, rom_W									;@ ROM
	.long 0x05, memZ80R5, rom_W									;@ ROM
	.long emuRAM, memZ80R6, k005849Ram_0W						;@ Graphic
	.long emptySpace, GreenBeretIO_R, GreenBeretIO_W			;@ IO

;@----------------------------------------------------------------------------
paletteInitGreenBeret:		;@ r0-r3 modified.
;@----------------------------------------------------------------------------
	stmfd sp!,{r4-r9,lr}
	mov r1,r0					;@ Gamma value = 0 -> 4
	ldr r8,=promBase			;@ Proms
	ldr r8,[r8]
	mov r7,#0xE0
	ldr r6,=MAPPED_RGB
	mov r4,#32					;@ Green Beret bgr
palInitLoop:					;@ Map bbgggrrr  ->  0bbbbbgggggrrrrr
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
	bne palInitLoop

	ldmfd sp!,{r4-r9,lr}
	bx lr

;@----------------------------------------------------------------------------
gPrefix:
	orr r0,r0,r0,lsr#3
	orr r0,r0,r0,lsr#6
	b gammaConvert
;@----------------------------------------------------------------------------
paletteTxAllGreenBeret:
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}

	ldr r1,=promBase			;@ Proms
	ldr r1,[r1]
	add r1,r1,#32				;@ LUT
	ldr r2,=MAPPED_RGB
	ldr r0,=EMUPALBUFF+0x200	;@ Sprites first
	bl paletteTx0
	add r2,r2,#0x20
	ldr r0,=EMUPALBUFF
	bl paletteTx0
	ldmfd sp!,{lr}
	bx lr

;@----------------------------------------------------------------------------
gberetMapRom:
;@----------------------------------------------------------------------------
	and r0,r0,#0xE0
	ldr r1,=mainCpu
	ldr r1,[r1]
	sub r1,r1,#0x3800
	add r1,r1,r0,lsl#6
	str r1,[z80ptr,#z80MemTbl+28]
	bx lr

;@----------------------------------------------------------------------------
	.end
#endif // #ifdef __arm__
