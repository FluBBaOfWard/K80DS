#ifdef __arm__

#include "../K005849/K005849.i"

	.global doCpuMappingIronHorse
	.global doCpuMappingScooterShooter
	.global gfxResetIronHorse
	.global paletteInitIronHorse
	.global paletteInitScooterShooter
	.global paletteTxAllIronHorse

	.syntax unified
	.arm

	.section .text
	.align 2
;@----------------------------------------------------------------------------
doCpuMappingIronHorse:
;@----------------------------------------------------------------------------
	adr r2,ironHorseMapping
	b continueMapping
;@----------------------------------------------------------------------------
doCpuMappingScooterShooter:
;@----------------------------------------------------------------------------
	adr r2,scooterShooterMapping
;@----------------------------------------------------------------------------
continueMapping:
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}
	bl do6809MainCpuMapping

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
	.long GFX_RAM0, mem6809R1, k005885Ram_0W					;@ Graphic
	.long 0, mem6809R2, rom_W									;@ ROM
	.long 1, mem6809R3, rom_W									;@ ROM
	.long 2, mem6809R4, rom_W									;@ ROM
	.long 3, mem6809R5, rom_W									;@ ROM
	.long 4, mem6809R6, rom_W									;@ ROM
	.long 5, mem6809R7, rom_W									;@ ROM
;@----------------------------------------------------------------------------
scooterShooterMapping:					;@ Scooter Shooter
	.long GFX_RAM0, mem6809R0, k005849Ram_0W					;@ Graphic
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
	.long SOUND_RAM, memZ80R2, ramZ80W2							;@ CPU2 RAM
	.long emptySpace, empty_R, empty_W							;@ Empty
	.long emptySpace, soundLatchR, empty_W						;@ CPU2 Latch
	.long emptySpace, empty_R, empty_W							;@ Empty
	.long emptySpace, empty_R, empty_W							;@ Empty
	.long emptySpace, empty_R, empty_W							;@ Empty

;@----------------------------------------------------------------------------
gfxResetIronHorse:
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}

	ldr r0,=m6809SetNMIPin
	ldr r1,=m6809SetIRQPin
	ldr r2,=m6809SetFIRQPin
	bl k005885Reset0
	ldr r0,=gfxChipType
	ldrb r0,[r0]
	bl k005849SetType
	bl bgInit
	mov r0,#1
	strb r0,[koptr,#isIronHorse]

	ldmfd sp!,{pc}
;@----------------------------------------------------------------------------
paletteInitIronHorse:		;@ r0-r3 modified.
;@----------------------------------------------------------------------------
	stmfd sp!,{r4-r7,lr}
	mov r1,r0					;@ Gamma value = 0 -> 4
	ldr r7,=promBase			;@ Proms
	ldr r7,[r7]
	ldr r6,=MAPPED_RGB
	mov r4,#0x100				;@ Iron Horse bgr, r1=R, r2=G, r3=B
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
paletteInitScooterShooter:	;@ r0-r3 modified.
;@----------------------------------------------------------------------------
	stmfd sp!,{r4-r7,lr}
	mov r1,r0					;@ Gamma value = 0 -> 4
	ldr r7,=promBase			;@ Proms
	ldr r7,[r7]
	ldr r6,=MAPPED_RGB
	mov r4,#0x100				;@ Scooter Shooter bgr, r1=R, r2=G, r3=B
palInitLoopSS:					;@ Map rrrr, gggg, bbbb  ->  0bbbbbgggggrrrrr
	ldrb r0,[r7,#0x200]			;@ Blue
	bl gPrefix
	mov r5,r0

	ldrb r0,[r7,#0x100]			;@ Green
	bl gPrefix
	orr r5,r0,r5,lsl#5

	ldrb r0,[r7],#1				;@ Red
	bl gPrefix
	orr r5,r0,r5,lsl#5

	rsb r0,r4,#0x100			;@ Order is shuffled on ScooterShooter
	and r2,r0,#0xF0
	add r0,r0,r2
	movs r0,r0,lsl#24
	orrcs r0,r0,#0x10000000
	mov r0,r0,lsr#23
	strh r5,[r6,r0]
	subs r4,r4,#1
	bne palInitLoopSS

	ldmfd sp!,{r4-r7,lr}
	bx lr
;@----------------------------------------------------------------------------
gPrefix:
	and r0,r0,#0xF
	orr r0,r0,r0,lsl#4
	b gammaConvert
;@----------------------------------------------------------------------------
paletteTxAllIronHorse:
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}

	ldr r1,=promBase			;@ Proms
	ldr r1,[r1]
	add r1,r1,#0x300			;@ LUT

	ldr r2,=MAPPED_RGB
	ldr r0,=paletteBank
	ldrb r0,[r0]
	add r2,r2,r0,lsl#6

	ldr r0,=EMUPALBUFF+0x200	;@ Sprites first
	bl paletteTx0
	add r2,r2,#0x20
	ldr r0,=EMUPALBUFF
	bl paletteTx0
	ldmfd sp!,{lr}
	bx lr

;@----------------------------------------------------------------------------
	.end
#endif // #ifdef __arm__
