; ============================================================================
; bootrom4.asm
;        __
;   \\__/ o\    (C) 2014  Robert Finch, Stratford
;    \  __ /    All rights reserved.
;     \/_//     robfinch<remove>@finitron.ca
;       ||
;  
;
; This source file is free software: you can redistribute it and/or modify 
; it under the terms of the GNU Lesser General Public License as published 
; by the Free Software Foundation, either version 3 of the License, or     
; (at your option) any later version.                                      
;                                                                          
; This source file is distributed in the hope that it will be useful,      
; but WITHOUT ANY WARRANTY; without even the implied warranty of           
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            
; GNU General Public License for more details.                             
;                                                                          
; You should have received a copy of the GNU General Public License        
; along with this program.  If not, see <http://www.gnu.org/licenses/>.    
;                                                                          
; ============================================================================
;
TXTCOLS		EQU		84
TXTROWS		EQU		31

CR	EQU	0x0D		;ASCII equates
LF	EQU	0x0A
TAB	EQU	0x09
CTRLC	EQU	0x03
CTRLH	EQU	0x08
CTRLI	EQU	0x09
CTRLJ	EQU	0x0A
CTRLK	EQU	0x0B
CTRLM   EQU 0x0D
CTRLS	EQU	0x13
CTRLX	EQU	0x18
XON		EQU	0x11
XOFF	EQU	0x13

SC_LSHIFT	EQU		$12
SC_RSHIFT	EQU		$59
SC_KEYUP	EQU		$F0
SC_EXTEND	EQU		$E0
SC_CTRL		EQU		$14
SC_ALT		EQU		$11
SC_DEL		EQU		$71		; extend
SC_LCTRL	EQU		$58
SC_NUMLOCK	EQU		$77
SC_SCROLLLOCK	EQU	$7E
SC_CAPSLOCK	EQU		$58

; Boot sector info (62 byte structure) */
BSI_JMP		= 0x00
BSI_OEMName	= 0x03
BSI_bps		= 0x0B
BSI_SecPerCluster	= 0x0D
BSI_ResSectors	= 0x0E
BSI_FATS	= 0x10
BSI_RootDirEnts	= 0x11
BSI_Sectors	= 0x13
BSI_Media	= 0x15
BSI_SecPerFAT	= 0x16
BSI_SecPerTrack	= 0x18
BSI_Heads	= 0x1A
BSI_HiddenSecs	= 0x1C
BSI_HugeSecs	= 0x1E

BSI_DriveNum	= 0x24
BSI_Rsvd1		= 0x25
BSI_BootSig		= 0x26
BSI_VolID		= 0x27
BSI_VolLabel	= 0x2B
BSI_FileSysType = 0x36

; error codes
E_Ok		=		0x00
E_Arg		=		0x01
E_BadMbx	=		0x04
E_QueFull	=		0x05
E_NoThread	=		0x06
E_NotAlloc	=		0x09
E_NoMsg		=		0x0b
E_Timeout	=		0x10
E_BadAlarm	=		0x11
E_NotOwner	=		0x12
E_QueStrategy =		0x13
E_DCBInUse	=		0x19
; Device driver errors
E_BadDevNum	=		0x20
E_NoDev		=		0x21
E_BadDevOp	=		0x22
E_ReadError	=		0x23
E_WriteError =		0x24
E_BadBlockNum	=	0x25
E_TooManyBlocks	=	0x26

; resource errors
E_NoMoreMbx	=		0x40
E_NoMoreMsgBlks	=	0x41
E_NoMoreAlarmBlks	= 0x44
E_NoMoreTCBs	=	0x45
E_NoMem		= 12

TS_READY	EQU		1
TS_RUNNING	EQU		2
TS_PREEMPT	EQU		4

LEDS	equ		$FFDC0600

; The following offsets in the I/O segment
TEXTSCR	equ		$00000
TEXTREG		EQU		$A0000
TEXT_COLS	EQU		0x00
TEXT_ROWS	EQU		0x04
TEXT_CURPOS	EQU		0x2C
TEXT_CURCTL	EQU		0x20

BMP_CLUT	EQU		$C5800

PIC			EQU		0xFFDC0FC0
PIC_IE		EQU		0xFFDC0FC4
PIC_ES		EQU		0xFFDC0FD0
PIC_RSTE	EQU		0xFFDC0FD4

KEYBD		EQU		0xFFDC0000
KEYBDCLR	EQU		0xFFDC0004

SPIMASTER	EQU		0xFFDC0500
SPI_MASTER_VERSION_REG	EQU	0x00
SPI_MASTER_CONTROL_REG	EQU	0x04
SPI_TRANS_TYPE_REG	EQU		0x08
SPI_TRANS_CTRL_REG	EQU		0x0C
SPI_TRANS_STATUS_REG	EQU	0x10
SPI_TRANS_ERROR_REG		EQU	0x14
SPI_DIRECT_ACCESS_DATA_REG		EQU	0x18
SPI_SD_SECT_7_0_REG		EQU	0x1C
SPI_SD_SECT_15_8_REG	EQU	0x20
SPI_SD_SECT_23_16_REG	EQU	0x24
SPI_SD_SECT_31_24_REG	EQU	0x28
SPI_RX_FIFO_DATA_REG	EQU	0x40
SPI_RX_FIFO_DATA_COUNT_MSB	EQU	0x48
SPI_RX_FIFO_DATA_COUNT_LSB  EQU 0x4C
SPI_RX_FIFO_CTRL_REG		EQU	0x50
SPI_TX_FIFO_DATA_REG	EQU	0x80
SPI_TX_FIFO_CTRL_REG	EQU	0x90
SPI_RESP_BYTE1			EQU	0xC0
SPI_RESP_BYTE2			EQU	0xC4
SPI_RESP_BYTE3			EQU	0xC8
SPI_RESP_BYTE4			EQU	0xCC

SPI_INIT_SD			EQU		0x01
SPI_TRANS_START		EQU		0x01
SPI_TRANS_BUSY		EQU		0x01
SPI_INIT_NO_ERROR	EQU		0x00
SPI_READ_NO_ERROR	EQU		0x00
SPI_WRITE_NO_ERROR	EQU		0x00
RW_READ_SD_BLOCK	EQU		0x02
RW_WRITE_SD_BLOCK	EQU		0x03

I2C_MASTER		EQU		0xFFDC0E00
I2C_PRESCALE_LO	EQU		0x00
I2C_PRESCALE_HI	EQU		0x01
I2C_CONTROL		EQU		0x02
I2C_TX			EQU		0x03
I2C_RX			EQU		0x03
I2C_CMD			EQU		0x04
I2C_STAT		EQU		0x04

NR_TCB		EQU		16
TCB_BackLink    EQU     0
TCB_Regs		EQU		8
TCB_SP0Save		EQU		0x800
TCB_SS0Save     EQU     0x808
TCB_SP1Save		EQU		0x810
TCB_SS1Save     EQU     0x818
TCB_SP2Save		EQU		0x820
TCB_SS2Save     EQU     0x828
TCB_SP3Save		EQU		0x830
TCB_SS3Save     EQU     0x838
TCB_SP4Save		EQU		0x840
TCB_SS4Save     EQU     0x848
TCB_SP5Save		EQU		0x850
TCB_SS5Save     EQU     0x858
TCB_SP6Save		EQU		0x860
TCB_SS6Save     EQU     0x868
TCB_SP7Save		EQU		0x870
TCB_SS7Save     EQU     0x878
TCB_SP8Save		EQU		0x880
TCB_SS8Save     EQU     0x888
TCB_SP9Save		EQU		0x890
TCB_SS9Save     EQU     0x898
TCB_SP10Save	EQU		0x8A0
TCB_SS10Save    EQU     0x8A8
TCB_SP11Save	EQU		0x8B0
TCB_SS11Save    EQU     0x8B8
TCB_SP12Save	EQU		0x8C0
TCB_SS12Save    EQU     0x8C8
TCB_SP13Save	EQU		0x8D0
TCB_SS13Save    EQU     0x8D8
TCB_SP14Save	EQU		0x8E0
TCB_SS14Save    EQU     0x8E8
TCB_SP15Save	EQU		0x8F0
TCB_SS15Save    EQU     0x8F8
TCB_Seg0Save    EQU     0x900
TCB_Seg1Save	EQU		0x908
TCB_Seg2Save	EQU		0x910
TCB_Seg3Save	EQU		0x918
TCB_Seg4Save	EQU		0x920
TCB_Seg5Save	EQU		0x928
TCB_Seg6Save	EQU		0x930
TCB_Seg7Save	EQU		0x938
TCB_Seg8Save	EQU		0x940
TCB_Seg9Save	EQU		0x948
TCB_Seg10Save	EQU		0x950
TCB_Seg11Save	EQU		0x958
TCB_Seg12Save	EQU		0x960
TCB_Seg13Save	EQU		0x968
TCB_Seg14Save	EQU		0x970
TCB_Seg15Save	EQU		0x978
TCB_PCSave      EQU     0x980
TCB_SPSave		EQU		0x988
TCB_Next		EQU		0xA00
TCB_Prev		EQU		0xA08
TCB_Status		EQU		0xA18
TCB_Priority	EQU		0xA20
TCB_hJob		EQU		0xA28
TCB_Size	EQU		8192

	bss
	org		$8
Ticks			dw		0
Milliseconds	dw		0
OutputVec		dw		0
TickVec			dw		0
RunningTCB		dw		0
FreeTCB			dw		0
QNdx0			fill.w	8,0
NormAttr		dw		0
CursorRow		db		0
CursorCol		db		0
Dummy1			dc		0
KeybdEcho		db		0
KeybdBad		db		0
KeybdLocks		dc		0
KeyState1		db		0
KeyState2		db		0
KeybdWaitFlag	db		0
KeybdLEDs		db		0
startSector		dh		0
disk_size		dh		0
	align	16
	; org $A0
RTCC_BUF		fill.b	96,0

; Just past the Bootrom
	org		$00010000
NR_PTBL		EQU		32

IVTBaseAddress:
	fill.w	512*2,0      ; 2 words per vector, 512 vectors

    align 4096
GDTBaseAddress:
    fill.w  256*16*2,0   ; 2 words per descriptor, 16 descriptors per task, 256 tasks

; Memory Page Allocation Map

PAM1			fill.w	512,0
PAM2			fill.w	512,0

RootPageTbl:
	fill.b	4096*NR_PTBL,0
PgSD0:
	fill.w	512,0
PgSD3:
	fill.w	512,0
PgTbl0:
	fill.w	512,0
PgTbl1:
	fill.w	512,0
PgTbl2:
	fill.w	512,0
PgTbl3:
	fill.w	512,0
PgTbl4:
	fill.w	512,0
PgTbl5:
	fill.w	512,0
IOPgTbl:
	fill.w	512,0

TempTCB:
	fill.b	TCB_Size,0

	; 2MB for TSS space
	align 8192
TSSBaseAddress:
TCBs:
	fill.b	TCB_Size*NR_TCB,0

SECTOR_BUF	fill.b	512,0
    align 4096
BYTE_SECTOR_BUF	EQU	SECTOR_BUF
ROOTDIR_BUF fill.b  16384,0
PROG_LOAD_AREA	EQU ROOTDIR_BUF

EndStaticAllocations:
	dw		0

; The & -4 below clears the two LSB's of the address to indicate a near address
;
	code
	org		$00008000
	dw		ClearScreen	& -4		; $8000
	dw		HomeCursor	& -4		; $8008
	dw		DisplayString	& -4	; $8010
	dw		KeybdGetCharNoWait	& -4	; $8018
	dw		ClearBmpScreen	& -4	; $8020
	dw		DisplayChar		& -4	; $8028
	dw		SDInit			& -4	; $8030
	dw		SDReadMultiple	& -4	; $8038
	dw		SDWriteMultiple	& -4	; $8040
	dw		SDReadPart		& -4	; $8048
	dw		SDDiskSize		& -4	; $8050
	dw		DisplayWord		& -4	; $8058
	dw		DisplayHalf		& -4	; $8060
	dw		DisplayCharHex	& -4	; $8068
	dw		DisplayByte		& -4	; $8070

	org		$8200
start:
	sei
	ldi		r1,#$00000080			; tmr writes
	mtspr	cr0,r1
;	ldi     r1,#(2047<<40)+(GDTBaseAddress>>12)
    ldi     r1,#$00FFF00000000012  ; 256 entries, base address $12000
	mtspr   GDT,r1
	ldi     r1,#$000FF00000000002  ; 256 entries, base address $2000
	mtspr   LDT,r1
	; Clear descriptor tables
	ldi     r1,#8191
.strt1:
	sw      r0,GDTBaseAddress[r0+r1*8]
	dbnz    r1,.strt1
	; Setup the first sixteen entries in the descriptor table corresponding to
    ; the sixteen segment registers. They are setup for a flat memory model.
	sw      r0,GDTBaseAddress
	sw      r0,GDTBaseAddress+8
	ldi     r1,#$920FFFFFFFFFFFFF  ; data segment
	ldi     r2,#GDTBaseAddress
    sw      r1,$18[r2]
    sw      r1,$28[r2]
    sw      r1,$38[r2]
    sw      r1,$48[r2]
    sw      r1,$58[r2]
    sw      r1,$68[r2]
    sw      r1,$78[r2]
    sw      r1,$88[r2]
    sw      r1,$98[r2]
    sw      r1,$A8[r2]
    ldi     r1,#$00000000000FFD00    ; setup I/O segment
    sw      r1,$B0[r2]
    ldi     r1,#$92000000000000FF    ; 1MB limit
    sw      r1,$B8[r2]
	ldi     r1,#$920FFFFFFFFFFFFF  ; data segment
    sw      r1,$C8[r2]
    sw      r1,$D8[r2]
    ldi     r1,#$9600000FFC0003C0    ; stack limits paragraph 3C0-3FF
    sw      r0,$E0[r2]
    sw      r1,$E8[r2]
	ldi     r1,#$9A00000000001FFF    ; 32MB is top of memory
	sw      r0,$F0[r2]               ; setup code segment
	sw      r1,$F8[r2]

; Initialize TSS segment descriptors
; The TSS segment is needed as a storage place for the stack (SS:SP)

	ldi     r1,#TSSBaseAddress>>12   ; setup first TSS descriptor
	ldi     r4,#15
	ldi     r3,#0
	ldi     r5,#$8100000000000001    ; TSS segment size = 8k
.st0003:
	sw      r1,$C0[r2+r3]
	sw      r5,$C8[r2+r3]
	addi    r1,r1,#2                 ; increment by 8k
	addi    r3,r3,#$100              ; increment to next selector group
	dbnz    r4,.st0003

