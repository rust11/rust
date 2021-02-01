file	stwld - wildcard compare
include	rid:rider
include	rid:stdef
include	rid:chdef

code	st_wld - match wildcard string

;	*	Wild string
;	% or ?	Wild character

  func	st_wld
	mod : * char~			; model substring with *? to find
	str : * char~			; string to search
	()  : int			; matched
  is  repeat				; big loop
	fine if !*mod && !*str		; all over
	if *mod eq '*'			; got a wildcard
	   ++mod			;
	   fine if !*mod		; ...* matchs anything
	   while *str			; attempt the remainder
	   .. fine if st_wld (mod,str++);
	.. fail				;
	if *mod eq '%'			;
	|| *mod eq '?'			;
	   fail if !*str		; nothing to match
	.. next ++mod, ++str		; skip single
	ch_low (*mod) ne ch_low (*str)	; compare one
	fail if ne			; (ne => true)
	++mod, ++str			; next pair
      forever
  end
