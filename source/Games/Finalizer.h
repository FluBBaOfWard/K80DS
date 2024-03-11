#ifndef FINALIZER_HEADER
#define FINALIZER_HEADER

#ifdef __cplusplus
extern "C" {
#endif

#include "../Shared/ArcadeRoms.h"

#define FI_GAME_COUNT (3)

extern const ArcadeRom finalizrRoms[20];
extern const ArcadeRom finalizraRoms[20];
extern const ArcadeRom finalizrbRoms[19];

extern const ArcadeGame finalizrGames[FI_GAME_COUNT];

/// This runs all save state functions for each chip.
int fiPackState(void *statePtr);

/// This runs all load state functions for each chip.
void fiUnpackState(const void *statePtr);

/// Gets the total state size in bytes.
int fiGetStateSize(void);

#ifdef __cplusplus
} // extern "C"
#endif

#endif // FINALIZER_HEADER
