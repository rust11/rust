file	stpar - string partition
include	rid:rider
include	rid:ctdef
include	rid:stdef

;	st_par determines the start or end of a string partition that 
;	includes or excludes specified characters or character classes.
;	st_par is not particulary efficient and is not a pattern matcher.
;
;	o  Match character classes and specific characters
;	o  Handle inclusion (match) or exclusion (miss)
;	o  Locate either the start or end of a partition
;	o  Optionally return a pointer past the location
;	o  Caller specifies failure return value
;
;	"res" = st_par ("ctl", "prg", "str")
;
;	All parameters are strings. 
;
; ctl	"ctl" is a control string. An optional leading minus sign specifies
;	that the match should be for missing characters. The next character
;	controls the position response for a match success. One of:
;
;	f  first match			j  jump - first match + 1
;	l  last match			p  past - last match + 1
;
;	The final character specifies the position to be returned on failure:
;
;	b  beginning of string		e  end of string
;	n  null pointer
;
; prg	"prg" is the match program. The first part is a sequence of characters,
;	each of which specifies a character class:
;
;	A  alphabetics (AZaz09$_)	S  whitespace
;	C  control			U  uppercase
;	D  digits			X  hex digits
;	L  lowercase			Z  anything
;	P  punctuation			|  ends classes
;
;	The end of the class part is specified with "|" (which is skipped),
;	or any character that does not specify a character class (not skipped).
;	The remaining characters are specific characters for the match process.
;
; str	"str" is the string to be partitioned.
;
; res	"res" is the result, a pointer to a partition of "str" or null. The
;	"ctl" string determines the position for success or failure.
;
;	Invalid control or program strings result in <>.
;
;	Examples:
;
;	st_par ("pn", ":",    "dev:file.typ") 		"file.typ"
;	st_par ("pb", ":],",  "nod::dev:[dir]x.y")	"x.y"
;	st_par ("fe", "AD$_", " <a_name> ")		"a_name> "
;	st_par ("pe", "AD$_", "a_name> ")		"> "		
;	st_par ("-pn", "*",  "aa*b")			"b"
code	st_par - string partition

  func	st_par
	ctl : * char~			; control string
	lft : * char			; program string
	rgt : * char~			; right string
	()  : * char			; -> match
  is	prg : * char			; program string (local pointer)
	beg : * char = rgt		; for failure results
	lst : * char = <>		; last occurrence
	pos : int			; positioning operation
	cha : int~			; current character of rgt
	don : int			; escape control
	tst : int 			; test state of this one
	req : int = 1			; assume match required
					;
	req = 0, ++ctl if *ctl eq '-'	; correct for missing required
	reply <> if *ctl eq		; crazy control string
	pos = *ctl++			; get positioning command
     repeat				;
;	debug ("ctl=[%s] prg=[%s] str=[%s]\n", ctl, lft, rgt)
	quit if (cha = *rgt) eq		; no more
	prg = lft			; get the match program
	tst = 0				; no test value yet
	don = 0				; break out control
	repeat				; scan classes
	   case *prg++ & 255		; next (or past) class
	   of '|'   ++don		; done classes
	   of 'A'   tst = ct_aln (cha)	;
	   of 'C'   tst = ct_ctl (cha)	;
	   of 'D'   tst = ct_dig (cha)	;
	   of 'L'   tst = ct_low (cha)	;
	   of 'P'   tst = ct_pun (cha)	;
	   of 'S'   tst = ct_spc (cha)	;
	   of 'U'   tst = ct_upr (cha)	;
	   of 'X'   tst = ct_hex (cha)	;
	   of 'Z'   tst = cha		; matchs anything
	   of other --prg, ++don	; not a class, backup, quit
	   end case			;
	until (tst|don)			; got match or end classes
					;
	if *ctl && tst eq		; got more and not found so far
	.. tst = st_mem (cha, prg)	; find specific
;	debug ("ctl=[%s] prg=[%s] rgt=[%s] tst=%d req=%d\n",
;		ctl, prg, rgt-1, tst, req)
	tst = tst ? 1 ?? 0		; normalize test value
	if tst eq req			; found required state
	   case pos			;
	   of 'f'   reply rgt		; first
	   of 'j'   reply rgt + 1	; jump first
	   of 'l'   lst = rgt		; last
	   of 'p'   lst = rgt + 1	; past last
	   of other reply <>		; invalid
	   end case			; no defaults
	end				;
	++rgt				; find another
     forever				; done matchs
	reply lst if lst ne <>		; found last or past
	case *ctl			; return their failure preference
	of 'b'   reply beg		; beginning of string
	of 'e'   reply rgt		; end of string	
	of 'n'   reply <>		; null
	or other reply <>		; invalid	
	end case			;
  end
