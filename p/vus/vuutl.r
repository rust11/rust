file	vuutl - vup utilities
include	rid:rider
include	rid:imdef
include	rid:medef
include	rid:rtdir
include	vub:vumod

	vuIdev : vuTobj = {0,0,   "rbp+", "",    "device"}
	vuIboo : vuTobj = {0,512, "rbp+", <>,    "boot block"}
	vuIhom : vuTobj = {1,512, "rbp+", <>,    "home block"}
	vuIroo : vuTobj = {2,2048,"rbp+", <>,    "secondary boot"}
	vuIseg : vuTobj = {6,1024,"rbp+", <>,    "directory"}
	vuIdrv : vuTobj = {0,1024,"rbp+", ".SYS","driver"}
	vuIbas : vuTobj = {0,512, "rb+",  <>,    "driver"} ; driver base block
	vuImon : vuTobj = {0,0,   "rb+",  ".SYS","monitor"}
	vuIsrc : vuTobj = {0,0,   "rbp+", "",    "input device"}
	vuIdst : vuTobj = {0,0,   "rbp+", "",    "output device"}

  init	vuAobj : [] * vuTobj
  is	&vuIdev, &vuIboo, &vuIhom, &vuIroo, &vuIseg,
	&vuIdrv, &vuIbas, &vuImon
	&vuIsrc, &vuIdst,
	0
  end

code	vu_alc - allocate buffer

  func	vu_alc
	obj : * vuTobj
  is	if !obj->Pbuf && obj->Vcnt
	.. obj->Pbuf = me_acc (obj->Vcnt)
  end

code	vu_rst - reset all files

  func	vu_rst
  is	lst : **vuTobj~ = vuAobj
	obj : * vuTobj~
	while (obj = *lst++)
	   me_dlc (obj->Pbuf) if obj->Pbuf
	   fi_prg (obj->Pfil, <>) if obj->Pfil && obj->Pdef
	end
  end

code	vu_opn - open file

;	Apply defaults - save full spec

  func	vu_opn 
	obj : * vuTobj
	spc : * char
  is
	vu_alc (obj)
	fi_def (spc, obj->Pdef, obj->Anam)
	obj->Pfil = fi_opn (obj->Anam, obj->Pmod, "") 
	reply that ne
  end

code	vu_cln - clone file

  func	vu_cln
	src : * vuTobj
	dst : * vuTobj
  is	vu_alc (dst)
	dst->Pfil = src->Pfil
	st_cop (src->Anam, dst->Anam)
  end

code	vu_clo - close file

  func	vu_clo
	obj : * vuTobj
  is	fine if !obj->Pfil
	fi_clo (obj->Pfil, "")
	reply that
  end

If 0
  func	vu_seg 
	opr : int
	seg : int
  is	vuIseg->Vblk = (seg*2)+4
	reply vu_trn (opr, &vuIseg)
  end
End

code	vu_get - transfer operations

  func	vu_get
	obj : * vuTobj
  is	reply vu_rea (obj, obj->Vblk, obj->Pbuf, obj->Vcnt)
  end

  func	vu_rea
	obj : * vuTobj
	blk : WORD
	buf : * void
	cnt : WORD
  is	rt_rea (obj->Pfil, blk, buf, cnt/2, rtWAI)
	pass fine
	fail vu_msg (obj, "reading")
  end

  func	vu_put
	obj : * vuTobj
  is	reply vu_wri (obj, obj->Vblk, obj->Pbuf, obj->Vcnt)
  end

  func	vu_wri
	obj : * vuTobj
	blk : WORD
	buf : * void
	cnt : WORD
  is	rt_wri (obj->Pfil, blk, buf, cnt/2, rtWAI)
	pass fine
	fail vu_msg (obj, "writing")
  end

  func	vu_msg
	obj : * vuTobj
	act : * char
  is	msg : [60] char
	FMT("E-Error %s %s [%s]", act, obj->Pdis, obj->Anam)
	im_rep (msg, <>)
	fail
  end

code	vu_inv - invalid command

  func	vu_inv
  is	im_rep ("F-Invalid command", <>)
  end
