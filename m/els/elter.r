;???;	ELTER - TKS issue is probably a TKS/interrupt race condition
;???;	ELTER - TKS sometimes jams with 300 (might be DOS problem too)
;???;	ELTER - TKS jam occurs after a trap to 4 etc sometimes
;???;	ELTER - or when I mishit the keyboard
file	elter - terminal emulation
include <windows.h>
include	elb:elmod
include elb:ekdef
include rid:vtdef
include	rid:chdef
include	rid:cldef
include rid:codef
include	rid:ctdef
include rid:kbdef
include	rid:imdef
include	rid:medef
include rid:prdef
include	rid:stdef
include rid:tidef
include rid:shdef
include rid:nfcab
include rid:dbdef

;	o  Asynchronous support (threaded)
;	o  Control keys
;	o  Ctrl-shift-C, H, Y
;	o  VT100 translation
;	o  Multiple terminal ports

	vt_hoo	: (*kbTcha) int
	ttVtra	: int- = 0
	ttVpau 	: int = 0
;???;	ELTER - move virtual terminal stuff to rls:wivir.r
code	vt_ini - initiate keyboard thread and hook

	ENABLE_VIRTUAL_TERMINAL_PROCESSING := 0x4
	ENABLE_VIRTUAL_TERMINAL_INPUT := 0x200
	ENABLE_PROCESSED_OUTPUT := 0x1

  proc	vt_ini
  is	han : * void
	mod : LONG = 0
  	ek_ini (&vt_hoo)
	exit if !elFvtx
;exit
	han = GetStdHandle (STD_INPUT_HANDLE)
	GetConsoleMode (han, &mod)
	exit if !db_lst ("IPT")
;	PUT("ipt=%o\n", mod)
	mod  = ENABLE_VIRTUAL_TERMINAL_INPUT
	SetConsoleMode (han, mod)
	exit if !db_lst ("VTT")

	han = GetStdHandle (STD_OUTPUT_HANDLE)
	GetConsoleMode (han, &mod)
	exit if !db_lst ("OPT")
;	PUT("opt=%o\n", mod)
	mod = ENABLE_VIRTUAL_TERMINAL_PROCESSING
	mod |= ENABLE_PROCESSED_OUTPUT
	SetConsoleMode (han, mod)
	exit if !db_lst ("VTT")
;	GetConsoleMode (han, &mod)
;	exit if !db_lst ("GCM")
;	PUT("mod=%x\n", mod)
  end

code	vt_ast - check abort

  proc	vt_ast
  is	el_exi () if elVsch & elEXI_
	if elVsch & elCTC_			; vrt vestige???
	.. elVsch &= ~(elCTC_)
  end
code	vt_hoo - keyboard thread hook

;	Treat this like an interrupt service routine.
;	If you call the debugger directly you'll hang because this
;	routine also delivers the debugger input.
;	Just set flags.

	vt_hlp : ()
	vt_sho : ()
	nfFtra : int+

  func	vt_hoo
	cha : *kbTcha
  is	flg : int = cha->Vflg
	ord : int = cha->Vord
PUT("%o ", ord)

	elVsch |= elCON_			; trigger call to el_tkb
	if (flg & ~(kbSYS_)) eq (kbALT_|kbASC_)	; alt-asc
;	|| (flg eq kbALT_|kbVIR_)		; hack for windows VT100
;	|| (flg eq kbSYS_|kbALT|kbVIR_)		; hack for windows VT100
	   case ch_upr (ord)
	   of 'A'  elVall = 1 if elVall
		   elVall = !elVall		; trace all emts
		   elVemt = 1 if elVall 	; enable EMTs if enabling ALL
		   nfFtra = 1			;
		   fine				;
	   of 'B'  ++bgVcth			; break - catch it later
		   elVsch |= elPAS_ 		;
		   fail cha->Vord = -1		; pass through
	   of 'C'  PUT("\n"), el_exi () 	; exit
	   of 'D'  fine elVdbg = !elVdbg 	; flip bus/cpu/bpt debug traps
	   of 'E'  fine elVemt = !elVemt 	; flip emt trace toggle
	   of 'F'  fine cab_rpt ()		; report cab files
;	   of 'G'
	   of 'H'  fine vt_hlp ()		; display help
	   of 'I'  fine bgVdsk = !bgVdsk 	; flip I/O disk trace
	   of 'J'  elVall = 2			; absolutely everything
		   elVemt = 1			;
		   fine
;	   of 'K'
	   of 'L'  fine el_lsd ()		; list logical disks
	   of 'M'  fine elVmai = !elVmai  ;?	; flip maintenance mode
	   of 'N'  ttVtra = !ttVtra		; flip network trace
	   	   fine nf_tra (ttVtra)		; 
;	   of 'O'
	   of 'P'  elVpau = !elVpau 		; flip screen pause
		   fine if elVpau		;
		   elVsch |= elPAS_ 		;
		   fail cha->Vord = -1		; pass through
	   of 'Q'  el_flg ()