;	ldi     r1,#$810FFFFFFFFFFFFF    ; TSS segment
;	sw      r1,$C8[r2]
	; Setup data and stack segment
	ldi     r1,#1
	mtspr	ds,r1					; setup data and stack segments
	ldi     r1,#14
	mtspr	ss,r1
	ldi     r1,#11
	mtspr   ios,r1
	ldi     r1,#12
	mtspr   ts,r1
	; now do a far jump to set the code segment
	jsp     r0,#15                  ; selector index 15, GDT
	jmp     .strt2
.strt2:
	ldi		sp,#$3FFFF8
	ldi		r1,#DisplayChar & 0xFFFFFFFFFC
	sw		r1,OutputVec
    bsr     DispStartMsg
    bsr     CopyROMtoRAM

	ldi		r1,#$000000C0			; tmr reads/writes
	mtspr	cr0,r1

;	icache_on
	nop
	ldi		r1,#$FF
	sb		r1,LEDS
	ldi		r1,#IVTBaseAddress>>13
	mtspr	vbr,r1

	; setup page tables and the page table address register
	bsr		SetupPageTbl
	ldi		r1,#RootPageTbl+4096+2	; 3 level page table system
	mtspr	cr3,r1
	; turn on paging
	ldi		r1,#$000001C0			; 1C0 cache on, paging and protection on; tmr read/write/execute (1C0)
	mtspr	cr0,r1

	bsr		InitBMP

	ldi		r1,#TickRout
	sw		r1,TickVec

	ldi		r1,#$FC
	sb		r1,LEDS

	sw		r0,Milliseconds
	ldi		r1,#%000000100_110101110_0000000000
	sb		r1,KeybdEcho
	sb		r0,KeybdBad
	sh		r1,NormAttr
	sb		r0,CursorRow
	sb		r0,CursorCol
	ldi		r1,#DisplayChar & 0xFFFFFFFFFC
	sw		r1,OutputVec
	bsr		ClearScreen
	bsr		HomeCursor
	ldi     r1,#7
	sb      r1,LEDS
	ldi		r1,#DisplayChar & 0xFFFFFFFFFC
	sw		r1,OutputVec
	ldi     r1,#8
	sb      r1,LEDS
	bsr		SetupIntVectors
	bsr		KeybdInit
	bsr		InitPIC
	bra		Monitor
	bsr		FMTKInitialize
	cli

	ldi		r1,#$FF
	sb		r1,LEDS
	ldi		r1,#$FE
	push	r1/r2/r3/r4
;	bsr		DispLed
	bsr		ClearScreen
	ldi		r1,#$6
	sb		r1,LEDS
	bsr		DispStartMsg
	ldi		r1,#$FD
	pop		r4/r3/r2/r1
	sb		r1,LEDS
j1:
	bsr		HomeCursor
	ldi		r3,#TEXTSCR+224
	lw		r1,Milliseconds
	bsr		DisplayWord
	ios:lh	r1,TEXTSCR+444
	add		r1,r1,#1
	ios:sh	r1,TEXTSCR+444
	bra		j1
	
DispLed:
	lw		r1,8[sp]
	sb		r1,LEDS
	rts		#8

CopyROMtoRAM:
	; copy the ROM to RAM
	
	ldi		r3,#$7FFF
	ldi		r1,#$8000
.st1:
	lb		r2,[r1+r3]
	sb		r2,[r1+r3]
	dbnz	r3,.st1
	rts

;------------------------------------------------------------------------------
; Setup the interrupt vector for the system.
;------------------------------------------------------------------------------

SetupIntVectors:
	ldi     r1,#$A7
	sb      r1,LEDS
	php
	sei
	ldi     r1,#$AB
	sb      r1,LEDS
	ldi		r2,#IVTBaseAddress
	; Initialize all vectors to uninitialized interrupt routine vector
	ldi		r3,#511
	ldi		r1,#uninit_rout
	ldi     r5,#$86F000000000000F             ; interrupt gate, CS=15
.siv1:
	; setup specific vectors
	shli	r4,r3,#4
	sw		r1,[r2+r4]
	sw		r5,8[r2+r4]		; set CS to #15
	dbnz	r3,.siv1	
	ldi     r1,#$AC
	sb      r1,LEDS
	ldi		r1,#start
	lea		r3,449*16[r2]
	bsr     SetVector
	ldi		r1,#Tick1000Rout
	lea		r3,450*16[r2]
	bsr     SetVector
	ldi		r1,#TickRout    ; This vector will be taken over by FMTK
	lea		r3,451*16[r2]
	bsr     SetVector
	ldi		r1,#KeybdIRQ
	lea		r3,463*16[r2]
	bsr     SetVector
	ldi		r1,#flt_except
	lea		r3,493*16[r2]
	bsr		SetVector
	ldi		r1,#exf_rout
	lea		r3,497*16[r2]
	bsr     SetVector
	ldi		r1,#dwf_rout
	lea		r3,498*16[r2]
	bsr     SetVector
	ldi		r1,#drf_rout
	lea		r3,499*16[r2]
	bsr     SetVector
	ldi		r1,#sbv_rout
	lea		r3,500*16[r2]
	bsr     SetVector
	ldi		r1,#priv_rout
	lea		r3,501*16[r2]
	bsr     SetVector
	ldi		r1,#stv_rout
	lea		r3,502*16[r2]
	bsr     SetVector
	ldi		r1,#snp_rout
	lea		r3,503*16[r2]
	bsr     SetVector
	ldi		r1,#berr_rout
	lea		r3,508*16[r2]
	bsr     SetVector
	ldi     r1,#$AA
	sb      r1,LEDS
	plp
	rts

SetVector:
    andi    r1,r1,#-4
    ori     r1,r1,#3
    sw      r1,[r3]
    rts

;------------------------------------------------------------------------------
; Initialize the interrupt controller.
;------------------------------------------------------------------------------

InitPIC:
	ldi		r1,#$0C			; timer interrupt(s) are edge sensitive
	sh		r1,PIC_ES
	ldi		r1,#$000F		; enable keyboard reset, timer interrupts
	sh		r1,PIC_IE
	rts

;------------------------------------------------------------------------------
; Setup the initial page tables.
; Initialize the PAM.
;------------------------------------------------------------------------------

SetupPageTbl:
	push	r1/r2/r3/r4

	;--------------------------------------------------------------------------
	; Setup the root page directory
	; The root page directory only has two valid entries in it.
	; 0) A pointer to a subdirectory representing the memory in the system (128MB)
	; 3) A pointer to a subdirectory locating the I/O in the system (2MB)
	;           ++--------------- these two bits mapped by the root directory
	; xrrr rrrr rrss_ssss_ssst_tttt_tttt_xxxx_xxxx_xxxx
	; 0000_0000_rrxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx
	;--------------------------------------------------------------------------
	ldi		r1,#RootPageTbl+4096
	bsr		ClearPageTable
	mov		r2,r1
	ldi		r1,#PgSD0
	and		r1,r1,#-4096
	or		r1,r1,#$0F	; priv 0, cacheable, readable, executable, writeable
	sw		r1,[r2]
	ldi		r1,#PgSD0
	and		r1,r1,#-4096
	or		r1,r1,#$0F	; priv 0, cacheable, readable, executable, writeable
	sw		r1,8[r2]
	ldi		r1,#PgSD3
	and		r1,r1,#-4096
	or		r1,r1,#$8D	; priv 8, cacheable, readable, executable, writeable
	sw		r1,24[r2]

	;--------------------------------------------------------------------------
	; Setup subdirectory zero.
	; This sub-directory is capable of mapping all the memory in the system
	; (and more). Only the first 64 pages are used.
	; clear out subdirectory entries
	; ++--------------- these two bits mapped by the root directory
	; ||++-++++-+++---- these nine bits mapped by subirectory SD0
	; rrss_ssss_sss
	; 0000_0sss_sssx_xxxx_xxxx_xxxx_xxxx_xxxx
	;--------------------------------------------------------------------------
	ldi		r2,#PgSD0
	ldi		r3,#511
	ldi     r4,#511*8
.0002:
	sw		r0,[r2+r4]
	subui   r4,r4,#8
	dbnz	r3,.0002

	ldi		r1,#PgTbl0
	and		r1,r1,#-4096
	or		r1,r1,#$0F	; priv 0, cacheable, readable, executable, writeable
	sw		r1,[r2]

	ldi		r1,#PgTbl1
	and		r1,r1,#-4096
	or		r1,r1,#$0F	; priv 0, cacheable, readable, executable, writeable
	sw		r1,8[r2]

	; Bitmap graphics memory pages
	ldi		r1,#PgTbl2
	and		r1,r1,#-4096
	or		r1,r1,#$8D	; priv 8, cacheable, readable, executable, writeable
	sw		r1,2*8[r2]
	ldi		r1,#PgTbl3
	and		r1,r1,#-4096
	or		r1,r1,#$8D	; priv 8, cacheable, readable, executable, writeable
	sw		r1,3*8[r2]
	ldi		r1,#PgTbl4
	and		r1,r1,#-4096
	or		r1,r1,#$8D	; priv 8, cacheable, readable, executable, writeable
	sw		r1,4*8[r2]
	ldi		r1,#PgTbl5
	and		r1,r1,#-4096
	or		r1,r1,#$8D	; priv 8, cacheable, readable, executable, writeable
	sw		r1,5*8[r2]

	; setup first four pages
	; the lowest 16kB of memory is a scratch space
	ldi		r1,#PgTbl0
	bsr		ClearPageTable
	mov		r2,r1
	ldi		r1,#$008F
	sw		r1,[r2]
	ldi		r1,#$108F
	sw		r1,8[r2]
	ldi		r1,#$208F
	sw		r1,16[r2]
	ldi		r1,#$308F
	sw		r1,24[r2]

	; memory between $8000 and $FFFF is the bootrom
	ldi		r3,#7		; eight pages to setup
	ldi     r4,#7*8
	ldi		r1,#$F00E	; priv 0, cacheable, readable, executable, but not writeable
.0003:
	sw		r1,8*8[r2+r4]
	subui	r1,r1,#$1000
	subui   r4,r4,#8
	dbnz	r3,.0003
	
	; memmory above $FFFF to $1FFFFF is RAM for the OS (2MB)
	ldi		r3,#495		; 512- 16-1
	ldi     r4,#495*8
	ldi		r1,#$1FFFFF
.0006:
	sw		r1,16*8[r2+r4]
	subui	r1,r1,#$1000
	subui   r4,r4,#8
	dbnz	r3,.0006

	; memory between $200000 and $3FFFFF is RAM for the OS (2MB)
	ldi		r2,#PgTbl1
	ldi		r1,#$3FFFFF
	bsr		SetupBMTable

	; Page2 range $400000 to $5FFFFF
	; 0000_0000_010x_xxxx_xxxx_xxxx_xxxx_xxxx
	ldi		r2,#PgTbl2
	ldi		r1,#$5FFFFF
	bsr		SetupBMTable

	; Page3 range $600000 to $7FFFFF
	; 0000_0000_011x_xxxx_xxxx_xxxx_xxxx_xxxx
	ldi		r2,#PgTbl3
	ldi		r1,#$7FFFFF
	bsr		SetupBMTable

	; Page4 range $800000 to $9FFFFF
	; 0000_0000_100x_xxxx_xxxx_xxxx_xxxx_xxxx
	ldi		r2,#PgTbl4
	ldi		r1,#$9FFFFF
	bsr		SetupBMTable

	; Page5 range $A00000 to $BFFFFF
	; 0000_0000_101x_xxxx_xxxx_xxxx_xxxx_xxxx
	ldi		r2,#PgTbl5
	ldi		r1,#$BFFFFF
	bsr		SetupBMTable

	;--------------------------------------------------------------------------
	; Setup the PAM (page allocation map).
	;--------------------------------------------------------------------------
	; first mark all free
	ldi		r3,#32768/64-1	; number of pages
	ldi		r1,#0
.0007:
	sw		r0,PAM1[r3]
	dbnz	r3,.0007

	; We've allocated the first 12MB of RAM to the OS and bitmapped
	; graphics display. Mark it in the PAM.
	ldi		r3,#$63		; 3072 pages /64 - 1
	ldi		r1,#-1
.0008:
	sw		r1,PAM1[r3]
	dbnz	r3,.0008

	;--------------------------------------------------------------------------
	; Setup the I/O subdirectory
	; clear out subdirectory entries
	; The I/O subdirectory has only a single valid entry at #510
	; ++--------------- these two bit mapped by the root directory
	; ||++-++++-+++---- these nine bits mapped by subirectory SD3
	; rrss_ssss_sss
	; 1111_1111_110x_xxxx_xxxx_xxxx_xxxx_xxxx
	;--------------------------------------------------------------------------
	ldi		r1,#PgSD3
	bsr		ClearPageTable
	mov		r2,r1
	ldi		r1,#IOPgTbl
	or		r1,r1,#$8D		; priv 8,cachable, readable, non-executable, writeable
	sw		r1,510*8[r2]	; put in proper slot

	;--------------------------------------------------------------------------
	; Setup the I/O page table
	; We setup the I/O page table with linear addresses matching
	; physical ones between $FFCxxxxx and $FFDFFFFF
	; We map all entries assuming there is I/O in each one. In
	; reality all the I/O is above $FFDx, it's too cumbersone
	; to map on a device by device basis. If there happens not to be an I/O
	; device at a memory location, a bus error will result.
	; ++--------------- these two bit mapped by the root directory
	; ||++-++++-+++---- these nine bits mapped by subirectory SD3
	; |||| |||| |||+-++++-++++---- these nine bits mapped by the I/O page table
	; rrss_ssss_sss| |||| ||||
	; 1111_1111_110t_tttt_tttt_xxxx_xxxx_xxxx
	;--------------------------------------------------------------------------
	ldi		r2,#IOPgTbl
	ldi		r3,#511
	ldi     r4,#511*8
	ldi		r1,#$FFDFF085	; priv 8, non-cachable, readable, non-executable, writeable
.0005:
	sw		r1,[r2+r4]
	subui	r1,r1,#$1000
	subui   r4,r4,#8
	dbnz	r3,.0005

	pop		r4/r3/r2/r1
	rts

;------------------------------------------------------------------------------
; Clear the page table ( a block of 512 words).
; Parameters:
;	r1 = address of page table
;------------------------------------------------------------------------------

ClearPageTable:
	push	r2
	ldi		r2,#511
.0001:
	sw		r0,[r1+r2*8]
	dbnz	r2,.0001
	pop		r2
	rts

;------------------------------------------------------------------------------
; r1 = address
; r2 = pointer to page table
;------------------------------------------------------------------------------

SetupBMTable:
	push	r3/r4
	ldi		r3,#511
	ldi     r4,#511*8
.0006:
	and		r1,r1,#-4096
	or		r1,r1,#$8F
	sw		r1,[r2+r4]
	subui	r1,r1,#$1000
	subui   r4,r4,#8
	dbnz	r3,.0006
	pop		r4/r3
	rts

