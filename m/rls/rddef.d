header	rddef - RT-11 directory toolkit
include rid:fidef
include rid:rtdir
include rid:rtbad

  type	rdTseg
  is
	Vtot : WORD		; total segments
	Vsuc : WORD		; next segment
	Vlst : WORD		; last segment in use
	Vext : WORD		; extra bytes per entry
	Vbas : WORD		; start block of first entry
	Aent : [1] rtTent	; array of entries
	Amor : [512-5-(#rtTent/2)] WORD	; entry space
				; -----------------------
	Vend : WORD		; rtEND_ stopper for segment
	Vidx : WORD		; index of this segment
	Pcur : *rtTent		; current entry
	Vavl : WORD		; available unused entries in segment
	Vsiz : WORD		; size of an entry
	Vblk : WORD		; start block of current entry
	Vacc : WORD		; block accumulator (start of next file)
				;
	Vval : WORD		; segment is valid
	Vupd : WORD		; segment needs update

	Verr : WORD		; processor errors

	Pfil : * FILE		; 
	Ppri : * rdTseg		; primary segment
	Psec : * rdTseg		; secondary segment
	Item : rtTent		; template directory entry
  end

  type	rdTdem			; volume demography
  is	Verr : WORD		; directory errors (later)
	Vuse : WORD		; blocks in use
	Vemp : WORD		; empty blocks
	Vsys : WORD		; number of .SYS system files
	Vpro : WORD		; number of protected files
	Vbad : WORD		; number of bad files
  end

	rd_alc : (*rdTseg, *FILE) *rdTseg
	rd_sec : (*rdTseg) *rdTseg
	rd_dlc : (*rdTseg) void
	rd_clr : (*rdTseg) void
	rd_fst : (*rdTseg) *rtTent
	rd_nxt : (*rdTseg, *rtTent) *rtTent
	rd_end : (*rdTseg) *rtTent
	rd_mov : (*rdTseg, *rtTent, *rtTent) void
	rd_tem : (*rdTseg, *rtTent, *char, int) *rtTent
	rd_emp : (*rtTent) void
	rd_suc : (*rdTseg) int
	rd_get : (*rdTseg, int) int
	rd_put : (*rdTseg, int) int
	rd_s2b : (int) int
	rd_sta : (*rdTseg) int
	rd_rep : (*rdTseg, *char) int
	rd_red : (*rdTseg) int
	rd_cal : (*rdTseg) int
	rd_exp : (*rdTseg, *rtTent, int, int) *rtTent
	rd_spl : (*rdTseg, *rtTent) *rtTent
	rd_cre : (*rdTseg, *rtTent, int, int) *rtTent
	rd_ext : (*rdTseg, *rtTent, int) int
	rd_tru : (*rdTseg, *rtTent, int) int
	rd_fnd : (*rdTseg, *WORD) *rtTent
	rd_loc : (*rdTseg, int) *rtTent
;	rd_vol : (*rdTseg, *rdTdem) int
	rd_ini : (*rdTseg, int, int, int, int) int
	rd_sav : (*rdTseg, *WORD) int
	rd_res : (*rdTseg, *WORD, int) int
	rd_det : (*rdTseg) int
	rd_chk : (*void, WORD) int
	rd_blk : (*rdTseg) int
	rd_dem : (*rdTseg, *rdTdem, *bdTbad) int

end header
