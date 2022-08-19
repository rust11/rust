file	DCX - issue RSX DCL command
include rid:rider
include rid:cldef
include rid:mxdef

;	%build
;	rider cus:dcx/object:cub:dcx
;	link cub:dcx/exe:cub:/map:cub:,lib:crt/cross/bott=2000 
;	%end
;
;	We need to stop the clock during DCL operations.
;	Otherwise the stack crashes, probably due to an interaction
;	between WTSE$ and MKTM$ asts.
;	Restarting the clock resets time to the current time

  	rsAdcl : [2] WORD+	; rad50 "...DCL" (see CTS:RSSPN)

  func	start
  is	cmd : [mxLIN] char
	sts : int
	im_ini ("DCX")
      repeat
	cl_cmd ("DCX> ", cmd)	; get command
	next if !cmd[0]		; no command
	exit if cl_mat (cmd, "EX*IT")
	rs_dti ()		; detach terminal input
	rs_int (0)		; interrupts off
	rs_spn (rsAdcl, cmd, &sts) ; issue DCL command
	rs_ati ()		; attach terminal
	rs_int (1)		; turn interrupts on
	rt_res ()		; soft reset
	im_rep ("W-Spawn failed: %d", sts) if sts lt
      forever
  end
