file	stcol - collapse string
include rid:rider
include rid:ctdef
include rid:stdef

code	st_col - collapse string

;	Convert tab to space, collapse multiple spaces

  func	st_col
	src : * char~
	dst : * char			; may be same as src
  is	prv : int = 0			; previous was space
	cur : int~			; current is space
	cha : int~			;
	while *src			;
	   cha = *src++			;
	   cha = ' ' if cha eq '\t'	; collapse tabs
	   cur = cha eq ' '		;
	   *dst++ = cha if !(prv && cur);
	   prv = cur			;
	end				;
	*dst = 0			;
  end
