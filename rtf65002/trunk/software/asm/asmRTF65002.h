#pragma once
#include "Assembler.h"

namespace RTFClasses
{
	class AsmRTF65002
	{
	public:
		static void out16(Opa *o) { theAssembler.out16(o); };
		static void r(Opa *);
		static void rn(Opa *);
		static void rn2(Opa *);
		static void rn1(Opa *);
		static void rnbit(Opa *);
		static void sb_zp(Opa *);
		static void lb_zp(Opa *);
		static void orb_zp(Opa *);
		static void orb_zpx(Opa *);
		static void orb_abs(Opa *);
		static void orb_absx(Opa *);
		static void zp(Opa *);
		static void zp2(Opa *);
		static void zpbit(Opa *);
		static void zpld(Opa *);
		static void zplda(Opa *);
		static void zpsta(Opa *);
		// The target register is R1 and Ra also = 1
		static void acc_imm8(Opa *);
		static void acc_imm16(Opa *);
		static void acc_imm32(Opa *);
		static void acc_rn(Opa *);
		static void acc_zp(Opa *);
		static void acc_abs(Opa *);
		static void acc_absx(Opa *);
		static void acc_rind(Opa *);
		// The target register is R0 and Ra also = 1
		static void bit_acc_imm8(Opa *);
		static void bit_acc_imm16(Opa *);
		static void bit_acc_imm32(Opa *);
		static void bit_acc_zpx(Opa *);
		static void bit_acc_abs(Opa *);
		static void bit_acc_absx(Opa *);
		static void bit_absx(Opa *);
		static void stz_zp(Opa *);
		static void stz_abs(Opa *);
//		static void acc_zpx(Opa *);
		static void imm4(Opa *);
		static void imm8(Opa *);
		static void imm16(Opa *);
		static void imm32(Opa *);
		static void mul_imm8(Opa *);
		static void mul_imm16(Opa *);
		static void mul_imm32(Opa *);
		static void imm8bit(Opa *);
		static void imm16bit(Opa *);
		static void imm32bit(Opa *);
		static void imm8ld(Opa *);
		static void imm16ld(Opa *);
		static void imm32ld(Opa *);
		static void imm8lda(Opa *);
		static void imm16lda(Opa *);
		static void imm32lda(Opa *);
		static void Ximm32(Opa *);
		static void Ximm16(Opa *);
		static void Ximm8(Opa *);
		static void jmp_abs(Opa *);
		static void jml_abs(Opa *);
		static void abs(Opa *);
		static void abs2(Opa *);
		static void absx(Opa *);
		static void absx2(Opa *);
		static void rind(Opa *);
		static void absbit(Opa *);
		static void abssb(Opa *);
		static void sb_absx(Opa *);
		static void rindbit(Opa *);
		static void absld(Opa *);
		static void absldb(Opa *);
		static void abslda(Opa *);
		static void abssta(Opa *);
		static void absxld(Opa *);
		static void absxldb(Opa *);
		static void absxlda(Opa *);
		static void absxsta(Opa *);
		static void rindld(Opa *);
		static void rindlda(Opa *);
		static void ldy_rind(Opa *);
		static void st_rind(Opa *);
		static void sta_rind(Opa *);
		static void sty_rind(Opa *);
		static void stz_rind(Opa *);
		static void rindldx(Opa *);
		static void rind_jmp(Opa *);
		static void stx_rind(Opa *);
		static void br(Opa *);
		static void brl(Opa *);
		static void trs(Opa *);
		static void tsr_imm(Opa *);
		static void push(Opa *);
		static void pop(Opa *);
		static void int_(Opa *);
		static void dsp(Opa *);
		static void acc_dsp(Opa *);
		static void ld_dsp(Opa *);
		static void ld_acc_dsp(Opa *);
		static void st_dsp(Opa *);
		static void st_acc_dsp(Opa *);
		static void ldx_absx(Opa *);
		static void ldx_abs(Opa *);
		static void stz_absx(Opa *);
		static void stx_absx(Opa *);
		static void sty_absx(Opa *);
		static void sub_sp_imm8(Opa *);
		static void sub_sp_imm16(Opa *);
		static void sub_sp_imm32(Opa *);
		static void bms_zp(Opa *);
		static void bms_abs(Opa *);
		static void bms_absx(Opa *);
	};
}
