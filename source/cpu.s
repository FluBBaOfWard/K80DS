#ifdef __arm__

#include "Shared/nds_asm.h"
#include "ARM6809/ARM6809.i"
#include "ARMZ80/ARMZ80.i"
#include "K005849/K005849.i"

#define CYCLE_PSL (H_PIXEL_COUNT/2)

	.global m6809CPU0
	.global m6809CPU1
	.global m6809CPU2

	.global run
	.global stepFrame
	.global cpuInit
	.global cpuReset
	.global frameTotal
	.global waitMaskIn
	.global waitMaskOut
	.global cpu01SetFIRQ
	.global cpu012SetIRQ
	.global cpu01SetNMI
	.global cpu1SetIRQ

	.syntax unified
	.arm

#if GBA
	.section .ewram, "ax", %progbits	;@ For the GBA
#else
	.section .text						;@ For anything else
#endif
	.align 2
;@----------------------------------------------------------------------------
run:						;@ Return after X frame(s)
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

	ldr r0,frameLoopPtr
	blx r0

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
//frameLoopPtr:			.long ddRunFrame
//frameLoopPtr:			.long gbRunFrame
frameLoopPtr:			.long ihRunFrame
m6809CyclesPerScanline:	.long 0
z80CyclesPerScanline:	.long 0
frameTotal:			.long 0		;@ Let Gui.c see frame count for savestates
waitCountIn:		.byte 0
waitMaskIn:			.byte 0
waitCountOut:		.byte 0
waitMaskOut:		.byte 0

;@----------------------------------------------------------------------------
ddRunFrame:					;@ Double Dribble
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}
ddFrameLoop:
	ldr m6809ptr,=m6809CPU2
	mov r0,#CYCLE_PSL
	bl m6809RestoreAndRunXCycles
	add r0,m6809ptr,#m6809Regs
	stmia r0,{m6809f-m6809pc,m6809sp}	;@ Save M6809 state
	bl ym2203_0_Run
;@--------------------------------------
	ldr m6809ptr,=m6809CPU1
	mov r0,#CYCLE_PSL
	bl m6809RestoreAndRunXCycles
	add r0,m6809ptr,#m6809Regs
	stmia r0,{m6809f-m6809pc,m6809sp}	;@ Save M6809 state
;@--------------------------------------
	ldr m6809ptr,=m6809CPU0
	mov r0,#CYCLE_PSL
	bl m6809RestoreAndRunXCycles
	add r0,m6809ptr,#m6809Regs
	stmia r0,{m6809f-m6809pc,m6809sp}	;@ Save M6809 state
;@--------------------------------------
	ldr koptr,=k005885_1
	bl doScanline
	ldr koptr,=k005885_0
	bl doScanline
	cmp r0,#0
	bne ddFrameLoop
	ldmfd sp!,{pc}

;@----------------------------------------------------------------------------
ihRunFrame:					;@ IronHorse/ScooterShooter
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}
ihFrameLoop:
	ldr z80ptr,=Z80OpTable
	ldr r0,z80CyclesPerScanline
	bl Z80RestoreAndRunXCycles
	add r0,z80ptr,#z80Regs
	stmia r0,{z80f-z80pc,z80sp}			;@ Save Z80 state
	bl ym2203_0_Run
;@--------------------------------------
	ldr m6809ptr,=m6809CPU0
	ldr r0,m6809CyclesPerScanline
	bl m6809RestoreAndRunXCycles
	add r0,m6809ptr,#m6809Regs
	stmia r0,{m6809f-m6809pc,m6809sp}	;@ Save M6809 state
;@--------------------------------------
	ldr koptr,=k005885_0
	bl doScanline
	cmp r0,#0
	bne ihFrameLoop
	ldmfd sp!,{pc}

;@----------------------------------------------------------------------------
gbRunFrame:					;@ GreenBeret/Mr.Goemon
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}
	ldr z80ptr,=Z80OpTable
	add r0,z80ptr,#z80Regs
	ldmia r0,{z80f-z80pc,z80sp}	;@ Restore Z80 state
;@----------------------------------------------------------------------------
gbFrameLoop:
	ldr r0,z80CyclesPerScanline
	bl Z80RunXCycles
	ldr koptr,=k005849_0
	bl doScanline
	cmp r0,#0
	bne gbFrameLoop
