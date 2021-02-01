header	skdef

; type	skTnod
; is	Vlen : WORD		; length of entry
;	Vprv : WORD		; length of previous entry
;	Vtyp : char		; entry type (for extensions)
;	Astr : [n] char		; string (extended)
; end

  type	skTstk
  is	Pbuf : * char		; stack buffer base
	Pptr : * char		; stack buffer pointer
	Vlen : int		; stack buffer length
	Vdsk : int		; disk transfer size
	Vrem : int		; remaining bytes in memory stack
	Vprv : int		; length of previous entry
				;
	Verr : int		; stack error, unwind
				;
	Hfil : * FILE		; file handle
	Vsiz : size	;?	; file size
	Vpos : size	;?	; Pbuf file position
  end
				; Vtyp
	skTYP_ := 1		; has type
	skWRD_ := 2		; has word length

;	deallocate control

	skBUF_ := 1
	skSTK_ := 2
	skFIL_ := 4
	skALL_ := 7

;	errors

	skOPN  := 1
	skREA  := 2
	skWRI  := 3
	skLEN  := 4

	sk_mak : () *skTstk
	sk_alc : (*skTstk, *char, int, int) *skTstk
	sk_dlc : (*skTstk, int)
	sk_psh : (*skTstk, *char, int, int)
	sk_pop : (*skTstk, *char, *int, int)

end header
