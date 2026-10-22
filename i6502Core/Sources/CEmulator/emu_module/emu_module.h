#ifndef __emu_module_h_
#define __emu_module_h_

#include "cpu_module.h"
#include "ppu_module.h"
#include "bus_module.h"
#include "cart_module.h"

#include <stdbool.h>
#include <stdint.h>

/* Emulator state */
struct EmuState {
    CpuState *cpu;
    PpuState *ppu;
    BusState *bus;
    CartState *cart;

    bool nmi_pending;
    bool irq_pending;

    uint32_t *framebuffer;

    CpuCycles cpu_cycles;
    uint8_t cpu_cycles_index;

    uint16_t dma_stall;  /* CPU stall cycles remaining (OAM DMA) */
};

#endif /* __emu_module_h_ */
