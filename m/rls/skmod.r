file	skstr - string stack
include	rid:rider
include	rid:fidef
include	rid:imdef
include	rid:medef
include	rid:skdef
include rid:tmdef

;	Strings (actually counted memory segments) can be pushed and popped
;	When stack memory overflows a portion is written to disk
;	When the stack goes below a threshold, memory is read back
;
;	For low usage the stack is never written to disk
;
;	      ^	+-------+ 
;	      |	|	| 
;	      v	+-------+ 
;	   w  ^	|	| 
;	   r  |	+-------+ ^  r
;	   i  |	|       | |  e
;	   t  |	|	| |  a
;	   e  v	+-------+ v  d 
;	   Over		  Under
;	
;	Overflow:
;	1. Write low area to disk
;	2. Slide high area down
;
;	Underflow:
;
;	The previous block is read

	sk_rea : (*skTstk)-
	sk_wri : (*skTstk)-
	sk_opn : (*skTstk) *FILE-
	sk_err : (*skTstk, int)-

code	sk_err - report errors

  init	skAerr : [] * char-
  is	<>
	"open"
	"read"
	"write"
	"length"
  end

  func	sk_err
	stk : * skTstk
	err : int
  is	stk->Verr |= err
	im_rep ("E-Stack buffer %s error", skAerr[err])
	fail
  end
code	sk_alc - allocate

  func	sk_mak
	()  : * skTstk
  is	sk_alc (<>, <>, 0, 0)
	reply that
  end

  func	sk_alc
	stk : * skTstk			; stack - optional
	buf : * char			; buffer - optional
	len : int			; length - optional if !buf
	siz : int			; stack file size - optional
	()  : * skTstk
  is	len = 1024 if !len
	stk = me_acc (#skTstk) if !stk
	buf = me_acc (len) if !buf
	stk->Pbuf = buf
	stk->Vlen = len
	stk->Vrem = len
	stk->Pptr = buf
	stk->Vdsk = len/2
	reply stk
  end

code	sk_dlc - deallocate string stack

  func	sk_dlc
	stk : * skTstk
	flg : int
  is	spc : * char
	flg = skALL_ if !flg
	if (flg & skFIL_) & (stk->Hfil ne)
	   spc = fi_spc (stk->Hfil)
	   fi_clo (stk->Hfil, <>)
	   fi_del (spc, <>)
	.. stk->Hfil = 0

	if flg & skBUF_
	   me_dlc (stk->Pbuf)
	.. stk->Pbuf = <>

	if flg & skSTK_
	.. me_dlc (stk)
  end
code	sk_psh - push string on stack

  func	sk_psh
	stk : * skTstk~
	mem : * char
	typ : int
	len : int
  is	ptr : * char~
	alc : int = len + 5			; 5-byte header

	if alc gt stk->Vrem			; no room
	   fail if !sk_wri (stk)		; write out low stack
	.. fail if alc gt stk->Vrem		; string too long
						;
	ptr = stk->Pptr				; get pointer after write
	*ptr++ = alc			; Vlen	;
	*ptr++ = alc/256		;	; word length
	*ptr++ = stk->Vprv		; Vprv	; length of previous
	*ptr++ = stk->Vprv/256		; 	; length of previous
	*ptr++ = typ			; Vtyp	;
	me_cop (mem, ptr, len)		; Adat	; copy in the data
						;
	stk->Vprv = alc				; previous length now
	stk->Pptr += alc			; that much more
	stk->Vrem -= alc			; that much less
	fine
  end

code	sk_pop - pop string from stack

  func	sk_pop
	stk : * skTstk~
	mem : * char
	typ : * int
	lim : int
	()  : int				; length
  is	ptr : * char~
	alc : int = stk->Vprv
	len : int = alc - 5

	fail if !len
	fail sk_err (stk, skLEN) if len gt lim

	if alc gt (stk->Vlen - stk->Vrem)	; got enough data?
	.. fail if !sk_rea (stk)		; nope, read lower stack
						;
	ptr = (stk->Pptr -= alc)		; get/reset stack pointer
	stk->Vrem += alc			; that much less
						;
	++ptr, ++ptr				; skip entry length
	stk->Vprv = *ptr++ & 255		; previous previous length
	stk->Vprv += (*ptr++&255)<<8		;
	*typ = *ptr & 255 if typ		;
	++ptr					;
	me_cop (ptr, mem, len)			; copy in the data
	fine
  end
code	sk_wri - write partial buffer to temp file

  func	sk_wri 
	stk : * skTstk~
  is	buf : * char~ = stk->Pbuf		;
	dsk : int = stk->Vdsk			;
	ret : int = (stk->Pptr - buf) - dsk	; bytes to retain
	fil : * FILE

	if !stk->Hfil				; no file yet
	   stk->Hfil = tm_opn (stk->Vsiz)	; open temp file
	.. fail sk_err (stk, skOPN) if fail	;
	fil = stk->Hfil				;
						;
	fi_wri (fil, buf, dsk)			; write to disk
	fail sk_err (stk, skWRI) if fail	; not all written
	me_cop (buf+dsk, buf, ret) 		; copy down retained
	stk->Pptr -= dsk			; move down pointer
	stk->Vrem += dsk			; that much more remaining
	fine
  end

code	sk_rea - read partial buffer from temp file

  func	sk_rea 
	stk : * skTstk~
  is	fil : * FILE~ = stk->Hfil
	buf : * char~ = stk->Pbuf
	ptr : * char~ = stk->Pptr
	dsk : int = stk->Vdsk
	ret : int = ptr - buf
	pos : long
	me_cop (buf, buf+dsk, ret)

	fi_flu (fil)				; force data out
	pos = fi_pos (fil) - dsk		; get position
	fi_see (fil, pos)			; seek back to buffer point
	fail sk_err (stk, skREA) if fail	; seek error
	fi_rea (fil, buf, dsk)			; read from disk
	fail sk_err (stk, skREA) if fail	; not all read
	fi_see (fil, pos)			; and reposition
	stk->Pptr += dsk			; point past buffer
	stk->Vrem -= dsk			; that much less remaining
	fine
  end
