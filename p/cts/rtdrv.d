header	rtdrv - RT-11 drivers

data	rtTdrv - driver root

	rxHAN := 031066

  type	drThdr
  is	Vgua : WORD		;drest handler guard
	Pftp : WORD		;fetch pointer
	Prsp : WORD		;release
	Plop : WORD		;load
	Punp : WORD		;unload
	Pfop : WORD		;format
	Pshp : WORD		;show
	Pf0p : WORD		;reserved pointer
				;
	Vcla : BYTE		;drest class code			$dcdef
	Vmod : BYTE		;drest class variant mod flags		$dcdef
				;drptr destroys dr.mod
	Vsfm : [6] BYTE		;drspf special function map
				;map clears dr.sft
	Vsft : WORD		;drspf special function table address
	Vrep : WORD		;drest replacement table address
	Af00 : [7] WORD		;
;		34:40 - 52-66	;unused
	Vhsz : WORD		;handler size
	Vdsz : WORD		;device size
	Vsta : WORD		;device status				$dsdef
	Vsyg : WORD		;sysgen options				$sgdef
	Vbpt : WORD		;boot pointer
	Vble : WORD		;boot length
	Vbrd : WORD		;boot read routine
				;
	Vdat : WORD		;drest data - data table address
	Vtyp : WORD		;drest type - .rad50 "typ"
				;
	Vdaf : WORD		;drdat - data usage flag
	Vdap : WORD		;drdat - data table pointer
	Vdal : WORD		;drdat - data control table byte length
				;
	Vuni : WORD		;druni - data table pointer
	Af01 : [2] WORD		;
				;
	Vuse : WORD		;druse table pointer
	Af02 : [27] WORD	; 104-170
	Vccs : WORD		;cti csr if mod2&v2
	Vpcs : WORD		;pdp csr if mod2&v2
	Vdcs : WORD		;display csr
	Vcsr : WORD		;csr address
  end

	drGUA := rxHAN		;driver guard
	drFTC := 00		;fetch
	drRLC := 02		;release
	drLOC := 04		;load
	drUNC := 06		;unload
	drRSC := 010		;reset release (dispatched as drrlc.)
	drSLC := 012		;system device load (dispatched as drloc.)
;	drFOC := 010		;format
;	drSHC := 012		;show
;	drMUC := 014		;maximum utility code
	drNFL_ := 0100000	;nofetch/noload flag

data	drTinf - driver info

  type	drTinf			
  is	Ihdr : drThdr		; driver block 0
	Vsta : WORD		; status - see below
	Pfil : * FILE		;
	Adev : [4] char		; HD  -- device name
	Adrv : [4] char		; HDX -- driver name
	Asuf : [2] char		; X   -- driver suffix
	Aspc : [16] char	; HD3:HDX.SYS
	Vuni : int		; device unit
  end
	drFND_ := 1		; driver located
	drIPT_ := 2		; input okay
	drVAL_ := 4		; is a driver
	drRST_ := 8		; RUST driver

end header
