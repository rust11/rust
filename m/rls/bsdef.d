header	bsdef - Bitmap sections
If wsSVR 

	bsTinf := BITMAPINFOHEADER
  type	bsTsec
  is	Vhgt : int		; section height in pixels
	Vwid : int		; section width in pixels
	Pbuf : * void		; data area
	Vext : int		; width extent after rounding up
				;
	Vini : int		; inited, must cleanup on exit
	Vwng : int		; WinG enabled
	Vori : int		; WinG orientation
				;
;	BITMAPINFO structure	;\<*BITMAPINFO>&sec.Sinf
	Sinf : bsTinf		;|bitmap info header. 
	Argb : [256] RGBQUAD	;/RGB array
				;
	Hidc : HDC 		; image DC handle
	Hpre : HBITMAP		; predecessor bitmap, for restore
	Hpal : HPALETTE		; palette handle
 	Ppal : * LOGPALETTE	; palette structure
  end

Else
	bsTsec	:= void		; just a pointer for client
End

	bs_alc	: (*wsTevt,*bsTsec,int,int) *bsTsec ; alloc bitmap section
					; also handles reallocate
	bs_dlc	: (*wsTevt,*bsTsec) void; deallocate and free up
	bs_blt	: (*wsTevt, *bsTsec) 	; blit the section

	bs_scn	: (*bsTsec, int) *void	; get start of nth scanline
	bs_dim	: (*bsTsec, *int, *int) ; get width & height

	bs_beg	: (*wsTevt, *bsTsec)	; begin paint (replaces gr_beg)
	bs_end	: (*wsTevt, *bsTsec)	; end paint

end header