;------------------------------------------------------------------------------
; Find the highest available page number and allocate it.
;
; Returns:
;	r1 = physical page number, 0 if none available
;------------------------------------------------------------------------------

FindHiPage:
	push	r2/r3
	ldi		r1,#511*8		; start at top of map
.0002:
	lw		r2,PAM1[r1]
	com		r2,r2			; com bit pattern so we can test for all ones
	brnz	r2,.0001		; is any page free ?
	dbnz	r1,.0002		; no, try next word
	; Here we are out of memory
	mov		r1,r0
	pop		r3/r2
	rts

.0001:
	com		r2,r2			; get back positive bits
	ldi		r3,#63			; number of bits to test - 1
.0004:
	brpl	r2,.0003		; check MSB, is it clear ?
	rol		r2,r2,#1		; rotate to next bit
	dbnz	r3,.0004		; loop back
.0003:
	rol		r2,r2,#1		; make MSB the LSB
	or		r2,r2,#1		; and set bit
	rol		r2,r2,r3		; put the bits back in original place
	sw		r2,PAM1[r1]		; update word in memory

	shl		r3,r3,#13		; multiply bit # by page size
	shl		r1,r1,#19		; 
	or		r1,r1,r3		; r1 = physical address
	pop		r3/r2
	rts

AddOSPT:
	

;------------------------------------------------------------------------------
; Convert ASCII character to screen display character.
;------------------------------------------------------------------------------

AsciiToScreen:
	and		r1,r1,#$FF
	or		r1,r1,#$100
	and		fl0,r1,#%00100000	; if bit 5 or 6 isn't set
	brz		fl0,.00001
	and		fl0,r1,#%01000000
	brz		fl0,.00001
	and		r1,r1,#%110011111
.00001:
	rts

ScreenChar:
    db     
    
;------------------------------------------------------------------------------
; Convert screen display character to ascii.
;------------------------------------------------------------------------------

ScreenToAscii:
	and		r1,r1,#$FF
	cmp		fl0,r1,#26+1
	bhs		fl0,.stasc1
	add		r1,r1,#$60
.stasc1:
	rts

CursorOff:
	rts
CursorOn:
	rts
HomeCursor:
	sb		r0,CursorRow
	sb		r0,CursorCol
	sc	    r0,TEXTREG+TEXT_CURPOS+$FFD00000
	rts

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
                                                                               
ClearScreen:
    push	r1/r2/r3/r4
	lbu	    r1,TEXTREG+TEXT_COLS+$FFD00000
	lbu	    r2,TEXTREG+TEXT_ROWS+$FFD00000
	mulu	r4,r2,r1
	subui   r4,r4,#1
	ldi		r3,#TEXTSCR+$FFD00000
	ldi		r1,#' '
	bsr		AsciiToScreen
	lhu		r2,NormAttr
	or		r1,r1,r2
.cs1:
    sh	    r1,[r3+r4*4]
	dbnz	r4,.cs1
	pop		r4/r3/r2/r1
;	pop     r1
;	shr     r2,r1,#2
;	and     r2,r2,#3
;	or      r1,r1,r2
;	addui   sp,sp,#8
;	bsr     DisplayWord
;	jmp     [r1]
	rts

;------------------------------------------------------------------------------
; Randomize the color lookup table for 8bpp mode (the default), so that
; something will show on the bitmap display if it's written to.
;------------------------------------------------------------------------------

InitBMP:
	mfspr	r2,tick
	mtspr	srand1,r2
	mfspr	r2,tick
	mtspr	srand2,r2
	ldi		r2,#511
.ibmp1:
	gran	r1
	ios:sh	r1,BMP_CLUT[r0+r2*4]
	dbnz	r2,.ibmp1
	rts

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------

ClearBmpScreen:
	ldi		r1,#$400000
	ldi		r2,#$7FFFF
.0001:
	sw		r0,[r1+r2*8]
	dbnz	r2,.0001
	rts

;------------------------------------------------------------------------------
; Display the word in r1
;------------------------------------------------------------------------------

DisplayWord:
	swap	r1,r1
	bsr		DisplayHalf
	swap	r1,r1

;------------------------------------------------------------------------------
; Display the half-word in r1
;------------------------------------------------------------------------------

DisplayHalf:
	ror		r1,r1,#16
	bsr		DisplayCharHex
	rol		r1,r1,#16

;------------------------------------------------------------------------------
; Display the char in r1
;------------------------------------------------------------------------------

DisplayCharHex:
	ror		r1,r1,#8
	bsr		DisplayByte
	rol		r1,r1,#8

;------------------------------------------------------------------------------
; Display the byte in r1
;------------------------------------------------------------------------------

DisplayByte:
	ror		r1,r1,#4
	bsr		DisplayNybble
	rol		r1,r1,#4

;------------------------------------------------------------------------------
; Display nybble in r1
;------------------------------------------------------------------------------

DisplayNybble:
	push	r1
	and		r1,r1,#$0F
	add		r1,r1,#'0'
	cmp		fl0,r1,#'9'+1
	blo		fl0,.0001
	add		r1,r1,#7
.0001:
	jsr		(OutputVec)
	pop		r1
	rts

DisplayString:
	push	r1/r2
	mov		r2,r1
.dm2:
	lbu		r1,[r2]
	addui   r2,r2,#1	; increment text pointer
	brz		r1,.dm1
	bsr		OutChar
	brz		r0,.dm2
.dm1:
	pop		r2/r1
	rts

DisplayStringCRLF:
	bsr		DisplayString
OutCRLF:
CRLF:
	push	r1
	ldi		r1,#CR
	bsr		OutChar
	ldi		r1,#LF
	bsr		OutChar
	pop		r1
	rts


DispCharQ:
	bsr		AsciiToScreen
	sc		r1,[r3]
	add		r3,r3,#4
	rts

DispStartMsg:
	ldi		r1,#msgStart
	bsr		DisplayString
	rts

	db	0
msgStart:
	db	"Table888 test system starting.",0

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------

KeybdIRQ:
	sb		r0,KEYBD+1
	rti

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------

TickRout:
	ios:lh	tr,TEXTSCR+220
	add		tr,tr,#1
	ios:sh	tr,TEXTSCR+220
	rts

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------

Tick1000Rout:
	push	r1
	ldi		r1,#2				; reset the edge sense circuit
	sh		r1,PIC_RSTE
	lw		r1,Milliseconds
	add		r1,r1,#1
	sw		r1,Milliseconds
	pop		r1
	rti

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------

GetScreenLocation:
	ldi		r1,#TEXTSCR+$FFD00000
	rts
GetCurrAttr:
	lhu		r1,NormAttr
	rts

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------

UpdateCursorPos:
	push	r1/r2/r4
	lbu		r1,CursorRow
	and		r1,r1,#$3f
	lbu	r2,TEXTREG+TEXT_COLS+$FFD00000
	mul		r2,r2,r1
	lbu		r1,CursorCol
	and		r1,r1,#$7f
	add		r2,r2,r1
	sc	r2,TEXTREG+TEXT_CURPOS+$FFD00000
	pop		r4/r2/r1
	rts
	
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------

CalcScreenLoc:
	push	r2/r4
	lbu		r1,CursorRow
	and		r1,r1,#$3f
	lbu	r2,TEXTREG+TEXT_COLS+$FFD00000
	mul		r2,r2,r1
	lbu		r1,CursorCol
	and		r1,r1,#$7f
	add		r2,r2,r1
	sc	r2,TEXTREG+TEXT_CURPOS+$FFD00000
	bsr		GetScreenLocation
	shl		r2,r2,#2
	add		r1,r1,r2
	pop		r4/r2
	rts

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------

DisplayChar:
	push	r1/r2/r3/r4
	and		r1,r1,#$FF
	cmp		fl0,r1,#'\r'
	beq		fl0,.docr
	cmp		fl0,r1,#$91		; cursor right ?
	beq		fl0,.doCursorRight
	cmp		fl0,r1,#$90		; cursor up ?
	beq		fl0,.doCursorUp
	cmp		fl0,r1,#$93		; cursor left ?
	beq		fl0,.doCursorLeft
	cmp		fl0,r1,#$92		; cursor down ?
	beq		fl0,.doCursorDown
	cmp		fl0,r1,#$94		; cursor home ?
	beq		fl0,.doCursorHome
	cmp		fl0,r1,#$99		; delete ?
	beq		fl0,.doDelete
	cmp		fl0,r1,#CTRLH	; backspace ?
	beq		fl0,.doBackspace
	cmp		fl0,r1,#'\n'	; line feed ?
	beq		fl0,.doLinefeed
	mov		r2,r1
	bsr		CalcScreenLoc
	mov		r3,r1
	mov		r1,r2
	bsr		AsciiToScreen
	mov		r2,r1
	bsr		GetCurrAttr
	or		r1,r1,r2
	sh	    r1,[r3]
	bsr		IncCursorPos
.dcx4:
	pop		r4/r3/r2/r1
	rts
.docr:
	sb		r0,CursorCol
	bsr		UpdateCursorPos
	bra     .dcx4
.doCursorRight:
	lbu		r1,CursorCol
	add		r1,r1,#1
	cmp		fl0,r1,#TXTCOLS
	bhs		fl0,.dcx7
	sb		r1,CursorCol
.dcx7:
	bsr		UpdateCursorPos
	bra     .dcx4
.doCursorUp:
	lbu		r1,CursorRow
	brz		r1,.dcx7
	sub		r1,r1,#1
	sb		r1,CursorRow
	bra		.dcx7
.doCursorLeft:
	lbu		r1,CursorCol
	brz		r1,.dcx7
	sub		r1,r1,#1
	sb		r1,CursorCol
	bra		.dcx7
.doCursorDown:
	lbu		r1,CursorRow
	add		r1,r1,#1
	cmp		fl0,r1,#TXTROWS
	bhs		fl0,.dcx7
	sb		r1,CursorRow
	bra		.dcx7
.doCursorHome:
	lbu		r1,CursorCol
	brz		r1,.dcx12
	sb		r0,CursorCol
	bra		.dcx7
.dcx12:
	sb		r0,CursorRow
	bra		.dcx7
.doDelete:
	bsr		CalcScreenLoc
	mov		r3,r1
	lbu		r1,CursorCol
	bra		.dcx5
.doBackspace:
	lbu		r1,CursorCol
	brz		r1,.dcx4
	sub		r1,r1,#1
	sb		r1,CursorCol
	bsr		CalcScreenLoc
	mov		r3,r1
	lbu		r1,CursorCol
.dcx5:
	lhu	    r2,4[r3]
	sh	    r2,[r3]
	add		r3,r3,#4
	add		r1,r1,#1
	cmp		fl0,r1,#TXTCOLS
	blo		fl0,.dcx5
	ldi		r1,#' '
	bsr		AsciiToScreen
	lhu		r2,NormAttr
	or		r1,r1,r2
	sub		r3,r3,#4
	sh	    r1,[r3]
	bra		.dcx4
.doLinefeed:
	bsr		IncCursorRow
	bra		.dcx4


;------------------------------------------------------------------------------
;------------------------------------------------------------------------------

IncCursorPos:
	push	r1/r2/r4
	lbu		r1,CursorCol
	addui	r1,r1,#1
	sb		r1,CursorCol
	cmp		fl0,r1,#TXTCOLS
	blo		fl0,icc1
	sb		r0,CursorCol
	bra		icr1
IncCursorRow:
	push	r1/r2/r4
icr1:
	lbu		r1,CursorRow
	addui	r1,r1,#1
	sb		r1,CursorRow
	cmp		fl0,r1,#TXTROWS
	blo		fl0,icc1
	ldi		r2,#TXTROWS-1
	sb		r2,CursorRow
	bsr		ScrollUp
icc1:
	bsr		UpdateCursorPos
	pop		r4/r2/r1
	rts

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------

ScrollUp:
	push	r1/r2/r3/r5
	push	r6
	lbu	    r1,TEXTREG+TEXT_COLS+$FFD00000
	lbu	    r2,TEXTREG+TEXT_ROWS+$FFD00000
	sub		r2,r2,#1
	mul		r6,r1,r2
	ldi		r1,#TEXTSCR+$FFD00000
	ldi		r2,#TEXTSCR+TXTCOLS*4+$FFD00000
	ldi		r3,#0
.0001:
	lh	r5,[r2+r3*4]
	sh	r5,[r1+r3*4]
	add		r3,r3,#1
	dbnz	r6,.0001
	lbu	    r1,TEXTREG+TEXT_ROWS+$FFD00000
	sub		r1,r1,#1
	bsr		BlankLine
	pop		r6
	pop		r5/r3/r2/r1
	rts

;------------------------------------------------------------------------------
; Blank out a line on the screen.
;
; Parameters:
;	r1 = line number to blank out
;------------------------------------------------------------------------------

BlankLine:
	push	r1/r2/r3/r4
    lbu r2,TEXTREG+TEXT_COLS+$FFD00000
	mul		r3,r2,r1
	sub		r2,r2,#1		; r2 = #chars to blank - 1
	shl		r3,r3,#2
	add		r3,r3,#TEXTSCR+$FFD00000
	ldi		r1,#' '
	bsr		AsciiToScreen
	lhu		r4,NormAttr
	or		r1,r1,r4
.0001:
	sh	    r1,[r3+r2*4]
	dbnz	r2,.0001
	pop		r4/r3/r2/r1
	rts

; ============================================================================
; Monitor Task
; ============================================================================

Monitor:
	ldi		r1,#49
	sb		r1,LEDS
;	bsr		ClearScreen
;	bsr		HomeCursor
	ldi		r1,#msgMonitorStarted
	bsr		DisplayStringCRLF
	sb		r0,KeybdEcho
	;ldi		r1,#7
	;ldi		r2,#0
	;ldi		r3,#IdleTask
	;ldi		r4,#0
	;ldi		r5,#0
	;bsr		StartTask
mon1:
    ldi     r1,#$01                 ; restore data segment
    mtspr   ds,r1
	ldi		r1,#50
	sb		r1,LEDS
;	ldi		sp,#TCBs+TCB_Size-8		; reload the stack pointer, it may have been trashed
    ldi     r1,#$0E
    sei                             ; restore SS:SP
    mtspr   ss,r1
	ldi		sp,#$3FFFF8
	cli
.PromptLn:
	bsr		CRLF
	ldi		r1,#'$'
	bsr		OutChar
.Prompt3:
	bsr		KeybdGetCharNoWait		; KeybdGetCharDirectNB
	brmi	r1,.Prompt3
	cmp		fl0,r1,#CR
	beq		fl0,.Prompt1
	bsr		OutChar
	bra		.Prompt3
.Prompt1:
	sb		r0,CursorCol
	bsr		CalcScreenLoc
	mov		r3,r1
	bsr		MonGetch
	cmp		fl0,r1,#'$'
	bne		fl0,.Prompt2
	bsr		MonGetch
