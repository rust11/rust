file	st_chg - change leading substring
include rid:rider
include rid:stdef

code	st_chg - change leading substring

  func	st_chg
	mod : * char			; model string 
	rep : * char			; replacement string
	tar : * char			; target target string
	()  : * char			; past replaced string in target
					; null if match failed
  is	st_rem (mod, tar)		; match and remove 
	pass null			; no match
	st_ins (rep, tar)		; insert replacement
	reply that			; past replacement
  end
