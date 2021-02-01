;	fix parsing filters
STR(x) := PUT("[%s] ", x)
REM := PUT("rem=[%s]\n", dcl->Prem)
KWD := PUT("kwd=[%s]\n", itm->Pkwd)
file	dcmod - DCL facilities
include rid:rider
include rid:cldef
include rid:imdef
include rid:medef
include rid:stdef
include rid:dcdef

;	See WUS:DCL.R for example syntax.
;
;	ENGINE:
;	Designed as a call-out machine to permit user routines to easily
;	gain control at key points.
;
;	The icky bit is end-of-field, end-of-line and qualifier processing. 
;
;	1. Command field qualifiers can't be processed until the
;	   command has been located and dispatched.
;
;	2. End of field processing must process qualifiers.
;
;	dcAidt is used as a string filter for everything except
;	file specs (which have embedded ":").
;
;	DEV := {"DE*VICE"

	dc_vrb : (*dcTdcl)			; find/process verb
	dc_sym : (*dcTdcl, *dcTitm, *char, int) int- ; keyword/qualifier
	dc_loo : (*dcTdcl, *dcTitm, int) *dcTitm-; lookup keyword
	dc_par : (*dcTdcl, *char, int) int-	; parse object
						;
	dc_obj : (*dcTdcl, *dcTitm)- 		; convert value
	dc_eol : (*dcTdcl, *dcTitm)-		; check end of line
	dc_flg : (*dcTdcl, *dcTitm)-		; set control flag
	dc_cvt : (*dcTdcl, *dcTitm)-		; convert
	dc_adv : (*dcTdcl, *dcTitm) * dcTitm-	; next syntax item
	dc_nst : (*dcTdcl, *dcTitm) int-	; nested syntax item
	dc_skp : (*dcTdcl)			; skip space

	DBG(x)   := dc_dbg (dcl, x)
	DBS(x,y) := dc_dbs (dcl, x, y)
	DBV(x,y) := dc_dbv (dcl, x, y)

	dc_dbg : (*dcTdcl, *char) int-
	dc_dbs : (*dcTdcl, *char, *char) int-
	dc_dbv : (*dcTdcl, *char, int) int-
	dc_put : (*dcTdcl, *dcTitm)-

data	strings

	dcAinv : "E-Invalid command"
	dcAidt : " /:=,"	; keyword parse
	dcAspc : " /=,"		; filespec parse

code	dc_inv - invalid command

  func	dc_inv
	dcl : * dcTdcl
  is	exit if dcl->Verr++		; once only
	im_rep (dcAinv, <>)		; report message
  end
data	syntax

;	dc_opt		searchs all qualifiers for /OPTION
;	dc_lst,"+"
;	dc_tim
;	dc_prt
;	dc_
;	dc_kwd		SET KEYWORD=...
;
;	EXIT
;	COPY/QUAL FIELD/... FIELD/...
;	FIELD :=  OBJECT/QUAL,OBJECT/QUAL...
;	FIELD :=  OBJECT/QUAL+OBJECT/QUAL...
;
;	COPY /QUAL=ATTRIBUTE
;	SET KEYWORD ATTRIBUTE
;	START KEYWORD=ATTRIBUTE 
;
;	MACRO A+B+C,D+E+F
;	COPY [1,2]FILE/PROTECTION=(RWED,,,)
;	LINK DK:A(1,2,3)
;
;	SET DL SIZE=20 TYPE="MAD"
;
;	dc_opt
;
;	Identifier	command, optn, qualifier, keyword,
;	Spec		device/directory/file spec
;	String
;
;	Command		Initial processing state
;	Verb		COPY, DIR etc
;			Skipped if initial command entry has no 
;			identifier pointer.
;	Qualifier	COPY/QUALIFIER
;	Keyword		SET KEYWORD KEYWORD
;	Attribute	/SIZE=attribute
;	indirect case
;	qualifiers
code	dc_eng - DCL engine

;	Work out multiple/single line operation
;	Acquire command if necessary
;	Reduce command
;	Call dc_nxt to process command verb

  func	dc_eng
	dcl : * dcTdcl~			; DCL context
	tab : * dcTitm			; DCL table
	prm : * char			;
  is	env : * int~ = &dcl->Venv	; command environment
	lin : * char~ = dcl->Alin	; command line
					;
	if *env & (dcCLI_|dcCLS_)	; wants CLI command
	&& cl_lin (lin)			; and got one
	&& *env & dcCLS_		; and want single line
	.. *env |= dcSIN_		; setup an exit
					;
	repeat				;
	   dcl->Pitm = tab		; setup the table
	   dc_ini (dcl)			; cleanup
					;
	   if !*lin && !(*env & dcNUL_)	; no command and required
	   .. cl_cmd (prm, lin)		; prompt
					;
	   cl_red (lin)			; reduce the line
	   DBS("cmd", lin)		;
					;
	   if *lin || (*env & dcNUL_)	; not a blank line
	      dc_vrb (dcl)		; process verb
	   .. dc_inv (dcl) if fail	;
	   dcl->Alin[0] = 0		; lines are once-only
	   fine if *env & dcSIN_	; single command
	end
  end
code	dc_vrb - process initial verb

; Level Idt		Fun	P1  V1	   Flg
;    1,	"SE*T",		dc_kwd, <>,	0, dcNST_
;	Verb

  func	dc_vrb
	dcl : * dcTdcl~
  is	itm : * dcTitm = dcl->Pitm
	dcl->Pqua = itm			; point to qualifiers
	fail if !dc_qua (dcl)		; get leading qualifiers
	fine if dcl->Venv & dcFIN_	; check for /help etc
					;
	if !(itm->Pkwd); || (*itm->Pkwd eq '/')
	.. reply dc_act (dcl)		; no verb, process action
					;
	dc_sym (dcl,dcl->Pitm,dcAidt,0)	; parse and process verb
	fail dc_inv (dcl) if fail	;
	reply dc_qua (dcl)		; grab qualifiers
  end

code	dc_kwd - process keyword

;	Called by dcl tables (by located verb)
;
; Level Idt		Fun	P1  V1	   Flg
;    1,	"SE*T",		dc_kwd, <>,	0, dcNST_
;     2,  "50*_HERTZ",	cu_set, <>, cu50H, dcEOL_
;     2,  "60*_HERTZ",	cu_set, <>, cu60H, dcEOL_
;	   Keywords

  func	dc_kwd				; keyword parse
	dcl : * dcTdcl~			;
  is	DBG("vrb")			;
	dc_sym (dcl,dcl->Pitm,dcAidt,0)	; parse and process
	fail dc_inv (dcl) if fail	;
	reply dc_qua (dcl)		; grab qualifiers
  end

code	dc_qua - process qualifiers 

;	Called opportunistically to process qualifiers
;
;	A separate qualifer table is avoided by placing qualifiers
;	at the end of a syntax section.
;
;	dc_atr	dcOPT_	attribute is optional
;		V1	is the default for dcOPT_
;
;    1,	"DI*RECTORY",	dc_act, <>,	0, dcNST_	; verb
;     2,  <>,		dc_fld, ...			; arguments
;     2,  <>,		cu_dir,0,	0,dcEOL_	; call

;     2,  "/BR*IEF",	dc_set,&ctl.Qbrf,1,0		; qualifiers
;     2,  "/CO*UNT",	dc_atr,&ctl.Qbrf,1,dcDEC|dcOPT_	; optional decimal

  func	dc_qua
	dcl : * dcTdcl~
  is	itm : * dcTitm = dcl->Pitm
	res : int = 1
	while *dcl->Prem eq '/'		; got another?
	   ++dcl->Prem			; yep - skip '/'
	   DBG("qua")			;
	   dc_sym (dcl,dcl->Pqua,dcAidt,1); parse and process
	   quit res = 0 if fail
	end
	dcl->Pitm = itm
	reply res
  end

code	dc_sym - parse/dispatch keyword/qualifier

;	Process identifier (verb/keyword/qualifier)
;	Call function for match
;
;	dc_vrb -> dc_sym
;	dc_kwd -> dc_sym
;	dc_qua -> dc_sym
;	dc_opt -> dc_sym
;
;	symbol		function
;    1,	"DI*RECTORY",	dc_act, <>,	0, dcNST_
;     2,  "/BR*IEF",	dc_set,&ctl.Qbrf,1,dcOPT_
;
;	fine	found and dispatched
;	fail	identifier not found

  func	dc_sym
	dcl : * dcTdcl
	lst : * dcTitm			; symbol list
	syn : * char			; identifer parse table
	qua : int			; 1 => qualifier
	()  : int			; fine => found, executed
  is	sym : * dcTitm~			;
	fail if !lst			; no list
	fail if !dc_par (dcl, syn, dcSPC); parse failed
	sym = dc_loo(dcl, lst, qua)	; find symbol
	pass fail			; not found
	fail if !dc_nst (dcl, sym)	; nesting error
	dc_flg (dcl, dcl->Pitm)		; set any flags
	dcl->Vsta = (*sym->Pfun)(dcl)	; do the command
	fail if !dc_eol (dcl, sym)	; 
	reply dcl->Vsta			; pass status
  end

code	dc_loo - lookup keyword

;	Searches for keyword match
;	or processes keyword command fields

  func	dc_loo
	dcl : * dcTdcl~			;
	itm : * dcTitm~			;
	qua : int			; 1 => qualifier search
	()  : * dcTitm			; fine => found, executed
  is	repeat				;
;PUT("[%s] [%s]\n", dcl->Pobj, itm->Pkwd+qua) if itm->Pkwd
	   if itm->Pkwd			; has a keyword
	   && (!qua || (qua && (*itm->Pkwd eq '/')))
	   && cl_mat (dcl->Pobj, itm->Pkwd+qua) ; and keyword matches
	      dcl->Pitm = itm		; remember it
	   .. reply itm			;
	   itm = dc_adv (dcl, itm)	; get next item
	   pass fail			; not found
	end				;
  end
code	dc_act - action list processor

; Level Idt		Fun	P1	V1 Flg
;    1,	"BO*OT",	dc_act, <>,	0, dcNST_
;     2,  <>,		dc_fld,ctl.Aims,16,dcSPC|dcOPT_
;     2,  <>,		cu_boo, <>,	0, dcEOL_
;
;	dc_vrb
;	dc_qua>dc_sym>Pfun()>dc_act
;
;	dc_act>Pfun()>dc_act?
;
;	Called by DC_ACT() in the function field
;	Each DCL pass results in at most one action.

  func	dc_act
	dcl : * dcTdcl~
  is	itm : * dcTitm~ = dcl->Pitm
	nst : * dcTitm
	dcl->Pqua = itm			; point to qualifiers
     repeat
	fail if !dc_qua (dcl)		; pick up qualifiers
	if !itm->Pkwd			; not a lookup entry
	&& itm->Pfun ne			; and has a function
	   if !dc_eol (dcl, itm)	; needed EOL
	   || !dc_nst (dcl, itm)	;
	   .. fail dc_inv (dcl)		;
	   dc_flg (dcl, itm)		; process flags
	   (*itm->Pfun)(dcl)		; call function
	   pass fail			;
	end				;
	itm = dc_adv (dcl, itm)		; skip item
	fine if fail			; no more items
	dcl->Pitm = itm
     forever
  end

code	dc_fld - process field

;    1,	"BO*OT",	dc_act, <>,	0, dcNST_
;     2,  <>,		dc_fld,ctl.Aims,16,dcSPC|dcOPT_
;
;	o Parse field object (may be optional)
;	o Parse field terminating qualifiers

  func	dc_fld
	dcl : * dcTdcl~
  is	fail if !dc_obj (dcl, dcl->Pitm);
	reply dc_qua (dcl)		; pickup qualifiers
  end

code	dc_flg - process item control flag

;	Flags are accepted for any activated P1 function
;	or any accepted qualifier

  func	dc_flg
	dcl : * dcTdcl
	itm : * dcTitm
  is	flg : int~ = itm->Vctl & dcFLG_
	dcl->Vflg |= BIT(flg) if flg
  end
code	dc_atr - process qualifier or keyword attributes

;	/xxx=value
;	/xxx=x:y:z
;	/xxx

  func	dc_atr
 	dcl : * dcTdcl~
  is	itm : * dcTitm~ = dcl->Pitm
	ctl : int~ = itm->Vctl

	if itm->Vctl & dcDFT_		; handle default
	.. *<*WORD>itm->P1 = itm->V1	;
					;
	if *dcl->Prem ne '='		; no value follows
	&& *dcl->Prem ne ':'		; no value follows
	   fine if ctl & dcOPT_		; was optional anyway
	.. fail dc_inv (dcl)		;
	++dcl->Prem			; skip : or =
	reply dc_obj (dcl, itm)		;
  end

code	dc_val - process qualifier value

;	process field values, and attributes

  func	dc_val
	dcl : * dcTdcl~
  is	itm : * dcTitm~ = dcl->Pitm

;	if dcl->Vatr & dcDFT_		; handle default
;	.. *<*WORD>itm->P1 = itm->V1	;
	reply dc_obj (dcl, itm)		;
  end

code	dc_set - set *P1 opr V1

;			       P1        V1
;     2,  "/FU*LL",	dc_set,&ctl.Qful,1, dcOPT_

  func	dc_set
	dcl : * dcTdcl
  is	itm : * dcTitm~ = dcl->Pitm
	ptr : * int~ = <*int>itm->P1
	val : int~ = itm->V1
	case itm->Vctl & dcTYP_
	of dcNOP
	or dcSET *ptr  =  val
	of dcBIS *ptr |=  val
	of dcBIC *ptr &= ~val
	of dcAND *ptr &=  val
	of dcNEG *ptr  = -val
	end case
	fine
  end
code	dc_obj - parse and convert object

  func	dc_obj
	dcl : * dcTdcl~
	itm : * dcTitm~
  is	typ : int~ = itm->Vctl & dcTYP_
	dc_skp (dcl)			; skip spaces
	if !*dcl->Prem			; got more coming
	   fine if itm->Vctl & dcOPT_	; yes - okay if optional
	else				;
	   typ eq dcSPC ? dcAspc ?? dcAidt ; choose syntax
	   if dc_par (dcl, that, typ)	; parse field
	   && dc_cvt (dcl, itm)		; convert value
;PUT("rem=[%s]\n", dcl->Prem)
	.. .. fine
	fail dc_inv (dcl)
  end

code	dc_cvt - convert value

  init	dcAcvt : [] * char
  is 	(0)		; none
	"%o%n%*s"	; dcOCT
	"%d%n%*s"	; dcDEC
	"%h%n%*s"	; dcHEX
;	<>		; dcR50
;	<>		; dcSTR
;	<>		; dcFLG
  end

  func	dc_cvt
	dcl : * dcTdcl
	itm : * dcTitm
  is	obj : * char~ = dcl->Pobj
	dst : * int~ = itm->P1
	typ : int~ = itm->Vctl & dcTYP_
	bas : int = 0
	res : int = 1				; assume fine
	cnt : int
	case typ				; process via type
	of dcNOP  nothing			;
	of dcOCT  bas = 8			;
	of dcDEC  bas = 10			;
	of dcHEX  bas = 16			;
	of dcR50  res = 0			; rad50
	of dcSTR				; string
	or dcSPC  res=0 if st_len(obj) ge itm->V1; too long
		  st_cop (obj, <*char>dst) otherwise ; spec
	end case				;
	reply res if !bas			;
	st_val (obj, bas, dst, &cnt)		; convert value
	pass fail				; no go
	reply cnt eq st_len (obj)		;
  end
code	dc_par - parse string

;	Extract either a string in double-quotes
;	or a command item (using syntax filter syn)
;	Result in dcl->Aobj
;	dcl->Prem points to command remainder
;
;	fail	did not collect an object

  func	dc_par
	dcl : * dcTdcl~
	syn : * char
	typ : int
  is	rem : * char~ = dcl->Prem
	cnt : int
	dc_skp (dcl)			; skip space
	dcl->Pobj = dcl->Aobj		; reset pointer
	if *rem eq '\"'			; got quoted string?
	   cnt = st_bal (rem) - rem	; yes - skip it
	   if cnt ge 31			;
	      cnt = -1			;
	   else				;
	   .. st_cln (rem,dcl->Pobj,cnt); clone result
	else				;
;	.. cnt = st_flt (syn, rem, dcl->Pobj, -32)
	.. cnt = st_flx (syn, "[],", rem, dcl->Pobj, -32)
	fail dc_inv (dcl) if cnt le	; report the error
	dcl->Prem += cnt		; skip the field
	fine dc_skp (dcl)		; skip next space
  end

code	dc_skp - skip space

  func	dc_skp
	dcl : * dcTdcl~
  is	++dcl->Prem if *dcl->Prem eq ' '
  end
code	dc_adv - advance to next item

;	Find the next item at this level
;	Skip over items with a higher indent number
;	Terminate if an item with a lower indent number is seen

  func	dc_adv
	dcl : * dcTdcl
	itm : * dcTitm~
	()  : * dcTitm
  is	ptr : * dcTitm~ = itm
	repeat
	   ++ptr
	   reply ptr if ptr->Vlev eq itm->Vlev  ; found another
	   fail if ptr->Vlev lt itm->Vlev	; no more at this level
	forever
  end

code	dc_nst - nest in

;	1
;	 2
;	  3
;
;	Can't nest at level 0

  func	dc_nst
	dcl : * dcTdcl
	itm : * dcTitm~
  is	nst : * dcTitm = itm + 1	; next item in array
	fine if !(itm->Vctl & dcNST_)	;
	fail if !nst->Vlev		; sanity test 
	dcl->Pitm = itm			;
	fine if itm->Vlev ge nst->Vlev	; syntax doesn't nest
	fine dcl->Pitm = nst		; nest
  end

code	dc_eol - validate EOL, set dcFIN

;	Remainder must be empty if EOL flag set

  func	dc_eol
	dcl : * dcTdcl
	itm : * dcTitm
  is	dcl->Venv |= (itm->Vctl & dcFIN_)
	fine if !(itm->Vctl & dcEOL_)
	reply *dcl->Prem eq
  end
code	dc_alc - allocate DCL object

  func	dc_alc
	()  : * dcTdcl
  is	reply me_acc (#dcTdcl)
  end

  func	dc_dlc
	dcl : * dcTdcl
  is	me_dlc (dcl)
  end

code	dc_ini - initialize context

  func	dc_ini
   	dcl : * dcTdcl~
  is	itm : * dcTitm = dcl->Pitm
	typ : int
	dcl->Vflg = 0
	dcl->Verr = 0
	dcl->Plin = dcl->Alin
	dcl->Prem = dcl->Plin
	dcl->Pobj = dcl->Aobj
	dcl->Pqua = <>
;	dcl->Alin[0] = 0
	dcl->Aobj[0] = 0

;	Reset variables

     while itm->Vlev
	next ++itm if !itm->P1
	typ = itm->Vctl & dcTYP_
	if itm->Pfun eq &dc_set
	.. typ = dcOCT
	case typ
	of dcOCT
	or dcDEC
	or dcHEX
	or dcR50
	of dcSTR
	or dcSPC
	   me_clr (itm->P1, 2)
	end case
	++itm
     end
  end
code	callbacks

  func	dc_fin
	dcl : * dcTdcl
  is	fine
  end

  func	dc_exi
	dcl : * dcTdcl~
  is	im_exi ()
  end

  func	dc_rep
	dcl : * dcTdcl~
  is	im_rep (dcl->Pitm->P1, <>)
	fine
  end

  func	dc_hlp
	dcl : * dcTdcl~
  is	ptr : ** char~ = dcl->Pitm->P1
	PUT("%s\n", *ptr++) while *ptr
	fine
  end

  func	dc_dbg
	dcl : * dcTdcl~
	tit : * char
  is	exit if !(dcl->Venv & dcDBG_)
	PUT("DCL: %s ", tit)
	dc_put (dcl, dcl->Pitm)
  end

  func	dc_dbs
	dcl : * dcTdcl~
	tit : * char
	str : * char
  is	exit if !(dcl->Venv & dcDBG_)
	PUT("DCL: %s=[%s] ", tit, str)
	dc_put (dcl, dcl->Pitm)
  end

  func	dc_dbv
	dcl : * dcTdcl~
	tit : * char
	val : int
  is	exit if !(dcl->Venv & dcDBG_)
	PUT("DCL: %s=%d ", tit, val)
	dc_put (dcl, dcl->Pitm)
  end

  func	dc_put
	dcl : * dcTdcl~
  	itm : * dcTitm~
  is	PUT("Rem=[%s] ", dcl->Prem)
	PUT("Obj=[%s] ", dcl->Pobj) if dcl->Pobj
	if itm
	   PUT("Itm: ")
	   PUT("Lev=%d ", itm->Vlev)
	   PUT("Kwd=[%s] ", itm->Pkwd) if itm->Pkwd
	   PUT("Val=%d ", itm->V1)
	.. PUT("Ctl=%o ", itm->Vctl)
	PUT("\n")
  end
end file
