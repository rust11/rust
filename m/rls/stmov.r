file	stmov - move string
include rid:rider
include rid:stdef
include rid:medef

code	st_mov - move string - copy overlapping strings

  func	st_mov
	src : * char~			; source string
	dst : * char~			; destination area
	()  : * char			; points past result destination
  is	st_len (src) + 1		; length of source
	<*char>me_mov (src, dst, that)	; move string and terminator
	reply that - 1			; return pointer to terminator
  end
