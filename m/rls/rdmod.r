;???:	RLS:RDMOD - Add INIT/NAKED to expose BOOT1$,HOME$$,BOOT2$ etc
;???;	RLS:RDMOD - Enter/Delete/Rename to be added
;\\\;	RLS:RDMOD - Merged cts:/rls:rtdir.d - rtThdr was different
;	rd_ini clears segment
;	do bad_block scan
;	[ EMPTYFIL]
;	Link should write out segments immediately
;	add validation code
;	add error messages/signals
file	rdmod - RT-11 directory toolkit
include	rid:rider
include	rid:imdef
include	rid:medef
include	rid:stdef
include rid:fidef
include	rid:rxdef
include rid:hodef
include rid:rtbad
include	rid:rtdir
include	rid:rddef
If Win
include rid:rtutl
rt_ftm(ent,siz) := 
Else
include rid:rtrea
End
mnt$c=0

;	o  May be used with device or container file
;	o  Assumes exclusive access to volume
;	o  All segment updates are fail-soft
;	o  Provides most of what is needed to construct an RT11X ACP (rt_acp)
;	o  Should be portable to non-RT-11 systems
;	o  Naming convention assumes:
;	   RD=RT11, XD=RSX, VD=VMS, UD=Unix, FD=Fat
;	   rt_acp,  od_acp, od_acp, ux_acp,  ft_acp
;
;	rd_alc 	allocate segment
;	rd_dlc	deallocate it
;
;	rd_get	get segment
;	rd_put	put segment
;	rd_upd	put segment if modified
;	rd_fst
;	rd_suc
;
;	rd_cal	calculate segment parameters
;	rd_val	validate segment
;	rd_rec	recognise directory type
;	rd_sum	display segment summary
;	rd_red	reduce segment
;
;	rd_nxt	point to next entry
;	NXT()	points to next but doesn't update segment accumulator etc
;
;	rd_ins	insert entry
;	rd_exp	expand segment creating new empty
;	rd_spl	split segment
;
;	;g_del	delete entry
;	;g_ren	rename entry
;	rd_cre	create entry at block
;	rd_mod	modify (extend/truncate) entry
;
;	rd_sav	save directory info
;	rd_res	restore directory info
;	rd_ini	create new directory
;	rd_bad	create/retrieve .bad entries
;	sq_squ	squeeze directory

	P(x)	:= (<*char>(x))
	V(x)	:= (<*void>(x))
	E(x)	:= (<*rtTent>(x))
	W(x)	:= (<WORD>(x))
	END(x)	:= (x->Vsta & rtEND_)
	EMP(x)	:= (x->Vsta & rtEMP_)
	PER(x)	:= (x->Vsta & rtPER_)
	NXT(s,x) := E(P(V(x)) + s->Vsiz) ; fast rd_nxt ()

;	rd_loc : (*rdTseg, WORD) *rtTent
	rd_emp : (*rtTent) void-
	rd_upd : (*rdTseg)
	rd_lnk : (*rdTseg)
	rd_bad : (*bdTbad, WORD, WORD)
