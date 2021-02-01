file	coprm - get command with prompt
include	rid:rider
include	rid:codef
include	rid:imdef
include	rid:stdef
include	rid:vkdef
include	rid:wimod
include	rid:dbdef
include	rid:medef
include	rid:mxdef
include rid:abdef

include rid:cldef

;sic]	co_edt : (*coTlin, *kbTcha) int
	co_ins : (*coTlin, int, int)
	co_rub : (*coTlin)
	co_emp : (*coTlin)
	co_era : (*coTlin)
	co_ref : (*coTlin)
	co_lft : (*coTlin)
	co_rgt : (*coTlin)
	co_pre : (*coTlin)
	co_suc : (*coTlin)
	co_fet : (*coTlin)
	co_sto : (*coTlin)
	co_col : (*coTlin)
	co_set : (*coTlin, int)
	co_pos : (int, *int, *int)
	co_inc : (*coTlin, *int)
	co_dec : (*coTlin, *int)
	co_ctc : (int)
	coGET := (-1)
	coSET := 1
code	co_prm - prompt for a command

	coPget : * coTget = &co_get
	coPlin : * coTlin = <>

  func	co_prm
	prm : * char
	buf : * char		; optional
	lim : size		; ??? unused
  is	lin : * coTlin = co_lin (&coPlin, prm)
	cha : kbTcha
     repeat
	fail if !(*coPget)(&cha, kbWAI_)
	co_edt (lin, &cha)
	next if fail
	co_cop (lin, buf) if buf
	fine
     forever
  end

  func	co_lin
	ptr : ** coTlin
	prm : * char
	()  : * coTlin
  is	lin : * coTlin = *ptr
	if !lin
	   lin = me_acc (#coTlin)
	   *ptr = lin
	   lin->Lbuf = mxLIN-8
	   lin->Lhis = 64
	.. lin->Abuf[0] = 0
	lin->Pprm = prm
	lin->Lprm = st_len (prm)
	co_pos (coGET, &lin->Lprm, <>) if eq
	PUT("%s", prm)
	co_emp (lin)
	reply lin
  end

  proc	co_cop
	lin : * coTlin
	buf : * char
  is	st_cop (lin->Abuf, buf)
  end
code	co_edt - edit the input line

  func	co_edt
	lin : * coTlin
	cha : * kbTcha
  is	ord : int = cha->Vord
	if cha->Vflg & kbASC_		; got a control
	&& ord ge 32
	   co_ins (lin, ord, 1)
	elif cha->Vflg & kbASC_		; got a control
	   case ord
	   of 21   co_era (lin)		; ctrl/u -- erase line
	   of 8    co_rub (lin)		; backspace
	   of 27   ;co_era (lin)	; escape -- erase line
		   ord = 3		;
	   or 3				;
;	   or 'G'-'@'
;	   or 'Y'-'@'
;		   PUT("^%c", ord + '@') 
		   PUT("[Cancel]")
		   co_ins (lin, ord, 0)
	   or '\r'			;
	   or '\n' co_sto (lin)		;
		   fine PUT("\n")	;
	   of other			;
	           co_ins (lin, ord, 0) ; 
	   end case
	else
	   case cha->Vord
	   of vkLFT co_lft (lin)
	   of vkRGT co_rgt (lin)
	   of vkUPA co_pre (lin)
	   of vkDWN co_suc (lin)
	   of vkHOM  spin while co_lft (lin)
	   of vkEND  spin while co_rgt (lin)
	.. end case
	fail
  end

  func	co_ins
	lin : * coTlin
	ord : int
	vis : int
  is	buf : * char = lin->Abuf
	ptr : * char = buf + lin->Vpos
	cnt : int
	col : int
	fine if (lin->Vcnt+4) gt lin->Lbuf
	col = co_col (lin)
	st_mov (ptr, ptr+1)
	*ptr = ord
	PUT("%s", ptr) if vis
	co_set (lin, col+1)
	++lin->Vpos, ++lin->Vcnt
  end

  func	co_rub
	lin : * coTlin
  is	buf : * char = lin->Abuf
	ptr : * char = buf + lin->Vpos
	cnt : int
	col : int
	fine if !lin->Vpos
	col = co_col (lin)
	co_set (lin, --col)
	PUT("%s ", ptr)
	co_set (lin, col)

	st_mov (ptr, ptr-1)
	--lin->Vpos, --lin->Vcnt
  end

  func	co_lft
	lin : * coTlin
  is	buf : * char = lin->Abuf
	fail if !lin->Vpos
	PUT("\b")
	--lin->Vpos
	fine
  end

  func	co_rgt
	lin : * coTlin
  is	buf : * char = lin->Abuf
	fail if lin->Vpos ge lin->Vcnt
	PUT("%c", lin->Abuf[lin->Vpos])
	++lin->Vpos
	fine
  end

  func	co_emp
	lin : * coTlin
  is	lin->Vcnt = 0
	lin->Vpos = 0
	lin->Abuf[0] = 0
  end

  func	co_era 
	lin : * coTlin
  is	cnt : int = lin->Vcnt
	co_set (lin, 0)
	PUT(" ") while cnt--
	co_set (lin, 0)
	co_emp (lin)
  end

  func	co_ref 
	lin : * coTlin
  is	co_set (lin, 0)
	PUT("%s", lin->Abuf)
	co_set (lin, lin->Vpos)
  end
code	co_sto - store line

;	Vfst	first stored
;	Vlst	last stored
;	Vcur	where we are pointing

  func	co_sto 
	lin : * coTlin
  is	buf : * char
	fine if !lin->Vcnt
	fine if st_mem (3, lin->Abuf)		; command was aborted
	++lin->Vuse if lin->Vuse lt (lin->Lhis-2)
	co_inc (lin, &lin->Vfst) otherwise
	co_inc (lin, &lin->Vlst)
	st_cop (lin->Abuf, lin->Ahis[lin->Vlst])
	lin->Vcur = lin->Vlst
	co_inc (lin, &lin->Vcur)
  end

code	co_pre - get predecessor line

  func	co_pre
	lin : * coTlin
  is	fine if !lin->Vuse		; none available
	fine if lin->Vcur eq lin->Vfst	; at first line
	co_dec (lin, &lin->Vcur)	; back one
	co_fet (lin)			; fetch this line
  end

code	co_suc - get successor line

  func	co_suc
	lin : * coTlin
  is	fine if !lin->Vuse		; none available
	if lin->Vcur eq lin->Vlst	; at first line
	.. fine co_era (lin)		; no more available
	co_inc (lin, &lin->Vcur)	; forward one
	co_fet (lin)			; fetch this line
  end

code	co_inc - increment line number

  func	co_inc
	lin : * coTlin
	ord : * int
  is	++*ord
	*ord = 0 if *ord ge lin->Lhis
  end

code	co_dec - decrement line number

  func	co_dec
	lin : * coTlin
	ord : * int
  is	--*ord
	*ord = lin->Lhis - 1 if lt
  end

code	co_fet - fetch a line

  func	co_fet
	lin : * coTlin
  is	co_era (lin)		; erase it first
	st_cop (lin->Ahis[lin->Vcur], lin->Abuf)
	lin->Vcnt = st_len (lin->Abuf)
	lin->Vpos = lin->Vcnt
	co_ref (lin)		; refresh display
  end
code	co_col - get/set column with prompt offset

  func	co_col
	lin : * coTlin
  is	col : int
	co_pos (coGET, &col, <>)
	reply col-lin->Lprm
  end

  func	co_set
	lin : * coTlin
	off : int
  is	col : int
	col = lin->Lprm + off
	co_pos (coSET, &col, <>)
	fine
  end

code	co_pos - get/set console position

  func	co_pos	
	mod : int
	col : *int
	row : *int
  is	han : HANDLE = GetStdHandle (STD_OUTPUT_HANDLE)
	inf : CONSOLE_SCREEN_BUFFER_INFO
	crd : COORD
	x   : int
	y   : int
	if mod eq coGET
	   GetConsoleScreenBufferInfo (han, &inf)
	   *col = inf.dwCursorPosition.X if col
	   *row = inf.dwCursorPosition.Y if row
	else
	   co_pos (coGET, &x, &y)
	   crd.X = (col) ? *col ?? x
	   crd.Y = (row) ? *row ?? y
	   SetConsoleCursorPosition (han, crd)
	end
	fine
  end

code	co_ctc - control control C

;	coVbrk : int = 0
	coVctc : int = 0
	coVonc : int = 0

  func	co_han
	sig : LONG
	()  : WINAPI int
  is
;	SetConsoleCtrlHandler (co_han, 1) ;if !coVctc
;	if sig eq CTRL_BREAK_EVENT
;	.. fine ++coVbrk
	fail if sig ne CTRL_C_EVENT
	++abVabt
	if coVctc eq coENB		; ctc enabled, signal abort
	   PUT("\n")			;
	.. im_exi ()			;
	fine				; don't abort
  end

  func	co_ctc
	cas : int
  is	mod : LONG
	han : HANDLE = GetStdHandle (STD_INPUT_HANDLE)
	if !coVonc
	   SetConsoleCtrlHandler (co_han, 1) ;if !coVctc
	.. coVonc = 1

	coVctc = cas

	GetConsoleMode (han, &mod)
	pass fail
	case cas
	of coENB mod |= ENABLE_PROCESSED_INPUT
	of coDSB mod &= (~ENABLE_PROCESSED_INPUT)
	end case
	SetConsoleMode (han, mod)
	reply that
  end
end file

	coRNG := 128
  type	coTrng
  is	Vlen : int		; ring length
	Vget : int		; get pointer 
	Vput : int		; put pointer
	Vthr : int		; thread handle
	Vwai : int		; set when waiting
	Vctc : int		;
	Abuf : [coRNG] char	; ring buffer
  end

  func	co_get
	cha : * kbTcha
	mod : int
  is	rng : * coTrng = coPrng
	if !rng
	   rng = coPrng = me_acc(#coTrng)
	   rng->Vlen = coRNG
	.. rng->Vthr = th_cre (co_thr)

      repeat
	if rng->Vcnt		; got characters
	   me_cop (rng->Abuf[rng->Vget], cha, #kbTcha)
	   ++rng->Vget if rng->Vget lt rng->Vlen
	   rng->Vget = 0 otherwise
	   --rng-Vcnt
	.. fine
	++rng->Vwai		; set inputting flag
	th_wai (rng->Vthr)	; wait for it
      forever
  end



  func	co_get
	cha : * kbTcha
	mod : int
  is	han : HANDLE
	rec : INPUT_RECORD
	key : * KEY_EVENT_RECORD
	cnt : LONG
	asc : int
	vir : int
	ctl : int
	flg : int = 0
	fail if !co_att (&han)
     repeat
a
	fail if !ReadConsoleInput (han, &rec, 1, &cnt)
	next if rec.EventType ne KEY_EVENT
	key = &rec.Event.KeyEvent
	next if key->bKeyDown eq
     never
	ctl = key->dwControlKeyState
	asc = key->uChar.AsciiChar
	vir = key->wVirtualKeyCode
	flg |= kbENH_ if ctl & ENHANCED_KEY
	flg |= kbCTL_ if ctl & (LEFT_CTRL_PRESSED|RIGHT_CTRL_PRESSED)
	flg |= kbSHF_ if ctl & SHIFT_PRESSED
	flg |= kbALT_ if ctl & (LEFT_ALT_PRESSED|RIGHT_ALT_PRESSED)
	flg |= kbASC_, cha->Vord = asc if asc
	flg |= kbVIR_, cha->Vord = vir otherwise
	fine cha->Vflg = flg
  end
If 0
code	main

  func	main
  is	buf : [mxLIN] char
	db_ini ()
     repeat
	co_prm ("[] ", buf, mxLIN)
	PUT("%s\n", buf)
     forever
  end
End
code	co_att - attach terminal

	coVatt	: int = 0
 	coHhan :  HANDLE = INVALID_HANDLE_VALUE
	coVmod : LONG = 0

  func	co_att
	res : * void
	()  : int
  is	han : HANDLE = coHhan
	mod : LONG
     repeat
	quit if coVatt
	han = GetStdHandle (STD_INPUT_HANDLE)
	fail if han eq INVALID_HANDLE_VALUE
	fail if !GetConsoleMode (han, &mod)
	coVmod = mod
	mod &= ~(ENABLE_ECHO_INPUT)
	fail if !SetConsoleMode (han, mod)
	coHhan = han
	coVatt = 1
     never
	*<*HANDLE>res = han if res
	fine
  end

code	co_det - detach terminal

  func	co_det
  is	fine if !coVatt
	SetConsoleMode (coHhan, coVmod)
	fine coVatt = 0
  end

code	co_get - get next character

  func	co_get
	cha : * kbTcha
	mod : int
  is	han : HANDLE
	rec : INPUT_RECORD
	key : * KEY_EVENT_RECORD
	cnt : LONG
	asc : int
	vir : int
	ctl : int
	flg : int = 0
	fail if !co_att (&han)
     repeat
	fail if !ReadConsoleInput (han, &rec, 1, &cnt)
	next if rec.EventType ne KEY_EVENT
	key = &rec.Event.KeyEvent
	next if key->bKeyDown eq
     never
	ctl = key->dwControlKeyState
	asc = key->uChar.AsciiChar
	vir = key->wVirtualKeyCode
	flg |= kbENH_ if ctl & ENHANCED_KEY
	flg |= kbCTL_ if ctl & (LEFT_CTRL_PRESSED|RIGHT_CTRL_PRESSED)
	flg |= kbSHF_ if ctl & SHIFT_PRESSED
	flg |= kbALT_ if ctl & (LEFT_ALT_PRESSED|RIGHT_ALT_PRESSED)
	flg |= kbASC_, cha->Vord = asc if asc
	flg |= kbVIR_, cha->Vord = vir otherwise
	fine cha->Vflg = flg
  end
end file
code	co_att - attach terminal

	coVatt	: int = 0
 	coHhan :  HANDLE = INVALID_HANDLE_VALUE
	coVmod : LONG = 0

	_coGSH := "%COHAN-E-Error connecting console\n"
	_coGCM := "%COHAN-E-Error getting console mode\n"
	_coGSM := "%COHAN-E-Error setting console mode\n"
	_coRCI := "%COHAN-E-Console read failed\n"

  func	co_att
	res : * void
	()  : int
  is	han : HANDLE = coHhan
	mod : LONG
     repeat
	quit if coVatt
	han = GetStdHandle (STD_INPUT_HANDLE)
	fail PUT (_coGSH) if han eq INVALID_HANDLE_VALUE
	GetConsoleMode (han, &mod)
	fail PUT (_coGCM) if fail
	coVmod = mod
	mod &= ~(ENABLE_ECHO_INPUT)
	SetConsoleMode (han, mod)
	fail PUT (_coGSM) if fail
	coHhan = han
	coVatt = 1
     never
	*<*HANDLE>res = han if res
	fine
  end

end file
code	co_wri - write to console

  func	co_wri
	col : int
	row : int
	buf : * char
  is	han : HANDLE
	dim : COORD = {80, 24}
	src : COORD = {0,0}
	dst : SMALL_RECT = {0, 0, 80, 24}
	fail if !co_att (&han)
;	WriteConsoleOutput (han, buf, dim, src, &dst)
  end
typedef struct _KEY_EVENT_RECORD { // ker  

    BOOL bKeyDown;             
    WORD wRepeatCount;         
    WORD wVirtualKeyCode;      
    WORD wVirtualScanCode;
    union {
        WCHAR UnicodeChar;
        CHAR  AsciiChar;
    } uChar;  
    DWORD dwControlKeyState;   
} KEY_EVENT_RECORD;


