#include <nds.h>

#include "Gui.h"
#include "Shared/EmuMenu.h"
#include "Shared/EmuSettings.h"
#include "Shared/FileHelper.h"
#include "Main.h"
#include "FileHandling.h"
#include "Cart.h"
#include "Gfx.h"
#include "io.h"
#include "cpu.h"
#include "ARM6809/Version.h"
#include "ARMZ80/Version.h"
#include "K005849/Version.h"
#include "YM2203/Version.h"

#define EMUVERSION "V0.4.0 2026-01-12"

static void scalingSet(void);
static const char *getScalingText(void);
static void controllerSet(void);
static const char *getControllerText(void);
static void swapABSet(void);
static const char *getSwapABText(void);
static void bgrLayerSet(void);
static const char *getBgrLayerText(void);
static void sprLayerSet(void);
static const char *getSprLayerText(void);
static void coinASet(void);
static const char *getCoinAText(void);
static void coinBSet(void);
static const char *getCoinBText(void);
static void difficultSet(void);
static const char *getDifficultText(void);
static void livesSet(void);
static const char *getLivesText(void);
static void bonusSet(void);
static const char *getBonusText(void);
static void cabinetSet(void);
static const char *getCabinetText(void);
static void demoSet(void);
static const char *getDemoText(void);
static void flipSet(void);
static const char *getFlipText(void);
static void uprightSet(void);
static const char *getUprightText(void);
static void serviceSet(void);
static const char *getServiceText(void);
static void gammaChange(void);

static void ui11(void);

