header	sdmod - SRCDIF definitions
include	rid:rider
include rid:fidef
include rid:fsdef
include	rid:imdef
include	rid:rtcsi
include	rid:rtdir

;	Each line is represented by a 3-word type.
;	Typically, 2000+ lines are available for each side

  type	sdTlin
  is	Vflg : WORD		; flags & high order position
	Vpos : WORD		; low order file position
	Vhsh : WORD		; hash code
  end
				; Vflg
	sdHOP_ := 0000777	; high order file position
	sdLEN_ := 0077000	; line length mod 64 (not implemented)
	sdLEN  := 9		; left-shift count for sdLEN_
	sdEOF_ := 0100000	; end of file marker
	sdMAX  := 132		; maximum line size
				;
	sd_eof(lin) := (lin->Vflg & sdEOF_)

  type	sdTsid
  is	Pcur : * sdTlin		; current line (first for compiler optimisation)
	Pbas : * sdTlin		; buffer base
	Pipt : * sdTlin		; file input pointer
	Pfst : * sdTlin		; first stored line
	Pmat : * sdTlin		; most recent match
	Plea : * sdTlin		; leading line
	Plim : * sdTlin		; buffer limit line
				;
				; file
	Pspc : * char		; spec
	Hfil : * FILE		; file handle
	Pmod : * char		; side model spec
	Icla : fsTcla		; filespec class
	Vipt : long		; input file position
;	Vdis : long		; display file position
				;
				; input line
	Vpos : long		; file position of line below
	Alin : [sdMAX] char	; raw line
	Ared : [sdMAX] char	; reduced line
				;
				; display
	Vsid : int		; 0 or 1
	Vpag : int		; page number
	Vlin : int		; line number
	Vdon : int		; display take done
	Vtak : int		; number to output
  end

  type	sdTopt
  is	Pspc : * char		; terminal if null
	Pfil : * FILE		; file
	Iext : fxText		; extension block for allocation
  end

  type	sdTctl
  is	Vmin : int		; minimum match
	Vlim : int		; maximum differences
				;
	Vblk : int		; match blank lines
	Vcas : int		; match case
	Vchg : int		; change-bar style
	Vcmt : int		; comment character (if any)
	Vedi : int		; edited text output
	Vexa : int		; exact
	Vfrm : int		; formfeed output
	Vlog : int		; log report
	Vmis : int		; verify missing files
	Vmax : int		; maximum differences
	Vopt : int		; 0=all, rxDIF, rxSAM
	Vspc : int		; match spaces
	Veig : int		; eight-bit compare
	Vver : int		; verify scanning choices
	Vwid : int		; width
	Vins : int		; insert character
	Vdel : int		; delete character
	Vnum : int		; line numbers
	Vmrg : int		; merged listing
	Vtra : int		; trailing merged lines to display
	Vpar : int		; parallel listing
	Vwin : int		; window size
				;
	Vtrm : int		; trim lines (has /slp impact)
	Vaud : int		; audittrail (/slp)
				;
	Vdis : int		; display type
	Vhdr : int		; header pending
	Vdif : int		; difference count
	Vsec : int		; difference sections count
	Vtot : int		; total differences
 	Vabt : int 		; abort pass
	Vovr : int		; overflow -- too many differences
	Vnew : int		; new-style output
	Vonl : int		; differences only, same only
	Vsta : int		; same-difference status
				;
	Aaud : [14] char	; audit trail
	Pscn : * rtTscn		; directory scan
				;
	Vfst : int		; set first
 end
				; Vdis - display type
	sdNOP := 0		; no output
	sdMRG := 1		; merged listing
	sdCHG := 2		; changebar listing
	sdPAR := 3		; parallel listing
				; parallel changebar 

				; Vsta - output states
	sdUND := 0		; undefined
	sdSAM := 1		; same 
	sdDIF := 2		; different

				; display driver tasks
	sdINI := 0		; init display
	sdHDR := 1		; display header
	sdLOG := 2		; terminal log header
	sdMAT := 3		; display match section
	sdMIS := 4		; display missmatch section
	sdMIX := 5		; matching items at difference section end
	sdFIN := 6		; finish display
	sdDIV := 7		; output divider

	sdNON := 0		; sd_eof ()
	sdONE := 1
	sdBTH := 2 

	lft : sdTsid+
	rgt : sdTsid+
	ctl : sdTctl+
	csi : csTcsi+
	opt : sdTopt+

	sdPscn : * rtTscn+

	sd_tak : (*sdTsid, int) *char

end header
