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
void zp_lda_t2(CpuState *state);
void zp_ldx_t2(CpuState *state);
void zp_ldy_t2(CpuState *state);
void zp_adc_t2(CpuState *state);
void zp_sbc_t2(CpuState *state);
void zp_and_t2(CpuState *state);
void zp_ora_t2(CpuState *state);
void zp_eor_t2(CpuState *state);
void zp_bit_t2(CpuState *state);
void zp_cmp_t2(CpuState *state);
void zp_cpx_t2(CpuState *state);
void zp_cpy_t2(CpuState *state);
void zp_sta_t2(CpuState *state);
void zp_stx_t2(CpuState *state);
void zp_sty_t2(CpuState *state);
void zp_rmw_t2(CpuState *state);
void zp_rmw_t4(CpuState *state);
void zp_asl_t3(CpuState *state);
void zp_lsr_t3(CpuState *state);
void zp_rol_t3(CpuState *state);
void zp_ror_t3(CpuState *state);
void zp_inc_t3(CpuState *state);
void zp_dec_t3(CpuState *state);

#endif /* __cpu_actions_h_ */
