header	fsdef - file spec operations
include	rid:mxdef

; ???	Different to CTS:
; ???	99% redundant
; ???	Only RENAME in USCOP.R uses most of this stuff

  type	fnTfnb
  is	Vflg : int		; flags
	Vdef : int		; defaulted
	Vprs : int		; present
	Vwld : int		; wild (fully wild)
	Vmix : int		; part wild/part not wild
	Vinv : int		; invalid
	Vcla : int		; class
	Aspc : [mxSPC] char	; full filespec
	Anod : [mxNOD] char	; node
	Adev : [mxDEV] char	; device
	Adir : [mxDIR] char	; directory	
	Anam : [mxNAM] char	; filename
	Atyp : [mxTYP] char	; filetype
	Aver : [mxVER] char	; version
  end

;	flags

	fsDEF_	:= BIT(15)	; apply system defaults
	fsWLD_	:= BIT(14)	; permit wildcards
	fsRIG_	:= BIT(13)	; rigorous
	fsCAC_	:= BIT(12)	; cache known names
	fsERR_	:= BIT(10)	; abort on errors
				;
;	default/present/wild/invalid flags

	fsNOD_	:= BIT(0)	; def prs wld inv
	fsDEV_	:= BIT(1)	;
	fsDIR_	:= BIT(2)	;
	fsPTH_ := (fiDEV_|fiDIR_)
	fsNAM_	:= BIT(3)	; was fsFIL_
	fsTYP_	:= BIT(4)	;
	fsFIL_ := (fiNAM_|fiTYP_)
	fsVER_	:= BIT(5)	;

;	fsREM_	:= BIT(8)	; is remote
;	fsLOG_	:= BIT(9)	; is logical
;	fsPTH_	:= BIT()	; is logical path 
;	fsPER_	:= BIT(10)	; is peripheral
;	fsCON_	:= BIT(11)	; is console
				;
	fsINV	:= 0		; invalid, missing or incomplete
	fsUNK	:= 1		; unknown, unidentified
	fsPER	:= 2		; peripheral
	fsNOD	:= 3		; node name
	fsDRV	:= 4		; drive name
	fsDEV	:= fsDRV	;
	fsROO	:= 5		; root directory
	fsLAB	:= 6		; volume label
	fsDIR	:= 7		; subdirectory
	fsFAM	:= 8		; family of subdirectories
	fsFIL	:= 9		; filespec
	fsWLD	:= 10		; wildcard spec
	fsMAX	:= 11		;
				;
	fsNAM	:= 12		; file name
	fsTYP	:= 13		; file type
	fsVER	:= 14		; file version

data	prototypes

;	spec operations

	fs_def	: (*char, *char, *char) int	; apply defaults
	fs_ass  : (int, *char, *char)		; assemble parts

	fs_sen	: (*char, *char) int		; sense device/dir/file
	fs_roo	: (*char) int			; test for root
	fs_nor	: (*char, *char) int		; normalize spec
	fs_cat	: (*char) int			; get spec category
	fs_cla	: (*char) int			; get spec class
						;
;	old definition
;	fs_res	: (*char, *char, *char, *char, int) int ; parse result spec
	fs_res	: (*char, *char, *char) int ; parse result spec
	fs_dev	: (*char, *char) *char		; get device part
	fs_dir	: (*char, *char) *char		; get directory part
	fs_nam	: (*char, *char) *char		; get name part
	fs_typ	: (*char, *char) *char		; get type part
						;
	fs_get	: (int, *char, *char) int	; get spec element
	fs_clr	: (int, *char, *char) int	; clear spec element
	fs_set	: (int, *char, *char, *char) int; set spec element
						;
	fs_tdr	: (*char) void			; to directory spec
	fs_fdr	: (*char) void			; from directory spec

;	FNB exploded operations

	fn_def	: (*fnTfnb, *fnTfnb, *char, *char, *char) int
	fn_sen	: (*fnTfnb, *char, *char) int	; sense
	fn_nor	: (*fnTfnb, *char, *char) int	; normalize
	fn_exp	: (*fnTfnb, *char) int		; explode 
	fn_red	: (*fnTfnb) int			; reduce (dots etc)
	fn_imp	: (*fnTfnb, *char) *char	; implode
	fn_mrg	: (*fnTfnb, *fnTfnb) int	; merge two specs
	fn_clr	: (*fnTfnb) void		; clear spec

	fsAcla : [fsMAX] *char	extern		; class table

data	separate filespec approach

	fs_ext	: (*char, *char, int) int	; extract spec component

end header
