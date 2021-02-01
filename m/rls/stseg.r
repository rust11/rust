file	stseg - extract leading string segment
include	rid:rider
include	rid:stdef
include	rid:medef

code	st_seg - extract leading string segment

;	See st_par in stpar for a description of string partition.
;	Prefix the control string with 'S' to skip spaces before the
;	partition operation. This affects the failure 'b' address as well.

  func	st_seg
	ctl : * char~
	prg : * char
	str : * char
	seg : * char~
	()  : * char
  is	pst : * char~			; past segment
	*seg = 0			; terminate segment buffer
	if *ctl eq 'S'			; skip leading spaces?
	 .. ++ctl, str = st_skp (str)	; yep
	pst = st_par (ctl, prg, str)	; get the partition
	pass null			; not found
	me_mov (str, seg, pst-str)	; move it into place 
	*<*char>that = 0		; terminate it
	reply pst			; past segment
  end
