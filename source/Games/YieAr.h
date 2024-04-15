#ifndef YIEAR_HEADER
#define YIEAR_HEADER

#ifdef __cplusplus
extern "C" {
#endif

#include "../Shared/ArcadeRoms.h"
#include "../YieArVideo/YieArVideo.h"

#define YA_GAME_COUNT (2)

extern YieArVideo yieAr_0;

extern const ArcadeRom yiearRoms[15];
extern const ArcadeRom yiear2Roms[15];

extern const ArcadeGame yiearGames[YA_GAME_COUNT];

/// This runs all save state functions for each chip.
int yaPackState(void *statePtr);

/// This runs all load state functions for each chip.
void yaUnpackState(const void *statePtr);

/// Gets the total state size in bytes.
int yaGetStateSize(void);

#ifdef __cplusplus
} // extern "C"
#endif

#endif // YIEAR_HEADER
