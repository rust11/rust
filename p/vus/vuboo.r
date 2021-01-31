;
;	BOOT spec/DRIVER=dd
;	Check for SWAP.SYS
; ???	/NOQUERY
; ???	/WAIT
;
file	vuboo - boot device/file
include	rid:rider
include	vub:vumod
include	rid:rtboo

code	cm_boo - boot device or file

;	BOOT dev:/FOREIGN/NOQUERY/WAIT
;
;??;	Check SWAP.SYS (VUBOO)
;??;	Check BOOT.SYS

	ipt := cmAspc[3]

  proc	cm_boo
  is	spc : * char = ipt.Pnam
	fxr : int = cmVopt & cmFOR_
	spc = <> if !*spc
	rs_exi () if rs_det ()		; RTX 
	rt_boo (spc, fxr, <>)		; boot it (btFOR=1)
  end
