header	ridef - rider data
include	rid:rider

  type	riTlin 
  is	Atxt : [256] char		; text area
	Asrc : [256] char		; text area
;	Alab : [128] char		; labels etc
	Pbod : * char			; pointer to body
	Vbal : int			; () balance
	Veof : char			; end of file
	Vnul : char			; null line count
	Vis  : char			; is at start of line
	Vbeg : char			; { at end of line
	Vend : char			; } at end of line
	Vcnd : char			; conditional flag
	Vcon : char			; continuation line (... ,)
	Vext : char			; extension line ( opr ...)
	Vwas : char			; has "was"
  end
	riLlin := sizeof (riTlin)	; the size of it

	riPcur : * riTlin extern	; current line
	riPnxt : * riTlin extern	; next line

	riVcod : char extern		; in code
	riVcnd : char extern		; conditional coming
	riVcon : char extern		; continuation coming
	riVsup : char extern		; don't write line out
	riVsup : char extern		; inhibit all output
	riVinh : char extern		; inhibit all output
	riVis  : char extern		; { ... count
	riVend : char extern		; ... } count
	riVwas : char extern		; ... } count
	riVnst : char extern		; nesting level
	riVhdr : char extern		; header level
	riAseg : [64] char extern	; segment name
	riVini : char extern		; doing initializers 
	riVfil : int extern		; seen 'file' (ri_cas)
	riVpre : int extern		; in preprocessor conditional

	quFdec : int extern		; DEC filenames
	quFdos : int extern		; DOS filenames
	quFunx : int extern		; Unix filenames
	quFver : int extern		; verify input
	quFlin : int extern		; line numbers

	riPswd	: *char extern		; ridat
	riPuwd	: *char extern
	riPsop	: *char extern
	riAver	: [] char extern
	riVdbg	: int  extern		; debug

  type	riTkwd	: (void) void

	ri_get	: (void) int		; ribuf
	ri_beg	: riTkwd		;
	ri_end	: riTkwd		;
	ri_orf	: (int) void		; ricas
;	ri_def	: (*char, char) void	; ridef
	ri_enm	: riTkwd		; rienu
	ri_par	: (void) void		; ripar
	ri_cnd	: (*char, *char) void	;

	ri_put	: (void) void		; riput
	ri_idn	: (int) void
	ri_prt	: (*char) void
	ri_new	: (void) void
	ri_dis	: (*char) void
If Win
If !&RIFMT
	ri_fmt	: (*char, ...) void
End
Else
	ri_fmt	: () void
End

	ri_typ	: (*char, *char) int	; rityp
	ri_kon	: riTkwd		;
	ri_siz	: riTkwd		;
	ri_bit	: riTkwd		;
	ri_cst	: (*char) int		;

	ut_idt	: (*char, *char) *char	; riutl
	ut_tok	: (*char, *char) *char
	ut_seg	: (*char, *char) void

	pp_if	: riTkwd
	pp_elf	: riTkwd
	pp_els	: riTkwd
	pp_end	: riTkwd
	pp_fix	: riTkwd

end header
