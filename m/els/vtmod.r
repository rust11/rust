;???;	VTMOD - Clear screen function broken "Esc[H, Esc[J"
;???;	VTMOD - Trying using "Esc[2J" - clear screen
file	vtmod - vt100 emulation
include <windows.h>
include rid:vtdef
include	rid:chdef
include	rid:ctdef
include	rid:stdef

;	Used by V11

  type	vtTscr
  is	Vact : int 
	Vhan : * void
	Pseq : * char
	Aseq : [32] char
	Vcnt : int
	Apar : [2] int
	Ireg : SMALL_RECT
 	Isav : COORD
	Vcup : int
	Vmod : int		; 0 or 52
	Vint : int		; introducer: ESC or CSI
  end

  type	vtTctx
  is	Pscr : * void
  end
	vtIscr : vtTscr = {0}
	vtIctx : vtTctx = {&vtIscr}

	vtPipt : * char = <>
	vtAipt : [16] char = {0}
	vtPopt : * char = <>
	vtAopt : [16] char = {0}

	vt_rep : (*char) int
	vt_scr : (*vtTctx, int) int
	vt_cup : (*vtTctx, int)
;	vt_eol : () 

	vt_act : (*vtTctx, int, int, int, int)
	vtVseq : int = 0

	vtV52  := -1
	vtESC  := 0
	vtCSI  := 1
	vtDEC  := 2
	vtINT  := 3
	 sRAW  := 0

	CSI    := 0233
	ESC    := 033
	SO     := 14
	SI     := 15
	LF     := 10

	bgVter : int+
	bgVtpb : WORD+

  func	vt_eol
  is	nothing
  end

  func 	vt_mod
	mod : int
  is	scr : * vtTscr = &vtIscr
	cur : int
	cur = scr->Vmod
	scr->Vmod = mod if mod
	reply cur
  end
el_dbg :  (*char)
code	vt_ipt - keyboard escape sequences

;	Translate windows virtual keyboard code to VTxxx sequence

  func	vt_ipt
	cha : kbTcha
  is	str : * char = <>
	flg : int = cha.Vflg
	ord : int = cha.Vord
	scr : * vtTscr = &vtIscr
	v52 : int = scr->Vmod eq 52

	flg &= (kbENH_|kbCTL_|kbSHF_|kbALT_|kbSYS_|kbVIR_|kbASC_|kbPAD_)

	if v52 & (flg & kbPAD_)
	   case ord
	   of 69  str = "$?P"	; PF1  numlock
	   of 53  str = "$?Q"	; PF2  /
	   of 55  str = "$?R"	; PF3  *	
	   of 74  str = "$?S"	; PF4  -
	   of 78  str = "$?m" if flg & kbSHF_	; -  +  shifted
		  str = "$?l" otherwise		; ,  +  unshifted
	   of 82  str = "$?p"	; 0
	   of 79  str = "$?q"	; 1
	   of 80  str = "$?r"	; 2
	   of 81  str = "$?s"	; 3
	   of 75  str = "$?t"	; 4
	   of 76  str = "$?u"	; 5
	   of 77  str = "$?v"	; 6
	   of 71  str = "$?w"	; 7
	   of 72  str = "$?x"	; 8
	   of 73  str = "$?y"	; 9
	   of 83  str = "$?n"	; .
	   of 28  str = "$?M"	; enter
	   end case

	elif flg & kbPAD_
	   case ord
	   of 69  str = "$OP"	; PF1  numlock
	   of 53  str = "$OQ"	; PF2  /
	   of 55  str = "$OR"	; PF3  *	
	   of 74  str = "$OS"	; PF4  -
	   of 78  str = "$Om" if flg & kbSHF_	; -  +  shifted
		  str = "$Ol" otherwise		; ,  +  unshifted
	   of 82  str = "$Op"	; 0
	   of 79  str = "$Oq"	; 1
	   of 80  str = "$Or"	; 2
	   of 81  str = "$Os"	; 3
	   of 75  str = "$Ot"	; 4
	   of 76  str = "$Ou"	; 5
	   of 77  str = "$Ov"	; 6
	   of 71  str = "$Ow"	; 7
	   of 72  str = "$Ox"	; 8
	   of 73  str = "$Oy"	; 9
	   of 83  str = "$On"	; .
	   of 28  str = "$OM"	; enter
	   end case

	elif v52 && (flg eq (kbENH_|kbVIR_))
	   case ord
	   of 37  str = "$D"	; <
	   of 38  str = "$A"	; ^
	   of 39  str = "$C"	; >
	   of 40  str = "$B"	; v
	   end case
	elif flg eq (kbENH_|kbVIR_)
	   case ord
	   of 37  str = "$[D"	; <
	   of 38  str = "$[A"	; ^
	   of 39  str = "$[C"	; >
	   of 40  str = "$[B"	; v
	   of 45  str = "$[1~"	; find
	   of 36  str = "$[2~"	; insert here
	   of 33  str = "$[3~"	; remove
	   of 46  str = "$[4~"	; select
	   of 35  str = "$[5~"	; prev screen
	   of 34  str = "$[6~"	; next screen
