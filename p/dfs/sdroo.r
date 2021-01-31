;	convert to DCL
;	do sub-directories
;	support Windows
;	handle catch-up lines
;	skip match records for merge;
;	cache last half dozen input lines
;	enough to stop i/o block switching
;	Convert non-printing characters
;	Doesn't compare comments with /COMMENT
file	sdroo - srcdif root
include	rid:rider
include rid:fidef
include	rid:imdef
include	rid:medef
include	rid:mxdef
include dfb:sdmod

	lft : sdTsid = {0}
	rgt : sdTsid = {0}
	ctl : sdTctl = {0}
	csi : csTcsi = {0}
	opt : sdTopt = {0}

	sd_ini : ()
	sd_sid : (*sdTsid,int)
	sd_zap : ()

	sd_eng : ()
	sd_dif : (*sdTsid, *sdTsid) int
	sd_pai : () int
	sd_cmp : () int
	sd_rea : (*sdTsid, *sdTlin) int
	sd_nxt : (*sdTsid)
	sd_get : (*sdTsid) int
	sd_red : (*sdTsid) int
	sd_hsh : (*char) int

	sd_adv : (*sdTsid, *sdTlin)
	sd_sts : () int
	sd_pos : (*sdTlin, **long, int)

	sdGET := 0	; get position
	sdSET := 1	; put position
