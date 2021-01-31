file	sdpar - SRCDIF parallel listing
include rid:rider
include rid:mxdef
include	dfb:sdmod

  type	sdTpar
  is	Vsta : int		; state
	Vwid : int		; width
  end
	pdNON := 0

	par : sdTpar = {0}

  func	sd_par
	cas : int
  is	case cas
	of sdINI  pr_ini ()
	of sdHDR  pr_hdr (0)
	of sdLOG  pr_hdr (1)
	of sdMAT  pr_mat ()
	of sdMIS  pr_mis ()
	of sdFIN  pr_fin ()
	of sdDIV  nothing ;pr_div ('-')
	end case
	par.Vsta = cas
  end

code	pr_ini - init

  func	pr_ini
  is	wid : int = ctl.Vwid
	wid = 80 if !wid
	wid = wid / 16
	wid = wid * 8		; don't let the compiler optimise
	wid = 40 if wid lt 8
	wid = 66 if wid gt 66
	par.Vwid = wid
  end

code	pr_mat - dump match section

  func	pr_mat
  is	src : * char = sd_tak (&lft, sdMAT)
	dst : * char = sd_tak (&rgt, sdMAT)
	exit if !src && !dst
	pr_hdr ()
	pr_div ('=') if par.Vsta ne sdMAT
	pr_lin (src, dst)
  end

code	pr_mis - dump missmatch section

  func	pr_mis
  is	src : * char
	dst : * char
	pr_hdr ()
	pr_div ('-') if par.Vsta ne sdMIS
	repeat
	   src = sd_tak (&lft, sdMIS)
	   dst = sd_tak (&rgt, sdMIS)
	   exit if !src && !dst
	   pr_lin (src, dst)
	end
  end

code	pr_lin - display line

  func	pr_lin
	src : * char
	dst : * char
  is	pr_txt (src)
	pr_txt (dst)
	sd_prt ("|")
  end

  func	pr_txt
	txt : * char
  is	fmt : [mxLIN] char
	sd_typ ("|")
	sd_fmt (txt, fmt, par.Vwid-2, 1, 0)
	sd_typ (fmt)
  end

code	pr_div - display divider

  func	pr_div
	sig : char
  is	buf : [mxLIN] char
	fmt : * char = buf
	sid : int = 2
	col : int
;	exit if !ctl.Vnum
	while sid--
	   col = par.Vwid - 2
	  *fmt++ = '+'
	  *fmt++ = sig while col--
	end
	*fmt++ = '+'
	*fmt++ = 0
	sd_prt (buf)
  end

  func	pr_hdr
	ter : int
  is	fine if ctl.Vhdr
	++ctl.Vhdr
	if ter
	   exit if !ctl.Vlog
	   PUT("1) %s\n", lft.Pspc)
	   PUT("2) %s\n", rgt.Pspc)
	else
	   exit if !ctl.Vopt
	   pr_div ('-')
	   pr_txt (lft.Pspc)
	   pr_txt (rgt.Pspc)
	   sd_prt ("|")
	end
  end

  func	pr_fin
  is	pr_div ('-') if par.Vsta ne sdINI
  end
code	sd_fmt - format line

	sdFRM_ := 1			; had form feed
	sdTAB_ := 2			; had tab
	sdCTL_ := 4			; had control character

  func	sd_fmt
	src : * char
	dst : * char
	wid : int
	pad : int	
	frm : int			; formfeed control
	()  : int			; formfeed seen in line
  is	col : int = 0
	res : int = 0			;
	fee : int = 0
	cha : int
      while wid
	cha = *src++			; get it
	if !cha				; end of src
	   quit if !pad			; not padding
	.. --src, cha = ' '		; space if padding

	if cha eq '\f'			; got formfeed
	   ++fee			; seen
	   next if frm eq		; skipping them
	elif cha eq '\t'		; got tab
	   if pad			;
	      repeat			;
	         *dst++ = ' ', ++col	;
	         quit if !--wid		;
	      until !(col & 7)		;
	   .. next			;
	elif cha lt 32			;
	   cha = '?'			;
	end				;
					;
	*dst++ = cha, ++col, --wid	;
      end				;
	*dst = 0			;
	reply fee			;
  end
end file

code	pr_num - display numbered divider

  func	pr_num
	dis : * sdTdis
	sig : char
  is	num : [32] char
	cnt : int
	exit pr_div (char) if !ctl.Vnum
	FMT (num, "[%d,%d]", dis->Vpag, dis->Vlin)

