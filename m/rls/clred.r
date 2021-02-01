file	clred - reduce command line
include	rid:rider
include	rid:stdef
include	rid:cldef
include rid:ctdef

;	compress whitespace
;	balance quotes
;	handle comments
;	check blank line

	SPC := (' ')			; DECUS C preprocessor needs this

  func	cl_red
	txt : * char~			; line to reduce
	()  : int			; fail => empty line
  is	lin : * char~ = txt		; a copy 
	dst : * char~ = txt		; in-place result
	ter : * char
	st_trm (txt)			; junk outerspace

      while *lin			; get the lot
	*lin = ' ' if *lin eq '\t'	; convert tabs to spaces
	case *lin			; handle leading stuff
	of SPC  quit if !ct_spc (lin[1]); not two spaces
;sic]		next ++lin		; skip second space
	or '\r'				; return
	or '\n' next ++lin		; newline
	of '!'  next *lin = 0		; comment
	of '\''				; '
	or '\"'	ter = st_bal (lin)	; " = balance it
		while lin lt ter	;
	        .. *dst++ = *lin++	;
		next			;
	of 3    fail *txt = 0		; ctrl/c - zap line
	end_case			; 
	*dst++ = *lin++			; keep any that falls thru
      end				; more
	*dst = 0			; terminate it
	st_trm (txt)			; cleanup trailing spaces
	reply *txt			; empty line state
  end
