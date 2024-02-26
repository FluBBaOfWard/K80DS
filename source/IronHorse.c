#include <nds.h>

#include "IronHorse.h"
#include "Cart.h"
#include "Gfx.h"
#include "cpu.h"
#include "K005849/K005849.h"
#include "ARMZ80/ARMZ80.h"
#include "ARM6809/ARM6809.h"


int packState(void *statePtr) {
	int size = 0;
	memcpy(statePtr+size, &paletteBank, 4);
	size += 4;
//	size += ym2203SaveState(statePtr+size, &ym2203_0);
	size += k005849SaveState(statePtr+size, &k005885_0);
	size += Z80SaveState(statePtr+size, &Z80OpTable);
	size += m6809SaveState(statePtr+size, &m6809CPU0);
	return size;
}

void unpackState(const void *statePtr) {
	int size = 0;
	memcpy(&paletteBank, statePtr+size, 4);
	size += 4;
//	size += ym2203LoadState(&ym2203_0, statePtr+size);
	size += k005849LoadState(&k005885_0, statePtr+size);
	size += Z80LoadState(&Z80OpTable, statePtr+size);
	m6809LoadState(&m6809CPU0, statePtr+size);
	paletteTxAll();
}

int getStateSize() {
	int size = 0;
	size += 4;
//	size += ym2203GetStateSize();
	size += k005849GetStateSize();
	size += Z80GetStateSize();
	size += m6809GetStateSize();
	return size;
}

const ArcadeRom ironhorsRoms[16] = {
	{ROM_REGION,   0x10000, (int)&mainCpu},
	{"560_k03.13c",  0x8000, 0x395351b4},
	{"560_k02.12c",  0x4000, 0x1cff3d59},
	{ROM_REGION,   0x10000, (int)&soundCpu},   // 64k for sound code
	{"560_h01.10c",  0x4000, 0x2b17930f},
	{ROM_REGION,   0x20000, (int)&vromBase0},
	{"560_h06.08f",  0x8000, 0xf21d8c93},
	{"560_h07.09f",  0x8000, 0xc761ec73},
	{"560_h05.07f",  0x8000, 0x60107859},
	{"560_h04.06f",  0x8000, 0xc1486f61},
	{ROM_REGION,     0x0500, (int)&promBase},
	{"03f_h08.bin",  0x0100, 0x9f6ddf83},
	{"04f_h09.bin",  0x0100, 0xe6773825},
	{"05f_h10.bin",  0x0100, 0x30a57860},
	{"10f_h12.bin",  0x0100, 0x5eb33e73},
	{"10f_h11.bin",  0x0100, 0xa63e37d8},
};

const ArcadeRom ironhorshRoms[16] = {
	{ROM_REGION,   0x10000, (int)&mainCpu},
	{"13c_h03.bin",  0x8000, 0x24539af1},
	{"12c_h02.bin",  0x4000, 0xfab07f86},
	{ROM_REGION,   0x10000, (int)&soundCpu},   // 64k for sound code
	{"10c_h01.bin",  0x4000, 0x2b17930f},
	{ROM_REGION,   0x20000, (int)&vromBase0},
	{"08f_h06.bin",  0x8000, 0xf21d8c93},
	{"09f_h07.bin",  0x8000, 0xc761ec73},
	{"07f_h05.bin",  0x8000, 0x60107859},
	{"06f_h04.bin",  0x8000, 0xc1486f61},
	{ROM_REGION,     0x0500, (int)&promBase},
	{"03f_h08.bin",  0x0100, 0x9f6ddf83},
	{"04f_h09.bin",  0x0100, 0xe6773825},
	{"05f_h10.bin",  0x0100, 0x30a57860},
	{"10f_h12.bin",  0x0100, 0x5eb33e73},
	{"10f_h11.bin",  0x0100, 0xa63e37d8},
};

