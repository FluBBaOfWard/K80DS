#ifdef __arm__

#include "Shared/nds_asm.h"
#include "Shared/EmuSettings.h"
#include "K005849/K005849.i"

	.global gfxState
	.global gFlicker
	.global gTwitch
	.global gScaling
	.global gGfxMask
	.global yStart
	.global gfxChipType
	.global paletteBank
	.global k005849_0
	.global k005885_0
	.global k005885_1
	.global GFX_RAM0
	.global GFX_RAM1
	.global k005885Palette
	.global Gfx1Bg
	.global Gfx1Obj
	.global Gfx2Bg
	.global Gfx2Obj
	.global gfxResetPtr
	.global paletteInitPtr
	.global paletteTxAllPtr

	.global GFX_DISPCNT
	.global GFX_BG0CNT
	.global GFX_BG1CNT
	.global GFX_BG2CNT
	.global MAPPED_RGB
	.global EMUPALBUFF
	.global scrollTemp
	.global scrollTemp2
	.global tmpOamBuffer

	.global gfxInit
	.global gfxReset
	.global bgInit
	.global paletteInit
	.global paletteTxAll
	.global paletteTx0
	.global paletteTxNoLUT
	.global refreshGfx
	.global endFrame
	.global gammaConvert
	.global vblIrqHandler

	.global k005849Reset0
	.global k005885Reset0
	.global k005885Reset1
	.global k005849Ram_0R
	.global k005885Ram_0R
	.global k005885Ram_1R
	.global k005849_0R
	.global k005885_0R
	.global k005885_1R
	.global k005849Ram_0W
	.global k005885Ram_0W
	.global k005885Ram_1W
	.global k005849_0W
	.global k005885_0W

	addy		.req r12		;@ Used by CPU cores

	.syntax unified
	.arm

	.section .text
	.align 2
;@----------------------------------------------------------------------------
gfxInit:					;@ Called from machineInit
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}

	ldr r0,=OAM_BUFFER1			;@ No stray sprites please
	mov r1,#0x200+SCREEN_HEIGHT
	mov r2,#0x100
	bl memset_
	adr r0,scaleParms
	bl setupSpriteScaling

	ldmfd sp!,{pc}

;@----------------------------------------------------------------------------
scaleParms:					;@  NH     FH     NV     FV
	.long OAM_BUFFER1,0x0000,0x0100,0xff01,0x0120,0xfee1
