// ============================================================================
//        __
//   \\__/ o\    (C) 2014  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@finitron.ca
//       ||
//
// A64 - Assembler
//  - 64 bit CPU
//
// This source file is free software: you can redistribute it and/or modify 
// it under the terms of the GNU Lesser General Public License as published 
// by the Free Software Foundation, either version 3 of the License, or     
// (at your option) any later version.                                      
//                                                                          
// This source file is distributed in the hope that it will be useful,      
// but WITHOUT ANY WARRANTY; without even the implied warranty of           
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            
// GNU General Public License for more details.                             
//                                                                          
// You should have received a copy of the GNU General Public License        
// along with this program.  If not, see <http://www.gnu.org/licenses/>.    
//                                                                          
// ============================================================================
//
#ifndef TOKEN_H
#define TOKEN_H

enum {
     tk_eof = -1,
     tk_none = 0,
     tk_comma = ',',
     tk_hash = '#',
     tk_plus = '+',
     tk_eol = '\n',
     tk_add = 128,
     tk_addi,
     tk_addu, // 130
     tk_2addu,
     tk_4addu,
     tk_8addu,
     tk_16addu,
     tk_2addui,
     tk_4addui,
     tk_8addui,
     tk_16addui,
     tk_addui,
     tk_align, //140
     tk_and,
     tk_andi,
     tk_asl,
     tk_asli,
     tk_asr,
     tk_asri,
     tk_beq,
     tk_bge,
     tk_bgeu,
     tk_bfchg, // 150
     tk_bfclr,
     tk_bfext,
     tk_bfextu,
     tk_bfins,
     tk_bfinsi,
     tk_bfset,
     tk_bgt,
     tk_bgtu,
     tk_bit,
     tk_biti, // 160
     tk_bits,
     tk_ble,
     tk_bleu,
     tk_blt,
     tk_bltu,
     tk_bmi,
     tk_bne,
     tk_bpl,
     tk_br,
     tk_bra, // 170
     tk_brk,
     tk_brnz,
     tk_brz,
     tk_bsr,
     tk_bss,
     tk_bvc,
     tk_bvs,
     tk_byte,
     tk_cas,
     tk_chk, // 180
     tk_chki,
     tk_cli,
     tk_cmp,
     tk_cmpi,
     tk_cmpu,
     tk_code,
     tk_com,
     tk_cpuid,
     tk_cs,
     tk_data, // 190
     tk_db, 
     tk_dbnz,
     tk_dc,
     tk_dec,
     tk_dh,
     tk_div,
     tk_divi,
     tk_divu,
     tk_divui,
     tk_ds,   // 200
     tk_dw,
     tk_end,
     tk_endpublic,
     tk_enor,
     tk_eor,
     tk_eori,
     tk_eq,
     tk_equ,
     tk_es,
     tk_extern, //210
     tk_fabs,  
     tk_fadd,
     tk_fcmp,
     tk_fcx,
     tk_fdiv,
     tk_fdx,
     tk_fex,
     tk_fill,
     tk_fix2flt,
     tk_flt2fix,//220
     tk_fmov,
     tk_fmul,
     tk_fs,
     tk_fnabs,
     tk_fneg,
     tk_frm,
     tk_fstat,
     tk_fsub,
     tk_ftst,
     tk_ftx, // 230
     tk_ge,
     tk_gran,
     tk_gs,
     tk_gt,
     tk_hs,
     tk_icon,
     tk_id,
     tk_inc,
     tk_int,
     tk_ios, // 240
     tk_jal,
     tk_jci,
     tk_jhi,
     tk_jgr,
     tk_jmp,
     tk_jsf,
     tk_jsp,
     tk_jsr,
     tk_land,
     tk_lb,
     tk_lbu, //250
     tk_lc,
     tk_lcu,
     tk_ldi,
     tk_ldis,
     tk_lea,
     tk_lfd,
     tk_lh,
     tk_lhu,
     tk_le,
     tk_lla, //260
     tk_llax,
     tk_lmr,
     tk_loop,
     tk_lor,
     tk_lshift,
     tk_lsr,
     tk_lsri,
     tk_lt,
     tk_lui,
     tk_lvb,
     tk_lvc, //270
     tk_lvh,
     tk_lvw,
     tk_lvwar,
     tk_lw,
     tk_lwar,
     tk_lws,
     tk_max,
     tk_memdb,
     tk_memsb,
     tk_message,
     tk_mffp, //280
     tk_mfspr,
     tk_mod,
     tk_modi,
     tk_modu,
     tk_modui,
     tk_mov,
     tk_mtfp,
     tk_mtspr,
     tk_mul,
     tk_muli, //290
     tk_mulu,
     tk_mului,
     tk_mv2fix,
     tk_mv2flt,
     tk_nand,
     tk_ne,
     tk_neg,
     tk_nop,
     tk_nor,
     tk_not, //300
     tk_or,
     tk_ori,
     tk_org,
     tk_pand,
     tk_pandc,
     tk_pea,
     tk_penor,
     tk_peor,
     tk_php, //310
     tk_plp,
     tk_pnand,
     tk_pnor,
     tk_pop,
     tk_por,
     tk_porc,
     tk_pred,
     tk_public,
     tk_push,
     tk_rconst,//320
     tk_rodata,
     tk_rol,
     tk_roli,
     tk_ror,
     tk_rori,
     tk_rshift,
     tk_rtd,
     tk_rte,
     tk_rtf,
     tk_rti,
     tk_rtl,
     tk_rts,
     tk_sb,
     tk_sc,
     tk_sei,
     tk_seq,
     tk_seqi,
     tk_sfd,
     tk_sgt,
     tk_sgti,
     tk_sgtu,
     tk_sgtui,
     tk_sge,
     tk_sgei,
     tk_sgeu,
     tk_sgeui,
     tk_sh,
     tk_shl,
     tk_shli,
     tk_shr,
     tk_shri,
     tk_shru,
     tk_shrui,
     tk_slli,
     tk_slt,
     tk_slti,
     tk_sltu,
     tk_sltui,
     tk_sle,
     tk_slei,
     tk_sleu,
     tk_sleui,
     tk_smr,
     tk_sne,
     tk_snei,
     tk_srai,
     tk_srli,
     tk_ss,
     tk_stcmp,
     tk_stmov,
     tk_stp,
     tk_stset,
     tk_stsb,
     tk_stsc,
     tk_stsh,
     tk_stsw,
     tk_sub,
     tk_subi,
     tk_subu,
     tk_subui,
     tk_sw,
     tk_swcr,
     tk_swap,
     tk_sws,
     tk_sxb,
     tk_sxc,
     tk_sxh,
     tk_sync,
     tk_sys,
     tk_tlbdis,
     tk_tlben,
     tk_tlbpb,
     tk_tlbrd,
     tk_tlbrdreg,
     tk_tlbwi,
     tk_tlbwr,
     tk_tlbwrreg,
     tk_tls,
     tk_to,
     tk_tst,
     tk_wai,
     tk_xnor,
     tk_xor,
     tk_xori,
     tk_zs,
     tk_zxb,
     tk_zxc,
     tk_zxh
};

extern int token;
extern int isIdentChar(char ch);
extern void ScanToEOL();
extern int NextToken();
extern void SkipSpaces();
extern void prevToken();
extern int need(int);
extern int expect(int);
extern int getRegister();
extern int getSprRegister();
extern int getFPRegister();
extern int getFPRoundMode();

#endif
