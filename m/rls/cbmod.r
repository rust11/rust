file	cbmod - windows clipboard
include	rid:wsdef
include	rid:cbdef
include	rid:medef
include	rid:stdef

  func	cb_opn
  is	ctx : * wsTctx = ws_ctx ()
	reply OpenClipboard (ctx->Hwnd) ne
  end

  func	cb_clo
  is	fine CloseClipboard ()
  end

  func	cb_get
	fmt : int
	()  : * char
  is	hnd : HWND
	src : * char
	dst : * char = <>
	len : int
	fmt = CF_TEXT if !fmt

	fail if !cb_opn ()
	if (hnd = GetClipboardData (fmt)) ne
	&& (src = GlobalLock (hnd)) ne
	   len = st_len (src)
	   dst = me_alc (len+1)
	   st_cop (src, dst)
	   GlobalUnlock (hnd)
	end
	cb_clo ()
	reply dst
  end

  func	cb_put
	src : * char
	fmt : int
  is	hnd : HWND
	dst : * char
	len : int
	fail if !cb_opn ()
	fmt = CF_TEXT if !fmt
	len = st_len (src)
	hnd = GlobalAlloc (GMEM_MOVEABLE, len+1)
	fail cb_clo () if !hnd
	dst = GlobalLock (hnd)
	st_cop (src, dst)
	SetClipboardData (fmt, dst)
	fine
  end



