file	rttrn - RT-11 bulk block transfer
include	rid:rider
include rid:medef
include rid:fidef
include	rid:imdef
include rid:rtdir

code	rt_trn - bulk block transfer

  func	rt_trn
	ipt : * FILE			; input file (erase output file if null)
	opt : * FILE			; output file
	ibl : WORD			; input start block
	obl : WORD			; output start block
	rem : WORD~			; blocks to transfer (remainder)
	flg : int			; later
  is	buf : * char			;
	bcc : size			; buffer char count
	tbc : size~			; transfer block count
	twc : size~			; transfer word count
	fail if !(bcc = (me_max () & ~(511)))
	fail if (buf = me_map (bcc)) eq
	me_clr (buf, bcc) if !ipt 	; clearing file
	while rem
	   tbc = bcc/512
	   tbc = rem if rem lt tbc
	   twc = tbc * 256
	   if ipt			; transferring
	      rt_rea (ipt, ibl, buf, twc, rtWAI)
	      quit if fail
	   .. quit if rt_cnt (ipt) ne twc
	   rt_wri (opt, obl, buf, twc, rtWAI)
	   quit if fail
	   quit if rt_cnt (opt) ne twc
	   ibl += tbc, obl += tbc
	   rem -= tbc
	end
	me_dlc (buf)
	reply !rem
  end
