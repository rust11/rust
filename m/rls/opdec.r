file	opdec - output decimal
include rid:rider

	opVdec : int own = 0		; local divisor

code	op_dec - decimal output

  func	op_dec				; decimal out 
	val : int			; the value
	buf : * char			;
	()  : * char			;
  is	dig : int			; next digit
	prt : int = 0			; printing
	div : int = opVdec		; maximum digit
					;
	if div eq			; need divisor
	   div = 10000			; start it off
	   while (div * 10) gt 0	; got more
	   .. div *= 10			; do it again
	.. opVdec = div			; save it
					;
	if val lt 0			; humph
	   val = -val			; negate it
	.. *buf++ = '-'			; make it negative
					;
	repeat				;
	   dig = 0			; init that
	   while div le val		; got more
	      ++dig			;
	   .. val -= div		;
	   if prt |= dig		; printing things
	   .. *buf++ = dig + '0'	; write digit
	until (div /= 10) le 1		; done them all
	*buf++ = val + '0'		; last digit
	*buf = 0			; terminate it
	reply buf			; send it back
  end
