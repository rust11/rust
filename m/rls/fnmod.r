file	fnmod - new font module
include	rid:wimod
include	rid:stdef
include	rid:medef
include	rid:fndef
;nclude	rid:dbdef
;nclude	rid:imdef

code	fn_col - make a collection

  func	fn_col
	()  : * fnTcol
  is	reply me_acc (#fnTcol)		; make a collection
  end

code	fn_reg - register a font size

  func	fn_reg
	col : * fnTcol
	ord : int
	hgt : int
	wid : int
	()  : bool
  is	siz : * fnTsiz
	ptr : ** fnTsiz = &col->Psiz
	while *ptr
	   siz = *ptr
	   fine if siz->Vsiz eq ord
	   quit if siz->Vsiz lt ord
	   ptr = &siz->Psuc
	end
	siz = me_acc (#fnTsiz)
	siz->Vsiz = ord
	siz->Vhgt = hgt
	siz->Vwid = wid
	siz->Psuc = *ptr
	*ptr = siz
	fine	
  end

code	fn_siz - get the dimensions of a font

  func	fn_siz
	col : * fnTcol
	ord : int
	()  : * fnTsiz
  is	siz : * fnTsiz = col->Psiz
	while siz
	   reply siz if siz->Vsiz eq ord
	   siz = siz->Psuc
	end
	fail
  end
code	fn_grp - register a font group

;	A group consists of a name and a size

  func	fn_grp
	col : * fnTcol
	nam : * char
	siz : int
	()  : * fnTgrp
  is	idx : int = 0
	ptr : ** fnTgrp = &col->Pgrp
	grp : * fnTgrp
	while *ptr
	   grp = *ptr
	   if st_sam (nam, grp->Pnam)
	   && siz eq grp->Vsiz
	   .. reply grp
	   ptr = &grp->Psuc
	end
	grp = me_acc (#fnTgrp)
	*ptr = grp
	grp->Pcol = col
	grp->Pnam = st_dup (nam)
	grp->Vsiz = siz
	reply grp
  end

code	fn_map - map and select a font

  proc	fn_clr
	col : * fnTcol
  is	col->Pcur = 0
  end

  func	fn_map
	dev : * void
	grp : * fnTgrp
	ren : int
	()  : bool
  is	col : * fnTcol = grp->Pcol
	idx : int = (ren >> 5) & 7
	fnt : * fnTfnt = grp->Aren[idx]
	fine col->Pcur = 0 if grp eq
	if fnt eq
	   fnt = grp->Aren[idx] = fn_fnt (dev, grp, ren)
	   fnt->Vren = ren
	else
	.. fine if fnt eq col->Pcur
	reply fn_sel (dev, fnt)
  end
code	fn_fnt - setup a font

  func	fn_fnt
	dev : * void
	grp : * fnTgrp
	ren : int
	()  : * fnTfnt
  is	col : * fnTcol = grp->Pcol
	log : LOGFONT = {0}
	met : TEXTMETRIC
	fnt : * fnTfnt = fn_alc ()
	old : * void
	nam : [32] char
	siz : * fnTsiz = fn_siz (col, grp->Vsiz)
	dev = fnt->Hdev if !dev
	log.lfHeight = siz->Vhgt
	log.lfWidth = siz->Vwid
;	log.lfWeight = 700 if ren & fnBOL_
;	log.lfUnderline = 1 if ren & fnUND_
;	log.lfItalic = 1 if ren & fnITA_
	st_fit (grp->Pnam, log.lfFaceName, #log.lfFaceName)
	fail if (fnt->Hfnt = CreateFontIndirect (&log)) eq
	old = SelectObject (dev, fnt->Hfnt)
	GetTextMetrics (dev, &met)
	fnt->Vver = met.tmHeight
	fnt->Vasc = met.tmAscent
	fnt->Vdes = met.tmDescent
	fnt->Vhor = met.tmMaxCharWidth
	fnt->Vren = ren
;	SelectObject (dev, old)
	reply fnt
  end

  func	fn_sel
	dev : * void
	fnt : * fnTfnt
	()  : bool
  is	dev = fnt->Hdev if !dev
	SelectObject (dev, fnt->Hfnt)
	reply that ne
  end

  func	fn_alc
	()  : * fnTfnt
  is	fnt : * fnTfnt = me_acc (#fnTfnt)
	rec : RECT = {0}
	fnt->Hdev = CreateEnhMetaFile (<>,<>,&rec,<>)
	reply fnt if fnt->Hdev
	fail me_dlc (fnt)
  end

  proc	fn_dlc
	fnt : * fnTfnt
  is;	fn_rel (fnt)
	DeleteEnhMetaFile (fnt->Hdev)
	me_dlc (fnt)
  end
