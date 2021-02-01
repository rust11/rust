rst_c := 1	; compile for RUST defaults
file	she - my sea shell
include	rid:rider
If Win
include	<time.h>
include	<stdio.h>
include	<stdlib.h>
End
include	rid:imdef
include	rid:stdef
include	rid:medef
include	rid:mxdef
include	rid:iodef
include	rid:osdef
include	rid:dfdef
include	rid:chdef
include	rid:cldef
include	rid:ctdef
include	rid:fidef
include	rid:codef

If Win
include	rid:abdef
include	rid:drdef
include	rid:evdef
include	rid:lndef
include	rid:prdef
include	rid:shdef
End

	sh_sin	: (*char) int
	shPshe : * shTshe = <>		

data	constants

	PUT	:= printf
	 shEXP	:= 1024			; expansion buffer size
	_shQUA	:= '/'			; qualifier
	_shCMT	:= '!'			; comment
	_shPRM	:= "o "			; prompt
If Vms
	_shCOM	:= <>			; local small executable -- none
	_shBAT	:= ".com"		; local command procedure
	_shRUN	:= "mcr "		; activate image
	_shSPC	:= "AD$_:[].;*%"	; filespec characters
	_shDEF	:= "sys$login:she.def"	; definition file
;???	_shSHO	:= "c:\\rub\\show.exe"	; show utility
;???	_shSPN	:= "c:\\rub\\she.exe"	; for spawns

Elif Dos || Win
	_shCOM	:= ".com"		; local small executable
	_shBAT	:= ".bat"		; local command procedure
	_shRUN	:= ""			; activate image
	_shSPC	:= "AD_:\\.*?`~"	; filespec characters
;	_shDEF	:= "c:\\ini\\she.def"	;	
;	_shSHO	:= "c:\\bin\\show.exe"	; show utility
;	_shSHE	:= "c:\\bin\\she.exe"	; for spawns
If rst_c
	_shROO  := "c:\\rust"		;
	_shDEF	:= "root:she.def"	;	
	_shSHO	:= "root:show.exe"	; show utility
	_shSPN	:= "root:she.exe"	; for spawns
Else
	_shDEF	:= "@INI@:she.def"	;	
	_shSHO	:= "@INI@:show.exe"	; show utility
	_shSPN	:= "@INI@:she.exe"	; for spawns
End
End

data	variables

	shVini	: int = 0		; init done
	shVprc	: int = 0		; in command procedure
	shVsin	: int = 0		; in single line form
	shPsin	: * char = <>		; single line command
	shVexp	: int = 0		; expansion in progress
	shPexp	: * char = <>		; expansion buffer
					;
	shVver	: int = 0		; verify
	shVlog	: int = 0		; log operations
	shVdbg	: int = 0		; debug
					;
	shVexi	: int = 0		; time to exit
	shVerr	: int = 0		; error count
	shPspc	: * char = _shSPC	; file spec characters
	shPdef	: * dfTctx = <>		; shell definitions
	shPspn	: * char = _shSPN	; shell spawing

data	routines

	sh_swi	: (*shTshe, *char) int
	sh_ovr	: (*char, *char) int
	sh_def	: (*char, *char) int
	sh_kwd	: (*char, *char) int
	sh_run	: (*char, *char) void
	sh_spn	: (*char, *char) void
	sh_hst	: (*char, *char) void
	sh_prc	: (*char, *char) void
	sh_get	: (*char) int

	ut_def	: () * dfTctx
	ut_upt	: (void) void
	ut_img	: (*char, *char) int

	ut_spc	: (*char, *char, *char) int

	ut_mor	: (*char) int
	ut_inv	: (void) void
	ut_rep	: (*char, *char) void
	ut_lst	: (**char) void

	ut_tim	: (void) void
	cd_chg	: (*char) int
	cd_sho	: (void) int
data	keyword routines

;  type	shTkwd
;  is	Pfun : * (*char) void		; some function
;	Pkwd : * char			; the keyword
;  end

	kw_cop	: (*char) void
	kw_del 	: (*char) void
	kw_ren	: (*char) void
	kw_typ	: (*char) void

	kw_def 	: (*char) void
	kw_und 	: (*char) void
	kw_exi 	: (*char) void
	kw_hst	: (*char) void
	kw_hlp	: (*char) void
	kw_run	: (*char) void
	kw_res	: (*char) void
	kw_roo	: (*char) int
	kw_set	: (*char) void
	kw_sho	: (*char) void
	kw_spn	: (*char) void
	kw_tim	: (*char) void
	kw_chg	: (*char) void
	kw_dis	: (*char) void

 init	shAkwd : [] shTkwd
 is	kw_cop,	"co*py"
