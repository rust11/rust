header	vpmod - vrt modules
include rid:rider
include rid:fidef
include rid:drdef
include rid:rtmod
include elb:elmod

;	REQ(x) := (x & 0xff)	; isolate request code
;	vr_unp : (*elTwrd, *char, int) void
 	vpApad : [512] char extern
	vp_chn : (int) *rtTchn

  type	vpTqel : forward
  type	vpTfun : (*vpTqel) void
  type	vpTiop : (*vpTqel, int) int

	vp_trn : (*vpTqel, int) void
;	vp_cmd : (*char)
	vp_set : (*vpTqel, int) void
	vp_eof : vpTfun
	vp_her : vpTfun

	nf_iop : vpTiop
	ld_iop : vpTiop
	ld_rst : () void
	dy_iop : vpTiop
	vm_iop : vpTiop
	im_iop : vpTiop

  type	vpTdrv : (*rtTqel, elTwrd, elTwrd) int
	nf_drv : vpTdrv

	ADR(a) := (<*void>(PNB(VPR(<long>((a)&0xffff)))))

	vp_boo : elTfun
	vp_rmn : elTfun
	vp_iot : () int
	vp_emt : () int
	vp_unp : (*elTwrd, *char, int) void

	JSW := (*<*elTwrd>(elPmem+jsw))
	JR0 := (*<*elTwrd>(elPmem+j_reg0))
	vpKmon := 0140000		; rmon address

	vpVjsw : elTwrd extern

	vpREA := 0
	vpWRI := 1
	vpQIO := 2

; cab stuff was here

  type	vpTter
  is	Abuf : [1024] char
	Vget : int
	Vnxt : int
	Vonc : int
  end
	vpIter : vpTter extern

	vt_kb_hoo : () void
data	SAM queue element

  type	vpTqel
  is	Vqlk	: elTwrd	; link to next element
	Vqgt	: elTwrd	; goto when done
				; start of transmit and copy sections
	Vqcm	: elTwrd	; flags and packet command
	Vqry	: elTwrd	; query flag; cleared on return 
	Vqch	: elTwrd	; [subcode | channel ]

	Vqa1	: elTwrd; Vqbl	; V2=2(area) V1=R0	(rename filename)
	Vqa2	: elTwrd; Vqbu	; V2=4(area) V1=n(sp)=1st push
	Vqa3	: elTwrd; Vqwc	;   ...		qa1-qa4 errors
	Vqa4	: elTwrd; Vqdu	;		    (enter,lookup,delete)
			; Vqfn	;
	Vqa5	: elTwrd;	;qdu for spfun
	Vqa6	: elTwrd; Vqr0	;send spfun; return r0
	Vqa7	: elTwrd; Vqer	;send spfun; return error-code
	Vqa8	: elTwrd;	;temporary, data, transfers=csw
	Vqx0	: elTwrd
	Vqx1	: elTwrd
	Vqx2	: elTwrd
	Vqx3	: elTwrd
	Vqx4	: elTwrd
	Vqx5	: elTwrd
	Vqx6	: elTwrd
	Vqx7	: elTwrd
	Vqdc	: elTwrd	; data count
				; end of copy section of packet
	Vqck	: elTwrd	; the command check
				; end of transmit section
	Vqdk	: elTwrd	; the data check
;	
	Vlnk	: elTwrd; Vfrk	; q_link q_fork
	Vcsw	: elTwrd	; q_csw
	Vblk	: elTwrd	; q_blkn
	Vfun	: elTbyt	; q_func
	Vuni	: elTbyt; Vjob	; q_unit q_jnum
	Vbuf	: elTwrd	; q_buff
	Vcnt	: elTwrd	; q_wcnt
	Vast	: elTwrd	; q_comp
	Vpar	: elTwrd	; q_par
	Vfr1	: elTwrd	; q_free
	Vfr2	: elTwrd	; q_fre2
	Vtwc	: elTwrd	; q_twc
	Vjob	: elTwrd	; q_job
	Vvid	: elTwrd	; q_vid
	Vtyp	: elTwrd	; q_type
	Vmch	: elTwrd	; q_mch
	Vjch	: elTwrd	; q_jch
	Vmwc	: elTwrd	; q_mwc
	Vsp	: elTwrd	; q_sp
  end

	Vjob	:= Vuni ;067
