#include <nds.h>

#include "GreenBeret.h"
#include "Gfx.h"
#include "Cart.h"
//#include "Sound.h"
//#include "SN76496/SN76496.h"
#include "K005849/K005849.h"
#include "ARMZ80/ARMZ80.h"


int gbPackState(void *statePtr) {
	int size = 0;
//	size += sn76496SaveState(statePtr+size, &SN76496_0);
	size += k005849SaveState(statePtr+size, &k005849_0);
	size += Z80SaveState(statePtr+size, &Z80OpTable);
	return size;
}

void gbUnpackState(const void *statePtr) {
	int size = 0;
//	size += sn76496LoadState(&SN76496_0, statePtr+size);
	size += k005849LoadState(&k005849_0, statePtr+size);
	Z80LoadState(&Z80OpTable, statePtr+size);
}

int gbGetStateSize() {
	int size = 0;
//	size += sn76496GetStateSize();
	size += k005849GetStateSize();
	size += Z80GetStateSize();
	return size;
}

const ArcadeRom gberetRoms[14] = {
	{ROM_REGION,   0x10000, (int)&mainCpu}, // 64k for code
	{"577l03.10c", 0x4000, 0xae29e4ff},
	{"577l02.8c",  0x4000, 0x240836a5},
	{"577l01.7c",  0x4000, 0x41fa3e1f},
	{ROM_REGION,   0x20000, (int)&vromBase0},
	{"577l06.5e",  0x4000, 0x0f1cb0ca},
	{"577l05.4e",  0x4000, 0x523a8b66},
	{"577l08.4f",  0x4000, 0x883933a4},
	{"577l04.3e",  0x4000, 0xccecda4c},
	{"577l07.3f",  0x4000, 0x4da7bd1b},
	{ROM_REGION,   0x0220, (int)&promBase},
	{"577h09.2f",  0x0020, 0xc15e7c80},
	{"577h10.5f",  0x0100, 0xe9de1e53},
	{"577h11.6f",  0x0100, 0x2a1a992b},
};

const ArcadeRom rushatckRoms[14] = {
	{ROM_REGION,   0x10000, (int)&mainCpu}, // 64k for code
	{"577h03.10c", 0x4000, 0x4d276b52},
	{"577h02.8c",  0x4000, 0xb5802806},
	{"577h01.7c",  0x4000, 0xda7c8f3d},
	{ROM_REGION,   0x20000, (int)&vromBase0},
	{"577l06.5e",  0x4000, 0x0f1cb0ca},
	{"577h05.4e",  0x4000, 0x9d028e8f},
	{"577l08.4f",  0x4000, 0x883933a4},
	{"577l04.3e",  0x4000, 0xccecda4c},
	{"577h07.3f",  0x4000, 0x03f9815f},
	{ROM_REGION,   0x0220, (int)&promBase},
	{"577h09.2f",  0x0020, 0xc15e7c80},
	{"577h10.5f",  0x0100, 0xe9de1e53},
	{"577h11.6f",  0x0100, 0x2a1a992b},
};

const ArcadeRom gberetbRoms[13] = {
	{ROM_REGION,   0x10000, (int)&mainCpu}, // 64k for code
	{"2-ic82.10g", 0x8000, 0x6d6fb494},
	{"3-ic81.10f", 0x4000, 0xf1520a0a},
	{ROM_REGION,   0x20000, (int)&vromBase0},
	{"7-1c8.2b",   0x4000, 0x86334522},
	{"6-ic9.2c",   0x4000, 0xbda50d3e},
	{"5-ic10.2d",  0x4000, 0x6a7b3881},
	{"4-ic11.2e",  0x4000, 0x3fb186c9},
	{"1-ic92.12c", 0x4000, 0xb0189c87},
	{ROM_REGION,   0x0220, (int)&promBase},
	{"577h09",     0x0020, 0xc15e7c80},
	{"577h10.5f",  0x0100, 0xe9de1e53},
	{"577h11.6f",  0x0100, 0x2a1a992b},
	// ROM_REGION( 0x0001, "plds", 0 )
	//{"ic35.5h.bin",0x0001, NO_DUMP ) // PAL16R6ACN
};

const ArcadeRom mrgoemonRoms[11] = {
	{ROM_REGION,   0x14000, (int)&mainCpu}, // 64k for code + banked ROM
	{"621d01.10c", 0x8000, 0xb2219c56},
	{"621d02.12c", 0x8000, 0xc3337a97},
	{ROM_REGION,   0x20000, (int)&vromBase0},
	{"621d03.4d",  0x8000, 0x66f2b973},
	{"621d04.5d",  0x8000, 0x47df6301},
	{"621a05.6d",  0x4000, 0xf0a6dfc5},
	{ROM_REGION,   0x0220, (int)&promBase},
	{"621a06.5f",  0x0020, 0x7c90de5f},
	{"621a07.6f",  0x0100, 0x3980acdc},
	{"621a08.7f",  0x0100, 0x2fb244dd},
};

const ArcadeGame gberetGames[GB_GAME_COUNT] = {
	AC_GAME("gberet", "Green Beret", gberetRoms)
	AC_GAME("rushatck", "Rush'n Attack (US)", rushatckRoms)
	AC_GAME("gberetb", "Green Beret (bootleg)", gberetbRoms)
	AC_GAME("mrgoemon", "Mr. Goemon (Japan)", mrgoemonRoms)
};
