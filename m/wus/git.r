file	git - git front-end
include rid:rider
include rid:dcdef
include rid:drdef
include rid:fidef
include rid:imdef
include rid:mxdef
include rid:prdef
include rid:stdef

;	WUB:GIT.EXE is a front-end to the standard GIT utility.
;
;	o Maps the GIT directory path as the default directory
;	o Translates logical names to explicit paths for GIT
;	o Elides redundant GIT output
;
;	Later:
;
;	o Synchronizes my source tree with the GIT source tree
;	o Automates repetitive GIT tasks
	

	_win := "c:\\f\\"	; windows directory root
	_git := "c:\\f\\git"	; git directory root
	_exe := "\"c:\\program files\\git\\bin\\git.exe\""
	_log := "c:\\tmp\\git.log"

	cuAstr : [mxLIN] char	; command string
	cuAspc : [mxSPC] char	; command file spec

	cm_add : (*dcTdcl)
	cm_cmt : (*dcTdcl)
	cm_dif : (*dcTdcl)
	cm_hlp : (*dcTdcl)
	cm_pul : (*dcTdcl)
	cm_psh : (*dcTdcl)
	cm_sts : (*dcTdcl)

	cu_spc : (*char, *char, *char)
	cu_cmd : (*char)
	cu_flt : ()

  init	cuAdcl : [] dcTitm
 ;level keyword		task	P1	  V1  	type|flags
  is
     1,	"EX*IT",	dc_exi, <>,	   0, 	dcEOL_
  
     1,	"AD*D",		dc_act, <>,	   0,	dcNST_
      2,  <>,		dc_fld, cuAspc,   32,	dcSPC
      2,  <>,		cm_add, <>, 	   0, 	dcEOL_

     1,	"CO*MMIT",	cm_cmt, <>,	   0, 	dcEOL_

     1,	"DI*FF",	dc_act, <>,	   0,	dcNST_
      2,  <>,		dc_fld, cuAspc,   32,	dcSPC
      2,  <>,		cm_dif, <>, 	   0, 	dcEOL_

     1,	"HE*LP",	dc_act, <>,	   0, 	dcNST_
      2,  <>,		dc_fld, cuAstr,   32,	dcSTR|dcOPT_
      2,  <>,		cm_hlp, <>, 	   0, 	dcEOL_

     1,	"PUL*L",	cm_pul, <>,	   0, 	dcEOL_
     1,	"PUS*H",	cm_psh, <>,	   0, 	dcEOL_
     1,	"ST*ATUS",	cm_sts, <>,	   0, 	dcEOL_
     0,	 <>,		<>,	<>,	   0, 	0
  end
code	git front-end

  func	start
  is	dcl : * dcTdcl
	im_ini ("GIT")
	dcl = dc_alc ()			; allocate DCL control block
	dcl->Venv = dcCLI_|dcCLS_	; DCL as CLI and single line command 
	dc_eng (dcl, cuAdcl, "GIT> ")	; DCL does all command processing
  end

code	git add <file>

  func	cm_add
 	dcl : * dcTdcl
  is	cmd : [mxLIN] char
	cu_spc ("add", cuAspc, cmd)
	cu_cmd (cmd)
	fine
  end

code	git commit

  func	cm_cmt
 	dcl : * dcTdcl
  is	cu_cmd ("commit -m update")
	fine
  end

code	git diff <file>

  func	cm_dif
 	dcl : * dcTdcl
  is	cmd : [mxLIN] char
	cu_spc ("diff", cuAspc, cmd)
	cu_cmd (cmd)
	fine
  end

code	git help

  func	cm_hlp
 	dcl : * dcTdcl
  is	cmd : [mxLIN] char
	st_cop ("help ", cmd)
	st_app (cuAstr, cmd)
	cu_cmd (cmd)
  end

code	git pull

  func	cm_pul
 	dcl : * dcTdcl
  is	cu_cmd ("pull")
  end

code	git push 

  func	cm_psh
 	dcl : * dcTdcl
  is	cu_cmd ("push")
  end

code	git status

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
  is	loc : [mxSPC] char	; localized spec

	st_cop (kwd, cmd)	; "keyword"
	st_app (" ", cmd)	; "keyword "

;	fi_def (spc, "DK:", loc); default the directory path
	fi_loc (spc, loc)	; localize spec
;PUT("loc=[%s]\n", loc)	;
	if st_scn (_win, loc)	; scan the directory root
	.. st_del (loc, st_len(_win)) ; elide git directory root
	st_app (loc, cmd)	; "keyword spec"
;PUT("cmd=[%s]\n", cmd)	;
  end

code	cu_cmd - execute git command

  func	cu_cmd
	str : * char
  is	cmd : [mxLIN] char

	st_cop (_exe, cmd)
	st_app (" ", cmd)
	st_app (str, cmd)

	st_app (" > ", cmd)
	st_app (_log, cmd)
	st_app ("\n", cmd)

	dr_set (_git, 0)	; make git current directory
	pr_cmd (cmd)		; execute command
	cu_flt ()		; filter output
  end

code	cu_flt - filter output

;	Filter redundant git output

  init	cuAflt : [] * char
  is	"  (use "
	"nothing added"
	<>
  end

  func	cu_flt 
  is	log : * FILE
	lin : [mxLIN] char
	flt : ** char
	log = fi_opn (_log, "r", "")
	pass fail

	while fi_get (log, lin, mxLIN) ge
	   next if !*lin		; skip empty lines
	   flt = cuAflt			; junk food
	   while *flt ne		; more guk
	      quit if st_scn (*flt, lin); same food
	      ++flt			; you are 
	   end				;  what you eat
	   next if *flt ne		; matched something
	   PUT("%s\n", lin)		; display output
	end
  end
