#include <nds.h>

#include "Jackal.h"
#include "../Cart.h"
#include "../Gui.h"
#include "../Cart.h"
#include "../Gfx.h"
#include "../cpu.h"
#include "../K005849/K005849.h"
#include "../ARM6809/ARM6809.h"

static int saveRam(void *statePtr);
static int loadRam(const void *statePtr);
static int getRamSize();


int jkPackState(void *statePtr) {
	int size = 0;
	size += saveRam(statePtr+size);
	size += k005849SaveState(statePtr+size, &k005885_1);
	size += k005849SaveState(statePtr+size, &k005885_0);
	size += m6809SaveState(statePtr+size, &m6809CPU1);
	size += m6809SaveState(statePtr+size, &m6809CPU0);
	return size;
}

void jkUnpackState(const void *statePtr) {
	int size = 0;
	size += loadRam(statePtr+size);
	size += k005849LoadState(&k005885_1, statePtr+size);
	size += k005849LoadState(&k005885_0, statePtr+size);
	size += m6809LoadState(&m6809CPU1, statePtr+size);
	m6809LoadState(&m6809CPU0, statePtr+size);
	paletteInit(gGammaValue);
	paletteTxAll();
}

int jkGetStateSize() {
	int size = 0;
	size += getRamSize();
	size += k005849GetStateSize();
	size += k005849GetStateSize();
	size += m6809GetStateSize();
	size += m6809GetStateSize();
	return size;
}


int saveRam(void *state) {
	int size = 0;
	memcpy(state+size, SHARED_RAM, sizeof(SHARED_RAM));
	size += sizeof(SHARED_RAM);
	memcpy(state+size, k005885Palette, sizeof(k005885Palette));
	size += sizeof(k005885Palette);
	memcpy(state+size, &chipBank, 4);
	size += 4;
	return size;
}

int loadRam(const void *state) {
	int size = 0;
	memcpy(SHARED_RAM, state+size, sizeof(SHARED_RAM));
	size += sizeof(SHARED_RAM);
	memcpy(k005885Palette, state+size, sizeof(k005885Palette));
	size += sizeof(k005885Palette);
	memcpy(&chipBank, state+size, 4);
	size += 4;
	jackalMapper(chipBank);
	return size;
}

int getRamSize() {
	return sizeof(SHARED_RAM) + sizeof(k005885Palette) + 4;
}

const ArcadeRom jackalRoms[13] = {
	{ROM_REGION,   0x20000, (int)&mainCpu}, // Banked 64k for 1st CPU
	{"631_v02.15d", 0x10000, 0x0b7e0584},
	{"631_v03.16d", 0x4000, 0x3e0dfb83},
	{ROM_REGION,   0x10000, (int)&subCpu}, // 64k for 2nd cpu (Graphics & Sound)
	{"631_t01.11d", 0x8000, 0xb189af6a},
	{ROM_REGION,   0x80000, (int)&vromBase0},
	{"631t04.7h",  0x20000, 0x457f42f0},
	{"631t05.8h",  0x20000, 0x732b3fc1},
	{"631t06.12h", 0x20000, 0x2d10e56e},
	{"631t07.13h", 0x20000, 0x4961c397},
	{ROM_REGION,   0x0200, (int)&promBase}, // Color lookup tables
	{"631r08.9h",  0x0100, 0x7553a172},
	{"631r09.14h", 0x0100, 0xa74dd86c},
};

const ArcadeRom jackalrRoms[13] = {
	{ROM_REGION,   0x20000, (int)&mainCpu}, // Banked 64k for 1st CPU
	{"631_q02.15d", 0x10000, 0xed2a7d66},
	{"631_q03.16d", 0x4000, 0xb9d34836},
	{ROM_REGION,   0x10000, (int)&subCpu}, // 64k for 2nd cpu (Graphics & Sound)
	{"631_q01.11d", 0x8000, 0x54aa2d29},
	{ROM_REGION,   0x80000, (int)&vromBase0},
	{"631t04.7h",  0x20000, 0x457f42f0},
	{"631t05.8h",  0x20000, 0x732b3fc1},
	{"631t06.12h", 0x20000, 0x2d10e56e},
	{"631t07.13h", 0x20000, 0x4961c397},
	{ROM_REGION,   0x0200, (int)&promBase}, // Color lookup tables
	{"631r08.9h",  0x0100, 0x7553a172},
	{"631r09.14h", 0x0100, 0xa74dd86c},
};

