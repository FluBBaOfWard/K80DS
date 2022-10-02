#ifdef __arm__

#include "Shared/nds_asm.h"
#include "ARM6809/ARM6809.i"
#include "ARMZ80/ARMZ80.i"
#include "K005849/K005849.i"

#define CYCLE_PSL (196)

	.global run
	.global cpuReset
	.global frameTotal
	.global waitMaskIn
	.global waitMaskOut
	.global cpu1SetIRQ


	.syntax unified
	.arm

	.section .text
	.align 2
;@----------------------------------------------------------------------------
run:		;@ Return after 1 frame
	.type   run STT_FUNC
;@----------------------------------------------------------------------------
	ldrh r0,waitCountIn
	add r0,r0,#1
	ands r0,r0,r0,lsr#8
	strb r0,waitCountIn
	bxne lr
	stmfd sp!,{r4-r11,lr}

;@----------------------------------------------------------------------------
runStart:
;@----------------------------------------------------------------------------
	ldr r0,=EMUinput
	ldr r0,[r0]

	ldr r2,=yStart
	ldrb r1,[r2]
	tst r0,#0x200				;@ L?
	subsne r1,#1
	movmi r1,#0
	tst r0,#0x100				;@ R?
	addne r1,#1
	cmp r1,#GAME_HEIGHT-SCREEN_HEIGHT
	movpl r1,#GAME_HEIGHT-SCREEN_HEIGHT
	strb r1,[r2]

	bl refreshEMUjoypads		;@ Z=1 if communication ok

;@----------------------------------------------------------------------------
konamiFrameLoop:
;@----------------------------------------------------------------------------
	ldr z80optbl,=Z80OpTable
	ldr r0,z80CyclesPerScanline
	bl Z80RestoreAndRunXCycles
	add r0,z80optbl,#z80Regs
	stmia r0,{z80f-z80pc,z80sp}			;@ Save Z80 state
	bl ym2203_0_Run
;@--------------------------------------
	ldr m6809optbl,=m6809OpTable
	ldr r0,m6809CyclesPerScanline
	b m6809RestoreAndRunXCycles
ihM6809End:
	add r0,m6809optbl,#m6809Regs
	stmia r0,{m6809f-m6809pc,m6809sp}	;@ Save M6809 state
;@--------------------------------------
	ldr koptr,=k005885_0
	bl doScanline
	cmp r0,#0
	bne konamiFrameLoop
;@----------------------------------------------------------------------------

	ldr r1,=fpsValue
	ldr r0,[r1]
	add r0,r0,#1
	str r0,[r1]

	ldr r1,frameTotal
	add r1,r1,#1
	str r1,frameTotal

	ldrh r0,waitCountOut
	add r0,r0,#1
	ands r0,r0,r0,lsr#8
	strb r0,waitCountOut
	ldmfdeq sp!,{r4-r11,lr}		;@ Exit here if doing single frame:
	bxeq lr						;@ Return to rommenu()
	b runStart

;@----------------------------------------------------------------------------
m6809CyclesPerScanline:	.long 0
z80CyclesPerScanline:	.long 0
frameTotal:			.long 0		;@ Let Gui.c see frame count for savestates
waitCountIn:		.byte 0
waitMaskIn:			.byte 0
waitCountOut:		.byte 0
waitMaskOut:		.byte 0

;@----------------------------------------------------------------------------
cpu1SetIRQ:
;@----------------------------------------------------------------------------
	stmfd sp!,{z80optbl,lr}
	ldr z80optbl,=Z80OpTable
	bl Z80SetIRQPin
	ldmfd sp!,{z80optbl,pc}
;@----------------------------------------------------------------------------
cpuReset:		;@ Called by loadCart/resetGame, r0= game nr
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}

;@---Speed - 3.072MHz / 60Hz / 256 lines	;Iron Horse M6809.
	ldr r1,=CYCLE_PSL
	str r1,m6809CyclesPerScanline
;@--------------------------------------
	ldr m6809optbl,=m6809OpTable

	adr r4,cpuMapData
	cmp r0,#4							;@ Scooter Shooter?
	addeq r4,r4,#8
	bl map6809Memory

	adr r0,ihM6809End
	str r0,[m6809optbl,#m6809NextTimeout]
	str r0,[m6809optbl,#m6809NextTimeout_]

	mov r0,#0
	bl m6809Reset


;@---Speed - 3.072MHz / 60Hz / 256 lines	;Iron Horse Z80.
	ldr r0,=CYCLE_PSL
	str r0,z80CyclesPerScanline
;@--------------------------------------
	ldr z80optbl,=Z80OpTable

	adr r4,cpuMapData+16
	bl mapZ80Memory

	mov r0,z80optbl
	mov r1,#0
	bl Z80Reset

	ldmfd sp!,{lr}
	bx lr
;@----------------------------------------------------------------------------
cpuMapData:
;@	.byte 0x07,0x06,0x05,0x04,0xFD,0xF8,0xFE,0xFF			;@ Double Dribble CPU0
;@	.byte 0x0B,0x0A,0x09,0x08,0xFB,0xFB,0xF9,0xF8			;@ Double Dribble CPU1
;@	.byte 0x0F,0x0E,0x0D,0x0C,0xFB,0xFB,0xFB,0xFA			;@ Double Dribble CPU2
;@	.byte 0x05,0x04,0x03,0x02,0x01,0x00,0xFE,0xFF			;@ Finalizer
;@	.byte 0xFF,0xFE,0x05,0x04,0x03,0x02,0x01,0x00			;@ Green Beret
	.byte 0x05,0x04,0x03,0x02,0x01,0x00,0xFE,0xFF			;@ Iron Horse M6809
	.byte 0x05,0x04,0x01,0x00,0x03,0x02,0xFD,0xFC			;@ Scooter Shooter M6809
	.byte 0x80,0x80,0x80,0xFA,0x80,0xFB,0x07,0x06			;@ Iron Horse/Scooter Shooter Z80
;@	.byte 0x09,0x08,0x03,0x02,0x01,0x00,0xFE,0xFF			;@ Jackal CPU0
;@	.byte 0x0D,0x0C,0x0B,0x0A,0xF8,0xFD,0xFA,0xFB			;@ Jackal CPU1
;@	.byte 0x03,0x02,0x01,0x00,0xF9,0xF9,0xFF,0xFE			;@ Jail Break
;@----------------------------------------------------------------------------
map6809Memory:
	stmfd sp!,{r5,lr}
	mov r5,#0x80
m6809DataLoop:
	mov r0,r5
	ldrb r1,[r4],#1
	bl m6809Mapper
	movs r5,r5,lsr#1
	bne m6809DataLoop
	ldmfd sp!,{r5,pc}
;@----------------------------------------------------------------------------
mapZ80Memory:
	stmfd sp!,{r5,lr}
	mov r5,#0x80
z80DataLoop:
	mov r0,r5
	ldrb r1,[r4],#1
	bl z80Mapper
	movs r5,r5,lsr#1
	bne z80DataLoop
	ldmfd sp!,{r5,pc}
;@----------------------------------------------------------------------------
	.end
#endif // #ifdef __arm__
