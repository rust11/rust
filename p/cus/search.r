;+++;	CUS:SEARCH - /replace="string"/output=path
;+++;	CUS:SEARCH - Use /F to specify RSX/VMS formatted ascii
;???;	CUS:SEARCH - move to windows with DCL
;???;	CUS:SEARCH - needs sub-directory wildcard search
.if ne 0
file	search - search files
include	rid:rider
include rid:ctdef
include	rid:fidef
include	rid:fsdef
include	rid:imdef
include	rid:medef
include	rid:mxdef
include	rid:rtcla
include	rid:rtcsi
include	rid:rtscn


;	%build
;	goto 'P1'
;	macro cus:search.r/object:cub:search.inf
;	rider cus:search/obj:cub:
;	link:
;	link cub:search(.obj,.inf)/exe:cub:/map:cub:,lib:crt/bot:2000/cross
;	%end

.title	search
.include "lib:rust.mac"

	$imgdef	SEARCH 2 0
	$imginf	fun=sav use=<RUST search utility SEARCH.SAV V2.0>
	$imgham	yrs=<2008> oth=<>
;	%date
	$imgdat	<15-Jun-2022 18:13:17>   
;	%edit
	$imgedt	<60   >
.end
end macro

data	general

  type	utTipt			; input
  is	Pspc : * char		; file spec
	Pdis : * char		; display spec
	Icla : fsTcla		; filespec class
	Hfil : * FILE		; file
	Vnew : int		; new title required
	Vcnt : int		; instances found
	Vlin : int		; line number
  end

  type	utTopt			; output
  is	Pspc : * char		; terminal if null
	Pdis : * char		; display spec
	Hfil : * FILE		; file
	Iext : fxText		; extension block for allocation
  end

  type	utTmod			; string model
  is	Psuc : * utTmod		; next
	Vwld : int		; wildcard search
	Pmod : * char		; model (lower case if !ctl.Vexa)
	Prep : * char		; report version
	Vlen : int		; string length
  end

  type	utTnum			; numeric model
  is	Psuc : * utTnum		;
	Vval : WORD		;
	Prep : * char		;
  end

  type	utTctl			; app control
  is	Vand : int		; /all
	Vnor : int		; /none
	Vior : int		; /any
	Vnan : int		; /some
	Vxor : int		;
	Veqv : int		;
				;
	Vexa : int		; /exact
	Vpln : int		; /plain
	Vpat : int		; /pattern=string
				;
	Vver : int		; /verify
				;
	Vbin : int		; /binary
	Vlst : int		; /list
	Vlin : int		; /lines
	Vhea : int		; /noheading
	Vnum : int		; /numbers
	Vpos : int		; /position (file location)
	Vwrd : int		; /word
	Vwin : int		; /window
;	Vctx : int		; /context=n
				;
	Vpas : int		; /passall
				;
	Vopt : int		; output
	Vtot : int		; total count
	Vmax : int		; maximum count
	Vtst : int		; See utNOR etc below
	Pmod : * char		; search model
				;
	Pnum : * utTnum		; /binary number list
 end

	utNOR := 1		; test codes
	utAND := 2		;
	utIOR := 3		;
	utNAN := 4
	utXOR := 5
	utEQV := 6

	ipt : utTipt = {0}
	ctl : utTctl = {0}
	csi : csTcsi = {0}
	opt : utTopt = {0}

	utImem : meTctx = {0}
	utIpas : meTctx = {0}
	utIimg : imTctx = {0}
	utPscn : * rtTscn = {0}

	ut_fnd : (*utTmod, *char) int
	ut_loc : (*char, *char) int
	ut_put : (*char, *char)
	ut_mod : ()
	ut_num : ()
	ut_wld : ()
	ut_eng : ()
	ut_bin : ()

  func	ut_ovr
  is	im_res (&utIimg, -1)
  end

  func	ut_put
	str : * char
	obj : * char
  is	PUT(str, obj)                if !ctl.Vopt
	fprintf (opt.Hfil, str, obj) otherwise
  end