const ArcadeRom topgunrRoms[13] = {
	{ROM_REGION,   0x20000, (int)&mainCpu}, // Banked 64k for 1st CPU
	{"631_u02.15d", 0x10000, 0xf7e28426},
	{"631_u03.16d", 0x4000, 0xc086844e},
	{ROM_REGION,   0x10000, (int)&subCpu}, // 64k for 2nd cpu (Graphics & Sound)
	{"631_t01.11d", 0x8000, 0xb189af6a},
	{ROM_REGION,   0x80000, (int)&vromBase0},
	{"631u04.7h",  0x20000, 0x50122a12},
	{"631u05.8h",  0x20000, 0x6943b1a4},
	{"631u06.12h", 0x20000, 0x37dbbdb0},
	{"631u07.13h", 0x20000, 0x22effcc8},
	{ROM_REGION,   0x0200, (int)&promBase}, // Color lookup tables
	{"631r08.9h",  0x0100, 0x7553a172},
	{"631r09.14h", 0x0100, 0xa74dd86c},
};

const ArcadeRom jackaljRoms[13] = {
	{ROM_REGION,   0x20000, (int)&mainCpu}, // Banked 64k for 1st CPU
	{"631_t02.15d", 0x10000, 0x14db6b1a},
	{"631_t03.16d", 0x4000, 0xfd5f9624},
	{ROM_REGION,   0x10000, (int)&subCpu}, // 64k for 2nd cpu (Graphics & Sound)
	{"631_t01.11d", 0x8000, 0xb189af6a},
	{ROM_REGION,   0x80000, (int)&vromBase0},
	{"631t04.7h",  0x20000, 0x457f42f0},
	{"631t05.8h",  0x20000, 0x732b3fc1},
	{"631t06.12h", 0x20000, 0x2d10e56e},
	{"631t07.13h", 0x20000, 0x4961c397},
	{ROM_REGION,   0x0200, (int)&promBase}, // Color lookup tables
	{"631r08.9h",  0x0100, 0x7553a172},
	{"631r09.14h", 0x0100, 0xa74dd86c},
};

const ArcadeRom jackalblRoms[26] = {
	{ROM_REGION,   0x20000, (int)&mainCpu}, // Banked 64k for 1st CPU
	{"epr-a-3.bin", 0x8000, 0x5fffee27},
	{"epr-a-4.bin", 0x8000, 0x976c8431},
	{"epr-a-2.bin", 0x4000, 0xae2a290a},
	{ROM_REGION,   0x10000, (int)&subCpu}, // 64k for 2nd cpu (Graphics & Sound)
	{"epr-a-1.bin", 0x8000, 0x54aa2d29},
	{ROM_REGION,   0x80000, (int)&vromBase0},
	/* same data, different layout */
	{"epr-a-17.bin", 0x08000, 0xa96720b6},
	{"epr-a-18.bin", 0x08000, 0x932d0ecb},
	{"epr-a-19.bin", 0x08000, 0x1e3412e7},
	{"epr-a-20.bin", 0x08000, 0x4b0d15be},
	{"epr-a-6.bin",  0x08000, 0xec7141ad},
	{"epr-a-5.bin",  0x08000, 0xc6375c74},
	{"epr-a-7.bin",  0x08000, 0x03e1de04},
	{"epr-a-8.bin",  0x08000, 0xf946ada7},
	{"epr-a-13.bin", 0x08000, 0x7c29c59e},
	{"epr-a-14.bin", 0x08000, 0xf2bbff39},
	{"epr-a-15.bin", 0x08000, 0x594dbaaf},
	{"epr-a-16.bin", 0x08000, 0x069bf945},
	{"epr-a-9.bin",  0x08000, 0xc00cef79},
	{"epr-a-10.bin", 0x08000, 0x0aed6cd7},
	{"epr-a-11.bin", 0x08000, 0xa48e9f60},
	{"epr-a-12.bin", 0x08000, 0x79b7c71c},
	{ROM_REGION,   0x0200, (int)&promBase}, // Color lookup tables
	{"n82s129n.prom2", 0x0100, 0x7553a172},
	{"n82s129n.prom1", 0x0100, 0xa74dd86c},
	// ROM_REGION( 0x1000, "pals", 0 )     // currently not used by the emulation
//	{"pal16r6cn.pal1",     0x0104, 0x9bba948f},
//	{"ampal16l8pc.pal2",   0x0104, 0x17c9de2f},
//	{"ampal16r4pc.pal3",   0x0104, 0xe54cd288},
//	{"pal16r8acn.pal4",    0x0104, 0x5cc45e00},
//	{"pal20l8a-2cns.pal5", 0x0144, NO_DUMP ) // Read protected
//	{"pal20l8acns.pal6",   0x0144, NO_DUMP ) // Read protected
//	{"pal16l8pc.pal7",     0x0104, 0xe8cdc259},
//	{"d5c121.ep1200",      0x0200, NO_DUMP ) // Not dumped yet
};

