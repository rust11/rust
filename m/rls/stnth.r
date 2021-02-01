file	stnth - find nth occurence of string
include	rid:rider
include	rid:stdef

;	*mod	model to search for
;	*tar	target to search thru
;	*lim	end of target (optional)
;	nth	occurrence, -1 is last

  func	st_nth
	mod : * char
	tar : * char
	lim : * char
	nth : int
	()  : * char
  is	ptr : * char = lim ? lim ?? st_end (tar)
	prv : * char
	fail if !nth
	repeat
	   lim = ptr
	   ptr = tar
	   prv = <>
	   while (ptr = st_fnd (mod, ptr)) ne
	      quit if ptr gt lim
	      --nth if nth gt
	      reply ptr if nth eq
	      prv = ptr
	   end
	   fail if nth ge
	   fail if !prv
	   reply prv if nth eq -1
	   ++nth
	end
  end
