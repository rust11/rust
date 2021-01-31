.title	rtmnt - RT-11 CRT maintenance monitor

;	1. Report previous test results, if any
;	2. Fill stack and dynamic memory with test pattern

  type	rtText
  is	Vlow : WORD
	Vtop : WORD
	Pptr : WORD
  end

  type	rtTmai
  is	Vini : int		; first time flag
	Istk : rtIext		; stack extent
	Idyn : rtIext		; dynamic memory extent
  end

	cur : rtTmai- = {0}
	det : rtTmai- = {0}	;

  func	rt_mai
  is	if prv.Vini		; already setup
	   rt_col (&dif, 1)	; get difference
	   			;
	end			;

	rt_col (&cur, 0)	; get current information
  end

