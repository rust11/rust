end file

file	vrdrv - VT100 screen driver
include	rid:crt
include	rid:scdef
;nclude	rid:vtdef

  func	vt_lnk
	scr : * scTscr
	()  : * scTdrv
  is	scr = sc_ini (scr)
	scr->Pfun = &vt_drv
	reply scr
  end

  func	vt_drv
	scr : * scTscr
	()  : int
  is case scr->Vopr
     of scREC.	nothing	
     of scBLK.	nothing
     of scPOS.	nothing
     of scSCR.	nothing
     of scWRI.	nothing
     of	other	fail
     end case
	fine
  end

  func	vt_rec
	scr : * scTscr
  is	fine if (

;	Output routines

	scREC.	x,y,w,h
	scBLK.	blank screen
	scPOS.	x,y
	scOUT.	cnt, pos, 
	scSCR.	cnt, rep

  func	sc_rec
	ctx : * scTctx
	rec : * scTrec
  is	
  end

  func	sc_scr
	ctx : * scTctx
	cnt : int
  is	
