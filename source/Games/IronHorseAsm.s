#ifdef __arm__

#include "../K005849/K005849.i"

	.global doCpuMappingIronHorse
	.global doCpuMappingScooterShooter
	.global paletteInitIronHorse
	.global paletteTxAllIronHorse

	.syntax unified
	.arm

	.section .text
	.align 2
;@----------------------------------------------------------------------------
doCpuMappingIronHorse:
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}
	ldr r0,=m6809CPU0
	ldr r1,=mainCpu
	ldr r1,[r1]
	adr r2,ironHorseMapping
	bl m6809Mapper
	b mapSoundCpu
;@----------------------------------------------------------------------------
doCpuMappingScooterShooter:
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}
	ldr r0,=m6809CPU0
	ldr r1,=mainCpu
	ldr r1,[r1]
	adr r2,scooterShooterMapping
	bl m6809Mapper
;@----------------------------------------------------------------------------
mapSoundCpu:
;@----------------------------------------------------------------------------
	ldr r0,=Z80OpTable
	ldr r1,=soundCpu
	ldr r1,[r1]
	adr r2,ironHorseZ80Mapping
	bl z80Mapper
	ldmfd sp!,{lr}
	bx lr
;@----------------------------------------------------------------------------
ironHorseMapping:						;@ Iron Horse
	.long emptySpace, IronHorseIO_R, IronHorseIO_W				;@ IO
	.long emuRAM, mem6809R1, k005885Ram_0W						;@ Graphic
	.long 0, mem6809R2, rom_W									;@ ROM
	.long 1, mem6809R3, rom_W									;@ ROM
	.long 2, mem6809R4, rom_W									;@ ROM
	.long 3, mem6809R5, rom_W									;@ ROM
	.long 4, mem6809R6, rom_W									;@ ROM
	.long 5, mem6809R7, rom_W									;@ ROM
;@----------------------------------------------------------------------------
scooterShooterMapping:					;@ Scooter Shooter
	.long emuRAM, mem6809R0, k005849Ram_0W						;@ Graphic
	.long emptySpace, ScooterShooterIO_R, ScooterShooterIO_W	;@ IO
	.long 2, mem6809R2, rom_W									;@ ROM
	.long 3, mem6809R3, rom_W									;@ ROM
	.long 0, mem6809R4, rom_W									;@ ROM
	.long 1, mem6809R5, rom_W									;@ ROM
	.long 4, mem6809R6, rom_W									;@ ROM
	.long 5, mem6809R7, rom_W									;@ ROM
;@----------------------------------------------------------------------------
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
paletteInitIronHorse:		;@ r0-r3 modified.
;@----------------------------------------------------------------------------
	stmfd sp!,{r4-r7,lr}
	mov r1,r0					;@ Gamma value = 0 -> 4
	ldr r7,=promBase			;@ Proms
	ldr r7,[r7]
	ldr r6,=MAPPED_RGB
	mov r4,#256					;@ Iron Horse bgr, r1=R, r2=G, r3=B
palInitLoop:					;@ Map rrrr, gggg, bbbb  ->  0bbbbbgggggrrrrr
	ldrb r0,[r7,#0x200]			;@ Blue
	bl gPrefix
	mov r5,r0

	ldrb r0,[r7,#0x100]			;@ Green
	bl gPrefix
	orr r5,r0,r5,lsl#5

	ldrb r0,[r7],#1				;@ Red
	bl gPrefix
	orr r5,r0,r5,lsl#5

	strh r5,[r6],#2
	subs r4,r4,#1
	bne palInitLoop

	ldmfd sp!,{r4-r7,lr}
	bx lr
;@----------------------------------------------------------------------------
gPrefix:
	and r0,r0,#0xF
	orr r0,r0,r0,lsl#4
	b gammaConvert
;@----------------------------------------------------------------------------
paletteTxAllIronHorse:				;@ Called from ui.c
;@----------------------------------------------------------------------------
	stmfd sp!,{r3-r5,lr}

	ldr r0,=gfxChipType
	ldrb r0,[r0]
	cmp r0,#CHIP_K005849
	ldr r3,=MAPPED_RGB
	ldr r4,=EMUPALBUFF
	ldr r1,=paletteBank
	ldrb r1,[r1]
	addeq r3,r3,r1,lsl#5
	moveq r5,#0x100
	addne r3,r3,r1,lsl#6
	movne r5,#0x20

	ldr r2,=promBase			;@ Proms
	ldr r2,[r2]
	add r2,r2,#0x300			;@ LUT

	add r3,r3,r5
	bl noMap3
	sub r3,r3,r5
	bl noMap3
	ldmfd sp!,{r3-r5,lr}
	bx lr

noMap3:
	mov r1,#256
palTxLoop1:
	ldrb r0,[r2],#1
	and r0,r0,#0xF
	mov r0,r0,lsl#1
	ldrh r0,[r3,r0]
	strh r0,[r4],#2
	subs r1,r1,#1
	bne palTxLoop1
	bx lr

;@----------------------------------------------------------------------------
	.end
#endif // #ifdef __arm__
