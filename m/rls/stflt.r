file	stflt - string filter
include	rid:rider
include	rid:stdef

code	st_flt - string filter

;	st_flt (mat, src, dst, flg/lim)
;
;	mat	match string for st_mem
;	src	source string
;	dst	result string
;	lim=n	ABS(lim) = result buffer limit (including \0)
;		lim gt => positive match
;		lim lt => negative match
;
;	res	number of characters copied
;		negative if limit overflow

  func	st_flt
	mat : * char			; match set
	src : * char~			; source string
	dst : * char~			; result string (zero terminated)
	flg : int			; gt=>positive, lt=> negative
	()  : int			; 1=>found, 0=>missing
  is	cnt : int~ = 0			; result count
	lim : int = ABS(flg)		; limit
	while *src			;
	   if st_mem (*src, mat)	; got a member 
	      quit if flg lt		; end of negative filter
	   else				; not a member
	   .. quit if flg gt		; end of positive filter
	   quit cnt = -cnt if !--lim	; no room
	   *dst++ = *src++, ++cnt	; copy
	end
	*dst = 0			; terminate
	reply cnt			; reply number copied
  end
