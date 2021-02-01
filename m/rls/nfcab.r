dbg$c := 0
;	mark temporary files for delete_on_clos
;	also delete_on_exit
;
file	nfcab - cabs
include	rid:rider
include rid:nfdef
include	rid:nfcab
include	rid:drdef
include	rid:fidef
include	rid:medef
include	rid:mxdef
include	rid:stdef
include	rid:imdef
include rid:mxdef
include rid:rtdir
include rid:rtutl
include rid:tidef

;	CABs (Channel Access Blocks) are used to map the RT-11 file system
;	on to the host system.
;
;	o  Solve RT-11 .SAVESTATUS problem
;	o  Create directory on-the-fly data
;	o  Solve tentative file problems
;
;	The image channel, channel 017, is sometimes special.
;
;	CAB numbers are stored starting at 0100000
;	This distinquishs them from channels opened on other devices.
;
;	Reset all cabs, except channel 17
;	delete	vx7:sreset.job	all but channel 15.
;	delete	vx7:jreset.job	all channels except logger if *.log

	cabPfre : * cabTcab = <>
	cabVseq : int = 0 ;elTwrd = 0
	cabVact : int = 0			; number of active cabs
	cabAcab : [1024] *cabTcab
	cabVimg : int = 0

	cab_img : (*cabTcab, **cabTcab, int) int
	cab_prg : (*cabTcab, int) int
;	cab_did : (*cabTcab) void
	cabApad : [512] char = {0}

	cab_get : (*cabTcab, *void, int, int) int
	vol_opn : (*cabTcab, int, int) int
	vol_clo : (*cabTcab) int
	vol_get : (*cabTcab, *void, int, int) int
	vol_put : (*cabTcab, *void, int, int) int
	vol_loc : (*cabTcab, int, *char, *int) int

;	cab_ver : (*cabTcab) int
;	cab_fnd : (*char) *cabTcab
	cab_det : (*cabTcab) int
	cab_att : (*cabTcab) int
	tmp_gen : (*cabTcab, *char, *char) int 
	tmp_rem : (*cabTcab, *char, *char, **cabTcab, *char, int) int
	tmp_res : (*char, *char) int
	tmp_prg : (*cabTcab)
	tmp_ten : (*char, *char, *char) void
	tmp_spc : (*char, int, *char, *char)
	tmp_exs : (*char)
	tmp_hng : (*char) int

	lnk_map : (*char) *cabTcab
	lnk_ren : (*cabTcab, *char, *char)
	lnk_res : (*cabTcab, *char)
	lnk_att : (*cabTcab)
	lnk_det : (*cabTcab)

	cabIboo : cabTcab = {<>, cabREP, cabDSK_}
code	cab_cre - create new cab

  func	cab_cre
	vab : * nfTvab
	fil : * FILE			; file block
	spc : * char			; the file spec
	typ : int			; type
	flg : int			; flags
	()  : * cabTcab			;
  is	cab : * cabTcab			;
	seq : int = -1			; cab sequence
					;
	if vab->Pcab			; already got one
	   cab = vab->Pcab		;
	   cab->Pfil = fil		;
	   cab->Vtyp = typ		;
	   cab->Vflg |=  flg		;
	   st_cop (cab->Aspc, cab->Atmp);
	   vab->Pcab = <>		; in use now
	.. reply cab			;
					;
	while ++seq lt cabVseq		; more in list
	   cab = cabAcab[seq]		;
	   next if !cab->Vtyp		; not in use
	   me_cmp(vab->Asrc,cab->Asrc,6); same station?
	   next if fail			; nope
	   next if cab->Vprc ne vab->Vjid
	   next if cab->Vchn ne vab->Vjcn ; same channel
	   next if !cab->Pfil		; no file
	   if cab->Vtyp eq cabLOO 	; close it for the moment
	      fi_clo (cab->Pfil, <>) if cab->Pfil 
	      cab->Pfil = <>		;
	   elif cab->Vtyp eq cabENT	;
	   .. cab_prg (cab, 0)		; purge that
