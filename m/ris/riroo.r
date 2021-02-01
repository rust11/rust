file	riroo - rider compiler root
include rid:rider
include rib:ridef
include rid:chdef
include rid:iodef
include rid:imdef
include rid:stdef

If Win
	quFpro : int = 1 
	quFear : int = 0 
Else
	quFpro : int = 0 
	quFear : int = 1 
End


data	locals

	ri_com	: (int, **char) int-
	ri_qua	: (*char) void-
	ri_hlp	: (void) void-
	quFhdr : int = 0

code	main

  func	main
	cnt : int			; argument count
	vec : ** char			; argument vector
	()  : int			; exit status
  is	im_ini ("RIDER")		; init image
	io_ini ()			; init i/o
	if ri_com (cnt, vec)		; get the command
	   ri_par ()			; parse it
	.. io_clo (ioCout)		;
	im_exi ()			; done
;?	reply 0				; for some compilers
  end
;+++;	RIROO - Add /D="tst$c=1" define conditionals
code 	ri_com - process command

;	Open input and output file

  func	ri_com
	cnt : int
	vec : ** char
	()  : int			; fail
  is	ipt : * char = riPsop		; input file name
	opt : * char = riPsop		; output file name

	case cnt			;
	of 3  ri_qua (vec[2])		; input and output
	      opt = vec[2] if *vec[2]	; got something
	or 2  ri_qua (vec[1])		; input only
	      ipt = vec[1] if *vec[1]	; got something
	of other
	      fail ri_hlp ()
	end case

	ipt = vec[1] ? vec[1] ?? "tt:"	; default input to terminal
	quFhdr ? "noname.d" ?? "noname.r"
	fail if !io_src(ipt, that)	; open source

	opt = vec[2] ? vec[2] ?? "tt:"	; default output to tt:
	quFhdr ? "noname.h" ?? "noname.c"
	reply io_opn (ioCout, opt, that, "w")
  end

code 	ri_qua - get qualifiers

  proc	ri_qua
 	fld : * char			; command field
  is	qua : int			; qualifier
	exit if !fld			; no qualifiers
					;
	while *fld 			; got more
	   if *fld ne _slash		; no slash
	   .. next fld++		; skip it
	   *fld++ = 0			; dump it
	   qua = *fld++			; get the qualifier
	   qua = _qmark if eq		;
	   qua = ch_upr (qua)		; convert it
	   case qua			; process it
	   of 'H'  ++quFhdr		; header
	   of 'L'  ++quFlin		; line numbers
	   of 'V'  ++quFver		; log input
	   of other			;
	      im_rep ("E-Invalid qualifier /%s", <*char>&qua)
	   end_case			;
	end				;
  end

code	ri_hlp - help

  proc	ri_hlp
  is	PUT("RIDER/C Language Translator V4.0\n")
	PUT("\n")
	PUT("      rider infile.r outfile.c\n")
	PUT("\n")
	PUT("/H    Translate .D header file to .H file\n")
	PUT("/L    Display line numbers\n")
	PUT("/V    Verify input\n")
   end
