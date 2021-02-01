file	wcmou - default wc_mou
include	rid:rider
include	rid:wcdef

;	These routines are inserted into the rider window library.
;	They are only called if the corresponding user routine is missing.
;	The library must be built with non-exclusive module names.
;	Each must occupy a separate module

code	wc_mou - cusp build

  func	wc_mou
	ctx : * wsTctx
  is	fine
  end	
