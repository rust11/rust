file	stfnd - find substring
include rid:rider
include rid:stdef

code	st_fnd - find substring

  func	st_fnd
	mod : * char~			; model substring to find
	str : * char~			; string to search
	()  : * char			; pointer to found or null pointer
  is	src : * char~			; for substring match
	dst : * char			;
					;
      repeat				; big loop
	while *mod ne *str		; find the first matching character
	.. reply <> if *str++ eq	; exhausted string, not found
	src = mod, dst = str		; found first
	repeat				; compare remainder
	   reply str if *src eq		; done, found
	until *src++ ne *dst++		; got another
	++str				; again, just past remainder
      forever				;
  end
