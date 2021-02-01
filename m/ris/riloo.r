;***;	RIS:RILOO - End code for generic block handling (and REPEAT IF)
file	riloo - for and repeat
include rid:rider
include rib:eddef
include rib:ridef
include	rid:imdef
include	rid:stdef
include	rid:medef

code	kw_for - for statements

;	Called by kw_whi in ripar when (in) seen
;	edPdot points at the variable
;
;	while var in sta..end 		for (var=sta; var<=end; ++var)
;	while var in end		     var=0
;	while var in sta..end by stp
;			      by -1		      var>=end;	--var
;			      by ...				var+=...
;	while var down ...

	foAvar : [64] char- = {0}	; local storage
	foAbas : [64] char- = {0}	;
	foAlim : [64] char- = {0}	;
	foAstp : [64] char- = {0}	;

  proc	kw_for
  is	var : * char~ = foAvar		; mein variable
	bas : * char~ = foAbas		; mein base wert
	lim : * char = foAlim		; mein limit wert
	stp : * char~ = foAstp		; mein step wert
	dwn : int = 0			; down to
	st_cop ("+1", stp)		; normale step wert
					;
	if ed_sub (" down ", "", var) ne <>
	   dwn = 1			; going down
	elif ed_sub (" in ", "", var) eq <> ; get the variable
	   im_rep ("W-Invalid [while] in [%s]", riAseg)
	.. exit				;
	ed_sub ("..", "", bas)		; get the base
	st_cop ("0", bas) if <>		; use default
	ed_sub (" by ", "", lim)	; get the limit
	st_cop (edPdot, lim) if <>	; no by - remainder is limit
	st_cop (edPdot, stp) otherwise	; got by - remainder is step
	ed_tru ()			; drop the gunk
					;
	ed_app ("for (")		; for (
	ed_app (var)			;	var
	ed_app (" = (")			;	   =(
	ed_app (bas)			;	     bas	
	ed_app ("); ")			;		);	
	ed_app (var)			;	var
					;
	ed_app ("<=(") if dwn eq	;	   <=(
	ed_app (">=(") otherwise	;	   >=(
					;
	ed_app (lim)			;	     lim
	ed_app ("); ")			;		);
	if dwn				; down
	|| st_cmp (stp, "-1") eq	; -1
	   ed_app ("--")		;	--
	   ed_app (var)			;	  var
	elif st_cmp (stp, "+1") eq	; +1
	   ed_app ("++")		;	++
	   ed_app (var)			;	  var
	else				;
	   ed_app (var)			;	var
	   ed_app (" += (")		;	   +=(
	   ed_app (stp)			;	     stp	
	.. ed_app (")")			;
	ed_app (")")			;		;) {
	ri_beg ()			; indent it and append '{'
  end
code	kw_rpt - repeat keyword
	
;	repeat 			for(;;) {
;	repeat if cnd		for(;;) { if (!(cnd)) break;

  proc	kw_rpt
  is	if not ed_del (" if")		; no condition
	    ed_pre ("for(;;) ")		;
	    ri_beg ()			; do {
	.. exit				;
					;
	im_rep ("W-Obselete (repeat if) in [%s]", riAseg)
	ed_pre ("for(;;) { if (!(")	;
	ed_app (")) break;")		; put at end
	ri_put ()			; put it out
	++riVnst			; up nest
	++riVsup			; already out
  end

code	kw_nvr - never keyword

  proc	kw_nvr 
  is	--riVnst			; down
	ed_pre (" break;} ")		;
  end

code	kw_fvr - forever keyword

  proc	kw_fvr
  is	--riVnst			; down
	ed_pre ("} ")			;
  end

code	kw_unt - until keyword

;	until cnd

  proc	kw_unt
  is	ri_cnd ("if", "break;")		; if (cnd) break; 
	ed_app (" }")			;		 }
	--riVnst			;
  end

code	kw_cnt - count keyword

;	count var

  proc	kw_cnt
  is	--riVnst			; adjust nesting
	ed_pre (" if (--(")		; if (--(
	ed_app (") <= 0) break;}")	;	 var)) > 0) break;
  end
end file

;	repeat if cnd		do { if (!(cnd)) break;
;	
;	until cnd		} while (!( cnd ));
;	until cnd <nl> && cnd	} while (!((cnd) && (cnd)));
;
;	if (cnd) break; } while (1);
  proc	kw_unt
  is	ri_cnd ("if", "break;")		; do the code
	int neg = 0			; negated
	--riVnst			; nest level down
	neg = ri_neg ()			; handle 'until not'
					;
	if riVcnd eq			; no conditional coming
	   ed_pre ("} while (")		; simple stuff
	   ed_app (");")		;
	.. exit				;

;	until ...\ && ...

	ed_pre ("} while (")		; } while ( (xxx) && (yyy) )
	repeat				;
	   ri_put ()			; dump it
	   ri_get ()			; get the next
	   ed_pre ("(")			; && (
	   ed_app (")")			;	    ... )
	until not riVcnd		; not the last
					;
	ed_app (");")			; all over
  end

code	ri_neg - setup negated test

  func	ri_neg 
	()  : int			; 1=> negated test
  is	ri_eql (edPdot)			; check a = b condition
	fail if ed_del (" !")		; got not
	ed_pre ("!(")			; negate inner
	ed_app (")")			; close inner
	fine				; is negated test
  end

code	kw_end - handle end of something

  proc	kw_end
  is	cla : int
	cla = bl_cla ()			; get current class
	case bl_cla ()			; do it
	of blNON			; nothing
	of blHDR			; header ...
		  im_rep ()		;
	of blCAS  kw_eca ()		; end case
	of blRPT  kw_fvr ()		; handle as forever
	of other			;
		  bl_end ()		; end it
	end case			;
  end

code	block control

;	Called by while, repeat, if, case

	blCLA_	:= 15			; loop class
	blNON	:= 0			; not in block
	blINI	:= 1			; an initializer
	blFUN	:= 2			; a function
	blBLK	:= 3			; a begin/end
	blCND	:= 4			; a conditional
	blCAS	:= 5			; a case block
	blWHI	:= 6			; a while
	blFOR	:= 7			; a for
	blRPT	:= 8			; a repeat block
					;
	blQUI_	:= BIT(4)		; had a quit
	blNXT_	:= BIT(5)		; had a next
					;
	blVlev	: int = 0		; loop level
	blAtab	: [64] char = {0}	; loop flag array

  func	bl_beg 
	cla : int
  is	++blVlev			; next level
	if blVlev ge 64			; too many
	   im_rep ("E-Nesting to deep [%s]", riAseg)
	.. blVlev = 63			;
	blAtab[blVlev] = cla		; setup the class
  end

 code	bl_end - end block and return its flags

 func	bl_end
	()  : int
  is	reply 0 if blVlev eq		; are none to exit
	reply blAtab[blVlev--]		; send it back
  end

code	bl_set - set flags for current block

  func	bl_set
	flg : int
	()  : int			;
  is	reply 0 if blVlev eq		; not in a loop
	blAtab[blVlev] |= flg		; set it
	reply flg			;
  end

code	bl_cla - get current block class

  func	bl_cla
	()  : int
  is	reply 0 if blVlev eq		; no class
	reply blAtab[blVlev] & blCLA_	; send it
  end
