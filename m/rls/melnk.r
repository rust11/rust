;	%unused%
file	mesuc - make object with link
include	rid:rider
include	rid:medef

  type	meTlnk
  is	Psuc : * void
  end

code	me_lnk - make object with link

;	lst is usually a pointer to a pointer to the last element.
;	In this case, successive calls add elements at the end
;	of the list.
;
;	However, it can also be a pointer an intermediate element.
;
;	Links (Psuc) are assumed to be the first element of the
;	structure (as all mine are).
;
;	This routine avoids coding errors and ugly casts.

; func	sh_mem
;	ctx : * shTctx
; is	lst : * void = &ctx->Pmem
;     repeat
;	mem = me_lnk (&lst, #shTmem)
;	mem->Vcla = cla
;	mem->Vflg = flg
;	...
;     forever
; end

  func	me_lnk
	lst : * void
	siz : size
	()  : * void
  is	obs : *** meTlnk = <***meTlnk>lst ; cast incrediable
	pre : ** meTlnk = *obs		; predescoire
	obj : * meTlnk = me_acc (siz)	; inventee vous
	if pre				; c'est un prediseased
	   obj->Psuc = *pre		; link avec successoire
	.. *pre = obj			; link avec predinorsauce
	*obs = <**meTlnk>obj		; observez vous noir?
	reply <*void>obj		; viola!
  end
