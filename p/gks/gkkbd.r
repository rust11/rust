file	gkkbd - keyboard character codes display
include	rid:rider
include	rid:mxdef
include	gkb:gkmod

;	special mode, rctrlo?

  func	gk_kbd
	dcl : * dcTdcl
  is	buf : [mxLIN] char
	ipt : * char
	opt : * char
	cnt : int

	if !ctl.Qcmt
	   PUT("?KBD-I-Type characters, then <enter>\n")
	else
	   PUT("?KBD-I-Type characters, <enter>, comment, <enter>\n")
	end

      repeat
	PUT("KBD> ")
	ipt = buf, cnt = mxLIN-3
	while cnt--
	   *ipt = rt_tin (1, 1)
	   quit if *ipt eq '\r'		; return
	   ++ipt			;
	end				;

	rt_tin (1)			; get/skip lf
	cnt = ipt - buf			;
	opt = buf

	PUT("[")
	while cnt--
	   PUT("%o", *opt++ & 0377)	; next character
	   quit if !cnt			; nothing - we are done
	   PUT(", ")
	end
	PUT("] ")

	next PUT("\n") if !ctl.Qcmt	; not commenting
	co_prm ("! ", buf)
     forever
	fine
  end
code	gk_ctl - control keys

  init	gkActl : [] * char
  is	"^A  KEYPAD  Select All"
	"^B  RUSTX   Back process"
	"    KEYPAD  Bold"
	"^C  RT-11   Cancel"
	"    KEYPAD  Copy selected text"
	"^D  KEYPAD  [Select]"
	"^E  SIMH    Exit emulator"
	"^F  RUSTX   Forward process"
	"^G  KEYPAD  [Gold]"
	"^H  KEYPAD  Help"
	"^I  VT100   <HT> Horizontal Tab"
	"^J  VT100   <LF> Newline"
	"^K  KEYPAD  [Command]"
	"^L  VT100   <FF> Formfeed"
	"^M  VT100   <CR> Carriage Return"
	"^N"
	"^O  RT-11   Erase to line start"
	"^P"
	"^Q  VT100   Resume output"
	"^R  KEYPAD  Repaint screen"
	"^S  VT100   Suspend output"
	"^T  RUSTX   Display status"
	"^U  RT-11   Erase to line start  "
	"^V  KEYPAD  Paste"
	"^W"
	"^X  KEYPAD  Cut selected text"
	"^Y  RUSTX   Interrupt process"
	"^Z  RT-11   End of text"
	"    KEYPAD  Exit KEYPAD"
	"^]"
	"^|"
	"^["
	"^^"
	"^_"
	<>
  end
     
  func	gk_ctl
  is	im_hlp (gkActl, 2)
	fine
  end
