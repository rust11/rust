file	fitra - file transfer operations
include rid:rider
include rid:fidef
include rid:medef
include <stdio.h>
;nclude <stdlib.h>
include rid:dbdef

	fiPbuf : * void	own = <>	;
	fiVbuf : size_t own = 0		; size of it

code	fi_cop - copy a file

  func	fi_cop
	src : * char
	dst : * char
	msg : * char
	mod : int
  is	lft : * FILE
	rgt : * FILE
;PUT("fi_cop:[%s] [%s]\n", src, dst)

	lft = fi_opn (src, "rb", <>)
	pass fail
	rgt = fi_opn (dst, "wb", <>)
	pass fail
	reply fi_kop (lft, rgt, 0) if mod
	reply fi_tra (lft, rgt, 0)
  end

code	fi_buf - setup a transfer buffer

  func	fi_buf
	buf : * void			; !<> => setup user buffer
	siz : size_t			; 0 => deallocate
	()  : size_t			; actual size
  is	if buf ne <>			; setup user buffer
	   fiPbuf = buf			;
	   fiVbuf = siz			;
	.. reply siz			; no worries
	reply siz if siz eq fiVbuf	; already have it
	if fiVbuf ne			; deallocate current
	   fiVbuf = 0			;
	.. me_dlc (fiPbuf)		;
	reply 0 if siz eq		; deallocated buffer
	repeat				; attempt to allocate it
	   fiPbuf = me_alc (siz)	; allocate it
	   quit if ne <>		; got it
	   fail if (siz /= 2) lt 1024	; ridiculous
	end				; try again
	reply (fiVbuf = siz)		; actual size
  end

code	fi_tra - transfer file

  func	fi_tra
	src : * FILE			; source file 
	dst : * FILE			; desination file
	lim : size_t			; transfer limit
	()  : int			; fine/fail
  is	tra : [1024] char		; emergency buffer
	buf : * char			;
	dlc : int = 0			; must deallocate
	siz : size_t			;
	cnt : size_t			;
	err : int = 0			;
	if fiVbuf eq			; need buffer
	.. dlc = fi_buf (<>, 8192*3)	; autobuffer
	if fiVbuf			; got a big buffer
	   buf = fiPbuf, siz = fiVbuf	;
	else				;
	.. buf = tra, siz = 1024	; use emergency buffer	
	lim = fi_len (src) if !lim	;
	while lim
	   siz = lim if lim lt siz 	; minimize it
	   cnt = fi_ipt (src, buf, siz)	; read more
;PUT("cnt=%ld, siz=%ld, lim=%ld \n", cnt,siz,lim)
;db_lst ("Read: ") if !cnt
	   quit err=1 if cnt eq		;
	   fi_wri (dst, buf, cnt)	; write it
	   quit err=2 if fail		; an error
	   lim -= siz			;
	end				;
	fi_buf (<>,0) if dlc		; deallocate buffer
	fail if err			;
	fail if fi_err (src, <>)	; check errors
	fail if fi_err (dst, <>)	;
	fine				; wunderbar
  end
code	fi_kop - kopy files (handle)

  func	fi_kop
	src : * FILE			; source file 
	dst : * FILE			; desination file
	len : long			; transfer size
	()  : int			; fine/fail
  is	tra : [1024] char		; emergency buffer
	buf : * char			;
	dlc : int = 0			; must deallocate
;	siz : size_t			;
;	cnt : size_t			;
	siz : long			;
	cnt : long			;
	res : int = 1			; assume o.k.

	setvbuf (src, <>, _IONBF, 0)	;
	setvbuf (dst, <>, _IONBF, 0)	;
	if fiVbuf eq			; need buffer
	.. dlc = fi_buf (<>, 8192*3)	; autobuffer
	if fiVbuf			; got a big buffer
	   buf = fiPbuf, siz = fiVbuf	;
	else				;
	.. buf = tra, siz = 1024	; use emergency buffer	
					;
	if !len				; no explicit size
	.. len = fi_len(src)-fi_pos(src); copy remainder of file
      repeat				;
	cnt = (siz lt len) ? siz ?? len	; minimize it
	if !fi_drd (src, buf, <size>cnt); read it
	|| !fi_dwr (dst, buf, <size>cnt); write it
	.. quit res = 0			; some error
	quit if (len -= cnt) eq		;
      end				;
	fi_buf (<>,0) if dlc		; deallocate buffer
	fail if fi_err (src, <>)	; check errors
	fail if fi_err (dst, <>)	;
	reply res			; status
  end
