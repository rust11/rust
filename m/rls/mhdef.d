header	mhdef - mosh definitions
include rid:dfdef

	mhEXP := 1024		; expansion buffer
	mhWRK := 1024		; work buffer
	mhRES := 1024		; result buffer
	mhIPT := 6		; up to six nested input files

  type	mhTpit : forward

  type	mhTget : (*mhTpit, *char) int ; get character routine
  type	mhTput : (*mhTpit, int)	int ; put character routine
				;
  type	mhTipt			; input file
  is	Pspc : * char		; script name
	Pfil : * FILE		; script file
  end

  type	mhTpit			; mosh pit
  is	P1   : * void		; caller usage
	P2   : * void		;
	V1   : int		;
	V2   : int		;
				;
	Pipt : * mhTipt		; current input file/spec
	Vidx : int		; current input index
	Aipt : [mhIPT] mhTipt	; input objects
				;
	Popt : * char		; output spec
	Hopt : * FILE		; output file
				;
	Pget : *(*mhTpit,*char) int ; get routine
	Pput : *(*mhTpit,int) int   ; put routine
				;
	Pexp : * char		; expansion stack buffer
	Vptr : int		; current expansion stack pointer
	Vtop : int		; stack pointer maximum
				;
	Pwrk : * char		; work buffer
	Pres : * char		; result buffer
	Pdef : * dfTctx		; definitions
				;
	Vpnd : int		; number of pending blank lines
	Vinh : int		; number of blank lines to inhibit
				;
	Vsol : int		; 1 => start of line
	Vexi : int		; time to quit
				;
	Vprv : int		; previous character
	Vcur : int 		; current character
	Vlin : int		; current source line number
				;
	Fmet : int		; show metas
	Fver : int		; verify input
  end

	mh_alc : (*char) *mhTpit
	mh_dlc : (*mhTpit)
	mh_par : (*mhTpit) int
	mh_ipt : (*mhTpit, *char) int
	mh_opt : (*mhTpit, *char) int

end header
