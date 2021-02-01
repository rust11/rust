file	stloo - string lookup
include	rid:rider
include	rid:stdef

code	st_loo - string lookup

;	Lookup a model string in an array of strings
;	Returns index of matched entry or -1 
;	Array is unsorted and terminated with a NULL
;	Empty string model ("") matchs correctly

  func	st_loo
	mod : * char			; thing to lookup
	tab : ** char			; string array
	()  : int			; index, -1 => not found
  is	idx : int = 0			; response index
	ent : * char			; table entry
	while (ent = *tab++) ne <>	; got another
	   if st_cmp (mod, ent) eq	; found one
	   .. reply idx			; great
	.. ++idx			; next index
	reply -1			; not found
  end
