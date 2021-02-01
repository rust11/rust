file	stext - extract leading string segment
include	rid:rider
include	rid:stdef
include	rid:medef

code	st_ext - extract leading string segment

;	See st_par in stpar for a description of string partition.
;	The string is modified by this operation.
;	Leading/trailing spaces are deleted everywhere.
;	The leading segment, if found, is deleted from the string.

  func	st_ext
	ctl : * char			; control string
	prg : * char			; parse program
	str : * char			; string to parse
	seg : * char			; result segment
	()  : * char			; fine: str, fail: null
  is	pst : * char			; past segment
	*seg = 0			; terminate segment buffer
	st_trm (str)			; clean it up
	pst = st_par (ctl, prg, str)	; get the partition
	pass null			; not found
	me_mov (str, seg, pst-str)	; move it into place 
	*<*char>that = 0		; terminate it
	st_mov (pst, str)		; squash it out
	st_trm (str), st_trm (seg)	; clean both up
	reply str			; past segment
  end