;	   of 144 str = "$OP"	; PF1
	   end case
;	elif flg eq (kbENH_|kbASC_)
;	   case ord
;	   of 47  str = "$OQ"		; PF2
;	   of 13  str = "$OM"		; RETURN
;	   end case
;	elif flg eq kbVIR_		
;	   case ord
;	   of 45  str = "$Op"		; 0
;	   of 35  str = "$Oq"		; 1
;	   of 40  str = "$Or"		; 2
;	   of 34  str = "$Os"		; 3
;	   of 37  str = "$Ot"		; 4
;	   of 12  str = "$Ou"		; 5
;	   of 39  str = "$Ov"		; 6
;	   of 36  str = "$Ow"		; 7
;	   of 38  str = "$Ox"		; 8
;	   of 33  str = "$Oy"		; 9
;	   of 46  str = "$On"		; . del
;	   end case
	end
;PUT("<%s>",str) if str && bgVter
	reply vt_rep (str)
  end

;	vt_rep - reply string

  func	vt_rep
	str : * char
  is	fail if !str
	vtPipt = vtAopt
	st_cop (str, vtPipt)
	fine
  end
code	vt100 screen data

	vtVcup : int = 0	; fix a Win32 bug

  init	vtAv52 : [] * char	; VT52
  is	vCUP:	"A"		; cursor up
	vCDN:	"B"		;
	vCRT:	"C"		;
	vCLF:	"D"		;
	eGRA:	"F"		; enter graphics mode
	lGRA:	"G"		; leave
	vHOM:	"H"		; cursor home
	vRLF:	"I"		; reverse line feed
	vESC:	"J"		; erase to end of screen
	vELN:	"K"		; erase to end of line
	vPOS:	"Y@@" ;line col	; position
	vIDT:	"Z"		; identify
	eAKM:	"="		;
	lAKM:	">"		;
	eANS:	"<"		; enter ansii mode
	eAUT:	"^"		; enter auto print mode
	lAUT:	"_"		;
	ePRT:	"W"		; printer controller mode
	lPRT:	"X"		;
	ePSC:	"]"		; print screen
	vPLN:	"V"		; print line
	vUNK:	"\\"		; unknown
		<>
  end

  init	vtAesc : [] * char
  is	xHTR:	"C"		; hard terminal reset
	xSUP:	"D"		; scroll up or cursor down
	xSDN:	"M"		; scroll down or cursor up
	xNLN:	"E"		; start of next line, scroll if at bottom
	xSAV:	"7"		; save cursor, attributes
	xRST:	"8"		; restore, home if nothing saved
	xTOP:	"#3"		; top character
	xBOT:	"#4"		; bottom character
	cDBL:	"#5"		; single width line
	sDBL:	"#6"		; double width line
	xAPP:	"="		; application keypad
	xANS:	"<"		; ansi mode
	xNUM:	">"		; numeric keypad
	aDID:	"Z"		; identify: "$/Z"
	xRES:	"c"		; reset
	xAG0:	"(B"		; select ascii G0
	xAG1:	")B"		; select ascii G1
	xSG0:	"(0"		; select special graphics G0
	xSG1:	")0"		; select special graphics G1
		<>		;
  end

  init	vtAcsi : [] * char
  is	xCSC:	"J[J"		; clear to end of screen 
	aCSC:	"J[0J"		; clear to end of screen 
	xCBS:	"J[1J"		; clear to beginning of screen
	xCSN:	"J[2J"		; clear entire screen
	xCLI:	"K[K"		; clear to end of line
	aCLI:	"K[0K"		; alternate
	xCBL:	"K[1K"		; erase to beginning of line
	xCLN:	"K[2K"		; erase line

	cHOM:	"H[H"		; cursor home
	rHOM:	"f[f"		; region home

	xCUP:	"A[@A"		; cursor up
	xCDN:	"B[@B"		; cursor down
	xCRT:	"C[@C"		; cursor right
	xCLF:	"D[@D"		; cursor left
	cPOS:	"H[@;@H"	; position (line, column)
