#ifndef JAILBREAK_HEADER
#define JAILBREAK_HEADER

#ifdef __cplusplus
extern "C" {
#endif

#include "../Shared/ArcadeRoms.h"

#define JB_GAME_COUNT (3)

extern const ArcadeRom jailbrekRoms[17];
extern const ArcadeRom jailbrekbRoms[13];
extern const ArcadeRom manhatanRoms[17];

extern const ArcadeGame jailbrekGames[JB_GAME_COUNT];

/// This runs all save state functions for each chip.
int jbPackState(void *statePtr);

/// This runs all load state functions for each chip.
void jbUnpackState(const void *statePtr);

/// Gets the total state size in bytes.
int jbGetStateSize(void);

#ifdef __cplusplus
} // extern "C"
#endif

#endif // JAILBREAK_HEADER
