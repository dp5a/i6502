#include "cpu_actions.h"
#include "cpu_actions_utils.h"
#include "cpu_module.h"
#include "bus_module.h"

#include <stdint.h>

/* MARK: - NMI cycles */

void nmi_t0(CpuState *state) {
    (void)bus_read(state->bus, state->register_pc);
}

void nmi_t1(CpuState *state) {
    (void)bus_read(state->bus, state->register_pc + 1);
}

void nmi_t2(CpuState *state) {
    uint8_t pch = (state->register_pc & 0xFF00) >> 8;

    bus_write(state->bus, 0x100 + state->register_sp--, pch);
}

void nmi_t3(CpuState *state) {
    uint8_t pcl = state->register_pc & 0x00FF;

    bus_write(state->bus, 0x100 + state->register_sp--, pcl);
}

void nmi_t4(CpuState *state) {
    uint8_t ps = (state->register_ps & ~B_MASK) | S_MASK;

    bus_write(state->bus, 0x100 + state->register_sp--, ps);
}

void nmi_t5(CpuState *state) {
    uint8_t low = bus_read(state->bus, 0xFFFA);

    state->register_pc = (state->register_pc & 0xFF00) | low;
}

void nmi_t6(CpuState *state) {
    uint16_t high = (uint16_t)bus_read(state->bus, 0xFFFB) << 8;

    state->register_pc = high | (state->register_pc & 0x00FF);
    state->register_ps |= I_MASK;
}

/* MARK: - RESET cycles */

void reset_t0(CpuState *state) {
    (void)bus_read(state->bus, state->register_pc);
}

void reset_t1(CpuState *state) {
    (void)bus_read(state->bus, state->register_pc + 1);
}

void reset_t2(CpuState *state) {
    (void)bus_read(state->bus, 0x100 + state->register_sp);
}

void reset_t3(CpuState *state) {
    (void)bus_read(state->bus, 0x100 + state->register_sp);
}

void reset_t4(CpuState *state) {
    (void)bus_read(state->bus, 0x100 + state->register_sp);
}

void reset_t5(CpuState *state) {
    uint8_t low = bus_read(state->bus, 0xFFFC);

    state->register_pc = (state->register_pc & 0xFF00) | low;
}

void reset_t6(CpuState *state) {
    uint16_t high = (uint16_t)bus_read(state->bus, 0xFFFD) << 8;

    state->register_pc = high | (state->register_pc & 0x00FF);
    state->register_ps |= I_MASK;
}

/* MARK: - IRQ cycles */

void irq_t0(CpuState *state) {
    (void)bus_read(state->bus, state->register_pc);
}

void irq_t1(CpuState *state) {
    (void)bus_read(state->bus, state->register_pc + 1);
}

void irq_t2(CpuState *state) {
    uint8_t pch = (state->register_pc & 0xFF00) >> 8;

    bus_write(state->bus, 0x100 + state->register_sp--, pch);
}

void irq_t3(CpuState *state) {
    uint8_t pcl = state->register_pc & 0x00FF;

    bus_write(state->bus, 0x100 + state->register_sp--, pcl);
}

void irq_t4(CpuState *state) {
    uint8_t ps = (state->register_ps & ~B_MASK) | S_MASK;

    bus_write(state->bus, 0x100 + state->register_sp--, ps);
}

void irq_t5(CpuState *state) {
    uint8_t low = bus_read(state->bus, 0xFFFE);

    state->register_pc = (state->register_pc & 0xFF00) | low;
}

void irq_t6(CpuState *state) {
    uint16_t high = (uint16_t)bus_read(state->bus, 0xFFFF) << 8;

    state->register_pc = high | (state->register_pc & 0x00FF);
    state->register_ps |= I_MASK;
}
