file	cltty - test file for terminal
include	rid:rider
#undef __STDC__		; need old functions
include	<stdio.h>	; filno() (if __STDC__ eq)
include	<io.h>		; isatty ()

code	cl_tty - test file for terminal

;	Check file for terminal
;	Return null if not
;	Return output file if is

  func	cl_tty
	fil : * FILE
	()  : * FILE			; fine=>yes
  is	isatty (fileno (fil))		; is a terminal
	reply null if eq		; not a terminal
	reply stderr if fileno (fil) eq	; some do not permit writes to stdin
	reply fil			;
  end
