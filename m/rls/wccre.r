file	wccre - default wc_cre
include	rid:rider
include	rid:wcdef
Log := 1
include	rid:dbdef

;	These routines are inserted into the rider window library.
;	They are only called if the corresponding user routine is missing.
;	The library must be built with non-exclusive module names.
;	Each must occupy a separate module

code	wc_cre - cusp build

  func	wc_cre
	ctx : * wsTctx
  is	;LOG ("wc_cre defaults")
	fine
  end	
