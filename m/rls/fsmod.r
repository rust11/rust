file	fsmod - filespec operations
include	rid:rider
include	rid:stdef
include	rid:drdef
include	rid:fsdef
include	rid:fidef
include	rid:medef

;	fnAbas	: [fsMAX] int extern

;	A class provides detailed information
;	A category reduces a class to INV, PER, DIR or FIL

  init	fsAcat : [fsMAX] int	; category to class
  is	fsINV:	fsINV		;
	fsUNK:	fsINV		; unknown is invalid
	fsPER:	fsPER		; peripheral
	fsNOD:	fsINV		; nodes are invalid
	fsDRV:	fsINV		; drives are invalid
	fsROO:	fsDIR		; root is a directory
	fsLAB:	fsINV		; labels are invalid
	fsDIR:	fsDIR		; subdirectory is a directory
	fsFAM:	fsINV		; wildcard directories are invalid
	fsFIL:	fsFIL		; files are files
	fsWLD:	fsFIL		; wildcard files are files
	fsMAX:			; check max
  end

  init	fsAcla : [fsMAX] *char	; class names
  is	fsINV:	"Inv"		;
	fsUNK:	"Unk"		; unknown is invalid
	fsPER:	"Per"		;
	fsNOD:	"Nod"		; nodes are invalid
	fsDRV:	"Drv"		; drives are invalid
	fsROO:	"Roo"		; root is a directory
	fsLAB:	"Lab"		; labels are invalid
	fsDIR:	"Dir"		; subdirectory is a directory
	fsFAM:	"Fam"		; wildcard directories are invalid
	fsFIL:	"Fil"		; files are files
	fsWLD:	"Wld"		; wildcard files are files
	fsMAX:			; check max
  end
code	fs_def - parse and default

  func	fs_def
	spc : * char			; the file spec
	def : * char			; <> = no default, "" = anything
	dst : * char			; result
	()  : int			; category
  is	fna : fnTfnb			;
	fnb : fnTfnb			;
	fn_def (&fna, &fnb, spc, def, dst)
	reply that
  end

code	fs_sen - sense device/directory/file

  func	fs_sen
	spc : * char
	dst : * char
  is	fnb : fnTfnb
	reply fn_sen (&fnb, spc, dst)
  end

code	fs_nor - normalize filename

  func	fs_nor
	src : * char
	dst : * char
  is	fnb : fnTfnb			; filename block
	fn_nor (&fnb, src, dst)		; normalize it
	fine				;
  end

code	fs_get - get part of a spec

  func	fs_get
	elm : int
	spc : * char
	dst : * char
  is	reply fs_set (elm, spc, <>, dst)
  end

code	fs_clr - clear part of a spec

  func	fs_clr
	elm : int
	spc : * char
	dst : * char
  is	reply fs_set (elm, spc, "", dst)
  end

code	fs_set - replace filespec element

  func	fs_set
	elm : int
	spc : * char
	rep : * char
	dst : * char
  is	fnb : fnTfnb
	src : * char
	len : int
	fn_exp (&fnb, spc)
	case elm
	of fsDEV src = fnb.Adev, len = mxDEV
	of fsDIR src = fnb.Adir, len = mxDIR
	of fsNAM src = fnb.Anam, len = mxNAM
	of fsTYP src = fnb.Atyp, len = mxTYP
	of fsVER src = fnb.Aver, len = mxVER
	end case
	if rep eq <>
	.. fine st_cop (src, dst)	; just a get
	st_cln (rep, src, len)		; overwrite it
	fn_imp (&fnb, dst)		; return it
  end

code	fs_ass - assemble parts

  func	fs_ass
	msk : int
	spc : * char
	dst : * char
  is	fnb : fnTfnb
	fn_exp (&fnb, spc)
	fnb.Adev[0] = 0 if !(msk & fsDEV_)
	fnb.Adir[0] = 0 if !(msk & fsDIR_)
	fnb.Anam[0] = 0 if !(msk & fsNAM_)
	fnb.Atyp[0] = 0 if !(msk & fsTYP_)
	fnb.Aver[0] = 0 if !(msk & fsVER_)
	fn_imp (&fnb, dst)		; return it
	fine
  end

code	fs_dev - get device name

  func	fs_dev
	spc : * char
	dst : * char
	()  : * char
  is	fnb : fnTfnb
	fn_exp (&fnb, spc)
	st_cop (fnb.Adev, dst)
	reply that
  end

