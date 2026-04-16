#ifndef __cpu_actions_h_
#define __cpu_actions_h_

#include "cpu_module.h"

/* MARK: - RESET actions */
void reset_t0(CpuState *state);
void reset_t1(CpuState *state);
void reset_t2(CpuState *state);
void reset_t3(CpuState *state);
void reset_t4(CpuState *state);
void reset_t5(CpuState *state);
void reset_t6(CpuState *state);

/* MARK: - IRQ actions */
void irq_t0(CpuState *state);
void irq_t1(CpuState *state);
void irq_t2(CpuState *state);
void irq_t3(CpuState *state);
void irq_t4(CpuState *state);
void irq_t5(CpuState *state);
void irq_t6(CpuState *state);

/* MARK: - NMI actions */
void nmi_t0(CpuState *state);
void nmi_t1(CpuState *state);
void nmi_t2(CpuState *state);
void nmi_t3(CpuState *state);
void nmi_t4(CpuState *state);
void nmi_t5(CpuState *state);
void nmi_t6(CpuState *state);

/* MARK: - common actions */
uint8_t fetch_t0(CpuState *state);
void com_lda(CpuState *state);
void com_ldx(CpuState *state);
void com_ldy(CpuState *state);
void com_adc(CpuState *state);
void com_sbc(CpuState *state);
void com_and(CpuState *state);
void com_ora(CpuState *state);
void com_eor(CpuState *state);
void com_bit(CpuState *state);
void com_cmp(CpuState *state);
void com_cpx(CpuState *state);
void com_cpy(CpuState *state);
void com_sta(CpuState *state);
void com_stx(CpuState *state);
void com_sty(CpuState *state);
void com_asl(CpuState *state);
void com_lsr(CpuState *state);
void com_rol(CpuState *state);
void com_ror(CpuState *state);
void com_inc(CpuState *state);
void com_dec(CpuState *state);
void com_rmw_0(CpuState *state);
void com_rmw_1(CpuState *state);

/* MARK: - immediate actions */
void imm_adc_t1(CpuState *state);
void imm_sbc_t1(CpuState *state);
void imm_and_t1(CpuState *state);
void imm_ora_t1(CpuState *state);
void imm_eor_t1(CpuState *state);
void imm_cmp_t1(CpuState *state);
void imm_cpx_t1(CpuState *state);
void imm_cpy_t1(CpuState *state);
void imm_lda_t1(CpuState *state);
void imm_ldx_t1(CpuState *state);
void imm_ldy_t1(CpuState *state);

/* MARK: - accumulator actions */
void acc_asl_t1(CpuState *state);
void acc_lsr_t1(CpuState *state);
void acc_rol_t1(CpuState *state);
void acc_ror_t1(CpuState *state);

/* MARK: - implied actions */
void imp_brk_t1(CpuState *state);
void imp_brk_t2(CpuState *state);
void imp_brk_t3(CpuState *state);
void imp_brk_t4(CpuState *state);
void imp_brk_t5(CpuState *state);
void imp_brk_t6(CpuState *state);
void imp_clc_t1(CpuState *state);
void imp_cli_t1(CpuState *state);
void imp_clv_t1(CpuState *state);
void imp_cld_t1(CpuState *state);
void imp_sec_t1(CpuState *state);
void imp_sei_t1(CpuState *state);
void imp_sed_t1(CpuState *state);
void imp_nop_t1(CpuState *state);
void imp_tax_t1(CpuState *state);
void imp_tay_t1(CpuState *state);
void imp_txa_t1(CpuState *state);
void imp_tya_t1(CpuState *state);
void imp_inx_t1(CpuState *state);
void imp_iny_t1(CpuState *state);
void imp_dex_t1(CpuState *state);
void imp_dey_t1(CpuState *state);
void imp_rti_t1(CpuState *state);
void imp_rti_t2(CpuState *state);
void imp_rti_t3(CpuState *state);
void imp_rti_t4(CpuState *state);
void imp_rti_t5(CpuState *state);
void imp_rts_t1(CpuState *state);
void imp_rts_t2(CpuState *state);
void imp_rts_t3(CpuState *state);
void imp_rts_t4(CpuState *state);
void imp_rts_t5(CpuState *state);
void imp_txs_t1(CpuState *state);
void imp_tsx_t1(CpuState *state);
void imp_pha_t1(CpuState *state);
void imp_pha_t2(CpuState *state);
void imp_php_t1(CpuState *state);
void imp_php_t2(CpuState *state);
void imp_pla_t1(CpuState *state);
void imp_pla_t2(CpuState *state);
void imp_pla_t3(CpuState *state);
void imp_plp_t1(CpuState *state);
void imp_plp_t2(CpuState *state);
void imp_plp_t3(CpuState *state);

/* MARK: - zero page actions */
void zp_t1(CpuState *state);
void zpx_t2(CpuState *state);
void zpy_t2(CpuState *state);

/* MARK: - absolute actions */
void abs_t1(CpuState *state);
void abs_t2(CpuState *state);
void abs_jmp_t2(CpuState *state);
void abs_jsr_t2(CpuState *state) ;
void abs_jsr_t3(CpuState *state);
void abs_jsr_t4(CpuState *state);
void abs_jsr_t5(CpuState *state);

void abx_rmw_t3(CpuState *state);
void aby_rmw_t3(CpuState *state);

void abx_adc_t3(CpuState *state);
void abx_and_t3(CpuState *state);
void abx_cmp_t3(CpuState *state);
void abx_eor_t3(CpuState *state);
void abx_lda_t3(CpuState *state);
void abx_ldy_t3(CpuState *state);
void abx_ora_t3(CpuState *state);
void abx_sbc_t3(CpuState *state);

void aby_adc_t3(CpuState *state);
void aby_and_t3(CpuState *state);
void aby_cmp_t3(CpuState *state);
void aby_eor_t3(CpuState *state);
void aby_lda_t3(CpuState *state);
void aby_ldx_t3(CpuState *state);
void aby_ora_t3(CpuState *state);
void aby_sbc_t3(CpuState *state);

/* MARK: - indirect actions */
void ind_jmp_t1(CpuState *state);
void ind_jmp_t2(CpuState *state);
void ind_jmp_t4(CpuState *state);
void ind_t3(CpuState *state);
void inx_t4(CpuState *state);
void iny_t2(CpuState *state);
void iny_t3(CpuState *state);
void iny_adc_t4(CpuState *state);
void iny_and_t4(CpuState *state);
void iny_cmp_t4(CpuState *state);
void iny_eor_t4(CpuState *state);
void iny_lda_t4(CpuState *state);
void iny_ora_t4(CpuState *state);
void iny_sbc_t4(CpuState *state);
void iny_sta_t4(CpuState *state);
void iny_sta_t5(CpuState *state);

/* MARK: - relative actions */
void rel_bpl_t1(CpuState *state);
void rel_bmi_t1(CpuState *state);
void rel_bvc_t1(CpuState *state);
void rel_bvs_t1(CpuState *state);
void rel_bcc_t1(CpuState *state);
void rel_bcs_t1(CpuState *state);
void rel_bne_t1(CpuState *state);
void rel_beq_t1(CpuState *state);
void rel_t2(CpuState *state);
void rel_t3(CpuState *state);

#endif /* __cpu_actions_h_ */
