file	sdchg - SRCDIF changebar listing
include rid:rider
include	dfb:sdmod

  type	sdTchg
  is	Vdel : int		; delete pending
	Amat : [2] char
	Ains : [2] char
	Adel : [2] char
  end

	chg : sdTchg = {0}

  func	sd_chg
	cas : int
  is	case cas
	of sdINI  cb_ini ()
	of sdHDR  cb_hdr (0)
	of sdLOG  cb_hdr (1)
	of sdMAT  cb_mat ()
	of sdMIS  cb_mis ()
	of sdFIN  cb_fin ()
	of sdDIV  cb_div ()
	end case
  end

code	cb_ini  - init

  func	cb_ini
  is	chg.Vdel = 0
	chg.Amat[0] = ' '
	chg.Ains[0] = '|'
	chg.Adel[0] = 'o'
  end

code	cb_mat - dump match section

  func	cb_mat
  is	src : * char = sd_tak (&lft, sdMAT)
	dst : * char = sd_tak (&rgt, sdMAT)
	exit if !src || !dst
	chg.Vdel ? chg.Adel ?? chg.Amat
	cb_dis (dst, that)
	chg.Vdel = 0
  end

code	cb_mis - dump missmatch section

  func	cb_mis
  is	src : * char
	dst : * char
	sig : * char
	repeat
	   src = sd_tak (&lft, sdMIS)
	   dst = sd_tak (&rgt, sdMIS)
	   exit if !src && !dst
	   next chg.Vdel = 1 if !dst
	   cb_dis (dst, chg.Ains)
	end
  end

  func	cb_dis
	txt : * char
	sig : * char
  is
	exit if !txt
	sd_typ ("    ")
	sd_typ (sig)
	sd_typ ("	")
	sd_prt (txt)
  end

  func	cb_hdr
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

  func	cb_div
  is	sd_prt ("----+---")
  end

  func	cb_fin
  is
  end
