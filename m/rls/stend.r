file	stend - string end
include	rid:rider
include	rid:stdef

code	st_end - get string end

  func	st_end
	str : * char~			; string pointer
	()  : * char			; pointer to string terminator
  is	spin while *str++		; skip to end
	reply --str			; backup to terminator
  end
