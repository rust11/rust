file	git - git front-end
include rid:rider
include rid:dcdef
include rid:fidef
include rid:mxdef
include rid:prdef
include rid:stdef

	_git := "\"c:\\program files\\git\\bin\\git.exe\""

	cuAspc : [mxSPC] char

	cm_add : (*dcTdcl)
	cm_cmt : (*dcTdcl)
	cm_dif : (*dcTdcl)
	cm_pul : (*dcTdcl)
	cm_psh : (*dcTdcl)
	cm_sts : (*dcTdcl)

	cu_spc : (*char, *char, *char)
	cu_cmd : (*char)

  init	cuAdcl : [] dcTitm
 ;level keyword		task	P1	  V1  	type|flags
  is
     1,	"EX*IT",	dc_exi, <>,	   0, 	dcEOL_
;    1,	"HE*LP",	dc_hlp, cuAhlp,	   0, 	dcEOL_
  
     1,	"AD*D",		dc_act, <>,	   0,	dcNST_
      2,  <>,		dc_fld, cuAspc,  32,	dcSPC
      2,  <>,		cm_add, <>, 	   0, 	dcEOL_

     1,	"CO*MMIT",	cm_cmt, <>,	   0, 	dcEOL_

     1,	"DI*FF",	dc_act, <>,	   0,	dcNST_
      2,  <>,		dc_fld, cuAspc,  32,	dcSPC
      2,  <>,		cm_dif, <>, 	   0, 	dcEOL_

     1,	"PUL*L",	cm_pul, <>,	   0, 	dcEOL_
     1,	"PUS*H",	cm_psh, <>,	   0, 	dcEOL_
     1,	"ST*ATUS",	cm_sts, <>,	   0, 	dcEOL_
     0,	 <>,		<>,	<>,	   0, 	0
  end

code	git front-end

  func	start
  is	dcl : * dcTdcl
	dcl = dc_alc ()		; allocate DCL control block
	dcl->Venv = dcCLI_|dcCLS_	; DCL as CLI and single line command 
	dc_eng (dcl, cuAdcl, "GIT> ")	; DCL does all command processing
  end

  func	cm_add
 	dcl : * dcTdcl
  is	cmd : [mxLIN] char
	cu_spc ("add", cuAspc, cmd)
	cu_cmd (cmd)
	fine
  end

  func	cm_cmt
 	dcl : * dcTdcl
  is	cu_cmd ("commit")
	fine
  end

  func	cm_dif
 	dcl : * dcTdcl
  is	cmd : [mxLIN] char
	cu_spc ("diff", cuAspc, cmd)
	cu_cmd (cmd)
	fine
  end

  func	cm_pul
 	dcl : * dcTdcl
  is	cu_cmd ("pull")
  end

  func	cm_psh
 	dcl : * dcTdcl
  is	cu_cmd ("push")
  end

  func	cm_sts
 	dcl : * dcTdcl
  is	cu_cmd ("status")
	fine
  end

code	cu_spc - add file spec to command

  func	cu_spc
	kwd : * char		; keyword
	spc : * char		; filespec
	cmd : * char		; result command
  is	st_cop (kwd, cmd)
	st_app (" ", cmd)
;	fi_def ()
	fi_loc (spc, st_end(cmd)); localize spec
  end

code	cu_cmd - execute git command

  func	cu_cmd
	str : * char
  is	cmd : [mxLIN] char
	st_cop (_git, cmd)
	st_app (" ", cmd)
	st_app (str, cmd)
PUT("[%s]\n", cmd)
	pr_cmd (cmd)		; execute command
  end

