#include "cpu_module.h"
#include "actions/cpu_actions.h"
#include "actions/cpu_actions_utils.h"

#include <stdint.h>
#include <stdlib.h>

/* MARK: - 6502 initializer & deinitializer */

CpuState * cpu_create() {
    CpuState *state = malloc(sizeof(CpuState));
    if (!state) { return NULL; }

    state->register_pc = rand() & UINT16_MAX;
    state->register_sp = rand() & UINT8_MAX;
    state->register_ps = (rand() & UINT8_MAX) | S_MASK;
    state->register_a = rand() & UINT8_MAX;
    state->register_x = rand() & UINT8_MAX;
    state->register_y = rand() & UINT8_MAX;

    state->data_latch = rand() & UINT8_MAX;
    state->address_latch = rand() & UINT16_MAX;
    return state;
}

void cpu_destroy(CpuState *state) {
    free(state);
}

/* MARK: - 6502 actions */

CpuCycles cpu_nmi(CpuState *state) {
    return (CpuCycles){
        .actions = { nmi_t0, nmi_t1, nmi_t2, nmi_t3, nmi_t4, nmi_t5, nmi_t6 },
        .count = 7
    };
}

CpuCycles cpu_reset(CpuState *state) {
    state->register_ps |= I_MASK;
    return (CpuCycles){
        .actions = { reset_t0, reset_t1, reset_t2, reset_t3, reset_t4, reset_t5, reset_t6 },
        .count = 7
    };
}

CpuCycles cpu_irq(CpuState *state) {
    return (CpuCycles){
        .actions = { irq_t0, irq_t1, irq_t2, irq_t3, irq_t4, irq_t5, irq_t6 },
        .count = 7
    };
}

