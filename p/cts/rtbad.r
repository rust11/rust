file	rtbad - RT-11 bad block routines
include	rid:rider
include rid:codef
include rid:fidef
include	rid:imdef
include rid:medef
include rid:rddef
include rid:rtbad
include rid:rtdir
RND_C := 0	; random bad blocks test

;	RT-11 bad block routines
;
;	RSX bad block handling is quite different.

code	allocation

  func	bd_alc				; allocate bad block structure
	bad : * bdTbad			;
	fil : * FILE			;
	()  : * bdTbad			;
  is	bad = me_acc (#bdTbad) if !bad	;
	me_clr (bad, #bdTbad)		; clear it
	bad->Pfil = fil			;
	bad->Irec.Vlim = bdREC 		;
	bad->Irep.Vlim = bdREP		; 
	reply bad			;
  end

  func	bd_dlc				; deallocate structure
	bad : * bdTbad			;
  is	me_dlc (bad) 			;
  end					;
code	bd_scn - scan bad blocks

  func	bd_scn
	bad : * bdTbad
	rep : int
  is	fil : * FILE = bad->Pfil
	buf : * char
	blk : WORD = bad->Iscn.Vsta
	rem : WORD = bad->Iscn.Vlim
	cnt : WORD			; block count
	res : int = 1			; assume success
	siz : size = me_max ()
	ctc : int = co_ctc (coDSB)	; disable ctrl/c

	fail if blk ge rem		; nothing to do
	rem = rem - blk			; get remainder

	fail if siz lt 512
	fail if (buf = me_map (siz)) eq
	siz /= 512
	while rem
	   quit if co_ctc (0)		; check ctrl/c
	   cnt = siz
	   cnt = rem if rem lt cnt
If RND_C
	   rt_rea (fil, blk, buf, cnt*256, rtWAI)
	   if fine && (rt_cnt (fil) eq cnt*256) && !bd_rnd (blk, cnt)
	   .. next  blk += cnt, rem -= cnt
Else
	   rt_rea (fil, blk, buf, cnt*256, rtWAI)
	   if fine && (rt_cnt (fil) eq cnt*256)
	   .. next  blk += cnt, rem -= cnt
End
	   while cnt
	      rt_rea (fil, blk, buf, 256, rtWAI)
	      if fail
	         if rep
		 .. PUT("?%s-W-Bad block: %o/%d.\n", imPfac, blk,blk)
	      .. quit res=0 if !bd_ent (bad, blk, 1)
	      ++blk, --cnt, --rem
	   end
	   quit if !res
	end
	co_ctc (ctc)		; restore ctrl/c
	me_dlc (buf)
	reply res
  end

If RND_C

  func	bd_rnd
	blk : size
	cnt : size
  is	bad : WORD
	fine if bd_chk (blk, cnt, 50)
	fine if bd_chk (blk, cnt, 70)
	fine if bd_chk (blk, cnt, 80)
	fine if bd_chk (blk, cnt, 90)
	fail
  end

  func	bd_chk
	blk : WORD
	cnt : WORD
	bad : WORD
  is	fail if bad lt blk
	fine if bad le (blk+cnt)
	fail
  end
End
code	bd_ent - enter bad block into table

;	Merge not supported yet

  func	bd_ent
	bad : * bdTbad~			; bad context
	blk : WORD			; block
	cnt : WORD			; count
  is	rec : * bdTrng~ = &bad->Irec	; recording range
	ent : * bdTrec~			;
					;					;					;
	if rec->Vpnt			; merge adjacent blocks
	   ent = &bad->Arec[rec->Vpnt-1]; get previous
	   if blk eq (ent->Vblk + ent->Vcnt) ; adjacent
	.. .. fine ent->Vcnt += cnt	; merge
					;
	if rec->Vpnt ge rec->Vlim	; too many?
	.. fail bad->Vflg |= bdOVR_	; overflow
	ent = &bad->Arec[rec->Vpnt++]	;
	ent->Vblk = blk			;
	ent->Vcnt = cnt			;
	fine
  end
code	bd_lst - list bad blocks

  func	bd_lst				; list bad blocks
	bad : * bdTbad			;
	rep : int 			; report files
  is	itm : * bdTrec = bad->Arec	;
	cnt : int = bad->Irec.Vpnt	;
	spc : * char = fi_spc (bad->Pfil)
	seg : * rdTseg			;
	ent : * rtTent
	nam : [12] char
	plu : * char

	exit im_rep ("I-No bad blocks detected ", spc) if !cnt

	seg = bad->Pseg = rd_alc (bad->Pseg, bad->Pfil)
	exit im_rep ("E-Error accesssing device %s", spc) if fail

	PUT("   Block\tCount")
	PUT("\tFile        Offset") if nam
	PUT("\n")

	while cnt--			
	   PUT("%o\t%d.\t\%d",
	   itm->Vblk, itm->Vblk, itm->Vcnt)
	   if rep
	   && (ent = rd_loc (seg, itm->Vblk)) ne
	      rx_fmt ("%r%r.%r", ent->Anam, nam)
	      PUT("\t%-12s%o	%d", nam, 
	      itm->Vblk-seg->Vblk, itm->Vblk-seg->Vblk)
	   end
	   PUT("\n")
	   ++itm				;
	end				;

	cnt = bad->Irec.Vpnt
	plu = (cnt eq 1) ? "" ?? "s"
	PUT("?VUP-I-%d bad block%s detected %s\n", cnt, plu, spc) 
  end
code	bd_map - map bad blocks to directory

  func	bd_map				; list bad blocks
	bad : * bdTbad			;
  is	itm : * bdTrec = bad->Arec	;
	cnt : int = bad->Irec.Vpnt	;
	seg : * rdTseg = bad->Pseg
	ent : * rtTent
	spc : * char = "FILE.BAD"

	fine if !cnt			; naught to be done
					;
	seg = bad->Pseg = rd_alc (seg, bad->Pfil)
	rd_get (seg, 1)			; get 

	while cnt--			;
	   if itm->Vblk lt ((seg->Vtot*2)+6)
	      bad->Vflg |= bdSYS_	; system blocks affected
	   else
	      ent = rd_tem (seg, <>, spc, itm->Vcnt)
	      rd_cre (seg, ent, itm->Vblk, 1)
	   .. bad->Vflg |= bdCRE_ if fail
	   ++itm
	end
	rd_upd (seg)
	fine
  end
code	bd_rep - report bad block status

  func	bd_rep
	bad : * bdTbad~
  is	spc : * char = fi_spc (bad->Pfil)
	if bad->Vflg & bdOVR_
	.. im_rep ("W-Too many bad blocks to record %s", spc)
	if bad->Vflg & bdSYS_
	.. im_rep ("W-Bad blocks in system area %s", spc)
	if bad->Vflg & bdCRE_
	.. im_rep ("W-Error creating bad block files %s", spc)
  end

