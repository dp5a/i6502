#ifndef __cpu_module_h_
#define __cpu_module_h_

#include "bus_module.h"
#include <stdint.h>

/* 6502 state */
typedef struct {
    uint16_t register_pc;
    uint8_t register_sp;
    uint8_t register_ps;
    uint8_t register_a;
    uint8_t register_x;
    uint8_t register_y;
    BusState *bus;

    uint8_t data_latch;
    uint16_t address_latch;
} CpuState;

/* 6502 operation (like read, write, ALU, ..) */
typedef void (*CpuAction)(CpuState *);

/* 6502 operations, that will be executed after fetching opcode */
typedef struct {
    CpuAction actions[7];
    uint8_t count;
} CpuCycles;

/* 6502 initializer & deinitializer */
CpuState * cpu_create();
void cpu_destroy(CpuState *state);

/* 6502 actions */
CpuCycles cpu_decode(CpuState *state);
CpuCycles cpu_nmi(CpuState *state);
CpuCycles cpu_reset(CpuState *state);
CpuCycles cpu_irq(CpuState *state);

#endif /* __cpu_module_h_ */
