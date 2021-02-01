exp$c := 1	; expression
file	chupr - uppercase conversion
include rid:rider
include rid:chdef
include rid:ctdef

code	ch_upr - convert to uppercase

  func	ch_upr 
	cha : int~ 			; to convert
	()  : int			; converted character
  is
If exp$c
	(cha ge 'a') && (cha le 'z')
	reply that ? cha - (_a - _A) ?? cha
Else
	if ct_low (cha)			; is lower case
	&& !(cha eq '_' || cha eq '$')	; and not special
	.. cha += (_A - _a)		; A...Z
	reply cha			;
End
  end
