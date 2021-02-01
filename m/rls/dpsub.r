file	dpsub - sub-directory control
include rid:rider
include rid:fsdef
include rid:dpdef
include rid:mxdef
include rid:stdef

code	dp_roo - extract directory components

;	Extract device and directory path from full specification
;	Fill in path spec, root path and current path fields

  func	dp_roo
	pth : * dpTpth~
	str : * char~
  is	cla : fsTcla~
	spc : * char = pth->Aspc
	ptr : * char

	st_cop (str, spc)		; for messages
	pth->Vtop = 1			; list top level files
	pth->Vsub = 0		; assume no sub-directories
	if st_rep ("\\*\\", "\\", spc)	;
	   --pth->Vtop			;
	.. ++pth->Vsub			;
	if st_rep ("\\\\", "\\", spc)	;
	.. ++pth->Vsub			;
					;
Str("xspc",spc)
	if (ptr = st_fnd (":\\", spc))	; :\
	&& !ptr[2]			; :\"
PUT("...")
	.. ptr[1] = 0			;
Str("xspc",spc)
					;
	st_cop ("DK:", spc) if !*spc	; default directory
	fs_ext (spc, pth->Aroo, fsPTH_)	; extract the path for scanning
	st_cop (pth->Aroo, pth->Apth)	; current path
Str("spc", spc)
Str("roo", pth->Aroo)

	fail if !dp_dev (pth, str)	; check device
	fs_cla (spc, &cla)		; get wildcard flags
	if (cla.Vwld & fsPTH_)		; device/directory wildcards
	.. fail im_rep ("E-Invalid wildcards %s", str)
	fine
  end

code	dp_psh - add sub-directory

  func	dp_psh
	pth : * dpTpth~
	nam : * char
  is	dir : * char~ = pth->Apth
	lst : * char = st_lst (dir)
	st_len (nam) + st_len (dir) + 2
	fail if that gt mxPTH

	st_app ("\\", dir) if *lst ne '\\'
	st_app (nam, dir)
	st_rep (".DSK", "", dir) 
	st_rep (".DIR", "", dir) 
	st_app ("\\", dir)
	fine
  end

code	dp_pop - pop sub-directory

  func	dp_pop
	pth : * dpTpth~
  is	lst : * char~ = st_lst (pth->Apth)
	fail if *lst ne '\\'
	repeat
	   fail if lst eq pth->Apth
	   next if *--lst ne '\\'
	   fine lst[1] = 0
	forever
  end
code	dp_sel - extract file name

  func	dp_sel
	flt : * dpTflt
	idx : int
	spc : * char~
  is	nam : * dpTnam = flt->Asel + idx
	reply fs_ext (spc, nam->Anam, fsNAM_|fsTYP_)
  end
