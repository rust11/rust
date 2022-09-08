;???;	CUS:PATCH - Show Settings has extra comma after "words,"
;???;	CUS:PATCH - Change don't work for PATCH/MEMORY
;&&&;	CUS:PATCH - Save/apply change list
;&&&;	CUS:PATCH - DCL version
;&&&;	CUS:PATCH/LDA/OBJECT
;&&&;	CUS:PATCH - windows version
;	finish patch/memory
;	support extended memory
;
;	2k 2m 	Value multipliers
;	A	Advance by word/byte in instruction mode
;	C	Combined instruction/value display
;	J	Jump to destination
;	P	Return to last jump
;
;	Leave this utility simple.
;	Do extended screen-oriented patch program (SPLAT)
;
;	Dump	DB= Bytes, DW=Words etc
;	=[Enter]  Instructions
;	=Instruction
;	Label:
;	SA[VE] SESSION
;	LO[AD] SESSION
;	PATCH/OBJECT (also autodetect)
;
;	nDF	Delete from file (from current location)
;	nIF	Insert in file (past current location)
;
.if ne 0
file	patch - patch images
include	rid:rider
include	rid:codef
include	rid:ctdef
include	rid:eldef
;nclude	rid:elrev
include	rid:fidef
include	rid:imdef
include	rid:medef
include	rid:mxdef
include	rid:rtcsi
include rid:rvpdp

;	%build
;	macro cus:patch.r/object:cub:patch.inf
;	rider cus:patch/object:cub:patch
;	link cub:patch(.inf,.obj)/exe:cub:/map:cub:,lib:crt/bot:3000/cross
;	%end

  type	cuTctl 
  is	Psrc : * FILE	; source file
	Vlim : elTadr	; file size in bytes
			;
	Vasc : WORD	; /ASCII
	Vbyt : WORD	; /BYTES
	Vdec : WORD	; /DECIMAL
	Vimm : WORD	; /IMMEDIATELY
	Vhex : WORD	; /HEXADECIMAL
	Vmem : WORD	; /MEMORY
	Vins : WORD	; /INSPECT
	Vrev : WORD	; /INSTRUCTION
	Voct : WORD	; /OCTAL
	Vqui : WORD	; /QUIET
	Vr50 : WORD	; /RAD50
	Vwrd : WORD	; /WORDS
	Asrc : [16] char
	Verr : int	; i/o error detected
  end
	ctl    : cuTctl = {0}
	csi    : csTcsi = {0}
	cu_eng : ()
	cu_fnd : (**char, *elTadr, int, int)

	cu_dmp : (*char, *char, int)
	cu_map : (elTadr) 
	cu_skp : (**char, int) int
	cu_com : (**char, *elTwrd, *int)
	cu_val : (**char, *elTwrd, *elTadr, *char)

	cu_lim : (elTadr) int
	cu_fwd : (elTadr) elTwrd
	cu_swd : (elTadr, elTwrd) int
	cu_adr : (elTadr) elTadr

	cu_sho : ()

	hiLEN := 256		; history length
	hi_put : (elTadr)
	hi_prv : () elTadr
	hi_nxt : () elTadr

	fdVval : elTwrd	= 0	; value to find
	fdVsta : elTadr	= 0	; start
	fdVlim : elTadr = 0	; limit
	fdVmsk : elTwrd = 0	; mask
	fdVdir : int = 1	; direction (ge => forward)
	fdVwid : int = 2	; width

	cuVval : int = 0	; show values (not instructions)
	cuVrad : int = 0	; radix
	cuVwid : int = 2	; word size
	cuVrel : int = 0	; relocation base

	cuCctc : int = 0	; ctrl/c flag

  type	cuTchg
  is	Psuc : * cuTchg
	Vadr : elTadr
	Vval : elTwrd
  end
	cuPchg : * cuTchg
	chVcnt : int = 0
	ch_get : (elTadr) elTwrd
	ch_put : (elTadr, elTwrd)
	ch_fnd : (elTadr) *cuTchg
	ch_upd : ()
	ch_sho : ()
	ch_zap : ()

  func	cu_inv
	str : * char
 	lst : * char
  is	*lst = 0
	PUT("?PATCH-W-Invalid command [%s]\n", str)
  end
