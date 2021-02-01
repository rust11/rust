exp$c := 1	; expression
file	chlow - lower case conversion
include rid:rider
include rid:chdef
include rid:ctdef

code	ch_low - convert to lowercase

  func	ch_low 
	cha : int~ 			; to convert
	()  : int			; converted character
  is
If exp$c
	(cha ge 'A') && (cha le 'Z')
	reply that ? cha + (_a - _A) ?? cha
Else
	if ct_upr (cha)			; A...Z
	&& !(cha eq '_' || cha eq '$')	; and not special
	.. cha += (_a - _A)		; a...z
	reply cha			;
End
  end
