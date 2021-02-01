file	bsmod - bitmap sections
include	rid:wsdef
include	rid:bsdef
include	rid:medef
include	rid:imdef
include	rid:stdef
;include	rid:wing
	bs_pal : (*wsTevt, *bsTsec) int

code	bs_sho - show device

   func	bs_sho
	sec : * bsTsec
	dev : HDC
	tit : * char
  is	buf : [512] char
	x   : int
	y   : int
	st_cop ("I-", buf)
	st_app (tit, buf)
	st_app (": ", buf)
	x = GetDeviceCaps (dev, HORZRES)
	y = GetDeviceCaps (dev, VERTRES)
	FMT(st_end(buf), "Width=%d, Height=%d\n", x, y)
	x = GetDeviceCaps (dev, SIZEPALETTE)
	FMT(st_end(buf), "Palette=%d\n", x)
	im_rep(buf, <>)
;bs_sho (sec, ddc, "HDC")
;bs_sho (sec, sec->Hidc, "IDC")
  end


code	bs_dim - get buffer dimensions

  func	bs_dim
	sec : * bsTsec
	wid : * int
	hgt : * int
  is	fail if !sec
	*wid = sec->Vwid
	*hgt = sec->Vhgt
	fine
  end

code	bs_scn - get start of scanline

;	Handle end-of-scanline padding and orientation
;	Call bs_scn (sec, 0) to get buffer address

  func	bs_scn
	sec : * bsTsec
	scn : int
	()  : * void
  is	reply <> if !sec
	reply <> if scn ge sec->Vhgt
	reply <*BYTE>sec->Pbuf + (scn * sec->Vext)
  end

code	bs_beg - begin/end paint

DDC : HDC

  func	bs_beg 
	evt : * wsTevt
	sec : * bsTsec
  is	ctx : * wsTctx = evt->Pctx
 	wnd : HWND = ctx->Hwnd
	ddc : HDC
	ctx->Vpnt = 0			; paint job done
 	ddc = BeginPaint(wnd,&evt->Ipnt); get hdc and pst
DDC = ddc
	SelectPalette (ddc, sec->Hpal, 0) if sec->Hpal
	RealizePalette (ddc)		;
;	evt->Hdev = ddc	= that		; device context
	evt->Hdev = sec->Hidc		;
	TextOut (sec->Hidc, 10, 10, "hello", 5)
	fine				;
  end

  func	bs_end 
	evt : * wsTevt
	sec : * bsTsec
  is	EndPaint (evt->Hwnd, &evt->Ipnt)
	fine
  end

code	bs_blt - blit the section

  func	bs_blt
	evt : * wsTevt
	sec : * bsTsec
  is	ddc : HDC
	fail if !sec
	BitBlt(DDC, 10,10,
		10, 10,
		sec->Hidc,  10, 10, SRCCOPY)
 	PUT("Blt %X\n", GetLastError()) if fail
;	BitBlt(DDC, 0,0,
;		sec->Vwid, sec->Vhgt,
;		sec->Hidc,  0, 0, SRCCOPY)
;	GdiFlush ()
	fine
  end
code	bs_alc - allocate/reallocate current bitmap section

