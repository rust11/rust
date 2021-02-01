file	drset - set directory
include	rid:rider
include	rid:drdef
include rid:dbdef
include rid:imdef
include	rid:wimod

;	dr_set is separate so that this common "set" operation
;	does not pull in all the other code.

code	dr_set - set current directory


  func	dr_set
	pth : * char
	cas : int			; later
  is
;PUT("set=[%s]\n", pth)
	fine if SetCurrentDirectory (pth) ; set it
;	im_rep ("W-Error setting current directory [%s]", pth)
;	db_lst ("dr_set")
	fail
  end
