;	need to catch WM_QUIT in nests
file	wsmod - windows server
include	rid:rider
include	rid:wsdef
include	rid:imdef
include	rid:medef
include	rid:stdef
include	rid:dbdef

;	wc_xxx	client routines
;	ws_xxx	server routines
;	wi_xxx	windows routines -- receives/returns windows types
;
;    client
;	wcdef.d		client code definitions - no windows dependency
;	wcmsg.d		message definitions
; ???	wccus.r		default cusp routines 
;
;    server
;	wsdef.d		server code definitions - very windows dependent
;
;	mndef/mod	menu support
;	dgdef/mod	dialogs
;	grdef/mod	graphics
;
;    wsmod.r		must be linked with root
;	ws_mai		client main - preprocessing
;	wi_app		init application
;	wi_ins		init instance
;	wc_bld		client build
;
;      ws_loo		command loop
;
;      wi_evt		window event
;	ws_cmd		command
;	 wc_cmd
;	wc_cre		create window
;	ws_pnt		paint window
;	 wc_pnt	
;	ws_exi		quit window

	wsPctx	: * wsTctx = <>		; all global data
					;
	wi_app	: (*wsTctx) BOOL own	; init application
	wi_ins	: (*wsTctx) BOOL own	; init instance

	wi_evt	: (HWND, UINT, WPARAM, LPARAM) CALLBACK LRESULT own
	wi_mai	: (HANDLE, HANDLE, LPSTR, int) APIENTRY int own
	wi_dis	: (*MSG) int own
code	ws_lnk - server link

;	A graphics program must make a reference to some part
;	of wsmod.r to force it into the link, thus overriding wscon.
;	This is the minimal routine to do that.
;	It informs the program that a server has been loaded.

  func	ws_lnk
  is	fine
  end

code	ws_ctx - get server process context

 func	ws_ctx
	()  : * wsTctx
 is	im_rep ("W-No windows context", <>) if !wsPctx
	reply wsPctx
 end

code	ws_evt - get dummy event context

  func	ws_evt
	()  : * wsTevt
  is	ctx : * wsTctx = ws_ctx ()
	reply &ctx->Ievt
  end

code	ws_cod - get event code

  func	ws_cod
	evt : * wsTevt
  is	reply evt->Vwrd
  end

code	ws_exi - exit this image

  func	ws_exi
	evt : * wsTevt			; evt may never be used
  is	im_exi ()			;
	fine				;
  end

code	ws_run - run a windows program

  func	ws_run
	spc : * char
	flg : int
	()  : int
  is	WinExec (spc, SW_SHOW)		; run a program
	reply that ge 32		; fine
  end

code	ws_tit - set window title

  func	ws_tit
	evt : * wsTevt
	tit : * char
  is	buf : [256] char
	FMT(buf, "%s %s", imPfac, tit)
	SetWindowText (evt->Hwnd, buf)
	fine
  end

code	ws_upd - force update

  func	ws_upd
	evt : * wsTevt
  is	ctx : * wsTctx = ws_ctx ()
	fail if !evt
	InvalidateRect (ctx->Hwnd, <>, ctx->Vclr); 1 to force clear
	fine
  end

