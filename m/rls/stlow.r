file	st_low - lowercase string
include	rid:rider
include	rid:stdef
include	rid:chdef

code	st_low - lowercase line

  func	st_low
	str : * char
	()  : * char
  is	ptr : * char~ = str
	spin while (*ptr++ = ch_low (*ptr)) ne
	reply str
  end
