header	kidef - keyboard interface (dls:dskbi.m)

	ki_ini	: (void) int
	ki_exi	: (void) int
	ki_mod	: (int)  int
If Dos
	ki_scn	: (void) *far void
Else
	ki_scn	: (void) *void
End
	ki_ctc	: (void) int
	ki_alt	: (void) int

end header