;	Vfork	:= 060
	Vqcs	:= Vqcs ;054
	Vqer	:= Vqa7	;026
	Vqr0	:= Vqa6	;
	Vqfn	:= Vqa4	;020
	Vqdu	:= Vqa4	;020
	Vqwc	:= Vqa3	;016
	Vqbu	:= Vqa2	;014
	Vqbl	:= Vqa1	;012

;	qlk	:= 00
;	qgt	:= 02
;	qcm	:= 04
;	qry	:= 06
;	qch	:= 010
;	qa1	:= 012
;	qbl	:= 012
;	qa2	:= 014
;	qbu	:= 014
;	qa3	:= 016
;	qwc	:= 016
;	qa4	:= 020
;	qdu	:= 020
;	qfn	:= 020
;	qa5	:= 022
;	qa6	:= 024
;	qr0	:= 024
;	qa7	:= 026
;	qer	:= 026
;	qa8	:= 030
;	qx0	:= 032
;	qx1	:= 034
;	qx2	:= 036
;	qx3	:= 040
;	qx4	:= 042
;	qx5	:= 044
;	qx6	:= 046
;	qx7	:= 050
;	qdc	:= 052
;	qck	:= 054
;	qdk	:= 056
;	qbs	:= 060
;	qcs	:= 054
;	qde	:= 04
;	
;	q_link	:= 060
;	q_fork	:= 060
;	q_csw	:= 062
;	q_blkn	:= 064
;	q_func	:= 066
;	q_unit	:= 067
;	q_jnum	:= 067
;	q_buff	:= 070
;	q_wcnt	:= 072
;	q_sqbu	:= 072
;	q_comp	:= 074
;	q_sqry	:= 074
;	q_par	:= 076
;	q_free	:= 0100
;	q_fre2	:= 0102
;	q_twc	:= 0104
;	q_job	:= 0106
;	q_vid	:= 0110
;	q_type	:= 0112
;	q_mch	:= 0114
;	q_jch	:= 0116
;	q_mwc	:= 0120
;	q_sp	:= 0122
;	qbt	:= 0124
data 	VRT constants

;	j_buff  := 144746

	j_buff	:= 04746
	_chkey	:= 0260
;	eof_	:= 020000
;	jsw	:= 044
	mo_evt	:= 0160000
;	mo_ev1	:= 0160006
	j_even	:= 0144056
;	jx_abt	:= 0100001
	jxABT_  := 0100001
;	jx_ctc	:= 0100002
	jxCTC_  := 0100002
;	jx_fpp	:= 0100004
;	jx_msg	:= 0100010
;	jx_bpt	:= 0100020
;	jx_pnd	:= 0100000
	j_jnum	:= 0606
;	j_jsw	:= 0144046
	__sid	:= 0532
	_unam1	:= 0142572
	_unam2	:= 0142674
	usersp	:= 042
	dkassg	:= 0142670
	syassg	:= 0142672
	_pname	:= 0142776
	_hentr	:= 0143074
	_stat	:= 0143174
;	_dvrec	:= 0143272
;	_hsize	:= 0143370
	_dvsiz	:= 0143466
	_type	:= 0143564
	ty_dma	:= 01
;	ty_rem	:= 02
;	ty_dmx	:= 04
;	ty_vmx	:= 010
	_syind	:= 0364
	__host	:= 03776
	__slot	:= 03774
	__loca	:= 04000
	t_ocou	:= 04132
	_rmon	:= 0140000
	j_reg0	:= 0144052
	bang	:= 0162472
	sn_pur	:= 0171502
	e340l	:= 0167156
	mrkt	:= 0161456
	_mrkt	:= 0167334
	cmkt	:= 0161556
	_cmkt	:= 0167336
	aid	:= 0163504
	_aid	:= 0140612
	_power	:= 0140550
	_net	:= 0140526
;	_csr	:= 0140534
;	_force	:= 0140574
;	_user	:= 0140622
;	_uic	:= 0140620
;	t_imod	:= 0144114
	userps	:= 0140472
	_mtpx	:= 0452
	_mfpx	:= 0464
	kaput	:= 0165734
	mo_res	:= 0160472
;	ren	:= 040
	vpREN	:= 040
	_paths	:= 0140576
	_top	:= 0140266
	_smon	:= 0140554
	_job	:= 0140540
	_jobc	:= 0140546
data	more

	ttspc_	:=	010000
	sysptr	:=	054	;
	spusr	:=	0272	;spusr offset
;	r50vx0	:=	0106536;
;	r50sy	:=	075250
;	r50dk	:=	015270
	r50sys	:=	075273
	r50_tt	:=	0100040
