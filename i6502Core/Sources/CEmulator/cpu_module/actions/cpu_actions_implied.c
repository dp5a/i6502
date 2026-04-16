#include "cpu_actions.h"
#include "cpu_actions_utils.h"
#include "cpu_module.h"
#include "bus_module.h"

#include <stdint.h>

/* MARK: - brk actions */

void imp_brk_t1(CpuState *state) {
    (void)bus_read(state->bus, state->register_pc++);
}

void imp_brk_t2(CpuState *state) {
    uint8_t pch = (state->register_pc & 0xFF00) >> 8;

    bus_write(state->bus, 0x100 + state->register_sp--, pch);
}

void imp_brk_t3(CpuState *state) {
    uint8_t pcl = state->register_pc & 0x00FF;

    bus_write(state->bus, 0x100 + state->register_sp--, pcl);
}

void imp_brk_t4(CpuState *state) {
    uint8_t ps = state->register_ps | B_MASK | S_MASK;

    bus_write(state->bus, 0x100 + state->register_sp--, ps);
}

void imp_brk_t5(CpuState *state) {
    uint8_t low = bus_read(state->bus, 0xFFFE);

    state->register_pc = (state->register_pc & 0xFF00) | low;
}

void imp_brk_t6(CpuState *state) {
    uint16_t high = (uint16_t)bus_read(state->bus, 0xFFFF) << 8;

    state->register_pc = high | (state->register_pc & 0x00FF);
    state->register_ps |= I_MASK;
}

/* MARK: - flag actions */

void imp_clc_t1(CpuState *state) {
    (void)bus_read(state->bus, state->register_pc);
    state->register_ps &= ~C_MASK;
}

void imp_cli_t1(CpuState *state) {
    (void)bus_read(state->bus, state->register_pc);
    state->register_ps &= ~I_MASK;
}

void imp_clv_t1(CpuState *state) {
    (void)bus_read(state->bus, state->register_pc);
    state->register_ps &= ~V_MASK;
}

void imp_cld_t1(CpuState *state) {
    (void)bus_read(state->bus, state->register_pc);
    state->register_ps &= ~D_MASK;
}

void imp_sec_t1(CpuState *state) {
    (void)bus_read(state->bus, state->register_pc);
    state->register_ps |= C_MASK;
}

void imp_sei_t1(CpuState *state) {
    (void)bus_read(state->bus, state->register_pc);
    state->register_ps |= I_MASK;
}

void imp_sed_t1(CpuState *state) {
    (void)bus_read(state->bus, state->register_pc);
    state->register_ps |= D_MASK;
}

/* MARK: - nop actions */

void imp_nop_t1(CpuState *state) {
    (void)bus_read(state->bus, state->register_pc);
}

/* MARK: - transfer actions */

void imp_tax_t1(CpuState *state) {
    (void)bus_read(state->bus, state->register_pc);
    apply_nz(state, state->register_x = state->register_a);
}

void imp_tay_t1(CpuState *state) {
    (void)bus_read(state->bus, state->register_pc);
    apply_nz(state, state->register_y = state->register_a);
}

void imp_txa_t1(CpuState *state) {
    (void)bus_read(state->bus, state->register_pc);
    apply_nz(state, state->register_a = state->register_x);
}

void imp_tya_t1(CpuState *state) {
    (void)bus_read(state->bus, state->register_pc);
    apply_nz(state, state->register_a = state->register_y);
}

/* MARK: - incr / decr actions */

void imp_inx_t1(CpuState *state) {
    (void)bus_read(state->bus, state->register_pc);
    apply_nz(state, ++state->register_x);
}

void imp_iny_t1(CpuState *state) {
    (void)bus_read(state->bus, state->register_pc);
    apply_nz(state, ++state->register_y);
}

void imp_dex_t1(CpuState *state) {
    (void)bus_read(state->bus, state->register_pc);
    apply_nz(state, --state->register_x);
}

void imp_dey_t1(CpuState *state) {
    (void)bus_read(state->bus, state->register_pc);
    apply_nz(state, --state->register_y);
}

/* MARK: - rti actions */

void imp_rti_t1(CpuState *state) {
    (void)bus_read(state->bus, state->register_pc);
}

void imp_rti_t2(CpuState *state) {
    (void)bus_read(state->bus, 0x100 + state->register_sp++);
}

void imp_rti_t3(CpuState *state) {
    state->register_ps = (bus_read(state->bus, 0x100 + state->register_sp++) & ~B_MASK) | S_MASK;
}

void imp_rti_t4(CpuState *state) {
    uint8_t pcl = bus_read(state->bus, 0x100 + state->register_sp++);

    state->register_pc = (state->register_pc & 0xFF00) | pcl;
}

void imp_rti_t5(CpuState *state) {
    uint8_t pch = bus_read(state->bus, 0x100 + state->register_sp);

    state->register_pc = (state->register_pc & 0x00FF) | (uint16_t)pch << 8;
}

/* MARK: - rts actions */

void imp_rts_t1(CpuState *state) {
    (void)bus_read(state->bus, state->register_pc);
}

void imp_rts_t2(CpuState *state) {
    (void)bus_read(state->bus, 0x100 + state->register_sp++);
}

void imp_rts_t3(CpuState *state) {
    uint8_t pcl = bus_read(state->bus, 0x100 + state->register_sp++);

    state->register_pc = (state->register_pc & 0xFF00) | pcl;
}

void imp_rts_t4(CpuState *state) {
    uint8_t pch = bus_read(state->bus, 0x100 + state->register_sp);

    state->register_pc = (state->register_pc & 0x00FF) | (uint16_t)pch << 8;
}

void imp_rts_t5(CpuState *state) {
    (void)bus_read(state->bus, state->register_pc++);
}

/* MARK: - stack actions */

void imp_txs_t1(CpuState *state) {
    (void)bus_read(state->bus, state->register_pc);
    state->register_sp = state->register_x;
}

void imp_tsx_t1(CpuState *state) {
    (void)bus_read(state->bus, state->register_pc);
    apply_nz(state, state->register_x = state->register_sp);
}

void imp_pha_t1(CpuState *state) {
    (void)bus_read(state->bus, state->register_pc);
}

void imp_pha_t2(CpuState *state) {
    bus_write(state->bus, 0x100 + state->register_sp--, state->register_a);
}

void imp_php_t1(CpuState *state) {
    (void)bus_read(state->bus, state->register_pc);
}

void imp_php_t2(CpuState *state) {
    bus_write(state->bus, 0x100 + state->register_sp--, state->register_ps | B_MASK | S_MASK);
}

void imp_pla_t1(CpuState *state) {
    (void)bus_read(state->bus, state->register_pc);
}

void imp_pla_t2(CpuState *state) {
    (void)bus_read(state->bus, 0x100 + state->register_sp++);
}

void imp_pla_t3(CpuState *state) {
    state->register_a = bus_read(state->bus, 0x100 + state->register_sp);
    apply_nz(state, state->register_a);
}

void imp_plp_t1(CpuState *state) {
    (void)bus_read(state->bus, state->register_pc);
}

void imp_plp_t2(CpuState *state) {
    (void)bus_read(state->bus, 0x100 + state->register_sp++);
}

void imp_plp_t3(CpuState *state) {
    state->register_ps = (bus_read(state->bus, 0x100 + state->register_sp) & ~B_MASK) | S_MASK;
}
