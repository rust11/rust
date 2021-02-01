file	meoth - other memory functions
include rid:rider
include	rid:medef

;	Pointer mode allocation -- these are being phazed out...

code	me_apc - memory allocate via pointer & clear

;	Does not reallocate an area
	
  func	me_apc
	ptr : ** void			; result pointer
	siz : size			; byte size
	()  : int			; fine/fail
  is	me_alg (*ptr, siz, meCLR_)	; allocate and clear
	*ptr = that			; store result
	reply that ne <>		; fail if null
  end

code	me_alp - memory allocate via pointer
	
;	Does not reallocate an area

  func	me_alp
	ptr : ** void			; result pointer
	siz : size			; byte size
	()  : int			; fine/fail
  is	me_alg (*ptr, siz, 0)		; allocate, don't clear
	*ptr = that			; store result
	reply that ne <>		; fail if null
  end

code	me_dlp - deallocate memory via pointer

  proc	me_dlp
	ptr : ** void
  is	exit if ptr eq <> || *ptr eq <>	; nothing to deallocate
	me_alg (*ptr, 0, 0)		; deallocate it
	*ptr = <>			; reset pointer
  end
code	me_ulk - unlock object

;	Dummy lock/unlock functions

  func	me_ulk
	bas : * void
	()  : * void
  is	reply bas
  end

code	me_lck - lock object

  func	me_lck
	bas : * void
	()  : * void
  is	reply bas
  end
