file	rtscn - scan rt-11 directory
include rid:rider
include rid:fidef
include rid:medef
include rid:rtdir

;	scn = rt_scn (<>, "sy:", 0, "")
;	pass fail
;	while rt_nxt (scn, spc, "")
;	   PUT("%s\n", spc)
;	end
;	fail if !rt_fin (scn)
; or:	fail rt_fin (scn) if scn->Perr

  func	rt_alc
	()  : * rtTscn
  is	reply me_acc (#rtTscn)
  end

  func	rt_dlc
  is	scn : * rtTscn
 	me_dlc (scn)
  end

  func	rt_scn
	scn : * rtTscn~				; scan block (optional)
	spc : * char				; directory spec
	sel : int				; rtPER etc
	msg : * char				; error message
	()  : * rtTscn				;
  is	fil : *FILE~
	fail if !(fil = fi_opn (spc, "rb", msg)); open failed
	scn = me_acc (#rtTscn) if !scn		; allocate new scan
	scn->Pfil = fil				; channel
	st_cop (spc, scn->Aspc)			; save spec for errors
	scn->Vsel = sel ? sel ?? rtPER_		; selector
	rt_rew (scn)				; setup for scan
	reply scn
  end

  func	rt_rew
	scn : * rtTscn~
  is	scn->Pbuf = scn->Abuf			; buffer
	scn->Vseg = 1				; first segment
	scn->Pnxt = <>				; next entry 
	scn->Perr = <>				; no error yet
  end

  func	rt_fin					; finish scan
	scn : * rtTscn~
  is	sta : int~ = 1				;
	fine if !scn				; never allocated
	--sta if scn->Perr			; had error
	fi_clo (scn->Pfil)			; close file
	reply sta				;
  end

  func	rt_ent 
	scn : * rtTscn
	ent : * rtTent~
  is	me_cop (scn->Pent, ent, #rtTent)
	if !scn->Vext
	   ent->Vctl = 0
	   ent->Vuic = 0
	   ent->Vpro = 0
	end
  end

  func	rt_nxt					; next entry
	scn : * rtTscn~				; scan block
	spc : * char				; optional result spec
	msg : * char				; optional error message
  is	fil : * FILE = scn->Pfil
	hdr : * rtThdr~				; directory header
	ent : * rtTent~				; directory entry
	err : * char="E-Invalid directory [%s]"	; default message
     repeat
	ent = scn->Pnxt				; next entry
	if !ent					; no entry - next segment
	   fail if !scn->Vseg			; trying to go past end
	   quit if scn->Vseg gt 31		; invalid directory
	   hdr = <*rtThdr>scn->Pbuf		; point at segment buffer
If 0
	   rt_see (fil, ((scn->Vseg-1)*2)+6, 0)	; seek to block/byte
	   if !fi_rea (fil, hdr, 1024)		; read next segment
	   .. quit err="E-Directory input error [%s]"
Else
	   ((scn->Vseg-1)*2)+6			; compute block
	   if !rt_rea (fil,that,hdr,512,rtWAI)	; read next segment
	   .. quit err="E-Directory input error [%s]"
End
	   scn->Vseg = hdr->Vnxt		; next segment
	   scn->Vacc = hdr->Vblk		; base block of segment
	   scn->Vext = hdr->Vext		; extra bytes per entry
	   quit if hdr->Vext & rtEXT_		; invalid shit
	.. ent = <*rtTent>(++hdr)		; point at first entry
						;
	next scn->Pnxt = 0 if ent->Vsta & rtEND_; get another segment
	scn->Pnxt = <*char>(ent+1)-rtRTX+scn->Vext ; next entry
	quit if <*char>(scn->Pnxt) ge ((<*char>scn->Pbuf)+1024 ); overrun
	scn->Vblk = scn->Vacc			; start block of this file
	scn->Vacc += ent->Vlen			; start of next
	next if !(ent->Vsta & scn->Vsel)	; not selected
	scn->Pent = ent				; remember this entry
	rx_fmt ("%r%r.%r",ent->Anam, spc) if spc; unpack the name
	fine					;
     forever
	scn->Perr = err				; flag error
	fail fi_rep (fil, msg, err)		; report error
  end
