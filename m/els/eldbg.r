;???;	ELDBG - Mark break etc locations: "1000  240  nop |b|"
file	eldbg - V11 debugger
include	elb:elmod
include	rid:rvpdp
include	rid:chdef
include	rid:medef
include	rid:fidef
include	rid:cldef
include	rid:imdef
include	rid:dbdef
include	rid:stdef
include	rid:mxdef
include	rid:ctdef
include rid:codef
include rid:tidef
include rid:wcdef
include rid:shdef
include rid:rtutl

	bg_dmp : (*char, *char, int)
	bg_mmu : () 
	bg_map : (elTadr) 
	bg_inf : elTfun
	bg_hlp : (void) void
	bgVpsw : int = 0
	bgVovr : int = 0
	bgVovp : int = 0
	bgVsto : int = 0	; step to
	bgVtop : int = 0	; step to pointer
	bgVban : int = 0	; step banner
	bg_fwd : (elTadr) elTwrd
	bg_swd : (elTadr, elTwrd) void
	bg_tra : (elTadr)
	bg_adr : (elTadr)
	bg_wat : ()
	bg_vpx : (elTadr) elTadr


  type	bgTmch
  is	Vopc : elTwrd
	Vnxt : elTwrd
	Vadr : elTwrd
  end
	bg_msv : (*bgTmch)
	bg_mrs : (*bgTmch)

	bg_val : (**char, *elTwrd, *int, *char)
	bg_res : (void) void

	bgVsch : int = 0	;
	bgVwid : int = 2
	bgVrad : int = 0	; radix: 0=>octal, !0=>decimal
	bgVtra : int = 0

	bgIbpt : bgTtrg = {0}	; BPT trigger
	bgIwat : bgTtrg = {0}	; watchpoint
	bgIfee : bgTtrg = {0}	; feelpoint

  func	bg_inv
	str : * char
 	lst : * char
  is	*lst = 0
	PUT("?V11-W-Invalid command [%s]\n", str)
  end
data	commands (may be out of date)

; +-C	enables/disables various things
; ?	queries state of things
;
;   A	
;*a B   Breakpoint (default is current, 0 clears)  
;?  BO	Boot
;   C
;   D	Display data
;   DI	Display instructions
;   DB	Display bytes
;   DW  Display words
;   E	
;   F
;*a G	Go 
;   H	Help
;   I	
; a J	Jump
;   K	
; c L	Last (previous) in history
; a M	Map address
;   MM	Show MMU
;   MD  D-space
;   MI	I-space
;   MK  Kernel space
;   MU  User space
;   MS  Supervisor space
;   N	Next in history
;   O	
;*c P	Proceed
;   PC	Display PC
;   PS	Display PS
;   Q
;*  R	Display all registers
;*  Rn	Display specific register
;*  RS	Display PS
; c S	Step 
;   SO	Step over
;   SP	Display stack
;   T	Transfer trap
;   U	
;   V   
; n W	Watch (default is current, zero clears)
;   X	Exit program
;   Y
;   Z
;
; ? B	Show microcode byte registers
; ? D	Show mounted disks
; ? I	Show instruction that caused trap
; ? M	Show MMU mapping
; ? W	Show internal word registers
;
; +-A 	Enable/disable address traps
; +-C	Enable/disable clock
; +-D	Enable/disable disk trace
; +-F	Enable/disable fast mode
; +-I	Enable/disable instruction traps
; +-M	Enable/disable MMU
; + R	Reset
;
;; pdp/debug
;	Enters debugger before bootstrapping processor
;
;	[alt][break]	interrupt program
;a?
;b	boot [unit]
;c +-c	+cpu		display bus/cpu traps		
;d +-d	+-disk	
;e se	extended address stuff - temporary

;f +-f	+-fast	
;	fast	exit
;g	[addr]go	resets before jump	
;
;h	help	
;i	
;j	[addr]jump	jumps without reset
;k  K	kernel		
;l	last		display last in history
;;m sm	mounts		display mounted devices
;	mapping		display mapping registers
;n	next		display next in history
;o sw	wOrds		display microcode word registers
;o	over		step over next instruction
;p	proceed		continue, reset counters
;q sq	q		Show most things
;r s+r	+register	display registers on break		
;	rs		display PSW
;	r0...r7		display register
;	r...		display all registers
;s	<N>step		Step N instructions
;t	-t		clear breakpoint
;	<N>t		set breakpoint at address N
;	t		set breakpoint at current address
; U	User		
;;u	previoUs	display previous instruction address
;v	values		show values, not instruction data
;w	-w		Clear watch address
;	of 'w'	 bgVwat = pol if num || (pol ge)
;		 bgVwad = adr, elVwvl = val if num
;x	x		exit emulator
;y sy	y		display microcode byte registers
;z	<N>z		store N into internal Z registers
;	@		Treat contents as address
;	=
;	-		Subtract 2 from address
;	!...		Comment

