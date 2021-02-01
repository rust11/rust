file	st_scn - scan leading substring
include rid:rider
include rid:stdef

;	res = st_scn (mod, tar)
;	
;	mod : * char
;		model string pointer
;	tar : * char
;		target string pointer
;
;	res : * char
;		past scanned substring
;		NULL if scan failed to match target

  func	st_scn
	mod : * char~			; model
	tar : * char~			; target
	()  : * char			; result
  is	while *mod ne			; got more
	   reply <> if *mod ne *tar	; different
	.. ++mod, ++tar			; next
	reply tar			; success
  end