;???	   cab->Vseq = seq + cabFST 	; reset that
	   quit				;
	end				;
	++cabVact			; count active cabs
	cab = cabPfre			; find a free cab
	if cab				;
	   cabPfre = cab->Psuc		; get the next
	else				;
	   seq = cabVseq		; get the sequence number
	   if seq eq cabMAX		;
	   .. im_rep ("F-NF channel overflow [%s]", spc)
	   cab = me_acc (#cabTcab)	; make another
	   cab->Vseq = seq + cabFST 	; get another
	   cabAcab[seq] = cab		; save the pointer
	.. ++cabVseq			;
	cab->Vcid = cab->Vseq<<cabSHF	; map sequence to cid
;PUT("CRE: seq=%o cid=%o\n", cab->Vseq, cab->Vcid)
	cab->Vnod = vab->Vnod		; node
	cab->Vprc = vab->Vjid		; process
	cab->Vchn = vab->Vjcn		; channel
	cab->Pfil = fil			;
	cab->Vtyp = typ			;
	cab->Vflg = flg			;
	if cab->Vchn eq 15		; image channel
	.. cab->Vimg = cabVimg++	; make image sequence 
	me_cop (vab->Asrc, cab->Asrc, 6); copy station address
					;
	tmp_hng (spc)			; get rid of hanging tentatives
	st_cop (spc, cab->Aspc)		; copy spec
	st_cop (spc, cab->Atmp)		; temp initially same as final
	if typ eq cabENT		;
	.. tmp_ten (spc, ".ten", cab->Atmp)
	reply cab			;
  end
code	cab_map - map cab to channel

  func	cab_map
	cid : int
	()  : * cabTcab
  is	cab : * cabTcab
	seq : int = cid>>cabSHF		; get our version of it
	if seq eq (cabFST|cabBOO)	; the boot cab
	   st_cop ("NF7:", cabIboo.Aspc)
	.. reply &cabIboo		;
	fail if seq lt cabFST		;
	fail if seq gt (cabFST+cabMAX)	;
	cab =  cabAcab[seq - cabFST]	;
	pass fail
	cab->Vblk = cid - (seq<<cabSHF)	; provide block offset
	reply cab
  end

code	cab_opn - access file

  func	cab_opn
	idx : int
	()  : * cabTcab
  is	cab : * cabTcab = cab_map (idx)
	fail if !cab
	if (cab->Vtyp eq cabLOO) && !cab->Pfil
	.. cab->Pfil = cab_acc (cab->Atmp)
	reply cab
  end

code	cab_det - detach cab

  func	cab_det
	cab : * cabTcab
  is	fine if !cab
	fi_clo (cab->Pfil, <>)
	pass fail
	cab->Pfil = <>
  end

code	cab_att - reattach cab

  func	cab_att
	cab : * cabTcab
  is	fine if !cab
	fine if cab->Pfil
	fine if cab->Vtyp ne cabENT
	cab->Pfil = cab_acc (cab->Aspc)
	reply that ne
  end

code	cab_acc - open a file

  func	cab_acc
	spc : * char
	()  : * FILE
  is	fil : * FILE
	fil = fi_opn (spc, "rb+", <>)		; open for read/write
	fil = fi_opn (spc, "rb", <>) if fail	; open read-only
	reply fil
  end
code	cab_dlc - deallocate a cab

  proc	cab_dlc
	cab : * cabTcab
	mod : int
  is	cur : * cabTrep
	suc : * cabTrep
	seq : int = cab->Vseq	; save that
;PUT("[%d]", cabVact)
	exit if !cab->Vtyp	; cab not in use
	exit if cab->Vflg & cabPER_ ; permanent file

	if cab->Vtyp ne cabREP	; not replacement data
	   cab_prg (cab, mod)	; purge temp files etc
	   exit if fail		; permanent file
	else			;
	   suc = cab->Prep	; deallocate replacement chain
	   while (cur = suc) ne	;
	      suc = cur->Psuc	;
	      me_dlc (cur)	;
	.. end			;
	me_clr (cab, #cabTcab)	; zap it because we're fastidious here
	cab->Vseq = seq 	; put the sequence number back
	cab->Psuc = cabPfre	; link us up front of free list
	cabPfre = cab		;
	--cabVact		; count active cabs
  end

code	cab_res - reset VRT cabs

;	This routine used only by VRT and V11

  proc	cab_res
	mod : int		; cabIRS to keep image
  is	cab : * cabTcab
	img : * cabTcab = <>
	seq : int = -1
	while ++seq lt cabVseq
	   cab = cabAcab[seq]
	   next if !cab
	   next if cab_img (cab, &img, mod)
	   cab_dlc (cab, 0)
	end
  end

code	cab_eli - elide NF cabs

;	This routine used only by NF
;
;	cabNRS	node reset
;	cabPRS	process reset
;	cabIRS	image reset

  proc	cab_eli
	vab : * nfTvab
	mod : int
  is	cab : * cabTcab
	seq : int = -1
	img : * cabTcab = <>
	while ++seq lt cabVseq			; more in list
	   cab = cabAcab[seq]			; get next cab
	   next if !cab->Vtyp			; not in use
; ??? redundant now
	   me_cmp (vab->Asrc, cab->Asrc, 6)	; same station?
	   next if fail				; nope
	   if mod ne cabNRS			; not node reset
;	      next if cab->Vchn eq 16		; system channel
	      next if vab->Vjid ne cab->Vprc	; different process
	      next if vab->Vnod ne cab->Vnod	; different node
	   .. next if cab_img (cab, &img, mod)	; check for hanging images
	   cab_dlc (cab, mod)			; get rid of it
	end					;
  end

code	cab_img - deallocate image channels

;	One open file per image channel is permitted to remain open.

  func	cab_img
	cab : * cabTcab
	img : ** cabTcab
	mod : int			; cabIRS to keep image
  is	fail if mod ne cabIRS		; not sreset
	fail if cab->Vchn ne 15		; image channel
	if !*img			; the first?
	.. fine *img = cab		; this is the first
	if cab->Vimg lt (*img)->Vimg	; new one is earlier
	.. fine cab_dlc (cab, 0)	; dump it
	cab_dlc (*img, 0)		; old is later
	fine *img = cab			; replace with earlier
  end
;???	purge not done
code	cab_clo - close a channel

;	Only tentative file channels are actually closed
;	Theoretically, this logic applies only to channels
;	that are FIRST referenced by .SAVESTATUS.

  func	cab_clo
	idx : int
  is	cab : * cabTcab = cab_map (idx)
	ten : [20] char
	ptr : * char
	sts : int = 1			; assume hunky dory
	fine if !cab			; happens when NF restarts 

;PUT("[%s]->[%s]\n", cab->Atmp, cab->Aspc)
	if cab->Pfil			; got a file
	&& fi_clo (cab->Pfil, <>)	; and it's healthy
	   if cab->Vtyp eq cabENT	; new file
	      if fi_exs (cab->Aspc, <>)	;
	         tmp_rem (cab,cab->Aspc,<>,<>,<>,0); remap files with same spec
	      .. fi_del (cab->Aspc, <>) ; delete previous version
	.. .. sts = fi_ren (cab->Atmp, cab->Aspc, "") ; rename it
	cab->Pfil = <>			;
	cab_dlc (cab, 0) if cab->Vtyp ne cabLOO
	reply sts			;
  end

code	cab_prg - purge channel

;	Called when a channel is reused before being closed,
;	a close with length zero, or after a job reset of some sort.
;
;	Delete any tentative file associated with the channel.

  func	cab_pur			; external purge by cab id
	idx : int
  is	cab : * cabTcab = cab_map (idx)
	cab_prg (cab, 0)
  end

  func	cab_prg
	cab : * cabTcab
	mod : int
  is	ten : [20] char
	ptr : * char
	fine if !cab
	fine if cab->Vflg & cabPER_
	if cab->Pfil
	   fi_clo (cab->Pfil, <>)
	   if cab->Vtyp eq cabENT
	.. .. fi_del (cab->Atmp, <>) 	; delete it
	cab->Pfil = <>
;	tmp_prg (cab)			; purge temps
;???
;	if cab->Vtyp eq cabLOO
;	   if st_fnd (".SYS", cab->Aspc)
;	   || st_fnd (".DSK", cab->Aspc)
;	      fail if mod ne cabNRS
;;PUT("CAB=%x\n", cab)
;	.. .. PUT("?NFCAB-I-Purging [%s]\n", cab->Aspc) 
	fine
  end

code	cab_ext - set file size

;	Used by close to set file size

  func	cab_ext
	idx : int
	len : long
  is	cab : * cabTcab = cab_map (idx)	;
	ten : [20] char			;
	ptr : * char			;
	sts : int = 1			; assume hunky dory
	fine if !cab			; happens when NF restarts 
	fine if !cab->Pfil		; no file
	fine if cab->Vtyp ne cabENT	; not a new file
	fi_lim (cab->Pfil, len)		; set file size
	reply that			;
  end
code	cab_del - delete file

  func	cab_del
	spc : * char
  is	lnk : * cabTcab = <>
	loc : [mxSPC] char
	fi_loc (spc, loc)
	tmp_rem (<>,spc,<>,&lnk,<>,0)	; remap hanging references
	fine if fi_del (spc, <>)	; attempt delete
	fine if lnk			; was renamed
	fail				;
  end

code	cab_ren - rename

;	We can't check to see if the target name is locked.
;
;	o  Create temp name
;	o  Delete temp (it may or may not exist)
;	o  Rename target to temp
;	o  Rename source to target
;	o  Delete temp
;
;	On failure:
;
;	o  Rename temp back to target
;	o  Leave the temp existing if that fails

  func	cab_ren
	src : * char
	dst : * char
  is	lnk : * cabTcab = <>
	lft : * cabTcab = <>
	rgt : * cabTcab = <>
	tmp : [mxSPC] char	
	ren : [mxSPC] char	
	bak : int = 0

      begin
	if fi_exs (dst, <>)		; target exists
	   bak = 1			;
	   tmp_rem (<>,dst,<>,&rgt,tmp,1); remap destination references
	.. pass fail			; can't create temp
	tmp_rem (<>,src,dst,&lft,<>,1)	; remap source references
	quit if fail			; oops
	fi_del (tmp, <>) if bak && !rgt	; delete backup 
	fine				;
      end block
	if bak && tmp_res (tmp, dst)	; move them back
	.. fi_del (tmp, <>)		; delete temp
	fail
  end
code	cab_rep - make replacement block 

; ???	Need to cache buffers and reuse them
;
;	Psuedo-data, such as RT-11 directories created on-the-fly,
;	is handled as a set of "replacement" blocks for a device.
;
;	cap_rep (..)	Creates replacement blocks
;	cab_rea (..)	Reads replacement blocks
;
;	No checks are made for duplicate blocks
;	Count must be a multiple of 512 (always internal writes)

  proc	cab_rep
	cab : * cabTcab
	buf : * void
	blk : int
	cnt : int
  is	rep : * cabTrep
	prv : ** cabTrep = &cab->Prep
	while cnt gt
	   rep = me_acc (#cabTrep)
	   rep->Vblk = blk
	   rep->Vcnt = cnt
	   me_cop (buf, rep->Abuf, 512)
	   rep->Psuc = cab->Prep
	   cab->Prep = rep
	   cnt -= 512, ++blk, <*char>buf += 512
	end
  end

code	cab_rea - read cab replacement blocks

  func	cab_rea
	cab : * cabTcab
	buf : * void
	blk : int
	cnt : int
	()  : int 			; bytes transferred
  is	rep : * cabTrep
	cop : int
	trn : int = 0

	while cnt
	   cop = (cnt lt 512) ? cnt ?? 512
	   if !vol_get (cab, buf, blk, cop)
	   && !cab_get (cab, buf, blk, cop)
	   .. fail
	   <*char>buf += 512, ++blk	   ;
	   cnt -= cop, trn += cop	   ;
	end				   ;
	vol_clo (cab)
	reply trn
  end

code	cab_wri - write cab replacement blocks

  func	cab_wri
	cab : * cabTcab
	buf : * void
	blk : int
	cnt : int
	()  : int 			; bytes transferred
  is	rep : * cabTrep
	cop : int
	trn : int = 0

	while cnt
	   cop = (cnt lt 512) ? cnt ?? 512
	   if !vol_put (cab, buf, blk, cnt)
	   .. quit
	   <*char>buf += 512, ++blk
	   cnt -= cop, trn += cop
	end
	vol_clo (cab)
	reply !cnt
  end

code	cab_get - get a block

  func	cab_get
	cab : * cabTcab
	buf : * void
	blk : int
	cnt : int
  is	rep : * cabTrep
	rep = cab_loc (cab, blk)	; find the replacement
	pass fail			; no such block
	me_cop (rep->Abuf, buf, cnt)	; copy back
	fine
  end

code	cab_loc - locate a cab replacement block

  func	cab_loc
	cab : * cabTcab
	blk : int
	()  : * cabTrep
  is	rep : * cabTrep
	rep = cab->Prep
	while rep && (rep->Vblk ne blk)
	.. rep = rep->Psuc
	reply rep
  end
;???	cab->Atmp
code	vol_get - mimic RT-11 volume

;	If the file volume.sys exists on the target device
;	then use blocks 0-5 as the volume header.
;
;	0..5	boot area
;	6..x-1	directory
;	x...	files
;
;	where x = 6 + (31*2) = 70

	el_dbg : (*char) int

  func	vol_opn
	cab : * cabTcab
	blk : int
	wri : int
  is	spc : [mxSPC] char
	fil : * FILE
	bas : int

	if blk lt 6
	   fine if cab->Pvol && !cab->Vbas
	   vol_clo (cab)
	   st_cop (cab->Aspc, spc)
	   st_app ("VOLUME.SYS", spc)
	   cab->Vbas = 0
	   cab->Pvol = cab_acc (spc)
	.. reply that ne

	fail if wri
	fail if (blk lt 70) || !(cab->Vflg & cabDSK_)

	if cab->Pvol
	&& cab->Vbas
	&& blk ge cab->Vbas
	&& (blk-cab->Vbas) lt cab->Vlen
	.. fine

	vol_clo (cab)
	vol_loc (cab, blk, spc, &cab->Vbas)	; find the file
	pass fail
	st_ins (cab->Aspc, spc)
;PUT("BOO: Spec=[%s]\n", spc)
;el_dbg ("spc")
	cab->Pvol = cab_acc (spc)
	fine if ne
	PUT("BOO: Can't open [%s]\n", spc)
	fail
  end

  func	vol_clo
	cab : * cabTcab
  is	fine if !cab->Pvol
	fi_clo (cab->Pvol, <>)
	cab->Pvol = <>
	fine
  end

  func	vol_get
	cab : * cabTcab
	buf : * void
	blk : int
	cnt : int
  is	fst : size
	if !vol_opn (cab, blk, 0)
	   fail if blk ge 6
	.. fine me_clr (buf, cnt)

	fst = (blk-cab->Vbas)*512
	case fi_prd (cab->Pvol, buf, fst, cnt, <>)
	of fiERR 
	or fiEOF fail
	of fiPAR 
	or fiSUC fine
	end case
  end

  func	vol_put
	cab : * cabTcab
	buf : * void
	blk : int
	cnt : int
  is	spc : [mxSPC] char
	fil : * FILE = cab->Pvol
	zap : int = 6

	if !vol_opn (cab, blk, 1)
	   fail if blk ge 6
	   st_cop (cab->Aspc, spc)
	   st_app ("VOLUME.SYS", spc)
	   fil = fi_opn (spc, "wb+", <>)
	   pass fail
	   cab->Pvol = fil
	   fi_wri (fil, cabApad, 512) while zap--
	   fi_clo (fil, <>)
	.. vol_opn (cab, blk, 1)

	fil = cab->Pvol
	blk -= cab->Vbas
	fi_see (fil, blk*512)

	fi_wri (fil, buf, cnt)
	pass fail

	if cnt lt 512
	.. fi_wri (fil, cabApad, 512-cnt)
	fine
  end
code	vol_loc - locate file at block

;	Given a block number, locate the file that contains the block.
;	File is located in cached (replacement block) directory.
;	Return the file spec and the base block of the file.

  func	vol_loc
	cab : * cabTcab
	blk : int
	spc : * char
	off : * int
  is	rep : * cabTrep
	hdr : rtThdr 
	ent : * rtTent
	buf : * char = <*char>&hdr
	idx : int = 6
	bas : int
	acc : int
	*off = 0
      repeat
	if !cab_get (cab, buf, idx++, 512)
	|| !cab_get (cab, buf+512, idx++, 512)
	.. fail
	acc = bas = hdr.Vblk & 0xffff
	ent = hdr.Aent
	while !(ent->Vsta & rtEND_)
;rt_unp (ent->Anam, spc, -3)
;PUT("BOO: Spec=[%s]\n", spc)
	   acc += ent->Vlen &0xffff
	   quit if bas gt blk
	   if blk lt acc
	      rt_unp (ent->Anam, spc, -3)
	      *off = bas
	   .. fine
	   bas = acc
	   ent = <*rtTent>(<*char>(++ent) + hdr.Vext - rtRTX)
	end
      end
	fail
  end
;	need to create rep
code	tmp_rem - remap names

;	Remap spec provided to new name (either generated or specific)
;	Point all cabs with old name to new name
;	Detach and attach as required
;
;	Applies only to lookup files

  func	tmp_rem
	skp : * cabTcab				; skip this cab
	spc : * char				; spec
	rep : * char				; replacement spec
	res : ** cabTcab			; link result (optional)
	ren : * char				; rename result (optional)
	alw : int 				; always
  is	buf : [mxSPC] char
	cab : * cabTcab
	lnk : * cabTcab
	seq : int = -1
	sts : int = 0
	*res = <> if res			; default 

	lnk = lnk_map (spc)			; get list of links
	fine if fail && !alw			; are none
	*res = lnk if res			;

	if !rep					; generate name
	   tmp_spc (spc, 0, ".del", buf)	;
	   rep = buf				;
	.. st_cop (rep, ren) if ren		;

	lnk_det (lnk)				; detach them all
	sts = lnk_ren (lnk, spc, rep)		; rename file and cabs
	lnk_att (lnk)				; attach files
	reply sts				;
  end

code	tmp_res - restore temps

  func	tmp_res
	src : * char
	dst : * char
  is
  end

code	tmp_prg - purge temp

;	Routine disabled because it deletes renamed files
;	Needs to be debugged 
;	Delete temp if it's the last reference

  func	tmp_prg
	cab : * cabTcab
  is	lnk : * cabTcab
	fine if !(cab->Vflg & cabTMP_)
	lnk = lnk_map (cab->Atmp)
	fine if !lnk
	fine if lnk->Plnk
	fi_del (cab->Atmp, <>)
	fine
  end
code	tmp_ten - create a tentative filename

;	"myfile.typ" => "myfile_typ(n).ten" (or ".ren")

  proc	tmp_ten
	spc : * char			; input
	typ : * char			; ".ten" or ".ren"
	ten : * char			; output
  is	tmp_spc (spc, 0, typ, ten)	; tentative spec
  end

code	tmp_spc - create temporary file spec

;	"myfile(1).typ"

  func	tmp_spc
	spc : * char
	ver : int
	typ : * char
	res : * char
  is	tmp : [mxSPC] char
	ptr : * char

	repeat
	   st_cop (spc, tmp)		; get a copy
	   ptr = st_fnd (".", tmp)	;
	   *ptr = '_' if ptr		; replace it
	   ptr = st_end (tmp)		;
	   FMT(ptr, "(%d)", ver) if ver ; make version number
	   st_app (typ, tmp)		;
	   ++ver			; for next time
PUT("[%s]\n", tmp) if dbg$c
	   next if tmp_exs (tmp)	; already in use
	   quit if !fi_exs (tmp, <>)	; not hanging tentative
	   quit if fi_del (tmp, <>)	; deleted
	end				; try once again
	st_cop (tmp, res)		; replace it
	fine
  end

code	tmp_exs - check temp file name in use

  func	tmp_exs
	spc : * char
  is	cab : * cabTcab
	seq : int = -1
	while ++seq lt cabVseq			; more in list
	   cab = cabAcab[seq]			; get next cab
	   next if !cab || !cab->Vtyp		; not in use
	   fine if st_sam (spc, cab->Atmp)	; same spec?
	end					;
	fail
  end
code	tmp_hng - cleanup hanging temp files
include	rid:htdef

;	On the first access to a directory only
;	Remember the directory in hash table (to check first-access)
;	Delete hanging .TEN/.DEL/.REN files more than two days old

	DAY(x) := ((x.Vyea*366)+(x.Vmon*32)+x.Vday)

	tmp_zap : (*char, *char)
	tmpVday : int = 0			; day-of-year * year
	tmpVonc : int = 0

  func	tmp_hng
	spc : * char
  is	pth : [mxSPC] char
	ptr : * char
	pst : * char = <>
	val : tiTval
	plx : tiTplx
	if !tmpVonc		; once-only
	   tmpVonc = 1		;
	   ti_clk (&val)
	   ti_plx (&val, &plx)	;
	.. tmpVday = DAY(plx) - 2

	st_cop (spc, pth)	; edit directory path
	ptr = st_end (pth)
	while ptr ne pth
	   if ptr[-1] eq '\\'
	   || ptr[-1] eq ':'
	      pst = ptr
	   .. quit
	   ptr--
	end
	fail if pst eq		; no ':' or '\' found
	fine if ht_fnd (pth)	; path already cleaned up
	ht_ins (pth)		; once-only
	tmp_zap (pth, "*.del")	; hanging .DELetes
	tmp_zap (pth, "*.ren")	; hanging .RENames
	tmp_zap (pth, "*.ten")	; hanging .TENtatives
  end

  func	tmp_zap
	pth : * char
	typ : * char
  is	spc : [mxSPC] char
	dir : * drTdir
	ent : * drTent
	plx : tiTplx 
	st_cop (pth, spc)
	st_app (typ, spc)
	dir = dr_scn (spc, drNOR_,drNAM); scan the directory
	pass fail			; no such directory
	while (ent = dr_nxt (dir)) ne	;		
	   ti_plx (&ent->Itim, &plx)	;
	   next if DAY(plx) ge tmpVday	; too recent
	   st_cop (pth, spc)		;
	   st_app (ent->Pnam, spc)	;
	   fi_del (spc, <>)		; report no errors
	end
	fine
  end
code	lnk_map - link cabs with same name

  func	lnk_map
	spc : * char
	()  : * cabTcab
  is	lnk : * cabTcab = <>
	cab : * cabTcab
	seq : int = -1
	while ++seq lt cabVseq			; more in list
	   cab = cabAcab[seq]			; get next cab
	   next if !cab || !cab->Vtyp		; not in use
	   next if !st_sam (spc, cab->Atmp)	; same spec?
	   cab->Plnk = lnk, lnk = cab		; create chain
	   cab->Vflg |= cabATT_ if cab->Pfil	;
	   cab->Vflg &= ~(cabATT_) otherwise	;
	end					;
	reply lnk
  end

code	lnk_ren - rename files

  func	lnk_ren
	cab : * cabTcab
	spc : * char
	rep : * char
  is	fi_ren (spc, rep, <>)
	pass fail
	while cab
	   st_cop (rep, cab->Atmp)
	   cab->Vflg |= cabTMP_
	   cab = cab->Plnk
	end
	fine
  end

code	lnk_res - move names back

  func	lnk_res
	cab : * cabTcab
	spc : * char
  is	while cab
	   st_cop (spc, cab->Atmp)
	   cab->Vflg &= ~(cabTMP_)
	   cab = cab->Plnk
	end
  end


code	lnk_det - detach files

  func	lnk_det
	cab : * cabTcab
  is	while cab
	   if cab->Vflg & cabATT_
	   .. cab_det (cab)
	   cab = cab->Plnk
	end
  end

code	lnk_att - attach files

  func	lnk_att
	cab : * cabTcab
  is	while cab
	   if cab->Vflg & cabATT_
	   .. cab_att (cab)
	   cab = cab->Plnk
	end
  end
code	cab_rpt - report cabs

;	Write CAB information to file

  proc	cab_rpt
  is	cab : * cabTcab
	seq : int = -1
	PUT("\nFiles:\n")
	while ++seq lt cabVseq			; more in list
	   cab = cabAcab[seq]			; get next cab
	   next if !cab || !cab->Vtyp		; not in use
	   PUT("cid=%x ", cab->Vcid)
	   PUT("nod=%d ", cab->Vnod) if cab->Vnod
	   PUT("prc=%d ", cab->Vprc) if cab->Vprc
	   PUT("chn=%d ", cab->Vchn) if cab->Vchn
	   PUT("spc=[%s] ", cab->Aspc)		;
;	   if !st_sam (cab->Aspc, cab->Atmp)	;
;	   .. PUT("tmp=[%s] ", cab->Atmp)	;
	   PUT("Open ") if cab->Pfil		;
	   PUT("Vol ") if cab->Pvol		;
	   PUT("Ver=%d ", cab->Vver) if cab->Vver

	   PUT("typ=")
;	   PUT("Loo ") if cab->Vtyp eq cabLOO
	   PUT("Ent ") if cab->Vtyp eq cabENT
	   PUT("Rep ") if cab->Vtyp eq cabREP
	   PUT("Dev ") if cab->Vtyp eq cabDEV
	   PUT("Wlk ") if cab->Vtyp eq cabWLK
	   PUT(" flg=") if cab->Vflg
	   PUT("Ron ") if cab->Vflg & cabRON_
	   PUT("Vax ") if cab->Vflg & cabVAX_
	   PUT("Rta ") if cab->Vflg & cabRTA_
	   PUT("Dir ") if cab->Vflg & cabDIR_
	   PUT("Dsk ") if cab->Vflg & cabDSK_
	   PUT("Per ") if cab->Vflg & cabPER_
	   PUT("Tmp ") if cab->Vflg & cabTMP_
	   PUT("Att ") if cab->Vflg & cabATT_
	   PUT("fil=0") if cab->Pfil eq
	   PUT("\n")
	end	
  end
end file
code	cab_ver - add version number to file spec

;	RT-11 permits new versions of an existing file to
;	be created while the file is open. Windows does not.
;
;	The solution is to identify conflicting files, close
;	them, rename them and then reopen them.
;
;	This operation applies to existing files and new files.
;
;	File specs must be normalised for the comparison

  func	cab_ver
	cab : * cabTcab
  is	can : * cabTcab
	spc : [mxSPC] char
	ptr : * char
	seq : int = 0
	ver : int = 1 
	ren : int = 0
	rty : int = 8				; eight retries

	fine if !cab
	while ++seq lt cabVseq			;
	   can = cabAcab[seq]			;
	   next if !can				;
	   next if can eq cab			;
	   next if !st_sam (cab->Aspc,can->Aspc);
	   cab_det (can)			; close it
	   if ren				; already did the rename
	      st_cop (spc, can->Aspc)		; give it a new spec
	      cab_att (cab)			; reattach it
	   .. next				;

	   repeat				; find new version number
;	make new spec
	      next if cab_fnd (spc)		; already have this
	      if fi_exs (spc, <>)		; if it's hanging about
	      && !fi_del (spc, <>)		; and can't delete it
	      .. next				; try next version number
	      fi_ren (cab->Aspc, can->Aspc, <>)	; rename it
	      quit ++ren if fine		; rename worked
	      next if rty--			; still got retries
	      fail				; something is screwy
	   end
	   cab_att (cab)			;
	end
  end

;???	cab->Atmp
  func	cab_fnd
	spc : * char
	()  : * cabTcab
  is	cab : * cabTcab
	seq : int = -1
	while ++seq lt cabVseq
	   cab = cabAcab[seq]
	   next if !cab
	   if st_sam (spc, cab->Aspc)
	   .. reply cab
	end
	fail
  end

code	cab_did - diddle cab with same file spec

  proc	cab_did
	src : * cabTcab
  is	tar : * cabTcab
	seq : int = -1
	while ++seq lt cabVseq
	   tar = cabAcab[seq]
	   next if !tar->Pfil		; ain't no chickens here
	   next if src eq tar		; don't diddle ourself
	   next if tar->Vtyp ne cabLOO	; not a lookup
	   next if !st_sam (src->Aspc, tar->Aspc) ; some other chicken
	   exit cab_prg (tar, cabNRS)	; it's gone (driver file lost too)
	end
  end

--------------------
code	tmp_gen - create cab tmp spec

;	For lookup the tmp spec is initially the name as the file spec
;	The spec is versioned off if:
;
;	(1) The file is deleted.
;	(2) The file is renamed.
;	(3) A new file with the same spec is closed.
;
;	For enter a unique tentative file spec is generated
;	This is never modified

  func	tmp_gen
	cab : * cabTcab			;
	spc : * char			;
	typ : * char			; ".ten" or ".ren"
  is	ptr : * char			;
	ver : int = 0			;
					;
	st_cop (cab->Aspc, spc)		; assume lookup/delete etc
	if !ver && (cab->Vflg & cabTMP_);
	.. ver = cab->Vver		;
	fine if !ver
	cab->Vflg |= cabVER_		; spec has version #
	fine
  end

  func	cab_ren
	src : * char
	dst : * char
  is	lnk : * cabTcab = <>
	tmp : [mxSPC] char	
	bak : int = 0

      begin
	if fi_exs (dst, <>)		; target exists
	   tmp_rem (<>, dst, <>, &lnk)	; remap destination references
	   ;tmp_ten (dst, ".ren", tmp)	; get a temp file name
           ;fi_del (tmp, <>)		; delete any previous of temp
	   ;fi_ren (dst, tmp, <>)	; rename target to temp
	   quit if fail			; can't create temp
	.. ++bak			; we have a backup
	tmp_rem (<>, src, <>)		; remap source references
	fi_ren (src, dst, "")		; do actual rename
	quit if fail			; oops
	fi_del (tmp, <>) if bak		; delete backup 
	fine				;
      end block
	if bak && tmp_res (tmp, dst)	; move them back
	.. fi_del (tmp, <>)		; delete temp
	fail
  end
