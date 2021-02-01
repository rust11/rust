file	meclr - clear memory
include rid:rider
include rid:medef
If meKrts
If Win
include rid:wimod
Else
include	<string.h>
End
End

code	me_clr - clear memory

  func	me_clr
	buf : * void fast		; buffer
	cnt : size			; clear count
	()  : * void			; past area cleared
  is
If meKrts
If Win
	ZeroMemory (buf, cnt)
Else
	memset (buf, 0, cnt)		; RTS is faster
End
	reply <*char>buf + cnt		; our return is different
Else
	while cnt ge 64U		; lots more
	   (<*long>buf)[0] = 0		; 4
	   (<*long>buf)[4] = 0		; 8
	   (<*long>buf)[8] = 0		; 12
	   (<*long>buf)[12] = 0		; 16
	   (<*long>buf)[16] = 0		; 20
	   (<*long>buf)[20] = 0		; 24
	   (<*long>buf)[24] = 0		; 28
	   (<*long>buf)[28] = 0		; 32
	   (<*long>buf)[32] = 0		; 36
	   (<*long>buf)[36] = 0		; 40
	   (<*long>buf)[40] = 0		; 44
	   (<*long>buf)[44] = 0		; 48
	   (<*long>buf)[48] = 0		; 52
	   (<*long>buf)[52] = 0		; 56
	   (<*long>buf)[56] = 0		; 60
	   (<*long>buf)[60] = 0		; 64
	   <*char>buf += 64, cnt -= 64
	end

	while cnt ge 16U		; 16 at a time
	   (<*long>buf)[0] = 0		; 4
	   (<*long>buf)[4] = 0		; 8
	   (<*long>buf)[8] = 0		; 12
	   (<*long>buf)[12] = 0		; 16
	   <*char>buf+= 16, cnt -= 16	;
	end				;
	while cnt--			; got more
	.. *(<*char>buf)++ = 0		; last 16
End
	reply buf			; return buffer
  end
