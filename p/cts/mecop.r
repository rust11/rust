file	mecop - memory copy
include rid:rider
include rid:medef

code	me_cop - copy block

  func	me_cop
	inp : * void		; source area
	opt : * void		; destinatation area
	cnt : int~		; char count
	()  : * void		; past result destination
  is	src : * char~ = inp
	dst : * char~ = opt
	if !((<int>src|<int>dst)&1)
	   while cnt ge 16
	      *(<*WORD>dst)++ = *(<*WORD>src)++	; 2
	      *(<*WORD>dst)++ = *(<*WORD>src)++	; 4
	      *(<*WORD>dst)++ = *(<*WORD>src)++	; 6
	      *(<*WORD>dst)++ = *(<*WORD>src)++	; 8
	      *(<*WORD>dst)++ = *(<*WORD>src)++	; 10
	      *(<*WORD>dst)++ = *(<*WORD>src)++	; 12
	      *(<*WORD>dst)++ = *(<*WORD>src)++	; 14
	      *(<*WORD>dst)++ = *(<*WORD>src)++	; 16
	   .. cnt -= 16
	else
	   while cnt ge 16		; 16 at a time
	      *dst++ = *src++	; 1
	      *dst++ = *src++	; 2
	      *dst++ = *src++	; 3
	      *dst++ = *src++	; 4
	      *dst++ = *src++	; 5
	      *dst++ = *src++	; 6
	      *dst++ = *src++	; 7
	      *dst++ = *src++	; 8
	      *dst++ = *src++	; 9
	      *dst++ = *src++	; 10
	      *dst++ = *src++	; 11
	      *dst++ = *src++	; 12
	      *dst++ = *src++	; 13
	      *dst++ = *src++	; 14
	      *dst++ = *src++	; 15
	      *dst++ = *src++	; 16
	   .. cnt -= 16		; count it 
	end			;
	while --cnt ge		; do remainder
	.. *dst++ = * src++	;
	reply dst		; end of result
  end
