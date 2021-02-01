;???;	dfmod - literal ^! and ^; required
;???;	DFMOD - ^t^1 fails because ^t expects a file name
upd$c := 0
;	fail if fi_clo
;	st_mov/st_cop in df_rep
file	dfmod - user definitions
;nclude	<stdio.h>
include	rid:rider
include	rid:imdef
include	rid:dfdef
include	rid:stdef
include	rid:medef
include	rid:chdef
include	rid:fidef
include	rid:cldef

;	Handles definitions of the form:
;
;	na*me := string
;
;	The name may include abbreviations (marked with '*')
;	Identical names are replaced
;	Ambiguous if eol or * before missmatching character

data	locals

	df_str	: (*dfTctx, *dfTdef, *char) void; definition to string
	df_par	: (*dfTctx, *char) int		; parse definition
	df_amb	: (*char, *char) int		; check ambiguous
	df_cmp	: (*char, *char) int		; compare non-wild
	df_mak	: (*dfTctx, *char, *char) *dfTdef ; constructor
	df_del	: (*dfTctx, *dfTdef) void	; destructor

	E_Inv	:= "E-Invalid definition [%s]"
	W_Opn	:= "W-Error opening definition file [%s]"
	E_Rea	:= "E-Error reading definition file [%s]"
	E_Cre	:= "E-Error creating definition file [%s]"
	E_Wri	:= "E-Error writing definition file [%s]"
	E_Cor	:= "E-Corrupted definition file [%s]"
	E_Amb	:= "E-Abbreviated symbol is ambiguous [%s]"
code	df_ctx - build definition context

