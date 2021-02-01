header	ftdef
include	rid:wcdef
include	rid:bmdef

	ftMAX := 64*64		; max char size
	ftTRA := 0		; transparent
	ftPAP := 1		; paper
	ftINK := 2		; ink

  type	ftTfnt
  is	Hdev : * void
	Hfnt : * void
	Hold : * void
	Vhgt : int		; max height
	Vasc : int		; ascent
	Vdes : int		; descent
	Vwid : int		; max width
	Anam : [32] char	; font name
	Ldat : int		;
	Pdat : * char		;
	Agly : [ftMAX/8] char	; glyph data
	Ibmp : bmTbmp		; return bitmap
	Abmp : [ftMAX] char	; bmp data
	Vcha : int		; characteristics
	Vcur : int		; current rendition
	Aren : [8] * void	; rendition cache
  end

data	font characteristics

	ftITA_ := BIT(5)	; inverse (italic)
	ftBOL_ := BIT(6)	; bold character
	ftUND_ := BIT(7)	; underline
	ftNOR_ := 0		; normal
	ftMren := (ftBOL_|ftUND_|ftITA_) ; rendition
	ftFIX_ := BIT(8)	; fixed width
	ftDOS_ := BIT(9)	; DOS character set
	ftSYM_ := BIT(10)	; symbol character set

	ft_alc : () *ftTfnt
	ft_dlc : (*ftTfnt) int
	ft_map : (*ftTfnt) int
	ft_rel : (*ftTfnt)
	ft_sel : (*ftTfnt, wsTdev) int
	ft_uns : (*ftTfnt, wsTdev)
	ft_gly : (*ftTfnt, int) int

end header
