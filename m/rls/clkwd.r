file	clkwd - keyword match
include	rid:rider
include	rid:cldef
include	rid:chdef

code	cl_kwd - match keyword

;	""	matchs an empty string (only)
;	"..*.."	matchs minimal part
;	"*..."	matchs "no..."

  func	cl_kwd
	kwd : * clTkwd~			; keyword stuff
	str : * char~			;
	()  : int			; fine/fail
  is	mod : * char~ = kwd->Pmod	;
	kwd->Vflg &= ~(clNEG_)		; not negated yet			; assume positive
	if *mod ne '*'			; not negatable
	   reply cl_mat (str, mod)	; simple match
	else				;
	   fine if *++mod eq		; "*" matchs anything
	   fine if cl_mat (str, mod)	; got positive form
	   if ch_low (str[0]) eq 'n'	;
	   && ch_low (str[1]) eq 'o'	;
	      kwd->Vflg |= clNEG_	;
	.. .. reply cl_mat (str+2, mod)	; match without 'no'
	fail				;
  end
