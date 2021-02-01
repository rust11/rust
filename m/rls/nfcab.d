header	nfcab - network channel access blocks
include	rid:fidef
include rid:nfdef

  type	cabTrep			; replacement blocks
  is	Psuc : * cabTrep	; successor
	Vblk : int		; block number
	Vcnt : int		; byte count
	Abuf : [512] char	; segment data
  end
	cabRTA := 1		; RT11A directory
	cabVMS := 2		; F11B directory

  type	cabTsav
  is	Vblk : int
	Vlen : int
  end

  type	cabTcab			; channel access block
  is	Psuc : * cabTcab	; successor (on free list only)
	Vtyp : int		; see below
	Vflg : int		; see below
	Vchn : int		; jcn - the channel number
	Vseq : int		; the sequence number
	Vhgh : int		; highest written 
	Vlen : int		; file length
	Vnod : int		; sid - satellite id
	Vprc : int		; sjn - satellite job number
	Vimg : int 		; internal image sequence
				;
	Vcid : int		; CID version of sequence number
	Vblk : int		; block offset from sequence #
				;
	Pchn : * void	;rtTchn	; channel pointer
	Pfil : * FILE		; associated file
	Pvol : * FILE		; volume file
	Vbas : int		; base block of volume file
	Prep : * cabTrep	; replacement blocks
	Aspc : [82] char	; final file spec
	Atmp : [82] char	; temporary file spec
	Asrc : [6] BYTE		; station address
	Vver : int		; file spec version number
	Plnk : * cabTcab	; linked cab list
	Isav : cabTsav		; saved stuff across walk
	Vinf : int		; saves Vblk across nf_wlk for nf_inf
  end
				; type
	cabFRE := 0		; free
	cabLOO := 1		; lookup type
	cabENT := 2		; enter type
	cabREP := 3		; replacement data type
	cabDEV := 4		; open as device
	cabWLK := 5		; directory walk
				; flags
	cabRON_ := BIT(0)	; read-only flag
	cabVAX_ := BIT(1)	; VAX directory
	cabRTA_ := BIT(2)	; RT-11 directory
	cabDIR_ := BIT(3)	; directory cab (always RON)
	cabDSK_ := BIT(4)	; disk I/O (i.e. boot I/O)
	cabPER_ := BIT(5)	; permanent cab
	cabTMP_ := BIT(6)	; temp file, delete on last close
	cabATT_ := BIT(7)	; cab is attached to file

;	external  1 vvs sss sss sss ---

	cabFST := 010000	; sequence number flag
	cabMAX := 1020		; maximum sequence number
	cabBOO := 1020		; BOOT cab
	cabSHO := 1023		; 
	cabSHF := 3		; sequence number shift
	cabMSK_ := ~(7)		; sequence number negative

	cabIRS := 1		; image reset (keep overlay channel)
	cabPRS := 2		; process reset
	cabNRS := 3		; node reset

  type	cabTnod
  is	Psuc : * cabTnod	;
	Pcab : ** cabTcab	; cab array for this node
	Vseq : int		; 
	Vtyp : int		; node type
	Asta : [6] char		; station address of node
  end

	cabVact : int+		; cabs active

	cab_cre : (*nfTvab, *FILE, *char, int, int) *cabTcab
	cab_eli : (*nfTvab, int) void
	cab_res : (int) void
	cab_map : (int) *cabTcab
	cab_opn : (int) *cabTcab
	cab_acc : (*char) *FILE
 	cab_clo : (int) int
	cab_pur : (int) int
	cab_del : (*char)
	cab_ren : (*char, *char)
	cab_ext	: (int, long) int
	cab_unm : (*nfTvab, *char) int
	cab_rep : (*cabTcab, *void, int, int) void
	cab_rea : (*cabTcab, *void, int, int) int
	cab_wri : (*cabTcab, *void, int, int) int
	cab_loc : (*cabTcab, int) *cabTrep
	cab_ten : (*char, *char, *char) void
	cab_dlc : (*cabTcab, int) void
	cab_rpt : (void) void
	tmp_hng : (*char) int

end header
