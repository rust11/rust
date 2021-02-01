file	stlen - string length
include	rid:rider
include	rid:stdef

code	st_len - get string length

  func	st_len
	str : * Char			; string pointer
	()  : int			; string length
  is	bas : * Char			; base address
	bas = str			; remember it
	.. while *str++			; skip to end
	reply str - bas - 1		; return length
  end
