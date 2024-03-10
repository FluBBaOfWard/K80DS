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
	.global VLMData_W

	.global SN76496_0
	.global ym2203_0
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
	mov r1,#0					;@ No irq func
	ldr r0,=ym2203_0
	bl ym2203Reset				;@ Sound
	ldr r0,=ym2203_0
	ldr r1,=VLM_R
	str r1,[r0,#ayPortBInFptr]
	ldr r1,=VLM_W
	str r1,[r0,#ayPortAOutFptr]

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

//	b dDribbleMix
//	b gbMixer
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
dDribbleMix:
;@----------------------------------------------------------------------------
	stmfd sp!,{r0,r1,r4,r5,lr}

	ldr r1,pcmPtr0
	ldr r2,=ym2203_0
	bl ay38910Mixer
	ldmfd sp,{r0}
	ldr r1,pcmPtr1
	ldr r2,=ym2203_0
	bl ym2203Mixer

	ldmfd sp,{r0}
	ldr r1,pcmPtr2
	mov r2,r0,lsr#3
	ldr r0,=vlm5030Chip
	ldr r0,[r0]
	blx vlm5030_update_callback

	ldmfd sp,{r0,r1}
	ldr r12,pcmPtr0
	ldr r5,pcmPtr1
	ldr r3,pcmPtr2
ddWavLoop:
	ldrsh r4,[r3]
	tst r0,#4
	addne r3,r3,#2

	ldrsh r2,[r12],#2
	ldrsh lr,[r5],#2
	add r2,r2,lr
	add r2,r4,r2,asr#3
	mov r2,r2,asr#1
	strh r2,[r1],#2

	ldrsh r2,[r12],#2
	ldrsh lr,[r5],#2
	add r2,r2,lr
	add r2,r4,r2,asr#3
	mov r2,r2,asr#1
	strh r2,[r1],#2

	ldrsh r2,[r12],#2
	ldrsh lr,[r5],#2
	add r2,r2,lr
	add r2,r4,r2,asr#3
	mov r2,r2,asr#1
	strh r2,[r1],#2

	ldrsh r2,[r12],#2
	ldrsh lr,[r5],#2
	add r2,r2,lr
	add r2,r4,r2,asr#3
	mov r2,r2,asr#1
	strh r2,[r1],#2

	subs r0,r0,#4
	bhi ddWavLoop

	ldmfd sp!,{r0,r1,r4,r5,lr}
	bx lr

;@----------------------------------------------------------------------------
gbMixer:
;@----------------------------------------------------------------------------
	stmfd sp!,{r0,lr}

	ldr r2,=SN76496_0
	bl sn76496Mixer

	ldmfd sp!,{r0,lr}
	bx lr

;@----------------------------------------------------------------------------
soundLatchR:			;@ IronHorse Z80 0x8000
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
soundLatchW:			;@ IronHorse M6809 0x0800
;@----------------------------------------------------------------------------
	strb r0,soundLatch
	bx lr
;@----------------------------------------------------------------------------
VLM_R:
;@----------------------------------------------------------------------------
	stmfd sp!,{r3,lr}
	ldr r0,=vlm5030Chip
	ldr r0,[r0]
	blx VLM5030_BSY
	cmp r0,#0
	movne r0,#1
	ldmfd sp!,{r3,pc}
;@----------------------------------------------------------------------------
VLM_W:
;@----------------------------------------------------------------------------
	mov r1,r0
	ldr r0,=vlm5030Chip
	ldr r0,[r0]
	stmfd sp!,{r0,r1,r3,lr}

	mov r1,r1,lsr#3
	and r1,r1,#1
	ldr r3,=vlmBase
	ldr r3,[r3]
	add r1,r3,r1,lsl#16
	mov r2,#0x10000				;@ ROM size
	blx VLM5030_set_rom

	ldmfd sp,{r0,r1}
	mov r1,r1,lsr#6
	and r1,r1,#1
	blx VLM5030_RST

	ldmfd sp,{r0,r1}
	mov r1,r1,lsr#5
	and r1,r1,#1
	blx VLM5030_ST

	ldmfd sp!,{r0,r1}
	mov r1,r1,lsr#4
	and r1,r1,#1
	blx VLM5030_VCU

	ldmfd sp!,{r3,pc}
;@----------------------------------------------------------------------------
VLMData_W:
;@----------------------------------------------------------------------------
	mov r1,r0
	ldr r0,=vlm5030Chip
	ldr r0,[r0]
	stmfd sp!,{r3,lr}
	blx VLM5030_WRITE8
	ldmfd sp!,{r3,pc}
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
pcmPtr1:	.long wavBuffer+0x0800
pcmPtr2:	.long wavBuffer+0x1000

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
	.space 0x1800
;@----------------------------------------------------------------------------
	.end
#endif // #ifdef __arm__
