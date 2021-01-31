header	rtcsi - RT-11 CSI interface

  type	csTswi
  is	Vcha : char		; option (always upper case)
	Vflg : BYTE		; BIT(7) => has value, file number
	Vval : WORD		; value, if any
  end
	csVAL_ := BIT(7)	; switch has value

  type	csTspc
  is	Pspc : * char		; ascii file spec (without sub-directories)
	Pdis : * char		; display file spec (with sub-directories)
	Valc : WORD		; allocation, if any
  end

  type	csTcsi
  is	Pnon : * char		; switchs with no value
	Popt : * char		; switchs with optional value
	Preq : * char		; switchs with required value
	Pexc : * char		; mutually exclusive switchs
	Pidt : * char		; ident string
	Pcmd : * char		; copy of command line
				; impure - cleared
	Vflg : WORD		; flags
	Vfil : WORD		; file mask
	Aswi : [17] csTswi	; switchs -- in command line order 
	Aopt : [3]  csTspc	; output specs
	Aipt : [6]  csTspc	; input specs
				; internal
	Acsi : [39] WORD	; .CSISPC files/allocation area
	Adis : [80] char	; display file specs
	Astr : [9*16] char	; string area (csi line is 80 characters max)
	Ptyp : * char		; default filetypes
  end
	csIDT_ := 1		; ident
	csEXC_ := 1		; ident

	cs_par : (*csTcsi, *char) int
	cs_val : (*csTcsi, WORD, WORD) int
	cs_inv : (void) void

end header
