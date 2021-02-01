header	hodef - rt-11 home block

  type	hoTbup
  is	Asig : [3] char		; "BUP" backup ID
	Anam : [9] char		; filename 
	Vvol : word		; volume number
	Vtot : word		; volumes-in-set count
	Vlst : word		; last volume size
  end

  type	hoTrtm
  is	Vsig : WORD		; RTEM signature/guard
	Vblk : WORD		; first user block
  end

  type	hoThdr 
  is	Vclu : WORD	; 1	; pack cluster size
	Vseg : WORD	; 6	; first segment block
	Vver : WORD	; ^rV5x	; rad50 system version (V3A, V4A or V05)
	Avol : [12] char;"RT.."	; volume id
	Aown : [12] char;"IAN."	; owner name
	Asys : [12] char;"RT.."	; system id
	Vf00 : word		; unused
	Vcks : WORD		; checksum
  end

	hoREP := 66		; bad block area size (words)
	hoRES := 19		; directory restore size (words)

  type	hoTdsk
  is	Arep : [hoREP] WORD	; bad block replacement area
	Ares : [hoRES] WORD	; directory restore area
	Ibup : hoTbup		; backup area
	Af01 : [130] WORD	;
	Irtm : hoTrtm		; RTEM area
	Af02 : [7] WORD		;
	Ihdr : hoThdr		; home block header
  end

end header
