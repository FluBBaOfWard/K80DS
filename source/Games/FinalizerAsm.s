#ifdef __arm__

#include "../Shared/nds_asm.h"
#include "../K005849/K005849.i"
#include "../ARM6809/ARM6809.i"

	.global doCpuMappingFinalizer
	.global gfxResetFinalizer
	.global paletteInitFinalizer
	.global paletteTxAllFinalizer

	.syntax unified
	.arm

	.section .text
	.align 2


;@----------------------------------------------------------------------------
doCpuMappingFinalizer:
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}
	ldr r0,=m6809CPU0
	mov r1,#1
	bl m6809SetEncryptedMode
	ldmfd sp!,{lr}

	adr r2,finalizerMapping
	b do6809MainCpuMapping
;@----------------------------------------------------------------------------
finalizerMapping:						;@ Finalizer
	.long emptySpace, FinalizerIO_R, FinalizerIO_W				;@ IO
	.long GFX_RAM0, k005885Ram_0R, k005885Ram_0W				;@ Graphic
	.long 0, mem6809R2, rom_W									;@ ROM
	.long 1, mem6809R3, rom_W									;@ ROM
	.long 2, mem6809R4, rom_W									;@ ROM
	.long 3, mem6809R5, rom_W									;@ ROM
	.long 4, mem6809R6, rom_W									;@ ROM
	.long 5, mem6809R7, rom_W									;@ ROM

;@----------------------------------------------------------------------------
gfxResetFinalizer:
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}

	ldr r0,=m6809SetNMIPinCurrentCpu	;@ Scanline counter
	ldr r1,=m6809SetIRQPinCurrentCpu	;@ VBlank
	ldr r2,=m6809SetFIRQPinCurrentCpu	;@ 1/2 VBlank
	bl k005849Reset0
	ldr r0,=gfxChipType
	ldrb r0,[r0]
	bl k005849SetType
	bl bgInit

	ldr r0,=BG_32x32 | BG_MAP_BASE(1) | BG_TILE_BASE(2) | BG_PRIORITY(0)
	mov r1,#REG_BASE
	strh r0,[r1,#REG_BG2CNT]

	ldmfd sp!,{pc}
;@----------------------------------------------------------------------------
paletteInitFinalizer:		;@ r0-r3 modified.
;@----------------------------------------------------------------------------
	stmfd sp!,{r4-r9,lr}
	mov r1,r0					;@ Gamma value = 0 -> 4
	ldr r8,=promBase			;@ Proms
	ldr r8,[r8]
	mov r7,#0xF0
	ldr r6,=MAPPED_RGB
	mov r4,#32					;@ Jail Break bgr, r1=R, r2=G, r3=B
noMap:							;@ Map 0000bbbbggggrrrr  ->  0bbbbbgggggrrrrr
	ldrb r0,[r8,#0x20]
	and r0,r7,r0,lsl#4			;@ Blue
	bl gPrefix
	mov r5,r0

	ldrb r9,[r8],#1
	and r0,r7,r9				;@ Green
	bl gPrefix
	orr r5,r0,r5,lsl#5

	and r0,r7,r9,lsl#4			;@ Red
	bl gPrefix
	orr r5,r0,r5,lsl#5

	strh r5,[r6],#2
	subs r4,r4,#1
	bne noMap

	ldmfd sp!,{r4-r9,lr}
	bx lr

;@----------------------------------------------------------------------------
gPrefix:
	orr r0,r0,r0,lsr#4
	b gammaConvert
;@----------------------------------------------------------------------------
paletteTxAllFinalizer:
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}

	ldr r1,=promBase			;@ Proms
	ldr r1,[r1]
	add r1,r1,#64				;@ LUT
	ldr r2,=MAPPED_RGB
	ldr r0,=EMUPALBUFF+0x200	;@ Sprites first
	bl paletteTx0
	add r2,r2,#0x20
	ldr r0,=EMUPALBUFF
	bl paletteTx0
	ldmfd sp!,{lr}
	bx lr

;@----------------------------------------------------------------------------
	.end
#endif // #ifdef __arm__