;	Call here from WM_SIZE with width/height from LPARAM.
;	bs_alc automatically allocates bsTsec if sec eq <>.

  func	bs_alc 
	evt : * wsTevt
  	sec : * bsTsec
	wid : int
	hgt : int
	()  : * bsTsec
  is	inf : * bsTinf
	han : HBITMAP
	fst : int = 0
	sec = me_acc (#bsTsec) if !sec			; autoallocate
	inf = &sec->Sinf				; BITMAPINFOHEADER
	sec->Vwid = inf->biWidth = wid			; reset these
	sec->Vhgt = inf->biHeight = hgt			;
	sec->Vext = ((wid+3)/4)*4			; compute scan extent
     if !sec->Vini					;
	inf->biSize = #bsTinf,	inf->biPlanes = 1	; magic numbers
	inf->biBitCount = 8, inf->biCompression = BI_RGB;
;;;	bs_pal (evt, sec)				; create the palette
;	sec->Hidc = WinGCreateDC () if sec->Vwng	;
	sec->Hidc = CreateCompatibleDC (<>) ;otherwise	; get a new DC
	im_rep ("E-Bitmap DC create failed", <>) if !sec->Hidc
	++sec->Vini, ++fst				; inited, first time
;	++sec->Vwng					; use wing
     end						;
     if sec->Vwng					; use wing
;	han = WinGCreateBitmap(sec->Hidc,		;
;		<*BITMAPINFO>inf, &sec->Pbuf)		;
     else						;
;  HBITMAP CreateDIBSection(HDC, BITMAPINFO *, UINT, VOID **, HANDLE, DWORD)
	han=CreateDIBSection(sec->Hidc,<*BITMAPINFO>inf,; create handle
	      DIB_RGB_COLORS, &sec->Pbuf, <>, 1)	; and buffer
     end						;
	fail im_rep ("E-Bitmap Section creation failed", <>) if !han
	inf->biSizeImage = inf->biWidth * inf->biHeight	; compute image size
	han = <HBITMAP>SelectObject (sec->Hidc, han)	; select new one
	im_rep ("E-Bitmap Select failed", <>) if fail	;
	sec->Hpre = han    if fst			; save it first time
	DeleteObject (han) otherwise			; delete temporary
	PatBlt(sec->Hidc, 0,0,wid, hgt, BLACKNESS)	; paint it black
	reply sec					; give them a section
  end

code	bs_dlc - deallocate bitmap section

  proc	bs_dlc
	evt : * wsTevt
	sec : * bsTsec
  is	han : HBITMAP
	exit if !sec || !sec->Vini	; never started
	sec->Vini = 0			;
	han = <HBITMAP>SelectObject(sec->Hidc, sec->Hpre)
	DeleteObject (han)		; delete the bitmap
	DeleteDC (sec->Hidc)		; delete the DC
	me_dlc (sec->Ppal)		; deallocte palette
	DeleteObject (sec->Hpal) if sec->Hpal
	me_dlc (sec)			; delete section header
  end
code	bs_pal - create palette
	bs_evt	: wsTast			; facility ast

  func	bs_pal
	evt : * wsTevt
	sec : * bsTsec
  is	pal : * LOGPALETTE		
	ent : * PALETTEENTRY
	rgb : * RGBQUAD
	bmp : HBITMAP
	fac : * wsTfac
	cnt : int
	scr : HDC
	fail if !sec
	if (pal = sec->Ppal) eq			; palette structure
	   sec->Ppal = pal = me_acc (#LOGPALETTE + (#PALETTEENTRY * 255))
	   pal->palVersion = 0x300		; magic numbers
	.. pal->palNumEntries=256		;
						;
	ent = pal->palPalEntry			; palette entry pointer
	rgb = sec->Argb				; rgb pointer
						;
	scr = GetDC (HWND_DESKTOP)		; get screen DC
	GetSystemPaletteEntries (scr,0,256,ent) ; get all the entries
						;
	ReleaseDC (0, scr)			; free up DC
	while cnt in 0..255
	   if (cnt ge 10) || (cnt lt 246)
	      rgb[cnt].rgbRed   = ent[cnt].peRed
	      rgb[cnt].rgbBlue  = ent[cnt].peBlue
	      rgb[cnt].rgbGreen = ent[cnt].peGreen
	      rgb[cnt].rgbReserved = 0
	      ent[cnt].peFlags = PC_NOCOLLAPSE
	   else
	   .. ent[cnt].peFlags = 0
	end
	sec->Hpal = CreatePalette (pal)
PUT("CreatePalette\n") if fail

	fac = ws_fac (evt, "BS_PALETTE")	; set up facility ast
	fac->Pusr = sec				; pass it the section
	fac->Past = bs_evt			; to this routine
  end

code	bs_evt - Windows event handling

  func	bs_evt
	evt : * wsTevt
	fac : * wsTfac
  is	sec : * bsTsec = fac->Pusr
	hdc : HDC
	fail if !sec
	fail if !sec->Vini
	case evt->Vmsg
	of WM_PALETTECHANGED
PUT("Palette event\n")
	   fail if evt->Hwnd eq <HWND>evt->Vwrd	; we just changed it
	or WM_QUERYNEWPALETTE
PUT("Palette event\n")
	   hdc = GetDC (evt->Hwnd)
PUT("1\n") if fail
if sec->Hpal
	   SelectPalette (hdc, sec->Hpal, 0); if sec->Hpal
PUT("2\n") if fail
end
	   RealizePalette (hdc)
PUT("3 %X\n", GetLastError ()) if that eq GDI_ERROR
	   ReleaseDC (evt->Hwnd, hdc);
PUT("4\n") if fail
	   fine
	end case
	fail
  end
end file


	case WM_PALETTECHANGED:
	    if (hWnd == (HWND)wParam)
    		break;
	    // Fall through here
	case WM_QUERYNEWPALETTE:
	    hDC = GetDC(hWnd);
   	    if (hpalApp)
    		SelectPalette(hDC,hpalApp,FALSE);

	    RealizePalette(hDC);
	    ReleaseDC(hWnd,hDC);
	    return FALSE;

  type	bsTpal




  is	Vver : int
	Vcnt : int
	Apal : [256] PALETTEENTRY
  end

typedef struct _PALETTE
{
	WORD Version;
	WORD NumberOfEntries;
	PALETTEENTRY aEntries[256];
} _PALETTE;
	Spal : bsTpal
_PALETTE LogicalPalette = {0x300, 256}; // The 'logical' palette we will use
	// "0x300" = Windows 3.0 or later
	// "256" = Number of colors




				HBITMAP hbm;
			    int Counter;
			    HDC Screen;
			    //RGBQUAD far *pColorTable;
		int nStaticColors;
		int nUsableColors;

		// *** Get the static colors
		nStaticColors = GetDeviceCaps(hdc, NUMCOLORS);
		GetSystemPaletteEntries(hdc, 0, 256, Palette.aEntries);

		// *** Set the peFlags of the lower static colors to zero
		nStaticColors = nStaticColors / 2;
		for (i=0; i<nStaticColors; i++)
			Palette.aEntries[i].peFlags = 0;

		// *** Fill in the entries from the given color table
		nUsableColors = nColors - nStaticColors;
		for (; i<nUsableColors; i++)
		{
			Palette.aEntries[i].peRed = aRGB[i].rgbRed;
			Palette.aEntries[i].peGreen = aRGB[i].rgbGreen;
			Palette.aEntries[i].peBlue = aRGB[i].rgbBlue;
			Palette.aEntries[i].peFlags = PC_RESERVED;
		}

		// *** Mark any empty entries as PC_RESERVED
		for (; i<256 - nStaticColors; i++)
			Palette.aEntries[i].peFlags = PC_RESERVED;

		// *** Set the peFlags of the upper static colors to zero
		for (i = 256 - nStaticColors; i<256; i++)
			Palette.aEntries[i].peFlags = 0;
	}

	ReleaseDC(NULL, hdc);

	// *** Create the palette
	return CreatePalette((LOGPALETTE *)&Palette);
end file

	cnt : int
	scr : HDC
	tab : * RGBQUAD

			} else {
				//  Create a new WinGDC and 8-bit WinGBitmap

				HBITMAP hbm;
			    int Counter;
			    HDC Screen;
			    //RGBQUAD far *pColorTable;
;	Create identity palette
	scr = GetDC (HWND_DESKTOP)	;  get desktop DC
			    hpalApp = CreatePalette((LOGPALETTE far *)&LogicalPalette);
				// Get the 20 system colors as PALETTEENTRIES
    GetSystemPaletteEntries(Screen,0,10,LogicalPalette.aEntries);
    GetSystemPaletteEntries(Screen,246,10,LogicalPalette.aEntries + 246);
                
                // Only a few DCs available, free this up so we aren't a hog
				ReleaseDC(0,Screen);

				// Initialize the logical palette and DIB color table
				// Note that we are doing this as double entries. Making
				// sure that we keep both tables -identical- this is to
				// make sure that we can end up with an 'identity palette'
				// which means that both the colortable assigned to the DIB
				// and the palette entries associated with the palette
				// that is selected into the Device Context are identical.

			    for(Counter = 0; Counter < 10; Counter++) {
				// copy the system colors into the DIB header
				// WinG will do this in WinGRecommendDIBFormat,
				// but it may have failed above so do it here anyway

					// The low end colors...				
					image.aColors[Counter].rgbRed =
						LogicalPalette.aEntries[Counter].peRed;
					image.aColors[Counter].rgbGreen =
						LogicalPalette.aEntries[Counter].peGreen;
					image.aColors[Counter].rgbBlue =
						LogicalPalette.aEntries[Counter].peBlue;
					image.aColors[Counter].rgbReserved = 0;
					LogicalPalette.aEntries[Counter].peFlags = 0;
                                            
					// And the high end colors...
					image.aColors[Counter + 246].rgbRed =
						LogicalPalette.aEntries[Counter + 246].peRed;
					image.aColors[Counter + 246].rgbGreen =
						LogicalPalette.aEntries[Counter + 246].peGreen;
					image.aColors[Counter + 246].rgbBlue =
						LogicalPalette.aEntries[Counter + 246].peBlue;
					image.aColors[Counter + 246].rgbReserved = 0;
					LogicalPalette.aEntries[Counter + 246].peFlags = 0;
				}

			    // Now fill in all of the colors in the middle to reflect
			    // the colors that we are wanting. Here, we are just
			    // setting random values.
			    for(Counter = 10;Counter < 246;Counter++) {
					image.aColors[Counter].rgbRed =
						LogicalPalette.aEntries[Counter].peRed = rand()%255;
					image.aColors[Counter].rgbGreen =
						LogicalPalette.aEntries[Counter].peGreen = rand()%255;
					image.aColors[Counter].rgbBlue =
						LogicalPalette.aEntries[Counter].peBlue = rand()%255;
					image.aColors[Counter].rgbReserved = 0;
					// In order for this to be an identity palette, it is
					// important that we not only get this color, but that
					// we get it in THIS location. Using PC_NOCOLLAPSE tells
					// the system not to 'collapse' this entry to another
					// palette entry that already has this color.
					LogicalPalette.aEntries[Counter].peFlags = PC_NOCOLLAPSE;
			    }

			    // The logical palette table is fully initialized.
			    // All we have to do now, is create it.
file	bmraw -- manage raw data window

  type	bmTraw
  is	Hidc : HDC 		; image device context
	Sinf : BITMAPINFOHEADER	; bitmap info
	Acol : [256] RGBQUAD	; palatte colour table
	pBuf : * void		; data area
  end

typedef struct _IMAGE {
	BITMAPINFOHEADER bi;  // Bitmap header information.
	RGBQUAD aColors[256]; // Palette color table
	union { // Now for the pointer to the data buffer we can whack on:
		LPVOID  lpvData; // This is the type that WinG likes to deal with
		LPBYTE  lpIndex; // This is just to make it easier for us to access it
	};
} _IMAGE;
_IMAGE image; // Contains most necessary information about the image to display
  func	bm_siz 
	evt : * wsTevt
  	raw : * bmTraw
  is	inf : * BITMAPINFOHEADER = &raw->Sinf
	wid : int = LOWORD (evt.Vlng)
	hgt : int = HIWORD (evt.Vlng)
	han : HBITMAP
	inf->biWidth = wid				; reset these
	inf->biHeight = hgt				;
     if win->Vidc					;
	han = CreateDibSection (raw->Hidc, inf,		;
	      DIB_PAL_COLORS, &raw->pBUf, <>, 0)	;
	if fail						;
	.. fail im_rep ("E-DIB Section creation failed"); oops
	inf->biWidth * inf.biHeight * raw->Vori		; compute image size
	inf->biSizeImage = that				; reset image size
	han = <HBITMAP>SelectObject (raw->Hidc, han)	; select new one
	DeleteObject (han)				; delete previous
     else
	cnt : int
	scr : HDC
	tab : * RGBQUAD

			} else {
				//  Create a new WinGDC and 8-bit WinGBitmap

				HBITMAP hbm;
			    int Counter;
			    HDC Screen;
			    //RGBQUAD far *pColorTable;
	inf->biSize = #BITMAPINFOHEADER
	inf->biPlanes = 1
	inf->biBitCount = 8
	inf->biCompression = BI_RGB
	inf->biSizeImage = 0
	inf->biClrUsed = 0
	inf->biClrImportant = 0

				image.bi.biWidth = LOWORD(lParam);
		image.bi.biHeight = HIWORD(lParam) * Orientation;

;	Create identity palette
	scr = GetDC (HWND_DESKTOP)	;  get desktop DC
				// Get the 20 system colors as PALETTEENTRIES
    GetSystemPaletteEntries(Screen,0,10,LogicalPalette.aEntries);
    GetSystemPaletteEntries(Screen,246,10,LogicalPalette.aEntries + 246);
                
                // Only a few DCs available, free this up so we aren't a hog
				ReleaseDC(0,Screen);

				// Initialize the logical palette and DIB color table
				// Note that we are doing this as double entries. Making
				// sure that we keep both tables -identical- this is to
				// make sure that we can end up with an 'identity palette'
				// which means that both the colortable assigned to the DIB
				// and the palette entries associated with the palette
				// that is selected into the Device Context are identical.

			    for(Counter = 0; Counter < 10; Counter++) {
				// copy the system colors into the DIB header
				// WinG will do this in WinGRecommendDIBFormat,
				// but it may have failed above so do it here anyway

					// The low end colors...				
					image.aColors[Counter].rgbRed =
						LogicalPalette.aEntries[Counter].peRed;
					image.aColors[Counter].rgbGreen =
						LogicalPalette.aEntries[Counter].peGreen;
					image.aColors[Counter].rgbBlue =
						LogicalPalette.aEntries[Counter].peBlue;
					image.aColors[Counter].rgbReserved = 0;
					LogicalPalette.aEntries[Counter].peFlags = 0;
                                            
					// And the high end colors...
					image.aColors[Counter + 246].rgbRed =
						LogicalPalette.aEntries[Counter + 246].peRed;
					image.aColors[Counter + 246].rgbGreen =
						LogicalPalette.aEntries[Counter + 246].peGreen;
					image.aColors[Counter + 246].rgbBlue =
						LogicalPalette.aEntries[Counter + 246].peBlue;
					image.aColors[Counter + 246].rgbReserved = 0;
					LogicalPalette.aEntries[Counter + 246].peFlags = 0;
				}

			    // Now fill in all of the colors in the middle to reflect
			    // the colors that we are wanting. Here, we are just
			    // setting random values.
			    for(Counter = 10;Counter < 246;Counter++) {
					image.aColors[Counter].rgbRed =
						LogicalPalette.aEntries[Counter].peRed = rand()%255;
					image.aColors[Counter].rgbGreen =
						LogicalPalette.aEntries[Counter].peGreen = rand()%255;
					image.aColors[Counter].rgbBlue =
						LogicalPalette.aEntries[Counter].peBlue = rand()%255;
					image.aColors[Counter].rgbReserved = 0;
					// In order for this to be an identity palette, it is
					// important that we not only get this color, but that
					// we get it in THIS location. Using PC_NOCOLLAPSE tells
					// the system not to 'collapse' this entry to another
					// palette entry that already has this color.
					LogicalPalette.aEntries[Counter].peFlags = PC_NOCOLLAPSE;
			    }

			    // The logical palette table is fully initialized.
			    // All we have to do now, is create it.
			    hpalApp = CreatePalette((LOGPALETTE far *)&LogicalPalette);
			    
				//  Create a WinGDC and Bitmap, then select away
#if defined (WIN32)
				hdcImage = CreateCompatibleDC (NULL); // Create a DC compatible with current screen
#else
				hdcImage = WinGCreateDC();
#endif
				image.bi.biWidth = LOWORD(lParam);
				image.bi.biHeight = HIWORD(lParam) * Orientation;

#if defined (WIN32)
hbm = CreateDIBSection (hdcImage, (BITMAPINFO far *)&image.bi, DIB_PAL_COLORS,
 &image.lpvData, NULL, 0);
#else
hbm = WinGCreateBitmap(hdcImage,(BITMAPINFO far *)&image.bi, &image.lpvData);
#endif
				// Make sure that 'biSizeImage' reflects the
				// size of the bitmap data.
				image.bi.biSizeImage = (image.bi.biWidth * image.bi.biHeight);
				image.bi.biSizeImage *= Orientation;
				//  Store the old hbitmap to select back in before deleting
				gbmOldMonoBitmap = (HBITMAP)SelectObject(hdcImage, hbm);
			}

			PatBlt(hdcImage, 0,0,dxClient,dyClient, BLACKNESS);
