#include <nds.h>

#include "Finalizer.h"
#include "../Cart.h"
#include "../Gfx.h"
//#include "../SN76496/SN76496.h"
#include "../cpu.h"
#include "../K005849/K005849.h"
#include "../ARM6809/ARM6809.h"


int fiPackState(void *statePtr) {
	int size = 0;
//	size += sn76496SaveState(statePtr+size, &sn76496_0);
	size += k005849SaveState(statePtr+size, &k005885_0);
	size += m6809SaveState(statePtr+size, &m6809CPU0);
	return size;
}

void fiUnpackState(const void *statePtr) {
	int size = 0;
//	size += sn76496LoadState(&sn76496_0, statePtr+size);
	size += k005849LoadState(&k005885_0, statePtr+size);
	m6809LoadState(&m6809CPU0, statePtr+size);
}

int fiGetStateSize() {
	int size = 0;
//	size += sn76496GetStateSize();
	size += k005849GetStateSize();
	size += m6809GetStateSize();
	return size;
}

const ArcadeRom finalizrRoms[20] = {
	{ROM_REGION,   0x10000, (int)&mainCpu},
	{"523k01.9c",   0x4000, 0x716633cb},
	{"523k02.12c",  0x4000, 0x1bccc696},
	{"523k03.13c",  0x4000, 0xc48927c6},
	{ROM_REGION,    0x1000, (int)&soundCpu}, // 8039
	{"d8749hd.bin", 0x0800, 0x978dfc33},
	{ROM_REGION,   0x20000, (int)&vromBase0},
	{"523h04.5e",   0x4000, 0xc056d710},
	{"523h05.6e",   0x4000, 0xae0d0f76},
	{"523h06.7e",   0x4000, 0xd2db9689},
	{FILL0X00,      0x4000, 0x00000000}, // C000-ffff empty
	{"523h07.5f",   0x4000, 0x50e512ba},
	{"523h08.6f",   0x4000, 0x79f44e17},
	{"523h09.7f",   0x4000, 0x8896dc85},
	{FILL0X00,      0x4000, 0x00000000}, // 1C000-1ffff empty
	{ROM_REGION,    0x0240, (int)&promBase}, // PROMs at 2F & 3F are MMI 63S081N (or compatibles), PROMs at 10F & 11F are MMI 6301-1N (or compatibles)
	{"523h10.2f",   0x0020, 0xec15dd15}, // RG Palette
	{"523h11.3f",   0x0020, 0x54be2e83}, // B Palette
	{"523h12.10f",  0x0100, 0x53166a2a}, // Sprite Pal LUT
	{"523h13.11f",  0x0100, 0x4e0647a0}, // Character Pal LUT
};

const ArcadeRom finalizraRoms[20] = {
	{ROM_REGION,   0x10000, (int)&mainCpu},
	{"1.9c",        0x4000, 0x7d464e5c},
	{"2.12c",       0x4000, 0x383dc94e},
	{"3.13c",       0x4000, 0xce177f6e},
	{ROM_REGION,    0x1000, (int)&soundCpu}, // 8039
	{"d8749hd.bin", 0x0800, 0x978dfc33},
	{ROM_REGION,   0x20000, (int)&vromBase0},
	{"523h04.5e",   0x4000, 0xc056d710},
	{"523h05.6e",   0x4000, 0xae0d0f76},
	{"523h06.7e",   0x4000, 0xd2db9689},
	{FILL0X00,      0x4000, 0x00000000}, // C000-ffff empty
	{"523h07.5f",   0x4000, 0x50e512ba},
	{"523h08.6f",   0x4000, 0x79f44e17},
	{"523h09.7f",   0x4000, 0x8896dc85},
	{FILL0X00,      0x4000, 0x00000000}, // 1C000-1ffff empty
	{ROM_REGION,    0x0240, (int)&promBase}, // PROMs at 2F & 3F are MMI 63S081N (or compatibles), PROMs at 10F & 11F are MMI 6301-1N (or compatibles)
	{"523h10.2f",   0x0020, 0xec15dd15}, // RG Palette
	{"523h11.3f",   0x0020, 0x54be2e83}, // B Palette
	{"523h12.10f",  0x0100, 0x53166a2a}, // Sprite Pal LUT
	{"523h13.11f",  0x0100, 0x4e0647a0}, // Character Pal LUT
};

const ArcadeRom finalizrbRoms[19] = {
	{ROM_REGION,   0x10000, (int)&mainCpu},
	{"finalizr.5",  0x8000, 0xa55e3f14},
	{"finalizr.6",  0x4000, 0xce177f6e},
	{ROM_REGION,    0x1000, (int)&soundCpu}, // 8039
	{"d8749hd.bin", 0x0800, 0x978dfc33},
	{ROM_REGION,   0x20000, (int)&vromBase0},
	{"523h04.5e",   0x4000, 0xc056d710},
	{"523h05.6e",   0x4000, 0xae0d0f76},
	{"523h06.7e",   0x4000, 0xd2db9689},
	{FILL0X00,      0x4000, 0x00000000}, // C000-ffff empty
	{"523h07.5f",   0x4000, 0x50e512ba},
	{"523h08.6f",   0x4000, 0x79f44e17},
	{"523h09.7f",   0x4000, 0x8896dc85},
	{FILL0X00,      0x4000, 0x00000000}, // 1C000-1ffff empty
	{ROM_REGION,    0x0240, (int)&promBase}, // PROMs at 2F & 3F are MMI 63S081N (or compatibles), PROMs at 10F & 11F are MMI 6301-1N (or compatibles)
	{"523h10.2f",   0x0020, 0xec15dd15}, // RG Palette
	{"523h11.3f",   0x0020, 0x54be2e83}, // B Palette
	{"523h12.10f",  0x0100, 0x53166a2a}, // Sprite Pal LUT
	{"523h13.11f",  0x0100, 0x4e0647a0}, // Character Pal LUT
};


const ArcadeGame finalizrGames[FI_GAME_COUNT] = {
	AC_GAME("finalizr", "Finalizer - Super Transformation (set 1)", finalizrRoms)
	AC_GAME("finalizra", "Finalizer - Super Transformation (set 2)", finalizraRoms)
	AC_GAME("finalizrb", "Finalizer - Super Transformation (bootleg)", finalizrbRoms)
};
