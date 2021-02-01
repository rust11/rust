file	clmat - match keyword with abbreviation
include	rid:rider
include	rid:cldef
include	rid:chdef

code	cl_mat - match keyword with abbreviation

  func	cl_mat
	str : * char~			; string (exit, exi, ex)
	pat : * char~			; keyword pattern (ex*it)
	()  : int			; fine => match
  is	abb : int~ = 0			; abbreviation seen
	fine if *pat eq '*' && pat[1] eq; pattern "*" matchs anything
	fine if *pat eq && *str eq	; empty pattern matchs empty string
     repeat				;
	next ++abb, ++pat if *pat eq '*'; skip and mark abbreviation
	if *str eq			; end of string
	   fine if *pat eq		; exact match
	.. reply abb			; otherwise abbreviation state
	ch_low (*pat) ne ch_low (*str)	; compare them
	fail if ne			; different things
	++pat, ++str			; skip both
     forever				;
  end