;???
	rPOS:	"H[@;@H"	; region position	
	xREG:	"r[@;@r"	; scrolling region (top, bottom)
	aREG:	"r[r"
	sIRM:	"h[4h"		; insert on 
	cIRM:	"h[4l"		; replace on
	xDCH:	"L[@L"		; delete characters
	xDLN:	"L[@M"		; delete line

	sKBL:	"h[2h"		; keyboard locked
	cKBL:	"h[2h"		; keyboard unlocked
	sSRM:	"l[12l"		; send-receive echo on
	cSRM:	"h[12h"		; send-receive echo off

	cALL:	"m[0m"		; all attributes off
	aALL:	"m[m"		; alternate
	sBOL:	"m[1m"		; bold on
	aBOL:	"m[7;1m"	; undocumented -- used by KED
	cBOL:	"m[22m"		; bold off
	sUND:	"m[4m"		; underline on 
	cUND:	"m[24m"		; underline off 
	sBLK:	"m[5m"		; blink on
	cBLK:	"m[25m"		; blink off
	sREV:	"m[7m"		; reverse on
	cREV:	"m[27m"		; reverse off
	x100:	"p[61:p"	; VT100 mode
	x200:	"p[62;1:p"	; VT200 mode
	xDSR:	"n[5n"		; request status report "$[0n"
	xCPR: 	"n[6n"		; request cursor position
	xSTR:	"p[!p"		; soft terminal reset
	xDAD:	"c[c"		; device attributes
	xNOP:   "q[q}"		; lights on/off
	xNO2:   "q[@q}"		; lights on/off
		<>		; "[@;@R" - cursor position report
  end

  init	vtAdec : [] * char
  is	xV52:	"l[?2l"		; set VT52 mode
	x80:	"l[?3l"		; 80 character line
	x132:	"h[?3h"		; 132 character line
	sJMP:	"l[?4l"		; jump scroll
	cJMP:	"h[?4h"		; smooth scroll
	sLCK:	"h[?6h"		; cursor locked to scrolling region
	cLCK:	"l[?6l"		; cursor not locked
	sWRP:	"h[?7h"		; set wrap
	cWRP:	"l[?7l"		; clear wrap
	sNLM:	"l[?20l"	; newline mode - usual
	cNLM:	"h[?20h"	; newline mode - lf -> cr/lf
	sAUT:	"h[?8h"		; autorepeat on
	cAUT:	"l[?8l"		; autorepeat off
	sCKM:	"h[?1h"		; cursor keys application mode
	cCKM:	"l[?1l"		; cursor-keys ansi mode
	xDID:	"c[?6c"		; identify: "VT102"
		<>		;
  end

  func	vt_num 
	mod : int
	str : * char
	res : * int
	()  : * char
  is	*res = 0
	if mod eq 52
	   if *str gt 037
	   .. *res = *str++ - 037
;	   if *str gt 060
;	   .. *res = *str++ - 060
	else
	   while ct_dig (*str)
	      *res *= 10
	      *res += *str++ - '0'
	   end	
	end
	reply str
  end
code	vt100 screen

  func	vt_opt
	cha : int 
  is
;PUT("(%o=%c)", cha,cha)
	fine if vt_scr (<>, cha)
;	fine if vt_cup (<>, cha)
;	vt_eol () if cha eq LF
	fail
  end

  func	vt_scr
	ctx : * vtTctx
	cha : int
  is	scr : * vtTscr
	lst : ** char = vtAesc
	mod : * char
	seq : * char
	par : * int
	ctl : int
	fnd : int
	act : int = -1
	p1  : int
	p2  : int
	typ : int = vtESC

