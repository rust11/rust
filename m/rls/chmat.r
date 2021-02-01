file 	chmat - match character
include rid:rider
include	rid:chdef

code	ch_mat - match character with string

;	Match each character in model string with a target character.
;	The first character of the model is always compared - this
;	permits a match with end of line -- \0.
;	Returns TRUE if matched, FALSE otherwise.
;
;	ch_mat ("/,=", cha)		; is cha slash, comma or equals?

  func	ch_mat
	mod : * char~			; model string
	cha : int			; character
	()  : int			; fine => matched
  is	repeat				;
	   fine if <BYTE>*mod++ eq <BYTE>cha ; found it
	until not *mod			; all over
	fail				;
  end
