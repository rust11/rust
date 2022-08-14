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

  type	cuTctl
  is	Astr : [mxLIN] char	; command string
	Aspc : [mxLIN] char	; command file spec
	Qraw : int		; display raw output
	Qver : int		; verify commands

  end
	ctl : cuTctl = {0}

	cm_add : (*dcTdcl)
	cm_cmt : (*dcTdcl)
	cm_dif : (*dcTdcl)
	cm_hlp : (*dcTdcl)
	cm_pul : (*dcTdcl)
	cm_psh : (*dcTdcl)
	cm_rem : (*dcTdcl)
	cm_res : (*dcTdcl)
	cm_snd : (*dcTdcl)
	cm_sts : (*dcTdcl)
	cm_upd : (*dcTdcl)

	cu_cmd : (*char)
	cu_flt : ()
	cu_spc : (*char, *char, *char)
	cu_sub : (*char, *char)
	cu_upd : (*char)

  init	cuAgen : [] dcTitm
 ;level keyword		task	P1	  V1  	type|flags
  is
      2,  "/RA*W",	dc_set, &ctl.Qraw, 1,	0
      2,  "/VE*RIFY",	dc_set, &ctl.Qver, 1,	0
      2,  <>,		<>, <>, 	   0,	dcRET_
  end

  init	cuAdcl : [] dcTitm
 ;level keyword		task	P1	  V1  	type|flags
  is
     1,	"EX*IT",	dc_exi, <>,	   0, 	dcEOL_
  
     1,	"AD*D",		dc_act, <>,	   0,	dcNST_
      2,  <>,		dc_fld, ctl.Aspc,  32,	dcSPC
      2,  <>,		cm_add, <>, 	   0, 	dcEOL_
      2,  <>,		<>, 	cuAgen,	   0,	dcCAL_

     1,	"CO*MMIT",	cm_cmt, <>,	   0, 	dcEOL_
      2,  <>,		<>, 	cuAgen,	   0,	dcCAL_

     1,	"DI*FF",	dc_act, <>,	   0,	dcNST_
      2,  <>,		dc_fld, ctl.Aspc,  32,	dcSPC
      2,  <>,		cm_dif, <>, 	   0, 	dcEOL_
      2,  <>,		<>, 	cuAgen,	   0,	dcCAL_

     1,	"HE*LP",	dc_act, <>,	   0, 	dcNST_
      2,  <>,		dc_fld, ctl.Astr,  32,	dcSTR|dcOPT_
      2,  <>,		cm_hlp, <>, 	   0, 	dcEOL_
      2,  <>,		<>, 	cuAgen,	   0,	dcCAL_

     1,	"DI*FF",	dc_act, <>,	   0,	dcNST_
      2,  <>,		dc_fld, ctl.Aspc,  32,	dcSPC
      2,  <>,		cm_dif, <>, 	   0, 	dcEOL_
      2,  <>,		<>, 	cuAgen,	   0,	dcCAL_

     1,	"RE*MOVE",	dc_act, <>,	   0,	dcNST_
      2,  <>,		dc_fld, ctl.Aspc,  32,	dcSPC
      2,  <>,		cm_rem, <>, 	   0, 	dcEOL_
      2,  <>,		<>, 	cuAgen,	   0,	dcCAL_

     1,	"RE*STORE",	dc_act, <>,	   0,	dcNST_
      2,  <>,		dc_fld, ctl.Aspc,  32,	dcSPC
      2,  <>,		cm_res, <>, 	   0, 	dcEOL_
      2,  <>,		<>, 	cuAgen,	   0,	dcCAL_

     1,	"PUL*L",	cm_pul, <>,	   0, 	dcEOL_
      2,  <>,		<>, 	cuAgen,	   0,	dcCAL_
     1,	"PUS*H",	cm_psh, <>,	   0, 	dcEOL_
      2,  <>,		<>, 	cuAgen,	   0,	dcCAL_
     1,	"SE*ND",	cm_snd, <>,	   0, 	dcEOL_
      2,  <>,		<>, 	cuAgen,	   0,	dcCAL_
     1,	"ST*ATUS",	cm_sts, <>,	   0, 	dcNST_
      2,  <>,		<>, 	cuAgen,	   0,	dcCAL_

     1,	"UP*DATE",	dc_act, <>,	   0, 	dcNST_
      2,  <>,		<>, 	cuAgen,	   0,	dcCAL_
      2,  <>,		dc_fld, ctl.Aspc,  32,	dcSPC|dcOPT_
      2,  <>,		cm_upd, <>, 	   0, 	dcEOL_
      2,  <>,		<>, 	cuAgen,	   0,	dcCAL_

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
	cu_spc ("add", ctl.Aspc, cmd)
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
	cu_spc ("diff", ctl.Aspc, cmd)
	cu_cmd (cmd)
	fine
  end

code	git help

  func	cm_hlp
 	dcl : * dcTdcl
  is	cmd : [mxLIN] char
	st_cop ("help ", cmd)
	st_app (ctl.Astr, cmd)
	cu_cmd (cmd)
	fine
  end

