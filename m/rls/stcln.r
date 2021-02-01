file	st_cln - clone -- copy limited string
include rid:rider
include rid:stdef

code	st_cln - clone -- copy limited string

;	st_cln (src, dst, cnt)
;
;	st_cln cnt does not include \0
;	st_fit cnt does
;
;	Copies N bytes (maximum)
;	Clears the following byte
;	Returns pointer to cleared byte

  func	st_cln
	src : * char~
	dst : * char~
	cnt : size~			; buffer length (excluding zero)
	()  : * char			; at terminator
  is	while cnt-- ne			; got more
	  quit if (*dst = *src) eq	;
	  ++dst, ++src			;
	end				;
	*dst = 0			; force termination
	reply dst			;
  end
