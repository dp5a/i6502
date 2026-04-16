#include "cpu_actions.h"
#include "cpu_actions_utils.h"
#include "cpu_module.h"
#include "bus_module.h"

#include <stdint.h>

void zp_t1(CpuState *state) {
    state->address_latch = bus_read(state->bus, state->register_pc++);
}

/* MARK: - read load actions */

void zp_lda_t2(CpuState *state) {
    state->register_a = bus_read(state->bus, state->address_latch);
    apply_nz(state, state->register_a);
}

void zp_ldx_t2(CpuState *state) {
    state->register_x = bus_read(state->bus, state->address_latch);
    apply_nz(state, state->register_x);
}

void zp_ldy_t2(CpuState *state) {
    state->register_y = bus_read(state->bus, state->address_latch);
    apply_nz(state, state->register_y);
}

/* MARK: - read logic/arithmetic actions */

void zp_adc_t2(CpuState *state) {
    uint8_t operand = bus_read(state->bus, state->address_latch);

    apply_adc(state, operand);
}

void zp_sbc_t2(CpuState *state) {
    uint8_t operand = bus_read(state->bus, state->address_latch);

    apply_sbc(state, operand);
}

void zp_and_t2(CpuState *state) {
    uint8_t operand = bus_read(state->bus, state->address_latch);

    apply_and(state, operand);
}

void zp_ora_t2(CpuState *state) {
    uint8_t operand = bus_read(state->bus, state->address_latch);

    apply_ora(state, operand);
}

void zp_eor_t2(CpuState *state) {
    uint8_t operand = bus_read(state->bus, state->address_latch);

    apply_eor(state, operand);
}

void zp_bit_t2(CpuState *state) {
    uint8_t operand = bus_read(state->bus, state->address_latch);

    apply_bit(state, operand);
}

/* MARK: - read compare actions */

void zp_cmp_t2(CpuState *state) {
    uint8_t operand = bus_read(state->bus, state->address_latch);

    apply_cmp(state, state->register_a, operand);
}

void zp_cpx_t2(CpuState *state) {
    uint8_t operand = bus_read(state->bus, state->address_latch);

    apply_cmp(state, state->register_x, operand);
}

void zp_cpy_t2(CpuState *state) {
    uint8_t operand = bus_read(state->bus, state->address_latch);

    apply_cmp(state, state->register_y, operand);
}

/* MARK: - write actions */

void zp_sta_t2(CpuState *state) {
    bus_write(state->bus, state->address_latch, state->register_a);
}

void zp_stx_t2(CpuState *state) {
    bus_write(state->bus, state->address_latch, state->register_x);
}

void zp_sty_t2(CpuState *state) {
    bus_write(state->bus, state->address_latch, state->register_y);
}

/* MARK: - read+modify+write actions */

void zp_rmw_t2(CpuState *state) {
    state->data_latch = bus_read(state->bus, state->address_latch);
}

void zp_rmw_t4(CpuState *state) {
    bus_write(state->bus, state->address_latch, state->data_latch);
}

void zp_asl_t3(CpuState *state) {
    bus_write(state->bus, state->address_latch, state->data_latch);

    state->data_latch = apply_asl(state, state->data_latch);
}

void zp_lsr_t3(CpuState *state) {
    bus_write(state->bus, state->address_latch, state->data_latch);

    state->data_latch = apply_lsr(state, state->data_latch);
}

void zp_rol_t3(CpuState *state) {
    bus_write(state->bus, state->address_latch, state->data_latch);

    state->data_latch = apply_rol(state, state->data_latch);
}

void zp_ror_t3(CpuState *state) {
    bus_write(state->bus, state->address_latch, state->data_latch);

    state->data_latch = apply_ror(state, state->data_latch);
}

void zp_inc_t3(CpuState *state) {
    bus_write(state->bus, state->address_latch, state->data_latch);

    apply_nz(state, ++state->data_latch);
}

void zp_dec_t3(CpuState *state) {
    bus_write(state->bus, state->address_latch, state->data_latch);

    apply_nz(state, --state->data_latch);
}