;PUT("%c", (cha eq ESC) ? '$' ?? cha)

	ctx = &vtIctx if !ctx
	scr = ctx->Pscr

	if scr->Vmod eq 52
	   lst = vtAv52
	   typ = vtV52
	.. cha &= 0177

	fine if cha eq SO
	fine if cha eq SI

	if cha eq ESC
	|| cha eq CSI
	   scr->Vint = cha
	   scr->Vcnt = 0
	   scr->Vact = 1
	   scr->Aseq[0] = scr->Aseq[1] = scr->Aseq[2] = 0
	   scr->Pseq = scr->Aseq
	.. fine

	fail if !scr->Vact		; not for us

	if scr->Vcnt++ ge 30		;
	.. fail scr->Vact = 0		; overflowed

	bgVtpb = 1			;
	if (typ eq vtV52) && (cha eq ' ')	;
	.. cha = '1'

	*scr->Pseq++ = cha		; store next
	*scr->Pseq = 0			;
	if scr->Aseq[0] eq '['		;
	   fine if !ct_alp (cha)	;
	   typ = vtCSI			;
	   lst = vtAcsi			;
	   if scr->Aseq[1] eq '?'	;
	      typ = vtDEC		;
	.. .. lst = vtAdec		;
     while *lst
	++act				; action
	mod = *lst++			; get the model
	next if typ gt && (*mod++ ne cha) ; optimise a little
	seq = scr->Aseq
	par = scr->Apar
	par[0] = par[1] = 0
	fnd = 1
	while *mod
	   if *mod eq '@'		; want a number
	      fine if !*seq		; no number
	      seq = vt_num (scr->Vmod, seq, par++)	;
	   .. next ++mod

	   if (*mod eq ':') && (*seq eq '"')
	   || *mod eq *seq		; still good
	   .. next ++mod, ++seq		;
	   fine if !*seq && *mod	; incomplete
	   quit				;
	end				;
	next if *mod || *seq		; not found
	if bgVter
	   mod = *--lst
	   ++mod if typ
	   vtVseq = 0 if ++vtVseq gt 9
	   PUT("{%d:\"%s\"(%d,%d) %d,%d} ", 
		vtVseq, scr->Aseq,scr->Apar[0],scr->Apar[1], typ, act)
	else
	.. vt_act (ctx, typ, act, scr->Apar[0], scr->Apar[1])
	scr->Vact = 0
	fine
    end
	if *mod && *seq
	   vtVseq = 0 if ++vtVseq gt 9
	   PUT("?%s", (typ eq vtCSI) ? "C" ?? "E")
	.. PUT("{%d:\"%s\"} ", vtVseq, scr->Aseq)
	scr->Vact = 0
	fine
  end
  func	el_vtt
  is	mod : LONG = ENABLE_VIRTUAL_TERMINAL_INPUT
	GetStdHandle (STD_OUTPUT_HANDLE)
	SetConsoleMode (that, mod)
  end

code	screen action

	COMMON_LVB_UNDERSCORE := 0x8000
	COMMON_LVB_REVERSE_VIDEO := 0x4000
	ENABLE_INSERT_MODE := 0x20
	ENABLE_EXTENDED_FLAGS := 0x0080

  func	vt_act
	ctx : * vtTctx
	typ : int
	act : int
	a1  : int
	a2  : int
  is	scr : * vtTscr = ctx->Pscr
	han : * void = scr->Vhan
	coo : COORD
	cur : COORD
	siz : COORD
	inf : CONSOLE_SCREEN_BUFFER_INFO
	win : SMALL_RECT
	reg : SMALL_RECT
	clp : SMALL_RECT
	dum : LONG
	att : WORD
	raw : WORD
	fil : CHAR_INFO
	mod : LONG
	p1  : int = a1 ? a1 ?? 1
	p2  : int = a2 ? a2 ?? 1

	scr->Vcup = 0

	if !han
	   han = scr->Vhan = GetStdHandle (STD_OUTPUT_HANDLE)
	   GetConsoleScreenBufferInfo (han, &inf)
	   scr->Ireg.Top=0, scr->Ireg.Bottom=23
	end

	GetConsoleScreenBufferInfo (han, &inf)
	coo.X = p1, coo.Y = p2
	win = inf.srWindow
	reg = scr->Ireg
	cur = inf.dwCursorPosition
	att = inf.wAttributes
	siz = inf.dwSize
	FOREGROUND_INTENSITY|COMMON_LVB_UNDERSCORE
	raw = att & ~(COMMON_LVB_REVERSE_VIDEO|that)

	spin while ShowCursor (0) ge
     if	typ eq vtINT
	case act
	of sRAW
	   SetConsoleTextAttribute (han, raw)
	end case
     elif typ eq vtV52
	case act
	of vCUP	; "A"		; cursor up
	   vt_act (ctx, vtCSI, xCUP, a1, a2)
	of vCDN	; "B"		;
	   vt_act (ctx, vtCSI, xCDN, a1, a2)
	of vCRT	; "C"		;
	   vt_act (ctx, vtCSI, xCRT, a1, a2)
	of vCLF	; "D"		;
	   vt_act (ctx, vtCSI, xCLF, a1, a2)
