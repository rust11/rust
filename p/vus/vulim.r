file	vuroo - VUP root
include	rid:rider
include	rid:csdef
include	rid:medef

;	KMON/DCS dispatch /R:RET incorrectly

;	Functions

	vfCRE := 1 
	vfTRU := 2
	vfUND := 3
	vfERA := 4
	vfRES := 5
	vfIMG := 6
	vfSCN := 7
	vfBOO := 8
	vfSQU := 9
	vfACT := 10
	vfINI := 11
	vfVOL := 12
	vfEXT := 13

;	options and values

	viBAD := 1
	viRET := 2
	viLST := 3 
	viFIL := 4 
	viSTA := 5 
	viVER := 6
	viSEG := 7
	viFOR := 8 
	viREP := 9
	viRET := 10
	viEXT := 11
	viDEV := 12
	viVOL := 13
	viONL := 14
	viNBT := 15

	viWRD := 16
	viNQY := 17
	viWAI := 18
	viST2 := 19

	viBAD_ := BIT(1)
	viRET_ := BIT(2)
	viLST_ := BIT(3)
	viFIL_ := BIT(4)
	viSTA_ := BIT(5) 
	viVER_ := BIT(6)
	viSEG_ := BIT(7)
	viFOR_ := BIT(8) 
	viREP_ := BIT(9)
	viRET_ := BIT(10)
	viEXT_ := BIT(11)
	viDEV_ := BIT(12)
	viVOL_ := BIT(13)
	viONL_ := BIT(14)
	viNBT_ := BIT(15)

	viWRD_ := BIT(0)
	viNQY_ := BIT(1)
	viWAI_ := BIT(2)
	viST2_ :- BIT(3)

	C := csCMD_

;	A J L M P unused

  init	vuAent : [] csTent
  is ;	swi fil	keyword	option	type	function
	'B',0,	0,	viBAD,	0	;  /BAD
	'B',0,	kwRET,	viRET,	0	;  /BAD=RETAIN
	'C',0,	0,	0,	vfCRE	;* CREATE	
	'C',0,	kwTRU,	0,	vfTRU	;
	'C',0,	kwUND,	0,	vfUND	;* UNDELETE
	'C',0,	kwERA,	0,	vfERA	;* ERASE
	'D',0,	0,	0,	vfRES	;  /RESTORE
	'E',0,	csRQD,	viLST,	0	;  /LAST=n
	'F',0,	0,	viFIL,	0	;  /FILES
	'G',0,	csRQD,	viSTA,	0	;  /START=n
	'G',0,	csRQD,	viST2,	0	;  /START=n (may be given twice)
	'H',0,	0,	viVER,	0	;  /VERIFY
	'I',0,	0,	0,	vfIMG	;* COPY/DEVICE
	'K',0,	0,	0,	vfSCN	;* DIR/BAD
	'N',0,	csRQD,	viSEG,	0	;  /SEGMENTS=n
	'O',0,	0,	0,	vfBOO	;* BOOT
	'Q',0,	0,	viFOR,	0	;  /FOREIGN
	'R',0,	0,	viREP,	0	;  /REPLACE
	'R',0,	kwRET,	viRET,	0	;  /REPLACE:RETAIN
	'S',0,	0,	0,	vfSQU	;* SQUEEZE
	'T',0,	csRQD,	viEXT,	vfEXT	;* CREATE/EXTENSION
	'U',0,	csR50,	viDEV,	vfACT	;* COPY/BOOT=[dev]
	'V',0,	0,	viVOL,	vfVOL	;  INIT|SHOW/VOLUMEID
	'V',0,	kwONL,	viONL,	vfINI	;  [INIT]/VOLUMEID=ONLY
	'W',0,	0,	viWAI,	0	;  /WAIT
	'X',0,	0,	viNBT,	0	;  SQUEEZE/NOBOOT
	'Y',0,	0,	viNQU,	0	;  /NOQUERY
	'Z',0,	csDEC,	viWRD,	vfINI	;* INIT[/EXTRA=n]
	0,	0,	0,	0
  end

