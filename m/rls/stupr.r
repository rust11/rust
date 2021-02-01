file	st_upr - uppercase string
include	rid:rider
include	rid:stdef
include	rid:chdef

code	st_upr - uppercase line

  func	st_upr
	str : * char~
	()  : * char
  is	ptr : * char = str
	spin while (*ptr++ = ch_upr (*ptr)) ne
	reply str
  end
