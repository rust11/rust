; ???	bal is overwritten
; ???	sep is not used
;Wnt := 1
code	cl_arg - returns nth argument 
include	rid:rider
include	rid:cldef
include	rid:ctdef
include	rid:medef
include	rid:mxdef
include	rid:stdef

	cl_ptr : (int, *char, int, *char, **char) int-

code	cl_arg - get nth argument from string

  func	cl_arg
	nth : int			; the argument required
	str : * char			; string to vectorize (and destroy)
	dst : * char			; result pointer
	sep : int			; the separator
	bal : * char			; the balance set
	()  : int			;
  is	src : * char			;
	len : int
	*dst = 0			; assume nothing
	len = cl_ptr(nth,str,sep,bal,&src); decode it
	pass fail			; nothing doing
	*<*char>me_mov (src,dst,len) = 0; copy it
	fine				;
  end

code	cl_ptr - get pointer to nth argument

  func	cl_ptr
	nth : int			; the argument required
	str : * char~			; string to vectorize (and destroy)
	sep : int			;
	bal : * char~			;
	res : ** char			; result pointer
	()  : int own			; length or fail
  is	fail if nth lt			; negative index
	sep = ' ' if sep eq		; default separator
	bal = "\"\'" if bal eq		;
      repeat				; the nth
	++str while ct_spc (*str)	; skip leading spaces
	quit if *str eq			; all done
	*res = str			; save start address
	while *str ne			; got more
	   bal = "\"\'"		;???	; balance set
	   while *bal ne		; look for balance member
	      if *str eq *bal++		; balance this one?
	   .. .. quit str = st_bal (str);
	   quit if *str eq ' ' || !*str	; gotcha or eol (from st_bal)
	   ++str			; try again
	end				;
 	quit if nth-- eq		; found it
	++str if *str ne		; skip terminator
      forever				; look at next
	fail if nth ge			; failed to find our dear one
	reply str-*res			; return the length of it
  end
end file
code	cl_vec - convert to string vector

  func	cl_vec
	str : * char			;
	cnt : * int			; result count
	ptr : *** char			; result string vector
	()  : int			; fine/fail
  is	nth : int = 0			;
	vec : ** char = *ptr		;
	if vec eq <>			; not allocated yet
	   vec = me_alc (33 * #<*char>)	; upto 32 parameters	   
	.. *ptr = vec			;
					;
	*cnt = 0			;
	*vec = st_dup ("")		; null string for first
	repeat				;
	   *++vec = <>			; terminate list
	   fail if *++cnt eq 32		; count and limit it
	   cl_nth (nth, str, *vec)	; get the nth 
	   fine if fail			; that was the last
	end				;
	fine				;
  end

code	cl_arg - get nth argument from string

  func	cl_arg
	nth : int			; the argument required
	str : * char			; string to vectorize (and destroy)
	dst : * char			; result pointer
	sep : int			; the separator
	bal : * char			; the balance set
	()  : int			;
  is	src : * char			;
	len : int
	len = cl_ptr(nth,str,sep,bal,&src); decode it
	pass fail			; nothing doing
	*<*char>me_mov (src,dst,len) = 0; copy it
	fine				;
  end

code	cl_ptr - get pointer to nth argument

  func	cl_ptr
	nth : int			; the argument required
	str : * char			; string to vectorize (and destroy)
	sep : int			;
	bal : * char			;
	res : ** char			; result pointer
	()  : int own			; length or fail
  is	fail if nth lt			; negative index
	sep = ' ' if sep eq		; default separator
	bal = "\"\'" if bal eq		;
      repeat				; the nth
	++str while ct_spc (*str)	; skip leading spaces
	quit if *str eq			; all done
	*res = str			; save start address
	while *str ne			; got more
	   bal = "\"\'"		;???	; balance set
	   while *bal ne		; look for balance member
	      if *str eq *bal++		; balance this one?
	   .. .. quit str = st_bal (str);
	   quit if *str eq ' ' || !*str	; gotcha or eol (from st_bal)
	   ++str			; try again
	end				;
 	quit if nth-- eq		; found it
	++str if *str ne		; skip terminator
      forever				; look at next
	fail if nth			; failed to find our dear one
	reply str-*res			; return the length of it
  end