code	el_dbg - debugger

  func	el_dbg
	rea : * char		; reason
	()  : int		; fine => we did it
  is	buf : [mxLIN] char
	sav : [mxLIN] char
	r50 : [4] char
	rep : * char
	cmd : * char
	adr : elTadr = PC	;*
	opc : elTwrd		;*
	val : elTwrd
	lng : int
	pol : int
	alp : int
	dig : int
	que : int 
	v1  : elTwrd
	v2  : elTwrd
	cas : int
	rev : rvTpdp = {0}
	nxt : elTwrd			;*
	str : [32] char
	exi : int = 0			; 1 => leave
	snd : int			; second char of command
	his : elThis			;*
	mch : bgTmch			; machine state
	inv : int = 0			; invalid command flag				;
	if !st_sam (rea, "zap")		;
	.. fine if bgVhlt		; already in debugger
	bgVhlt = 1			; now halted
	bgVcnt = 0			;
	bgVpsw = PS			; get ps at time of trap
					;
;	if bgVtpb && (bgVtpb ne '\n')	; get a new line
;	   bgVtpb = 0
;	.. PUT("\n")			;
	el_sol ()			; force start of line
	if st_sam (rea, "step") && !bgVtra;
	   bgVstp = 0			;
	   bg_reg () if bgVban		; want banner
	elif st_sam (rea, "over")	;
	   bgVovr = 0			;
	elif st_sam (rea, "Felt")
	   PUT("Feel: %o\n", bgVfel)
	elif rea || bgVtra
	   PUT("%s: PC=%0o OP=%0o",rea,PC,OP)
	   bg_wat () if bgIwat.Venb
	.. PUT("\n")			;
	if bgVtra
	   fine bgVstp=1, bgVcnt=1 if st_sam (rea, "step")
	.. bgVtra = 0, bgVstp = 0

	*sav = 0			; no repeat
     repeat				;
	rev.Vloc = adr			;
	rev.Vopc = opc = PS if adr eq elPSW	; needed for LSI 'cos PS
	rev.Vopc = opc = bg_fwd (adr) otherwise	; is an invalid address
	rev.Vlen = 1			;
	elVprb = 1			;
	rev.Adat[1] = v1 = bg_fwd(adr+2);
	rev.Adat[2] = v2 = bg_fwd(adr+4);
	elVprb = 0			;
	rv_pdp (&rev)			;
					;
	if bg_mem (adr) || bgVval	;
	   rt_unp (&opc, r50, 1)	;
	   bg_dmp ((<*char>&opc),str,2)	;
