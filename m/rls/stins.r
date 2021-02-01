file	stins - insert string
include rid:rider
include rid:stdef
include rid:medef

code	st_ins - insert string

;	st_ins ("this", "that") => "thisthat"
;
;	Insert string may not overlap destination string

  func	st_ins
	ins : * char			; insert string
	dst : * char~			; destination string
	()  : * char			; past insert
  is	len : int~ ;= st_len (ins)	; size of insert
	len = st_len (ins)
	st_mov (dst, dst+len)		; move it up
	me_cop (ins, dst, len)		; insert it
	reply <*char>that		; send it back
  end
