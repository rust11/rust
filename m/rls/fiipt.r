file	fiipt - input/output file
include rid:rider
include rid:fidef
include rid:stdef
include rid:cldef
include <stdio.h>

;	fi_ipt/fi_opt transfer n elements of 1 byte each. Thus they can return
;	partial transfer sizes - but may be slower than fi_rea/fi_wri.

code	fi_ipt - input file

  func	fi_ipt
	fil : * FILE
	buf : * void
	cnt : size_t
	()  : size_t			; bytes transferred
  is	fread (buf, 1, cnt, fil)	; read it
	reply that			;
  end

code -  fi_opt - write file

  func	fi_opt
	fil : * FILE
	buf : * void
	cnt : size_t
	()  : size_t			; bytes transferred
  is	tmp : * char
	cnt = st_len(buf) if cnt eq (~1); compute size
If Wdw
	if cl_tty (fil)			; is console file
	   tmp = buf			; avoid casting
	   putchar (*tmp++) while cnt--	; ugh
	.. reply cnt			;
End					;
	fwrite (buf, 1, cnt, fil)	; write it
	reply that			;
  end
