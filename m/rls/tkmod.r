file	tkmod - token processing
include	rid:rider
include	rid:cldef
include	rid:stdef
include	rid:medef
include	rid:tkdef
include	rid:ctdef

code	tk_alc - allocate token context

  func	tk_alc
	flg : int
	()  : * tkTctx
  is	ctx : * tkTctx
	ctx = me_acc (#tkTctx)
	ctx->Vflg = flg
	reply ctx
  end

code	tk_dlc - deallocate token context

  proc	tk_dlc
	ctx : * tkTctx
  is	me_dlc (ctx)
  end

code	tk_lin - accept another line

  proc	tk_lin
	ctx : * tkTctx
	lin : * char
  is	ctx->Plin = lin
	ctx->Pfst = lin
	ctx->Plst = lin
	ctx->Pnxt = lin
	ctx->Vsta = 0
	tk_skp (ctx)			; point at first
  end

code	tk_cli - process image activation command line

  proc	tk_cli
	ctx : * tkTctx
	cnt : int
	vec : ** char
	()  : * tkTctx
  is	lin : * char
	ctx = tk_alc (0) if !ctx	; make a context
	lin = ctx->Alin			;
	cl_ass (lin, cnt, vec)		; assemble line from vector
	tk_lin (ctx, lin)		; set it up
	reply ctx			;
  end
code	tk_nxt - get next token

  func	tk_nxt
	ctx : * tkTctx
  is	cha : int
	tok : * char
	ptr : * char
	fail if ctx eq			; no context
	fail if ctx->Pnxt eq		; no line
	ctx->Atok[0] = 0		;
	ctx->Vtyp = tkEND		; assume all over
	tok = ctx->Atok			; the token output
	fail if !tk_skp (ctx)		; skip to start of token
	ctx->Pfst = ctx->Pnxt		; start/end of token
	ctx->Plst = ctx->Pnxt		;
      repeat
	cha = *ctx->Pnxt		; get it
	if (cha eq '\"') || (cha eq '\''); got a string
	   ptr = st_bal (ctx->Pnxt)	; get the other extremity
	   while ctx->Pnxt ne ptr	; copy all that
	   .. *tok++ = *ctx->Pnxt++ 	;
	.. quit ctx->Vtyp = tkSTR	; some string
					;
	if tk_idt (*ctx->Pnxt)		; an identifier character
	   repeat			;
	      *tok++ = cha		;
	      ++ctx->Pnxt		;
	      cha = *ctx->Pnxt		;
	   until !tk_idt (*ctx->Pnxt)	;
	.. quit ctx->Vtyp = tkIDT	;
					;
	*tok++ = cha			; punctuation
	ctx->Vtyp = tkPUN		;
	++ctx->Pnxt			;
      never				;
	*tok = 0			;
	ctx->Plst = ctx->Pnxt		; point at last
	tk_skp (ctx)			; skip to next one
	reply ctx->Vtyp			;
   end

code	tk_idt - check identifier character

  func	tk_idt
	cha : int
  is	cha = cha & 255			;
	fine if ct_aln (cha)		; is identifier
	fine if cha eq '$'		;
	fine if cha eq '_'		;
	fail
  end

  func	tk_pun
	cha : int
  is	reply !tk_idt (cha)		;
  end

code	tk_skp - skip spaces and comments

  func	tk_skp
	ctx : * tkTctx
  is	cha : int
      repeat
	cha = *ctx->Pnxt		;
	fail if eq			; all over
	if cha eq ctx->Vcmt		; simple comment
	   ctx->Pnxt = st_end(ctx->Pnxt); skip the lot
	.. fail				;
	if (cha eq ' ') || (cha eq '\t'); got space
	.. next ++ctx->Pnxt 		;
	fine				; something real
      forever				;
  end
code	tk_loo - lookup token in table

  func	tk_loo
	ctx : * tkTctx
	tab : []* char
  is	idx : int = 0
	while *tab
	   if ctx->Vtyp ne tkEND
	   && cl_mat (*tab++, ctx->Atok)
	   .. quit
	   ++idx
	end
	reply idx
  end

code	tk_spc - get a file spec

  func	tk_spc
	ctx : * tkTctx
	spc : * char
  is	ptr : * char
	st_par ("pn", "A0|$_:.\\*%?[];", ctx->Pfst)
	fail if (ptr = that) eq <>
	ctx->Plst = ptr
	ctx->Pnxt = ptr
	tk_skp (ctx)
	st_cln (ctx->Pfst, ctx->Atok, ptr-ctx->Pfst)
	st_cop (ctx->Atok, spc) if spc
	fine
  end