const MItem dummyItems[] = {
	{"", uiDummy}
};
const MItem fileItems[] = {
	{"Load Game", ui9},
	{"Load State", loadState},
	{"Save State", saveState},
	{"Save Settings", saveSettings},
	{"Reset Game", resetGame},
	{"Quit Emulator", ui11},
};
const MItem optionItems[] = {
	{"Controller", ui4},
	{"Display", ui5},
	{"DipSwitches", ui6},
	{"Settings", ui7},
	{"Debug", ui8},
};
const MItem ctrlItems[] = {
	{"B Autofire:", autoBSet, getAutoBText},
	{"A Autofire:", autoASet, getAutoAText},
	{"Controller:", controllerSet, getControllerText},
	{"Swap A-B:  ", swapABSet, getSwapABText},
};
const MItem displayItems[] = {
	{"Display:", scalingSet, getScalingText},
	{"Scaling:", flickSet, getFlickText},
	{"Gamma:", gammaChange, getGammaText},
};
const MItem dipItems[] = {
	{"Difficulty:", difficultSet, getDifficultText},
	{"Coin A:", coinASet, getCoinAText},
	{"Coin B:", coinBSet, getCoinBText},
	{"Lives:", livesSet, getLivesText},
	{"Bonus:", bonusSet, getBonusText},
	{"Cabinet:", cabinetSet, getCabinetText},
	{"Demo Sound:", demoSet, getDemoText},
	{"Flip Screen:", flipSet, getFlipText},
	{"Upright Controls:", uprightSet, getUprightText},
	{"Service Mode:", serviceSet, getServiceText},
};
const MItem setItems[] = {
	{"Speed:", speedSet, getSpeedText},
	{"Autoload State:", autoStateSet, getAutoStateText},
	{"Autosave Settings:", autoSettingsSet, getAutoSettingsText},
	{"Autopause Game:", autoPauseGameSet, getAutoPauseGameText},
	{"Powersave 2nd Screen:", powerSaveSet, getPowerSaveText},
	{"Emulator on Bottom:", screenSwapSet, getScreenSwapText},
	{"Autosleep:", sleepSet, getSleepText},
};
const MItem debugItems[] = {
	{"Debug Output:", debugTextSet, getDebugText},
	{"Disable Background:", bgrLayerSet, getBgrLayerText},
	{"Disable Sprites:", sprLayerSet, getSprLayerText},
	{"Step Frame", stepFrame},
};
const MItem fnList9[ARRSIZE(allGames)] = {
	{"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame},
};
const MItem fnList11[] = {
	{"Yes ", exitEmulator},
	{"No ", backOutOfMenu},
};

const Menu menu0 = MENU_M("", uiNullNormal, dummyItems);
Menu menu1 = MENU_M("", uiAuto, fileItems);
const Menu menu2 = MENU_M("", uiAuto, optionItems);
const Menu menu3 = MENU_M("", uiAbout, dummyItems);
const Menu menu4 = MENU_M("Controller Settings", uiAuto, ctrlItems);
const Menu menu5 = MENU_M("Display Settings", uiAuto, displayItems);
const Menu menu6 = MENU_M("Dipswitch Settings", uiAuto, dipItems);
const Menu menu7 = MENU_M("Settings", uiAuto, setItems);
const Menu menu8 = MENU_M("Debug", uiAuto, debugItems);
const Menu menu9 = MENU_M("Load Game", uiLoadGame, fnList9);
const Menu menu10 = MENU_M("", uiDummy, dummyItems);
const Menu menu11 = MENU_M("Quit Emulator?", uiAuto, fnList11);

const Menu *const menus[] = {&menu0, &menu1, &menu2, &menu3, &menu4, &menu5, &menu6, &menu7, &menu8, &menu9, &menu10, &menu11 };

static const char *const ctrlTxt[] = {"1P", "2P"};
static const char *const dispTxt[] = {"Unscaled", "Scaled"};

const char *const coinTxt[] = {
	"1 Coin 1 Credit",  "1 Coin 2 Credits", "1 Coin 3 Credits", "1 Coin 4 Credits",
	"1 Coin 5 Credits", "1 Coin 6 Credits", "1 Coin 7 Credits", "2 Coins 1 Credit",
	"2 Coins 3 Credits","2 Coins 5 Credits","3 Coins 1 Credit", "3 Coins 2 Credits",
	"3 Coins 4 Credits","4 Coins 1 Credit", "4 Coins 3 Credits","Free Play"};
const char *const diffTxt[] = {"Easy", "Normal", "Hard", "Very Hard"};
char *const livesTxt[] = {"2", "3", "5", "7"};
char *const bonusTxt[] = {"30K 70K+", "40K 80K+", "40K", "50K"};
char *const cabTxt[] = {"Cocktail", "Upright"};
char *const singleTxt[] = {"Single", "Dual"};


void setupGUI() {
	emuSettings = AUTOPAUSE_EMULATION;
	keysSetRepeat(25, 4);	// delay, repeat.
	menu1.itemCount = ARRSIZE(fileItems) - (enableExit?0:1);
	openMenu();
}

/// This is called when going from emu to ui.
void enterGUI() {
}

/// This is called going from ui to emu.
void exitGUI() {
}

void autoLoadGame(void) {
	ui9();
	selected = 0;
	quickSelectGame();
}

void quickSelectGame(void) {
	while (loadGame(selected)) {
		ui10();
		if (!browseForFileType(FILEEXTENSIONS)) {
			backOutOfMenu();
			return;
		}
	}
	closeMenu();
}

void uiNullNormal() {
	uiNullDefault();
}

void uiAbout() {
	cls(1);
	drawTabs();
	drawMenuText("Select: Insert coin", 4, 0);
	drawMenuText("Start:  Start button", 5, 0);
	drawMenuText("DPad:   Move character", 6, 0);
	drawMenuText("Up:     Climb", 7, 0);
	drawMenuText("Y:      Squat", 8, 0);
	drawMenuText("B:      Attack", 9, 0);
	drawMenuText("A:      Power", 10, 0);

	char s[10];
	int2Str(coinCounter0, s);
	drawStrings("CoinCounter1:", s, 1, 15, 0);
	int2Str(coinCounter1, s);
	drawStrings("CoinCounter2:", s, 1, 16, 0);

	drawMenuText("K80DS        " EMUVERSION, 19, 0);
	drawMenuText("ARM6809      " ARM6809VERSION, 20, 0);
	drawMenuText("ARMZ80       " ARMZ80VERSION, 21, 0);
	drawMenuText("ARMK005849   " K005849VERSION, 22, 0);
	drawMenuText("ARMYM2203    " ARMYM2203VERSION, 23, 0);
}

void uiLoadGame() {
	setupSubMenuText();
	int i;
	for (i=0; i<ARRSIZE(allGames); i++) {
		drawSubItem(allGames[i].fullName, NULL);
		if (i > menuYOffset + 10) {
			break;
		}
	}
}

void ui11() {
	enterMenu(11);
}

void nullUINormal(int key) {
	if (key & KEY_TOUCH) {
		openMenu();
	}
}

void nullUIDebug(int key) {
	if (key & KEY_TOUCH) {
		openMenu();
	}
}

void resetGame() {
	loadCart(romNum,0);
}


//---------------------------------------------------------------------------------
/// Switch between Player 1 & Player 2 controls
void controllerSet() {				// See io.s: refreshEMUjoypads
	joyCfg ^= 0x20000000;
}
const char *getControllerText() {
	return ctrlTxt[(joyCfg>>29)&1];
}
/// Swap A & B buttons
void swapABSet() {
	joyCfg ^= 0x400;
}
const char *getSwapABText() {
	return autoTxt[(joyCfg>>10)&1];
}

/// Turn on/off scaling
void scalingSet(){
	gScaling ^= 0x01;
	refreshGfx();
}
const char *getScalingText() {
	return dispTxt[gScaling];
}

/// Change gamma (brightness)
void gammaChange() {
	gammaSet();
	paletteInit(gGammaValue);
	paletteTxAll();					// Make new palette visible
	setupMenuPalette();
}

/// Turn on/off rendering of background
void bgrLayerSet(){
	gGfxMask ^= 0x03;
}
const char *getBgrLayerText() {
	return autoTxt[gGfxMask&1];
}
/// Turn on/off rendering of sprites
void sprLayerSet(){
	gGfxMask ^= 0x10;
}
const char *getSprLayerText() {
	return autoTxt[(gGfxMask>>4)&1];
}


/// Number of coins for credits
void coinASet() {
	int i = (gDipSwitch0+1) & 0xF;
	gDipSwitch0 = (gDipSwitch0 & ~0xF) | i;
}
const char *getCoinAText() {
	return coinTxt[gDipSwitch0 & 0xF];
}
/// Number of coins for credits
void coinBSet() {
	int i = (gDipSwitch0+0x10) & 0xF0;
	gDipSwitch0 = (gDipSwitch0 & ~0xF0) | i;
}
const char *getCoinBText() {
	return coinTxt[(gDipSwitch0>>4) & 0xF];
}
/// Number of lifes to start with
void livesSet() {
	int i = (gDipSwitch1+1) & 3;
	gDipSwitch1 = (gDipSwitch1 & ~3) | i;
}
const char *getLivesText() {
	return livesTxt[gDipSwitch1 & 3];
}
/// At which score you get bonus lifes
void bonusSet() {
	int i = (gDipSwitch1+8) & 0x8;
	gDipSwitch1 = (gDipSwitch1 & ~0x08) | i;
}
const char *getBonusText() {
	return bonusTxt[(gDipSwitch1>>3) & 1];
}
/// Game difficulty
void difficultSet() {
	int i = (gDipSwitch1+0x10) & 0x30;
	gDipSwitch1 = (gDipSwitch1 & ~0x30) | i;
}
const char *getDifficultText() {
	return diffTxt[(gDipSwitch1>>4) & 3];
}
/// Cocktail/upright
void cabinetSet() {
	gDipSwitch1 ^= 0x04;
}
const char *getCabinetText() {
	return cabTxt[(gDipSwitch1>>2) & 1];
}
/// Demo sound on/off
void demoSet() {
	gDipSwitch1 ^= 0x80;
}
const char *getDemoText() {
	return autoTxt[(gDipSwitch1>>7) & 1];
}
/// Flip screen
void flipSet() {
	gDipSwitch2 ^= 0x01;
}
const char *getFlipText() {
	return autoTxt[gDipSwitch2 & 1];
}
void uprightSet() {
	gDipSwitch2 ^= 0x02;
}
const char *getUprightText() {
	return singleTxt[(gDipSwitch2>>1) & 1];
}
/// Test/Service mode
void serviceSet() {
	gDipSwitch2 ^= 0x04;
}
const char *getServiceText() {
	return autoTxt[(gDipSwitch2>>2) & 1];
}
