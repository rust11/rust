file	st_rem - remove leading substring
include rid:rider
include rid:stdef

;	res = st_rem (mod, tar)
;	
;	mod : * char
;		model string pointer
;	tar : * char
;		target string pointer
;
;	res : * char
;		at start of target if substring removed
;		<> if scan failed to match target

  func	st_rem
	mod : * char			; model
	tar : * char~			; target
	()  : * char			; result
  is	pst : * char~			;
	pst = st_scn (mod, tar)		; attempt to match it
	pass fail			; not present
	st_mov (pst, tar)		; delete it
	reply tar			; found it
  end