.Prompt2:
	cmp		fl0,r1,#'?'
	beq		fl0,.doHelp
	cmp		fl0,r1,#'C'
	beq		fl0,doCLS
	cmp     fl0,r1,#'c'
	beq     fl0,doCS
	cmp		fl0,r1,#'F'
	beq		fl0,doFillmem
	cmp		fl0,r1,#'M'
	beq		fl0,doDumpmem
	cmp		fl0,r1,#'J'
	beq		fl0,doJump
	cmp		fl0,r1,#'m'
	beq		fl0,MRTest
	cmp		fl0,r1,#'S'
	beq		fl0,doSDBoot
	cmp		fl0,r1,#'g'
	beq		fl0,doRand
	cmp		fl0,r1,#'e'
	beq		fl0,eval
	cmp		fl0,r1,#'D'
	beq		fl0,doDate
	bra mon1

.doHelp:
	ldi		r1,#msgHelp
	bsr		DisplayString
	bra mon1

MonGetch:
	lhu	    r1,[r3]
	andi	r1,r1,#$1FF
	add		r3,r3,#4
	bsr		ScreenToAscii
	rts

;------------------------------------------------------------------------------
; Ignore blanks in the input
; r3 = text pointer
; r1 destroyed
;------------------------------------------------------------------------------

ignBlanks:
ignBlanks1:
	bsr		MonGetch
	cmp		fl0,r1,#' '
	beq		fl0,ignBlanks1
	sub		r3,r3,#4
	rts

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------

GetTwoParams:
	bsr		ignBlanks
	bsr		GetHexNumber	; get start address of dump
	mov		r2,r1
	bsr		ignBlanks
	bsr		GetHexNumber	; get end address of dump
	rts

;------------------------------------------------------------------------------
; Get a range, the end must be greater or equal to the start.
;------------------------------------------------------------------------------

GetRange:
	bsr		GetTwoParams
	cmp		fl0,r2,r1
	bhi		fl0,DisplayErr
	rts

doDumpmem:
	bsr		CursorOff
	bsr		GetRange
	bsr		CRLF
.001:
	bsr		CheckKeys
	bsr		DisplayMemBytes
	cmp		fl0,r2,r1
	bls		fl0,.001
	bra mon1

;------------------------------------------------------------------------------
; Fill memory
;
; FB FFD80000 FFD8FFFF r	; fill sprite memory with random bytes
;------------------------------------------------------------------------------

doFillmem:
	bsr		CursorOff
	bsr		MonGetch		; skip over 'B' of "FB"
	cmp		fl0,r1,#'B'
	beq		fl0,.0004
	sub		r3,r3,#4		; backup text pointer
.0004:
	bsr		GetRange
	push	r1/r2
	bsr		ignBlanks
	bsr		MonGetch		; check for random fill
	cmp		fl0,r1,#'r'
	beq		fl0,.0001
	sub		r3,r3,#4
	bsr		GetHexNumber
	mov		r3,r1
	pop		r2/r1
.0002:
	bsr		CheckKeys
	sb		r3,[r2]
	add		r2,r2,#1
	cmp		fl0,r2,r1
	blo		fl0,.0002
	bra		mon1
.0001:
	pop		r2/r1
.0003:
	bsr		CheckKeys
	gran	r3
	sb		r3,[r2]
	add		r2,r2,#1
	cmp		fl0,r2,r1
	blo		fl0,.0003
	bra		mon1

doSDBoot:
;	sub		r3,r3,#4
	bsr		SDInit
	brnz	r1,mon1
	bsr		SDReadPart
	brnz	r1,mon1
	bsr		SDReadBoot
	brnz	r1,mon1
	bsr		loadBootFile
	jmp		mon1

OutChar:
	jmp		(OutputVec)

doRand:
	mfspr	r1,tick
	mtspr	srand1,r1
	mfspr	r1,tick
	mtspr	srand2,r1
.0001:
	gran	r1
	bsr		DisplayWord
	bsr		CRLF
	bsr		CheckKeys
	bra .0001

doJump:
	bsr		MonGetch		; skip over 'S'
	bsr		ignBlanks
	bsr		GetHexNumber
	jsr		[r1]
	bra		mon1

doCS:
    mfspr   r1,cs
    bsr     DisplayHalf
    bsr     CRLF
    bra     mon1

doDate:
	bsr		MonGetch		; skip over 'T'
	cmp		fl0,r1,#'A'		; look for DAY
	beq		fl0,doDay
	bsr		ignBlanks
	bsr		MonGetch
	cmp		fl0,r1,#'?'
	beq		fl0,.0001
	sub		r3,r3,#4
	bsr		GetHexNumber
	sb		r1,RTCC_BUF+5	; update month
	bsr		GetHexNumber
	sb		r1,RTCC_BUF+4	; update day
	bsr		GetHexNumber
	sb		r1,RTCC_BUF+6	; update year
	bsr		RTCCWritebuf
	bra		mon1
.0001:
	bsr		RTCCReadbuf
	bsr		CRLF
	lbu		r1,RTCC_BUF+5
	bsr		DisplayByte
	ldi		r1,#'/'
	bsr		OutChar
	lbu		r1,RTCC_BUF+4
	bsr		DisplayByte
	ldi		r1,#'/'
	bsr		OutChar
	lbu		r1,RTCC_BUF+6
	bsr		DisplayByte
	bsr		CRLF
	bra		mon1

doDay:
	bsr		ignBlanks
	bsr		GetHexNumber
	mov		r3,r1			; value to write
	ldi		r1,#$6F			; device $6F
	ldi		r2,#$03			; register 3
	bsr		I2C_WRITE
	bra		mon1

;------------------------------------------------------------------------------
; Display memory pointed to by r2.
; destroys r1,r3
;------------------------------------------------------------------------------
;
DisplayMemBytes:
	push	r1/r3
	ldi		r1,#'>'
	bsr		OutChar
	ldi		r1,#'B'
	bsr		OutChar
	ldi		r1,#' '
	bsr		OutChar
	mov		r1,r2
	bsr		DisplayHalf
	ldi		r3,#7
.001:
	ldi		r1,#' '
	bsr		OutChar
	lbu		r1,[r2]
	jsr		DisplayByte
	add		r2,r2,#1
	dbnz	r3,.001
	ldi		r1,#':'
	bsr		OutChar
	ldi		r1,#%110101110_000000100_0000000000	; reverse video
	sh		r1,NormAttr
	ldi		r3,#7
	sub		r2,r2,#8
.002
	lbu		r1,[r2]
	cmp		fl0,r1,#26				; convert control characters to '.'
	bhs		fl0,.004
	ldi		r1,#'.'
	bra .003
.004:
	cmp		fl0,r1,#$80				; convert other non-ascii to '.'
	blo		fl0,.003
	ldi		r1,#'.'
.003:
	bsr		OutChar
	add		r2,r2,#1
	dbnz	r3,.002
	ldi		r1,#%000000100_110101110_0000000000	; normal video
	sh		r1,NormAttr
	bsr		CRLF
	pop		r3/r1
	rts

;------------------------------------------------------------------------------
; CheckKeys:
;	Checks for a CTRLC or a scroll lock during long running dumps.
;------------------------------------------------------------------------------

CheckKeys:
	bsr		CTRLCCheck
	bra CheckScrollLock

;------------------------------------------------------------------------------
; CTRLCCheck
;	Checks to see if CTRL-C is pressed. If so then the current routine is
; aborted and control is returned to the monitor.
;------------------------------------------------------------------------------

CTRLCCheck:
	push	r1
	bsr		KeybdGetCharNoWait
	cmp		fl0,r1,#CTRLC
	beq		fl0,.0001
	pop		r1
	rts
.0001:
	add		sp,sp,#16
	bra mon1

;------------------------------------------------------------------------------
; CheckScrollLock:
;	Check for a scroll lock by the user. If scroll lock is active then tasks
; are rescheduled while the scroll lock state is tested in a loop.
;------------------------------------------------------------------------------

CheckScrollLock:
	push	r1
.0002:
	lcu		r1,KeybdLocks
	and		fl0,r1,#$4000		; is scroll lock active ?
	brz		fl0,.0001
	brk		#2*16				; reschedule tasks
	bra .0002
.0001:
	pop		r1
	rts

;------------------------------------------------------------------------------
; Get a hexidecimal number. Maximum of eight digits.
; R3 = text pointer (updated)
; R1 = hex number
;------------------------------------------------------------------------------
;
GetHexNumber:
	push	r2/r4
	ldi		r2,#0
	ldi		r4,#15
.gthxn2:
	bsr		MonGetch
	bsr		AsciiToHexNybble
	cmp		fl0,r1,#-1
	beq		fl0,.gthxn1
	shl		r2,r2,#4
	and		r1,r1,#$0f
	or		r2,r2,r1
	dbnz	r4,.gthxn2
.gthxn1:
	mov		r1,r2
	pop		r4/r2
	rts

;------------------------------------------------------------------------------
; Convert ASCII character in the range '0' to '9', 'a' to 'f' or 'A' to 'F'
; to a hex nybble.
;------------------------------------------------------------------------------
;
AsciiToHexNybble:
	cmp		fl0,r1,#'0'
	blo		fl0,.gthx3
	cmp		fl0,r1,#'9'+1
	bhs		fl0,.gthx5
	sub		r1,r1,#'0'
	rts
.gthx5:
	cmp		fl0,r1,#'A'
	blo		fl0,.gthx3
	cmp		fl0,r1,#'F'+1
	bhs		fl0,.gthx6
	sub		r1,r1,#'A'
	add		r1,r1,#10
	rts
.gthx6:
	cmp		fl0,r1,#'a'
	blo		fl0,.gthx3
	cmp		fl0,r1,#'z'+1
	bhs		fl0,.gthx3
	sub		r1,r1,#'a'
	add		r1,r1,#10
	rts
.gthx3:
	ldi		r1,#-1		; not a hex number
	rts

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
eval:
	bsr		ignBlanks
	bsr		GetHexNumber
	mtfp	fp1,r1
	fix2flt	fp1,fp1
	mffp	r1,fp1
	bsr		DisplayWord
	bsr		OutCRLF
	bsr		ignBlanks
	bsr		MonGetch
	push	r1
	bsr		ignBlanks
	bsr		GetHexNumber
	mtfp	fp2,r1
	fix2flt	fp2,fp2
	mffp	r1,fp2
	bsr		DisplayWord
	bsr		OutCRLF
	pop		r1
	cmp		fl0,r1,#'+'
	beq		fl0,.doPlus
	cmp		fl0,r1,#'-'
	beq		fl0,.doMinus
	cmp		fl0,r1,#'*'
	beq		fl0,.doMult
	cmp		fl0,r1,#'/'
	beq		fl0,.doDiv
	bra		DisplayErr
.doPlus:
	fadd	fp3,fp2,fp1
	bra		.dumpRes
.doMinus:
	fsub	fp3,fp1,fp2
	bra		.dumpRes
.doMult:
	fmul	fp3,fp1,fp2
	bra		.dumpRes
.doDiv:
	fdiv	fp3,fp1,fp2
	bra		.dumpRes
.dumpRes:
	flt2fix	fp3,fp3
	mffp	r1,fp3
	bsr		DisplayWord
	bsr		OutCRLF
	bra		mon1
	
DisplayErr:
	ldi		r1,#msgErr
	bsr		DisplayString
	bra mon1

msgErr:
	db	"**Err",CR,LF,0

msgHelp:
	db		"? = Display Help",CR,LF
	db		"CLS = clear screen",CR,LF
	db		"DT = set/read date",CR,LF
	db		"FB = fill memory",CR,LF
	db		"MB = dump memory",CR,LF
	db		"JS = jump to code",CR,LF
	db		"S = boot from SD card",CR,LF
	db		0

msgMonitorStarted
	db		"Monitor started.",0

doCLS:
	bsr		ClearScreen
	bsr		HomeCursor
	bra mon1

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
; Keyboard processing routines follow.
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------

KEYBD_DELAY		EQU		1000

KeybdGetCharDirectNB:
	push	r2
	sei
	mfspr	r1,cr0			; turn off tmr for i/o
	push	r1
	ldi		r1,#0
	mtspr	cr0,r1
	lcu		r1,KEYBD
	and		fl0,r1,#$8000
	brz		fl0,.0001
	lbu		r0,KEYBD+4		; clear keyboard strobe
	cli
	and		fl0,r1,#$800	; is it keydown ?
	brnz	fl0,.0001
	pop		r2
	mtspr	cr0,r2			; set tmr mode back
	and		r1,r1,#$FF
	lbu		r2,KeybdEcho
	brz		r2,.0002
	cmp		fl0,r1,#CR
	bne		fl0,.0003
	bsr		CRLF
	bra .0002
.0003:
	jsr		(OutputVec)
.0002:
	pop		r2
	rts
.0001:
	pop		r2
	mtspr	cr0,r2			; set tmr mode back
	cli
	ldi		r1,#-1
	pop		r2
	rts

KeybdGetCharDirect:
	push	r2
	mfspr	r1,cr0
	push	r1
	mtspr	cr0,r0			; clear tmr mode
.0001:
	lc		r1,KEYBD
	and		fl0,r1,#$8000
	brz		fl0,.0001
	lbu		r0,KEYBD+4		; clear keyboard strobe
	and		fl0,r1,#$800	; is it keydown ?
	brnz	fl0,.0001
	pop		r2				; restore tmr mode
	mtspr	cr0,r2
	and		r1,r1,#$FF
	lbu		r2,KeybdEcho
	brz		r2,.gk1
	cmp		fl0,r1,#CR
	bne		fl0,.gk2
	bsr		CRLF
	bra .gk1
.gk2:
	jsr		(OutputVec)
.gk1:
	pop		r2
	rts

;KeybdInit:
;	mfspr	r1,cr0		; turn off tmr mode
;	push	r1
;	mtspr	cr0,r0
;	ldi		r1,#33
;	sb		r1,LEDS
;	bsr		WaitForKeybdAck	; grab a byte from the keyboard
;	cmp		flg0,r1,#$AA	; did it send a ack ?
;	
;	ldi		r1,#$ff			; issue keyboard reset
;	bsr		SendByteToKeybd
;	ldi		r1,#38
;	sb		r1,LEDS
;	ldi		r1,#4
;	jsr		Sleep
;	ldi		r1,#KEYBD_DELAY	; delay a bit
kbdi5:
;	sub		r1,r1,#1
;	brnz	r1,kbdi5
;	ldi		r1,#34
;	sb		r1,LEDS
;	ldi		r1,#0xf0		; send scan code select
;	bsr		SendByteToKeybd
;	ldi		r1,#35
;	sb		r1,LEDS
;	ldi		r2,#0xFA
;	bsr		WaitForKeybdAck
;	cmp		fl0,r1,#$FA
;	bne		fl0,kbdi2
;	ldi		r1,#36
;	sb		r1,LEDS
;	ldi		r1,#2			; select scan code set#2
;	bsr		SendByteToKeybd
;	ldi		r1,#39
;	sb		r1,LEDS
;kbdi2:
;	ldi		r1,#45
;	sb		r1,LEDS
;	pop		r1				; turn back on tmr mode
;	mtspr	cr0,r1
;	rts

