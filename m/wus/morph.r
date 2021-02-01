file	morph - replace strings
include	rid:rider
include	rid:fidef
include rid:imdef
include	rid:medef
include	rid:mxdef
include	rid:stdef

;	%build
;	rider wus:morph/object:cub:morph
;	link cub:morph/exe:cub:/map:cub:,lib:crt/cross/bott=2000 
;	%end
;
;	A quick little app to replace strings in text files.
;	Compiles for Windows or RUST
;
;	morph control, source, destination
;
;	control file:
;
;	log
;	nolog
;	elide
;	xxx := yyy
;	...
;	end elide

  type	cuTnod
  is	Psuc : * cuTnod
	Plab : * char
	Pdef : * char
  end

  type	cuTctl 
  is	Pnod : * cuTnod
	Hdef : * FILE
	Hipt : * FILE
	Hopt : * FILE
	Aipt : [mxLIN] char
	Aopt : [mxLIN] char
	Vlog : int
	Veli : int
  end
	cu_def : (*cuTctl, *char)
	cu_rep : (*cuTctl, *char, *char)
	cu_ctl : (*cuTctl, *char)

  func	main
	cnt : int
	vec : **char
  is	ctl : * cuTctl = me_acc (#cuTctl)
	chg : int 
	im_ini ("MORPH")
	ctl->Vlog = 1

	++vec, --cnt
	if cnt ne 3
	   PUT("?MORPH-I-MORPH control-file in-file out-file\n")
	.. im_rep ("F-Invalid command", "") if cnt ne 3

	if (ctl->Hdef = fi_opn (vec[0], "r", "")) eq
	|| (ctl->Hipt = fi_opn (vec[1], "r", "")) eq
	|| (ctl->Hopt = fi_opn (vec[2], "w+", "")) eq
	.. fail

      while fi_get (ctl->Hdef, ctl->Aipt, mxLIN-1) ne EOF
	 next if cu_ctl (ctl, ctl->Aipt)
	 cu_def (ctl, ctl->Aipt)
      end

      while fi_get (ctl->Hipt, ctl->Aipt, mxLIN-1) ne EOF
	ctl->Aopt[0] = 0
	chg = cu_rep (ctl, ctl->Aipt, ctl->Aopt)
	PUT("[%s]\n", ctl->Aopt) if chg && ctl->Vlog
	if chg && !ctl->Veli
	.. fi_put (ctl->Hopt, ctl->Aopt) if st_len (ctl->Aopt)
      end
	fail if fi_err (ctl->Hipt, "E-Error processing input file [%s]")
	fail if fi_err (ctl->Hopt, "E-Error processing output file [%s]")
	fi_clo (ctl->Hopt, "")
	fine
  end

  func	cu_def
	ctl : * cuTctl
	src : * char
  is	nod : * cuTnod
	def : * char = st_fnd (" := ", src)
	fail if !def
	*def = 0			; terminate label
	def += 4			; length of " := "
	nod = me_acc (#cuTnod)
	nod->Plab = st_dup (src)
	nod->Pdef = st_dup (def)
	nod->Psuc = ctl->Pnod
	ctl->Pnod = nod
 	fine
  end

  func	cu_rep
	ctl : * cuTctl
	src : * char
	dst : * char
  is	nod : * cuTnod 
	scn : * char
	cnt : int = 0
	fnd : int
      while *src
	nod = ctl->Pnod
	fnd = 0
	while nod
	   if (scn = st_scn (nod->Plab, src)) eq
	   .. next nod = nod->Psuc
	   dst = st_cop (nod->Pdef, dst)
	   quit src = scn, ++fnd, ++cnt
	end
	*dst++ = *src++ if !fnd
      end
	*dst = 0
	reply cnt
  end

  func	cu_ctl
	ctl : * cuTctl
	lin : * char
  is	fine ctl->Veli = 1 if st_sam (lin, "elide")
	fine ctl->Veli = 0 if st_sam (lin, "end elide")
	fine ctl->Vlog = 1 if st_sam (lin, "log")
	fine ctl->Vlog = 0 if st_sam (lin, "nolog")
	fail
  end