;	   PUT (" %0o %d. %s [%s]",opc,opc,r50,str)
	   if !bgVrad
	      PUT ("\t%0o\t%3o  %3o  %3s [%s]",opc,(opc>>8)&255,opc&255,r50,str)
	   else
	   .. PUT ("\t%0d.\t%3d. %3d. %3s [%s]",opc,(opc>>8)&255,opc&255,r50,str)
	   nxt = bgVwid			;
	   nxt = 1 if adr & 1		;
	else 				;
	   nxt = rev.Vlen * 2		;
	   PUT("\t%0o\t", opc)	;
	.. PUT("%s", rev.Astr)		;
					;
	cmd = buf			; get a command
	cl_cmd (" | ", cmd)		;

	st_trm (cmd)			;
	st_low (cmd)
	++cmd if *cmd eq -1		;
	if !*cmd			; blank line
	   if adr eq elPSW		;
	   || adr eq (elREG + 8*2)	;
	      adr = elREG		;
	   .. next			;
	.. next adr += nxt		;
	if *cmd eq ';'			; repeat
	   st_cop (sav, cmd)		;
	else				;
	.. st_cop (cmd, sav)		;
      while *cmd			;
	dig = alp = que = val = 0	; start over
	pol = -1			;
					;
	++cmd while *cmd && *cmd eq ' '	; skip spaces
	rep = cmd			; report string for errors
	pol = 0, ++cmd if *cmd eq '-'	; - 
	pol = 1, ++cmd if *cmd eq '+'	; +
	dig =  bg_val (&cmd, &val, &lng, <>)	; get optional value
					;
	if (pol ge) && !dig && !*cmd	; just "+" or "-"
	   dig = 1, val = bgVwid	; fudge a number
	.. dig = 1, val = 1 if adr & 1	; byte increments
					;
	if (pol ge) && dig		; just +- and a number
	   adr += val if pol		; add the offset
	   adr -= val otherwise		;
	   adr &= 0xffff		; ignore overflow
	.. next				; next command 
					;
	adr = val if dig & !*cmd	; just a number - absolute location
	quit if !*cmd			; all over
					;
	que = 1, ++cmd if *cmd eq '?'	; ?
	cas = alp = ch_low (*cmd++) if ct_alp (*cmd)
	cas = *cmd++ otherwise		; alpha or punctuation
	snd = ch_low (*cmd)		; second char of command, e.g. sO, sP
					;
	inv = 0				; command error
	if que && alp			; ?a
	 case alp			;
	 of 'a'	bg_sho ()		; lots of things
	 of 'b' bg_byt ()		; show microcode byte registers
	 of 'd'	bg_dev ()		; show mounted devices
	 of 'p' PUT("Instruction count: %o\n", bgVict)
	 of 'w' bg_wrd ()		; show microcode word registers
	 end case			;
	elif (pol ge) && alp		; +-a
	 case alp			;
	 of 'a'	bgVbus = pol		; [don't] catch address traps
	 of 'b' bgIbpt.Venb = pol	; [don't] do breakpoints
;	 of 'b'	el_boo (dig ? val ?? bgVuni)
	 of 'c' elVclk = pol		; [don't] send clock interrupts
	 of 'd'	bgVdsk = pol		; [don't] trace disk operations
	 of 'f'	bgVfst = pol		; [don't] use fast mode
	 of 't'	bgVcpu = pol		; [don't] catch bus/cpu/mmu traps
	 of 'r' bgVreg = pol		; [don't] display registers on entry
	 of 'p' elVpau = pol		; [don't] pause for output
	 of 'w' bgIwat.Venb = pol	; [don't] watch
	 end case			;
	else				;
	 case cas			;
	 of '\\' bgVval = ~bgVval	;	flip assembler/data
	 of '/' bgVrad = ~bgVrad	;	flip radix
;	 of 'a' bgVval = 0		; a	display assembler
	 of 'b' val = adr if !dig	; b	set breakpoint
		bg_set (&bgIbpt,val,bgVpsw);
		bgVovr = 0		;
					;
	 of 'c'	if snd eq 'b'		; cb	clear break
		   bgIbpt.Venb = 0	;
		.. next ++cmd		;
					;
	 	if snd eq 'f'		; cf	clear feel
		   bgIfee.Venb = 0	;
		.. next ++cmd		;
					;
	 	if snd eq 'u'		; cu	clear underflow
		   bgVund = 0		;
		.. next ++cmd		;
					;
	 	if snd eq 'w'		; cw	clear watch
		   bgIwat.Venb = 0	;
		   bgIwat.Vflg = 0	;
		.. next ++cmd		;
		inv = 1			;
					;
	 of 'd'	pol = 0			; d	disable
	 or 'e'	pol = 1 if cas eq 'e'	; e	enable
		quit if !snd		;
		case snd
	 	of 'a' bgVbus = pol	; [don't] catch address traps
	 	of 'b' bgIbpt.Venb = pol; [don't] do breakpoints
;	 	of 'b' el_boo (dig ? val ?? bgVuni)
	 	of 'c' elVclk = pol	; [don't] send clock interrupts
	 	of 'd' bgVdsk = pol	; [don't] trace disk operations
	 	of 'f' bgVfst = pol	; [don't] use fast mode
	 	of 't' bgVcpu = pol	; [don't] catch bus/cpu/mmu traps
	 	of 'r' bgVreg = pol	; [don't] display registers on entry
;	 	of 's' nothing		; d-space
	 	of 'p' elVpau = pol	; [don't] pause for output
	 	of 'w' bgIwat.Venb = pol; [don't] watch
		of other
			inv = 1		;
		end case
		++cmd if !inv

	 of 'f'	bgVfad=val if dig	;
		bgVfad=adr otherwise	;
		bgVfen = 1		;
		bgVfel = 0		;
					;
	 of 'g' PC = val if dig		; #g	goto
		PC = adr otherwise	;
		adr = PC		;
		next if *cmd		;
		fine bg_res ()		;
					;
	 of 'h'	bg_hlp ()		; h	help
					;
;	 of 'i'				; i	instruction space
					;
	 of 'k' bgVpsw = 0		; k	kernel mode
					;
	 of 'l'	hi_prv (&his)		; l	last (previous) in history
		adr = his.Vloc		;
		bgVpsw = his.Vmod	;
					;
	 of 'm'	if snd eq 'a'		; ma	machine address 
	           adr = val if dig	;
		   adr |= elQIO		;
		elif snd eq 'r'		; mr	machine restore
		   if bg_mrs (&mch)	;	restore machine state
		      opc = mch.Vopc	;
		      nxt = mch.Vnxt	;
		   .. adr = mch.Vadr	;
a
		elif snd eq 's'		; ms	machine save
		   mch.Vopc = opc	;
		   mch.Vnxt = nxt	;
		   mch.Vadr = adr	;
		   bg_msv (&mch)	;	save machine state
		else
		   inv = 1		;
		end
	 	++cmd if !inv
					;
	 of 'n'	hi_nxt (&his)		; n	next in history
		adr = his.Vloc		;
		bgVpsw = his.Vmod	;
					;
	 of 'o' bg_res ()		; o 	step over
		bgVovp=adr+(rev.Vlen*2)	;
		bgVstp=0, bgVovr=1	;
		fine			;
					;
	 of 'p'	if snd eq 'c'		; pc	pc
		   adr = elREG + (7*2)	;
		.. next ++cmd		;
					;
	 	if snd eq 's'		; pc	pc
		   adr = elPSW		;
		.. next ++cmd		;
					;
	 	bg_res ()		; p	proceed
		bgVict = 0		;
		bgVcnt = lng if dig	; #p
		fine			;
					;
	 of 'r'	if snd eq 's'		; rs	psw
		   adr = elPSW, ++cmd	;
		elif ct_dig(*cmd)	; r#	register
		   adr = ((*cmd++ - '0')*2) + elREG
		else			; r	all registers
		.. bg_reg ()		;
					;
	 of 's'	if snd eq 'p'		; sp	sp
		   adr = elREG + (6*2)	;
		   next ++cmd		;
		elif snd eq 'b'		; show bytes
		   bgVwid = 1		;
		   next ++cmd		;
		elif snd eq 'i'		; step into
		   bg_res ()		;
		   bgVcnt = val if dig	;
		   bgVcnt = 1 otherwise	;
		   bgVstp=1		;
	           ++bgVstp if st_sam (rea,"bpt")
		   fine			;
		elif snd eq 'm'		; show mmu (???supervisor mode)
		   bg_mmu ()		; ???undocumented
		   next ++cmd		;
		elif snd eq 'o'		; step over
		   bgVovp=adr+(rev.Vlen*2)
		   bgVstp=0, bgVovr=1	;
		   fine			;
		elif snd eq 's'		; show settings
		   bg_sho ()		;
		   next ++cmd		;
	 	elif snd eq 't'		; show address translation
		   val = adr if !dig	; 
		   bg_map (val)		;
		   next ++cmd		;
		elif snd eq 'w'		; show words
		   bgVwid = 2		;
		   next ++cmd		;
		elif snd eq 'u'		; set stack underflow
		   ++cmd		; skip 'u'
		   bg_val (&cmd, &val, &lng, "") ; get value
		   val = 0 if fail	; default
		   bgVund = val		;
		.. next			;
					;
		bg_res ()		; s	step
					;
		if !dig			; step over jsr xx,yy 
		&& (rev.Vopc & ~(070)) eq 04707
		   bgVovp=adr+(rev.Vlen*2)
		   bgVstp=0, bgVovr=1 
		.. fine		
					;
		bgVcnt = val if dig	;
		bgVcnt = 1 otherwise	;
		bgVstp=1		;
	        ++bgVstp if st_sam (rea,"bpt")
		fine			;
					;
	 of 't'	if snd eq 'r'		; tr	trace instructions
		   bg_res ()		; 	step
		   bgVcnt = val if dig	;
		   bgVcnt = 1 otherwise	;
		   bgVstp = 1		;
		   bgVtra = 1		;
		.. fine			;
					;
	 	fail if snd eq 't'	; tt	transfer trap to program
					;
		bg_res ()		;
	        bgVtop=val if dig	; #t	step to
		bgVtop=adr otherwise	;
		bgVsto = 1		;
	        fine			;
					;
	 of 'u' bgVpsw = 0140000	; u	user mode
	 of 'v'	bgVval = 1		; v 	show values
	 of 'w'	if snd eq 'v'		; wv	watch value
		   bgIwat.Vmat = val	;
	           bgIwat.Vflg = 1	;
	        .. next ++cmd		;
	        val = adr if !dig	; w	watch
		bg_set (&bgIwat,val,bgVpsw);
		bgIwat.Vval = bg_fwd (val)
		bgIwat.Padr = PNW(bg_vpx (val))
		bgVovr = 0		;
					;
	 of 'x'	el_exi ()		; x	exit
					;
	 of 'y' adr = bgVprv		; y 	backup
					;
	 of 'z' bgVzed = val		;
	 of '@' adr = val if dig	;
		adr = bg_fwd (adr)	; @	indirect
	 of '>' adr = rev.Vdst		;
	 of '='	adr = val if dig	;	got an address
		bg_val (&cmd, &val, &lng, "");	get required value
		next if fail		;	nothing doing
		bg_swd (adr, val)	;	set the bugger
		if adr ne 0177776	;	if not the PSW
		.. adr += 2		;	skip it
	 of '.' adr = PC		; .
	 of '!'	 *cmd = 0		; !	comment
	 of ','	 nothing		;
	 of ' '	 nothing		;	space
	 of '\t' nothing		;	tab
	 of other
		 inv = 1		;
	 end case
	 *cmd = 0, bg_inv (rep, cmd) if inv
	end
      end
     forever
  end
code	assists

  type	bgTctx
  is	Vsch : int
	Vpsw : int
  end

  func	bg_sav
	ctx : * bgTctx
  is	ctx->Vsch = elVsch
	ctx->Vpsw = PS
	elVsch = 0
	NEWPS(bgVpsw)
  end

  func	bg_rst
	ctx : * bgTctx
  is	sch : int = elVsch
	if sch & elMMX_
	&& !elVprb
	.. PUT("?V11-I-Memory management exception\n")
	elVsch = ctx->Vsch
	NEWPS(ctx->Vpsw) 
  end

  func	bg_fwd
	adr : elTadr
	()  : elTwrd
  is	ctx : bgTctx
	val : elTwrd
	reply *PNW(adr) if adr ge elQIO

	bg_sav (&ctx)
	if adr & 1
	|| (bgVwid eq 1) && bgVval
	   val = el_fbt (adr) & 0377
	else
	.. val = el_fwd (adr)
	bg_rst (&ctx)
	reply val
  end

  proc	bg_swd
	adr : elTadr
	val : elTwrd
  is	ctx : bgTctx
	bg_sav (&ctx)
	if adr & 1
	   el_sbt (adr, val)
	else
	.. el_swd (adr, val)
	bg_rst (&ctx)
  end

code	bg_val - get value

  func	bg_val
	cmd : ** char
	val : * elTwrd
	lng : * int
	msg : * char
  is	ptr : * char = *cmd
	if !ct_dig (*ptr)		;
	   if msg
	   .. PUT(*msg ? msg ?? "?V11-E-No value specified\n")
	.. fail
	SCN(ptr, "%o", lng)		; get the number
	*val = *<*elTwrd>lng
	++ptr while ct_dig(*ptr)	; skip it
	*cmd = ptr
	fine
  end

code	bg_vpx - physical translation

  func	bg_vpx
	adr : elTadr
	()  : elTadr
  is	ctx : bgTctx
	res : elTadr
	bg_sav (&ctx)
	res = VPR(adr)
	bg_rst (&ctx)
;PUT("adr=%o pa=%x\n", adr, res)
	reply res
  end

code	bg_res - resume operation

  proc	bg_res
  is	bgVfst=0, bgVhlt=0	;
	bgVcnt=0, bgVstp=0	;
 	bgVovr=0, bgVsto=0	;
 end

code	bg_bpt - set breakpoint

  func	bg_bpt
	adr : elTwrd
	mod : int
  is	bg_set (&bgIbpt, adr, mod)
  end

code	bg_set - set address

  func	bg_set
	trg : * bgTtrg
	loc : elTwrd
	mod : int
  is	trg->Venb = 1
	trg->Vloc = loc
	trg->Vmod = mod & elCUR_
  end

code	bg_prb - setup memory probe

  func	bg_prb
	opr : int
  is	res : int  = 0

	case opr
	of bgPRB  elVprb = 1		; setup to probe
	of bgTST  res = elVprb eq -1	; test and clear
	or bgCLR  elVprb = 0		; clear
	of bgERR  if elVprb		; set error
		  .. elVprb=-1, res=1	; advise (not) probing
	end case
	reply res
  end
code	display help

	bgAhlp : [] * char

;	H	Debug help
;	HA	Alt-Key help

  proc	bg_hlp
  is	hlp : ** char = bgAhlp		; help lines
	lft : ** char = hlp		; 
	rgt : ** char			;
	len : int = 0			;
	++len while *hlp++ 		; count them
	rgt = lft + (len /= 2)		; right
	PUT("\n")
	while len--			; got more
	   PUT("%-41s", *lft++)		; the left part
	   PUT("%s\n", *rgt++)		;
	end
	PUT("\n")
  end

  init	bgAhlp : [] * char
  is	"#B    Set Breakpoint [here]"
	" C    Clear: Break/Watch/Feel/Underflow"
;	" D[S] Data space"
	" E/D  Enable/Disable: Bus/Cpu/Bpt/Traps"
	"#F    Set Feelpoint [here]"
	"nG    Goto n"
	" H    Display help"
;	" I    Step into"
;	" I[S] Instruction space"
	" K    Kernel mode"
	" L    Open history previous (last)"
	" M    Machine: Address/Save/Restore"
	" N    Open history next"
;	" O    Step over"
	" PC   Display PC"
	" PS   Display PS"
	"nP    Proceed [n steps]"
	" Rn   Display register"
	" R    Display all registers"
	" SP   Display stack pointer"
	" SB   Show bytes"
	" SI   Step into"
	" SO   Step over"
	" SS   Show settings"
	"nST   Show MMU Translation"
	"nSU   Set Stack Underflow address"
	" SW   Show words"
	"nS    Step [n] inst's. Steps over JSR."
	" TT   Transfer trap"
	"#T    Step to [here]"
	" U    User mode"
	"#W    Set Watchpoint [here]"
	" X    Exit V11"
	""
	" \\    Toggle assembler/value display"
	" /    Toggle octal/decimal display"
	"Enter Open next location"
	";     Repeat previous command"
	".     Open PC location"
	"@     Indirect"
	"+-n   Add/Subtract n from location"
	"=n    Deposit n"
	"     "
	"# default=location, n default=none"
	<>
  end
code	display routines

If 0
  proc	bg_inf
  is	PUT("SP=%0o ", elPreg[6])
	PUT("PC=%0o ", elPreg[7])
	PUT("PS=%0o ", PS)
	PUT((TBIT) ? "t" ?? "")
	PUT((NBIT) ? "n" ?? "_")
	PUT((ZBIT) ? "z" ?? "_")
	PUT((VBIT) ? "v" ?? "_")
	PUT((CBIT) ? "c" ?? "_")
	PUT("\n")
  end
End

  proc	bg_reg
  is	PUT("R0=%0o ", elPreg[0])
	PUT("R1=%0o ", elPreg[1])
	PUT("R2=%0o ", elPreg[2])
	PUT("R3=%0o ", elPreg[3])
	PUT("R4=%0o ", elPreg[4])
	PUT("R5=%0o ", elPreg[5])
	PUT("SP=%0o ", elPreg[6])
	PUT("PC=%0o ", elPreg[7])
	PUT("PS=%0o ", PS)
	PUT((TBIT) ? "t" ?? "")
	PUT((NBIT) ? "n" ?? "_")
	PUT((ZBIT) ? "z" ?? "_")
	PUT((VBIT) ? "v" ?? "_")
	PUT((CBIT) ? "c" ?? "_")
	PUT("\n")
  end

  proc	bg_wrd
  is	PUT("OP=%0o ", elVopc)
	PUT("SWA=%0o ", elVswa)
	PUT("DWA=%0o ", elVdwa)
	PUT("SWV=%0o ", elVswv)
	PUT("DWV=%0o ", elVdwv)
	PUT("TWV=%0o ", elVtwv)
	PUT("\n")
  end
  proc	bg_byt
  is	PUT("OP=%0o ", elVopc)
	PUT("SBA=%0o ", elVsba)
	PUT("DBA=%0o ", elVdba)
	PUT("SBV=%0o ", elVsbv)
	PUT("DBV=%0o ", elVdbv)
	PUT("TBV=%0o ", elVtbv)
	PUT("\n")
  end

  func	bg_mem
	adr : elTadr
  is	reg : int = (adr - elREG) / 2

	if (reg ge 0) && (reg le 5)
	.. fine PUT("R%d", reg)
	fine PUT("SP") if reg eq 6
	fine PUT("PC") if reg eq 7
	
	fine PUT("PS") if reg eq 8
	fine PUT("PS") if adr eq elPSW

	case adr
	of elTKS  PUT("TKS ")
	of elTKB  PUT("TKB ")
	of elTPS  PUT("TPS ")
	of elTPB  PUT("TPB ")
	of hdCSR  PUT("DKS ")
	of hdCNT  PUT("DBC ")
	of hdBLK  PUT("DBL ")
	of hdBUF  PUT("DBU ")
	of other  PUT("%0o%s", adr, el_mod (bgVpsw))
		  fail
	end case
	PUT("%0o", adr)
	fine
  end

  proc	bg_dev
  is	uni : int = 0
	dev : * elTdev = elAdsk
	while uni lt 8
	   if dev->Anam[1]
	   .. PUT("LD%d: %-8d %s\n", dev->Vuni, dev->Vsiz, dev->Anam)
	   ++uni, ++dev
	end
  end

  proc	bg_dsk
  is	PUT("Disk: Csr=%0o ", el_fwd (hdCSR))
	PUT("Buf=%0o ", el_fwd (hdBUF))
	PUT("Cnt=%0o ", el_fwd (hdCNT))
	PUT("Blk=%0o\n", el_fwd (hdBLK))
  end

  proc	bg_sho
  is	bpt : * bgTtrg = &bgIbpt
	wat : * bgTtrg = &bgIwat
	fee : * bgTtrg = &bgIfee

;PUT("pa=%x val=%o\n", wat->Padr, *PNW(wat->Padr))

	PUT("\n")
	PUT("Debug:")
	PUT(" Bus=%d", bgVbus)
	PUT(" Cpu=%d", bgVcpu)
	PUT(" Reg=%d", bgVreg)
	PUT(" Bpt=%0o%s", bpt->Vloc, el_mod (bpt->Vmod))
	PUT("+") if bpt->Venb
	PUT(" Disk=%0o", bgVdsk)
	PUT(" Feel=%0o%s", fee->Vloc, el_mod (fee->Vmod))
	PUT("+") if fee->Venb
	PUT(" Watch=%0o%s:", wat->Vloc, el_mod (wat->Vmod))
	PUT("%0o", wat->Vval)
	PUT("+") if wat->Venb
	PUT(" Value=%o", wat->Vmat)
	PUT("+") if wat->Vflg
	el_new ()
	PUT("Terminal: TKS=%0o ", TKS)
	PUT("TKB=%0o ", TKB)
	PUT("TPS=%0o ", TPS)
	PUT("TPB=%0o\n", TPB)
	bg_dsk ()
	el_new ()
	bg_dev ()
	el_new ()
exit
	exit if elVsch
	PUT("Interrupts: ")
	PUT("Clock ") if elVsch & BIT(elCLK)
	PUT("Keyboard ") if elVsch & BIT(elKBD)
	PUT("Screen ") if elVsch & BIT(elTER)
	PUT("Disk ") if elVsch & BIT(elHDD)
	el_new ()
	el_new ()
  end

code	bg_dmp - dump ascii

  func	bg_dmp
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

  func	bg_wat 
  is	wat : * bgTtrg = &bgIwat
	PUT(" Watch: %o%s=%o/%d.",wat->Vloc,el_mod (wat->Vmod),
	   wat->Vval,wat->Vval)
  end

code	el_mod - get processor mode

  init	elAmod : [] * char
  is	"k", "s", "?", "u"
  end

  func	el_mod
	mod : elTwrd
	()  : * char
  is	reply "" if !elVmmu
	reply elAmod[(mod>>14)&3]
  end
code	memory management display routines

  func	bg_par
	mod : * char
	par : LONG
	stk : int
  is	ptr : * elTwrd = MNW (par)
	cnt : int = 8
	PUT("%s: ", mod)
	while cnt--
	  PUT("%o ", *ptr++ & 0xffff)
	end
	PUT("sp=%o ", elAstk[stk])
	PUT("PSS=%o ", elVpss) if elVpsr
	PUT("\n")
  end

  func	bg_mmu
  is	PUT(KERMOD ? "*" ?? " ")
	bg_par ("K", 0172340, 0)
	PUT(USPMOD ? "*" ?? " ")
	bg_par ("U", 0177640, 3)
 	PUT("PS=%o ", PS & 0xffff)
	PUT("SR0=%o, SR3=%o, ", MM0, MM3)
	PUT("18-bit") if !elV22b
	PUT("22-bit") otherwise
	PUT("\n")
  end

  func	bg_map
	adr : elTadr
  is	ctx : bgTctx
	ps  : elTwrd = PS
	bg_sav (&ctx)
	bg_tra (adr)
	bg_rst (&ctx)
  end

  func	bg_tra
	va  : elTadr
  is	apr : int = (va>>13) & 7
	off : int = va & 017777
	bas : int = elPpar[apr]
	pa  : int = (bas << 6) + off
PUT("par=%lx\n", elPpar)
	PUT("va=%o apr=%d off=%o bas=%o pa=%o ", va, apr, off, bas, pa)
 	PUT("mmu0=%o mmu3=%o psw=%o", MM0, MM3, PS) 
; 	PUT("cur=%o spm=%o\n", elVmmd, elVspm) 
	el_new ()
 end
code	bg_msv - machine save

;	Save machine to TMP:V11_n.DMP

	elVdsz : int+
	elVvsz : int+
	bgAmsv : [mxLIN] char = {0}
	bg_msp : (*char, *char, int)

  func	bg_msv
	mch : * bgTmch
  is	fil : * FILE
	spc : [mxSPC] char
	prm : [mxLIN] char
	fail if !bg_msp (spc, prm, 1)
	cl_cmd (prm, bgAmsv)
	fil = fi_opn (spc, "wb", "")
	if fil ne
	&& fi_wri (fil, bgAmsv, mxLIN)
	&& fi_wri (fil, mch, #bgTmch)
	&& fi_wri (fil, elAdsk, elVdsz)
	&& fi_wri (fil, elAvec, elVvsz)
	&& fi_wri (fil, elAsys, mxSPC)
	&& fi_wri (fil, &hiIsto, #hiTsto)
	&& fi_wri (fil, elPmem, elMEM)
	&& fi_clo (fil, "")
	.. fine
	fail PUT("?V11-W-Error saving machine\n")
  end

code	bg_mrs - machine restore

  func	bg_mrs
	mch : * bgTmch
  is	fil : * FILE
	spc : [mxSPC] char
	prm : [mxLIN] char
	fail if !bg_msp (spc, prm, 0)
	PUT("?V11-I-Restoring machine %s\n", spc)
	fil = fi_opn (spc, "rb", "")
a
	if fil ne
	&& fi_rea (fil, bgAmsv, mxLIN)
	&& fi_rea (fil, mch, #bgTmch)
	&& fi_rea (fil, elAdsk, elVdsz)
	&& fi_rea (fil, elAvec, elVvsz)
	&& fi_rea (fil, elAsys, mxSPC)
	&& fi_rea (fil, &hiIsto, #hiTsto)
	&& fi_rea (fil, elPmem, elMEM)
	&& fi_clo (fil, "")
	   el_rmt ()
	   PUT("V11-I-Machine save note: %s\n", bgAmsv)
	.. fine
	fail PUT("?V11-W-Error restoring machine %s\n", spc)
  end

code	bg_msp - machine save/restore spec

  func	bg_msp
	spc : * char
  	prm : * char
	sav : int		; 0=old, 1=new
  is	ver : [12] char
	cnt : int = 0
	fnd : int = 0		;

      repeat
	FMT(spc, "tmp:v11_%d.dmp", cnt)
	quit if fi_mis (spc, <>)
	++cnt, ++fnd
      end
	if !sav && !fnd
	.. fail PUT("V11-W-No machine save file found\n")
	--cnt if !sav
	FMT(spc, "TMP:V11_%d.DMP", cnt)
	FMT(prm, "?V11-I-Machine save TMP:V11_%d.DMP note: ", cnt)
	fine
  end
