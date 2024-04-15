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
	ldr r0,=m6809CPU0
	mov r1,#1
	bl m6809SetEncryptedMode
	ldmfd sp!,{lr}

	adr r2,jailBreakMapping
	b do6809MainCpuMapping
;@----------------------------------------------------------------------------
jailBreakMapping:						;@ Jail Break
	.long GFX_RAM0, k005849Ram_0R, k005849Ram_0W				;@ Graphic
	.long emptySpace, JailBreakIO_R, JailBreakIO_W				;@ IO
	.long emptySpace, empty_R, VLM_JB_W							;@ VLM
	.long emptySpace, VLM_JB_R, empty_W							;@ VLM
	.long 0, mem6809R4, rom_W									;@ ROM
	.long 1, mem6809R5, rom_W									;@ ROM
	.long 2, mem6809R6, rom_W									;@ ROM
	.long 3, mem6809R7, rom_W									;@ ROM

;@----------------------------------------------------------------------------
VLM_JB_W:
;@----------------------------------------------------------------------------
	cmp r12,#0x4000
	beq VLM_W
	cmp r12,#0x5000
	beq VLMData_W
	bne empty_W
;@----------------------------------------------------------------------------
VLM_JB_R:
;@----------------------------------------------------------------------------
	cmp r12,#0x6000
	beq VLM_R
	bne empty_R

;@----------------------------------------------------------------------------
	.end
#endif // #ifdef __arm__
