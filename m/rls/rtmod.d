header	rtmod - rt-11 module definitions
include	rid:eldef

;	rtutl.d	- common RT-11 routines (date/time pack/unpack)
;	rtmod.d	- lots of RT-11 environment -- many 2las
;	rtdef.d - reserved for RT11A
;
;	ch	channel
;	dv	device
;	em	emts
;	rt	types and error codes -- nothing else!
;	rx	rad50
;	ve	vectors

data	rad50 constants

	rxDK	:= 015270
	rxNL	:= 054540
	rxSY	:= 075250
	rxSYS	:= 075273
	rxTT	:= 0100040
	rxVS	:= 0106170
	rxVX	:= 0106500
	rxVX0	:= 0106536

data	rtXXX - hard errors

	rtUSR := -1	; AST called USR
	rtUNL := -2	; unloaded device
	rtDIO := -3	; directory I/O error
	rtFET := -4	; .FETCH error
	rtOVR := -5	; overlay I/O error
	rtFUL := -6	; device full
	rtADR := -7	; invalid address
	rtCHN := -8	; invalid channel #
	rtEMT := -9	; invalid EMT code
	rtBUS := -10	; trap to 4
	rtCPU := -11	; trap to 10
	rtDIR := -12	; invalid/corrupt directory
	rtXFT := -13	; XM .FETCH
	rtFPU := -14	; FPU error
	rtPAR := -15	; parity error	
	rtMMU := -16	; MMU error

data	rtTimg - RT-11 executable image

  type	rtTimg
  is	Vexi : elTwrd
	Af0  : [040-02] char
	Vupc : elTwrd
	Vusp : elTwrd
	Vjsw : elTwrd
	Vusa : elTwrd
	Vtop : elTwrd
	Verr : elTbyt
	Vsev : elTbyt
	Vsys : elTwrd
	Af1  : [0500-056] char
	Acha : [4] elTwrd
	Vcct : elTwrd
	Vcst : elTwrd
	Af2  : [01000-0514] char
  end
data	rtTchn - RT-11 I/O channel

  type	rtTchn
  is	Vcsw : elTwrd		; channel status word
	Vblk : elTwrd		; start block 
	Vlen : elTwrd		; file length
	Vuse : elTwrd		; blocks used (for tentative file)
	Vioc : elTbyt		; i/o count
	Vuni : elTbyt		; device unit and job #
  end

	chHER_ := 01		; hard error
	chIDX_ := 076		; device index
	chTEN_ := 0200		; tentative file
	chEOF_ := 020000	; end of file seen
	chACT_ := 0100000	; channel active

	chIMG  := 15		; image channel

data	rtTdst - RT-11 device status

  type	rtTdst
  is	Vcha : elTwrd		; characteristics
	Vhsz : elTwrd		; handler size
	Vadr : elTwrd		; load address + 6
	Vsiz : elTwrd		; volume size in blocks
  end

data	rtTdev - device data

	dvMAX := 16
  type	rtTdev
  is	Alog : [dvMAX] elTwrd	; $unam1
	Vldk : elTwrd 		; DK: logical
	Vlsy : elTwrd 		; SY: logical
	Aequ : [dvMAX] elTwrd	; equivalence
	Vedk : elTwrd 		; DK: equivalence
	Vesy : elTwrd 		; SY: equivalence
	Anam : [dvMAX] elTwrd	; permanent names
	Aent : [dvMAX] elTwrd	; handler entry points
	Vgua : elTwrd; -1	; handler guard (used to get table length)
	Asta : [dvMAX] elTwrd	; device status word (see below)
;	Ahbl : [dvMAX] elTwrd	; SY: block number of device handler
;	Ahsz : [dvMAX] elTwrd	; device handler byte size
	Asiz : [dvMAX] elTwrd	; device size -- in blocks
  end

	dvCOD_ := 0377		; device code
	dvVAR_ := 0400		; variable size device
	dvGAB_ := 01000		; handler accepts generic aborts
	dvFUN_ := 02000		; accepts special functions
	dvHAB_ := 04000		; handler accepts I/O aborts
	dvSTR_ := 010000	; stranger directory device
	dvWON_ := 020000	; write-only device
	dvRON_ := 040000	; read-only device
	dvRTA_ := 0100000	; RT11A file structure
	dvFIL_ := (dvSTR_|dvRTA_) ; file structured

	dvTTI := 0		; TT: index
	dvSYI := 1		; SY: index
	dvNLI := 2		; NL: index

data	rtTqel - RT-11 queue element

  type	rtTqel
  is	Vlnk : elTwrd	; 0	; q.link
				; q.fork
	Vcsw : elTwrd	; 2	; q.csw - channel status word
	Vblk : elTwrd	; 4	; q.blkn - block number
	Vfun : elTbyt	; 6	; q.func - function
	Vuni : elTbyt	; 7	; q.unit - device unit
				; q.jnum - job number
	Vbuf : elTwrd	; 8	; q.buff - buffer address
	Vcnt : elTwrd	; 10	; q.wcnt - word count
				; q.sqbu - ??
	Vast : elTwrd	; 12	; q.comp - completion routine address
				; q.sqry
;	Vpar : elTwrd		; q.par  - XM par
  end
