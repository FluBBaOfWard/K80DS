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
	.global ROM_Space

	.global machineInit
	.global loadCart
	.global m6809Mapper

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

	ldr r4,=MEMMAPTBL_
	ldr r5,=RDMEMTBL_
	ldr r6,=WRMEMTBL_

	mov r0,#0
	ldr r2,=mem6809R0
	ldr r3,=rom_W
tbLoop1:
	add r1,r7,r0,lsl#13
	bl initMappingPage
	add r0,r0,#1
	cmp r0,#0x06
	bne tbLoop1

	adr r8,pageMappings
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

	ldr r0,=Z80OpTable
	ldr r1,soundCpu
	adr r2,ironHorseZ80Mapping
	bl z80Mapper2

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

greenBeretMapping:						;@ Green Beret
	.long 0x00, memZ80R0, rom_W
	.long 0x01, memZ80R1, rom_W
	.long 0x02, memZ80R2, rom_W
	.long 0x03, memZ80R3, rom_W
	.long 0x04, memZ80R4, rom_W
	.long 0x05, memZ80R5, rom_W
	.long emuRAM, memZ80R6, k005849Ram_0W						;@ Graphic
	.long emptySpace, GreenBeretIO_R, GreenBeretIO_W			;@ IO
ironHorseZ80Mapping:					;@ Iron Horse Z80
	.long 0x00, memZ80R0, rom_W									;@ ROM
	.long 0x01, memZ80R1, rom_W									;@ ROM
	.long soundCpuRam, memZ80R2, ramZ80W2						;@ CPU2 RAM
	.long emptySpace, empty_R, empty_W							;@ Empty
	.long emptySpace, soundLatchR, empty_W						;@ CPU2 Latch
	.long emptySpace, empty_R, empty_W							;@ Empty
	.long emptySpace, empty_R, empty_W							;@ Empty
	.long emptySpace, empty_R, empty_W							;@ Empty

;@----------------------------------------------------------------------------
initMappingPage:	;@ r0=page, r1=mem, r2=rdMem, r3=wrMem
;@----------------------------------------------------------------------------
	str r1,[r4,r0,lsl#2]		;@ MemMap
	str r2,[r5,r0,lsl#2]		;@ RdMem
	str r3,[r6,r0,lsl#2]		;@ WrMem
	bx lr
;@----------------------------------------------------------------------------

;@----------------------------------------------------------------------------
z80Mapper2:		;@ Rom paging.. r0=cpuptr, r1=romBase, r2=mapping table.
;@----------------------------------------------------------------------------
	stmfd sp!,{r4-r8,lr}

	add r7,r0,#z80MemTbl
	add r8,r0,#z80ReadTbl
	add lr,r0,#z80WriteTbl

	mov r6,#8
z80M2Loop:
	ldmia r2!,{r3-r5}
	cmp r3,#0x100
	addmi r3,r1,r3,lsl#13
	rsb r0,r6,#8
	sub r3,r3,r0,lsl#13

	str r3,[r7],#4
	str r4,[r8],#4
	str r5,[lr],#4
	subs r6,r6,#1
	bne z80M2Loop
;@------------------------------------------
//z80Flush:		;@ Update cpu_pc & lastbank
;@------------------------------------------
//	reEncodePC
	ldmfd sp!,{r4-r8,lr}
	bx lr

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
