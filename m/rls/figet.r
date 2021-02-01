file	figet - get next line
include	<stdio.h>
include rid:rider
include	rid:fidef
include rid:chdef

code	fi_get - Returns next line from a file

;	Uses standard descriptors and GETC
;
;	Drops null, return and linefeed
;	Returns on end of line or end of file

  func	fi_get
	fil : * FILE 			; the file
	buf : * char			; the buffer
	cnt : int~			; maximum buffer size
	()  : int			; result count or EOF
  is	dot : * char~ = buf		; output
	cha : int~			; next character
	repeat				;
	   *dot = 0			; terminate it
	   quit if cnt eq		; done all
	   cha = getc (fil)		; next
	   pass EOF			; forget it
	   next if cha eq		; ignore nulls
		|| cha eq _cr		; and returns
	   quit if cha eq _nl		; done on newline
	   *dot++ = cha			; store it
	   --cnt			; count it
	forever				;
	reply (dot - buf)		; send back count
  end
