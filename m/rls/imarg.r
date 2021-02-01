file	imarg - get image argument
include	rid:rider

code	im_arg - get image argument

  func	im_arg
	arg : int			; argument number
	dst : * char			; destination buffer
	lim : int			; destination buffer limit
	cnt : int			; argument count
	vec : ** char			; argument vector
	()  : int			; -1 or number of chars in argument
  is	str : * char			;
	len : int = 0			;
	*dst = 0			; terminate buffer
	reply -1 if arg ge cnt		;
	str = vec[arg]			; get the string
	while len lt lim		;
	   *dst++ = *str++		;
	   quit if eq			; all done
	   ++len			; count it
	end				;
	reply len			;
  end
