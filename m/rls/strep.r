file	strep - replace substring
include	rid:rider
include	rid:stdef

code	st_rep - replace string if found

  func	st_rep
	mod : * char			; model string
	rep : * char			; replacement string
	str : * char			; edit string
	()  : * char			; past replacement or <>
					; at replacement if rep eq <>
  is	pnt : * char			; pointer
	pnt = st_fnd (mod, str)		; locate the model
	pass <>				; not found
	reply pnt if rep eq <>		; just want to find it
	st_exc (rep, pnt, st_len (mod))	; replace it
	reply that			; past replacement
  end
