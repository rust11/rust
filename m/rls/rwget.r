file	rwget - raw i/o get/put 
include	rid:rider
include	rid:rwdef
include	rid:medef
	
code	rw_buf - init buffering

  func	rw_buf
	fil : * rwTfil
  is	if fil->Pbuf eq		
	..  fil->Pbuf = me_alc (512)
	fil->Vadr = -1
	fil->Vctl &= ~(rwMOD_)
	fine
  end

code	rw_flu - flush modified block

  func	rw_flu 
	fil : * rwTfil
  is	fine if !(fil->Vctl & rwMOD_)	; fine
	rw_wri (fil, fil->Pbuf, fil->Vadr/512, 512)
	pass fail			;
	fil->Vctl &= ~(rwMOD_)
	fine				;
  end

code	rw_ptr - setup pointer

  func	rw_ptr
	fil : * rwTfil
	pos : int
	()  : * char
  is	blk : long = pos/512		; compute block
	if blk ne (fil->Vadr / 512)	; wrong block
	   rw_flu (fil)			; flush it
	   pass fail			;
	   rw_rea (fil, fil->Pbuf, blk, 512)
	.. pass fail			; all over
	fil->Vadr = pos			; got it
	reply fil->Pbuf + (pos - (blk*512))
  end

code	rw_see - seek

  func	rw_see
	fil : * rwTfil
	pos : long
  is	fine if rw_ptr (fil, pos)
	fail
  end

code	rw_get - get n bytes

  func	rw_get
	fil : * rwTfil
	buf : * void
	cnt : size
	()  : size
  is	res : size = 0
	adr : size = fil->Vadr
	src : * char
	dst : * char = buf
	while cnt--
	   src = rw_ptr (fil, adr++)		; get the next
	   quit if fail				;
	   *dst++ = *src			;
	   ++res				;
	end					;
	reply res				;
  end

code	rw_put - put n bytes

  func	rw_put
	fil : * rwTfil
	buf : * void
	cnt : size
  is	res : size = 0
	adr : size = fil->Vadr
	dst : * char
	src : * char = buf
	while cnt--
	   dst = rw_ptr (fil, adr++)		; get the next
	   pass fail				; oops
	   *dst = *src++			;
	   ++res				;
	   fil->Vctl |= rwMOD_			;
	end					;
	rw_flu (fil)				;
	fine					;
  end
