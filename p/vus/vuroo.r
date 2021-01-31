;???;	VUP has macro csi interface
file	vuroo - VUP root
include	rid:rider
include	rid:fidef
include	rid:imdef
include	rid:medef
include rid:rtbad
include	vub:vumod

code	start VUP

  func	start
  is	im_ini ("VUP")		; setup for messages
	vu_alc ()		; allocate buffers
	vu_cmd ()		; process commands
	fine
  end

code	cm_squ - squeeze

  proc	cm_squ
  is	im_rep ("E-SQUEEZE support currently in VIP", <>)
  end

code	cm_ini - init

;	Calls init overlay and then bad block overlay

  proc	cm_ini
  is	bad : * bdTbad
	spc : * char

	bad = vu_ini ()				; do init
	exit if eq				; no bad block processing
	spc = fi_spc (bad->Pfil)		;

	if !cmVret				; don't want them retained
	   bad->Irec.Vpnt = 0			; rewind
	.. bd_scn (bad, (cmVopt & cmLOG_))	;

	bd_map (bad)				; map them
	bd_rep (bad)				; report accumulated errors
  end
