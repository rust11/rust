header	rtcla - RT-11 file class

  type	rtTcla			; device information
  is	Vflg : WORD		; file class flags
	Vcod : BYTE		; file class code (later)
	Vsta : BYTE		; operation status
	Vsiz : WORD		; 16-bit size
	Vsz0 : WORD		; 32-bit size
	Vsz1 : WORD		; 
	Vdsw : WORD		; RT-11 device status word
  end
				; Vflg
	fcFIL_ := 01		; opened as file
	fcDEV_ := 02		; opened as device
	fcDIR_ := 04		; opened as directory
	fcCON_ := 010		; opened as container disk file
;	       := 020
;	       := 040
	fcTER_ := 0100		; terminal
	fcPRO_ := 0200		; protected file
	fcSYS_ := 0400		; system device

	fcMAG_ := 01000		; magtape
	fcCAS_ := 02000		; cassette
	fcDSK_ := 04000		; disk-like device
	fcVIR_ := 010000	; logical disk
	fcPAR_ := 020000	; disk partition (other than zero)
	fcNET_ := 040000	; network channel
	fcSUB_ := 0100000	; sub-directory channel
				; status
;	fcDEV_ := fcDEV_	; device access okay
;	fcFIL_ := fcFIL_	; file access okay

end header