;	ERASE/DEVICE/NODELETE/
;
;	/D	RESTORE
;	/Z/D	INIT/RESTORE cm_ini has to dispatch this.

	vyCOM_ := viWAI_|viNQU_

	vxINI_ := viBAD_|viRET_|viVER_|viSEG_|viREP_|viVOL_|viONL_|viRES_
	vyINI_ := viBAD_|vyCOM_

	vxIMG_ := viSTA_|viLST_|viVER_|viFIL_|viREP_
	vyIMG_ := viST2_|vyCOM_
	vxSCN_ := viSTA_|viLST_|viFIL_

  init	vuAsyn : [] csTsyn
  is	vfCRE, cm_cre, viSTA_, vyCOM_, 0
	vfTRU, cm_tru, viEXT_, vyCOM_, 0
	vfUND, cm_und, 0,    , vyCOM_, 0
	vfERA, cm_era, 0,    , vyCOM_, 0
	vfRES, cm_res, 0,    , vyCOM_, vfINI_
	vfIMG, cm_img, vxIMG_, vyIMG_, 0
	vfSCN, cm_scn, vxSCN_, vyCOM_, 0
	vfBOO, cm_boo, viFOR_, vyCOM_, 0
	vfSQU, cm_squ, viNBO_, vyCOM_, 0
	vfACT, cm_act, viDEV_, vyCOM_, 0
	vfINI, cm_ini, vxINI_, vyINI_, 0OL_|vfSCN_
	vfVOL, cm_vol, viVOL_, vyCOM_, 0
  end

  	vuAdef : [4] WORD = {0,0,0,0}	; default file types

;	/C:UND		UNDELETE a file
;	/C:ERA		ERASE device or file
;    	/D	[/Z]	RESTORE volume
;  /I/K	/E:n		Last block
;  /I/K	/F		Display badblock names, copy/device/files
;/C/I/K	/G:n		First block
;  /I  	/H		Verify init
;	/I	/E/G/H	COPY/DEVICE
;	/J
;	/K 	/E/F/G	DIR/BADBLOCKS
;	/L
;	/M
;    /Z	/N:n		Number of directory segments (1:37)
;	/O	/Q	BOOT device or file
;	/P
;    /O	/Q		Boot foreign
;  /I/Z	/R		Scans and creates bad block replacement table
;??? /Z	/R:RET		Retains existing replacement table
;	/S	/X	SQUEEZE
;	/T:n		EXTEND file by n blocks
;/C:TRU	/T:n		Specify truncate size
;	/U		COPY/BOOTSTRAP to device
;	/U:dev		Specify device handler for bootstrap
;	/V		DIR/VOLUMEID device
;    /Z	/V		Init and write label
;    /Z	/V:ONL		Write label only
;    /*	/W		Wait before beginning operations
;    /S	/X		Don't boot after squeeze
;    /*	/Y		Noquery
;	/Z /B/D/H/N/R/V	INIT device
;	/Z:n		Specifies extra words per directory entry
	boot		dev:	  /foreign
	create		fil	  /start=n/blocks=n/bytes=n
	copy/boot=drv	fil dev:
	copy/dev	spc spc	  /start=n/end=n/blocks/rep/bad/verify 
				  /duplicate
	dir/bad		dev:	  /out:fil/start=n/end=n/blocks=n
	dir/vol		dev:	  /out:fil
	erase		dev:	  /delete
	extend		fil	  /blocks=n/bytes=n
	init		dev:	  /seg=n/ext=n /bad/rep/retain /vol/only
				  /verify /rt11*/rsx/vms
				  /duplicate
	restore		dev:
	squeeze		dev:	  /soft/hard/noboot
				  /directory
	truncate	fil	  /blocks=n/bytes=n

	vxINI_ := viBAD_|viRET_|viVER_|viSEG_|viREP_|viVOL_|viONL_|viRES_
	vyINI_ := viBAD_|vyCOM_

	vxIMG_ := viSTA_|viLST_|viVER_|viFIL_|viREP_
	vyIMG_ := viST2_|vyCOM_
	vxSCN_ := viSTA_|viLST_|viFIL_

  init	vuAsyn : [] csTsyn
  is	vfCRE, cm_cre, viSTA_, vyCOM_, 0
	vfTRU, cm_tru, viEXT_, vyCOM_, 0
	vfUND, cm_und, 0,    , vyCOM_, 0
	vfERA, cm_era, 0,    , vyCOM_, 0
	vfRES, cm_res, 0,    , vyCOM_, vfINI_
	vfIMG, cm_img, vxIMG_, vyIMG_, 0
	vfSCN, cm_scn, vxSCN_, vyCOM_, 0
	vfBOO, cm_boo, viFOR_, vyCOM_, 0
	vfSQU, cm_squ, viNBO_, vyCOM_, 0
	vfACT, cm_act, viDEV_, vyCOM_, 0
	vfINI, cm_ini, vxINI_, vyINI_, 0OL_|vfSCN_
	vfVOL, cm_vol, viVOL_, vyCOM_, 0
  end

