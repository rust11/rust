file	tiday - day and week of year
include	rid:rider
include	rid:tidef

code	ti_woy - week of year

;	Assume the week starts on Sunday

  func	ti_woy
	plx : * tiTplx
  is	doy : int = ti_doy (plx)
	reply (ti_doy (plx) - plx->Vdow) / 7
  end

code	ti_doy - get day of year

  init	tiAdoy : [12] char signed own
  is	; J  F  M  A  M  J  J  A  S  O  N  D 
	; 31 28 31 30 31 30 31 31 30 31 30 31
	  0, 1,-1, 0, 0, 1, 1, 2, 3, 3, 4, 4 
  end

  func	ti_doy
	plx : * tiTplx~
  is	doy : int
	doy = plx->Vday + (plx->Vmon*30)	; your basic day
	doy += tiAdoy[plx->Vmon]		; your adjusted day
	if (plx->Vmon gt 1) && !ti_lea (plx)	; march etc and not leap year
	.. ++doy				; add a day
	reply doy				;
  end

code	ti_lea - is leap year?

  func	ti_lea
	plx : * tiTplx
  is	reply (plx->Vyea & 3) eq
  end
