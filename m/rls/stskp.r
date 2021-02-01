file	stskp - string skip whitespace
include	rid:rider
include	rid:stdef

code	st_skp - string skip whitespace

  func	st_skp
	str : * Char			; string
	()  : * char			;
  is	while *str eq ' '		; whitestuff
	   || *str eq '\t'		;
	.. ++str			; skip it
	reply str			; send back result
  end
