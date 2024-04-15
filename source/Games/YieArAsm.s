#ifdef __arm__

#include "../Shared/nds_asm.h"
#include "../ARM6809/ARM6809.i"
#include "../YieArVideo/YieArVideo.i"


	.global doCpuMappingYieAr
	.global gfxResetYieAr
	.global paletteInitYieAr
	.global paletteTxAllYieAr
	.global endFrameYieAr

	.global yieAr_0
	.global yieArRam_0R
	.global yieArRam_0W
	.global yieAr_0W

	.syntax unified
	.arm

	.section .text
	.align 2


;@----------------------------------------------------------------------------
doCpuMappingYieAr:
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}
	ldr r0,=vlm5030Chip
	ldr r0,[r0]
	ldr r1,=vlmBase
	ldr r1,[r1]
	mov r2,#0x2000				;@ ROM size
	blx VLM5030_set_rom
	ldmfd sp!,{lr}

	adr r2,yieArMapping
	b do6809MainCpuMapping
;@----------------------------------------------------------------------------
yieArMapping:						;@ Yie Ar Kung-Fu
	.long emptySpace, VLM_YA_R, empty_W							;@ IO
	.long emptySpace, empty_R, empty_W							;@ Empty
	.long SHARED_RAM, YieArIO_R, YieArIO_W						;@ Graphic
	.long emptySpace, empty_R, empty_W							;@ Empty
	.long 0, mem6809R4, rom_W									;@ ROM
	.long 1, mem6809R5, rom_W									;@ ROM
	.long 2, mem6809R6, rom_W									;@ ROM
	.long 3, mem6809R7, rom_W									;@ ROM

;@----------------------------------------------------------------------------
gfxResetYieAr:					;@ Called with CPU reset
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}

	ldr r0,=Gfx2Obj
	bl yiearInit

	ldr r0,=m6809SetNMIPinCurrentCpu
	ldr r1,=m6809SetIRQPinCurrentCpu
	ldr r2,=SHARED_RAM+0x1000
	bl yiearReset0
	bl bgInit

	mov r0,#24
	ldr r1,=spriteCount
	strb r0,[r1]
	mov r0,#0x11
	ldr r1,=enabledVideo
	strb r0,[r1]

	mov r1,#REG_BASE
	ldr r0,=DISPLAY_SPR_1D | DISPLAY_BG0_ACTIVE | DISPLAY_SPR_ACTIVE | DISPLAY_WIN0_ON
	strh r0,[r1,#REG_DISPCNT]


	bl paletteTxAllYieAr				;@ Transfer palette

	ldr r0,=scrollTemp
	mov r1,#0
	mov r2,#0x100
	bl memset_

	ldmfd sp!,{pc}

;@----------------------------------------------------------------------------
bgInit:					;@ BG tiles
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}
	ldr r0,=BG_GFX+0x8000		;@ r0 = NDS BG tileset
	ldr r1,=vromBase0
	ldr r1,[r1]					;@ r1 = even bytes
	bl yiearConvertTiles

	ldr r0,=vromBase1
	ldr r0,[r0]					;@ r1 = even bytes
	str r0,[koptr,#spriteRomBase]

	ldmfd sp!,{lr}
	bx lr

;@----------------------------------------------------------------------------
paletteInitYieAr:		;@ r0-r3 modified.
;@----------------------------------------------------------------------------
	stmfd sp!,{r4-r7,lr}
	mov r1,r0					;@ Gamma value = 0 -> 4
	mov r7,#0xE0
	ldr r6,=MAPPED_RGB
	mov r4,#0x200				;@ Yie Ar bgr
	sub r4,r4,#2
noMap:							;@ Map bbgggrrr  ->  0bbbbbgggggrrrrr
	and r0,r7,r4,lsl#4			;@ Red ready
	bl gPrefix
	mov r5,r0

	and r0,r7,r4,lsl#1			;@ Green ready
	bl gPrefix
	orr r5,r5,r0,lsl#5

	and r0,r7,r4,lsr#1			;@ Blue ready
	bl gPrefix
	orr r5,r5,r0,lsl#10

	strh r5,[r6,r4]
	subs r4,r4,#2
	bpl noMap

	ldmfd sp!,{r4-r7,lr}
	bx lr

;@----------------------------------------------------------------------------
gPrefix:
	orr r0,r0,r0,lsr#3
	orr r0,r0,r0,lsr#3
	b gammaConvert
;@----------------------------------------------------------------------------
paletteTxAllYieAr:
;@----------------------------------------------------------------------------
	stmfd sp!,{r4-r5}

	ldr r2,=promBase			;@ Proms
	ldr r2,[r2]
	ldr r3,=MAPPED_RGB
	ldr r4,=EMUPALBUFF
	add r5,r4,#0x200
	mov r1,#0x10
noMap2:
	ldrb r0,[r2],#1
	mov r0,r0,lsl#1
	ldrh r0,[r3,r0]
	strh r0,[r5],#2
	subs r1,r1,#1
	bne noMap2

	mov r1,#0x10
noMap3:
	ldrb r0,[r2],#1
	mov r0,r0,lsl#1
	ldrh r0,[r3,r0]
	strh r0,[r4],#2
	subs r1,r1,#1
	bne noMap3

	ldmfd sp!,{r4-r5}
	bx lr

;@----------------------------------------------------------------------------
endFrameYieAr:					;@ Called just before screen end (~line 240)	(r0-r2 safe to use)
;@----------------------------------------------------------------------------
	stmfd sp!,{koptr,lr}

	adr koptr,yieAr_0
	mov r0,#BG_GFX
	bl yiearConvertTileMap
	ldr r0,=tmpOamBuffer		;@ Destination
	ldr r0,[r0]
	bl yiearConvertSprites

	ldmfd sp!,{koptr,pc}
;@----------------------------------------------------------------------------
VLM_YA_R:
;@----------------------------------------------------------------------------
	cmp r12,#0x0000
	beq VLM_R
	b empty_R

;@----------------------------------------------------------------------------
yiearReset0:			;@ r0=periodicIrqFunc, r1=frameIrqFunc, r2=ram
;@----------------------------------------------------------------------------
	adr koptr,yieAr_0
	b yiearReset
;@----------------------------------------------------------------------------
yieArRam_0R:				;@ Ram read (0x5000-0x5FFF)
;@----------------------------------------------------------------------------
	stmfd sp!,{addy,lr}
	mov r1,addy
	adr koptr,yieAr_0
	bl yiearRamR
	ldmfd sp!,{addy,pc}
;@----------------------------------------------------------------------------
yieArRam_0W:				;@ Ram write (0x5000-0x5FFF)
;@----------------------------------------------------------------------------
	stmfd sp!,{addy,lr}
	mov r1,addy
	adr koptr,yieAr_0
	bl yiearRamW
	ldmfd sp!,{addy,pc}
;@----------------------------------------------------------------------------
yieAr_0W:					;@ I/O write  (0x4000)
;@----------------------------------------------------------------------------
	stmfd sp!,{addy,lr}
	mov r1,addy
	adr koptr,yieAr_0
	bl yiearW
	ldmfd sp!,{addy,pc}

;@----------------------------------------------------------------------------
yieAr_0:
	.space yieArSize

;@----------------------------------------------------------------------------
	.end
#endif // #ifdef __arm__
