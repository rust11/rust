header	btdef - RT-11 bootstrap
era$c := 1

	btBOT := 07354		; rad50 /bot/
	btRTE := 071645		; rad50 /rte/
	btRST := 071614		; rad50 /rst/

	btHDR := 03714 		; header offset in bytes
	btNAM := 18		; length of name string
				; standard RT-11 is 28 bytes
;	RUSTxx/XM V99.99 0
;	123456789012345678

  type	btThdr
  is	Vtmv : WORD	;retver - RTEM version (rts$id)
	Vdvn : WORD	;b$devn - DLX - device name with suffix in rad50
	Vdvs : WORD	;b$devs - DL  - device name without suffix in rad50
	Vdvu : WORD	;b$devu - device unit (^rbot=bootable, ^rrte=>rtem)
	Amon : [2] WORD	;b$fnam - monitor - .rad50 /BOOT  /
	Vrea : WORD	;b$read - read routine start address
	Vhto : WORD	;syhtop - system handler top address
	Vdup : WORD	;dupflg - copied from @#0 - 0 if from DUP
	Vrms : WORD	;$rmsiz - v3/v5 monitor size in bytes
	Anam : [btNAM] char;	- v3/v5 boot string
	Aimg : [4] WORD	;	- RUST boot image - .rad50 /SY RUST  SAV/
	Vrst : WORD	;	- RUST rad50 /RST/ signature
	Vsuf : WORD	;suffx	- __X - v5 rad50 handler suffix
	Vsyg : WORD	;syop	- v5 sysgen options (probably v4 as well)
			;	- v3 swap file size (zero)
If era$c
	Vers : WORD	;	- .rad50 /ERA/ for extended time header
	Vera : WORD	;	- extended time
End
  end

  type	btTsec
  is	Asec : [btHDR] char	; secondary boot	
	Ihdr : btThdr		; bootstrap header
  end

  type	btTinf
  is	Ihdr : btThdr		; boot header
	Vsta : WORD		; status
	Adev : [4] char		; device name
	Asuf : [2] char		; suffix
	Amon : [8] char		; monitor name
	Aimg : [16] char	; RUST load image name
If era$c
	Vhtz : WORD		; 50/60 hertz
	Vqui : WORD		; Quiet=0, Noquiet=1
End
  end
	btIPT_ := 1		; input okay
	btBOT_ := 2		; bootable
	btRTE_ := 4		; RTEM
	btRST_ := 8		; RUST

;	bt_inf : (*FILE, *btTinf, *char) int

end header