;	   of 'R'
	   of 'S'  fine vt_sho ()		; show settings
	   of 'T'  fine bgVcpu = !bgVcpu 	; flip bus/cpu debug traps
;	   of 'U'
	   of 'V'  fine bgVter = !bgVter 	; flip VT100 trace
	   of 'W'  fine el_win ()		; windows dependencies
;	   of 'X'
	   of 'Y'  PUT("\n") if bgVtpb ne '\n'	; interrupt emulator
		   im_exe ("root:she.exe", "/s=V11>", 0)
	   of 'Z'  bgVzed = ~bgVzed		; internal debugging--varies
	.. end case

	if ttVpau
	&& flg eq (kbCTL_|kbASC_)
	&& ord eq 3
	.. elVsch |= elPAS_
	fail	
  end

code	vt_hlp - display help

  func	vt_hlp
  is
   PUT("\n")
   PUT("Alt-A	All  	Trace-All toggle\n")
   PUT("Alt-B	Break	Trigger debugger\n")
   PUT("Alt-C	Cancel	Exit emulator\n")
   PUT("Alt-D	Debug	Enable BPTs toggle\n")
   PUT("Alt-E	EMTs	Trace EMTs toggle\n")
   PUT("Alt-F	Files	Report open NF files\n")
;	    G
   PUT("Alt-H	Help	Display this\n")	
   PUT("Alt-I	I/O	Disk I/O trace toggle\n")
;	    J
;	    K
   PUT("Alt-L	Logical	List logical disks\n")
   PUT("Alt-M	Maint	Catch everything toggle\n")
   PUT("Alt-N	Net	NF operations trace toggle\n")	
;	    O
   PUT("Alt-P	Pause	Screen pause toggle\n")
;	    Q
;	    R
   PUT("Alt-S	Show	Show current settings\n")	
   PUT("Alt-T	Traps	Catch bus/address traps toggle\n")	
;	    U
   PUT("Alt-V	VT100	VT100 operations trace toggle\n")	
   PUT("Alt-W   Windows Show Windows dependencies\n")
   PUT("Alt-Y	Shell	Interrupt emulator\n")	
;	    Z
  end

code	vt_sho - show items

	vt_itm : (*char, int)
  func	vt_sho
  is	PUT("\n")
	vt_itm ("All", elVall)
	vt_itm ("Debug", elVdbg)
	vt_itm ("EMTs", elVemt)
	vt_itm ("I/O", bgVdsk)
	vt_itm ("Maint", elVmai)
	PUT("\n")
	vt_itm ("Net", ttVtra)
	vt_itm ("Pause", elVpau)
	vt_itm ("Traps", bgVcpu)
	vt_itm ("VT100", bgVter)
	PUT("\n")
  end

  func	vt_itm
	tit : * char
	flg : int
  is	PUT("%s=", tit)
	PUT("On ") if flg
	PUT("Off ") otherwise
  end

code	el_tkb - pdp tks/tkb - machine in

;	Called when the CPU keyboard hook triggers scheduler
;	el_tkb calls el_get to get the next character

	elVtkp : elTwrd = 0

  proc	el_tkb
  is	asc : int
	if TKS & elRDY_				; got something
	&& !(elVsch & BIT(elKBD))		; but not scheduled
	   if !(elVtkp & elENB_)		; wasn't enabled 
	   && (TKS & elENB_)			; but is now
	   .. el_sch (elKBD)			; trigger interrupt
	   elVtkp = TKS				; previous
	.. exit					;
	elVtkp = TKS				; previous
;??? check DOS boot error here						;
	exit if TKS & elRDY_			; already has stuff

	asc = el_get ()				; get another
	exit if fail				;

;???PUT("(%o) ", asc)
	exit if asc eq 255			;

	asc = ch_upr (asc) if elFupr		; uppercase terminal
	elVtks = 0, elVtkb = 1			;
	TKB = asc, TKS |= elRDY_		;
	el_sch (elKBD)
  end

code	el_tpb - pdp tps/tpb - machine out

;	Called when the CPU keyboard hook triggers scheduler
;	el_tpb calls el_put to output a character

  proc	el_tpb
  is	val : int
	val = TPB & (elF7bt ? 127 ?? 255)	; clean up
;	exit if !val				; ignore nulls
;	if !(elVcmd & elENB_)			; command input not active
	el_sig (val)				; collect opening signature
	if !elPcmd ;|| elPsig
	&& val && (val ne 127)			;
	.. el_put (val)				;
	bgVtpb = val				; clear trigger
	TPB=0, TPS|=elRDY_, el_sch (elTER)	; setup for interrupt
  end

code	el_sig

;	el_boo uses elPsig to pass startup commands to RSX

  proc	el_sig
	cha : int
  is	exit if !elPsig
	if elPsig[elVsig] ne cha
	.. exit elVsig = 0
	exit if elPsig[++elVsig]
	elPsig = 0
  end
code	el_get - terminal input

