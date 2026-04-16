#include "cpu_actions.h"
#include "cpu_actions_utils.h"
#include "cpu_module.h"
#include "bus_module.h"

#include <stdint.h>

void ind_jmp_t1(CpuState *state) {
    uint8_t low = bus_read(state->bus, state->register_pc++);

    state->address_latch = (state->address_latch & 0xFF00) | low;
}

void ind_jmp_t2(CpuState *state) {
    uint16_t high = bus_read(state->bus, state->register_pc++);

    state->address_latch = (state->address_latch & 0x00FF) | high << 8;
}

void ind_t3(CpuState *state) {
    uint8_t low = bus_read(state->bus, state->address_latch);

    state->data_latch = low;
}

void ind_jmp_t4(CpuState *state) {
    uint16_t adl = ((state->address_latch & 0x00FF) + 1) & UINT8_MAX;
    uint16_t adh = state->address_latch & 0xFF00;
    uint16_t pc_high = bus_read(state->bus, adl + adh);

    state->register_pc = state->data_latch | pc_high << 8;
}

void inx_t4(CpuState *state) {
    uint16_t adh = bus_read(state->bus, (state->address_latch + 1) & 0x00FF);

    state->address_latch = state->data_latch | adh << 8;
}

void iny_t2(CpuState *state) {
    uint8_t pcl = bus_read(state->bus, state->address_latch & 0xFF);

    state->data_latch = pcl;
}

void iny_t3(CpuState *state) {
    uint16_t pcl = state->data_latch;
    uint16_t pch = bus_read(state->bus, (state->address_latch + 1) & 0xFF);
    uint16_t pcly = pcl + state->register_y;

    state->address_latch = (pch << 8) | (pcly & 0xFF);
    if (pcly >= 0x100) {
        state->page_crossed = true;
    }
}

void iny_adc_t4(CpuState *state) {
    uint8_t operand = bus_read(state->bus, state->address_latch);

    if (state->page_crossed) {
        apply_adc(state, operand);
        state->page_crossed = false;
    } else {
        state->address_latch += 0x100;
        state->page_crossed = true;
    }
}

void iny_and_t4(CpuState *state) {
    uint8_t operand = bus_read(state->bus, state->address_latch);

    if (state->page_crossed) {
        apply_and(state, operand);
        state->page_crossed = false;
    } else {
        state->address_latch += 0x100;
        state->page_crossed = true;
    }
}

void iny_cmp_t4(CpuState *state) {
    uint8_t operand = bus_read(state->bus, state->address_latch);

    if (state->page_crossed) {
        apply_cmp(state, state->register_a, operand);
        state->page_crossed = false;
    } else {
        state->address_latch += 0x100;
        state->page_crossed = true;
    }
}

void iny_eor_t4(CpuState *state) {
    uint8_t operand = bus_read(state->bus, state->address_latch);

    if (state->page_crossed) {
        apply_eor(state, operand);
        state->page_crossed = false;
    } else {
        state->address_latch += 0x100;
        state->page_crossed = true;
    }
}

void iny_lda_t4(CpuState *state) {
    uint8_t operand = bus_read(state->bus, state->address_latch);

    if (state->page_crossed) {
        state->register_a = operand;
        state->page_crossed = false;
        apply_nz(state, operand);
    } else {
        state->address_latch += 0x100;
        state->page_crossed = true;
    }
}

void iny_ora_t4(CpuState *state) {
    uint8_t operand = bus_read(state->bus, state->address_latch);

    if (state->page_crossed) {
        apply_ora(state, operand);
        state->page_crossed = false;
    } else {
        state->address_latch += 0x100;
        state->page_crossed = true;
    }
}

void iny_sbc_t4(CpuState *state) {
    uint8_t operand = bus_read(state->bus, state->address_latch);

    if (state->page_crossed) {
        apply_sbc(state, operand);
        state->page_crossed = false;
    } else {
        state->address_latch += 0x100;
        state->page_crossed = true;
    }
}

void iny_sta_t4(CpuState *state) {
    (void)bus_read(state->bus, state->address_latch);

    uint16_t adl = state->data_latch;
    uint16_t adly = adl + state->register_y;

    if (adly >= 0x100) {
        state->address_latch += 0x100;
    }
}

void iny_sta_t5(CpuState *state) {
    bus_write(state->bus, state->address_latch, state->register_a);
}
