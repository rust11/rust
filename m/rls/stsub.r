file	stsub - test substring
include rid:rider
include rid:stdef

code	st_sub - test substring

  func	st_sub
	mod : * char			; model substring to find
	str : * char			; string to search
	()  : int			; fine => model is substring of string
  is	src : * char			; for substring match
	dst : * char			;
					;
      repeat				; big loop
	while *mod ne *str		; find the first matching character
	.. fail if *str++ eq		; exhausted string, not found
	src = mod, dst = str		; found first
	repeat				; compare remainder
	   fine if *src eq		; done, found
	until *src++ ne *dst++		; got another
	++str				; again, just past remainder
      forever				;
  end