;	r50_vs	:=	0106170
	r50_vx	:=	0106500
	r50_sy	:=	075250
	r50_dk	:=	015270
	r50_nl	:=	054540
	r50_ld	:=	045640
	r50_dy  :=	016350

	r50_vx7	:=	0106545
	r50DIR	:=	015172

	radVX7	:=	0106545
	radDIR	:=	015172

;	r50_vx6	:=	0106544
;	r50_0	:=	036

	lddev	:=	0102446
	dydev	:=	0102446
;	fildev	:=	0100376
	vxdev	:=	012200
	nfdev	:=	012205
	nldev	:=	025
;	r50_vrt	:=	0106144
	config	:=	0300
	confg2	:=	0370
	eis_	:=	0400
	sysgen	:=	0372
	rtem_	:=	010
;
;	unam1	:=	-(66*2)
;	unam2	:=	-66
;
;	ttslot	:=	0
	vxslot	:=	2
	nlslot	:=	4
	ldslot	:=	6
	dyslot :=	8
;	xmslot	:=	8
;	imslot	:=	10
	joslot	:=	12	;first job slot
;
;;	device slots
;
;	vtTT := 0
;	vtVX := 1
;	vtNL := 2
;	vtLD := 3
;	vtVM := 4
;	vtIM := 5
;	vtJO := 6
end header
end file

r
;  type	vtTchn
;  is	Vcsw  : elTwrd
;	Vsblk : elTwrd
;	Vleng : elTwrd
;	Vused : elTwrd
;	Vdevq : elTbyt
;	Vunit : elTbyt
;  end
;	c_csw	:=	0
;	c_sblk	:=	2
;	c_leng	:=	4
;	c_used	:=	6
;	c_devq	:=	010
;	c_unit	:=	011
;	c_bs	:=	012
.title	mim	impure areas
.pass
.psect	mim

;V5.2 cli flag & type

set	clucf$ 1,	cldcl$ 2,	clccl$ 4
set	clucl$ 10,	clkmn$ 200

; queue structure

meta	<.blkw c><.rept c><.word 0><.endr>
meta	<.blkb c><.rept c><.byte 0><.endr>

set	quels =5.		;make quels global
set	$ 0

meta	<entry x y z><set x,=$,y,=$,z,=$><$=$+2>

entry	qlk	;.+qbs		; link to next element
entry	qgt	;receive 	; goto when done
				; start of transmit and copy sections
entry	qcm			; [flags  packet command]
entry	qry			; -> query flag; cleared on packet return 
entry		qch		; [subcode | channel]
entry	qa1	qbl		; V2=2(area) V1=R0	(rename filename)
entry	qa2	qbu		; V2=4(area) V1=n(sp)=1st push
entry	qa3	qwc		;   ...		qa1-qa4 errors
entry	qa4	qdu	qfn	;		    (enter,lookup,delete)
entry	qa5			;qdu for spfun
entry	qa6	qr0		;send spfun; return r0
entry	qa7	qer		;send spfun; return error-code
entry	qa8			;temporary, data, transfers=csw
entry	qx0
entry	qx1
entry	qx2
entry	qx3
entry	qx4
entry	qx5
entry	qx6
entry	qx7
entry	qdc			;data count
				; end of copy section of packet
entry	qck			;the command check
entry	qdk			;the data check
				; end of transmit section

set	qbs =$, qcs =qbs-qcm, qen 2, qde =4, qac 6
;.iif ne qbs-40, .error;update qbt in ss and usr

;	kernel	host	private	usf	mus
;	-----------------------------------
entry	q.link	q.fork;	q.csw	emt-address	
entry	q.csw;	pc	q.sblk	fil	csw mask
entry	q.blkn;	r5	q.leng	typ
entry	q.func;	r4	q.used	typ
	q.unit==q.func+1
	q.jnum==q.func+1
entry	q.buff;	(reloc);q.devq
entry	q.wcnt	q.sqbu
entry	q.comp	q.sqry
entry	q.par;	q.par		;for xm type devices
entry	q.free			;for 22-bit stuff
entry	q.fre2			;q.free requires two words

entry	q.twc			;transfer word count
entry	q.job			;address of job plex
entry	q.vid			;volume id  [unit | slot]
entry	q.type			;device type (see $type)
entry	q.mch			;mapped channel number
entry	q.jch			;job channel number
entry	q.mwc			;maximum word count for transfer
entry	q.sp			;saved sp in usr operations

set	qbt =$
