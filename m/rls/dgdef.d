header	dgdef - dialog client definitions

  type	dgTdlg
  is	Vtyp : int
	Vcod : int
	Pdat : *void
	Vval : long
  end

	dg_opn	: (*char, *char, *char, int) int	; open file
	dg_fnt	: (*wsTevt, *wsTfnt) int		; get font

	dg_beg	: (*wsTevt, int, int) * dgTdlg		; begin async
	dg_end	: (*wsTevt, *dgTdlg)			; end async
	dgDRG	:= 1					; drag/drop dialogue
	dg_drg	: (*wsTevt, *dgTdlg, int, *char) int	; nth dropped file

	dg_fnd	: (*wsTevt, *char, *char, int) int	; find dialogue
	dgNXT	:= 2
	dgREP	:= 3
	dgALL	:= 4
	dgTER	:= 5

end header
