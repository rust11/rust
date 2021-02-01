file	sttrm - trim whitespace
include rid:rider
include rid:ctdef
include rid:stdef

code	st_trm - trim spaces from both ends of a string

  func	st_trm
	str : * char~			; string to trim
	()  : * char			; past trimmed string
  is	ptr : * char~ = str		; some pointer
	while *ptr ne			; got more
	   quit if not ct_spc (*ptr)	; no more
	   ++ptr			; skipeth spaces
	end				;
	st_mov (ptr, str) if ptr ne str	; take out those at the beginning
	ptr = st_end (str)		; point past string
	while ptr ne str		; got more to check
	   if not ct_spc (*--ptr)	; previous is not a space
	   .. reply ++ptr		; return past string
	.. *ptr = 0			; re-terminate string
	reply ptr			; past end of string
  end
