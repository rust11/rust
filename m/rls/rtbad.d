header	rtbad - RT-11 bad block handling
include rid:fidef

	bdMAX := 128

	bdREC := 128		; maximum recording entries
	bdREP := 32		; maximum replacement entries
	bdDLX := 10		; maximum replacement blocks for DL: RL01/RL02
	bdDMX := 32		; maximum replacement blocks for DM: RK06/RK07

  type	bdTrng			; range
  is	Vsta : int		; beginning value
	Vpnt : int		; point (count, next, etc)
	Vlim : int		; limit
  end

  type	bdTrec			; recording entry
  is	Vtyp : WORD		; bad block type
	Vblk : WORD		; block number
	Vcnt : WORD		; block count
  end

	bdSFT_ := BIT(0); Vtyp	; soft
	bdHRD_ := BIT(1)	; hard
	bdINH_ := BIT(2)	; inherited

  type	bdTrep			; replacement entry
  is	Vblk : WORD		; bad block number
	Vrep : WORD		; replacement block number
  end

  type	bdTbad			; bad block map
  is	Pfil : * FILE		; device/file
	Pseg : * void		; segment control
	Vflg : int		; access type
	Verr : int		; I/O errors during ACP operations
				; 
	Iscn : bdTrng		; scan control
	Idet : bdTrng		; detected control
				;
	Irec : bdTrng		; recording control
	Arec : [bdREC] bdTrec	; recording table
				;
	Irep : bdTrng		; replacement control
	Arep : [bdREP] bdTrep	; replacement table
  end

	bdINS_ := BIT(0); Vflg	; inspect only (used for directory/files)
	bdOVR_ := BIT(1)	; recording table overflow
	bdLOG_ := BIT(2)	; log during scan
	bdSYS_ := BIT(3)	; bad blocks in system area
	bdCRE_ := BIT(4)	; not all bad block files were created

end header
