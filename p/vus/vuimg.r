pur$c := 0
;	last = end + 1 -- always at least one block
file	vuimg - image copy
include	rid:rider
include	rid:fidef
include	rid:hodef
include	rid:imdef
include	rid:medef
include	rid:rtcla
include	rid:rtdir
include	vub:vumod

;	65536	200000
;	65535	177777	maximum disk or file block size
;	65534	177776	maximum addressable block

code	cm_img	image copy

	imFIN := 0
	imREA := 1
	imWRI := 2
	imRED := 3 	; read destination
	imCMP := 4
	imMEM := 5

	ipt := cmAspc[3]
	opt := cmAspc[0]

  type	imTobj
  is	Pfil : * FILE
	Pspc : * char
	Icla : rtTcla
	Vfst : WORD
	Vlst : WORD
	Vcnt : WORD
	Vsiz : WORD
  end

	src : imTobj = {0}
	dst : imTobj = {0}

code	cm_img - copy engine

  proc	cm_img
  is	ext : fxText 
	buf : word = 0
	err : int = 0
	cnt : int = 0
	lim : int = 0
	tru : int = 0
	hom : * WORD = <>
	me_clr (&ext, #fxText)

	exit vu_inv () if !(*ipt.Pnam && *opt.Pnam)

	src.Pspc = ipt.Pnam
	dst.Pspc = opt.Pnam
	src.Pfil = fi_opn (src.Pspc, "rb", "")
	exit if fail
	ext.Valc = -1
	dst.Pfil = fx_opn (dst.Pspc, "wb", "", &ext)
	exit if fail
	if !rt_cla (src.Pfil, &src.Icla)
	.. exit im_rep ("E-Error accessing source %s", src.Pspc)
	if !rt_cla (dst.Pfil, &dst.Icla)
	.. exit im_rep ("E-Error accessing destination %s", src.Pspc)

	if !(src.Icla.Vflg & (fcDSK_|fcMAG_|fcCAS_)) 
	|| !src.Icla.Vsiz
	.. exit im_rep ("E-Inappropriate source %s", src.Pspc)

	if !(dst.Icla.Vflg & (fcDSK_|fcMAG_|fcCAS_)) 
	|| !dst.Icla.Vsiz
	.. exit im_rep ("E-Inappropriate destination %s", src.Pspc)

	src.Vlst = src.Vsiz = src.Icla.Vsiz	; last = size
	dst.Vlst = dst.Vsiz = dst.Icla.Vsiz

	if cmIst1.Vsel
	   ++lim
	   if cmIst1.Vchn eq
   	      dst.Vfst = cmIst1.Vval
   	   elif cmIst1.Vchn eq 3
   	      src.Vfst = cmIst1.Vval
   	   else
	.. .. err = 1

	if cmIst2.Vsel
	   ++lim
	   if cmIst2.Vchn eq
	      dst.Vfst = cmIst2.Vval
	   elif cmIst2.Vchn eq 3
	      src.Vfst = cmIst2.Vval
	   else
	.. .. err = 1

	if cmVopt & cmLST_		; /LAST (aka /END)
	   ++lim			;
	   src.Vlst = cmIlst.Vval	;
	   ++err if src.Vlst gt 65535	; block number out of range
	.. ++src.Vlst otherwise		; lst = lst + 1

	if (src.Vfst ge src.Vlst)	; make sure geometry works
	|| (src.Vlst gt src.Vsiz)
	|| (dst.Vfst ge dst.Vlst)
	|| (dst.Vlst gt dst.Vsiz)
	.. ++err

	if err
	.. exit im_rep ("E-Invalid parameter", <>)

	src.Vcnt = src.Vlst - src.Vfst	; cnt = lst-fst
	dst.Vcnt = dst.Vlst - dst.Vfst
	cnt = src.Vcnt

;PUT("SRC fst=%d lst=%d siz=%d cnt=%d\n",
;     src.Vfst, src.Vlst, src.Vsiz, src.Vcnt)
;PUT("DST fst=%d lst=%d siz=%d cnt=%d\n",
;     dst.Vfst, dst.Vlst, dst.Vsiz, dst.Vcnt)

	if !lim				; rationalise count
	   if dst.Vcnt lt src.Vcnt
	   .. ++tru, cnt = dst.Vcnt
	else
	   if (dst.Vfst+cnt) gt dst.Vsiz
	.. .. ++tru, cnt = dst.Vcnt

;PUT("src=%d/%d dst=%d/%d cnt=%d\n", src.Vfst, src.Vlst, dst.Vfst, dst.Vlst, cnt)

	if !cmVnoq				; query
	.. exit if !rt_qry (dst.Pspc, "/Copy", <>)

	if !cmVnoq && tru			; truncation warning
	.. exit if !rt_qry ("","Output is shorter than input", <>)

	if (cmVopt & cmVER_)			; copy/verify
	   err = bl_ver (src.Pfil,dst.Pfil,src.Vfst,dst.Vfst,cnt)
	else					; copy
	.. err = bl_trn (src.Pfil,dst.Pfil,src.Vfst,dst.Vfst,cnt)

	if !err
	   fi_clo (src.Pfil)
	   fi_clo (dst.Pfil)
	.. exit

If pur$c
	fi_pur (src.Pfil)
	fi_pur (dst.Pfil)
End
	case err
	of imFIN
	of imREA im_rep ("E-Error reading file %s", src.Pspc)
	of imWRI im_rep ("E-Error writing file %s", dst.Pspc)
	of imRED im_rep ("E-Error reading file %s", dst.Pspc)
	of imCMP im_rep ("E-Verify failed %s", dst.Pspc)
	of imMEM im_rep ("F-Memory allocation error", <>)
	end case
  end
;+++;	VUIMG bl_trn to library
code	bl_trn - block transfer

  func	bl_trn
	ifl : * FILE
	ofl : * FILE
	ibl : WORD
	obl : WORD
	rem : WORD		; block count
	flg : int
  is	buf : * char
	cnt : size
	lim : size = me_max () / 512
	err : int = imFIN

	if !lim
	|| (buf = me_map (lim*512)) eq
	.. reply imMEM

	while rem
	   cnt = lim
	   cnt = rem if rem lt cnt

	   err = imREA
	   quit if !im_trn (imREA, ifl, ibl, buf, cnt)

	   err = imRED
	   quit if !im_ret (ofl, buf, ibl, obl, cnt)

	   err = imWRI
	   quit if !im_trn (imWRI, ofl, obl, buf, cnt)

	   ibl += cnt, obl += cnt
	   rem -= cnt
	   err = imFIN
	end
	me_dlc (buf)
	reply err
  end

code	bl_ver - block transfer/verify

  func	bl_ver
	ifl : * FILE
	ofl : * FILE
	ibl : WORD
	obl : WORD
	rem : WORD		; block count
	flg : int
  is	ibf : * WORD
	obf : * WORD
	cnt : size
	lim : size = me_max () / (512*2)
	err : int = imFIN
	if !lim
	|| (ibf = me_map (lim*512)) eq
	|| (obf = me_map (lim*512)) eq
	   me_dlc (ibf)			; may have succeeded
	.. reply imMEM

	while rem
	   cnt = lim
	   cnt = rem if rem lt cnt

	   err = imREA
	   quit if !im_trn (imREA, ifl, ibl, ibf, cnt)

	   err = imRED
	   quit if !im_ret (ofl, ibf, ibl, obl, cnt)

	   err = imWRI
	   quit if !im_trn (imWRI, ofl, obl, ibf, cnt)

	   err = imRED
	   quit if !im_trn (imREA, ofl, obl, obf, cnt)

	   err = imCMP
	   quit if !me_cmw (ibf, obf, cnt*256)

	   ibl += cnt, obl += cnt
	   rem -= cnt
	   err = imFIN
	end
	me_dlc (ibf)
	me_dlc (obf)
	reply err
  end
code	im_trn - transfer and report per-block errors

;	Copy block-at-a-time if bulk copy fails

  func	im_trn
	opr : int
	fil : * FILE
	blk : WORD
	buf : * WORD
	cnt : WORD
  is	opr = 0 if opr eq imREA

	if rt_opr (fil, blk, buf, cnt*256, rtWAI, opr)
;test	&& blk ne 0
	.. reply (rt_cnt (fil) eq cnt*256)

	while cnt--
	   if !rt_opr (fil, blk, buf, 256, rtWAI, opr)
;test	   || blk lt 5
	      (opr ? "writing" ?? "reading")
	      PUT("VUP-E-Error %s %s at block %d\n", that,
	         fi_spc (fil), blk)
	      fail if !(cmVopt & cmIGN_)
	   end
	   ++blk, buf += 256
	end
	fine
  end
code	im_ret - check retain home block replacement

;	Bad block information is stored at the beginning of the home block
;	We write this over the beginning of the new home block

  func	im_ret
	fil : * FILE
	buf : * WORD
	ibl : WORD
	obl : WORD
	cnt : WORD
  is	if !(cmVopt & cmREP_)		; not requested
	|| ibl gt 1			; gone past home block
	|| obl ne ibl			; not straight copy
	|| !ibl && (cnt le 1)		; or only block zero
	.. fine				; nothing to do

	buf += 256 if !ibl		; skip block zero
	rt_rea (fil, 1, buf, hoREP, rtWAI) ; read replacement block info
	reply that && (rt_cnt (fil) eq hoREP) ; info over the copy block
  end