code	segment allocation

  func	rd_alc				; allocate segment structure
	seg : * rdTseg~
	fil : * FILE			; directory handle
	()  : * rdTseg
  is	seg = me_acc (#rdTseg) if !seg	; allocate new one
	seg->Pfil = fil			;
	reply seg			;
  end

  func	rd_sec				; allocate secondary
	seg : * rdTseg~
	()  : * rdTseg
  is	seg->Psec = rd_alc (seg->Psec, seg->Pfil) ; allocate secondary
	reply that
  end

  proc	rd_dlc				; deallocate all
	seg : * rdTseg~
  is	me_dlc (seg->Psec)		; deallocate secondary
	me_dlc (seg)			; deallocate primary
  end

  proc	rd_clr				; clear segment
	seg : * rdTseg
  is	fil : * FILE = seg->Pfil	; retain file link
	me_clr (seg, #rdTseg)
	seg->Pfil = fil
  end
;???;	RLS:RDMOD - RD_END doesn't check corrupt directory
code	entry routines

  proc	rd_fst				; point to first entry
	seg : * rdTseg~
	()  : * rtTent
  is	ent : * rtTent~ = seg->Aent
	seg->Pcur = ent			; current entry
	seg->Vblk = seg->Vbas		; current block
	seg->Vacc = seg->Vbas 		; setup accumulator
	seg->Vacc += ent->Vlen if !END(ent)
	reply ent
  end

  func	rd_nxt				; point to next entry
	seg : * rdTseg~
	ent : * rtTent~
	()  : * rtTent
  is	fail if END(ent)
	ent = NXT(seg, ent)		; point to next
	fail if P(ent) - P(seg) ge 1024	; corrupt directory
	seg->Vblk = seg->Vacc		; start of this file
	seg->Vacc += ent->Vlen if !END(ent)
	seg->Pcur = ent			 
	reply ent
  end

  func	rd_end				; point to end entry
	seg : * rdTseg~
	()  : * rtTent
  is	ent : * rtTent~ = seg->Aent
	while !END(ent)			; got more?
	.. ent = NXT(seg, ent)		; skip it
	reply ent
  end

  proc	rd_mov				; move entry
	seg : * rdTseg
	src : * rtTent
	dst : * rtTent
  is	me_mov (src, dst, seg->Vsiz)
  end
code	rd_tem - construct entry template

  func	rd_tem				; construct template entry
	seg : * rdTseg
	ent : * rtTent~
	spc : * char~
	len : int
	()  : * rtTent
  is	ptr : * char~
	ent = &seg->Item if !ent
	if (ptr = st_fnd (":", spc)) ne
	.. spc = ptr + 1
	while (ptr = st_fnd ("\\", spc)) ne
	.. spc = ptr + 1
	rx_scn (spc, <*WORD>ent)
	ent->Vsta = rtPER_		; overwrite dev: with status
	rt_ftm (ent, seg->Vsiz)		; get file time
	ent->Vlen = len
	reply ent
  end

code	rd_emp - make empty entry

	rx_EM := 0325
	rxPTY := 063471
	rxFIL := 023364

  proc	rd_emp
	ent : * rtTent~
  is	ent->Vsta = rtEMP_
	exit if ent->Anam[0]		; has a name
	ent->Anam[0] = rx_EM		;
	ent->Anam[1] = rxPTY		;
	ent->Anam[2] = rxFIL		;
  end
;+++;	RLS:RDMOD - Completed RD_REP to display message (untested)
code	segment routines

  func	rd_val				; is segment valid?
	seg : * rdTseg
  is	reply seg->Vval
  end

  func	rd_suc				; get successor segment
	seg : * rdTseg~
  is	reply rd_get (seg, seg->Vsuc)	; get successor
  end

  func	rd_get				; get/read segment
	seg : * rdTseg~
	idx : int~
  is	if !seg->Vval || (idx ne seg->Vidx)
	   fail if !rd_upd (seg)	; update if required
	   seg->Vval = 0		;
	   fail if !idx			; segment overrun
	   rt_rea (seg->Pfil, rd_s2b(idx), P(seg), 512, rtWAI)
	   fail ++seg->Verr if fail	; oops
	.. ++seg->Vval			; segment is valid
	seg->Vidx = idx			; current segment index
	seg->Vsiz = (rtRTA*2)+seg->Vext	; entry size
	rd_red (seg)			; reduce and calculate
;sic]	rd_cal (seg)
	fine
  end

  func	rd_upd				; update segment
	seg : * rdTseg~
  is	fine if !seg->Vupd		; nothing to do
	reply rd_put (seg, 0)		; update it
  end

  func	rd_put				; write segment
	seg : * rdTseg~
	idx : int~
  is	idx = seg->Vidx if !idx		; current segment
	seg->Vupd = 0			; updated, even if fail
	rt_wri (seg->Pfil, rd_s2b(idx), P(seg), 512, rtWAI)
	fail ++seg->Verr if fail	;
	fine
  end

  func	rd_s2b				; segment index to block number
	idx : int			; segment index
  is	reply ((idx - 1) * 2) + 6	; segment to block
  end

  func	rd_sta				; get segment error status
	seg : * rdTseg
  is	reply !seg->Verr
  end

  func	rd_rep				; report segment status
	seg : * rdTseg
	msg : * char
  is	spc : * char = fi_spc(seg->Pfil);
	fine if !seg->Verr		;
	fail if !msg			; no message required
	fail im_rep (msg, spc)		; display message
  end
code	rd_red - reduce segment

;	Adjacent empty/tentative entries are merged

  func	rd_red
  	seg : * rdTseg~
  is	ent : * rtTent~ = rd_fst (seg)
	nxt : * rtTent~ = ent
	while !END(nxt)
	   if ent ne nxt		; only copy if necessary
	   .. rd_mov (seg, nxt, ent)	; move one more
	   nxt = NXT(seg, nxt)		; fast next
	   while !PER(ent) && !PER(nxt)	;
	      quit if END(nxt)		;
	      ent->Vlen += nxt->Vlen	;
	      nxt = NXT(seg, nxt)	;
	   end				;
	   ent = NXT(seg, ent)		; fast next
	end
	ent->Vsta = nxt->Vsta		; copy end marker
	reply rd_cal (seg)		; recalculate
  end

code	rd_cal - calculate segment parameters

  func	rd_cal
	seg : * rdTseg~
  is	ent : * rtTent~ = rd_fst (seg)
	seg->Vsiz = (rtRTA*2) + seg->Vext
	seg->Vavl = (1024/<word>seg->Vsiz)-1 ;<word> avoids PDP-11 long div
	while !END(ent)
	   --seg->Vavl
	.. ent = rd_nxt (seg, ent)
	rd_fst (seg)
	fine
  end
code	rd_exp - expand segment to create new entry

; 	ent ->	entry before new entry
;	req =	minimum number of free entries which will be required
;		If an operation requires at least two free empties
;		it makes the first call with req=2 and the second with
;		req=1 (or req=0).
;	emp =>	Convert new entry to zero-length free entry
;
;	ent ->	entry, relocated if directory split occurred
;		its followed by a zero-length empty entry

  func	rd_exp
	seg : * rdTseg~
	ent : * rtTent~
	req : int
	emp : int			;??; this is unused, forgotten
	()  : * rtTent
  is	nxt : * rtTent
	len : int
	if seg->Vavl lt req		; no more entries available
	   ent = rd_spl (seg, ent)	; split the segment
	.. pass fail			; directory full or error
					;
	len = P(rd_end(seg))-P(ent)+2	; length of copy
	nxt = NXT(seg, ent)		; next entry
	me_mov (P(ent), P(nxt), len)	; move all succeeding entries up
	rd_emp (nxt)			; make an empty entry
;	nxt->Vsta = rtEMP_		; an empty
	nxt->Vlen = 0			; of zero length
	--seg->Vavl			; one less entry available
	reply ent			; return (relocated) pointer
  end
code	rd_spl - split segment

;	Split the segment such that the selected entry and it's 
;	successor are not separated.
;
;	Return adjusted pointer to entry

  func	rd_spl
	pri : * rdTseg~
	tar : * rtTent
	()  : * rtTent
  is	sec : * rdTseg~ = rd_sec (pri)
	hlf : * rtTent = E(P(pri) + 512)
	ent : * rtTent
	emp : * rtTent
	src : * rtTent
	dst : * rtTent
	nxt : * rtTent~
	rel : int = 0
	dif : int
	siz : WORD = pri->Vsiz

	fail if (emp = rd_nxt (pri, tar)) eq	; can't split at end
	nxt = rd_fst (pri)

	while (nxt lt hlf)
	.. fail if (nxt = rd_nxt (pri, nxt)) eq	; go past halfway mark

	if nxt eq emp				; our target empty
	.. fail if (nxt = rd_nxt (pri, nxt)) eq	; keep successor empty
	hlf = nxt

	fail if !rd_lnk (pri)			; link to new segment
	sec->Vbas = pri->Vblk			; setup start block
	src = nxt, dst = sec->Aent		; setup to copy
	while !END(src)				;
	   tar = dst, ++rel if tar eq src	; track target
	   rd_mov (pri, src, dst)		; move one more
	   src = NXT(pri, src)			;
	   dst = NXT(sec, dst)			;
	end					;
	nxt->Vsta = src->Vsta			; terminate primary segment
	dst->Vsta = src->Vsta			; terminate secondary
	fail if !rd_put (sec, 0)		; put secondary first
	fail if !rd_put (pri, 0)		; reglue directory
						;
	if rel					; we moved the target entry
	   me_mov (&pri->Item, &sec->Item, #rtTent)
	   me_mov (sec, pri, #rdTseg)		; so copy it all back
	   dif = P(tar) - P(sec->Aent)		;
	.. tar = E(P(pri->Aent) + dif)	;
						;
	rd_cal (pri)				; recalculate available
	nxt = rd_fst (pri)			; set accumulator up to entry
	while nxt && (nxt ne tar)		; recalculate stuff
	.. nxt = rd_nxt (pri, nxt)		;
						;
	reply tar				;
  end

code	rd_lnk - link in new segment

;	1.  Get new segment number from root Vlst, incrementing it.
;	2.  Update root if root is not current segment.
;	3.  Build new segment and links.
;	4.  Mark current and new segment for update.

  func	rd_lnk
	pri : * rdTseg~
  is	sec : * rdTseg~ = rd_sec (pri)
	ent : * rtTent~
	idx : WORD
	if pri->Vidx eq 1		; in root segment
	   fail if pri->Vlst ge pri->Vtot ; no more segments
	   idx = ++pri->Vlst		; get next index
	else				;
	   fail if !rd_get (sec, 1)	; get root
	   fail if sec->Vlst ge sec->Vtot ; no more segments
	   idx = ++sec->Vlst		; get next index
	   fail if !rd_put (sec, 1)	; put root
	end				;
					;
	me_cop (pri, sec, #rtThdr)	; copy header
	sec->Vsiz = pri->Vsiz		; copy entry size (for NXT(sec))
					;
	sec->Vsuc = pri->Vsuc		; link us in
	sec->Vidx = idx			;
	pri->Vsuc = idx			;
					;
	ent = sec->Aent			; create initial empty
	rd_emp (ent)			; make an empty entry
;	ent->Vsta = rtEMP_		;
	ent->Vlen = 0			; caller sets size up
					;
	ent = NXT(sec, ent)		; terminate secondary 
	ent->Vsta = rtEND_		;
					;
	rd_cal (sec)			; calculate
	pri->Vupd = 1			;
	sec->Vupd = 1			;
	fine
  end
code	rd_cre - create file at specific block

  func	rd_cre
	seg : * rdTseg~
	tem : * rtTent
	blk : int
	upd : int 
	()  : * rtTent
  is	ent : * rtTent~
	nxt : * rtTent
	len : WORD = tem->Vlen
	dif : int
	siz : int = #rtTent

	ent = rd_loc (seg, blk)		; find the block
	pass fail			; not found
	fail if !EMP(ent)		; must be an empty
	siz = seg->Vsiz if seg->Vsiz lt siz
					;
	if blk gt seg->Vblk		; need preceding filler
	   ent = rd_exp (seg, ent, 2, 1); make space (reserve space for two)
	   pass fail			;
	   nxt = NXT(seg, ent)		;
	   dif = blk - seg->Vblk	; get the difference
	   nxt->Vlen = ent->Vlen-dif	; move remainder to next
	   ent->Vlen = dif		; fix size of filler
	.. ent = rd_nxt (seg, ent)	; skip it (and count it)
					;
	if len ne ent->Vlen		; not exactly the right size
	   ent = rd_exp (seg, ent, 1, 1); guaranteed not to split :-)
	   pass fail			;
	   nxt = NXT(seg, ent)		;
	   nxt->Vlen = ent->Vlen-len	;
	.. ent->Vlen = len		;
					;
	me_clr (ent, seg->Vsiz)		; make sure unused data is cleared
	me_mov (tem, ent, siz)		; copy in the template
	++seg->Vupd			; update required
	reply ent			;
  end
code	rd_siz - change entry size

  func	rd_siz
	seg : * rdTseg~
	ent : * rtTent~
	len : int
  is	dif : int = len - ent->Vlen
	fine if !dif
	reply rd_ext (seg, ent, dif) if dif gt
	reply rd_tru (seg, ent, -dif) ;otherwise
  end

code	rd_ext - extend entry

  func	rd_ext
	seg : * rdTseg
	ent : * rtTent
	len : int~
  is	nxt : * rtTent~
	nxt = rd_nxt (seg, ent)		; point at next
	pass fail			; i/o error
	fail if !EMP(nxt)		; must be empty
	fail if nxt->Vlen lt len	; insufficient space
	ent->Vlen += len		; adjust them
	nxt->Vlen -= len		; signal update
	seg->Vupd = 1			;
	fine				;
  end

code	rd_tru - truncate entry

;	ent may point at empty or actual file

  func	rd_tru
	seg : * rdTseg
	ent : * rtTent
	len : int
  is	nxt : * rtTent
	nxt = rd_nxt (seg, ent)
	pass fail
	if !EMP(nxt)			;
	   nxt = rd_exp (seg, ent, 1, 1); expand segment
	   pass fail			; directory full or error
	.. nxt = rd_nxt (seg, nxt)	; skip to real next
	nxt->Vlen += nxt->Vlen + len
	ent->Vlen -= len
	seg->Vupd = 1
	fine
  end
code	rd_fnd - find entry via name

  func	rd_fnd
	seg : * rdTseg~
	nam : * WORD
	()  : * rtTent
  is	ent : * rtTent~

	fail if !rd_get (seg, 1)	; get first segment
	while rd_val (seg)		;
	   ent = rd_fst (seg)		; first in segment
	   while !END(ent)		; not at segment end
	      if PER(ent)		; permanent
	      && me_cmp (nam, ent->Anam, 6) ; same name
	      .. reply ent		; we have a match
	      ent = rd_nxt (seg, ent)	; try next entry
	   end				;
	   fail if !rd_suc (seg)	;
	end				;
	fail				;
  end

code	rd_loc - locate entry via block number

  func	rd_loc
	seg : * rdTseg~
	blk : int
	()  : * rtTent
  is	ent : * rtTent~

;	Optimise to start at current segment if possible

	if seg->Vval			; got valid segment
	&& blk ge seg->Vbas		; and it starts below target block
	   rd_fst (seg)			; start here
	else				;
	.. fail if !rd_get (seg, 1)	; back to the start

	while rd_val (seg)		;
	   ent = rd_fst (seg)		; first in segment
	   while !END(ent)		; not at segment end
	      if W(blk) ge seg->Vblk	; check block in range
	      && W(blk) lt seg->Vacc	;
	      .. reply ent		; found it
	      ent = rd_nxt (seg, ent)	; try next entry
	   end				;
	   fail if !rd_suc (seg)	; get next segment
	end
	fail
  end
code	rd_ini - initialize directory

  func	rd_ini
	seg : * rdTseg~			; open segment
	tot : int			; total segments
	len : int			; disk size in blocks
	ext : int			; extra bytes per entry
	wri : int 			; write flag
  is	ent : * rtTent~			;
	seg->Vidx = 1			; manual segment index
	seg->Vsiz = (rtRTA*2) + ext	; manual entry size
					;
	seg->Vtot = tot			; total segments
	seg->Vsuc = 0			; no successor segment
	seg->Vlst = 1			; we are the last segment
	seg->Vext = ext			; extra words per entry
	seg->Vbas = (tot*2) + 6		; first data block
	ent = seg->Aent			;
	ent->Anam[0]=0			; force " EMPTY.FIL"
	rd_emp (ent)			; make an empty entry
	rt_ftm (ent, seg->Vsiz)		; fill in the time
	ent->Vlen = len - seg->Vbas	; length of empty 
	ent = NXT(seg, ent)		; point to next
	ent->Vsta = rtEND_		; terminate segment
	rd_cal (seg)			; count things
	++seg->Vupd			; needs update
	reply rd_put (seg, 1) if wri	; update now
	fine				;
  end

code	rd_sav - save directory

  func	rd_sav
	seg : * rdTseg
	buf : * WORD
  is	fail if !rd_get (seg, 1)	; get directory
	me_mov (seg, buf, hoRES*2)	; copy directory header 
	fine
  end

code	rd_res - restore directory

  func	rd_res
	seg : * rdTseg~
	buf : * WORD
	wri : int
  is	fail if !rd_get (seg, 1)	; get directory
	me_mov (buf, seg, hoRES*2)	; copy directory header 
	seg->Vupd = 1			; needs update
	fine if !wri			; don't update
	reply rd_upd (seg) if wri	; update now
  end
code	rd_chk - check directory header

  func	rd_det				; detect RT11A/RT11X directory
	seg : * rdTseg
  is	fail if !rd_get (seg, 1)	; oops
	reply rd_chk (seg, 1)		; check structure
  end

  func	rd_chk
	ptr : * void			; called from other places
	idx : WORD			; segment index
  is	dir : * rdTseg~ = ptr
	if idx eq
	|| idx gt dir->Vtot
	|| dir->Vtot eq
	|| dir->Vtot gt 31
	|| dir->Vsuc gt 31
	|| dir->Vlst eq
	|| dir->Vlst gt 31
	|| dir->Vext & 1
	|| dir->Vext gt 128
	|| (dir->Aent[0].Vsta & (rtTEN_|rtEMP_|rtPER_)) eq
	.. fail

	if idx eq 1			; first segment
	&& (dir->Vbas ne ((dir->Vtot*2)+6)) ; block missmatch
	.. fail
	fine
  end

code	rd_blk - check for blank (initialized) directory

  func	rd_blk
	seg : * rdTseg~
  is	ent : * rtTent~
	nxt : * rtTent~
	fail if !rd_get (seg, 1)
	ent = rd_fst (seg)
	nxt = rd_nxt (seg, ent)
	if seg->Vsuc ne			; must be single segment
	|| (ent->Vsta & rtEMP_) eq	; with a single empty
	|| (nxt->Vsta & rtEND_) eq	;
	.. fail
	fine
  end
code	rd_dem - check volume demography

;	Work out used/free blocks, bad/sys files, protected files
;	Calls bad block driver to record bad block files 

	rxSYS := 075273
	rxBAD := 06254

  func	rd_dem
	seg : * rdTseg~
	dem : * rdTdem~
	bad : * bdTbad
  is	ent : * rtTent~ 
	me_clr (dem, #rdTdem)
	fail if !rd_get (seg, 1)
	while rd_val (seg)
	   ent = rd_fst (seg)		; first in segment
	   while !END(ent)		; not at segment end
	      if PER(ent)
	         dem->Vuse += ent->Vlen
	         ++dem->Vpro if ent->Vsta & rtPRO_
	         ++dem->Vsys if ent->Anam[2] eq rxSYS
	         ++dem->Vbad if ent->Anam[2] eq rxBAD
		 if bad && (ent->Anam[2] eq rxBAD)
		 .. rd_bad (bad, seg->Vblk, ent->Vlen)
	      else
	      .. dem->Vemp += ent->Vlen
	      ent = rd_nxt (seg, ent)	; try next entry
	   end				;
	   rd_suc (seg)			;
	end
	reply rd_sta (seg)		; return status
  end

code	rd_bad - enter bad block into table

;	This code duplicates bd_ent. It's here to avoid loading
;	all the bad block code.

  func	rd_bad
	bad : * bdTbad~			; bad context
	blk : WORD			; block
	cnt : WORD			; count
  is	rec : * bdTrng~ = &bad->Irec	; recording range
	ent : * bdTrec~
	if rec->Vpnt ge rec->Vlim	; too many?
	.. fail bad->Vflg |= bdOVR_	; overflow
	ent = &bad->Arec[rec->Vpnt++]	;
	ent->Vblk = blk			;
	ent->Vcnt = cnt			;
	fine
  end
end file
code	rd_dmp - maintenance dump
;If mnt$c

  func	rd_dmp
	seg : * rdTseg~
	cnt : int
  is	ent : * rtTent~
	nam : [16] char
	cnt = 100 if !cnt

	PUT("\n")
If 1
	PUT("idx=%d, cur=%o, avl=%d, siz=%d, blk=%d, acc=%d\n",
	  seg->Vidx,seg->Pcur,seg->Vavl, seg->Vsiz, seg->Vblk, seg->Vacc)
End
If 0  
	PUT("val=%d, upd=%d, err=%d, pri=%o, sec=%o, fil=%o\n",
	  seg->Vval,seg->Vupd,seg->Verr, seg->Ppri, seg->Psec, seg->Pfil)

	PUT("tot=%d, suc=%d, lst=%d, ext=%d, bas=%o\n",
	  seg->Vtot,seg->Vsuc,seg->Vlst, seg->Vext, seg->Vbas)
End
	ent = seg->Aent
	while cnt-- && ent->Vsta
	  rx_fmt ("%r%r.%r", ent->Anam, nam)
	  PUT("%o:\t", ent)
	  PUT("sta=%o [%s] len=%d tim=%o dat=%o\n",
	    ent->Vsta, nam, ent->Vlen, ent->Vtim, ent->Vdat)
	  quit if END(ent)
	  ent = NXT(seg, ent)
	end
  end
;End
end file
code	rd_vol - get volume information

;	Work out used/free blocks

	rxSYS := 075273
	rxBAD := 06254

  func	rd_vol
	seg : * rdTseg~
	vol : * rdTvol
  is	ent : * rtTent~ 
	idx : int = 1
	me_clr (vol, #rdTvol)
	reply rd_wlk (seg, &rd_vlw, vol)
  end

  func	rd_vlw
	seg : * rdTseg
	vol : * rdTvol
	ent : * rtTent
  is	if PER(ent)
	   vol->Vuse += ent->Vlen
	   ++vol->Vpro if ent->Vsta & rtPRO_
	   ++vol->Vsys if ent->Anam[2] eq rxSYS
	   ++vol->Vbad if ent->Anam[2] eq rxBAD
	else
	.. vol->Vemp += ent->Vlen
	fine
  end
end file
code	rd_bad - record bad blocks

;	Bad block entries are copied to an array
;	All information is retained

	rxBAD := 06254

  func	rd_bad
	seg : * rdTseg~
	bad : * rtTbad
  is	bad->Vtot = 0
	rd_wlk (seg, &rd_bdw, bad)
  end

  func	rd_bdw
	seg : * rdTseg
	bad : * bdTbad
	ent : * rtTent
  is	if !PER(ent) 
	&&  ent->Anam[2] ne rxBAD
	   if bad->Vtot lt bad->Vmax
	   .. bad->Abad[bad->Vtot] = seg->Vblk
	.. ++bad->Vtot
  end

  func	rd_wlk
	seg : * rdTseg
	fun : * rdTwlk
	par : * void
  is	rd_get (seg, 1)
	while rd_val (seg)
	   ent = rd_fst (seg)
	   while !END(ent)
	      (*fun)(seg, par, ent)
	      pass fail
	      ent = rd_nxt (ent)
	   end
	  rd_suc (seg)
	end
	reply rd_sta (seg)
  end
If acpC
code	rt_rec - recognise RT-11 media

  type	acTent
  is	Vflg : WORD		; flags
	Pspc : * char		; file spec
 	Vlen : long		; file length (if known)
	Vblk : long		; start block (if applicable)
	Itim : tiTxxx		; file creation time
	Vuic : WORD		; UIC
	Vprt : WORD		; protection mask
	Vfmt : WORD		; file format
	Pacp : * <>		; native ACP object
  end

  func	rt_acp
	acp : * acTacp
	cod : int
  is
  end

  func	rt_rec
  is
  end

  func	rt_mnt
  is
  end

  func rt_loo
	seg : * rdTseg
	spc : * rtTspc
	()  : * rtTent
  is	ent : * rtTent
	ent = rd_fnd (seg, spc)
	reply ent if ent
	reply rtFNF
  end

  func	rt_del
	seg : * rdTseg
	spc : * rtTpc
  is	ent : * rtent = rd_fnd ()
	reply rtFNF if !ent
	reply rtPRT if ent->Vsta & rtPRT_
	ent->Vsta = rtEMP_
	rd_upd (seg)
	fine
  end

  func	rt_ren
	old : * rtTspc
	tar : * rtTspc
  is	ent : * rtTent
	tmp : * rtTent
	ent = rd_fnd (old)
	reply rtFNF if !ent
	reply rtPRT if ent->Vsta & rtPRT_
	ent = rd_fnd (tar)
	if ent && (ent->Vsta && rtPRT_)
	.. reply rtPRT
	ent->Vsta = rtTMP
	rd_upd (seg)
	rd_fnd (seg, old)
	reply rtCOR if !ent
	me_cop (tar, ent->Anam, 6)
	rd_upd (seg)
	fine
  end

  func	rt_ent
  is

;	need to add logic to record largest/second largest hole
;	and to locate a hole if a given minimum size

  end


  func	rt_inf
  is

  end

End
