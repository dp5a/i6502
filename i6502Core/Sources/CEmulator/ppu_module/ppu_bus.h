#ifndef __ppu_bus_
#define __ppu_bus_

#include "ppu_module.h"

/* PPU bus */

void ppu_bus_write(PpuState *state, uint16_t address, uint8_t value);
uint8_t ppu_bus_read(PpuState *state, uint16_t address);

#endif /* __ppu_bus_ */