msgBadKeybd:
	db		"Keyboard not responding.",0

;SendByteToKeybd:
;	push	r2
;	sb		r1,KEYBD
;	ldi		r1,#40
;	sb		r1,LEDS
;	mfspr	r3,tick
;kbdi4:						; wait for transmit complete
;	mfspr	r4,tick
;	sub		r4,r4,r3
;	cmp		fl0,r4,#KEYBD_DELAY
;	bhi		fl0,kbdbad
;	ldi		r1,#41
;	sb		r1,LEDS
;	lbu		r1,KEYBD+1
;	and		fl0,r1,#64
;	brz		fl0,kbdi4
;	bra 	sbtk1
;kbdbad:
;	ldi		r1,#42
;	sb		r1,LEDS
;	lbu		r1,KeybdBad
;	brnz	r1,sbtk2
;	ldi		r1,#1
;	sb		r1,KeybdBad
;	ldi		r1,#43
;	sb		r1,LEDS
;	ldi		r1,#msgBadKeybd
;	bsr		DisplayStringCRLF
;sbtk1:
;	ldi		r1,#44
;	sb		r1,LEDS
;	pop		r2
;	rts
;sbtk2:
;	bra sbtk1

; Wait for keyboard to respond with an ACK (FA)
;
;WaitForKeybdAck:
;	ldi		r1,#64
;	sb		r1,LEDS
;	mfspr	r3,tick
;wkbdack1:
;	mfspr	r4,tick
;	sub		r4,r4,r3
;	cmp		fl0,r4,#KEYBD_DELAY
;	bhi		fl0,wkbdbad
;	ldi		r1,#65
;	sb		r1,LEDS
;	lb		r1,KEYBD+1				; check keyboard status for key
;	brpl	r1,wkbdack1				; no key available, go back
;	lbu		r1,KEYBD				; get the scan code
;	sb		r0,KEYBD+1				; clear recieve register
;wkbdbad:
;	rts

KeybdInit:
	ldi		r3,#5
.0001:
	bsr		KeybdRecvByte	; Look for $AA
	bmi		r1,.0002
	cmp		fl0,r1,#$AA		;
	beq		fl0,.config
.0002:
	bsr		Wait10ms
	ldi		r1,#-1			; send reset code to keyboard
	sb		r1,KEYBD+1		; write to status reg to clear TX state
	bsr		Wait10ms
	ldi		r1,#$FF
	bsr		KeybdSendByte	; now write to transmit register
	bsr		KeybdWaitTx		; wait until no longer busy
	bsr		KeybdRecvByte	; look for an ACK ($FA)
	cmp		fl0,r1,#$FA
	bsr		KeybdRecvByte
	cmp		fl0,r1,#$FC		; reset error ?
	beq		fl0,.tryAgain
	cmp		fl0,r1,#$AA		; reset complete okay ?
	bne		fl0,.tryAgain
.config:
	ldi		r1,#$F0			; send scan code select
	sb		r1,LEDS
	bsr		KeybdSendByte
	bsr		KeybdWaitTx
	bmi		r1,.tryAgain
	bsr		KeybdRecvByte	; wait for response from keyboard
	bmi		r1,.tryAgain
	cmp		fl0,r1,#$FA
	beq		fl0,.0004
.tryAgain:
	dbnz	r3,.0001
.keybdErr:
	ldi		r1,#msgBadKeybd
	bsr		DisplayString
	rts
.0004:
	ldi		r1,#2			; select scan code set #2
	bsr		KeybdSendByte
	bsr		KeybdWaitTx
	bmi		r1,.tryAgain
	rts

; Get the keyboard status
;
KeybdGetStatus:
	push	r2
	mfspr	r2,cr0			; turn off tmr mode
	push	r2
	mtspr	cr0,r0
	lb		r1,KEYBD+1
	pop		r2
	mtspr	cr0,r2			; restore TMR
	pop		r2
	rts

; Get the scancode from the keyboard port
;
KeybdGetScancode:
	push	r2
	mfspr	r2,cr0					; turn off tmr mode
	push	r2
	mtspr	cr0,r0
	lbu		r1,KEYBD				; get the scan code
	sb		r0,KEYBD+1				; clear receive register
	pop		r2
	mtspr	cr0,r2					; restore TMR
	pop		r2
	rts

; Recieve a byte from the keyboard, used after a command is sent to the
; keyboard in order to wait for a response.
;
KeybdRecvByte:
	push	r3
	ldi		r3,#100			; wait up to 1s
.0003:
	bsr		KeybdGetStatus	; wait for response from keyboard
	bmi		r1,.0004		; is input buffer full ? yes, branch
	bsr		Wait10ms		; wait a bit
	dbnz	r3,.0003		; go back and try again
	pop		r3				; timeout
	ldi		r1,#-1			; return -1
	rts
.0004:
	bsr		KeybdGetScancode
	pop		r3
	rts


; Wait until the keyboard transmit is complete
; Returns .CF = 1 if successful, .CF=0 timeout
;
KeybdWaitTx:
	push	r2/r3
	ldi		r3,#100			; wait a max of 1s
.0001:
	bsr		KeybdGetStatus
	and		r1,r1,#$40		; check for transmit complete bit
	brnz	r1,.0002		; branch if bit set
	bsr		Wait10ms		; delay a little bit
	dbnz	r3,.0001		; go back and try again
	pop		r3/r2			; timed out
	ldi		r1,#-1			; return -1
	rts
.0002:
	pop		r3/r2			; wait complete, return 
	ldi		r1,#0			; return 0
	rts

KeybdGetCharNoWait:
	sb		r0,KeybdWaitFlag
	bra		KeybdGetChar

KeybdGetCharWait:
	ldi		r1,#-1
	sb		r1,KeybdWaitFlag
	
KeybdGetChar:
	push	r2/r3
.0003:
	bsr		KeybdGetStatus			; check keyboard status for key available
	bmi		r1,.0006				; yes, go process
	lb		r1,KeybdWaitFlag		; are we willing to wait for a key ?
	bmi		r1,.0003				; yes, branch back
	ldi		r1,#-1					; flag no char available
	pop		r3/r2
	rts
.0006:
	bsr		KeybdGetScancode
.0001:
	ldi		r2,#1
	sb		r2,LEDS
	cmp		fl0,r1,#SC_KEYUP
	beq		fl0,.doKeyup
	cmp		fl0,r1,#SC_EXTEND
	beq		fl0,.doExtend
	cmp		fl0,r1,#$14				; code for CTRL
	beq		fl0,.doCtrl
	cmp		fl0,r1,#$12				; code for left shift
	beq		fl0,.doShift
	cmp		fl0,r1,#$59				; code for right-shift
	beq		fl0,.doShift
	cmp		fl0,r1,#SC_NUMLOCK
	beq		fl0,.doNumLock
	cmp		fl0,r1,#SC_CAPSLOCK
	beq		fl0,.doCapsLock
	cmp		fl0,r1,#SC_SCROLLLOCK
	beq		fl0,.doScrolllock
	lb		r2,KeyState1			; check key up/down
	sb		r0,KeyState1			; clear keyup status
	brnz	r2,.0003				; ignore key up
	lb		r2,KeyState2
	and		r3,r2,#$80				; is it extended code ?
	brz		r3,.0010
	and		r3,r2,#$7f				; clear extended bit
	sb		r3,KeyState2
	sb		r0,KeyState1			; clear keyup
	lbu		r1,keybdExtendedCodes[r1]
	bra		.0008
.0010:
	lb		r2,KeyState2
	and		r3,r2,#$04				; is it CTRL code ?
	brz		r3,.0009
	and		r1,r1,#$7F
	lbu		r1,keybdControlCodes[r1]
	bra		.0008
.0009:
	lb		r2,KeyState2
	and		r3,r2,#$01				; is it shift down ?
	brz		r3,.0007
	lbu		r1,shiftedScanCodes[r1]
	bra		.0008
.0007:
	lbu		r1,unshiftedScanCodes[r1]
	ldi		r2,#2
	sb		r2,LEDS
.0008:
	ldi		r2,#3
	sb		r2,LEDS
	pop		r3/r2
	rts
.doKeyup:
	ldi		r1,#-1
	sb		r1,KeyState1
	bra		.0003
.doExtend:
	lbu		r1,KeyState2
	or		r1,r1,#$80
	sb		r1,KeyState2
	bra		.0003
.doCtrl:
	lb		r1,KeyState1
	sb		r0,KeyState1
	bpl		r1,.0004
	lb		r1,KeyState2
	and		r1,r1,#-5
	sb		r1,KeyState2
	bra		.0003
.0004:
	lb		r1,KeyState2
	or		r1,r1,#4
	sb		r1,KeyState2
	bra		.0003
.doShift:
	lb		r1,KeyState1
	sb		r0,KeyState1
	bpl		r1,.0005
	lb		r1,KeyState2
	and		r1,r1,#-2
	sb		r1,KeyState2
	bra		.0003
.0005:
	lb		r1,KeyState2
	or		r1,r1,#1
	sb		r1,KeyState2
	bra		.0003
.doNumLock:
	lb		r1,KeySTate2
	eor		r1,r1,#16
	sb		r1,KeyState2
	bsr		KeybdSetLEDStatus
	bra		.0003
.doCapsLock:
	lb		r1,KeyState2
	eor		r1,r1,#32
	sb		r1,KeyState2
	bsr		KeybdSetLEDStatus
	bra		.0003
.doScrollLock:
	lb		r1,KeyState2
	eor		r1,r1,#64
	sb		r1,KeyState2
	bsr		KeybdSetLEDStatus
	bra		.0003

KeybdSetLEDStatus:
	push	r2/r3
	sb		r0,KeybdLEDs
	lb		r1,KeyState2
	and		r2,r1,#16
	brz		r2,.0002
	ldi		r3,#2
	sb		r3,KeybdLEDs
.0002:
	and		r2,r1,#32
	brz		r2,.0003
	lb		r3,KeybdLEDs
	or		r3,r3,#4
	sb		r3,KeybdLEDs
.0003:
	and		r2,r1,#64
	brz		r2,.0004
	lb		r3,KeybdLEDs
	or		r3,r3,#1
	sb		r3,KeybdLEDs
.0004:
	ldi		r1,#$ED
	bsr		KeybdSendByte
	bsr		KeybdWaitTx
	bsr		KeybdRecvByte
	bmi		r1,.0001
	cmp		fl0,r1,#$FA
	lb		r1,KeybdLEDs
	bsr		KeybdSendByte
	bsr		KeybdWaitTx
	bsr		KeybdRecvByte
.0001:
	pop		r3/r2
	rts

KeybdSendByte:
	push	r2
	mfspr	r2,cr0		; turn off tmr mode
	push	r2
	mtspr	cr0,r0
	sb		r1,KEYBD
	pop		r2
	mtspr	cr0,r2
	pop		r2
	rts
	
Wait10ms:
	push	r3/r4
	mfspr	r3,tick					; get orginal count
.0001:
	mfspr	r4,tick
	sub		r4,r4,r3
	brmi	r4,.0002				; shouldn't be -ve unless counter overflowed
	cmp		fl0,r4,#250000			; about 10ms at 25 MHz
	blo		fl0,.0001
.0002:
	pop		r4/r3
	rts

	;--------------------------------------------------------------------------
	; PS2 scan codes to ascii conversion tables.
	;--------------------------------------------------------------------------
	;
	align	16
unshiftedScanCodes:
	.byte	$2e,$a9,$2e,$a5,$a3,$a1,$a2,$ac
	.byte	$2e,$aa,$a8,$a6,$a4,$09,$60,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$71,$31,$2e
	.byte	$2e,$2e,$7a,$73,$61,$77,$32,$2e
	.byte	$2e,$63,$78,$64,$65,$34,$33,$2e
	.byte	$2e,$20,$76,$66,$74,$72,$35,$2e
	.byte	$2e,$6e,$62,$68,$67,$79,$36,$2e
	.byte	$2e,$2e,$6d,$6a,$75,$37,$38,$2e
	.byte	$2e,$2c,$6b,$69,$6f,$30,$39,$2e
	.byte	$2e,$2e,$2f,$6c,$3b,$70,$2d,$2e
	.byte	$2e,$2e,$27,$2e,$5b,$3d,$2e,$2e
	.byte	$ad,$2e,$0d,$5d,$2e,$5c,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$08,$2e
	.byte	$2e,$95,$2e,$93,$94,$2e,$2e,$2e
	.byte	$98,$7f,$92,$2e,$91,$90,$1b,$af
	.byte	$ab,$2e,$97,$2e,$2e,$96,$ae,$2e

	.byte	$2e,$2e,$2e,$a7,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$fa,$2e,$2e,$2e,$2e,$2e

shiftedScanCodes:
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$09,$7e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$51,$21,$2e
	.byte	$2e,$2e,$5a,$53,$41,$57,$40,$2e
	.byte	$2e,$43,$58,$44,$45,$24,$23,$2e
	.byte	$2e,$20,$56,$46,$54,$52,$25,$2e
	.byte	$2e,$4e,$42,$48,$47,$59,$5e,$2e
	.byte	$2e,$2e,$4d,$4a,$55,$26,$2a,$2e
	.byte	$2e,$3c,$4b,$49,$4f,$29,$28,$2e
	.byte	$2e,$3e,$3f,$4c,$3a,$50,$5f,$2e
	.byte	$2e,$2e,$22,$2e,$7b,$2b,$2e,$2e
	.byte	$2e,$2e,$0d,$7d,$2e,$7c,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$08,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$7f,$2e,$2e,$2e,$2e,$1b,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e

	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e

; control
keybdControlCodes:
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$09,$7e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$11,$21,$2e
	.byte	$2e,$2e,$1a,$13,$01,$17,$40,$2e
	.byte	$2e,$03,$18,$04,$05,$24,$23,$2e
	.byte	$2e,$20,$16,$06,$14,$12,$25,$2e
	.byte	$2e,$0e,$02,$08,$07,$19,$5e,$2e
	.byte	$2e,$2e,$0d,$0a,$15,$26,$2a,$2e
	.byte	$2e,$3c,$0b,$09,$0f,$29,$28,$2e
	.byte	$2e,$3e,$3f,$0c,$3a,$10,$5f,$2e
	.byte	$2e,$2e,$22,$2e,$7b,$2b,$2e,$2e
	.byte	$2e,$2e,$0d,$7d,$2e,$7c,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$08,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$7f,$2e,$2e,$2e,$2e,$1b,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e

