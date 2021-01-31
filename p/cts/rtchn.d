header	rtchn - RT-11 channel

  type	rtTchn
  is	Vcsw : WORD		; channel status word
	Vblk : WORD		; start block 
	Vlen : WORD		; file length
	Vuse : WORD		; blocks used (for tentative file)
	Vioc : BYTE		; i/o count
	Vuni : BYTE		; device unit and job #
  end

	chHER_ := 01		; hard error
	chIDX_ := 076		; device index
	chSHR_ := 0100		; shared file (XM)
	chTEN_ := 0200		; tentative file
;		  017400	; XM access
	chEOF_ := 020000	; end of file seen
	chSUB_ := 040000	; sub-directory channel
	chACT_ := 0100000	; channel active
				;
	chTTI := 0		; TT: index
	chSYI := 2		; SY: index
;	chNLI := 4		; NL: index (XM only)

	chIMG  := 15		; image channel

  type	rtTcst
  is	Vcsw : WORD
	Vblk : WORD
	Vlen : WORD
	Vuse : WORD
	Vuni : WORD
	Vdev : WORD
  end

  type	chTinf
  is	Icst : rtTcst
	Vsta : WORD
	Adev : [4] char
  end

end header
