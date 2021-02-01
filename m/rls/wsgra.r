file	wsgra - graphic functions
include	rid:rider
include	rid:wsdef
include	rid:stdef
include rid:dbdef
include	rid:ftdef

code	gr_beg - begin paint


  func	gr_beg 
	evt : * wsTevt
  is	ctx : * wsTctx = ws_ctx ()
 	wnd : HWND = ctx->Hwnd
	dev : HDC
	met : TEXTMETRIC			;

;	gr_syn (evt) if evt->Vmsg ne WM_PAINT	;
	if evt->Vmsg eq WM_PAINT		;
	   ctx->Vpnt = 0			; paint job done
	   dev = BeginPaint (wnd, &evt->Ipnt)	; get hdc and pst
	else					;
	.. dev = GetDC (wnd)			;
	evt->Hdev = dev				; device context
	if !ctx->Vbow				; not black on white
	   SetBkColor (dev, RGB(0,0,0))		; wants white on black
	.. SetTextColor (dev, RGB(255,255,255))	;
	ctx->Hbru = GetStockObject (OEM_FIXED_FONT) ; default font
	SelectObject (dev, that)		; select it
	fine					;
  end

code	gr_end - end paint

  func	gr_end 
	evt : * wsTevt
  is	ctx : * wsTctx = evt->Pctx

	if evt->Vmsg eq WM_PAINT
	   EndPaint (evt->Hwnd, &evt->Ipnt)
	else
	.. ReleaseDC (evt->Hwnd, evt->Hdev)
	DeleteObject (ctx->Hbru)
	DeleteObject (ctx->Hpen)
	ctx->Hbru = 0
	ctx->Hpen = 0
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

  func	gr_txt
	evt : * wsTevt
	x   : int
	y   : int
	str : * char
  is	dev : HDC = evt->Hdev
	TextOut (dev, x, y, str, st_len (str))
	fine
  end

code	gr_txw - text out wide

  func	gr_txw
	evt : * wsTevt
	x   : int
	y   : int
	str : * WORD
	cnt : int 
  is	dev : HDC = evt->Hdev
	TextOutW (dev, x, y, str, cnt)
	fine
  end
code	gr_col - select colours

  func	gr_col
	evt : * wsTevt
	pap : int
	ink : int
  is	han : HBRUSH
	ctx : * wsTctx = ws_ctx ()
	pen : HGDIOBJ = ctx->Hbru
	bru : HGDIOBJ = ctx->Hpen
	SetBkColor (evt->Hdev, PALETTEINDEX(pap)) if pap ne -1
	SetTextColor (evt->Hdev, PALETTEINDEX(ink)) if ink ne -1

	ctx->Hbru = CreateSolidBrush (PALETTEINDEX(ink))
	SelectObject (evt->Hdev, ctx->Hbru)
	ctx->Hpen = CreatePen (PS_SOLID, 0, PALETTEINDEX(ink))
	SelectObject (evt->Hdev, ctx->Hpen)
	DeleteObject (bru)
	DeleteObject (pen)
	fine
  end
code	gr_car - caret operations

;	Any race conditions are fixed up by the subsequent SET_FOCUS.
;	See wsmod.r for SET_FOCUS/KILL_FOCUS dispatch.

  func	gr_car
	evt : * wsTevt
	opr : int
	col : int
	row : int
  is	ctx : * wsTctx = ws_ctx ()
	car : * wsTcar = &ctx->Icar
	wnd : HWND = ctx->Hwnd
	wid : int = ws_int (evt, wsCHW)
	hgt : int = ws_int (evt, wsCHH)

	exit if !wnd
;PUT("*")

;	if (opr eq grBLK) || (opr eq grGRY)
;	if opr eq grPOS
;	.. car->Vcol=col, car->Vrow=row

	case opr
	of grFOC car->Vfoc = 1, car->Vvis = 0
;PUT("<")
	of grKIL car->Vfoc=car->Vcre=car->Vvis=0
	         DestroyCaret() 
;PUT(">")
	of grHID car->Vsho = 0
	of grSHO car->Vsho = 1
	of grBLK car->Vren = 0
	of grGRY car->Vren = 1
	of grPOS car->Vcol=col, car->Vrow=row
	end case

	exit if !car->Vfoc

	if !car->Vsho
	   while car->Vvis gt
;PUT("!")
	   .. --car->Vvis, HideCaret(wnd)
	.. exit

	if !car->Vcre
;PUT("^")
	   CreateCaret (wnd,<*void>car->Vren,3, hgt)
  	   exit if !car->Vfoc 	; lost focus
	.. ++car->Vcre

	SetCaretPos (car->Vcol, car->Vrow)

	while car->Vsho && (car->Vvis le)
;PUT(".")
	.. ++car->Vvis, ShowCaret(wnd)
  end
code	gr_fnt - setup font metrics

;	Obseleting this

  func	gr_fnt 
	evt : * wsTevt
	fnt : int
  is	ctx : * wsTctx = evt->Pctx
	rec : RECT = {0}
;	dev : HDC = CreateMetaFile (<>)
	dev : HDC = CreateEnhMetaFile (<>,<>,&rec,<>)
	han : HENHMETAFILE		
	met : TEXTMETRIC		
	GetStockObject (OEM_FIXED_FONT)	; default font
	SelectObject (dev, that)	; select it
	GetTextMetrics (dev, &met)	; get text metrics
	ctx->Vchh = met.tmHeight	;
	ctx->Vchw = met.tmMaxCharWidth	;
	han = CloseEnhMetaFile (dev)	;
	DeleteEnhMetaFile (han)		;
	fine				;
  end

code	gr_sel - select font object

;	Call this after gr_beg ()

  func	gr_sel
	evt : * wsTevt
	fnt : * wsTfnt
  is	ctx : * wsTctx = ws_ctx ()
	ft_sel (fnt, evt->Hdev)
	pass fail
	ctx->Vchh = (<*ftTfnt>fnt)->Vhgt
	ctx->Vchw = (<*ftTfnt>fnt)->Vwid
	fine
  end

  func	gr_uns
	evt : * wsTevt
	fnt : * wsTfnt
  is	reply ft_uns (fnt, evt->Hdev)
  end
end file
code	gr_car - caret operations

	grVcar : int = 0
	grVvis : int = 0

  func	gr_car
	evt : * wsTevt
	opr : int
	col : int
	row : int
  is	ctx : * wsTctx = ws_ctx ()
	wnd : HWND = ctx->Hwnd
	wid : int = ws_int (evt, wsCHW)
	hgt : int = ws_int (evt, wsCHH)
	if !grVcar				; not setup
	   ++grVcar				; default done
	   gr_car (evt, grBLK, 3, hgt)		; create caret
	.. gr_car (evt, grSHO, 0, 0)		; and display it
	case opr
	of grHID  if grVvis			;
		  .. grVvis=0 if HideCaret(wnd)	; hide it
	of grSHO  if !grVvis			;
		  .. grVvis=1 if ShowCaret(wnd)	; show it
	of grPOS  SetCaretPos (col, row)
		  db_lst ("SetCaretPos") if fail
	of grBLK  CreateCaret (wnd, <*void>0, col, row)
		  db_lst ("CreateCaret") if fail
	of grGRY  CreateCaret (wnd, <*void>1, col, row)
		  db_lst ("CreateCaret") if fail
	end case
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
