file	fndef - new font definitions

;	font collection		all app. fonts and sizes
;	  font sizes		lookup
;	  font group		typeface and size
;	    font renditions	rendition


	fnITA_ := BIT(5)	; inverse (italic)
	fnBOL_ := BIT(6)	; bold character
	fnUND_ := BIT(7)	; underline
	fnNOR_ := 0		; normal
	fnMren := (fnBOL_|fnUND_|fnITA_) ; rendition

  type	fnTgrp : forward
  type	fnTsiz : forward
  type	fnTfnt : forward
; type	fnTgly : forward

  type	fnTcol
  is	Pgrp : * fnTgrp		; font xgroups
	Psiz : * fnTsiz		; font sizes
	Pcur : * fnTfnt		; current font
  end

  type	fnTgrp
  is	Psuc : * fnTgrp		; next group
	Pcol : * fnTcol		; uplink to collection
	Pnam : * char		; font name
	Vsiz : int		; font size
	Aren : [8] * fnTfnt	; rendition font array
  end

  type	fnTsiz
  is	Psuc : * fnTsiz		; next size
	Vsiz : int		; font size
	Vhgt : int		; font height
	Vwid : int		; font width
  end

  type	fnTfnt
  is	Pgrp : * fnTgrp		; uplink to group
	Vren : int		; rendition
	Hdev : * void		; windows device handle
	Hfnt : * void		; windows font handle
	Vver : int		; max height
	Vasc : int		; ascent
	Vdes : int		; descent
	Vhor : int		; max width
  end

	fn_col : (void) * fnTcol
	fn_reg : (*fnTcol, int, int, int) bool
	fn_siz : (*fnTcol, int) *fnTsiz
	fn_grp : (*fnTcol, *char, int) * fnTgrp
	fn_clr : (*fnTcol) void
	fn_map : (*void, *fnTgrp, int) bool
	fn_fnt : (*void, *fnTgrp, int) * fnTfnt
	fn_sel : (*void, *fnTfnt) bool
	fn_alc : (void) *fnTfnt
	fn_dlc : (*fnTfnt) void
