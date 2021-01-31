header	fsdef - file spec operations


	fsNOD_	:= BIT(0)		; def prs wld inv
	fsDEV_	:= BIT(1)		;
	fsDIR_	:= BIT(2)		;
	fsPTH_	:= (fsDEV_|fsDIR_)	;
	fsNAM_	:= BIT(3)		; was fsFIL_
	fsTYP_	:= BIT(4)		;
	fsFIL_	:= (fsNAM_|fsTYP_)	;
	fsVER_	:= BIT(5)		;

	fs_ext	: (*char,*char,int) int	; extract spec component

data	file classes

  type	fsTcla
  is	Vnod : char
	Vdev : char
	Vdir : char
	Vnam : char
	Vtyp : char
	Vver : char

	Vblk : char
	Vwld : char
	Vmix : char
	Vany : char
  end

	fsBLK_ := BIT(0)		; blank/missing
	fsWLD_ := BIT(1)		; wildcards
	fsMIX_ := BIT(2)		; mixed wild/characters
	fsANY_ := BIT(3)		; just "*"s

	fs_cla : (*char, *fsTcla) int	; interpret file class

end header
