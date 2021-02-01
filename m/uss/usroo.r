file	usroo - utilities root
include	usb:usmod
include	rid:codef
If Dos
include	rid:kidef
End

data	qualifiers
	cuFque	: int = 0	; /query collection

	quFall	: int = 0	; /all			all
	quFany	: int = 0	; /any			all
	quFbin	: int = 0	; /binary
	quFbar	: int = 0	; /bare			   lst cmp sea
	quFbig	: int = 0	; /big			all
	quFbyt	: int = 0	; /byte			       dmp	
	quFdat	: int = 0	; /date			   lst
	quFdbg	: int = 0	; /debug
	quFdec	: int = 0	; /decimal		       dmp	
	quFdtb	: int = 0	; /detab
	quFdir	: int = 0	; /directory		atr
	quFdou	: int = 0	; /double		    prn
	quFdwn	: int = 0	; /down					srt
	quFeps	: int = 0	; /epson		    prn
	quFfor	: int = 0	; /force
	quFfre	: int = 0	; /free
	quFfst	: int = 0	; /first		        dmp
	quFful	: int = 0	; /full			    lst cmp sea
	quFhex	: int = 0	; /hex			    lst
	quFimg	: int = 0	; /image		    lst
	quFlog	: int = 0	; /log			all
	quFlng	: int = 0	; /long			       dmp	
	quFnew	: int = 0	; /new			all
	quFoct	: int = 0	; /octal		       dmp	
	quFold	: int = 0	; /old			all
	quFpau  : int = 0	; /pause		all
	quFpee	: int = 0	; /peek			    lst
	quFque  : int = 0	; /query		all except dir/list
	quFnqr	: int = 0	; /noquery		all
	quFqui	: int = 0	; /quiet
	quFrep	: int = 0	; /replace		    cop ren
	quFnrp	: int = 0	; /noreplace		    cop ren
	quFrev	: int = 0	; /reverse		srt
	quFsma	: int = 0	; /small		all
	quFtim	: int = 0	; /time			    lst
	quFtit	: int = 0	; /title		    lst	
	quFtrm	: int = 0	; /trim					srt
	quFtot	: int = 0	; /totals			cmp sea
	quFuse  : int = 0	; /use			    lst
	quFvrb	: int = 0	; /verbose
	quFwid	: int = 0	; /wide (dos)		    lst
	quFwrd	: int = 0	; /word				?
				;
	quVfro	: int = 0	; /from=column				srt
	quVlft	: int = 0	; left indent			prn
	quVtop	: int = 0	; top indent			prn
				;
	quFlst	: int = 0	; listing
	quFvie	: int = 0	; review
	quFsiz	: int = 0	; sizes in listing
	quFacc	: int = 0	; accumulators
				;
	quFcop	: int = 0	; transfer=copy
	quFren	: int = 0	; transfer=rename
	quFmov	: int = 0	; transfer=move

	quVlin  : int = 0	; line in page
				;
	quVatr	: int = 0	; attributes
	quVcat	: int = 0	; attrs to clear
	quVsat	: int = 0	; attrs to clear
	quVcol	: int = 0	; columns
	quVsrt	: int = 0	; sort criteria
				;	
	cuPsrc	: * cuTctx = <>	; source context
	cuPdst	: * cuTctx = <>	; destination context

code	kw_hlp - display help

  init	cuAhp0 : [] * char
  is	"US - file utilities"
	""
	<>
  end

  init	cuAhp1 : [] * char
  is	"change    path...  /directory"
	"compare   old new  /all/full/totals"
	"                   /directory/binary"