code	fs_dir - get directory name

  func	fs_dir
	spc : * char
	dst : * char
	()  : * char
  is	fnb : fnTfnb
	fn_exp (&fnb, spc)		;
	st_cop (fnb.Adir, dst)		;
	if *st_lst (dst) eq '\\'	; last is \
	&& st_len (dst) ne 1		; and not root
	.. *st_lst (dst) = 0		;
	reply st_end (dst)		;
  end

code	fs_nam - get name

  func	fs_nam
	spc : * char
	dst : * char
	()  : * char
  is	fnb : fnTfnb
	fn_exp (&fnb, spc)
	st_cop (fnb.Anam, dst)
	reply that
  end

code	fs_typ - get file type

  func	fs_typ
	spc : * char
	dst : * char
	()  : * char
  is	fnb : fnTfnb
	typ : * char = fnb.Atyp
	fn_exp (&fnb, spc)
	++typ if *typ eq '.'
	st_cop (typ, dst)
	reply that
  end

code	fs_tdr - convert to directory

  proc	fs_tdr
	dir : * char
  is	if *st_lst (dir) ne '\\'
	.. st_app ("\\", dir)		; add one
  end

code	fs_fdr - convert from directory

  proc	fs_fdr
	dir : * char
  is	exit if *st_lst (dir) ne '\\'	; fine 
	exit if fs_roo (dir)		; is root spec
	*st_lst (dir) = 0		; remove \
  end

code	fs_res - construct result spec

;	One special case is handled:
;
;	src	spc	dst	res
;		abcd	?xy*	axyd	'*' only as last char of dst
;
;	After the first '*' in the destination spec:
;
;	o  The remainder of the actual spec field is copied to result
;	o  '*' is ignored
;	o  '?' causes an error to be flagged (nothing to match)
;	o  Other dest characters are copied
;
;	In the destination spec wildcard '*' may be followed only
;	by nothing or explicit characters.
;
;	valid:	abc*def	abc*	abc***def
;	bad:	abc*def*
;
;	Fails for invalid wildcards ('*' not at end of dst spec)

	fs_mix : (*char, *char, *char, *fnTfnb, int) int
If 0

  func	fs_res
	src : * char			; source wildcard spec
	ipt : * char			; actual input file spec
	dst : * char			; dest wildcard spec
	res : * char			; resultant spec
	flg : int			; unused
  is	fns : fnTfnb
	fni : fnTfnb
	fnd : fnTfnb
	fnr : fnTfnb = {0}
	fn_exp (&fns, src)		; expand them
	fn_exp (&fni, ipt)		;
	fn_exp (&fnd, dst)		; got default output
	me_cop (&fnd, &fnr, #fnTfnb)	; cheap default
	fail if !fs_mix (fni.Adev, fnd.Adev, fnr.Adev, &fnd, fsDEV_)
	fail if !fs_mix (fni.Adir, fnd.Adir, fnr.Adir, &fnd, fsDIR_)
	fail if !fs_mix (fni.Anam, fnd.Anam, fnr.Anam, &fnd, fsNAM_)
	fail if !fs_mix (fni.Atyp, fnd.Atyp, fnr.Atyp, &fnd, fsTYP_)
	fn_imp (&fnr, res)		;  end
 	fine				;
 end

  func	fs_mix
	ipt : * char			; actual input spec
	dst : * char			; dest spec
	res : * char			; result
	fnd : * fnTfnb			; destination block
	flg : int			; element flags
  is	if fnd->Vwld & flg		; straight wildcard
	.. fine st_cop (ipt, res)	;
	fine if !fnd->Vmix & flg	; not mixed flags
	while *dst ne '*'		; the pattern
	   *res = *ipt if *dst eq '?'	; copy input spec
	   *res = *dst otherwise	;
	   fine if !*dst		; finished pattern
	   ++dst, ++res			;
	   ++ipt if *ipt		;
	end				;
	res = st_cop (ipt, res)		; copy the rest
	while *dst			;
	   *res = 0			; keep it terminated
	   next ++dst if *dst eq '*'	; skip any of them
	   fail if *dst eq '?'		; that's invalid syntax
	   *res++ = *dst++		; copy anything else
	end
	fine				;
  end

End
code	fs_cat - get specification category

  func	fs_cat
	spc : * char
  is	reply fsAcat[fs_cla (spc)]	; convert to category
  end

code	fs_cla - get specification class

;	00	fine
;	02	no such file
;	03	no such path
;	12	no more files

  func	fs_cla
	spc : * char
	()  : int			; true if peripheral name
  is	loc : [mxLIN] char		; local version
	atr : int 			;
	sta : int			;
	cla : int			;
	wld : int			;
;	sta = ds_FndFst (&fnd,spc,0x16)	; find first
      repeat				; done block
	quit cla = fsROO if fs_roo (spc); this is the root directory
	sta = fi_gat (spc, &atr, <>)	; get the file attributes
	quit cla = fsUNK if !sta	; no such file
;;;	if sta eq 0x12			; no more files
;;;	   quit cla = fsROO if fs_roo (spc) ; is root directory
;;;	.. cla = fsFIL			; is filespec otherwise
;sic]	quit cla = fsUNK if sta eq 0x02	; no such file (dos 3.x???)
;;;	quit cla = fsUNK if sta ne	; no such file, no such path
	cla = fsFIL			; assume this
	quit cla = fsLAB if atr & drLAB_; label (not selected by 0x16)
	quit cla = fsPER if atr & drPER_; peripheral
	if atr & drDIR_			;
