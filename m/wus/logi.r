;	Move those files
;	DCL next
;	SHE TYPE command broken
;	rebuild Windows apps without debug
;	should validate names (i.e. no % ? or *)
;	exit statement if cnd fails
;	Provide installation tutorial and setup.
;	Why do we startup with C:\F\RUST?
;	SHE must report problems with ROOT or DEFAULT
;	Why do help fields begin with a discarded space?
;	/translated
;	/nopage
;	/nopage instead of /nopause on all

file	logi - windows RUST/SHE logical name utility
include rid:rider
include rid:codef
include rid:stdef
include rid:fidef
include rid:lndef
include rid:medef
include rid:imdef
include rid:cldef
include rid:chdef

;	define log equ	 	
;	help
;	import file[.def] [log*]
;	export file[.def] [log*]
;	show logical [log*]
;	show equivalences [equ*]
;	show translation log
;	show native log
;	undefine log*
;
;	Colons are trimmed from logical names.
;	Translation is recursive except for SHOW TRANSLATION.
;	Equivalences can be full file specifications.

  type	cuTdef : forward

  type	cuTctl			; program control
  is	Pvec : ** char		; cli argument vector
	Vcnt : int		; cli argument count
	Plog : * char		; logical name
	Pequ : * char		; equivalence name
	Pfld : * char		; command field
	Ppat : * char		; wildcard pattern string
	Pdef : * cuTdef		; definition list
  end

  type	cuTdef			; wildcard definition list entry
  is	Psuc : * cuTdef		; successor
	Plog : * char		; logical
	Pequ : * char		; equivalence
  end

	kw_def : (*cuTctl)	; keywords
	kw_exp : (*cuTctl)
	kw_imp : (*cuTctl)
	kw_nat : (*cuTctl)
	kw_sho : (*cuTctl, int)
	kw_trn : (*cuTctl)
	kw_und : (*cuTctl)

	cu_par : (*cuTctl, int, int) int; parse argument
	cu_sho : (*cuTctl)
	cu_dis : (*cuTctl, *char, *char)
	cu_lst : (*cuTctl, int) *cuTdef
	cu_rep : (*cuTctl, *char, *char)

	cuLOG  := 0		; argument types
	cuEQU  := 1		;
	cuPAT  := 2		; match pattern
	cuFLD  := 3		; command field
				;
	cuOPT_ := BIT(0)	; optional parameter
	cuCOL_ := BIT(1)	; trim trailing colon 
	cuLST_ := BIT(2)	; last argument

  init	cuAkey : [] *char
  is	kwDEF: "de*fine"
	kwEXP: "ex*port"
	kwIMP: "im*port"
	kwHLP: "he*lp"
	kwSHO: "sh*ow"
	kwUND: "un*define"
  	kwMIS: <>
  end

  init	cuAsho : [] *char
  is	shEQU: "eq*uivalences"
	shLOG: "lo*gical"
	shTRN: "tr*anslation"
	shNAT: "na*tive"
  	shMIS: <>
  end

  init  cuAhlp : [] * char
  is	""
	"LOGI - Maintain RUST logical name definitions"
	""
	"define log equ          Define a logical name"
	"define log @equ         Translate the equivalence name"
	"export file [log*]      Export definitions to a file"
	"import file [log*]      Import definitions from a file"
	"help                    Display this help"
	"show logical log*       Display logical names"
	"show equivalences equ*  Display logical names"
	"show translation log    Display single translation step"
	"show native log         Display native translation"
	"undefine log*           Undefine logical names"
	""
	"Where:"
	""
	"log  = logical name"
	"equ  = equivalance name"
	"   * = accepts wildcards"
	""
;	"Names are stored in the Windows registery under:"
;	"    HKEY_LOCAL_MACHINE\\SOFTWARE\\Rust"
;	"or: HKEY_LOCAL_MACHINE\\SOFTWARE\\Wow6432Node\\Rust"
	<>
  end

	_cuINV := "E-Invalid command [%s]"
	_cuLEN := _cuINV
	_cuFEW := "E-Required command field missing"
	_cuEXT := "E-Too many command fields [%s]"
	_cuEXT := "E-Command field too long [%s]"
	_cuNNF := "E-Name not found [%s]"
	_cuFMT := "E-Invalid definition file format [%s]"

code	cu_rep - report messages

  func	cu_rep
	ctl : * cuTctl
	msg : * char
	arg : * char
  is	im_rep (msg, arg)
	im_exi ()
  end

code	cu_dis - display definition

  func	cu_dis
	ctl : * cuTctl
	log : * char
	equ : * char
  is	PUT("%s => %s\n", log, equ)	; display entry
  end
