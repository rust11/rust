header	eldef - pdp-11 definitions
include	rid:rider
include rid:eldef

data	cpu environment

;	s d	source dest
;	b w	byte word
;	a v	address value

  type	elTfun : (void) void
; type	elTwrd : WORD
; type	elTbyt : BYTE
; type	elTlng : LONG
; type	elTadr : LONG

	_1k   := (1024)		;     02000
	_8k   := (8   * _1k)	;    020000
	_64k  := (64  * _1k)	;   0200000   0170000
	_256k := (256 * _1k)	;  01000000   0770000
	_1m   := (_1k * _1k)	;  04000000
	_4m   := (4   * _1m)	; 020000000 017770000

	elVAS  := _64k		; virtual address space (unmapped as well)
	elUAS  := _256k		; unibus address space
	elQAS  := _4m		; qbus address space

	elVIO  := (elVAS - _8k)	;   0170000
	elUIO  := (elUAS - _8k)	;   0770000
	elQIO  := (elQAS - _8k)	; 017770000

	elPAS  := (elVAS)	; physical address space
	elHWM  := (elPAS-_8k)	; high water mark (I/O base)
	elNMX  := (elPAS-elVAS)	; native to machine address, byte or word
	elMCH  := (elPAS-elVAS)	; pointer to the I/O page (64k page)

	elREG  := (elPAS)	; register storage
	elMEM  := (elPAS+128)	; total memory to allocate (includes regs)

	MMU(x) := el_mmu (x)			; MMU setup with mode
	VPR(x) := el_vpr (x)			; virtual to physical, read
	VPW(x) := el_vpr (x)			; virtual to physical, write
	PNB(x) := (<*elTbyt>(elPmem + (x)))	; physical to native, byte
	PNW(x) := (<*elTwrd>(elPmem + (x)))	; physical to native, word
	MNB(x) := (<*elTbyt>(elPmch + (x)))	; machine to native, byte
	MNW(x) := (<*elTwrd>(elPmch + (x)))	; machine to native, word
	NMX(x) := ((x)-elNMX)			; native to machine, typeless

	el_fmw(x) := (*MNW(x))			; fetch machine word
	el_fmb(x) := (*MNB(x))			; fetch machine byte
	el_smw(x,y) := (*MNW(x)=(y))		; store machine word
	el_smb(x,y) := (*MNB(x)=(y))		; store machine byte

	elPmem : [] elTbyt extern ; [elMEM] - main memory (could be pointer)
	elPmch : * elTbyt extern; direct access to machine (64kb page!)
	elPreg : * elTwrd extern; direct access to registers
	elVpsw : elTwrd	extern	; internal and actual PSW
				;
	elAzer : [] char extern ; [512] - to zero-extend disk writes
	elVlsi : int extern	; PDP-11/03 flag
	elVmmu : int extern	; MMU flag
	elVmmu : int extern	; mmu enabled
	elV22b : int extern	; 22bit enabled
				;
	elVevn : elTadr extern	; ~(1) for 11/03. ~(0) for others.
	elVopc : elTwrd extern	; opcode
	elVsch : int extern	; scheduled interrupts
				;
	elVswa : elTadr extern	; source word address
	elVdwa : elTadr extern	; dest   word address
	elVsba : elTadr extern	; source byte address
	elVdba : elTadr extern	; dest   byte address
	elVtwa : elTadr extern	; temp   word address
	elVtba : elTadr extern	; temp   byte address
	elVswv : elTwrd extern	; source word value
	elVsbv : elTbyt extern	; source byte value
	elVdwv : elTwrd extern	; dest   word value
	elVdbv : elTbyt	extern	; dest   byte value
	elVtwv : elTwrd extern	; temp   word value
	elVtbv : elTbyt extern	; temp   byte value
	elVtlv : elTlng extern	; temp	 long value
	elVslv : elTlng extern	; source long value
	elVdlv : elTlng extern	; dest	 long value
data	CPU definitions

	OP  := elVopc		; opcode
	R0  := elPreg[0] 
	R1  := elPreg[1] 
	R2  := elPreg[2] 
	R3  := elPreg[3] 
	R4  := elPreg[4] 
	R5  := elPreg[5] 
	SP  := elPreg[6]
	PC  := elPreg[7]
	PS  := elVpsw

	elMtbt(x) := ((x) & ~(elT_))	; clear the TBIT

	TBIT := ((PS & elT_) >> 4)
	NBIT := ((PS & elN_) >> 3)
	ZBIT := ((PS & elZ_) >> 2)
	VBIT := ((PS & elV_) >> 1)
	CBIT := (PS & elC_)

	CLC := (PS &= (~elC_))
	CLV := (PS &= (~elV_))
	CLZ := (PS &= (~elZ_))
	CLN := (PS &= (~elN_))
	SEC := (PS |= elC_)
	SEV := (PS |= elV_)
	SEZ := (PS |= elZ_)
	SEN := (PS |= elN_)


end header
