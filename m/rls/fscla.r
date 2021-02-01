file	ficla - wildcard file classes
include rid:rider
include	rid:fsdef
include rid:mxdef
include	rid:stdef

;	fs_cla (spc, *fsTcla)
;
;	cla->V

;	This module assumes that NOD..VER are sequential for
;	the file masks and fsTcla.
;
; 	A note on the search string "?%*". "*" comes last so
;	that if it's seen as first character in the reduction
;	then we know that "?%" aren't present.

  func	fs_cla
	spc : * char
	cla : * fsTcla~
  is	com : * char~ = <*char>(cla)
	buf : [mxSPC] char
	red : [mxSPC] char
	ptr : * char
	msk : int~ = fsNOD_

	cla->Vwld = 0
	cla->Vmix = 0
      while msk le fsVER_
	*com = 0
	fs_ext (spc, buf, msk)		; extract the field
	st_int ("%?*", buf, red)	; filter all but these
	*com |= fsBLK_ if !buf[0] 	; it's blank
	if red[0]			; have wild cards
	   *com |= fsWLD_ 		; has wild cards
	   ptr = red			; check what we have
	   while *ptr			;
	      if !st_mem (*ptr, ":\\.;%?*"); punctuation
	      ..  *com |= fsMIX_	; mixed wildcards
	      ++ptr			;
	.. end				;
	if !(*com & fsMIX_) 		; not mixed
	&& red[0] eq '*'		; and only '*' (see st_int ())
	.. *com |= fsANY_		; plain "*" or "**" etc
	cla->Vwld |= msk if *com & fsWLD_
	cla->Vmix |= msk if *com & fsMIX_
	msk <<= 1, ++com
      end
  end
