file	fiver - create unique filename using versions
include	rid:rider
include	rid:fidef
include	rid:stdef

  func	fi_ver
	src : * char
	dst : * char
	bas : int
	lim : int
  is	tmp : [mxSPC*2] char
	ptr : * char = tmp
	dot : * char = <>
	lft : * char = <>
	rgt : * char = <>
	st_cop (src, tmp)
	dot = st_nth (".", tmp, <>, -1)
	dot = st_end (tmp) if !dot
	rgt = st_nth (")", tmp, dot, -1)
	lft = st_nth ("(", tmp, rgt, -1)
	if (lft && rgt) && (rgt-dot eq 1)
	   SCN(lft, "(%d", cur)
	   st_del 
	else
	.. lft = dot

  end


end file