;	"copy      from to  "
	"count     path     /all/full/totals"
	"create    file     /directory"
	"delete    path     /directory"
	"detab     from to  /directory"
	"dump      path     /first"
	"differ    old new  /all/full/totals"
	"directory path     /bare/free/full/wide"
	"kopy      from to  (simple copy)"
	"make      path     /directory"
	"list      path     /date/size/time"
	"                   /peek/title/usage"
	"help"
	"move      old new"
	"protect   path"
	"remove    path      /directory"
	"rename    old new    "
	"review    path       "
	"search    path text /all/full/totals"
	"see       path       "
	"show                /directory"
	"sort      path      /from=n/down/trim"
	"touch     path       "
	"truncate  path      (autoquery)"
	"type      path       "
	"unprotect path"
	"zap       d:\\dir"
	""
	<>
  end

  init	cuAhp2 : [] * char
  is	""
	"query:    /any /query /force (Yes No All Quit)"
	"attrs:    /archive /directories /hidden /readonly /system /volume"
	"other:    /new /old /big /small /[no]replace" ;/exclude
	"order:    /chronological /names /reverse /spatial /type"
 	<>
  end

code	kw_hlp - display help

  func	kw_hlp
	ctx : * cuTctx			;
  is	hlp : ** char			;
	lft : ** char			; 
	rgt : ** char			;
	len : int = 0			;
	hlp = cuAhp0			;
	puts (*hlp++) while *hlp	;
					;
	lft = hlp = cuAhp1		; two column help
	++len while *hlp++ 		; count them
	rgt = lft + (len /= 2)		; right
	while len--			; got more
	   printf ("%-40s", *lft++)	; the left part
	   puts (*rgt++) if *rgt	;
	end				;
					;
	hlp = cuAhp2			;
	puts (*hlp++) while *hlp	;
  end
code	main

	cu_exi	: (void) void own

  proc	main
	cnt : int
	vec : ** char
  is	cuPsrc = cu_ctx ()		; source context
	cuPdst = cu_ctx ()		; destination
	im_ini ("US")			; setup
	co_ctc (coENB)			;
;	ab_enb ()			; enable aborts
	imPexi = &cu_exi		; exit routine
;V4	ki_ini ()			; catch aborts
	cu_cmd (cuPsrc, cnt, vec)	; handle command
	im_exi ()			;
  end

code	cu_exi - exit routine

  proc	cu_exi
  is	ki_exi ()			; exit keyboard interface
  end

code	cu_abt - check abort

  proc	cu_abt
  is	im_exi () if ki_ctc ()		; ctrl/c check
  end

