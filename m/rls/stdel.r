file	stdel - delete leading substring
include	rid:rider
include	rid:stdef

code	st_del - delete leading substring

  func	st_del
	str : * Char			; target
	cnt : size			; number to delete
	()  : * char			; at string 
  is	st_mov (str+cnt, str)		; squash them out
	reply str			;
  end
