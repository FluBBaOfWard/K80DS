#ifdef __arm__

#include "../K005849/K005849.i"
#include "../ARM6809/ARM6809.i"

	.global doCpuMappingDDribble
	.global paletteInitDDribble
	.global paletteTxAllDDribble
	.global updateBankReg

	.syntax unified
	.arm

	.section .text
	.align 2


;@----------------------------------------------------------------------------
updateBankReg:
	.type   updateBankReg STT_FUNC
;@----------------------------------------------------------------------------
	ldrb r0,bankReg
	b mapBankReg
;@----------------------------------------------------------------------------
bank_W:						;@ Write ROM bank address, CPU0
;@----------------------------------------------------------------------------
	cmp addy,#0x8000
	bne rom_W
	and r0,r0,#0x07
	strb r0,bankReg
mapBankReg:
	ldr r1,=mainCpu
	ldr r1,[r1]
	add r1,r1,r0,lsl#13
	sub r1,r1,#0x8000
	ldr r2,=m6809CPU0
	str r1,[r2,#m6809MemTbl+4*4]
	bx lr

;@----------------------------------------------------------------------------
doCpuMappingDDribble:
;@----------------------------------------------------------------------------
stmfd sp!,{lr}
	adr r2,ddribbleMapping
	bl do6809MainCpuMapping
;@----------------------------------------------------------------------------
doCpuMappingDDribbleCpu1:
;@----------------------------------------------------------------------------
	adr r2,ddribbleCpu1Mapping
	ldr r0,=m6809CPU1
	ldr r1,=mainCpu
	ldr r1,[r1]
	bl m6809Mapper
;@----------------------------------------------------------------------------
doCpuMappingDDribbleCpu2:
;@----------------------------------------------------------------------------
	adr r2,ddribbleCpu2Mapping
	ldr r0,=m6809CPU2
	ldr r1,=mainCpu
	ldr r1,[r1]
	bl m6809Mapper
	ldmfd sp!,{lr}
	bx lr

;@----------------------------------------------------------------------------
ddribbleMapping:						;@ Double Dribble CPU0
	.long emptySpace, k005885_0_1R, k005885_0_1W				;@ IO
	.long GFX_RAM0, k005885Ram_0R, k005885Ram_0W				;@ GFX RAM
	.long SHARED_RAM, mem6809R2, sharedRAM_W					;@ RAM
	.long GFX_RAM1, k005885Ram_1R, k005885Ram_1W				;@ GFX RAM
	.long 4, mem6809R4, bank_W									;@ ROM
	.long 5, mem6809R5, bank_W									;@ ROM
	.long 6, mem6809R6, bank_W									;@ ROM
	.long 7, mem6809R7, bank_W									;@ ROM
;@----------------------------------------------------------------------------
ddribbleCpu1Mapping:					;@ Double Dribble CPU1
	.long SHARED_RAM, mem6809R0, sharedRAM_W					;@ RAM
	.long SOUND_RAM, DDribbleIO_R, DDribbleIO_W					;@ Sound RAM
	.long emptySpace, empty_R, empty_W							;@ Empty
	.long emptySpace, empty_R, empty_W							;@ Empty
	.long 8, mem6809R4, rom_W									;@ ROM
	.long 9, mem6809R5, rom_W									;@ ROM
	.long 0xA, mem6809R6, rom_W									;@ ROM
	.long 0xB, mem6809R7, rom_W									;@ ROM
;@----------------------------------------------------------------------------
ddribbleCpu2Mapping:					;@ Double Dribble CPU2
	.long SOUND_RAM, YM0_R, YM0_W								;@ Sound RAM
	.long emptySpace, empty_R, VLMData_W						;@ VLM write
	.long emptySpace, empty_R, empty_W							;@ Empty
	.long emptySpace, empty_R, empty_W							;@ Empty
	.long 0xC, mem6809R4, rom_W									;@ ROM
	.long 0xD, mem6809R5, rom_W									;@ ROM
	.long 0xE, mem6809R6, rom_W									;@ ROM
	.long 0xF, mem6809R7, rom_W									;@ ROM

;@----------------------------------------------------------------------------
paletteInitDDribble:		;@ r0-r3 modified.
;@----------------------------------------------------------------------------
	stmfd sp!,{r4-r9,lr}
	mov r1,r0					;@ Gamma value = 0 -> 4
	ldr r8,=k005885Palette
	mov r7,#0xF8
	ldr r6,=MAPPED_RGB
	mov r4,#64					;@ Double Dribble rgb, r1=R, r2=G, r3=B
noMap:							;@ Map 0rrrrrgggggbbbbb  ->  0bbbbbgggggrrrrr
	ldrb r9,[r8],#1
	ldrb r0,[r8],#1
	orr r9,r0,r9,lsl#8
	and r0,r7,r9,lsr#7			;@ Blue ready
	bl gPrefix
	mov r5,r0

	and r0,r7,r9,lsr#2			;@ Green ready
	bl gPrefix
	orr r5,r0,r5,lsl#5

	and r0,r7,r9,lsl#3			;@ Red ready
	bl gPrefix
	orr r5,r0,r5,lsl#5

	strh r5,[r6],#2
	subs r4,r4,#1
	bne noMap

	ldmfd sp!,{r4-r9,lr}
	bx lr

;@----------------------------------------------------------------------------
gPrefix:
	orr r0,r0,r0,lsr#5
	b gammaConvert
;@----------------------------------------------------------------------------
paletteTxAllDDribble:
;@----------------------------------------------------------------------------
	stmfd sp!,{r4,lr}

	ldr r1,=promBase			;@ Proms
	ldr r1,[r1]					;@ LUT
	ldr r2,=MAPPED_RGB
	ldr r0,=EMUPALBUFF+0x200	;@ Sprites first
	bl paletteTx0
	sub r0,r0,#0x20
	add r2,r2,#0x20
	mov r3,#0x10
	noMap4:
	rsb r12,r3,#0x10
	mov r12,r12,lsl#1
	ldrh r12,[r2,r12]
	strh r12,[r0],#2
	subs r3,r3,#1
	bne noMap4

	ldr r0,=EMUPALBUFF
	bl noMap2

	ldmfd sp!,{r4,lr}
	bx lr

noMap2:
	mov r3,#0x100
palTxLoop2:
	rsb r12,r3,#0x100
	and r12,r12,#0x2F
	mov r12,r12,lsl#1
	ldrh r12,[r2,r12]
	strh r12,[r0],#2
	subs r3,r3,#1
	bne palTxLoop2
	bx lr

;@----------------------------------------------------------------------------
k005885_0_1R:				;@ I/O read, 0x0000-0x005F / 0x0800-0x085F
;@----------------------------------------------------------------------------
	cmp addy,#0x0860
	bpl paletteRead
	stmfd sp!,{addy,lr}
	bic r1,addy,#0x0800
	tst addy,#0x0800
	ldreq koptr,=k005885_0
	ldrne koptr,=k005885_1
	bl k005885_R
	ldmfd sp!,{addy,pc}
;@----------------------------------------------------------------------------
k005885_0_1W:				;@ I/O write  (0x0000-0x005F) / (0x0800-0x085F)
;@----------------------------------------------------------------------------
	cmp addy,#0x0860
	bpl paletteWrite
	stmfd sp!,{addy,lr}
	bic r1,addy,#0x0800
	tst addy,#0x0800
	ldreq koptr,=k005885_0
	ldrne koptr,=k005885_1
	bl k005885_W
	ldmfd sp!,{addy,pc}
;@----------------------------------------------------------------------------
paletteRead:
;@----------------------------------------------------------------------------
	subs r1,addy,#0x1800
	bmi empty_IO_R
	cmp r1,#0x80
	bpl empty_IO_R
	ldr r2,=k005885Palette
	ldrb r0,[r2,r1]
	bx lr

;@----------------------------------------------------------------------------
paletteWrite:
;@----------------------------------------------------------------------------
	subs r1,addy,#0x1800
	bmi empty_IO_W
	cmp r1,#0x80
	bpl empty_IO_W
	ldr r2,=k005885Palette
	strb r0,[r2,r1]
	bx lr
;@----------------------------------------------------------------------------
DDribbleIO_R:				;@ I/O read (CPU 1 0x2000-0x3FFF)
;@----------------------------------------------------------------------------
	subs r1,addy,#0x2800
	bmi soundRamR
	cmp addy,#0x2C00
	beq Input4_R
	cmp addy,#0x3000
	beq Input5_R
	bics r2,r1,#3
	and r2,r1,#3
	ldreq pc,[pc,r2,lsl#2]
;@---------------------------
	b empty_IO_R
;@io_read_tbl
	.long Input3_R				;@ 0x2800
	.long Input0_R				;@ 0x2801
	.long Input1_R				;@ 0x2802
	.long Input2_R				;@ 0x2803

;@----------------------------------------------------------------------------
DDribbleIO_W:				;@ I/O write (CPU 1 0x2000-0x3FFF)
;@----------------------------------------------------------------------------
	subs r1,addy,#0x2800
	bmi soundRamW
	cmp addy,#0x3400
	beq ddCoinW
	cmp addy,#0x3C00
	beq watchDogW
	b empty_IO_W

;@----------------------------------------------------------------------------
VLMData_W:
;@----------------------------------------------------------------------------
	mov r1,r0
//	ldr r0,=vlm5030Chip
	ldr r0,[r0]
	stmfd sp!,{r3,lr}
//	blx VLM5030_WRITE8
	ldmfd sp!,{r3,pc}
;@----------------------------------------------------------------------------
YM0_R:
;@----------------------------------------------------------------------------
	bic r1,r12,#0x0001
	cmp r1,#0x1000
	bne soundRamR
	tst r12,#1
	ldr r0,=ym2203_0
	bne ym2203DataR
	b ym2203StatusR
;@----------------------------------------------------------------------------
YM0_W:
;@----------------------------------------------------------------------------
	bic r1,r12,#0x0001
	cmp r1,#0x1000
	bne soundRamW
	tst r12,#1
	ldr r1,=ym2203_0
	bne ym2203DataW
	b ym2203IndexW
;@----------------------------------------------------------------------------
soundRamR:					;@ Ram read (0x0000-0x07FF / 0x2000-0x27FF)
;@----------------------------------------------------------------------------
	tst r12,#0x1800
	bxne lr
	bic r1,r12,#0x3F800
	ldr r2,=SOUND_RAM
	ldrb r0,[r2,r1]
	bx lr
;@----------------------------------------------------------------------------
soundRamW:					;@ Ram write (0x0000-0x07FF / 0x2000-0x27FF)
;@----------------------------------------------------------------------------
	tst r12,#0x1800
	bxne lr
	bic r1,r12,#0x3F800
	ldr r2,=SOUND_RAM
	strb r0,[r2,r1]
	bx lr
;@----------------------------------------------------------------------------
bankReg:
	.long 0

	.end
#endif // #ifdef __arm__
