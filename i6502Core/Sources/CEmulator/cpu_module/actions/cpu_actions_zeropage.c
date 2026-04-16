#include "cpu_actions.h"
#include "cpu_actions_utils.h"
#include "cpu_module.h"
#include "bus_module.h"

#include <stdint.h>

void zp_t1(CpuState *state) {
    state->address_latch = bus_read(state->bus, state->register_pc++);
}

void zpx_t2(CpuState *state) {
    (void)bus_read(state->bus, state->address_latch);
    state->address_latch = (state->address_latch + state->register_x) & UINT8_MAX;
}

void zpy_t2(CpuState *state) {
    (void)bus_read(state->bus, state->address_latch);
    state->address_latch = (state->address_latch + state->register_y) & UINT8_MAX;
}
