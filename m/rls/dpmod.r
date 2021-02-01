file	dpmod - general directory path routines
include rid:rider
include rid:dpdef
include rid:stdef

code	dp_ter - directory path termination 

;	dev:\a\b\c\f.t ->  dev:\a\b\c[\]

  func	dp_ter
	src : * char
	spc : * char
	opr : int
  is	lst : * char = <>
	ptr : * char = spc

	st_cop (src, spc)		; spc must have space for terminator
	lst = st_lst (spc)		; last character

	if *lst ne '\\'			;
	   fail if opr & dpMHT_		; must have terminator
	   if opr & dpADT_		; add terminator
	      fail if !*lst++		; must be non-null
	      lst[0] = '\\'		; add terminator
	   .. lst[1] = 0		; assume space available
	else				;
	.. *lst = 0 if opr & dpRMT_	; remove terminator
	fine
  end
code	dp_rsx - convert RSX spec

;	[a.b.c] -> \a\b\c\
; ???	[n,n] -> [00n00n]

  func	dp_rsx
	src : * char
	spc : * char~
  is	ptr : * char~ = spc

	st_cop (src, spc)

	while *ptr ne '['		; need [
	   fine if !*ptr++		; is none
	end				; nothing to dod

	*ptr++ = '\\'			; [a.a] -> \a.a]\
	repeat				;
	   case *ptr			; 
	   of 0    fail			; [... - no ], fail
	   of '.'  *ptr eq '\\'		; \a.b] -> [a\b] 
	   of ']'  *ptr = '\\'		; \a\b] -> \a\b\
	   	   fine			;
	   end case			;
	   ++ptr
	forever
	fine
  end
