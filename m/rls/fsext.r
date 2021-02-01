;+++;	FSEXT - Morph into FSENG engine
;	fs_par (fsp, ...)
;	fs_ins (fsp, itm, dst, flg)
;	fsDEV,...,fsDR0, fsDR1, etc
file	fsext - extract file spec components
include	rid:rider
include	rid:fidef
include	rid:fsdef
include rid:stdef

;???;	Should handle Windows versions "... (3)"
;???;	Should handle RSX/VMS [g,m] and [dir.dir.dir]
;
;	fs_ext (spc, dst, flg)
;
;	fsDEV_	the device name		dev:, if any
;	fsDIR_	the directory list	\x\y\z[\]
;	fsNAM_	the file name		name
;	fsTYP_	the file type		.typ
;	fsVER_	the file version	;n
;
;	Multiple fields may be specified:
;
;	fs_ext ("dev:\d\d\d\f.t;v", dst, fsDEV_|fsDIR_)
;	dst = "dev:\d\d\d\"

  func	fs_ext
	src : * char
	dst : * char~
	flg : int~
	()  : int		; length of result field
  is	prv : * char
	beg : * char = dst
	def : int = fsNAM_
	mat : int~
	cha : int

      repeat 
	prv = dst
	repeat
	   quit if (cha = *src) eq
	   *dst++ = *src++
	until st_mem (cha, ":\\.;")
	*dst = 0

	case cha
	of ':'  mat = fsDEV_
	of '\\'	mat = fsDIR_
;	        mat = fsNAM_ if !st_fnd ("\\", src)       
	of '.' 	--dst
		mat = fsNAM_
		def = fsTYP_
	of ';'  --dst
	or 0	if !(flg & def)
		   dst = prv
		elif def eq fsTYP_
		.. st_ins (".", prv), ++dst
		if cha & (flg & fsVER_)
		.. dst = st_cop (src-1, dst) 
		*dst = 0
		reply dst-beg
	end case
	dst = prv if !(flg & mat)	; not wanted, elide
      forever
  end
