file	clscn - scan and delete leading string
include rid:rider
include rid:stdef
include rid:cldef

  func	cl_scn
	mod : * char			; model to skip
	lin : * char~			; line to process
	()  : int			;
  is	pst : * char~			; past scanned model
	st_trm (lin)			; junk spaces
	pst = st_scn (mod, lin)		;
	fail if null			; not found
	st_mov (pst, lin)		; delete it
	st_trm (lin)			; clean it up
	fine
  end

