file	wc_cmd - cusp command dispatcher
include	rid:rider
include	rid:wcdef

;	These routines are inserted into the rider window library.
;	They are only called if the corresponding user routine is missing.
;	The library must be built with non-exclusive module names.
;	Each must occupy a separate module

code	wc_cmd - execute commands

  func	wc_cmd
	evt : * wsTevt
	() : _export int
  is	fine
  end
