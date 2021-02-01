file	cowin - console window interface
include	rid:rider
include	rid:codef
include	rid:vkdef
include	rid:wimod
include	rid:dbdef

code	co_att - attach terminal

	coVatt : int = 0
 	coHhan : HANDLE = INVALID_HANDLE_VALUE
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
	mod &= ~(ENABLE_ECHO_INPUT|ENABLE_WINDOW_INPUT|ENABLE_MOUSE_INPUT)
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

code	co_dlc - deallocate console

  proc	co_dlc
  is	FreeConsole ()
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
	scn : int
	ctl : int
	flg : int = 0
	sts : int
	fail if !co_att (&han)
     repeat
	if !(mod & kbWAI_)
	   GetNumberOfConsoleInputEvents (han, &cnt)
	   db_lst ("GetNumberOfInputEvents") if fail
	.. fail if !cnt

	if !(mod  & kbPEE_)
	   WaitForSingleObject (han, INFINITE)
	.. PUT("fail") if that eq WAIT_FAILED
	sts = PeekConsoleInput (han, &rec, 1, &cnt) if mod & kbPEE_
	sts = ReadConsoleInput (han, &rec, 1, &cnt) otherwise
	fail if !sts
	next if rec.EventType ne KEY_EVENT
	key = &rec.Event.KeyEvent
	next if key->bKeyDown eq
     never
	ctl = key->dwControlKeyState
	asc = key->uChar.AsciiChar
	vir = key->wVirtualKeyCode
	scn = key->wVirtualScanCode

	flg |= kbENH_ if ctl & ENHANCED_KEY
	flg |= kbCTL_ if ctl & (LEFT_CTRL_PRESSED|RIGHT_CTRL_PRESSED)
	flg |= kbSHF_ if ctl & SHIFT_PRESSED
	flg |= kbALT_ if ctl & (LEFT_ALT_PRESSED|RIGHT_ALT_PRESSED)
	flg |= kbASC_, cha->Vord = asc if asc
	flg |= kbVIR_, cha->Vord = vir otherwise
	cha->Vflg = flg

;	If there was reasonable to map keypad keys, I'd use it.

;PUT("\nflg=%o scn=%d ", flg, scn)

	if (flg & (kbENH_|kbVIR_)) eq (kbENH_|kbVIR_)
	   case vir
	   of 144  cha->Vord = 69, cha->Vflg = kbPAD_
	   end case
	.. fine

	case scn
	of 69	; numlock
	or 55	; *	
	or 74	; -
	or 71	; 7
	or 72	; 8
	or 73	; 9
	or 75	; 4
	or 76	; 5
	or 77	; 6
	or 78	; +
	or 79	; 1
	or 80	; 2
	or 81	; 3
	or 82	; 0
	or 83	; .
	   flg |= kbPAD_
	of 28	; enter
	or 53	; /
	   flg |= kbPAD_ if flg & kbENH_
	end case
	if (flg & kbPAD_)
;PUT(" (flg=%o scn=%d) ", flg, scn)
	   cha->Vord = scn
	.. flg &= (kbPAD_|kbSHF_)
;PUT(" (flg=%o scn=%d) ", flg, cha->Vord)
	fine cha->Vflg = flg
  end
end file

code	co_get - get next character

  func	co_get
	cha : * kbTcha
	flg : int
  is	ctx : * wsTctx = ws_ctx ()
	kbd : * kbTkbd = ctx->Pkbd
     repeat
	if kbd->Vget ne kbd->Vput
	   *cha = kbd->Abuf[kbd->Vget]
	   fine if flg & kbPEE_
	   ++kbd->Vget if kbd->Vget ne kbd->Lbuf
	   kbd->Vget = 0 otherwise
	.. fine
	; Have to let some events through even if non-wait
	ev_wai (kbd->Pevt)
;;;	fail if !ws_pee (<>, (flg & kbWAI_) ne)
     forever
  end

code	co_put - put character in ring buffer

  func	co_put
	evt : * wsTevt
	cha : * kbTcha
  is	ctx : * wsTctx = evt->Pctx
	kbd : * kbTkbd = ctx->Pkbd
	nxt : int = kbd->Vput + 1
	nxt = 0 if nxt eq kbd->Lbuf
	fail if nxt eq kbd->Vget
	kbd->Abuf[kbd->Vput] = *cha
	kbd->Vput = nxt
	ev_sig (evt, 1)
	fine
  end
