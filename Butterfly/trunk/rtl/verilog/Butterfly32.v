//=============================================================================
//	(C) 2010  Robert Finch
//	All rights reserved.
//	robfinch@bird_computer.ca
//
//	Butterfly32.v
//		Butterfly processor using 32 bit bus.
//
//	This source code is available only for veiwing, testing and evaluation
//	purposes. Any commercial use requires a license. This copyright
//	statement and disclaimer must remain present in the file.
//
//
//	NO WARRANTY.
//  THIS Work, IS PROVIDEDED "AS IS" WITH NO WARRANTIES OF ANY KIND, WHETHER
//	EXPRESS OR IMPLIED. The user must assume the entire risk of using the
//	Work.
//
//	IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY
//  INCIDENTAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES WHATSOEVER RELATING TO
//  THE USE OF THIS WORK, OR YOUR RELATIONSHIP WITH THE AUTHOR.
//
//	IN ADDITION, IN NO EVENT DOES THE AUTHOR AUTHORIZE YOU TO USE THE WORK
//	IN APPLICATIONS OR SYSTEMS WHERE THE WORK'S FAILURE TO PERFORM CAN
//	REASONABLY BE EXPECTED TO RESULT IN A SIGNIFICANT PHYSICAL INJURY, OR IN
//	LOSS OF LIFE. ANY SUCH USE BY YOU IS ENTIRELY AT YOUR OWN RISK, AND YOU
//	AGREE TO HOLD THE AUTHOR AND CONTRIBUTORS HARMLESS FROM ANY CLAIMS OR
//	LOSSES RELATING TO SUCH UNAUTHORIZED USE.
//
//
//
//
//	Spartan3-4
//	709 LUTs / 426 slices / 38MHz	(area)
//	1109 LUTs / 603 slices / 54MHz (speed)
//=============================================================================

//`define WISHBONE

`define RST_ADDR	32'hFFFF_FFFC
`define SYS		12'h000
`define RST		16'h000F	// FFFF_FFF8
`define NMI		16'h000E	// FFFF_FFF0
`define IRQ		16'h000D
`define BRK		16'h0000	// FFFF_FF80
`define WAT		16'h000C
`define SYSOP	16'h0001	// FFFF_FF88
`define SSI		16'h000B	// FFFF_FFD8

// Flag manipulators
`define EI		16'h0010	// clear interrupt mask (enable interrupts)
`define DI		16'h0011	// set interrupt mask
`define RBI		16'h0012
`define TRCON	16'h0013
`define TRCOFF	16'h0014

`define RESV	16'h0018
`define CRES	16'h0019

`define NOP		16'h0020
`define STOP	16'h0021
`define END		16'h0022
`define BYT		16'h0023

`define RTI		12'h004

// Major groups opcode decode

`define MISC	4'h0		// miscellaneous
`define ADDI	4'h1		// ADD SUB CMP
`define RR		4'h2		// register - register 		ADD SUB AND OR EOR
`define RI		4'h3		// register - immediate		AND OR EOR
//`define SHIFT	4'h5
`define CPR12	4'h4		// 12 bit constant prefix
`define CPR28	4'h5		// 28 bit constant prefix
`define ADDI8	4'h6
`define JAL		4'h8		// jump and link			JAL JMP RET
`define CALL	4'h9		// jump to subroutine		CALL
`define BR		3'b101		// branch conditionals		BNE BPL BGT BGTU BGT BGTU BRA BEQ BMI BLE BLEU BLT BLTU BSR
`define SB		4'hC		// store byte				SB
`define SH		4'hD		// store character			SH
`define SW		4'hD		// store word				SW
`define LB		4'hE		// load byte				LB
`define LH		4'hF		// load character			LH
`define LW		4'hF		// load word				LW

`define	ADD		4'h0
`define ADC		4'h1
`define SUB		4'h2
`define SBC		4'h3
`define XOR		4'h4
`define AND		4'h5
`define OR		4'h6

`define SHL		4'h8
`define ROL		4'h9
`define SHR		4'hA
`define ASR		4'hB
`define ROR		4'hC

`define CMP		4'hD
`define TST		4'hD	// TST # only in place of CMPR #
`define TSR		4'hE
`define TRS		4'hF
`define EXT		4'hE

`define ZXB		4'h0
`define ZXH		4'h1
`define SXB		4'h2
`define SXH		4'h3


// Special purpose register designations
`define SR		4'h0
`define ILR		4'h1
`define WAR		4'h2
`define VER		4'h3
`define VBA		4'd5

