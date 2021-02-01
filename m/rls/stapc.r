file	stapc - append character
include	rid:rider
include	rid:stdef

code	st_apc - append character

;	Appends source character to destination string

  func	st_apc
	src : char			; source string
	dst : * char~			; destinatation area
	lim : size			;
	()  : * char			; past destination
  is	dst[lim-1] = 0 if lim		; truncate string
	++dst while *dst		; skip to end
	*dst++ = src			; append character
	*dst = 0			; terminator
	reply dst			; at terminator
  end
