#ifdef __arm__

#include "Shared/EmuSettings.h"
#include "ARM6809/ARM6809mac.h"
#include "ARMZ80/ARMZ80.i"
#include "K005849/K005849.i"

	.global machineInit
	.global loadCart
	.global m6809Mapper
	.global z80Mapper
	.global emuFlags
	.global romNum
	.global cartFlags
	.global romStart
	.global vromBase0
	.global vromBase1
	.global promBase
	.global gberetMapRom

	.global ROM_Space


	.syntax unified
	.arm

	.section .rodata
	.align 2

rawRom:
/*
// Iron Horse
// Main cpu
	.incbin "ironhors/13c_h03.bin"
	.incbin "ironhors/12c_h02.bin"
// Sound cpu
	.incbin "ironhors/10c_h01.bin"
// Graphics
	.incbin "ironhors/08f_h06.bin"
	.incbin "ironhors/09f_h07.bin"
	.incbin "ironhors/07f_h05.bin"
	.incbin "ironhors/06f_h04.bin"
// Proms
	.incbin "ironhors/03f_h08.bin"
	.incbin "ironhors/04f_h09.bin"
	.incbin "ironhors/05f_h10.bin"
	.incbin "ironhors/10f_h12.bin"
	.incbin "ironhors/10f_h11.bin"
*/
/*
	.incbin "ironhors/ironhors.008"
	.incbin "ironhors/ironhors.009"
//	.incbin "ironhors/ironhors.007"
//	.incbin "ironhors/ironhors.010"
	.incbin "ironhors/ironhors.001"
	.incbin "ironhors/ironhors.002"
	.incbin "ironhors/ironhors.003"
	.incbin "ironhors/ironhors.004"
	.incbin "ironhors/ironhors.005"
	.incbin "ironhors/ironhors.006"
	.incbin "ironhors/ironcol.003"
	.incbin "ironhors/ironcol.001"
	.incbin "ironhors/ironcol.002"
	.incbin "ironhors/10f_h12.bin"
	.incbin "ironhors/ironcol.005"
*/
/*
	.incbin "ironhors/560-k03.13c"
	.incbin "ironhors/560-k02.12c"
//	.incbin "ironhors/560-j01.10c"
	.incbin "ironhors/560-j06.8f"
	.incbin "ironhors/560-j05.7f"
	.incbin "ironhors/560-k07.9f"
	.incbin "ironhors/560-k04.6f"
	.incbin "ironhors/03f_h08.bin"
	.incbin "ironhors/04f_h09.bin"
	.incbin "ironhors/05f_h10.bin"
	.incbin "ironhors/10f_h12.bin"
	.incbin "ironhors/10f_h11.bin"
*/
/*
// Finalizer
// Main cpu
	.incbin "finalizr/523k01.9c"
	.incbin "finalizr/523k02.12c"
	.incbin "finalizr/523k03.13c"
//	.incbin "finalizr/d8749hd.bin"
	.incbin "finalizr/523h04.5e"
	.incbin "finalizr/523h05.6e"
	.incbin "finalizr/523h06.7e"
	.incbin "finalizr/523h07.5f"
	.incbin "finalizr/523h08.6f"
	.incbin "finalizr/523h09.7f"
	.incbin "finalizr/523h10.2f"
	.incbin "finalizr/523h11.3f"
	.incbin "finalizr/523h13.11f"
	.incbin "finalizr/523h12.10f"
*/
/*
// Main cpu
	.incbin "finalizr/finalizr.5"
	.incbin "finalizr/finalizr.6"
//	.incbin "finalizr/d8749hd.bin"
	.incbin "finalizr/523k04.5e"
	.incbin "finalizr/523k05.6e"
	.incbin "finalizr/523k06.7e"
	.incbin "finalizr/523k07.5f"
	.incbin "finalizr/523k08.6f"
	.incbin "finalizr/523k09.7f"
	.incbin "finalizr/523h10.2f"
	.incbin "finalizr/523h11.3f"
	.incbin "finalizr/523h13.11f"
	.incbin "finalizr/523h12.10f"
*/
/*
// Scooter Shooter
// Main cpu
	.incbin "scotrsht/gx545_g03_12c.bin"
	.incbin "scotrsht/gx545_g02_10c.bin"
// Sound cpu
	.incbin "scotrsht/gx545_g01_8c.bin"
// Gfx
	.incbin "scotrsht/gx545_g06_6f.bin"
	.incbin "scotrsht/gx545_h04_4f.bin"
	.incbin "scotrsht/gx545_g05_5f.bin"
	.space 0x8000
// Proms
	.incbin "scotrsht/gx545_6301_1f.bin"
	.incbin "scotrsht/gx545_6301_2f.bin"
	.incbin "scotrsht/gx545_6301_3f.bin"
	.incbin "scotrsht/gx545_6301_7f.bin"
	.incbin "scotrsht/gx545_6301_8f.bin"
*/
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

