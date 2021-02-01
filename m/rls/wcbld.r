file	wcbld - default wc_bld
include	rid:rider
include	rid:wcdef

;	These routines are inserted into the rider window library.
;	They are only called if the corresponding user routine is missing.
;	The library must be built with non-exclusive module names.
;	Each must occupy a separate module

code	wc_bld - cusp build

  func	wc_bld
	ctx : * wsTctx
	cmd : * char
	()  : int
  is	fine
  end	
