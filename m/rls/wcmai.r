file	wcmai - default wc_mai
include	rid:rider
include	rid:wcdef
include	rid:cldef
include	rid:imdef

;	These routines are inserted into the rider window library.
;	They are only called if the corresponding user routine is missing.
;	The library must be built with non-exclusive module names.
;	Each must occupy a separate module

code	wc_mai - cusp main

  func	wc_mai
	evt : * wsTevt
  is	fine
  end
