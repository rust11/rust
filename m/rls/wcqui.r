file	wcqui - default wc_qui
include	rid:rider
include	rid:wcdef

;	These routines are inserted into the rider window library.
;	They are only called if the corresponding user routine is missing.
;	The library must be built with non-exclusive module names.
;	Each must occupy a separate module

code	wc_qui - cusp quit

  func	wc_qui
	ctx : * wsTctx
	()  : int
  is	fine
  end	

