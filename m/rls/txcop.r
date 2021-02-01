file	tx_cop - copy counted string
include rid:rider
include rid:txdef

code	tx_cop - copy counted

  func	tx_cop
	src : * char
	dst : * char
	cnt : int			; buffer length (excluding zero)
	()  : * char			; at terminator
  is	reply dst if cnt eq		; crazy
	while cnt-- ne			; got more
	  quit if (*dst = *src) eq	;
	  ++dst, ++src			;
	end				;
	*dst = 0			; force termination
	reply dst			;
  end
