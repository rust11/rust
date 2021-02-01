file	fi_loa - load file
include rid:rider
include rid:fidef
include	rid:medef
include	rid:stdef
include <stdio.h>

include rid:dbdef

;	flLoa_siz := 1
;	flLoa_opn := 2
;	flLoa_spc := 3

  func	fi_loa
	spc : * char				;
	buf : ** void
	len : * size				;
	chn : ** FILE				;
	msg : * char				;
  is	siz : long = 0				;
	fil : * FILE = <>			;
	src : * char = <>			;
	res : int = 0				; assume failure
	cod : int = 0				;
      repeat					; fail block
	quit if (fil = fi_opn (spc, "rb", msg)) eq; no access
	siz = fi_len (fil)			; get the size of it
PUT("Load=%d\n", siz)
	quit if (src = me_alc (siz+2)) eq	; yuk, no space
	quit if siz && !fi_rea (fil, src, siz)	; read large file

	src[siz] = 0, src[siz+1] = 0		; double termination
	*buf = src				; return pointers
	*len = siz if len			; total size
	*chn = fil if chn			; wants a channel
	fi_clo (fil, "") otherwise		;
	fine					;
      never					;
	me_dlc (src) if src			; deallocate buffer
	fi_clo (fil, <>) if fil			; close file
	fail
  end
code	fi_sto -- store file

  func	fi_sto 
	spc : * char				;
	buf : * void				;
	siz : size				; -1 => compute size
	fre : int				; free bufferz
	msg : * char				; error message
  is	fil : * FILE				;

	siz = st_len (buf) if siz eq (~0)	; 
	if (fil = fi_opn (spc, "wb" ,msg)) eq	; write a file
	  ;db_lst ("cre")
	.. fail

	if siz && fi_wri (fil, buf, siz) eq	;
	  ;db_lst ("wri")
	   fi_rep (spc, msg, "spc")		; say what happened
	   fi_clo (fil, "")			;
	.. fail					;

	fi_clo (fil, "")			; close it
	fi_dlc (buf) if fre			; want's buffer free'd
	fine
  end

code	fi_dlc - deallocate file buffer

  func	fi_dlc
	buf : * void
  is	me_dlc (buf)				; dump the buffer
	fine
  end
end file
code	fl_drd - direct read file

  func	fl_drd
	fil : * FILE
	buf : * voidL
	cnt : long
	()  : int 			; fine/fail
  is
If Msc
	_read (fileno (fil), buf, cnt)	;
	reply <size>that eq cnt		; -1 or wrong count
Else
	reg : dsTreg
	seg : dsTseg
	DS=SEG(buf), DX=OFF(buf)	;
	BX = fileno (fil), CX=cnt	;
	ds_s21 (0x3f00)			;
	reply !CF && AX eq cnt		;
End
  end

code	fl_dwr - direct write file

  func	fl_dwr
	fil : * FILE
	buf : * voidL
	cnt : long
	()  : int 			; fine/fail
  is
If Msc
	fine if cnt eq			; do not truncate file
	_write (fileno (fil), buf, cnt)	;
	reply <size>that eq cnt		; -1 or wrong count
Else
	reg : dsTreg
	seg : dsTseg
	fine if cnt eq			; do not truncate file
	DS=SEG(buf), DX=OFF(buf)	;
	BX = fileno (fil), CX=cnt	;
	ds_s21 (0x4000)			;
	reply !CF && AX eq cnt		;
End
  end
