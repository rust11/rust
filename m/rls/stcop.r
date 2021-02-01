file	stcop - copy string
include	rid:rider
include	rid:stdef

code	st_cop - string copy

;	Copies source string to destination string
	
  func	st_cop
	src : * char~			; source string
	dst : * char~			; destinatation area
	()  : * char			; past destination
  is
;	while *src			; got more
;	   *dst = *src			;
;	   ++src, ++dst			; makes better code
;	end				;
	spin while (*dst++ = *src++) ne	; copy it (ne to inhibit warning)
	reply --dst			; backup destination
;	*dst = 0			;
;	reply dst			;
  end

