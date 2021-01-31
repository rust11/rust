header	rtdev - RT-11 device status

  type	rtTdst
  is	Vdsw : WORD		; device status word (rt-11)
	Vhsz : WORD		; handler byte size
	Vent : WORD		; handler entry point (lqe)
	Vdsz : WORD		; device block size
  end
				; Vdsw
	dsCOD_ := 0377		; device code positive
	dsVAR_ := 0400		; varsz$ variable size device
	dsGAB_ := 01000		; abtio$ generic abort
	dsFUN_ := 02000		; spfun$ accepts spfun
	dsHAB_ := 04000		; hndlr$ handler abort
	dsSPC_ := 010000	; specl$ special directory
	dsWON_ := 020000	; wonly$ write-only
	dsRON_ := 040000	; ronly$ read-only
	dsRTA_ := 0100000	; filst$ rt11a file-structured

				; device codes
	dsNFC := 0205		; NF:
	dsFXC := 0206		; FX:
If 0
				; RUST/XM???
  type	rtTdvi			; device information
  is	Vdsw : WORD		; RT-11 status
	Vatt : WORD		; additional attributes
	Vsz0 : WORD		; device length
	Vsz1 : WORD		; high-order device length
  end
				; Vatt
	dvDSK_ := 01		; disk-like device
	dvCON_ := 02		; .DSK container file
	dvDIR_ := 04		; sub-directory
	dvDEV_ := 010		; no filename (except container)
				;
	dvSYS_ := 020		; system device
	dvREM_ := 040		; remote (NF:)
	dvSUB_ := 0100		; sub-directory channel

;	dvLOG_ := 0100		; Logical disk
;	dvWLD_ := 0200		; Wildcards in spec
End

end header
