#ifdef __arm__

#include "../Shared/nds_asm.h"
#include "../K005849/K005849.i"
#include "../ARM6809/ARM6809.i"

	.global doCpuMappingDDribble
	.global updateBankReg
	.global gfxResetDDribble
	.global paletteInitDDribble
	.global paletteTxAllDDribble
	.global endFrameDDribble

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

	ldr r0,=vlm5030Chip
	ldr r0,[r0]
	ldr r1,=vlmBase
	ldr r1,[r1]
	mov r2,#0x10000				;@ ROM size
	blx VLM5030_set_rom

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
gfxResetDDribble:
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}

	ldr r0,=cpu01SetNMI
	ldr r1,=cpu01SetFIRQ
	ldr r2,=cpu012SetIRQ
	bl k005885Reset0
	mov r0,#CHIP_K005885
	bl k005849SetType
	ldr r0,=BG_GFX+0x8000		;@ Tile ram 2
	str r0,[koptr,#bgrGfxDest]
	ldr r0,=Gfx1Bg
	str r0,[koptr,#bgrRomBase]
	ldr r0,=Gfx1Obj				;@ r0=SRC SPR tileset
	str r0,[koptr,#spriteRomBase]
	mov r0,#0xF
	strb r0,[koptr,#spritePaletteOffset]

	ldr r0,[koptr,#bgrRomBase]	;@ Dest
	ldr r1,=vromBase0			;@ r1 = even bytes
	ldr r1,[r1]
	add r2,r1,#0x20000			;@ r2 = odd bytes
	mov r3,#0x40000				;@ Length
	bl convertTiles5885

	mov r0,#0
	mov r1,#0
	mov r2,#0
	bl k005885Reset1
	mov r0,#CHIP_K005885
	bl k005849SetType
	ldr r0,=BG_GFX+0x10000		;@ Tile ram 4
	str r0,[koptr,#bgrGfxDest]
	ldr r0,=Gfx2Bg
	str r0,[koptr,#bgrRomBase]
	ldr r0,=Gfx2Obj				;@ r0=SRC SPR tileset
	str r0,[koptr,#spriteRomBase]
	ldr r0,=0x1FF
	str r0,[koptr,#spriteMask]

	ldr r0,[koptr,#bgrRomBase]
	ldr r1,=vromBase1			;@ r1 = even bytes
	ldr r1,[r1]
	add r2,r1,#0x20000			;@ r2 = odd bytes
	mov r3,#0x40000				;@ Length
	bl convertTiles5885

	ldr r0,[koptr,#spriteRomBase]
	ldr r1,=vromBase1			;@ r1 = source
	ldr r1,[r1]
	add r1,r1,#0x40000			;@ Offset to sprites
	add r2,r1,#0x20000			;@ r2 = odd bytes
	mov r3,#0x40000				;@ Length
	bl convertTiles5885

	ldr r1,=GFX_BG0CNT
	ldr r0,=BG_32x32 | BG_COLOR_16 | BG_MAP_BASE(0) | BG_TILE_BASE(2) | BG_PRIORITY(0)
	strh r0,[r1]

	ldr r0,=BG_64x32 | BG_MAP_BASE(4) | BG_TILE_BASE(4) | BG_PRIORITY(2)
	mov r1,#REG_BASE
	strh r0,[r1,#REG_BG2CNT]

	mov r0,#128
	ldr r1,=spriteCount
	strb r0,[r1]
	mov r0,#0x17
	ldr r1,=enabledVideo
	strb r0,[r1]

	ldmfd sp!,{pc}
;@----------------------------------------------------------------------------
paletteInitDDribble:		;@ r0-r3 modified.
;@----------------------------------------------------------------------------
	stmfd sp!,{r4-r9,lr}
	mov r1,r0					;@ Gamma value = 0 -> 4
	ldr r8,=k007327Palette
	mov r7,#0xF8
	ldr r6,=MAPPED_RGB
	mov r4,#64					;@ K007327 rgb
noMap:							;@ Map 0bbbbbgggggrrrrr  ->  0bbbbbgggggrrrrr
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
endFrameDDribble:
;@----------------------------------------------------------------------------
	ldr r0,=k005885_1
	cmp koptr,r0
	bxeq lr
	stmfd sp!,{koptr,lr}

	ldr koptr,=k005885_1
	ldr r0,=scrollTemp2
	bl copyScrollValues
	ldr r0,=BG_GFX+0x2000
	bl convertTileMapDD
	ldr r0,=tmpOamBuffer		;@ Destination
	ldr r0,[r0]
	bl convertSprites5885
;@--------------------------
	ldr r0,[koptr,#sprMemAlloc]
	ldrb r1,[koptr,#sprMemReload]
	ldr koptr,=k005885_0
	str r0,[koptr,#sprMemAlloc]
	cmp r1,#0
	strbne r1,[koptr,#sprMemReload]

	ldr r0,=scrollTemp
	bl copyScrollValues
	ldr r0,=BG_GFX
	bl convertTileMapDDFG
	ldr r0,=tmpOamBuffer		;@ Destination
	ldr r0,[r0]
	add r0,r0,#64*8
	bl convertSprites5885
;@--------------------------
	ldr r0,[koptr,#sprMemAlloc]
	ldrb r1,[koptr,#sprMemReload]
	ldr koptr,=k005885_1
	str r0,[koptr,#sprMemAlloc]
	cmp r1,#0
	strbne r1,[koptr,#sprMemReload]
	ldmfd sp!,{koptr,pc}

;@----------------------------------------------------------------------------
k005885_0_1R:				;@ I/O read (0x0000-0x005F / 0x0800-0x085F)
;@----------------------------------------------------------------------------
	cmp addy,#0x1800
	bpl k007327Read
	stmfd sp!,{addy,lr}
	bic r1,addy,#0x0800
	tst addy,#0x0800
	ldreq koptr,=k005885_0
	ldrne koptr,=k005885_1
	bl k005885_R
	ldmfd sp!,{addy,pc}
;@----------------------------------------------------------------------------
k005885_0_1W:				;@ I/O write  (0x0000-0x005F / 0x0800-0x085F)
;@----------------------------------------------------------------------------
	cmp addy,#0x1800
	bpl k007327Write
	stmfd sp!,{addy,lr}
	bic r1,addy,#0x0800
	tst addy,#0x0800
	ldreq koptr,=k005885_0
	ldrne koptr,=k005885_1
	bl k005885_W
	ldmfd sp!,{addy,pc}

;@----------------------------------------------------------------------------
k007327Read:				;@ 0x1800-0x187F
;@----------------------------------------------------------------------------
	bic r1,addy,#0xF800
	cmp r1,#0x80
	bpl empty_IO_R
	ldr r2,=k007327Palette
	ldrb r0,[r2,r1]
	bx lr
;@----------------------------------------------------------------------------
k007327Write:				;@ 0x1800-0x187F
;@----------------------------------------------------------------------------
	bic r1,addy,#0xF800
	cmp r1,#0x80
	bpl empty_IO_W
	ldr r2,=k007327Palette
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
