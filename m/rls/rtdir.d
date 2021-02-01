header	rtdir - RT11x file structure

  type	rtTent
  is	Vsta : WORD		; status
	Anam : [3] WORD		; filename in rad50
	Vlen : WORD		; length
	Vtim : WORD		; time in 3 second units
	Vdat : WORD		; date
	Vctl : WORD		; various
	Vuic : WORD		; UIC
	Vpro : WORD		; protection
  end

  type	rtThdr
  is	Vtot : WORD		; total segments
	Vnxt : WORD		; next segment
	Vlst : WORD		; last segment in use
	Vext : WORD		; extra bytes per entry
	Vblk : WORD		; start block of first entry
	Aent : [1] rtTent	; array of entries
	Amor : [512-5-(#rtTent/2)] WORD	; entry space
  end
	rtEXT_ := (~(0776))	;  Vext valid mask (even && lt 512)
	rtRTX := 6		; extra bytes for RT11X
	rtRTA := #rtTent-rtRTX	; RT11A entry size

	rtTEN_ := 0400		; tentative file
	rtEMP_ := 01000		; empty entry
	rtPER_ := 02000		; permanent entry
	rtEND_ := 04000		; end of segment
	rtPRO_ := 0100000	; protected file

	rtTIM_ := 0100000	; Vtim flag
	rtREM_ := 03		; time remainder in Vctl
	rtBYT_ := 03774		; byte remainder in Vctl

end header
