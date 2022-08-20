file	extyp - expat xxdp commands
include rid:rider	; rider
include	rid:cldef	; command line
include rid:fidef	; files
include rid:medef	; memory
include rid:mxdef	; maxima
include rid:stdef	; strings
include	rid:vfdef	; virtual files
include	exb:exmod	; expat

	cu_dsc : (*char, *char)- int
	cu_idx : ()-
	cuAfnd : [mxLIN] char-

  type	cuTxdp
  is;	Hidx : * FILE		; index file handle
;	Vxnf : int		; index not found dflag
	Afnd : [mxLIN] char	; search string
  end

	cuVlin : int-
	xdp : cuTxdp = {0}

	DIS(fmt,str) 	  := fprintf (opt,fmt,str) ; display value
	DS2(fmt,s1,s2)    := fprintf (opt,fmt,s1,s2)
	DS3(fmt,s1,s2,s3) := fprintf (opt,fmt,s1,s2,s3)
	TYP(fmt)     	  := fprintf (opt,fmt)     ; type string
	LIN	     	  := TYP("\n")	      	   ; newline	
code	cm_xdp - XXDP directory

  func	cm_xdp
	src : * vfTobj
	ent : * vfTent~
  is	opt : * FILE~ = ctl.Hopt
 	fmt : [mxSPC+3] char		; formatted spec
	dsc : [mxLIN] char		;
	fnd : * char = xdp.Afnd		;

	if !cu_dsc (ent->Anam, dsc)	; get the description
	.. fine if *fnd ;&& !dsc[0]	; doesn't match
					;
	cu_pag ()			; /page
	cu_f63 (ent->Anam, fmt)		;
	DIS("  %s  ", fmt)		; display file name
					;
	if dsc[0]			; got a description
	   TYP(" ") if dsc[0] ne '*'	;
	.. DIS("%s", dsc)		;
	LIN
	fine
  end

code	cu_dsc - get an XXDP image description

  func	cu_dsc
	str : * char
	dsc : * char
  is	fnd : * char = xdp.Afnd
	mod : [mxLIN] char
	lin : [mxLIN] char
	ptr : * char
	len : int

	st_cop (str, mod)
	st_upr (mod)
	mod[4] = 0
	*dsc = 0

	fail if !cu_idx ()		; open index file
	fi_see (ctl.Hidx, 0L)		; rewind the index

	repeat
	   len = fi_get (ctl.Hidx, lin, mxLIN-1)
	   fail if eq EOF
	   next if len lt 10
	   quit if me_cmp (mod, lin, 4)
	end

	ptr = st_fnd (" ", lin)
	fail if eq
	st_cop (ptr+1, dsc)

	fine if !*fnd
	reply st_wld (fnd, dsc)
  end

code	cu_idx - open XINDEX.TXT

  func	cu_idx
  is	spc : [mxSPC] char		;
	reply ctl.Vidx if ctl.Vidx	; 1=>open, -1=>missing
	cl_dir (spc)			; get image device spec
	st_app ("xindex.txt", spc)	; "dev:xindex.txt"
	ctl.Hidx = fi_opn (spc, "r", ""); open
	fine ++ctl.Vidx if ne
	fail --ctl.Vidx			; index not found flag
  end
end file
  func	cm_xdp
	dcl : * dcTdcl
  is	fnd : * char~ = xdp.Afnd

	*fnd = 0			; assume not searching
	if ctl.Asch[0]			; doing a search
	   st_cop (ctl.Asch, fnd)	; "xxx"  - get a copy
	   st_upr (fnd)			; "XXX"  - upper case model
	   st_ins ("*", fnd)		; "*XXX" - wildcard the model
	   st_app ("*", fnd)		; "*XXX*
	end				;
					;
	cx_dis (dcl, &cf_xdp)		; do the files
  end
code	cu_idx - index xindex

  type	cuTidx
  is	Anam : [6] char
  end

  func	cu_idx
  is	lin : [mxLIN] char
	ent : * cuTidx
	cnt : int
	blk : int = 1

	fine if ctl.Pidx ne
	fail if !cu_idx ()

	cnt = (fi_len (ctl.Hidx)/512L) + 1
	ent = me_acc (cnt * #cuTidx)

      while blk lt cnt
	fi_see (ctl.Hidx, blk*512L, "")
	fi_get (fil, lin, mxLIN)
	fi_get (fil, lin, mxLIN)
	st_cop ("      ", ent->Anam)
	spc = st_fnd (" ", lin)
	spc = 6 if spc gt 6
	me_mov (lin, ent->Anam, 6)
	++ent, ++blk
      end
	*ent = 0
  end

code	cu_fnd - find entry in index

  func	cu_fnd
	nam : * char
	dsc : * char
	()  : * char
  is	idx : * cuTidx = ctl.Pidx
	blk : int = 0
	fail if !idx
	repeat
	   fail if !idx->Aent[0]
           st_cmp (nam, ent->Anam)
	   quit if lt
	   ++idx, ++blk
	end
	fi_see (ctl.Hidx, blk*512L)
	fi_get (fil, lin, mxLIN)
      repeat
	fi_get (fil, lin, mxLIN)
	st_cop ("      ", nam)
	spc = st_fnd (" ", lin)
	spc = 6 if spc gt 6
	me_mov (lin, ent->Anam, 6)
	st_cmp (mod, nam)

	++ent, ++blk
      end
code	cu_fnd - find XXDP diagnostics

	idx : * FILE = <>

  func	cu_fnd
	str : * char
	dsc : * char
  is	mod : [mxLIN] char
	lin : [mxLIN] char
	spc : [mxSPC] char
	ptr : * char
	len : int

	fail if !cu_idx ()

	st_cop (str, mod)
	st_upr (mod)
	st_ins ("*", mod)
	st_app ("*", mod)

	fi_see (idx, 0L)
	repeat
	   len = fi_get (idx, lin, mxLIN-1)
	   fail if len eq EOF

	   next if len lt 15
	   ptr = st_fnd (" ", lin)
	   next if eq
	   ++ptr
	   next if !me_cmp (mod, ptr, 4)
	end
	   ptr = st_fnd (" ", ptr)
	   fail if eq
	   st_cop (ptr, dsc)
	   fine
  end
