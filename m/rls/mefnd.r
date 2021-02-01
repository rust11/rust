file	mefnd - find memory
include rid:rider
include rid:medef

code	me_fnd - find memory 

;	Can't use pointer as non-zero result because result
;	memory pointer could be at location zero.

  func	me_fnd
	mod : * void			; model substring to find
	len : size			; length of model
	mem : * void			; base of memory
	lim : size			; length of search area
	res : ** void			; result pointer
	()  : int			; fine/fail 
  is	cnt : int = lim - len		;
					;
	repeat				;
	   fail if cnt-- lt		; fails immediately if lim lt len
	   if me_cmp (mod, mem, len)	; compare memory
	      *res = mem if res		; optional result
	   .. fine			;
	   ++<*byte>mem			; next location
	end
  end
