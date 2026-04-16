#ifndef __emu_module_h_
#define __emu_module_h_

#include "cpu_module.h"
#include "bus_module.h"

#include <stdbool.h>
#include <stdint.h>

/* Emulator state */
struct EmuState {
    CpuState *cpu;
    BusState *bus;

    bool nmi_pending;
    bool irq_pending;

    CpuCycles cpu_cycles;
    uint8_t cpu_cycles_index;
};

#endif /* __emu_module_h_ */
