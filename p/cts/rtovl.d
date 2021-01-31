header	rtovl - RT-11 overlay structures

;	This table is located with:
;
;	mov	j$blot,r0
;	sub	#ov.lot,r0
;
  type	ovTrdb		; region definition block
  is	Vrid : WORD	; region id
	Vsiz : WORD	; region page size (= $ovdf3 from LINK)
	Vsta : WORD	; region status
  end

  type	ovThdr
  is	Pwde : * ovTwdb	;$vdf5 -> $ovdf5 - WDB end pointer
	Pwdb : * WORD	;$vdf4 -> $ovdf4 - WDB table begin pointer
	Ireg : ovTrdb	; overlay region
	Prha : * WORD	;$vdf1 -> $ovdf1 - root high address
	Plha : * ovTlow	;$vdf2 -> $ovdf1 - low overlay area high address
	Alot : [] ovTlow;$ovtab <- j$blot - overlay table (origin)
  end
;
; j$blot -> $ovtab = start of low overlay table
;
  type	ovTlow		;low-memory segment 
  is	Vadr : WORD	;low-memory - virtual address
	Vblk : WORD	;low-memory - block number
	Vwct : WORD	;low-memory - word-count
  end
;			;(variable number of these)
;
; j$bvot -> virtual overlay table
;
  type	ovTvir		;virtual segment
  is	Pwdb : WORD	;virtual - wdb pointer (va in wdb)
	Vblk : WORD	;virtual - block number
	Vwct : WORD	;virtual - word-count
  end
;			;(variable number of these)
;
; No pointer - must be searched for with pattern matching
;
  type	ovTdum
  is	Vjsr : WORD	;dummy - jsr r5,$ovrh(v) (pattern=4767)
	Vrou : WORD	;dummy - $ovrh(v) (pattern $ovrh(v))
	Vseg : WORD	;dummy - segment number * 6
	Vadr : WORD	;dummy - virtual address
  end
;			;(variable number of these)
;
; ov.wdb==$vdf4 -> $ovdf4 - wdb begin
;
;	ov.wdt	null,0	;wdb's (xm.wbs)
;			;(variable number of these)
;
; ov.wdb==$vdf5 -> $ovvd5 - wdb end
;
end header
