#ifndef FILEHANDLING_HEADER
#define FILEHANDLING_HEADER

#ifdef __cplusplus
extern "C" {
#endif

#include "Games/DoubleDribble.h"
#include "Games/GreenBeret.h"
#include "Games/Finalizer.h"
#include "Games/IronHorse.h"
#include "Games/Jackal.h"
#include "Games/JailBreak.h"
#include "Games/YieAr.h"

#define FILEEXTENSIONS ".zip"

#define GAME_COUNT (25)

extern const ArcadeGame allGames[GAME_COUNT];

int loadSettings(void);
void saveSettings(void);
int loadNVRAM(void);
void saveNVRAM(void);
void loadState(void);
void saveState(void);
bool loadGame(int gameNr);

#ifdef __cplusplus
} // extern "C"
#endif

#endif // FILEHANDLING_HEADER