;@----------------------------------------------------------------------------
gfxReset:					;@ Called with CPU reset, r0 = chip type
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}
	ldrb r1,gfxChipType
	strb r0,gfxChipType
	cmp r0,r1
	blne gfxInit

	ldr r0,=gfxState
	mov r1,#6					;@ 6*4
	bl memclr_					;@ Clear GFX regs

	mov r1,#REG_BASE
	ldr r0,=0x00FF				;@ start-end
	strh r0,[r1,#REG_WIN0H]
	mov r0,#SCREEN_HEIGHT		;@ start-end
	strh r0,[r1,#REG_WIN0V]
	mov r0,#0x0000
	strh r0,[r1,#REG_WINOUT]

	ldr r0,gfxResetPtr
	blx r0

	ldr r0,=gGammaValue
	ldrb r0,[r0]
	bl paletteInit				;@ Do palette mapping
	bl paletteTxAll				;@ Transfer it

	ldmfd sp!,{lr}
endGfx:
	bx lr
;@----------------------------------------------------------------------------
bgInit:					;@ BG tiles, r0=chip type
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}
	cmp r0,#CHIP_K005849
	ldr r0,=BG_GFX+0x8000		;@ r0 = NDS BG tileset
	str r0,[koptr,#bgrGfxDest]
	ldr r0,=Gfx1Bg				;@ r0 = DST tileset
	str r0,[koptr,#spriteRomBase]
	str r0,[koptr,#bgrRomBase]
	ldr r1,=vromBase0			;@ r1 = bitplane 0
	ldr r1,[r1]
	beq do5849Tiles
	add r2,r1,#0x10000			;@ r2 = bitplane 1
	mov r3,#0x20000				;@ Length
	bl convertTiles5885
	b skip5849T
do5849Tiles:
	mov r2,#0x18000				;@ Length
	bl convertTiles5849
skip5849T:
	ldr r0,=BG_GFX+0x4000		;@ r0 = NDS BG tileset
	bl addBackgroundTiles

	ldmfd sp!,{pc}

;@----------------------------------------------------------------------------
paletteInit:		;@ r0-r3 modified.
	.type paletteInit STT_FUNC
;@ Called by ui.c:  void paletteInit(gammaVal);
;@----------------------------------------------------------------------------
	ldr pc,paletteInitPtr
;@----------------------------------------------------------------------------
gammaConvert:	;@ Takes value in r0(0-0xFF), gamma in r1(0-4),returns new value in r0=0x1F
;@----------------------------------------------------------------------------
	rsb r2,r0,#0x100
	mul r3,r2,r2
	rsbs r2,r3,#0x10000
	rsb r3,r1,#4
	orr r0,r0,r0,lsl#8
	mul r2,r1,r2
	mla r0,r3,r0,r2
	mov r0,r0,lsr#13

	bx lr
;@----------------------------------------------------------------------------
paletteTxAll:				;@ Called from ui.c
	.type paletteTxAll STT_FUNC
;@----------------------------------------------------------------------------
	stmfd sp!,{r3,r12,lr}
	ldr r0,paletteTxAllPtr
	blx r0
	ldmfd sp!,{r3,r12,lr}
	bx lr
;@----------------------------------------------------------------------------
paletteTx0:					;@ r0=dst, r1=source, r2=Palette
;@----------------------------------------------------------------------------
	mov r3,#0x100
palTx0Loop:
	ldrb r12,[r1],#1
	and r12,r12,#0xF
	mov r12,r12,lsl#1
	ldrh r12,[r2,r12]
	strh r12,[r0],#2
	subs r3,r3,#1
	bne palTx0Loop
	bx lr
;@----------------------------------------------------------------------------
paletteTxNoLUT:				;@ r0=dst, r1=unused, r2=Palette
;@----------------------------------------------------------------------------
	mov r3,#0x100
palTxNoLutLoop:
	rsb r12,r3,#0x100
	mov r12,r12,lsl#1
	ldrh r12,[r2,r12]
	strh r12,[r0],#2
	subs r3,r3,#1
	bne palTxNoLutLoop
	bx lr
;@----------------------------------------------------------------------------
vblIrqHandler:
	.type vblIrqHandler STT_FUNC
;@----------------------------------------------------------------------------
	stmfd sp!,{r4-r8,lr}
	bl calculateFPS

	ldrb r0,gScaling
	cmp r0,#UNSCALED
	moveq r6,#0
	ldrne r6,=0x80000000 + ((GAME_HEIGHT-SCREEN_HEIGHT)*0x10000) / (SCREEN_HEIGHT-1)		;@ NDS 0x2B10 (was 0x2AAB)
	ldrbeq r8,yStart
	movne r8,#0
	add r8,r8,#0x10
	mov r7,r8,lsl#16
	orr r7,r7,#(GAME_WIDTH-SCREEN_WIDTH)/2

	ldr r0,gFlicker
	eors r0,r0,r0,lsl#31
	str r0,gFlicker
	addpl r6,r6,r6,lsl#16

	ldr r5,=SCROLLBUFF
	mov r4,r5

	ldr r2,=scrollTemp
	mov r12,#SCREEN_HEIGHT
scrolLoop2:
	ldr r0,[r2,r8,lsl#2]
	add r0,r0,r7
	mov r1,r0
	stmia r4!,{r0-r1}
	adds r6,r6,r6,lsl#16
	addcs r7,r7,#0x10000
	adc r8,r8,#1
	subs r12,r12,#1
	bne scrolLoop2


	mov r6,#REG_BASE
	strh r6,[r6,#REG_DMA0CNT_H]	;@ DMA0 stop

	add r1,r6,#REG_DMA0SAD
	mov r2,r5					;@ Setup DMA buffer for scrolling:
	ldmia r2!,{r4-r5}			;@ Read
	add r3,r6,#REG_BG0HOFS		;@ DMA0 always goes here
	stmia r3,{r4-r5}			;@ Set 1st value manually, HBL is AFTER 1st line
	ldr r4,=0x96600002			;@ noIRQ hblank 32bit repeat incsrc inc_reloaddst, 2 word
	stmia r1,{r2-r4}			;@ DMA0 go

	add r1,r6,#REG_DMA3SAD

	ldr r2,dmaOamBuffer			;@ DMA3 src, OAM transfer:
	mov r3,#OAM					;@ DMA3 dst
	mov r4,#0x84000000			;@ noIRQ 32bit incsrc incdst
	ldrb r7,gfxChipType
	cmp r7,#CHIP_K005849
	orreq r4,r4,#48*2			;@ 48 sprites * 2 longwords
	orrne r4,r4,#64*2			;@ 64 sprites * 2 longwords
	stmia r1,{r2-r4}			;@ DMA3 go

	ldr r2,=EMUPALBUFF			;@ DMA3 src, Palette transfer:
	mov r3,#BG_PALETTE			;@ DMA3 dst
	mov r4,#0x84000000			;@ noIRQ 32bit incsrc incdst
	orr r4,r4,#0x100			;@ 256 words (1024 bytes)
	stmia r1,{r2-r4}			;@ DMA3 go

	ldr koptr,=k005885_0
	ldrb r2,[koptr,#sprBank]
	cmp r7,#CHIP_K005849
	ldrheq r0,GFX_BG0CNT
	ldrne r0,=0x000A
	strh r0,[r6,#REG_BG0CNT]

	mov r0,#0x0017
	tst r2,#0x04				;@ Is left/right overlay on?
	biceq r0,#0x0004
	ldrb r1,gGfxMask
	bic r0,r0,r1
	strh r0,[r6,#REG_WININ]
	tst r2,#0x80				;@ 240/256 screen width.
	ldreq r0,=0x00FF			;@ start-end
	ldrne r0,=0x08F8			;@ start-end
	strh r0,[r6,#REG_WIN0H]

	blx scanKeys
	ldmfd sp!,{r4-r8,pc}


;@----------------------------------------------------------------------------
gFlicker:			.byte 1
					.space 2
gTwitch:			.byte 0

gScaling:			.byte SCALED
gGfxMask:			.byte 0
yStart:				.byte 0
					.byte 0
gfxResetPtr:		.long endGfx
paletteInitPtr:		.long endGfx
paletteTxAllPtr:	.long endGfx
;@----------------------------------------------------------------------------
refreshGfx:					;@ Called from C when changing scaling.
	.type refreshGfx STT_FUNC
;@----------------------------------------------------------------------------
	adr koptr,k005885_0
;@----------------------------------------------------------------------------
endFrame:					;@ Called just before screen end (~line 240)	(r0-r2 safe to use)
;@----------------------------------------------------------------------------
	stmfd sp!,{r3,lr}

//	bl endFrameDDribble

	ldr r0,=scrollTemp
	bl copyScrollValues

	mov r0,#BG_GFX
	bl convertTileMap
	ldr r0,tmpOamBuffer			;@ Destination
	bl convertSprites
;@--------------------------

	ldr r0,dmaOamBuffer
	ldr r1,tmpOamBuffer
	str r0,tmpOamBuffer
	str r1,dmaOamBuffer

	mov r0,#1
	str r0,oamBufferReady

	ldr r0,=windowTop			;@ Load wTop, store in wTop+4.......load wTop+8, store in wTop+12
	ldmia r0,{r1-r3}			;@ Load with increment after
	stmib r0,{r1-r3}			;@ Store with increment before

	ldmfd sp!,{r3,lr}
	bx lr

;@----------------------------------------------------------------------------

tmpOamBuffer:		.long OAM_BUFFER1
dmaOamBuffer:		.long OAM_BUFFER2

oamBufferReady:		.long 0
GFX_DISPCNT:		.long 0
GFX_BG0CNT:			.short 0
GFX_BG1CNT:			.short 0
GFX_BG2CNT:			.short 0
GFX_BG3CNT:			.short 0

;@----------------------------------------------------------------------------
k005849Reset0:
k005885Reset0:			;@ r0=periodicIrqFunc, r1=frameIrqFunc, r2=frame2IrqFunc
;@----------------------------------------------------------------------------
	ldr r3,=GFX_RAM0
	ldr koptr,=k005885_0
	b k005849Reset
;@----------------------------------------------------------------------------
k005885Reset1:			;@ r0=periodicIrqFunc, r1=frameIrqFunc, r2=frame2IrqFunc
;@----------------------------------------------------------------------------
	ldr r3,=GFX_RAM1
	adr koptr,k005885_1
	b k005849Reset
;@----------------------------------------------------------------------------
k005849Ram_0R:				;@ Ram read (0x0000-0x1FFF)
k005885Ram_0R:				;@ Ram read (0x2000-0x3FFF)
;@----------------------------------------------------------------------------
	stmfd sp!,{addy,lr}
	mov r1,addy
	adr koptr,k005885_0
	bl k005885Ram_R
	ldmfd sp!,{addy,pc}
;@----------------------------------------------------------------------------
k005885Ram_1R:				;@ Ram read (0x6000-0x7FFF)
;@----------------------------------------------------------------------------
	stmfd sp!,{addy,lr}
	mov r1,addy
	adr koptr,k005885_1
	bl k005885Ram_R
	ldmfd sp!,{addy,pc}
;@----------------------------------------------------------------------------
k005849_0R:					;@ I/O read, 0x2000-0x2044
;@----------------------------------------------------------------------------
	stmfd sp!,{addy,lr}
	mov r1,addy
	adr koptr,k005849_0
	bl k005849_R
	ldmfd sp!,{addy,pc}
;@----------------------------------------------------------------------------
k005885_0R:					;@ I/O read, 0x0000-0x005F
;@----------------------------------------------------------------------------
	stmfd sp!,{addy,lr}
	mov r1,addy
	adr koptr,k005885_0
	bl k005885_R
	ldmfd sp!,{addy,pc}
;@----------------------------------------------------------------------------
k005885_1R:					;@ I/O read, 0x0000-0x005F
;@----------------------------------------------------------------------------
	stmfd sp!,{addy,lr}
	mov r1,addy
	adr koptr,k005885_1
	bl k005885_R
	ldmfd sp!,{addy,pc}

;@----------------------------------------------------------------------------
k005849Ram_0W:				;@ Ram write (0x0000-0x1FFF)
k005885Ram_0W:				;@ Ram write (0x2000-0x3FFF)
;@----------------------------------------------------------------------------
	stmfd sp!,{addy,lr}
	mov r1,addy
	adr koptr,k005885_0
	bl k005885Ram_W
	ldmfd sp!,{addy,pc}
;@----------------------------------------------------------------------------
k005885Ram_1W:				;@ Ram write (0x6000-0x7FFF)
;@----------------------------------------------------------------------------
	stmfd sp!,{addy,lr}
	mov r1,addy
	adr koptr,k005885_1
	bl k005885Ram_W
	ldmfd sp!,{addy,pc}
;@----------------------------------------------------------------------------
k005849_0W:					;@ I/O write  (0x2000-0x2044)
;@----------------------------------------------------------------------------
	stmfd sp!,{addy,lr}
	mov r1,addy
	adr koptr,k005849_0
	bl k005849_W
	ldmfd sp!,{addy,pc}
;@----------------------------------------------------------------------------
k005885_0W:					;@ I/O write  (0x0000-0x005F)
;@----------------------------------------------------------------------------
	stmfd sp!,{addy,lr}
	mov r1,addy
	adr koptr,k005885_0
	bl k005885_W
	ldmfd sp!,{addy,pc}

k005849_0:
k005885_0:
	.space k005849Size
k005885_1:
	.space k005849Size
;@----------------------------------------------------------------------------

gfxState:
adjustBlend:
	.long 0
windowTop:
	.long 0,0,0,0		;@ L/R scrolling in unscaled mode

paletteBank:
	.long 0
gfxChipType:
	.byte CHIP_K005885			;@ K005849 or K005885
	.space 3

	.section .bss
	.align 2
scrollTemp:
	.space 0x100*4
scrollTemp2:
	.space 0x100*4
OAM_BUFFER1:
	.space 0x400
OAM_BUFFER2:
	.space 0x400
SCROLLBUFF:
	.space 0x400*3				;@ Scrollbuffer.
MAPPED_RGB:
	.space 0x400				;@ 0x400
EMUPALBUFF:
	.space 0x400
k005885Palette:
	.space 0x400
GFX_RAM0:
	.space 0x2000
	.space SPRBLOCKCOUNT*4
	.space BGBLOCKCOUNT*4
GFX_RAM1:
	.space 0x2000
	.space SPRBLOCKCOUNT*4
	.space BGBLOCKCOUNT*4

	.align 9
Gfx1Bg:
	.space 0x20000
Gfx1Obj:
	.space 0x20000
Gfx2Bg:
	.space 0x40000
Gfx2Obj:
	.space 0x40000

;@----------------------------------------------------------------------------
	.end
#endif // #ifdef __arm__