;	Called by el_tkb to get a keyboard character
;	
;	alt-c	exit
;	alt-h	debug
;	alt-t	trace
;	scrlk	flip elVpau
;	ctl-*	ctl-*
;	asc-8	asc-127

	el_ctl : (kbTcha, *int) int

	xxABT := 0
	xxCHA := 1
	xxINT := 2
	xxOTH := 3
	xxIGN := 4

  func	el_flu
  is	cha : kbTcha
	spin while ek_get (&cha, kbGET_)	; flush input buffer
  end

  func	el_get
  is	cha : kbTcha
	asc : int
	typ : int
     repeat
	if elPcmd && !elPsig			; got an image command
	   asc = *elPcmd++			; next
	   asc = '\r', elPcmd = <> if !asc	; last
	.. reply asc				;

	if vtPipt				; got escape sequence
	   if (asc = *vtPipt++) ne		; got another
	      asc = 033 if asc eq '$'		; convert $ to escape
	   .. reply asc				;
	.. vtPipt = <>				; end of sequence

	fail if !ek_get (&cha, kbGET_)		; no character available

	next if cha.Vflg eq -1			; skip this character
	typ = el_ctl (cha, &asc)		; translate it
;PUT("%o ", asc); if asc lt 32
	case typ				;
	of xxINT
	or xxABT fail				;
	or xxIGN next
	end case				;
;;;	next if elFvtx && vt_ipt (cha)		; input escape sequences
	reply asc if typ ne xxOTH		;
     forever
  end

code	el_ctl - process control characters

  func	el_ctl
	cha : kbTcha
	res : * int
  is	flg : int = cha.Vflg
	ord : int = cha.Vord
	asc : int = 0
	pc  : elTwrd = PC

	if (flg eq kbASC_) && (ord eq 8)	; asc-7 => 127
	.. fine *res = 127			; backspace is DEL

	if flg eq kbASC_			;
	|| flg eq (kbASC_|kbSHF_)		;
	|| flg eq (kbASC_|kbCTL_)		;
	.. fine *res = ord			;%o ", asc)
PUT("flg=%o ord=%d ", flg, ord)

	if (flg eq kbSYS_|kbVIR_)
	.. flg = (flg & ~(kbSYS_)) || (kbALT_|kbASC_)	; alt-asc

	if (flg & ~(kbSYS_)) eq (kbALT_|kbASC_)	; alt-asc
	|| (flg eq kbALT_|kbVIR_)		; hack for windows VT100
	   asc = ch_upr (ord)			; get lower case
;PUT("ctl=%o ", asc)
	   reply xxABT if asc eq 'B'		; debug coming through
	.. reply xxIGN				;
;PUT("$")

	reply xxIGN if flg eq -1		;
	reply xxOTH				; other
  end
code	el_put - terminal output

	elVlst : int = 0			; last output character
	elVlin : int = 0			; pause line counter
	elVscr : int = 24 			; pause screen size
	elHopt : * void = 0			; terminal handle

  proc	el_put
	cha : int
  is	buf : [128] char
	res : LONG
	exit if !cha

	if elHopt eq			; get terminal handle
	.. elHopt = GetStdHandle (STD_OUTPUT_HANDLE)
	elVlst = cha			; save last char

;???	if !elFvtx || !vt_opt (cha)	; try video output
	   buf[0] = cha			; we do it
;???	.. WriteConsole (elHopt, buf, 1, &res, <>)
	   WriteConsole (elHopt, buf, 1, &res, <>)

	fi_opt (elPlog, &cha, 1) if elVlog ; log output

	bgVtpb = cha			; remember last char

	exit if !elVpau			; no pause
	++elVlin if cha eq '\n'		; count lines
	exit if elVlin lt elVscr	; more to go
	elVlin = 0			; reset counter
	ttVpau = 1			; terminal in pause
	el_prm ("More? ", buf)		; prompt for more
	ttVpau = 0			; clear pause flag
	vt_ast ()			; trigger terminal
  end

  proc	el_new
  is	el_put ('\n')			; new line
  end

  proc	el_sol
  is	el_new () if elVlst ne '\n'	; force start-of-line
  end
code	el_prm - prompt for input

;	Prompt for "More?"

	elPlin : * coTlin- = {0}

  func	el_prm
	prm : * char
	buf : * char
  is	lin : * coTlin = co_lin (&elPlin, prm)
	cha : kbTcha
	ctl : int
 	pc  : elTwrd = PC
     repeat
	if elVsch & (elBRK_|elEXI_|elCTC_|elPAS_)
	.. fail vt_ast ()
	fail if !(*coPget)(&cha, kbWAI_|kbPEE_); check the next
	if elVsch & (elBRK_|elEXI_|elCTC_|elPAS_)
	.. fail vt_ast ()

	fail if !(*coPget)(&cha, kbWAI_); get the next
	next if cha.Vflg eq -1		; break through character

	case el_ctl (cha, &ctl)		; translate it
	of xxABT fail			;
	of xxIGN next			; ignore
	of xxINT next ;co_rpt (lin_)	; interrupted - repaint
	end case			; ordinary character

	co_edt (lin, &cha)		; update line
	next if fail			; more to go
	fine co_cop (lin, buf)		; return line
     forever
  end
