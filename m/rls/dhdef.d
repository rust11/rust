header	dhdef - dosbatch file system

  type	dxTmfh		 ; master file directory header
  is	Vmf2 : WORD	 ; link to first MFP block
	Vbms : WORD	 ; bitmap start block
	Abmp : [254] WORD; bitmap block number array (zero terminated)
  end

  type	dxTbmp		 ; bitmap block
  is	Abmp : [256] WORD; bitmap array
  end			 ; each word maps 16 blocks, 0..15 ascending 

  type	dxTufp 		; user file directory pointers
  is	Vuic : WORD	; user identification code
	Vufd : WORD	; user file directory start block
	Vufc : WORD	; number of words in UFD entry
	Vf00 : WORD	;
  end

  type	dxTmfp		; master file directory pointer block
  is	Vnxt : WORD	; next MF1 block
	Aufp : [64] dxTufp ; UFP array
  end

  type	dxTufx		; user file directory entry
  is	Anam : [2] WORD	; filename
	Vtyp : WORD	; file type
	Vdat : WORD	; date and flag
	Vnfb : WORD	; next free byte
	Vsta : WORD	; start block
	Vlen : WORD	; block length
	Vlbw : WORD	; last block written
	Vflg : WORD	; flags (protection, usage, lock)_
  end

	dxDAM_ := 0007777 ; Vdat: date mask
	dxLNK_ := 0100000 ; Vdat: linked file	
	dxOWN_ := 0300	; owner protection
	dxGRP_ := 0070	; group protection
	dxWLD_ : 0007	; world protection

  type	dxTufd		; user file directory segment
  is	Vnxt : WORD	; next directory segment
	Aent : [28] dxTufx ; entries
	Af00 : [4] WORD	; unused
  end

end header
