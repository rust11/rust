file	mecop - memory copy
include rid:rider
include rid:medef
If meKrts
If Win
include rid:wimod
Else
include	<string.h>
End
End

code	me_dup - duplicate object

  proc	me_dup
	src : * void
	siz : size
	()  : * void
  is	dst : * void = me_alc (siz) 
	me_cop (src, dst, siz)
	reply dst
  end

code	me_cop - copy block

  func	me_cop
	src : * void~			; source area
	dst : * void~			; destinatation area
	cnt : size				; char count
	()  : * void				; past result destination
  is
If meKrts
If Win
	CopyMemory (dst, src, cnt)
Else
	memcpy (dst, src, cnt)			; move it
End
	reply <*char>dst + cnt			; our reply style
Else
	while cnt ge 16U			; 16 at a time
	   (<*long>dst)[0] = (<*long>src)[0]	; 1
	   (<*long>dst)[1] = (<*long>src)[1]	; 2
	   (<*long>dst)[2] = (<*long>src)[2]	; 3
	   (<*long>dst)[3] = (<*long>src)[3]	; 4
	   <*char>dst += 16, <*char>src += 16	;
	.. cnt -= 16				; count it 
						;
	while cnt--				; do remainder
	.. *(<*char>dst)++ = *(<*char>src)++	;
	reply dst				; end of result
End
  end
