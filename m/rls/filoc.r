file	filoc - convert to local specification
include	rid:rider
include	rid:fidef
If !Pdp
include	rid:stdef
include	rid:mxdef
include	rid:ctdef
include	rid:lndef
include	rid:medef
End

  proc	fi_loc
	spc : * char			; file spec
	loc : * char			; result area (can be same as spc)
  is
If Pdp
	st_cop (spc, loc)
Else
  	nxt : * char			; next character of interest
	cnt : int = 0			; count \'s
	quo : int = 0			; needs quotes wrapped at end

     repeat
	fi_trn (spc, loc, 0)		; translate before localisation

;	st_cop (spc, loc)		; return in result area

;	Remove versions (;xxx)

	nxt = st_fnd (";", loc)		; look for version
	*nxt = 0 if ne			; scrap versions

;	Convert (`) to space

	while (nxt=st_fnd("`", loc)) ne	; find pseudo space
	.. ++quo, *nxt = ' '		; replace with a space

;	xxx	Done if no colon (:)
;	x:	Done if single character device name

	nxt = st_fnd (":", loc)		; find colon
	quit if null			; no device
	quit if loc[1] eq ':'		; single char device name
					
;	Done if "con", "conin$" or "conout$"

	*nxt = 0			; terminate it a second
	if st_sam (loc, "con")		;
	|| st_sam (loc, "conin$")	;
	|| st_sam (loc, "conout$")	;
	.. quit				; leave it untouched
					;
;	Strings that begin with underline (_) have the
;	underline removed and have no further processing.

	if *loc eq '_'			; starts with "_"
	   me_mov(loc+1,loc,st_len(loc)); delete the underline
	.. quit				; and done

;	Otherwise (xx) is converted to (\xx\)

	*nxt = '\\'			; replace with '\'
	st_ins ("\\", loc)		; another up front
     never
	if quo
	   st_ins ("\"", loc)		; wrap in quotes
	.. st_ins ("\"", st_end (loc))	;
End
  end
If !Pdp
code	fi_trn -- translate file spec

  func	fi_trn
	spc : * char
	res : * char
	mod : int			; 1 =>
	()  : int			; fails if no space
  is	lft : [mxSPC] char		;
	rep : [mxSPC] char		;
	trm : * char			;
	idx : int			;
	cnt : int = 16			; maximum 16 levels of redirection
	fst : int = *spc		; save first character
	trn : int = 0			;
	st_cop (spc, res)		; default translation

      while cnt--			;
	st_cop (res, lft)		; get a copy
					;
	if (trm = st_fnd (":", lft)) ne	; find the colon
	   *trm++ = 0			; drop and skip colon
	else				;
	   trm = lft			; search for non-alphanumeric
	   while *trm			;
	.. .. fine if !ct_aln (*trm++)	; got punctuation
					;
	if !ln_trn (lft, rep, 0) 	; attempt translation
	   fine if trn			; already translated once
	   fine if !(mod & 1)		; nothing to translate
	.. reply -1			; didn't translate
	++trn				; remember we translated
					;
	st_len (rep) + st_len (trm)	;
	fail if that gt (mxSPC-4)	; no room for translation
					;
	if *trm				; filename following
	&& *st_lst (rep) ne '\\'	; no terminating '\'
	&& *trm ne '\\'			; and none coming
	.. st_app ("\\", rep)		; add one
					;
	st_app (trm, rep)		; append filename part
	st_cop (rep, res)		; bingo
	fine if !st_fnd (":", res)	; any more to translate?
;	fine if fst eq '@'		; these do not loop
     end
	fail
  end

End
end file

; to dos
;	d:f.t	=>	d:f.t		if #d = 1
;			\d\f.t		otherwise
;
;	[s]f.t		\s\f.t
;	[s.s]f.t	\s\s\f.t
;
;	con
;	conin$
;	conout$				no further translation
;	x`y		x y		"^" replaced by space
;	_x:		x:		no further translation
;	x:				single character devices accepted
;	xx:yyy		xx\yy
;	xx:		xx\
;
;	other		...\		
;
; to vms
;
;	d:f.t	=>	d:f.t
;	\s\f.t		[s]f.t
;	\s\s\f.t	[s.s]f.t
;
;	Program`Files
;
;
; fi_trn
;
;	Isolate device part and translate it
;
; ???	@...		no recursive translation
;
;	aaa		an alphanumeric string
;	xxx		any string
;	yyy		any string
;	
;	xxx:yyy		xxx is translated
;			'\' inserted as separator if necessary:
;			if xxx translates
;			if translation does not end with '\'
;			if yyy is non-null
;			if yyy does not start with '\'
;	aaa		aaa is translated
If vms
	if ferror (fil->Pfil) ne	; had an error
	.. im_rep ("E-File input error [%s]", fil->Aspc)
End

If vms
	if *mod eq 'w'			; a new file
	   fil->Pfil = fopen (spc, mod, "RFM=STM") ; create stream file
	else				; an old file
	.. fil->Pfil = fopen (spc, mod)	; attempt open
Else
	fil->Pfil = fi_opn (spc, mod,""); open it
End
