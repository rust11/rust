header	bmdef - bitmaps
include	rid:wcdef

	bmMON	:= 1			; mono => 2-colour
	bmPAL	:= 2			; palette => 256 colours
	bmRGB	:= 3			; RGB => 24-bit colours

  type	bmTbmp
  is	Vtyp : int			; type (above)
	Vwid : size			; width (in pixels)
	Vhgt : size			; height (in pixels)
;	Vbrd : size			;
	Vtot : size			; total (in bytes)
	Pdat : *void			; la data
	Hhan : *void			; le handle
  end

	bm_alc : (*bmTbmp, int, int, int) *bmTbmp
	bm_dlc : (*bmTbmp) void
	bm_tot : (int, int, int) int
	bm_fil : (*bmTbmp, int, int, int, int, int)
	bm_adr : (*bmTbmp, int, int, *int, *int) *void

	bm_cre : (*BYTE, int, int) *bmTbmp
	bm_pnt : (*wsTevt, *bmTbmp, int, int) int
	bm_imp : (*void, *bmTbmp) int		; import bitmap
	bm_gly : (int, *bmTbmp)			; get bmp of char. glyph

	bm_loa : (*char, *char) *bmTbmp
	bm_sto : (*bmTbmp, *char, *char) int

end header
