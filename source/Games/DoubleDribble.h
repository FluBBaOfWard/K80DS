#ifndef DOUBLEDRIBBLE_HEADER
#define DOUBLEDRIBBLE_HEADER

#ifdef __cplusplus
extern "C" {
#endif

#include "../Shared/ArcadeRoms.h"

#define DD_GAME_COUNT (2)

extern const ArcadeRom ddribbleRoms[17];
extern const ArcadeRom ddribblepRoms[23];

extern const ArcadeGame ddribbleGames[DD_GAME_COUNT];

/// This runs all save state functions for each chip.
int ddPackState(void *statePtr);

/// This runs all load state functions for each chip.
void ddUnpackState(const void *statePtr);

/// Gets the total state size in bytes.
int ddGetStateSize(void);

#ifdef __cplusplus
} // extern "C"
#endif

#endif // DOUBLEDRIBBLE_HEADER
