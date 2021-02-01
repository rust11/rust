file	stint - string intersection
include	rid:rider
include	rid:stdef

code	st_int - string intersection

  func	st_int
	src : * char~			;
	dst : * char~			; the set (or <> for empty set)
	res : * char~			;
	()  : int			; n=>found, 0=>missing
  is	cha : char			;
	cnt : int = 0			; characters in set
	while (cha = *src++) ne		; got more
	   if st_mem (cha, dst)		; found in result
	      ++cnt			; count it
	   .. *res++ = cha if res	; record it
	end				;
	*res = 0 if res			; terminate result
	reply cnt			;
  end