keybdExtendedCodes:
	.byte	$2e,$2e,$2e,$2e,$a3,$a1,$a2,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$2e,$2e,$2e,$2e,$2e,$2e,$2e
	.byte	$2e,$95,$2e,$93,$94,$2e,$2e,$2e
	.byte	$98,$99,$92,$2e,$91,$90,$2e,$2e
	.byte	$2e,$2e,$97,$2e,$2e,$96,$2e,$2e

	align	16
MRTest:
	ldi		r1,#0
	ldi		r3,#255
.0001:
    shl     r4,r3,#3
	sw		r3,$100000[r0+r4]
	dbnz	r3,.0001
	ldi		r1,#$100000
	lmr		r2,r255,[r1]
	ldi		r1,#$120000
	smr		r2,r255,[r1]
	jmp		mon1
		
; ============================================================================
; ============================================================================
;------------------------------------------------------------------------------
; Initialize the SD card
; Returns
; acc = 0 if successful, 1 otherwise
; Z=1 if successful, otherwise Z=0
;------------------------------------------------------------------------------
;
SDInit:
	push	r2
	mfspr	r2,cr0		; turn off tmr
	push	r2
	mtspr	cr0,r0
	ldi		r2,#SPIMASTER
	ldi		r1,#SPI_INIT_SD
	sb		r1,SPI_TRANS_TYPE_REG[r2]
	ldi		r1,#SPI_TRANS_START
	sb		r1,SPI_TRANS_CTRL_REG[r2]
	nop
.spi_init1
	lbu		r1,SPI_TRANS_STATUS_REG[r2]
	bsr		spi_delay
	cmp		fl0,r1,#SPI_TRANS_BUSY
	beq		fl0,.spi_init1
	lbu		r1,SPI_TRANS_ERROR_REG[r2]
	and		r1,r1,#3
	cmp		fl0,r1,#SPI_INIT_NO_ERROR
	bne		fl0,.spi_error
;	lda		#spi_init_ok_msg
;	jsr		DisplayStringB
	pop		r2
	mtspr	cr0,r2
	pop		r2
	ldi		r1,#E_Ok
	rts
.spi_error
	bsr		DisplayByte
	ldi		r1,#spi_init_error_msg
	bsr		DisplayString
	lbu		r1,SPI_RESP_BYTE1[r2]
	bsr		DisplayByte
	lbu		r1,SPI_RESP_BYTE2[r2]
	bsr		DisplayByte
	lbu		r1,SPI_RESP_BYTE3[r2]
	bsr		DisplayByte
	lbu		r1,SPI_RESP_BYTE4[r2]
	bsr		DisplayByte
	pop		r2
	mtspr	cr0,r2
	pop		r2
	ldi		r1,#1
	rts

spi_delay:
	nop
	nop
	rts


;------------------------------------------------------------------------------
; SD read sector
;
; r1= sector number to read
; r2= address to place read data
; Returns:
; r1 = 0 if successful
;------------------------------------------------------------------------------
;
SDReadSector:
	push	r2/r3/r4/r5
	push	r6
	mfspr	r6,cr0
	mtspr	cr0,r0
	ldi		r5,#SPIMASTER	
	sb		r1,SPI_SD_SECT_7_0_REG[r5]
	shr		r1,r1,#8
	sb		r1,SPI_SD_SECT_15_8_REG[r5]
	shr		r1,r1,#8
	sb		r1,SPI_SD_SECT_23_16_REG[r5]
	shr		r1,r1,#8
	sb		r1,SPI_SD_SECT_31_24_REG[r5]

	ldi		r4,#19	; retry count

.spi_read_retry:
	; Force the reciever fifo to be empty, in case a prior error leaves it
	; in an unknown state.
	ldi		r1,#1
	sb		r1,SPI_RX_FIFO_CTRL_REG[r5]

	ldi		r1,#RW_READ_SD_BLOCK
	sb		r1,SPI_TRANS_TYPE_REG[r5]
	ldi		r1,#SPI_TRANS_START
	sb		r1,SPI_TRANS_CTRL_REG[r5]
	nop
.spi_read_sect1:
	lbu		r1,SPI_TRANS_STATUS_REG[r5]
	bsr		spi_delay			; just a delay between consecutive status reg reads
	cmp		fl0,r1,#SPI_TRANS_BUSY
	beq		fl0,.spi_read_sect1
	lbu		r1,SPI_TRANS_ERROR_REG[r5]
	shr		r1,r1,#2
	and		r1,r1,#3
	cmp		fl0,r1,#SPI_READ_NO_ERROR
	bne		fl0,.spi_read_error
	ldi		r3,#511		; read 512 bytes from fifo
.spi_read_sect2:
	lbu		r1,SPI_RX_FIFO_DATA_REG[r5]
	mtspr	cr0,r6
	sb		r1,[r2]		; store byte in buffer using tmr
	mtspr	cr0,r0
	add		r2,r2,#1
	dbnz	r3,.spi_read_sect2
	ldi		r1,#0
	bra		.spi_read_ret
.spi_read_error:
	dbnz	r4,.spi_read_retry
	bsr		DisplayByte
	ldi		r1,#spi_read_error_msg
	bsr		DisplayString
	ldi		r1,#1
.spi_read_ret:
	mtspr	cr0,r6
	pop		r6
	pop		r5/r4/r3/r2
	rts

;------------------------------------------------------------------------------
; BlocksToSectors:
;	Convert a logical block number (LBA) to a sector number
;------------------------------------------------------------------------------

BlocksToSectors:
	shl		r1,r1,#1			; 1k blocks = 2 sectors
	rts

;------------------------------------------------------------------------------
; SDReadBlocks:
;
; Registers Affected: r1-r5
; Parameters:
;	r1 = pointer to DCB
;	r3 = block number
;	r4 = number of blocks
;	r5 = pointer to data area
;------------------------------------------------------------------------------

SDReadBlocks:
	rts

;------------------------------------------------------------------------------
; SDWriteBlocks:
;
; Parameters:
;	r1 = pointer to DCB
;	r3 = block number
;	r4 = number of blocks
;	r5 = pointer to data area
;------------------------------------------------------------------------------

SDWriteBlocks:
	rts

;------------------------------------------------------------------------------
; SDWriteSector:
;
; r1= sector number to write
; r2= address to get data from
; Returns:
; r1 = 0 if successful
;------------------------------------------------------------------------------
;
SDWriteSector:
	push	r2/r3/r4/r5
	push	r1
	mfspr	r5,cr0
	mtspr	cr0,r0
	ldi		r4,#SPIMASTER

	; Force the transmitter fifo to be empty, in case a prior error leaves it
	; in an unknown state.
	ldi		r1,#1
	sb		r1,SPI_TX_FIFO_CTRL_REG[r4]
	nop			; give I/O time to respond
	nop

	; now fill up the transmitter fifo
	ldi		r3,#511
.spi_write_sect1:
	mtspr	cr0,r5
	lbu		r1,[r2]
	mtspr	cr0,r0
	sb		r1,SPI_TX_FIFO_DATA_REG[r4]
	nop			; give the I/O time to respond
	nop
	add		r2,r2,#1
	dbnz	r3,.spi_write_sect1

	; set the sector number in the spi master address registers
	pop		r1
	sb		r1,SPI_SD_SECT_7_0_REG[r4]
	shr		r1,r1,#8
	sb		r1,SPI_SD_SECT_15_8_REG[r4]
	shr		r1,r1,#8
	sb		r1,SPI_SD_SECT_23_16_REG[r4]
	shr		r1,r1,#8
	sb		r1,SPI_SD_SECT_31_24_REG[r4]

	; issue the write command
	ldi		r1,#RW_WRITE_SD_BLOCK
	sb		r1,SPI_TRANS_TYPE_REG[r4]
	ldi		r1,#SPI_TRANS_START
	sb		r1,SPI_TRANS_CTRL_REG[r4]
	nop
.spi_write_sect2:
	lbu		r1,SPI_TRANS_STATUS_REG[r4]
	nop							; just a delay between consecutive status reg reads
	nop
	cmp		fl0,r1,#SPI_TRANS_BUSY
	beq		fl0,.spi_write_sect2
	lbu		r1,SPI_TRANS_ERROR_REG[r4]
	shr		r1,r1,#4
	and		r1,r1,#3
	cmp		fl0,r1,#SPI_WRITE_NO_ERROR
	bne		fl0,.spi_write_error
	ldi		r1,#0
	bra		.spi_write_ret
.spi_write_error:
	bsr		DisplayByte
	ldi		r1,#spi_write_error_msg
	bsr		DisplayString
	ldi		r1,#1

.spi_write_ret:
	mtspr	cr0,r5
	pop		r5/r4/r3/r2
	rts

;------------------------------------------------------------------------------
; SDReadMultiple: read multiple sectors
;
; r1= sector number to read
; r2= address to write data
; r3= number of sectors to read
;
; Returns:
; r1 = 0 if successful
;
;------------------------------------------------------------------------------

SDReadMultiple:
	push	r4
	ldi		r4,#0
.spi_rm1:
	push	r1
	bsr		SDReadSector
	add		r4,r4,r1
	add		r2,r2,#512
	pop		r1
	add		r1,r1,#1
	sub		r3,r3,#1
	brnz	r3,.spi_rm1
	mov		r1,r4
	pop		r4
	rts

;------------------------------------------------------------------------------
; SD write multiple sector
;
; r1= sector number to write
; r2= address to get data from
; r3= number of sectors to write
;
; Returns:
; r1 = 0 if successful
;------------------------------------------------------------------------------
;
SDWriteMultiple:
	push	r4
	ldi		r4,#0
.spi_wm1:
	push	r1
	bsr		SDWriteSector
	add		r4,r4,r1		; accumulate an error count
	add		r2,r2,#512		; 512 bytes per sector
	pop		r1
	add		r1,r1,#1
	sub		r3,r3,#1
	brnz	r3,.spi_wm1
	mov		r1,r4
	pop		r4
	rts
	
;------------------------------------------------------------------------------
; read the partition table to find out where the boot sector is.
; Returns
; r1 = 0 everything okay, 1=read error
; also Z=1=everything okay, Z=0=read error
;------------------------------------------------------------------------------

SDReadPart:
	push	r2/r3
	sh		r0,startSector					; default starting sector
	ldi		r1,#0							; r1 = sector number (#0)
	ldi		r2,#BYTE_SECTOR_BUF				; r2 = target address (word to byte address)
	bsr		SDReadSector
	brnz	r1,.spi_rp1
	lcu		r1,BYTE_SECTOR_BUF+$1C8
	lcu		r3,BYTE_SECTOR_BUF+$1C6
	shl		r1,r1,#16
	or		r1,r1,r3
	sh		r1,startSector					; r1 = 0, for okay status
	bsr		DisplayHalf
	bsr		CRLF
	lcu		r1,BYTE_SECTOR_BUF+$1CC
	lcu		r3,BYTE_SECTOR_BUF+$1CA
	shl		r1,r1,#16
	or		r1,r1,r3
	sh		r1,disk_size					; r1 = 0, for okay status
	bsr		DisplayHalf
	bsr		CRLF
	pop		r3/r2
	ldi		r1,#0
	rts
.spi_rp1:
	pop		r3/r2
	ldi		r1,#1
	rts

SDDiskSize:
	lhu		r1,disk_size
	rts

;------------------------------------------------------------------------------
; Read the boot sector from the disk.
; Make sure it's the boot sector by looking for the signature bytes 'EB' and '55AA'.
; Returns:
; r1 = 0 means this card is bootable
; r1 = 1 means a read error occurred
; r1 = 2 means the card is not bootable
;------------------------------------------------------------------------------

SDReadBoot:
	push	r2/r3/r5
	lhu		r1,startSector				; r1 = sector number
	ldi		r2,#BYTE_SECTOR_BUF			; r2 = target address
	bsr		SDReadSector
	brnz	r1,spi_read_boot_err
	lbu		r1,BYTE_SECTOR_BUF
	cmp		fl0,r1,#$EB
	bne		fl0,spi_eb_err
spi_read_boot2:
	ldi		r1,#msgFoundEB
	bsr		DisplayStringCRLF
	lbu		r1,BYTE_SECTOR_BUF+$1FE		; check for 0x55AA signature
	cmp		fl0,r1,#$55
	bne		fl0,spi_eb_err
	lbu		r1,BYTE_SECTOR_BUF+$1FF		; check for 0x55AA signature
	cmp		fl0,r1,#$AA
	bne		fl0,spi_eb_err
	pop		r5/r3/r2
	ldi		r1,#0						; r1 = 0, for okay status
	rts
spi_read_boot_err:
	pop		r5/r3/r2
	ldi		r1,#1
	rts
spi_eb_err:
	ldi		r1,#msgNotFoundEB
	bsr		DisplayStringCRLF
	pop		r5/r3/r2
	ldi		r1,#2
	rts

msgFoundEB:
	db	"Found EB code.",0
msgNotFoundEB:
	db	"EB/55AA Code missing.",0


; Load the root directory from disk
; r2 = where to place root directory in memory
;
loadBootFile:
	lbu		r1,BYTE_SECTOR_BUF+BSI_SecPerFAT+1			; sectors per FAT
	shl		r2,r1,#8
	lbu		r1,BYTE_SECTOR_BUF+BSI_SecPerFAT
	or		r1,r2,r1
	brnz	r1,loadBootFile7
	lhu		r1,BYTE_SECTOR_BUF+$24			; sectors per FAT, FAT32