CpuCycles cpu_decode(CpuState *state) {
    uint8_t opcode = fetch_t0(state);

    switch (opcode) {
        /* Immediate mode operations */
        case 0x69: return (CpuCycles){
            .actions = { imm_adc_t1 },
            .count = 1
        };
        case 0xE9: return (CpuCycles){
            .actions = { imm_sbc_t1 },
            .count = 1
        };
        case 0x29: return(CpuCycles){
            .actions = { imm_and_t1 },
            .count = 1
        };
        case 0x09: return(CpuCycles){
            .actions = { imm_ora_t1 },
            .count = 1
        };
        case 0x49: return(CpuCycles){
            .actions = { imm_eor_t1 },
            .count = 1
        };
        case 0xC9: return(CpuCycles){
            .actions = { imm_cmp_t1 },
            .count = 1
        };
        case 0xE0: return(CpuCycles){
            .actions = { imm_cpx_t1 },
            .count = 1
        };
        case 0xC0: return(CpuCycles){
            .actions = { imm_cpy_t1 },
            .count = 1
        };
        case 0xA9: return(CpuCycles){
            .actions = { imm_lda_t1 },
            .count = 1
        };
        case 0xA2: return(CpuCycles){
            .actions = { imm_ldx_t1 },
            .count = 1
        };
        case 0xA0: return(CpuCycles){
            .actions = { imm_ldy_t1 },
            .count = 1
        };
        /* Accumulator mode operations */
        case 0x0A: return(CpuCycles){
            .actions = { acc_asl_t1 },
            .count = 1
        };
        case 0x4A: return(CpuCycles){
            .actions = { acc_lsr_t1 },
            .count = 1
        };
        case 0x2A: return(CpuCycles){
            .actions = { acc_rol_t1 },
            .count = 1
        };
        case 0x6A: return(CpuCycles){
            .actions = { acc_ror_t1 },
            .count = 1
        };
        /* Implied operations */
        case 0x18: return(CpuCycles){
            .actions = { imp_clc_t1 },
            .count = 1
        };
        case 0x38: return(CpuCycles){
            .actions = { imp_sec_t1 },
            .count = 1
        };
        case 0x58: return(CpuCycles){
            .actions = { imp_cli_t1 },
            .count = 1
        };
        case 0x78: return(CpuCycles){
            .actions = { imp_sei_t1 },
            .count = 1
        };
        case 0xB8: return(CpuCycles){
            .actions = { imp_clv_t1 },
            .count = 1
        };
        case 0xD8: return(CpuCycles){
            .actions = { imp_cld_t1 },
            .count = 1
        };
        case 0xF8: return(CpuCycles){
            .actions = { imp_sed_t1 },
            .count = 1
        };
        case 0xEA: return(CpuCycles){
            .actions = { imp_nop_t1 },
            .count = 1
        };
        case 0xAA: return(CpuCycles){
            .actions = { imp_tax_t1 },
            .count = 1
        };
        case 0x8A: return(CpuCycles){
            .actions = { imp_txa_t1 },
            .count = 1
        };
        case 0xCA: return(CpuCycles){
            .actions = { imp_dex_t1 },
            .count = 1
        };
        case 0xE8: return(CpuCycles){
            .actions = { imp_inx_t1 },
            .count = 1
        };
        case 0xA8: return(CpuCycles){
            .actions = { imp_tay_t1 },
            .count = 1
        };
        case 0x98: return(CpuCycles){
            .actions = { imp_tya_t1 },
            .count = 1
        };
        case 0x88: return(CpuCycles){
            .actions = { imp_dey_t1 },
            .count = 1
        };
        case 0xC8: return(CpuCycles){
            .actions = { imp_iny_t1 },
            .count = 1
        };
        case 0x40: return(CpuCycles){
            .actions = { imp_rti_t1, imp_rti_t2, imp_rti_t3, imp_rti_t4, imp_rti_t5 },
            .count = 5
        };
        case 0x60: return(CpuCycles){
            .actions = { imp_rts_t1, imp_rts_t2, imp_rts_t3, imp_rts_t4, imp_rts_t5 },
            .count = 5
        };
        case 0x9A: return(CpuCycles){
            .actions = { imp_txs_t1 },
            .count = 1
        };
        case 0xBA: return(CpuCycles){
            .actions = { imp_tsx_t1 },
            .count = 1
        };
        case 0x48: return(CpuCycles){
            .actions = { imp_pha_t1, imp_pha_t2 },
            .count = 2
        };
        case 0x68: return(CpuCycles){
            .actions = { imp_pla_t1, imp_pla_t2, imp_pla_t3, },
            .count = 3
        };
        case 0x08: return(CpuCycles){
            .actions = { imp_php_t1, imp_php_t2 },
            .count = 2
        };
        case 0x28: return(CpuCycles){
            .actions = { imp_plp_t1, imp_plp_t2, imp_plp_t3 },
            .count = 3
        };
        case 0x00: return(CpuCycles){
            .actions = { imp_brk_t1, imp_brk_t2, imp_brk_t3, imp_brk_t4, imp_brk_t5, imp_brk_t6 },
            .count = 6
        };
        /* Zero page operations */
        case 0x65: return(CpuCycles){
            .actions = { zp_t1, zp_adc_t2 },
            .count = 2
        };
        case 0x25: return(CpuCycles){
            .actions = { zp_t1, zp_and_t2 },
            .count = 2
        };
        case 0x06: return(CpuCycles){
            .actions = { zp_t1, zp_rmw_t2, zp_asl_t3, zp_rmw_t4 },
            .count = 4
        };
        case 0x24: return(CpuCycles){
            .actions = { zp_t1, zp_bit_t2 },
            .count = 2
        };
        case 0xC5: return(CpuCycles){
            .actions = { zp_t1, zp_cmp_t2 },
            .count = 2
        };
        case 0xE4: return(CpuCycles){
            .actions = { zp_t1, zp_cpx_t2 },
            .count = 2
        };
        case 0xC4: return(CpuCycles){
            .actions = { zp_t1, zp_cpy_t2 },
            .count = 2
        };
        case 0xC6: return(CpuCycles){
            .actions = { zp_t1, zp_rmw_t2, zp_dec_t3, zp_rmw_t4 },
            .count = 4
        };
        case 0x45: return(CpuCycles){
            .actions = { zp_t1, zp_eor_t2 },
            .count = 2
        };
        case 0xE6: return(CpuCycles){
            .actions = { zp_t1, zp_rmw_t2, zp_inc_t3, zp_rmw_t4 },
            .count = 4
        };
        case 0xA5: return(CpuCycles){
            .actions = { zp_t1, zp_lda_t2 },
            .count = 2
        };
        case 0xA6: return(CpuCycles){
            .actions = { zp_t1, zp_ldx_t2 },
            .count = 2
        };
        case 0xA4: return(CpuCycles){
            .actions = { zp_t1, zp_ldy_t2 },
            .count = 2
        };
        case 0x46: return(CpuCycles){
            .actions = { zp_t1, zp_rmw_t2, zp_lsr_t3, zp_rmw_t4 },
            .count = 4
        };
        case 0x05: return(CpuCycles){
            .actions = { zp_t1, zp_ora_t2 },
            .count = 2
        };
        case 0x26: return(CpuCycles){
            .actions = { zp_t1, zp_rmw_t2, zp_rol_t3, zp_rmw_t4 },
            .count = 4
        };
        case 0x66: return(CpuCycles){
            .actions = { zp_t1, zp_rmw_t2, zp_ror_t3, zp_rmw_t4 },
            .count = 4
        };
        case 0xE5: return(CpuCycles){
            .actions = { zp_t1, zp_sbc_t2 },
            .count = 2
        };
        case 0x85: return(CpuCycles){
            .actions = { zp_t1, zp_sta_t2 },
            .count = 2
        };
        case 0x86: return(CpuCycles){
            .actions = { zp_t1, zp_stx_t2 },
            .count = 2
        };
        case 0x84: return(CpuCycles){
            .actions = { zp_t1, zp_sty_t2 },
            .count = 2
        };
        /* TODO: rest modes */
    }
    return(CpuCycles){ .count = 0 };
}
