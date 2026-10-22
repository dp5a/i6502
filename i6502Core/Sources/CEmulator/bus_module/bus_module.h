#ifndef __bus_module_h_
#define __bus_module_h_

#include "cart_module.h"

#include <stdint.h>

typedef struct PpuState PpuState;

/* Memory bus state */
typedef struct {
    uint8_t ram[2048];
    PpuState *ppu;
    CartState *cart;

    /* Controller */
    uint8_t controller_state[2];
    uint8_t controller_shift[2];
    bool controller_strobe;

    /* OAM DMA */
    uint8_t dma_page;
    bool dma_pending;
} BusState;

/* Bus initializer & deinitializer */
BusState * bus_create();
void bus_destroy(BusState *state);

/* Bus actions */
uint8_t bus_read(BusState *state, uint16_t address);
void bus_write(BusState *state, uint16_t address, uint8_t value);

#endif /* __bus_module_h_ */
