file	mealc - memory allocation
include rid:rider
include	rid:imdef
include	rid:medef

	meValc : size = 0		; total bytes allocated

code	me_alc - memory allocate

  func	me_alc
	siz : size			; byte size
	()  : * void			; area
  is	me_alg (<>, siz, 0)		; allocate, don't clear
	reply that			; send back result
  end

code	me_acc - memory allocate & clear

  func	me_acc
	siz : size			; byte size
	()  : * void			; area
  is	me_alg (<>, siz, meCLR_)	; allocate, and clear
	reply that			; send back result
  end

code	me_ral - reallocate memory

  func	me_ral
	bas : * void
	siz : size
	()  : * void
  is	reply me_alg (bas, siz, 0)	; reallocate memory
  end	

code	me_dlc - deallocate memory

  proc	me_dlc
	bas : * void
  is	me_alg (bas, 0, 0)		; deallocate it
  end
If 0 ;Win
code	me_alg - allocate generic
include	rid:wimod

;	bas siz 
;	0   0	nop
;	0   xxx	allocate
;	xxx 0  	deallocate
;	xxx xxx	reallocate

  func	me_alg
	bas : * void			; area pointer address
	siz : size			; byte size
	mod : int			; operation mode
	()  : * void			; base address or <>
  is	han : HANDLE = GetProcessHeap ();
	flg : DWORD = 0
	flg |= HEAP_ZERO_MEMORY if mod & meCLR_
	flg |= HEAP_GENERATE_EXCEPTIONS if !(mod & meALC_) 

	if bas eq <>				; not already allocated
	   fail if !siz				;
	   meValc += siz			; total allocates
	.. reply HeapAlloc (han, flg, siz)	; allocate it
	fail HeapFree (han, 0, bas) if !siz	; deallocate it
	reply HeapReAlloc (han, flg, bas, siz)	; reallocate it
  end

Else
code	me_alg - allocate generic
include	<stdlib.h>

  func	me_alg
	bas : * void			; area pointer address
	siz : size			; byte size
	mod : int			; operation mode
	()  : * void			; base address or <>
  is
	if bas eq <>			; not already allocated
	   fail if !siz			;
	   meValc += siz		; total allocates
	   bas = malloc (siz)		; get the space
	else				;
	   fail free (bas) if !siz	; deallocate it
	.. bas = realloc (bas, siz)	; reallocate it
					;
	if bas eq <>			; failed
	   reply <> if mod & meALC_	; private mode
	.. im_rep ("F-Memory exhausted", <>); jumps or aborts
					;
	me_clr (bas, siz) if mod & meCLR_; want it cleared
	reply bas			; return base
  end
End
If 0
code	standard functions

If meKstd

;	Redefining the standard functions stops the compiler's
;	default startup code from including the RTL's malloc etc.
;	(I could have implemented the engine like this!)

  func	malloc
	siz : size
	()  : * void
  is	reply me_alc (siz)
  end

  func	calloc
	cnt : size
	siz : size
	()  : * void
  is	reply me_acc (cnt * siz)
  end


  func	realloc
	bas : * void
	siz : size
	()  : * void
  is	reply me_ral (bas, siz)
  end

  proc	free
	bas : * void
  is	me_dlc (bas)
  end

End

End
end file

	meValc	: size = 0		; total allocated
	meVdlc	: size = 0		; total deallocated
