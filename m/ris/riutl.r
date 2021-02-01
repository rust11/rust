file	riutl - various things
include rid:rider
include rib:eddef
include rib:ridef
include	rid:ctdef
include	rid:stdef
include	rid:medef

code	ut_idt - parse or skip an identifier

  func	ut_idt
	str : * char		
	idt : * char			; null to skip
	()  : * char			; past identifier in string
  is	while ct_aln (*str)		; got another
	|| *str eq '_'			;
	|| *str eq '$'			; for vax
	   if idt ne <>			; got a buffer
	   .. *idt++ = *str		;
	.. ++str			;
	*idt = 0 if idt ne <>		;
	reply str			; past it
  end

code	ut_tok - parse or skip a token

;	(...)		parenthetic
;	...		whitespace bound

  func	ut_tok
	str : * char		
	idt : * char			; null to skip
	()  : * char			; past identifier in string
  is	lim : * char = str		;
	if *lim eq '('			; parenthetic group
	   lim = st_bal (lim)		; get the end of it
	else				;
	   while *lim ne		;
	      quit if *lim eq ' '	;
	      if *lim eq '('		;
	      || *lim eq '\''		;
	      || *lim eq '\"'		;
	      || *lim eq '\''		;
	         lim = st_bal (lim)	; get the end of it
	      else			;
	.. .. .. ++lim			;
	if idt ne <>			;
	   me_mov (str, idt, lim-str)	;
	.. *<*char>that = 0		; terminate it
	reply lim			; past token
  end
code	ut_seg - extract segment name

  proc	ut_seg
	sec : * char			; section: func/proc/header etc
	str : * char			; string with name
  is	seg : [64] char			; segment name
	str = edPdot if str eq <>	;
	st_seg ("Spn", "AD$_", str, seg); get segment name
	exit if null			; forget it
	st_cop (seg, riAseg)		; keep it for messages
  end
