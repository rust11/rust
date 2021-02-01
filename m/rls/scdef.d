header	scdef - screen library

  type	scTval : int

  type	scTrec 
  is	x   : scTval
	y   : scTval
	w   : scTval
	h   : scTval
  end
	scTscr : forward
	scTfun : (*scTscr) int

  type	scTscr
  is	Psuc : * scTscr	; next screen
	Vidt : int	; screen ident
	Vtyp : int	; screen type
	Iscr : scTrec	; full screen
	Iwin : scTrec	; screen window
	Ireg : scTreg	; window region
	Icur : scTreg	; current position
			;
	Pdrv : scTfun	; driver
	Pcal : scTfun	; callback routine
			;
	Vopr : int	; operation
	Iopr : scTreg	; operation position
	P1   : * <>	; output data
	V1   : scTval	; operation count etc
  end

	scINI. = 1	; initialize screen
	scGET. = 2	; get screen characteristics
	scSET. = 3	; set screen characteristics
	scLIM. = 4	; set screen limits
	scPOS. = 5	; set screen position
	scSCR. = 6	; scroll screen
	scOPT. = 7	; output

	sc_ini : (scTscr) * scTscr
	sc_alc : () * scTalc
	sc_dlc : (*scTalc) 
	sc_drv : (*scTscr, int) int
  type	scTdrv : (*scTscr) int

end header
