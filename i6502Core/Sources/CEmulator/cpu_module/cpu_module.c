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
    state->page_crossed = false;
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
    state->register_ps = 0xFD;
    state->page_crossed = false;
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
        /* MARK: Immediate mode operations */
        case 0x69: return (CpuCycles){
            .actions = { imm_adc_t1 },
            .count = 1
        };
        case 0xE9: return (CpuCycles){
            .actions = { imm_sbc_t1 },
            .count = 1
        };
        case 0x29: return (CpuCycles){
            .actions = { imm_and_t1 },
            .count = 1
        };
        case 0x09: return (CpuCycles){
            .actions = { imm_ora_t1 },
            .count = 1
        };
        case 0x49: return (CpuCycles){
            .actions = { imm_eor_t1 },
            .count = 1
        };
        case 0xC9: return (CpuCycles){
            .actions = { imm_cmp_t1 },
            .count = 1
        };
        case 0xE0: return (CpuCycles){
            .actions = { imm_cpx_t1 },
            .count = 1
        };
        case 0xC0: return (CpuCycles){
            .actions = { imm_cpy_t1 },
            .count = 1
        };
        case 0xA9: return (CpuCycles){
            .actions = { imm_lda_t1 },
            .count = 1
        };
        case 0xA2: return (CpuCycles){
            .actions = { imm_ldx_t1 },
            .count = 1
        };
        case 0xA0: return (CpuCycles){
            .actions = { imm_ldy_t1 },
            .count = 1
        };
        /* MARK: Accumulator mode operations */
        case 0x0A: return (CpuCycles){
            .actions = { acc_asl_t1 },
            .count = 1
        };
        case 0x4A: return (CpuCycles){
            .actions = { acc_lsr_t1 },
            .count = 1
        };
        case 0x2A: return (CpuCycles){
            .actions = { acc_rol_t1 },
            .count = 1
        };
        case 0x6A: return (CpuCycles){
            .actions = { acc_ror_t1 },
            .count = 1
        };
        /* MARK: Implied operations */
        case 0x18: return (CpuCycles){
            .actions = { imp_clc_t1 },
            .count = 1
        };
        case 0x38: return (CpuCycles){
            .actions = { imp_sec_t1 },
            .count = 1
        };
        case 0x58: return (CpuCycles){
            .actions = { imp_cli_t1 },
            .count = 1
        };
        case 0x78: return (CpuCycles){
            .actions = { imp_sei_t1 },
            .count = 1
        };
        case 0xB8: return (CpuCycles){
            .actions = { imp_clv_t1 },
            .count = 1
        };
        case 0xD8: return (CpuCycles){
            .actions = { imp_cld_t1 },
            .count = 1
        };
        case 0xF8: return (CpuCycles){
            .actions = { imp_sed_t1 },
            .count = 1
        };
        case 0xEA: return (CpuCycles){
            .actions = { imp_nop_t1 },
            .count = 1
        };
        case 0xAA: return (CpuCycles){
            .actions = { imp_tax_t1 },
            .count = 1
        };
        case 0x8A: return (CpuCycles){
            .actions = { imp_txa_t1 },
            .count = 1
        };
        case 0xCA: return (CpuCycles){
            .actions = { imp_dex_t1 },
            .count = 1
        };
        case 0xE8: return (CpuCycles){
            .actions = { imp_inx_t1 },
            .count = 1
        };
        case 0xA8: return (CpuCycles){
            .actions = { imp_tay_t1 },
            .count = 1
        };
        case 0x98: return (CpuCycles){
            .actions = { imp_tya_t1 },
            .count = 1
        };
        case 0x88: return (CpuCycles){
            .actions = { imp_dey_t1 },
            .count = 1
        };
        case 0xC8: return (CpuCycles){
            .actions = { imp_iny_t1 },
            .count = 1
        };
        case 0x40: return (CpuCycles){
            .actions = { imp_rti_t1, imp_rti_t2, imp_rti_t3, imp_rti_t4, imp_rti_t5 },
            .count = 5
        };
        case 0x60: return (CpuCycles){
            .actions = { imp_rts_t1, imp_rts_t2, imp_rts_t3, imp_rts_t4, imp_rts_t5 },
            .count = 5
        };
        case 0x9A: return (CpuCycles){
            .actions = { imp_txs_t1 },
            .count = 1
        };
        case 0xBA: return (CpuCycles){
            .actions = { imp_tsx_t1 },
            .count = 1
        };
        case 0x48: return (CpuCycles){
            .actions = { imp_pha_t1, imp_pha_t2 },
            .count = 2
        };
        case 0x68: return (CpuCycles){
            .actions = { imp_pla_t1, imp_pla_t2, imp_pla_t3, },
            .count = 3
        };
        case 0x08: return (CpuCycles){
            .actions = { imp_php_t1, imp_php_t2 },
            .count = 2
        };
        case 0x28: return (CpuCycles){
            .actions = { imp_plp_t1, imp_plp_t2, imp_plp_t3 },
            .count = 3
        };
        case 0x00: return (CpuCycles){
            .actions = { imp_brk_t1, imp_brk_t2, imp_brk_t3, imp_brk_t4, imp_brk_t5, imp_brk_t6 },
            .count = 6
        };
        /* MARK: Relative operations */
        case 0x10: return (CpuCycles){
            .actions = { rel_bpl_t1, rel_t2, rel_t3 },
            .count = 1
        };
        case 0x30: return (CpuCycles){
            .actions = { rel_bmi_t1, rel_t2, rel_t3 },
            .count = 1
        };
        case 0x50: return (CpuCycles){
            .actions = { rel_bvc_t1, rel_t2, rel_t3 },
            .count = 1
        };
        case 0x70: return (CpuCycles){
            .actions = { rel_bvs_t1, rel_t2, rel_t3 },
            .count = 1
        };
        case 0x90: return (CpuCycles){
            .actions = { rel_bcc_t1, rel_t2, rel_t3 },
            .count = 1
        };
        case 0xB0: return (CpuCycles){
            .actions = { rel_bcs_t1, rel_t2, rel_t3 },
            .count = 1
        };
        case 0xD0: return (CpuCycles){
            .actions = { rel_bne_t1, rel_t2, rel_t3 },
            .count = 1
        };
        case 0xF0: return (CpuCycles){
            .actions = { rel_beq_t1, rel_t2, rel_t3 },
            .count = 1
        };
        /* MARK: Zero page operations */
        case 0x65: return (CpuCycles){
            .actions = { zp_t1, com_adc },
            .count = 2
        };
        case 0x25: return (CpuCycles){
            .actions = { zp_t1, com_and },
            .count = 2
        };
        case 0x06: return (CpuCycles){
            .actions = { zp_t1, com_rmw_0, com_asl, com_rmw_1 },
            .count = 4
        };
        case 0x24: return (CpuCycles){
            .actions = { zp_t1, com_bit },
            .count = 2
        };
        case 0xC5: return (CpuCycles){
            .actions = { zp_t1, com_cmp },
            .count = 2
        };
        case 0xE4: return (CpuCycles){
            .actions = { zp_t1, com_cpx },
            .count = 2
        };
        case 0xC4: return (CpuCycles){
            .actions = { zp_t1, com_cpy },
            .count = 2
        };
        case 0xC6: return (CpuCycles){
            .actions = { zp_t1, com_rmw_0, com_dec, com_rmw_1 },
            .count = 4
        };
        case 0x45: return (CpuCycles){
            .actions = { zp_t1, com_eor },
            .count = 2
        };
        case 0xE6: return (CpuCycles){
            .actions = { zp_t1, com_rmw_0, com_inc, com_rmw_1 },
            .count = 4
        };
        case 0xA5: return (CpuCycles){
            .actions = { zp_t1, com_lda },
            .count = 2
        };
        case 0xA6: return (CpuCycles){
            .actions = { zp_t1, com_ldx },
            .count = 2
        };
        case 0xA4: return (CpuCycles){
            .actions = { zp_t1, com_ldy },
            .count = 2
        };
        case 0x46: return (CpuCycles){
            .actions = { zp_t1, com_rmw_0, com_lsr, com_rmw_1 },
            .count = 4
        };
        case 0x05: return (CpuCycles){
            .actions = { zp_t1, com_ora },
            .count = 2
        };
        case 0x26: return (CpuCycles){
            .actions = { zp_t1, com_rmw_0, com_rol, com_rmw_1 },
            .count = 4
        };
        case 0x66: return (CpuCycles){
            .actions = { zp_t1, com_rmw_0, com_ror, com_rmw_1 },
            .count = 4
        };
        case 0xE5: return (CpuCycles){
            .actions = { zp_t1, com_sbc },
            .count = 2
        };
        case 0x85: return (CpuCycles){
            .actions = { zp_t1, com_sta },
            .count = 2
        };
        case 0x86: return (CpuCycles){
            .actions = { zp_t1, com_stx },
            .count = 2
        };
        case 0x84: return (CpuCycles){
            .actions = { zp_t1, com_sty },
            .count = 2
        };
        /* MARK: Zero page X operations */
        case 0x75: return (CpuCycles){ /* adc $nn,x */
            .actions = { zp_t1, zpx_t2, com_adc },
            .count = 3
        };
        case 0x35: return (CpuCycles){ /* and $nn,x */
            .actions = { zp_t1, zpx_t2, com_and },
            .count = 3
        };
        case 0x16: return (CpuCycles){ /* asl $nn,x */
            .actions = { zp_t1, zpx_t2, com_rmw_0, com_asl, com_rmw_1 },
            .count = 5
        };
        case 0xD5: return (CpuCycles){ /* cmp $nn,x */
            .actions = { zp_t1, zpx_t2, com_cmp },
            .count = 3
        };
        case 0xD6: return (CpuCycles){ /* dec $nn,x */
            .actions = { zp_t1, zpx_t2, com_rmw_0, com_dec, com_rmw_1 },
            .count = 5
        };
        case 0x55: return (CpuCycles){ /* eor $nn,x */
            .actions = { zp_t1, zpx_t2, com_eor },
            .count = 3
        };
        case 0xF6: return (CpuCycles){ /* inc $nn,x */
            .actions = { zp_t1, zpx_t2, com_rmw_0, com_inc, com_rmw_1 },
            .count = 5
        };
        case 0xB5: return (CpuCycles){ /* lda $nn,x */
            .actions = { zp_t1, zpx_t2, com_lda },
            .count = 3
        };
        case 0xB4: return (CpuCycles){ /* ldy $nn,x */
            .actions = { zp_t1, zpx_t2, com_ldy },
            .count = 3
        };
        case 0x56: return (CpuCycles){ /* lsr $nn,x */
            .actions = { zp_t1, zpx_t2, com_rmw_0, com_lsr, com_rmw_1 },
            .count = 5
        };
        case 0x15: return (CpuCycles){ /* ora $nn,x */
            .actions = { zp_t1, zpx_t2, com_ora },
            .count = 3
        };
        case 0x36: return (CpuCycles){ /* rol $nn,x */
            .actions = { zp_t1, zpx_t2, com_rmw_0, com_rol, com_rmw_1 },
            .count = 5
        };
        case 0x76: return (CpuCycles){ /* ror $nn,x */
            .actions = { zp_t1, zpx_t2, com_rmw_0, com_ror, com_rmw_1 },
            .count = 5
        };
        case 0xF5: return (CpuCycles){ /* sbc $nn,x */
            .actions = { zp_t1, zpx_t2, com_sbc },
            .count = 3
        };
        case 0x95: return (CpuCycles){ /* sta $nn,x */
            .actions = { zp_t1, zpx_t2, com_sta },
            .count = 3
        };
        case 0x94: return (CpuCycles){ /* sty $nn,x */
            .actions = { zp_t1, zpx_t2, com_sty },
            .count = 3
        };
        /* MARK: Zero page Y operations */
        case 0xB6: return (CpuCycles){ /* ldx $nn,y */
            .actions = { zp_t1, zpy_t2, com_ldx },
            .count = 3
        };
        case 0x96: return (CpuCycles){ /* stx $nn,y */
            .actions = { zp_t1, zpy_t2, com_stx },
            .count = 3
        };
        /* MARK: Absolute operations */
        case 0x6D: return (CpuCycles){ /* adc $nnnn */
            .actions = { abs_t1, abs_t2, com_adc },
            .count = 3
        };
        case 0x2D: return (CpuCycles){ /* and $nnnn */
            .actions = { abs_t1, abs_t2, com_and },
            .count = 3
        };
        case 0x0E: return (CpuCycles){ /* asl $nnnn */
            .actions = { abs_t1, abs_t2, com_rmw_0, com_asl, com_rmw_1 },
            .count = 5
        };
        case 0x2C: return (CpuCycles){ /* bit $nnnn */
            .actions = { abs_t1, abs_t2, com_bit },
            .count = 3
        };
        case 0xCD: return (CpuCycles){ /* cmp $nnnn */
            .actions = { abs_t1, abs_t2, com_cmp },
            .count = 3
        };
        case 0xEC: return (CpuCycles){ /* cpx $nnnn */
            .actions = { abs_t1, abs_t2, com_cpx },
            .count = 3
        };
        case 0xCC: return (CpuCycles){ /* cpy $nnnn */
            .actions = { abs_t1, abs_t2, com_cpy },
            .count = 3
        };
        case 0xCE: return (CpuCycles){ /* dec $nnnn */
            .actions = { abs_t1, abs_t2, com_rmw_0, com_dec, com_rmw_1 },
            .count = 5
        };
        case 0x4D: return (CpuCycles){ /* eor $nnnn */
            .actions = { abs_t1, abs_t2, com_eor },
            .count = 3
        };
        case 0xEE: return (CpuCycles){ /* inc $nnnn */
            .actions = { abs_t1, abs_t2, com_rmw_0, com_inc, com_rmw_1 },
            .count = 5
        };
        case 0xAD: return (CpuCycles){ /* lda $nnnn */
            .actions = { abs_t1, abs_t2, com_lda },
            .count = 3
        };
        case 0xAE: return (CpuCycles){ /* ldx $nnnn */
            .actions = { abs_t1, abs_t2, com_ldx },
            .count = 3
        };
        case 0xAC: return (CpuCycles){ /* ldy $nnnn */
            .actions = { abs_t1, abs_t2, com_ldy },
            .count = 3
        };
        case 0x4E: return (CpuCycles){ /* lsr $nnnn */
            .actions = { abs_t1, abs_t2, com_rmw_0, com_lsr, com_rmw_1 },
            .count = 5
        };
        case 0x0D: return (CpuCycles){ /* ora $nnnn */
            .actions = { abs_t1, abs_t2, com_ora },
            .count = 3
        };
        case 0x2E: return (CpuCycles){ /* rol $nnnn */
            .actions = { abs_t1, abs_t2, com_rmw_0, com_rol, com_rmw_1 },
            .count = 5
        };
        case 0x6E: return (CpuCycles){ /* ror $nnnn */
            .actions = { abs_t1, abs_t2, com_rmw_0, com_ror, com_rmw_1 },
            .count = 5
        };
        case 0xED: return (CpuCycles){ /* sbc $nnnn */
            .actions = { abs_t1, abs_t2, com_sbc },
            .count = 3
        };
        case 0x8D: return (CpuCycles){ /* sta $nnnn */
            .actions = { abs_t1, abs_t2, com_sta },
            .count = 3
        };
        case 0x8E: return (CpuCycles){ /* stx $nnnn */
            .actions = { abs_t1, abs_t2, com_stx },
            .count = 3
        };
        case 0x8C: return (CpuCycles){ /* sty $nnnn */
            .actions = { abs_t1, abs_t2, com_sty },
            .count = 3
        };
        case 0x4C: return (CpuCycles){ /* jmp $nnnn */
            .actions = { abs_t1, abs_jmp_t2 },
            .count = 2
        };
        case 0x20: return (CpuCycles){ /* jsr $nnnn */
            .actions = { abs_t1, abs_jsr_t2, abs_jsr_t3, abs_jsr_t4, abs_jsr_t5 },
            .count = 5
        };
        /* MARK: Absolute X operations */
        case 0x7D: return (CpuCycles){ /* adc $nnnn,x */
            .actions = { abs_t1, abs_t2, abx_adc_t3, com_adc },
            .count = 3
        };
        case 0x3D: return (CpuCycles){ /* and $nnnn,x */
            .actions = { abs_t1, abs_t2, abx_and_t3, com_and },
            .count = 3
        };
        case 0xDD: return (CpuCycles){ /* cmp $nnnn,x */
            .actions = { abs_t1, abs_t2, abx_cmp_t3, com_cmp },
            .count = 3
        };
        case 0x5D: return (CpuCycles){ /* eor $nnnn,x */
            .actions = { abs_t1, abs_t2, abx_eor_t3, com_eor },
            .count = 3
        };
        case 0xBD: return (CpuCycles){ /* lda $nnnn,x */
            .actions = { abs_t1, abs_t2, abx_lda_t3, com_lda },
            .count = 3
        };
        case 0xBC: return (CpuCycles){ /* ldy $nnnn,x */
            .actions = { abs_t1, abs_t2, abx_ldy_t3, com_ldy },
            .count = 3
        };
        case 0x1D: return (CpuCycles){ /* ora $nnnn,x */
            .actions = { abs_t1, abs_t2, abx_ora_t3, com_ora },
            .count = 3
        };
        case 0xFD: return (CpuCycles){ /* sbc $nnnn,x */
            .actions = { abs_t1, abs_t2, abx_sbc_t3, com_sbc },
            .count = 3
        };
        case 0x1E: return (CpuCycles){ /* asl $nnnn,x */
            .actions = { abs_t1, abs_t2, abx_rmw_t3, com_rmw_0, com_asl, com_rmw_1 },
            .count = 6
        };
        case 0xDE: return (CpuCycles){ /* dec $nnnn,x */
            .actions = { abs_t1, abs_t2, abx_rmw_t3, com_rmw_0, com_dec, com_rmw_1 },
            .count = 6
        };
        case 0xFE: return (CpuCycles){ /* inc $nnnn,x */
            .actions = { abs_t1, abs_t2, abx_rmw_t3, com_rmw_0, com_inc, com_rmw_1 },
            .count = 6
        };
        case 0x5E: return (CpuCycles){ /* lsr $nnnn,x */
            .actions = { abs_t1, abs_t2, abx_rmw_t3, com_rmw_0, com_lsr, com_rmw_1 },
            .count = 6
        };
        case 0x3E: return (CpuCycles){ /* rol $nnnn,x */
            .actions = { abs_t1, abs_t2, abx_rmw_t3, com_rmw_0, com_rol, com_rmw_1 },
            .count = 6
        };
        case 0x7E: return (CpuCycles){ /* ror $nnnn,x */
            .actions = { abs_t1, abs_t2, abx_rmw_t3, com_rmw_0, com_ror, com_rmw_1 },
            .count = 6
        };
        case 0x9D: return (CpuCycles){ /* sta $nnnn,x */
            .actions = { abs_t1, abs_t2, abx_rmw_t3, com_sta },
            .count = 4
        };
        /* MARK: Absolute Y operation */
        case 0x79: return (CpuCycles){ /* adc $nnnn,y */
            .actions = { abs_t1, abs_t2, aby_adc_t3, com_adc },
            .count = 3
        };
        case 0x39: return (CpuCycles){ /* and $nnnn,y */
            .actions = { abs_t1, abs_t2, aby_and_t3, com_and },
            .count = 3
        };
        case 0xD9: return (CpuCycles){ /* cmp $nnnn,y */
            .actions = { abs_t1, abs_t2, aby_cmp_t3, com_cmp },
            .count = 3
        };
        case 0x59: return (CpuCycles){ /* eor $nnnn,y */
            .actions = { abs_t1, abs_t2, aby_eor_t3, com_eor },
            .count = 3
        };
        case 0xB9: return (CpuCycles){ /* lda $nnnn,y */
            .actions = { abs_t1, abs_t2, aby_lda_t3, com_lda },
            .count = 3
        };
        case 0xBE: return (CpuCycles){ /* ldx $nnnn,y */
            .actions = { abs_t1, abs_t2, aby_ldx_t3, com_ldx },
            .count = 3
        };
        case 0x19: return (CpuCycles){ /* ora $nnnn,y */
            .actions = { abs_t1, abs_t2, aby_ora_t3, com_ora },
            .count = 3
        };
        case 0xF9: return (CpuCycles){ /* sbc $nnnn,y */
            .actions = { abs_t1, abs_t2, aby_sbc_t3, com_sbc },
            .count = 3
        };
        case 0x99: return (CpuCycles){ /* sta $nnnn,y */
            .actions = { abs_t1, abs_t2, aby_rmw_t3, com_sta },
            .count = 4
        };
        /* MARK: Indirect operation */
        case 0x6C: return (CpuCycles){ /* jmp ($nnnn) */
            .actions = { ind_jmp_t1, ind_jmp_t2, ind_t3, ind_jmp_t4 },
            .count = 4
        };
        /* MARK: Indirect X operations */
        case 0x61: return (CpuCycles){ /* adc ($nn,x) */
            .actions = { zp_t1, zpx_t2, ind_t3, inx_t4, com_adc },
            .count = 4
        };
        case 0x21: return (CpuCycles){ /* and ($nn,x) */
            .actions = { zp_t1, zpx_t2, ind_t3, inx_t4, com_and },
            .count = 4
        };
        case 0xC1: return (CpuCycles){ /* cmp ($nn,x) */
            .actions = { zp_t1, zpx_t2, ind_t3, inx_t4, com_cmp },
            .count = 4
        };
        case 0x41: return (CpuCycles){ /* eor ($nn,x) */
            .actions = { zp_t1, zpx_t2, ind_t3, inx_t4, com_eor },
            .count = 4
        };
        case 0xA1: return (CpuCycles){ /* lda ($nn,x) */
            .actions = { zp_t1, zpx_t2, ind_t3, inx_t4, com_lda },
            .count = 4
        };
        case 0x01: return (CpuCycles){ /* ora ($nn,x) */
            .actions = { zp_t1, zpx_t2, ind_t3, inx_t4, com_ora },
            .count = 4
        };
        case 0xE1: return (CpuCycles){ /* sbc ($nn,x) */
            .actions = { zp_t1, zpx_t2, ind_t3, inx_t4, com_sbc },
            .count = 4
        };
        case 0x81: return (CpuCycles){ /* sta ($nn,x) */
            .actions = { zp_t1, zpx_t2, ind_t3, inx_t4, com_sta },
            .count = 5
        };
        /* MARK: Indirect Y operations */
        case 0x71: return (CpuCycles){ /* adc ($nn),y */
            .actions = { zp_t1, iny_t2, iny_t3, iny_adc_t4, com_adc },
            .count = 4
        };
        case 0x31: return (CpuCycles){ /* and ($nn),y */
            .actions = { zp_t1, iny_t2, iny_t3, iny_and_t4, com_and },
            .count = 4
        };
        case 0xD1: return (CpuCycles){ /* cmp ($nn),y */
            .actions = { zp_t1, iny_t2, iny_t3, iny_cmp_t4, com_cmp },
            .count = 4
        };
        case 0x51: return (CpuCycles){ /* eor ($nn),y */
            .actions = { zp_t1, iny_t2, iny_t3, iny_eor_t4, com_eor },
            .count = 4
        };
        case 0xB1: return (CpuCycles){ /* lda ($nn),y */
            .actions = { zp_t1, iny_t2, iny_t3, iny_lda_t4, com_lda },
            .count = 4
        };
        case 0x11: return (CpuCycles){ /* ora ($nn),y */
            .actions = { zp_t1, iny_t2, iny_t3, iny_ora_t4, com_ora },
            .count = 4
        };
        case 0xF1: return (CpuCycles){ /* sbc ($nn),y */
            .actions = { zp_t1, iny_t2, iny_t3, iny_sbc_t4, com_sbc },
            .count = 4
        };
        case 0x91: return (CpuCycles){ /* sta ($nn),y */
            .actions = { zp_t1, iny_t2, iny_t3, iny_sta_t4, iny_sta_t5 },
            .count = 5
        };
    }
    return (CpuCycles){ .count = 0 };
}
