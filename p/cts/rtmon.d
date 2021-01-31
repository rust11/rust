;***;	CTS:RTMON - Added BOOT identify/run flags at unused 360
header rtmon - RT-11 monitor header
include rid:rtchn
boo$c=1	; boot flags

	elTwrd := WORD
	elTbyt := BYTE

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
	Almp :	[20] elTbyt		;326 0  lowmap (unused)
	Vusl :	elTwrd;	0		;352 0	usr location
	Vgtv :	elTwrd;	0		;354 x	gt shift out vector
	Verc :	elTwrd;	0		;356 ?	error count from cusps
	Vmtp :	elTwrd; br bo$mtp	;360	move to ps
	Vmfp :	elTwrd; br bo$mfp	;362	move from ps
	Vsyi :	elTwrd;	desyi.		;364	system device index
If boo$c
	Vidt :	elTbyt;	0		;366	BOOT identify flag
	Vrun :	elTbyt; 0		;367	BOOT RUN flag
Iff
	Vcfs :	elTwrd;	0		;366 ?	command file status
End
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
  end

  type	rtTcor
  is	Vfst : elTwrd
	Vlst : elTwrd
  end

end header
