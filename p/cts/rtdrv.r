file	rtdrv - find/open RT-11 driver
include rid:rider
include rid:ctdef
include rid:fidef
include rid:fsdef
include rid:stdef
include rid:rtdrv

code	rt_drv - find & open RT-11 driver

  func	rt_drv
	dev : * char			; device name
	drv : * char			; driver name
	cla : int			; suffix class (-1, 'X', 'P', 'V')
	inf : * drTinf~			; returns driver info
  is	tmp : [8] char			;
	hdr : * drThdr~ = &inf->Ihdr	;
	len : int 			; driver name length
	suf : * char~			; suffix list
	sfx : int			; current suffix
	me_clr (inf, #drTinf)		;
;PUT("dev=[%s] drv=%s\n", dev, drv)

	fs_ext (dev, tmp, fsDEV_)	; get device name
	if ct_dig (tmp[2])		;
	   inf->Vuni = tmp[2] - '0'	;
	.. tmp[2] = 0			;
	drv = tmp if !drv		; default driver to device
;PUT("tmp=[%s] drv=%s\n", tmp, drv)
	len = st_len (drv)		;
					;
	fail if len lt 2		; D: ???
	fail if len gt 3		; DDDD: ???

	case cla			; select suffix
	of -1				; local machine
	   suf = "PX_" if rt_xmm ()	; assume RUST
	   suf = "V_" otherwise		;
	of 'P'				; RUST/XM
	   suf = "PX_"			;
	of 'V'				; RUST/SJ
	   suf = "V_"			;
	of other			;
	   suf = &cla if cla		; RT11/XM
	   suf = "_" otherwise		; RT11/SJ
	end case			;
					;
	st_cop (drv, inf->Adev)		; 
	if len eq 3			; explicit suffix
	   suf = drv+2			; use it
	.. inf->Adev[2] = 0		; device name (no suffix)

	repeat
	   fail if (sfx = *suf++) eq
	   sfx = 0 if (sfx eq '_') || (sfx eq '$') ; null case
	   inf->Asuf[0] = sfx		; return suffix
	   FMT(inf->Adrv, "%s%c", inf->Adev, sfx)
	   FMT(inf->Aspc, "%s%s.SYS", dev, inf->Adrv)
;PUT("spc=[%s]\n", inf->Aspc)
	   inf->Pfil = fi_opn (inf->Aspc, "rb+", <>)
	   quit if ne
	forever
	inf->Vsta |= drFND_
	fi_rea (inf->Pfil, &inf->Ihdr, #drThdr)
	fail fi_prg (inf->Pfil) if fail
	inf->Vsta |= drIPT_
	inf->Vsta |= drVAL_ if hdr->Vgua eq rxHAN
	fine
  end

end file