loadBootFile7:
	lbu		r4,BYTE_SECTOR_BUF+$10			; number of FATs
	mul		r3,r1,r4						; offset
	lcu		r1,BYTE_SECTOR_BUF+$E			; r1 = # reserved sectors before FAT
	lbu     r13,BYTE_SECTOR_BUF+$D          ; r13 = sectors per cluster
	add		r3,r3,r1						; r3 = root directory sector number
	lhu		r6,startSector
	add		r5,r3,r6						; r5 = root directory sector number
	lbu     r7,BYTE_SECTOR_BUF+BSI_RootDirEnts
	lbu     r8,BYTE_SECTOR_BUF+BSI_RootDirEnts+1
	shl     r8,r8,#8
	or      r7,r7,r8                        ; r7 = #root directory entries
	; /16 is sector size / directory entry size (512 / 32) = 16
	shru    r7,r7,#4                        ; r7 = #sectors for directory (likely 32)
	add     r8,r7,r5                        ; r8 = start of data area (cluster #2)

; r1= sector number to read
; r2= address to write data
; r3= number of sectors to read
    mov      r1,r5                          ; r1 = root directory sector
    ldi      r2,#ROOTDIR_BUF                ; r2 = where to place directory info
    mov      r3,r7                          ; r3 = number of sectors in roor dir
    bsr      SDReadMultiple                 ; read it

    shl      r7,r7,#4                       ; r7 = # root directory entries
    mov      r3,r7                          ; r3 = # root directory entries
    sub      r3,r3,#1                       ; r3 = count which is one less
    ldi      r2,#ROOTDIR_BUF                ; r2 = where to start search
.0002:
    sb       r0,11[r2]
;    mov      r1,r2
;    bsr      DisplayString
;    bsr      CRLF
    lw       r1,[r2]
    cmp      flg0,r1,#$2020202020534F44     ; look for "DOS"
    bne      flg0,.0001
    lcu      r1,$1A[r2]                     ; r1 = starting cluster
    lhu      r10,$1C[r2]                    ; r10 = size of file
    sub      r1,r1,#2                       ; clusters start at 2
    mul      r9,r1,r13                      ; r9 = clusters to sectors
    add      r9,r9,r8                       ; r9 = starting sector of file
    mov      r1,r9
    ldi      r2,#PROG_LOAD_AREA-$200        ; $200 is size of ELF header
    mov      r3,r10
    add      r3,r3,#511                     ; round up to next sector
    shru     r3,r3,#9                       ; divide by sector size (512)
    bsr      SDReadMultiple
    bra      loadBootFile3
.0001:
    add      r2,r2,#32                      ; directory entry size
    dbnz     r3,.0002
    ldi      r1,#msgDOSNotFound
    bsr      DisplayString
    bra      mon1

	;lbu		r1,BYTE_SECTOR_BUF+$D			; sectors per cluster
	add		r3,r7,r5						; r3 = start of data area
	mov     r1,r3
	bsr     DisplayHalf
	bsr     CRLF
	bra		loadBootFile6

loadBootFile6:
	; For now we cheat and just go directly to sector 512.
	bra		loadBootFileTmp

loadBootFileTmp:
	; We load the number of sectors per cluster, then load a single cluster of the file.
	; This is 16kib
	mov		r5,r3							; r5 = start sector of data area	
	ldi		r2,#PROG_LOAD_AREA-0x200    	; where to place file in memory (200 is ELF header size)
	lbu		r3,BYTE_SECTOR_BUF+$D			; sectors per cluster
	mului	r3,r3,#16						; read 16 clusters (256kb)
	sub		r3,r3,#1
loadBootFile1:
	ldi		r1,#'.'
	bsr		DisplayChar
	mov		r1,r5							; r1=sector to read
	bsr		SDReadSector
	add		r5,r5,#1						; r5 = next sector
	add		r2,r2,#512
	dbnz	r3,loadBootFile1
loadBootFile3:
	lhu		r1,PROG_LOAD_AREA		; make sure it's bootable
	cmp		fl0,r1,#$544F4F42
	bne		fl0,loadBootFile2
	ldi		r1,#msgJumpingToBoot
	bsr		DisplayString
	bra     cpy_br_desc
	jsr		PROG_LOAD_AREA+$100
	bra		mon1
loadBootFile2:
	ldi		r1,#msgNotBootable
	bsr		DisplayString
	ldi		r2,#PROG_LOAD_AREA
	bsr		DisplayMemBytes
	bsr		DisplayMemBytes
	bsr		DisplayMemBytes
	bsr		DisplayMemBytes
	bra		mon1

cpy_br_desc:
; copy the BIOS descriptors to the first program descriptor area
    ldi     r2,#GDTBaseAddress
    ldi     r3,#31
.lbf0001:
    lw      r4,[r2+r3*8]
    sw      r4,$100[r2+r3*8]
    dbnz    r3,.lbf0001
; Set code segment base address
    ldi     r1,#PROG_LOAD_AREA
    shrui   r1,r1,#12
    sw      r1,$1F0[r2]
; Set data segment base address
    sw      r1,$110[r2]
; Set stack segment base address
    sw      r1,$1E0[r2]

    sei
    ldi     sp,#$FFFF8   ; set stack pointer to the top of the program space
    ldi     r1,#$1E
    mtspr   ss,r1
    cli
    ldi     r1,#$11
    mtspr   ds,r1
    jsp     r0,#$00001F
    jsr     $100
; Reset the bootrom stack and data segments
    bra     mon1

    ; Save registers to TSS in blocks of 16 registers at a time so that
    ; interrupt latency isn't adversely affected.
;    ts:smr      r1,r15,$008
;    ts:smr     r16,r31,$080
;    ts:smr     r32,r47,$100
;    ts:smr     r48,r63,$180
;    ts:smr     r64,r79,$200
;    ts:smr     r80,r95,$280
;    ts:smr     r96,r111,$300
;    ts:smr     r112,r127,$380
;    ts:smr     r128,r143,$400
;    ts:smr     r144,r159,$480
;    ts:smr     r160,r175,$500
;    ts:smr     r176,r191,$580
;    ts:smr     r192,r207,$600
;    ts:smr     r208,r223,$680
;    ts:smr     r224,r239,$700
;    ts:smr     r240,r255,$780

msgJumpingToBoot:
	db	"Jumping to boot",0	
msgNotBootable:
	db	"card not bootable.",0
spi_init_ok_msg:
	db "card initialized okay.",0
spi_init_error_msg:
	db	": error occurred initializing the card.",0
spi_boot_error_msg:
	db	"card boot error",CR,LF,0
spi_read_error_msg:
	db	"card read error",CR,LF,0
spi_write_error_msg:
	db	"card write error",0
msgDOSNotFound:
    db  "DOS file not found",CR,LF,0

; ============================================================================
; I2C interface to RTCC
; ============================================================================

I2C_INIT:
	push	r5/r1/r2
	mfspr	r5,cr0		
	mtspr	cr0,r0					; turn off TMR
	ldi		r2,#I2C_MASTER
	sb		r0,I2C_CONTROL[r2]		; disable the contoller
	sb		r0,I2C_PRESCALE_HI[r2]	; set clock divisor for 100kHz
	ldi		r1,#99					; 24=400kHz, 99=100KHz
	sb		r1,I2C_PRESCALE_LO[r2]
	ldi		r1,#$80					; controller enable bit
	sb		r1,I2C_CONTROL[r2]
	mtspr	cr0,r5					; restore TMR
	pop		r2/r1/r5
	rts

;------------------------------------------------------------------------------
; I2C Read
;
; Parameters:
; 	r1 = device ($6F for RTCC)
; 	r2 = register to read
; Returns
; 	r1 = register value $00 to $FF if successful, else r1 = -1 on error
;------------------------------------------------------------------------------
;
I2C_READ:
	push	r5/r2/r3/r4
	mfspr	r5,cr0		
	mtspr	cr0,r0					; turn off TMR
	shl		r1,r1,#1				; clear rw bit for write
;	or		r1,r1,#1				; set rw bit for a read
	mov		r4,r1					; save device address in r4
	mov		r3,r2
	; transmit device #
	ldi		r2,#I2C_MASTER
	sb		r1,I2C_TX[r2]
	ldi		r1,#$90					; STA($80) and WR($10) bits set
	sb		r1,I2C_CMD[r2]
	bsr		I2C_WAIT_TC				; wait for transmit to complete
	; transmit register #
	lb		r1,I2C_STAT[r2]
	and		r1,r1,#$80				; test RxACK bit
	brnz	r1,I2C_ERR
	sb		r3,I2C_TX[r2]			; select register r3
	ldi		r1,#$10					; set WR bit
	sb		r1,I2C_CMD[r2]
	bsr		I2C_WAIT_TC

	; transmit device #
	lb		r1,I2C_STAT[r2]
	and		r1,r1,#$80				; test RxACK bit
	brnz	r1,I2C_ERR
	or		r4,r4,#1				; set read flag
	sb		r4,I2C_TX[r2]
	ldi		r1,#$90					; STA($80) and WR($10) bits set
	sb		r1,I2C_CMD[r2]
	bsr		I2C_WAIT_TC				; wait for transmit to complete

	; receive data byte
	lb		r1,I2C_STAT[r2]
	and		r1,r1,#$80				; test RxACK bit
	brnz	r1,I2C_ERR
	ldi		r1,#$68					; STO($40), RD($20), and NACK($08)
	sb		r1,I2C_CMD[r2]
	bsr		I2C_WAIT_TC
	lbu		r1,I2C_RX[r2]			; $00 to $FF = byte read, -1=err
	mtspr	cr0,r5					; restore TMR
	pop		r4/r3/r2/r5
	rts

I2C_ERR:
	ldi		r1,#-1
	mtspr	cr0,r5					; restore TMR
	pop		r4/r3/r2/r5
	rts

;------------------------------------------------------------------------------
; I2C Write
;
; Parameters:
; 	r1 = device ($6F)
; 	r2 = register to write
; 	r3 = value for register
; Returns
; 	r1 = 0 if successful, else r1 = -1 on error
;------------------------------------------------------------------------------
;
I2C_WRITE:
	push	r5/r2/r3/r4
	mfspr	r5,cr0		
	mtspr	cr0,r0					; turn off TMR
	shl		r1,r1,#1				; clear rw bit for write
	mov		r4,r3					; save value r4
	mov		r3,r2
	; transmit device #
	ldi		r2,#I2C_MASTER			; r2 = I/O base address of controller
	sb		r1,I2C_TX[r2]
	ldi		r1,#$90					; STA($80) and WR($10) bits set
	sb		r1,I2C_CMD[r2]
	bsr		I2C_WAIT_TC				; wait for transmit to complete
	; transmit register #
	lb		r1,I2C_STAT[r2]
	and		r1,r1,#$80				; test RxACK bit
	brnz	r1,I2C_ERR
	sb		r3,I2C_TX[r2]			; select register r3
	ldi		r1,#$10					; set WR bit
	sb		r1,I2C_CMD[r2]
	bsr		I2C_WAIT_TC
	; transmit value
	lb		r1,I2C_STAT[r2]
	and		r1,r1,#$80				; test RxACK bit
	brnz	r1,I2C_ERR
	sb		r4,I2C_TX[r2]			; select value in r4
	ldi		r1,#$50					; set STO, WR bit
	sb		r1,I2C_CMD[r2]
	bsr		I2C_WAIT_TC
	mtspr	cr0,r5					; restore TMR
	ldi		r1,#0					; everything okay
	pop		r4/r3/r2/r5
	rts

; Wait for I2C controller transmit complete

I2C_WAIT_TC:
.0001:
	lb		r1,I2C_STAT[r2]
	and		r1,r1,#2
	brnz	r1,.0001
	rts

; Read the entire contents of the RTCC including 64 SRAM bytes

RTCCReadbuf:
	bsr		I2C_INIT
	ldi		r2,#$00
.0001:
	ldi		r1,#$6F
	bsr		I2C_READ
	sb		r1,RTCC_BUF[r2]
	add		r2,r2,#1
	cmp		fl0,r2,#$60
	blo		fl0,.0001
	rts

; Write the entire contents of the RTCC including 64 SRAM bytes

RTCCWritebuf:
	bsr		I2C_INIT
	ldi		r2,#$00
.0001:
	ldi		r1,#$6F
	lbu		r3,RTCC_BUF[r2]
	bsr		I2C_WRITE
	add		r2,r2,#1
	cmp		fl0,r2,#$60
	blo		fl0,.0001
	rts

RTCCOscOn:
	bsr		I2C_INIT
	ldi		r1,#$6F
	ldi		r2,#$00			; register zero
	bsr		I2C_READ		; read register zero
	or		r3,r1,#$80		; set start osc bit
	ldi		r1,#$6F
	bsr		I2C_WRITE
	rts

; ============================================================================
; FMTK: Finitron Multi-Tasking Kernel
;        __
;   \\__/ o\    (C) 2014  Robert Finch, Stratford
;    \  __ /    All rights reserved.
;     \/_//     robfinch<remove>@finitron.ca
;       ||
; ============================================================================
;  
;------------------------------------------------------------------------------
; Initialize the multi-tasking kernel.
;------------------------------------------------------------------------------

FMTKInitialize:
	php
	sei
	ldi		r1,#46
	sb		r1,LEDS
	mfspr	r1,vbr
	ldi		r2,#FMTKScheduler
	sw		r2,2*16[r1]
	ldi		r2,#FMTKTick
	sw		r2,451*16[r1]
	plp

	sw		r0,RunningTCB
	sw		r0,QNdx0
	sw		r0,QNdx0+8
	sw		r0,QNdx0+16	
	sw		r0,QNdx0+24
	sw		r0,QNdx0+32
	sw		r0,QNdx0+40
	sw		r0,QNdx0+48
	sw		r0,QNdx0+56

	ldi		r2,#TCBs			; r2 = pointer to TCB
	ldi		r3,#TCBs+TCB_Size	; r3 = pointer to next TCB
	ldi		r6,#NR_TCB-1		; r6 = counter
	sw		r2,FreeTCB
.0001:
	sw		r3,TCB_Next[r2]
	sw		r0,TCB_Prev[r2]
	sb		r0,TCB_Status[r2]	; status = none
	sb		r0,TCB_hJob[r2]
	ldi		r4,#7
	sb		r4,TCB_Priority[r2]	; lowest priority
	mov		r2,r3				; current = next
	add		r3,r3,#TCB_Size
	dbnz	r6,.0001
	sw		r0,TCB_Next[r2]		; initialize last link

	ldi		r1,#47
	sb		r1,LEDS
	ldi		tr,#TCBs
	ldi		r1,#4
	ldi		r2,#0
	ldi		r3,#Monitor
	ldi		r4,#0
	ldi		r5,#0
	bsr		StartTask
	ldi		r1,#48
	sb		r1,LEDS
	
	rts

IdleTask:
.it1:
	ios:lhu	r199,TEXTSCR+444
	add		r199,r199,#1
	ios:sh	r199,TEXTSCR+444
	jmp		.it1

;------------------------------------------------------------------------------
; Parameters:
;	r1 = priority
;	r2 = flags
;	r3 = start address
;	r4 = parameter
;	r5 = job
;------------------------------------------------------------------------------

StartTask:
	push	r6/r7/r8

	; Get a TCB from the free list
	php
	sei
	ldi		r6,#51
	sb		r6,LEDS
	lw		r6,FreeTCB
	lw		r7,TCB_Next[r6]
	sw		r7,FreeTCB
	plp

	; Initialize the TCB fields
	sb		r1,TCB_Priority[r6]
	sb		r5,TCB_hJob[r6]
	add		r7,r6,#TCB_Size-8
	sub		r7,r7,#24
	ldi		r8,#ExitTask
	and		r8,r8,#-4				; flag: short form address
	sw		r8,16[r7]				; setup exit address on stack
	;and		r2,r2,#$FFFFFFFF		; mask off any extraneous bits
	;sw		r2,16[r7]				; setup flags to pop
	sw		r0,8[r7]				; setup code segment
	and		r3,r3,#-4				; flag:
	or		r3,r3,#0				; interrupt flag
	sw		r3,[r7]					; setup return address (start address)
	sw		r7,TCB_SP0Save[r6]		; save the stack pointer
	mov		r1,r6
	php
	sei
	bsr		AddTaskToReadyList
	plp
	ldi		r6,#54
	sb		r6,LEDS
	brk		#2*16						; reschedule tasks
	pop		r8/r7/r6
	rts

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------

ExitTask:
	sei
	lw		tr,RunningTCB			; refuse to exit the Monitor task
	cmp		fl0,tr,#TCBs
	beq		fl0,.0001
	lw		r6,FreeTCB
	sw		r6,TCB_Next[tr]
	sw		tr,FreeTCB
	sw		r0,RunningTCB
	jmp		SelectTaskToRun
.0001:
	cli
	rts

;------------------------------------------------------------------------------
; Inserts a task into the ready queue at the tail.
;------------------------------------------------------------------------------

AddTaskToReadyList:
	push	r3/r4/r5/r6
	lbu		r3,TCB_Priority[r1]
	and		r3,r3,#7
	shl     r4,r3,#3
	lw		r4,QNdx0[r4]
	brz		r4,.initQ				; is the queue empty ?
	lw		r5,TCB_Prev[r4]
	lw		r6,TCB_Next[r5]
	sw		r1,TCB_Next[r5]
	sw		r1,TCB_Prev[r4]
	sw		r5,TCB_Prev[r1]
	sw		r4,TCB_Next[r1]
	ldi		r4,#TS_READY
	sb		r4,TCB_Status[r1]
	pop		r6/r5/r4/r3
	rts
.initQ:
    shl     r4,r3,#3
	sw		r1,QNdx0[r4]
	sw		r1,TCB_Next[r1]
	sw		r1,TCB_Prev[r1]
	ldi		r4,#TS_READY
	sb		r4,TCB_Status[r1]
	pop		r6/r5/r4/r3
	rts

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------

RemoveTaskFromReadyList:
	push	r3/r4/r6/r7
	lw		r6,TCB_Next[r1]
	lw		r7,TCB_Prev[r1]
	sw		r7,TCB_Prev[r6]
	sw		r6,TCB_Next[r7]
	lbu		r3,TCB_Priority[r1]
	shl     r4,r3,#3
	lw		r4,QNdx0[r4]
	cmp		fl0,r4,r1
	bne		fl0,.0001
	shl     r4,r3,#3
	sw		r6,QNdx0[r4]
.0001:
	sw		r0,TCB_Next[r1]
	sw		r0,TCB_Prev[r1]
	sb		r0,TCB_Status[r1]
	pop		r7/r6/r4/r3
	rts
	
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------

FMTKScheduler:
	sei
	ldi		tr,#52
	sb		tr,LEDS
	lw		tr,RunningTCB
	brnz	tr,.0002
	ldi		tr,#TCBs-TCB_Size
.0002:
	;mfspr	r250,cs
	;shr		r250,r250,#60
	sw		sp,TCB_SP0Save[tr]	;+r250*8]
	push	tr
	bsr		SaveContext
	pop		tr
	ldi		r201,#TS_READY
	sb		r201,TCB_Status[tr]
	bra		SelectTaskToRun

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------

