file	elkbd - windows keyboard
include sci:windows
include	elb:elmod
include rid:codef
include	rid:ctdef
include	rid:medef
include	rid:stdef
include	rid:thdef
include elb:ekdef

;	o  Asynch signals to VRT
;	o  TKS/TKB for PDP
;	o  alt-Y and SHE for both (redo logicals afterwards)
;
;	o  Asynchronous support (threaded)
;	o  Control keys
;	o  VT100 translation
;
;	bs	delete
;	alt-c	abort
;	alt-h	debug
;
;	cl_cmd -> cl_prm -> co_prm
code	ek_ini - initialise the keyboard

;  type	kbTthr
;  is	thr : * thTthr
;	kbd : * kbTkbd
;	hoo : * kbThoo
;	ctc : int
;	brk : int
;  end

	ekPkbd : * kbTkbd = <>		; added
	ekPthr : * thTthr = <>
	ekVbrk : int = 0
	ekPhoo : * ekThoo = <>
	ek_kbd : thTfun

code	ek_ini - create thread 

  proc	ek_ini
	hoo : * ekThoo
  is	ekPhoo = hoo
	ekPthr = th_cre (&ek_kbd, <>)
  end

  proc	ek_can
  is	kb_can (ekPkbd)
  end

  proc	ek_brk
  is	thr : * thTthr = ekPthr
	ekVbrk = 1
	th_sig (ekPthr, 1)
	ekVbrk = 0
  end

code	ek_kbd - keyboard thread

;	Concurrent keyboard input polling loop
;
;???	Add stall logic for keyboard full
;	Discards overflow at present

  func	ek_kbd
	thr : * thTthr
  is	kbd : * kbTkbd
	cha : kbTcha
	ekPkbd = kbd = kb_alc ()
	coPget = &ek_get		; setup console get routine
	co_att (<>)			; attach console
	co_ctc (coDSB)			; we do our own
	repeat				;
	   co_get (&cha, kbWAI_)	;
	   if ne			;
	      if ekPhoo			; got a hook
	   .. .. next if (*ekPhoo)(&cha); it did it
	   kb_wri (kbd, &cha)		;
	   th_sig (thr, 1)		; tell them
	forever
  end

code	ek_get - get next character

;	Called via input routines.
;
;	Call the user keyboard hook.

ekVcnt : int = 0

  func	ek_get
	cha : * kbTcha
	mod : int
	()  : int
  is	thr : * thTthr = ekPthr	
	kbd : * kbTkbd = ekPkbd		
PUT(" ekVcnt=%d ", ekVcnt) if elFvrb && (ekVcnt++ lt 2)
	repeat
	   th_sig (thr, 0)		; clear the signal
	   fail if ekVbrk		; wants to break
	   kb_rea (kbd, cha, mod)	; peek or read next
	   pass fine			;
	   fail if !(mod & kbWAI_)	; not waiting
	   th_wai (thr)			; wait for input
	forever
  end
end file

code	ek_trn - translate character

  func	ek_trn
  is
  end

	if !(mod & kbWAI_)
	   GetNumberOfConsoleInputEvents (han, &cnt)
	   db_lst ("GetNumberOfInputEvents") if fail
	.. fail if !cnt

	if !(mod  & kbPEE_)
	   WaitForSingleObject (han, INFINITE)
	.. PUT("fail") if that eq WAIT_FAILED
	if cha->Vflg & kbASC_		; got a control
	&& ord ge 32
	   reply ord
	elif cha->Vflg & kbASC_		; got a control
	   case ord
	   of 21   co_era (lin)		; ctrl/u -- erase line
	   of 8    co_rub (lin)		; backspace
	   of 27   ;co_era (lin)	; escape -- erase line
		   ord = 3		;
	   or 3				;
	   or 'G'-'@'
	   or 'Y'-'@'
		   PUT("^%c", ord + '@') 
		   co_ins (lin, ord, 0)
	   or '\r'			;
	   or '\n' co_sto (lin)		;
		   fine PUT("\n")	;
	   of other			;
	           co_ins (lin, ord, 0) ; 
	   end case
	pass fail
	

t waitingdt - edit the input line

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
	   or 'G'-'@'
	   or 'Y'-'@'
		   PUT("^%c", ord + '@') 
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
	.. end case
	fail
  end

end file

  func	vt_kb_prc
	cod : int
	wrd : WPARAM
	lng : LPARAM
	()  : CALLBACK LRESULT
  is
a
	fail 			; let windows process it
  end

  proc	vt_kb_hoo
  is
	SetWindowsHookEx (WH_KEYBOARD, <*void>vt_kb_prc, <>, GetCurrentThreadId ())
;PUT("res=%x\n", that)

  end
