file	rtnat - RT-11 native time
include	rid:rider
include	rid:rttim

;	"Native time" is used for applications which only need
;	to compare times (and not perform addition/subtraction).
;	Quad time takes 3kw more space and is way to slow for
;	applications like COPY and DIR.
;
;	Native time type is stored as three WORDs for nt_cmp ():
;
;	  type	ntTval
;	  is	Aval : [3] WORD
;	  end
;
;	But is treated as <WORD,long> during conversion.
;
;	  type	ntTval
;	  is	Vhot : WORD
;		Vlot : long
;	  end
;
;	To accomodate invalid date fields:
;
;	Day 	0:31, not 1:31
;	Month:	0:13, not 0:13
;	Year:	0:2097151
;
;	The stored long value is never negative.

code	nt_val - plex to native time value

  func	nt_val
	tim : * tiTplx~
	val : * ntTval
  is	plx : tiTplx
	hot : * WORD = <*WORD>val->Aval
	lot : * long~ = <*long>(val->Aval + 1)
	lng : long~
	ti_rng (tim, &plx)		; range check and truncate
	*hot = plx.Vyea / 32		; get the high order
	lng = plx.Vyea % 32		; low order year
	lng *= 13L, lng += plx.Vmon	; range 0:12
	lng *= 32L, lng += plx.Vday	; range 0:31
	lng *= 24L, lng += plx.Vhou
	lng *= 60L, lng += plx.Vmin
	lng *= 60L, lng += plx.Vsec
	*lot = lng
  end

code	nt_plx - native time value to plex

  func	nt_plx
	val : * ntTval
	plx : * tiTplx~
  is	hot : * WORD = <*WORD>val->Aval
	lot : * long~ = <*long>(val->Aval + 1)
	lng : long~ = *lot
	plx->Vsec = lng % 60L, lng /= 60L 
	plx->Vmin = lng % 60L, lng /= 60L 
	plx->Vhou = lng % 24L, lng /= 24L 
	plx->Vday = lng % 32L, lng /= 32L 
	plx->Vmon = lng % 13L, lng /= 13L 
	plx->Vyea = (*hot * 32) + lng
  end

code	nt_cmp - compare native times

  func	nt_cmp
	lft : * ntTval~
	rgt : * ntTval~
  is	res : int~
	if (res = lft->Aval[0] - rgt->Aval[0]) ne
	|| (res = lft->Aval[1] - rgt->Aval[1]) ne
	|| (res = lft->Aval[2] - rgt->Aval[2]) ne
	end
	reply res
  end
end file