//	ldr r7,=rawRom
	ldr r7,=ROM_Space
								;@ r7=rombase til end of loadcart so DON'T FUCK IT UP
	cmp r0,#3
	str r7,romStart				;@ Set rom base
	add r0,r7,#0xC000			;@ 0xC000
	addeq r0,r0,#0x2000			;@ Far West
	str r0,cpu2Start			;@ Sound CPU ROM
	add r0,r0,#0x4000
	str r0,vromBase0			;@ Spr & bg
	str r0,vromBase1			;@
	add r0,r0,#0x20000
	str r0,promBase				;@ Colour prom

	ldr r4,=MEMMAPTBL_
	ldr r5,=RDMEMTBL_
	ldr r6,=WRMEMTBL_
	adr r8,pageMappings

	mov r0,#0
	ldr r2,=mem6809R0
	ldr r3,=rom_W
tbLoop1:
	add r1,r7,r0,lsl#13
	bl initMappingPage
	add r0,r0,#1
	cmp r0,#0x06
	bne tbLoop1

//	mov r0,#0
	ldr r2,=memZ80R0
tbLoop2:
	add r1,r7,r0,lsl#13
	bl initMappingPage
	add r0,r0,#1
	cmp r0,#0x08
	bne tbLoop2

	ldmfd r8!,{r0-r3}
tbLoop3:
	bl initMappingPage
	add r0,r0,#1
	cmp r0,#0x100
	bne tbLoop3

	mov r9,#8
tbLoop4:
	ldmfd r8!,{r0-r3}
	bl initMappingPage
	subs r9,r9,#1
	bne tbLoop4

	cmp r11,#4
	movne r0,#CHIP_K005885
	movpl r0,#CHIP_K005849
	bl gfxReset
	bl ioReset
	bl soundReset
	mov r0,r11
	bl cpuReset

	ldmfd sp!,{r4-r11,lr}
	bx lr

;@----------------------------------------------------------------------------
pageMappings:
	.long 0x08, emptySpace, empty_R, empty_W						;@ Empty
	.long 0xFA, emptySpace, soundLatchR, empty_W					;@ CPU2 Latch
	.long 0xFB, soundCpuRam, memZ80R2, ramZ80W2						;@ CPU2 RAM
	.long 0xF8, emuRAM, memZ80R6, k005849Ram_0W						;@ Graphic
	.long 0xFC, emuRAM, mem6809R0, k005849Ram_0W					;@ Graphic
	.long 0xFE, emuRAM, mem6809R1, k005885Ram_0W					;@ Graphic
	.long 0xF9, emptySpace, GreenBeretIO_R, GreenBeretIO_W			;@ IO
	.long 0xFD, emptySpace, ScooterShooterIO_R, ScooterShooterIO_W	;@ IO
	.long 0xFF, emptySpace, IronHorseIO_R, IronHorseIO_W			;@ IO