const ArcadeRom dairesyaRoms[16] = {
	{ROM_REGION,   0x10000, (int)&mainCpu},
	{"560-k03.13c",  0x8000, 0x2ac6103b},
	{"560-k02.12c",  0x4000, 0x07bc13a9},
	{ROM_REGION,   0x10000, (int)&soundCpu},   // 64k for sound code
	{"560-j01.10c",  0x4000, 0xa203b223},
	{ROM_REGION,   0x20000, (int)&vromBase0},
	{"560-j06.8f",   0x8000, 0xa6e8248d},
	{"560-k07.9f",   0x8000, 0xc8a1b840},
	{"560-j05.7f",   0x8000, 0xf75893d4},
	{"560-k04.6f",   0x8000, 0xc883d856},
	{ROM_REGION,     0x0500, (int)&promBase},
	{"03f_h08.bin",  0x0100, 0x9f6ddf83},
	{"04f_h09.bin",  0x0100, 0xe6773825},
	{"05f_h10.bin",  0x0100, 0x30a57860},
	{"10f_h12.bin",  0x0100, 0x5eb33e73},
	{"10f_h11.bin",  0x0100, 0xa63e37d8},
};

const ArcadeRom farwestRoms[19] = {
	{ROM_REGION,   0x12000, (int)&mainCpu}, // 64k for code + 8k for extra ROM
	{"ironhors.008", 0x4000, 0xb1c8246c},
	{"ironhors.009", 0x8000, 0xea34ecfc},
	{"ironhors.007", 0x2000, 0x471182b7},
	{ROM_REGION,   0x10000, (int)&soundCpu},   // 64k for sound code
	{"ironhors.010", 0x4000, 0xa28231a6},
	{ROM_REGION,   0x10000, (int)&vromBase0},
	{"ironhors.005", 0x8000, 0xf77e5b83},
	{"ironhors.006", 0x8000, 0x7bbc0b51},
	// ROM_REGION( 0x10000, "gfx2", 0 )
	{"ironhors.001", 0x4000, 0xa8fc21d3},
	{"ironhors.002", 0x4000, 0x9c1e5593},
	{"ironhors.003", 0x4000, 0x3a0bf799},
	{"ironhors.004", 0x4000, 0x1fab18a3},
	{ROM_REGION,     0x0500, (int)&promBase},
	{"ironcol.003",  0x0100, 0x3e3fca11},
	{"ironcol.001",  0x0100, 0xdfb13014},
	{"ironcol.002",  0x0100, 0x77c88430},
	{"10f_h12.bin",  0x0100, 0x5eb33e73},
	{"ironcol.005",  0x0100, 0x15077b9c},
};

const ArcadeRom scotrshtRoms[16] = {
	{ROM_REGION,   0x10000, (int)&mainCpu},
	{"gx545_g03_12c.bin", 0x8000, 0xb808e0d3},
	{"gx545_g02_10c.bin", 0x4000, 0xb22c0586},
	{ROM_REGION,   0x10000, (int)&soundCpu},   // 64k for sound code
	{"gx545_g01_8c.bin",  0x4000, 0x46a7cc65},
	{ROM_REGION,   0x20000, (int)&vromBase0},
	{"gx545_g06_6f.bin",  0x8000, 0x14ad7601}, // Sprites
	{"gx545_h04_4f.bin",  0x8000, 0xc06c11a3},
	{"gx545_g05_5f.bin",  0x8000, 0x856c349c}, // Characters
	{FILL0XFF,            0x8000, 0x00000000},
	{ROM_REGION,          0x0500, (int)&promBase},
	{"gx545_6301_1f.bin", 0x0100, 0xf584586f}, // Red
	{"gx545_6301_2f.bin", 0x0100, 0xad464db1}, // Green
	{"gx545_6301_3f.bin", 0x0100, 0xbd475d23}, // Blue
	{"gx545_6301_7f.bin", 0x0100, 0x2b0cd233}, // Char lookup
	{"gx545_6301_8f.bin", 0x0100, 0xc1c7cf58}, // Sprites lookup
};

const ArcadeGame ironhorsGames[IH_GAME_COUNT] = {
	AC_GAME("ironhors", "Iron Horse (version K)", ironhorsRoms)
	AC_GAME("ironhorsh", "Iron Horse (version H)", ironhorshRoms)
	AC_GAME("dairesya", "Dai Ressya Goutou (Japan, version K)", dairesyaRoms)
	AC_GAME("farwest", "Far West", farwestRoms)
	AC_GAME("scotrsht", "Scooter Shooter", scotrshtRoms)
};
