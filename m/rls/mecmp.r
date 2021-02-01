file	mecmp - compare memory
include rid:rider
include rid:medef

code	me_cmp - compare memory

  func	me_cmp
	lft : * void
	rgt : * void
	cnt : size~
	()  : int
  is	src : * char~ = lft
	dst : * char~ = rgt
	while cnt--
	   fail if *src++ ne *dst++
	end
	fine
  end
