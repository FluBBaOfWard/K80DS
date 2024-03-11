#ifdef __arm__

#include "K005849/K005849.i"
#include "Shared/EmuMenu.i"

	.global ioReset
	.global FinalizerIO_R
	.global FinalizerIO_W
	.global GreenBeretIO_R
	.global GreenBeretIO_W
	.global IronHorseIO_R
	.global IronHorseIO_W
	.global ScooterShooterIO_R
	.global ScooterShooterIO_W
	.global Z80In
	.global Z80Out
	.global convertInput
	.global refreshEMUjoypads
	.global Input0_R
	.global Input1_R
	.global Input2_R
	.global Input3_R
	.global Input4_R
	.global Input5_R
	.global Input5_R
	.global ddCoinW
	.global watchDogW

	.global joyCfg
	.global EMUinput
	.global gDipSwitch0
	.global gDipSwitch1
	.global gDipSwitch2
	.global gDipSwitch3
	.global coinCounter0
	.global coinCounter1

	addy		.req r12		;@ Used by CPU cores

	.syntax unified
	.arm

	.section .text
	.align 2
;@----------------------------------------------------------------------------
ioReset:
;@----------------------------------------------------------------------------
	bx lr
;@----------------------------------------------------------------------------
convertInput:			;@ Convert from device keys to target r0=input/output
	.type convertInput STT_FUNC
;@----------------------------------------------------------------------------
	mvn r1,r0
	tst r1,#KEY_L|KEY_R			;@ Keys to open menu
	orreq r0,r0,#KEY_OPEN_MENU
	bx lr
