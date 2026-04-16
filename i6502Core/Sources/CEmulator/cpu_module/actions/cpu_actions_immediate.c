#include "cpu_actions.h"
#include "cpu_actions_utils.h"
#include "cpu_module.h"
#include "bus_module.h"

#include <stdint.h>

void imm_adc_t1(CpuState *state) {
    uint8_t operand = bus_read(state->bus, state->register_pc++);

    apply_adc(state, operand);
}

void imm_sbc_t1(CpuState *state) {
    uint8_t operand = bus_read(state->bus, state->register_pc++);

    apply_sbc(state, operand);
}

void imm_and_t1(CpuState *state) {
    uint8_t operand = bus_read(state->bus, state->register_pc++);

    apply_and(state, operand);
}

void imm_ora_t1(CpuState *state) {
    uint8_t operand = bus_read(state->bus, state->register_pc++);

    apply_ora(state, operand);
}

void imm_eor_t1(CpuState *state) {
    uint8_t operand = bus_read(state->bus, state->register_pc++);

    apply_eor(state, operand);
}

void imm_cmp_t1(CpuState *state) {
    uint8_t operand = bus_read(state->bus, state->register_pc++);

    apply_cmp(state, state->register_a, operand);
}

void imm_cpx_t1(CpuState *state) {
    uint8_t operand = bus_read(state->bus, state->register_pc++);

    apply_cmp(state, state->register_x, operand);
}

void imm_cpy_t1(CpuState *state) {
    uint8_t operand = bus_read(state->bus, state->register_pc++);

    apply_cmp(state, state->register_y, operand);
}

void imm_lda_t1(CpuState *state) {
    uint8_t operand = bus_read(state->bus, state->register_pc++);

    apply_nz(state, state->register_a = operand);
}

void imm_ldx_t1(CpuState *state) {
    uint8_t operand = bus_read(state->bus, state->register_pc++);

    apply_nz(state, state->register_x = operand);
}

void imm_ldy_t1(CpuState *state) {
    uint8_t operand = bus_read(state->bus, state->register_pc++);

    apply_nz(state, state->register_y = operand);
}
