file	ricas - case statements
include rid:rider
include rid:chdef
include rid:imdef
include rid:stdef
include rib:eddef
include rib:ridef

;	case val		switch (val) {	
;	of val			break; case val: 	
;	or val			       case val: 
;	end_case		}
;
;	first [of] elides break
;
;	of ... statement
;	or ... statement
;	of other statement
;	of/or ... to ...
;
;	of/or are handled during buffering 

	riKcas := 32			; 32 nested cases
	riVcas : int = 0		; case index
	riAcas : [riKcas] int = {0}	;

code	ri_orf - or/of preprocessor

;	or/of ...
;	or/of (...)
;	or/of ... to ...

  proc	ri_orf
	brk : int			; break flag
  is	buf : [128] char		; label output
	lab : * char~ = buf		; setup pointer
	dot : * char~ = edPdot		;
	*lab = 0			; terminate label
					;
	if not riAcas[riVcas]		; not in case
	   if riVfil ne			; had 'file' statement
	   .. im_rep ("W-of/or not in case in (%s)", riAseg)
	.. riAcas[++riVcas] = 2		; don't treat as first
					;
	if brk				; needs break
	&& riAcas[riVcas] ne 1		; and not first case
	.. st_app (" break; ", lab)	; needs break first
	++riAcas[riVcas]		; count it
					;
	ed_del (" ")			; skip spaces
	if ed_del ("other")		; of/or other
	   st_app ("default: ", lab)	; label it
	   ri_idn (-1)			; indent
	   ri_prt (lab)			; write it
	.. exit				; and done
					;
	st_app ("case ", lab)		; case
	dot = ut_tok (dot, that)	;       ' '
	st_app (":", lab)		; 	   :
	ri_idn (-1)			; indent
	ri_prt (lab)			; display it
	st_mov (dot, edPdot)		; reduce line
	ed_del (" ")			; dump leading spaces
  end
code	kw_cas - case statement

  proc	kw_cas
  is	ed_pre ("switch (")		; switch (...
	ed_app (")")			; switch (...)
	ri_beg ()			; new nest
	riAcas[++riVcas] = 1		; first case
  end

code	kw_eca - end-case statement

  proc	kw_eca
  is	ri_end ()			; just end it
	if not riVcas			; not in case
	   im_rep ("W-end_case not in case in (%s)", riAseg)
	.. else	--riVcas		;
  end

code	kw_or - handle of ... to ...

;	Handles single character literals only - 16 per line

  proc	kw_or
  is	buf : [128] char		; label output
	lab : * char = buf		; setup pointer
	dot : * char~ = edPdot		; 
	cha : char~			;
	ter : char			;
	cnt : int			;
;?	if *lab				; got break
;?	.. ri_prt (lab)			; write break; if necessary

;	'a' to 'b'

	cha = dot[1]			; character
	ter = dot[8]
	dot[1] = 'a'			; reset it
	dot[8] = 'a'			;
	if (st_cmp (dot, "'a' to 'a'")) ; failed
	   dot[1] = cha			; reset it
	.. dot[8] = ter			;

;	write out the cases

	st_mov ("case 'a': ", lab)	; startup label
	cnt = 8				;
	while cha ne ter		;
	   if --cnt eq			; a newline
	      cnt = 8			; reset it
	   .. ri_new ()			; put it
	   lab[6] = cha			; next case
	   ri_dis (lab)			; write it
	   if ter gt cha		; up to it
	      ++cha			; up
	.. .. else --cha		; down
	ri_new ()			; done
	++riVsup			; line done
  end
