header	rvTpdp- reverse compile PDP-11

  type	rvTpdp
  is	Vflg : int		; flags
	Vloc : WORD		; PDP-11 location
	Vopc : WORD		; opcode
	Adat : [3] WORD		; instruction data (following opcode)
	Vlen : int		; instruction length
;	Vsrc : WORD		; instruction source address
	Vdst : WORD		; instruction destination address
	Astr : [128] char	; instruction as string
	Pstr : * char		; used internally
	Vtyp : WORD		; operation type (see list below)
	Vatr : WORD		; operation attributes
	Vrel : WORD		; optional relocation base address offset
  end
	rvSKE_ := BIT(0)	; skeleton (no digits)
	rvNFP_ := BIT(1)	; no floating point

	rv_pdp : (*rvTpdp) void

data	operation types

	rvCTL  := 0		;ctl	000000	000000	control
	rvREG  := 1		;reg	000007	00000r	register
	rvPRI  := 2		;pri	000007	00000n	priority
	rvCON  := 3		;con	000017	0000cc	condition codes
	rvUOP  := 4		;uop	000077	0000mr	unary operand
	rvMRK  := 5		;mrk	000077	0000oo	6-bit offset
	rvBRA  := 6		;bra	000377	000ooo	8-bit offset
	rvEMT  := 7		;emt	000377	000nnn	trap code
	rvRMD  := 8		;rmd	000777	000rmm	register, mode
	rvSOB  := 9		;sob	000777	000roo	register, offset
	rvBOP  := 10		;bop	007777	00mmmm	mode, mode
	rvWRD  := 11		;wrd	000000	nnnnnn	.word
	rvEIS  := 12		;eis	000777	000rmm  EIS register, mode
	rvSOP  := 13		;sop	007700	00mm00	psh
	rvFPS  := 14		;fps	000377	000ass  accumulator, register
	rvFPD  := 15		;fpd	000377	000add  acc, dst register

	rvTYP_ := 017		;code mask (0..15)
				;flags below returned in Vatr
	rvMOD_ := BIT(6)	;modifies destination
	rvCAL_ := BIT(7)	;is a CALL or JSR
	rvBYT_ := BIT(8)	;byte oriented
	rvSPC_ := BIT(9)	;CPU specific instructions
	rvFIS_ := BIT(10)	;FIS
	rvFPU_ := BIT(11)	;FPU
	rvMMU_ := BIT(12)	;MMU
	rvTER_ := BIT(13)	;terminates code
	rvRAR_ := BIT(14)	;rarely used

end header
