file	wcfnd - default wc_fnd
include	rid:rider
include	rid:wcdef
Log := 1
include	rid:dbdef

;	These routines are inserted into the rider window library.
;	They are only called if the corresponding user routine is missing.
;	The library must be built with non-exclusive module names.
;	Each must occupy a separate module

code	wc_fnd - cusp find

  func	wc_fnd
	evt : * wsTevt
	act : int
	flg : int
	mod : * char
	rep : * char
  is	LOG ("wc_fnd defaults")
	fine
  end	