;@----------------------------------------------------------------------------
	add r0,z80ptr,#z80Regs
	stmia r0,{z80f-z80pc,z80sp}	;@ Save Z80 state
	ldmfd sp!,{pc}

;@----------------------------------------------------------------------------
stepFrame:					;@ Return after 1 frame
	.type   stepFrame STT_FUNC
;@----------------------------------------------------------------------------
	stmfd sp!,{r4-r11,lr}

	ldr r0,frameLoopPtr
	blx r0

	ldr r1,frameTotal
	add r1,r1,#1
	str r1,frameTotal

	ldmfd sp!,{r4-r11,lr}
	bx lr
;@----------------------------------------------------------------------------
cpu01SetFIRQ:
;@----------------------------------------------------------------------------
	stmfd sp!,{r0,m6809ptr,lr}
	ldr m6809ptr,=m6809CPU0
	bl m6809SetFIRQPin
	ldmfd sp!,{r0}
	ldr m6809ptr,=m6809CPU1
	bl m6809SetFIRQPin
	ldmfd sp!,{m6809ptr,pc}
;@----------------------------------------------------------------------------
cpu012SetIRQ:
;@----------------------------------------------------------------------------
	stmfd sp!,{r0,m6809ptr,lr}
	ldr m6809ptr,=m6809CPU0
	bl m6809SetIRQPin
	ldmfd sp,{r0}
	ldr m6809ptr,=m6809CPU1
	bl m6809SetIRQPin
	ldmfd sp!,{r0}
	ldr m6809ptr,=m6809CPU2
	bl m6809SetIRQPin
	ldmfd sp!,{m6809ptr,pc}
;@----------------------------------------------------------------------------
cpu01SetNMI:
;@----------------------------------------------------------------------------
	stmfd sp!,{r0,m6809ptr,lr}
	ldr m6809ptr,=m6809CPU0
	bl m6809SetNMIPin
	ldmfd sp!,{r0}
	ldr m6809ptr,=m6809CPU1
	bl m6809SetNMIPin
	ldmfd sp!,{m6809ptr,pc}
;@----------------------------------------------------------------------------
cpu1SetIRQ:				;@ r0=pin state
;@----------------------------------------------------------------------------
	ldr r1,=Z80OpTable
	b Z80SetIRQPin
;@----------------------------------------------------------------------------
cpuInit:			;@ Called by machineInit
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}
	ldr r0,=m6809CPU0
	bl m6809Init
	ldr r0,=m6809CPU1
	bl m6809Init
	ldr r0,=m6809CPU2
	bl m6809Init
	ldmfd sp!,{lr}
	bx lr
;@----------------------------------------------------------------------------
cpuReset:		;@ Called by loadCart/resetGame
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}

;@ Iron Horse/Scooter Shooter/Double Dribble M6809.
;@---Speed - 1.536MHz / 61Hz / 262 lines
	ldr r1,=CYCLE_PSL/2
	str r1,m6809CyclesPerScanline
;@--------------------------------------
	ldr r0,=m6809CPU0
	bl m6809Reset
;@--------------------------------------
	ldr r0,=m6809CPU1
	bl m6809Reset
;@--------------------------------------
	ldr r0,=m6809CPU2
	bl m6809Reset

;@ Iron Horse/Scooter Shooter/Green Beret Z80.
;@---Speed - 3.072MHz / 61Hz / 262 lines
	ldr r0,=CYCLE_PSL
	str r0,z80CyclesPerScanline
;@--------------------------------------
	ldr r0,=Z80OpTable
	mov r1,#0
	bl Z80Reset

	ldmfd sp!,{lr}
	bx lr
;@----------------------------------------------------------------------------
#ifdef NDS
	.section .dtcm, "ax", %progbits		;@ For the NDS
#elif GBA
	.section .iwram, "ax", %progbits	;@ For the GBA
#endif
	.align 2
;@----------------------------------------------------------------------------
m6809CPU0:
	.space m6809Size
m6809CPU1:
	.space m6809Size
m6809CPU2:
	.space m6809Size
;@----------------------------------------------------------------------------
	.end
#endif // #ifdef __arm__
