file	cldis - dispatch command
include	rid:rider
include	rid:cldef
include	rid:imdef

	E_InvCmd := "E-Invalid command"

code	cl_dis - dispatch command

  func	cl_dis
	env : * void			; passed to keyword routine
	str : * char			; potential command
	tab : * clTdis~			; command table
	msg : * char			; <>=no message, ""=default, else ours
	()  : int			; fail=not found
  is	while tab->Pkwd ne <>		; got more
	   if cl_mat (str, tab->Pkwd)	;
	   .. fine (*tab->Pfun)(env)	; do it
	   ++tab			; git the next
	end				;
	fail if msg eq <>		; want no message
	msg = E_InvCmd if *msg eq	; want default command
	fail im_rep (msg, str)		; report it
  end
