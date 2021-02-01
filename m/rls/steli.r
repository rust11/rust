file	steli - elide characters in string
include	rid:rider
include	rid:stdef

code	st_eli - string elide

;	st_eli (mat, src, dst)
;
;	mat	match string for st_mem
;	src	source string
;	dst	result string (may be same as source)

  func	st_eli
	mat : * char			; match set
	src : * char~			; source string
	dst : * char~			; result string (zero terminated)
	()  : int			; result string length
  is	cnt : int = 0			;
	while *src			;
	   if !st_mem (*src, mat)	; not excluded
	   .. *dst++ = *src		;
	   src++			; copy
	end
	*dst = 0			; terminate
	reply cnt			; reply number copied
  end
