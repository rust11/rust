file	merep - replicate memory
include	rid:rider
include rid:medef

code	me_rep - replicate memory

  func	me_rep
	src : * void
	dst : * void
	siz : size
	cnt : int
	()  : * void
  is	lft : * char~ = src
	rgt : * char~ = dst
	while cnt--
	   rgt = me_cop (lft, rgt, siz)
	end
	reply rgt
  end