code	cu_ctx - make a context

  func	cu_ctx
	()  : * cuTctx
  is	ctx : * cuTctx = me_acc (#cuTctx)
	ctx->Pcmd = me_acc (mxLIN)	;
	ctx->P1   = me_acc (mxLIN)	;
	ctx->P2   = me_acc (mxLIN)	;
	ctx->P3   = me_acc (mxLIN)	;
	ctx->Ppth = me_acc (mxLIN)	;
	ctx->Pspc = me_acc (mxLIN)	;
	ctx->Ptar = me_acc (mxLIN)	;
	ctx->Pobf = me_acc (mxLIN*2)	;
	ctx->Phdr = me_acc (mxLIN)	;
	reply ctx
  end
code	cu_cmd - get command

  type	cuTkwd
  is	Vtag : int
	Pnam : * char
	Vmin : int
	Vmax : int
	Pfun : * cuTrou
	Ppre : * cuTrou
	Ppos : * cuTrou
	Pjoi : * char
  end

  init	cuAkwd : [] cuTkwd
;		tag	nam		min max fun	pre	pos joi		
  is	kwCHG: kwCHG, "cha*nge",	 0, 9, <>,	&kw_chg,<>,<>
	kwCMP: kwCMP, "com*pare",	 2, 2, &kw_cmp, &su_cmp,<>, "with"
	kwCOP: kwCOP, "cop*y",		 2, 2, &kw_tra, &su_tra,<>, "to"
	kwCNT: kwCNT, "cou*nt",		 1, 1, &kw_cnt, <>,	<>,<>
	kwCRE: kwCRE, "cr*eate",	 1, 1, <>,	&su_cre,<>,<>
;	define
	kwDEL: kwDEL, "del*ete",	 1, 1, &kw_del, <>,	<>,<>
	kwDTB: kwDTB, "det*ab",		 2, 2, &kw_edt, &su_edt,<>,"to"
	kwDMP: kwDMP, "du*mp",		 1, 1, &kw_dmp, <>,	<>,<>
	kwDIF: kwDIF, "dif*fer",	 2, 2, &kw_dif, &su_cmp,<>, "with"
	kwDIR: kwDIR, "di*rectory",	 0, 1, <>,	<>,	<>,<>
;	kwKOP: kwKOP, "kop*y",		 2, 2, &kw_kop, &su_kop,<>,"to"
	kwLST: kwLST, "li*st",		 0, 1, <>,	<>,	<>,<>
	kwMAK: kwMAK, "mak*e",		 1, 1, <>,	&kw_mak,<>,<>
	kwMOV: kwMOV, "mo*ve",		 2, 2, &kw_tra, &su_tra,<>,"to"
	kwHLP: kwHLP, "he*lp",		 0, 0, <>,	&kw_hlp,<>,<>
	kwREM: kwREM, "rem*ove",	 1, 1, <>,	&kw_rem,<>,<>
	kwREN: kwREN, "ren*ame",	 2, 2, &kw_tra, &su_tra,<>,"to"
	kwREV: kwREV, "rev*iew",	 1, 1, &kw_typ, <>,	<>,<>
	kwPRN: kwPRN, "pr*int",		 1, 2, &kw_prn, <>,	<>,<>
	kwPRO: kwPRO, "prot*ect",	 1, 1, &kw_atr,	<>,	<>,<>
	kwSEA: kwSEA, "sea*rch",	 2, 2, &kw_sea, &su_sea,<>,"for"
	kwSEE: kwSEE, "see",		 1, 1, &kw_see, <>,	<>,<>
	kwSHO: kwSHO, "sh*ow",		 0, 1, <>,	&kw_sho,<>,<>
	kwSRT: kwSRT, "sor*t",		 1, 1, &kw_srt, <>,	<>,<>
	kwTOU: kwTOU, "tou*ch",		 1, 1, &kw_tou, <>,	<>,<>
	kwTRU: kwTRU, "tru*ncate",	 1, 1, &kw_tru,	<>,	<>,<>
	kwTYP: kwTYP, "ty*pe",		 1, 1, &kw_typ, <>,	<>,<>
	kwUNP: kwUNP, "unpr*otect",	 1, 1, &kw_atr,	<>,	<>,<>
	kwZAP: kwZAP, "zap",		 1, 1, &kw_zap, &su_zap,&pu_zap, <>
	kwINV: kwINV, 	<>,		 0, 0, <>,	<>,	<>,<>
  end

;	compare/directories

  init	kwSvar : cuTkwd
  is		kwCMP, "compare/dir",	 2, 2, <>,	&kw_var,<>, "with"
  end

  func	cu_cmd
	ctx : * cuTctx
	cnt : int
	vec : ** char
  is	qua : ** char = vec
	kwd : * cuTkwd = cuAkwd
	cmd : * char
	++vec				; skip image name
	cmd = ctx->Pcmd			;
	vec = cu_arg (ctx, vec, cmd)	; get some things
	vec = cu_arg (ctx, vec, ctx->P1); 
	vec = cu_arg (ctx, vec, ctx->P2);
	vec = cu_arg (ctx, vec, ctx->P3);
	cu_err (E_MisCmd, <>) if *cmd eq; aint no command
	--ctx->Varg			; keyword is not an argument
					;
	repeat				;
	   if kwd->Pnam eq <>		; not found
	   .. cu_err (E_InvCmd, ctx->Pcmd)
	   quit if cl_mat (cmd, kwd->Pnam) ; found it
	   ++kwd			; next
	end				;
					;
	if quFdir			; directory land
	   case kwd->Vtag		;
	   of kwCMP  kwd = &kwSvar	;
		     ++quFacc		;
	   of kwCRE  kwd = &cuAkwd[kwMAK]
	   of kwDEL  kwd = &cuAkwd[kwREM]
	   of kwCHG
	   or kwDIR
	   or kwSHO
	   of other nothing
	.. end case

;	if kwd->Vtag eq kwCMP		; compare
;	&& quFdir			; /directories
;	   ++quFacc			;
;	.. kwd = &kwSvar		; vary

	ctx->Pfun = kwd->Pfun		; the routine
	ctx->Pjoi = kwd->Pjoi		;
	st_cop (kwd->Pnam, ctx->Pcmd)	; get a copy of the command name
	st_rep ("*", "", ctx->Pcmd)	; remove wildcards
	*ctx->Pcmd = ch_upr (*ctx->Pcmd); cap it
	if ctx->Varg lt kwd->Vmin	; too few
	|| ctx->Varg gt kwd->Vmax	;
	.. cu_err (E_InvCnt, ctx->Pcmd)	; forget it
					;
	case kwd->Vtag			; some simple preprocessing
	of kwCMP  ++quFacc		; has accumulators
	of kwCNT  ++quFacc		; has accumulators
	of kwCRE  cu_wld (ctx, 0)	; ban wildcards
	of kwDEL			;
	or kwTRU  cu_wld (ctx, 1)	; autoquery wildcards
	of kwDIR  ++quFsiz		; wants sizes
	or kwLST  ++quFlst		; is a listing
		  if !*ctx->P1		; default it
		     st_cop ("*.*", ctx->P1)
		  .. ++ctx->Varg	; and count it
	of kwPRO  quVsat = drRON_	; protect
	of kwREV  ++quFvie		; review 
	of kwSEA  ++quFacc		; search has totals
	of kwUNP  quVcat = drRON_|drSYS_|drHID_ ; unprotect
	of kwCOP ++quFcop		; transfer=copy
	of kwMOV ++quFmov		; transfer=move
	of kwREN ++quFren		; transfer=rename
	of kwDTB ++quFdtb		; edit=detab
	end case			;
	quFque = 0 if quFfor || quFany	; noquery default
	quFque = 0 if quFnqr		;
	quFque |= cuFque	; ???	; explicit query
	quFqui = 1 if quFany		; any is usually quiet
	quFqui = 1 if quFbar && !quFlog	; quiet
	quFqui = 0 if quFlog		; but report overrides it all
					;
	if kwd->Ppre ne <>		; got a preprocessor
	   fail if !(*kwd->Ppre)(ctx)	; preprocessor completed it
	.. fail if kwd->Pfun eq 	; that was all
	cu_scn (ctx)			; scan files
	if kwd->Ppos ne <>		; got one
	.. fail if !(*kwd->Ppos)(ctx)	; post process
	fine				; more to do
  end
code	cu_arg - command argument

  type	cuTqua
  is	Vtag : int
	Pnam : * char
	Pflg : * int		; flag/value
	Vopt : int		; quREQ/quOPT
	Vsrt : int		; sort criteria
	Vatr : int		; selection attributes
	Vcol : int		; columns
  end
	quREQ	:= BIT(0)	; required value
	quOPT	:= BIT(1)	; optional value

;	quBLK:	quBLK, "bl*ock",	&quFblk, 0,	0,	0

  init	cuAqua : [] cuTqua		; flg    opt	srt	atr	col
  is	quALL:	quALL, "al*l",		&quFall, 0,	0,	drALL_,	0
	quANY:	quANY, "any",		&quFany, 0,	0,	0,	0
	quARC:  quARC, "ar*chive",	<>,	 0,	0,	drARC_,	0
	quCHR:  quCHR, "ch*ronological",&quFtim, 0,	drTIM,	0,	1
	quBAR:	quBAR, "ba*re",		&quFbar, 0,	0,	0,	1
	quBIG:	quBIG, "bi*g",		&quFbig, 0,	0,	0,	1
	quBIN:	quBIG, "bi*nary",	&quFbin, 0,	0,	0,	1
	quBYT:	quBYT, "by*tes",	&quFbyt, 0,	0,	0,	1
;	quCNT:  quCNT, "co*unt",	&quFcnt, 0,	0,	0,	0
	quDAT:  quDAT, "da*te",	 	&quFdat, 0,	0,	0,	0
	quDBG:	quDBG, "deb*ug",	&quFdbg, 0,	0,	0,	0
	quDEC:	quDEC, "dec*imal",	&quFdec, 0,	0,	0,	0
	quDIR:  quDIR, "di*rectory",    &quFdir, 0,	0,	drDIR_,	0
	quDOU:	quDOU, "do*uble",	&quFdou, 0,	0,	0,	0
	quDWN:  quDWN, "dow*n",		&quFdwn, 0,	0,	0,	0
	quEPS:  quEPS, "epson",		&quFeps, 0,	0,	0,	0
	quFST:	quFST, "fi*rst",	&quFfst, 0,	0,	0,	0
	quFOR:	quFOR, "for*ce",	&quFfor, 0,	0,	0,	0
	quFRE:  quFRE, "fre*e",		&quFfre, 0,	0,	0,	0
	quFRO:	quFRO, "fro*m",		&quVfro, quREQ,	0,	0,	0
	quFUL:	quFUL, "fu*ll",		&quFful, 0,	0,	0,	1
	quHID:  quHID, "hi*dden",	<>,	 0,	0,	drHID_,	0
	quHEX:  quHEX, "he*x",		&quFhex, 0,	0,	0,	0
	quIMG:  quIMG, "im*age",	&quFimg, 0,	0,	0,	0
	quLFT:	quLFT, "le*ft",		&quVlft, quREQ,	0,	0,	0
	quLOG:	quLOG, "log",		&quFlog, 0,	0,	0,	0
	quLNG:	quBYT, "lon*g",		&quFlng, 0,	0,	0,	1
	quNAM:  quNAM, "na*mes",	<>,	 0,	drNAM,	0,	0
	quNEW:	quNEW, "n*ew",		&quFnew, 0,	0,	0,	0
	quOCT:	quBYT, "oc*tal",	&quFoct, 0,	0,	0,	1
	quPAU:  quPAU, "pa*use",	&quFpau, 0,	0,	0,	0
	quPEE:  quPEE, "pe*ek",		&quFpee, 0,	drTYP,	0,	1
	quOLD:	quOLD, "old",		&quFold, 0,	0,	0,	0
	quRON:	quRON, "rea*donly",	<>,	 0,	0,	drRON_,	0
	quREV:  quREV, "re*verse",	&quFrev, 0,	0,	0,	0
	quQUI:	quQUI, "qui*et",	&quFqui, 0,	0,	0,	0
	quQUE:  quQUE, "qu*ery",	&cuFque, 0,	0,	0,	0
	quNQR:  quQUE, "noqu*ery",	&quFnqr, 0,	0,	0,	0
	quREP:	quREP, "rep*lace",	&quFrep, 0,	0,	0,	0
	quNRP:	quNRP, "norep*lace",	&quFnrp, 0,	0,	0,	0
	quSIZ:  quSIZ, "si*ze",		&quFsiz, quOPT,	0,	0,	4
	quSMA:	quSMA, "sm*all",	&quFsma, 0,	0,	0,	0
	quSPA:  quSPA, "sp*atial",	&quFsiz, 0,	drSIZ,	0,	4
	quSYS:  quSYS, "sy*stem",	<>,	 0,	0,	drSYS_,	0
	quTIM:	quTIM, "tim*e",		&quFtim, 0,	0,	0,	1
	quTIT:	quTIT, "tit*le",	&quFtit, 0,	drTYP,	0,	1
	quTRM:	quTRM, "tr*im",		&quFtrm, 0,	0,	0,	0
	quTOP:	quTOP, "top",		&quVtop, quREQ,	0,	0,	0
	quTOT:  quTOT, "tot*als",	&quFtot, 0,	0,	0,	0
	quTYP:  quTYP, "ty*pe",		<>,	 0,	drTYP,	0,	0
	quUSE:  quUSE, "us*e",		&quFuse, 0,	drTYP,	0,	1
	quVRB:	quVRB, "v*erbose",	&quFvrb, 0,	0,	0,	6
	quVOL:	quVOL, "vo*lume",	<>,	 0,	0,	drVOL_,	0
	quWID:	quWID, "wi*de",		&quFwid, 0,	0,	0,	6
	quWRD:	quWRD, "wo*rd",		&quFwrd, 0,	0,	0,	0
	quINV:	quINV,	<>,		<>,	 0,	0,	0,	0
  end
	cu_qua	: (*cuTctx, *char) void own
	cu_val	: (*cuTqua, **char) void

  func	cu_arg
	ctx : * cuTctx
	vec : ** char
	arg : * char
 	()  : ** char
  is	*arg = 0			; assume none
      repeat				;
	quit if *vec eq <> 		; done
	cu_qua (ctx, *vec)		; strip qualifiers
	st_cop (*vec++, arg)		; copy the parameter
	st_trm (arg)			; remove spaces
	quit ++ctx->Varg if *arg	; count arguments
      end				; loop for argument
	reply vec			;
  end

code 	cu_qua - get qualifiers

  proc	cu_qua
	ctx : * cuTctx			;
 	fld : * char			; command field
  is	buf : [mxLIN] char		;
	dst : * char			; 
	qua : * cuTqua			;
	atr : int = 0			;
	while fld ne <> && *fld ne 	; got more
	   next fld++ if *fld ne '/'	; no slash
	   *fld++ = 0			; dump it
;	   st_ext ("pb", "AD", fld, dst); grab the qualifier
	   dst = buf			;
	   while ct_aln (*fld)		;
	   .. *dst++ = *fld++		; copy it
	   *dst = 0			;
	   st_low (buf)			; get our kind of name
	   qua = cuAqua			; the qualifiers
	   repeat			;
	      if qua->Pnam eq <>	; not found
	      .. cu_err (E_InvQua, buf)	; invalid qualifier
	      quit if cl_mat (buf, qua->Pnam) ; found it
	      ++qua			; next
	   end				;
	   if qua->Vopt			; got an option
	      cu_val (qua, &fld)	; get the value
	   else				;
	   .. ++*qua->Pflg if qua->Pflg	; set any flags
					;
	   if qua->Vsrt && !quVsrt	;
	   .. quVsrt = qua->Vsrt	; setup the sort
	   if qua->Vcol && !quVcol	; single
	   .. quVcol = qua->Vcol	;
	   quVatr |= qua->Vatr		;
					;
	   case qua->Vtag		; specials
	   of quCHR  ++quFsiz		; needs size too
	   of quLFT  if quVlft gt mxLIN
		     .. cu_err (E_RngVal, qua->Pnam)
	   of quTOP  if quVtop gt 20	;
		     .. cu_err (E_RngVal, qua->Pnam)
	   end case			;
	end				;
  end

code	cu_val - extract value

  proc	cu_val
	qua : * cuTqua
	fld : ** char
  is	str : * char = *fld
	val : * int = qua->Pflg		; the value
	*val = 0			;
	if *str++ ne '='		; missing =
	   exit if qua->Vopt & quOPT	; its optional
	.. cu_err (E_MisVal, qua->Pnam)	;
	if !ct_dig (*str)		; no digit
	.. cu_err (E_InvVal, qua->Pnam)	; no value
	while ct_dig (*str)		;
	   *val = (*val * 10) + *str++ - '0'
	end				;
	*fld = str			;
  end
