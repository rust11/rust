opt$c := 1
;minrite errors???
file	sdcli - SRCDIF command decode
include	rid:rider
include rid:fidef
include	rid:imdef
include	rid:medef
include	rid:mxdef
include rid:rtcli
include rid:rtdir
include dfb:sdmod

	rxEXA := 021401
	rxGEN := 026226
	rxMIS := 051273
	rxDIF := 015156
	rxSAM := 073365

code	sd_cli - SRCDIF command decode

  func	sd_cli
  is 	swi : * csTswi~
	val : WORD~
	ctl.Pscn = me_acc (#rtTscn)	; directory scan
     repeat
	fi_zap ()			; zap all channels
	me_clr (&ctl, #sdTctl)		; Default all to zero
	ctl.Aaud[0] = 0			; /AUDIT default
	ctl.Vcmt = ';'			; /COMMENT default
	ctl.Vnum = 1			; /LINENUMBERS default
	ctl.Vexa = 1			; /EXACT default
	ctl.Veig = 0177			; /NOMULTINATIONAL
	ctl.Vlog = 1			; /LOG
	ctl.Vopt = 1			; /OUTPUT default
	ctl.Vspc = 0			; /SPACES default (RT-11 is /SPACES)
	ctl.Vtrm = 1			; /TRIM default
					;
	ctl.Vtra = 1			; default trailing records
	ctl.Vdis = sdMRG		; default display
	ctl.Vins = '|'			; insert signature
	ctl.Vdel = 'o'			; delete signature
	ctl.Vnew = 1			; not /TRADITIONAL
					;
	csi.Pnon = "ABCFGDNRSTZ"	; no value
	csi.Popt = "CHIKLMNOP"		; optional value
	csi.Preq = "XV"			; required value
	csi.Pexc = <>			; mutually exclusive
	csi.Pidt = "?SRCDIF-I-RUST source differences utility SRCDIF.SAV V1.0"
	csi.Ptyp = "MACDIFSLP   "	; default filetypes
					;
	cs_par (&csi, <>)		; parse command
	next if fail			;
	cs_val (&csi, 0030, 0031)	; req: 2*int, opt: 1*ou
	next if fail			;
	lft.Pspc = csi.Aipt[0].Pspc	; file specs
	rgt.Pspc = csi.Aipt[1].Pspc	; 
	opt.Pspc = csi.Aopt[0].Pspc	; output file, if any
	opt.Iext.Valc = csi.Aopt[0].Valc;
					;
	swi = csi.Aswi			; process switchs
	while swi->Vcha			;
	   val = swi->Vval		;
	   case swi->Vcha		;*=RT-11 options
	   of 'A'  ctl.Vaud = 1		;*/AUDIT
	   of 'B'  ctl.Vblk = 1		;*/BLANKLINES
	   of 'C'  ctl.Vcmt = 0		;*/[NO]COMMENTS=val
		   if swi->Vflg & csVAL_; has explicit value 
		   .. ctl.Vcmt = val	; set comment character
	   of 'D'  ctl.Vchg = 1		;*/CHANGEBAR
		   ctl.Vdis = sdCHG	;
	   of 'E'  ctl.Veig = 0377	; /MULTINATIONAL (/EIGHT_BIT)
	   of 'F'  ctl.Vfrm = 1		;*/FORMFEEDS
	   of 'G'  ctl.Vlog = 0		; /NOLOG
	   of 'H'  ctl.Vver = val	; /LOG
		   ctl.Vver = 1 if eq	; default for /h
	   of 'I'  ctl.Vexa = val 	;*/CASE=[EXA*CT|GEN*ERAL]
		   if !swi->Vflg	; no value
		   .. ctl.Vexa = 1	; default for RT-11 /I
	   of 'K'  ctl.Vwin = val	; /WINDOW=n
	   of 'L'  ctl.Vmin = val	;*/MATCH=n
	   of 'M'  ctl.Vmrg = 1		; /MERGED=1
		   if swi->Vflg & csVAL_; has explicit value 
		   .. ctl.Vtra = val	; set trailing count
		   ctl.Vdis = sdMRG	;
	   of 'N'  ctl.Vnum = 0		;*/[NO]NUMBERS=[RT11|RUST]
					; /N undocumented RT-11 feature
	   of 'O'
If opt$c
		   if val eq rxDIF	;
		   || val eq rxSAM	;
		      ctl.Vonl = val	; only DIFferences|SAMe
		   else
		      ctl.Vopt = 0	; /NOOUTPUT
		   .. ctl.Vdis = sdNOP	; NOP display
Else
		   ctl.Vopt = 0		; /NOOUTPUT
		   ctl.Vdis = sdNOP	; NOP display
End
	  				;*/P RT-11 NOP
	   of 'P'  ctl.Vpar = 1		; /PARALLEL=n
		   if swi->Vflg & csVAL_; has explicit value 
		   .. ctl.Vtra = val	; set trailing count
		   ctl.Vdis = sdPAR	;
	   of 'R'  ctl.Vedi = 1		; /EDITED
	   of 'S'  ctl.Vspc = 0		;*/NOSPACES
	   of 'T'  ctl.Vtrm = 0		; /NOTRIM
	   of 'V'  if  swi->Vflg & csVAL_;
		      sd_sig (val)	;*/CHANGEBAR="!%"
		   .. next if fail	;
	   of 'W'  ctl.Vwid = val	; /WIDTH=n
	   of 'X'  ctl.Vmax = val	; /MAXIMUM=n
	   of 'Z'  ctl.Vspc = 1		; /SPACES
	   end case			;
	   ++swi			; next switch
	end				;

	case ctl.Vcas			; check syntax
	of 0				; default
	or 1				; /I default
	of rxEXA  ctl.Vexa = 1		; /I:EXACT 
	of rxGEN  ctl.Vexa = 0		; /I:GENERAL
	of other
	   im_rep ("E-Invalid /CASE value", <>)
	   next
	end case

	case ctl.Vver			; check syntax
	of 0				; default
	or 1				; /V default
	of rxMIS  ctl.Vmis = 1		; /V:MISSING
	of other
	   im_rep ("E-Invalid /VERIFY value", <>)
	   next
	end case

	ctl.Vmin = 3 if !ctl.Vmin	; default minimum match
	if ctl.Vmin ge 200		;
	   im_rep ("E-Invalid /MATCH value", <>)
	.. next	

	if ctl.Vopt			; want output
	   if opt.Pspc && !rt_ter (opt.Pspc)
	      opt.Pfil = fx_opn (opt.Pspc, "w", "", &opt.Iext)
	      next if fail		;
	   else				;
	.. .. opt.Pfil = stdout		; direct terminal output

	sd_aud () if ctl.Vaud
      never
  end

code	sd_sig - setup the changebar signatures

  func	sd_sig 
	val : int~ 
  is	if ((val gt 0) && (val lt 32))
	|| ((val gt 127) && (val lt 160))
	|| (val eq 255)
	|| ctl.Vins 
	.. fail im_rep ("E-Invalid /CHANGEBAR (/V) parameters", <>)
	val = 0 if val eq 32
	ctl.Vins = val|0400 if !ctl.Vins
	ctl.Vdel = val otherwise
	fine
  end

code	sd_aud - prompt for the audit trail

  func	sd_aud
  is	buf : [mxLIN] char
	rt_prm ("Audit trail? ", buf, rtGLN_)
	if st_len (buf) ge 12
	   buf[12] = 0
	.. im_war ("W-Audit trail truncated to twelve characters [%s]", buf)
	st_cop (buf, ctl.Aaud)
  end
