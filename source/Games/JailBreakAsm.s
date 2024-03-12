#ifdef __arm__

#include "../K005849/K005849.i"
#include "../ARM6809/ARM6809.i"

	.global doCpuMappingJailBreak

	.syntax unified
	.arm

	.section .text
	.align 2


;@----------------------------------------------------------------------------
doCpuMappingJailBreak:
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}
	ldr r0,=vlm5030Chip
	ldr r0,[r0]
	ldr r1,=vlmBase
	ldr r1,[r1]
	cmp r11,#16
	addeq r1,r1,#0x2000			;@ Manhattan 24 has speech in top of rom
	mov r2,#0x2000				;@ ROM size
	blx VLM5030_set_rom
	ldmfd sp!,{lr}

	adr r2,jailBreakMapping
	b do6809MainCpuMapping
;@----------------------------------------------------------------------------
jailBreakMapping:						;@ Jail Break
	.long GFX_RAM0, k005849Ram_0R, k005849Ram_0W				;@ Graphic
	.long emptySpace, JailBreakIO_R, JailBreakIO_W				;@ IO
	.long emptySpace, VLM_R, VLM_W								;@ VLM
	.long emptySpace, VLM_R, VLM_W								;@ VLM
	.long 0, mem6809R4, rom_W									;@ ROM
	.long 1, mem6809R5, rom_W									;@ ROM
	.long 2, mem6809R6, rom_W									;@ ROM
	.long 3, mem6809R7, rom_W									;@ ROM

;@----------------------------------------------------------------------------
VLM_W:
;@----------------------------------------------------------------------------
	cmp r12,#0x4000
	bne notVLMPins
	mov r1,r0
	ldr r0,=vlm5030Chip
	ldr r0,[r0]
	stmfd sp!,{r0,r1,r3,lr}
	mov r1,r1,lsr#1
	and r1,r1,#1
	blx VLM5030_ST

	ldmfd sp!,{r0,r1}
	mov r1,r1,lsr#2
	and r1,r1,#1
	blx VLM5030_RST
	ldmfd sp!,{r3,pc}
notVLMPins:
	cmp r12,#0x5000
	bne empty_W
	mov r1,r0
	ldr r0,=vlm5030Chip
	ldr r0,[r0]
	stmfd sp!,{r3,lr}
	blx VLM5030_WRITE8
	ldmfd sp!,{r3,pc}
;@----------------------------------------------------------------------------
VLM_R:
;@----------------------------------------------------------------------------
	cmp r12,#0x6000
	bne empty_R
vlmBusy:
	stmfd sp!,{r3,lr}
	ldr r0,=vlm5030Chip
	ldr r0,[r0]
	blx VLM5030_BSY
	cmp r0,#0
	movne r0,#1
	ldmfd sp!,{r3,pc}

;@----------------------------------------------------------------------------
	.end
#endif // #ifdef __arm__
