#ifdef __arm__

#include "YM2203/YM2203.i"
#include "SN76496/SN76496.i"

	.global soundInit
	.global soundReset
	.global VblSound2
	.global setMuteSoundGUI
	.global setMuteSoundGame
	.global soundLatchR
	.global soundLatchW
	.global ym2203_0_Run
	.global ym2203_0_R
	.global ym2203_0_W
	.global SN_0_W

	.global SN76496_0
	.extern pauseEmulation

	.syntax unified
	.arm

	.section .text
	.align 2
;@----------------------------------------------------------------------------
soundInit:
	.type soundInit STT_FUNC
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}

	ldmfd sp!,{lr}
//	bx lr

;@----------------------------------------------------------------------------
soundReset:
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}
	mov r1,#0
	ldr r0,=ym2203_0
	bl ym2203Reset				;@ sound

	ldr r1,=SN76496_0
	mov r0,#1
	bl sn76496Reset				;@ Sound
	ldmfd sp!,{lr}
	bx lr

;@----------------------------------------------------------------------------
setMuteSoundGUI:
	.type   setMuteSoundGUI STT_FUNC
;@----------------------------------------------------------------------------
	ldr r1,=pauseEmulation		;@ Output silence when emulation paused.
	ldrb r0,[r1]
	strb r0,muteSoundGUI
	bx lr
;@----------------------------------------------------------------------------
setMuteSoundGame:			;@ For System E ?
;@----------------------------------------------------------------------------
	strb r0,muteSoundGame
	bx lr
;@----------------------------------------------------------------------------
VblSound2:					;@ r0=length, r1=pointer, r2=format?
;@----------------------------------------------------------------------------
	ldr r3,muteSound
	cmp r3,#0
	bne silenceMix

;@	mov r11,r11
	stmfd sp!,{r0,r1,r4,lr}

	ldr r1,pcmPtr1
	ldr r2,=ym2203_0
	bl ym2203Mixer
	ldmfd sp,{r0}
	ldr r1,pcmPtr0
	ldr r2,=ym2203_0
	bl ay38910Mixer

	ldmfd sp,{r0,r1}
	ldr r3,pcmPtr0
	ldr r4,pcmPtr1
mixLoop:
	ldrsh r2,[r3],#2
	ldrsh r12,[r4],#2
	add r2,r2,r12
	mov r2,r2,asr#1

	subs r0,r0,#1
	strhpl r2,[r1],#2
	bhi mixLoop

	ldmfd sp!,{r0,r1,r4,lr}
	bx lr

silenceMix:
	mov r12,r0
	mov r2,#0
silenceLoop:
	subs r12,r12,#1
	strhpl r2,[r1],#2
	bhi silenceLoop
	bx lr

;@----------------------------------------------------------------------------
soundLatchR:			;@ Z80 0x8000
;@----------------------------------------------------------------------------
	cmp r12,#0x8000
	bne empty_R
	stmfd sp!,{lr}
	mov r0,#0
	bl cpu1SetIRQ
	ldmfd sp!,{lr}
	ldrb r0,soundLatch
	mov r11,r11
	bx lr
;@----------------------------------------------------------------------------
soundLatchW:			;@ M6809 0x0800
;@----------------------------------------------------------------------------
	strb r0,soundLatch
	bx lr
;@----------------------------------------------------------------------------
SN_0_W:
;@----------------------------------------------------------------------------
	stmfd sp!,{r3,lr}
	ldr r1,=SN76496_0
	bl sn76496W
	ldmfd sp!,{r3,lr}
	bx lr
;@----------------------------------------------------------------------------
ym2203_0_Run:
;@----------------------------------------------------------------------------
	mov r0,#196
	ldr r1,=ym2203_0
	b ym2203Run
;@----------------------------------------------------------------------------
ym2203_0_R:				;@ Z80 IO 0x00-0x01
;@----------------------------------------------------------------------------
	stmfd sp!,{r3,lr}
	tst r12,#1
	ldr r0,=ym2203_0
	adr lr,ymReadRet
	beq ym2203StatusR
	bne ym2203DataR
ymReadRet:
	ldmfd sp!,{r3,lr}
	bx lr
;@----------------------------------------------------------------------------
ym2203_0_W:				;@ Z80 IO 0x00-0x01
;@----------------------------------------------------------------------------
	stmfd sp!,{r3,lr}
	tst r12,#1
	ldr r1,=ym2203_0
	adr lr,ymWriteRet
	beq ym2203IndexW
	bne ym2203DataW
ymWriteRet:
	ldmfd sp!,{r3,lr}
	bx lr

;@----------------------------------------------------------------------------
pcmPtr0:	.long wavBuffer
pcmPtr1:	.long wavBuffer+0xA00

muteSound:
muteSoundGUI:
	.byte 0
muteSoundGame:
	.byte 0
	.space 2

soundLatch:
	.byte 0
	.space 3

	.section .bss
	.align 2
ym2203_0:
	.space ymSize
SN76496_0:
	.space snSize
wavBuffer:
	.space 0x1400
;@----------------------------------------------------------------------------
	.end
#endif // #ifdef __arm__
