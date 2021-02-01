file	flrea - read/write file long
#undef __STDC__				; need unix things
include <stdio.h>
include rid:rider
include rid:fidef
include	rid:medef
include	rid:dsdef
If Wdw | Msc
#undef putchar
include	rid:cldef
include	<io.h>
End

;	fl_rea/fl_wri read 1 element of n bytes. Thus, they cannot report
;	the size of partial read/write (use fl_ipt/fl_opt). fl_rea/fl_wri
;	may be significantly faster than fl_ipt/fl_opt.

code -  fl_rea - read file

  func	fl_rea
	fil : * FILE
	buf : * voidL
	cnt : long
	()  : int 			; fine/fail
  is	rem : long = cnt 
	while rem ne			; got more
	   cnt = rem if rem lt 32*1024L	; last bit
	   cnt = 32*1024L otherwise	;
	   rem -= cnt			;
	   fread (<*void>buf, <int>cnt, 1, fil) ; read it
	   fail if ne 1			; missed this bit
	   <*huge char>buf += cnt	;
	end				;
	fine				;
  end

code -  fl_wri - write file

  func	fl_wri
	fil : * FILE
	buf : * voidL
	cnt : long
	()  : int 			; fine/fail
  is	rem : long = cnt 
If Wdw
	tmp : * char
	if cl_tty (fil)			; is console file
	   tmp = buf			; avoid casting
	   putchar (*tmp++) while cnt--	; ugh
	.. fine				;
End					;
	while rem ne			; got more
	   cnt = rem if rem lt 32*1024L	; last bit
	   cnt = 32*1024L otherwise	;
	   rem -= cnt			;
	   fwrite (<*void>buf, <int>cnt, 1, fil) ; read it
	   fail if ne 1			; missed this bit
	   <*huge char>buf += cnt	;
	end				;
	fine				;
  end
code	fl_loa - load huge file
include	rid:medef

;	me_alh	: (long) HVP
;	hread	: () long
;	siz = hread (_fileno (fil), src, 20)	;

	flLoa_siz := 1
	flLoa_opn := 2
	flLoa_spc := 3

  func	fl_loa
	spc : * char				;
	buf : ** voidL
	len : * long				;
	chn : ** FILE				;
	msg : * char				;
  is	siz : long = 0L				;
	fil : * FILE = <>			;
	src : * charL = <>			;
	res : int = 0				; assume failure
	cod : int = 0				;

      repeat					; fail block
	quit if (siz = fi_siz (spc)) eq		; no such file or what?
	quit if (fil = fi_opn (spc, "rb", "")) eq; no access
	quit if (src = ml_alc (siz)) eq		; yuk, no space
						;
	quit if !fl_rea (fil, src, siz)		; read large file
	*buf = src				; return pointers
	*len = siz				; total size
	*chn = fil if chn ne <>			; wants a channel
	fi_clo (fil, "") otherwise		;
	fine					;
      never
;	me_dlh (src) if src			; deallocate buffer
;	fi_clo (fil, "") if fil			; close file
	fail
  end


code	fl_sto -- store huge file


  func	fl_sto 
	spc : * char				;
	buf : * voidL				;
	siz : long				;
	fre : int				; free buffer
	msg : * char				; error message
  is	fil : * FILE				;
	if (fil = fi_opn (spc, "wb", "")) eq	; write a file
	|| fl_wri (fil, buf, siz) eq		;
	   fi_rep (spc, msg, "")		; say what happened
	   fi_clo (fil, "")			;
	.. fail					;
	fi_clo (fil, "")			; close it
	ml_dlc (buf) if fre			; want's buffer free'd
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
