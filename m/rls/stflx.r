file	stflx - filter with exceptions
include	rid:rider
include	rid:stdef

;	This is a hack

code	st_flx - string filter with exceptions

;	st_flt (mat, bra, src, dst, flg/lim)
;
;	mat	match string for st_mem
;	bra	bracket string (see below)
;	src	source string
;	dst	result string
;	lim=n	ABS(lim) = result buffer limit (including \0)
;		lim gt => positive match
;		lim lt => negative match
;
;	res	number of characters copied
;		negative if limit overflow
;
;	Convert RSX spec to RUST spec
;
;	bra =	"[]," => skip "," between "[" and "]"

  func	st_flx
	mat : * char			; match set
	bra : * char			; bracket set
	src : * char~			; source string
	dst : * char~			; result string (zero terminated)
	flg : int			; gt=>positive, lt=> negative
	()  : int			; 1=>found, 0=>missing
  is	cnt : int~ = 0			; result count
	act : int = 0			; bracket active
	lim : int = ABS(flg)		; limit
	while *src			;
	   act = 1 if *src eq bra[0]
	   act = 0 if *src eq bra[1]
	   if act && st_mem (*src, bra+2)
	   elif st_mem (*src, mat)	; got a member 
	      quit if flg lt		; end of negative filter
	   else				; not a member
	   .. quit if flg gt		; end of positive filter
	   quit cnt = -cnt if !--lim	; no room
	   *dst++ = *src++, ++cnt	; copy
	end
	*dst = 0			; terminate
	reply cnt			; reply number copied
  end
