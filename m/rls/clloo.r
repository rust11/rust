file	clloo - lookup keyword
include	rid:rider
include	rid:cldef
include	rid:chdef

code	cl_loo - lookup keyword

;	  init	xxAtab : [] * char
;	  is	xxDEF:  ""		; matchs an empty string (default)
;		xxEXI:	"e*xit"		;
;		xxVER:	"*ve*rify"	; matchs verify or noverify
;		xxINV:	<>		; returned for no match
;	  end
;
;	""	matchs an empty string (only)
;	"*..."	matchs "no..."

  func	cl_loo
	str : * char~			; string to match
	tab : [] * char~		; array of strings
	pol : * int			; if !<>, 0=>negated, 1=>not
	()  : int			; result index (at final for fail)
  is	ent : * char~			;
	idx : int = 0			;
	neg : int = 1			; assume not negated
	repeat				;
	   ent = *tab++			; get the next
	   reply idx if null		; are no more - not found
	   if *ent ne '*'		; not negatable
	      quit if cl_mat (str, ent)	; found it
	   else				;
	      quit if *++ent eq		; "*" matchs anything
	      quit if cl_mat (str, ent)	; got positive form
	      if ch_low (str[0]) eq 'n'	;
	      && ch_low (str[1]) eq 'o'	;
	         cl_mat (str+2, ent)	; match without 'no'
	   .. .. quit neg = 0 if ne	; got negated form
	   ++idx			; next index
	end				;
	*pol = neg if pol ne <>		; wanted polarity
	reply idx			;
  end
