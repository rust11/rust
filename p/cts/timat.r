file	timat - time math 
include	rid:rider
include	rid:qddef
include	rid:tidef
include	rid:timat
cmp$c := 0		; ti_cmp is in tipdp.r

;	Front-ends to maintain types

	Q(x) := <*WORD>(x)

  func	ti_clr
	dst : * tiTval
  is 	qd_clr (Q(dst))
  end

  func	ti_mov
	src : * tiTval
	dst : * tiTval
  is	qd_mov (Q(src), Q(dst))
  end

  func	ti_add
	lft : * tiTval
	rgt : * tiTval
	res : * tiTval
  is	qd_add (Q(lft), Q(rgt), Q(res))
  end

  func	ti_sub
	lft : * tiTval
	rgt : * tiTval
	res : * tiTval
  is	qd_sub (Q(lft), Q(rgt), Q(res))
  end

;	ti_cmp is in tipdp.r

If cmp$c
  func	ti_cmp
	lft : * tiTval
	rgt : * tiTval
	res : * tiTval
	()  : int
  is	qd_cmp (Q(lft), Q(rgt), Q(res))
  end
End

  func	ti_mul
	lft : * tiTval
	rgt : * tiTval
	res : * tiTval
  is	qd_mul (Q(lft), Q(rgt), Q(res))
  end

  func	ti_div
	lft : * tiTval
	rgt : * tiTval
	quo : * tiTval
	rem : * tiTval
  is	qd_div (Q(lft), Q(rgt), Q(quo), Q(rem))
  end
