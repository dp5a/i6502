#include "cpu_actions.h"
#include "cpu_actions_utils.h"
#include "cpu_module.h"
#include "bus_module.h"

#include <stdint.h>

void acc_asl_t1(CpuState *state) {
    (void)bus_read(state->bus, state->register_pc);

    state->register_a = apply_asl(state, state->register_a);
}

void acc_lsr_t1(CpuState *state) {
    (void)bus_read(state->bus, state->register_pc);

    state->register_a = apply_lsr(state, state->register_a);
}

void acc_rol_t1(CpuState *state) {
    (void)bus_read(state->bus, state->register_pc);

    state->register_a = apply_rol(state, state->register_a);
}

void acc_ror_t1(CpuState *state) {
    (void)bus_read(state->bus, state->register_pc);

    state->register_a = apply_ror(state, state->register_a);
}
