file	firea - read/write file
#undef __STDC__				; need unix things
include <stdio.h>
include rid:rider
include rid:fidef
include rid:stdef
If Wdw || Wnt || Msc
#undef putchar
include	<io.h>
include	rid:cldef
End

;	fi_rea/fi_wri read 1 element of n bytes. Thus, they cannot report
;	the size of partial read/write (use fi_ipt/fi_opt). fi_rea/fi_wri
;	may be significantly faster than fi_ipt/fi_opt.

code -  fi_rea - read file

  func	fi_rea
	fil : * FILE
	buf : * void
	cnt : size_t
	()  : int 			; fine/fail
  is	fread (buf, cnt, 1, fil)	; read it
	reply that eq 1			; success
  end

code -  fi_wri - write file

  func	fi_wri
	fil : * FILE
	buf : * void
	cnt : size_t
	()  : int 			; fine/fail
  is	cnt = st_len(buf) if cnt eq ~(1); mumble mumble
If Wdw
	tmp : * char
	if cl_tty (fil)			; is console file
	   tmp = buf			; avoid casting
	   putchar (*tmp++) while cnt--	; ugh
	.. fine				;
End					;
	fwrite (buf, cnt, 1, fil)	; write it
	reply that eq 1			; wrote it all
  end