;	dfVctx : int = 0		; recursion issues
	dvPctx : * dfTctx		; static

   func	df_ctx
	spc : * char			; file spec (optional)
	flg : int			; flags
 	()  : int
   is	ctx : * dfTctx = me_acc(#dfTctx);

	ctx->Pspc = spc			; the spec
	ctx->Vflg = flg			; the flags
	ctx->Pbal = ""			; default is no balancing
	ctx->Vsep = ' '			; default separator is space
	ctx->Vflg |= dfINI_		; inited now
	ctx->Proo = <>			; none yet
	ctx->Popr = ":=" if ctx->Popr eq <>
	ctx->Palc = &me_acc		; caller may replace these hooks
	ctx->Pdlc = &me_dlc		;
	ctx->Prep = &im_rep		;
					;
	reply df_rea (ctx) if spc ne	; read definition file
	fine
  end

code	df_dlc - deallocate the lot

  proc	df_dlc
	ctx : * dfTctx~			;
  is	exit if ctx eq			; nothing to deallocate
	df_zap (ctx)			; clear definitions out
	me_dlc (ctx)			; dump the context
  end

code	df_zap - clear definitions

  proc	df_zap
	ctx : * dfTctx~			;
  is	def : * dfTdef~			;
	nxt : * dfTdef			;
	exit if ctx eq			; nothing to deallocate
	def = ctx->Proo			; get the first entry
	while def			; dump the definitions
	   nxt = def->Psuc		;
	   df_del (ctx, def)		; delete this one
	   def = nxt			;
	end				;
	ctx->Proo = <>			; are none
  end
code	df_mak - make a new definition

  func	df_mak
	ctx : * dfTctx
	nam : * char
	bod : * char
	()  : * dfTdef
  is	def : * dfTdef~
	def = me_acc (#dfTdef)		; allocate it
	def->Pnam = st_dup (nam)	;
	def->Pbod = st_dup (bod)	;
	ctx->Vflg |= dfMOD_		; modified
	reply def			;
  end

code	df_del - delete a definition

  proc	df_del
	ctx : * dfTctx			;
	def : * dfTdef~			;
  is	me_dlc (def->Pnam)		; the name
	me_dlc (def->Pbod)		;
	me_dlc (def)			;
	ctx->Vflg |= dfMOD_		; was modified
  end

code	df_nth - n'th definition

  func	df_nth
	ctx : * dfTctx
	nth : int			; nth
	()  : * dfTdef			; nth or null
  is	def : * dfTdef~
	def = ctx->Proo			; the first
	while def ne <>			; got more
	   reply def if nth-- eq	; that was it
	   def = def->Psuc		; get the next
	end				;
	reply null			; are no more
  end
code	df_def - define a definition

  func	df_def
	ctx : * dfTctx~			; the context
	lin : * char			;
	()  : int			; fail/fine
  is	df_par (ctx, lin)		; parse it
	pass fail			; oops

	if ctx->Vflg & dfMOD_		; changed something
	.. reply df_wri (ctx)		; write if changed
	fine				;
  end

code	df_loo - lookup definition

  func	df_loo
	ctx : * dfTctx~	
	str : * char			; name
	()  : * dfTdef			; result definition or <>
  is	def : * dfTdef~			;
	nam : [mxLIN] char		;
	st_cop (str, nam)		; get a copy
	st_trm (nam)			; clean it up
	def = ctx->Proo			; get them
	if (ctx->Vflg & dfCAS_) ne	; case sensitive
	   while def ne <>		; got more
	      st_sam (nam, def->Pnam)	; match them
	      reply def if ne		; matched unambiguous
	      def = def->Psuc		; move on
	   end				;
	else				;
	   st_low (nam)			; lower it
	   while def ne <>		; got more
	      cl_mat (nam, def->Pnam)	; match them
	      reply def if gt		; matched unambiguous
	      def = def->Psuc		; move on
	.. end				;
	reply <>			; not found
  end
code	df_par - parse & insert

  func	df_par
	ctx : * dfTctx~			;
	str : * char			;
	()  : int			; fine/fail
  is	bod : * char~			;
	nam : [mxLIN] char		;
	st_cop (str, nam)		; get a local copy
	bod = st_fnd (ctx->Popr, nam)	; look for operator
	if fail				; not found
	.. fail df_rep (ctx, E_Inv, nam); invalid definition
	*bod = 0			; terminate name
	bod += 2			; skip :=
	df_ins (ctx, nam, bod)		; insert it
	reply that			;
  end

code	df_ins - insert definition

  func	df_ins
	ctx : * dfTctx~			; context
	nam : * char
	bod : * char
	()  : int
  is	def : * dfTdef~			; get the list
	pre : ** dfTdef~			; predecessor
	ent : * dfTdef~			;
	if (ctx->Vflg & dfCAS_) eq	; not case sensitive
	.. st_low (nam)			; lowercase name
	st_trm (nam)			; cleanup name
	st_trm (bod)			; cleanup body

;	Check ambiguous

	def = ctx->Proo			; first definition
	while def ne <>			;
	   if df_amb (nam, def->Pnam)	; got ambiguous names
	      df_rep (ctx, E_Amb, nam)	; say so
	   .. fail			; does not return here
	   def = def->Psuc		;
	end				;

;	Find the slot

	pre = &ctx->Proo		;
	repeat				;
	   def = *pre			; get the next
	   quit if null			; aint no more
	   quit if df_cmp (def->Pnam, nam) ge ; just passed our predecessor
	   pre = &def->Psuc		; the next one
	end				;

;	Identity

	if def ne <>			; got one
	&& df_cmp (def->Pnam, nam) eq	; exact match
	   if st_sam (def->Pnam, nam)	; exact match on name
	   && st_sam (def->Pbod, bod)	; exact match on body
	   .. fine			; ok - nothing changed
	   *pre = def->Psuc		; take it out of the food chain
	   df_del (ctx, def)		; delete previous version
	.. fine if *bod eq		; just deleting it

;	Insert

	ent = df_mak (ctx, nam, bod)	; make another
	ent->Psuc = *pre		; insert us
	*pre = ent			;
	fine
  end
code	df_rea - read definition file

;	Avoid a long chain of error messages when reading a definition file
;	Require that each line of the file contain the operator
;	Otherwise the file is corrupt

  func	df_rea
	ctx : * dfTctx~			; context
	()  : int			; fine/fail
  is	fil : * FILE			;
	lin : [mxLIN] char		;
	spc : * char = ctx->Pspc	; filespec
	fst : int = 1			; first line flag
	fine if ctx->Vflg & dfMEM_	; memory only
	fil = fi_opn (spc, "r", <>)	; open the file
	if null				; failed
;	   fine if ctx->Vflg & dfEPH_	; ephemeral o.k.
	.. fail df_rep (ctx, W_Opn, spc); report it
	ctx->Vflg |= dfREA_		; read in progress
	ctx->Vflg &= ~(dfMRK_)		; remove error mark

	repeat				;
	   fi_get (fil, lin, mxLIN-2)	; read another
	   quit if eof			; all over
	   next if *lin eq		; empty line
	   next if *lin eq '!'		; a comment
	   next if *lin eq ';'		; a comment
	   if st_fnd (ctx->Popr, lin) eq <> ; missing operator
	   .. quit df_rep (ctx, E_Cor, spc) ; file is corrupt
	   df_par (ctx, lin)		; parse and insert
	end				;

	fi_clo (fil, <>)		; close and check it
	df_rep (ctx, E_Rea, spc) if eq	; error reading it
	ctx->Vflg &= ~(dfREA_)		; no longer reading it
	fine if (ctx->Vflg & dfMRK_) eq	; no errors
	fail df_rep (ctx, ctx->Pmsg, ctx->Aobj) ;
  end

code	df_wri - write definitions

  func	df_wri
	ctx : * dfTctx~			; context
	()  : int			; fine/fail
  is	fil : * FILE			;
	lin : [mxLIN] char		;
	spc : * char = ctx->Pspc	; file spec
	def : * dfTdef = ctx->Proo	;
	cnt : int
	fine if ctx->Vflg & (dfMEM_|dfSTA_) ; memory or static
If upd$c
	(ctx->Vflg & dfUPD_) ? "rw" ?? "w"
	fil = fi_opn (spc, that, <>)	; create it
	if null				; oops
	.. fail df_rep (ctx, E_Cre, spc); failed
Else
	fil = fi_opn (spc, "w", <>)	; create it
	if null				; oops
	.. fail df_rep (ctx, E_Cre, spc); failed
End
	while def ne <>			;
	   df_str (ctx, def, lin)	; make a string out of it
	   fi_put (fil, lin)		; write it
	   def = def->Psuc		; get the next
	end				;
If upd$c
	me_clr (lin, mxLIN)		; updated files need to be
	cnt = 20			;
	fi_wri (fil, lin, mxLIN) while cnt-- ; padded with zeroes
End					;
	fine if fi_clo (fil, <>)	; no processing errors
	fail df_rep (ctx, E_Wri, spc)	; write error
  end
code	df_amb - check ambiguous

;	time		time		identical
;	t*ime		ti*me		identical
;	t*im		ti*me		ambiguous
;	tim		time		different

  func	df_amb
	lft : * char~
	rgt : * char~
	()  : int
  is	fail if df_cmp (lft, rgt) eq	; same are never ambiguous
	if st_mem ('*', lft) eq		; no wildcards on left
	&& st_mem ('*', rgt) eq		; none on right
	.. fail				; different & no wildcards
  	repeat				; must differ before first star
	   fine if *lft eq '*' || *lft eq ; ambiguous
	   fine if *rgt eq '*' || *rgt eq
	   fail if *lft ne *rgt		; not ambiguous
	   ++lft, ++rgt			; skip leading match
	end
  end

code	df_cmp - compare without stars

  func	df_cmp
	lft : * char~
	rgt : * char~
	()  : int
  is	repeat				;
	   ++lft if *lft eq '*'		; skip it there
	   ++rgt if *rgt eq '*'		;
	   quit if *lft ne *rgt		; got difference
	   quit if *lft eq		; identical
	   ++lft, ++rgt			;
	end				;
;	reply <char unsigned>*lft - <char unsigned>*rgt
	reply (*lft&255) - (*rgt&255)	; no unsigned char in DECUS C
  end
code	df_lst - list definitions

  proc	df_lst
	ctx : * dfTctx			; context
  is	lin : [mxLIN] char		;
	def : * dfTdef~ = ctx->Proo	; the first
	while def ne <>			;
	   df_str (ctx, def, lin)	; make a string out of it
	   PUT(lin)			;
	   def = def->Psuc		; get the next
	end				;
  end

code	df_str - definition to string

  proc	df_str				; definition as string
	ctx : * dfTctx			;
	def : * dfTdef~			; definition
	lin : * char~			; where it goeth
  is	st_cop (def->Pnam, lin)		;
	st_app (" ", lin)		;
	st_app (ctx->Popr, lin)		;
	st_app (" ", lin)		;
	st_app (def->Pbod, lin)		;
	st_app ("\n", lin)		;
  end

code	df_idt - definition identity 

  func	df_idt
	ctx : * dfTctx
	nam : * char
  is	reply st_fnd (ctx->Popr, nam) ne
  end

code	df_rep - report errors

  proc	df_rep
	ctx : * dfTctx~
	msg : * char
	obj : * char
  is	ctx->Pmsg = msg			; the message
	st_cop (obj, ctx->Aobj)		; copy the object
	ctx->Vflg |= dfERR_|dfMRK_	; some error
	exit if ctx->Vflg & (dfMUT_|dfREA_) ; muted or reading
	(*ctx->Prep)(msg, obj)		; report it
  end
