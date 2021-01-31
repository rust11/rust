file	sdmrg - SRCDIF merged listing
include rid:rider
include	rid:stdef
include	dfb:sdmod

  type	sdTmrg
  is	Vpag : int 
	Vdiv : int
  end
	mrg : sdTmrg = {0}

  func	sd_mrg
	cas : int
  is	case cas
	of sdINI  mg_ini ()
	of sdHDR  mg_hdr (0)
	of sdLOG  mg_hdr (1)
	of sdMAT  mg_mat ()
	of sdMIS
	or sdMIX  mg_mis ()
	of sdFIN  mg_fin ()
	of sdDIV  nothing
	end case
  end

code	mg_ini - setup

  func	mg_ini
  is	mrg.Vdiv = 0
  end

code	mg_mat - match section

;	Just ignore the data 
;	Only ever a pair at a time

  func	mg_mat
  is	sd_tak (&lft, sdMAT)
	sd_tak (&rgt, sdMAT)
  end

code	mg_mis - dump missmatch section

;	Multiple missmatch items 

  func	mg_mis
  is	mg_hdr (0) if !ctl.Vhdr
	mrg.Vdiv = 1
	sd_prt ("**********")
	mg_sid (&lft)
	sd_prt ("****")
	mg_sid (&rgt)
  end

  func	mg_sid
	sid : * sdTsid~
  	mat : int
  is	txt : * char
	cnt : int = 0
	mrg.Vpag = 0
	while (txt = sd_tak (sid, sdMAT)) ne
	   mg_idt (sid)
	   sd_prt (txt)
	   ++cnt
	end
;	if ctl.Vtra
  end

code	mg_idt - display line ident

  func	mg_idt
	sid : * sdTsid
  is	buf : [32] char
	ptr : * char = buf
	exit if !ctl.Vnum
	(sid->Vsid eq 0) ? "1)" ?? "2)"
	ptr = st_cop (that, ptr)
	if mrg.Vpag ne sid->Vpag
	   FMT(ptr, "%d", sid->Vpag)
	.. mrg.Vpag = sid->Vpag
	sd_typ (buf)
	sd_typ ("\t")
  end

code	mg_hdr - display header

  func	mg_hdr
	ter : int
  is	++ctl.Vhdr
	if ter
	   exit if !ctl.Vlog
	   PUT("1) %s\n", lft.Pspc)
	   PUT("2) %s\n", rgt.Pspc)
	else
	   exit if !ctl.Vopt
	   sd_typ ("1) "), sd_prt (lft.Pspc)
	   sd_typ ("2) "), sd_prt (rgt.Pspc)
	end
  end

code	mg_fin - finish up

  func	mg_fin
  is	sd_prt ("**********") if mrg.Vdiv
  end