;	kw_tim, "da*te"
	kw_def,	"def*ine"
	kw_del,	"del*ete"
	kw_exi,	"ex*it"
	kw_hlp,	"he*lp"
	kw_hst,	"ho*st"
	kw_ren,	"rename"
	kw_exi, "qu*it"
	kw_res,	"reset*"
	kw_run,	"ru*n"
	kw_sho,	"sh*ow"
	kw_set, "se*t"
;If Spn
;	kw_spn, "sp*awn"
;End
;	kw_tim,	"ti*me"
	kw_typ,	"ty*pe"
	kw_und,	"undef*ine"
	kw_chg, "cd"
	kw_dis, "dis*play"
	<>,	<>
 end

data	messages

	E_MisImgSpc := "E-Missing image spec"
	E_ErrActImg := "E-Error activating image [%s]"
	E_TooManExp := "E-Too many expansions [%s]"
	E_MisPrcSpc := "E-Missing procedure spec"
	E_ErrAccPrc := "E-Error accessing procedure [%s]"
	W_IgnJnkLin := "W-Ignored junk on line [%s]"
	E_InvSetItm := "E-No such set item [%s]"
;	E_InvShoItm := "E-No such show item [%s]"

data	about

  init	shAabo : [] * char
  is	"SHE Command Shell V2.0"
	""
	"	she [command]"
	""
	<>
  end

data	help

  init	shAhlp : [] * char
  is	"name := .. Define definition"
	"name :=    Delete definition"
	"@file      Execute procedure file.she"
	"copy       Copy files"
	"cd         Change directory"
	"define     Define logical name"
	"delete     Delete files"
	"directory  List directory"
	"display    Display string or calculation"
;	"dump       Dump file contents"
	"exit       End procedure or exit SHE"
	"help       Display help"
	"host       Execute host command"
	"quit       End procedure or exit SHE"
	"reset      Reset logical names"
	"rename     Rename files"
	"run        Execute image (default)"
;	"search     Search files for string"
	"set        Set default,prompt,[no]verify"
	"show       Show commands, ..."
;If Spn
;	"spawn      Spawn image or command"
;End
;	"time       Display time"
	"type       Display files"
	"undefine   Delete logical name"
	<>
  end
code	she main

;	This is the only call for a simple shell.

  func	sh_mai				;
	cnt : int			; argument count
	vec : ** char			; argument vector
  is	she : * shTshe			;
	buf : [mxLIN] char		; command line
	lin : * char = buf		;
	flg : int = 0			;

	if !st_sam (imPfac, "NONAME")	; we are first, or main
	   flg = shSHE_			; we're a shell
	.. im_ini ("SHE")		; init image stuff
					;
	if cnt eq 2			; just want help
	&& st_scn ("/?", vec[1]) 	;
	   ut_lst (shAabo)		; tell them
	.. im_exi ()			;
					;
	she = sh_ini ()			; get environment
	she->Vflg |= flg		; set our flags
					;
	if cnt ge 2			;
	&& sh_swi (she, vec[1])		; check switchs
	.. --cnt, ++vec			; got some
					;
	*lin = 0			; assume no command
	while --cnt gt			; rebuild command line
	   st_app (*++vec, lin)		; copy that back
	   st_app (" ", lin)		;
	end				;
	st_trm (lin)			; clean it up
	she->Plin = lin			; the command line
	kw_res (<>)			; setup "default"
	cd_chg ("")			;
	sh_cmd (she)			; single or multiple
	im_exi ()			;
  end

code	sw_swi - get command switches

;	/p=V11 		get prompt, switch default is "O"
;	/r=c:\rust	get root, switch default is c:\rust

  func	sh_swi
	she : * shTshe
	str : * char
  is	val : *char
	ptr : * char
	swi : int
	cnt : int
	rep : int
	fail if *str ne '/'		; no options
      repeat
	rep = 0				;
	fine if !*str			;
	quit if *str++ ne '/'		;
	swi = ch_low (*str++)		;
	quit if eq			; yuk
	val = <>, cnt = mxLIN-1		;
	if *str eq '='			; got a value
	   val = ptr = ++str
	   while *str && (*str ne '/')	;
	   && --cnt			;
	      *ptr++ = *str++		;
	   end				;
	   fail if !cnt			;
	   rep = *str, *str = 0		;
	end
	quit if !cnt			;
	case swi
	of 'p'				; /prompt=chars
	   val = "O" if !val		;
	   fail if st_len (val) gt mxSPC;
	   st_cop (val, she->Aprm)	;
	of 'r'				; /root=spec
	   val = _shROO if !val		; default
	   kw_roo (val)			;
	of 'd'				; /default=spec
	   val = _shROO if !val		; default
	   cd_chg (val)			;
	of other
	   quit
	end case
	*str = rep if val		;
      end
	fine ut_inv ()
  end
