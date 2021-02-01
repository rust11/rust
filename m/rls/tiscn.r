end file
;???;?;	TISCN is broken
include	rid:rider
include	rid:tidef
include	rid:medef
include	rid:mxdef
include	rid:stdef

code	ti_sdt - scan date

  init	tiAmon : [] * char
  is	"JAN", "FEB", "MAR", "APR", "MAY", "JUN",
	"JUL", "AUG", "SEP", "OCT", "NOV", "DEC", "BAD"
  end

  func	ti_sdt
	plx : * tiTplx
	str : * char~
	()  : int
  is	day : int
	mon : [16] char
	yea : int
	idx : int~ = 0
	cnt : int~ = 0
;;;	lst : ** char = tiAmon

	me_clr (mon, 14)
	st_rep ("-", ":", str)
	st_rep ("-", ":", str)
	st_rep ("-", "/", str)
	st_rep ("-", "/", str)

	cnt = SCN(str, "%2d:%3s:%6d",
	   &day, mon, &yea)
;	PUT("cnt=%d\n", cnt)
	fail if cnt ne 3

	st_upr (mon)		

	while idx le 13
;	PUT("[%s] [%s] %d\n", mon, *lst, idx)
;;;	  quit if st_sam (&mon, *lst++)	
	  ++idx, ++lst
	end

	plx->Vday = day
	plx->Vmon = idx	
	plx->Vyea = yea
	fine
  end

  func	ti_stm
	plx : * tiTplx
	str : * char
	()  : int
  is	hou : int
	min : int
	sec : int
	SCN(str, "%2d:%2d:%td",
	   &hou, &min, &sec)
	fail if ne 3
	plx->Vhou = hou
	plx->Vmin = min
	plx->Vsec = sec
	fine
  end
