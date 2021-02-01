file	st_pad - pad string
include rid:rider
include rid:stdef

code	st_pad - pad string

;	Fill string out to specified length with pad character

  func	st_pad
       	str : * char~
	pad : int
	cha : int
	()  : * char
  is	len : int~ = st_len (str)
	str += len
	while len++ lt pad
	.. *str++ = cha
	*str = 0
	reply str
  end
