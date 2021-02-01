file	edloc - find substring
include rid:rider
include rib:eddef
include rid:chdef
include rid:ctdef
include rid:stdef

code	ed_loc - find substring

;	Alpha models must be properly isolated in string
;	Skips quoted strings unless they start the model

  func	ed_loc
	mod : * char~			; model substring to find
	str : * char~			; string to search
	()  : * char			; pointer to found or NULL
  is	ptr : * char~			; saved string
	anc : * char = mod		; saved model anchor
	alp : int 			; alpha flag
	alp = ct_alp (mod[0])		; remember alpha model

    repeat
	while *mod ne *str		; find the first
	   if *str eq _quotes		; "
	   || *str eq _apost		; '
	      str = st_bal (str)	; balance them
	   .. next			;
	.. fail if not *str++ 		; all over

	if alp				; alpha string
	&& ct_aln (str[-1])		; and previous alpha
	&& ct_aln (*str)		; and got more coming
	   while ct_aln (*str)		; skip alphas
	   .. ++str			; skip it
	.. next				; try again

	ptr = str			; save string pointer
	repeat				; compare model
	   if not *mod			; no more
	      if ct_aln (mod[-1])	; and ended alpha
 	      && ct_aln (str[0])	; and got alpha coming
	      .. quit			; no match - try next one
	   .. reply ptr			; found it
	until *mod++ ne *str++		; got another

;	backup and start over

	mod = anc			; restore model pointer
	str = ++ptr			; next string character
    forever				;
  end
