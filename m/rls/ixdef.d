;	arpl/lar/lsl
;	verr/verw
;	int/into/iret/iretd
;
header	ixdef - Intel iAPX architecture
include	rid:rider

  type	ixTlad : *void		; linear address
  type	ixTpad : *void		; physical address
  type	ixTsel : WORD		; selector
	ixRPL_ := 0x3		; selector requested privilege level
	ixGLI_ := 0x4		; 0=gdt, 1=>ldt
	ixSEL_ := 0xFFF4	; 11 bit index

  type	ixTpsl : LONG		; processor status word (flags)
				; lahf/sahf clc/cld/cli/cmc stc/std/sti
				; pushfd/popfd
  type	ixTmsw : LONG	; cr0	; machine status word lmsw/smsw/clts
				; clts
  type	ixTcr2 : ixTlad	; cr2	; Page Fault LA
  type	ixTcr3 : ixTpad ; cr3	; Page Directory Base Address

  type	ixTvec
  is	Vlof : WORD
	Vsel : WORD
	Vf00 : BYTE
	Vflg : BYTE
	Vhof : WORD
  end

  ixMoff(v) := (((v)->Vhof<<16)|(v)->Vlof)
  ixMtyp(v) := ((v)->Vflg&0xf)

  type	ixTdsc
  is	Vlm0 : WORD		; limit.0
	Vbs0 : WORD		; base.0
	Vbs1 : BYTE		; base.1
	Vflg : BYTE		; flags
	Vlm1 : BYTE		; limit.1 and more flags
	Vbs2 : BYTE		; base.2
  end
  ixMbas(v) := (((v)->Vbs2<<24)|((v)->Vbs1<<16)|v->Vbs0)
  ixMlim(v) := ((((v)->Vlm1&0xf)<<16)|(v)->Vlm0)

  type	ixTdtr			; desc. table register idtr/gdtr
  is	Vlim : WORD		; limit
	Pbas : * void ;ixTdsc LA; base
	Vsel : WORD		; unused
  end
  type	ixTidt
  is	Vlim : WORD
	Pbas : * ixTvec	; LA	;
	Vsel : WORD		; unused
  end

  type	ixTgdt : ixTdtr		; lgdt/sgdt
; type	ixTidt : ixTdtr		; lidt/sidt
  type	ixTldt : ixTsel		; lldt/sldt
  type	ixTtsk : ixTsel		; ltr/str

data	gate types

	ixTS2 := 1		; tss16
	ixLDT := 2		; ldt
	ixBS2 := 3		; busy16
	ixCL2 := 4		; call16
	ixTSK := 5		; task
	ixIN2 := 6		; int16
	ixTP2 := 7		; trap16
	ixTSS := 9		; tss
	ixBSY := 11		; busy
	ixCAL := 12		; call
	ixINT := 14		; int
	ixTRP := 15		; trap

data	exceptions

	ixDIV := 0		; divide error
	ixDBG := 1		; debug exception
	ixBPT := 3		; software breakpoint
	ixOVR := 4		; overflow
	ixBND := 5		; array bound
	ixOPC := 6		; invalid opcode
	ixMIS := 7		; coprocessor missing	
	ixDBL := 8		; double fault
	ixTSX := 10		; invalid TSS
	ixSEG := 11		; segment fault
	ixSTK := 12		; stack underflow/overflow
	ixPRT := 13		; general protection violation
	ixPAG := 14		; page fault
	ixCOP := 16		; coprocessor error

data	psuedo-segment register specifiers

	ixDS	:= (~0)		;
	ixES	:= (~1)		;
	ixFS	:= (~2)		;
	ixGS	:= (~3)		;
	ixCS	:= (~4)		;
	ixSS	:= (~5)		;
	ixLS	:= (~6)		; linear address

data	ixTmch - machine state

 	ixTtrt := LONG
	ixTcrt := LONG
	ixTseg := LONG

  type	ixTmch
  is	Igdt : ixTgdt		; gdt limit, base LA
	Iidt : ixTidt		; idt limit, base LA
	Ildt : ixTldt		; ldt selector
	Itrt : ixTtrt		; tr  selector
				;
	Vpsl : ixTpsl		;
	Vcr0 : ixTcrt		; msw/msl
	Vcr2 : ixTlad		; LA last page fault
	Vcr3 : ixTpad		; PA page directory
				;
	Vds  : ixTseg		; segment registers
	Ves  : ixTseg		;
	Vfs  : ixTseg		;
	Vgs  : ixTseg		;
	Vcs  : ixTseg		;
	Vss  : ixTseg		;
  end

end header
