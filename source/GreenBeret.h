#ifndef GREENBERET_HEADER
#define GREENBERET_HEADER

#ifdef __cplusplus
extern "C" {
#endif

#include "Shared/ArcadeRoms.h"

#define GAME_COUNT (4)

extern const ArcadeGame gberetGames[GAME_COUNT];

/// This runs all save state functions for each chip.
int bgPackState(void *statePtr);

/// This runs all load state functions for each chip.
void gbPnpackState(const void *statePtr);

/// Gets the total state size in bytes.
int gbGetStateSize(void);

#ifdef __cplusplus
} // extern "C"
#endif

#endif // GREENBERET_HEADER