;	   vt_act (ctx, vtCSI, act-vCUP+xCUP, a1, a2)
	of eGRA	; "F"		; enter graphics mode
	of lGRA	; "G"		; leave
	of vHOM	; "H"		; cursor home
;PUT("h=%d:%d ", a1,a2)
	   vt_act (ctx, vtCSI, cHOM, a1, a2)
	of vRLF	; "I"		; reverse line feed
	   vt_act (ctx, vtCSI, xSDN, a1, a2)
	of vESC	; "J"		; erase to end of screen
;PUT("s=%d:%d ", a1,a2)
	   vt_act (ctx, vtCSI, xCSC, a1, a2)
	of vELN	; "K"		; erase to end of line
;PUT("l=%d:%d ", a1,a2)
	   vt_act (ctx, vtCSI, xCLI, a1, a2)
	of vPOS	; "Y" ; line col	; position
;PUT("p=%d:%d ", a1,a2)
	   vt_act (ctx, vtCSI, cPOS, a1, a2)
	of vIDT	; "Z"		; identify
	   vt_rep ("\033/Z")
;	of eAKM	; "="		;
;	of lAKM	; ">"		;
	of eANS	; "<"		; enter ansii mode
	   scr->Vmod = 0	;
;	of eAUT	; "^"		;
;	of lAUT	; "_"		;
;	of ePRT	; "W"		; printer controller mode
;	of lPRT	; "X"		;
;	of ePSC	; "]"		; print screen
;	of vPLN	; "V"		; print line
	end case
     elif typ eq vtESC
	case act
	of xSUP ; "D"		; scroll up or cursor down
	   vt_eol ()
	   if cur.Y ne reg.Bottom
	   .. quit ++cur.Y, SetConsoleCursorPosition (han, cur)

	   fil.Attributes = raw, fil.Char.AsciiChar = ' '
	   coo.X = 0, coo.Y = 0
	   win.Top = 1
	   win.Bottom = reg.Bottom, win.Left = 0, win.Right = siz.X-1
;PUT("up t=%d b=%d ", win.Top, win.Bottom)
	   clp = win
	   ScrollConsoleScreenBuffer (han, &win, <>, coo, &fil)
	   coo.X = 0, coo.Y = reg.Bottom
	   SetConsoleCursorPosition (han, coo)
;exit

	of xSDN ; "M"		; scroll down or cursor up
	   vt_eol ()
	   if cur.Y ne 
	   .. quit --cur.Y, SetConsoleCursorPosition (han, cur)

	   fil.Attributes = raw, fil.Char.AsciiChar = ' '
	   coo.X = 0, coo.Y = 1
	   win.Top = 0
	   win.Bottom = reg.Bottom-1, win.Left = 0, win.Right = siz.X-1
;PUT("down t=%d b=%d ", win.Top, win.Bottom)
	   clp = win
	   ScrollConsoleScreenBuffer (han, &win, <>, coo, &fil)
	   coo.X = 0, coo.Y = 0
	   SetConsoleCursorPosition (han, coo)
;exit
	of xNLN ; "E"		; start of next line, scroll if at bottom
	   vt_eol ()
	   PUT("[%s]", scr->Aseq)
	of xSAV ; "7"		; save cursor, attributes
	   scr->Isav = cur
	of xRST ; "8"		; restore, home if nothing saved
