#ifndef __cpu_actions_utils_h_
#define __cpu_actions_utils_h_

#include "cpu_module.h"

#include <stdint.h>

/* MARK: - PS register masks */
#define N_MASK 0b10000000 /* Negative flag */
#define V_MASK 0b01000000 /* Overflow flag */
#define S_MASK 0b00100000 /* Skip (unused) flag */
#define B_MASK 0b00010000 /* Break pseudo-flag */
#define D_MASK 0b00001000 /* Decimal mode flag */
#define I_MASK 0b00000100 /* Interrupt disabled flag */
#define Z_MASK 0b00000010 /* Zero flag */
#define C_MASK 0b00000001 /* Carry flag */

/* MARK: - Common functions */
static inline __attribute__((always_inline))
void apply_nz(CpuState *state, uint8_t value) {
    state->register_ps = (state->register_ps & ~(N_MASK | Z_MASK))
        | (value & N_MASK)
        | (value == 0 ? Z_MASK : 0);
}

static inline __attribute__((always_inline))
void apply_adc(CpuState *state, uint8_t operand) {
    uint8_t carry = state->register_ps & C_MASK;
    uint16_t sum = (uint16_t)state->register_a + operand + carry;
    uint8_t overflow = (state->register_a ^ sum) & (operand ^ sum) & N_MASK;

    state->register_a = (uint8_t)sum;

    state->register_ps = (state->register_ps & ~(N_MASK | V_MASK | Z_MASK | C_MASK))
        | (state->register_a & N_MASK)
        | (overflow ? V_MASK : 0)
        | ((state->register_a == 0) ? Z_MASK : 0)
        | ((sum >> 8) & C_MASK);
}

static inline __attribute__((always_inline))
void apply_sbc(CpuState *state, uint8_t operand) {
    apply_adc(state, ~operand);
}

static inline __attribute__((always_inline))
void apply_and(CpuState *state, uint8_t operand) {
    apply_nz(state, state->register_a &= operand);
}

static inline __attribute__((always_inline))
void apply_ora(CpuState *state, uint8_t operand) {
    apply_nz(state, state->register_a |= operand);
}

static inline __attribute__((always_inline))
void apply_eor(CpuState *state, uint8_t operand) {
    apply_nz(state, state->register_a ^= operand);
}

static inline __attribute__((always_inline))
uint8_t apply_asl(CpuState *state, uint8_t operand) {
    uint8_t prev_value = operand;

    operand <<= 1;
    state->register_ps = (state->register_ps & ~C_MASK) | (prev_value & 0b10000000 ? C_MASK : 0);
    apply_nz(state, operand);
    return operand;
}

static inline __attribute__((always_inline))
uint8_t apply_lsr(CpuState *state, uint8_t operand) {
    uint8_t prev_value = operand;

    operand >>= 1;
    state->register_ps = (state->register_ps & ~C_MASK) | (prev_value & C_MASK);
    apply_nz(state, operand);
    return operand;
}

static inline __attribute__((always_inline))
uint8_t apply_rol(CpuState *state, uint8_t operand) {
    uint8_t prev_value = operand;

    // carry shifts into pos 0, pos 7 shift to carry
    operand = (operand << 1) | (state->register_ps & C_MASK);
    state->register_ps = (state->register_ps & ~C_MASK) | (prev_value & 0b10000000 ? C_MASK : 0);
    apply_nz(state, operand);
    return operand;
}

static inline __attribute__((always_inline))
uint8_t apply_ror(CpuState *state, uint8_t operand) {
    uint8_t prev_value = operand;

    // carry shifts into pos 7, pos 0 shift to carry
    operand = (operand >> 1) | (state->register_ps & C_MASK ? 0b10000000 : 0);
    state->register_ps = (state->register_ps & ~C_MASK) | (prev_value & C_MASK);
    apply_nz(state, operand);
    return operand;
}

static inline __attribute__((always_inline))
void apply_cmp(CpuState *state, uint8_t lhs, uint8_t rhs) {
    uint16_t result = (uint16_t)lhs - rhs;

    state->register_ps = (state->register_ps & ~(N_MASK | Z_MASK | C_MASK))
        | ((uint8_t)result & N_MASK)
        | ((uint8_t)result == 0 ? Z_MASK : 0)
        | (lhs >= rhs ? C_MASK : 0);
}

static inline __attribute__((always_inline))
void apply_bit(CpuState *state, uint8_t value) {
    state->register_ps = (state->register_ps & ~(N_MASK | Z_MASK | V_MASK))
        | (value & N_MASK)
        | ((state->register_a & value) == 0 ? Z_MASK : 0)
        | (value & V_MASK);
}

#endif /* __cpu_actions_utils_h_ */
