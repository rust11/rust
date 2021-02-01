file	lnmod - logical name routines
include <stdlib.h>
include	rid:rider
include	rid:drdef
include	rid:evdef
include	rid:mxdef
include	rid:stdef
include	rid:rgdef
include	rid:lndef

  proc	ln_exi
  is	nothing
  end

code	ln_trn - full translation

  func	ln_trn
	log : * char			; name to translate
	res : * char			; result buffer (up to mxSPC)
	mod : int			; 0=full, 1=single step
	()  : int			; fine/fail
  is	nam : [mxSPC] char		; private copy
	pen : [mxSPC] char		;
	prv : [mxSPC] char		; translated name
	fnd : int = 0			;
	loo : int = 16			;
					;
	st_fit (log, nam, mxSPC)	; get a copy
	st_low (nam)			; lower it
	st_cop (nam, res)		; default result is logical name
	prv[0] = 0			;
					;
      while loo--			; avoid infinity
	if nam[1] eq ':'		; device name (e.g. "c:")?
	.. fine st_cop (nam, res)	; yep, that's fixed
					;
	rg_get (nam, nam, mxSPC)	; translation step
	quit if fail			; no more translations
	st_cop (prv, pen)		; lazy
	st_cop (nam, prv)		;
	++fnd				; found something
	quit if mod eq 1
      end				;
	fail if !fnd			; found nothing
	(*pen && (mod & lnPEN_)) ? pen ?? prv
	fine st_cop (that, res)		; return result
   end
code	ln_def - define logical name

  func	ln_def
	log : * char
	equ : * char
	mod : int			; currently unused
	()  : int
  is	rg_set (log, equ)		; change the name
	if st_sam (log, "default")	; for "default"
	   ev_set ("Default", log)	; notify other processes
	.. dr_set (log, 0)		; change process default
	fine
  end

code	ln_und - undefine logical name

  func	ln_und
	log : * char
	mod : int			; currently unused
	()  : int
  is	rg_und (log)
  end

code	ln_nth enumerate names

  func	ln_nth
	nth : int
	log : * char
	equ : * char
	len : int
  is	fail if !rg_nth (nth, log, len)
	fine if rg_get (log, equ, len)
	fine st_cop ("?", equ)
  end

code	ln_rev - reverse translation

;	This routine translates a name in reverse.
;	The nth occurrence of the translation may be selected

  func	ln_rev
	equ : * char			; name to translate
	res : * char			; result buffer
	nth : int			; nth translation
	()  : int			; fine/fail
  is	nam : [mxIDT] char		; equ in lower case
	log : [mxIDT] char		;
	trn : [mxIDT] char		;
	idx : int = 0			; enumeration index
	st_fit (equ, nam, mxIDT)	; get a copy
	st_low (nam)			;
	repeat				;
	   ln_nth (idx++,log,trn,mxIDT)	; get next
	   pass fail			; not found
	   if st_sam (nam,trn) && !--nth; need nth instance
	   .. fine st_cop (log, res)	; got it
	forever				;
   end
end file
code	ln_dev - check device name change

;	This routine monitors changes to device names.
;	It's used by V11 to catch changes to the definitions
;	of LD0..LD7 etc.
;
;	Also called by kus:roll.r

  func	ln_dev
	nam : * char
	sig : int
  is	len : int = st_len (nam)
	if len gt 3
	|| len lt 2
	|| !ct_alp (*nam++)
	|| !ct_alp (*nam++)
	|| (*nam && !ct_dig (*nam))
	.. fail
	ev_sig (evDEV) if sig
	fine
  end
code	ln_upd - update logical name table

  func	ln_upd
	()  : int
  is	exit if !lnPctx			; nothing open
	ev_sig (evLOG)			; signal change
	df_wri (lnPctx)			; update disk copy
	pass fine			; honky dory
	fail ++lnVerr			; count it
  end
;	earlier .def file implementation
file	lnmod - logical name routines
include	rid:rider
include	rid:dfdef
include	rid:mxdef
include	rid:stdef
include	rid:lndef

	ln_ctx	: (void) *dfTctx
	lnPctx : * dfTctx extern

code	ln_exi - exit define/undefine sequence

  proc	ln_exi
  is	ln_upd () if lnVchg		; update if required
	df_dlc (lnPctx) if lnPctx	; deallocate the lot
	lnPctx = <>			;
  end

code	ln_upd - update logical name table

  func	ln_upd
	()  : int
  is	exit if not lnPctx		; nothing open
	df_wri (lnPctx)			; update disk copy
	fail ++lnVerr if fail		; count it
	lnVchg = 0			; disk copy is updated
	fine				;
  end

code	ln_def - define logical name

  func	ln_def
	log : * char
	equ : * char
	mod : int			; currently unused
	()  : int
  is	lft : [mxIDT] char
	rgt : [mxIDT] char
	ctx : * dfTctx = ln_ctx ()
	fail if ctx eq
	st_cln (log, lft, mxIDT-1)
	st_cln (equ, rgt, mxIDT-1)
	st_low (lft)
	st_low (rgt)
	df_ins (ctx, log, equ)
	reply ln_upd ()
  end

code	ln_und - undefine logical name

  func	ln_und
	log : * char
	mod : int			; currently unused
	()  : int
  is	lft : [mxIDT] char
	ctx : * dfTctx = ln_ctx ()
	def : * dfTdef
	nam : * char
	wri : int = 0
	fail if !ctx
	st_cln (log, lft, mxIDT-1)
	st_low (lft)
	def = df_loo (ctx, lft)
	fail if !def
	df_del (ctx, def)
	reply ln_upd ()
  end
