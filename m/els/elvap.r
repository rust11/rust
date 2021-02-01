;	Rename elvap, el_vap, vaXXX etc
file	elvap - V11 API
include elb:elmod
include rid:imdef
include rid:lndef
include rid:drdef
include rid:stdef
include rid:nfcab
include rid:fidef
include rid:prdef

;	vxETH := 14		; Ethernet header size
;	vxVAB := 46		; VAB size
	VAD(a) := (PNB(VPR(<long>((a)&0xffff))))

;	psh	p3
;	psh	p2
;	psh	p1
;	psh	cod
;	.word	vrSIG.

  proc	el_vap
  is	cod : elTwrd = el_fwd (SP)
	a1  : elTwrd = el_fwd (SP+2)
	a2  : elTwrd = el_fwd (SP+4)
	a3  : elTwrd = el_fwd (SP+6)
	p1  : * char = <*char>VAD(a1)
	p2  : * char = <*char>VAD(a2)
	p3  : * char = <*char>VAD(a3)
	vab : * nfTvab
	log : [128] char
	spc : [128] char
	lst : * char
	tim : int
	dat : int
	era : int

	case cod
	of vrNFI 			; NF: driver server
	   vab = <*nfTvab>(p1+nfETH+4)	; point to VAB
	   nfPbuf = <*char>vab + nfVAB	; point to buffer
	   nf_ser (vab)			; rls:nfser.r
	of vrNFW			; NFW:
	   nf_drv (<*rtTqel>(p1),a2,a3)	; els:vxdev.r, has:nfw.mac
	   R0 = that			;
	of vrMKD			; make directory
	   dr_mak (p1)			; see F11
	   R0 = that			;
	of vrDEF			; define logical
	   st_cop (p1, log)		; see F11
	   lst = st_lst (log)		;
	   *lst = 0 if *lst eq ':'	; remove trailing ":"
	   fi_def (p2, p3, spc)		; (we don't define devices)
	   ln_def (log, spc, 0)		;
	   R0 = that			;
	   el_rmt ()
	   cab_res (cabIRS)		;
	of vrDET			; detect
	   R0 = vrPDP			;
	of vrVCL			; CLI reset
	   SEC				; assume failure
	   if elVcmd & elRDY_		; already done this
	   && !elVrsx
	      el_exi () ;if !elX...	;
	   elif elVcmd & elENB_		;
	      st_cop (elAcmd, <*char>(PNB(R0)))	;
	      CLC			;
	   .. elVcmd = elRDY_		; clears elACT_
	of vrPAU			; scheduler pause
	   pr_slp (1)			; sleep one millisecond
	of vrEXI			; exit emulator
	   im_exi ()			;
	of vrHTZ			; get/set hertz
	   el_htz (R0) if R0		; set the clock period
	   R0 = elVhtz			; return hertz
	of vrTIM			; get time R0->hot,lot,dat,era
	   el_tim (&tim, &dat, &era)	; RT-11 time/date
	   el_swd (R0+0, dat)		; .word Y2K DATE
	   el_swd (R0+2, tim>>16)	; .word HOT
	   el_swd (R0+4, tim)		; .word LOT
	   el_swd (R0+6, era)		; .word  Y2M date remainder
	end case
  end

end file