// Branches
`define BLT		4'h0
`define BGE		4'h1
`define BLE		4'h2
`define BGT		4'h3
`define BLTU	4'h4
`define BGEU	4'h5
`define BLEU	4'h6
`define BGTU	4'h7
`define BEQ		4'h8
`define BNE		4'h9
`define BMI		4'hA
`define BPL		4'hB
`define BEX		4'hC
`define BNX		4'hD
`define BRA		4'hE
`define BSR 	4'hF

module Butterfly32
(
	input [7:0] id,		// cpu id (which cpu am I?)
	input nmi,			// non-maskable interrupt
	input irq,			// irq inputs
	input go,			// exit stop state if active
	// Bus master interface
	input rst_i,			// reset
	input clk_i,			// clock
	output reg soc_o,		// start of cyc_ole
	output reg cyc_o,		// cyc_ole valid
	input ack_i,			// bus transfer complete
	output reg resv_o,		// set a reservation on the address
	output reg cres_o,		// clear address reservation
	output reg ird_o,		// instruction read cyc_ole
	output reg we_o,		// we_oite cyc_ole
	output reg [3:0] sel_o,	// byte sel_oects
	output reg [31:0] adr_o,	// address
	input  [31:0] dat_i,		// instruction / data input bus
	output reg [31:0] dat_o,	// data output bus
	output soc_nxt_o,		// start of cyc_ole is next
	output cyc_nxt_o,		// next cyc_ole will be valid
	output ird_nxt_o,			// next cyc_ole will be an instruction read
	output we_nxt_o,			// next cyc_ole will be a we_oite
	output [3:0] sel_nxt_o,	// byte sel_oects for next cyc_ole
	output reg [31:0] adr_nxt_o,	// address for next cyc_ole
	output reg [31:0] dat_nxt_o	// data output for next cyc_ole
);
localparam DBW = 32;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
reg [31:1] pc;			// program counter
reg [31:1] pc_inc;		// program counter increment
reg [31:0] ilr;			// interrupted pc value (interrupt link register)
reg [31:0] war;			// watch address register
reg [31:6] vba;			// vector table base address
reg stopped;
reg [15:0] ir;			// instruction register
reg [15:0] cir;			// cached ir during load / store
reg [15:0] ir_nxt;
reg [15:0] insn1, insn2, insn3;	// pipeline for constants
reg ls1;					// load / store state

reg im ,imb;				// interrupt mask
reg cf, nf, zf, vf, sf;	// status register
reg cfb, nfb, zfb, vfb, sfb;// status register
reg trc, trcb;				// trace mode
reg rf, crf;			// reserve flag