const ArcadeRom topgunblRoms[26] = {
	{ROM_REGION,   0x20000, (int)&mainCpu}, // Banked 64k for 1st CPU
	{"t-3.c5", 0x8000, 0x7826ad38},
	{"t-4.c4", 0x8000, 0x976c8431},
	{"t-2.c6", 0x4000, 0xd53172e5},
	{ROM_REGION,   0x10000, (int)&subCpu}, // 64k for 2nd cpu (Graphics & Sound)
	{"t-1.c14", 0x8000, 0x54aa2d29},
	{ROM_REGION,   0x80000, (int)&vromBase0},
	/* same data, different layout */
	{"t-17.n12", 0x08000, 0xe8875110},
	{"t-18.n13", 0x08000, 0xcf14471d},
	{"t-19.n14", 0x08000, 0x46ee5dd2},
	{"t-20.n15", 0x08000, 0x3f472344},
	{"t-6.n1",   0x08000, 0x539cc48c},
	{"t-5.m1",   0x08000, 0xdbc26afe},
	{"t-7.n2",   0x08000, 0x0ecd31b1},
	{"t-8.n3",   0x08000, 0xf946ada7},
	{"t-13.n8",  0x08000, 0x5d669abb},
	{"t-14.n9",  0x08000, 0xf349369b},
	{"t-15.n10", 0x08000, 0x7c5a91dd},
	{"t-16.n11", 0x08000, 0x5ec46d8e},
	{"t-9.n4",   0x08000, 0x8269caca},
	{"t-10.n5",  0x08000, 0x25393e4f},
	{"t-11.n6",  0x08000, 0x7895c22d},
	{"t-12.n7",  0x08000, 0x15606dfc},
	{ROM_REGION,   0x0200, (int)&promBase}, // Color lookup tables
	{"631r08.bpr", 0x0100, 0x7553a172},
	{"631r09.bpr", 0x0100, 0xa74dd86c},
};

const ArcadeGame jackalGames[JK_GAME_COUNT] = {
	AC_GAME("jackal",   "Jackal (World, 8-way Joystick)", jackalRoms)
	AC_GAME("jackalr",  "Jackal (World, Rotary Joystick)", jackalrRoms)
	AC_GAME("topgunr",  "Top Gunner (US, 8-way Joystick)", topgunrRoms)
	AC_GAME("jackalj",  "Tokushu Butai Jackal (Japan, 8-way Joystick)", jackaljRoms)
	AC_GAME("jackalbl", "Jackal (bootleg, Rotary Joystick)", jackalblRoms)
	AC_GAME("topgunbl", "Top Gunner (bootleg, Rotary Joystick)", topgunblRoms)
};