;	   vt_eol ()
	   SetConsoleCursorPosition (han, scr->Isav)
	of xTOP	; "#3"		; top character
	of xBOT	; "#4"		; bottom character
	of cDBL	; "#5"		; single width line
	of sDBL	; "#6"		; double width line
	of xAPP ; "="		; application keypad
	of xANS ; "<"		; ansi mode
	of xNUM ; ">"		; numeric keypad
	of aDID ; "Z"		; identify: "$/Z"
	or xRES ; "c"		; reset
	   PUT("[%s]", scr->Aseq)
	of xAG0 ; "(B"		; select ascii G0
	or xAG1 ; ")B"		; select ascii G1
	or xSG0 ; "(0"		; select special graphics G0
	or xSG1 ; ")0"		; select special graphics G1
	   nothing
	of xHTR			; hard terminal reset
	or xSTR			; soft terminal reset
	   vt_act(ctx,vtCSI,cHOM,0,0) ; home
	   vt_act(ctx,vtCSI,xCSN,0,0) ; clear screen
	end case
     elif typ eq vtCSI
	case act
	of xCSC ; "J[J"		; clear to end of screen 
	or aCSC ; "J[0J"	; clear to end of screen 
	   ;coo.X = 1, coo.Y = 1
	   FillConsoleOutputAttribute (han, raw, 24*80, cur, &dum)
	   FillConsoleOutputCharacter (han, ' ', 24*80, cur, &dum)
	   SetConsoleTextAttribute (han, att)
	of xCBS ; "J[1J"	; clear to beginning of screen
	or xCSN ; "J[2J"	; clear entire screen; cursor doesn't move
	   PUT("[%s]", scr->Aseq)
	   coo.X = 1, coo.Y = 1
	   SetConsoleCursorPosition (han, coo)
	   FillConsoleOutputAttribute (han, raw, 24*80, cur, &dum)
	   FillConsoleOutputCharacter (han, ' ', 24*80, cur, &dum)
	   SetConsoleCursorPosition (han, cur)
	   SetConsoleTextAttribute (han, att)
	of xCLI ; "K[K"		; clear to end of line
	or xCLN ; "K[2K"	; erase line
	or aCLI ; "K[0K"	; alternate
	   vt_eol ()
	   FillConsoleOutputAttribute (han, raw, 80-cur.X, cur, &dum)
	   FillConsoleOutputCharacter (han, ' ', 80-cur.X, cur, &dum)
	   SetConsoleTextAttribute (han, att)
	of xCBL ; "K[1K"	; erase to beginning of line
	   PUT("[%s]", scr->Aseq)
	of cHOM ; "H[H"		; cursor home
	   vt_eol ()
	   coo.X = 0, coo.Y = 0
	   vt_eol ()		;
	   SetConsoleCursorPosition (han, coo)
	of rHOM ; "f[f"		; region home
	   vt_eol ()
	   PUT("[%s]", scr->Aseq)
	of xCUP ; "A[@A"	; cursor up
	   quit if (cur.Y-=p1) lt 0
	   vt_eol ()
	   SetConsoleCursorPosition (han, cur)
	   vtVcup = 1		; Win32 fix
	of xCDN ; "B[@B"	; cursor down
	   quit if (cur.Y+=p1) gt 23
	   vt_eol ()
	   SetConsoleCursorPosition (han, cur)
	of xCRT ; "C[@C"	; cursor right
	   quit if (cur.X+=p1) gt 79
	   vt_eol ()
	   SetConsoleCursorPosition (han, cur)
	of xCLF ; "D[@D"	; cursor left
	   quit if (cur.X-=p1) lt 0
	   SetConsoleCursorPosition (han, cur)
	of cPOS ; "H[@;@H"	; position (line, column)
	   vt_eol ()
	   cur.X = p2-1, cur.Y = p1-1
	   SetConsoleCursorPosition (han, cur)
	of rPOS ; "H[@;@H"	; region position	
	   vt_eol ()
	   PUT("[%s]", scr->Aseq)
	of xREG ; "r[@;@r"	; scrolling region (top, bottom)
	or aREG	; "r[r"		; alternate
	   scr->Ireg.Top = p1-1, scr->Ireg.Bottom = p2-1
	   cur.X = 0, cur.Y = 0
	   SetConsoleCursorPosition (han, cur)
	of sIRM ; "h[4h"	; insert on 
	   mod = GetConsoleMode (han, &mod)
	   mod |= ENABLE_INSERT_MODE|ENABLE_EXTENDED_FLAGS
	   SetConsoleMode (han, mod)
	of cIRM ; "h[4l"	; replace on
	   mod = GetConsoleMode (han, &mod)
	   mod &= ~(ENABLE_INSERT_MODE|ENABLE_EXTENDED_FLAGS)
	   SetConsoleMode (han, mod)
	of xDCH ; "L[@L"	; delete characters
	or xDLN ; "L[@M"	; delete characters
	or sKBL ; "h[2h"	; keyboard locked
	or cKBL ; "h[2h"	; keyboard unlocked
	or sSRM ; "l[12l"	; send-receive echo on
	or cSRM ; "h[12h"	; send-receive echo off
	   PUT("[%s]", scr->Aseq)
	of cALL ; "m[0m"	; all attributes off
	or aALL ; "m[m"		; alternate
	   att &= ~(FOREGROUND_INTENSITY)
	   att &= ~(COMMON_LVB_UNDERSCORE)
	   SetConsoleTextAttribute (han, att)
	of sBOL ; "m[1m"	; bold on
	or aBOL ; "m[7;1m"	; undocumented - used by KED
	   att |= FOREGROUND_INTENSITY
	   SetConsoleTextAttribute (han, att)
	   scr->Vcup = FOREGROUND_INTENSITY
	   ++vtVcup
	of cBOL ; "m[22m"	; bold off
	   att &= ~(FOREGROUND_INTENSITY)
	   SetConsoleTextAttribute (han, att)
	of sUND ; "m[4m"	; underline on 
	   att |= COMMON_LVB_UNDERSCORE
	   SetConsoleTextAttribute (han, att)
	   scr->Vcup = COMMON_LVB_UNDERSCORE
	of cUND ; "m[24m"	; underline off 
	   att &= ~(COMMON_LVB_UNDERSCORE)
	   SetConsoleTextAttribute (han, att)
	of sBLK ; "m[5m"	; blink on
	of cBLK ; "m[25m"	; blink off
	of sREV ; "m[7m"	; reverse on
	   att |= COMMON_LVB_REVERSE_VIDEO
	   SetConsoleTextAttribute (han, att)
	of cREV ; "m[27m"	; reverse off
	   att &= ~(COMMON_LVB_REVERSE_VIDEO)
	   SetConsoleTextAttribute (han, att)
	of xDAD
	   vt_rep ("VT102")
	end case
     elif typ eq vtDEC
	case act
	of xV52			; VT52 mode
	   scr->Vmod = 52	; VT52 mode
	of x100 ; "p[61:p"	; VT100 mode
	of x200 ; "p[62;1:p"	; VT200 mode
	of xDSR ; "n[5n"	; request status report "$[0n"
	   vt_rep ("\033[0n")	; reply
	of xCPR ; "n[6n"	; request cursor position
	   vtPipt = vtAipt
	   cur.X = 79 if cur.X gt 79
	   FMT(vtPipt, "\033[%d;%dR", cur.Y+1, cur.X+1)
	of x80	; "l[?3l"	; 80 character line
	of x132 ; "h[?3h"	; 132 character line
	of sJMP ; "l[?24l"	; jump scroll
	of cJMP ; "h[?4h"	; smooth scroll
	of sLCK ; "h[?6h"	; cursor locked to scrolling region
	of cLCK ; "l[?6l"	; cursor not locked
	of sWRP ; "h[?7h"	; set wrap
	of cWRP ; "l[?7l"	; clear wrap
	of sNLM ; "l[?20l"	; newline mode - usual
	of cNLM ; "h[?20h"	; newline mode - lf -> cr/lf
	of sAUT ; "h[?8h"	; autorepeat on
	of cAUT ; "l[?8l"	; autorepeat off
	of sCKM ; "h[?1h"	; cursor keys application mode
	of cCKM ; "l[?1l"	; cursor-keys ansi mode
	of xDID ; "c[?6c"	; identify: "VT102"
	   vt_rep ("VT102")
;	   PUT("[%s]", scr->Aseq)
	end case
    end
	spin while ShowCursor (1) lt
  end
