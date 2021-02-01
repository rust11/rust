file	st_kop - copy counted string
include rid:rider
include rid:stdef

code	st_kop - copy counted

  func	st_kop
	src : * char
	dst : * char
	cnt : int			; buffer length (including zero)
	()  : * char			; at terminator
  is	reply dst if cnt eq		; crazy
	while cnt-- ne			; got more
	  quit if (*dst++ = *src++) eq	;
	end				;
	*--dst = 0			; force termination
	reply dst			;
  end
