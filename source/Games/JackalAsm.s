#ifdef __arm__

#include "../Shared/nds_asm.h"
#include "../K005849/K005849.i"
#include "../ARM6809/ARM6809.i"

	.global chipBank

	.global doCpuMappingJackal
	.global gfxResetJackal
	.global jackalMapper
	.global paletteInitJackal
	.global paletteTxAllJackal
	.global endFrameJackal

	.syntax unified
	.arm

	.section .text
	.align 2


;@----------------------------------------------------------------------------
jackalMapper:				;@ Switch bank for 0x4000-0xBFFF, 4 banks.
	.type   jackalMapper STT_FUNC
;@----------------------------------------------------------------------------
	and r0,r0,#0x20
	ldr r1,=mainCpu
	ldr r1,[r1]
	add r1,r1,r0,lsl#10
	sub r1,r1,#0x4000
	ldr r2,=m6809CPU0
	str r1,[r2,#m6809MemTbl+4*2]
	str r1,[r2,#m6809MemTbl+4*3]
	str r1,[r2,#m6809MemTbl+4*4]
	str r1,[r2,#m6809MemTbl+4*5]
	bx lr
;@----------------------------------------------------------------------------
doCpuMappingJackal:
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}
	adr r2,JackalMapping
	bl do6809MainCpuMapping
	ldmfd sp!,{lr}
;@----------------------------------------------------------------------------
doCpuMappingJackalSub:
;@----------------------------------------------------------------------------
	adr r2,JackalSubMapping
	ldr r0,=m6809CPU1
	ldr r1,=subCpu
	ldr r1,[r1]
	b m6809Mapper
;@----------------------------------------------------------------------------
JackalMapping:						;@ Jackal
	.long SHARED_RAM, JackalIO_R, JackalIO_W					;@ IO
	.long GFX_RAM0, k005885Ram_0_1R, k005885Ram_0_1W			;@ Graphic
	.long 0, mem6809R2, rom_W									;@ ROM
	.long 1, mem6809R3, rom_W									;@ ROM
	.long 2, mem6809R4, rom_W									;@ ROM
	.long 3, mem6809R5, rom_W									;@ ROM
	.long 8, mem6809R6, rom_W									;@ ROM
	.long 9, mem6809R7, rom_W									;@ ROM
;@----------------------------------------------------------------------------
JackalSubMapping:					;@ Jackal sub cpu
	.long emptySpace, empty_R, empty_W							;@ Empty
	.long emptySpace, YM0_R, YM0_W								;@ Sound
	.long k007327Palette, k007327Read, k007327Write				;@ Palette
	.long SHARED_RAM, mem6809R3, sharedRAM_W					;@ RAM
	.long 0, mem6809R4, rom_W									;@ ROM
	.long 1, mem6809R5, rom_W									;@ ROM
	.long 2, mem6809R6, rom_W									;@ ROM
	.long 3, mem6809R7, rom_W									;@ ROM

;@----------------------------------------------------------------------------
gfxResetJackal:					;@ In r0=ChipType
;@----------------------------------------------------------------------------
	stmfd sp!,{r0,lr}

	mov r0,#0
	mov r1,#0
	mov r2,#0
	bl k005885Reset1
	ldr r0,=BG_GFX+0x8000		;@ Tile ram 0.5
	str r0,[koptr,#bgrGfxDest]
	ldr r0,=Gfx2Bg				;@ Src bg tileset
	str r0,[koptr,#bgrRomBase]
	ldr r0,=Gfx2Obj+0x20000		;@ Src spr tileset
	str r0,[koptr,#spriteRomBase]

	mov r0,#0
	ldr r1,=cpu0SetIRQ_1SetNMI
	mov r2,#0
	bl k005885Reset0
	ldr r0,=BG_GFX+0x8000		;@ Tile ram 0.5
	str r0,[koptr,#bgrGfxDest]
	ldr r0,=Gfx2Bg				;@ Src bg tileset
	str r0,[koptr,#bgrRomBase]
	ldr r0,=Gfx2Obj				;@ r0=SRC SPR tileset
	str r0,[koptr,#spriteRomBase]

	ldr r1,=GFX_BG0CNT
	ldr r0,=BG_32x32 | BG_MAP_BASE(0) | BG_COLOR_256 | BG_TILE_BASE(2) | BG_PRIORITY(2)
	strh r0,[r1]

	mov r0,#128
	ldr r1,=spriteCount
	strb r0,[r1]
	mov r0,#0x11
	ldr r1,=enabledVideo
	strb r0,[r1]

	ldmfd sp!,{r0}
	cmp r0,#CHIP_K005885B
	beq selBg2

	bl sprInit
	bl bgInit1
	ldmfd sp!,{pc}
selBg2:
	bl sprInit2
	bl bgInit2
	ldmfd sp!,{pc}
;@----------------------------------------------------------------------------
bgInit1:					;@ BG tiles
;@----------------------------------------------------------------------------
	ldr r0,[koptr,#bgrRomBase]	;@ r0 = destination
	ldr r1,=vromBase0			;@ r1 = source even bytes1
	ldr r1,[r1]
	stmfd sp!,{r4-r8,lr}
	mov r2,#0x20000				;@ Offset odd bytes 1
	mov r3,#0x40000				;@ Offset even bytes 2
	mov r7,#0x60000				;@ Offset odd bytes 2
	mov r6,#0x40000				;@ Length
	ldr r8,=0xF0F0F0F0
								;@ E1 O1 E2 O2
bgChr1:							;@ 01 23 45 67 -> 02 13 46 57
	mov r4,#0
	ldrb r5,[r1,r7]				;@ Odd bytes 2
	orr r5,r5,r5,lsl#12
	and r5,r5,r8
	orr r4,r4,r5,lsl#12

	ldrb r5,[r1,r2]				;@ Odd bytes 1
	orr r5,r5,r5,lsl#12
	and r5,r5,r8
	orr r4,r4,r5,lsl#16

	ldrb r5,[r1,r3]				;@ Even bytes 2
	orr r5,r5,r5,lsl#12
	and r5,r5,r8
	orr r4,r4,r5,lsr#4

	ldrb r5,[r1],#1				;@ Even bytes 1
	orr r5,r5,r5,lsl#12
	and r5,r5,r8
	orr r4,r4,r5,lsr#0

	str r4,[r0],#4

	subs r6,r6,#4
	bne bgChr1

	ldmfd sp!,{r4-r8,pc}
;@----------------------------------------------------------------------------
bgInit2:				;@ BG tiles
;@----------------------------------------------------------------------------
	ldr r0,[koptr,#bgrRomBase]	;@ r0 = destination
	ldr r1,=vromBase0			;@ r1 = source even bytes1
	ldr r1,[r1]
	stmfd sp!,{r4-r8,lr}
	add r2,r1,#0x40000			;@ Offset even bytes 2
	mov r6,#0x40000				;@ Length
	ldr r8,=0xF0F0F0F0
								;@ E1 O1 E2 O2
bgChr2:							;@ 01 23 45 67 -> 02 13 46 57
	mov r4,#0
	ldrb r5,[r2],#1				;@ Odd bytes 2
	orr r5,r5,r5,lsl#12
	and r5,r5,r8
	orr r4,r4,r5,lsl#12

	ldrb r5,[r1],#1				;@ Odd bytes 1
	orr r5,r5,r5,lsl#12
	and r5,r5,r8
	orr r4,r4,r5,lsl#16

	ldrb r5,[r2],#1				;@ Even bytes 2
	orr r5,r5,r5,lsl#12
	and r5,r5,r8
	orr r4,r4,r5,lsr#4

	ldrb r5,[r1],#1				;@ Even bytes 1
	orr r5,r5,r5,lsl#12
	and r5,r5,r8
	orr r4,r4,r5,lsr#0

	str r4,[r0],#4

	subs r6,r6,#4
	bne bgChr2

	ldmfd sp!,{r4-r8,pc}
;@----------------------------------------------------------------------------
sprInit:					;@ SPR tiles
;@----------------------------------------------------------------------------
	stmfd sp!,{r4-r6,lr}
	ldr r4,[koptr,#spriteRomBase]
	ldr r5,=vromBase0			;@ r1 = even bytes
	ldr r5,[r5]
	mov r6,#2					;@ Loop
sprChr1:
	mov r0,r4
	add r1,r5,#0x10000			;@ Offset to sprites
	add r2,r1,#0x20000			;@ r2 = odd bytes
	mov r3,#0x20000				;@ Length
	bl convertTiles5885

	add r4,r4,#0x20000
	add r5,r5,#0x40000
	subs r6,r6,#1
	bne sprChr1

	ldmfd sp!,{r4-r6,pc}
;@----------------------------------------------------------------------------
sprInit2:					;@ SPR tiles
;@----------------------------------------------------------------------------
	stmfd sp!,{r4-r8,lr}
	ldr r0,[koptr,#spriteRomBase]
	ldr r1,=vromBase0			;@ r1 = source even bytes
	ldr r1,[r1]
	add r1,r1,#0x20000			;@ Offset to sprites
	ldr lr,=0x0F0F0F0F
	mov r7,#2
sprChr2_2:
	mov r6,#0x20000				;@ Length
sprChr2:
	ldrb r5,[r1],#1
	ldrb r4,[r1],#1
	orr r4,r4,r5,lsl#8
	ldrb r5,[r1],#1
	orr r4,r4,r5,lsl#24
	ldrb r5,[r1],#1
	orr r4,r4,r5,lsl#16

	and r5,lr,r4,lsr#4
	and r4,lr,r4
	orr r4,r5,r4,lsl#4
	str r4,[r0],#4

	subs r6,r6,#4
	bne sprChr2
	add r1,r1,#0x20000
	subs r7,r7,#1
	bne sprChr2_2

	ldmfd sp!,{r4-r8,pc}

;@----------------------------------------------------------------------------
paletteInitJackal:		;@ r0-r3 modified.
;@----------------------------------------------------------------------------
	stmfd sp!,{r4-r9,lr}
	mov r1,r0					;@ Gamma value = 0 -> 4
	ldr r8,=k007327Palette
	mov r7,#0xF8
	ldr r6,=MAPPED_RGB
	mov r4,#0x200				;@ K007327 rgb
noMap:							;@ Map 0bbbbbgggggrrrrr  ->  0bbbbbgggggrrrrr
	ldrb r9,[r8],#1
	ldrb r0,[r8],#1
	orr r9,r9,r0,lsl#8
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
paletteTxAllJackal:
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}

	ldr r1,=promBase			;@ Proms
	ldr r1,[r1]
	add r1,r1,#0x100			;@ LUT
	ldr r2,=MAPPED_RGB+0x20
	ldr r0,=EMUPALBUFF+0x200	;@ Sprites First
	bl paletteTx0
	add r2,r2,#0x200-0x20
	ldr r0,=EMUPALBUFF
	bl paletteTxNoLUT
	ldmfd sp!,{lr}
	bx lr

;@----------------------------------------------------------------------------
endFrameJackal:
;@----------------------------------------------------------------------------
	stmfd sp!,{koptr,lr}

	ldr r0,=k005885_1
	cmp koptr,r0
	ldmfdeq sp!,{koptr,pc}

	ldr koptr,=k005885_0
	ldr r0,=scrollTemp
	bl copyScrollValues
	mov r0,#BG_GFX
	bl convertTileMapJackal
	ldr r0,=tmpOamBuffer		;@ Destination
	ldr r0,[r0]
	bl convertSprites5885
;@--------------------------
	ldr r0,[koptr,#sprMemAlloc]
	ldrb r1,[koptr,#sprMemReload]
	ldr koptr,=k005885_1
	str r0,[koptr,#sprMemAlloc]
	cmp r1,#0
	strbne r1,[koptr,#sprMemReload]

	ldr r0,=tmpOamBuffer		;@ Destination
	ldr r0,[r0]
	add r0,r0,#64*8
	bl convertSprites5885
;@--------------------------
	ldr r0,[koptr,#sprMemAlloc]
	ldrb r1,[koptr,#sprMemReload]
	ldr koptr,=k005885_0
	str r0,[koptr,#sprMemAlloc]
	cmp r1,#0
	strbne r1,[koptr,#sprMemReload]

	ldmfd sp!,{koptr,pc}

;@----------------------------------------------------------------------------
k005885Ram_0_1R:			;@ Ram read (0x2000-0x3FFF)
;@----------------------------------------------------------------------------
	ldrb r1,chipBank
	tst addy,#0x1000
	biceq r1,r1,#0x08
	tst r1,#0x18
	beq k005885Ram_0R
	b k005885Ram_1R
;@----------------------------------------------------------------------------
k005885_0_1R:				;@ I/O read, 0x0000-0x005F
;@----------------------------------------------------------------------------
	cmp addy,#0x60
	bpl mem6809R0
	ldrb r1,chipBank
	tst r1,#0x10
	beq k005885_0R
	b k005885_1R

;@----------------------------------------------------------------------------
k005885Ram_0_1W:			;@ Ram write (0x2000-0x3FFF)
;@----------------------------------------------------------------------------
	ldrb r1,chipBank
	tst addy,#0x1000
	biceq r1,r1,#0x08
	tst r1,#0x18
	stmfd sp!,{r0,addy,lr}
	bleq k005885Ram_0W
	ldmfd sp!,{r0,addy,lr}
	ldrb r1,chipBank
	tst addy,#0x1000
	orreq r1,r1,#0x10
	tst r1,#0x18
	bne k005885Ram_1W
	bx lr
;@----------------------------------------------------------------------------
k005885_0_1W:				;@ I/O write  (0x0000-0x005F)
;@----------------------------------------------------------------------------
	cmp addy,#0x60
	bpl sharedRAM_W
	stmfd sp!,{r0,addy,lr}
	mov r1,addy
	ldr koptr,=k005885_0
	bl k005885_W
	ldmfd sp,{r0,r1}
	ldr koptr,=k005885_1
	bl k005885_W
	ldmfd sp!,{r0,addy,pc}
;@----------------------------------------------------------------------------
k007327Read:				;@ (0x4000-0x5FFF)
;@----------------------------------------------------------------------------
	bic r1,addy,#0xFF000
	ldr r2,=k007327Palette
	ldrb r0,[r2,r1]
	bx lr

;@----------------------------------------------------------------------------
k007327Write:				;@ (0x4000-0x5FFF)
;@----------------------------------------------------------------------------
	bic r1,addy,#0xFF000
	ldr r2,=k007327Palette
	strb r0,[r2,r1]
	bx lr

;@----------------------------------------------------------------------------
YM0_R:						;@ (0x2000-0x3FFF)
;@----------------------------------------------------------------------------
	tst r12,#1
//	ldr ymptr,=YM2151_0
	mov r0,#0
//	bne YM2151DataR
	ldr r0,status
	add r0,r0,#1
	str r0,status
	bx lr
;@----------------------------------------------------------------------------
YM0_W:						;@ (0x2000-0x3FFF)
;@----------------------------------------------------------------------------
	tst r12,#1
//	ldr ymptr,=YM2151_0
//	bne YM2151DataW
//	b YM2151IndexW
	bx lr
;@----------------------------------------------------------------------------
JackalIO_R:					;@ I/O read (0x0010-0x0018)
;@----------------------------------------------------------------------------
	subs r1,addy,#0x0010
	bmi k005885_0_1R
	cmp r1,#0x0009
	ldrmi pc,[pc,r1,lsl#2]
;@---------------------------
	b k005885_0_1R
;@io_read_tbl
	.long Input4_R				;@ 0x0010
	.long Input0_R				;@ 0x0011
	.long Input1_R				;@ 0x0012
	.long Input2_R				;@ 0x0013
	.long empty_IO_R			;@ 0x0014
	.long empty_IO_R			;@ 0x0015
	.long empty_IO_R			;@ 0x0016
	.long empty_IO_R			;@ 0x0017
	.long Input5_R				;@ 0x0018

;@----------------------------------------------------------------------------
JackalIO_W:					;@I/O write (0x0019,0x001C)
;@----------------------------------------------------------------------------
	cmp addy,#0x0019
	beq watchDogW
	cmp addy,#0x001C
	cmpne addy,#0x001E
	beq jkCoinW
	b k005885_0_1W

;@----------------------------------------------------------------------------
chipBank:
	.long 0
status:
	.long 0

;@----------------------------------------------------------------------------
	.end
#endif // #ifdef __arm__
