#ifndef __cpu_actions_utils_h_
#define __cpu_actions_utils_h_

#include "cpu_module.h"

#include <stdint.h>

/* PS register masks */
#define N_MASK 0b10000000 /* Negative flag */
#define V_MASK 0b01000000 /* Overflow flag */
#define S_MASK 0b00100000 /* Skip (unused) flag */
#define B_MASK 0b00010000 /* Break pseudo-flag */
#define D_MASK 0b00001000 /* Decimal mode flag */
#define I_MASK 0b00000100 /* Interrupt disabled flag */
#define Z_MASK 0b00000010 /* Zero flag */
#define C_MASK 0b00000001 /* Carry flag */

/* Fetch opcode action */
uint8_t fetch_t0(CpuState *state);

/* Common functions */
void apply_adc(CpuState *state, uint8_t value);
void apply_sbc(CpuState *state, uint8_t value);
void apply_cmp(CpuState *state, uint8_t lhs, uint8_t rhs);
void apply_and(CpuState *state, uint8_t operand);
void apply_ora(CpuState *state, uint8_t operand);
void apply_eor(CpuState *state, uint8_t operand);
void apply_bit(CpuState *state, uint8_t value);

uint8_t apply_asl(CpuState *state, uint8_t operand);
uint8_t apply_lsr(CpuState *state, uint8_t operand);
uint8_t apply_rol(CpuState *state, uint8_t operand);
uint8_t apply_ror(CpuState *state, uint8_t operand);

void apply_nz(CpuState *state, uint8_t value);

#endif /* __cpu_actions_utils_h_ */
