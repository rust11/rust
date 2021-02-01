file	mgalc - global memory allocation
include <stdlib.h>
include rid:rider
include	rid:imdef
include	rid:medef

;	realloc has problems
If Win
include	rid:wimod

;	mgTblk should always be a multiple of 16-bytes in length
;	The system is responsible for maintaining lock counters.

	mgSIG	:= 0xf0f0f0f0		; signature

  type	mgTblk
  is	Vsig : long			; signature
	Hhan : HGLOBAL			; global handle		local only
	Ploc : * mgTblk			; local header		in both
	Pglb : * mgTblk			; global header
  end					;
	mg_loc	: (*void) *mgTblk own	; get local control block

code	mg_alc - global memory allocate

  func	mg_alc
	siz : size			; byte size
	()  : * void			; area
  is	mg_alg (<>, siz, 0)		; allocate, don't clear
	reply that			; send back result
  end

code	mg_acc - global memory allocate & clear

  func	mg_acc
	siz : size			; byte size
	()  : * void			; area
  is	mg_alg (<>, siz, meCLR_)	; allocate, and clear
	reply that			; send back result
  end

code	mg_ral - global reallocate memory

  func	mg_ral
	bas : * void
	siz : size
	()  : * void
  is	reply mg_alg (bas, siz, 0)	; reallocate memory
  end	

code	mg_dup - duplicate object

  proc	mg_dup
	src : * void
	siz : size
	()  : * void
  is	dst : * void = mg_alc (siz) 	; allocate the space
	me_cop (src, dst, siz)		; copy it
	reply dst
  end

code	mg_alg - global allocate generic

; ???	Unsure what happens when GlobalReAlloc fails -- is the
; ???	original area lost?

  func	mg_alg
	bas : * void			; area pointer address
	siz : size			; byte size
	mod : int			; operation mode
	()  : * void			; base address or <>
  is	loc : * mgTblk = <>		; local block
	dat : * char			; data pointer
	han : HGLOBAL = 0		;
	ptr : * HGLOBAL			;
	atr : nat = GMEM_MOVEABLE|GMEM_SHARE
	atr |= GMEM_ZEROINIT if mod & meCLR_; want it cleared
;im_rep ("I-Alg", <>)
      repeat
	if bas eq <>			; not already allocated
	   loc = me_alg (<>, #mgTblk, meALC_|meCLR_) ; get the local block
	   quit if eq			; no local storage
	   han = GlobalAlloc (atr, siz + #mgTblk)
	   quit if eq			; nothing
	else				;
	   loc = mg_loc (bas)		; get the local block
	   quit if eq			; failed
 	   mg_flt (loc)			; unlock it in any case
	   han = loc->Hhan		; get the handle
	   han = GlobalReAlloc (han, atr, siz)
	.. quit if eq			;
					;
	loc->Vsig = mgSIG		; set up the signature
	loc->Hhan = han			; store the handle
	loc->Ploc = loc			; setup the self-reference
	dat = mg_lck (loc + 1)		; lock the memory in
	quit if fail			;
	reply dat			; point to the data
      never				;
	me_dlc (loc) 			; deallocate pointer block
	reply <> if mod & meALC_	; private mode
	im_rep ("F-Global memory exhausted",<>); jumps or aborts
	fail				;
  end

code	mg_dlc - global deallocate memory

  func	mg_dlc
	bas : * void
	()  : int			;
  is	loc : * mgTblk			;
;im_rep ("I-Dlc", <>)			;
	fine if (loc = mg_loc (bas)) eq	; was a null pointer
	mg_flt (bas)			; take all locks off
	me_dlc (loc->Ploc)		; deallocate local first
	reply GlobalFree (loc->Hhan) eq <> ; null is success
  end

code	mg_ulk - unlock global block

  func	mg_ulk
	bas : * void
	()  : * void
  is	loc : * mgTblk = mg_loc (bas)	;
	fail if !loc			; no local, no nothing
	GlobalUnlock (loc->Hhan)	; unlock area -- ignore errors
	loc->Pglb = <> if eq		; the pointer is gone
	reply loc + 1			; return local pointer
  end

code	mg_lck - lock global block

  func	mg_lck
	bas : * void
	()  : * void
  is	loc : * mgTblk = mg_loc (bas)	;
	glb : * mgTblk			;
;txt : [128] char
	fail if !loc			; nothing doing at all
	glb = GlobalLock (loc->Hhan)	; lock the area in
	pass fail			;
;FMT(txt, "loc=%x glb=%x", loc,glb)
;im_rep ("I-Lck %s", txt)
	glb->Vsig = mgSIG		; set up the signature
	glb->Ploc = loc			;
	loc->Pglb = glb			; setup pointers
	reply glb + 1			; return data pointer
  end

code	mg_fix - fix in memory

  func	mg_fix
	bas : * void
	()  : * void
  is	loc : * mgTblk = mg_loc (bas)	;
	glb : * mgTblk			;
	fail if !loc			; not a memory block
	reply loc->Pglb if loc->Pglb	; already have it
	reply mg_lck (bas)		; lock it
  end

code	mg_flt - float object

  func	mg_flt
	bas : * void
	()  : * void
  is	loc : * mgTblk = mg_loc (bas)	;
	cnt : int = 100			; maximum
;im_rep ("I-Flt", <>)
	fail if !loc			; nothing to do
	while cnt--			; ignore failure
	   mg_ulk (bas)			; unlock it
	   quit if !loc->Pglb		; got rid of it
;im_rep ("I-flt...", <>)
	end				;
	reply loc + 1			; float address
  end

code	mg_loc - get local block

  func	mg_loc
	bas : * void
 	()  : * mgTblk own
 is	blk : * mgTblk			; local or global block
;txt : [128] char
	fail if !bas			; no memory block
	blk = (<*mgTblk>bas) - 1	;
;FMT(txt, "bas=%x blk=%x sig=%x loc=%x glb=%x",
;	bas, blk, blk->Vsig, blk->Ploc, blk->Pglb)
;im_rep ("I-Loc %s", txt)
	if blk->Vsig ne mgSIG		; not one of ours
	   im_rep ("I-Invalid global memory block", <>)
	.. fail				;
	reply blk->Ploc			; return the local object
  end

End