data	info

;minrite errors???
;
;	For line listings do file once to get count, then to display
;
; cts	formatted ascii
;	Vwin (lines=n)
;
;	/WILD
;	/STRICT
;
;	/FORMAT=PASSALL|TEXT
;
;	/BY_OWNER
;	/HIGHLIGHT
;	/LIMIT=n	/MAXIMUM
;	/LOG		/LIST
;	/PAGE		Screen edit
;	/REMAINING
;	/SKIP
;
;	/KEY=(position=n,size=n)
;	/POSITION	Character position in file
;	/QUIET		Report status only
;
;	/NOWILD		Ignore wildcard escapes
;
;	/HELP	Display syntax 
;	/XOR	
;	/NOXOR	
;
;	/[NO]WILD="!"
;
;	"...'"..."
;	\* \%
;	\"	
;	\s	space
;	\t	tab
;	\w	whitespace
;	\[ \]	start/end of line
;	\< \>	start/end of word
;
;	~* ~%
;	~"	
;	~s	space
;	~t	tab
;	~w	whitespace
;	~< ~>	start/end of word
;	~[ ~]	start/end of line
;
;	"'* '' '\", and use st_wld if wildcards included
;	regular expressions
;	cl_cmd () with no prompt to pick up initial command
;	cl_cmd () to then pick up strings
code	start - search

  func	start
  is 	swi : * csTswi
	val : WORD
	sig : int = 0			; memory overflow
	idx : int = 0			; input file index

	im_ini ("SEARCH")		; who we are
	im_clr ()			; clear status

	utPscn = rt_alc ()		; rt_scn permanent memory objects

	me_sav (&utImem)		; save memory context
     repeat
	sig = im_sav (&utIimg)		; save image context
					; non-zero result is signal
	fi_zap ()			; zap all channels
	me_res (&utImem)		; restore memory context
	if sig 				; memory overflow
	.. im_rep ("E-Insufficient memory", <>)
	me_sig (&ut_ovr)		; memory overflow routine
					;
	me_clr (&ctl, #utTctl)		;
	ctl.Vopt = 1			; /OUTPUT default
	ctl.Vwin = 0			; /WINDOW default
	ctl.Vnum = 1			;
	ctl.Vtst = utIOR		; default test
					;
;	me_clr (&ipt, #utTipt)		;
;	me_clr (&opt, #utTopt)		;
					;
	csi.Pnon = "ABEILNOPQSTUV"	; no value
	csi.Popt = ""			; optional value
	csi.Preq = "M"			; required value
	csi.Pexc = "ANS"		; mutually exclusive
	csi.Pidt = "?SEARCH-I-RUST search utility SEARCH.SAV V1.0"
	csi.Ptyp = "LSTLSTLSTTXT"	; default filetypes
					;
	cs_par (&csi, <>)		; parse command
	next if fail			;
	cs_val (&csi, 0010, 0771)	; req: 1*ipt+0*opt: 6*ipt+1*opt
	next if fail			;
	opt.Pspc = csi.Aopt[0].Pspc	; output file, if any
	opt.Pdis = csi.Aopt[0].Pdis	; output display spec
	opt.Iext.Valc = csi.Aopt[0].Valc;
					;
	ctl.Vhea = 1			; defaults
	swi = csi.Aswi			; process switchs
	while swi->Vcha			;
	   val = swi->Vval		;
;	/PLAIN to /NOWILD
;	/POSITION /O
	   case swi->Vcha		;
;	   of ...			; /ANY/OR
	   of 'A'  ctl.Vand = 1		; /ALL/AND
		   ctl.Vtst = utAND	;
	   of 'B'  ctl.Vbin = 1		; /BINARY
;	   of 'C'  ctl.Vexc = 1		; /EXCLUDE
;	   of 'D'  ctl.Vdat = 1		; /DATE:date
	   of 'E'  ctl.Vexa = 1		; /EXACT
;	   of 'F'			; /formatted ???
;	   of 'G'  ctl.Vreg = 1		; /REGULAR=pattern
	   of 'H'  ctl.Vhea = 0		; /NOHEADING
	   of 'I'  ctl.Vpln = 1		; /NOWILD
;	   of 'J'  ctl.Vsin = 1		; /SINCE=date
;	   of 'K'  ctl.Vbef = 1		; /BEFORE=date
	   of 'L'  ctl.Vlin = 1		; /LINES[=n]
		   ctl.Vlin = val if val;
	   of 'M'  ctl.Vmax = val	; /MAXIMUM=n
	   of 'N'  ctl.Vnor = 1		; /NONE /NOR
		   ctl.Vtst = utNOR	;
	   of 'O'  ctl.Vpos = 1		; /POSITION	Show file location
	   of 'P'  ctl.Vpas = 1		; /PASSALL	Ignored
	   of 'Q'  ctl.Veqv = 1		; /NXOR 	
		   ctl.Vtst = utEQV	;
;	   of 'R'  ctl.Vpat = 1		;?/PATTERN=string
	   of 'S'  ctl.Vnan = 1		; /SOME /NAND
		   ctl.Vtst = utNAN	;
	   of 'T'  ctl.Vlst = 1		; /LIST
	   of 'U'  ctl.Vnum = 1		; /NUMBERS
	   of 'V'  ctl.Vver = 1		; /VERIFY	Show file specs
	   of 'W'  ctl.Vwrd = 1		; /WORDS
	   of 'X'  ctl.Vxor = 1		; /XOR
	  	   ctl.Vtst = utXOR	;
	   end case			;
	   ++swi			; next switch
	end				;

	if ctl.Vlin && ctl.Vlst		; /LINES AND /LIST
	.. ctl.Vlst = 0			; ignore /LIST

	if ctl.Vopt			; want output
	   if opt.Pspc && !rt_ter (opt.Pspc)
	      opt.Hfil = fx_opn (opt.Pspc, "w", "", &opt.Iext)
	      next if fail
	   else
	.. .. opt.Hfil = stdout

	ut_num () if ctl.Vbin		; get binary models
	ut_mod () otherwise		; get search models

	while idx lt 6			;
	   ipt.Pspc = csi.Aipt[idx].Pspc; file specs
	   ipt.Pdis = csi.Aipt[idx].Pdis;
;PUT("[%s] [%s]\n", ipt.Pspc, ipt.Pdis)
	   ut_wld () if ipt.Pspc	; got a spec
	  ++idx
	end

	if ctl.Vopt
	   fi_clo (opt.Hfil, "") if opt.Pspc
	else
	.. fi_prg (opt.Hfil, "") if opt.Pspc

	ut_dlc ()			; deallocate stuff
     forever
  end
code	ut_mod - pick up search models

  func	ut_mod
  is	mod : * utTmod
	prv : * utTmod = <>
	lin : [82] char
	src : * char = lin
	str : [82] char
	dst : * char = mod
	ter : int
	wld : int 

      repeat
	cl_cmd ("Strings? ", src)
	prv = <>
	wld = 0
	while *src
	   ter = '\"', ++src if *src eq '\"'
	   ter = ',' otherwise
	   dst = str

	   while *src
	      quit if *src eq ter
	      if (*src ne '\\') || !src[1]
	         case *src
		 of '*'  ++wld
		 of '%'  ++wld
		 of '?'  ++wld
	         end case
	      .. next *dst++ = *src++
	      ++src
	      case *src
	      of 'n'   *src = '\n'
	      of 'r'   *src = '\r'
	      of 's'   *src = ' '
	      of 't'   *src = '\t'
	      of other *dst = *src
	      end case
	      ++src, ++dst
	   end

	   ++src if *src eq ter
	   ++src if *src eq ' '
	   ++src if *src eq ','
	   ++src if *src eq ' '
	   *dst = 0
	   next if !str[0]		; ignore null models

	   mod = me_acc (#utTmod)	; new model
	   prv->Psuc = mod if prv
	   ctl.Pmod = mod otherwise
	   prv = mod
	   mod->Prep = st_dup (str)

	   if !ctl.Vpln
	   .. mod->Vwld = wld		

	   if mod->Vwld && (*str ne '*')
	      mod->Pmod = me_acc (st_len (str)+2)
	      *mod->Pmod = '*'
	      st_cop (str, mod->Pmod+1)
	   else
	   .. mod->Pmod = st_dup (str)
	   mod->Vlen = st_len (mod->Pmod)
	   st_low (mod->Pmod) if !ctl.Vexa
;PUT("model=[%s]\n", mod->Pmod)
	end
	quit if ctl.Pmod		; got at least one model
	PUT("%s\n", csi.Pidt)
      forever
  end

code	ut_dlc - deallocate space

  func	ut_dlc
  is	mod : * utTmod = ctl.Pmod
	prv : * utTmod
	while mod ne
	   me_dlc (mod->Pmod)
	   me_dlc (mod->Prep)
	   prv = mod
	   mod = mod->Psuc
	   me_dlc (prv)
	end
	ctl.Pmod = 0
  end
code	ut_wld - wildcard driver

  func	ut_wld
  is	src : * utTipt~ = &ipt
	scn : * rtTscn = utPscn
	pth : [mxPTH] char
	nam : [mxNAM+mxTYP] char
	cnt : int = 0
;PUT("spc=[%s]\n", ipt.Pspc)

	fs_cla (ipt.Pspc, &ipt.Icla)	; get wildcard flags

	if (ipt.Icla.Vwld & fsPTH_)	; device/directory wildcards
	.. fail im_rep ("E-Invalid wildcards %s", ipt.Pdis)

	if !(ipt.Icla.Vwld & fsFIL_)	; no wildcards
	   exit if !ut_opn ()		; single file
	.. exit ut_eng ()		;
					;
	fs_ext (ipt.Pspc, pth, fsPTH_)	; extract the path for scanning
	rt_scn (utPscn, pth, rtPER_, ""); scan directory
	exit if fail			; nothing doing
					; shouldn't come back for errors
	fs_ext (ipt.Pspc, nam, fsFIL_)	; extract name for matching
	if ctl.Vver			; wants verification
	   PUT("?SEARCH-I-Scanning [%s%s]\n", pth, nam)
	end

      repeat
	fi_prg (ipt.Hfil, <>)		; release files
	rt_wld (scn, nam, ipt.Pspc, "")	; scan another
	quit if fail			; no more or error
	st_ins (pth, ipt.Pspc)		; insert path

	next if !ut_opn ()
	if ctl.Vver
	   PUT("?SEARCH-I-Searching [%s]\n", ipt.Pdis)
	end
	++cnt
	quit if !ut_eng ()		; engine failed
      end
	rt_fin (scn)			; close scan
	if !cnt
	   im_rep ("E-No matching file for %s", ipt.Pdis)
	else
	.. im_suc ()			; report success
  end

  func	ut_opn
  is	fine if (ipt.Hfil = fi_opn (ipt.Pspc, "rb", <>))
;	if ctl.Vmis
;	.. PUT("?SEARCH-I-File not located %s\n", ipt.Pdis)
	fail
  end
code	ut_eng - search engine

;	Search a single file

  func	ut_eng
  is	lin : [82] char			; line buffer
	mod : * utTmod = ctl.Pmod	; models
	fnd : int 
	mis : int 
	suc : int

;	me_sav (&utIpas)		; save memory
	ipt.Vnew = 1			; new file
	ipt.Vcnt = 0			; none found yet
	ipt.Vlin = 1			; line number
      while (fi_get (ipt.Hfil, &lin, 80) ne EOF)
	st_low (&lin) if !ctl.Vexa	; compare lower case
	fnd = mis = 0			;
	mod = ctl.Pmod			;
	while mod			; for each model
	   fnd=1 if ut_fnd (mod, lin)	; match
	   mis=1 otherwise		; missmatch
	   mod = mod->Psuc		;
	end				;
	suc = 0				;
	case ctl.Vtst			;
	of utNOR ++suc if !fnd		; NONE/NOR  - no hits
	of utAND ++suc if !mis		; ALL/AND   - no misses
	of utIOR ++suc if  fnd		; ANY/OR    - at least one hit
	of utNAN ++suc if  mis		; SOME/NAND - at least one missing
	of utXOR ++suc if  fnd eq mis	; XOR       - hits and misses
	of utEQV ++suc if  fnd ne mis	; NOT XOR   - not both hits and misses
	end case

	if suc				; matched conditions
	   ++ipt.Vcnt			; count in this file
	   if ctl.Vhea && !ipt.Vnew
	      ipt.Vnew = 1		; once-only per file
 	      ut_put("---------------------\n", <>) if ctl.Vwin
	   .. ut_put("Searching %s\n", ipt.Pspc)
	   if ctl.Vlin			; report lines
	      ut_put(" %d:\t", ipt.Vlin) if ctl.Vnum
	   .. ut_put("%s\n", lin)
	.. quit if ctl.Vmax && (ipt.Vcnt ge ctl.Vmax)
	++ipt.Vlin			; line number
      end

	if ctl.Vver 
	   if !ipt.Vcnt
	   .. PUT("?SEARCH-W-No matching strings found %s\n", ipt.Pspc)
	else
	   ut_put("  %d\t", ipt.Vcnt) if ipt.Vcnt && !ctl.Vlst
	.. ut_put("%s\n", ipt.Pspc)   if ipt.Vcnt
	fine
  end
code	ut_fnd - find string

  func	ut_fnd
	mod : * utTmod
	lin : * char
  is	fnd : * char
	fnd = st_fnd (mod->Pmod, lin) if !mod->Vwld
	fnd = ut_loc (mod->Pmod, lin) otherwise

	fail if !fnd			; failed
	fine if !ctl.Vwrd		; fine if not unembedded word
					; unembedded word
	fail if ct_aln(fnd[mod->Vlen])	; following is alphanumeric
	fine if fnd eq lin		; at start of line
	fail if ct_aln(fnd[-1])		; preceding is alphanumeric
	fine
  end

code	ut_loc - find wildcard substring

;	*	Wild string
;	% or ?	Wild character

  func	ut_loc
	mod : * char~			; model substring with *? to find
	str : * char~			; string to search
	()  : int			; matched
  is  repeat				; big loop
	fine if !*mod; && !*str		; all over
	if *mod eq '*'			; got a wildcard
	   ++mod			;
	   fine if !*mod		; ...* matchs anything
	   while *str			; attempt the remainder
	   .. fine if st_wld (mod,str++);
	.. fail				;
	if *mod eq '?'			;
	|| *mod eq '%'			;
	   fail if !*str		; nothing to match
	.. next ++mod, ++str		; skip single
	fail if *mod ne *str		;
	++mod, ++str			; next pair
      forever
  end
;???;	SEARCH binary search incomplete (nearly there though)
;	not implemented
; 	use C scanf grammar (%o, %d etc with %x for rad50)

code	ut_bin - binary search

  func	ut_bin
  is	num : * utTnum
	adr : long
	loc : long
	nxt : long
	val : int
      repeat
	loc = adr = nxt, nxt += 2
	num = ctl.Pnum			; number list
	while num			;
;	   quit if !ut_gwd (adr, &val)	; get next value
	   quit if val ne num->Vval	;
	   adr += 2			;
	   num = num->Psuc		;
	end				
	next if num ne			; didn't find all of them
;	DMP1("%0l\n")
      end
  end

code	ut_num - pick up numbers to search for

  func	ut_num
  is	num : * utTnum
	prv : * utTnum
	lin : [82] char
	src : * char = lin
	str : [82] char
	dst : * char = str
	ter : int
      repeat
	cl_cmd ("Values? ", src)
	prv = <>
	while *src
	   dst = str
	   ++src while *src eq ' '
	   while *src && (*src ne ' ') && (*src ne ',')
	   .. *dst++ = *src++
	   ++src if *src eq ' '
	   ++src if *src eq ','
	   ++src if *src eq ' '
	   *dst = 0
	   next if !str[0]		; ignore null models
	   num = me_acc (#utTnum)	; new model
	   prv->Psuc = num if prv
	   ctl.Pnum = num otherwise
	   prv = num
	   num->Prep = st_dup (str)
	end
	quit if ctl.Pmod		; got at least one model
	PUT("%s\n", csi.Pidt)
      forever
  end
end file
.endc
.title	search
.include "lib:rust.mac"

	$imgdef	SEARCH 2 0
	$imginf	fun=sav use=<RUST search utility SEARCH.SAV V2.0>
	$imgham	yrs=<2008> oth=<>
;	%date
	$imgdat	<22-Dec-2008 02:11:42.22>
;	%edit
	$imgedt	<57   >

.end
  func	ut_log
	msg : * char
	obj : * char
  is	ut_tit () if ctl.Vhea
	im_rep (msg, obj) if ctl.Vlin
	im_war () if *msg eq 'W'
	im_err () if *msg eq 'E'
  end
;	/UNEMBEDDED -- string is not embedded
;
;	/BY_OWNER/BEFORE/DATE/AFTER/
;	/HEADING		Default if wildcards used
;	/NOHEADING		Default if no wildcards
;	/KEY=n,m		Search area
;	/LOG			Display name of each file as searched
;	/NUMBERS		Show line numbers
;	/REMAINING		Displays all lines following match
;	/WARNINGS		NOMATCHES, TRUNCATE, NULLFILE
;	/WINDOW=n,m		Lines before/after match 
;	/WRAP			Wrap long lines instead of truncating them
;	
;	/TERMINAL		
;
;	/flat	    /=	all files at this level (usual default)
;	/recursive  /*	all files at this level and below
;	/below	    /-	all files below this level
;
;	Defaults:
;
;	dir	/recursive
;	search	/recursive
;	copy	/flat
;	delete	/flat
;	rename	/flat
;	etc
;
;	/flat
;	/recursive
;	/below
;
;	/P	PASSALL		/P  EXCLUDE
;	/Q	QUIET		/Q: BY_OWNER
;
;	95% of searches are for a simple string
;
;	/before=time
;	/since=time
;	  /backup/created/expired/modified
;	/by_owner[=uic]
;	/[NO]confirm
;	/[NO]exact
;	/exclude=(specs...)
;	/format=option
;	  dump, noff, nonulls, passall, text (text)
;	/(no)heading
;	/window (separates files with asterixs)
;	/(NO)highlight[=keyword]
;	  BOLD, blink, reverse, underline
;	  hardcopy=overstrike hardcopy=underline
;	/key=(position=n,size=n)
;	/(NO)log
;	/match=option
;	  and, eqv, nor, nand, or
;	/(NO)numbers
;	  displays line numbers
;	/(no)output(=spec)
;	/(NO)page[=keyword]
;	  clear_screen, scroll, save=n
;
;	/flat/recursive
;	/date/before/since/by_owner
;	/[no]window/linenumbers
;	/highlight/page
;	/exclude=(...)
;
;			VIP	VIR
;	/DATE		/C	/D
;	/BEFORE		/J	/K
;	/SINCE		/I	/J
;	/BY_OWNER	/Q:u:g	/Q:u:g
;	/EXCLUDE	/P	/P
