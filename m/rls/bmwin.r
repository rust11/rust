code	bmwin - windows bitmap operations
include	rid:rider
include	rid:wsdef	; wsdef must precede bmdef
include	rid:bmdef
include	rid:medef

code	bm_inf - get bitmap info

;	Undocumented but true: bitmap plex and buffer need to be
;	in global shared memory for W16, unclear with WNT.
;
;	W32 SetDIBitsToDevice DIB_PAL_INDICES mode only under WNT.

	bmPinf : * BITMAPINFO own = <>

  func	bm_inf
	()  : * BITMAPINFO own
  is	inf : * BITMAPINFO = bmPinf
	hdr : * BITMAPINFOHEADER
	pal : * word
	cnt : int = 0
	reply inf if inf
	mg_acc (#BITMAPINFO + (256*#word))
	inf = bmPinf = that

	pal = <*word>&inf->bmiColors		; dummy up a pallette
	*pal++ = cnt++ while cnt lt 256		; fill in a pallette
						;
	hdr = &inf->bmiHeader			; fill in the constants
	hdr->biSize = #BITMAPINFOHEADER		; version ident
	hdr->biPlanes = 1			; always one plane
	hdr->biBitCount = 8			; always 256 colours
	hdr->biCompression = BI_RGB		; no compression
	hdr->biXPelsPerMeter = 0		; ignored apparently
	hdr->biYPelsPerMeter = 0		;
	hdr->biClrUsed = 32			; probably unused
	hdr->biClrImportant = 0			;
	reply inf
  end

code	bm_pnt - paint bitmap

  func	bm_pnt
	evt : * wsTevt
	bmp : * bmTbmp
	x   : int
	y   : int
  is	inf : * BITMAPINFO = bm_inf ()
	wid : int = bmp->Vwid
	hgt : int = bmp->Vhgt

	inf->bmiHeader.biWidth = wid
	inf->bmiHeader.biHeight = -hgt

;;;	hdr->biSizeImage = wid * hgt

	SetDIBitsToDevice (evt->Hdev,
		x, y, wid, hgt, 
		0, 0, 0,   hgt,
		bmp->Pdat, inf,
;		DIB_PAL_INDICES)
		DIB_PAL_COLORS)		; use DIB_PAL_INDICES for WNT
	printf ("%bm_pnt-W-Error=%d\n", GetLastError ()) if !that
	fine
  end
end file
code	bm_imp - import windows bitmap
xxx : int own = 0

  func	bm_imp
	ptr : * void
	bmp : * bmTbmp
  is	inf : * BITMAPINFO = ptr
	hdr : * BITMAPINFOHEADER ;= &inf->bmiHeader
	rgb : * RGBQUAD ;= <*RGBQUAD>(<*BYTE>hdr + hdr->biSize)
	dat : * void ;= <*BYTE>(rgb + hdr->biClrUsed)
	hdr = &inf->bmiHeader
PUT("inf=%X hdr=%X\n", inf, hdr)
	rgb = <*RGBQUAD>(<*BYTE>hdr + hdr->biSize)
	dat = <*BYTE>(rgb + hdr->biClrUsed)
++xxx, PUT("biSize=%d\n", hdr->biSize) if hdr->biSize && !xxx

PUT("BitCount=%d, Compression=%d, ClrUsed=%d\n",
  hdr->biBitCount, hdr->biCompression, hdr->biClrUsed)

	bmp->Vtyp = bmPAL
	bmp->Vwid = hdr->biWidth
	bmp->Vhgt = hdr->biHeight
	bmp->Vhgt = -bmp->Vhgt if bmp->Vhgt lt
	bmp->Vtot = bmp->Vwid * bmp->Vhgt
	bmp->Pdat = dat
	fine
  end