code	start

  func	start
  is 	swi : * csTswi
	im_ini ("PATCH")		; who we are
     repeat
	fi_prg (ctl.Psrc, <>) if ctl.Psrc
	me_clr (&ctl, #cuTctl)		; no switches
					;
	csi.Pidt = "?PATCH-I-RUST binary patch utility PATCH.SAV V2.0"
	csi.Pnon = "ABDFHMNIOQRXW"	; no value
	csi.Preq = ""			; required value
	csi.Pexc = <>			; mutually exclusive

	next if !cs_par (&csi, <>)	; parse the command
	swi = csi.Aswi
	while swi->Vcha
	   case swi->Vcha
	   of 'A'   ++ctl.Vasc		; /ASCII       ??????
	   of 'B'   ++ctl.Vbyt		; /BYTES
	   of 'D'   ++ctl.Vdec		; /DECIMAL
	   of 'F'   ++ctl.Vimm		; /IMMEDIATELY
	   of 'H'   ++ctl.Vhex		; /HEXADECIMAL
	   of 'M'   ++ctl.Vmem,++ctl.Vimm; /MEMORY
	   of 'N'   ++ctl.Vins		; /INSPECT
	   of 'I'   ++ctl.Vrev		; /INSTRUCTION [default]
	   of 'O'   ++ctl.Voct		; /OCTAL       [default]
	   of 'Q'   ++ctl.Vqui		; /QUIET
	   of 'R'   ++ctl.Vr50		; /RAD50
	   of 'X'   ++ctl.Vr50		; /RAD50
	   of 'W'   ++ctl.Vwrd		; /WORDS       [default]
	   end case
	   ++swi
	end
	if ctl.Vmem
;	ctl.Vmem ? 0 ?? 010			; no files for /MEMORY
	   next if !cs_val (&csi, 0, 0)		; required, permitted files
	else
	.. next if !cs_val (&csi, 010, 010)	; required, permitted files
						;
	next cu_eng () if ctl.Vmem		; patch memory

	fi_def (csi.Aipt[0].Pspc, "DK:.SAV", ctl.Asrc); input file
	ctl.Psrc = fi_opn (ctl.Asrc, "rpb+", ""); open the file
	next if fail				;
						;
	ctl.Vlim = fi_len (ctl.Psrc)		; file byte size
	fdVlim = ctl.Vlim			; default search limit
	co_ctc (coDSB)				; disable ctrl-c
	cu_eng ()				; patch it
 	im_exi ()				; only one file
    forever
  end

code	cu_exi - exit

  func	cu_exi
  is	ch_upd ()			; update file
	fi_clo (ctl.Psrc, "")		; close
;	error check
	im_exi ()			; out of here
  end

code	cu_qui - quit

  func	cu_qui
  is	im_exi ()
  end

code	cu_abt - check abort

  func	cu_abt
	lin : int 
  is	if chVcnt		; unwritten changes
	   PUT("\n") if lin
	.. fine if !rt_qry (ctl.Asrc, "/Abort changes", <>)
	cu_qui ()
  end
code	cu_eng - patch engine

  func	cu_eng
  is	buf : [mxLIN] char
	sav : [mxLIN] char
	r50 : [4] char
	rep : * char
	cmd : * char
	adr : elTadr = 0
	opc : elTwrd
	val : elTwrd
	lng : elTadr
	pol : int
	alp : int
	dig : int
	que : int 
	cas : int
	rev : rvTpdp
	nxt : elTwrd = 2
	str : [32] char
	exi : int = 0			; 1 => leave
	snd : int			; second char of command
	his : int = 1			;
     repeat				;
	nxt = cuVwid			;
	rev.Vflg = 0
	rev.Adat[1] = rev.Adat[2] = 0	; default values
	ctl.Verr = 0			; set if i/o error
					;
	rev.Vloc = adr			;
	rev.Vopc = opc = ch_get (adr)	; get next opcode
	rev.Vlen = 1			;
	rev.Adat[1] = ch_get(adr+2) if !ctl.Verr
	rev.Adat[2] = ch_get(adr+4) if !ctl.Verr
	rv_pdp (&rev)			;
					;
	adr = cu_adr (adr)		; display address
	hi_put (adr) if his		; history enabled
	his = 1				; enable it next time
	rx_unp (opc, r50)		;
	cu_dmp ((<*char>&opc),str,2)	;
	if cuVval			; want values
;	   PUT (" %0o %d. %s [%s]",opc,opc,r50,str)
	   if !cuVrad && !ctl.Vqui
	      PUT("\t%0o\t%3o  %3o  %3s [%s]",opc,(opc>>8)&255,opc&255,r50,str)
	   elif !ctl.Vqui
	   .. PUT ("\t%0d.\t%3d. %3d. %3s [%s]",opc,(opc>>8)&255,opc&255,r50,str)
	   nxt = cuVwid			;
	   nxt = 1 if (adr & 1) ne	;
	else 				;
	   if !ctl.Vqui
	      PUT("\t%3s %2s", r50, str)
	      rx_unp (opc, r50)		;
	   .. cu_dmp ((<*char>&opc),str,2)	;
	   nxt = rev.Vlen * 2		; want reverse assemble
	   if !ctl.Vqui
	      PUT("\t%0o\t", opc)		;
	.. .. PUT("%s", rev.Astr)		;
					;
	cmd = buf			; get a command
	ctl.Vqui ? "" ?? " | "
	cl_cmx (that, cmd)		;
	if ch_mat (cmd, 3)		; skip ^C
	   cu_abt (1)
	.. *cmd = 0			;

	st_trm (cmd)			; trim spaces
	if !*cmd			; blank line
	.. next adr += nxt		;

	if *cmd eq ';'			; repeat
	   st_cop (sav, cmd)		;
	else				;
	.. st_cop (cmd, sav)		;

      while *cmd			; more commands on line
	dig = alp = que = val = 0	; start over
	pol = 0				;
	++cmd while *cmd eq ' '		; skip spaces
	rep = cmd			; report string for errors
	--pol, ++cmd if *cmd eq '-'	; - 
	++pol, ++cmd if *cmd eq '+'	; +
	dig =  cu_val (&cmd, &val, &lng, <>)	; get optional value
					;
	if pol && !dig && !*cmd		; just "+" or "-"
	   dig = 1, lng = cuVwid	; fudge a number
	.. dig = 1, lng = 1 if (adr&1) ne ; byte increments
					;
	if pol && dig			; just +- and a number
	   adr += lng if pol gt		; add the offset
	   adr -= lng otherwise		;
	.. next				; next command 
					;
	adr = lng if dig & !*cmd	; just a number - absolute location
	quit if !*cmd			; all over
					;
	cas = alp = ch_low (*cmd++) if ct_alp (*cmd)
	cas = *cmd++ otherwise		; alpha or punctuation
	snd = ch_low (*cmd)		; second char of command, e.g. sO, sP
					;
	case cas			;
	of '\\' cuVval = ~cuVval	; \	flip assembler/data
	of '/'  cuVrad = ~cuVrad	; /	flip radix
					;
	of 'e' if snd eq 'x'		; ex	exit
		   cu_exi ()		;	update file
		else 			;
		.. cu_inv (rep, cmd)	;
					;
	of 'f'	cu_fnd (&cmd, &adr, val, pol); f	find
		PUT("?PATCH-W-Value not found [%o]\n", fdVval) if fail
					;
	of 'h'	cu_hlp ()		; h	help
					;
	of 'l'	adr = hi_prv (), his=0	; l	last in history
	of 'n'	adr = hi_nxt (), his=0	; n	next in history
					;
	of 'q'	if snd eq 'u'		; qu	quit, no update
		   cu_qui ()		;
		else 			;
		.. cu_inv (rep, cmd)	;

	of 's'	if snd eq 'b'		; sb	show bytes
		   cuVwid = 1		;
		elif snd eq 'r'		; sr	set relocation base
		   cuVrel = adr		;
		elif snd eq 's'		; ss	show settings
		   cu_sho ()		;
		elif snd eq 'w'		; sw	show words
		   cuVwid = 2		;
		elif snd eq 'c'		; sc	show change list
		   ch_sho ()		;
		else
		.. cu_inv (rep, cmd)	;
		++cmd			; skip second letter
					;
	of 'u' if snd eq 'p'		; up	update file
		   ch_upd ()		;
		else 			;
		.. cu_inv (rep, cmd)	;
		++cmd			; skip second letter

	of 'v'	cuVval = 1		; v 	show values
	of 'x'	fine cu_exi ()		; x	exit
					;
	of 'z' if snd eq 'c'		; zc	zap change list
		   ch_zap ()		;
		else 			;
		.. cu_inv (rep, cmd)	;
		++cmd			; skip second letter

	 of '@' adr = val if dig	;
		adr = ch_get (adr)	; @	indirect
	 of ']' adr = rev.Vdst		; >	Destination
	 of '='	adr = val if dig	; =	got an address
		cu_val (&cmd,&val,&lng,"") ;	get required value
		next if fail		;	nothing doing
		ch_put (adr, val)	;	change word
	        adr += 2		;	always a word???
	 of '!'	 *cmd = 0		; !	comment
	 of ','	 adr += cuVrel		; ,	relocate
	 of 32   nothing		;	space
	 of '\t' nothing		;	tab
	 of other cu_inv (rep, cmd)
	 end case
       end;while
     forever
  end
code	cu_fnd - find value

;	+-FBWv,s,l,m
;
;	+-	polarity
;	B W	byte/word
;	"..."	ascii
;	'a'	character
;	^x...	value
;	v	value
;	s	start
;	l	limit
;	m	mask

  func	cu_fnd
	cmd : ** char
	adr : * elTadr
	cnt : int
	pol : int
  is	nxt : elTadr = *adr
	val : elTwrd
	sta : elTadr = 0
	lim : elTadr = 0
	abt : int = 0			; timer
	fdVdir = pol if pol		; change direction
	fdVwid = 1 if cu_skp (cmd, 'b')	; bytes
	fdVwid = 2 if cu_skp (cmd, 'w')	; words

	cu_val (cmd, &fdVval, 0, <>)	; value
	fdVdir = 1 if that && !pol	; default direction for new search
	cu_com (cmd, 0, &fdVsta)	; start
	cu_com (cmd, 0, &fdVlim)	; limit
	cu_com (cmd, &fdVmsk, 0)	; mask

	val = fdVval			;
	abt = 4000			; check abort 
     repeat
	if !abt--			; check for abort
	   abt = 4*512			; every 4 blocks
	.. fail if co_ctc (coCHK)	; ctrl/c seen

	if fdVdir ge			; forward
	   nxt += fdVwid		;
	   fail if cu_lim (nxt)		; next will fail
	else				;
	   fail if (nxt eq <>)		; going backwards
	.. nxt -= fdVwid		;
	val = ch_get (nxt)		; 
	if fdVwid eq 2			;
	    quit if val eq fdVval	;
	else				;
	    quit if (val & 0377) eq (fdVval & 0377)
	..  quit if ((val>>8) & 0377) eq (fdVval & 0377)
     forever				;
	fine *adr = nxt			;
  end
code	ch_get - get change or fetch from file

;	F[B]v,s,l,m
;	F"....",
;	F^r123,
;
;	.NAME=VAL

  func	ch_get
	adr : elTadr
	()  : elTwrd
  is	chg : * cuTchg
	reply chg->Vval if (chg = ch_fnd (adr)) ne
	reply cu_fwd (adr)
  end

code	ch_put - change list

;	cuPchg -> cuTchg:
;
;	Psuc	| Pointer to next entry |
;	Vadr	| Image address         |
;	Vval	| Replacement value     |

;	Fail if no more room left for changes

  func	ch_put
	adr : elTadr
	val : elTwrd
  is	ptr : * cuTchg = cuPchg
	chg : * cuTchg
	prv : ** cuTchg
	fail if cu_lim (adr)

	reply cu_swd (adr, val) if ctl.Vimm

	chg = ch_fnd (adr)
	fine chg->Vval = val if chg
;	chg = me_alg (0, #cuTchg, meCLR_|meALC_)
	chg = me_acc (#cuTchg)
	pass fail
	++chVcnt
	chg->Vadr = adr
	chg->Vval = val
	prv = &cuPchg
	repeat
	   ptr = *prv
	   if !ptr || ptr->Vadr gt adr
	      chg->Psuc = ptr
	   .. fine *prv = chg
	   prv = &ptr->Psuc
	forever
	fine
  end

  func	ch_fnd			
	adr : elTadr
	()  : * cuTchg
  is	ptr : * cuTchg = cuPchg
	repeat
	   fail if !ptr
           reply ptr if adr eq ptr->Vadr
	   ptr = ptr->Psuc
	forever
	fail
  end

code	ch_upd - update file with change list

;	Change list entries are removed as they are applied
;	Update write/seek fail leaves remainding entries in list

  func	ch_upd
  is	ptr : * cuTchg = cuPchg
	dlc : * cuTchg
	while ptr
	   cu_swd (ptr->Vadr, ptr->Vval)
	   pass fail
	   dlc = ptr
	   cuPchg = ptr = ptr->Psuc
	   me_dlc (dlc)
	  --chVcnt
	end
	fi_flu (ctl.Psrc)		; flush changes out
	fine
  end

code	ch_zap - delete change list entries

  func	ch_zap
  is	ptr : * cuTchg = cuPchg
	dlc : * cuTchg
	while ptr
	   dlc = ptr
	   ptr = ptr->Psuc
	   me_dlc (dlc)
	   --chVcnt
	end
	cuPchg = <>
	fine
  end

code	ch_sho - show change list entries

  func	ch_sho
  is	ptr : * cuTchg = cuPchg
	adr : elTadr
	val : elTwrd
	fine PUT("?PATCH-I-No changes made\n") if !chVcnt
	PUT("\nAddress	Old	New\n")
	while ptr
	   adr = ptr->Vadr
	   cu_adr (adr)
	   val = cu_fwd (adr)
	   PUT("\t%0o\t%0o\n", val, ptr->Vval)
	   ptr = ptr->Psuc
	end
	fine
  end
code	cu_adr - display address with address check

  func	cu_adr
	adr : elTadr
	()  : elTadr
  is	if !ctl.Vqui
	   PUT("%0lo", adr)
	.. PUT("?") if cu_lim (adr)
	reply adr
  end

code	cu_lim - check file limit

  func	cu_lim 
	adr : elTadr
  is	val : elTwrd
	reply !me_pee (<word>adr, &val, 2) if ctl.Vmem
	reply adr ge ctl.Vlim
  end

code	cu_fwd - fetch word

  func	cu_fwd
	adr : elTadr
	()  : elTwrd
  is	wrd : elTwrd
	fail if cu_lim (adr)
	if ctl.Vmem
	   reply wrd if me_pee (<word>adr, &wrd, 2)
	   PUT("?PATCH-W-Invalid memory address ")
	   cu_adr (adr), PUT("\n")
	.. fail ++ctl.Verr

	if !fi_see (ctl.Psrc, adr)
	   PUT("?PATCH-W-Error seeking %s at ", ctl.Asrc)
	   cu_adr (adr), PUT("\n")
	.. fail ++ctl.Verr
	if !fi_rea (ctl.Psrc, &wrd, 2)
	   PUT("?PATCH-W-Error reading %s at ", ctl.Asrc)
	   cu_adr (adr), PUT("\n")
	.. fail ++ctl.Verr
	reply wrd
  end

code	cu_swd - store word

  func	cu_swd
	adr : elTadr
	val : elTwrd
  is	fine if ctl.Vins		; inspect only
	if ctl.Vmem
	   fine if me_pok (<word>adr, &val, 2)
	   PUT("?PATCH-W-Invalid memory address ")
	   cu_adr (adr), PUT("\n")
	.. fail
	fi_see (ctl.Psrc, adr)
	im_rep ("W-Error seeking image %s", ctl.Asrc) if fail
	fi_wri (ctl.Psrc, &val, 2)
	im_rep ("W-Error writing image %s", ctl.Asrc) if fail
	fine
  end
;&&&;	patch hi_put - make library file
code	hi_put - put in history

;	Circular location history

	hiVcur : elTadr = 0	;
	hiVput : int = 0	; history put index
	hiVget : int = 0	; history get index
	hiAhis : [hiLEN] elTadr = {0}

  func	hi_put
 	adr : elTadr
  is	idx : int = hiVput	;
	exit if adr eq hiVcur	; avoid duplicates
	hiVcur = adr		;
	hiAhis[idx] = adr	; save the pc
	idx = 0 if ++idx ge hiLEN ;
	hiVput = hiVget = idx	;
	hiAhis[idx] = 0		;
  end

code	hi_prv - get previous value from history

  func	hi_prv
	()  : elTadr
  is	idx : int = hiVget - 1
	idx = hiLEN-1 if idx lt
	hiVget = idx
	reply hiAhis[idx]
  end

code	hi_suc - get next value from history

  func	hi_nxt
	()  : elTadr
  is	idx : int = hiVget + 1
	idx = 0 if idx ge hiLEN
	hiVget = idx
	reply hiAhis[idx]
  end
code	cu_sho - show stuff

  func	cu_sho
  is	PUT("Show ")
	PUT("values, ") if cuVval
	PUT("instructions, ") otherwise
	PUT("decimal, ") if cuVrad
	PUT("octal, ") otherwise
	PUT("bytes, ") if cuVwid eq 1
	PUT("words, ") if cuVwid eq 2
	PUT("\n")

	PUT("Search")
	PUT(" Forward") if fdVdir ge
	PUT(" Backward") if fdVdir lt
	PUT(" Value=%o", fdVval)
	PUT(", From="), cu_adr (fdVsta)
	PUT(", To="), cu_adr (fdVlim)
	PUT(", Mask=%o", fdVmsk)
	PUT("\n")

	PUT("No changes ") if !chVcnt
	PUT("One change ") if chVcnt eq 1
	PUT("%d changes ", chVcnt) if chVcnt gt 1
	PUT("\n")
  end
code	cu_hlp - help

  init	cuAhlp : [] * char
  is	"PATCH commands"
	""
	"Enter  Open next location"
	"-      Open preceding location"
	"n      Open octal location n"
	"+-n    Add/Subtract n to/from address"
	",	Add relocation base to address"	
	"=n     Deposit n, open next location"
	"@      Open indirect"
	"]      Open destination address"

	"\\      Toggle assembler/value display" ;sic: Needs indent for "\\"
	"/      Toggle octal/decimal display"
	";      Repeat previous command"
	"!      Comment. Ignore remainder"
	"Space  Command separator"
	"EX     Exit, updating file"
	"Fv,f,t Find Value between From & To"
	"-F...  Search backwards"
	"F      Find next"
	"H      Display help"
	"L      Open previous in history"
	"N      Open next in history"
	"QU     Exit, not updating file"
	"SB     Show bytes"
	"SC     Show change list"
	"SR	Set relocation base"
	"SS     Show settings"
	"SW     Show words"
	"UP     Update file with changes"
	"ZC     Zap change list"
	""
	<>
  end

  func	cu_hlp
  is	hlp : ** char = cuAhlp		; help lines
	lft : ** char			; 
	rgt : ** char			;
	len : int = 0			;
	lft = hlp			; two column help
	++len while *hlp++ 		; count them
	rgt = lft + (len /= 2)		; right
	PUT("\n")
	while len--			; got more
	   PUT("%-40s", *lft++)		; the left part
	   PUT("%s\n", *rgt++)		;
	end
	PUT("\n")
  end
code	cu_skp - skip character

  func	cu_skp
	cmd : ** char
	cha : int
  is	fail if *(*cmd) ne cha
	fine ++(*cmd)
  end

code	cu_com - get value preceded by comma

  func	cu_com
	cmd : ** char
	wrd : * elTwrd
	lng : * elTadr
  is	ptr : * char = *cmd
	fail if *(*cmd) ne ','
	++(*cmd)
	fine if *(*cmd) eq ','
	reply cu_val (cmd, wrd, lng, "")
  end

code	cu_val - get value


;	nnnn	%onnn	octal
;	nnnn.	%dnnn	decimal
;		%hnnn	hex
;		%rnnn	rad50
;???		"aa"	ascii

  func	cu_val
	cmd : ** char
	wrd : * elTwrd
	lng : * elTadr
	msg : * char
  is	ptr : * char = *cmd
	adr : elTadr
	lng = &adr if !lng
	if !ct_dig (*ptr)		;
	   if msg
	   .. PUT(*msg ? msg ?? "?PATCH-No value specified\n")
	.. fail
	SCN(ptr, "%lo", lng)		; get the number
	*wrd = *lng & 0177777		; reduce to word
	++ptr while ct_dig (*ptr)	; skip it
	*cmd = ptr
	fine
  end

code	cu_dmp - dump ascii

  func	cu_dmp
	src : * char
	dst : * char
	cnt : int
  is	cha : int
	while cnt--
	   cha = *src
	   *dst++ = cha if (cha ge 32) && (cha lt 127)
	   *dst++ = '.' otherwise
	   ++src if *src
	end
	*dst = 0 
  end
end file
.endc
.title	patch
.include "lib:rust.mac"

;	V1/V2 PATCH were Maree implementations by Erwald Muessig

	$imgdef	PATCH 3 0
	$imginf	fun=sav use=<RUST image patch utility PATCH.SAV V3.0>
	$imgham	yrs=<2011> oth=<>
;	%date
	$imgdat	<09-Sep-2022 05:23:16>   
;	%edit
	$imgedt	<67   >

.end
code	LDA support

code	ld_imp - import LDA as saved image

  func	ld_imp
	lda : * ldTlda
	imp : * char
	exp : * char
  is	lda : ldTfil
	lda->Himp = fi_opn (imp, "rb", "")
	pass fail
	ld_scn (lda, imp)
	lda->Hexp = fx_opn (exp, "rb+", "", ext)

                                                                                                