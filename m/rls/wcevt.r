file	wcevt - default wc_evt
include	rid:rider
include	rid:wcdef

;	These routines are inserted into the rider window library.
;	They are only called if the corresponding user routine is missing.
;	The library must be built with non-exclusive module names.
;	Each must occupy a separate module

code	wc_evt - cusp event preprocessor

  func	wc_evt
	evt : * wsTevt
	()  : int
  is	fail			; fail => not processed
  end	
