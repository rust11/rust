file	txmod - windows text objects
include	rid:wsdef
include	rid:txdef
include	rid:medef
include	rid:fidef
include	rid:stdef
Log := 0
include	rid:dbdef

code	tx_cre - create text window

	ES1 :=	WS_CHILD | WS_VISIBLE | WS_VSCROLL ;| WS_HSCROLL
	ES2 :=	ES_LEFT | ES_MULTILINE | WS_BORDER 
	ES3 :=	ES_NOHIDESEL | ES_AUTOVSCROLL ;| ES_AUTOHSCROLL
	EDITID := 1

  func	tx_cre
	evt : * wsTevt
	()  : * txTtxt
  is	txt : * txTtxt
	ctx : * wsTctx = evt->Pctx
	ins : HANDLE = (<LPCREATESTRUCT>evt->Vlng)->hInstance
	wnd : HWND
	log : LOGFONT

;	LOG ("Create edit window")
	wnd = CreateWindow ("edit", <>,
		ES1|ES2|ES3, 0, 0, 0, 0,
		evt->Hwnd, <HMENU>EDITID, ins, <>)
;	LOGe("Edit window create failed") if !wnd
	fail if !wnd
	txt = me_acc (#txTtxt)	
	txt->Hwnd = wnd
;	LOGv("wnd=%x", wnd)
	ws_chd (evt, wnd)
	SendMessage (wnd, EM_LIMITTEXT, 64000, 0L)
	GetStockObject (SYSTEM_FONT)
	GetObject (that, #LOGFONT, <LPSTR>&log)
	tx_fnt (evt, txt, &log)
	reply txt
  end

code	tx_des - destroy text window

  func	tx_des
	evt : * wsTevt
	txt : * txTtxt
  is	DestroyWindow (txt->Hwnd)	
	me_dlc (txt)
	fine
  end
code	tx_loa - load file

  func	tx_loa
	evt : * wsTevt
	txt : * txTtxt
	spc : * char
	mod : int
	()  : int
  is	dat : * char
	len : size
	res : int = 0
;	LOG("tx_loa")
	fi_loa (spc, &<*void>dat, &len, <>, <>)
	fail if !dat
	if len lt 64000
;	   LOG ("fi_loa - set window text")
;	   LOGv("buf=%x", dat)
;	   LOGv("len=%d", len)
	   dat[len-1] = 0
	.. res = SetWindowText (txt->Hwnd, dat)
;	LOG ("fi_loa - deallocate")
	me_dlc (dat)
;	LOGv("tx_loa done %d", res)
	reply res
  end

code	tx_clo - close file

  func	tx_clo
	evt : * wsTevt
	txt : * txTtxt
  is	SetWindowText (txt->Hwnd, "\0")
	tx_fun (evt, txt, txALL)
	tx_fun (evt, txt, txDEL)
	fine
  end

code	tx_sto - store file

  func	tx_sto
	evt : * wsTevt
	txt : * txTtxt
	spc : * char
	mod : int
  is	len : size
;	han : HANDLE
	buf : * char
	res : int
;	LOG ("tx_sto")
;	LOGv("txt=%x", txt)
;	LOGv("wnd=%x", txt->Hwnd)
	len = GetWindowTextLength (txt->Hwnd)
;	LOGv("len=%d", len)
	buf = me_alc (len)

;	LOGv("buf=%x", buf)
	fail if !buf
	res = GetWindowText (txt->Hwnd, buf, len)
;	if res ne len
;	.. LOGv ("GetWindowText %d", res)
	if res ne
	.. res = fi_sto (spc, buf, len, 0, "")
;	LOG ("tx_sto -- dealloc")
	me_dlc (buf)
;	LOGv("tx_sto res=%d", res)
	reply res
  end
code	tx_fun - simple functions

  func	tx_fun
	evt : * wsTevt
	txt : * txTtxt
	fun : int
  is	cod : int
	lng : long
	fine if !txt
	case fun
	of txUND  cod = WM_UNDO
	of txCUT  cod = WM_CUT
	of txCOP  cod = WM_COPY
	of txPAS  cod = WM_PASTE
	of txDEL  cod = WM_CLEAR
	of txALL  cod = EM_SETSEL
		  lng = ~(0)
	end case
	SendMessage (txt->Hwnd, cod, 0, lng)
	reply that
  end

code	tx_fnt - get/set font

  func	tx_fnt
	evt : * wsTevt
	txt : * txTtxt
	fnt : * wsTfnt
	()  : * wsTfnt
  is	ctx : * wsTctx = evt->Pctx
	log : * LOGFONT = <*LOGFONT>fnt
	new : HFONT

	reply &txt->Sfnt if !fnt		; query

	new = CreateFontIndirect (log)
	SendMessage (ctx->Hchd, WM_SETFONT, <LONG>new, 0L)
	DeleteObject (txt->Hfnt) if txt->Hfnt
	txt->Hfnt = new
	me_cop (log, &txt->Sfnt, #LOGFONT)
	reply &txt->Sfnt
  end
code	tx_opt - output string

  func	tx_opt
	evt : * wsTevt
	txt : * txTtxt
	buf : * char
	len : int
  is	len = st_len (buf) if len eq -1
	while len--
	   SendMessage (txt->Hwnd, WM_CHAR, *buf++, 0)
	end
	fine
  end

end file
code	tx_get - get active text

  func	tx_get
	evt : * wsTevt
	buf : * txTbuf
  is	txt : * txTtxt
                         iOffset = HIWORD (
                              SendMessage (hwndEdit, EM_GETSEL, 0, 0L)) ;

  end
