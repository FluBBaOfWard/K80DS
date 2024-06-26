#ifndef SOUND_HEADER
#define SOUND_HEADER

#ifdef __cplusplus
extern "C" {
#endif

#include <maxmod9.h>

#include "SN76496/SN76496.h"
#include "YM2203/YM2203.h"

#define sample_rate 55930
#define buffer_size (512+16)

extern SN76496 sn76496_0;
extern YM2203 ym2203_0;

void soundInit(void);
void setMuteSoundGUI(void);
mm_word VblSound2(mm_word length, mm_addr dest, mm_stream_formats format);

#ifdef __cplusplus
} // extern "C"
#endif

#endif // SOUND_HEADER
