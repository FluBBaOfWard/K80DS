#ifdef __arm__

#include "Shared/EmuSettings.h"
#include "ARM6809/ARM6809mac.h"
#include "ARMZ80/ARMZ80.i"
#include "K005849/K005849.i"

	.global romNum
	.global emuFlags
	.global cartFlags
	.global romStart
	.global mainCpu
	.global soundCpu
	.global vromBase0
	.global vromBase1
	.global promBase
	.global vlmBase
	.global bankReg
	.global SHARED_RAM
	.global SOUND_RAM
	.global ROM_Space
	.global emptySpace

	.global machineInit
	.global loadCart
	.global do6809MainCpuMapping
	.global doZ80MainCpuMapping
	.global m6809Mapper
	.global z80Mapper

	.syntax unified
	.arm

	.section .text
	.align 2
;@----------------------------------------------------------------------------
machineInit: 	;@ Called from C
	.type   machineInit STT_FUNC
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}
	bl gfxInit
//	bl ioInit
//	bl soundInit
	bl cpuInit

	ldmfd sp!,{lr}
	bx lr

	.section .ewram,"ax"
	.align 2
;@----------------------------------------------------------------------------
loadCart: 		;@ Called from C:  r0=rom number, r1=emuflags
	.type   loadCart STT_FUNC
;@----------------------------------------------------------------------------
	stmfd sp!,{r4-r11,lr}
	str r0,romNum
	str r1,emuFlags
	mov r11,r0

//	bl doCpuMappingDDribble
//	bl doCpuMappingGreenBeret
//	bl doCpuMappingIronHorse
//	bl doCpuMappingScooterShooter
	bl setupMachine
	ldr r1,cpuMappingPointer
	blx r1

	adr r1,romNum2ChipType
	ldrb r0,[r1,r11]
	bl gfxReset
	bl ioReset
	bl soundReset
	bl cpuReset

	ldmfd sp!,{r4-r11,lr}
endCmd:
	bx lr

;@----------------------------------------------------------------------------
setupMachine:					;@ r0=num number
;@----------------------------------------------------------------------------
	cmp r0,#11
	bxpl lr

	adr r1,romNum2Machine
	ldrb r0,[r1,r0]
	adr r1,machineFunctions
	add r1,r1,r0,lsl#5
	ldr r2,[r1],#4
	str r2,cpuMappingPointer
	ldr r2,[r1],#4
	ldr r0,=frameLoopPtr
	str r2,[r0]
	ldr r2,[r1],#4
	ldr r0,=gfxResetPtr
	str r2,[r0]
	ldr r2,[r1],#4
	ldr r0,=paletteInitPtr
	str r2,[r0]
	ldr r2,[r1],#4
	ldr r0,=paletteTxAllPtr
	str r2,[r0]
	bx lr

;@----------------------------------------------------------------------------
romNum2Machine:
	.byte 0, 0, 0, 0, 1, 2, 2, 2, 2, 3, 3
;@----------------------------------------------------------------------------
romNum2ChipType:
	.byte CHIP_K005885, CHIP_K005885, CHIP_K005885, CHIP_K005885, CHIP_K005849,
	.byte CHIP_K005849, CHIP_K005849, CHIP_K005849, CHIP_K005849, CHIP_K005885,
	.byte CHIP_K005885
	.align 2
;@----------------------------------------------------------------------------
machineFunctions:
	.long doCpuMappingIronHorse, ihRunFrame, gfxResetIronHorse, paletteInitIronHorse
	.long paletteTxAllIronHorse, 0, 0, 0
	.long doCpuMappingScooterShooter, ihRunFrame, gfxResetIronHorse, paletteInitScooterShooter
	.long paletteTxAllIronHorse, 0, 0, 0
	.long doCpuMappingGreenBeret, gbRunFrame, gfxResetGreenBeret, paletteInitGreenBeret
	.long paletteTxAllGreenBeret, 0, 0, 0
	.long doCpuMappingDDribble, ddRunFrame, gfxResetDDribble, paletteInitDDribble
	.long paletteTxAllDDribble, 0, 0, 0

;@----------------------------------------------------------------------------
doZ80MainCpuMapping:
;@----------------------------------------------------------------------------
	ldr r0,=Z80OpTable
	ldr r1,mainCpu
;@----------------------------------------------------------------------------
z80Mapper:		;@ Rom paging.. r0=cpuptr, r1=romBase, r2=mapping table.
;@----------------------------------------------------------------------------
	stmfd sp!,{r4-r8,lr}

	add r7,r0,#z80MemTbl
	add r8,r0,#z80ReadTbl
	add lr,r0,#z80WriteTbl

	mov r6,#8
z80MLoop:
	ldmia r2!,{r3-r5}
	cmp r3,#0x100
	addmi r3,r1,r3,lsl#13
	rsb r0,r6,#8
	sub r3,r3,r0,lsl#13

	str r3,[r7],#4
	str r4,[r8],#4
	str r5,[lr],#4
	subs r6,r6,#1
	bne z80MLoop
;@------------------------------------------
z80Flush:		;@ Update cpu_pc & lastbank
;@------------------------------------------
//	reEncodePC
	ldmfd sp!,{r4-r8,lr}
	bx lr

;@----------------------------------------------------------------------------
do6809MainCpuMapping:
;@----------------------------------------------------------------------------
	ldr r0,=m6809CPU0
	ldr r1,mainCpu
;@----------------------------------------------------------------------------
m6809Mapper:		;@ Rom paging.. r0=cpuptr, r1=romBase, r2=mapping table.
;@----------------------------------------------------------------------------
	stmfd sp!,{r4-r8,lr}

	add r7,r0,#m6809MemTbl
	add r8,r0,#m6809ReadTbl
	add lr,r0,#m6809WriteTbl

	mov r6,#8
m6809M2Loop:
	ldmia r2!,{r3-r5}
	cmp r3,#0x100
	addmi r3,r1,r3,lsl#13
	rsb r0,r6,#8
	sub r3,r3,r0,lsl#13

	str r3,[r7],#4
	str r4,[r8],#4
	str r5,[lr],#4
	subs r6,r6,#1
	bne m6809M2Loop
;@------------------------------------------
m6809Flush:		;@ Update cpu_pc & lastbank
;@------------------------------------------
	reEncodePC
	ldmfd sp!,{r4-r8,lr}
	bx lr

;@----------------------------------------------------------------------------

romNum:
	.long 0						;@ romnumber
romInfo:						;@ Keep emuflags/BGmirror together for savestate/loadstate
emuFlags:
	.byte 0						;@ emuflags      (label this so Gui.c can take a peek) see EmuSettings.h for bitfields
//scaling:
	.byte SCALED				;@ (display type)
	.byte 0,0					;@ (sprite follow val)
cartFlags:
	.byte 0 					;@ cartflags
	.space 3
cpuMappingPointer:
	.long endCmd
romStart:
mainCpu:
	.long 0
soundCpu:
cpu2Base:
	.long 0
cpu3Base:
	.long 0
vromBase0:
	.long 0
vromBase1:
	.long 0
vromBase2:
	.long 0
promBase:
	.long 0
vlmBase:
	.long 0

	.section .bss
	.align 2
SHARED_RAM:
	.space 0x2000
SOUND_RAM:
	.space 0x0800
ROM_Space:
	.space 0x10012C
emptySpace:
	.space 0x2000
;@----------------------------------------------------------------------------
	.end
#endif // #ifdef __arm__