;@----------------------------------------------------------------------------
refreshEMUjoypads:			;@ Call every frame
;@----------------------------------------------------------------------------
;@	mov r11,r11
		ldr r4,=frameTotal
		ldr r4,[r4]
		movs r0,r4,lsr#2		;@ C=frame&2 (autofire alternates every other frame)
	ldr r4,EMUinput
	mov r3,r4
	and r0,r4,#0xf0
		ldr r2,joyCfg
		andcs r4,r4,r2
		tstcs r4,r4,lsr#10		;@ L?
		andcs r4,r4,r2,lsr#16
	ldr r1,=k005885_0
	ldrb r1,[r1,#irqControl]
	tst r1,#0x08				;@ Screen flip?
	adreq r1,rlud2lrud
	adrne r1,rlud2lrud180
	ldrb r0,[r1,r0,lsr#4]


	ands r1,r4,#3				;@ A/B buttons to Shoot/Power Up
	cmpne r1,#3
	eorne r1,r1,#3
	tst r2,#0x400				;@ Swap A/B?
	andeq r1,r4,#3
	orr r0,r0,r1,lsl#4
	mov r1,#0
	tst r3,#0x800				;@ Y?
	orrne r1,r1,#0x40
	mov r3,#0
	tst r4,#0x4					;@ Select
	orrne r3,r3,#0x01			;@ Coin
	tst r4,#0x8					;@ Start
	orrne r3,r3,#0x08			;@ Start
	tst r2,#0x20000000			;@ Player2?
	movne r2,r0
	movne r0,r1
	movne r1,r2
	movne r3,r3,lsl#1

	strb r0,joy0State
	strb r1,joy1State
	strb r3,joy2State
	bx lr

joyCfg: .long 0x00ff01ff	;@ byte0=auto mask, byte1=(saves R), byte2=R auto mask
							;@ bit 31=single/multi, 30,29=1P/2P, 27=(multi) link active, 24=reset signal received
playerCount:.long 0			;@ Number of players in multilink.
joySerial:	.byte 0
joy0State:	.byte 0
joy1State:	.byte 0
joy2State:	.byte 0
rlud2lrud:		.byte 0x00,0x02,0x01,0x03, 0x04,0x06,0x05,0x07, 0x08,0x0a,0x09,0x0b, 0x0c,0x0e,0x0d,0x0f
rlud2lrud180:	.byte 0x00,0x01,0x02,0x03, 0x08,0x09,0x0a,0x0b, 0x04,0x05,0x06,0x07, 0x0c,0x0d,0x0e,0x0f
rlud2lrud90:	.byte 0x00,0x08,0x04,0x0c, 0x02,0x0a,0x06,0x0e, 0x01,0x09,0x05,0x0d, 0x03,0x0b,0x07,0x0f
rlud2lrud270:	.byte 0x00,0x04,0x08,0x0c, 0x01,0x05,0x09,0x0d, 0x02,0x06,0x0a,0x0e, 0x03,0x07,0x0b,0x0f
gDipSwitch0:	.byte 0
gDipSwitch1:	.byte 0x85		;@ Lives, cabinet & demo sound.
gDipSwitch2:	.byte 0
gDipSwitch3:	.byte 0
coinCounter0:	.long 0
coinCounter1:	.long 0

EMUinput:			;@ This label here for main.c to use
	.long 0			;@ EMUjoypad (this is what Emu sees)

;@----------------------------------------------------------------------------
Input0_R:		;@ Player 1
;@----------------------------------------------------------------------------
;@	mov r11,r11					;@ No$GBA breakpoint
	ldrb r0,joy0State
	eor r0,r0,#0xFF
	bx lr
;@----------------------------------------------------------------------------
Input1_R:		;@ Player 2
;@----------------------------------------------------------------------------
;@	mov r11,r11					;@ No$GBA breakpoint
	ldrb r0,joy1State
	eor r0,r0,#0xFF
	bx lr
;@----------------------------------------------------------------------------
Input2_R:		;@ Coins, Start & Service
;@----------------------------------------------------------------------------
;@	mov r11,r11					;@ No$GBA breakpoint
	ldrb r0,joy2State
	eor r0,r0,#0xFF
	bx lr
;@----------------------------------------------------------------------------
Input2_R_Finalizer:		;@ Coins, Start & Service
;@----------------------------------------------------------------------------
;@	mov r11,r11					;@ No$GBA breakpoint
	ldrb r0,joy2State
	ldr koptr,=k005849_0
	ldr r1,[koptr,#scanline]
	cmp r1,#224
	orrpl r0,r0,#0x80
	eor r0,r0,#0xFF
	bx lr
;@----------------------------------------------------------------------------
Input3_R:
;@----------------------------------------------------------------------------
	ldrb r0,gDipSwitch0
	eor r0,r0,#0xFF
	bx lr
;@----------------------------------------------------------------------------
Input4_R:
;@----------------------------------------------------------------------------
	ldrb r0,gDipSwitch1
	eor r0,r0,#0xFF
	bx lr
;@----------------------------------------------------------------------------
Input5_R:
;@----------------------------------------------------------------------------
	ldrb r0,gDipSwitch2
	eor r0,r0,#0xFF
	bx lr

;@----------------------------------------------------------------------------
FinalizerIO_R:			;@ I/O read
;@----------------------------------------------------------------------------
	bics r2,addy,#0x0800
	beq Input5_R
	cmp r2,#0x0008
	beq Input4_R
	bic r2,r2,#3
	cmp r2,#0x0010
	and r2,addy,#3
	ldreq pc,[pc,r2,lsl#2]
;@---------------------------
	b k005885_0R
;@io_read_tbl
	.long Input2_R_Finalizer	;@ 0x0810
	.long Input0_R				;@ 0x0811
	.long Input1_R				;@ 0x0812
	.long Input3_R				;@ 0x0813

;@----------------------------------------------------------------------------
FinalizerIO_W:		;@I/O write
;@----------------------------------------------------------------------------
	bic r2,addy,#0x0800
	cmp r2,#0x0018
	beq watchDogW
	cmp r2,#0x0019
	beq ddCoinW
	cmp r2,#0x001A
	beq SN_0_W
	cmp r2,#0x001B
	beq SN_0_W
	cmp r2,#0x001C
	beq watchDogW				;@ Sound cpu irq
	cmp r2,#0x001D
	beq watchDogW				;@ Sound cpu latch byte
	b k005885_0W

;@----------------------------------------------------------------------------
GreenBeretIO_R:				;@ I/O read  (0xE045-0xFFFF)
;@----------------------------------------------------------------------------
	cmp addy,#0xF200
	beq Input4_R
	cmp addy,#0xF400
	beq Input5_R
	cmp addy,#0xF800
	bpl memZ80R7
	bic r2,addy,#3
	cmp r2,#0xF600
	and r2,addy,#3
	ldreq pc,[pc,r2,lsl#2]
;@---------------------------
	b k005849_0R
;@io_read_tbl
	.long Input3_R				;@ 0xF600
	.long Input1_R				;@ 0xF601
	.long Input0_R				;@ 0xF602
	.long Input2_R				;@ 0xF603

;@----------------------------------------------------------------------------
GreenBeretIO_W:				;@I/O write  (0xE045-0xFFFF)
;@----------------------------------------------------------------------------
	cmp addy,#0xF200
	bxeq lr
	cmp addy,#0xF400
	beq SN_0_W
	cmp addy,#0xF000
	beq gbCoinW
	cmp addy,#0xF600
	beq watchDogW
	b k005849_0W

;@----------------------------------------------------------------------------
IronHorseIO_R:				;@ I/O read 0x0000-0x1FFF
;@----------------------------------------------------------------------------
	cmp addy,#0x0900
	beq Input5_R
	cmp addy,#0x0A00
	beq Input4_R
	bic r2,addy,#3
	cmp r2,#0x0B00
	and r2,addy,#3
	ldreq pc,[pc,r2,lsl#2]
;@---------------------------
	b k005885_0R
;@io_read_tbl
	.long Input3_R				;@ 0x0B00
	.long Input1_R				;@ 0x0B01
	.long Input0_R				;@ 0x0B02
	.long Input2_R				;@ 0x0B03

;@----------------------------------------------------------------------------
IronHorseIO_W:				;@ I/O write 0x0000-0x1FFF
;@----------------------------------------------------------------------------
	cmp addy,#0x0800
	beq soundLatchW
	cmp addy,#0x0900
	beq setSoundCpuIrq
	cmp addy,#0x0A00
	beq coinW
	cmp addy,#0x0B00
	beq watchDogW
	b k005885_0W

;@----------------------------------------------------------------------------
ScooterShooterIO_R:			;@ I/O read 0x2000-0x3FFF
;@----------------------------------------------------------------------------
	cmp addy,#0x3100
	beq Input4_R
	cmp addy,#0x3200
	beq Input5_R
	bic r2,addy,#3
	cmp r2,#0x3300
	and r2,addy,#3
	ldreq pc,[pc,r2,lsl#2]
;@---------------------------
	b k005849_0R
;@io_read_tbl
	.long Input2_R				;@ 0x3300
	.long Input0_R				;@ 0x3301
	.long Input1_R				;@ 0x3302
	.long Input3_R				;@ 0x3303

;@----------------------------------------------------------------------------
ScooterShooterIO_W:			;@ I/O write 0x2000-0x3FFF
;@----------------------------------------------------------------------------
	cmp addy,#0x3100
	beq soundLatchW
	cmp addy,#0x3200
	beq setSoundCpuIrq
	cmp addy,#0x3000
	beq ssCoinW
	cmp addy,#0x3300
	beq watchDogW
	b k005849_0W

;@----------------------------------------------------------------------------
setSoundCpuIrq:
;@----------------------------------------------------------------------------
	mov r0,#1
	b cpu1SetIRQ
;@----------------------------------------------------------------------------
watchDogW:
;@----------------------------------------------------------------------------
	bx lr
;@----------------------------------------------------------------------------
ssCoinW:
;@----------------------------------------------------------------------------
	mov r0,r0,ror#4				;@ Nibbles are swapped compared to Iron Horse.
	orr r0,r0,r0,lsr#24
;@----------------------------------------------------------------------------
coinW:
;@----------------------------------------------------------------------------
	and r2,r0,#0x07
	ldr r1,=paletteBank
	strb r2,[r1]

	tst r0,#0x10
	ldrne r1,coinCounter0
	addne r1,r1,#1
	strne r1,coinCounter0
	tst r0,#0x20
	ldrne r1,coinCounter1
	addne r1,r1,#1
	strne r1,coinCounter1
//	tst r0,#0x04				;@ END?
//	tst r0,#0x08				;@ SA?
	b paletteTxAll
	bx lr
;@----------------------------------------------------------------------------
ddCoinW:
;@----------------------------------------------------------------------------
	tst r0,#0x01
	ldrne r1,coinCounter0
	addne r1,r1,#1
	strne r1,coinCounter0
	tst r0,#0x02
	ldrne r1,coinCounter1
	addne r1,r1,#1
	strne r1,coinCounter1
//	tst r0,#0x04			;@ END?
//	tst r0,#0x08			;@ ROM A14?
	bx lr
;@----------------------------------------------------------------------------
gbCoinW:
;@----------------------------------------------------------------------------
	tst r0,#0x01
	ldrne r1,coinCounter0
	addne r1,r1,#1
	strne r1,coinCounter0
	tst r0,#0x02
	ldrne r1,coinCounter1
	addne r1,r1,#1
	strne r1,coinCounter1

	b gberetMapRom

;@----------------------------------------------------------------------------
Z80In:
;@----------------------------------------------------------------------------
	b ym2203_0_R
;@----------------------------------------------------------------------------
Z80Out:
;@----------------------------------------------------------------------------
	b ym2203_0_W
;@----------------------------------------------------------------------------
	.end
#endif // #ifdef __arm__