;	/C:UND		UNDELETE a file
;	/C:ERA		ERASE device or file
;    	/D	[/Z]	RESTORE volume
;  /I/K	/E:n		Last block
;  /I/K	/F		Display badblock names, copy/device/files
;/C/I/K	/G:n		First block
;  /I  	/H		Verify init
;	/I	/E/G/H	COPY/DEVICE
;	/J
;	/K 	/E/F/G	DIR/BADBLOCKS
;	/L
;	/M
;    /Z	/N:n		Number of directory segments (1:37)
;	/O	/Q	BOOT device or file
;	/P
;    /O	/Q		Boot foreign
;  /I/Z	/R		Scans and creates bad block replacement table
;??? /Z	/R:RET		Retains existing replacement table
;	/S	/X	SQUEEZE
;	/T:n		EXTEND file by n blocks
;/C:TRU	/T:n		Specify truncate size
;	/U		COPY/BOOTSTRAP to device
;	/U:dev		Specify device handler for bootstrap
;	/V		DIR/VOLUMEID device
;    /Z	/V		Init and write label
;    /Z	/V:ONL		Write label only
;    /*	/W		Wait before beginning operations
;    /S	/X		Don't boot after squeeze
;    /*	/Y		Noquery
;	/Z /B/D/H/N/R/V	INIT device
;	/Z:n		Specifies extra words per directory entry
code	vu_sta - start VUP

;	VUP bypasses C's standard main()

	new(x) = (me_acc (#x))

  func	start
  is	ctx : * vuTctx = new(vuTctx)
	csi : * csTcsi = new(csTcsi)
	csi->Pimg = "VUP"
	csi->Pctx = ctx
	csi->Pent = vuAent
	csi->Psyn = vuAsyn
	csi->Pdef = vuAdef
	csi->Vflg = csDIS_|csFUN_|csERR_
	cs_csi (csi) while 1
  end
code	cm_res - Restore volume

;	INIT/RESTORE dev:
;
;	VUP dev:*=/D/Z
;
;	DEV:	Must be an RT11A volume.
;
;	Use the information stored in the home block to
;	restore the initial directory header and the first
;	two directory entries. Only works if the volume
;	hasn't been written to since the INIT.

  proc	cm_res
  is	hom : * char = ctx->Pbl0	; where the home block goes
	seg : * rtTdir = ctx->Psg0	; where the segment goes
	vu_opn (vuIF0, vuPIO)		; open device for physical I/O
	vl_dev (vuRTA, vuVAL)		; must be RT11x
	vu_hom (vuREA, vuVAL)		; read the home block
	vu_seg (0, 0, vuREA, vuVAL)	; read segment
;	move in data
	vl_seg (vuRTA)			; validate result segment
	vu_hom (vuWRI, 0)		; validate it
	vu_clo (			; close open files
  end

code	cm_vol - Show volumeid - label and owner

;	VUP dev:/V
;
; 	Redundant functionality -- VIR does this.
;
;	Volume ID: RT11A
;	Owner    : IAN

  proc	cm_vol
	ctx : * vuTctx
  is	hom : * char = ctx->Pbl0	; where the home block goes
	lab : [xxx] char
	vu_opn (vuIF0, vuPIO)		; open device for physical I/O
	vl_dev (vuRTA, vuVAL)		; must be RT11x
	vu_hom (vuREA, vuVAL)		; read the home block
	me_mov (hom+xxx, lab, yyy)	; move it in
	PUT(
  end

code	cm_ini - INIT volume

;	Initialise RT-11 disk-like device
;
;	dd:*=/Z	INIT dev:
;	/Z:n	/EXTRA:n
;	/N:n	/SEGMENTS:n
;	/B:RET	/BAD[:RETAIN]
;	/R:RET	/REPLACE[:RETAIN]
;	/V:ONL	/VOLUME[:ONLY]
;	/D	/RESTORE - see cm_res
;
;	/B	Replaces badblocks with FILE.BAD
;	/B:RET	Retains badblock files
;	/N:n	Number of directory segments (1:37)
;	/R	Scans and creates bad block replacement table
;	/R:RET	Retains existing replacement table
;	/V	Init and write label
;	/V:ONL	Write label only
;	/Z	Init device
;	/Z:n	Specifies extra words per directory entry
;
;
;	INIT/DUPLICATE=dup: dev:
;
;	dev:*=dup:/Z:DUP
;
;	Defaults are taken from DUP: for:
;
;	o  /segments, /extra
;	o  Volumeid
;	o  Bad block table
;	o  Replacement table

  type	vuTini
  is	Adev : 
	Vseg : int
	Vext : int
	Vbad : int
	Vrep : int
	Vvol : int
	Alab : [12] char
	Aown : [12] char
  end


  proc	cm_ini
	ctx : * vuTctx
  is	csi : * csTcsi = ctx->Pcsi
	opt : * csTqua = csi->Aqua
	ini : vuAini = {0}
	ini->Vdev = csi->Alft[0][0]
	ini->Vseg = opt[viSEG]		; segments
	ini->Vext = opt[viWRD]		; extra words
	vu_ini (ctx, ini)		; go do it
  end

	dev : * duTfil = ctx->Pof0
	boo : * rtTboo
	hom : * rtThom
	
	vu_opn (dev, "device")
	vu_vol (dev, )		; check the volume
	exit in_res (ctx) if vuVres eq r5ONL ;

	in_sav (ctx, dev)		; save init information
	in_dir (ctx)			; init directory
	bb_scn (ctx)			; bad block scan

	vu_err (E-"No device specified", 0) if !dev
	ut_opn (ctx, 
	mk_bbl (ctx)
	mk_hom (ctx)
	rt_wri (opt->Vchn, opt->Pbuf, 512, 0)

	cu_rea (ctx, chn, 0, buf, 512)
  end
code	cm_act	activate - copy bootstrap to volume

;	COPY/BOOT[:dd] sys:system dev:
;
;	VUP dev:*=sys:system.*/U:drv
;
;	DEV:	RT-11 DUP defaults DEV: to the system device.
;		We issue a message "no output device specified".
;
;		RT-11 requires that DEV: be an RT11A volume.
;		So do we at present, but that might change.
;
;	SYS: 	Defaults to DK:*.SYS
;
;		RT-11 requires that SYS: be an RT11A volume (because
;		it does the directory scan internally).
;		We use ordinary lookups and don't require RT11A.
;
;	DD	Defaults to DEV:DD?.SYS, where "?" is the suffix.
;
;		RT-11 searchs SYSTEM.SYS for the suffix.
;		So do we, but we also accept an explicit suffix.
;
;		The driver must be present on the target device.
;
;		RT-11 uses an internal lookup. We don't.
;
;		RT-11 requires that DD?.SYS and SYSTEM.SYS have the
;		same SYSGEN options. We don't for BOOT.SYS.
;		(BOOT.SYS has no SYSGEN options).
;
;	o  Copy the primary bootstrap
;	o  Copy the secondary bootstrap
;	o  Restore the original bootstrap if the secondary fails

  proc	cm_cbo
	ctx : * vuTctx
  is	drv : * vuTfil = &ctx->If0
	img : * vuTfil = &ctx->If1
	dev : * vuTfil = &ctx->If2

	rt_opn (drv, "rw", &csi->Aopt[0], "device")
	rt_opn (drv, "r", &csi->Aipt[0], "image")

