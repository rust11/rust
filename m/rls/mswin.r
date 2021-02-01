file	mswin - mouse for windows
include	rid:wsdef
include	rid:medef
include	rid:msdef

	ms_evt : wsTast own
	msIphy : msTpos = {0}
	msPphy : * msTpos = &msIphy

code	ms_ini - init mouse

  func	ms_ini
	pos : * msTpos
  is	phy : * msTpos = msPphy
	fac : * wsTfac
	fac = ws_fac (<>, "mouse")	;
	fac->Past = ms_evt		;
;	wsPmou = &ms_evt		; setup event latch
	fine phy->Vmou = pos->Vmou = 2	;
  end

code	ms_qui - quit mouse

  func	ms_qui
	pos : * msTpos
  is	fac : * wsTfac
	fac = ws_fac (<>, "mouse")	; find the facility
	fac->Past = <>			; unhook us
	fine
  end

code	ms_sho - show mouse

  proc	ms_sho
	pos : * msTpos
  is;	ShowCursor (1)
  end

code	ms_hid - hide mouse

  proc	ms_hid
	pos : * msTpos
  is;	ShowCursor (0)
  end

code	ms_get - get mouse position and states

  proc	ms_get
	pos : * msTpos
  is	phy : * msTpos = msPphy		; the mouse
	pos->Vcol  = phy->Vcol		; copy things
	pos->Vrow  = phy->Vrow		;
	pos->Vrow /= pos->Vhgt if pos->Vhgt ; scale it
	pos->Vcol /= pos->Vwid if pos->Vwid ;
	pos->Vcol = pos->Vrgt-pos->Vcol if pos->Vrgt
	pos->Vrow = pos->Vbot-pos->Vrow if pos->Vbot
	pos->Vbut  = phy->Vbut		;
  end

code	ms_set - set mouse position

  proc	ms_set
	pos : * msTpos
	row : int
	col : int
  is	ctx : * wsTctx = ws_ctx ()	;
	exit if pos->Vmou eq		;
	exit if !ctx			; no context
	row  = pos->Vrow if row eq -1	;
	col  = pos->Vcol if col eq -1	;
	row += pos->Vbot		;
	col += pos->Vrgt		;
	row *= pos->Vhgt if pos->Vhgt	; scale it
	col *= pos->Vwid if pos->Vwid	;
	SetCursorPos (ctx->Vlft+col, ctx->Vtop+row)
  end

code	ms_clk - detect mouse click

  func	ms_clk
	pos : * msTpos			;
	but : int 			; 1=>left, 2=>right
	()  : int			; fine=>clicked
  is	phy : * msTpos = msPphy		;
	clk : WORD = 0			;
					;
	fail if pos->Vmou eq		;
					;
	clk = but & phy->Vclk		; got a click?
	fail if (pos->Vclk = clk) eq	; got nothing
	phy->Vclk &= ~(but)		; take it/them out
					;
	pos->Vobt = pos->Vbut		; save these
	pos->Vocl = pos->Vcol		;
	pos->Vorw = pos->Vrow		;
					;
	ms_get (pos)			; get new position info
;	pos->Vbut = but			; button number
	reply clk			;
  end

code	ms_drg - check drag

  func	ms_drg
	pos : * msTpos
	but : int
  is	fail if (pos->Vbut & but) eq		; not set now
	fail if (pos->Vobt & but) eq		; or before
	pos->Vver = pos->Vrow - pos->Vorw	; check for drag
	pos->Vhor = pos->Vcol - pos->Vocl	;
	fail if (pos->Vver | pos->Vhor) eq	; unmoved
	pos->Vorw = pos->Vrow			; update these
	pos->Vocl = pos->Vcol			;
	fine
  end
code	ms_evt - mouse event handler

  func	ms_evt
	evt : * wsTevt
	fac : * wsTfac
  is	phy : * msTpos = msPphy		; physical
	wrd : int = evt->Vwrd		; flags
	but : int = 0			; buttons
	fail if !phy->Vmou		; no mouse
	case evt->Vmsg
	of other	    fail	; not for us
	of WM_LBUTTONDOWN   phy->Vclk |= msLFT_
	of WM_RBUTTONDOWN   phy->Vclk |= msRGT_
	of WM_MBUTTONDOWN   phy->Vclk |= msMID_
	of WM_LBUTTONUP			; just capture these
	of WM_RBUTTONUP
	of WM_MBUTTONUP
	or WM_LBUTTONDBLCLK
	or WM_RBUTTONDBLCLK
	or WM_MBUTTONDBLCLK
	of WM_MOUSEMOVE	
	   nothing
	end case
	but |= msLFT_ if wrd & MK_LBUTTON
	but |= msRGT_ if wrd & MK_RBUTTON
	but |= msMID_ if wrd & MK_MBUTTON
	but |= msCTL_ if wrd & MK_CONTROL
	but |= msSHF_ if wrd & MK_SHIFT
	phy->Vbut = but
	phy->Vcol = LOWORD(evt->Vlng)
	phy->Vrow = HIWORD(evt->Vlng)
	fine
  end
end file
	ms_edg : (int, *int, *int) int own
code	ms_edg - filter button-up edge

  func	ms_edg
	but : int
	x   : * int
	y   : * int
	()  : int
  is	phy : * msTpos = msPphy
	clk : int
	clk = but & phy->Vclk		; got a click?
	pass fail			; nope
	phy->Vclk &= ~(but)		; take it/them out
	*x = phy->Vcol			; return position
	*y = phy->Vrow			;
	reply clk			;
  end

