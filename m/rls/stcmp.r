file	stcmp - string compare
include	rid:rider
include	rid:stdef

code	st_cmp - compare strings

;	Returns comparison result as -1, 0 or 1
;
;	 1 => mod gt tar
;	 0 => mod eq tar
;	-1 => mod lt tar

  func	st_cmp 
	mod : * char~			; model string
	tar : * char~			; target string
	()  : int			; comparison result
  is	while *mod eq *tar		; are same
	   reply 0 if *tar eq		;  0 => mod eq tar
	   ++mod, ++tar			; more
	end				;  1 => mod gt tar
	reply (*mod gt *tar) ? 1 ?? -1	; -1 => mod lt tar
  end
