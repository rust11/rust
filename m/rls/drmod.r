file	drmod - directory access
include	rid:medef
include	rid:mxdef
include	rid:stdef
include	rid:tidef
include	rid:fidef
include <stdio.h>
include <stdlib.h>
include	rid:drdef

	dr_acc	: (*drTdir, *drTent) *drTent own
	dr_srt	: (*drTdir) int own

code	dr_scn - scan directory

  func	dr_scn
	raw : * char			; the raw file spec
	atr : int			; the attributes
	srt : int			; sort 
	()  : * drTdir			; result
  is	pth : * char = me_acc (mxSPC)	;
	dir : * drTdir = me_acc (#drTdir)
	ent : * drTent = me_acc (#drTent)
	prv : * drTent = <>		;
					;
	dir->Ppth = pth			;
	dir->Vatr = atr			; attributes
	dir->Vsrt = srt			; sort criteria
;sic]	dir->Pnxt = <>			; init next logic
	dr_pth (raw, pth)		; get the path
	if !dr_acc (dir, ent)		; get the first one
	   me_dlc (ent)			; nothing found, free it
	   me_dlc (dir)			; nothing found, free it
	   fail				;
	else				;
	   dir->Proo = ent	 	; this is the first
	   while ent ne <>		; collection loop
	      prv->Psuc = ent if prv	;
	      prv = ent, ++dir->Vcnt	; for next time around, count it
	      ent = dr_enu (dir, <>, 0, 1) ; get more
 	   end				;
	   dr_don (dir)			; release resources
	.. dr_srt (dir) if srt		; sort the directory
	reply dir			;
  end

code	dr_nxt - get next entry

  func	dr_nxt
	dir : * drTdir
	()  : * drTent
  is	ent : * drTent
	fail if !dir			; no directory
	ent = dir->Pnxt	; get the next
	ent = dir->Proo if ent eq <>	; the first
	ent = ent->Psuc otherwise	; successor
	reply <> if ent eq <>		; all done
	reply (dir->Pnxt = ent)		; remember it
  end

code	dr_dlc - deallocate directory

  proc	dr_dlc
	dir : * drTdir			; may be null
  is	nxt : * drTent			; next
	cur : * drTent			;
	exit if dir eq <>		;
	nxt = dir->Proo			; first entry
	while nxt ne <>			; got more
	   cur = nxt, nxt = cur->Psuc	; remove it
	   me_dlc (cur->Pnam)		;
	   me_dlc (cur->Palt)		;
	   me_dlc (cur)			;
	end				;
	me_dlc (dir->Ppth)		;
	me_dlc (dir->Pext)		;
	me_dlc (dir)			; deallocate dir block
  end
code	dr_srt - sort entries

 	dr_cmp : (*void const, *void const) int own ; compare
	drVsrt : int own = 0		; sort criteria
	drVrev : int own = 0		; reverse sort

  func	dr_srt				;
	dir : * drTdir			; the sort
	()  : int own			;
  is	tab : ** drTent			;
	ent : ** drTent			;
	fil : * drTent			;
	cnt : int = dir->Vcnt		; number of entries
	wid : size = #<*drTent>		; pointer width
	chk : int = 0			;
	fine if cnt le			; forget those
	fail if cnt gt 15000		; enough is enough
					;
	tab = me_alc (wid * cnt)	; make a table
	fail if null			; no room
	ent = tab			; first entry
	fil = dir->Proo			;
	while fil ne <>			;
	   if ++chk le cnt		;
	   .. *ent++ = fil		; fill in the table
	   fil = fil->Psuc		;
	end				;
	drVsrt = dir->Vsrt & drSRT_	; sort criteria
	drVrev = dir->Vsrt & drREV_	;
	qsort (tab, cnt, wid, &dr_cmp)	; sort them
	ent = tab			; first entry
	dir->Proo = fil = *ent++	; get the first
	while --cnt			; got more
	   fil->Psuc = *ent		; point it 
	   fil = *ent++			; move along
	end				;
	fil->Psuc = <>			; block the last
	me_dlc (tab)			; dump that
	fine				;
   end

code	dr_cmp - compare two members

  func	dr_cmp
	src : * void const
	dst : * void const
	()  : int
  is	lft : * drTent = *(<**drTent>src)
	rgt : * drTent = *(<**drTent>dst)
	ltp : * char
	rtp : * char
	cmp : int
      repeat					; fail block
	cmp = (rgt->Vatr & drDIR_) - (lft->Vatr & drDIR_)
	quit if ne				; directories first always
	if drVsrt eq drSIZ			; size 
	   cmp = lft->Vsiz - rgt->Vsiz		;
	elif drVsrt eq drTIM			; time
	.. cmp = ti_cmp (&lft->Itim, &rgt->Itim)
	if cmp eq				; name
	   if drVsrt eq drTYP			; by type
	      ltp = st_fnd (".", lft->Pnam)	;
	      ltp = "" if null			;
	      rtp = st_fnd (".", rgt->Pnam)	;
	      rtp = "" if null			;
	      cmp = st_cmp (ltp, rtp)		; compare types
	   .. quit if cmp ne			; different types
	.. cmp = st_cmp (lft->Pnam, rgt->Pnam)	; compare names
      never					;
	reply (drVrev) ? -cmp ?? cmp		; handle reverse
  end
code	dr_acc - access first file

  func	dr_val
	pth : * char
  is	dir : drTdir = {0}
	ent : drTent = {0}
	dir.Ppth = pth
 	reply dr_acc (&dir, &ent) ne
  end

  proc	dr_acc
	dir : * drTdir			;
	ent : * drTent			;
  	()  : * drTent own		; the entry
  is	pth : * char = dir->Ppth	; the basic path
	atr : int = dir->Vatr | drFST_	; the attributes
	nxt : * drTent	 		; next file block
	ptr : * char			;
	wld : int = 0			;

;	xxx:		xxx:*.*
;	xxx\.		xxx\*.
;	xxx:.		xxx:*.
;	xxx.		xxx.*

	if (ptr = st_fnd (":", pth)) ne	; xxx:
	   if st_cmp (":\\", ptr) eq	; xxx:\
	.. .. st_app ("*.*", pth)	; xxx:\*.*
					;
	if (ptr = st_fnd ("\\.",pth)) ne; \xxx\.yyy
	|| (ptr = st_fnd (":.", pth)) ne; xxx:.yyy
	.. st_ins ("*", ptr+1)		; \xxx\*.yyy
	if *(ptr = st_lst (pth)) eq '.'	; xxx.
	   st_app ("*", pth)		; xxx.*
	elif *ptr eq ':'		; xxx:
	   st_app ("\\*.*", pth)	; xxx:\*.*
	elif *ptr eq '\\'		; xxx\
	.. st_app ("*.*", pth)		; xxx\*.*
					;
	++wld if st_mem ('*', pth)	; got a wildcard
	++wld if st_mem ('?', pth)	;
	if wld && !st_mem ('.', pth)	;
	.. st_app (".*",pth)		;
;PUT("[%s]\n", pth)
					;
	nxt = dr_enu (dir, ent, atr|drDIR_, 0)
	if null				; failed
	   if !st_mem ('.', pth)	;
	      st_app (".*", pth)	; add one
	   .. nxt = dr_enu (dir, ent, atr, 0)
	else				; found
	   if (nxt->Vatr & drDIR_) && !wld ; the first is a directory
	      st_app ("\\*.*", pth)	; search its files
	.. .. nxt = dr_enu (dir, ent, atr, 0) ; now without directory
	reply <> if nxt eq		; failed 
					;
	if nxt->Vatr & drDIR_		; got directory on first
	&& (atr & drDIR_) eq		; but were not requested
	.. nxt = dr_enu (dir, ent, atr, 1) ; get another
	reply nxt			;
  end
code	dr_pth - work out path

;	xxx:		xxx:\
;	xxx:aaa		xxx:\aaa
;	\aaa		DRV:\aaa
;	aaa		DRV:\DIR\aaa
;
;	Where DRV and DIR and the current device/directory.
;
;	This code does not implement the DOS convention of a default
;	directory per drive. No other system supports that convention.

  proc	dr_pth 
	spc : * char			; partial file spec
	pth : * char			; result path
  is	buf : [mxSPC] char		;
	src : * char = buf		;
 	drv : * char = pth		; where the drive went
	*src = 0			;
	fi_loc (spc, src)		; make a local spec
	st_low (src)		; ???	; all lower case for us
	*pth = 0			;
					;
	if *st_lst (src) eq ':'		; just a device?
	   st_cop (src, pth)		; yes
	   st_app ("\\", pth)		; default it
	   exit				;
	elif !st_fnd (":", src)		; no device specified
	   if *src eq '\\'		; what do we need
	      dr_sho (pth, drDRV)	; just the drive
	      pth = st_end (pth)	;
;	      pass fail			;
	   else				;
	      dr_sho (pth, drPTH)	;
;	      pass fail			;
	      if *st_lst (pth) ne '\\'	; not root directory
	      .. st_app ("\\", pth)	; needs trailing
	   .. pth = st_end (pth)	;
	else				;
	   *pth++ = *src++ while *src ne ':'
	   *pth++ = *src++		; copy the colon
	.. *pth++ = '\\' if *src ne '\\'; no directory
	st_cop (src, pth)		; copy the rest
  end
code	dr_spc - form full file spec

;	pth	c:\d1\d2\f1.t1
;	nam	f2.t2
;	spc	c:\d1\d2\f2.t2
;
;	nam=<>	returns directory part of spec

  func	dr_spc
	pth : * char			;
	nam : * char			; "file", "", <>
	spc : * char			;
	()  : * char			; past parse
  is	lst : * char			;
	st_cop (pth, spc)		; get the path
	st_low (spc)			; lower the lot
	*st_par ("pe","\\", spc) = 0	; truncate past final \
	if nam ne <>			; want dir\name
	.. reply st_app (nam, spc)	; result is past spec
					;
;	Want parent directory of spec

	lst = st_lst (spc)		; look at final character
	if *lst eq '\\'			; ends as directory
	&& lst ne spc			; not the only character
	&& lst[-1] ne ':'		; and not root directory
	&& lst[-1] ne '\\'		; and not node name
	.. *lst = 0			; remove final \
	reply lst			; actually past
  end
code	dr_mat - match directory file

  func	dr_mat
	dir : * drTdir
	nam : * char
  is	buf : [256] char
	mod : * char = st_par ("pb", ":\\", dir->Ppth)
	fail if !dir
	st_cop (nam, buf)
	st_app (".", buf) if st_idx ('.', buf) lt
	reply st_wld (mod, buf)
  end

code	dr_roo - determines if spec is root directory

  func	dr_roo
	spc : * char
  is	pth : [mxSPC] char		; directory path
	dr_spc (spc, <>, pth)		; get the directory path
	fine if st_sam (pth, "\\")	; root
	fine if st_sam (pth+1, ":\\")	;
	fail
  end
end file

  proc dr_dum
	spc : * char
  is	dr_roo (spc)
  end
