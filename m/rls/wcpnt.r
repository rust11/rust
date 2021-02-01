file	wccre - default wc_cre
include	rid:rider
include	rid:wcdef

;	These routines are inserted into the rider window library.
;	They are only called if the corresponding user routine is missing.
;	The library must be built with non-exclusive module names.
;	Each must occupy a separate module

code	wc_pnt - paint window

  func	wc_pnt
	evt : * wsTevt
	()  : int
  is	gr_beg (evt)
	gr_end (evt)
	fine
  end	