;	   cla = fsDIR, wld = fsFAM	;
	   cla = fsDIR, wld = fsWLD	; ambiguous
	else				;
	.. cla = fsFIL, wld = fsWLD	;
	if st_fnd ("*", spc)		; got *
	|| st_fnd ("?", spc)		; got ?
	.. cla = wld			;
     never				;
;   PUT("cla=%s sta=%04X [%s]\n", fsAcla[cla], sta, spc)
	reply cla			;
  end

code	fs_roo - check root specification

  func	fs_roo
	dir : * char
  is	fail if !*dir			; ""
	fine if st_sam (dir, "\\")	; "\"
	fine if st_sam (dir+1, ":\\")	; "d:\"
	fail				;
  end
code	fn_def - parse and default

;	copy a.a *.*
;	copy a.a b.*

  func	fn_def
	fna : * fnTfnb
	fnb : * fnTfnb
	spc : * char			; the file spec
	def : * char			; <> = no default, "" = anything
	dst : * char			; result
	()  : int			; category
  is	cla : int			;
	cla = fn_sen (fna, spc, dst)	; normalize and sense
	if cla eq fsPER			; is a peripheral
	elif def eq <>			; no defaults
	   reply fsINV if cla ne fsFIL	;
	elif *def ne			; got a default
	   fn_nor (fnb, def, <>)	; get the default spec
	   fn_mrg (fnb, fna)		; merge them
	   fn_imp (fna, dst)		; implode result
	.. cla = fn_sen (fna, dst, dst)	; resense it
	reply cla			; category
  end

code	fn_sen - sense spec type -- directory/file/device

  func	fn_sen
	fnb : * fnTfnb
	spc : * char
	dst : * char
  is	dir : * char
	cla : int			;
	fn_nor (fnb, spc, dst)		; normalize it
	cla = fs_cla (dst)		; get the class
	if cla eq fsPER			; its a peripheral
	   st_cop (fnb->Anam, dst)	; just the name
	.. reply fsPER			; and say so
	if (cla eq fsDIR		; its a directory
	|| cla eq fsFAM)		; or family of directories
	&& fnb->Anam[0] ne		; and is currently a name
	   fs_tdr (dst)			; make whole thing a directory
	.. fn_nor (fnb, dst, dst)	;
;	.. fs_fdr (fnb->Adir)		;
;	   dir = fnb->Adir		;
;	   fs_tdr (dir)			; force directory
;	   st_app (fnb->Anam, dir)	;
;	   st_app (fnb->Atyp, dir)	;
;	   fnb->Anam[0] = 0		;
;	   fnb->Atyp[0] = 0		;
;	.. fn_imp (fnb, dst)		; implode that
	reply cla			;
  end

code	fn_nor - normalize spec

  func	fn_nor
	fnb : * fnTfnb
	spc : * char
	dst : * char
  is	fn_exp (fnb, spc)		; get the fnb
	fn_red (fnb)			; reduce it
	fn_imp (fnb, dst) if dst	; get the intermediate form
  end
