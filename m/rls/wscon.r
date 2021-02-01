file	wscon - console application
include	rid:wsdef
include	rid:cldef
include	rid:imdef
include	rid:mxdef
include	rid:medef
include	rid:stdef
include	<stdio.h>
	main : (int, **char) int extern

;	Handles console applications 

  func	WinMain
	ins : HINSTANCE
	prv : HINSTANCE
	cmd : LPSTR
	sho : int
	()  : APIENTRY int
  is	buf : [512] char
	cnt : int = 0
	vec : ** char = <>
	st_cop ("image ", buf)			; dummy image name
	st_app (cmd, buf)			; the command
	cl_vec (buf, &cnt, &vec)		; leave space for image name
	main (cnt, vec)				;
	im_exi ()				;
  end
end file

code	ws_prt - printf replacement

;	Just bypass our renaming mechanism

  func	ws_prt
	fmt : * char const
	... : ...
  	()  : int
  is	vprintf(fmt, <va_list>&(fmt) + #fmt)
	fine
  end

code	ws_msg - write message

  func	ws_msg
	msg : * char
	obj : * char
  is	reply im_con (msg, obj)		; bypass the bypass
  end
