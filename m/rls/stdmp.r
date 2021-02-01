file	stdmp - dump a string
include	rid:rider
include	rid:stdef

  func	st_dmp
	str : * char~
  is	cha : int~
	PUT("[")
	while *str
	   cha = *str++
	   PUT("%d ", cha)
	end
	PUT("]")
  end