code	main

  func	main
	cnt : int
	vec : **char
  is	ctl : * cuTctl
	fld : * char
	im_ini ("LOGI")			; register name for messages
	co_ctc (coENB)			; allow ctrl-C abort

	ctl = me_acc (#cuTctl)		; control
	ctl->Pvec = ++vec		; skip image name
	ctl->Vcnt = --cnt		;
	ctl->Plog = me_acc (mxSPC)	;
	ctl->Pequ = me_acc (mxSPC)	;
	ctl->Ppat = me_acc (mxSPC)	;
	ctl->Pfld = me_acc (mxSPC)	; command field
	fld = that			; local pointer
					;
	cu_par (ctl, cuFLD, cuOPT_)	; get next argument
	exit im_hlp (cuAhlp, 1) if fail	; no parameters

	case cl_loo (fld, cuAkey, <>)
	of kwMIS  cu_rep (ctl, _cuINV, fld)
	of kwDEF  kw_def (ctl)
	of kwEXP  kw_exp (ctl)
	of kwIMP  kw_imp (ctl)
	of kwUND  kw_und (ctl)
	of kwSHO  cu_sho (ctl)
	of kwHLP  im_hlp (cuAhlp, 1)
	end case
  end

  func	cu_sho
	ctl : * cuTctl
  is	fld : * char = ctl->Pfld

	if !ctl->Vcnt			; just "SHOW"
	.. exit kw_sho (ctl, shLOG)	; SHOW defaults to SHOW LOGICAL
	cu_par (ctl, cuFLD, 0)		; must succeed

	case cl_loo (fld, cuAsho, <>)
	of shMIS  cu_rep (ctl, _cuINV, fld)
	of shLOG  kw_sho (ctl, shLOG)
	of shEQU  kw_sho (ctl, shEQU)
	of shTRN  kw_trn (ctl)
	of shNAT  kw_nat (ctl)
	end case
  end
code	kw_def - define log-name equ-name

;	define log equ
;	define log @equ
;	define log @equ:...

  func	kw_def
	ctl : * cuTctl
  is	log : * char = ctl->Plog
	equ : * char = ctl->Pequ
	pat : * char = ctl->Ppat

	cu_par (ctl, cuLOG, cuCOL_)
	cu_par (ctl, cuEQU, cuLST_)

	if *equ eq '@'			; want translated?
	   st_cop (equ+1, pat) 		; yes
	   fi_trn (pat, equ, 1)		; translate file spec
	.. exit cu_rep (ctl, _cuNNF, equ) if le
					;
	ln_def (log, equ, 0)		; define it
  end

code	kw_und - undefine log-names

  func	kw_und
	ctl : * cuTctl
  is	pat : * char = ctl->Ppat
	def : * cuTdef
	fnd : int = 0
	cu_par (ctl, cuPAT, cuCOL_|cuLST_)

	if !st_int ("*%?", pat, <>)	; no wildcards
	   ln_und (pat, 0)		; undelete single logical name
	   cu_rep (ctl, _cuNNF, pat) if fail
	.. exit

	def = cu_lst (ctl, shLOG) 	; build the list
	cu_rep (ctl, _cuNNF, pat) if fail
	while def
	   ++fnd
	   ln_und (def->Plog, 0)
	   fail cu_rep (ctl, _cuNNF, pat) if fail
	   def = def->Psuc
	end
  end

code	kw_sho - show logicals/equivalences

  func	kw_sho
	ctl : * cuTctl
	typ : int
  is	log : * char = ctl->Plog
	pat : * char = ctl->Ppat
	def : * cuTdef
	lin : int = 0

	(typ eq shLOG) ? cuCOL_ ?? 0	; trim logical name colons
	cu_par (ctl, cuPAT, that|cuOPT_|cuLST_)
	st_cop ("*", pat) if !*pat	; default for SHOW
					;
	def = cu_lst (ctl, typ)		; build the list
	exit cu_rep (ctl, _cuNNF, pat) if fail
	while def			; process definitions
	   cu_dis (ctl, def->Plog, def->Pequ)
	   cl_cmd ("More? ", <>), lin = 0 if ++lin eq 24
	   def = def->Psuc
	end
  end

code	kw_trn - single-step translate log-name

  func	kw_trn
	ctl : * cuTctl
  is	log : * char = ctl->Plog
	equ : * char = ctl->Pequ
	cu_par (ctl, cuLOG, cuCOL_|cuLST_)
	ln_trn (log, equ, 1)		; single translation step
	cu_rep (ctl, _cuNNF, log) if fail
	cu_dis (ctl, log, equ)    otherwise
  end

code	kw_nat - show native translation of file spec

  func	kw_nat
	ctl : * cuTctl
  is	log : * char = ctl->Plog
	equ : * char = ctl->Pequ
	cu_par (ctl, cuLOG, cuLST_)	; get spec
	fi_loc (log, equ)		; localize it
	cu_dis (ctl, log, equ)		; show it
  end
code	kw_imp - import definitions

	mxDEF := (mxSPC*2)+8

  func	kw_imp
	ctl : * cuTctl
  is	spc : * char = ctl->Pfld	;
	lin : [mxDEF] char		;
	pat : * char = ctl->Ppat	;
	fil : * FILE			;
	def : * cuTdef			;
	ptr : * char			;
	cu_par (ctl, cuFLD, 0)		;  get filespec
	cu_par (ctl, cuPAT, cuOPT_|cuLST_)
	st_cop ("*", pat) if fail	;
	fi_def (spc, ".def", spc)	; default type
	fil = fi_opn (spc, "r", "")	; open it
	pass fail			;
	while fi_get (fil,lin,mxDEF) ne EOF ; read another line
	   ptr = st_fnd (" => ", lin)	;
	   if !ptr || (ptr eq lin)	;
	   || (st_len (ptr) lt 5)	;
	   .. cu_rep (ctl, _cuFMT, spc)	; invalid file format
	   *ptr = 0, ptr += 4		; terminate logical
	   next if !st_wld (pat, lin)	;
	   ln_def (lin, ptr, 0)		;
	end				;
	fi_clo (fil, "")		;
  end

code	kw_exp - export definitions

  func	kw_exp
	ctl : * cuTctl
  is	spc : * char = ctl->Pfld	;
	lin : [mxDEF] char		;
	fil : * FILE			;
	def : * cuTdef			;
	cu_par (ctl, cuFLD, 0)		;  get filespec
	cu_par (ctl, cuPAT, cuOPT_|cuLST_)
	st_cop ("*", ctl->Ppat) if fail	;
	fi_def (spc, ".def", spc)	; default type
	fil = fi_opn (spc, "w", "")	; open it
	pass fail			;
	def = cu_lst (ctl, shLOG)	;
	pass fail			;
	while def			;
	   FMT(lin, "%s => %s\n", def->Plog, def->Pequ)
	   fi_put (fil, lin)		;
	   def = def->Psuc
	end
	fi_clo (fil, "")
  end
code	cu_lst - generate sorted list

  func	cu_lst
	ctl : * cuTctl
	typ : int			; shLOG or shEQU
	() : * cuTdef
  is	pat : * char = ctl->Ppat	; wildcard pattern
	log : [mxSPC] char		; local copies
	equ : [mxSPC] char		;
	nxt : ** cuTdef
	cur : * cuTdef
	def : * cuTdef
	idx : int = 0
	ctl->Pdef = <>
	fail if !*pat

      while ln_nth (idx++, log, equ, mxSPC)
	(typ eq shLOG) ? log ?? equ
	next if !st_wld (pat, that)
	def = me_acc (#cuTdef)
	def->Plog = st_dup (log)
	def->Pequ = st_dup (equ)
	nxt = &ctl->Pdef
	while *nxt
	   cur = *nxt
	   if st_cmp (log, cur->Plog) lt
	   .. quit def->Psuc = *nxt
	   nxt = &(*nxt)->Psuc
	end
	*nxt = def 
      end
	reply ctl->Pdef
  end
code	cu_par - parse argument

  func	cu_par
	ctl : * cuTctl
	fld : int
	flg : int
  is	par : * char
	lst : * char

	case fld
	of cuLOG  par = ctl->Plog	; select the field
	of cuEQU  par = ctl->Pequ
	of cuPAT  par = ctl->Ppat
	of cuFLD  par = ctl->Pfld
	end case
	*par = 0			; terminate field
					;
	if !ctl->Vcnt			; no more arguments
	   fail if flg & cuOPT_		; it was optional, reply missing
	.. cu_rep (ctl, _cuFEW, <>)	; required parameter missing
					;
	--ctl->Vcnt			; pickup argument
					;
	if st_len (*ctl->Pvec) gt mxSPC	; string overflow
	.. cu_rep (ctl, _cuLEN, *ctl->Pvec) ; invalid parameter
	st_cop (*ctl->Pvec++, par)	;
					;
	if ctl->Vcnt && (flg & cuLST_)	; should have been last
	.. cu_rep (ctl, _cuEXT, par)	; too many arguments
					;
	st_low (par)			; make lower case
					;
	if flg & cuCOL_			; remove trailing colon
	   if st_sam (par, ":")		; just a colon
	   .. cu_rep (ctl, _cuINV, par)	; that's not valid
	   lst = st_lst (par)		;
	   *lst = 0 if *lst eq ':'	; remove colon
	end				;
					;
	fine				;
  end
;	Later
;
;	/pause
;	/exact		do not strip ":" from logicals
;
;	roll /table=xxx	Interactive on selected table.
;
;	xxx\yyy		"xxx" is the name of a table.
;
;	xxx:		Explicit ":" requires such for translation.
;			Avoids name clashs with files. (e.g. con:, system:)
;
;	xxx := _yyy	Physical translation. Only returned by ln_phy.
;			Like a rooted name in VMS, or SUBST in Dos.
;
;	xxx := yyy, zzz	Directory paths
;
;	xxx := (yyy, zzz)
;			Psuedo directory trees.
