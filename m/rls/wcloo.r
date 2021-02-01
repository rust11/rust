file	wcloo - default windows client loop
include	rid:rider
include	rid:wcdef

;	These routines are inserted into the rider window library.
;	They are only called if the corresponding user routine is missing.
;	The library must be built with non-exclusive module names.
;	Each must occupy a separate module

code	wc_loo - default loop

  func	wc_loo
	evt : * wsTevt
  is	ws_loo (evt)			; use server loop
  end

