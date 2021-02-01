file	mosh - text macro processor
include	rid:rider
include	rid:chdef
include	rid:ctdef
include	rid:dfdef
include rid:fidef
include	rid:imdef
include	rid:medef
include	rid:stdef
include rid:mhdef

	mh_met : (*mhTpit, int)
	mh_pun : (*mhTpit, int)
	mh_get : (*mhTpit) int
	mh_pee : (*mhTpit) int
	mh_fil : (*mhTpit) int
	mh_gch : mhTget
	mh_psh : (*mhTpit, *char, int)
	mh_wri : (*mhTpit, *char)
	mh_put : (*mhTpit, int)
	mh_pch : mhTput
	mh_lin : (*mhTpit, int)
	mh_msg : (*mhTpit, *char, *char, *char)

code	mh_alc - allocate mosh pit

  func	mh_alc
	def : * char
	()  : * mhTpit
  is	pit : * mhTpit
	ctx : * dfTctx = df_alc ()

	pit = me_acc (#mhTpit)			; allocate and clear
						;
	pit->Pwrk = me_acc (mhWRK)		; work buffer
	pit->Pres = me_acc (mhRES)		;
	pit->Pexp = me_acc (mhEXP)		; expansion buffer
	pit->Vptr = pit->Vtop = mhEXP		; expansion stack pointer
						;
	pit->Pdef = ctx				;
	df_ctx (ctx, <>, dfSTA_|dfCAS_)		; setup initial context
						;
	pit->Pget = &mh_gch			; get routine
	pit->Pput = &mh_pch			; put routine
	reply pit
  end

code	mh_dlc - deallocate block

  func	mh_dlc
	pit : * mhTpit
  is	ipt : * mhTipt = pit->Aipt
	idx : int = 0

	df_dlc (pit->Pdef)
	me_dlc (pit->Pwrk)
	me_dlc (pit->Pres)
	me_dlc (pit->Pexp)
	while idx lt mhIPT
	   ipt = pit->Aipt + idx++
	   fi_clo (ipt->Pfil, "") if ipt->Pfil
	   me_dlc (ipt->Pspc) if ipt->Pspc
	end
	me_dlc (pit->Popt) if pit->Popt
	fi_clo (pit->Hopt, "") if pit->Hopt
	me_dlc (pit)
  end
code	mh_par - parse file

;	@...	meta at start of line
;	...(@	embedded meta
;	...\\	embedded punctuation meta
;
;	@@exit line
;	@@include filespec
;	@@end			; no more definitions

  func	mh_par
	pit : * mhTpit
  is	cha : int
	snd : int
	pit->Vsol = 1			; start of line
      repeat				;
	fine if pit->Vexi		; quit
					;
	cha = mh_get (pit)		; get next character
	quit if fail			; end of it all
	snd = mh_pee (pit)		; peek at next (second)
					;
;     if pit->Vact			; active mode
	if pit->Vsol && cha eq '@'	; sol @meta...?
	.. next mh_met (pit,'\n')	; process line meta
					;
	pit->Vsol = (cha eq '\n')	; set start-of-line for next character
					;
	if (cha eq '(') && (snd eq '@')	; ...(@meta...) ?
	   mh_get (pit)			; skip @
	.. next mh_met (pit, ')')	; process embedded meta
					;
	if cha eq '~'			; escaping
	    mh_get (pit)		; skip one of them tildes
	.. next mh_put (pit, snd)	; put the character
;  end
					;
	if (cha eq snd) && ct_pun (cha)	; repeated punctuation character
	.. next if mh_pun (pit, cha)	; handle punctuation
					;
	mh_put (pit, cha)		; otherwise write the character
      forever
  end

code	mh_ipt - add input file

  func	mh_ipt
	pit : * mhTpit
	nam : * char
  is	spc : [mxSPC] char
	ipt : * mhTipt
	fine if !nam
	if (pit->Vidx+1) ge mhIPT	; too many open input files
	.. fail mh_msg (pit, "F-Too many input files [%s]", nam, <>)
					;
	ipt = pit->Aipt + ++pit->Vidx 	;
	fi_def (nam, ".m", spc)		; handle the defaults
	ipt->Pfil = fi_opn (spc, "r",""); open the file
	pass fail			;
	ipt->Pspc = st_dup (spc)	;
	pit->Pipt = ipt			;
	fine
  end

code	mh_opt - specify output file

  func	mh_opt
	pit : * mhTpit
	nam : * char
  is	spc : [mxSPC] char
	fine if !nam
	fi_def (nam, ".mx", spc)	; handle the defaults
	pit->Hopt = fi_opn (spc, "w",""); open the file
	pass fail			;
	pit->Popt = st_dup (spc)	;
	fine
  end
code	mh_met - process definitions

;	<sol>@...
;	(@...

  func	mh_met
	pit : * mhTpit
	ter : int			; ) or \n
  is	wrk : * char = pit->Pwrk
	res : * char = pit->Pres
	ptr : * char = wrk
	cnt : int = 0
	cha : int
	nst : int = 0			;
	ent : * dfTdef
	eol : int = ter eq '\n'		; trailing newline 

	while cnt lt 80
	   wrk[cnt] = 0			; terminate it
	   cha = mh_get (pit)		; get another
	   pass fail			; EOF
	   ++nst if (ter eq ')') && (cha eq '(')
	   if cha eq ter		;
	      quit if !nst		;
	   .. --nst			;
	   wrk[cnt++] = cha		;
	end

	fine if !cnt			; forget it
	fine if wrk[0] eq ';'		;
					;
	if st_fnd (":=", wrk)		; this a definition?
	   fine if df_def(pit->Pdef,wrk); yes, no newline required
	   mh_msg (pit, "W-Definition failed", <>, wrk)
	.. fail

	if wrk[cnt-1] eq ';'		; lines ending ";"
	.. --cnt, --eol			; don't get a newline

	if st_scn ("@exit", wrk)	; @exit
	.. fine ++pit->Vexi		; exit time
					;
	if st_scn ("@include ", wrk)	; @include spec
	   fine if mh_ipt (pit, ptr+9)	;
	.. fail ++pit->Vexi		; quit
					;
	df_trn (pit->Pdef, wrk, res, 1022)
	fail mh_msg (pit, "W-Translation failed", wrk, <>) if fail
					;
	PUT("(%s)\n", res) if pit->Fver	; wants expansions
					;
	mh_psh (pit, "\n", 1) if eol	; needs newline
	mh_psh (pit, res, st_len (res))	; push result
	fine
  end

code	mh_pun - process punctuation

;	Repeated punctuation characters, such "||", may name metas

  func	mh_pun
	pit : * mhTpit
	cha : int
  is	res : * char = pit->Pres
	idt : [4] char

	idt[1] = idt[0] = cha, idt[2] = 0
	df_trn (pit->Pdef, idt, res, 32)
	pass fail
	mh_get (pit)			; pop second character
	mh_psh (pit, res, st_len (res))	; push result
	fine
  end
code	mh_get - next character

  func	mh_get
	pit : * mhTpit
  is	cha : int
	if pit->Vptr eq pit->Vtop	; more there
	.. fail if !mh_fil (pit)	;
	cha = pit->Pexp[pit->Vptr++]	; get next character
	mh_lin (pit, cha)		; count lines
	reply cha			;
  end

code	mh_pee - peek at next character

  func	mh_pee
	pit : * mhTpit
  is	if pit->Vptr eq pit->Vtop	; more there
	.. fail if !mh_fil (pit)	;
	reply pit->Pexp[pit->Vptr]	; peek at next
  end

  func	mh_fil
	pit : * mhTpit~
  is	res : int
      repeat
	pit->Pexp + pit->Vptr - 1	; buffer address
	res = (*pit->Pget)(pit, that)	; get next character
	fine --pit->Vptr if fine	; got one
	if --pit->Vidx le		; no more files
	.. fail pit->Vidx = 0		; don't go below zero
	pit->Pipt = pit->Aipt+pit->Vidx	; back to previous input file
      end
  end

  func	mh_gch
	pit : * mhTpit
	cha : * char
  is 	fi_rea (pit->Pipt->Pfil, cha, 1); a thousand cuts
	reply that
  end

code	mh_psh - push on to expansion stack

  func	mh_psh
	pit : * mhTpit
	txt : * char
	cnt : int
  is	if cnt ge pit->Vptr		; too much
	.. mh_msg (pit, "F-Meta buffer overflow", <>, <>)
	pit->Vptr -= cnt		;
	pit->Pexp + pit->Vptr		; where to put them
	me_mov (txt, that, cnt)		; copy them in
  end

code	mh_wri - write string to output file

  func	mh_wri
	pit : * mhTpit
	str : * char
  is	while *str
	.. mh_put (pit, *str++)
  end

code	mh_put - write character to output file

  func	mh_put
	pit : * mhTpit
	cha : int
  is	fine if !cha
	reply (*pit->Pput)(pit, cha)
  end

  func	mh_pch
	pit : * mhTpit
	cha : int
  is	reply fi_ptb (pit->Hopt, cha)
  end
code	mh_lin - count lines

  func	mh_lin
	pit : * mhTpit
	cha : int
  is	++pit->Vlin if pit->Vprv eq '\n'
	pit->Vprv = pit->Vcur
	pit->Vcur = cha
  end

code	mh_msg - messages

  func	mh_msg
	pit : * mhTpit
	msg : * char
	obj : * char
	lin : * char
  is	buf : [60] char
	PUT("?%s-", imPfac)
	PUT("%s ", msg)
	PUT("[%s] ", obj) if obj ne

	PUT("%s ", pit->Pipt->Pspc)
	PUT("Line %d ", pit->Vlin)
	PUT("\n")
	PUT("[%s]\n", lin) if lin ne
	im_exi () if msg[0] eq 'F'
  end
end file

;	free form text replacement
;
  type	mhTnod
  is	Palt : * mhTnod
	Pdwn : * mhTnod
	Vcha : int
	Pter : * char
  end

	mhAini : [128] * mhTnod = {}

  func	mh_mak
	lab : * char
	str : * cgar
  is	prv : ** mhTnod
	fst : int = *lab & 127
	prv = &(mhAmap[fst])

	if (nod = mhAmap[fst]) eq
	   nod = me_acc(#mhTnod)
	   nod->Plab = st_dup (lab)
	   nod->Pstr = st_dup (str)

