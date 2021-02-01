file	clwin - windows calls
include	rid:rider
include	rid:cldef
include	rid:stdef
include	<windows.h>

code	cl_dir - get directory out of the command line

;	The string may be enclosed in double-quotes

  func	cl_dir
	dir : * char
  is	buf : [256] char
	ptr : * char = buf
	lst : * char = buf
	fst : * char = buf
	*dir = 0
	cl_lin (buf)
	pass fail
	++ptr, ++fst if *ptr eq '"'	
	while *ptr && *ptr ne ' '
	   lst = ptr if *ptr eq '\\'
	   ++ptr
	   *ptr = ' 'if *ptr eq '"'	
	end
	fail if !lst		; didn't find a directory
	lst[1] = 0		; terminate it
	st_cop (fst, dir)	; return it
  end

  func	cl_lin
	lin : * char
  is	cmd : * char
	*lin = 0			; assume no cmmand
	cmd = GetCommandLine ()		;
	cmd = st_fnd (" ", cmd)		; skip image name
	pass fail			; no command
	++cmd if *cmd eq ' '		; skip space
	st_cop (cmd, lin)
	fine
  end
