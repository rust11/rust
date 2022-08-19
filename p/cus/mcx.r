file	mcx - issue RSX MCR command
include rid:rider
include rid:cldef
include rid:mxdef

;	%build
;	rider cus:mcx/object:cub:mcx
;	link cub:mcx/exe:cub:/map:cub:,lib:crt/cross/bott=2000 
;	%end

  	rsAmcr : [2] WORD+	; rad50 "MCR..." (see CTS:RSSPN)

  func	start
  is	cmd : [mxLIN] char
	sts : int
	im_ini ("MCX")
      repeat
	cl_cmd ("MCX> ", cmd)	; get command
	next if !cmd[0]		; no command
	exit if cl_mat (cmd, "EX*IT")
	rs_dti ()		; detach terminal input
	rs_int (0)		; interrupts off
	rs_spn (rsAmcr, cmd, &sts) ; issue MCR command
	rs_ati ()		; attach terminal
	rs_int (1)		; turn interrupts on
	rt_res ()		; soft reset
      forever
  end
