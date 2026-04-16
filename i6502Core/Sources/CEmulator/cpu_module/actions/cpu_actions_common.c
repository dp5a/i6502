#include "cpu_actions.h"
#include "cpu_actions_utils.h"
#include "cpu_module.h"
#include "bus_module.h"

#include <stdint.h>

uint8_t fetch_t0(CpuState *state) {
    return bus_read(state->bus, state->register_pc++);
}

/* MARK: - read actions */

void com_lda(CpuState *state) {
    state->page_crossed = false;
    state->register_a = bus_read(state->bus, state->address_latch);
    apply_nz(state, state->register_a);
}

void com_ldx(CpuState *state) {
    state->page_crossed = false;
    state->register_x = bus_read(state->bus, state->address_latch);
    apply_nz(state, state->register_x);
}

void com_ldy(CpuState *state) {
    state->page_crossed = false;
    state->register_y = bus_read(state->bus, state->address_latch);
    apply_nz(state, state->register_y);
}

void com_adc(CpuState *state) {
    uint8_t operand = bus_read(state->bus, state->address_latch);

    state->page_crossed = false;
    apply_adc(state, operand);
}

void com_sbc(CpuState *state) {
    uint8_t operand = bus_read(state->bus, state->address_latch);

    state->page_crossed = false;
    apply_sbc(state, operand);
}

void com_and(CpuState *state) {
    uint8_t operand = bus_read(state->bus, state->address_latch);

    state->page_crossed = false;
    apply_and(state, operand);
}

void com_ora(CpuState *state) {
    uint8_t operand = bus_read(state->bus, state->address_latch);

    state->page_crossed = false;
    apply_ora(state, operand);
}

void com_eor(CpuState *state) {
    uint8_t operand = bus_read(state->bus, state->address_latch);

    state->page_crossed = false;
    apply_eor(state, operand);
}

void com_bit(CpuState *state) {
    uint8_t operand = bus_read(state->bus, state->address_latch);

    state->page_crossed = false;
    apply_bit(state, operand);
}

void com_cmp(CpuState *state) {
    uint8_t operand = bus_read(state->bus, state->address_latch);

    state->page_crossed = false;
    apply_cmp(state, state->register_a, operand);
}

void com_cpx(CpuState *state) {
    uint8_t operand = bus_read(state->bus, state->address_latch);

    state->page_crossed = false;
    apply_cmp(state, state->register_x, operand);
}

void com_cpy(CpuState *state) {
    uint8_t operand = bus_read(state->bus, state->address_latch);

    state->page_crossed = false;
    apply_cmp(state, state->register_y, operand);
}

/* MARK: - write actions */

void com_sta(CpuState *state) {
    state->page_crossed = false;
    bus_write(state->bus, state->address_latch, state->register_a);
}

void com_stx(CpuState *state) {
    state->page_crossed = false;
    bus_write(state->bus, state->address_latch, state->register_x);
}

void com_sty(CpuState *state) {
    state->page_crossed = false;
    bus_write(state->bus, state->address_latch, state->register_y);
}

/* MARK: - read+modify+write actions */

void com_asl(CpuState *state) {
    state->page_crossed = false;
    bus_write(state->bus, state->address_latch, state->data_latch);

    state->data_latch = apply_asl(state, state->data_latch);
}

void com_lsr(CpuState *state) {
    state->page_crossed = false;
    bus_write(state->bus, state->address_latch, state->data_latch);

    state->data_latch = apply_lsr(state, state->data_latch);
}

void com_rol(CpuState *state) {
    state->page_crossed = false;
    bus_write(state->bus, state->address_latch, state->data_latch);

    state->data_latch = apply_rol(state, state->data_latch);
}

void com_ror(CpuState *state) {
    state->page_crossed = false;
    bus_write(state->bus, state->address_latch, state->data_latch);

    state->data_latch = apply_ror(state, state->data_latch);
}

void com_inc(CpuState *state) {
    state->page_crossed = false;
    bus_write(state->bus, state->address_latch, state->data_latch);

    apply_nz(state, ++state->data_latch);
}

void com_dec(CpuState *state) {
    state->page_crossed = false;
    bus_write(state->bus, state->address_latch, state->data_latch);

    apply_nz(state, --state->data_latch);
}

void com_rmw_0(CpuState *state) {
    state->data_latch = bus_read(state->bus, state->address_latch);
}

void com_rmw_1(CpuState *state) {
    bus_write(state->bus, state->address_latch, state->data_latch);
}
