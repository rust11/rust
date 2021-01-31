file	vubad - bad blocks
include	rid:rider
include	vub:vumod
include	rid:rtbad
include	rid:rtcla

code	cm_dir - bad block directory

	ipt := cmAspc[3]

  proc	cm_dir
  is	spc : * char = ipt.Pnam
	fil : * FILE
	cla : * rtTcla
	bad : * bdTbad
	sta : WORD = 0
	lim : WORD = 0
	nam : int = 0
	log : int = cmVopt & cmLOG_

	exit vu_inv () if !*spc			; no device specified
	fil = fi_opn (spc, "rb", "")		;
	pass fail				;
	bad = bd_alc (<>, fil)			;
	rt_cla (fil, cla)
	exit im_rep ("E-Error accessing device %s", spc) if fail
	exit im_rep ("E-Can't scan bad blocks on %s", spc) if !cla->Vsiz

	bad->Iscn.Vlim = cla->Vsiz
	if cmVopt & cmSTA_
	.. sta = cmIst1.Vval
	if cmVopt & cmLST_
	.. lim = cmIlst.Vval + 1

	lim = cla->Vsiz if !lim
	vu_inv () if sta ge lim
	bad->Iscn.Vsta = sta
	bad->Iscn.Vlim = lim

	if !bd_scn (bad, (cmVopt & cmLOG_))
	.. im_rep ("W-Too many bad blocks %s", spc)

	if (cla->Vflg & (fcDEV_|fcDIR_|fcCON_))
	.. nam = cmVopt & cmFIL_
	bd_lst (bad, nam)
	bd_rep (bad)
  end
