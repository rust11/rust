header	vwdef - vwin32 operations
include	rid:rider

  type	vwTreg
  is	Vebx : LONG
	Vedx : LONG
	Vecx : LONG
	Veax : LONG
	Vedi : LONG
	Vesi : LONG
	Vflg : LONG
  end

	vw_dio : (*vwTreg, LONG, LONG, LONG, LONG, LONG, LONG) int
end header
