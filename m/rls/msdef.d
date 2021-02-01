header	msdef - mouse definitions

  type	msTpos
  is	Vmou : WORD		; mouse detected (button count)
				;
	Vclk : WORD		; clicked (button number)
	Vprs : WORD		; pressed
	Vrel : WORD		; released
	Vdbl : WORD		; doubleclicked
				;
	Vbut : WORD		; button state
	Vcol : int		; current column
	Vrow : int		; current row
				;
	Vobt : int		; old button state
	Vocl : int		; old column
	Vorw : int		; old row
				;
	Vdrg : int		; dragged buttons
	Vhor : int		; horizontal drag
	Vver : int		; vertical drag
				;
	Vhgt : int		; mouse row scaling height
	Vwid : int		; mouse column scaling width
	Vbot : int		; invert row to bottom line
	Vrgt : int		; invert column to rightmost

	Vtim : int		; time counter
  end

	msTIM	:= 300		; time counter

	msLFT_	:= BIT(0)
	msRGT_	:= BIT(1)
	msMID_	:= BIT(2)
	msCTL_	:= BIT(3)
	msSHF_	:= BIT(4)

	msNON	:= 0		; no drag
	msDRG	:= 1		; dragging
	msDRP	:= 2		; dropped

	ms_ini	: (*msTpos) int
	ms_qui	: (*msTpos)
	ms_res	: (*msTpos)
	ms_get	: (*msTpos) void
	ms_set	: (*msTpos, int, int) void
	ms_sho	: (*msTpos) void
	ms_hid	: (*msTpos) void
	ms_clk	: (*msTpos, int) int
	ms_drg	: (*msTpos, int) int

end header
