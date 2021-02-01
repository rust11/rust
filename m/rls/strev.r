file	strev - reverse string
include	rid:rider
include	rid:stdef

code	st_rev - reverse string

;	a bcde f	a bcd e
;	f bcde a	e bcd a
;	fe cd ba	ed c ba

  proc	st_rev
	str : * char
	()  : * char			; past string
  is	res : * char			; result
	lst : * char			; last 
	cha : int			; temp
	reply str if *str eq		; null string
	lst = res = st_end (str)	; point at end
	while str lt --lst		; got more
	   cha = *lst			; get temp
	   *lst = *str			; swap another
	   *str++ = cha			;
	end				;
	reply res			; end of it
  end