code	fn_exp - explode file spec

  type	fnTexp
  is	Vtag : int
	Actl : * char
	Aprg : * char
	Vmax : int
	Vmsk : int
	Pflt : * char		; wildcard filter
  end

  init	fnAexp : [] fnTexp
  is	fDEV:: fDEV, "pb", ":",  mxDEV, fsDEV_, "*:" 
	fDIR:: fDIR, "pb", "\\", mxDIR, fsDIR_, "*\\"
	fNAM:: fNAM, "le", ".",  mxNAM, fsNAM_, "*"
	fTYP:: fTYP, "pe", "Z",  mxTYP, fsTYP_, "*."
	fMAX:: fMAX, <>, <>, 0, 0     
  end

;	If no device has been specified, add the current device.
;	If no directory has been specified, add the current directory
;	only if the device was also blank, otherwise add the root.
;
;	Also sets wildcard flags for each element.
;	Vwld |= fsXXX_	if element consists only of "*"s
;	Vmix |= fsXXX_	if element has "?" or "*" otherwise

  func	fn_exp
	nam : * fnTfnb
	spc : * char
	()  : int
  is	src : [256] char
	buf : [256] char
	dst : * char
	elm : * char
	exp : * fnTexp = fnAexp
	sta : int = 1
	cur : int = 0			; is current device
	fi_loc (spc, src)		; translate the filespec
	me_clr (nam, #fnTfnb)		; clean it up
      while exp->Vtag ne fMAX		;
	dst = buf, *buf = 0		; default is none
	st_ext (exp->Actl,exp->Aprg,src,buf); extract element
;	fail if st_len(buf) gt exp->Vmax; too long
	case exp->Vtag			;
	of fDEV				; the device
	   elm = nam->Adev		;
	   quit if *dst			; got a device
	   dr_sho (dst, drDRV)		; get current drive
	   ++cur			; remember that
	of fDIR				; directory
	   elm = nam->Adir		;
	   if !*dst && cur		; none, and current drive
	   .. dr_sho (dst, drDIR) 	; get current drive
	   fs_tdr (dst)			; force final \
	   if st_sam (src, "..")	; . or .. follows
	   || st_sam (src, ".")		;
	      st_app (src, dst)		;
	      st_app ("\\", dst)	; add \
	   .. src[0] = 0		; all done
	of fNAM				;
	   buf[mxNAM] = 0		; truncate the name
	   elm = nam->Anam		;
	of fTYP				;
	   buf[mxTYP+1] = 0		; truncate the type
	   elm = nam->Atyp		;
	end case			;
	st_low (buf)			;
	st_cln (buf, elm, exp->Vmax)	; got it
	if st_fnd ("*", elm)		; setup wildcard flags
	   if !st_par ("-pn", exp->Pflt, elm) ; check only wildcards
	      nam->Vwld |= exp->Vmsk	; wildcard only
	   else				;
	   .. nam->Vmix |= exp->Vmsk	; mixed
	elif st_fnd ("?", elm)		;
	.. nam->Vmix |= exp->Vmsk	; wildchar is always mixed
	++exp				; next one
      end
	fine
  end
code	fn_red - reduce subdirectories

  func	fn_red
	nam : * fnTfnb
  is	buf : [128] char
	lft : * char
	rgt : * char
	st_cop (nam->Adir, buf)		; get a working copy
	spin while st_rep ("\\.\\", "\\", buf) ; junk self refs

	while (rgt = st_fnd ("\\..\\", buf)) ne
	   lft = rgt			; reduce ..
	   while lft gt buf		; got more
	   until *--lft eq '\\'		;
	   st_cop (rgt+3, lft)		; remove it
	end				;
	st_cop (buf, nam->Adir)		; copy back result
	fine
  end

code	fn_imp - implode name

  func	fn_imp
	nam : * fnTfnb
	spc : * char
	()  : * char
  is	st_cop (nam->Adev, spc)
	st_cop (nam->Adir, that)
	st_cop (nam->Anam, that)
	st_cop (nam->Atyp, that)
	reply that
  end

code	fn_mrg - merge file specs

	fn_rep	: (*char, *char) void own
  func	fn_mrg
	def : * fnTfnb
  	dst : * fnTfnb
  is	fn_rep (def->Adev, dst->Adev)
	fn_rep (def->Adir, dst->Adir)
	fn_rep (def->Anam, dst->Anam)
	fn_rep (def->Atyp, dst->Atyp)
	fine
  end

code	fn_rep - replace string

  proc	fn_rep
	def : * char
	dst : * char
  is	exit if *def eq			; nothing to replace with
	if *dst eq			; has nothing
	|| *dst eq '*' && dst[1] eq	; simple wildcard
	.. exit st_cop (def, dst)	; replace it all
;	complicated wildcards
  end
