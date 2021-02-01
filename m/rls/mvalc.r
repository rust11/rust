file	mvalc - virtual allocate
include	rid:rider
include	rid:medef
include	rid:wimod

  func	mv_dup
	bas : * void
	siz : size
	()  : * void
  is	res : * void = mv_alc (siz)
	me_cop (bas, res, siz)
	reply res
  end

  func	mv_alc
	siz : size
	()  : * void
  is	res : * void
	res = VirtualAlloc (<>, siz, MEM_COMMIT, PAGE_READWRITE)
	reply res
  end

  proc	mv_dlc
	bas : * void
  is	VirtualFree (bas, 0, 0)
  end

