file	stapp - append string
include	rid:rider
include	rid:stdef

code	st_app - append string

;	Appends source string to destination string

  func	st_app
	src : * Char			; source string
	dst : * Char			; destinatation area
	()  : * char			; past destination
  is	spin while *dst++		; skip to end
	--dst				; backup to terminator
	spin while (*dst++ = *src++) ne	; copy it
	reply --dst			; backup destination
  end
