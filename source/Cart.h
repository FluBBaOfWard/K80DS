#ifndef CART_HEADER
#define CART_HEADER

#ifdef __cplusplus
extern "C" {
#endif

extern u8 bankReg;

extern u8 SHARED_RAM[0x2000];
extern u8 SOUND_RAM[0x800];
extern u8 ROM_Space[0x32500];
extern u8 *mainCpu;
extern u8 *soundCpu;
extern u8 *vromBase0;
extern u8 *vromBase1;
extern u8 *promBase;
extern u8 *vlmBase;

void machineInit(void);
void loadCart(int, int);
void ejectCart(void);

#ifdef __cplusplus
} // extern "C"
#endif

#endif // CART_HEADER