;	Locate driver
;
;	Locate boot in driver

	vu_err ("E-No image specified", "")
	vu_err 

	han : * BYTE
	boo : * BYTE
	sec : * BYTE

	boo = han + x
	rt_ipt (drv, blk, 512) 
	rt_rea (img, buf, #1, 512*4) 
	rt_wri (dev, blk, 0, 512)	; write primary bootstrap
	rt_wri (dev, buf, 2, 512*4)	; secondary bootstrap
	rt_clo (dev)
  end
code	cm_boo - boot volume

;	Later - BOOT handled by DCL.

code	cm_squ - squeeze volume

;	Later - SQUEEZE/SOFT handled by VIP.

code	cm_era - erase file or volume

;	Later - ERASE does this.

code	cm_tru - truncate file

;	Later - future stuff.

code	cm_ima - copy device image

;	COPY/DEVICE src:/START:n/END:n dst:/start:n /RETAIN
;	COPY/DEVICE src:/START:n/END:n dst:spec     /FILE[S]
;
;	/RETAIN
;	o  Lost in RT-11 V5.5 for some reason. Typo?
;	o  /R and not /R:RET as for INIT
;
;	/FILES
code	cm_scn - scan bad blocks

;	DIRECTORY/BAD/FILES dev:
;
;
;	INIT/BAD:RETAIN/REPLACE:RETAIN also needs this stuff. 
code	cm_ext - extend file

;	CREATE/EXTENSION:n filespec
;
;	We send this task to the RT11A ACP using EVA
code	cm_squ - squeeze volume

;	SQUEEZE/NOBOOT dev:
;
;	VUP =dev:/S/X		SQUEEZE/NOBOOT dev:
;	VUP out:*=dev:/S	COPY/SQUEEZE dev: out:
;
;	SQUEEZE IN-PLACE:
;
;	o  *.BAD files can't be moved. We look-ahead to fill gaps.
;
;	o Segments are compressed and written out on-the-fly.
;	  Again, *.BAD complicates this process.
;
;	o Write errors are handled by restoring the file.
;	  If that, in turn, fails, then we're in deep shit.
;	  A bad-block entry is created for the blocks concerned.
;
;	o Build a map of the directory linkage structure.
;	o Scan the directory front for a collection of gaps.
;	o Scan backwards from directory end for candidates files
;	  to fill the gaps.
;	o Files may not be in use.
;	o Copy those files in optimal order.
;	o If the directory is full, compress it and repeat.
;	o Repeat the process until no more candidates.
;	o Compress the directory.
;
;
;	COPY/SQUEEZE
;
;	o Output directory must be initialized.
;	o Copy files ordinarily until a badblock file is detected.
;	o Look-ahead (multi-volume style) for files to fill the gap.
;	o Repeat
;	o Compress output directory
;
;
;	COPY/DUPLICATE
;
;	o Same as COPY/SQUEEZE except output volume is initialized.
;	o INIT parameters are copied from input volume.
;
;
;	SQUEEZE/DIRECTORY
;
;	o Compresses directory.
code	utilities

  func	vu_hom 
	opr : int
	mod : int
  is	vu_trn (opr, ctx.Hpri, ctx->Pboo, 0, 256., "home block")
	reply that
  end

  func	vu_boo
	opr : int
	mod : int
  is	vu_trn (opr, ctx.Hpri, ctx->Pboo, 0, 256., "boot block")
	reply that
  end

  func	vu_boo
	opr : int
	seg : int
	mod : int
  is	seg = (seg * 2) + 4
	vu_trn (opr, ctx.Hpri, ctx->Pseg, seg, 512., "directory")
	reply that
  end

  func	vu_buf
	opr : int
	seg : int
	mod : int
  is	seg = (seg * 2) + 4
	vu_trn (opr, ctx.Hpri, ctx->Pseg, seg, 512., "directory")
	reply that
  end


  func	vu_trn
	opr : int
	fil : * FILE
	buf : * void
	blk : int
	cnt : int
	com : * char
	msg : [60] char
	rt_see (fil, blk*512)
	res = rt_rea (fil, buf, cnt*2) if opr eq vuREA
	res = rt_wri (fil, buf, cnt*2) otherwise
	fine if res
	st_cop ("E-Error ", msg)
	st_app ("reading ", msg) if opr eq vuREA
	st_app ("writing ", msg) otherwise
	st_app (com, msg)
	fi_msg (fil, msg, 0)
	fail
  end
