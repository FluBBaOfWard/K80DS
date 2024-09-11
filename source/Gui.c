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

#define EMUVERSION "V0.3.9 2024-09-11"

static void uiDebug(void);
static void ui11(void);

const MItem fnList0[] = {{"",uiDummy}};
const MItem fnList1[] = {
	{"Load Game",ui9},
	{"Load State",loadState},
	{"Save State",saveState},
	{"Save Settings",saveSettings},
	{"Reset Game",resetGame},
	{"Quit Emulator",ui11}};
const MItem fnList2[] = {
	{"Controller",ui4},
	{"Display",ui5},
	{"Settings",ui6},
	{"Debug",ui7},
	{"DipSwitches",ui8}};
const MItem fnList4[] = {{"",autoBSet}, {"",autoASet}, {"",controllerSet}, {"",swapABSet}};
const MItem fnList5[] = {{"",scalingSet}, {"",flickSet}, {"",gammaSet}};
const MItem fnList6[] = {{"",speedSet}, {"",autoStateSet}, {"",autoSettingsSet}, {"",autoPauseGameSet}, {"",powerSaveSet}, {"",screenSwapSet}, {"",sleepSet}};
const MItem fnList7[] = {{"",debugTextSet}, {"",bgrLayerSet}, {"",sprLayerSet}, {"",stepFrame}};
const MItem fnList8[] = {{"",difficultSet}, {"",coinASet}, {"",coinBSet}, {"",livesSet}, {"",bonusSet}, {"",cabinetSet}, {"",demoSet}, {"",flipSet}, {"",uprightSet}, {"",serviceSet}};
const MItem fnList9[GAME_COUNT] = {{"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}, {"",quickSelectGame}};
const MItem fnList11[] = {{"Yes ",exitEmulator}, {"No ",backOutOfMenu}};

const Menu menu0 = MENU_M("", uiNullNormal, fnList0);
Menu menu1 = MENU_M("", uiAuto, fnList1);
const Menu menu2 = MENU_M("", uiAuto, fnList2);
const Menu menu3 = MENU_M("", uiAbout, fnList0);
const Menu menu4 = MENU_M("Controller Settings", uiController, fnList4);
const Menu menu5 = MENU_M("Display Settings", uiDisplay, fnList5);
const Menu menu6 = MENU_M("Settings", uiSettings, fnList6);
const Menu menu7 = MENU_M("Debug", uiDebug, fnList7);
const Menu menu8 = MENU_M("Dipswitch Settings", uiDipswitches, fnList8);
const Menu menu9 = MENU_M("Load Game", uiLoadGame, fnList9);
const Menu menu10 = MENU_M("", uiDummy, fnList0);
const Menu menu11 = MENU_M("Quit Emulator?", uiAuto, fnList11);

const Menu *const menus[] = {&menu0, &menu1, &menu2, &menu3, &menu4, &menu5, &menu6, &menu7, &menu8, &menu9, &menu10, &menu11 };

u8 gGammaValue = 0;

const char *const autoTxt[] = {"Off", "On", "With R"};
const char *const speedTxt[] = {"Normal", "200%", "Max", "50%"};
const char *const brighTxt[] = {"I", "II", "III", "IIII", "IIIII"};
const char *const sleepTxt[] = {"5min", "10min", "30min", "Off"};
const char *const ctrlTxt[] = {"1P", "2P"};
const char *const dispTxt[] = {"Unscaled", "Scaled"};
const char *const flickTxt[] = {"No Flicker", "Flicker"};

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
	menu1.itemCount = ARRSIZE(fnList1) - (enableExit?0:1);
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
	char str[32];
	char *s = str+22;

	cls(1);
	drawTabs();
	drawMenuText("Select: Insert coin", 4, 0);
	drawMenuText("Start:  Start button", 5, 0);
	drawMenuText("DPad:   Move character", 6, 0);
	drawMenuText("Up:     Climb", 7, 0);
	drawMenuText("Y:      Squat", 8, 0);
	drawMenuText("B:      Attack", 9, 0);
	drawMenuText("A:      Power", 10, 0);

	strcpy(str,"Coin Counter 0:       ");
	int2Str(coinCounter0, s);
	drawMenuText(str, 14, 0);
	strcpy(str,"Coin Counter 1:       ");
	int2Str(coinCounter1, s);
	drawMenuText(str, 15, 0);

	drawMenuText("K80DS        " EMUVERSION, 19, 0);
	drawMenuText("ARM6809      " ARM6809VERSION, 20, 0);
	drawMenuText("ARMZ80       " ARMZ80VERSION, 21, 0);
	drawMenuText("ARMK005849   " K005849VERSION, 22, 0);
	drawMenuText("ARMYM2203    " ARMYM2203VERSION, 23, 0);
}

void uiController() {
	setupSubMenuText();
	drawSubItem("B Autofire:", autoTxt[autoB]);
	drawSubItem("A Autofire:", autoTxt[autoA]);
	drawSubItem("Controller:", ctrlTxt[(joyCfg>>29)&1]);
	drawSubItem("Swap A-B:  ", autoTxt[(joyCfg>>10)&1]);
}

void uiDisplay() {
	setupSubMenuText();
	drawSubItem("Display:", dispTxt[gScaling]);
	drawSubItem("Scaling:", flickTxt[gFlicker]);
	drawSubItem("Gamma:", brighTxt[gGammaValue]);
}

void uiSettings() {
	setupSubMenuText();
	drawSubItem("Speed:", speedTxt[(emuSettings>>6)&3]);
	drawSubItem("Autoload State:", autoTxt[(emuSettings>>2)&1]);
	drawSubItem("Autosave Settings:", autoTxt[(emuSettings>>9)&1]);
	drawSubItem("Autopause Game:", autoTxt[emuSettings&1]);
	drawSubItem("Powersave 2nd Screen:",autoTxt[(emuSettings>>1)&1]);
	drawSubItem("Emulator on Bottom:", autoTxt[(emuSettings>>8)&1]);
	drawSubItem("Autosleep:", sleepTxt[(emuSettings>>4)&3]);
}

void uiDebug() {
	setupSubMenuText();
	drawSubItem("Debug Output:", autoTxt[gDebugSet&1]);
	drawSubItem("Disable Background:", autoTxt[gGfxMask&1]);
	drawSubItem("Disable Sprites:", autoTxt[(gGfxMask>>4)&1]);
	drawSubItem("Step Frame", NULL);
}

void uiDipswitches() {
	setupSubMenuText();
	drawSubItem("Difficulty:", diffTxt[(gDipSwitch1>>4)&3]);
	drawSubItem("Coin A:", coinTxt[gDipSwitch0 & 0xF]);
	drawSubItem("Coin B:", coinTxt[(gDipSwitch0>>4) & 0xF]);
	drawSubItem("Lives:", livesTxt[gDipSwitch1 & 3]);
	drawSubItem("Bonus:", bonusTxt[(gDipSwitch1>>3)&1]);
	drawSubItem("Cabinet:", cabTxt[(gDipSwitch1>>2)&1]);
	drawSubItem("Demo Sound:", autoTxt[(gDipSwitch1>>7)&1]);
	drawSubItem("Flip Screen:", autoTxt[gDipSwitch2&1]);
	drawSubItem("Upright Controls:", singleTxt[(gDipSwitch2>>1)&1]);
	drawSubItem("Service Mode:", autoTxt[(gDipSwitch2>>2)&1]);
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

/// Swap A & B buttons
void swapABSet() {
	joyCfg ^= 0x400;
}

/// Turn on/off scaling
void scalingSet(){
	gScaling ^= 0x01;
	refreshGfx();
}

/// Change gamma (brightness)
void gammaSet() {
	gGammaValue++;
	if (gGammaValue > 4) gGammaValue = 0;
	paletteInit(gGammaValue);
	paletteTxAll();					// Make new palette visible
	setupMenuPalette();
}

/// Turn on/off rendering of background
void bgrLayerSet(){
	gGfxMask ^= 0x03;
}
/// Turn on/off rendering of sprites
void sprLayerSet(){
	gGfxMask ^= 0x10;
}


/// Number of coins for credits
void coinASet() {
	int i = (gDipSwitch0+1) & 0xF;
	gDipSwitch0 = (gDipSwitch0 & ~0xF) | i;
}
/// Number of coins for credits
void coinBSet() {
	int i = (gDipSwitch0+0x10) & 0xF0;
	gDipSwitch0 = (gDipSwitch0 & ~0xF0) | i;
}
/// Number of lifes to start with
void livesSet() {
	int i = (gDipSwitch1+1) & 3;
	gDipSwitch1 = (gDipSwitch1 & ~3) | i;
}
/// At which score you get bonus lifes
void bonusSet() {
	int i = (gDipSwitch1+8) & 0x8;
	gDipSwitch1 = (gDipSwitch1 & ~0x08) | i;
}
/// Game difficulty
void difficultSet() {
	int i = (gDipSwitch1+0x10) & 0x30;
	gDipSwitch1 = (gDipSwitch1 & ~0x30) | i;
}
/// Cocktail/upright
void cabinetSet() {
	gDipSwitch1 ^= 0x04;
}
/// Demo sound on/off
void demoSet() {
	gDipSwitch1 ^= 0x80;
}
/// Flip screen
void flipSet() {
	gDipSwitch2 ^= 0x01;
}
void uprightSet() {
	gDipSwitch2 ^= 0x02;
}
/// Test/Service mode
void serviceSet() {
	gDipSwitch2 ^= 0x04;
}
