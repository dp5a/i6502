#include "cpu_actions.h"
#include "cpu_actions_utils.h"
#include "cpu_module.h"
#include "bus_module.h"

#include <stdint.h>
#include <stdbool.h>

void abs_t1(CpuState *state) {
    uint8_t adl = bus_read(state->bus, state->register_pc++);

    state->address_latch = (state->address_latch & 0xFF00) | adl;
}

void abs_t2(CpuState *state) {
    uint16_t adh = bus_read(state->bus, state->register_pc++);

    state->address_latch = (state->address_latch & 0x00FF) | adh << 8;
}

void abs_jmp_t2(CpuState *state) {
    uint16_t pch = bus_read(state->bus, state->register_pc);

    state->register_pc = (state->address_latch & 0x00FF) | pch << 8;
}

void abs_jsr_t2(CpuState *state) {
    (void)bus_read(state->bus, 0x100 + state->register_sp);
}

void abs_jsr_t3(CpuState *state) {
    uint8_t pch = (state->register_pc & 0xFF00) >> 8;

    bus_write(state->bus, 0x100 + state->register_sp--, pch);
}

void abs_jsr_t4(CpuState *state) {
    uint8_t pcl = state->register_pc & 0x00FF;

    bus_write(state->bus, 0x100 + state->register_sp--, pcl);
}

void abs_jsr_t5(CpuState *state) {
    uint16_t adh = bus_read(state->bus, state->register_pc);

    state->register_pc = (state->address_latch & 0xFF) | adh << 8;
}

void abx_rmw_t3(CpuState *state) {
    uint16_t adl = state->address_latch & 0xFF;
    uint16_t adlx = adl + state->register_x;

    state->address_latch = (state->address_latch & 0xFF00) | (adlx & 0xFF);

    (void)bus_read(state->bus, state->address_latch);

    if (adlx >= 0x100) {
        state->address_latch += 0x100;
    }
}

void aby_rmw_t3(CpuState *state) {
    uint16_t adl = state->address_latch & 0xFF;
    uint16_t adly = adl + state->register_y;

    state->address_latch = (state->address_latch & 0xFF00) | (adly & 0xFF);

    (void)bus_read(state->bus, state->address_latch);

    if (adly >= 0x100) {
        state->address_latch += 0x100;
    }
}

/* MARK: - absolute,x/y adc */

void abx_adc_t3(CpuState *state) {
    uint16_t adl = state->address_latch & 0xFF;
    uint16_t adlx = state->address_latch + state->register_x;

    state->address_latch = (state->address_latch & 0xFF00) | (adlx & 0xFF);

    uint8_t operand = bus_read(state->bus, state->address_latch);

    if (adlx >= 0x100) {
        state->address_latch += 0x100;
        state->page_crossed = true;
    } else {
        state->page_crossed = false;
        apply_adc(state, operand);
    }
}

void aby_adc_t3(CpuState *state) {
    uint16_t adl = state->address_latch & 0xFF;
    uint16_t adly = state->address_latch + state->register_y;

    state->address_latch = (state->address_latch & 0xFF00) | (adly & 0xFF);

    uint8_t operand = bus_read(state->bus, state->address_latch);

    if (adly >= 0x100) {
        state->address_latch += 0x100;
        state->page_crossed = true;
    } else {
        state->page_crossed = false;
        apply_adc(state, operand);
    }
}

/* MARK: - absolute,x/y and */

void abx_and_t3(CpuState *state) {
    uint16_t adl = state->address_latch & 0xFF;
    uint16_t adlx = state->address_latch + state->register_x;

    state->address_latch = (state->address_latch & 0xFF00) | (adlx & 0xFF);

    uint8_t operand = bus_read(state->bus, state->address_latch);

    if (adlx >= 0x100) {
        state->address_latch += 0x100;
        state->page_crossed = true;
    } else {
        state->page_crossed = false;
        apply_and(state, operand);
    }
}

void aby_and_t3(CpuState *state) {
    uint16_t adl = state->address_latch & 0xFF;
    uint16_t adly = state->address_latch + state->register_y;

    state->address_latch = (state->address_latch & 0xFF00) | (adly & 0xFF);

    uint8_t operand = bus_read(state->bus, state->address_latch);

    if (adly >= 0x100) {
        state->address_latch += 0x100;
        state->page_crossed = true;
    } else {
        state->page_crossed = false;
        apply_and(state, operand);
    }
}

/* MARK: - absolute,x/y cmp */

void abx_cmp_t3(CpuState *state) {
    uint16_t adl = state->address_latch & 0xFF;
    uint16_t adlx = state->address_latch + state->register_x;

    state->address_latch = (state->address_latch & 0xFF00) | (adlx & 0xFF);

    uint8_t operand = bus_read(state->bus, state->address_latch);

    if (adlx >= 0x100) {
        state->address_latch += 0x100;
        state->page_crossed = true;
    } else {
        state->page_crossed = false;
        apply_cmp(state, state->register_a, operand);
    }
}

void aby_cmp_t3(CpuState *state) {
    uint16_t adl = state->address_latch & 0xFF;
    uint16_t adly = state->address_latch + state->register_y;

    state->address_latch = (state->address_latch & 0xFF00) | (adly & 0xFF);

    uint8_t operand = bus_read(state->bus, state->address_latch);

    if (adly >= 0x100) {
        state->address_latch += 0x100;
        state->page_crossed = true;
    } else {
        state->page_crossed = false;
        apply_cmp(state, state->register_a, operand);
    }
}
/* MARK: - absolute,x/y eor */