nStartQue:
	db		0,1,0,2,0,3,0,1,0,4,0,5,0,6,0,7
	db		0,1,0,2,0,3,0,1,0,4,0,5,0,6,0,7

;------------------------------------------------------------------------------
; FMTKTick:
;	Timer tick routine that does the pre-emptive multi-tasking.
;------------------------------------------------------------------------------
;interrupt link register......

FMTKTick:
	ldi		tr,#3				; reset the edge sense circuit
	sh		tr,PIC_RSTE
	lw		tr,TickVec
	brz		tr,.0001
	jsr		(TickVec)
.0001:
	lh		tr,Ticks
	add		tr,tr,#1
	sh		tr,Ticks
	lw		tr,RunningTCB
	brnz	tr,.0002
	ldi		tr,#TCBs-TCB_Size
.0002:
	sw		sp,TCB_SP0Save[tr]
	push	tr
	bsr		SaveContext
	pop		tr
	ldi		r206,#TS_PREEMPT
	sb		r206,TCB_Status[tr]

;------------------------------------------------------------------------------
; SelectTaskToRun:
;
;------------------------------------------------------------------------------

SelectTaskToRun:
	ldi		r201,#53
	sb		r201,LEDS
	lh		r201,Ticks
	and		r201,r201,#$1F
	lb		r203,nStartQue[r201]
	ldi		r206,#7				; number of queues to check - 1
.qagain:
	and		r203,r203,#7			; max 0-7 queues
	shl     r203,r203,#3
	lw		r201,QNdx0[r203]
	brz		r201,.qempty
	lw		tr,TCB_Next[r201]
	sw		tr,QNdx0[r203]
	sw		tr,RunningTCB

	ldi		r206,#TS_RUNNING
	sb		r206,TCB_Status[tr]
	bra		.qxit
.qempty:
    shr     r203,r203,#3
	add		r203,r203,#1
	dbnz	r206,.qagain
	ldi		tr,#TCBs-TCB_Size
	jmp		.qxit
	ldi		r1,#msgNoTasks
	bsr		kernel_panic
.qerr:
	ldi		r250,#$C
	sb		r250,LEDS
	brz		r0,.qerr

.qxit:
	ldi		r201,#$A
	sb		r201,LEDS
	; RestoreContext will modify the task register
	lw		r250,TCB_SP0Save[tr]
	push	r250
	bsr		RestoreContext
	pop		sp
	rti

msgNoTasks:
	db		"No tasks in queue.",0

kernel_panic:
	bsr		DisplayString
	rts

;------------------------------------------------------------------------------
; Save the task context. The context is saved in blocks of 16 registers at
; a time in order to minimize interrupt latency.
;------------------------------------------------------------------------------

SaveContext:
	push	tr
	smr		r1,r15,[tr]
	add		tr,tr,#15*8
	smr		r16,r31,[tr]
	add		tr,tr,#16*8
	smr		r32,r47,[tr]
	add		tr,tr,#16*8
	smr		r48,r63,[tr]
	add		tr,tr,#16*8
	smr		r64,r79,[tr]
	add		tr,tr,#16*8
	smr		r80,r95,[tr]
	add		tr,tr,#16*8
	smr		r96,r111,[tr]
	add		tr,tr,#16*8
	smr		r112,r127,[tr]
	add		tr,tr,#16*8
	smr		r128,r143,[tr]
	add		tr,tr,#16*8
	smr		r144,r159,[tr]
	add		tr,tr,#16*8
	smr		r160,r175,[tr]
	add		tr,tr,#16*8
	smr		r176,r191,[tr]
	add		tr,tr,#16*8
	smr		r192,r207,[tr]
	add		tr,tr,#16*8
	smr		r208,r223,[tr]
	add		tr,tr,#16*8
	smr		r224,r239,[tr]
	add		tr,tr,#16*8
	smr		r240,r254,[tr]
	add		tr,tr,#15*8
	pop		tr

	rts

;------------------------------------------------------------------------------
; Restore the task context. The context is saved in blocks of 16 registers at
; a time in otder to minimize interrupt latency.
;------------------------------------------------------------------------------

RestoreContext:
	lmr		r1,r15,[tr]
	add		tr,tr,#15*8
	lmr		r16,r31,[tr]
	add		tr,tr,#16*8
	lmr		r32,r47,[tr]
	add		tr,tr,#16*8
	lmr		r48,r63,[tr]
	add		tr,tr,#16*8
	lmr		r64,r79,[tr]
	add		tr,tr,#16*8
	lmr		r80,r95,[tr]
	add		tr,tr,#16*8
	lmr		r96,r111,[tr]
	add		tr,tr,#16*8
	lmr		r112,r127,[tr]
	add		tr,tr,#16*8
	lmr		r128,r143,[tr]
	add		tr,tr,#16*8
	lmr		r144,r159,[tr]
	add		tr,tr,#16*8
	lmr		r160,r175,[tr]
	add		tr,tr,#16*8
	lmr		r176,r191,[tr]
	add		tr,tr,#16*8
	lmr		r192,r207,[tr]
	add		tr,tr,#16*8
	lmr		r208,r223,[tr]
	add		tr,tr,#16*8
	lmr		r224,r239,[tr]
	add		tr,tr,#16*8
	lmr		r240,r251,[tr]
	add		tr,tr,#12*8
	lw		r253,8[tr]
	rts

;------------------------------------------------------------------------------
; Test RAM using checkerboard pattern.
;------------------------------------------------------------------------------

RAMTest:
	bsr		CRLF
	ldi		r1,$10000				; start past the ROM
	ldi		r2,#$AAAAAAAA55555555	; Checkerboard pattern
	
	; First store the checkerboard pattern to all memory locations
.0002:
	sw		r2,[r1]
	andi	r3,r1,#$FFF				; display progress and check
	brnz	r3,.0001				; for CTRL-C every so often
	bsr		DisplayHalf
	mov		r4,r1
	ldi		r1,#CR
	bsr		DisplayChar
	bsr		KeybdGetCharDirectNB
	sub		r1,r1,#CTRLC
	brz		r1,.0006
	mov		r1,r4
.0001:
	addi	r1,r1,#8				; increment to next word
	cmp		flg0,r1,#$0800000		; 128MB is the RAM onboard
	bltu	flg0,.0002
	
	; Readback the checkboard pattern from all memory locations
	ldi		r1,#$10000
.0005:
	lw		r2,[r1]
	cmp		flg0,r2,#$AAAAAAAA55555555
	beq		flg0,.0003
	bsr		DisplayHalf
	bsr		CRLF
.0003:
	andi	r3,r1,#$FFF			; display progress and check
	brnz	r3,.0004			; for CTRL-C every so often
	bsr		DisplayHalf
	mov		r4,r1
	ldi		r1,#CR
	bsr		DisplayChar
	bsr		KeybdGetCharDirectNB
	sub		r1,r1,#CTRLC
	brz		r1,.0006
	mov		r1,r4
.0004:
	addi	r1,r1,#8			; increment to next word
	cmp		flg0,r1,#$0800000
	bltu	flg0,.0005
.0006:
	rts

;------------------------------------------------------------------------------
; An uninitialized interrupt occurred. Display the vector number and the
; interrupt address.
;------------------------------------------------------------------------------

uninit_rout:
	ldi		r1,#$ba
	sb		r1,LEDS
	ldi		r1,#msgUninit
	bsr		DisplayStringCRLF
	mfspr	r1,ivno
	bsr		DisplayHalf
	bsr		CRLF
	pop		r1
	bsr		DisplayHalf
	bsr		CRLF
	ldi		r3,#63
.0002:
	mfspr	r1,history
	bsr		DisplayHalf
	ldi		r1,#' '
	bsr		DisplayChar
	dbnz	r3,.0002
.0001:
	bra .0001

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------

flt_except:
	push	r1
	ldi		r1,#msgFltExcept
	bsr		DisplayString
	fstat	r1
	bsr		DisplayHalf
	bsr		OutCRLF
.self:
	bra		.self
	bsr		KeybdGetCharWait
	pop		r1
	rti
;	bra		mon1

msgFltExcept:
	.byte	"FLT Exception: ",0

;------------------------------------------------------------------------------
; Execution fault. Occurs when an attempt is made to execute code from a
; page marked as non-executable.
;------------------------------------------------------------------------------

exf_rout:
	ldi		r1,#$bb
	sb		r1,LEDS
	ldi		r1,#msgexf
	bsr		DisplayStringCRLF
.0001:
	bra .0001

;------------------------------------------------------------------------------
; Data read fault. Occurs when an attempt is made to read from a page marked
; as non-readble.
;------------------------------------------------------------------------------

drf_rout:
	ldi		r1,#$bb
	sb		r1,LEDS
	ldi		r1,#msgdrf
	bsr		DisplayStringCRLF
.0001:
	bra .0001

;------------------------------------------------------------------------------
; Data write fault. Occurs when an attempt is made to write to a page marked
; as non-writeable.
;------------------------------------------------------------------------------

dwf_rout:
	ldi		r1,#$bb
	sb		r1,LEDS
	ldi		r1,#msgdwf
	bsr		DisplayStringCRLF
.0001:
	bra .0001

;------------------------------------------------------------------------------
; Segment bounds violation fault.
;------------------------------------------------------------------------------

sbv_rout:
	ldi		r1,#$bb
	sb		r1,LEDS
	ldi		r1,#msgSBV
	bsr		DisplayStringCRLF
.0001:
	bra .0001

;------------------------------------------------------------------------------
; Privilege violation fault. Occurs when the current privilege level isn't
; sufficient to allow access.
;------------------------------------------------------------------------------

priv_rout:
	ldi		r1,#$bc
	st		r1,LEDS
	ldi		r1,#msgPriv
	bsr		DisplayStringCRLF
.0001:
	bra .0001

;------------------------------------------------------------------------------
; Segment type violation. Occurs when an attempt is made to load a data
; segment into the code segment or the code segment into a data segment
; register.
;------------------------------------------------------------------------------

stv_rout:
	ldi		r1,#$bd
	sb		r1,LEDS
	ldi		r1,#msgSTV
	bsr		DisplayStringCRLF
	mfspr	r1,fault_pc
	bsr		DisplayWord
	bsr		CRLF
	mfspr	r1,fault_cs
	bsr		DisplayHalf
	bsr		CRLF
	mfspr	r1,fault_seg
	bsr		DisplayHalf
	bsr		CRLF
	mfspr	r1,fault_st
	bsr		DisplayByte
	bsr		CRLF
.0001:
	bra .0001

;------------------------------------------------------------------------------
; Segment not present. Occurs when the segment is marked as not present in
; memory.
;------------------------------------------------------------------------------

snp_rout:
	ldi		r1,#$be
	sb		r1,LEDS
	ldi		r1,#msgSNP
	bsr		DisplayStringCRLF
.0001:
	bra .0001

;------------------------------------------------------------------------------
; Message strings for the faults.
;------------------------------------------------------------------------------

msgexf:
	db	"exf ",0
msgdrf:
	db	"drf ",0
msgdwf:
	db	"dwf ",0
msgSBV:
	db	"sbv fault",0
msgPriv:
	db	"priv fault",0
msgSTV:
	db	"stv fault",0
msgSNP:
	db	"snp fault",0
msgUninit:
	db	"uninit int.",0

;------------------------------------------------------------------------------
; Bus error routine.
;------------------------------------------------------------------------------

berr_rout:
	ldi		r1,#$AA
	st		r1,LEDS
	mfspr	r1,bear
;	bsr		DisplayWord
.be1:
	bra .be1

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------

AlgnFault:
	mfspr	r1,fault_pc
	bsr		DisplayWord
	bsr		CRLF
AlgnFault2:
	ldi		r1,#$AF
	sw		r1,LEDS
	bra AlgnFault2

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------

DebugRout:
	ldi		r1,#$DB
	sw		r1,LEDS
	bra DebugRout

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
	org		$0000FFB0		; Alignment fault
	bra AlgnFault

	org		$0000FFC0		; debug vector
	bra DebugRout

	org		$0000FFE0		; NMI vector
	rti

	org		$0000FFF0
	jmp		start