code	cm_rem - remove file

  func	cm_rem
 	dcl : * dcTdcl
  is	cmd : [mxLIN] char
	cu_spc ("rm", ctl.Aspc, cmd)
	cu_cmd (cmd)
	fine
  end

code	cm_res - restore file

  func	cm_res
 	dcl : * dcTdcl
  is	cmd : [mxLIN] char
	cu_spc ("restore", ctl.Aspc, cmd)
	cu_cmd (cmd)
	fine
  end

code	git pull

  func	cm_pul
 	dcl : * dcTdcl
  is	cu_cmd ("pull")
	fine
  end

code	git push 

  func	cm_psh
 	dcl : * dcTdcl
  is	cu_cmd ("push")
	fine
  end

code	git send

;	Commit and push

  func	cm_snd
 	dcl : * dcTdcl
  is	cm_cmt (dcl)
	cm_psh (dcl)
	fine
  end

code	git status

  func	cm_sts
 	dcl : * dcTdcl
  is	cu_cmd ("status ")
	fine
  end

code	cm_upd - update <file>

;	Copy file to git tree

  func	cm_upd
	dcl : * dcTdcl
  is	cu_upd (ctl.Aspc)
	cm_add (dcl)
	fine
  end
code	cu_upd - update \git file

  func	cu_upd
	src : * char
  is	dst : [mxSPC] char
	fail if !fi_exs (src, ""); no such file
	st_cop (_git, dst)	; "c:\f\git\"
	cu_sub (src,st_end(dst)); "c:\f\git\<sub>\filnam.typ"
	pass fail		;
	st_low (src)		; lower case specs for git
	fi_cop (src, dst, "", 1); copy the file
	reply that
  end

code	cu_spc - add file spec to command

  func	cu_spc
	kwd : * char		; keyword
	spc : * char		; filespec
	cmd : * char		; result command
  is	loc : [mxSPC] char	; localized spec

	fail if !fi_exs (spc, ""); no such file
				;
	st_cop (kwd, cmd)	; "keyword"
	st_app (" ", cmd)	; "keyword "

;	fi_def (spc, "DK:", loc); default the directory path
	fi_loc (spc, loc)	; localize spec
	if st_scn (_win, loc)	; scan the directory root
	.. st_del (loc, st_len(_win)) ; elide git directory root
	st_app (loc, cmd)	; "keyword spec"
  end

code	cu_sub - extract common subdirectory

  func	cu_sub
	spc : * char
	sub : * char
  is	loc : [mxSPC] char
	fi_loc (spc, loc)		; localize spec
	fail if! st_scn (_win, loc)	; scan the directory root
	st_del (loc, st_len(_win)-1)   	; elide git directory root
	st_cop (loc, sub)
	fine
  end
code	cu_cmd - execute git command

  func	cu_cmd
	str : * char
  is	cmd : [mxLIN] char

	st_cop (_exe, cmd)	; "c:\\\git.exe" 
	st_app (" ", cmd)	; "c:\\\git.exe " 
	st_app (str, cmd)	; "c:\\\git.exe <cmd>" 
				;
	if !ctl.Qraw		; not /raw output
	   if !st_scn ("push", str)
	      st_app (" > ",cmd); "c:\\\git.exe <cmd> > " 
	   else			;
	   .. st_app (" 2> ",cmd); "c:\\\git.exe <cmd> > " 
	.. st_app (_log, cmd)	; "c:\\\git.exe <cmd> > tmp:a.a" 
	st_app ("\n", cmd)	;
				;
	dr_set (_git, 0)	; make git current directory
	PUT("%s",cmd) if ctl.Qver ; verify command
	pr_cmd (cmd)		; execute command as a process
	cu_flt ()		; filter output
  end

code	cu_flt - filter output

;	Filter redundant git output

  init	cuAflt : [] * char
  is	"  (use "
	"[master"
	"On branch"
	"Changes to"
	"nothing added"
	"file changed"
	"rewrite"
	"Your branch is"
	"Enumerating"
	"Delta"
	"Compressing"
	"Writing"
	"Total"
	"remote:"
	"To https:"
	"master ->"
	"Changes not"
;	"modified: "
	"no changes"
	<>
  end

  func	cu_flt 
  is	log : * FILE
	lin : [mxLIN] char
	flt : ** char

	fine if ctl.Qraw		; wanted it /raw
					;
	log = fi_opn (_log, "r", "")	; open log file
	pass fail			;
					;
	while fi_get (log,lin,mxLIN) ge	;
	   next if !*lin		; skip empty lines
	   flt = cuAflt			; junk food
	   while *flt ne		; more guk
	      quit if st_fnd (*flt, lin); same food
	      ++flt			; you are 
	   end				;  what you eat
	   next if *flt ne		; matched something
	   PUT("%s\n", lin)		; display output
	end
	fi_clo (log, "")			
  end
