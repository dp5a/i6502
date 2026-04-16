#include "cpu_actions.h"
#include "cpu_actions_utils.h"
#include "cpu_module.h"
#include "bus_module.h"

#include <stdint.h>
#include <stdbool.h>

void rel_bpl_t1(CpuState *state) {
    uint8_t offset = bus_read(state->bus, state->register_pc++);

    if (state->register_ps & N_MASK) {
        state->page_crossed = false;
    } else {
        state->page_crossed = true;
        state->data_latch = offset;
    }
}

void rel_bmi_t1(CpuState *state) {
    uint8_t offset = bus_read(state->bus, state->register_pc++);

    if (state->register_ps & N_MASK) {
        state->page_crossed = true;
        state->data_latch = offset;
    } else {
        state->page_crossed = false;
    }
}

void rel_bvc_t1(CpuState *state) {
    uint8_t offset = bus_read(state->bus, state->register_pc++);

    if (state->register_ps & V_MASK) {
        state->page_crossed = false;
    } else {
        state->page_crossed = true;
        state->data_latch = offset;
    }
}

void rel_bvs_t1(CpuState *state) {
    uint8_t offset = bus_read(state->bus, state->register_pc++);

    if (state->register_ps & V_MASK) {
        state->page_crossed = true;
        state->data_latch = offset;
    } else {
        state->page_crossed = false;
    }
}

void rel_bcc_t1(CpuState *state) {
    uint8_t offset = bus_read(state->bus, state->register_pc++);

    if (state->register_ps & C_MASK) {
        state->page_crossed = false;
    } else {
        state->page_crossed = true;
        state->data_latch = offset;
    }
}

void rel_bcs_t1(CpuState *state) {
    uint8_t offset = bus_read(state->bus, state->register_pc++);

    if (state->register_ps & C_MASK) {
        state->page_crossed = true;
        state->data_latch = offset;
    } else {
        state->page_crossed = false;
    }
}

void rel_bne_t1(CpuState *state) {
    uint8_t offset = bus_read(state->bus, state->register_pc++);

    if (state->register_ps & Z_MASK) {
        state->page_crossed = false;
    } else {
        state->page_crossed = true;
        state->data_latch = offset;
    }
}

void rel_beq_t1(CpuState *state) {
    uint8_t offset = bus_read(state->bus, state->register_pc++);

    if (state->register_ps & Z_MASK) {
        state->page_crossed = true;
        state->data_latch = offset;
    } else {
        state->page_crossed = false;
    }
}

void rel_t2(CpuState *state) {
    (void)bus_read(state->bus, state->register_pc);

    uint16_t old_pc = state->register_pc;
    int8_t offset = (int8_t)state->data_latch;

    uint16_t new_pc = old_pc + offset;

    if ((old_pc & 0xFF00) == (new_pc & 0xFF00)) {
        state->register_pc = new_pc;
        state->page_crossed = false;
    } else {
        state->register_pc = (old_pc & 0xFF00) | (new_pc & 0x00FF);
        state->page_crossed = true;
    }
}

void rel_t3(CpuState *state) {
    (void)bus_read(state->bus, state->register_pc);

    int8_t offset = (int8_t)state->data_latch;

    if (offset > 0) state->register_pc += 0x100;
    else state->register_pc -= 0x100;
    state->page_crossed = false;
}
