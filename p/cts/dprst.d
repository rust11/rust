header	dprst - directory path RUST/RSX statics
include	rid:mxdef
include	rid:rtdev
include	rid:rtdir
include	rid:rttim
include	rid:sbdef
include	rid:skdef
include	rid:tidef

;	dprst.d - rust/rsx
;	dpwin.d - windows
;	dpdef.d	- generic

   type	dpTctl : int

	dpNAM  := 14		; filnametc.typ\0
	dpSRT  := 12		; sort program size

  type	dpTatr : char		; object attributes
;	file type offset
	dpSUB_ := BIT(0)	; sub-directory
	dpPER_ := BIT(1)	; permanent
	dpDEL_ := BIT(2)	; deleted
	dpEMP_ := BIT(3)	; empty (directory?)
	dpTEN_ := BIT(4)	; tentative
	dpSYS_ := BIT(5)	; system file
	dpVOL_ := BIT(6)	; volume label
	dpBAD_ := BIT(7)	; bad blocks
	dpANC_ := BIT(8)	; ?
	dpALL_ := -1

  type	dpTlen : long		; handle long files
  type	dpTpos : long		; file position
  type	dpTtyp : int		; type flags

  type	dpTnam			; file name
  is	Vatr : dpTatr		; file attributes
	Anam : [dpNAM] char	; file name
	Vver : WORD		; file version
;	Iidx : dpTidx		; F11A index
  end

  type	dpTflt			; filter
  is	Vflg : int		; filter flags
	Vtyp : dpTtyp		; type flags
	Ibef : ntTval		; before
	Iaft : ntTval		; after
	Itim : ntTval		; time
	Vmin : dpTlen		; minimum size
	Vmax : dpTlen		; maximum size
	Vpos : dpTpos		; block positon
	Asel : [6] dpTnam	; selected
	Pexc : [6] dpTnam	; excluded
  end

  type	dpTsta
  is	Vtot : long		; total bytes
	Vuse : long		; bytes used
	Vfil : size		; files
	Vemp : size		; empties
	Vdel : size		; deleted
	Vten : size		; tentative
	Lidx : size		; index file size in blocks
	Vidx : size		; index blocks in use
  end

  type	dpTsrt
  is	Aprg : [dpSRT] char	; sort program
  end
	dpEND := 0		; also used for NOSORT
	dpFIL := 1
	dpTYP := 2
	dpVER := 3
	dpLEN := 4
	dpTIM := 5
	dpUIC := 6
	dpPRO := 7
	dpORG := 8
	dpREV := 10		; reverses sort

  type	dpTpth
  is	Vacp : int		; path ACP
	Aspc : [mxSPC] char	; full incoming spec (messages)
	Aroo : [mxPTH] char	; directory path root
	Apth : [mxPTH] char	; current path
	Psto : * sbTsto		; entry store
	Pstk : * skTstk		; entry stack
	Igra : dpTsta		; grand-total
	Ista : dpTsta		; statistics
	Hfil : * FILE		; directory file
	Idst : rtTdst		; device status
	Iscn : rtTscn		; RT-11 scan block
	Ient : rtTent		; RT-11 directory entry
	Iflt : dpTflt		; filters
	Isrt : dpTsrt		; sort
	Vtop : int		; do top-level directories
	Vsub : int		; do sub-directories
  end

	dpRTA := 1		; ACPs
	dpRSX := 2		;
	dpWIN := 3		;

  type	dpTobj
  is	Vatr : dpTatr	    ;2	;
	Anam : [dpNAM] char ;14	; file name
;	Vtyp : int	    ;1  ; offset to file type (for sort)
	Vver : WORD	    ;2	; file version
;	Iidx : dpTidx	    ;	; F11A index
	Vlen : dpTlen	    ;4	; file length
	Itim : ntTval	    ;8	; file time
	Vuic : WORD	    ;2	; file uic
	Vpro : WORD	    ;2	; file protection
  end			    ;34 ; 30 per kiloword

; 1442 => 49k = 191 blocks (use VM:)

  type	dpTent
  is	Vatr : dpTatr		; attributes
	Anam : [dpNAM] char	; file name
	Valc : dpTlen		; size to allocate
  end

;	dpSYS_
;	dpEMP_
;

end header