code	sh_cmd - process commands

  func	sh_cmd				; process a command
	she : * shTshe			;
	()  : int			; execution status
  is	cmd : [mxLIN] char		; the command
	buf : [mxLIN] char		; command line
	lin : * char = buf		;
	sin : * char = she->Plin	; single command
	ptr : * char			;
					;
	if !(she->Vflg & shCTC_)	;
	.. co_ctc (coDSB)		; disable control/c
					;
	shPsin=sin, shVsin=1 if *sin	; single line form
	shVsin = 0 otherwise		;
	she->Vsts = 0			;
					;
     repeat				; the big one
	if she->Vflg & shSHE_		; this is a shell
	   quit if she->Vflg & shEXI_	; seen exit
	else				;
	.. quit if she->Vflg & shFIN_	; we're finished
	sh_get (buf)			; get another line
	quit if fail			; are no more lines
					;
	lin = buf			; rewind for repeats
	st_rem ("$", lin)		; remove any dollar up front
					;
	if cl_scn ("@", lin)		; got procedure
	   ut_spc (lin, cmd, E_MisPrcSpc); get a spec
	   quit if fail			; no filespec
	   if st_fnd (".", cmd) eq <>	; has file type
	      if !ut_img (cmd, ".she")	; not one of ours
	      && ut_img (cmd, _shBAT)	; and local batch file
	      .. sh_hst (cmd, lin)	; try host command
	   else				;
	   ..  st_app (".she", cmd)	; add one
	.. next sh_prc (cmd, lin)	; call it
					;
	if st_fnd (":=", lin) ne <>	; got a definition definition
	   df_def (ut_def (), lin)	; do it
	.. next ev_sig (evCMD)		; signal change
					;
	if st_fnd ("=>", lin) ne <>	; got a logical name definition
	   ptr = st_rep ("=>", " ", lin); elide =>
	   ptr = st_skp (ptr)		; skip white space
	   kw_und (lin) if !*ptr	; LOG =>
	   kw_def (lin) otherwise	; LOG => EQU
	.. next				;
					;
	if she->Pdis			; user dispatch
	   she->Pcmd = lin		; 
	.. next if (*she->Pdis) (she)	; user did it
	next if !*lin			; empty line
					;
	ut_spc (lin, cmd, <>)		; accept next as command
	next if sh_def (cmd, lin)	; user definition
	next if sh_kwd (cmd, lin)	; found a command
					;
	if  ut_img (cmd, ".she")	; got command procedure
	.. next sh_prc (cmd, lin)	; do that
					;
	if ut_img (cmd, _shCOM)		; got executable
	|| ut_img (cmd, ".exe")		;
	.. next sh_run (cmd, lin)	; run it
					;
	sh_hst (cmd, lin)		; try host command
     forever				; read loop
	reply she->Vsts | (she->Vflg & shFIN_)
  end

code	sh_exi - setup exit

  proc	sh_abt
  is	shPshe->Vflg |= shABT_		; remember abort
  end

  proc	sh_exi
  is	shPshe->Vflg |= shEXI_		; exit command
  end

  proc	sh_ter
  is	shPshe->Vflg&=shTER_ if ab_chk() ; terminated
  end
code	sh_ini - init definitions etc

  func	sh_ini
	()  : * shTshe
  is	she : * shTshe
If 0	; unused - from some earlier version
	cmd : [mxLIN] char		; the command
	buf : [mxLIN] char		; command line
	lin : * char = buf		;
