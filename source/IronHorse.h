#ifndef IRONHORSE_HEADER
#define IRONHORSE_HEADER

#ifdef __cplusplus
extern "C" {
#endif

#include "Shared/ArcadeRoms.h"

#define IH_GAME_COUNT (5)

extern const ArcadeRom ironhorsRoms[16];
extern const ArcadeRom ironhorshRoms[16];
extern const ArcadeRom dairesyaRoms[16];
extern const ArcadeRom farwestRoms[19];
extern const ArcadeRom scotrshtRoms[16];

extern const ArcadeGame ironhorsGames[IH_GAME_COUNT];

/// This runs all save state functions for each chip.
int packState(void *statePtr);

/// This runs all load state functions for each chip.
void unpackState(const void *statePtr);

/// Gets the total state size in bytes.
int getStateSize(void);

#ifdef __cplusplus
} // extern "C"
#endif

#endif // IRONHORSE_HEADER