;@----------------------------------------------------------------------------
initMappingPage:	;@ r0=page, r1=mem, r2=rdMem, r3=wrMem
;@----------------------------------------------------------------------------
	str r1,[r4,r0,lsl#2]		;@ MemMap
	str r2,[r5,r0,lsl#2]		;@ RdMem
	str r3,[r6,r0,lsl#2]		;@ WrMem
	bx lr

;@----------------------------------------------------------------------------
//	.section itcm
;@----------------------------------------------------------------------------

;@----------------------------------------------------------------------------
m6809Mapper:		;@ Rom paging.. r0=which pages to change, r1=page nr.
;@----------------------------------------------------------------------------
	ands r0,r0,#0xFF			;@ Safety
	bxeq lr
	stmfd sp!,{r3-r8,lr}
	ldr r5,=MEMMAPTBL_
	ldr r2,[r5,r1,lsl#2]!
	ldr r3,[r5,#-1024]			;@ RDMEMTBL_
	ldr r4,[r5,#-2048]			;@ WRMEMTBL_

	mov r5,#0
	cmp r1,#0x88
	movmi r5,#12

	add r6,m6809ptr,#m6809ReadTbl
	add r7,m6809ptr,#m6809WriteTbl
	add r8,m6809ptr,#m6809MemTbl
	b m6809MemAps
m6809MemApl:
	add r6,r6,#4
	add r7,r7,#4
	add r8,r8,#4
m6809MemAp2:
	add r3,r3,r5
	sub r2,r2,#0x2000
m6809MemAps:
	movs r0,r0,lsr#1
	bcc m6809MemApl				;@ C=0
	strcs r3,[r6],#4			;@ readmem_tbl
	strcs r4,[r7],#4			;@ writemem_tb
	strcs r2,[r8],#4			;@ memmap_tbl
	bne m6809MemAp2
;@------------------------------------------
m6809Flush:		;@ update cpu_pc & lastbank
;@------------------------------------------
	reEncodePC
	ldmfd sp!,{r3-r8,lr}
	bx lr

;@----------------------------------------------------------------------------
z80Mapper:		;@ Rom paging.. r0=which pages to change, r1=page nr.
;@----------------------------------------------------------------------------
	ands r0,r0,#0xFF			;@ Safety
	bxeq lr
	stmfd sp!,{r3-r8,lr}
	ldr r5,=MEMMAPTBL_
	ldr r2,[r5,r1,lsl#2]!
	ldr r3,[r5,#-1024]			;@ RDMEMTBL_
	ldr r4,[r5,#-2048]			;@ WRMEMTBL_

	mov r5,#0
	cmp r1,#0x88
	movmi r5,#12

	add r6,z80ptr,#z80ReadTbl
	add r7,z80ptr,#z80WriteTbl
	add r8,z80ptr,#z80MemTbl
	b z80MemAps
z80MemApl:
	add r6,r6,#4
	add r7,r7,#4
	add r8,r8,#4
z80MemAp2:
	add r3,r3,r5
	sub r2,r2,#0x2000
z80MemAps:
	movs r0,r0,lsr#1
	bcc z80MemApl				;@ C=0
	strcs r3,[r6],#4			;@ readmem_tbl
	strcs r4,[r7],#4			;@ writemem_tb
	strcs r2,[r8],#4			;@ memmap_tbl
	bne z80MemAp2
;@------------------------------------------
z80Flush:		;@ Update cpu_pc & lastbank
;@------------------------------------------
//	reEncodePC
	ldmfd sp!,{r3-r8,lr}
	bx lr

;@----------------------------------------------------------------------------
gberetMapRom:
;@----------------------------------------------------------------------------
	and r0,r0,#0xE0
	ldr r1,=romStart
	ldr r1,[r1]
	sub r1,r1,#0x3800
	add r1,r1,r0,lsl#6
	str r1,[z80ptr,#z80MemTbl+28]
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

romStart:
	.long 0
cpu2Start:
	.long 0
vromBase0:
	.long 0
vromBase1:
	.long 0
promBase:
	.long 0

	.section .bss
WRMEMTBL_:
	.space 256*4
RDMEMTBL_:
	.space 256*4
MEMMAPTBL_:
	.space 256*4
soundCpuRam:
	.space 0x0400
ROM_Space:
	.space 0x32500
emptySpace:
	.space 0x2000
;@----------------------------------------------------------------------------
	.end
#endif // #ifdef __arm__