End
	reply shPshe if shVini		; not reentrant yet
	shPshe = she = me_acc (#shTshe)	;
	++shVini			;
	st_cop (_shPRM, she->Aprm)	; the prompt
	ab_dsb ()			; disable aborts
	abVboo = 1			; enable boot aborts
	shPexp = me_acc (shEXP)		; space for expansions
	shPdef = df_alc ()		;
	df_ctx (_shDEF, dfEPH_) 	; setup definitions
	reply she			; errors caught later
  end

code	ut_def - see if the definition have changed

  func	ut_def
	() : * dfTctx
  is	if ev_chk (evCMD)		; commands changed
	   df_dlc (shPdef)		; forget the past
	.. shPdef = df_ctx(_shDEF,dfEPH_); setup definitions
	reply shPdef
  end

code	ut_img - determine if image exists

;	Check to see if an image with a specific file type exists

  func	ut_img 
	spc : * char			; file spec
	typ : * char			; file type
	()  : int			; fine => exists
  is	res : int = 0			; result
	fil : * FILE			;
	app : * char			; append point
	fail if typ eq <>		; not specified for this system
	if st_fnd (".", spc) ne <>	; got a type
	   st_fnd (typ, spc)		; see if it is ours
	   fail if eq <>		;
	else				;
	   app = st_end (spc)		; append point
	.. st_cop (typ, that)		; add in the type
	fil = fi_opn (spc, "r", <>)	; try to open it
	if ne <>			; got one
	   ++res			; got it
	   fi_clo (fil, <>)		; forget it
	else				;
	.. *app = 0 if app ne <>	; remove appended type
	reply res			;
  end
code	sh_ovr - set/show overrides

  proc	sh_ovr
	pre : * char			; prefix ("help_")
	rem : * char			;
	()  : int			; fine=was definition
  is	itm : [mxLIN] char		;
	lin : [mxLIN] char		;
	cmd : [mxLIN] char		;
	st_cop (rem, lin)		; leave original alone
	ut_spc (lin, itm, <>)		;
	st_cop (pre, cmd)		; get the prefix
	st_app (itm, cmd)		; append the item
	reply sh_def (cmd, lin)		;
  end

code	sh_def - check definition	

  func	sh_def
	cmd : * char			; the command
	rem : * char			; its remainder
	()  : int			; found/not found
  is	buf : [mxLIN*2] char		; expansion buffer
	exp : * char = shPexp		; shell expansions
	ctx : * dfTctx = ut_def ()	; synch with definitions
	def : * dfTdef			;
	rep : * char			;
					;
	def = df_loo (ctx, cmd)		; look it up
	fail if null			;
	df_exp (ctx, def, rem, buf, mxLIN, '^', 0)
	if gt				; success
	   st_len(buf) + st_len(exp)	; get total length  
	   if that gt shEXP-4		; too many expansions
	      sh_abt ()			; abort things
	      ut_rep (E_TooManExp, cmd)	;
	   .. fine			;
	   st_ins ("\n",exp) if shVexp	; insert a separator
	   *exp=0, ++shVexp  otherwise	; first expansion
	   st_ins (buf, exp)		; insert this one
	.. shVexp = 1			; remember it
	ut_rep ("L-Definition [%s]",cmd); debug it
	fine				; we did it
  end

code	sh_kwd - check for keyword

  func	sh_kwd
	cmd : * char			; string to lookup
	rem : * char			; the command line
	()  : int			; fine => found, executed
  is	ent : * shTkwd = shAkwd		; keyword array
	while ent->Pkwd ne <>		; got more
	   if cl_mat (cmd, ent->Pkwd)	; same command
	      (*ent->Pfun)(rem)		; do the command
	   .. fine			;
	   ++ent			;
	end				;
	fail				;
  end
code	kw_res - reset things

  proc	kw_res
	rem : * char
  is	def : [mxSPC] char
	ln_exi ()			; reset logical names
exit
	ln_trn ("default", def, 0)	; get default
	exit if fail			; is none
	dr_set (def, 0)			; reset our default
  end

code	kw_exi - exit shell

  proc	kw_exi
 	rem : * char
  is	sh_exi ()
  end

code	kw_hlp - display help

  proc	kw_hlp
	rem : * char
  is	hlp : ** char = shAhlp		; help lines
	lft : ** char			; 
	rgt : ** char			;
	len : int = 0			;
	exit if sh_ovr ("help_", rem)	; had definition override
	if *rem				; want host help
	.. exit sh_hst ("help", rem)	;
	PUT("%s\n\n", shAabo[0])	; title from about
	lft = hlp			; two column help
	++len while *hlp++ 		; count them
	rgt = lft + (len /= 2)		; right
	while len--			; got more
	   printf ("%-40s", *lft++)	; the left part
	   puts (*rgt++)		;
	end
  end

code	kw_dis - display text

  proc	kw_dis
	rem : * char
  is	lst : * char
	if ct_dig (*rem)
	   sh_hst ("root:calc", rem) 
	else
	   st_del (rem, 1) if *rem eq '"'
	   lst = st_lst (rem)
	   *lst = 0 if *lst eq '"'
	.. PUT("%s\n", rem)
  end
code	kw_xxx - abbreviation front ends

;	dos type does not accept wildcards
;	dos rename does not accept destination paths

	sh_lc1 : (*char, *char) void
	sh_lc2 : (*char, *char) void

  proc	kw_hst
	rem : * char
  is	sh_hst (rem, "")		; host
  end

  proc	kw_run
	rem : * char
  is	spc : [mxLIN] char
	ut_spc (rem, spc, E_MisImgSpc)
	exit if fail
	if ut_img (spc, _shCOM) eq	; not com
	.. ut_img (spc, ".exe")		; try exe
	sh_run (spc, rem)		; run it
  end

  proc	kw_cop
	rem : * char
  is	sh_lc2 ("copy", rem)
  end

  proc	kw_ren
	rem : * char
  is	sh_lc2 ("rename", rem)
  end

  proc	sh_lc2
	cmd : * char
	rem : * char
  is	src : [mxLIN] char
	dst : [mxLIN] char
	if ut_spc (rem, src, <>)
	&& ut_spc (rem, dst, <>)
	   fi_loc (src, src)
	   fi_loc (dst, dst)
	   st_app (" ", src)
	   st_app (dst, src)
	.. rem = src
	sh_hst (cmd, rem)
  end

  proc	kw_del
	rem : * char
  is	sh_hst ("del", rem)		; dos
  end

  proc	kw_typ
	rem : * char
  is	sh_hst ("type", rem)
  end

  proc	sh_lc1 
	cmd : * char
	rem : * char
  is	dst : [mxLIN] char
	if ut_spc (rem, dst, <>)
	   fi_loc (dst, dst)
	.. rem = dst
	sh_hst (cmd, rem)
  end

  proc	kw_tim
 	rem : * char
  is	st_cop ("time", rem)
	sh_run (_shSHO, rem)
  end

  proc	kw_def
	rem : * char
  is	st_ins ("define ", rem)
	cl_red (rem)
	sh_hst ("root:logi.exe", rem)
  end

  proc	kw_und
	rem : * char
  is	st_ins ("undefine ", rem)
	cl_red (rem)
	sh_hst ("root:logi.exe", rem)
  end
code	kw_set - set things

  init	shAset : [] * char
  is	stDEF:	"def*ault"
	stPRM:	"pr*ompt"
	stDBG:	"*deb*ug"
	stROO:	"ro*ot"
;	stLOG:	"*lo*g"
	stVER:	"*ve*rify"
		<>
  end

  proc	kw_set
	rem : * char
  is	she : * shTshe = shPshe
	itm : [mxLIN] char = {0}	; the item value
	pol : int 			; polarity
	exit if sh_ovr ("set_", rem)	; got definition override
	ut_spc (rem, itm, <>)		;
					;
	if she->Pset			; user set routine
	   she->Prem = rem		;
	   she->Pcmd = itm		;
	.. exit if (*she->Pset)(she); User did it
					;
	case cl_loo (itm, shAset, &pol)	; look it up
	of stDEF  cd_chg (rem)		; set default
;	of stDBG  shVdbg = pol		;
	of stROO  kw_roo (rem)
	of stVER  shVlog = pol		;
		  shVver = pol		;
	of stPRM  st_cop (rem,she->Aprm);
		  st_app (" ",she->Aprm);
	of other			;
	   ut_rep (E_InvSetItm, itm)	;
	end case			;
  end

code	kw_sho - show things

  init	shAsho : [] * char
  is	shCOM:	"co*mmands"
	shDEF:	"de*fault"
	shLOG:	"lo*gicals"
	shROO:  "ro*ot"
	shSET:  "se*tup"
	shTIM:	"ti*me"
		<>
  end
	ut_sho	: (*char) void own

  proc	kw_sho
	rem : * char
  is	she : * shTshe = shPshe
	itm : [mxLIN] char		;
	lin : [mxLIN] char		;
	exit if sh_ovr ("show_",rem)	; got definition override
	st_cop (rem, lin)		; save it for SHOW.EXE
	ut_spc (rem, itm, <>)		;
	if she->Psho			; user show routine
	   she->Prem = rem		;
	   she->Pcmd = itm		;
	.. exit if (*she->Psho)(she)	; user did it

     if	itm[0]				; got specifics
	case cl_loo (itm, shAsho, <>)	; look it up
	of shCOM  exit ut_sho (rem)	; show command(s) [command]
	of shDEF  exit cd_sho ()	; show default	
	of shLOG  st_ins ("show ", rem)
		  exit sh_hst ("root:logi.exe", rem)
	of shROO  exit kw_roo (<>)	; show root
	of shSET  quit			; show setup
	of shTIM  exit ut_tim ()	; show time
	of other  exit ut_inv ()	; invalid command
	end case			;
     end				;
	PUT("default = ")
	cd_sho ()
	kw_roo (<>)
	st_cop ("setup = ", lin)	;
;	st_app ("no", lin) if shVdbg eq
;	st_app ("debug ", lin)
;	st_app ("no", lin) if shVlog eq
;	st_app ("log ", lin)
	st_app ("no", lin) if shVver eq
	st_app ("verify ", lin)
	PUT ("%s\n", lin)
  end

code	ut_sho - show definitions

  proc	ut_sho
	rem : * char
  is	def : * dfTdef			;
	tar : [mxLIN*2] char
	src : * char
	dst : * char
	cnt : int = 0
	mor : int = 0
	rem = "*" if !*rem 

;	if *rem				; specific
;	   def = df_loo (shPdef, rem)	; look it up
;	   if null			; not defined
;	      PUT ("%s := (undefined)\n", rem) ; the name
;	   else				;
;	   .. PUT("%s := %s\n", def->Pnam, def->Pbod)
;	.. exit				;
	ut_def ()			;
	def = (ut_def ())->Proo		; get the first
	exit if null			; are none
	while def ne <>			; got more
	   src = def->Pnam		; edit out punctuation
	   dst = tar			;
	   while *src			; got more of target
	      if *src ne '*'		; skip '*'
	      && *src ne '?'		;
	      .. *dst++ = *src		; copy one
	   .. ++src			;
	   *dst = 0			; terminate model
	   if st_wld (rem, tar)		; didn't match
	      exit if !cl_mor (&mor)	;
	      PUT("%-10s := %s\n", 	;
	   .. def->Pnam, def->Pbod)	;
	   def = def->Psuc		;
	end				;
  end

code	kw_roo - set/show root

  func	kw_roo
	rem : * char
  is	roo : [mxSPC] char
	if !rem
	   ev_get ("Root", roo, mxSPC)
	   PUT("root = %s\n", roo)
	.. fine
	ev_set ("Root", rem)
  end
code	sh_run - run program

  proc	sh_run
	spc : * char
	rem : * char
  is	she : * shTshe = she
	msg : int
	sts : int
	han : * void
	if shVlog			; logging
	.. PUT("?SHE-I-Run %s %s\n", spc, rem) ; tell them
;	ut_rep ("I-Run [%s %s]",spc,rem); tell them
	st_upr (spc)			; uppercase the name
	sh_hst (spc, rem)
	reply that

	st_ins (" ", rem)		; space before remainder
	ab_enb ()			; enable aborts
	han = cl_foc (0)		;
	sts = im_exe (spc, rem, 0)	; execute the program
	she->Vsts |= that		;
	ab_dsb ()			; disable aborts
	cl_foc (han)			; get the focus back
	if sts lt			; some error
	.. ut_rep (E_ErrActImg, spc)	; report it
	if shVlog ne			; want logging
	.. printf ("%%SHE-I-Status = %d\n", sts)
  end

code	sh_hst - execute host command

  proc	sh_hst
	cmd : * char
	rem : * char
  is	she : * shTshe = shPshe		;
	img : [mxLIN] char		;
	lin : [mxLIN] char
	sts : int			;
	han : * void
	fi_loc (cmd, img)		;
	st_cop (img, lin)		; build the command
	if *rem				; got more
	   st_app (" ", lin)		;
	.. st_app (rem, lin)		;
	if shVlog ne			;
	.. ut_rep ("I-Host [%s]", lin)	; tell them
;	ab_enb ()			; enable aborts
	han = cl_foc (0)		;
;	co_ctc (coENB)			;
	she->Vsts |= pr_cmd (lin)	; execute it
	co_ctc (coDSB)			;
	ab_dsb ()			; disable aborts
	cl_foc (han)			; get the focus back
	if shVlog ne			; want logging
	.. printf ("%%SHE-I-Status = %d\n", she->Vsts)
  end
code	sh_prc - initiate command procedure

  proc	sh_prc
	spc : * char			; filespec
	lin : * char			; command line
  is	if io_src (spc, "") eq		; open it
	   ut_rep (E_ErrAccPrc, spc)	; error accessing procedure
	else				;
	.. ++shVprc			; got procedure
  end
	
code	sh_get - get next command line

;	Obtain next line from command procedure or input
;	Handle reduction, comments and verify

  func	sh_get
	lin : * char			; command buffer
	()  : int			; fail => no more input
  is	she : * shTshe = shPshe		;
	exp : * char = shPexp		;
	ptr : * char			;
 
      repeat				;
	shVexp = 0 if abVcan|abVabt	; abort definitions
	if shVexp ne			; got expansion
	   ptr = st_fnd ("\n", exp)	; find
	   if <>			; single line
	      st_cop (exp, lin)		; copy it back
	      *exp = 0			; delete it
	   else				;
	      *ptr++ = 0		; delete newline
	      st_cop (exp, lin)		; copy command
	   .. st_mov (ptr, exp)		; elide command
	   shVexp = 0 if *exp eq	; got anymore
	.. quit				; fine
					;
	if shVprc ne			; command procedure
	   if io_get (lin) ne		; get another
	      next if abVcan|abVabt	; aborted somewhere
	      if shVver ne		; need to verify
	      .. printf ("%s\n", lin)	; display it
	      sh_ter ()			; check aborts
	   .. quit			; got something
	.. shVprc = 0			; out of procedures
					;
	sh_ter ()			; clear pending aborts
	if shVsin ne			; single line
	   fail if shVsin lt		; was single line command
	   shVsin = -1			; once only
	   st_cop (shPsin, lin)		; copy it back
	.. quit				; got something
					;
	sh_sin (lin)			; get another line
	if st_mem (3, lin) || abVabt	; got control C		
	   sh_abt ()			;
	.. *lin = 0			; dump the input
	fine				;
      forever				;
	fine cl_red (lin)		; reduce it
  end

code	sh_sin - get a single keyboard command

;	Used by external interface to collect & reduce a command

  func	sh_sin				;
	lin : * char			;
	()  : int			;
  is	she : * shTshe = shPshe		;
	shVsin = -1 if she->Vflg & shMAN_ ; manual drive
	(*she->Pprm)(she) if she->Pprm	; user prompt hook
	cl_prm (stdin, she->Aprm, lin, mxLIN) ; get terminal line
	reply cl_red (lin)		; check empty line
  end					;
code	parsers, errors

;	All routines delete from the front of a string
;	All routines elide leading and trailing spaces

code	ut_spc - filter filespec

  func	ut_spc
	lin : * char			; the line
	spc : * char			; result specification
	msg : * char			; error message
	()  : int			; got something
  is	st_ext ("-fe", _shSPC, lin, spc); extract token
	fine if *spc			; got something
	ut_rep (msg, <>) if msg ne <>	; report the error
	fail				;
  end

code	ut_mor - check more on line

  func	ut_mor
	lin : * char
	()  : int			; fine => error
  is	fail if *lin eq			; exhausted line
	ut_rep (W_IgnJnkLin, lin)	; ignored junk on line
	fine				; not sleepy
  end

code	ut_inv - invalid command

  proc	ut_inv
  is	im_rep ("E-Invalid command", <>)
  end

code	ut_rep - report and set status

  proc	ut_rep
	msg : * char
	obj : * char
  is	exit if *msg eq 'L' && shVlog eq; logging is off
	im_rep (msg, obj)		; report it
	im_exi () if *msg eq 'F'	; fatal
	++shVerr  if *msg eq 'E'	;
  end

code	ut_lst - print array of text

  proc	ut_lst
	tab : ** char
  is	while *tab ne <>		; got more
	   printf ("%s\n", *tab++)	; another
	end				;
  end
code	kw_chg - change directory

  proc	kw_chg
	rem : * char
  is	cd_chg (rem) if *rem
	cd_sho () otherwise
  end

;	CD c:
;	CD c:\dir\dir
;	CD \dir\dir
;	CD log:
;	CD dir dir

code	cd_chg - change directory

;	cd xxx
;  =>	cd xxx
;	cd ..\xxx
;	cd ..\..\xxx
;	cd ..\..\..\xxx
;	cd ..\..\..\..\xxx
	
  func	cd_chg
	dir : * char
  is	loc : [mxLIN] char
	buf : [mxLIN] char
	dep : int = 0
	rep : int = 0
	cnt : int
	aut : int = 0
	if *dir eq			; wants default default
	   ev_get ("Default", loc, mxLIN-20) ; initial call
	   st_cop (_shROO, loc) if fail	; use default root
	else				;
	   fi_loc (dir, loc)		;
	end				;
	while dep lt 4			; got more depth
	   buf[0] = 0			;
	   while cnt in 1..dep		; got more
	      ++rep			;
	   .. st_app ("..\\", buf)	; back a directory
	   st_app (loc, buf)		; add the directory
	   if dr_set (buf, 0)		; set directory
	      ln_def ("default", buf, 0); as a logical name
	      ev_set ("Default", buf)	; setup permanent default
	      cd_sho () if rep		;
	   .. fine			;
	   ++dep
	end
	im_rep ("W-Error setting current directory [%s]", loc)
	fail
  end

code	cd_sho - show current

;	CD displays the current directory and the
;	first, if any, logical name that matches it.
;
;	cd
;    =>	c:\m\bin (bin:)

  func	cd_sho
  is	lin : [mxLIN] char
	buf : [mxLIN] char
	equ : [mxLIN] char
	pth : * char = buf		;
	nth : int = 0
	dr_sho (pth, drPTH)		; get current directory
	st_low (pth)			;
	FMT(lin, "%s", buf)		; put path

 	while ++nth lt 3		;
	   quit if !ln_rev (buf,equ,nth); no more logicals
	   next if st_sam(equ,"default"); not the one we want
	   FMT(st_end (lin)," (%s:)",equ); logical
	   quit
	end
	PUT("%s\n", lin)
  end
code	ut_tim - show time

	tiTplx	:= struct tm

  init	tiAday : [] * char 
  is	"Sunday", "Monday", "Tuesday", "Wednesday"
	"Thursday", "Friday", "Saturday"
  end

  init	tiAmon : [] * char
  is	"Jan", "Feb", "Mar", "Apr", "May", "Jul" 
	"Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
  end

  proc	ut_tim
  is	tim : time_t
	plx : * tiTplx
	day : * char
	mon : * char
	tim = time (<>)			; get current time
	plx = localtime (&tim)		; make it local
	day = tiAday[plx->tm_wday]	; day of the week
	mon = tiAmon[plx->tm_mon]	;
					;
	printf ("%s %02d-%s-%4d",	; Tuesday 12-Apr-1992
		day,			;
		plx->tm_mday,		;
		mon,			;
		plx->tm_year + 1900)	;
	printf (" %02d:%02d:%02d\n",	; 12:24:30
		plx->tm_hour,		;
		plx->tm_min,		;
		plx->tm_sec)		;
  end
end file

include rid:dbdef
  func	cu_prm
	she : * shTshe
  is	st_cop ("[] ", she->Aprm)
	fine
  end

  func	cu_dis 
	she : * shTshe
  is	PUT("cmd=[%s] rem=[%s]\n", she->Pcmd, she->Prem)
	fail
  end

  func	main
	cnt : int
	vec : ** char
  is	she : * shTshe = sh_ini ()
	db_hoo (db_rev)
	she->Pprm = cu_prm
	she->Pdis = cu_dis
	sh_mai (cnt, vec)
  end

If Spn
  proc	kw_spn
	rem : * char
  is	spc : [mxLIN] char
	if *rem eq			; default
	.. exit sh_spn (shPspn, "/s")	; spawn a shell
	ut_spc (rem, spc,E_MisImgSpc)	;
	exit if fail			;
	if ut_img (spc, _shCOM) eq	; not com
	.. ut_img (spc, ".exe")		; try exe
	sh_spn (spc, rem)		; run it
  end
End


If Spn
code	sh_spn - spawn command

  proc	sh_spn
	spc : * char
	rem : * char
  is	msg : int
	sts : int
	ut_rep ("L-Spawn [%s]", spc)	; tell them
	st_upr (spc)			; uppercase the name
	st_ins (" ", rem)		; space before remainder
	sts = im_exe (spc, rem, 0)	; execute the program
	shVsts |= that			;
	if sts lt			; some error
	.. ut_rep (E_ErrActImg, spc)	; report it
	if shVlog ne			; want logging
	.. printf ("%%SHE-I-Status = %d\n", sts)
  end
End

