;	Convert non-printing characters
;	Doesn't compare comments with /COMMENT
opt$c := 1
;minrite errors???
file	srcdif - compare text files
include	rid:rider
include rid:fidef
include	rid:fsdef
include	rid:imdef
include	rid:medef
include	rid:mxdef
include rid:rtcli
include	rid:rtcsi
include	rid:rtdir
include dfb:sdmod

	sd_sum : ()-
	sd_opn : (*sdTsid) int-
	sd_rep : (*char, *char)-
	sd_sum : ()-

code	sd_wld - wildcard driver

  func	sd_wld
  is	src : * sdTsid~ = &lft
	dst : * sdTsid~ = &rgt
	scn : * rtTscn = ctl.Pscn
	pth : [mxPTH] char
	nam : [mxNAM+mxTYP] char
	cnt : int = 0
	sig : int = 0

	fs_cla (lft.Pspc, &lft.Icla)	; get wildcard flags
	fs_cla (rgt.Pspc, &rgt.Icla)	;

	if (lft.Icla.Vwld & fsPTH_)	; device/directory wildcards
	.. fail im_rep ("E-Invalid wildcards %s", lft.Pspc)
	if (rgt.Icla.Vwld & fsPTH_)	; 
	.. fail im_rep ("E-Invalid wildcards %s", rgt.Pspc)

	if !(lft.Icla.Vwld & fsFIL_)	; no wildcards
	&& !(rgt.Icla.Vwld & fsFIL_)	; also none
	   ctl.Vmis = 1			;
	   fail if !sd_opn (&lft) || !sd_opn (&rgt)
	.. exit sd_drv ()		; simple file to file

;	Choose a side which has wildcard
;	If both have wildcards, choose the with the least

;PUT("lft=%o rgt=%o\n", lft.Icla.Vwld, rgt.Icla.Vwld)

	if !(lft.Icla.Vwld & fsFIL_)	; right wild cards only
	|| (lft.Icla.Vwld gt rgt.Icla.Vwld)
	.. src = &rgt, dst = &lft	; so right drives

	if dst->Icla.Vmix & fsFIL_	; output can't be mixed
	.. fail im_rep ("E-Invalid wildcard combination %s", dst->Pspc)

	st_cop (lft.Pspc, lft.Pmod)	; specs become the models
	st_cop (rgt.Pspc, rgt.Pmod)	;

	fs_ext (src->Pmod, pth, fsPTH_)	; extract the path for scanning
	scn = rt_scn (<>, pth, rtPER_, "") ; scan directory
	exit if fail			; nothing doing
					; shouldn't come back for errors
	fs_ext (src->Pmod, nam, fsFIL_)	; extract name for matching
	if ctl.Vver			; wants verification
	   PUT("?SRCDIF-I-Scanning [%s%s] for matching [%s]\n",
	   pth, nam, dst->Pmod)
	end

      repeat
	fi_prg (lft.Hfil, <>)		; release files
	fi_prg (rgt.Hfil, <>)		;
	me_max ()			; merges all empties

	rt_wld (scn,nam,src->Pspc,"")	; scan another
	quit if fail			; no more or error

	st_ins (pth, src->Pspc)
	fs_res (src->Pspc, dst->Pmod, dst->Pspc)

	if !sd_opn (&lft) || !sd_opn (&rgt)
	   if ctl.Vnew
	   .. PUT("%-14s  ???\n", lft.Pspc)
	.. next

	if ctl.Vver
	   PUT("?SRCDIF-I-Comparing [%s] with [%s]\n", 
	      lft.Pspc, rgt.Pspc)
	end
	++cnt

;	if !sig
	   quit if !sd_drv ()		; engine failed
;	else
;	.. im_rep ("W-Too many differences %s", lft.Pspc)

      end
	if !cnt
	.. im_rep ("E-No matching file for %s", lft.Pmod)
  end

  func	sd_opn
	sid : * sdTsid~
	()  : int
  is	fine if (sid->Hfil = fi_opn (sid->Pspc, "r", <>))
	if ctl.Vmis
	.. PUT("?SRCDIF-I-File not located %s\n", sid->Pspc)
	fail
  end
code	sd_drv - srcdif driver

  func	sd_drv
  is
	ctl.Vhdr = 0			; output header pending
	ctl.Vdif = 0			; reset difference counter
	ctl.Vovr = 0			; no overflow
	ctl.Vsta = 0			; no status

	sd_dis (sdINI)			; initialize output
	sd_eng ()			;
PUT("over ") if ctl.Vovr

	ctl.Vtot += ctl.Vdif		; accumulate differences

	sd_log () if !(ctl.Vhdr|ctl.Vver) ; no headers output yet

	sd_sum ()
	fine
  end

code	sd_rep - report status

  func	sd_rep
	msg : * char
	obj : * char
  is	im_rep (msg, obj) if ctl.Vlog
	im_war () if *msg eq 'W'
  end

code	sd_sum - report counters

  func	sd_sum
  is	if !ctl.Vnew
	  if ctl.Vovr
	     sd_rep ("W-Too many differences %s", lft.Pspc) if ctl.Vdif
	  else
	     sd_rep ("W-Files are different  %s", lft.Pspc) if ctl.Vdif
	  .. sd_rep ("I-No differences found %s", lft.Pspc) otherwise
	.. exit
	PUT("%-14s  ", lft.Pspc)
	PUT("%d\n", ctl.Vdif) if !ctl.Vovr
	PUT("***\n") otherwise
  end
