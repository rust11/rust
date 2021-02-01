file	stmem - string member test
include	rid:rider
include	rid:stdef

code	st_mem - string membership test

  func	st_mem
	cha : int			; the non-zero character
	str : * char~			; the set (or <> for empty set)
	()  : int			; 1=>found, 0=>missing
  is	tmp : char~			;
	fail if str eq <>		; null set
	while (tmp = *str++) ne		; got more
	   fine if <char>tmp eq <char>cha; got a match
	end				;
	fail				;
  end
