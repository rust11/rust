file	stexc - exchange leading substring
include	rid:rider
include	rid:stdef

code	st_exc - exchange leading substring

  func	st_exc
	rep : * char			; replacement string
	str : * char~			; destination exchange pointer
	cnt : int			; exchange size
	()  : * char			; past insertion
  is	st_mov (str+cnt, str)		; squash them out
	st_ins (rep, str)		; insert remainder
	reply that			; past replacement
  end
