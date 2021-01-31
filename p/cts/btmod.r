file	btmod - RT-11 bootstrap utilities
include	rid:rider
include rid:fbdef
include rid:fidef
include	rid:imdef
include rid:rtboo

code	bt_chk - check bootable image

  func	bt_chk
	hdr : * btThdr~
	obj : * char			;
  is	if hdr->Vdvu eq rxBOT		; is bootable
	|| hdr->Vdvu eq rxRTE		; rtem
	.. fine				;
	im_rep ("E-Not a bootable image [%s]", obj) if obj
	fail
  end

code	bt_suf - return suffix from bootable image

  func	bt_suf
	hdr : * btThdr~
	spc : * char
	()  : * char
  is	rx_fmt ("%r", &hdr->Vsuf, spc)
	reply that
  end

code	bt_drv - get primary bootstrap from a driver

	drBPT := 062
	drREA := 066

  func	bt_drv
	fil : * FILE
	buf : * char
	rea : * word		; optional
	msg : * char
  is	off : word
	see : long 
	repeat
	   quit if !fi_see (fil, <long>0)
	   quit if !fi_rea (fil, buf, 512)
	   *rea = (<*word>buf)[drREA/2] if rea
	   see = (<*word>buf)[drBPT/2]
	   quit if !fi_see (fil, see)
	   quit if !fi_rea (fil, buf, 512)
	   fine
	never
	fail
  end

code	bt_inf - get boot info

  func	bt_inf
	fil : * FILE
	inf : * btTinf~
	msg : * char
  is	hdr : * btThdr~ = &inf->Ihdr
	ptr : * char
	off : int = 512
	inf->Vsta = 0
	if (ptr = st_fnd (":", fil->Pspc)) ne
	&& !ptr[1]
	.. off = 1024
	if !fi_see (fil, <long>(btHDR+off))
	|| !fi_rea (fil, hdr, #btThdr)
	.. fail fi_rep (fil, msg, "E-Error accessing boot [%s]")
	inf->Vsta = btIPT_		; input okay
	if hdr->Vdvu eq rxBOT		; is bootable
	.. inf->Vsta |= btBOT_		; bootable
	if hdr->Vdvu eq rxRTE		; 
	.. inf->Vsta |= btRTE_		; RTEM
	if hdr->Vrst eq rxRST		;
	.. inf->Vsta |= btRST_		; RUST
	rx_fmt ("%r", &hdr->Vdvs, inf->Adev)
	rx_fmt ("%r", &hdr->Vsuf, inf->Asuf)
	rx_fmt ("%r%r", hdr->Amon, inf->Amon)
	rx_spc (hdr->Aimg, inf->Aimg)
	fine
  end
code	bt_put - put boot header

  func	bt_put
	fil : * FILE
	hdr : * btThdr
  is	fi_see (fil, btHDR)
	pass fail
	fi_wri (fil, hdr, #btThdr)
	reply that
  end

code	bt_spc - return file spec from boot header

  func	bt_spc
	hdr : * btThdr~
	spc : * char
	()  : * char
  is;	rx_fmt (rx_fmt (spc, "%x", hdr->Vfn0, hdr->Vfn1))
	rx_fmt ("%r%r", hdr->Amon, spc)
	reply that
  end
end file

code	rt_boo - boot rt-11

  func	rt_boo
	spc : * char
	for : int
  is	nam : [4] WORD
	mem : * void = me_acc (btXXX.)
	nam[0] = nam[1] = 0
	rx_spc (spc, nam) if spc	;
	spc = "SY:" otherwise		; for fail messages
	msg = rt$boo (nam, for, mem)
	me_dlc (mem)
	fail im_rep (msg, spc)
  end

end file

