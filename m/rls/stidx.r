file	stidx - character index in string
include	rid:rider
include	rid:stdef

code	st_idx - character index in string

  func	st_idx
	cha : int			; the non-zero character
	str : * char			; the set (or <> for empty set)
	()  : int			; -1 => no set or no match
					; +n => index of located member
  is	idx : int = 0			;
	tmp : int			; avoid double access
	reply -1 if str eq <>		; no set 
	while (tmp = *str++) ne		; no game
	    <BYTE>tmp eq <BYTE>cha	; match
	   reply idx if that		; game, set and match
	   ++idx			;
	end				;
	reply -1			;
  end