// processor version identification
wire [31:0] ver = {8'h1,8'h1,8'h1,id};

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// ID stage instruction decodat_ig
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

// nybble breakdown
wire [3:0] op3 = ir[15:12];		// major opcode
wire [3:0] op2 = ir[11:8];		// destination register / condition
wire [3:0] op1 = ir[7:4];		// source register / minor opcode
wire [3:0] op0 = ir[3:0];		// minor opcode / immediate

wire [3:0] cond = op2;			// branch condition
// default branch displacement (nine bits)
// extended branch displacements are handled later
wire [31:1] brdisp	= {{23{ir[12]}},ir[7:0]};

wire misc	= op3 == `MISC;		// 0
wire addi	= op3 == `ADDI;		// 1
wire rr 	= op3 == `RR;		// 2
wire ri		= op3 == `RI;		// 3
wire cpr12 	= op3 == `CPR12;	// 4
wire cpr28 	= op3 == `CPR28;	// 5
wire addi8	= op3 == `ADDI8;	// 6
wire jal	= op3 == `JAL;		// 8
wire call	= op3 == `CALL;		// 9
wire brn	= op3[3:1] == `BR;	// A,B
wire sb		= op3 == `SB;			// C
wire sh		= (op3 == `SH) && ~ir[0];	// D
wire sw		= (op3 == `SW) &&  ir[0];	// D
wire lb		= op3 == `LB;			// E
wire lh		= (op3 == `LH) && ~ir[0];	// F
wire lw		= (op3 == `LW) &&  ir[0];	// F

wire [3:0] rsrc = ir[7:4];		// source register
wire [3:0] rdst = ir[11:8];		// destination (target) register  Trick: on bsr ir[11:8] will equal 4'hF
wire [3:0] srn  = ir[3:0];		// special register number

wire ld		= lw|lh|lb;
wire st		= sw|sh|sb;
wire ls		= ld|st;
wire lsb	= lb|sb;
wire lsh	= lh|sh;
wire lsw	= lw|sw;

wire ei		= ir[15:0]==`EI;
wire disint	= ir[15:0]==`DI;
wire rbi	= ir[15:0]==`RBI;
wire nop	= ir[15:0]==`NOP;
wire stop	= ir[15:0]==`STOP;
wire bsr	= brn && cond==`BSR;
wire sys	= ir[15:4]==`SYS;
wire rti	= ir[15:4]==`RTI;
wire trcon	= ir[15:4]==`TRCON;
wire trcoff	= ir[15:4]==`TRCOFF;
wire resv	= ir[15:0]==`RESV;
wire cres   = ir[15:0]==`CRES;

wire add	= rr && op0 == `ADD;
wire adc	= rr && op0 == `ADC;
wire sub	= rr && op0 == `SUB;
wire sbc	= rr && op0 == `SBC;
wire cmp	= rr && op0 == `CMP;
wire _and	= rr && op0 == `AND;
wire _or	= rr && op0 == `OR;
wire _xor	= rr && op0 == `XOR;

// Note: the core currently supports only immediate shifts
// these decodes aren't needed at the moment
wire asr	= rr && op0 == `ASR;
wire shr	= rr && op0 == `SHR;
wire shl	= rr && op0 == `SHL;
wire rol	= rr && op0 == `ROL;
wire ror	= rr && op0 == `ROR;

wire ext	= rr && op0 == `EXT;
wire zxb	= ext && op1 == `ZXB;
wire zxh	= ext && op1 == `ZXH;
wire sxb	= ext && op1 == `SXB;
wire sxh	= ext && op1 == `SXH;

wire subri	= ri && op1 == `SUB;
wire andi	= ri && op1 == `AND;
wire ori	= ri && op1 == `OR;
wire xori	= ri && op1 == `XOR;
wire tsti	= ri && op1 == `TST;

wire asri	= ri && op1 == `ASR;
wire shri	= ri && op1 == `SHR;
wire shli	= ri && op1 == `SHL;
wire roli	= ri && op1 == `ROL;
wire rori	= ri && op1 == `ROR;

wire tsr	= ri && op1 == `TSR;
wire trs	= ri && op1 == `TRS;

wire [1:0] shiftop = (rr ? ir[1:0] : ir[5:4])|ror|rori;

wire asop 	= sub|sbc|cmp|subri;
wire [2:0] logop	= {1'b0,_or|ori,_and|andi|tsti};
wire isAddsub		= add|sub|addi|addi8|subri|adc|sbc|cmp;
wire isLogop		= _and|_or|_xor|andi|tsti|ori|xori;

// register update signal
wire ru 	= (rr|ri|addi|addi8|jal|bsr|ld)&~(cmp|trs);
wire ruf 	= (rr|ri|addi|addi8|ld)&~trs;	// flag update

// EX/M stage operations decoded from the ID stage
reg x_cpr12;
reg x_cpr28;
reg m_cpr28;


// Force the two lsb during address generation
wire [31:0] n32;
// The following line is for word aligned offsets
//	assign n32[3:0] = {ir[3:2],((lsw&ls1)?1'b1:ir[1]),(lsw|lsh)?1'b0:ir[0]};
assign n32[3:0] = {ir[3:1],lsw?1'b0:ir[0]};	// ir[0] will be 0 for lsh
assign n32[31:4] =
		m_cpr28 ? {insn2, insn3[11:0]} :
		x_cpr12 ? {{16{insn2[11]}},insn2[11:0]} :
		addi8 	? {{24{ir[7]}},ir[7:4]} :
		 		   {28{n32[3]&n32[2]}};

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Control logic
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

// generate critical reset signal
wire crst_i;
criticalResetGen crg0(.clk(clk_i), .rst(rst_i), .creset(crst_i));

reg [1:0] su_cnt;
wire prime = su_cnt != 2'd1;
wire btout;
assign cyc_nxt_o = ack_i | prime;	// | btout;
wire pipe_ce = cyc_nxt_o & ~stopped & ird_nxt_o;

always @(posedge clk_i)
	if (rst_i)
		su_cnt <= 0;
	else if (crst_i)
		su_cnt <= 0;
	else if (su_cnt!=2'd1)
		su_cnt <= su_cnt + 1;
/*
busTimeoutCtr btc0(.rst_i(rst_i), .crst_i(crst_i), .clk_i(clk_i), .ce(1'b1),
	 .req(soc_o), .ack_i(cyc_nxt_o), .timeout(btout) );
*/
// state machine control

// indicates a change of program flow will take place
// x_cpr28 means there was a cpr28 instruction previously
// which means the following word is an immediate value,
// so we want the instruction register to be loaded with
// a nop in that case, just like a change of flow.
wire take_br;
wire flowchg = take_br | jal | cpr28 | sys | rti | prime;

wire ci = adc ? cf : sbc ? ~cf : sub|subri|cmp;

// Bus controls
// setup the read and we_oite signals
// These signals can be registered so they are valid at the
// beginning of a cyc_ole.
wire ls_done    = ls1;
assign we_nxt_o   = ~ls_done & st;
wire rd_nxt     = ~ls_done & (ld|sys);
assign ird_nxt_o  = ~(we_nxt_o|rd_nxt);

// general register file

// Do register update when:
// a) not we_oiting to register zero
// b) and the instruction is not annulled,
// c) and it's a register update instruction
wire rfwe_o = rdst != 4'h0 && ru;

tri [31:0] res;					// result bus (register file input)
wire [31:0] rfo_dst, rfo_src;		// read outputs

arRam1rw1r #(DBW,16) rf0(.clk(clk_i), .ce(pipe_ce), .wr(rfwe_o), .rwa(rdst), .ra(ri ? rdst : rsrc), .i(res), .rwo(rfo_dst), .ro(rfo_src));


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Control signal propagation
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

// DC to EX to M stage signal propagation
always @(posedge clk_i)
	if (rst_i) begin
		x_cpr12 <= 0;
		x_cpr28 <= 0;
		m_cpr28 <= 0;
	end
	else if (pipe_ce) begin
		x_cpr12 <= cpr12;
		x_cpr28 <= cpr28;
		m_cpr28 <= x_cpr28;
	end


	//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// ALU
	//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	reg  [31:0] aa;		// operand 'A'
	reg  [31:0] bb;		// operand 'B'
	wire [31:0] aso;	// adder / subtracter output
	wire [31:0] lgo;	// logic output
	wire asc;
	wire v;
	reg c;

	always @* aa <= rr  ? rfo_dst : n32;
	always @* bb <= rti ? ilr : addi8 ? rfo_dst : rfo_src;

	addsub #(DBW) as0(.op(asop), .ci(ci), .a(aa), .b(bb), .o(aso), .co(asc), .v(v));
	logicUnit #(DBW) lg0(.op(logop), .a(aa), .b(bb), .o(lgo) );


	//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// result multiplexer control
	//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	assign res = isAddsub ? aso : 'bz;
	assign res = isLogop  ? lgo : 'bz;
	assign res = (shli|roli) ? {bb[30:0],roli?bb[31]:1'b0} : 'bz;
	assign res = (shri|rori|asri)? {rori?bb[0]:asri?bb[31]:1'b0,bb[31:1]} : 'bz;

	// Load - first_i cyc_ole - load sign extended value
	assign res = (lb & sel_o[0]) ? {{24{dat_i[ 7]}},dat_i[ 7: 0]} : 'bz;
	assign res = (lb & sel_o[1]) ? {{24{dat_i[15]}},dat_i[15: 8]} : 'bz;
	assign res = (lb & sel_o[2]) ? {{24{dat_i[23]}},dat_i[23:16]} : 'bz;
	assign res = (lb & sel_o[3]) ? {{24{dat_i[31]}},dat_i[31:24]} : 'bz;
	assign res = (lh & sel_o[0]) ? {{16{dat_i[15]}},dat_i[15: 0]} : 'bz;
	assign res = (lh & sel_o[3]) ? {{16{dat_i[31]}},dat_i[31:16]} : 'bz;
	assign res = (lw) ? dat_i : {DBW{1'bz}};

	assign res = zxh|sxh ? {{16{sxh ? aa[15] : 1'b0}},aa[15:0]} : {DBW{1'bz}};
	assign res = zxb|sxb ? {{24{sxb ? aa[ 7] : 1'b0}},aa[ 7:0]} : {DBW{1'bz}};

	assign res = jal | bsr | sys ? {pc,1'b0} : {DBW{1'bz}};
	assign res = tsr && srn==`SR ? {16'b0,imb,trcb,2'b0,nfb,vfb,cfb,zfb,im,trc,2'b0,nf,vf,cf,zf}: {DBW{1'bz}};
	assign res = tsr && srn==`WAR ? war : {DBW{1'bz}};
	assign res = tsr && srn==`ILR ? ilr : {DBW{1'bz}};
	assign res = tsr && srn==`VER ? ver : {DBW{1'bz}};
	assign res = tsr && srn==`VBA ? vba : {DBW{1'bz}};
	assign res = trs ? rfo_dst : {DBW{1'bz}};


	//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// IR handling
	//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	// Pipeline interlock
	// Don't allow interrupts until the instruction following a
	// constant prefix instruction is loaded.
	// Also, disallow in branch shadow
	wire pipil = cpr12|x_cpr28|flowchg|resv|cres;

	// detect nmi edge
	reg hwi;
	reg hwi_nxt;
	wire nmi_edge;
	edge_det ed0(.rst(rst_i), .clk(clk_i), .ce(pipe_ce & ~pipil & ~hwi), .i(nmi), .pe(nmi_edge), .ne(), .ee() );

	// ir
	// Determine the source of the next instruction. This
	// will be a hardcoded interrupt instruction in the case
	// of an interrupt (the pipeline must also not be 
	// interlocked in this case), a cached value if the
	// current instruction is a load or store, the incoming
	// instruction stream (provided a flow change isn't in
	// progress) or just a NOP if nothing else.
	wire [15:0] insn = adr_o[1] ? dat_i[31:16] : dat_i[15:0];

	always @*
	begin
		// the hwi flag prevents an interrupt from occuring in two
		// consecutive clock cycles, which otherwise happens
		// because the im flag isn't set yet.
		if (((irq & ~im) | nmi_edge | trc) & ~pipil & ~hwi) begin 	// nmi is edge triggered
			if (trc)
				ir_nxt <= `SSI;
			else
				ir_nxt <= `IRQ ^ {nmi_edge,nmi_edge};
			hwi_nxt <= 1'b1;
		end
		else if (~ird_o) begin
			ir_nxt  <= cir;
			hwi_nxt <= 1'b0;
		end
		else if (~flowchg) begin			// also takes care of cp
			ir_nxt  <= insn;
			hwi_nxt <= 1'b0;
		end
		else begin
			ir_nxt  <= `NOP;
			hwi_nxt <= 1'b0;
		end
	end

	// ir
	// Clock in the instruction.
	always @(posedge clk_i)
		if (rst_i) begin
			ir  <= `RST;
			hwi <= 1'b1;
		end
		else if (crst_i) begin
			ir  <= `RST;
			hwi <= 1'b1;
		end
		else if (pipe_ce) begin
			ir  <= ir_nxt;
			hwi <= hwi_nxt;
		end

	// This insn pipeline stage needed for 32 bit constants
	// The start of the pipeline begins with insn/cir rather
	// than ir because ir is forced to a nop for constants.
	always @(posedge clk_i)
		if (rst_i) begin
			insn1 <= 0;
			insn2 <= 0;
			insn3 <= 0;
		end
		else if (pipe_ce) begin
			insn1 <= ird_o ? insn : cir;
			insn2 <= insn1;
			insn3 <= insn2;
		end

	// cir
	// Capture a copy of the incoming instruction in case
	// it gets put off by a load or store operation.
	always @(posedge clk_i)
		if (rst_i)
			cir <= `RST;
		else if (cyc_nxt_o & ~stopped & ird_o)
			cir <= insn;

// synthesis translate_off
	// Disassembler
	// This makes it a bit easier to read the simulator output
	always @(posedge clk_i)
	begin
		if (cpr12)	$display("CP12 #%h", ir[11:0]);
		if (cpr28)	$display("CP28 #%h", n32[31:4]);
		if (addi)	$display("ADD r%d,r%d,#%h", rdst, rsrc, n32);
		if (add)	$display("ADD r%d,r%d", rdst, rsrc);
		if (sub)	$display("SUB r%d,r%d", rdst, rsrc);
		if (tsti)	$display("TST r%d,#%h", rdst, n32);
		if (adc)	$display("ADC r%d,r%d", rdst, rsrc);
		if (sbc)	$display("SBC r%d,r%d", rdst, rsrc);
		if (cmp)	$display("CMP r%d,r%d", rdst, rsrc);
		if (lw)		$display("LW r%d,%h[r%d]", rdst, n32, rsrc);
		if (sw)		$display("SW r%d,%h[r%d]", rdst, n32, rsrc);
		if (lh)		$display("LH r%d,%h[r%d]", rdst, n32, rsrc);
		if (sh)		$display("SH r%d,%h[r%d]", rdst, n32, rsrc);
		if (lb)		$display("LB r%d,%h[r%d]", rdst, n32, rsrc);
		if (sb)		$display("SB r%d,%h[r%d]", rdst, n32, rsrc);
		if (jal)	$display("JAL  r%d,%h[r%d]", rdst, n32, rsrc);
		if (_and)	$display("AND r%d,r%d", rdst, rsrc);
		if (_or)	$display("OR r%d,r%d", rdst, rsrc);
		if (_xor)	$display("XOR r%d,r%d", rdst, rsrc);
		if (andi)	$display("AND r%d,#%h", rdst, n32);
		if (ori)	$display("OR r%d,#%h", rdst, n32);
		if (xori)	$display("XOR r%d,#%h", rdst, n32);
		if (shl)	$display("SHL r%d,r%d", rdst, n32);
		if (shr)	$display("SHR r%d,r%d", rdst, n32);
		if (asr)	$display("ASR r%d,r%d", rdst, n32);
		if (ror)	$display("ROR r%d,r%d", rdst, n32);
		if (rol)	$display("ROL r%d,r%d", rdst, n32);
		if (shli)	$display("SHL r%d,#%h", rdst, n32);
		if (shri)	$display("SHR r%d,#%h", rdst, n32);
		if (asri)	$display("ASR r%d,#%h", rdst, n32);
		if (rori)	$display("ROR r%d,#%h", rdst, n32);
		if (roli)	$display("ROL r%d,#%h", rdst, n32);
		if (ei)		$display("EI");
		if (disint)	$display("DI");
		if (tsr)	$display("TSR r%d,spr%d", rdst, ir[3:0]);
		if (trs)	$display("TRS r%d,spr%d", rdst, ir[3:0]);
		if (nop)	$display("NOP");
		if (stop)	$display("STOP");
		if (sys)	$display("SYS");
		if (rti)	$display("RTI #%h", n32);
		if (brn) begin
			case(cond)
			`BEQ:	$display("BEQ %h", {pc+brdisp,1'b0});
			`BNE:	$display("BNE %h", {pc+brdisp,1'b0});
			`BLT:	$display("BLT %h", {pc+brdisp,1'b0});
			`BLE:	$display("BLE %h", {pc+brdisp,1'b0});
			`BGT:	$display("BGT %h", {pc+brdisp,1'b0});
			`BGE:	$display("BGE %h", {pc+brdisp,1'b0});
			`BLEU:	$display("BLEU %h", {pc+brdisp,1'b0});
			`BLTU:	$display("BLTU %h", {pc+brdisp,1'b0});
			`BGEU:	$display("BGEU %h", {pc+brdisp,1'b0});
			`BGTU:	$display("BGTU %h", {pc+brdisp,1'b0});
			`BMI:	$display("BMI %h", {pc+brdisp,1'b0});
			`BPL:	$display("BPL %h", {pc+brdisp,1'b0});
			`BRA:	$display("BRA %h", {pc+brdisp,1'b0});
			`BSR:	$display("BSR %h", {pc+brdisp,1'b0});
			endcase
		end
	end
// synthesis translate_on

	//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// 'stop' signal handling
	//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	always @(posedge clk_i)
		if (rst_i)
			stopped <= 0;
		else begin
			if (nmi_edge | go)
				stopped <= 0;
			if (pipe_ce) begin
				if (stop)
					stopped <= 1;
			end
		end


	always @(posedge clk_i)
		if (rst_i)
			rf <= 0;
		else if (pipe_ce) begin
			if (resv)
				rf <= 1;
			else
				rf <= 0;
		end

	always @(posedge clk_i)
		if (rst_i)
			crf <= 0;
		else if (pipe_ce) begin
			if (cres)
				crf <= 1;
			else
				crf <= 0;
		end

	//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// condition generation / branch evaluation
	//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	reg taken;

	always @(cond,zf,nf,vf,cf)
	begin
		case (cond)
		`BEQ:	taken <= zf;
		`BNE:	taken <= ~zf;
		`BRA:	taken <= 1;
		`BSR:	taken <= 1;
		`BMI:	taken <= nf;
		`BPL:	taken <= ~nf;
//		`BEX:	taken <= xf;
//		`BNX:	taken <= ~xf;
		`BLT:	taken <= nf ^ vf;
		`BGE:	taken <= ~(nf ^ vf);
		`BLE:	taken <= (nf ^ vf ) | zf;
		`BGT:	taken <= ~((nf ^ vf ) | zf);
		`BLTU:	taken <= ~cf & ~zf;
		`BGEU:	taken <= cf | zf;
		`BLEU:	taken <= ~cf | zf;
		`BGTU:	taken <= cf & ~zf;
		default:	taken <= 1;
		endcase
	end

	assign take_br = brn & taken;


	//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// pc handling
	//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	// determine how much to increment the pc
	always @(call,take_br,x_cpr12,m_cpr28,ir,n32,brdisp)
		casex ({call,take_br,x_cpr12|m_cpr28})	// synopsys parallel_case full_case
		3'b1xx:		pc_inc <= {{19{ir[11]}},ir[11:0]};	// call instruction
		3'b011:		pc_inc <= n32;						// extended branch
		3'b010:		pc_inc <= brdisp;					// unextended branch
		default:	pc_inc <= 1;						// default increment
		endcase

	always @(posedge clk_i)
		if (pipe_ce) begin
			if (!hwi_nxt)
				pc <= adr_nxt_o[31:1];
		end

	always @(posedge clk_i)
		if (pipe_ce) begin
			if (sys)
				ilr <= res;	// res will be source by pc for sys
			else if (trs&&srn==`ILR)
				ilr <= res;
		end


	//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// status register handling
	//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	wire z = res == 32'b0;
	wire n = res[31];

	always @*
		if (isAddsub)
			c <= asop ? ~asc : asc;
		else if (shli|roli)
			c <= bb[31];
		else if (shri|rori|asri)
			c <= bb[0];
		else
			c <= cf;


	// Interrupt flag handling
	// disabling interrupts takes effect immediately
	// enabling interrupts takes effect after another clock cyc_ole
	// has passed. The idea is the cpu gets to execute at least
	// one other intstruction once interrupts are enabled, to
	// prevent the system from being stuck in an infinite interrupt
	// loop.
	reg im2;
	reg trc2;
	always @(posedge clk_i)
		if (rst_i) begin
			im <= 1;
			im2 <= 1;
			trc2 <= 0;
			trc <= 0;
		end
		else if (pipe_ce) begin
			if (disint) begin
				im <= 1;
				im2 <= 1;
			end
			// turn trace mode off when SSI interrupt present
			else if (sys) begin
				trc2 <= 0;
				trc <= 0;
				im <= 1;
				im2 <= 1;
			end
			else if (trcon)	// turn on trace mode
				trc2 <= 1;
			// If a TRC instruction, clear the trace mode flag because
			// we are about to enter the SSI interrupt routine
			else if (trcoff) begin
				trc2 <= 0;
				trc <= 0;
			end
			else if (ei)
				im2 <= 0;
			else if (rbi|rti) begin
				im2 <= imb;
				if (imb)
					im <= 1;
				trc2 <= trcb;
				if (~trcb)
					trc <= 0;
			end
			else if (trs && srn==`SR) begin
				im2 <= rfo_dst[7];
				if (rfo_dst[7]) 
					im <= 1;
				trc2 <= rfo_dst[6];
				if (~rfo_dst[6])
					trc <= 0;
			end
			else begin
				im <= im2;
				trc <= trc2;
			end
		end


	// Flag setting
	always @(posedge clk_i)
		if (rst_i) begin
			cf <= 0;
			nf <= 0;
			vf <= 0;
			zf <= 0;
			sf <= 1;
		end
		else if (pipe_ce) begin
			if (sys)
				sf <= 1;
			// copy backup flags to flags on return from interrupt
			else if (rti) begin
				cf <= cfb;
				nf <= nfb;
				vf <= vfb;
				zf <= zfb;
				sf <= sfb;
			end
			// transfer to status register
			else if (trs && srn==`SR) begin
				sf <= rfo_dst[5];
				nf <= rfo_dst[3];
				vf <= rfo_dst[2];
				cf <= rfo_dst[1];
				zf <= rfo_dst[0];
			end
			else if (ruf) begin
				cf <= c;
				// update overflow only for addsub
				if (isAddsub)
					vf <= v;
				nf <= n;
				zf <= z;
			end
		end

	// Backup flag setting	
	always @(posedge clk_i)
		if (rst_i) begin
			cfb <= 0;
			nfb <= 0;
			vfb <= 0;
			zfb <= 0;
			imb <= 1;
			trcb <= 0;
			sfb <= 1;
		end
		else if (pipe_ce) begin
			// Copy flags to backup on an interrupt instruction	
			// and mask interrupts
			if (sys) begin
				cfb <= cf;
				nfb <= nf;
				vfb <= vf;
				zfb <= zf;
				imb <= im;
				trcb <= trc;
				sfb <= sf;
			end
			// transfer to status register
			else if (trs && srn==`SR) begin
				nfb <= rfo_dst[11];
				vfb <= rfo_dst[10];
				cfb <= rfo_dst[9];
				zfb <= rfo_dst[8];
				imb <= rfo_dst[15];
				trcb <= rfo_dst[14];
				sfb <= rfo_dst[13];
			end
		end



	//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// load / store operations
	// high order characters are stored at higher addresses
	//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	// clock the load / store states
	wire ls0 = (ls|sys) & ~ls1;
	always @(posedge clk_i)
		if (rst_i)
			ls1 <= 0;
		else if (cyc_nxt_o)
			ls1 <= ls0;


	//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	// Bus support
	//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	assign sel_nxt_o[0] = 
		ird_nxt_o ? ~adr_nxt_o[1] :
		~ls_done && ((lsb && (adr_nxt_o[1:0]==2'b00))||
					 (lsh && (~adr_nxt_o[1]))||
					  lsw|sys)
		;
	assign sel_nxt_o[1] = 
		ird_nxt_o ? ~adr_nxt_o[1] :
		~ls_done && ((lsb && (adr_nxt_o[1:0]==2'b01))||
					 (lsh && (~adr_nxt_o[1]))||
					  lsw|sys)
		;
	assign sel_nxt_o[2] = 
		ird_nxt_o ? adr_nxt_o[1] :
		~ls_done && ((lsb && (adr_nxt_o[1:0]==2'b10))||
					 (lsh && (adr_nxt_o[1]))||
					  lsw|sys)
		;
	assign sel_nxt_o[3] = 
		ird_nxt_o ? adr_nxt_o[1] :
		~ls_done && ((lsb && (adr_nxt_o[1:0]==2'b11))||
					 (lsh && (adr_nxt_o[1]))||
					  lsw|sys)
		;

	// update the vba register
	always @(posedge clk_i)
		if (rst_i)
			vba <= {26{1'b1}};
		else if (crst_i)
			vba <= {26{1'b1}};
		else if (pipe_ce) begin
			if (trs && srn == `VBA)
				vba <= rfo_dst[31:6];
		end

	// decide the next address to put on the bus
	always @(rst_i,sys,ls0,ls1,vba,ir,jal,rti,ird_nxt_o,aso,pc,pc_inc)
		if (rst_i|(sys&ls0)) begin
			$display("Calling sys vector %h  ", {vba,ir[3:0],2'b0});
			adr_nxt_o <= {vba,ir[3:0],2'b0};
		end
		else if (sys&ls1)
			adr_nxt_o <= dat_i;
		else if (jal|rti|~ird_nxt_o)
			adr_nxt_o <= aso;
		else
			adr_nxt_o <= {pc + pc_inc,1'b0};

	always @(posedge clk_i)
		if (cyc_nxt_o)
			adr_o <= adr_nxt_o;

	always @(sb,sh,rfo_dst)
		if (sb)
			dat_nxt_o <= {4{rfo_dst[7:0]}};
		else if (sh)
			dat_nxt_o <= {2{rfo_dst[15:0]}};
		else // sw
			dat_nxt_o <= rfo_dst;

	always @(posedge clk_i)
		if (cyc_nxt_o)
			dat_o <= dat_nxt_o;

	always @(posedge clk_i)
		if (rst_i) begin
			soc_o <= 0;
			cyc_o <= 0;
			we_o  <= 0;
			sel_o <= 0;
			ird_o <= 0;
			cres_o <= 0;
			resv_o <= 0;
		end
		else begin
			soc_o <= 0;
			if (cyc_nxt_o) begin
				soc_o <= 1;
				cyc_o <= 1;
				we_o  <= we_nxt_o;
				resv_o <= rd_nxt & rf;
				cres_o <= we_nxt_o & crf;
				sel_o <= sel_nxt_o;
				ird_o <= ird_nxt_o;
			end
		end

	assign soc_nxt_o = cyc_nxt_o;

endmodule