code	sd_ini - startup 

  func	start
  is	im_ini ("DIFFER")
	sd_cli ()
	sd_wld ()
  end

  func	sd_ini
  is	me_max () - 2048
	ctl.Vlim = that / (#sdTlin * 2)
	sd_sid (&lft, 0, &rgt)
	sd_sid (&rgt, 1, &lft)
	sd_dis (sdINI)
  end

  func	sd_zap
  is	me_dlc (lft.Pbas)
	me_dlc (rgt.Pbas)
  end

code	sd_sid - initialize side

  func	sd_sid
	sid : * sdTsid~
	idt : int
  is	buf : * sdTlin~ = me_acc (#sdTlin * ctl.Vlim)

	sid->Vsid = idt
	sid->Pbas = buf
	sid->Pfst = buf
	sid->Pmat = buf
	sid->Pcur = buf
	sid->Pipt = buf + 1
	sid->Plim = buf + ctl.Vlim
  end
code	sd_eng - difference engine

  func	sd_eng
  is	sd_ini ()			; setup sides
      while sd_sts () ne sdBTH		; until both at EOF
	next sd_dis (sdMAT) if sd_pai (); repeat matched line pairs
	repeat				; inch differences ahead on both files
	   quit if sd_dif (&lft, &rgt)	; get next left
	   quit if sd_dif (&rgt, &lft)	; get next right
	forever				;
      end				;
	sd_dis (sdFIN)			; finish up display
	sd_zap ()			; deallocate
  end

code	sd_dif - process a differences section

;	There is at least one difference in the arrays on entry

  func	sd_dif
	hea : * sdTsid~
	tai : * sdTsid~
  is	cur : * sdTlin = tai->Pcur	; rememember tail cur
	min : int = ctl.Vmin		; minimum match count
	tai->Pcur = tai->Pfst		; start with first in tail
	sd_adv (tai, &tai->Pcur)	; nudge to actual first
	sd_nxt (hea)			; inch ahead
      repeat				; search loop
	if sd_cmp ()			; got initial match
	   hea->Pmat = hea->Pcur	; save first match
	   tai->Pmat = tai->Pcur	;
	   min = ctl.Vmin		; minimum match count
	   spin while --min && sd_pai (); check minimum match
	   hea->Pcur = hea->Pmat	; restore first match
	   tai->Pcur = tai->Pmat	;
	.. quit if !min			; minimum, set, match
	fail if tai->Pcur eq cur	; ain't no more--fail
	sd_adv (tai, &tai->Pcur)	; continue search
      forever
	++ctl.Vdif			; count difference sections
	sd_dis (sdMIS)			; display missmatches
	sd_dis (sdMAT) if ctl.Vdis ne sdMRG ; display match
	if hea->Pfst ne hea->Pcur	; sanity check
	|| tai->Pfst ne tai->Pcur	;
	.. im_rep ("F-Difference engine broken", <>)
	fine
  end

code	sd_pai - get a pair and compare

  func	sd_pai
  is	sd_nxt (&lft), sd_nxt (&rgt)
	reply sd_cmp ()
  end
code	sd_cmp - compare lines

;	There's a 1-in-64k chance that missmatched lines will share
;	a hash code and line length. There's an infintessimal chance 
;	that two such lines will be found in close proximity. Well, 
;	that's the theory.

  func	sd_cmp
	()  : int			; true=same
  is	src : * sdTlin~ = lft.Pcur
	dst : * sdTlin~ = rgt.Pcur
	case sd_sts ()
	of sdBTH fine			; EOF && EOF is fine
	of sdONE fail			; EOF && !EOF fails
	end case

	fail if src->Vhsh ne dst->Vhsh	; hash codes different
	fail if (src->Vflg & sdLEN_) ne (dst->Vflg & sdLEN_)
	sd_rea (&lft, src), sd_rea (&rgt, dst)
	fine if st_sam (lft.Ared, rgt.Ared)

;	If they're not the same then make sure we don't
;	have a corrupted data scheme or buggy algorithm.

	if sd_hsh (lft.Ared) ne src->Vhsh
	|| sd_hsh (lft.Ared) ne src->Vhsh
	.. im_rep ("F-File model corrupted", <>)
	fail				; lines were different
  end

code	sd_rea - reread a line

  func	sd_rea
	sid : * sdTsid~
	lin : * sdTlin~
	()  : int				; fail=>EOF line
  is	pos : long				;
	if sd_eof (lin)				; does not exist
	.. fail sid->Alin[0] = sid->Ared[0] = 0	; blank line (for display)
						;
	sd_pos (lin, &pos, sdGET)		; get the line position
	if !fi_see (sid->Hfil, pos)		; seek to input position
	|| fi_get (sid->Hfil, sid->Alin, mxLIN) eq EOF	; get line
	|| !sd_red (sid)			; reduce the line
	.. im_err ("F-Error restoring line", <>);
	fine
  end
code	sd_nxt - point at next line in stream

  func	sd_nxt
	sid : * sdTsid~
  is	sd_adv (sid, &sid->Pcur)	; continue search
	if sid->Pcur eq sid->Pfst	; out of space
	.. im_err ("E-Too many differences", "")
	exit if sd_eof (sid->Pcur)	; nothing changes
	if sid->Pcur eq sid->Pipt	; time for more
	   sd_get (sid)			; get it
	.. sd_adv (sid, &sid->Pipt)	; next line is input
  end

code	sd_get - get next line from side

;	Lines which aren't compared are skipped
;	The display sub-system reconstructs such lines, page numbers etc

  func	sd_get
	sid : * sdTsid~
	()  : int				; fine or EOF
  is	lin : * sdTlin~ = sid->Pcur
	fi_see (sid->Hfil, sid->Vipt)		; seek to input position
      repeat					;
	sd_pos (lin, &sid->Vipt, sdSET)		; store position
	sid->Alin[0] = 'Z'
	fi_get (sid->Hfil, sid->Alin, mxLIN)	; get next line
	fail lin->Vflg |= sdEOF_ if EOF		; this ends right here
	sid->Vipt = fi_pos (sid->Hfil)		; reset that for next time
	next if !sd_red (sid)			; next time is right now
	lin->Vhsh = sd_hsh (sid->Ared)		; hash reduced line
	st_len (sid->Ared) << sdLEN		; get length in place
	lin->Vflg |= (that & sdLEN_)		; remember length
	fine					;
      forever
  end
code	sd_red - reduce line

  func	sd_red
	sid : * sdTsid
	()  : int
  is	lin : * char = sid->Alin
	red : * char~ = sid->Ared
	cha : int~
	len : int~ = 0
	prv : int = ' '
	fst : int = 0

 	while (*lin & ctl.Veig) ne
	   cha = *lin++ & ctl.Veig		; get and mask character
	   next if cha eq '\f'			; skip all form feeds
	   cha = ch_cvt (cha, 1) if !ctl.Vexa	; not exact - convert
	   quit if cha eq ctl.Vcmt && prv eq ' '; space-comment ends it
	   if !ctl.Vspc				; not comparing spacing
	   && ((cha eq ' ') || (cha eq '\t'))	; and have space
;sic]	      next if !len			; ignore leading spaces
	      cha = ' ' if cha eq '\t'		; reduce tabs
	   .. next if prv eq ' '		; fold 
	   *red++ = prv = cha, ++len		; accept character
	end					;
						;
	if ctl.Vtrm				; remove trailing spaces
	.. --red, --len while len && red[-1] eq ' ' ;
	*red = 0				; terminate line buffer
	reply len || ctl.Vblk			; blanklines test
  end

code	sd_hsh - hash string

  func	sd_hsh
	str : * char~
	() : int
  is	hsh : int~ = 0			;
	tmp : int~ = 0			; intermediate value
					;
	while *str			; for each character
	   tmp = *str++ & 0377		; get low part of word hash
	   if *str			; got another character
	      tmp |= *str++ << 7	; or in high byte
	   else				; no more characters
	      tmp | (*str << 7)		; use first character instead
	   .. tmp = -that		; and negate it
	   hsh ^= (hsh+tmp)		; hsh = (hsh+wrd) xor hsh
	end				;
	reply hsh			;
  end
code	sd_adv - advance a line pointer

  func	sd_adv
	sid : * sdTsid~
	ptr : ** sdTlin
  is	lin : * sdTlin~ = *ptr
	exit if sd_eof (lin)		; sit on this forever
	lin = sid->Pbas if ++lin eq sid->Plim ; advance and wrap
	*ptr = lin
  end

code	sd_pos - get/set line file position

  func	sd_pos
	lin : * sdTlin~
	pos : * long
	opr : int
  is	wrd : * WORD~ = <*void>pos
	if opr eq sdGET
	   wrd[0] = lin->Vflg & sdHOP_
	   wrd[1] = lin->Vpos
	else ; opr eq sdSET
	  lin->Vflg = wrd[0] & sdHOP_
	  lin->Vpos = wrd[1]
	end
  end

code	sd_sts - status EOF check

	sdNON := 0
	sdONE := 1
	sdBTH := 2

  func	sd_sts
	()  : int
  is	res : int~ = 0
	++res if sd_eof (lft.Pcur)
	++res if sd_eof (rgt.Pcur)
	reply res
  end
code	sd_dis - display match or missmatch

  func	sd_dis
	tsk : int
  is	case ctl.Vdis
	of sdNOP  nothing
	of sdMRG  sd_mrg (tsk)		; merged
	of sdCHG  sd_chg (tsk)		; changebar
	of sdPAR  sd_par (tsk)		; parallel
	end case
  end

code	sd_tak - take an element to display

  func	sd_tak
	sid : * sdTsid~
	cas : int
	()  : * char
  is	nxt : * sdTlin = sid->Pfst
	gap : * char
	sd_adv (sid, &nxt)
;	reply gap if (gap = sd_gap (sid, nxt)) ne
	case cas
	of sdMIS fail if nxt eq sid->Pcur
	or sdMAT fail if sid->Pfst eq sid->Pcur
	end case
	sid->Pfst = nxt
	fail if sd_eof (nxt)
	sd_rea (sid, nxt)
;	sid->Vopt = fi_pos (sid->Hfil)
	reply ctl.Vedi ? sid->Ared ?? sid->Alin
  end

  func	sd_hdr
  is	exit if ctl.Vhdr
	++ctl.Vhdr
	fine sd_dis (sdHDR)
  end

  func	sd_log
  is	sd_dis (sdLOG)
  end

  func	sd_typ
	lin : * char
  is	fi_wri (opt.Pfil, lin, st_len (lin))
  end

  func	sd_prt
	str : * char
  is	exit if !ctl.Vopt
	fi_put (opt.Pfil, str)
  end
end file