code	ws_fac - create facility

  func	ws_fac
	evt : * wsTevt		; may be null
	nam : * char
	()  : * wsTfac
  is	ctx : * wsTctx = ws_ctx ()
	prv : ** wsTfac = &ctx->Pfac
	cur : * wsTfac
	while *prv
	   cur = *prv
	   if st_sam (cur->Anam, nam)
	   .. reply cur
	   prv = &cur->Psuc
	end
	cur = me_acc (#wsTfac)
	*prv = cur
	st_fit (nam, cur->Anam, #cur->Anam)
	reply cur
  end

code	ws_chd - get/set child

  func	ws_chd
	evt : * wsTevt
	new : HWND
	()  : HWND
  is	ctx : * wsTctx = evt->Pctx
	old : HWND = ctx->Hchd
	ctx->Hchd = new if new
	reply old
  end

code	tm_sta - start timer

  func	tm_sta
	evt : * wsTevt
	per : long
	ast : * wsTcal
  is	ctx : * wsTctx = evt->Pctx
	ctx->Ptim = ast
	SetTimer (ctx->Hwnd, 1, per, <>)
	reply that
  end

code	tm_stp - stop timer

  func	tm_stp 
	evt : * wsTevt
  is	ctx : * wsTctx = evt->Pctx
	KillTimer (ctx->Hwnd, 1)
  end
code	wi_mai - WinMain 

  func	WinMain
	ins : HINSTANCE
	prv : HINSTANCE
	cmd : LPSTR
	sho : int
	()  : APIENTRY int
  is	ctx : * wsTctx			; the application context
	evt : wsTevt = {0}		;
	hgt : int
	wid : int
	imPrep = ws_msg 		; catch messages
	ctx = me_acc (#wsTctx)		;
	wsPctx = evt.Pctx = ctx		;
	ctx->Hins = ins			; fill in context
	ctx->Hprv = prv			;
	ctx->Pcmd = cmd			;
	ctx->Vsho = sho			;
	ctx->Vclr = 1			; clear screen on paint default
	ctx->Vbow = 1			; black on white is default
	ctx->Ievt.Pctx = ctx		; dummy event
					;
	gr_fnt (&evt, 0)		; setup font sizes
	hgt = ws_int (&evt, wsDTH)	; setup initial dimensions
	wid = ws_int (&evt, wsDTW)	;
	ctx->Vlft = wid/8		;
	ctx->Vtop = hgt/8		;
	ctx->Vwid = wid/6		;
	ctx->Vhgt = hgt/6		;

;	Call client main. They can can use ws_set to change
;	parameters affecting wi_app and wi_ins.

	wc_mai (&evt)			; client main preprocessing
	fail if !prv && !wi_app (ctx)	; init first instance
	fail if !wi_ins (ctx)		; init any instance
	evt.Hwnd = ctx->Hwnd		;
	wc_bld (&evt, cmd)		; client build
					;
	ws_upd (&evt)		;???	; force screen update
	wc_loo (&evt)			; default calls ws_loo
  end					;
code	wi_app - init application

	CS1 := CS_BYTEALIGNCLIENT
	CS2 := CS_HREDRAW | CS_VREDRAW
	CS3 := CS_DBLCLKS
;	CS4 := CS_OWNDC			; Don't use this -- exhausts GDI

  func	wi_app
	ctx : * wsTctx
	()  : BOOL
  is	cla : WNDCLASS = {0}
	nam : * char = imPfac		;
	nam = "noname" if !nam		;
	cla.style = CS1|CS2|CS3		;
	cla.lpfnWndProc = wi_evt	; our event procedure
;sic]	cla.cbClsExtra = 0		;
;sic]	cla.cbWndExtra = 0 		; 
	cla.hInstance = ctx->Hins	;
;	cla.hIcon = LoadIcon(ctx->Hins, ctx->Xico)
	cla.hCursor = LoadCursor (NULL, IDC_ARROW)
	(ctx->Vbow) ? WHITE_BRUSH ?? BLACK_BRUSH
	cla.hbrBackground = GetStockObject (that)
	cla.lpszMenuName =  ""		;
	cla.lpszClassName = nam		; image name
	reply RegisterClass (&cla)	;
  end

code	wi_ins - init instance

	WS1 := WS_VSCROLL|WS_HSCROLL
	WS2 := WS_MINIMIZEBOX|WS_MAXIMIZEBOX|WS_THICKFRAME
	WS3 := WS_OVERLAPPED
	WS4 := WS_CAPTION|WS_SYSMENU
 
  func	wi_ins
	ctx : * wsTctx
 	()  : BOOL
  is	wnd : HWND
	nam : * char = imPfac		
	lft : int
	top : int
	sho : int
	sty : int = WS2 | WS3 | WS4	; default style
	cla : * char			;
	nam = "noname" if !nam		; must have something
	cla = nam			; default class

	case ctx->Vsty			; style
	of wsBOX  sty = WS_POPUPWINDOW	;
	end case			;
					;
	wnd = CreateWindow (		;
	  cla, nam, sty,		; class, name, style
	  ctx->Vlft, ctx->Vtop, ctx->Vwid, ctx->Vhgt,
	  NULL, NULL, ctx->Hins, NULL)	;
	fail if !wnd			; failed
	ctx->Hwnd = wnd			; remember it 
					;
	sho = SW_MINIMIZE if ctx->Vmin	;
	sho = ctx->Vsho otherwise	;
					;
	ShowWindow (wnd, sho)		; display it, maybe
	UpdateWindow (wnd)		; update it
	fine
  end
code	ws_loo - server driven message loop

  func	ws_loo
	evt : * wsTevt		
	()  : int
  is	msg : MSG
	while GetMessage (&msg, <>, 0,0); get a windows message
	   wi_dis (&msg)		; dispatch the message
	end				;
	reply 0
  end

code	wi_dis - dispatch message

  func	wi_dis
	msg : * MSG
  is	TranslateMessage (msg)		; translate it
	DispatchMessage (msg) 		; dispatch it
	fine
  end

code	ws_pee - peek at a message

  func	ws_pee
	evt : * wsTevt
	wai : int
  is	msg : MSG
	evt = ws_evt () if !evt		; no event supplied
	if !wai				; look ahead
	   PeekMessage (&msg, <>, 0, 0, PM_REMOVE)
	   pass fail			; nothing doing
	else				; wait for a message
	   GetMessage (&msg,<>, 0, 0)	; get a windows message
	.. fail wc_exi (evt) if eq	; all over
	wi_dis (&msg)			;
	fine
  end
code	wi_evt - windows event (WindowProc)

;	We "fail" to report that we did it

  func	wi_evt
	wnd : HWND
	msg : UINT
	wrd : WPARAM
	lng : LPARAM
	()  : CALLBACK LRESULT
  is	ctx : * wsTctx = ws_ctx ()	; get our context
	evt : wsTevt			; setup the event
	evt.Pctx = ctx			; normalize it
	evt.Hwnd = wnd			;
	evt.Vmsg = msg			;	
	evt.Vwrd = wrd			;
	evt.Vlng = lng			;
	reply ws_dis (&evt)		; dispatch the event
  end

  func	ws_dis
	evt : * wsTevt
  	()  : LONG
  is	ctx : * wsTctx = evt->Pctx
	fac : * wsTfac = ctx->Pfac	; facility list
	chd : HWND = ctx->Hchd		; child window
	msg : UINT = evt->Vmsg
	wrd : WPARAM = evt->Vwrd
	lng : LPARAM = evt->Vlng
	if evt->Hwnd eq ctx->Hwnd	; ignore child here
	   case msg			; preprocess message
	   of WM_MOVE			; position
	      ctx->Vlft = LOWORD (lng)	;
	      ctx->Vtop = HIWORD (lng)	;
	   of WM_SIZE			; size
	      ctx->Vwid = LOWORD (lng)	;
	      ctx->Vhgt = HIWORD (lng)	;
	.. end case			;

;	Facilities handle mouse, drag/drop, waves etc.

	while fac			; handle facilities
	   if fac->Past			; got an ast happening
	      (*fac->Past)(evt, fac)	; call facility
	   .. fail if fine		; facility did it
	   fac = fac->Psuc		;
	end				;
	msg = evt->Vmsg			; refresh that

;	Message dispatch

	case msg			;
	of WM_COMMAND			; command
	   fail wc_cmd (evt) 		;
	of WM_CREATE			; create window
	   fail wc_cre (evt)		; create window
	of WM_PAINT			; paint window
	   fail if wc_pnt (evt)	; use default if fail
	of WM_CLOSE			;
	   wc_exi (evt)		; close client
	   ws_exi (evt)		; should not get here
	of WM_QUIT			;
	or WM_DESTROY			; destroy window
	   fail wc_exi (evt)		; user will quit
	of WM_TIMER			;
	   (*ctx->Ptim)(evt) if ctx->Ptim ; call the timer
	   fail				;
	of WM_SETFOCUS			;
	   gr_car (evt, grFOC, 0, 0)	;
	of WM_KILLFOCUS			;
	   gr_car (evt, grKIL, 0, 0)	;
;	   quit if !chd			; no child window
;	   fail SetFocus (chd)		; focus child
	of WM_SIZE			;
	   fail if ctx->Vmin		; keep it minimized
	   quit if !chd			; no child window
	   fail MoveWindow (chd, 0, 0, LOWORD(lng),  HIWORD(lng), 1)
	of WM_SYSCOMMAND		; alt key up
	   if wrd eq SC_KEYMENU		;
	   .. fail			; we do F10 and Alt up
	end case			;
	reply DefWindowProc (evt->Hwnd, msg, wrd, lng)
  end
code	ws_str - string information

  func	ws_str
	evt : * wsTevt
	cod : int
	()  : * char
  is	ctx : * wsTctx = wsPctx
	case cod
	of wsCMD  reply ctx->Pcmd
	end case
	fail
  end

code	ws_int - integer information

  func	ws_int
	evt : * wsTevt
	cod : int
	()  : int
  is	ctx : * wsTctx = wsPctx ;evt->Pctx
	case cod
	of wsDIH  reply ctx->Vhgt
	of wsDIW  reply ctx->Vwid
	of wsDSX  reply ctx->Vlft
	of wsDSY  reply ctx->Vtop
	of wsDTH  reply GetSystemMetrics (SM_CYFULLSCREEN)
	of wsDTW  reply GetSystemMetrics (SM_CXFULLSCREEN)
	of wsCLR  reply ctx->Vclr
	of wsMIN  reply ctx->Vmin
	of wsSTY  reply ctx->Vsty
	of wsCLA  reply ctx->Vcla
	of wsCHH  reply	ctx->Vchh
	of wsCHW  reply ctx->Vchw
	of wsBOW  reply ctx->Vbow
	of wsDEV  reply <int>(evt->Hdev)
	end case
	fail
  end

code	ws_set - set values

  func	ws_set
	evt : * wsTevt
	cod : int
	val : int
  is	ctx : * wsTctx = wsPctx ;evt->Pctx
	case cod
	of wsDIH  ctx->Vhgt = val
	of wsDIW  ctx->Vwid = val
	of wsDSX  ctx->Vlft = val
	of wsDSY  ctx->Vtop = val
	of wsCLR  ctx->Vclr = val
	of wsPNT  UpdateWindow (ctx->Hwnd) if val
	of wsMIN  ctx->Vmin = val
	of wsSTY  ctx->Vsty = val
	of wsCLA  ctx->Vcla = val
	of wsBOW  ctx->Vbow = val
	end case
	fine
  end

code	ws_mov - reset window area

  func	ws_mov
	evt : * wsTevt
  is	ctx : * wsTctx = evt->Pctx
	wnd : HWND = ctx->Hwnd
	SetWindowPos (wnd, 0,
		ctx->Vlft, ctx->Vtop,
		ctx->Vwid, ctx->Vhgt,
		SWP_NOZORDER|SWP_NOACTIVATE)
	fine
  end
end file
;	of WM_DROPFILES			;
;	   fail (*wsPdrp)(&evt) if *wsPdrp ; got a drop file handler
;	if ctx->Vlog 
;	   case msg
;	   of WM_NCHITTEST		; these occur often
;	   of WM_NCMOUSEMOVE		;
;	   of WM_SETCURSOR		;
;	   of WM_MOUSEFIRST		;
;	   of WM_ENTERIDLE		;
;	   of other			;
;	      PUT("msg=%d ", msg)
;	.. end case
;	if ctx				; got context
;	   fail if wc_evt (&evt)	; got a client event
;	   if wsPwav			;
;	   .. fail if (*wsPwav) (&evt)	; it was a wave event
;	   if wsPmou && (*wsPmou)(&evt)	; got a mouse poll
;	   .. fail wc_mou (&evt)	; client mouse event
;	end				;
code	ws_upd - force update

	grHbru : HBRUSH = 0
	grHpen : HPEN = 0

  func	ws_upd
	evt : * wsTevt
  is	ctx : * wsTctx
	fail if !evt
	ctx = wsPctx ; evt->Pctx
	InvalidateRect (ctx->Hwnd, <>, ctx->Vclr); 1 to force clear
	fine
  end

  func	gr_syn				; sync
	evt : * wsTevt			;
  is	ctx : * wsTctx = evt->Pctx
	msg : MSG			;
	res : int			;
	RedrawWindow (evt->Hwnd, <>, <>, RDW_ERASENOW)
      repeat				;
	res = GetMessage (&msg,<>,0,0)	; get a windows message
	quit if fail			;
	quit if msg.message eq WM_PAINT	; got it 
	DefWindowProc (msg.hwnd, msg.message,
		   msg.wParam, msg.lParam)
      forever				;
	fine				;
  end

  func	gr_beg 
	evt : * wsTevt
	()  : int
  is	ctx : * wsTctx = wsPctx ; evt->Pctx
 	wnd : HWND = ctx->Hwnd
	dev : HDC
	met : TEXTMETRIC		;
	if evt->Vmsg ne WM_PAINT	;
	.. gr_syn (evt)			; catch a falling star
					;
	ctx->Vpnt = 0			; paint job done
	BeginPaint (wnd, &evt->Ipnt)	; get hdc and pst
	evt->Hdev = dev	= that		; device context
	GetStockObject (OEM_FIXED_FONT)	; default font
	SelectObject (dev, that)	; select it
	fine				;
  end

  func	gr_end 
	evt : * wsTevt
	()  : int
  is	ctx : * wsTctx = wsPctx ()
	DeleteObject (ctx->Hbru) if ctx->Hbru
	DeleteObject (ctx->Hpen) if ctx->Hpen
	ctx->Hbru = 0
	ctx->Hpen = 0
	EndPaint (evt->Hwnd, &evt->Ipnt)
	fine
  end
code	gr_pol - draw polyline

  func	gr_pol
	evt : * wsTevt
	seg : * long
	cnt : int
  is	dev : HDC = evt->Hdev
	Polyline (dev, <*POINT>seg, cnt)
	fine
  end

code	gr_ppl - poly polyline

  func	gr_ppl
	evt : * wsTevt
	seg : * long		; segments
	sec : * LONG		; section counts
	cnt : int		; sections
  is	dev : HDC = evt->Hdev
;;;NT	PolyPolyline (dev, <*POINT>seg, sec, cnt)
	while cnt--
	   gr_pol (evt, seg, *sec)
	   seg += *sec++ * 2	; 2 longs per point
	end
	fine
  end

code	gr_txt - text out

  func	gr_txtx
	evt : * wsTevt
	x   : int
	y   : int
	str : * char
  is	dev : HDC = evt->Hdev
;if <nat>(evt->Pctx) lt 100
;	ws_dec ("x: evt->Pctx", <int>evt->Pctx)
;else
	TextOut (dev, x, y, str, st_len (str))
;end
	fine
  end

code	gr_txw - text out wide

  func	gr_txw
	evt : * wsTevt
	x   : int
	y   : int
	str : * char
	cnt : int 
  is	dev : HDC = evt->Hdev
;if <nat>(evt->Pctx) lt 100
;	ws_dec ("x: evt->Pctx", <int>evt->Pctx)
;else
	TextOutW (dev, x, y, str, cnt)
;end
	fine
  end


code	gr_col - select colours

  func	gr_col
	evt : * wsTevt
	pap : int
	ink : int
  is	han : HBRUSH
	SetBkColor (evt->Hdev, PALETTEINDEX(pap)) if pap ne -1
	fine if ink eq -1
	SetTextColor (evt->Hdev, PALETTEINDEX(ink))

;	DeleteObject (grHbru) if grHbru
;	DeleteObject (grHpen) if grHpen
;	grHbru = CreateSolidBrush (PALETTEINDEX(ink))
;	SelectObject (evt->Hdev, grHbru)
;	grHpen = CreatePen (PS_SOLID, 0, PALETTEINDEX(ink))
;	SelectObject (evt->Hdev, grHpen)
	fine
  end

code	gr_fnt - setup font metrics

  func	gr_fnt 
	evt : * wsTevt
	fnt : int
	()  : int
  is	ctx : * wsTctx = evt->Pctx
	rec : RECT = {0}
;	dev : HDC = CreateMetaFile (<>)
	dev : HDC = CreateEnhMetaFile (<>,<>,&rec,<>)
	han : HENHMETAFILE		;
	met : TEXTMETRIC		;
	GetStockObject (OEM_FIXED_FONT)	; default font
	SelectObject (dev, that)	; select it
	GetTextMetrics (dev, &met);get text metrics
	ctx->Vchh = met.tmHeight	;
	ctx->Vchw = met.tmMaxCharWidth	;
	han = CloseEnhMetaFile (dev)	;
	DeleteEnhMetaFile (han)		;
	fine				;
  end
