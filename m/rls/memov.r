file	memov - move memory
include rid:rider
include rid:medef
If meKrts
If Win
include rid:wimod
Else
include	<string.h>
End
End

code	me_mov - move overlapping memory

  func	me_mov
	src : * void fast			; source area
	dst : * void fast			; destinatation area
	cnt : size				; char count
	()  : * void				; past result destination
  is	res : * void				; result for moveup
If meKrts
If Win
	MoveMemory (dst, src, cnt)
Else
	memmove (dst, src, cnt)			; move it
End
	reply <*char>dst + cnt			; our reply value
Else
	reply dst if cnt eq 0			; ignore wacky counts
      if src gt dst				; source higher, move down
	while cnt ge 16U			; 16 at a time
	   (<*long>dst)[0] = (<*long>src)[0]	; 1
	   (<*long>dst)[1] = (<*long>src)[1]	; 2
	   (<*long>dst)[2] = (<*long>src)[2]	; 3
	   (<*long>dst)[3] = (<*long>src)[3]	; 4
	   <*char>dst += 16, <*char>src += 16	;
	.. cnt -=  16				; count it 
	while cnt--				; do remainder
	.. *(<*char>dst)++ = *(<*char>src)++	;
	reply dst				; end of result
      else					; source lower, move up
	<*char>src += cnt			; point past end
	<*char>dst += cnt			; point past end
	res = dst				; for the return value
	while cnt ge 16U			; 16 at a time
	   <*char>dst -= 16, <*char>src -= 16	;
	   (<*long>dst)[3] = (<*long>src)[3]	; 1
	   (<*long>dst)[2] = (<*long>src)[2]	; 2
	   (<*long>dst)[1] = (<*long>src)[1]	; 3
	   (<*long>dst)[0] = (<*long>src)[0]	; 4
	.. cnt -=  16				; count it 
	while cnt--				; do remainder
	.. *--(<*char>dst) = *--(<*char>src)	;
	reply res				; end of result
      end					;
End
  end