data	rtTmon - monitor header

	emTTO	:=	0341	; .ttyout	em.tto
	emPRI	:=	0351	; .print	em.pri
	emSRS	:=	0352	; .sreset

  type	rtTmon
  is	Amon :	[2] elTwrd ;jmp	bo$sec	;000	67,0 - not EXPERT monitor
	Achn :	[17] rtTchn		;004 	channel area
	Vblk :	elTwrd;	0		;256 0	current dir. segment
	Vchk :	elTwrd;	0		;260 0	current dir. device
	Vdat :	elTwrd;	0		;262	date
	Vdfl :	elTwrd;	0		;264 0	directory operation flag
	Vusr :	elTwrd;	b$hlim		;266	usr address - top of user area
	Vqco :	elTwrd;	0		;270 0	qcomp address
	Vspu :	elTwrd;	0		;272  	special device usr errors
	Vsyu :	elTwrd;	0		;274	system unit (in high byte)
	Vsyv :	elTbyt;	5		;276	RT-11 version
	Vsup :	elTbyt;	33		;277	RT-11 update
	Vcfg :	elTwrd;	cn50h$		;300	CONFIGuration flags
	Vscr :	elTwrd;	0		;302 0	GT control block address
	Vtks :	elTwrd;	h$wtks		;304 0	console addresses
	Vtkb :	elTwrd;	h$wtkb		;306
	Vtps :	elTwrd;	h$wtps		;310
	Vtpb :	elTwrd;	h$wtpb		;312
	Vmax :	elTwrd;	-1		;314 ?	maximum block size
	Ve16 :	elTwrd;	0		;316 ?	emt 16 group offset
	Atim :	[2] elTwrd;0,0		;320	hot/lot time of day
	Vsyn :	elTwrd;	0		;324 0?	.synch routine
	Almp :	[24] elTbyt		;326 0  lowmap (unused)
	Vusl :	elTwrd;	0		;352 0	usr location
	Vgtv :	elTwrd;	0		;354 x	gt shift out vector
	Verc :	elTwrd;	0		;356 ?	error count from cusps
	Vmtp :	elTwrd; br bo$mtp	;360	move to ps
	Vmfp :	elTwrd; br bo$mfp	;362	move from ps
	Vsyi :	elTwrd;	desyi.		;364	system device index
	Vcfs :	elTwrd;	0		;366 ?	command file status
	Vcf2 :	elTwrd;	0		;370	confg2 - config two
	Vsyg :	elTwrd;	sgfpu$		;372	sysgen options - from boot.
	Vusa :	elTwrd;	2		;374	size of usr in bytes
	Verl :	elTbyt;	esdef$		;376 0	image abort level
	Vcfn :	elTbyt;	16.		;377 0	command file nesting level
	Vemr :	elTwrd;	;sy$fex-r$mmon	;400 0	emt return path
	Vfrk :	elTwrd;	;fk$enq-r$mmon	;402 0	offset to fork processor
	Vpnp :	elTwrd;	b$opnm-r$mmon	;404	pname table offset
	Amnm :	[2]elTwrd;.rad50/BOOT  /;406	monitor name
	Vsuf :	elTwrd;	.rad50	/  X/	;412	handler suffix
	Vdcn :	elTwrd;	0		;414	decnet - spool
	Vinx :	elTbyt;	0		;416 0	ind extension
	Vins :	elTbyt;	0		;417 0	ind status
	Vmes :	elTwrd;	1600		;420	sj/fb memory size in pages
	;b$ompt				;	dummy memory map
	Vclg :	elTwrd;	0		;422 0	new usage - unused
	Vtcf :	elTwrd;	b$otcf+borel.	;424	pointer to ttcnfg
	Vidv :	elTwrd;	b$oidv+borel.	;426 0	pointer to ind dev name
	Vmpt :	elTwrd;	b$ompt-r$mmon	;430	offset to memory map
	Vp1x :	elTwrd;	0		;432 0	par1 externalisation routine
	;
	Vgcs :	elTwrd;	;sy$ert		;434 0	getcsr - v5.1 - sec, return
	Vgvc :	elTwrd;	;sy$ert		;436 0	getvec - v5.1 - sec, return
	Vdwt :	elTwrd;	0		;440 0	dwtype - v5.1
	;	assume <.-r$mmon> eq 442;442 0	v5.1 & v5.2 end
	Vtrs :	elTwrd;	0		;442 0	trpset - xm trap list
	Vnul :	elTwrd;	0		;444 0	$nuljb
	Viml :	elTwrd;	0		;446 0	imploc
	Vkmn :	elTwrd;	0		;450 0	kmonin
	Aprd :	[2] elTbyt;0,0		;452 0	progdf - ked,f4
	Vwld :	elTbyt;1		;454 0	wildef - wildcards
	Vf00 :	elTbyt;	0		;455 0	unused
	Af01 :	[64] elTwrd		; expansion space
	Idev :	rtTdev			; device database	

;	Interrupt hooks

	Abus : [3] elTwrd		; IOT, veBUS, RTI
	Acpu : [3] elTwrd		; IOT, veCPU, RTI
	Aemt : [3] elTwrd		; IOT, veEMT, RTI
	Aclk : [3] elTwrd		; IOT, veCLK, RTI
  end
end header