void abx_eor_t3(CpuState *state) {
    uint16_t adl = state->address_latch & 0xFF;
    uint16_t adlx = state->address_latch + state->register_x;

    state->address_latch = (state->address_latch & 0xFF00) | (adlx & 0xFF);

    uint8_t operand = bus_read(state->bus, state->address_latch);

    if (adlx >= 0x100) {
        state->address_latch += 0x100;
        state->page_crossed = true;
    } else {
        state->page_crossed = false;
        apply_eor(state, operand);
    }
}

void aby_eor_t3(CpuState *state) {
    uint16_t adl = state->address_latch & 0xFF;
    uint16_t adly = state->address_latch + state->register_y;

    state->address_latch = (state->address_latch & 0xFF00) | (adly & 0xFF);

    uint8_t operand = bus_read(state->bus, state->address_latch);

    if (adly >= 0x100) {
        state->address_latch += 0x100;
        state->page_crossed = true;
    } else {
        state->page_crossed = false;
        apply_eor(state, operand);
    }
}

/* MARK: - absolute,x/y lda */

void abx_lda_t3(CpuState *state) {
    uint16_t adl = state->address_latch & 0xFF;
    uint16_t adlx = state->address_latch + state->register_x;

    state->address_latch = (state->address_latch & 0xFF00) | (adlx & 0xFF);

    uint8_t operand = bus_read(state->bus, state->address_latch);

    if (adlx >= 0x100) {
        state->address_latch += 0x100;
        state->page_crossed = true;
    } else {
        state->page_crossed = false;
        state->register_a = operand;
        apply_nz(state, operand);
    }
}

void aby_lda_t3(CpuState *state) {
    uint16_t adl = state->address_latch & 0xFF;
    uint16_t adly = state->address_latch + state->register_y;

    state->address_latch = (state->address_latch & 0xFF00) | (adly & 0xFF);

    uint8_t operand = bus_read(state->bus, state->address_latch);

    if (adly >= 0x100) {
        state->address_latch += 0x100;
        state->page_crossed = true;
    } else {
        state->page_crossed = false;
        state->register_a = operand;
        apply_nz(state, operand);
    }
}

/* MARK: - absolute,x ldy */

void abx_ldy_t3(CpuState *state) {
    uint16_t adl = state->address_latch & 0xFF;
    uint16_t adlx = state->address_latch + state->register_x;

    state->address_latch = (state->address_latch & 0xFF00) | (adlx & 0xFF);

    uint8_t operand = bus_read(state->bus, state->address_latch);

    if (adlx >= 0x100) {
        state->address_latch += 0x100;
        state->page_crossed = true;
    } else {
        state->page_crossed = false;
        state->register_y = operand;
        apply_nz(state, operand);
    }
}

void aby_ldx_t3(CpuState *state) {
    uint16_t adl = state->address_latch & 0xFF;
    uint16_t adly = state->address_latch + state->register_y;

    state->address_latch = (state->address_latch & 0xFF00) | (adly & 0xFF);

    uint8_t operand = bus_read(state->bus, state->address_latch);

    if (adly >= 0x100) {
        state->address_latch += 0x100;
        state->page_crossed = true;
    } else {
        state->page_crossed = false;
        state->register_x = operand;
        apply_nz(state, operand);
    }
}

/* MARK: - absolute,x/y ora */

void abx_ora_t3(CpuState *state) {
    uint16_t adl = state->address_latch & 0xFF;
    uint16_t adlx = state->address_latch + state->register_x;

    state->address_latch = (state->address_latch & 0xFF00) | (adlx & 0xFF);

    uint8_t operand = bus_read(state->bus, state->address_latch);

    if (adlx >= 0x100) {
        state->address_latch += 0x100;
        state->page_crossed = true;
    } else {
        state->page_crossed = false;
        apply_ora(state, operand);
    }
}

void aby_ora_t3(CpuState *state) {
    uint16_t adl = state->address_latch & 0xFF;
    uint16_t adly = state->address_latch + state->register_y;

    state->address_latch = (state->address_latch & 0xFF00) | (adly & 0xFF);

    uint8_t operand = bus_read(state->bus, state->address_latch);

    if (adly >= 0x100) {
        state->address_latch += 0x100;
        state->page_crossed = true;
    } else {
        state->page_crossed = false;
        apply_ora(state, operand);
    }
}
/* MARK: - absolute,x/y sbc */

void abx_sbc_t3(CpuState *state) {
    uint16_t adl = state->address_latch & 0xFF;
    uint16_t adlx = state->address_latch + state->register_x;

    state->address_latch = (state->address_latch & 0xFF00) | (adlx & 0xFF);

    uint8_t operand = bus_read(state->bus, state->address_latch);

    if (adlx >= 0x100) {
        state->address_latch += 0x100;
        state->page_crossed = true;
    } else {
        state->page_crossed = false;
        apply_sbc(state, operand);
    }
}

void aby_sbc_t3(CpuState *state) {
    uint16_t adl = state->address_latch & 0xFF;
    uint16_t adly = state->address_latch + state->register_y;

    state->address_latch = (state->address_latch & 0xFF00) | (adly & 0xFF);

    uint8_t operand = bus_read(state->bus, state->address_latch);

    if (adly >= 0x100) {
        state->address_latch += 0x100;
        state->page_crossed = true;
    } else {
        state->page_crossed = false;
        apply_sbc(state, operand);
    }
}
